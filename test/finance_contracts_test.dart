import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/finance_contracts.dart';

void main() {
  final cost = <String, dynamic>{
    'productId': 1,
    'currency': 'USD',
    'priceMinor': 900,
    'recipeVersion': 1,
    'complete': false,
    'replacementCostMinor': null,
    'contributionMinor': null,
  };
  test('unknown costs remain nullable in the native contract', () {
    expect(ProductCostDto.fromJson(cost).replacementCostMinor, null);
  });
  test('a complete response cannot silently substitute missing money', () {
    expect(
      () => ProductCostDto.fromJson({...cost, 'complete': true}),
      throwsFormatException,
    );
  });
  test('fractional monetary totals cannot cross the minor-unit boundary', () {
    expect(
      () => ProductCostDto.fromJson({...cost, 'priceMinor': 9.0}),
      throwsFormatException,
    );
  });
  test('a new owner policy has no inferred target', () {
    expect(
      PricingPolicyDto.fromJson({
        'version': 0,
        'confirmed': false,
        'targetBps': null,
        'maxIncreaseBps': 1000,
        'incrementMinor': 10,
      }).targetBps,
      null,
    );
  });
  test('a malformed feasible scenario is refused', () {
    expect(
      () => PricingScenarioDto.fromJson({
        'id': 1,
        'productId': 1,
        'feasible': true,
        'expiresAt': '2026-11-05T23:00:00Z',
        'current': {'priceMinor': 900},
        'recommended': null,
      }),
      throwsFormatException,
    );
  });
}
