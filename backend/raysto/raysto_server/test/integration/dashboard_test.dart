// A judges' café reset stores a month of sample history.
@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The owner's dashboard: paid sales by
// the café's own days and hours, the period before, the kitchen now, the
// target, and, on a judges' café, the stored sample history every other page
// reads too.
void main() {
  withServerpod('The owner dashboard', (builder, endpoints) {
    late TestSessionBuilder owner, waiter;
    late Restaurant restaurant;
    late tz.Location zone;
    var serial = 0;
    String key() => 'dashboard_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user) => builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(user, {}),
    );
    Future<Json> read(String range, {TestSessionBuilder? who}) =>
        BackOfficeModule.read(
          (who ?? owner).build(),
          restaurantId: restaurant.id!,
          name: 'dashboard',
          d: {'range': range},
        );

    /// A placed order at [at], paid unless said otherwise.
    Future<PurchaseOrder> order(
      DateTime at, {
      int total = 1000,
      String status = 'completed',
      String payment = 'paid',
      String origin = 'online',
      int tip = 0,
    }) async {
      final s = builder.build();
      final o = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurant.id!,
          customerId: 'dash-diner',
          requestKey: key(),
          requestHash: 'h',
          fulfillment: 'pickup',
          lines: [],
          currency: 'USD',
          subtotalMinor: total,
          deliveryFeeMinor: 0,
          totalMinor: total,
          status: status,
          paymentStatus: payment,
          version: 1,
          createdAt: at.toUtc(),
          updatedAt: at.toUtc(),
        ),
      );
      await OrderContext.db.insertRow(
        s,
        OrderContext(
          restaurantId: restaurant.id!,
          orderId: o.id!,
          detailsJson: '{}',
          paymentTiming: 'before',
          cancellationRequested: false,
          stockReleased: false,
          origin: origin,
          orderNumber: o.id,
          createdAt: at.toUtc(),
        ),
      );
      if (tip > 0) {
        await BillCharge.db.insertRow(
          s,
          BillCharge(
            restaurantId: restaurant.id!,
            orderId: o.id!,
            lineKey: 'tip',
            kind: 'tip',
            amountMinor: tip,
            creditedMinor: 0,
            settledMinor: tip,
            reservedMinor: 0,
            foodNetMinor: 0,
            version: 1,
          ),
        );
      }
      return o;
    }

    tz.TZDateTime localNow() =>
        tz.TZDateTime.from(DateTime.now().toUtc(), zone);
    tz.TZDateTime midnight([int daysBack = 0]) {
      final n = localNow();
      return tz.TZDateTime(zone, n.year, n.month, n.day - daysBack);
    }

    setUp(() async {
      owner = session('dash-owner');
      waiter = session('dash-waiter');
      zone = CatalogueModule.zone('America/New_York');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final (user, name) in [
        ('dash-owner', 'Lina'),
        ('dash-waiter', 'Sam'),
        ('dash-diner', 'Diner'),
      ]) {
        await ActorProfile.db.insertRow(
          s,
          ActorProfile(
            userId: user,
            isGuest: false,
            disabled: false,
            dataJson: jsonEncode({'displayName': name}),
            version: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      final created = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Dashboard fixture","currency":"USD"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.settingsJson = jsonEncode({
        ...CatalogueModule.defaults,
        'taxConfigured': true,
        'address': 'Fixture street',
        'contactEmail': 'owner@example.test',
        'country': 'US',
        'timezone': 'America/New_York',
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: 'dash-waiter',
          role: 'waiter',
          active: true,
        ),
      );
    });
    tearDown(() => ProviderClients.environment = () => Platform.environment);

    test('days split at the café\'s own midnight, not UTC\'s', () async {
      final late = midnight(0).subtract(const Duration(minutes: 30));
      final early = midnight(0).add(const Duration(minutes: 30));
      await order(late, total: 700);
      await order(early, total: 1300);
      final d = await read('7d');
      final points = (d['points'] as List).cast<Json>();
      expect(d['granularity'], 'day');
      expect(points, hasLength(7));
      expect(points[5]['salesMinor'], 700);
      expect(points[6]['salesMinor'], 1300);
      expect(points[6]['start'], midnight(0).toUtc().toIso8601String());
      expect(d['from'], midnight(6).toUtc().toIso8601String());
      expect(d['to'], midnight(-1).toUtc().toIso8601String());
      expect(points.every((p) => (p['label'] as String).length == 3), isTrue);
      final kpis = d['kpis'] as Json;
      expect((kpis['sales'] as Json)['value'], 2000);
      expect((kpis['sales'] as Json)['series'], [0, 0, 0, 0, 0, 700, 1300]);
      expect((kpis['averageTicket'] as Json)['value'], 1000);
      final thirty = await read('30d');
      expect(thirty['points'], hasLength(30));
      final today = await read('today');
      expect(today['granularity'], 'hour');
      expect(today['points'], hasLength(localNow().hour + 1));
      expect(((today['points'] as List).first as Json)['label'], '0:00');
    });

    test(
      'only paid orders count; the kitchen counts what is open now',
      () async {
        final at = midnight(0).add(const Duration(minutes: 5));
        await order(at, total: 1000, tip: 150);
        await order(at, total: 500, status: 'preparing');
        await order(
          at,
          total: 9000,
          status: 'awaitingPayment',
          payment: 'unpaid',
        );
        await order(at, total: 9000, status: 'cancelled');
        await order(at, total: 9000, status: 'rejected');
        await order(at, total: 9000, status: 'expired');
        await order(at, total: 800, status: 'ready', origin: 'counter');
        final d = await read('7d');
        final kpis = d['kpis'] as Json;
        expect((kpis['sales'] as Json)['value'], 2300);
        expect((kpis['orders'] as Json)['value'], 3);
        expect((kpis['tips'] as Json)['value'], 150);
        expect(d['channels'], [
          {'channel': 'pickup', 'salesMinor': 1500, 'orders': 2},
          {'channel': 'counter', 'salesMinor': 800, 'orders': 1},
        ]);
        final kitchen = d['kitchen'] as Json;
        expect(kitchen['preparing'], 1);
        expect(kitchen['ready'], 1);
        expect(kitchen['submitted'], 0);
        expect(kitchen['oldestMinutes'], greaterThanOrEqualTo(0));
        expect((d['latest'] as List), hasLength(7));
        expect(((d['latest'] as List).first as Json).keys.toSet(), {
          'id',
          'number',
          'status',
          'paymentStatus',
          'fulfillment',
          'origin',
          'totalMinor',
          'currency',
          'createdAt',
          'customerLabel',
        });
        expect((d['target'] as Json)['todayMinor'], 2300);
      },
    );

    test('an empty period before gives a comparison, not a crash', () async {
      await order(midnight(0).add(const Duration(minutes: 1)), total: 1200);
      final d = await read('30d');
      final sales = (d['kpis'] as Json)['sales'] as Json;
      expect(sales['value'], 1200);
      expect(sales['previous'], 0);
      expect(((d['kpis'] as Json)['averageTicket'] as Json)['previous'], 0);
      final empty = await read('today');
      expect(empty['staff'], isEmpty);
    });

    test('today compares with yesterday up to the same time', () async {
      final elapsed = localNow().difference(midnight(0));
      final yesterday = midnight(1);
      await order(yesterday.add(elapsed ~/ 2), total: 400);
      await order(
        yesterday.add(elapsed + (const Duration(days: 1) - elapsed) ~/ 2),
        total: 9000,
      );
      final d = await read('today');
      expect(((d['kpis'] as Json)['sales'] as Json)['previous'], 400);
    });

    test('only owners and managers read it', () async {
      await expectLater(
        read('today', who: waiter),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      await expectLater(
        read('year'),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'invalid_input'),
        ),
      );
    });

    test('the daily target is a setting the owner sets', () async {
      final s = builder.build();
      Future<Json> set(int value) async {
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        return CatalogueModule.autonomy(
          owner.build(),
          PlatformCommand(
            requestKey: key(),
            restaurantId: restaurant.id,
            expectedVersion: policy.version,
            dataJson: jsonEncode({'dailyTargetMinor': value}),
          ),
        );
      }

      expect((await read('today'))['target'], {
        'dailyTargetMinor': 0,
        'todayMinor': 0,
      });
      expect((await set(25000))['dailyTargetMinor'], 25000);
      expect(((await read('7d'))['target'] as Json)['dailyTargetMinor'], 25000);
      for (final bad in [-1, 10000001]) {
        await expectLater(
          set(bad),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'invalid_input'),
          ),
        );
      }
    });

    test('the on-the-fly sample is retired, even where it was once switched on', () async {
      await order(midnight(1).add(const Duration(hours: 12)), total: 2150, tip: 200);
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_JUDGE_RESTAURANT_ID': '${restaurant.id}',
        'RAYSTO_JUDGE_SAMPLE_HISTORY': 'true',
      };
      for (final range in ['today', '7d', '30d']) {
        final d = await read(range);
        expect(d.containsKey('sample'), isTrue, reason: 'the contract keeps the field');
        expect(d['sample'], isNull, reason: range);
      }
      expect((((await read('7d'))['kpis'] as Json)['sales'] as Json)['value'], 2150);
    });

    test('a judges\' café: the dashboard, analytics, ledger and close read the same stored month', () async {
      final s = builder.build();
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_JUDGE_RESTAURANT_ID': '${restaurant.id}',
      };
      await JudgeModule.reset(s, restaurant.id!);
      for (final range in ['7d', '30d']) {
        final d = await read(range);
        final kpis = d['kpis'] as Json;
        final sales = (kpis['sales'] as Json)['value'] as int;
        final tips = (kpis['tips'] as Json)['value'] as int;
        final orders = (kpis['orders'] as Json)['value'] as int;
        expect(sales, greaterThan(0), reason: range);
        expect(d['sample'], isNull);
        // Cafe-sized tickets.
        expect(sales / orders, inInclusiveRange(1400, 2200), reason: range);
        // Today is a judge's own: the history never reaches it.
        final points = (d['points'] as List).cast<Json>();
        expect(points.last['salesMinor'], 0, reason: range);
        expect(points.first['salesMinor'], greaterThan(0), reason: range);
        // The ledger over the same window: every sale was cash at the till,
        // so what the till took is the dashboard's sales, and the sales
        // account is the same less the tips owed to the team.
        final journal = await LedgerModule.read(
          owner.build(),
          restaurantId: restaurant.id!,
          name: 'ledger.journal',
          d: {'from': d['from'], 'to': d['to']},
        );
        expect(journal['balanced'], isTrue);
        final totals = {
          for (final t in (journal['totals'] as List).cast<Map>()) t['account']: t,
        };
        expect(totals['1010']!['debitMinor'], sales, reason: range);
        expect(totals['4000']!['creditMinor'], sales - tips, reason: range);
        expect(totals['2200']!['creditMinor'], tips, reason: range);
        // Never a PayPal figure: no PayPal money, no PayPal fee.
        expect(totals.containsKey('1000'), isFalse, reason: range);
        expect(totals.containsKey('6000'), isFalse, reason: range);
        final analytics = await BackOfficeModule.read(
          owner.build(),
          restaurantId: restaurant.id!,
          name: 'analytics',
          d: {'from': d['from'], 'to': d['to']},
        );
        expect(analytics['salesMinor'], sales, reason: range);
        expect(analytics['orders'], orders, reason: range);
        expect(analytics['tipsMinor'], tips, reason: range);
        expect(analytics['paypalCapturedMinor'], 0, reason: range);
        expect(analytics['feesMinor'], 0, reason: range);
      }
      // The close of a day of the history reads the same till.
      final week = await read('7d');
      final day = (week['points'] as List).cast<Json>()[3];
      final close = await CloseAgent.readDay(
        s,
        restaurant.id!,
        BackOfficeModule.localDay({'timezone': 'America/New_York'}, DateTime.parse(day['start'] as String)),
      );
      expect(close['cashMinor'], day['salesMinor']);
      expect(close['paypalCapturedMinor'], 0);
      expect((close['books'] as Map)['cashInMinor'], day['salesMinor']);
      // The latest orders are the newest placed, whenever they were stored.
      final latest = (week['latest'] as List).cast<Json>();
      expect(latest, hasLength(8));
      final placed = [for (final o in latest) DateTime.parse(o['createdAt'] as String)];
      expect(placed, [...placed]..sort((a, b) => b.compareTo(a)));
    });

    test('the response has exactly the contract\'s fields', () async {
      final s = builder.build();
      final at = midnight(0).add(const Duration(minutes: 10));
      await order(at, total: 2150, tip: 100);
      await AuditRecord.db.insertRow(
        s,
        AuditRecord(
          restaurantId: restaurant.id,
          userId: 'dash-waiter',
          requestKey: key(),
          kind: 'order.ready',
          entityType: 'order',
          entityId: 1,
          detailsJson: '{}',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await StaffShift.db.insertRow(
        s,
        StaffShift(
          restaurantId: restaurant.id!,
          name: 'Omar',
          role: 'kitchen',
          startsAt: midnight(0).add(const Duration(hours: 1)).toUtc(),
          endsAt: midnight(0).add(const Duration(hours: 5)).toUtc(),
          hourlyRateMinor: 1800,
          version: 1,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      final d = await read('7d');
      final fixture =
          jsonDecode(
                File(
                  '../../../docs/fixtures/dashboard-7d.json',
                ).readAsStringSync(),
              )
              as Json;
      void same(dynamic a, dynamic b, String path) {
        // Retired in 0.16.2 and always null; the fixture keeps its old shape.
        if (path == 'dashboard.sample') {
          expect(a, isNull);
          return;
        }
        if (b is Map) {
          expect(a, isA<Map>(), reason: path);
          expect((a as Map).keys.toSet(), b.keys.toSet(), reason: path);
          for (final k in b.keys) {
            same(a[k], b[k], '$path.$k');
          }
        } else if (b is List && b.isNotEmpty && b.first is Map) {
          expect(a, isA<List>(), reason: path);
          expect((a as List), isNotEmpty, reason: path);
          same(a.first, b.first, '$path[0]');
        }
      }

      same(d, fixture, 'dashboard');
      final staff = (d['staff'] as List).cast<Json>();
      expect(staff.map((p) => p['name']), containsAll(['Sam', 'Omar']));
      expect(staff.firstWhere((p) => p['name'] == 'Sam')['ordersMoved'], 1);
      expect(staff.firstWhere((p) => p['name'] == 'Omar')['hours'], 4.0);
      expect(d['basis'], 'paidOrdersByCreatedAt');
      expect(d['timezone'], 'America/New_York');
      expect(d['currency'], 'USD');
    });
  });
}
