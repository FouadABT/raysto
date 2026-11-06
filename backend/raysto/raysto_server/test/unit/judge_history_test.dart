import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

// The judges' cafés' sample history, planned without a database: the same
// café and day always give the same sales, café-sized and café-shaped.
void main() {
  final zone = CatalogueModule.zone('America/New_York');
  var id = 0;
  final menu = {
    for (final dish in JudgeModule.menu)
      dish['name'] as String: HistoryDish(
        productId: ++id,
        productVersion: 1,
        name: dish['name'] as String,
        priceMinor: dish['priceMinor'] as int,
        option: dish['modifiers'] == null
            ? null
            : HistoryOption(
                ((dish['modifiers'] as List).first as Json)['options'][0]['name'] as String,
                ((dish['modifiers'] as List).first as Json)['options'][0]['priceMinor'] as int,
              ),
      ),
  };
  final (days, _) = JudgeHistory.window(zone, DateTime.utc(2026, 11, 5, 15));
  List<HistoryDay> month(HistoryProfile p) => [
    for (final d in days)
      JudgeHistory.plan(profile: p, day: d, zone: zone, menu: menu),
  ];

  test('the window is the thirty local days before today, oldest first', () {
    expect(days, hasLength(30));
    expect(days.first, '2026-10-06');
    expect(days.last, '2026-11-04');
  });

  test('the same café and day always plan the same sales', () {
    final a = JudgeHistory.plan(profile: JudgeHistory.first, day: '2026-10-14', zone: zone, menu: menu);
    final b = JudgeHistory.plan(profile: JudgeHistory.first, day: '2026-10-14', zone: zone, menu: menu);
    expect(a.sales.map((x) => x.totalMinor), b.sales.map((x) => x.totalMinor));
    expect(a.sales.map((x) => x.at), b.sales.map((x) => x.at));
    expect(a.produceMinor, b.produceMinor);
    final other = JudgeHistory.plan(profile: JudgeHistory.second, day: '2026-10-14', zone: zone, menu: menu);
    expect(other.sales.length, lessThan(a.sales.length));
  });

  for (final profile in [JudgeHistory.first, JudgeHistory.second]) {
    test('${profile.key}: café-shaped days, tickets of \$14–22, a few refunds', () {
      final plan = month(profile);
      final sales = [for (final d in plan) ...d.sales];
      final total = sales.fold<int>(0, (n, x) => n + x.totalMinor);
      final average = total / sales.length;
      expect(average, inInclusiveRange(1400, 2200));
      // Tips on some orders, not all; a few single-item refunds, never a
      // whole order.
      final tipped = sales.where((x) => x.tipMinor > 0).length;
      expect(tipped / sales.length, inInclusiveRange(0.15, 0.35));
      final refunds = sales.where((x) => x.refundedUnit != null).toList();
      expect(refunds, isNotEmpty);
      expect(refunds.length, lessThan(sales.length ~/ 50));
      for (final x in refunds) {
        expect(x.refundMinor, lessThan(x.foodMinor));
      }
      // Lunch and dinner peaks; every sale inside opening hours, on its day.
      final byHour = <int, int>{};
      for (final d in plan) {
        for (final x in d.sales) {
          final local = tz.TZDateTime.from(x.at, zone);
          expect(BackOfficeModule.localDay({'timezone': 'America/New_York'}, x.at), d.day);
          expect(local.hour, inInclusiveRange(7, 20));
          byHour[local.hour] = (byHour[local.hour] ?? 0) + 1;
        }
      }
      expect(byHour[12]! + byHour[13]!, greaterThan(byHour[15]! + byHour[16]!));
      expect(byHour[19]!, greaterThan(byHour[16]!));
      // Weekends busier than weekdays, Tuesday the quietest weekday.
      int ordersOn(int weekday) => [
        for (final d in plan)
          if (tz.TZDateTime.from(d.produceAt, zone).weekday == weekday) d.sales.length,
      ].fold(0, (a, b) => a + b);
      expect(ordersOn(DateTime.saturday), greaterThan(ordersOn(DateTime.monday)));
      expect(ordersOn(DateTime.tuesday), lessThan(ordersOn(DateTime.wednesday)));
    });
  }

  // The costs the seed already books in any 30 days: the rent, water and
  // internet bills, and (first café only) last week's two receipts net of
  // their VAT.
  const fixed = {'atelier': 180000 + 4120 + 5999 + 47980 + 7956 - 589, 'harbour': 180000 + 4120 + 5999};
  for (final profile in [JudgeHistory.first, JudgeHistory.second]) {
    test('${profile.key}: whatever the day, the last 30 days net 15–22%', () {
      final cache = <String, HistoryDay>{};
      final margins = <double>[];
      for (var shift = 0; shift < 120; shift++) {
        final today = DateTime.utc(2026, 11, 5, 15).add(Duration(days: shift));
        final (window, _) = JudgeHistory.window(zone, today);
        var revenue = 0, costs = fixed[profile.key]!;
        for (final day in window) {
          final d = cache[day] ??= JudgeHistory.plan(profile: profile, day: day, zone: zone, menu: menu);
          for (final x in d.sales) {
            revenue += x.foodMinor - x.refundMinor;
          }
          costs += d.produceMinor + d.wagesMinor;
        }
        margins.add((revenue - costs) / revenue);
      }
      margins.sort();
      expect(margins.first, greaterThanOrEqualTo(0.155));
      expect(margins.last, lessThanOrEqualTo(0.215));
    });
  }
}
