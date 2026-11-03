import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. The back-office records: shifts,
// suppliers, stock, expenses, complaints, catering requests, owner limits.
void main() {
  withServerpod('The back office records', (builder, endpoints) {
    late TestSessionBuilder owner, waiter, customer;
    late Restaurant restaurant;
    late int burger;
    var serial = 0;
    String key() => 'backoffice_${(++serial).toString().padLeft(8, '0')}';
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
    Future<Json> read(TestSessionBuilder who, String name, [Json d = const {}]) =>
        BackOfficeModule.read(
          who.build(),
          restaurantId: restaurant.id!,
          name: name,
          d: d,
        );

    setUp(() async {
      owner = session('bo-owner');
      waiter = session('bo-waiter');
      customer = session('bo-customer');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in ['bo-owner', 'bo-waiter', 'bo-customer']) {
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
          dataJson: '{"name":"Back office fixture","currency":"USD"}',
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
            {'day': day, 'start': 0, 'end': 1440},
        ],
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      await Membership.db.insertRow(
        s,
        Membership(
          restaurantId: restaurant.id!,
          userId: 'bo-waiter',
          role: 'waiter',
          active: true,
        ),
      );
      burger = (await CatalogueModule.saveItem(
        owner.build(),
        command({'name': 'Burger', 'category': 'Mains', 'priceMinor': 900}, version: 1),
      ))['id'] as int;
    });

    test('a shift is planned by a manager and clocked by its own member', () async {
      final starts = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
      final saved = await BackOfficeModule.saveShift(
        owner.build(),
        command({
          'userId': 'bo-waiter',
          'name': 'Sam',
          'role': 'floor',
          'startsAt': starts.toIso8601String(),
          'endsAt': starts.add(const Duration(hours: 6)).toIso8601String(),
          'hourlyRateMinor': 1500,
          'payoutEmail': 'sam@example.test',
        }),
      );
      final id = saved['shiftId'] as int;
      await expectLater(
        BackOfficeModule.saveShift(waiter.build(), command({'name': 'x'})),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'forbidden')),
      );
      final clocked = await BackOfficeModule.clock(
        waiter.build(),
        command({'action': 'in'}, id: id),
      );
      expect(clocked['clockInAt'], isNotNull);
      await expectLater(
        BackOfficeModule.clock(customer.build(), command({'action': 'in'}, id: id)),
        throwsA(isA<DomainError>()),
      );
      final shifts = await read(owner, 'shifts');
      final row = (shifts['rows'] as List).single as Map;
      expect(row['name'], 'Sam');
      expect(row['workedMinutes'], greaterThan(300));
      expect(row['payoutEmail'], 'sam@example.test');
    });

    test('suppliers, stock and expenses are recorded and listed', () async {
      final supplier = await BackOfficeModule.saveSupplier(
        owner.build(),
        command({'name': 'Boulangerie Dupont', 'payoutEmail': 'dupont@example.test'}),
      );
      final stock = await BackOfficeModule.saveStock(
        owner.build(),
        command({
          'name': 'Croissants',
          'unit': 'piece',
          'quantity': 12,
          'costMinor': 60,
          'supplierId': supplier['supplierId'],
          'lowAt': 20,
        }),
      );
      expect(stock['version'], 1);
      final listed = await read(owner, 'stock');
      final row = (listed['rows'] as List).single as Map;
      expect(row['low'], isTrue);
      expect(row['supplierId'], supplier['supplierId']);
      await BackOfficeModule.recordExpense(
        owner.build(),
        command({
          'category': 'food',
          'amountMinor': 4800,
          'spentAt': DateTime.now().toUtc().toIso8601String(),
          'merchant': 'Metro',
        }),
      );
      await expectLater(
        BackOfficeModule.recordExpense(
          owner.build(),
          command({
            'category': 'yachts',
            'amountMinor': 1,
            'spentAt': DateTime.now().toUtc().toIso8601String(),
            'merchant': 'x',
          }),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_input')),
      );
      final expenses = await read(owner, 'expenses');
      expect(expenses['totalMinor'], 4800);
      expect((await read(owner, 'suppliers'))['rows'], hasLength(1));
      await expectLater(read(waiter, 'suppliers'), throwsA(isA<DomainError>()));
    });

    test('a diner complains about a paid order; unpaid orders are refused', () async {
      Future<int> sale() async {
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
        return (await OrderingModule.submit(
          customer.build(),
          SubmitOrder(
            requestKey: key(),
            restaurantId: restaurant.id!,
            quoteId: q['id'] as int,
          ),
        ))['orderId'] as int;
      }

      final unpaid = await sale();
      await expectLater(
        BackOfficeModule.openComplaint(
          customer.build(),
          command({'text': 'Cold'}, id: unpaid),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_transition')),
      );
      final paid = await sale();
      await MoneyModule.allocate(
        owner.build(),
        AllocatePayment(
          requestKey: key(),
          restaurantId: restaurant.id!,
          orderId: paid,
          method: 'cash',
        ),
      );
      final opened = await BackOfficeModule.openComplaint(
        customer.build(),
        command({'text': 'The burger was cold.'}, id: paid),
      );
      expect(opened['complaintId'], isNotNull);
      await expectLater(
        BackOfficeModule.openComplaint(
          customer.build(),
          command({'text': 'Again'}, id: paid),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_transition')),
      );
      final listed = await read(owner, 'complaints');
      final row = (listed['rows'] as List).single as Map;
      expect(row['status'], 'open');
      expect(row['orderId'], paid);
      expect(row['captureId'], isNotNull);
    });

    test('a catering request is stored for the agent and read back', () async {
      final r = await BackOfficeModule.requestCatering(
        owner.build(),
        command({
          'customerEmail': 'Events@Example.test',
          'customerName': 'Dana',
          'text': '20 sandwiches and 20 coffees for Friday at noon',
          'eventAt': DateTime.now().toUtc().add(const Duration(days: 3)).toIso8601String(),
        }),
      );
      final one = await read(owner, 'catering.request', {'id': r['cateringId']});
      expect(one['status'], 'requested');
      expect(one['customerEmail'], 'events@example.test');
      expect(one['currency'], 'USD');
      expect((await read(owner, 'catering'))['rows'], hasLength(1));
    });

    test('the owner sets the money agents\' limits; nothing else changes', () async {
      final s = builder.build();
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      final set = await CatalogueModule.autonomy(
        owner.build(),
        command({
          'autonomy': {'refundsMaxMinor': 500, 'refundsPerDay': 3, 'remindersAuto': true},
          'closeAt': 1320,
        }, version: policy.version),
      );
      expect(set['autonomy'], {'refundsMaxMinor': 500, 'refundsPerDay': 3, 'remindersAuto': true});
      final after = _decode(
        (await RestaurantPolicy.db.findById(s, policy.id!))!.settingsJson,
      );
      expect(after['closeAt'], 1320);
      expect(after['timezone'], 'America/New_York');
      expect(after['taxConfigured'], true);
      await expectLater(
        CatalogueModule.autonomy(
          owner.build(),
          command({
            'autonomy': {'refundsMaxMinor': 99999},
          }, version: (set['version'] as int)),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_input')),
      );
      expect((await read(owner, 'backoffice.close'))['state'], 'none');
      expect((await read(owner, 'payouts'))['rows'], isEmpty);
      expect((await read(owner, 'customers'))['rows'], isEmpty);
      expect((await read(owner, 'disputes'))['rows'], isEmpty);
    });
  });
}

Json _decode(String value) => jsonDecode(value) as Json;
