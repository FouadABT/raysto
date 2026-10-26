import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raysto_client/raysto_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'session_controller.dart';
import '../firebase_options.dart';

class FirebaseIdentityGateway implements IdentityGateway {
  FirebaseIdentityGateway(this.auth, {this.resolveMultiFactor});
  final FirebaseAuth auth;
  final Future<void> Function(FirebaseAuthMultiFactorException)?
  resolveMultiFactor;
  static Future<void>? _googleInitialization;

  @override
  AccountIdentity? get current {
    final user = auth.currentUser;
    return user == null
        ? null
        : AccountIdentity(
            uid: user.uid,
            email: user.email,
            verified: user.emailVerified,
          );
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthMultiFactorException catch (e) {
      if (resolveMultiFactor == null) rethrow;
      await resolveMultiFactor!(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    await (_googleInitialization ??= GoogleSignIn.instance.initialize(
      clientId: RaystoFirebaseOptions.currentPlatform.iosClientId,
    ));
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw AccountSignInCanceled();
      }
      rethrow;
    }
    final token = account.authentication.idToken;
    if (token == null) throw StateError('Google did not return an ID token.');
    try {
      await auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: token),
      );
    } on FirebaseAuthMultiFactorException catch (e) {
      if (resolveMultiFactor == null) rethrow;
      await resolveMultiFactor!(e);
    }
  }

  @override
  Future<void> createAccount(String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendVerification() async {
    final user = auth.currentUser;
    if (user == null) throw StateError('No account is signed in.');
    await user.sendEmailVerification();
  }

  @override
  Future<void> reload() async => auth.currentUser?.reload();
  @override
  Future<String> freshToken() async {
    final token = await auth.currentUser?.getIdToken(true);
    if (token == null) {
      throw StateError('Sign in before connecting to the backend.');
    }
    return token;
  }

  @override
  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email);
  @override
  Future<void> signOut() async {
    try {
      if (_googleInitialization != null) {
        await _googleInitialization;
        await GoogleSignIn.instance.signOut();
      }
    } finally {
      await auth.signOut();
    }
  }
}

class ServerpodSessionGateway implements SessionGateway {
  ServerpodSessionGateway(this.client);
  final Client client;

  @override
  Future<void> restore() async {
    await client.auth.initialize();
  }

  @override
  Future<VerifiedBackendSession> exchange(String firebaseToken) async {
    // Reopening the account checks a fresh Firebase identity. Revoke the old
    // restored device session before replacing it rather than orphaning refresh
    // credentials in SQL on every app restart.
    if (client.auth.isAuthenticated) await client.auth.signOutDevice();
    final result = await client.firebase.login(idToken: firebaseToken);
    return VerifiedBackendSession(result.authUserId.toString(), result);
  }

  @override
  Future<void> commit(VerifiedBackendSession session) =>
      client.auth.updateSignedInUser(session.credentials as AuthSuccess);
  @override
  Future<void> clear() => client.auth.updateSignedInUser(null);
  @override
  Future<void> revoke() async {
    await client.auth.signOutDevice();
  }
}
