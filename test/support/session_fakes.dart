import 'dart:async';

import 'package:raysto/backend/auth/session_controller.dart';

class IdentityFake implements IdentityGateway {
  @override
  AccountIdentity? current;
  Completer<void>? pendingSignIn;
  bool verifiedOnSignIn = true;
  int signIns = 0;
  int verifications = 0;
  Object? googleError;
  @override
  Future<void> signInWithGoogle() async {
    if (googleError case final Object error) throw error;
    await signIn('google@example.test', '');
  }

  @override
  Future<void> signIn(String email, String password) async {
    signIns++;
    await pendingSignIn?.future;
    current = AccountIdentity(
      uid: 'firebase-user',
      email: email,
      verified: verifiedOnSignIn,
    );
  }

  @override
  Future<void> createAccount(String email, String password) async {
    current = AccountIdentity(uid: 'new-user', email: email, verified: false);
  }

  @override
  Future<void> sendVerification() async {
    verifications++;
  }

  @override
  Future<void> reload() async {}
  @override
  Future<String> freshToken() async => 'firebase-token';
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signOut() async {
    current = null;
  }
}

class SessionFake implements SessionGateway {
  VerifiedBackendSession? stored;
  Completer<VerifiedBackendSession>? pendingExchange;
  Object? exchangeError;
  bool revokeFails = false;
  int exchanges = 0;
  @override
  Future<void> restore() async {}
  @override
  Future<VerifiedBackendSession> exchange(String token) async {
    exchanges++;
    if (exchangeError case final Object error) throw error;
    return pendingExchange?.future ??
        const VerifiedBackendSession('server-user', 'secure-token');
  }

  @override
  Future<void> commit(VerifiedBackendSession session) async {
    stored = session;
  }

  @override
  Future<void> clear() async {
    stored = null;
  }

  @override
  Future<void> revoke() async {
    if (revokeFails) throw TimeoutException('Offline');
  }
}
