import 'dart:async';

import 'package:flutter/foundation.dart';

class AccountIdentity {
  const AccountIdentity({
    required this.uid,
    required this.email,
    required this.verified,
  });
  final String uid;
  final String? email;
  final bool verified;
}

abstract interface class IdentityGateway {
  AccountIdentity? get current;
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> createAccount(String email, String password);
  Future<void> sendVerification();
  Future<void> reload();
  Future<String> freshToken();
  Future<void> resetPassword(String email);
  Future<void> signOut();
}

class VerifiedBackendSession {
  const VerifiedBackendSession(this.userId, this.credentials);
  final String userId;
  final Object credentials;
}

/// User cancellation is a normal outcome, not a connection failure.
class AccountSignInCanceled implements Exception {}

abstract interface class SessionGateway {
  Future<void> restore();
  Future<VerifiedBackendSession> exchange(String firebaseToken);
  Future<void> commit(VerifiedBackendSession session);
  Future<void> clear();
  Future<void> revoke();
}

enum SessionPhase {
  starting,
  signedOut,
  verificationRequired,
  connecting,
  ready,
  failure,
}

/// Firebase proves identity; Serverpod supplies the actual backend session.
/// The UI never treats a Firebase sign-in alone as access to restaurant data.
class SessionController extends ChangeNotifier {
  SessionController({
    required this.identity,
    required this.backend,
    this.beforeSignOut,
    this.guestLogin,
    this.guestRestore,
  });
  final IdentityGateway identity;
  final SessionGateway backend;
  final Future<void> Function()? beforeSignOut;
  final Future<VerifiedBackendSession> Function()? guestLogin;
  final Future<String?> Function()? guestRestore;
  bool isGuest = false;
  SessionPhase phase = SessionPhase.starting;
  String? userId;
  String? message;
  bool _running = false;
  bool _signingOut = false;
  bool get busy => _running || _signingOut;
  bool _disposed = false;
  int _generation = 0;
  Future<void> _sessionWrites = Future.value();

  void _publish(SessionPhase next, {String? error}) {
    if (_disposed) return;
    phase = next;
    message = error;
    notifyListeners();
  }

  /// Serializes secure-storage writes, so a late exchange cannot restore a
  /// session after sign-out has already cleared it.
  Future<void> _write(Future<void> Function() action) {
    final operation = _sessionWrites.then((_) => action());
    _sessionWrites = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> initialize() => _run((generation) async {
    userId = null;
    _publish(SessionPhase.starting);
    await _write(backend.restore);
    if (identity.current == null && guestRestore != null) {
      final restored = await guestRestore!();
      if (restored != null && generation == _generation) {
        userId = restored;
        isGuest = true;
        _publish(SessionPhase.ready);
        return;
      }
    }
    await _synchronize(generation);
  });

  Future<void> continueAsGuest() => _run((generation) async {
    if (guestLogin == null) return;
    _publish(SessionPhase.connecting);
    final result = await guestLogin!();
    await _write(() async {
      if (generation != _generation) return;
      await backend.commit(result);
      if (generation != _generation) return;
      userId = result.userId;
      isGuest = true;
      _publish(SessionPhase.ready);
    });
  });

  Future<void> signIn(String email, String password) =>
      _run((generation) async {
        userId = null;
        _publish(SessionPhase.connecting);
        await _write(backend.clear);
        await identity.signIn(email.trim(), password);
        await _synchronize(generation);
      });

  Future<void> createAccount(String email, String password) =>
      _run((generation) async {
        userId = null;
        _publish(SessionPhase.connecting);
        await _write(backend.clear);
        await identity.createAccount(email.trim(), password);
        await identity.sendVerification();
        await _synchronize(generation);
      });

  Future<void> signInWithGoogle() => _run((generation) async {
    userId = null;
    _publish(SessionPhase.connecting);
    await _write(backend.clear);
    await identity.signInWithGoogle();
    await _synchronize(generation);
  });

  Future<void> retry() => _run((generation) async {
    await identity.reload();
    await _synchronize(generation);
  });

  Future<void> sendVerification() => _run((generation) async {
    await identity.sendVerification();
    if (generation == _generation) _publish(SessionPhase.verificationRequired);
  });

  Future<void> resetPassword(String email) => _run((generation) async {
    await identity.resetPassword(email.trim());
    if (generation == _generation) _publish(SessionPhase.signedOut);
  });

  Future<void> _synchronize(int generation) async {
    if (generation != _generation || _disposed) return;
    final account = identity.current;
    if (account == null || !account.verified) {
      await _write(backend.clear);
      userId = null;
      if (generation == _generation) {
        _publish(
          account == null
              ? SessionPhase.signedOut
              : SessionPhase.verificationRequired,
        );
      }
      return;
    }
    _publish(SessionPhase.connecting);
    final token = await identity.freshToken();
    if (generation != _generation || identity.current?.uid != account.uid) {
      return;
    }
    final verified = await backend.exchange(token);
    await _write(() async {
      if (generation != _generation || identity.current?.uid != account.uid) {
        return;
      }
      await backend.commit(verified);
      if (generation != _generation) return;
      userId = verified.userId;
      isGuest = false;
      _publish(SessionPhase.ready);
    });
  }

  Future<void> _run(Future<void> Function(int generation) action) async {
    if (busy || _disposed) return;
    _running = true;
    message = null;
    notifyListeners();
    final generation = _generation;
    try {
      await action(generation);
    } catch (error) {
      if (generation == _generation) {
        try {
          await _write(backend.clear);
        } catch (_) {}
        userId = null;
        if (error is AccountSignInCanceled) {
          _publish(SessionPhase.signedOut);
        } else {
          _publish(SessionPhase.failure, error: accountErrorMessage(error));
        }
      }
    } finally {
      if (generation != _generation) {
        try {
          await _write(backend.clear);
        } catch (_) {}
        try {
          await identity.signOut();
        } catch (_) {}
      }
      _running = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> signOut({Future<void> Function()? beforeRevoke}) async {
    if (_signingOut) return;
    _signingOut = true;
    _generation++;
    userId = null;
    _publish(SessionPhase.signedOut);
    // Local credentials are cleared even if server-side revocation is offline.
    try {
      try {
        await beforeSignOut?.call();
        await beforeRevoke?.call();
      } catch (_) {}
      await backend.revoke();
    } catch (_) {
    } finally {
      try {
        await _write(backend.clear);
      } finally {
        try {
          await identity.signOut();
        } finally {
          _signingOut = false;
          if (!_disposed) notifyListeners();
        }
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _disposed = true;
    super.dispose();
  }
}

/// Provider details and credentials must not be interpolated into UI errors.
String accountErrorMessage(Object error) => error is TimeoutException
    ? 'Connection timed out. Check your connection and try again.'
    : 'Could not connect your account. Please try again.';
