import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only; the model is never called. These cover
// who may open which assistant conversation, which tools each one may use,
// the takeaway basket approval, and the manager facts tools.
void main() {
  withServerpod('Assistant contexts: basket, table and manager', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, customer, other;
    late Restaurant restaurant;
    late int burger;
    var serial = 0;
    String key() =>
        'assistant_fixture_${(++serial).toString().padLeft(8, '0')}';
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
    Future<T> work<T>(String user, Future<T> Function(Work) fn) =>
        MoneyModule.locked(builder.build(), restaurant.id!, user, fn);
    // assistant.start reads auth_time from the Firebase proof header; a
    // fixture token with that claim is enough here, nothing is verified.
    Session proven(TestSessionBuilder who) {
      final s = who.build();
      PlatformApi.bindHttpHeaders(s, {
        'x-raysto-firebase-token':
            'fixture.${base64Url.encode(utf8.encode(jsonEncode({'auth_time': 1700000000})))}.sig',
      });
      return s;
    }

    AssistantRun run(String user, {int? roomId, Json input = const {}}) =>
        AssistantRun(
          restaurantId: restaurant.id!,
          roomId: roomId,
          userId: user,
          requestKey: key(),
          status: 'running',
          inputJson: jsonEncode(input),
          outputJson: '{}',
          traceJson: '[]',
          reservedMicros: 0,
          chargedMicros: 0,
          budgetStage: 'development',
          version: 1,
          createdAt: DateTime.now().toUtc(),
        );

    setUp(() async {
      owner = session('assistant-owner');
      customer = session('assistant-customer');
      other = session('assistant-other');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in [
        'assistant-owner',
        'assistant-customer',
        'assistant-other',
      ]) {
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
          dataJson: '{"name":"Assistant fixture","currency":"EUR"}',
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
        'country': 'BE',
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
    });

    test('a customer may open a basket chat but not a manager thread', () async {
      final started = await AssistantModule.start(
        proven(customer),
        command({'text': 'Something vegetarian under 15 euros', 'context': 'cart'}),
      );
      expect(started['status'], 'queued');
      final row = (await AssistantRun.db.findById(
        builder.build(),
        started['runId'] as int,
      ))!;
      expect(AssistantModule.isCart(row), isTrue);
      expect(row.roomId, isNull);
      await expectLater(
        AssistantModule.start(
          proven(customer),
          command({'text': 'How are sales today?'}),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      final s = builder.build();
      restaurant.published = false;
      await Restaurant.db.updateRow(s, restaurant);
      await expectLater(
        AssistantModule.start(
          proven(customer),
          command({'text': 'Anything?', 'context': 'cart'}),
        ),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'unavailable'),
        ),
      );
    });

    test('guests cannot spend the shared AI budget on basket chats', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      await ActorProfile.db.insertRow(
        s,
        ActorProfile(
          userId: 'assistant-guest',
          isGuest: true,
          disabled: false,
          dataJson: '{}',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await expectLater(
        AssistantModule.start(
          session('assistant-guest').build(),
          command({'text': 'Anything?', 'context': 'cart'}),
        ),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'account_required'),
        ),
      );
    });

    test('each conversation sees only its own tools', () {
      final cart = run('assistant-customer', input: {'context': 'cart'});
      expect(
        AssistantModule.toolsFor(cart),
        unorderedEquals(['read_menu', 'quote_basket', 'payment_status']),
      );
      expect(
        AssistantModule.declarationsFor(cart).map((d) => d['name']),
        unorderedEquals(['read_menu', 'quote_basket', 'payment_status']),
      );
      final manager = run('assistant-owner');
      expect(
        AssistantModule.toolsFor(manager),
        containsAll([
          'sales_summary',
          'kitchen_load',
          'pickup_ready',
          'unresolved_payments',
          'payment_status',
        ]),
      );
      expect(AssistantModule.toolsFor(manager), isNot(contains('read_bill')));
      final table = run('assistant-customer', roomId: 1);
      expect(
        AssistantModule.toolsFor(table),
        containsAll(['read_bill', 'propose_payment', 'quote_basket']),
      );
      expect(
        AssistantModule.toolsFor(table),
        isNot(contains('unresolved_payments')),
      );
    });

    test('a takeaway basket proposal is approved into a quote and ordered', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      final input = {
        'fulfillment': 'pickup',
        'lines': [
          {'productId': burger, 'quantity': 2, 'options': [], 'note': ''},
        ],
        'tipMinor': 0,
      };
      final r = await AssistantRun.db.insertRow(
        s,
        run('assistant-customer', input: {'context': 'cart', 'text': 'two'}),
      );
      final quote = await work(
        'assistant-customer',
        (w) => OrderingModule.price(w, input),
      );
      expect(quote['totalMinor'], 1800);
      final hash = await work(
        'assistant-customer',
        (w) => AssistantModule.contextHash(w, null, 'basket'),
      );
      final proposal = await AssistantProposal.db.insertRow(
        s,
        AssistantProposal(
          restaurantId: restaurant.id!,
          runId: r.id!,
          userId: 'assistant-customer',
          kind: 'basket',
          payloadJson: jsonEncode({
            'proposalKind': 'basket',
            'input': input,
            'quote': quote,
          }),
          contextHash: hash,
          status: 'review',
          version: 1,
          expiresAt: now.add(const Duration(minutes: 5)),
          createdAt: now,
        ),
      );
      await expectLater(
        AssistantModule.approve(
          other.build(),
          command({}, id: proposal.id, version: 1),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      final approved = await AssistantModule.approve(
        customer.build(),
        command({}, id: proposal.id, version: 1),
      );
      expect(approved['kind'], 'basket');
      final placed = await OrderingModule.submit(
        customer.build(),
        SubmitOrder(
          requestKey: key(),
          restaurantId: restaurant.id!,
          quoteId: approved['quoteId'] as int,
        ),
      );
      expect(placed['status'], 'awaitingPayment');
      expect(placed['number'], 1);
      final ctx = (await OrderContext.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(placed['orderId'] as int),
      ))!;
      expect(ctx.visitId, isNull);
      expect(ctx.pickupCode, matches(RegExp(r'^\d{4}$')));
    });

    test('manager facts tools read real orders and payments', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      final q = await OrderingModule.quote(
        customer.build(),
        CreateQuote(
          requestKey: key(),
          restaurantId: restaurant.id!,
          fulfillment: 'pickup',
          linesJson: jsonEncode([
            {'productId': burger, 'quantity': 1},
          ]),
          tipMinor: 0,
        ),
      );
      final placed = await OrderingModule.submit(
        customer.build(),
        SubmitOrder(
          requestKey: key(),
          restaurantId: restaurant.id!,
          quoteId: q['id'] as int,
        ),
      );
      // The kitchen finished it seven minutes ago and nobody collected it.
      final order = (await PurchaseOrder.db.findById(
        s,
        placed['orderId'] as int,
      ))!;
      order.status = 'ready';
      order.paymentStatus = 'paid';
      order.updatedAt = now.subtract(const Duration(minutes: 7));
      await PurchaseOrder.db.updateRow(s, order);
      // A PayPal approval link opened 45 minutes ago and never finished.
      final stale = await CheckoutIntent.db.insertRow(
        s,
        CheckoutIntent(
          restaurantId: restaurant.id!,
          userId: 'assistant-customer',
          orderId: order.id,
          requestKey: key(),
          requestHash: 'fixture',
          providerRequestId: key(),
          providerOrderId: 'PP-STALE',
          merchantId: 'MERCHANT-FIXTURE',
          state: 'created',
          method: 'paypal',
          currency: 'EUR',
          amountMinor: 900,
          commissionMinor: 0,
          commissionBps: 0,
          createdAt: now.subtract(const Duration(minutes: 45)),
          updatedAt: now.subtract(const Duration(minutes: 45)),
        ),
      );

      final load = await work('assistant-owner', AssistantModule.kitchenLoad);
      expect(load['ready']['count'], 1);
      expect(load['ready']['oldestMinutes'], greaterThanOrEqualTo(7));
      expect(load['awaitingAcceptance']['count'], 0);

      final pickups = await work('assistant-owner', AssistantModule.pickupReady);
      final waiting = (pickups['orders'] as List).single as Map;
      expect(waiting['number'], 1);
      // The pickup code is a handover secret and never goes to the model.
      expect(waiting.containsKey('pickupCode'), isFalse);
      expect(waiting['readyForMinutes'], greaterThanOrEqualTo(7));

      final unresolved = await work(
        'assistant-owner',
        AssistantModule.unresolvedPayments,
      );
      final attempt = (unresolved['checkouts'] as List).single as Map;
      expect(attempt['checkoutId'], stale.id);
      expect(attempt['state'], 'created');
      expect(attempt['ageMinutes'], greaterThanOrEqualTo(45));
      expect(attempt['providerKnown'], isTrue);

      final sales = await work(
        'assistant-owner',
        (w) => AssistantModule.salesSummary(w, 'today'),
      );
      expect(sales['currency'], 'EUR');
      expect(sales['ordersCreated'], 1);
      expect(sales['bookedSalesMinor'], 900);
      expect(sales['channels']['pickup:online']['orders'], 1);

      await expectLater(
        work('assistant-customer', AssistantModule.kitchenLoad),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
    });
  });
}
