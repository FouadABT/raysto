import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/mobile_app.dart';
import 'package:raysto/domain/domain.dart';

void main() {
  testWidgets(
    'cold PayPal return bypasses demo onboarding and reaches connected entry',
    (tester) async {
      final demo = DemoStore();
      addTearDown(demo.dispose);
      Uri? received;
      await tester.pumpWidget(
        RaystoApp(
          demoStore: demo,
          initialRoute:
              'https://api.rays.to/payments/return?token=TESTORDER123',
          paymentReturnBuilder: (_, uri) {
            received = uri;
            return const Scaffold(body: Text('Connected payment return'));
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Connected payment return'), findsOneWidget);
      expect(received?.queryParameters['token'], 'TESTORDER123');
      expect(demo.sessionActive, isFalse);
    },
  );
  testWidgets(
    'warm path-only cancel reaches payment return without changing demo records',
    (tester) async {
      final demo = DemoStore();
      addTearDown(demo.dispose);
      Uri? received;
      await tester.pumpWidget(
        RaystoApp(
          demoStore: demo,
          paymentReturnBuilder: (_, uri) {
            received = uri;
            return const Scaffold(body: Text('Connected payment return'));
          },
        ),
      );
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.pushNamed('/payments/cancel?token=TESTORDER123');
      await tester.pumpAndSettle();
      expect(received?.path, '/payments/cancel');
      expect(demo.sessionActive, isFalse);
      expect(find.text('Connected payment return'), findsOneWidget);
    },
  );
}
