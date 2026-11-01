import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test('cancelled checkout does not claim a fresh PayPal confirmation', () {
    final text = AssistantModule.factualAnswer('payment_status', {
      'source': 'raysto_ledger',
      'status': 'cancelled',
      'currency': 'USD',
      'amountMinor': 100,
    })!;
    expect(text, contains('cancelled for USD 1.00'));
    expect(text, contains('PayPal was not queried'));
    expect(text, isNot(contains('PayPal reports')));
    expect(text, isNot(contains('REST fallback')));
  });
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
  test('a refund check says it is about a refund, not a payment', () {
    final text = AssistantModule.factualAnswer('payment_status', {
      'source': 'paypal_mcp',
      'status': 'COMPLETED',
      'checkoutId': 5,
      'refundId': 1,
      'currency': 'USD',
      'amountMinor': 500,
    })!;
    expect(text, contains('COMPLETED for refund 1 on checkout 5: USD 5.00'));
    expect(text, isNot(contains('mark the bill paid')));
  });
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
  test('unresolved payments are listed, or plainly reported as none', () {
    expect(
      AssistantModule.factualAnswer('unresolved_payments', {
        'checkouts': <Json>[],
        'exceptions': <Json>[],
      }),
      startsWith('No PayPal payment needs attention'),
    );
    final text = AssistantModule.factualAnswer('unresolved_payments', {
      'checkouts': <Json>[
        {
          'checkoutId': 9,
          'state': 'uncertain',
          'amountMinor': 1350,
          'currency': 'USD',
          'ageMinutes': 3,
        },
      ],
      'exceptions': <Json>[
        {
          'id': 1,
          'kind': 'captureAfterRelease',
          'amountMinor': 500,
          'currency': 'USD',
        },
      ],
    })!;
    expect(text, contains('1 checkout(s) and 1 payment exception(s)'));
    expect(text, contains('Checkout 9: uncertain, USD 13.50'));
    expect(text, contains('Exception 1: captureAfterRelease, USD 5.00'));
  });
}
