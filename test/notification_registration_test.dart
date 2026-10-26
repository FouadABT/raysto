import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/notification_registration.dart';

class _Store implements PushRegistrationStore {
  PushRegistration? value;
  @override
  Future<PushRegistration?> read() async => value;
  @override
  Future<void> write(PushRegistration? registration) async =>
      value = registration;
}

class _Device implements PushDevice {
  final changes = StreamController<String>.broadcast(sync: true);
  Completer<bool>? permission;
  bool allowed = true;
  bool enabled = false;
  String token = 'device-token-1';
  int deletions = 0;
  Completer<String?>? tokenGate;
  Completer<void>? tokenRequested;
  @override
  Future<bool> requestPermission() async => permission?.future ?? allowed;
  @override
  Future<void> setEnabled(bool value) async => enabled = value;
  @override
  Future<String?> getToken() async {
    tokenRequested?.complete();
    return tokenGate?.future ?? token;
  }

  @override
  Future<void> deleteToken() async {
    deletions++;
    token = 'fresh-token-$deletions';
  }

  @override
  Stream<String> get tokenChanges => changes.stream;
}

class _Backend implements PushBackend {
  @override
  String? userId = 'account-a';
  final rows = <String, String>{};
  Completer<void>? registerGate;
  Completer<void>? registerStarted;
  Completer<void>? registered;
  String? awaitedToken;
  bool offline = false;
  @override
  Future<void> register(String token) async {
    registerStarted?.complete();
    await registerGate?.future;
    if (offline) throw StateError('Offline');
    rows[token] = userId!;
    if (awaitedToken == null || awaitedToken == token) registered?.complete();
  }

  @override
  Future<void> unregister(String token) async {
    if (offline) throw StateError('Offline');
    if (rows[token] == userId) rows.remove(token);
  }
}

void main() {
  late _Store store;
  late _Device device;
  late _Backend backend;
  NotificationRegistration make([_Device? native]) => NotificationRegistration(
    device: native ?? device,
    backend: backend,
    store: store,
  );
  setUp(() {
    store = _Store();
    device = _Device();
    backend = _Backend();
  });

  test(
    'cold-start logout removes SQL registration without another opt-in',
    () async {
      await make().enable();
      expect(backend.rows, {'device-token-1': 'account-a'});
      final restartedDevice = _Device();
      await make(restartedDevice).disable();
      expect(backend.rows, isEmpty);
      expect(store.value, isNull);
      expect(restartedDevice.deletions, 1);
      expect(restartedDevice.enabled, isFalse);
    },
  );

  test(
    'logout completes while the permission dialog is still pending',
    () async {
      device.permission = Completer<bool>();
      final notifications = make();
      final enabling = expectLater(notifications.enable(), throwsStateError);
      await notifications.disable();
      backend.userId = null;
      device.permission!.complete(true);
      await enabling;
      expect(backend.rows, isEmpty);
      expect(device.enabled, isFalse);
    },
  );

  test('logout cleans a registration accepted after logout began', () async {
    backend.registerGate = Completer<void>();
    backend.registerStarted = Completer<void>();
    final notifications = make();
    final enabling = expectLater(notifications.enable(), throwsStateError);
    await backend.registerStarted!.future;
    final logout = notifications.disable();
    backend.registerGate!.complete();
    await Future.wait([enabling, logout]);
    expect(backend.rows, isEmpty);
    expect(store.value, isNull);
    expect(device.enabled, isFalse);
  });

  test(
    'token rotation replaces the old row and logout removes the new row',
    () async {
      final notifications = make();
      await notifications.enable();
      backend.registered = Completer<void>();
      device.changes.add('rotated-token');
      await backend.registered!.future;
      expect(backend.rows, {'rotated-token': 'account-a'});
      expect(store.value?.token, 'rotated-token');
      await notifications.disable();
      expect(backend.rows, isEmpty);
    },
  );

  test(
    'offline logout invalidates native token and retries SQL cleanup on login',
    () async {
      await make().enable();
      backend.offline = true;
      await expectLater(make().disable(), throwsStateError);
      expect(device.deletions, 1);
      expect(device.enabled, isFalse);
      expect(store.value?.enabled, isFalse);
      backend.offline = false;
      await make().resume();
      expect(backend.rows, isEmpty);
      expect(store.value, isNull);
      expect(device.enabled, isFalse);
    },
  );

  test(
    'another account receives a fresh token, never the old account token',
    () async {
      await make().enable();
      backend.userId = 'account-b';
      final next = make();
      await next.enable();
      expect(backend.rows['device-token-1'], 'account-a');
      expect(backend.rows[device.token], 'account-b');
      expect(device.token, isNot('device-token-1'));
      expect(store.value?.userId, 'account-b');
      await next.disable();
    },
  );

  test(
    'sign-in without prior opt-in performs no registration or native init',
    () async {
      await make().resume();
      expect(backend.rows, isEmpty);
      expect(store.value, isNull);
      expect(device.enabled, isFalse);
      expect(device.deletions, 0);
    },
  );

  test('permission denial does not enable or register notifications', () async {
    device.allowed = false;
    await expectLater(make().enable(), throwsStateError);
    expect(backend.rows, isEmpty);
    expect(store.value, isNull);
    expect(device.enabled, isFalse);
  });

  test('a queued refresh cannot add a token after logout', () async {
    final notifications = make();
    await notifications.enable();
    device.changes.add('late-token');
    await notifications.disable();
    expect(backend.rows, isEmpty);
    expect(store.value, isNull);
  });

  test('rotation during native token retrieval is not lost', () async {
    device.tokenGate = Completer<String?>();
    device.tokenRequested = Completer<void>();
    final notifications = make();
    backend.awaitedToken = 'rotated-during-get-token';
    backend.registered = Completer<void>();
    final enabling = notifications.enable();
    await device.tokenRequested!.future;
    device.changes.add('rotated-during-get-token');
    device.tokenGate!.complete('old-native-token');
    await enabling;
    await backend.registered!.future.timeout(const Duration(seconds: 2));
    expect(backend.rows, {'rotated-during-get-token': 'account-a'});
    expect(store.value?.token, 'rotated-during-get-token');
    await notifications.disable();
    expect(backend.rows, isEmpty);
    expect(store.value, isNull);
  });
}
