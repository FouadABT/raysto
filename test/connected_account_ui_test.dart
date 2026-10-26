import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/auth/session_controller.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/account/live_account_screen.dart';
import 'package:raysto/l10n/app_localizations.dart';

import 'support/session_fakes.dart';

class _AuthFake implements FirebaseAuth {
  @override
  User? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RuntimeFake implements LiveRuntime {
  _RuntimeFake(this.session);
  final SessionController session;
  @override
  Future<void> Function(FirebaseAuthMultiFactorException)? resolveMultiFactor;
  @override
  SessionController createSession() => session;
  @override
  FirebaseAuth get firebase => _AuthFake();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host(LiveRuntime runtime, {String language = 'en', double scale = 1}) =>
    MotionScope(
      reducedMotion: true,
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: Locale(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: LiveAccountScreen(runtime: runtime),
      ),
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final jakarta = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      jakarta.addFont(
        rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
      );
    }
    await jakarta.load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });

  testWidgets(
    'real-account form and password recovery fit Arabic at 320px, 2x and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final session = SessionController(
        identity: IdentityFake(),
        backend: SessionFake(),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        host(_RuntimeFake(session), language: 'ar', scale: 2),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byWidgetPredicate(
          (w) => w is TextFormField && w.key == const ValueKey('sign-in-email'),
        ),
        180,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.test',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('نسيت كلمة المرور؟'),
        180,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'unverified live account shows email-link verification and no demo code',
    (tester) async {
      final identity = IdentityFake()
        ..current = const AccountIdentity(
          uid: 'unverified',
          email: 'user@example.test',
          verified: false,
        );
      final session = SessionController(
        identity: identity,
        backend: SessionFake(),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(host(_RuntimeFake(session)));
      await tester.pumpAndSettle();
      expect(find.text('I have verified my email'), findsOneWidget);
      expect(find.textContaining('123456'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
