// Docker Postgres on this machine is slow; each test makes many round trips.
@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Webhooks go to a local fake; no
// request leaves the machine.
void main() {
  withServerpod('The Delivery Partner API: keys, signatures and webhooks', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, courier;
    late Restaurant restaurant;
    late int bowl;
    late List<http.Request> hooks;
    var hookStatus = 200;
    const ownerAuth = 'partner-owner-session';
    const pepper = 'fixture-pepper-0123456789abcdef0123456789';
    var serial = 0;
    String key() => 'partner_fixture_${(++serial).toString().padLeft(8, '0')}';
    TestSessionBuilder session(String user, {String? authId}) =>
        builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            user,
            {},
            authId: authId,
          ),
        );
    PlatformCommand command(Json data, {int? id, int? version, String? request}) =>
        PlatformCommand(
          requestKey: request ?? key(),
          restaurantId: restaurant.id,
          resourceId: id,
          expectedVersion: version,
          dataJson: jsonEncode(data),
        );
    Matcher refused(String code) => throwsA(
      isA<DomainError>().having((e) => e.code, 'code', code),
    );
    Future<void> stepUp() => SecurityGrant.db.insertRow(
      builder.build(),
      SecurityGrant(
        userId: 'partner-owner',
        kind: 'recent_auth',
        proofHash: sha256
            .convert(utf8.encode('stepup:partner-owner:$ownerAuth:recent_auth'))
            .toString(),
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().toUtc(),
      ),
    );

    /// One request to the partner API, signed with [secret] unless told not to.
    Future<(int, Json)> call(
      String method,
      String path, {
      Json? body,
      String? appKey,
      String? secret,
      String? idem,
      int? at,
    }) {
      final raw = body == null ? '' : jsonEncode(body);
      final t = at ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return PartnerModule.inbound(
        builder.build(),
        method: method,
        path: path,
        headers: {
          if (appKey != null) 'authorization': 'Bearer $appKey',
          if (secret != null)
            'x-raysto-signature': 't=$t,v1=${PartnerModule.sign(secret, t, raw)}',
          'idempotency-key': ?idem,
        },
        body: raw,
      );
    }

    Future<Json> createApp({String? webhookUrl = 'https://partner.example.test/hooks'}) async {
      await stepUp();
      return PartnerModule.save(
        owner.build(),
        command({
          'name': 'Demo Delivery Co.',
          'webhookUrl': ?webhookUrl,
          'simulator': true,
        }),
      );
    }

    Json orderBody(String ref, {String by = 'restaurant', double lat = 40.7500, double lng = -74.0000}) => {
      'ref': ref,
      'fulfilledBy': by,
      'lines': [
        {'productId': bowl, 'quantity': 2},
      ],
      'address': {
        'line': '1 Fixture Avenue',
        'city': 'New York',
        'country': 'US',
        'latitude': lat,
        'longitude': lng,
      },
      'customer': {'name': 'Pat'},
    };

    Future<PurchaseOrder> order(int id) async =>
        (await PurchaseOrder.db.findById(builder.build(), id))!;
    Future<DeliveryAssignment> job(int orderId) async =>
        (await DeliveryAssignment.db.findFirstRow(
          builder.build(),
          where: (t) => t.orderId.equals(orderId),
        ))!;
    Future<void> step(int orderId, String status) async {
      await OrderingModule.transition(
        owner.build(),
        command({'status': status}, id: orderId, version: (await order(orderId)).version),
      );
    }

    Future<void> ready(int orderId) async {
      if ((await order(orderId)).status == 'submitted') await step(orderId, 'accepted');
      await step(orderId, 'preparing');
      for (final t in await KitchenProgress.db.find(
        builder.build(),
        where: (t) => t.orderId.equals(orderId),
      )) {
        await OrderingModule.kitchen(
          owner.build(),
          command(
            {'lineKey': t.lineKey, 'completedQuantity': t.quantity},
            id: orderId,
            version: t.version,
          ),
        );
      }
      await step(orderId, 'ready');
    }

    Future<List<PartnerEvent>> outbound(String type) => PartnerEvent.db.find(
      builder.build(),
      where: (t) => t.direction.equals('out') & t.type.equals(type),
      orderBy: (t) => t.id,
    );

    /// Reads a module query as the owner, inside one transaction.
    Future<Json> read(String name, [Json d = const {}]) async {
      final s = builder.build();
      final actor = (await ActorProfile.db.findFirstRow(
        s,
        where: (t) => t.userId.equals('partner-owner'),
      ))!;
      return s.db.transaction((tx) async {
        final p = await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
          transaction: tx,
        );
        final w = Work(s, tx, actor, command({}), restaurant, p);
        return (await PartnerModule.query(w, name, d, 30, 0, (rows) => {'rows': rows}))!;
      });
    }

    setUp(() async {
      owner = session('partner-owner', authId: ownerAuth);
      courier = session('partner-courier');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final (user, name) in [
        ('partner-owner', 'Owner'),
        ('partner-courier', 'Rui Courier'),
      ]) {
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
          dataJson: '{"name":"Partner fixture","currency":"USD"}',
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
        'modes': ['pickup', 'delivery'],
        'deliveryZones': [
          {'latitude': 40.7424, 'longitude': -74.0060, 'radiusKm': 3},
        ],
        'deliveryFeeMinor': 299,
        'deliveryMinimumMinor': 0,
        'deliveryProof': 'code',
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
          userId: 'partner-courier',
          role: 'courier',
          active: true,
        ),
      );
      bowl = (await CatalogueModule.saveItem(
        owner.build(),
        command({
          'name': 'Bowl',
          'category': 'Mains',
          'priceMinor': 1000,
        }, version: 1),
      ))['id'] as int;
      hooks = [];
      hookStatus = 200;
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_PARTNER_PEPPER': pepper,
      };
      ProviderClients.httpClient = () => MockClient((request) async {
        hooks.add(request);
        return http.Response('{}', hookStatus);
      });
      PartnerModule.publicHost = (host) async => host.endsWith('.example.test');
    });
    tearDown(() {
      ProviderClients.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
      PartnerModule.publicHost = (host) async => false;
    });

    test('a key is shown once, and only its hash is kept', () async {
      await expectLater(
        PartnerModule.save(owner.build(), command({'name': 'No step-up'})),
        refused('reauthentication_required'),
      );
      await stepUp();
      for (final url in [
        'http://partner.example.test/hooks',
        'https://127.0.0.1/hooks',
        'https://localhost/hooks',
        'https://partner.example.test:8443/hooks',
      ]) {
        await expectLater(
          PartnerModule.save(owner.build(), command({'name': 'Bad', 'webhookUrl': url})),
          refused('invalid_input'),
        );
      }
      final request = key();
      final created = await PartnerModule.save(
        owner.build(),
        command({
          'name': 'Demo Delivery Co.',
          'webhookUrl': 'https://partner.example.test/hooks',
          'simulator': true,
        }, request: request),
      );
      final apiKey = created['key'] as String;
      expect(apiKey, matches(RegExp(r'^rk_[a-z0-9]{8}_[A-Za-z0-9_-]{20,}$')));
      expect(created['webhookSecret'], startsWith('whsec_'));
      expect(created['shown'], true);
      final s = builder.build();
      final app = (await PartnerApp.db.findById(s, created['id'] as int))!;
      expect(app.keyHash, sha256.convert(utf8.encode(apiKey)).toString());
      expect(apiKey, startsWith('rk_${app.keyPrefix}_'));
      final receipts = await MutationReceipt.db.find(s);
      expect(receipts.any((r) => r.resultJson.contains(apiKey)), isFalse);
      expect(
        receipts.any((r) => r.resultJson.contains(created['webhookSecret'] as String)),
        isFalse,
      );
      // A retry of the same request does not show the key again.
      final retry = await PartnerModule.save(
        owner.build(),
        command({
          'name': 'Demo Delivery Co.',
          'webhookUrl': 'https://partner.example.test/hooks',
          'simulator': true,
        }, request: request),
      );
      expect(retry['shown'], false);
      expect(retry.containsKey('key'), isFalse);
      expect(retry['id'], created['id']);
    });

    test('requests need the key, a fresh signature and an idempotency key', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      expect((await call('GET', 'menu')).$1, 401);
      expect(
        (await call('GET', 'menu', appKey: 'rk_aaaaaaaa_${'x' * 43}', secret: secret)).$1,
        401,
      );
      final unsigned = await call('GET', 'menu', appKey: apiKey);
      expect(unsigned.$1, 401);
      expect(unsigned.$2['error']['code'], 'signature_required');
      final stale = await call(
        'GET',
        'menu',
        appKey: apiKey,
        secret: secret,
        at: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 600,
      );
      expect(stale.$2['error']['code'], 'stale_signature');
      final forged = await call('GET', 'menu', appKey: apiKey, secret: 'whsec_wrong');
      expect(forged.$2['error']['code'], 'bad_signature');
      final menu = await call('GET', 'menu', appKey: apiKey, secret: secret);
      expect(menu.$1, 200);
      expect((menu.$2['items'] as List).cast<Map>().single['name'], 'Bowl');
      expect(menu.$2['fulfilledBy'], ['restaurant', 'partner']);
      final noKey = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        body: orderBody('A-1'),
      );
      expect(noKey.$1, 400);
      expect(noKey.$2['error']['code'], 'idempotency_key_required');
      expect((await call('GET', 'nowhere', appKey: apiKey, secret: secret)).$1, 404);
      final events = await PartnerEvent.db.find(
        builder.build(),
        where: (t) => t.direction.equals('in'),
        orderBy: (t) => t.id,
      );
      expect(events.map((e) => e.status), containsAll(['rejected', 'ok']));
      expect(events.where((e) => e.type == 'menu.read' && e.status == 'ok'), hasLength(1));
    });

    test('an order is priced by the café, settled outside PayPal, and replayed', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      final created = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-order-0001',
        body: orderBody('A-100'),
      );
      expect(created.$1, 201, reason: '${created.$2}');
      final body = created.$2;
      expect(body['status'], 'received');
      expect(body['settlement'], 'externalPartner');
      expect(body['deliveryFeeMinor'], 299);
      expect(body['dropoffCode'], matches(RegExp(r'^\d{4}$')));
      final o = await order(body['orderId'] as int);
      expect(o.customerId, 'walk-in:partner:${app['id']}');
      expect(o.paymentStatus, 'externalPartner');
      expect(o.status, 'submitted');
      final s = builder.build();
      final ctx = (await OrderContext.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(o.id!),
      ))!;
      expect(ctx.origin, 'partner');
      expect(ctx.paymentTiming, 'after');
      expect(ctx.customerLabel, 'Pat · Demo Delivery Co.');
      expect((await job(o.id!)).partnerRef, 'A-100');
      final replay = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-order-0001',
        body: orderBody('A-100'),
      );
      expect(replay.$1, 201);
      expect(replay.$2['orderId'], body['orderId']);
      expect(replay.$2['replayed'], true);
      expect(await PurchaseOrder.db.count(s), 1);
      final conflict = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-order-0001',
        body: orderBody('A-101'),
      );
      expect(conflict.$1, 409);
      expect(conflict.$2['error']['code'], 'idempotency_conflict');
      final duplicate = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-order-0002',
        body: orderBody('A-100'),
      );
      expect(duplicate.$2['error']['code'], 'duplicate_ref');
      final far = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-order-0003',
        body: orderBody('A-102', lat: 40.80, lng: -73.90),
      );
      expect(far.$1, 422);
      expect(far.$2['error']['code'], 'outside_delivery_area');
      final read = await call('GET', 'orders/A-100', appKey: apiKey, secret: secret);
      expect(read.$2['status'], 'received');
    });

    test('the café\'s own delivery minimum never applies to a partner\'s order', () async {
      final s = builder.build();
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      final before = policy.settingsJson;
      policy.settingsJson = jsonEncode({...jsonDecode(before) as Json, 'deliveryMinimumMinor': 100000});
      await RestaurantPolicy.db.updateRow(s, policy);
      try {
        final app = await createApp();
        final created = await call(
          'POST',
          'orders',
          appKey: app['key'] as String,
          secret: app['webhookSecret'] as String,
          idem: 'idem-minimum-0001',
          body: orderBody('MIN-1'),
        );
        expect(created.$1, 201, reason: '${created.$2}');
        // The café's drivers deliver it, so the café's fee still applies.
        expect(created.$2['deliveryFeeMinor'], 299);
      } finally {
        final fresh = (await RestaurantPolicy.db.findById(s, policy.id!))!;
        fresh.settingsJson = before;
        await RestaurantPolicy.db.updateRow(s, fresh);
      }
    });

    test('the café\'s progress reaches the partner signed, with backoff', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      final created = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-hooks-0001',
        body: orderBody('H-1'),
      );
      final orderId = created.$2['orderId'] as int;
      await step(orderId, 'accepted');
      final accepted = (await outbound('order.accepted')).single;
      expect(accepted.status, 'pending');
      final s = builder.build();
      expect(
        await PlatformJob.db.count(
          s,
          where: (t) => t.dedupeKey.equals('partner-webhook:${accepted.id}:0'),
        ),
        1,
      );
      await PartnerModule.deliver(s, accepted.id!, 0);
      final sent = hooks.single;
      expect(sent.url.toString(), 'https://partner.example.test/hooks');
      expect(sent.headers['x-raysto-event'], 'order.accepted');
      final signature = RegExp(
        r'^t=(\d+),v1=([0-9a-f]{64})$',
      ).firstMatch(sent.headers['x-raysto-signature']!)!;
      expect(
        PartnerModule.sign(secret, int.parse(signature.group(1)!), sent.body),
        signature.group(2),
      );
      final payload = jsonDecode(sent.body) as Map;
      expect(payload['id'], 'evt_${accepted.id}');
      expect(payload['data']['ref'], 'H-1');
      expect((await PartnerEvent.db.findById(s, accepted.id!))!.status, 'delivered');

      hookStatus = 500;
      await ready(orderId);
      final readyEvent = (await outbound('order.ready')).single;
      await PartnerModule.deliver(s, readyEvent.id!, 0);
      var row = (await PartnerEvent.db.findById(s, readyEvent.id!))!;
      expect(row.status, 'retrying');
      expect(row.attempts, 1);
      expect(row.responseCode, 500);
      expect(
        row.nextAttemptAt!.difference(DateTime.now().toUtc()).inSeconds,
        inInclusiveRange(55, 60),
      );
      final retry = (await PlatformJob.db.findFirstRow(
        s,
        where: (t) => t.dedupeKey.equals('partner-webhook:${readyEvent.id}:1'),
      ))!;
      expect(retry.kind, 'partner.webhook');
      // A stale attempt does nothing.
      await PartnerModule.deliver(s, readyEvent.id!, 0);
      expect((await PartnerEvent.db.findById(s, readyEvent.id!))!.attempts, 1);
      for (var attempt = 1; attempt <= 5; attempt++) {
        await PartnerModule.deliver(s, readyEvent.id!, attempt);
      }
      row = (await PartnerEvent.db.findById(s, readyEvent.id!))!;
      expect(row.status, 'failed');
      expect(row.attempts, 6);
      expect(hooks, hasLength(7));
    });

    test('the café\'s own driver: pickup, position and handover reach the partner', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      final created = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-own-00001',
        body: orderBody('R-1'),
      );
      final orderId = created.$2['orderId'] as int;
      final code = created.$2['dropoffCode'] as String;
      var a = await job(orderId);
      await OrderingModule.assignCourier(
        owner.build(),
        command({'courierId': 'partner-courier'}, id: a.id, version: a.version),
      );
      await ready(orderId);
      Future<void> move(String status) async {
        final current = await job(orderId);
        await OrderingModule.delivery(
          courier.build(),
          command({'status': status}, id: current.id, version: current.version),
        );
      }

      await move('collected');
      final pickedUp = (await outbound('order.picked_up')).single;
      expect(jsonDecode(pickedUp.payloadJson)['driver']['name'], 'Rui');
      await move('outForDelivery');
      a = await job(orderId);
      for (var i = 0; i < 2; i++) {
        await OrderingModule.location(
          courier.build(),
          command({'consent': true, 'latitude': 40.746, 'longitude': -74.003}, id: a.id),
        );
      }
      // Positions reach the partner at most every 30 seconds.
      expect(await outbound('driver.location'), hasLength(1));
      await DeliveryModule.proof(
        courier.build(),
        command({'code': code}, id: a.id, version: a.version),
      );
      expect(await outbound('order.delivered'), hasLength(1));
      final read = await call('GET', 'orders/R-1', appKey: apiKey, secret: secret);
      expect(read.$2['status'], 'delivered');
      expect(read.$2.containsKey('dropoffCode'), isFalse);
      final now = DateTime.now().toUtc();
      final due = await PartnerModule.settlementDue(
        builder.build(),
        restaurant.id!,
        app['id'] as int,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(minutes: 1)),
      );
      expect(due['orders'], 1);
      expect(due['totalMinor'], (await order(orderId)).totalMinor);
    });

    test('the partner\'s own courier: pickup code, ready first, then delivered', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      final created = await call(
        'POST',
        'orders',
        appKey: apiKey,
        secret: secret,
        idem: 'idem-theirs-0001',
        // Outside the café's own zone: the partner's courier goes anywhere.
        body: orderBody('P-1', by: 'partner', lat: 40.80, lng: -73.90),
      );
      expect(created.$1, 201, reason: '${created.$2}');
      expect(created.$2['deliveryFeeMinor'], 0);
      expect(created.$2['pickupCode'], matches(RegExp(r'^\d{4}$')));
      final orderId = created.$2['orderId'] as int;
      Future<(int, Json)> status(String idem, Json body) => call(
        'POST',
        'orders/P-1/status',
        appKey: apiKey,
        secret: secret,
        idem: idem,
        body: body,
      );
      final early = await status('idem-theirs-0002', {'status': 'picked_up'});
      expect(early.$1, 409);
      expect(early.$2['error']['code'], 'not_ready');
      await ready(orderId);
      expect((await outbound('order.ready')).single.payloadJson, contains('pickup'));
      final picked = await status('idem-theirs-0003', {
        'status': 'picked_up',
        'courier': {'name': 'Lou', 'vehicle': 'car'},
      });
      expect(picked.$1, 200, reason: '${picked.$2}');
      expect(picked.$2['status'], 'picked_up');
      final driver = (await Driver.db.findById(
        builder.build(),
        (await job(orderId)).driverId!,
      ))!;
      expect(driver.kind, 'partner');
      expect(driver.name, 'Lou');
      final delivered = await status('idem-theirs-0004', {'status': 'delivered'});
      expect(delivered.$2['status'], 'delivered');
      expect((await job(orderId)).proofKind, 'partner');
      // What the partner reported is not echoed back to it.
      expect(await outbound('order.picked_up'), isEmpty);
      expect(await outbound('order.delivered'), isEmpty);
      // The café cannot move a job the partner delivers.
      final a = await job(orderId);
      await expectLater(
        OrderingModule.delivery(
          owner.build(),
          command({'status': 'issue', 'reason': 'x'}, id: a.id, version: a.version),
        ),
        refused('invalid_transition'),
      );
    });

    test('a partner cancels until the kitchen finishes; then it is too late', () async {
      final app = await createApp();
      final apiKey = app['key'] as String;
      final secret = app['webhookSecret'] as String;
      Future<(int, Json)> post(String path, String idem, Json body) =>
          call('POST', path, appKey: apiKey, secret: secret, idem: idem, body: body);
      final first = await post('orders', 'idem-cancel-0001', orderBody('C-1'));
      final cancelled = await post('orders/C-1/cancel', 'idem-cancel-0002', {
        'reason': 'Customer changed their mind',
      });
      expect(cancelled.$1, 200);
      expect(cancelled.$2['status'], 'cancelled');
      expect((await order(first.$2['orderId'] as int)).status, 'cancelled');
      expect(await outbound('order.cancelled'), isEmpty);
      final second = await post('orders', 'idem-cancel-0003', orderBody('C-2'));
      await ready(second.$2['orderId'] as int);
      final late = await post('orders/C-2/cancel', 'idem-cancel-0004', {});
      expect(late.$1, 409);
      expect(late.$2['error']['code'], 'too_late');
      // The café rejecting an order does tell the partner.
      final third = await post('orders', 'idem-cancel-0005', orderBody('C-3'));
      final o = await order(third.$2['orderId'] as int);
      await OrderingModule.transition(
        owner.build(),
        command({'status': 'rejected', 'reason': 'Out of bowls'}, id: o.id, version: o.version),
      );
      expect(await outbound('order.cancelled'), hasLength(1));
    });

    test('rotation stops the old key, a switched-off app is refused, 60 a minute', () async {
      final app = await createApp(webhookUrl: null);
      final oldKey = app['key'] as String;
      var secret = app['webhookSecret'] as String;
      final id = app['id'] as int;
      // createApp's identity check is still fresh for the rotations.
      final rotated = await PartnerModule.rotate(
        owner.build(),
        command({'what': 'key'}, id: id, version: app['version'] as int),
      );
      final newKey = rotated['key'] as String;
      expect((await call('GET', 'menu', appKey: oldKey, secret: secret)).$1, 401);
      expect((await call('GET', 'menu', appKey: newKey, secret: secret)).$1, 200);
      final resecret = await PartnerModule.rotate(
        owner.build(),
        command({'what': 'secret'}, id: id, version: rotated['version'] as int),
      );
      expect(resecret['webhookSecret'], isNot(secret));
      expect((await call('GET', 'menu', appKey: newKey, secret: secret)).$1, 401);
      secret = resecret['webhookSecret'] as String;
      expect((await call('GET', 'menu', appKey: newKey, secret: secret)).$1, 200);
      // The 61st request in a minute is refused: fill this minute's window
      // (and the next, in case the clock turns) to the limit.
      final minute = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 60000;
      for (final m in [minute, minute + 1]) {
        final start = DateTime.fromMillisecondsSinceEpoch(m * 60000, isUtc: true);
        final s = builder.build();
        final window = await RateWindow.db.findFirstRow(
          s,
          where: (t) => t.bucket.equals('partner:$id') & t.windowStart.equals(start),
        );
        if (window == null) {
          await RateWindow.db.insertRow(
            s,
            RateWindow(bucket: 'partner:$id', windowStart: start, requests: 60),
          );
        } else {
          window.requests = 60;
          await RateWindow.db.updateRow(s, window);
        }
      }
      final limited = await call('GET', 'menu', appKey: newKey, secret: secret);
      expect(limited.$1, 429);
      expect(limited.$2['error']['code'], 'rate_limited');
      final disabled = await PartnerModule.disable(
        owner.build(),
        command({}, id: id, version: resecret['version'] as int),
      );
      expect(disabled['active'], false);
      final refusedCall = await call('GET', 'menu', appKey: newKey, secret: secret);
      expect(refusedCall.$1, 403);
      final listed = await read('partner.apps');
      final row = (listed['rows'] as List).cast<Json>().single;
      expect(row['active'], false);
      expect(row['keyHint'], startsWith('rk_'));
      expect(jsonEncode(listed), isNot(contains(newKey)));
      final log = await read('partner.events');
      expect((log['rows'] as List).cast<Json>().first['direction'], 'in');
    });
  });
}
