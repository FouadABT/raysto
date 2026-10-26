import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';

void main() {
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
