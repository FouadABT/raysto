import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. PayPal is a local fake transport bound
// to fixture credentials; nothing here reaches a provider.
void main() {
  withServerpod('V2 counter sales, kitchen rights and payment recovery', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, cashier, waiter, kitchen, cook, customer;
    late Restaurant restaurant;
    late DiningTable table;
    late int burger, fries;
    late FakePayPal paypal;
    const ownerAuth = 'owner-ordering-session';
    var serial = 0;
    String key() => 'ordering_fixture_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user, {String? authId}) => builder.copyWith(
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
    Future<Json> quote(
      TestSessionBuilder who,
      List<Json> lines, {
      String fulfillment = 'pickup',
      int? visitId,
      bool counter = false,
      String? label,
    }) => OrderingModule.quote(
      who.build(),
      CreateQuote(
        requestKey: key(),
        restaurantId: restaurant.id!,
        visitId: visitId,
        fulfillment: fulfillment,
        linesJson: jsonEncode(lines),
        tipMinor: 0,
        onBehalf: counter ? true : null,
        customerLabel: label,
      ),
    );
    Future<Json> submit(TestSessionBuilder who, Json q) =>
        OrderingModule.submit(
          who.build(),
          SubmitOrder(
            requestKey: key(),
            restaurantId: restaurant.id!,
            quoteId: q['id'] as int,
          ),
        );
    Future<Json> pay(
      TestSessionBuilder who, {
      int? orderId,
      int? visitId,
      String method = 'cash',
      int? amountMinor,
    }) => MoneyModule.allocate(
      who.build(),
      AllocatePayment(
        requestKey: key(),
        restaurantId: restaurant.id!,
        orderId: orderId,
        visitId: visitId,
        amountMinor: amountMinor,
        method: method,
      ),
    );
    Future<PurchaseOrder> order(int id) async =>
        (await PurchaseOrder.db.findById(builder.build(), id))!;
    Future<CheckoutIntent> intent(int id) async =>
        (await CheckoutIntent.db.findById(builder.build(), id))!;
    Future<void> member(String user, String role, [List<String>? caps]) =>
        Membership.db.insertRow(
          builder.build(),
          Membership(
            restaurantId: restaurant.id!,
            userId: user,
            role: role,
            active: true,
            capabilities: caps,
          ),
        );
    Future<void> stepUp() => SecurityGrant.db.insertRow(
      builder.build(),
      SecurityGrant(
        userId: 'ordering-owner',
        kind: 'recent_auth',
        proofHash: sha256
            .convert(
              utf8.encode('stepup:ordering-owner:$ownerAuth:recent_auth'),
            )
            .toString(),
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    // Moves a PayPal checkout's lease into the past, as the worker would see it.
    Future<void> age(int checkoutId, String state) async {
      final s = builder.build();
      final row = (await CheckoutIntent.db.findById(s, checkoutId))!;
      row.state = state;
      row.updatedAt = DateTime.now().toUtc().subtract(
        const Duration(minutes: 10),
      );
      await CheckoutIntent.db.updateRow(s, row);
    }

    setUp(() async {
      owner = session('ordering-owner', authId: ownerAuth);
      cashier = session('ordering-cashier');
      waiter = session('ordering-waiter');
      kitchen = session('ordering-kitchen');
      cook = session('ordering-cook');
      customer = session('ordering-customer');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in [
        'ordering-owner',
        'ordering-cashier',
        'ordering-waiter',
        'ordering-kitchen',
        'ordering-cook',
        'ordering-customer',
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
          dataJson: '{"name":"Snack fixture","currency":"EUR"}',
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
      table = await DiningTable.db.insertRow(
        s,
        DiningTable(
          restaurantId: restaurant.id!,
          label: 'B2',
          zone: 'main',
          capacity: 4,
          active: true,
          needsReset: false,
          qrKey: 'ordering-fixture-qr',
          geometryJson: '{}',
          version: 1,
        ),
      );
      await member('ordering-cashier', 'waiter', ['counter']);
      await member('ordering-waiter', 'waiter');
      await member('ordering-kitchen', 'kitchen', ['acceptOrders']);
      await member('ordering-cook', 'kitchen');
      final menu = (await CatalogueModule.saveItem(
        owner.build(),
        command({
          'name': 'Burger',
          'category': 'Mains',
          'priceMinor': 900,
        }, version: 1),
      ));
      burger = menu['id'] as int;
      fries = (await CatalogueModule.saveItem(
        owner.build(),
        command({
          'name': 'Fries',
          'category': 'Sides',
          'priceMinor': 350,
        }, version: menu['menuVersion'] as int),
      ))['id'] as int;
      paypal = FakePayPal();
      ProviderClients.httpClient = paypal.client;
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
        'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': 'true',
        'RAYSTO_SANDBOX_RESTAURANT_ID': '${restaurant.id}',
        'PAYPAL_SANDBOX_MERCHANT_ID': 'MERCHANT-FIXTURE',
        'PAYPAL_SANDBOX_CLIENT_ID': 'fixture-client',
        'PAYPAL_SANDBOX_CLIENT_SECRET': 'fixture-secret',
        'PAYPAL_V2_RETURN_URL': 'https://example.test/return',
        'PAYPAL_V2_CANCEL_URL': 'https://example.test/cancel',
      };
    });
    tearDown(() {
      ProviderClients.httpClient = http.Client.new;
      ProviderClients.environment = () => Platform.environment;
    });

    Future<Json> counterSale({String? label}) async {
      final q = await quote(
        cashier,
        [
          {'productId': burger, 'quantity': 1},
          {'productId': fries, 'quantity': 1},
        ],
        counter: true,
        label: label,
      );
      return submit(cashier, q);
    }

    Future<int> onlineSale() async {
      final q = await quote(customer, [
        {'productId': burger, 'quantity': 1},
      ]);
      return (await submit(customer, q))['orderId'] as int;
    }

    Future<Json> step(TestSessionBuilder who, int id, String status, [Json extra = const {}]) async =>
        OrderingModule.transition(
          who.build(),
          command({'status': status, ...extra}, id: id, version: (await order(id)).version),
        );

    // From accepted to completed: cook every line, mark ready, hand over.
    Future<void> cookAndHandOver(TestSessionBuilder handler, int id, [Json collect = const {}]) async {
      if ((await order(id)).status == 'submitted') await step(owner, id, 'accepted');
      await step(owner, id, 'preparing');
      final s = builder.build();
      for (final t in await KitchenProgress.db.find(s, where: (t) => t.orderId.equals(id))) {
        await OrderingModule.kitchen(
          owner.build(),
          command({'lineKey': t.lineKey, 'completedQuantity': t.quantity}, id: id, version: t.version),
        );
      }
      await step(owner, id, 'ready');
      await step(handler, id, 'collected', collect);
      await step(owner, id, 'completed');
    }

    test('a counter sale is numbered, coded and kept out of the cashier history', () async {
      final first = await counterSale(label: 'Sam');
      final second = await counterSale();
      expect(first['number'], 1);
      expect(second['number'], 2);
      final s = builder.build();
      final sale = await order(first['orderId'] as int);
      expect(sale.customerId, OrderingModule.walkIn(restaurant.id!));
      expect(sale.status, 'awaitingPayment');
      expect(
        await PurchaseOrder.db.count(
          s,
          where: (t) => t.customerId.equals('ordering-cashier'),
        ),
        0,
      );
      final ctx = (await OrderContext.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(sale.id!),
      ))!;
      expect(ctx.origin, 'counter');
      expect(ctx.customerLabel, 'Sam');
      expect(ctx.placedBy, 'ordering-cashier');
      expect(ctx.pickupCode, matches(RegExp(r'^\d{4}$')));
      await pay(cashier, orderId: sale.id);
      final paid = await order(sale.id!);
      expect(paid.paymentStatus, 'paid');
      // Staff took the order, so once paid it goes straight to the kitchen.
      expect(paid.status, 'accepted');
    });

    test('the daily number restarts on a new service day', () async {
      final yesterday = await counterSale();
      final s = builder.build();
      // Move the earlier ticket and the counter to a past service day.
      final ctx = (await OrderContext.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(yesterday['orderId'] as int),
      ))!;
      ctx.serviceDay = '2000-01-01';
      await OrderContext.db.updateRow(s, ctx);
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.orderSeqDay = '2000-01-01';
      await RestaurantPolicy.db.updateRow(s, policy);
      expect((await counterSale())['number'], 1);
    });

    test('a waiter without the counter capability cannot ring up sales', () async {
      await expectLater(
        quote(waiter, [
          {'productId': burger, 'quantity': 1},
        ], counter: true),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      await expectLater(
        quote(customer, [
          {'productId': burger, 'quantity': 1},
        ], counter: true),
        throwsA(isA<DomainError>()),
      );
    });

    test('a kitchen that accepts orders can accept; one that does not cannot', () async {
      final id = await onlineSale();
      await pay(owner, orderId: id);
      final ready = await order(id);
      expect(ready.status, 'submitted');
      await expectLater(
        OrderingModule.transition(
          cook.build(),
          command({'status': 'accepted'}, id: id, version: ready.version),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      final accepted = await OrderingModule.transition(
        kitchen.build(),
        command({'status': 'accepted'}, id: id, version: ready.version),
      );
      expect(accepted['status'], 'accepted');
    });

    test('paid online orders skip acceptance when the shop auto-accepts', () async {
      final waiting = await onlineSale();
      await pay(owner, orderId: waiting);
      expect((await order(waiting)).status, 'submitted');
      final s = builder.build();
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.settingsJson = jsonEncode({
        ..._decode(policy.settingsJson),
        'autoAcceptPaid': true,
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      final id = await onlineSale();
      await pay(owner, orderId: id);
      expect((await order(id)).status, 'accepted');
    });

    test('checking an unapproved PayPal checkout leaves it cancellable', () async {
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      final created = await MoneyModule.checkout(
        cashier.build(),
        command({}, id: checkout),
      );
      expect(created['state'], 'created');
      // The customer taps "I approved" before approving in PayPal.
      final checked = await MoneyModule.capture(
        cashier.build(),
        command({}, id: checkout),
      );
      expect(checked['state'], 'created');
      expect(paypal.calls.where((c) => c.endsWith('/capture')), isEmpty);
      final cancelled = await MoneyModule.cancel(
        cashier.build(),
        command({}, id: checkout),
      );
      expect(cancelled['state'], 'cancelled');
    });

    test('a failed PayPal read is not treated as an unknown capture', () async {
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      paypal.failReads = true;
      await expectLater(
        MoneyModule.capture(cashier.build(), command({}, id: checkout)),
        throwsA(isA<DomainError>()),
      );
      expect((await intent(checkout)).state, isNot('uncertain'));
      // The worker's next read, once the lease is stale, restores the state.
      paypal.failReads = false;
      await age(checkout, 'capturing');
      final restored = await MoneyModule.reconcile(builder.build(), checkout);
      expect(restored['state'], 'created');
    });

    test('approval followed by a check settles the order', () async {
      final sale = await counterSale();
      final id = sale['orderId'] as int;
      final checkout =
          (await pay(cashier, orderId: id, method: 'paypal'))['checkoutId'] as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      paypal.status = 'APPROVED';
      final done = await MoneyModule.capture(
        cashier.build(),
        command({}, id: checkout),
      );
      expect(done['state'], 'completed');
      expect((await order(id)).paymentStatus, 'paid');
    });

    test('an approval seen by the worker is captured without the payer returning', () async {
      final sale = await counterSale();
      final id = sale['orderId'] as int;
      final checkout =
          (await pay(cashier, orderId: id, method: 'paypal'))['checkoutId'] as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      // Not approved yet: the worker only reads.
      expect(
        (await MoneyModule.settleApproved(builder.build(), checkout))['state'],
        'created',
      );
      paypal.status = 'APPROVED';
      final settled = await MoneyModule.settleApproved(builder.build(), checkout);
      expect(settled['state'], 'completed');
      expect((await order(id)).paymentStatus, 'paid');
      expect(
        paypal.calls.where((c) => c.endsWith('/capture')),
        hasLength(1),
      );
    });

    test('a manager releases an unresolved checkout only when PayPal shows no capture', () async {
      await stepUp();
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      await age(checkout, 'uncertain');
      final released = await MoneyModule.release(
        owner.build(),
        command({}, id: checkout),
      );
      expect(released['released'], isTrue);
      expect((await intent(checkout)).state, 'cancelled');

      final other = await counterSale();
      final second =
          (await pay(cashier, orderId: other['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      paypal.reset();
      await MoneyModule.checkout(cashier.build(), command({}, id: second));
      paypal.status = 'APPROVED';
      paypal.captured = true;
      await age(second, 'uncertain');
      final kept = await MoneyModule.release(
        owner.build(),
        command({}, id: second),
      );
      expect(kept['released'], isFalse);
      expect((await intent(second)).state, 'completed');
    });

    test('a refund for one order on a shared capture leaves the other order paid', () async {
      await stepUp();
      final visit = await DiningModule.start(
        owner.build(),
        StartVisit(
          requestKey: key(),
          restaurantId: restaurant.id!,
          tableId: table.id!,
          guestCount: 2,
        ),
      );
      final visitId = visit['id'] as int;
      final a = await submit(
        owner,
        await quote(owner, [
          {'productId': burger, 'quantity': 1},
        ], fulfillment: 'dineIn', visitId: visitId),
      );
      final b = await submit(
        owner,
        await quote(owner, [
          {'productId': fries, 'quantity': 1},
        ], fulfillment: 'dineIn', visitId: visitId),
      );
      await pay(owner, visitId: visitId);
      final s = builder.build();
      final capture = (await PaymentCapture.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      final refund = await MoneyModule.refund(
        owner.build(),
        RequestRefund(
          requestKey: key(),
          restaurantId: restaurant.id!,
          captureId: capture.id!,
          amountMinor: 100,
          reason: 'Cold fries',
          orderId: b['orderId'] as int,
        ),
      );
      await MoneyModule.processRefund(s, refund['refundId'] as int);
      expect((await order(a['orderId'] as int)).paymentStatus, 'paid');
      expect(
        (await order(b['orderId'] as int)).paymentStatus,
        'partiallyRefunded',
      );
    });

    test('a partially refunded paid order goes all the way to collection', () async {
      await stepUp();
      final sale = await counterSale();
      final id = sale['orderId'] as int;
      await pay(cashier, orderId: id);
      final s = builder.build();
      final capture = (await PaymentCapture.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      final refund = await MoneyModule.refund(
        owner.build(),
        RequestRefund(
          requestKey: key(),
          restaurantId: restaurant.id!,
          captureId: capture.id!,
          amountMinor: 200,
          reason: 'Missing sauce',
        ),
      );
      await MoneyModule.processRefund(s, refund['refundId'] as int);
      final refunded = await order(id);
      expect(refunded.paymentStatus, 'partiallyRefunded');
      expect(refunded.status, 'accepted');
      await cookAndHandOver(cashier, id);
      expect((await order(id)).status, 'completed');
    });

    test('an order with a settled share is not expired while others pay', () async {
      final visit = await DiningModule.start(
        owner.build(),
        StartVisit(
          requestKey: key(),
          restaurantId: restaurant.id!,
          tableId: table.id!,
          guestCount: 2,
        ),
      );
      final visitId = visit['id'] as int;
      final placed = await submit(
        owner,
        await quote(owner, [
          {'productId': burger, 'quantity': 2},
        ], fulfillment: 'dineIn', visitId: visitId),
      );
      await pay(owner, visitId: visitId, amountMinor: 900);
      await expectLater(
        PlatformWorker.expireOrder(builder.build(), placed['orderId'] as int),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'payment_pending'),
        ),
      );
      expect(
        (await order(placed['orderId'] as int)).status,
        'awaitingPayment',
      );
    });

    test('a partial settings save keeps every other saved setting', () async {
      final s = builder.build();
      final before = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      await CatalogueModule.configure(
        owner.build(),
        command({
          'name': 'Snack fixture',
          'currency': 'EUR',
          'settings': {'slotMinutes': 30},
        }, version: before.version),
      );
      final after = _decode(
        (await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!.settingsJson,
      );
      expect(after['slotMinutes'], 30);
      expect((after['hours'] as List), hasLength(7));
      expect(after['contactEmail'], 'owner@example.test');
    });

    test('toggling one item does not expire quotes for other items', () async {
      final q = await quote(customer, [
        {'productId': fries, 'quantity': 1},
      ]);
      final product = (await MenuProduct.db.findById(builder.build(), burger))!;
      await expectLater(
        CatalogueModule.availability(
          kitchen.build(),
          command({}, id: burger, version: product.version),
        ),
        throwsA(isA<DomainError>()),
      );
      await CatalogueModule.availability(
        kitchen.build(),
        command({'available': false}, id: burger, version: product.version),
      );
      final placed = await submit(customer, q);
      expect(placed['status'], 'awaitingPayment');
    });

    test('capabilities are validated when a manager grants them', () async {
      await IdentityModule.membership(
        owner.build(),
        command({
          'userId': 'ordering-waiter',
          'role': 'waiter',
          'active': true,
          'capabilities': ['dispatch', 'counter'],
        }),
      );
      final m = (await Membership.db.findFirstRow(
        builder.build(),
        where: (t) =>
            t.restaurantId.equals(restaurant.id!) &
            t.userId.equals('ordering-waiter'),
      ))!;
      expect(m.capabilities, ['counter', 'dispatch']);
      await expectLater(
        IdentityModule.membership(
          owner.build(),
          command({
            'userId': 'ordering-waiter',
            'role': 'waiter',
            'active': true,
            'capabilities': ['refunds'],
          }),
        ),
        throwsA(isA<DomainError>()),
      );
    });

    test('a courier can never hold counter rights', () async {
      final s = builder.build();
      final now = DateTime.now().toUtc();
      await ActorProfile.db.insertRow(
        s,
        ActorProfile(
          userId: 'ordering-courier',
          isGuest: false,
          disabled: false,
          dataJson: '{}',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await member('ordering-courier', 'courier');
      await expectLater(
        IdentityModule.membership(
          owner.build(),
          command({
            'userId': 'ordering-courier',
            'role': 'courier',
            'active': true,
            'capabilities': ['counter'],
          }),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_input')),
      );
      // A grant stored before this rule existed is ignored.
      final m = (await Membership.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(restaurant.id!) &
            t.userId.equals('ordering-courier'),
      ))!;
      m.capabilities = ['counter'];
      await Membership.db.updateRow(s, m);
      await expectLater(
        quote(session('ordering-courier'), [
          {'productId': burger, 'quantity': 1},
        ], counter: true),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
    });

    test('the till keeps selling when online ordering is paused or closed', () async {
      final s = builder.build();
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.settingsJson = jsonEncode({
        ..._decode(policy.settingsJson),
        'paused': true,
        'hours': [],
        'modes': ['dineIn'],
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      restaurant.published = false;
      await Restaurant.db.updateRow(s, restaurant);
      final sale = await counterSale();
      expect(sale['number'], 1);
      await expectLater(
        quote(customer, [
          {'productId': burger, 'quantity': 1},
        ]),
        throwsA(isA<DomainError>()),
      );
      policy.suspended = true;
      await RestaurantPolicy.db.updateRow(s, policy);
      await expectLater(counterSale(), throwsA(isA<DomainError>()));
    });

    test('counter staff cannot take cash on or cancel a customer\'s own order', () async {
      final id = await onlineSale();
      await expectLater(
        pay(cashier, orderId: id),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      await expectLater(
        OrderingModule.cancel(
          cashier.build(),
          command({'reason': 'No show'}, id: id, version: (await order(id)).version),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      await pay(owner, orderId: id);
      expect((await order(id)).paymentStatus, 'paid');
    });

    test('an online pickup is handed over only against its code', () async {
      final id = await onlineSale();
      await pay(owner, orderId: id);
      await step(owner, id, 'accepted');
      await step(owner, id, 'preparing');
      final s = builder.build();
      for (final t in await KitchenProgress.db.find(s, where: (t) => t.orderId.equals(id))) {
        await OrderingModule.kitchen(
          owner.build(),
          command({'lineKey': t.lineKey, 'completedQuantity': t.quantity}, id: id, version: t.version),
        );
      }
      await step(owner, id, 'ready');
      final ctx = (await OrderContext.db.findFirstRow(s, where: (t) => t.orderId.equals(id)))!;
      Matcher mismatch = throwsA(
        isA<DomainError>().having((e) => e.code, 'code', 'pickup_code_mismatch'),
      );
      await expectLater(step(cashier, id, 'collected'), mismatch);
      final wrong = ctx.pickupCode == '0000' ? '1111' : '0000';
      await expectLater(step(cashier, id, 'collected', {'code': wrong}), mismatch);
      final done = await step(cashier, id, 'collected', {'code': ctx.pickupCode});
      expect(done['status'], 'collected');
    });

    test('pickup codes are unique within a service day', () async {
      final codes = <String>{};
      for (var i = 0; i < 12; i++) {
        final sale = await counterSale();
        final ctx = (await OrderContext.db.findFirstRow(
          builder.build(),
          where: (t) => t.orderId.equals(sale['orderId'] as int),
        ))!;
        expect(codes.add(ctx.pickupCode!), isTrue);
      }
    });

    test('a day that resumes continues after its highest ticket number', () async {
      await counterSale();
      await counterSale();
      final s = builder.build();
      // As if the timezone moved the counter to another day and back.
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.orderSeqDay = '2000-01-01';
      policy.orderSeq = 7;
      await RestaurantPolicy.db.updateRow(s, policy);
      expect((await counterSale())['number'], 3);
    });

    test('a capture that lands after a release is recorded for review', () async {
      await stepUp();
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      await age(checkout, 'uncertain');
      final released = await MoneyModule.release(owner.build(), command({}, id: checkout));
      expect(released['released'], isTrue);
      // PayPal finishes a capture that was still on its way.
      paypal.status = 'APPROVED';
      paypal.captured = true;
      final after = await MoneyModule.settleApproved(builder.build(), checkout);
      expect(after['state'], 'cancelled');
      final s = builder.build();
      final capture = (await PaymentCapture.db.findFirstRow(
        s,
        where: (t) => t.checkoutId.equals(checkout),
      ))!;
      expect(capture.state, 'review');
      final exception = (await PaymentException.db.findFirstRow(
        s,
        where: (t) => t.captureId.equals(capture.id!),
      ))!;
      expect(exception.kind, 'captureAfterRelease');
      // Seen once, recorded once.
      await MoneyModule.settleApproved(builder.build(), checkout);
      expect(
        await PaymentException.db.count(s, where: (t) => t.captureId.equals(capture.id!)),
        1,
      );
    });

    test('a read that changes nothing leaves the checkout time stamp alone', () async {
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      await MoneyModule.checkout(cashier.build(), command({}, id: checkout));
      final before = (await intent(checkout)).updatedAt;
      await MoneyModule.reconcile(builder.build(), checkout);
      await MoneyModule.reconcile(builder.build(), checkout);
      expect((await intent(checkout)).updatedAt, before);
    });

    test('another cashier can cancel a colleague\'s walk-in checkout', () async {
      final sale = await counterSale();
      final checkout =
          (await pay(cashier, orderId: sale['orderId'] as int, method: 'paypal'))['checkoutId']
              as int;
      final s = builder.build();
      final now = DateTime.now().toUtc();
      await ActorProfile.db.insertRow(
        s,
        ActorProfile(
          userId: 'ordering-cashier-2',
          isGuest: false,
          disabled: false,
          dataJson: '{}',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await member('ordering-cashier-2', 'waiter', ['counter']);
      final cancelled = await MoneyModule.cancel(
        session('ordering-cashier-2').build(),
        command({}, id: checkout),
      );
      expect(cancelled['state'], 'cancelled');
    });
  });
}

Json _decode(String raw) => jsonDecode(raw) as Json;

/// A PayPal Orders v2 double for one order whose status each test controls.
class FakePayPal {
  String status = 'CREATED';
  bool failReads = false;
  bool captured = false;
  int checkoutId = 0;
  String merchant = '';
  int amountMinor = 0;
  String currency = 'EUR';
  final calls = <String>[];

  void reset() {
    status = 'CREATED';
    failReads = false;
    captured = false;
    calls.clear();
  }

  Json get _amount => {
    'currency_code': currency,
    'value': PayPalGateway.money(amountMinor),
  };

  Json order() => {
    'id': 'PP-ORDER-$checkoutId',
    'intent': 'CAPTURE',
    'status': captured ? 'COMPLETED' : status,
    'purchase_units': [
      {
        'custom_id': 'raysto-v2:$checkoutId',
        'payee': {'merchant_id': merchant},
        'amount': _amount,
        if (captured)
          'payments': {
            'captures': [
              {
                'id': 'CAPTURE-$checkoutId',
                'status': 'COMPLETED',
                'final_capture': true,
                'amount': _amount,
              },
            ],
          },
      },
    ],
    'links': [
      {
        'rel': 'payer-action',
        'href':
            'https://www.sandbox.paypal.com/checkoutnow?token=PP-ORDER-$checkoutId',
      },
    ],
  };

  http.Client client() => MockClient((request) async {
    final path = request.url.path;
    calls.add('${request.method} $path');
    if (path == '/v1/oauth2/token') {
      return http.Response(jsonEncode({'access_token': 'fixture-token'}), 200);
    }
    if (request.method == 'POST' && path == '/v2/checkout/orders') {
      final unit = (jsonDecode(request.body)['purchase_units'] as List).single
          as Map;
      checkoutId = int.parse((unit['custom_id'] as String).split(':').last);
      merchant = (unit['payee'] as Map)['merchant_id'] as String;
      final amount = unit['amount'] as Map;
      amountMinor = PayPalGateway.parseMoney(amount['value'] as String);
      currency = amount['currency_code'] as String;
      return http.Response(jsonEncode(order()), 201);
    }
    if (failReads) return http.Response('{}', 503);
    if (request.method == 'GET' && path == '/v2/checkout/orders/PP-ORDER-$checkoutId') {
      return http.Response(jsonEncode(order()), 200);
    }
    if (request.method == 'POST' &&
        path == '/v2/checkout/orders/PP-ORDER-$checkoutId/capture') {
      if (status != 'APPROVED') {
        return http.Response('{"name":"UNPROCESSABLE_ENTITY"}', 422);
      }
      captured = true;
      return http.Response(jsonEncode(order()), 201);
    }
    return http.Response('{}', 404);
  });
}
