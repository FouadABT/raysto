import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/payments/sandbox_test_screen.dart';
import 'package:raysto/l10n/app_localizations.dart';
import 'package:raysto_client/raysto_client.dart' as api;

import 'payment_ui_test.dart' show loadPaymentFonts;

Widget receiptHost({
  String language = 'en',
  double scale = 1,
  bool verifiedWebhook = false,
}) => MaterialApp(
  theme: AppTheme.light,
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    appBar: AppBar(title: const Text('PayPal Sandbox')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SandboxReceipt(
          payment: api.SandboxPayment(
            id: 7,
            userId: 'qa',
            requestKey: 'fixture',
            providerRequestId: 'fixture',
            amountMinor: 100,
            currency: 'USD',
            state: 'captured',
            providerOrderId: 'TESTORDER123456789',
            captureId: 'TESTCAPTURE1234567',
            createdAt: DateTime.utc(2026, 10, 25),
            webhookReceivedAt: verifiedWebhook
                ? DateTime.utc(2026, 10, 25)
                : null,
          ),
        ),
      ],
    ),
  ),
);

void main() {
  setUpAll(loadPaymentFonts);
  testWidgets(
    'capture and verified webhook remain independent receipt evidence',
    (tester) async {
      await tester.pumpWidget(receiptHost());
      await tester.pumpAndSettle();
      expect(find.text('Sandbox capture confirmed'), findsOneWidget);
      expect(find.text('Webhook: waiting for PayPal delivery'), findsOneWidget);
      expect(find.text('Webhook: verified and received'), findsNothing);
      await tester.pumpWidget(receiptHost(verifiedWebhook: true));
      await tester.pumpAndSettle();
      expect(find.text('Webhook: verified and received'), findsOneWidget);
    },
  );
  for (final language in ['en', 'fr', 'ar']) {
    testWidgets('receipt fits 320px and 2x text in $language', (tester) async {
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(receiptHost(language: language, scale: 2));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (language == 'ar') {
        expect(
          Directionality.of(tester.element(find.byType(SandboxReceipt))),
          TextDirection.rtl,
        );
      }
    });
  }
}
