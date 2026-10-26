import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test(
    'provider pending status remains informational and exposes REST fallback',
    () {
      final text = AssistantModule.factualAnswer('payment_status', {
        'source': 'paypal_rest',
        'status': 'PAYER_ACTION_REQUIRED',
        'currency': 'USD',
        'amountMinor': 1350,
      })!;
      expect(text, contains('PAYER_ACTION_REQUIRED'));
      expect(text, contains('USD 13.50'));
      expect(text, contains('REST fallback'));
      expect(text, contains('does not mark the bill paid'));
    },
  );
  test('manager summary separates unpaid debt from collected revenue', () {
    final text = AssistantModule.factualAnswer('operations_summary', {
      'filter': 'billRequested',
      'currency': 'USD',
      'outstandingMinor': 2700,
      'rows': <Json>[
        {'label': 'Garden 1', 'outstandingMinor': 2700},
      ],
    })!;
    expect(text, contains('Showing 1 tables'));
    expect(text, contains('Garden 1: USD 27.00'));
    expect(text, contains('not collected revenue'));
    expect(AssistantModule.factualAnswer('quote_basket', {}), isNull);
  });
}
