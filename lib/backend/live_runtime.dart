import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'platform_api.dart';

import 'auth/firebase_session.dart';
import 'auth/session_controller.dart';
import 'backend_connection.dart';
import 'cloud_account_services.dart';
import 'firebase_notifications.dart';
import 'firebase_options.dart';
import 'notification_registration.dart';
import '../payments/payment_adapters.dart';
import '../payments/payment_controller.dart';
import '../payments/payment_models.dart';

class LiveRuntime {
  LiveRuntime._(this.connection, this.firebase);
  final BackendConnection connection;
  final FirebaseAuth firebase;
  Future<void> Function(FirebaseAuthMultiFactorException)? resolveMultiFactor;
  final _secure = const FlutterSecureStorage();
  DateTime _appCheckRetry = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastAttestation;
  late final platform = PlatformApi(
    journal: const FlutterSecureStorage(),
    origin: connection.apiUrl,
    identity: () => _session?.userId,
    headers: () async {
      final bearer = await connection.client.authKeyProvider?.authHeaderValue;
      final token = await firebase.currentUser?.getIdToken();
      if (DateTime.now().isAfter(_appCheckRetry)) {
        try {
          _lastAttestation = await FirebaseAppCheck.instance.getToken().timeout(
            const Duration(seconds: 4),
          );
          _appCheckRetry = DateTime.now().add(const Duration(minutes: 5));
        } catch (_) {
          _appCheckRetry = DateTime.now().add(const Duration(minutes: 2));
        }
      }
      return {
        'Authorization': ?bearer,
        'X-Raysto-Firebase-Token': ?token,
        'X-Firebase-AppCheck': ?_lastAttestation,
      };
    },
    refreshCredentials: () async {
      final provider = connection.client.authKeyProvider;
      if (provider is RefresherClientAuthKeyProvider) {
        await provider.refreshAuthKey(force: true);
      }
      await firebase.currentUser?.getIdToken(true);
    },
  );
  late final cloud = CloudAccountServices(
    auth: firebase,
    firestoreDatabaseId: 'raysto-mobile',
    databaseUrl: RaystoFirebaseOptions.currentPlatform.databaseURL,
  );
  SessionController? _session;
  late final sandboxCheckout = SandboxCheckoutStarter(
    connection.client,
    connection.apiUrl.toString(),
  );
  late final payments = PaymentController(
    backend: ServerpodPaymentBackend(
      connection.client,
      () => _session?.phase == SessionPhase.ready && !_session!.busy
          ? _session!.userId
          : null,
    ),
    store: SecurePaymentStore(connection.apiUrl.toString()),
    browser: ExternalPaymentBrowser(),
    links: PayPalLinkPolicy(callbackOrigin: Uri.parse('https://api.rays.to')),
  );
  String? _servicesUser;
  late final _notifications = NotificationRegistration(
    device: FirebasePushDevice(),
    backend: ServerpodPushBackend(connection.client),
    store: SecurePushRegistrationStore(connection.apiUrl.toString()),
  );
  static Future<LiveRuntime>? _shared;

  static Future<LiveRuntime> shared({bool retry = false}) {
    if (retry) _shared = null;
    return _shared ??= initialize();
  }

  static Future<LiveRuntime> initialize() async {
    await Firebase.initializeApp(
      options: RaystoFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
    // Notification permission remains an explicit action after sign-in.
    await FirebaseMessaging.instance.setAutoInitEnabled(false);
    const configuredUrl = String.fromEnvironment('RAYSTO_API_URL');
    final apiUrl = configuredUrl.isNotEmpty
        ? configuredUrl
        : kDebugMode
        ? 'http://10.0.2.2:8080/'
        : throw StateError(
            'RAYSTO_API_URL is required for a connected release build.',
          );
    return LiveRuntime._(
      BackendConnection(Uri.parse(apiUrl)),
      FirebaseAuth.instance,
    );
  }

  SessionController createSession() {
    if (_session != null) return _session!;
    final session = SessionController(
      identity: FirebaseIdentityGateway(
        firebase,
        resolveMultiFactor: (e) async {
          final resolver = resolveMultiFactor;
          if (resolver == null) throw AccountSignInCanceled();
          await resolver(e);
        },
      ),
      backend: ServerpodSessionGateway(connection.client),
      guestLogin: () async {
        final token = await FirebaseAppCheck.instance.getToken(true);
        if (token == null) throw StateError('Device attestation required.');
        final result = await connection.client.guest.login(token: token);
        await _secure.write(
          key: 'raysto.guest.${connection.apiUrl}',
          value: result.authUserId.toString(),
        );
        _lastAttestation = token;
        return VerifiedBackendSession(result.authUserId.toString(), result);
      },
      guestRestore: () async {
        final id = await _secure.read(key: 'raysto.guest.${connection.apiUrl}');
        return connection.client.auth.authInfo?.authUserId.toString() == id
            ? id
            : null;
      },
      beforeSignOut: () async {
        await _secure.delete(key: 'raysto.guest.${connection.apiUrl}');
        await unregisterNotifications();
      },
    );
    session.addListener(() {
      if (session.phase != SessionPhase.ready ||
          session.busy ||
          session.isGuest) {
        payments.disconnect();
        _servicesUser = null;
        return;
      }
      unawaited(payments.connect(session.userId!));
      if (_servicesUser == session.userId) return;
      _servicesUser = session.userId;
      // Optional push recovery must not turn a valid sign-in into a failure.
      // It restores a saved opt-in, without asking for permission automatically.
      unawaited(_notifications.resume().catchError((Object _) {}));
    });
    return _session = session;
  }

  Future<void> saveGuestClaim() async {
    final ticket = await platform.command('identity.claimTicket', {});
    await _secure.write(
      key: 'raysto.guestClaim.${connection.apiUrl}',
      value: ticket['claimToken'] as String,
    );
  }

  Future<void> claimGuestActivity() async {
    final key = 'raysto.guestClaim.${connection.apiUrl}';
    final proof = await _secure.read(key: key);
    if (proof == null) {
      throw const PlatformFailure(
        'no_guest_claim',
        'No guest activity is waiting to be linked on this device.',
      );
    }
    await platform.command('identity.claim', {'claimToken': proof});
    await _secure.delete(key: key);
  }

  Future<void> enableNotifications() async {
    if (_session?.phase != SessionPhase.ready || _session!.busy) {
      throw StateError('Connect your account before enabling notifications.');
    }
    await _notifications.enable();
  }

  Future<void> unregisterNotifications() => _notifications.disable();
}
