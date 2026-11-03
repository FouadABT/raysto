import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The judges' café: a published manager
// login, so the café keeps its identity and starts fresh every day.
void main() {
  withServerpod('The judges’ café', (builder, endpoints) {
    late TestSessionBuilder owner, manager;
    late Restaurant restaurant;
    var serial = 0;
    String key() => 'judge_fixture_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user) => builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(user, {}),
    );
    final now = DateTime.now().toUtc();
    final old = now.subtract(const Duration(hours: 2));

    setUp(() async {
      owner = session('judge-owner');
      manager = session('judge-manager');
      final s = builder.build();
      for (final user in ['judge-owner', 'judge-manager', 'judge-diner']) {
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
          dataJson: '{"name":"Judges fixture","currency":"USD"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
      // The owner's contact email, as the café's setup records it.
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.settingsJson = jsonEncode({
        ...jsonDecode(policy.settingsJson) as Map,
        'contactEmail': 'owner@example.com',
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: 'judge-manager',
          role: 'manager',
          active: true,
        ),
      );
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_JUDGE_RESTAURANT_ID': '${restaurant.id}',
      };
    });
    tearDown(() => ProviderClients.environment = () => Platform.environment);

    Future<Map<String, MenuDefinition>> menu() async {
      final s = builder.build();
      final definitions = await MenuDefinition.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      );
      return {
        for (final d in definitions)
          (await MenuProduct.db.findById(s, d.productId))!.name: d,
      };
    }

    Future<PurchaseOrder> order(
      String status,
      String payment, {
      required DateTime at,
    }) async {
      final s = builder.build();
      final o = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurant.id!,
          customerId: 'judge-diner',
          requestKey: key(),
          requestHash: 'fixture',
          fulfillment: 'pickup',
          lines: [],
          currency: 'USD',
          subtotalMinor: 750,
          deliveryFeeMinor: 0,
          totalMinor: 750,
          status: status,
          paymentStatus: payment,
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
          detailsJson: '{"lines":[]}',
          paymentTiming: 'before',
          cancellationRequested: false,
          stockReleased: false,
          origin: 'online',
          createdAt: at,
        ),
      );
      await BillCharge.db.insertRow(
        s,
        BillCharge(
          restaurantId: restaurant.id!,
          orderId: o.id!,
          lineKey: 'order',
          kind: 'order',
          amountMinor: 750,
          creditedMinor: 0,
          settledMinor: payment == 'paid' ? 750 : 0,
          reservedMinor: 0,
          foodNetMinor: 750,
          version: 1,
        ),
      );
      return o;
    }

    Future<AgentAction> proposal(DateTime at) async {
      final s = builder.build();
      final task = await AgentTask.db.insertRow(
        s,
        AgentTask(
          restaurantId: restaurant.id!,
          agent: 'copilot',
          trigger: 'schedule',
          dedupeKey: 'judge-fixture:${key()}',
          status: 'done',
          title: 'Fixture',
          inputJson: '{}',
          stateJson: '{}',
          traceJson: '[]',
          feature: 'agents',
          reservedMicros: 0,
          chargedMicros: 0,
          version: 1,
          createdAt: at,
          updatedAt: at,
        ),
      );
      return AgentAction.db.insertRow(
        s,
        AgentAction(
          restaurantId: restaurant.id!,
          taskId: task.id!,
          agent: 'copilot',
          ordinal: 0,
          command: 'settings.patch',
          title: 'Fixture',
          rationale: 'Fixture',
          payloadJson: '{}',
          previewJson: '{}',
          evidenceJson: '{}',
          risk: 'ops',
          contextHash: 'fixture',
          status: 'pending',
          version: 1,
          expiresAt: now.add(const Duration(days: 1)),
          createdAt: at,
        ),
      );
    }

    test('it starts fresh without deleting anything', () async {
      final s = builder.build();
      final first = await JudgeModule.reset(s, restaurant.id!);
      expect(first['dishes'], 11);
      final base = await menu();
      expect(base.values.where((d) => !d.archived), hasLength(11));
      final croque = base['Croque monsieur']!.productId;

      // A judge reads the full menu photo in and approves it.
      final draft = await MenuDraft.db.insertRow(
        s,
        MenuDraft(
          restaurantId: restaurant.id!,
          userId: 'judge-manager',
          itemsJson: jsonEncode([
            {
              'productId': croque,
              'name': 'Croque monsieur',
              'category': 'Sandwiches',
              'priceMinor': 990,
            },
            {'name': 'Lemon tart', 'category': 'Sweets', 'priceMinor': 450},
          ]),
          baseMenuVersion: 0,
          version: 1,
          status: 'draft',
          createdAt: now,
        ),
      );
      await CatalogueModule.publishDraft(
        manager.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: draft.id,
          expectedVersion: 1,
          dataJson: '{"confirm":true,"merge":true}',
        ),
      );
      final paid = await order('accepted', 'paid', at: old);
      final unpaid = await order('awaitingPayment', 'unpaid', at: old);
      final current = await order('awaitingPayment', 'unpaid', at: now);
      final stale = await proposal(old);
      final fresh = await proposal(now);
      final abandoned = await CheckoutIntent.db.insertRow(
        s,
        CheckoutIntent(
          restaurantId: restaurant.id!,
          userId: 'judge-diner',
          requestKey: key(),
          requestHash: 'fixture',
          providerRequestId: 'judge-fixture-request',
          merchantId: 'MERCHANT-FIXTURE',
          state: 'created',
          method: 'paypal',
          currency: 'USD',
          amountMinor: 750,
          commissionMinor: 0,
          commissionBps: 0,
          createdAt: old,
          updatedAt: old,
        ),
      );
      restaurant
        ..name = 'Renamed by a judge'
        ..published = false;
      await Restaurant.db.updateRow(s, restaurant);
      final orders = await PurchaseOrder.db.count(s);

      final result = await JudgeModule.reset(s, restaurant.id!);
      expect(result, containsPair('completed', 1));
      expect(result, containsPair('cancelled', 1));
      expect(result, containsPair('expired', 1));
      expect(result, containsPair('released', 1));

      final after = await menu();
      expect(after['Lemon tart']!.archived, isTrue);
      expect(after['Croque monsieur']!.productId, croque);
      expect(after.values.where((d) => !d.archived), hasLength(11));
      expect((await MenuProduct.db.findById(s, croque))!.priceMinor, 750);
      final cafe = (await Restaurant.db.findById(s, restaurant.id!))!;
      expect(cafe.name, JudgeModule.name);
      expect(cafe.published, isTrue);
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      final settings = jsonDecode(policy.settingsJson) as Map;
      expect(settings['timezone'], 'America/New_York');
      expect(
        [
          for (final c in settings['menuCategories'] as List) c['name'],
        ],
        ['Breakfast', 'Sandwiches', 'Plates', 'Drinks'],
      );

      Future<String> status(PurchaseOrder o) async =>
          (await PurchaseOrder.db.findById(s, o.id!))!.status;
      expect(await status(paid), 'completed');
      expect(await status(unpaid), 'cancelled');
      expect(await status(current), 'awaitingPayment');
      expect(await PurchaseOrder.db.count(s), orders);
      expect((await AgentAction.db.findById(s, stale.id!))!.status, 'expired');
      expect((await AgentAction.db.findById(s, fresh.id!))!.status, 'pending');
      expect(
        (await CheckoutIntent.db.findById(s, abandoned.id!))!.state,
        'cancelled',
      );

      // The back office a judge finds: shifts this week, a catering request,
      // a seeded dispute, suppliers, stock, expenses and two regulars. The
      // first reset of the day seeds them; later resets re-make only shifts.
      expect(first['shifts'], 18);
      expect(first, containsPair('catering', 1));
      expect(first, containsPair('dispute', 1));
      expect(result['shifts'], 18);
      expect(result, containsPair('catering', 0));
      expect(result, containsPair('dispute', 0));
      final rid = restaurant.id!;
      expect(
        await StaffShift.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        18,
      );
      expect(
        await CateringRequest.db.count(
          s,
          where: (t) => t.restaurantId.equals(rid),
        ),
        1,
      );
      expect(
        await Supplier.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        2,
      );
      expect(
        await StockItem.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        6,
      );
      expect(
        await Expense.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        2,
      );
      expect(
        await CustomerProfile.db.count(
          s,
          where: (t) => t.restaurantId.equals(rid),
        ),
        2,
      );
      // No capture exists in this fixture, so no complaint is seeded.
      expect(result, containsPair('complaint', 0));
    });

    test('restoring only the menu leaves orders and the back office', () async {
      final s = builder.build();
      await JudgeModule.reset(s, restaurant.id!);
      final croque = (await menu())['Croque monsieur']!.productId;
      final draft = await MenuDraft.db.insertRow(
        s,
        MenuDraft(
          restaurantId: restaurant.id!,
          userId: 'judge-manager',
          itemsJson: jsonEncode([
            {
              'productId': croque,
              'name': 'Croque monsieur',
              'category': 'Sandwiches',
              'priceMinor': 990,
            },
          ]),
          baseMenuVersion: 0,
          version: 1,
          status: 'draft',
          createdAt: now,
        ),
      );
      await CatalogueModule.publishDraft(
        manager.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: draft.id,
          expectedVersion: 1,
          dataJson: '{"confirm":true,"merge":true}',
        ),
      );
      final paid = await order('accepted', 'paid', at: old);
      final shifts = await StaffShift.db.count(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      );

      final result = await JudgeModule.command(
        manager.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          dataJson: '{"menu":true}',
        ),
      );
      expect(result, containsPair('menuOnly', true));
      expect(result, containsPair('completed', 0));
      expect((await MenuProduct.db.findById(s, croque))!.priceMinor, 750);
      expect(
        (await PurchaseOrder.db.findById(s, paid.id!))!.status,
        'accepted',
      );
      expect(
        await StaffShift.db.count(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ),
        shifts,
      );
    });

    test('the hourly tidy closes demo orders and keeps the menu', () async {
      final s = builder.build();
      await JudgeModule.reset(s, restaurant.id!);
      final croque = (await menu())['Croque monsieur']!.productId;
      final draft = await MenuDraft.db.insertRow(
        s,
        MenuDraft(
          restaurantId: restaurant.id!,
          userId: 'judge-manager',
          itemsJson: jsonEncode([
            {
              'productId': croque,
              'name': 'Croque monsieur',
              'category': 'Sandwiches',
              'priceMinor': 990,
            },
          ]),
          baseMenuVersion: 0,
          version: 1,
          status: 'draft',
          createdAt: now,
        ),
      );
      await CatalogueModule.publishDraft(
        manager.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: draft.id,
          expectedVersion: 1,
          dataJson: '{"confirm":true,"merge":true}',
        ),
      );
      final paid = await order('accepted', 'paid', at: old);
      final current = await order('accepted', 'paid', at: now);

      final result = await JudgeModule.reset(
        s,
        restaurant.id!,
        quiet: const Duration(minutes: 30),
        full: false,
      );
      expect(result, containsPair('completed', 1));
      expect(result.containsKey('menuVersion'), isFalse);
      expect(
        (await PurchaseOrder.db.findById(s, paid.id!))!.status,
        'completed',
      );
      expect(
        (await PurchaseOrder.db.findById(s, current.id!))!.status,
        'accepted',
      );
      expect(
        (await MenuProduct.db.findById(s, croque))!.priceMinor,
        990,
        reason:
            'The tidy leaves a judge’s approved menu until the daily reset.',
      );
      expect(
        await StaffShift.db.count(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ),
        18,
        reason: 'The tidy keeps the seeded back office.',
      );
      expect(
        await CateringRequest.db.count(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ),
        1,
      );

      // The worker queues the tidy once an hour.
      await JudgeModule.schedule(s);
      await JudgeModule.schedule(s);
      expect(
        await PlatformJob.db.count(
          s,
          where: (t) =>
              t.kind.equals('judge.tidy') &
              t.restaurantId.equals(restaurant.id!),
        ),
        1,
      );
    });

    test('its manager runs demos but cannot change who it is', () async {
      final s = builder.build();
      await JudgeModule.reset(s, restaurant.id!);
      Future<Json> configure(
        TestSessionBuilder who, {
        String? name,
        Json settings = const {},
      }) async {
        final policy = (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        return CatalogueModule.configure(
          who.build(),
          PlatformCommand(
            requestKey: key(),
            restaurantId: restaurant.id,
            expectedVersion: policy.version,
            dataJson: jsonEncode({
              'name': name ?? JudgeModule.name,
              'currency': 'USD',
              'settings': settings,
            }),
          ),
        );
      }

      final forbidden = throwsA(
        isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
      );
      await expectLater(configure(manager, name: 'Something else'), forbidden);
      await expectLater(
        configure(manager, settings: {'paused': true}),
        forbidden,
      );
      await expectLater(
        CatalogueModule.publish(
          manager.build(),
          PlatformCommand(
            requestKey: key(),
            restaurantId: restaurant.id,
            dataJson: '{"published":false}',
          ),
        ),
        forbidden,
      );
      await expectLater(
        IdentityModule.invite(
          manager.build(),
          PlatformCommand(
            requestKey: key(),
            restaurantId: restaurant.id,
            dataJson: '{"email":"someone@example.com","role":"kitchen"}',
          ),
        ),
        forbidden,
      );
      // What the copilot proposes still goes through.
      await configure(manager, settings: {'preparationMinutes': 25});
      // The owner keeps every control.
      await configure(owner, settings: {'paused': true});
      final started = await JudgeModule.command(
        manager.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          dataJson: '{}',
        ),
      );
      expect(started['dishes'], 11);
      final settings =
          jsonDecode(
                (await RestaurantPolicy.db.findFirstRow(
                  s,
                  where: (t) => t.restaurantId.equals(restaurant.id!),
                ))!.settingsJson,
              )
              as Map;
      expect(settings['paused'], isFalse);
      expect(settings['preparationMinutes'], 15);
    });

    test('no other restaurant can be reset', () async {
      final other = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Someone else","currency":"USD"}',
        ),
      );
      final forbidden = throwsA(
        isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
      );
      await expectLater(
        JudgeModule.reset(builder.build(), other['id'] as int),
        forbidden,
      );
      await expectLater(
        JudgeModule.command(
          owner.build(),
          PlatformCommand(
            requestKey: key(),
            restaurantId: other['id'] as int,
            dataJson: '{}',
          ),
        ),
        forbidden,
      );
      ProviderClients.environment = () => Platform.environment;
      await expectLater(
        JudgeModule.reset(builder.build(), restaurant.id!),
        forbidden,
      );
    });
  });
}
