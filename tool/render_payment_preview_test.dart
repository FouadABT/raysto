// Regenerate explicitly with flutter test tool/render_payment_preview_test.dart --update-goldens.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/features/payments/payment_panel.dart';
import 'package:raysto/payments/testing/payment_lab.dart';

import '../test/payment_ui_test.dart' show loadPaymentFonts, paymentHost;

void main() {
  setUpAll(loadPaymentFonts);
  testWidgets('render payment core review states with bundled fonts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('payment-review'),
        child: paymentHost(),
      ),
    );
    await tester.pumpAndSettle();
    final controller = tester
        .widget<PaymentPanel>(find.byType(PaymentPanel))
        .controller;
    final backend = controller.backend as LabPaymentBackend;
    Future<void> render(String name) async {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('payment-review')),
        matchesGoldenFile('../docs/qa/2026-10-25/paypal-core-$name.png'),
      );
    }

    await render('lab');
    await controller.prepare('LAB-001');
    await tester.pumpAndSettle();
    await render('ready');
    await controller.openApproval();
    backend.approved = true;
    backend.loseNextCaptureResponse = true;
    await controller.complete();
    await tester.pumpAndSettle();
    await render('uncertain');
    await controller.refresh();
    await tester.pumpAndSettle();
    await render('recovered');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(320, 780);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('payment-review'),
        child: paymentHost(language: 'ar', scale: 2, dark: true),
      ),
    );
    await tester.pumpAndSettle();
    await render('ar-2x');
  });
}
