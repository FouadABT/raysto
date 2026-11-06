import 'package:raysto_server/src/services/financial_narrative.dart';
import 'package:test/test.dart';

void main() {
  final evidence = {
    'currency': 'USD',
    'replacementCostMinor': 385,
    'change': {'costIncreaseMinor': 35},
    'scenario': {
      'recommended': {'priceMinor': 970},
    },
  };
  test('authorized prices and recorded changes can be quoted', () {
    expect(
      FinancialNarrative.amountsSupported(
        'The cost is \$3.85, up USD 0.35. The scenario recommends 9.70 USD.',
        evidence,
      ),
      true,
    );
  });
  test('invented amounts are refused', () {
    expect(
      FinancialNarrative.amountsSupported('The cost is \$4.00.', evidence),
      false,
    );
  });
  test('a correct number in an unauthorized currency is refused', () {
    expect(
      FinancialNarrative.amountsSupported('The cost is €3.85.', evidence),
      false,
    );
  });
  test('unknown amounts do not become zero', () {
    expect(
      FinancialNarrative.amountsSupported('The cost is \$0.00.', {
        'currency': 'USD',
        'costMinor': null,
      }),
      false,
    );
  });
  test('unitless money wording cannot evade the guard', () {
    expect(
      FinancialNarrative.amountsSupported('The cost is 4 dollars.', evidence),
      false,
    );
  });
  test('a qualified explanation without amounts remains usable', () {
    expect(
      FinancialNarrative.amountsSupported(
        'The receipt comparison records a cost increase. Demand response is assumed.',
        evidence,
      ),
      true,
    );
  });
  test('percentages and basis points require exact backend evidence', () {
    final data = {
      'targetBps': 6000,
      'contributionBps': 5722,
      'volumeChangeBps': -1500,
    };
    for (final text in [
      '60.00% target; 57.22 percent contribution',
      '15% fewer units',
      '-15.00% volume; 6,000 bps target',
    ]) {
      expect(
        FinancialNarrative.amountsSupported(text, data),
        true,
        reason: text,
      );
    }
    for (final text in [
      '59.26% at the cap',
      '57.2 percent contribution',
      '5926 basis points',
      '15.001% fewer units',
    ]) {
      expect(
        FinancialNarrative.amountsSupported(text, data),
        false,
        reason: text,
      );
    }
  });
}
