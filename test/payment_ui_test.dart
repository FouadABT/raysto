import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/payments/payment_lab_screen.dart';
import 'package:raysto/l10n/app_localizations.dart';

Widget paymentHost({
  String language = 'en',
  double scale = 1,
  bool dark = false,
}) => MotionScope(
  reducedMotion: true,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: dark ? AppTheme.dark : AppTheme.light,
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
    home: const PaymentLabScreen(),
  ),
);

Future<void> loadPaymentFonts() async {
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
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  for (final (family, file) in [
    ('PhosphorRegular', 'Phosphor.ttf'),
    ('PhosphorFill', 'Phosphor-Fill.ttf'),
  ]) {
    await (FontLoader('packages/phosphor_flutter/$family')..addFont(
          rootBundle.load('packages/phosphor_flutter/lib/fonts/$file'),
        ))
        .load();
  }
}

void main() {
  setUpAll(loadPaymentFonts);
  Future<void> press(
    WidgetTester tester,
    String label, {
    bool app = false,
  }) async {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    final button = find.widgetWithText(app ? AppButton : OutlinedButton, label);
    await tester.scrollUntilVisible(
      button,
      180,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 35,
    );
    await tester.pumpAndSettle();
    final target = app
        ? find.descendant(of: button, matching: find.byType(InkWell))
        : button;
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('local lab completes through approval and backend confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(paymentHost());
    await tester.pumpAndSettle();
    expect(find.text('Local simulation — no PayPal requests'), findsOneWidget);
    await press(tester, 'Prepare test checkout', app: true);
    await press(tester, 'Simulate opening PayPal', app: true);
    await press(tester, 'Simulate buyer approval and return');
    expect(find.text('Payment confirmed'), findsNothing);
    await press(tester, 'Check and complete payment', app: true);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('Payment confirmed'), findsOneWidget);
    final reset = find.widgetWithText(TextButton, 'Reset local test');
    await tester.scrollUntilVisible(
      reset,
      180,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
    await tester.pumpAndSettle();
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await press(tester, 'Prepare test checkout', app: true);
    expect(find.text('Payment confirmed'), findsNothing);
    expect(find.text('Checkout saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final language in ['en', 'fr', 'ar']) {
    testWidgets('payment lab fits 320px, 2x text and $language in dark mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        paymentHost(language: language, scale: 2, dark: true),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('lab-response-loss')),
        250,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
