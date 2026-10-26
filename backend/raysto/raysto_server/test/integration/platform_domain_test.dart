import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// SQL integration definitions only. Use the isolated Raysto test cluster when
// execution is authorized. These tests never call Firebase, Gemini or PayPal.
void main() {
  withServerpod('V2 tenant and dining invariants', (builder, api) {
    late TestSessionBuilder owner, guest, stranger;
    late Restaurant restaurant;
    late DiningTable table;
    var seq = 0;
    String key() => 'platform_test_${(++seq).toString().padLeft(8, '0')}';
    PlatformCommand command(
      Map<String, dynamic> data, {
      int? id,
      int? version,
      int? tenant,
    }) => PlatformCommand(
      requestKey: key(),
      restaurantId: tenant ?? restaurant.id,
      resourceId: id,
      expectedVersion: version,
      dataJson: jsonEncode(data),
    );
    setUp(() async {
      owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'owner-v2',
          {},
        ),
      );
      guest = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'guest-v2',
          {},
        ),
      );
      stranger = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'other-v2',
          {},
        ),
      );
      final s = builder.build();
      for (final name in ['owner-v2', 'guest-v2', 'other-v2']) {
        await ActorProfile.db.insertRow(
          s,
          ActorProfile(
            userId: name,
            isGuest: name == 'guest-v2',
            disabled: false,
            dataJson: '{}',
            version: 1,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
      final result = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Fixture","currency":"EUR"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, result['id'] as int))!;
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
          label: 'A1',
          zone: 'main',
          capacity: 4,
          active: true,
          needsReset: false,
          qrKey: 'fixture-public-qr',
          geometryJson: '{}',
          version: 1,
        ),
      );
    });
    test('REST identity proofs stay bound to their own request session', () {
      final first = owner.build(), second = stranger.build();
      PlatformApi.bindHttpHeaders(first, {
        'x-raysto-firebase-token': 'request-one-proof',
        'x-firebase-appcheck': 'request-one-attestation',
        'client-role': 'owner',
      });
      expect(
        PlatformApi.requestHeader(first, 'x-raysto-firebase-token'),
        'request-one-proof',
      );
      expect(
        PlatformApi.requestHeader(first, 'x-firebase-appcheck'),
        'request-one-attestation',
      );
      expect(PlatformApi.requestHeader(first, 'client-role'), isNull);
      expect(
        PlatformApi.requestHeader(second, 'x-raysto-firebase-token'),
        isNull,
      );
    });
    test('guest cannot create a restaurant or grant membership', () async {
      await expectLater(
        IdentityModule.createRestaurant(
          guest.build(),
          PlatformCommand(
            requestKey: key(),
            dataJson: '{"name":"Bad","currency":"EUR"}',
          ),
        ),
        throwsA(isA<DomainError>()),
      );
      await expectLater(
        IdentityModule.invite(
          guest.build(),
          command({'email': 'x@example.test', 'role': 'manager'}),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test('table code alone does not authorize seating', () async {
      await expectLater(
        DiningModule.start(
          guest.build(),
          StartVisit(
            requestKey: key(),
            restaurantId: restaurant.id!,
            tableId: table.id!,
            guestCount: 2,
          ),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test(
      'one active visit per table and repeated command returns same visit',
      () async {
        final request = StartVisit(
          requestKey: key(),
          restaurantId: restaurant.id!,
          tableId: table.id!,
          guestCount: 2,
        );
        final first = await DiningModule.start(owner.build(), request);
        final second = await DiningModule.start(owner.build(), request);
        expect(first, second);
        await expectLater(
          DiningModule.start(
            owner.build(),
            StartVisit(
              requestKey: key(),
              restaurantId: restaurant.id!,
              tableId: table.id!,
              guestCount: 1,
            ),
          ),
          throwsA(isA<DomainError>()),
        );
        expect(await DiningVisit.db.count(builder.build()), 1);
      },
    );
    test('foreign table reference cannot cross restaurant boundary', () async {
      final other = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Second","currency":"EUR"}',
        ),
      );
      await expectLater(
        DiningModule.resetTable(
          owner.build(),
          command({}, tenant: other['id'] as int, id: table.id, version: 1),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test('stale menu revisions cannot overwrite a later publication', () async {
      final item = {'name': 'Soup', 'category': 'Starter', 'priceMinor': 500};
      await CatalogueModule.saveItem(owner.build(), command(item, version: 1));
      await expectLater(
        CatalogueModule.saveItem(
          owner.build(),
          command({...item, 'name': 'Stale soup'}, version: 1),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test(
      'same key with changed guest count is an idempotency conflict',
      () async {
        final k = key();
        await DiningModule.start(
          owner.build(),
          StartVisit(
            requestKey: k,
            restaurantId: restaurant.id!,
            tableId: table.id!,
            guestCount: 1,
          ),
        );
        await expectLater(
          DiningModule.start(
            owner.build(),
            StartVisit(
              requestKey: k,
              restaurantId: restaurant.id!,
              tableId: table.id!,
              guestCount: 2,
            ),
          ),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'idempotency_conflict',
            ),
          ),
        );
      },
    );
    test('a deactivated waiter loses command access immediately', () async {
      await Membership.db.insertRow(
        builder.build(),
        Membership(
          restaurantId: restaurant.id!,
          userId: 'other-v2',
          role: 'waiter',
          active: false,
        ),
      );
      await expectLater(
        DiningModule.resetTable(
          stranger.build(),
          command({}, id: table.id, version: 1),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test(
      'cash split, duplicate retry, and final settlement cannot overcollect',
      () async {
        final s = owner.build();
        final order = await PurchaseOrder.db.insertRow(
          s,
          PurchaseOrder(
            restaurantId: restaurant.id!,
            customerId: 'guest-v2',
            requestKey: key(),
            requestHash: 'fixture',
            fulfillment: 'pickup',
            lines: [],
            currency: 'EUR',
            subtotalMinor: 1000,
            deliveryFeeMinor: 0,
            totalMinor: 1000,
            status: 'submitted',
            paymentStatus: 'unpaid',
            version: 1,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
        await OrderContext.db.insertRow(
          s,
          OrderContext(
            restaurantId: restaurant.id!,
            orderId: order.id!,
            detailsJson: '{}',
            paymentTiming: 'atEnd',
            cancellationRequested: false,
            stockReleased: false,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        final charge = await BillCharge.db.insertRow(
          s,
          BillCharge(
            restaurantId: restaurant.id!,
            orderId: order.id!,
            lineKey: 'unit:1',
            kind: 'food',
            amountMinor: 1000,
            creditedMinor: 0,
            settledMinor: 0,
            reservedMinor: 0,
            foodNetMinor: 1000,
            version: 1,
          ),
        );
        final first = AllocatePayment(
          requestKey: key(),
          restaurantId: restaurant.id!,
          orderId: order.id,
          amountMinor: 400,
          method: 'cash',
        );
        final result = await MoneyModule.allocate(s, first);
        expect(await MoneyModule.allocate(s, first), result);
        expect(
          (await BillCharge.db.findById(s, charge.id!))!.settledMinor,
          400,
        );
        expect(await PaymentCapture.db.count(s), 1);
        await expectLater(
          MoneyModule.allocate(
            s,
            AllocatePayment(
              requestKey: key(),
              restaurantId: restaurant.id!,
              orderId: order.id,
              amountMinor: 601,
              method: 'cash',
            ),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'invalid_amount'),
          ),
        );
        await MoneyModule.allocate(
          s,
          AllocatePayment(
            requestKey: key(),
            restaurantId: restaurant.id!,
            orderId: order.id,
            method: 'cash',
          ),
        );
        expect(
          (await BillCharge.db.findById(s, charge.id!))!.settledMinor,
          1000,
        );
        expect(
          (await PurchaseOrder.db.findById(s, order.id!))!.paymentStatus,
          'paid',
        );
        expect(await CommissionEntry.db.count(s), 0);
        await expectLater(
          MoneyModule.allocate(
            s,
            AllocatePayment(
              requestKey: key(),
              restaurantId: restaurant.id!,
              orderId: order.id,
              amountMinor: 1,
              method: 'cash',
            ),
          ),
          throwsA(isA<DomainError>()),
        );
      },
    );
  });
}
