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
      // Every reset asks the catering demo afresh; the dispute stays.
      expect(result, containsPair('catering', 1));
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
      // Eight stock items since 0.16 (oranges and Gruyère for the recipes).
      expect(
        await StockItem.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        8,
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

    test('the 0.16 back office is seeded as labelled samples, once', () async {
      final s = builder.build();
      final rid = restaurant.id!;
      for (final user in ['judge-courier']) {
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
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: rid,
          userId: 'judge-courier',
          role: 'courier',
          active: true,
        ),
      );
      // The franchise demo's second café, owned by the same owner.
      final created = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Harbour fixture","currency":"USD"}',
        ),
      );
      final second = created['id'] as int;
      final policy2 = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(second),
      ))!;
      policy2.settingsJson = jsonEncode({
        ...jsonDecode(policy2.settingsJson) as Map,
        'contactEmail': 'owner@example.com',
      });
      await RestaurantPolicy.db.updateRow(s, policy2);
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: second,
          userId: 'judge-manager',
          role: 'manager',
          active: true,
        ),
      );
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_JUDGE_RESTAURANT_ID': '$rid',
        'RAYSTO_JUDGE_SECOND_RESTAURANT_ID': '$second',
        'RAYSTO_JUDGE_PAYOUT_EMAILS':
            'buyer-one@personal.example.com,buyer-two@personal.example.com',
        'RAYSTO_PAY_LINK_SECRET': 'judge-test-pay-link-secret',
      };

      final first = await JudgeModule.reset(s, rid);
      // The four bills, this month's expected electricity and the
      // supplier's bill for the received order.
      expect(first['bills'], 6);
      expect(first['supplierOrders'], 3);
      expect(first['drivers'], 3);
      expect(first['group'], 1);
      expect(first['payLink'], 1);
      expect(first['recipes'], greaterThan(15));

      // Every seeded row says it is a sample.
      final bills = await Bill.db.find(s, where: (t) => t.restaurantId.equals(rid));
      expect(bills, hasLength(6));
      for (final b in bills) {
        expect(b.vendor, endsWith(JudgeModule.sample));
        expect(jsonDecode(b.readJson)['sample'], isTrue);
      }
      final byCategory = {
        for (final b in bills.where((b) => b.state != 'expected')) b.category: b,
      };
      // This month's electricity is expected, with the vendor's Sandbox
      // PayPal email, so the bill read from the sample PDF can take it over.
      final expected = bills.singleWhere((b) => b.state == 'expected');
      expect(expected.category, 'electricity');
      expect(expected.recurringOfId, byCategory['electricity']!.id);
      expect(expected.payVia, 'paypal');
      expect(expected.payeeEmail, 'buyer-one@personal.example.com');
      // The rent is paid elsewhere: the landlord has no PayPal.
      expect(byCategory['rent']!.state, 'paidElsewhere');
      expect(byCategory['rent']!.payeeEmail, isNull);
      // The internet bill goes to a Sandbox account: paying it is a real Payout.
      expect(byCategory['internet']!.payVia, 'paypal');
      expect(byCategory['internet']!.payeeEmail, 'buyer-two@personal.example.com');
      expect(byCategory['water']!.state, 'approved');
      // Nothing claims a PayPal payment that did not happen.
      expect(bills.where((b) => b.state == 'paid' || b.payoutBatchId != null), isEmpty);

      final orders = await SupplierOrder.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        orderBy: (t) => t.id,
      );
      expect([for (final o in orders) o.state], ['draft', 'sent', 'received']);
      expect(orders.every((o) => o.note!.contains('Sample')), isTrue);
      final received = jsonDecode(orders.last.linesJson) as List;
      expect(
        received.any((l) => l['receivedUnitCostMinor'] != l['unitCostMinor']),
        isTrue,
        reason: 'The received order carries a price change to flag.',
      );
      // Its bill, at the delivered prices, completes the 3-way match.
      final supplierBill = byCategory['supplier']!;
      expect(supplierBill.supplierOrderId, orders.last.id);
      expect(supplierBill.state, 'review');
      expect(supplierBill.amountMinor, 6 * 650 + 10 * 1040);

      final drivers = await Driver.db.find(s, where: (t) => t.restaurantId.equals(rid));
      expect(drivers.where((d) => d.userId == 'judge-courier'), hasLength(1));
      expect(
        drivers.where((d) => d.userId == null).every((d) => d.name.endsWith(JudgeModule.sample)),
        isTrue,
      );

      final request = (await PaymentRequest.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(rid),
      ))!;
      expect(request.payerName, endsWith(JudgeModule.sample));
      expect(request.kind, 'link');
      expect(request.state, 'open');
      // Made like request.create makes a link, so its QR code really opens.
      expect(request.linkTokenHash, isNot(startsWith('pending:')));
      expect(request.linkTokenHash, hasLength(64));

      // The group: both cafés, the owner as owner, the manager as area manager.
      final link = (await GroupVenue.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(rid),
      ))!;
      final group = (await RestaurantGroup.db.findById(s, link.groupId))!;
      expect(group.name, JudgeModule.groupName);
      expect(
        {
          for (final v in await GroupVenue.db.find(
            s,
            where: (t) => t.groupId.equals(group.id!),
          ))
            v.restaurantId,
        },
        {rid, second},
      );
      final members = {
        for (final m in await GroupMembership.db.find(
          s,
          where: (t) => t.groupId.equals(group.id!),
        ))
          m.userId: m.role,
      };
      expect(members, {'judge-owner': 'owner', 'judge-manager': 'areaManager'});

      // The second café resets like the first, under its own sample name.
      final harbour = await JudgeModule.reset(s, second);
      expect(harbour['dishes'], 11);
      expect(harbour['bills'], 5);
      final cafe2 = (await Restaurant.db.findById(s, second))!;
      expect(cafe2.name, JudgeModule.secondName);
      final cafe2Bills = await Bill.db.find(s, where: (t) => t.restaurantId.equals(second));
      expect(cafe2Bills.where((b) => b.payVia == 'paypal'), isEmpty,
          reason: 'The second café has no Sandbox payees.');

      // The tidy keeps all of it; a second full reset adds nothing new.
      final tidy = await JudgeModule.reset(s, rid, full: false);
      expect(tidy.containsKey('bills'), isFalse);
      final again = await JudgeModule.reset(s, rid);
      expect(again['bills'], 0);
      expect(again['group'], 0);
      expect(again['supplierOrders'], 0);
      expect(again['drivers'], 0);
      expect(again['payLink'], 0);
      expect(
        await RestaurantGroup.db.count(s),
        1,
      );
      expect(
        await SupplierOrder.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        3,
      );
      expect(
        await Driver.db.count(s, where: (t) => t.restaurantId.equals(rid)),
        3,
      );
    });

    test('the reset puts stock back with an audited adjustment and clears old unpaid bills', () async {
      final s = builder.build();
      final rid = restaurant.id!;
      await JudgeModule.reset(s, rid);
      final beans = (await StockItem.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(rid) & t.name.equals('Espresso beans'),
      ))!;
      beans.quantity = 9;
      await StockItem.db.updateRow(s, beans);
      // A judge's own bill, read yesterday and never paid, and one they paid.
      final yesterday = now.subtract(const Duration(days: 1));
      Bill bill(String state) => Bill(
        restaurantId: rid,
        vendor: 'A judge’s upload',
        category: 'electricity',
        amountMinor: 1000,
        vatMinor: 0,
        currency: 'USD',
        state: state,
        payVia: 'elsewhere',
        readJson: '{}',
        version: 1,
        createdAt: yesterday,
        updatedAt: yesterday,
      );
      final unpaid = await Bill.db.insertRow(s, bill('review'));
      final settled = await Bill.db.insertRow(s, bill('paidElsewhere'));

      await JudgeModule.reset(s, rid);
      final after = (await StockItem.db.findById(s, beans.id!))!;
      expect(after.quantity, 2.0);
      expect(after.parLevel, 6.0);
      final moves = await StockMovement.db.find(
        s,
        where: (t) => t.stockItemId.equals(beans.id!) & t.refType.equals('judge.reset'),
      );
      expect(moves, hasLength(1));
      expect(moves.single.kind, 'adjust');
      expect(moves.single.quantity, closeTo(-7, 1e-9));
      expect(await Bill.db.findById(s, unpaid.id!), isNull);
      expect(await Bill.db.findById(s, settled.id!), isNotNull);
    });

    test('the hourly tidy releases a paid bill read from a sample file, keeping the money record', () async {
      final s = builder.build();
      final rid = restaurant.id!;
      await JudgeModule.reset(s, rid);
      final earlier = now.subtract(const Duration(hours: 2));
      final paid = await Bill.db.insertRow(
        s,
        Bill(
          restaurantId: rid,
          vendor: 'Hudson Power & Light · Sample',
          category: 'electricity',
          reference: 'HPL-2026-11-0417',
          amountMinor: 19086,
          vatMinor: 1414,
          currency: 'USD',
          state: 'paid',
          payVia: 'paypal',
          payeeEmail: 'buyer-one@personal.example.com',
          sourceMediaId: 77,
          contentSha: 'a' * 64,
          payoutBatchId: 5,
          readJson: '{"from":"agent"}',
          paidAt: earlier,
          version: 3,
          createdAt: earlier,
          updatedAt: earlier,
        ),
      );
      final fresh = await Bill.db.insertRow(
        s,
        paid.copyWith(
          id: null,
          reference: 'HPL-FRESH',
          contentSha: 'b' * 64,
          updatedAt: now,
        ),
      );
      await AgentTask.db.insertRow(
        s,
        AgentTask(
          restaurantId: rid,
          agent: 'accountant',
          trigger: 'user',
          dedupeKey: 'bill:$rid:77',
          status: 'done',
          title: 'Read a bill',
          inputJson: '{}',
          stateJson: '{}',
          traceJson: '[]',
          feature: 'agent.accountant',
          reservedMicros: 0,
          chargedMicros: 0,
          version: 1,
          createdAt: earlier,
          updatedAt: earlier,
        ),
      );

      final tidy = await JudgeModule.reset(s, rid, full: false);
      expect(tidy['readBills'], 1);
      final released = (await Bill.db.findById(s, paid.id!))!;
      expect(released.contentSha, isNull);
      expect(released.reference, 'HPL-2026-11-0417 (earlier demo run)');
      // The money record is untouched.
      expect(released.state, 'paid');
      expect(released.amountMinor, 19086);
      expect(released.payoutBatchId, 5);
      expect(released.paidAt, isNotNull);
      // A bill paid in the last hour is left as it is.
      expect((await Bill.db.findById(s, fresh.id!))!.contentSha, 'b' * 64);
      final task = (await AgentTask.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(rid) & t.agent.equals('accountant'),
      ))!;
      expect(task.dedupeKey, 'bill:$rid:77:run${task.id}');
      // A second tidy has nothing more to release.
      expect((await JudgeModule.reset(s, rid, full: false))['readBills'], 0);
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
