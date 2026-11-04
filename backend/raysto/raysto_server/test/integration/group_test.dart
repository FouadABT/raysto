import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Franchise groups: group roles read,
// venue memberships act; nothing in one group reaches another.
void main() {
  withServerpod('Franchise groups', (builder, endpoints) {
    const ownerAuth = 'group-owner-session';
    late TestSessionBuilder owner, rival, area, accountant, outsider;
    late Restaurant downtown, harbour, elsewhere;
    var serial = 0;
    String key() => 'group_${(++serial).toString().padLeft(10, '0')}';
    TestSessionBuilder session(String user, {String? authId}) =>
        builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user,
            {},
            authId: authId,
          ),
        );
    PlatformCommand command(Json data, {int? restaurantId, int? id, int? version}) =>
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurantId,
          resourceId: id,
          expectedVersion: version,
          dataJson: jsonEncode(data),
        );
    Matcher refused(String code) =>
        throwsA(isA<DomainError>().having((e) => e.code, 'code', code));

    Future<Restaurant> venue(TestSessionBuilder who, String name, String currency) async {
      final created = await IdentityModule.createRestaurant(
        who.build(),
        command({'name': name, 'currency': currency}),
      );
      return (await Restaurant.db.findById(builder.build(), created['id'] as int))!;
    }

    Future<void> stepUp() => SecurityGrant.db.insertRow(
      builder.build(),
      SecurityGrant(
        userId: 'group-owner',
        kind: 'recent_auth',
        proofHash: sha256
            .convert(utf8.encode('stepup:group-owner:$ownerAuth:recent_auth'))
            .toString(),
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().toUtc(),
      ),
    );

    /// Runs `GroupModule.grant` the way accepting an invitation does.
    Future<void> grant(int groupId, String user, String role) async {
      final s = owner.build();
      final actor = (await ActorProfile.db.findFirstRow(
        s,
        where: (t) => t.userId.equals('group-owner'),
      ))!;
      await s.db.transaction((tx) async {
        await GroupModule.grant(
          Work(s, tx, actor, command({}), null, null),
          groupId,
          user,
          role,
        );
      });
    }

    Future<int> group() async =>
        (await GroupModule.create(
          owner.build(),
          command({'name': 'Atelier Group', 'currency': 'USD'}),
        ))['groupId'] as int;

    Future<void> attach(int groupId, Restaurant r, [TestSessionBuilder? who]) =>
        GroupModule.attach(
          (who ?? owner).build(),
          command({'groupId': groupId}, restaurantId: r.id),
        );

    Future<Json> read(TestSessionBuilder who, String name, Json d) =>
        GroupModule.read(who.build(), name: name, d: d);

    setUp(() async {
      owner = session('group-owner', authId: ownerAuth);
      rival = session('group-rival');
      area = session('group-area');
      accountant = session('group-accountant');
      outsider = session('group-outsider');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final user in [
        'group-owner',
        'group-rival',
        'group-area',
        'group-accountant',
        'group-outsider',
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
      downtown = await venue(owner, 'Atelier Downtown', 'USD');
      harbour = await venue(owner, 'Atelier Harbour', 'EUR');
      elsewhere = await venue(rival, 'Rival Café', 'USD');
    });

    test('a group holds its owner\'s venues and refuses anyone else\'s', () async {
      final gid = await group();
      await attach(gid, downtown);
      await attach(gid, harbour);
      // Not the owner of that venue.
      await expectLater(attach(gid, elsewhere), refused('forbidden'));
      // The rival owns the venue but not the group.
      await expectLater(attach(gid, elsewhere, rival), refused('forbidden'));
      // A venue already in a group cannot join a second one.
      final second = (await GroupModule.create(
        owner.build(),
        command({'name': 'Second', 'currency': 'USD'}),
      ))['groupId'] as int;
      await expectLater(attach(second, downtown), refused('forbidden'));
      final list = await read(owner, 'group.list', {});
      final mine = (list['rows'] as List).cast<Map>().firstWhere((g) => g['id'] == gid);
      expect([for (final v in (mine['venues'] as List).cast<Map>()) v['name']],
          ['Atelier Downtown', 'Atelier Harbour']);
    });

    test('an area manager reads the group but acts in no venue', () async {
      final gid = await group();
      await attach(gid, downtown);
      await grant(gid, 'group-area', 'areaManager');
      final overview = await read(area, 'group.overview', {'groupId': gid});
      expect((overview['venues'] as List).length, 1);
      // No venue membership: venue reads and commands are refused.
      await expectLater(
        BackOfficeModule.read(area.build(), restaurantId: downtown.id!, name: 'expenses'),
        refused('forbidden'),
      );
      await expectLater(
        CatalogueModule.saveItem(
          area.build(),
          command(
            {'name': 'Tart', 'category': 'Sweets', 'priceMinor': 450},
            restaurantId: downtown.id,
            version: 1,
          ),
        ),
        refused('forbidden'),
      );
      // Group commands belong to the owner.
      await expectLater(
        GroupModule.saveTemplate(
          area.build(),
          command({
            'groupId': gid,
            'name': 'Autumn',
            'items': [
              {'name': 'Soup', 'category': 'Plates', 'priceMinor': 650},
            ],
          }),
        ),
        refused('forbidden'),
      );
      // Someone outside the group reads nothing.
      await expectLater(read(outsider, 'group.overview', {'groupId': gid}), refused('forbidden'));
      await expectLater(read(outsider, 'group.payables', {'groupId': gid}), refused('forbidden'));
    });

    test('a group accountant gets a revocable accountant membership in each venue', () async {
      final gid = await group();
      await attach(gid, downtown);
      await grant(gid, 'group-accountant', 'accountant');
      await attach(gid, harbour);
      final s = builder.build();
      Future<List<Membership>> memberships() => Membership.db.find(
        s,
        where: (t) => t.userId.equals('group-accountant'),
        orderBy: (t) => t.restaurantId,
      );
      final granted = await memberships();
      expect([for (final m in granted) (m.restaurantId, m.role, m.active)], [
        (downtown.id, 'accountant', true),
        (harbour.id, 'accountant', true),
      ]);
      // Detaching a venue takes its accountant membership back.
      await GroupModule.detach(
        owner.build(),
        command({'groupId': gid}, restaurantId: harbour.id),
      );
      expect((await memberships()).firstWhere((m) => m.restaurantId == harbour.id).active, isFalse);
      final overview = await read(accountant, 'group.overview', {'groupId': gid});
      expect([for (final v in (overview['venues'] as List).cast<Map>()) v['restaurantId']], [downtown.id]);
      // Revoking ends the rest.
      await GroupModule.revoke(
        owner.build(),
        command({'groupId': gid, 'userId': 'group-accountant'}),
      );
      expect((await memberships()).every((m) => !m.active), isTrue);
      await expectLater(read(accountant, 'group.ledger', {'groupId': gid}), refused('forbidden'));
    });

    test('inviting into a group needs the owner\'s identity check', () async {
      final gid = await group();
      await attach(gid, downtown);
      PlatformCommand invite() => command({
        'groupId': gid,
        'email': 'books@example.test',
        'role': 'accountant',
      });
      await expectLater(
        GroupModule.invite(owner.build(), invite()),
        refused('reauthentication_required'),
      );
      await stepUp();
      final sent = await GroupModule.invite(owner.build(), invite());
      expect(sent['invitationCode'], isA<String>());
      expect(sent['role'], 'accountant');
    });

    test('a template becomes a draft in every venue, published only by that venue', () async {
      final gid = await group();
      await attach(gid, downtown);
      await attach(gid, harbour);
      final saved = await GroupModule.saveTemplate(
        owner.build(),
        command({
          'groupId': gid,
          'name': 'Autumn',
          'items': [
            {'productId': 99, 'name': 'Pumpkin soup', 'category': 'Plates', 'priceMinor': 650},
          ],
        }),
      );
      final pushed = await GroupModule.pushTemplate(
        owner.build(),
        command({'groupId': gid, 'templateId': saved['templateId']}),
      );
      expect((pushed['drafts'] as List).length, 2);
      final drafts = await MenuDraft.db.find(
        builder.build(),
        where: (t) => t.restaurantId.inSet({downtown.id!, harbour.id!}),
      );
      expect(drafts.map((d) => d.status).toSet(), {'draft'});
      final items = (jsonDecode(drafts.first.itemsJson) as List).cast<Map>();
      expect(items.single['name'], 'Pumpkin soup');
      expect(items.single.containsKey('productId'), isFalse);
      // Nothing is on either menu until a venue publishes.
      expect(
        await MenuProduct.db.count(
          builder.build(),
          where: (t) => t.restaurantId.inSet({downtown.id!, harbour.id!}),
        ),
        0,
      );
    });

    test('totals are kept per currency, never added across them', () async {
      final gid = await group();
      await attach(gid, downtown);
      await attach(gid, harbour);
      final s = builder.build();
      for (final r in [downtown, harbour]) {
        await Bill.db.insertRow(
          s,
          Bill(
            restaurantId: r.id!,
            vendor: 'City Power',
            category: 'electricity',
            amountMinor: r == downtown ? 12000 : 9000,
            vatMinor: 0,
            currency: r.currency,
            dueAt: DateTime.now().toUtc().add(const Duration(days: 2)),
            state: 'approved',
            payVia: 'paypal',
            readJson: '{}',
            version: 1,
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
      final overview = await read(owner, 'group.overview', {'groupId': gid, 'range': '30d'});
      final totals = (overview['totals'] as List).cast<Map>();
      expect({for (final t in totals) t['currency']: t['billsDueMinor']}, {'USD': 12000, 'EUR': 9000});
      final payables = await read(owner, 'group.payables', {'groupId': gid});
      expect((payables['rows'] as List).length, 2);
      expect((payables['totals'] as List).length, 2);
      final compare = await read(owner, 'group.compare', {'groupId': gid, 'range': '7d'});
      expect((compare['rows'] as List).length, 14);
    });

    test('stock moves between two venues of the same group, once each way', () async {
      final gid = await group();
      await attach(gid, downtown);
      await attach(gid, harbour);
      final s = builder.build();
      final flour = await StockItem.db.insertRow(
        s,
        StockItem(
          restaurantId: downtown.id!,
          name: 'Flour T55',
          unit: 'kg',
          quantity: 25,
          costMinor: 120,
          lowAt: 5,
          version: 1,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      final moved = await GroupModule.transfer(
        owner.build(),
        command(
          {'toRestaurantId': harbour.id, 'stockItemId': flour.id, 'quantity': 10},
          restaurantId: downtown.id,
        ),
      );
      expect((moved['from'] as Map)['quantity'], 15);
      expect((moved['to'] as Map)['quantity'], 10);
      final movements = await StockMovement.db.find(
        s,
        where: (t) => t.refId.equals(moved['transferId'] as String),
      );
      expect(movements.map((m) => m.quantity).toSet(), {-10.0, 10.0});
      // A venue outside the group is refused, even for its owner.
      await expectLater(
        GroupModule.transfer(
          owner.build(),
          command(
            {'toRestaurantId': elsewhere.id, 'stockItemId': flour.id, 'quantity': 1},
            restaurantId: downtown.id,
          ),
        ),
        refused('forbidden'),
      );
    });

    test('only owners save a Studio layout; readers load their own', () async {
      final gid = await group();
      await attach(gid, downtown);
      await grant(gid, 'group-area', 'areaManager');
      final saved = await StudioLayoutModule.save(
        owner.build(),
        command({
          'scope': 'group:$gid',
          'section': 'group',
          'state': {'selectedPageId': 'portfolio'},
        }),
      );
      expect(saved['version'], 1);
      await expectLater(
        StudioLayoutModule.save(
          area.build(),
          command({'scope': 'group:$gid', 'section': 'group', 'state': {}}),
        ),
        refused('forbidden'),
      );
      await expectLater(
        StudioLayoutModule.save(
          owner.build(),
          command({'scope': 'venue:${elsewhere.id}', 'section': 'accountant', 'state': {}}),
        ),
        refused('forbidden'),
      );
      final again = await StudioLayoutModule.save(
        owner.build(),
        command({
          'scope': 'venue:${downtown.id}',
          'section': 'accountant',
          'state': {'selectedPageId': 'pnl'},
        }),
      );
      expect(again['scope'], 'venue:${downtown.id}');
    });
  });
}
