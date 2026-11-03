import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import '../fixtures/money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The model is scripted; PayPal is a fake.
void main() {
  withServerpod('The daily close agent', (builder, endpoints) {
    late TestSessionBuilder owner, cashier, customer;
    late Restaurant restaurant;
    late int burger;
    late MoneyAgentsUpstream upstream;
    var serial = 0;
    String key() => 'close_fixture_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user) => builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        user,
        {},
        authId: '$user-session',
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

    /// The model: reads both tools, then explains every gap it was given.
    List<Json> script(int turn, Json body) {
      if (turn == 1) {
        return [
          {
            'functionCall': {'name': 'read_day', 'args': {}},
          },
          {
            'functionCall': {'name': 'read_paypal_day', 'args': {}},
          },
        ];
      }
      final results = toolResults(body);
      final paypalDay = results['read_paypal_day'];
      if (paypalDay == null || paypalDay['error'] != null) {
        // Surface the tool failure as the summary, so the test reads it.
        return [
          {
            'functionCall': {
              'name': 'propose_close',
              'args': {
                'summary': 'TOOL FAILURE: ${jsonEncode(results)}',
                'gaps': <Json>[],
              },
            },
          },
        ];
      }
      final found = (paypalDay['gapsFound'] as List).cast<Map>();
      return [
        {
          'functionCall': {
            'name': 'propose_close',
            'args': {
              'summary':
                  'A quiet day: PayPal and the till agree apart from the gaps below.',
              'gaps': [
                for (final g in found)
                  {
                    'kind': g['kind'],
                    'amountMinor': g['amountMinor'],
                    'explanation': 'Explained: ${g['kind']} of ${g['amountMinor']}.',
                  },
              ],
            },
          },
        },
      ];
    }

    Future<Json> quote(TestSessionBuilder who, {int tipMinor = 0, bool counter = false}) =>
        OrderingModule.quote(
          who.build(),
          CreateQuote(
            requestKey: key(),
            restaurantId: restaurant.id!,
            fulfillment: 'pickup',
            linesJson: jsonEncode([
              {'productId': burger, 'quantity': 1},
            ]),
            tipMinor: tipMinor,
            onBehalf: counter ? true : null,
          ),
        );
    Future<int> submit(TestSessionBuilder who, Json q) async =>
        (await OrderingModule.submit(
          who.build(),
          SubmitOrder(
            requestKey: key(),
            restaurantId: restaurant.id!,
            quoteId: q['id'] as int,
          ),
        ))['orderId'] as int;

    /// An online order paid through the fake PayPal and captured.
    Future<int> paypalSale({int tipMinor = 0}) async {
      final id = await submit(customer, await quote(customer, tipMinor: tipMinor));
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
      final done = await MoneyModule.capture(
        customer.build(),
        command({}, id: checkout),
      );
      expect(done['state'], 'completed');
      return checkout;
    }

    setUp(() async {
      owner = session('close-owner');
      cashier = session('close-cashier');
      customer = session('close-customer');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in ['close-owner', 'close-cashier', 'close-customer']) {
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
          dataJson: '{"name":"Close fixture","currency":"USD"}',
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
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: 'close-cashier',
          role: 'waiter',
          active: true,
          capabilities: ['counter'],
        ),
      );
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
        'RAYSTO_AGENT_CLOSE_ENABLED': 'true',
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

    /// A day's trade: one PayPal sale with a tip, one cash sale, one served
    /// ticket nobody paid. Returns the PayPal checkout id.
    Future<int> tradingDay() async {
      final checkout = await paypalSale(tipMinor: 100);
      final cashOrder = await submit(cashier, await quote(cashier, counter: true));
      await MoneyModule.allocate(
        cashier.build(),
        AllocatePayment(
          requestKey: key(),
          restaurantId: restaurant.id!,
          orderId: cashOrder,
          method: 'cash',
        ),
      );
      final s = builder.build();
      final unpaid = await submit(cashier, await quote(cashier, counter: true));
      final row = (await PurchaseOrder.db.findById(s, unpaid))!;
      row.status = 'completed';
      await PurchaseOrder.db.updateRow(s, row);
      return checkout;
    }

    Future<AgentTask> runClose() async {
      final s = builder.build();
      final started = await CloseAgent.runCommand(owner.build(), command({}));
      await AgentModule.run(s, started['taskId'] as int);
      return (await AgentTask.db.findById(s, started['taskId'] as int))!;
    }

    test('without Transaction Search the close works from the ledger and explains the unpaid ticket', () async {
      await tradingDay();
      upstream.transactions = null;
      final task = await runClose();
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      expect(upstream.geminiTools.toSet(), {'read_day', 'read_paypal_day', 'propose_close'});
      final s = builder.build();
      final close = (await DailyClose.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      expect(close.state, 'drafted');
      expect(close.source, 'raysto_ledger');
      final summary = jsonDecode(close.summaryJson) as Map;
      expect(summary['raystoCapturedMinor'], 1000);
      expect(summary['paypalCapturedMinor'], 1000);
      expect(summary['cashMinor'], 900);
      expect(summary['tipsMinor'], 100);
      expect(summary['refundsMinor'], 0);
      expect(summary['currency'], 'USD');
      final gaps = (jsonDecode(close.gapsJson) as List).cast<Map>();
      expect(gaps.map((g) => g['kind']), ['unpaid_ticket']);
      expect(gaps.single['amountMinor'], 900);
      expect(gaps.single['explanation'], contains('unpaid_ticket'));
      final actions = await AgentAction.db.find(s, where: (t) => t.taskId.equals(task.id!));
      expect(actions.map((a) => a.command), ['close.sign']);
      expect((jsonDecode(actions.single.previewJson) as Map)['gaps'], 1);
      // The manager signs off through the inbox; the row is signed once.
      final decided = await AgentModule.decide(
        owner.build(),
        command({'decision': 'approve'}, id: actions.single.id, version: actions.single.version),
      );
      expect(decided['state'], 'executed');
      final signed = (await DailyClose.db.findById(s, close.id!))!;
      expect(signed.state, 'signed');
      expect(signed.signedBy, 'close-owner');
      final again = await CloseAgent.signCommand(owner.build(), command({}, id: close.id));
      expect(again['state'], 'signed');
      // A signed day may be closed again: a new task is queued and the
      // signed row stays until the new draft replaces it.
      final again2 = await CloseAgent.runCommand(owner.build(), command({}));
      expect(again2['taskId'], isA<int>());
      final read = await BackOfficeModule.read(
        owner.build(),
        restaurantId: restaurant.id!,
        name: 'backoffice.close',
      );
      expect(read['state'], 'signed');
      expect((read['gaps'] as List).length, 1);
    });

    test('with PayPal\'s list a capture Raysto missed is found and its fix proposed', () async {
      final checkout = await tradingDay();
      // An unfinished checkout whose payment PayPal shows as captured.
      final late = await submit(customer, await quote(customer));
      final lateCheckout =
          (await MoneyModule.allocate(
                customer.build(),
                AllocatePayment(
                  requestKey: key(),
                  restaurantId: restaurant.id!,
                  orderId: late,
                  method: 'paypal',
                ),
              ))['checkoutId']
              as int;
      await MoneyModule.checkout(customer.build(), command({}, id: lateCheckout));
      upstream.transactions = [
        {'id': 'CAPTURE-$checkout', 'value': '10.00', 'fee': '-0.59'},
        {
          'id': 'CAPTURE-$lateCheckout',
          'value': '9.00',
          'fee': '-0.56',
          'customId': 'raysto-v2:$lateCheckout',
        },
      ];
      final task = await runClose();
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      final s = builder.build();
      final close = (await DailyClose.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      expect(close.source, 'paypal_transactions');
      final summary = jsonDecode(close.summaryJson) as Map;
      expect(summary['paypalCapturedMinor'], 1900);
      expect(summary['raystoCapturedMinor'], 1000);
      expect(summary['feesMinor'], 115);
      expect(summary['via'], 'paypal_rest');
      final gaps = (jsonDecode(close.gapsJson) as List).cast<Map>();
      expect(gaps.map((g) => g['kind']).toSet(), {
        'capture_not_in_raysto',
        'fee_note',
        'unpaid_ticket',
      });
      final missing = gaps.singleWhere((g) => g['kind'] == 'capture_not_in_raysto');
      expect(missing['amountMinor'], 900);
      expect((missing['proposedFix'] as Map)['checkoutId'], lateCheckout);
      final actions = await AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(task.id!),
        orderBy: (t) => t.ordinal,
      );
      expect(actions.map((a) => a.command), ['close.sign', 'payment.reconcile']);
    });
  });
}
