import 'package:raysto_server/src/services/restaurant_costing.dart';
import 'package:test/test.dart';

void main() {
  group('Fixed quantity and replacement costs', () {
    test('preserves six decimal places', () {
      expect(RestaurantCosting.quantity('0.000001'), 1);
      expect(RestaurantCosting.quantity('12.345678'), 12345678);
    });
    for (final v in ['0', '-1', 'NaN', '1e3', '0.1234567', '1000001']) {
      test(
        'rejects invalid quantity $v',
        () => expect(() => RestaurantCosting.quantity(v), throwsArgumentError),
      );
    }
    test(
      'kg to grams',
      () => expect(
        RestaurantCosting.lineCostMicros(
          unitCostMinor: 1000,
          quantityMicros: RestaurantCosting.quantity('150'),
          recipeUnit: 'g',
          purchaseUnit: 'kg',
        ),
        150000000,
      ),
    );
    test(
      'litres to ml',
      () => expect(
        RestaurantCosting.lineCostMicros(
          unitCostMinor: 200,
          quantityMicros: RestaurantCosting.quantity('250'),
          recipeUnit: 'ml',
          purchaseUnit: 'l',
        ),
        50000000,
      ),
    );
    test(
      'pack of twelve',
      () => expect(
        RestaurantCosting.lineCostMicros(
          unitCostMinor: 600,
          quantityMicros: RestaurantCosting.quantity('2'),
          recipeUnit: 'piece',
          purchaseUnit: 'piece',
          packSizeMicros: 12000000,
        ),
        100000000,
      ),
    );
    test(
      'yield increases purchase requirement',
      () => expect(
        RestaurantCosting.lineCostMicros(
          unitCostMinor: 1000,
          quantityMicros: RestaurantCosting.quantity('100'),
          recipeUnit: 'g',
          purchaseUnit: 'kg',
          yieldBps: 8000,
        ),
        125000000,
      ),
    );
    test(
      'fractional cents survive before recipe rounding',
      () => expect(
        RestaurantCosting.lineCostMicros(
          unitCostMinor: 100,
          quantityMicros: RestaurantCosting.quantity('1'),
          recipeUnit: 'g',
          purchaseUnit: 'kg',
        ),
        100000,
      ),
    );
    test(
      'dimension mismatch is not guessed',
      () => expect(
        () => RestaurantCosting.lineCostMicros(
          unitCostMinor: 100,
          quantityMicros: 1000000,
          recipeUnit: 'g',
          purchaseUnit: 'ml',
        ),
        throwsArgumentError,
      ),
    );
    test(
      'zero yield fails',
      () => expect(
        () => RestaurantCosting.lineCostMicros(
          unitCostMinor: 100,
          quantityMicros: 1000000,
          recipeUnit: 'g',
          purchaseUnit: 'g',
          yieldBps: 0,
        ),
        throwsArgumentError,
      ),
    );
  });
  Map<String, dynamic> scenario({
    int price = 800,
    int cost = 380,
    int target = 6000,
    int cap = 1000,
    int step = 10,
    int tax = 0,
    bool inclusive = false,
    int feeBps = 0,
    int fixed = 0,
    int units = 100,
    int volume = 0,
    int? restore,
  }) => RestaurantCosting.scenario(
    priceMinor: price,
    costMinor: cost,
    targetBps: target,
    maxIncreaseBps: cap,
    incrementMinor: step,
    taxBps: tax,
    pricesIncludeTax: inclusive,
    feeBps: feeBps,
    feeFixedMinor: fixed,
    baselineUnits: units,
    volumeChangeBps: volume,
    reviewedPriceMinor: restore,
  );
  group('Owner targets and transparent scenarios', () {
    test('restoration uses current costs and discloses an unmet target', () {
      final s = scenario(price: 970, cost: 385, restore: 900);
      expect(s['kind'], 'price-restoration');
      expect(s['recommended']['priceMinor'], 900);
      expect(s['recommended']['contributionMinor'], 515);
      expect(s['targetMet'], false);
      expect(s['current']['priceMinor'], 970);
    });
    test(
      'a reviewed restoration still respects price bounds and increments',
      () {
        expect(() => scenario(price: 970, restore: 2000), throwsArgumentError);
        expect(() => scenario(price: 970, restore: 905), throwsArgumentError);
        expect(() => scenario(price: 970, restore: -1), throwsArgumentError);
      },
    );
    test('unattainable target does not exceed cap', () {
      final s = scenario();
      expect(s['feasible'], false);
      expect(s['recommended'], null);
      expect(s['capMinor'], 880);
    });
    test('lowest allowed candidate reaches target', () {
      final s = scenario(target: 5000);
      expect((s['recommended'] as Map)['priceMinor'], 800);
    });
    test('current price retained even when not on rounding grid', () {
      expect(
        (scenario(price: 805, cost: 300, target: 5000)['recommended']
            as Map)['priceMinor'],
        805,
      );
    });
    test('price-sensitive fees change for each candidate', () {
      final s = scenario(cost: 380, target: 5000, feeBps: 500, fixed: 10);
      expect((s['recommended'] as Map)['priceMinor'], 870);
      expect((s['recommended'] as Map)['feeMinor'], 54);
    });
    test('tax inclusive revenue excludes tax', () {
      final s = scenario(price: 1100, cost: 300, inclusive: true, tax: 1000);
      expect((s['current'] as Map)['netPriceMinor'], 1000);
    });
    test(
      'tax on top remains outside contribution but enters estimated fees',
      () {
        final s = scenario(price: 1000, cost: 300, tax: 1000, feeBps: 100);
        expect((s['current'] as Map)['netPriceMinor'], 1000);
        expect((s['current'] as Map)['grossPriceMinor'], 1100);
        expect((s['current'] as Map)['feeMinor'], 11);
      },
    );
    test('sensitivity includes explicit custom assumption', () {
      final s = scenario(target: 5000, volume: -2500);
      final sensitivity = (s['sensitivity'] as List).cast<Map>();
      expect(sensitivity.last['units'], 75);
      expect(sensitivity.last['contributionMinor'], 31500);
    });
    test(
      'zero baseline has no misleading break-even',
      () => expect(scenario(cost: 800, target: 0)['breakEvenUnits'], null),
    );
    test(
      'negative baseline has no misleading break-even',
      () => expect(scenario(cost: 850, target: 0)['breakEvenUnits'], null),
    );
    test('rounding never publishes above cap', () {
      final s = scenario(
        price: 805,
        cost: 430,
        target: 5000,
        cap: 500,
        step: 100,
      );
      expect(s['recommended'], null);
    });
    test(
      'invalid fee rate is refused',
      () => expect(() => scenario(feeBps: 5001), throwsArgumentError),
    );
    test(
      'zero volume is refused',
      () => expect(() => scenario(units: 0), throwsArgumentError),
    );
    test(
      'work is bounded for tiny increments',
      () =>
          expect(() => scenario(price: 10000000, step: 1), throwsArgumentError),
    );
    test(
      'explains that demand is assumed',
      () => expect(
        (scenario()['assumptions'] as List).first,
        contains('not predicted'),
      ),
    );
  });
}
