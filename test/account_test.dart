import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/app.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/domain/domain.dart';
import 'package:raysto/features/account/account_screens.dart';
import 'package:raysto/l10n/app_localizations.dart';

Future<void> fonts() async {
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
}

Widget host(DemoStore store, Widget page, {double scale = 1}) =>
    ListenableBuilder(
      listenable: store,
      builder: (context, _) => MotionScope(
        reducedMotion: store.settings.reducedMotion,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: store.settings.appearance == 'dark'
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: Locale(store.settings.locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: page,
        ),
      ),
    );

Finder button(String label) => find.widgetWithText(AppButton, label);
Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 40,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(fonts);
  test(
    'every localization has two nonempty translations and both theme pairs meet text contrast',
    () {
      for (final entry in translations.entries) {
        expect(
          entry.value.$1.trim(),
          isNotEmpty,
          reason: '${entry.key} French',
        );
        expect(
          entry.value.$2.trim(),
          isNotEmpty,
          reason: '${entry.key} Arabic',
        );
      }
      expect(
        const AppLocalizations(
          Locale('fr'),
        ).tr('Garden bowl is unavailable. Remove it or choose a replacement.'),
        'Garden bowl est indisponible. Retirez-le ou choisissez un remplacement.',
      );
      expect(
        const AppLocalizations(
          Locale('ar'),
        ).tr('Choose 1–2 options for Dressing.'),
        'اختر من 1 إلى 2 خيارات لـ Dressing.',
      );
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        final c = theme.colorScheme;
        for (final pair in [
          (c.primary, c.onPrimary),
          (c.primaryContainer, c.onPrimaryContainer),
          (c.secondaryContainer, c.onSecondaryContainer),
          (c.tertiaryContainer, c.onTertiaryContainer),
          (c.surface, c.onSurface),
          (c.surface, c.onSurfaceVariant),
          (c.surfaceContainerLowest, c.onSurface),
          (c.error, c.onError),
        ]) {
          final a = pair.$1.computeLuminance(), b = pair.$2.computeLuminance();
          final contrast = ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
          expect(
            contrast,
            greaterThanOrEqualTo(4.5),
            reason: '${theme.brightness}: $pair',
          );
        }
      }
    },
  );

  testWidgets(
    'new customer one-tap entry reaches and resumes onboarding without losing the account',
    (tester) async {
      final store = DemoStore()..setDelayMode('instant');
      addTearDown(store.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      await reveal(tester, button('Explore demo accounts'));
      await tester.tap(button('Explore demo accounts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('new.customer@raysto.test'));
      await tester.pumpAndSettle();
      expect(store.currentAccount.id, 'new-customer');
      expect(find.text('Your Raysto, your preferences'), findsOneWidget);
      await reveal(tester, button('Continue'));
      await tester.tap(button('Continue'));
      await tester.pumpAndSettle();
      expect(store.currentAccount.onboardingStep, 1);
      await tester.tap(find.widgetWithText(FilterChip, 'Vegetarian'));
      expect(store.currentAccount.preferences['Vegetarian'], true);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      expect(find.text('What sounds good?'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'sign in can open account creation and verification must succeed before local creation',
    (tester) async {
      final store = DemoStore()..setDelayMode('instant');
      addTearDown(store.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      final signIn = find.widgetWithText(TextButton, 'Sign in');
      await reveal(tester, signIn);
      await tester.tap(signIn);
      await tester.pumpAndSettle();
      final create = find.widgetWithText(OutlinedButton, 'Create account');
      await reveal(tester, create);
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(field('Name'), findsOneWidget);
      await tester.enterText(field('Name'), 'Demo Jamie');
      await tester.enterText(field('Email'), 'jamie@raysto.test');
      await tester.enterText(field('Password'), 'RaystoDemo123!');
      await reveal(tester, button('Create account'));
      await tester.tap(button('Create account'));
      await tester.pumpAndSettle();
      expect(store.accounts.any((a) => a.email == 'jamie@raysto.test'), false);
      await tester.enterText(field('Verification code'), '000000');
      await tester.tap(button('Verify'));
      await tester.pump();
      expect(find.text('Wrong code. Try 123456.'), findsOneWidget);
      expect(store.accounts.any((a) => a.email == 'jamie@raysto.test'), false);
      await tester.enterText(field('Verification code'), '123456');
      await tester.tap(button('Verify'));
      await tester.pumpAndSettle();
      expect(store.currentAccount.email, 'jamie@raysto.test');
      expect(find.text('Your Raysto, your preferences'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'staff practice exercises real transitions without changing restaurant records',
    (tester) async {
      for (final account in ['waiter', 'kitchen', 'courier']) {
        final store = DemoStore()
          ..switchAccount(account)
          ..updateOnboardingStep(1);
        await tester.pumpWidget(host(store, OnboardingScreen(store: store)));
        await tester.pumpAndSettle();
        final actions = switch (account) {
          'waiter' => ['Acknowledge water request', 'Mark completed'],
          'kitchen' => ['Mark practice ticket ready'],
          _ => ['Confirm pickup', 'Start delivery', 'Confirm delivered'],
        };
        for (final action in actions) {
          await reveal(tester, button(action));
          await tester.tap(button(action));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.text('Practice complete'), findsOneWidget);
        expect(
          store.requests.firstWhere((r) => r.id == 'request-water').status,
          RequestStatus.sent,
        );
        expect(
          store.orders.firstWhere((o) => o.id == 'order-kitchen').status,
          OrderStatus.preparing,
        );
        expect(
          store.deliveries.firstWhere((d) => d.id == 'delivery-ready').status,
          DeliveryStatus.assigned,
        );
        await tester.pumpWidget(const SizedBox());
        store.dispose();
      }
    },
  );

  testWidgets(
    'verification refuses wrong and expired codes and allows a valid retry',
    (tester) async {
      final store = DemoStore();
      addTearDown(store.dispose);
      await tester.pumpWidget(host(store, VerificationScreen(store: store)));
      await tester.pumpAndSettle();
      await tester.enterText(field('Verification code'), '000000');
      await tester.tap(button('Verify'));
      await tester.pump();
      expect(find.text('Wrong code. Try 123456.'), findsOneWidget);
      store.advanceTime(const Duration(minutes: 6));
      await tester.enterText(field('Verification code'), '123456');
      await tester.tap(button('Verify'));
      await tester.pump();
      expect(
        find.text('Code expired. Request another demo code.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 31));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Resend demo code'));
      await tester.pump();
      expect(
        find.text('Code expired. Request another demo code.'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'account screens fit actual Arabic and French fonts at 320px and 2x in dark mode',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = DemoStore()
        ..switchAccount('customer')
        ..updateSettings(appearance: 'dark', reducedMotion: true);
      addTearDown(store.dispose);
      for (final locale in ['fr', 'ar']) {
        store.updateSettings(locale: locale);
        for (final page in <Widget>[
          SettingsScreen(store: store),
          LanguageAppearanceScreen(store: store),
          AccessibilityScreen(store: store),
          AddressBookScreen(store: store),
          NotificationSettingsScreen(store: store),
          DemoControlsScreen(store: store),
          OnboardingScreen(store: store),
        ]) {
          await tester.pumpWidget(host(store, page, scale: 2));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$locale ${page.runtimeType}',
          );
          expect(
            Directionality.of(tester.element(find.byType(Scaffold).first)),
            locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          final scroll = tester
              .state<ScrollableState>(find.byType(Scrollable).first)
              .position;
          for (var y = 0.0; y < scroll.maxScrollExtent; y += 600) {
            scroll.jumpTo(y.clamp(0, scroll.maxScrollExtent));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$locale ${page.runtimeType} at $y',
            );
          }
          scroll.jumpTo(scroll.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$locale ${page.runtimeType} bottom',
          );
          await tester.pumpWidget(const SizedBox());
        }
      }
    },
  );
}
