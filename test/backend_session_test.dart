import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/auth/session_controller.dart';

import 'support/session_fakes.dart';

void main() {
  late IdentityFake identity;
  late SessionFake backend;
  late SessionController controller;
  setUp(() {
    identity = IdentityFake();
    backend = SessionFake();
    controller = SessionController(identity: identity, backend: backend);
  });
  tearDown(() => controller.dispose());

  test('Firebase identity alone cannot enter the authenticated app', () async {
    identity.verifiedOnSignIn = false;
    await controller.signIn('user@example.test', 'password');
    expect(controller.phase, SessionPhase.verificationRequired);
    expect(controller.userId, isNull);
    expect(backend.exchanges, 0);
    expect(backend.stored, isNull);
  });

  test(
    'an attested guest restores without being upgraded to an account',
    () async {
      controller.dispose();
      controller = SessionController(
        identity: identity,
        backend: backend,
        guestRestore: () async => 'guest-user',
      );
      await controller.initialize();
      expect(controller.phase, SessionPhase.ready);
      expect(controller.isGuest, isTrue);
      expect(controller.userId, 'guest-user');
      expect(backend.exchanges, 0);
    },
  );

  test('a late guest login cannot restore access after logout', () async {
    controller.dispose();
    final pending = Completer<VerifiedBackendSession>();
    controller = SessionController(
      identity: identity,
      backend: backend,
      guestLogin: () => pending.future,
    );
    final login = controller.continueAsGuest();
    await Future<void>.delayed(Duration.zero);
    await controller.signOut();
    pending.complete(const VerifiedBackendSession('guest-user', 'token'));
    await login;
    expect(controller.phase, SessionPhase.signedOut);
    expect(controller.userId, isNull);
    expect(backend.stored, isNull);
  });

  test(
    'verified email exchanges its token and uses the server identity',
    () async {
      await controller.signIn('user@example.test', 'password');
      expect(controller.phase, SessionPhase.ready);
      expect(controller.userId, 'server-user');
      expect(backend.stored?.userId, 'server-user');
    },
  );

  test('backend failure clears stale credentials and does not expose provider secrets', () async {
    backend.stored = const VerifiedBackendSession('old-user', 'old-token');
    backend.exchangeError = StateError('private-provider-detail');
    await controller.signIn('user@example.test', 'password');
    expect(controller.phase, SessionPhase.failure);
    expect(controller.userId, isNull);
    expect(backend.stored, isNull);
    expect(controller.message, isNot(contains('private-provider-detail')));
  });

  test('late server exchange cannot resurrect a signed-out session', () async {
    backend.pendingExchange = Completer();
    final login = controller.signIn('user@example.test', 'password');
    await Future<void>.delayed(Duration.zero);
    expect(backend.exchanges, 1);
    await controller.signOut();
    backend.pendingExchange!.complete(
      const VerifiedBackendSession('server-user', 'token'),
    );
    await login;
    expect(controller.phase, SessionPhase.signedOut);
    expect(controller.userId, isNull);
    expect(backend.stored, isNull);
    expect(identity.current, isNull);
  });

  test('late Firebase sign-in is cleared after sign-out', () async {
    identity.pendingSignIn = Completer();
    final login = controller.signIn('user@example.test', 'password');
    await Future<void>.delayed(Duration.zero);
    await controller.signOut();
    identity.pendingSignIn!.complete();
    await login;
    expect(controller.phase, SessionPhase.signedOut);
    expect(identity.current, isNull);
    expect(backend.exchanges, 0);
    expect(backend.stored, isNull);
  });

  test(
    'sign-out clears both systems even when revocation is offline',
    () async {
      await controller.signIn('user@example.test', 'password');
      backend.revokeFails = true;
      await controller.signOut();
      expect(controller.phase, SessionPhase.signedOut);
      expect(backend.stored, isNull);
      expect(identity.current, isNull);
    },
  );

  test(
    'account creation sends verification and never grants demo staff rights',
    () async {
      await controller.createAccount('user@example.test', 'password');
      expect(identity.verifications, 1);
      expect(controller.phase, SessionPhase.verificationRequired);
      expect(backend.exchanges, 0);
      expect(controller.userId, isNull);
    },
  );

  test('rapid sign-in taps cause one identity request', () async {
    identity.pendingSignIn = Completer();
    final first = controller.signIn('user@example.test', 'password');
    final second = controller.signIn('user@example.test', 'password');
    await Future<void>.delayed(Duration.zero);
    expect(identity.signIns, 1);
    identity.pendingSignIn!.complete();
    await Future.wait([first, second]);
    expect(controller.phase, SessionPhase.ready);
  });

  test(
    'Google identity must exchange a token for the backend session',
    () async {
      await controller.signInWithGoogle();
      expect(identity.current?.email, 'google@example.test');
      expect(backend.exchanges, 1);
      expect(controller.userId, 'server-user');
      expect(controller.phase, SessionPhase.ready);
    },
  );

  test(
    'canceling Google sign-in leaves a signed-out state without an error',
    () async {
      identity.googleError = AccountSignInCanceled();
      await controller.signInWithGoogle();
      expect(backend.exchanges, 0);
      expect(controller.phase, SessionPhase.signedOut);
      expect(controller.message, isNull);
      expect(backend.stored, isNull);
    },
  );

  test(
    'a late Google response cannot restore an account after logout',
    () async {
      identity.pendingSignIn = Completer<void>();
      final login = controller.signInWithGoogle();
      await Future<void>.delayed(Duration.zero);
      await controller.signOut();
      identity.pendingSignIn!.complete();
      await login;
      expect(controller.phase, SessionPhase.signedOut);
      expect(identity.current, isNull);
      expect(backend.stored, isNull);
    },
  );

  test('logout hides identity immediately and blocks another sign-in during device cleanup', () async {
    await controller.signIn('user@example.test', 'password');
    final cleanup = Completer<void>();
    final logout = controller.signOut(beforeRevoke: () => cleanup.future);
    expect(controller.phase, SessionPhase.signedOut);
    expect(controller.userId, isNull);
    expect(controller.busy, isTrue);
    await controller.signIn('another@example.test', 'password');
    expect(identity.signIns, 1);
    cleanup.complete();
    await logout;
    expect(backend.stored, isNull);
    expect(identity.current, isNull);
    expect(controller.busy, isFalse);
  });

  test('reopening checks Firebase before exposing a previously stored backend identity', () async {
    await controller.signIn('user@example.test', 'password');
    identity.current = null;
    final opening = controller.initialize();
    expect(controller.phase, SessionPhase.starting);
    expect(controller.userId, isNull);
    await opening;
    expect(controller.phase, SessionPhase.signedOut);
    expect(backend.stored, isNull);
  });

  test(
    'runtime cleanup runs for every logout and failure still clears identity',
    () async {
      controller.dispose();
      var cleanups = 0;
      controller = SessionController(
        identity: identity,
        backend: backend,
        beforeSignOut: () async {
          cleanups++;
          throw StateError('Device cleanup offline');
        },
      );
      await controller.signIn('user@example.test', 'password');
      await controller.signOut();
      expect(cleanups, 1);
      expect(controller.phase, SessionPhase.signedOut);
      expect(backend.stored, isNull);
      expect(identity.current, isNull);
    },
  );
}
