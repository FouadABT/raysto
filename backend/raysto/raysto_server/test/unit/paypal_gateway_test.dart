import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';

void main() {
  test(
    'reported capture fees preserve unknowns, currencies and actual zero',
    () {
      Map<String, dynamic> capture(String currency, Object value) => {
        'seller_receivable_breakdown': {
          'paypal_fee': {'currency_code': currency, 'value': value},
        },
      };
      expect(
        PayPalGateway.reportedCaptureFee(capture('USD', '0.71'), 'USD', 1000),
        71,
      );
      expect(
        PayPalGateway.reportedCaptureFee(capture('USD', '0.00'), 'USD', 1000),
        0,
      );
      expect(PayPalGateway.reportedCaptureFee({}, 'USD', 1000), null);
      expect(
        PayPalGateway.reportedCaptureFee(capture('EUR', '0.71'), 'USD', 1000),
        null,
      );
      for (final value in ['0.001', '-0.71', '11.00', 0.71]) {
        expect(
          PayPalGateway.reportedCaptureFee(capture('USD', value), 'USD', 1000),
          null,
        );
      }
    },
  );
  test('money uses integer minor units with no floating point rounding', () {
    expect(PayPalGateway.money(1), '0.01');
    expect(PayPalGateway.money(2200), '22.00');
    expect(PayPalGateway.parseMoney('22.00'), 2200);
    expect(
      () => PayPalGateway.parseMoney('22.001'),
      throwsA(isA<DomainError>()),
    );
    expect(
      () => PayPalGateway.parseMoney('-1.00'),
      throwsA(isA<DomainError>()),
    );
  });
}
