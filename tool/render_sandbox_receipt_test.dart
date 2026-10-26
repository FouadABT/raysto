// Rendered fixture only: this is not evidence of a real PayPal capture.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/payment_ui_test.dart' show loadPaymentFonts;
import '../test/sandbox_receipt_ui_test.dart' show receiptHost;

void main() {
  setUpAll(loadPaymentFonts);
  testWidgets('render receipt fixture with real fonts', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('sandbox-receipt'),
        child: receiptHost(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('sandbox-receipt')),
      matchesGoldenFile(
        '../docs/qa/2026-10-25/paypal-sandbox-receipt-fixture.png',
      ),
    );
  });
}
