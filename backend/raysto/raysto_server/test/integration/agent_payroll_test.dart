import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import '../fixtures/money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The model is scripted; PayPal is a fake.
void main() {
  withServerpod('The payroll agent', (builder, endpoints) {
    late TestSessionBuilder owner, customer;
    late Restaurant restaurant;
    late int burger;
    late MoneyAgentsUpstream upstream;
    const ownerAuth = 'payroll-owner-session';
    var serial = 0;
    String key() => 'payroll_fixture_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user, {String? authId}) =>
        builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user,
            {},
            authId: authId,
          ),
        );
    PlatformCommand command(Json data, {int? id, int? version}) =>
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: id,
          expectedVersion: version,
          dataJson: jsonEncode(data),
        );

    /// The model: reads the week, then lays out exactly what it was given.
    List<Json> script(int turn, Json body) {
      if (turn == 1) {
        return [
          {
            'functionCall': {'name': 'read_week', 'args': {}},
          },
        ];
      }
      final week = toolResults(body)['read_week']!;
      return [
        {
          'functionCall': {
            'name': 'propose_pay',
            'args': {
              'summary':
                  'Tips of \$${(week['tipPoolMinor'] as int) / 100} split by hours; wages from the clock.',
              'people': [
                for (final p in (week['people'] as List).cast<Map>())
                  {
                    'recipientEmail': p['recipientEmail'],
                    'tipMinor': p['tipMinor'],
                    'wagesMinor': p['wagesMinor'],
                    'note': '${p['minutes']} minutes as ${(p['roles'] as List).join('/')}.',
                  },
              ],
            },
          },
        },
      ];
    }

    Future<void> stepUp() => SecurityGrant.db.insertRow(
      builder.build(),
      SecurityGrant(
        userId: 'payroll-owner',
        kind: 'recent_auth',
        proofHash: sha256
            .convert(utf8.encode('stepup:payroll-owner:$ownerAuth:recent_auth'))
            .toString(),
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().toUtc(),
      ),
    );

    Future<int> shift(String name, String role, int hours, int rate, String? email) async =>
        (await BackOfficeModule.saveShift(
          owner.build(),
          command({
            'name': name,
            'role': role,
            'startsAt': DateTime.now().toUtc().subtract(Duration(hours: hours + 1)).toIso8601String(),
            'endsAt': DateTime.now().toUtc().subtract(const Duration(hours: 1)).toIso8601String(),
            'hourlyRateMinor': rate,
            'payoutEmail': ?email,
          }),
        ))['shiftId'] as int;

    /// A PayPal sale with a tip, captured through the fake.
    Future<void> tippedSale(int tipMinor) async {
      final q = await OrderingModule.quote(
        customer.build(),
        CreateQuote(
          requestKey: key(),
          restaurantId: restaurant.id!,
          fulfillment: 'pickup',
          linesJson: jsonEncode([
            {'productId': burger, 'quantity': 4},
          ]),
          tipMinor: tipMinor,
        ),
      );
      final id = (await OrderingModule.submit(
        customer.build(),
        SubmitOrder(requestKey: key(), restaurantId: restaurant.id!, quoteId: q['id'] as int),
      ))['orderId'] as int;
      final checkout =
          (await MoneyModule.allocate(
                customer.build(),
                AllocatePayment(
                  requestKey: key(),
                  restaurantId: restaurant.id!,
                  orderId: id,
                  method: 'paypal',
                ),
              ))['checkoutId']
              as int;
      await MoneyModule.checkout(customer.build(), command({}, id: checkout));
      upstream.status = 'APPROVED';
      expect((await MoneyModule.capture(customer.build(), command({}, id: checkout)))['state'], 'completed');
    }

    setUp(() async {
      owner = session('payroll-owner', authId: ownerAuth);
      customer = session('payroll-customer');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in ['payroll-owner', 'payroll-customer']) {
        await ActorProfile.db.insertRow(
          s,
          ActorProfile(
            userId: user,
            isGuest: false,
            disabled: false,
            dataJson: '{}',
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
          dataJson: '{"name":"Payroll fixture","currency":"USD"}',
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
        'timezone': 'UTC',
        'hours': [
          for (var day = 1; day <= 7; day++)
            {'day': day, 'start': 0, 'end': 1440},
        ],
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      burger =
          (await CatalogueModule.saveItem(
                owner.build(),
                command({
                  'name': 'Burger',
                  'category': 'Mains',
                  'priceMinor': 900,
                }, version: 1),
              ))['id']
              as int;
      upstream = MoneyAgentsUpstream(gemini: script);
      ProviderClients.httpClient = upstream.client;
      ProviderClients.environment = () => {
        ...Platform.environment,
        'GEMINI_API_KEY': 'fixture-key',
        'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
        'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': 'true',
        'RAYSTO_SANDBOX_RESTAURANT_ID': '${restaurant.id}',
        'PAYPAL_SANDBOX_MERCHANT_ID': 'MERCHANT-FIXTURE',
        'PAYPAL_SANDBOX_CLIENT_ID': 'fixture-client',
        'PAYPAL_SANDBOX_CLIENT_SECRET': 'fixture-secret',
        'PAYPAL_V2_RETURN_URL': 'https://example.test/return',
        'PAYPAL_V2_CANCEL_URL': 'https://example.test/cancel',
      };
      AgentModule.environment = () => {
        ...Platform.environment,
        'RAYSTO_AGENT_PAYROLL_ENABLED': 'true',
      };
      AiBudget.environment = () => {
        ...Platform.environment,
        'RAYSTO_AI_BUDGET_STAGE': 'hackathon',
        'RAYSTO_AI_INPUT_USD_PER_MILLION': '0.75',
        'RAYSTO_AI_OUTPUT_USD_PER_MILLION': '3.75',
        'RAYSTO_AI_TENANT_DAILY_MICROS': '2000000',
      };
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      AiBudget.environment = () => Platform.environment;
      ProviderClients.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
    });

    test('tips are split by hours to the cent and sent through PayPal Payouts after the identity check', () async {
      await shift('Nadia', 'floor', 4, 1500, 'nadia@example.test');
      await shift('Omar', 'kitchen', 2, 1200, 'omar@example.test');
      await tippedSale(2000);
      final s = builder.build();
      final started = await PayrollAgent.runCommand(
        owner.build(),
        command({
          'from': DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String(),
          'to': DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String(),
        }),
      );
      await AgentModule.run(s, started['taskId'] as int);
      final task = (await AgentTask.db.findById(s, started['taskId'] as int))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      expect(upstream.geminiTools.toSet(), {'read_week', 'propose_pay'});
      final batches = await PayoutBatch.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
        orderBy: (t) => t.id,
      );
      expect(batches.map((b) => b.kind), ['tips', 'wages']);
      final tips = batches.first;
      expect(tips.totalMinor, 2000);
      expect(tips.state, 'proposed');
      final items = await PayoutItem.db.find(
        s,
        where: (t) => t.batchId.equals(tips.id!),
        orderBy: (t) => t.id,
      );
      expect(items.map((i) => i.amountMinor).toList(), [1334, 666]);
      expect(items.first.recipientEmail, 'nadia@example.test');
      expect(items.first.note, contains('minutes'));
      final wages = batches.last;
      expect(wages.totalMinor, 6000 + 2400);
      final actions = await AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(task.id!),
        orderBy: (t) => t.ordinal,
      );
      expect(actions.map((a) => a.command), ['payout.send', 'payout.send']);
      expect(actions.first.risk, 'money');
      expect((jsonDecode(actions.first.previewJson) as Map)['totalMinor'], 2000);

      // Approval needs the identity check; with it, PayPal gets one batch.
      final requestKey = key();
      Future<Json> decide() => AgentModule.decide(
        owner.build(),
        PlatformCommand(
          requestKey: requestKey,
          restaurantId: restaurant.id,
          resourceId: actions.first.id,
          expectedVersion: actions.first.version,
          dataJson: '{"decision":"approve"}',
        ),
      );
      final held = await decide();
      expect(held['needs'], 'reauthentication_required');
      expect(upstream.payouts, isEmpty);
      await stepUp();
      final done = await decide();
      expect(done['state'], 'executed', reason: jsonEncode(done));
      expect(upstream.payouts.length, 1);
      final sentBody = upstream.payouts.single['body'] as Map;
      final sentItems = (sentBody['items'] as List).cast<Map>();
      expect(sentItems.map((i) => (i['amount'] as Map)['value']).toList(), ['13.34', '6.66']);
      expect(sentItems.map((i) => i['receiver']).toList(), ['nadia@example.test', 'omar@example.test']);
      expect(upstream.payouts.single['requestId'], 'payout-${tips.requestKey}');
      final sent = (await PayoutBatch.db.findById(s, tips.id!))!;
      expect(sent.state, 'sent');
      expect(sent.providerBatchId, 'BATCH-1');
      // Sending the same batch again does nothing more at PayPal.
      final again = await PayrollAgent.sendCommand(owner.build(), command({}, id: tips.id));
      expect(again['state'], 'sent');
      expect(upstream.payouts.length, 1);
      // The poll job follows it to completion.
      await PayrollAgent.poll(s, tips.id!, 0);
      final completed = (await PayoutBatch.db.findById(s, tips.id!))!;
      expect(completed.state, 'completed');
      final paidItems = await PayoutItem.db.find(s, where: (t) => t.batchId.equals(tips.id!));
      expect(paidItems.every((i) => i.state == 'completed' && i.providerItemId != null), isTrue);
      final view = await BackOfficeModule.read(
        owner.build(),
        restaurantId: restaurant.id!,
        name: 'payout',
        d: {'id': tips.id},
      );
      expect(view['providerBatchId'], 'BATCH-1');
      expect((view['items'] as List).length, 2);
      // The list carries each batch's lines too, the same as the single read.
      final list = await BackOfficeModule.read(
        owner.build(),
        restaurantId: restaurant.id!,
        name: 'payouts',
      );
      final rows = (list['rows'] as List).cast<Map>();
      expect(rows.length, 2);
      for (final row in rows) {
        expect(row['items'], isA<List>(), reason: 'payouts list row ${row['id']}');
      }
      final listed = rows.firstWhere((r) => r['id'] == tips.id);
      expect((listed['items'] as List).map((i) => (i as Map)['amountMinor']), [1334, 666]);
    });

    test('someone who worked without a PayPal email is held by name, never dropped', () async {
      await shift('Nadia', 'floor', 4, 1500, 'nadia@example.test');
      await shift('Lina', 'manager', 4, 2200, null);
      await tippedSale(1000);
      final s = builder.build();
      final week = await PayrollAgent.readWeek(
        s,
        restaurant.id!,
        DateTime.now().toUtc().subtract(const Duration(days: 1)),
        DateTime.now().toUtc().add(const Duration(days: 1)),
      );
      // The pool counts the settled tip and is shared with everyone who worked.
      expect(week['tipPoolMinor'], 1000);
      final people = (week['people'] as List).cast<Map>();
      final held = (week['held'] as List).cast<Map>();
      expect(people.map((p) => p['recipientName']), ['Nadia']);
      expect(held.map((p) => p['recipientName']), ['Lina']);
      expect(people.single['tipMinor'] + held.single['tipMinor'], 1000);
      expect(held.single['wagesMinor'], 4 * 2200);
      expect(held.single['reason'], contains('PayPal email'));

      final started = await PayrollAgent.runCommand(
        owner.build(),
        command({
          'from': DateTime.now().toUtc().subtract(const Duration(days: 1)).toIso8601String(),
          'to': DateTime.now().toUtc().add(const Duration(days: 1)).toIso8601String(),
        }),
      );
      await AgentModule.run(s, started['taskId'] as int);
      final task = (await AgentTask.db.findById(s, started['taskId'] as int))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      expect(task.summary, contains('Held, no PayPal email yet: Lina'));
      final batches = await PayoutBatch.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
        orderBy: (t) => t.id,
      );
      for (final b in batches) {
        final items = await PayoutItem.db.find(s, where: (t) => t.batchId.equals(b.id!));
        expect(items.map((i) => i.recipientName), ['Nadia'], reason: b.kind);
        final summary = jsonDecode(b.summaryJson) as Map;
        expect((summary['held'] as List).cast<Map>().single['recipientName'], 'Lina');
      }
      final action = (await AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(task.id!),
        orderBy: (t) => t.ordinal,
      )).first;
      final preview = jsonDecode(action.previewJson) as Map;
      expect((preview['held'] as List).cast<Map>().single['recipientName'], 'Lina');
    });

    test('a tip counts once its order is paid, and only inside the period', () async {
      await shift('Nadia', 'floor', 4, 1500, 'nadia@example.test');
      // A tipped order that was never paid: its tip charge is not settled.
      final q = await OrderingModule.quote(
        customer.build(),
        CreateQuote(
          requestKey: key(),
          restaurantId: restaurant.id!,
          fulfillment: 'pickup',
          linesJson: jsonEncode([
            {'productId': burger, 'quantity': 1},
          ]),
          tipMinor: 300,
        ),
      );
      await OrderingModule.submit(
        customer.build(),
        SubmitOrder(requestKey: key(), restaurantId: restaurant.id!, quoteId: q['id'] as int),
      );
      final s = builder.build();
      Future<int> pool(DateTime from, DateTime to) async =>
          (await PayrollAgent.readWeek(s, restaurant.id!, from, to))['tipPoolMinor'] as int;
      final from = DateTime.now().toUtc().subtract(const Duration(days: 1));
      final to = DateTime.now().toUtc().add(const Duration(days: 1));
      expect(await pool(from, to), 0);
      await tippedSale(700);
      expect(await pool(from, to), 700);
      // The same paid tip falls outside last week's window.
      expect(
        await pool(from.subtract(const Duration(days: 8)), from.subtract(const Duration(days: 1))),
        0,
      );
    });

    test('the split is exact under both policies', () {
      final people = [
        {'recipientEmail': 'a@x', 'minutes': 240},
        {'recipientEmail': 'b@x', 'minutes': 120},
        {'recipientEmail': 'c@x', 'minutes': 0},
      ];
      final byHours = PayrollAgent.splitTips(1000, people, 'hours');
      expect(byHours, {'a@x': 667, 'b@x': 333, 'c@x': 0});
      final equal = PayrollAgent.splitTips(1000, people, 'equal');
      expect(equal.values.fold<int>(0, (a, b) => a + b), 1000);
      expect(equal, {'a@x': 334, 'b@x': 333, 'c@x': 333});
      expect(PayrollAgent.splitTips(0, people, 'hours'), isEmpty);
    });
  });
}
