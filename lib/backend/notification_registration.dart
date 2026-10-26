import 'dart:async';

class PushRegistration {
  const PushRegistration(this.userId, this.token, {this.enabled = true});
  final String userId;
  final String token;
  final bool enabled;
}

abstract interface class PushRegistrationStore {
  Future<PushRegistration?> read();
  Future<void> write(PushRegistration? registration);
}

abstract interface class PushDevice {
  Future<bool> requestPermission();
  Future<void> setEnabled(bool enabled);
  Future<String?> getToken();
  Future<void> deleteToken();
  Stream<String> get tokenChanges;
}

abstract interface class PushBackend {
  String? get userId;
  Future<void> register(String token);
  Future<void> unregister(String token);
}

/// Keeps native token state and its SQL ownership together across app restarts.
/// Permission prompts run outside the queue so dismissing one cannot hold logout.
class NotificationRegistration {
  NotificationRegistration({
    required this.device,
    required this.backend,
    required this.store,
  });
  final PushDevice device;
  final PushBackend backend;
  final PushRegistrationStore store;
  Future<void> _work = Future.value();
  StreamSubscription<String>? _changes;
  int _generation = 0;

  Future<void> _serialize(Future<void> Function() action) {
    final next = _work.then((_) => action());
    _work = next.catchError((Object _) {});
    return next;
  }

  String _owner() =>
      backend.userId ??
      (throw StateError('Sign in before enabling notifications.'));

  void _check(int generation, String owner) {
    if (generation != _generation || backend.userId != owner) {
      throw StateError('Account changed during notification registration.');
    }
  }

  Future<void> enable() async {
    final generation = _generation;
    final owner = _owner();
    final allowed = await device.requestPermission();
    _check(generation, owner);
    if (!allowed) throw StateError('Notification permission was not granted.');
    await _serialize(() => _registerCurrent(generation, owner));
  }

  /// Restore only an earlier explicit opt-in, never prompt during sign-in.
  Future<void> resume() {
    final generation = _generation;
    final owner = _owner();
    return _serialize(() async {
      _check(generation, owner);
      final previous = await store.read();
      _check(generation, owner);
      if (previous == null || previous.userId != owner) return;
      if (!previous.enabled) {
        await _cleanup();
        return;
      }
      await _registerCurrent(generation, owner);
    });
  }

  Future<void> _registerCurrent(int generation, String owner) async {
    _check(generation, owner);
    final previous = await store.read();
    _check(generation, owner);
    if (previous != null && (!previous.enabled || previous.userId != owner)) {
      // An offline logout may have left a pending SQL cleanup. Never transfer
      // that account's native token to a different signed-in user.
      await device.deleteToken();
      _check(generation, owner);
      if (previous.userId == owner) await backend.unregister(previous.token);
      _check(generation, owner);
      await store.write(null);
    }
    await _changes?.cancel();
    _check(generation, owner);
    _changes = device.tokenChanges.listen((token) {
      unawaited(
        _serialize(() => _register(generation, owner, token))
            .catchError((Object _) {
              // Keep the stored registration for explicit retry or next resume.
            }),
      );
    }, onError: (Object _) {});
    // Subscribe before enabling/getToken: rotation during either native call
    // must queue an update instead of leaving SQL with an already stale token.
    await device.setEnabled(true);
    _check(generation, owner);
    final token = await device.getToken();
    _check(generation, owner);
    if (token == null) throw StateError('No notification token is available.');
    await _register(generation, owner, token);
    _check(generation, owner);
  }

  Future<void> _register(int generation, String owner, String token) async {
    _check(generation, owner);
    final previous = await store.read();
    _check(generation, owner);
    if (previous != null && previous.userId != owner) {
      throw StateError('A different account owns this registration.');
    }
    if (previous != null && previous.token != token) {
      await backend.unregister(previous.token);
      _check(generation, owner);
    }
    // Persist before HTTP: a timeout or process exit may occur after the server
    // accepts registration. Logout must still know which token to unregister.
    await store.write(PushRegistration(owner, token));
    _check(generation, owner);
    await backend.register(token);
  }

  Future<void> disable() {
    _generation++;
    final changes = _changes;
    _changes = null;
    return _serialize(() async {
      await changes?.cancel();
      await _cleanup();
    });
  }

  Future<void> _cleanup() async {
    var sqlRemoved = false;
    try {
      final registration = await store.read();
      sqlRemoved = registration == null;
      if (registration != null) {
        await store.write(
          PushRegistration(
            registration.userId,
            registration.token,
            enabled: false,
          ),
        );
        if (registration.userId == backend.userId) {
          await backend.unregister(registration.token);
          sqlRemoved = true;
        }
      }
    } finally {
      try {
        // Invalidate even when SQL is offline. Keep a disabled pending record
        // until its owner can retry cleanup; it must not auto-enable on login.
        await device.deleteToken();
        if (sqlRemoved) await store.write(null);
      } finally {
        await device.setEnabled(false);
      }
    }
  }
}
