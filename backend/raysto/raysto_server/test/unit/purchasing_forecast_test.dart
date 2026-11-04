import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

// The supply arithmetic is plain code: the planner's AI explains it but
// never computes it. These are the numbers a manager sees.
void main() {
  final now = DateTime.utc(2026, 11, 4, 12);

  group('forecast', () {
    test('reorders when the stock left after the lead time is below the low mark', () {
      // 56 kg over 28 days = 2 kg a day; 10 kg lasts 5 days; after a 2-day
      // lead time 6 kg are left, under the 8 kg mark. Par is the larger of
      // twice the low mark (16) and usage over lead + 7 days (18).
      final f = PurchasingModule.forecast(
        quantity: 10,
        lowAt: 8,
        leadDays: 2,
        consumed: 56,
        unit: 'kg',
        now: now,
      );
      expect(f['dailyUsage'], 2.0);
      expect(f['daysCover'], 5.0);
      expect(f['stockOutAt'], '2026-11-09T12:00:00.000Z');
      expect(f['atArrival'], 6.0);
      expect(f['parLevel'], 18.0);
      expect(f['reorder'], isTrue);
      expect(f['suggestedQty'], 12.0);
    });

    test('an item with no usage reorders only when it is below its mark', () {
      final low = PurchasingModule.forecast(
        quantity: 3,
        lowAt: 5,
        leadDays: 2,
        consumed: 0,
        unit: 'kg',
        now: now,
      );
      expect(low['dailyUsage'], 0.0);
      expect(low['daysCover'], isNull);
      expect(low['stockOutAt'], isNull);
      expect(low['reorder'], isTrue);
      expect(low['suggestedQty'], 7.0, reason: 'up to twice the mark');
      final fine = PurchasingModule.forecast(
        quantity: 6,
        lowAt: 5,
        leadDays: 2,
        consumed: 0,
        unit: 'kg',
        now: now,
      );
      expect(fine['reorder'], isFalse);
      expect(fine['suggestedQty'], 0.0);
    });

    test('pieces and boxes are ordered whole, up to the par level', () {
      // 70 eggs over 28 days = 2.5 a day; 12 left minus 3 days = 4.5;
      // up to the par of 30 is 25.5, so 26 eggs.
      final f = PurchasingModule.forecast(
        quantity: 12,
        lowAt: 10,
        parLevel: 30,
        leadDays: 3,
        consumed: 70,
        unit: 'piece',
        now: now,
      );
      expect(f['dailyUsage'], 2.5);
      expect(f['daysCover'], 4.8);
      expect(f['atArrival'], 4.5);
      expect(f['suggestedQty'], 26.0);
    });

    test('an item that runs out before the delivery orders the whole par', () {
      final f = PurchasingModule.forecast(
        quantity: 5,
        lowAt: 4,
        leadDays: 2,
        consumed: 280,
        unit: 'l',
        now: now,
      );
      expect(f['daysCover'], 0.5);
      expect(f['atArrival'], -15.0);
      expect(f['parLevel'], 90.0);
      expect(f['suggestedQty'], 90.0);
    });

    test('a full shelf is left alone', () {
      final f = PurchasingModule.forecast(
        quantity: 100,
        lowAt: 8,
        leadDays: 2,
        consumed: 56,
        unit: 'kg',
        now: now,
      );
      expect(f['daysCover'], 50.0);
      expect(f['reorder'], isFalse);
      expect(f['suggestedQty'], 0.0);
    });

    test('rounding by unit', () {
      expect(PurchasingModule.roundQty(2.346, 'kg'), 2.35);
      expect(PurchasingModule.roundQty(2.01, 'box'), 3.0);
      expect(PurchasingModule.roundQty(12.0, 'piece'), 12.0);
    });
  });

  test('usage: order lines times recipe quantities', () {
    final used = PurchasingModule.usage(
      [
        OrderLine(productId: 1, name: 'Croissant', quantity: 4, unitPriceMinor: 300),
        OrderLine(productId: 2, name: 'Omelette', quantity: 2, unitPriceMinor: 900),
        OrderLine(productId: 3, name: 'Water', quantity: 1, unitPriceMinor: 100),
      ],
      [
        RecipeLine(restaurantId: 1, productId: 1, stockItemId: 10, quantity: 0.05, updatedAt: now),
        RecipeLine(restaurantId: 1, productId: 1, stockItemId: 11, quantity: 0.025, updatedAt: now),
        RecipeLine(restaurantId: 1, productId: 2, stockItemId: 11, quantity: 0.01, updatedAt: now),
        RecipeLine(restaurantId: 1, productId: 2, stockItemId: 12, quantity: 3, updatedAt: now),
      ],
    );
    expect(used, {10: 0.2, 11: 0.12, 12: 6.0});
  });

  group('the 3-way match', () {
    final ordered = [
      {'stockItemId': 1, 'name': 'Flour T55', 'unit': 'kg', 'qty': 25, 'unitCostMinor': 120},
      {'stockItemId': 2, 'name': 'Butter AOP', 'unit': 'kg', 'qty': 10, 'unitCostMinor': 980},
    ];

    test('a clean delivery and bill agree', () {
      final m = PurchasingModule.match(
        ordered: ordered,
        delivered: [
          {'name': 'flour t55', 'unit': 'kg', 'quantity': 25, 'unitCostMinor': 120},
          {'name': 'Butter AOP', 'unit': 'kg', 'quantity': 10, 'unitCostMinor': 1000},
        ],
        billTotalMinor: 13000,
      );
      expect(m['flagged'], 0, reason: 'a 2% price move is not flagged');
      expect(m['clean'], isTrue);
      expect(m['orderedTotalMinor'], 12800);
      expect(m['deliveredTotalMinor'], 13000);
    });

    test('short, dearer, missing and unordered lines are flagged', () {
      final m = PurchasingModule.match(
        ordered: [
          ...ordered,
          {'stockItemId': 3, 'name': 'Eggs', 'unit': 'piece', 'qty': 60, 'unitCostMinor': 32},
        ],
        delivered: [
          {'name': 'Flour T55', 'unit': 'kg', 'quantity': 20, 'unitCostMinor': 120},
          {'name': 'Butter AOP', 'unit': 'kg', 'quantity': 10, 'unitCostMinor': 1050},
          {'name': 'Sugar', 'unit': 'kg', 'quantity': 2, 'unitCostMinor': 300},
        ],
        billTotalMinor: 13600,
      );
      final lines = (m['lines'] as List).cast<Map>();
      Map line(String name) => lines.firstWhere((l) => l['name'] == name);
      expect(line('Flour T55')['flags'], ['short']);
      expect(line('Flour T55')['qtyVariance'], -5.0);
      expect(line('Butter AOP')['flags'], ['price_up']);
      expect(line('Butter AOP')['priceVariancePct'], 7.1);
      expect(line('Eggs')['flags'], ['missing']);
      expect(line('Sugar')['flags'], ['not_ordered']);
      expect(m['flagged'], 4);
      expect(m['deliveredTotalMinor'], 2400 + 10500 + 600);
      expect(m['billDiffers'], isTrue, reason: 'the bill charges 13600, the note 13500');
      expect(m['clean'], isFalse);
    });

    test('a bill line priced differently from the note is flagged', () {
      final m = PurchasingModule.match(
        ordered: ordered,
        delivered: [
          {'name': 'Flour T55', 'unit': 'kg', 'quantity': 25, 'unitCostMinor': 120},
          {'name': 'Butter AOP', 'unit': 'kg', 'quantity': 10, 'unitCostMinor': 980},
        ],
        billed: [
          {'name': 'Butter AOP', 'unitCostMinor': 990},
        ],
      );
      final butter = (m['lines'] as List).cast<Map>().firstWhere((l) => l['name'] == 'Butter AOP');
      expect(butter['flags'], ['billed_differs']);
      expect(m['clean'], isFalse);
    });
  });
}
