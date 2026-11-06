import 'package:raysto_server/src/services/restaurant_costing.dart';
import 'package:test/test.dart';

Map<String, dynamic> compare({
  int cap = 1000,
  int? candidate,
  int cost = 385,
  int units = 100,
  int response = 0,
}) => RestaurantCosting.comparison(
  priceMinor: 900,
  costMinor: cost,
  taxBps: 0,
  pricesIncludeTax: true,
  targetBps: 6000,
  maxIncreaseBps: cap,
  incrementMinor: 10,
  minimumMinor: 1,
  maximumMinor: 100000,
  feeBps: 0,
  feeFixedMinor: 0,
  baselineUnits: units,
  volumeChangeBps: response,
  candidatePriceMinor: candidate,
);

void main() {
  test(
    'alternatives use the same confirmed cost and exact break-even units',
    () {
      final v = compare();
      final options = v['options'] as List;
      expect(options[0]['contributionMinor'], 515);
      expect(options[1]['priceMinor'], 970);
      expect(options[1]['contributionMinor'], 585);
      expect(options[1]['breakEvenUnits'], 89);
      expect(options[1]['sensitivity'][1]['contributionMinor'], 52650);
      expect(options[1]['sensitivity'][2]['contributionMinor'], 46800);
      expect(v['keepPriceCostReductionMinor'], 25);
    },
  );
  test(
    'narrow cap retains keep and custom analyses without a false recommendation',
    () {
      final v = compare(cap: 500, candidate: 950);
      expect(v['feasible'], false);
      final custom = (v['options'] as List).last;
      expect(custom['publishable'], false);
      expect(
        custom['violations'],
        containsAll(['increase_cap', 'contribution_target']),
      );
      expect(custom['priceMinor'], 950);
    },
  );
  test('custom price obeys cap, increment and target independently', () {
    expect(
      (compare(candidate: 980)['options'] as List).last['publishable'],
      true,
    );
    expect(
      (compare(candidate: 975)['options'] as List).last['violations'],
      contains('rounding_increment'),
    );
    expect(
      (compare(candidate: 1100)['options'] as List).last['violations'],
      contains('increase_cap'),
    );
  });
  test('nonpositive baseline has no claimed break-even volume', () {
    for (final option in compare(cost: 1000)['options'] as List) {
      expect(option['breakEvenUnits'], null);
    }
  });
  test('custom volume uses integer units and input bounds are enforced', () {
    final custom =
        (compare(candidate: 980, units: 250, response: -1500)['options']
                as List)
            .last;
    expect(custom['sensitivity'].last['units'], 212);
    expect(() => compare(candidate: 0), throwsArgumentError);
    expect(() => compare(units: 0), throwsArgumentError);
  });
}
