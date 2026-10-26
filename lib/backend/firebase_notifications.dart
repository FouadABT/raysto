import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:raysto_client/raysto_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    show FlutterAuthSessionManagerExtension;

import 'notification_registration.dart';

class FirebasePushDevice implements PushDevice {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<void> setEnabled(bool enabled) =>
      _messaging.setAutoInitEnabled(enabled);

  @override
  Future<String?> getToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      if (await _messaging.getAPNSToken() == null) {
        throw StateError(
          'Apple notification registration is not ready. Retry later.',
        );
      }
    }
    return _messaging.getToken();
  }

  @override
  Future<void> deleteToken() => _messaging.deleteToken();
  @override
  Stream<String> get tokenChanges => FirebaseMessaging.instance.onTokenRefresh;
}

class ServerpodPushBackend implements PushBackend {
  ServerpodPushBackend(this.client);
  final Client client;
  @override
  String? get userId => client.auth.authInfo?.authUserId.toString();
  @override
  Future<void> register(String token) => client.commerce.registerDevice(token);
  @override
  Future<void> unregister(String token) =>
      client.commerce.unregisterDevice(token);
}

class SecurePushRegistrationStore implements PushRegistrationStore {
  SecurePushRegistrationStore(String apiUrl)
    : _key = 'raysto.push.v1.${base64Url.encode(utf8.encode(apiUrl))}';
  final String _key;
  static const _storage = FlutterSecureStorage();

  @override
  Future<PushRegistration?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    final value = jsonDecode(raw) as Map<String, dynamic>;
    return PushRegistration(
      value['userId'] as String,
      value['token'] as String,
      enabled: value['enabled'] == true,
    );
  }

  @override
  Future<void> write(PushRegistration? registration) => registration == null
      ? _storage.delete(key: _key)
      : _storage.write(
          key: _key,
          value: jsonEncode({
            'userId': registration.userId,
            'token': registration.token,
            'enabled': registration.enabled,
          }),
        );
}
