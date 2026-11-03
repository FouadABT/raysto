import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The supplies, expenses and loyalty
// agents, the copilot's roster, and the analytics read, with a scripted
// Gemini: the vision answer is what the sample photos in
// docs/qa/2026-11-03 print, and the tool turns are fixed.
void main() {
  withServerpod('The back-office agents', (builder, endpoints) {
    late TestSessionBuilder owner, waiter;
    late Restaurant restaurant;
    var serial = 0;
    String key() => 'money_agents_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user) => builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(user, {}),
    );
    PlatformCommand command(Json data, {int? id, int? version}) =>
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: id,
          expectedVersion: version,
          dataJson: jsonEncode(data),
        );
    Future<Json> read(String name, [Json d = const {}]) =>
        BackOfficeModule.read(
          owner.build(),
          restaurantId: restaurant.id!,
          name: name,
          d: d,
        );
    Future<Json> decide(AgentAction a) => AgentModule.decide(
      owner.build(),
      PlatformCommand(
        requestKey: key(),
        restaurantId: restaurant.id,
        resourceId: a.id,
        expectedVersion: a.version,
        dataJson: '{"decision":"approve"}',
      ),
    );
    Future<List<AgentAction>> runTask(int taskId) async {
      final s = builder.build();
      await AgentModule.run(s, taskId);
      final task = (await AgentTask.db.findById(s, taskId))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      return AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(taskId),
        orderBy: (t) => t.ordinal,
      );
    }

    String sse(List<Json> parts) =>
        'data: ${jsonEncode({
          'candidates': [
            {
              'index': 0,
              'content': {'role': 'model', 'parts': parts},
              'finishReason': 'STOP',
            },
          ],
          'usageMetadata': {'promptTokenCount': 900, 'candidatesTokenCount': 120, 'totalTokenCount': 1020},
        })}\r\n\r\n';
    Json call(String name, Json args) => {
      'functionCall': {'name': name, 'args': args},
    };

    /// Scripts Gemini: the photo answer, then one list of parts per turn.
    void gemini({Json? photo, required List<List<Json>> turns}) {
      var turn = 0;
      ProviderClients.httpClient = () => MockClient((r) async {
        if (r.url.path.endsWith(':countTokens')) {
          return http.Response('{"totalTokens": 900}', 200);
        }
        final parts = r.body.contains('inlineData')
            ? [
                {'text': jsonEncode(photo)},
              ]
            : turns[turn++];
        return http.Response.bytes(
          utf8.encode(sse(parts)),
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });
    }

    Future<MediaAsset> photo() => MediaAsset.db.insertRow(
      builder.build(),
      MediaAsset(
        restaurantId: restaurant.id,
        userId: 'ma-owner',
        purpose: 'support',
        objectName: 'v2/sanitized/fixture/${key()}.jpg',
        mime: 'image/jpeg',
        byteLength: 3,
        sha256: 'fixture',
        status: 'approved',
        public: false,
        metadataJson: '{}',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    Future<void> paidOrder(String customer, DateTime at, int totalMinor) async {
      final s = builder.build();
      final o = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurant.id!,
          customerId: customer,
          requestKey: key(),
          requestHash: 'fixture',
          fulfillment: 'pickup',
          lines: [OrderLine(productId: 1, name: 'Lunch', quantity: 1, unitPriceMinor: totalMinor)],
          currency: 'USD',
          subtotalMinor: totalMinor,
          deliveryFeeMinor: 0,
          totalMinor: totalMinor,
          status: 'completed',
          paymentStatus: 'paid',
          version: 1,
          createdAt: at,
          updatedAt: at,
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
          stockReleased: true,
          origin: 'online',
          createdAt: at,
        ),
      );
    }

    setUp(() async {
      owner = session('ma-owner');
      waiter = session('ma-waiter');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final (user, name) in [('ma-owner', 'Owner'), ('ma-waiter', 'Sam'), ('ma-anna', 'Anna'), ('ma-bilal', 'Bilal'), ('ma-chloe', 'Chloé')]) {
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
          dataJson: '{"name":"Money agents fixture","currency":"USD"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
      restaurant.published = true;
      await Restaurant.db.updateRow(s, restaurant);
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
        'hours': [
          for (var day = 1; day <= 7; day++)
            {'day': day, 'start': 420, 'end': 1320},
        ],
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      await Membership.db.insertRow(
        s,
        Membership(restaurantId: restaurant.id!, userId: 'ma-waiter', role: 'waiter', active: true),
      );
      AgentModule.environment = () => {
        ...Platform.environment,
        'RAYSTO_AGENT_SUPPLIES_ENABLED': 'true',
        'RAYSTO_AGENT_EXPENSES_ENABLED': 'true',
        'RAYSTO_AGENT_LOYALTY_ENABLED': 'true',
        'RAYSTO_AGENT_COPILOT_ENABLED': 'true',
      };
      ProviderClients.environment = () => {
        ...Platform.environment,
        'GEMINI_API_KEY': 'fixture-key',
      }..remove('RAYSTO_PAYPAL_REPORTING_ENABLED');
      MenuAgent.readFile = (_) async => Uint8List.fromList([0xff, 0xd8, 0xff]);
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      ProviderClients.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
      MenuAgent.readFile = ProviderClients.getFile;
    });

    test('a delivery note tops up stock and proposes the supplier payout', () async {
      final s = builder.build();
      final lines = [
        {'name': 'Flour T55', 'quantity': 25, 'unit': 'kg', 'unitCostMinor': 120},
        {'name': 'Butter AOP', 'quantity': 10, 'unit': 'kg', 'unitCostMinor': 980},
        {'name': 'Free-range eggs', 'quantity': 180, 'unit': 'piece', 'unitCostMinor': 32},
        {'name': 'Button mushrooms', 'quantity': 6, 'unit': 'kg', 'unitCostMinor': 650},
        {'name': 'Arborio rice', 'quantity': 8, 'unit': 'kg', 'unitCostMinor': 390},
        {'name': 'Gruyère', 'quantity': 4, 'unit': 'kg', 'unitCostMinor': 1800},
        {'name': 'Espresso beans', 'quantity': 5, 'unit': 'kg', 'unitCostMinor': 2200},
        {'name': 'Oranges', 'quantity': 20, 'unit': 'kg', 'unitCostMinor': 210},
      ];
      await BackOfficeModule.saveStock(
        owner.build(),
        command({'name': 'Oranges', 'unit': 'kg', 'quantity': 3, 'costMinor': 250, 'lowAt': 5}),
      );
      gemini(
        photo: {
          'supplierName': 'Marché Dupont',
          'payoutEmail': 'supplier-dupont@business.example.com',
          'reference': 'DN-2026-1147',
          'lines': lines,
          'totalMinor': 47980,
          'dueDays': 7,
        },
        turns: [
          [call('read_stock', {}), call('read_suppliers', {})],
          // A wrong total is refused; the model reads the note again.
          [
            call('propose_delivery', {
              'supplierName': 'Marché Dupont',
              'payoutEmail': 'supplier-dupont@business.example.com',
              'lines': lines,
              'totalMinor': 47900,
              'payNow': true,
              'explanation': 'x',
            }),
          ],
          [
            call('propose_delivery', {
              'supplierName': 'Marché Dupont',
              'payoutEmail': 'supplier-dupont@business.example.com',
              'lines': lines,
              'totalMinor': 47980,
              'payNow': true,
              'explanation':
                  'Marché Dupont delivered 8 lines for \$479.80, topping up oranges and adding seven items. The note is due in 7 days and names a PayPal email.',
            }),
          ],
        ],
      );
      final media = await photo();
      await expectLater(
        SuppliesAgent.receive(waiter.build(), command({'mediaId': media.id})),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      final started = await SuppliesAgent.receive(owner.build(), command({'mediaId': media.id}));
      final actions = await runTask(started['taskId'] as int);
      final task = (await AgentTask.db.findById(s, started['taskId'] as int))!;
      expect(
        (jsonDecode(task.traceJson) as List).any((t) => t['tool'] == 'propose_delivery' && t['status'] == 'rejected'),
        isTrue,
        reason: 'the wrong total was refused',
      );
      expect(actions.first.command, 'stock.receive');
      final evidence = jsonDecode(actions.first.evidenceJson) as Map;
      expect(evidence['topsUp'], ['Oranges']);
      expect(evidence['newItems'], hasLength(7));
      final payout = actions.where((a) => a.command == 'payout.send').toList();
      if (AgentModule.commands.containsKey('payout.send')) {
        expect(payout, hasLength(1));
        final batch = (await PayoutBatch.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!) & t.kind.equals('supplier'),
        ))!;
        expect(batch.totalMinor, 47980);
        expect(batch.state, 'proposed');
        final item = (await PayoutItem.db.findFirstRow(s, where: (t) => t.batchId.equals(batch.id!)))!;
        expect(item.recipientEmail, 'supplier-dupont@business.example.com');
      }
      final done = await decide(actions.first);
      expect(done['state'], 'executed', reason: '$done');
      final stock = (await read('stock'))['rows'] as List;
      expect(stock, hasLength(8));
      final oranges = stock.firstWhere((r) => r['name'] == 'Oranges') as Map;
      expect(oranges['quantity'], 23.0);
      expect(oranges['costMinor'], 210);
      final suppliers = (await read('suppliers'))['rows'] as List;
      expect((suppliers.single as Map)['payoutEmail'], 'supplier-dupont@business.example.com');
      final delivery = ((await read('deliveries'))['rows'] as List).single as Map;
      expect(delivery['state'], 'received');
      expect(delivery['totalMinor'], 47980);
    });

    test('a receipt becomes an expense, honest about PayPal\'s list being off', () async {
      final s = builder.build();
      gemini(
        photo: {
          'merchant': 'Greenline Cleaning Supplies',
          'spentAt': '2026-11-03T09:42:00-05:00',
          'totalMinor': 7956,
          'vatMinor': 589,
          'paymentMethod': 'PayPal',
          'paypalTransactionId': '7XK40217PL338',
          'items': [
            {'name': 'Dish soap 5L x2', 'amountMinor': 1780},
          ],
        },
        turns: [
          [
            call('read_paypal_transactions', {
              'from': '2026-11-02T12:00:00Z',
              'to': '2026-11-04T12:00:00Z',
            }),
          ],
          [
            call('propose_expense', {
              'merchant': 'Greenline Cleaning Supplies',
              'category': 'cleaning',
              'amountMinor': 7956,
              'vatMinor': 589,
              'spentAt': '2026-11-03T09:42:00-05:00',
              'paypalTransactionId': '7XK40217PL338',
              'explanation':
                  'Cleaning supplies for \$79.56 including \$5.89 VAT, paid by PayPal; the receipt prints the PayPal id, but PayPal\'s list is not enabled so it was not cross-checked.',
            }),
          ],
        ],
      );
      final media = await photo();
      final started = await ExpensesAgent.snap(owner.build(), command({'mediaId': media.id}));
      final actions = await runTask(started['taskId'] as int);
      expect(actions.single.command, 'expense.record');
      final evidence = jsonDecode(actions.single.evidenceJson) as Map;
      expect(evidence['paypalMatched'], isTrue);
      expect(evidence['paypalSource'], 'none');
      expect(evidence['paypalNote'], contains('not enabled'));
      final done = await decide(actions.single);
      expect(done['state'], 'executed', reason: '$done');
      final expense = (await Expense.db.findFirstRow(s, where: (t) => t.restaurantId.equals(restaurant.id!)))!;
      expect(expense.merchant, 'Greenline Cleaning Supplies');
      expect(expense.amountMinor, 7956);
      expect(expense.vatMinor, 589);
      expect(expense.category, 'cleaning');
      expect(expense.paypalTransactionId, '7XK40217PL338');
      expect(expense.mediaId, media.id);
      expect(expense.spentAt.toUtc().hour, 14);
    });

    test('regulars, lapsed and new customers are counted; a coupon is proposed for the lapsed', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (var d = 1; d <= 5; d++) {
        await paidOrder('ma-anna', now.subtract(Duration(days: d * 2)), 1200);
      }
      await paidOrder('ma-bilal', now.subtract(const Duration(days: 40)), 2500);
      await paidOrder('ma-bilal', now.subtract(const Duration(days: 60)), 1500);
      await paidOrder('ma-chloe', now.subtract(const Duration(days: 2)), 900);
      await paidOrder('walk-in:till', now.subtract(const Duration(days: 1)), 400);
      gemini(
        turns: [
          [call('read_customers', {})],
          [
            call('propose_coupon', {
              'segment': 'lapsed',
              'code': 'COMEBACK',
              'type': 'percent',
              'value': 15,
              'minimumMinor': 1000,
              'expiresDays': 14,
              'maxUses': 50,
              'rationale': 'One customer has not been back in three weeks. A 15% welcome-back coupon on a \$10 minimum costs about \$2 if they use it.',
            }),
          ],
        ],
      );
      final started = await LoyaltyAgent.start(owner.build(), command({}));
      final actions = await runTask(started['taskId'] as int);
      final customers = (await read('customers'))['rows'] as List;
      expect(customers, hasLength(3), reason: 'walk-ins are not customers');
      Map row(String name) => customers.firstWhere((r) => r['displayName'] == name) as Map;
      expect(row('Anna')['tags'], ['regular']);
      expect(row('Anna')['visits'], 5);
      expect(row('Bilal')['tags'], ['lapsed']);
      expect(row('Bilal')['spentMinor'], 4000);
      expect(row('Chloé')['tags'], ['new']);
      expect(actions.single.command, 'coupon.create');
      final evidence = jsonDecode(actions.single.evidenceJson) as Map;
      expect(evidence['segmentSize'], 1);
      expect(evidence['expectedRedemptions'], 1);
      final done = await decide(actions.single);
      expect(done['state'], 'executed', reason: '$done');
      final policy = (await RestaurantPolicy.db.findFirstRow(s, where: (t) => t.restaurantId.equals(restaurant.id!)))!;
      final coupons = (jsonDecode(policy.settingsJson) as Map)['coupons'] as List;
      expect((coupons.single as Map)['code'], 'COMEBACK');
      expect((coupons.single as Map)['value'], 1500);
      final after = (await read('customers'))['rows'] as List;
      expect((after.firstWhere((r) => r['displayName'] == 'Bilal') as Map)['couponCode'], 'COMEBACK');
      expect((after.firstWhere((r) => r['displayName'] == 'Anna') as Map)['couponCode'], isNull);

      final analytics = await read('analytics', {
        'from': now.subtract(const Duration(days: 90)).toIso8601String(),
        'to': now.add(const Duration(minutes: 1)).toIso8601String(),
      });
      expect(analytics['orders'], 9);
      expect(analytics['salesMinor'], 6000 + 4000 + 900 + 400);
      expect(analytics['byHour'], hasLength(24));
      expect(analytics['feesEstimated'], isTrue);
      final channels = {for (final c in analytics['byChannel'] as List) c['channel']: c['salesMinor']};
      expect(channels['counter'], 400);
      expect(channels['pickup'], 10900);
      expect(analytics['marginByDish'], isEmpty);
      await expectLater(
        BackOfficeModule.read(waiter.build(), restaurantId: restaurant.id!, name: 'analytics'),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
    });

    test('the copilot plans next week\'s roster from the busiest hours', () async {
      final s = builder.build();
      final zone = CatalogueModule.zone('America/New_York');
      final today = tz.TZDateTime.from(DateTime.now().toUtc(), zone);
      var monday = tz.TZDateTime(zone, today.year, today.month, today.day);
      while (monday.weekday != DateTime.monday) {
        monday = monday.add(const Duration(days: 1));
      }
      if (!monday.isAfter(today)) monday = monday.add(const Duration(days: 7));
      await paidOrder('ma-anna', tz.TZDateTime(zone, today.year, today.month, today.day, 12, 30).subtract(const Duration(days: 7)).toUtc(), 1200);
      await BackOfficeModule.saveShift(
        owner.build(),
        command({
          'name': 'Sam',
          'role': 'floor',
          'startsAt': monday.subtract(const Duration(days: 7)).add(const Duration(hours: 11)).toUtc().toIso8601String(),
          'endsAt': monday.subtract(const Duration(days: 7)).add(const Duration(hours: 16)).toUtc().toIso8601String(),
          'hourlyRateMinor': 1500,
          'payoutEmail': 'sam@example.test',
        }),
      );
      gemini(
        turns: [
          [call('read_demand', {})],
          [
            call('propose_roster', {
              'shifts': [
                {'name': 'Sam', 'role': 'floor', 'day': 0, 'start': '11:00', 'end': '16:00'},
                {'name': 'Sam', 'role': 'floor', 'day': 2, 'start': '11:00', 'end': '15:00'},
                {'name': 'Omar', 'role': 'kitchen', 'day': 0, 'start': '10:00', 'end': '15:00'},
              ],
              'explanation': 'Lunch at 12:00 was the busiest hour. Sam keeps Monday and Wednesday lunches and Omar covers the kitchen on Monday.',
            }),
          ],
        ],
      );
      await expectLater(
        CopilotAgent.plan(owner.build(), command({'weekStart': monday.add(const Duration(hours: 3)).toUtc().toIso8601String()})),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_input')),
      );
      final started = await CopilotAgent.plan(owner.build(), command({'weekStart': monday.toUtc().toIso8601String()}));
      final actions = await runTask(started['taskId'] as int);
      expect(actions.single.command, 'shift.plan');
      final done = await decide(actions.single);
      expect(done['state'], 'executed', reason: '$done');
      final planned = await StaffShift.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!) & (t.startsAt >= monday.toUtc()),
        orderBy: (t) => t.startsAt,
      );
      expect(planned, hasLength(3));
      final sam = planned.where((x) => x.name == 'Sam').toList();
      expect(sam, hasLength(2));
      expect(sam.first.hourlyRateMinor, 1500);
      expect(sam.first.payoutEmail, 'sam@example.test');
      expect(tz.TZDateTime.from(sam.first.startsAt, zone).hour, 11);
    });
  });
}
