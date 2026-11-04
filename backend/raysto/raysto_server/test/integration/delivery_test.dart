// Docker Postgres on this machine is slow; each test makes many round trips.
@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import '../fixtures/money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Gemini is a scripted local fake; no
// request leaves the machine.
void main() {
  withServerpod('Drivers, offers, proof and the AI dispatcher', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, courierA, courierB, customer;
    late Restaurant restaurant;
    late int bowl;
    const ownerAuth = 'delivery-owner-session';
    const venue = (lat: 40.7424, lng: -74.0060);
    var serial = 0;
    String key() => 'delivery_fixture_${(++serial).toString().padLeft(8, '0')}';
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
    Matcher refused(String code) => throwsA(
      isA<DomainError>().having((e) => e.code, 'code', code),
    );

    Future<void> patchSettings(Json patch) async {
      final s = builder.build();
      final policy = (await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      policy.settingsJson = jsonEncode({
        ...jsonDecode(policy.settingsJson) as Map,
        ...patch,
      });
      await RestaurantPolicy.db.updateRow(s, policy);
    }

    /// Reads a module query as [user] would, inside one transaction.
    Future<Json> read(String user, String name, [Json d = const {}]) async {
      final s = builder.build();
      final actor = (await ActorProfile.db.findFirstRow(
        s,
        where: (t) => t.userId.equals(user),
      ))!;
      return s.db.transaction((tx) async {
        final r = await Restaurant.db.findById(s, restaurant.id!, transaction: tx);
        final p = await RestaurantPolicy.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(restaurant.id!),
          transaction: tx,
        );
        final w = Work(
          s,
          tx,
          actor,
          PlatformCommand(
            requestKey: key(),
            restaurantId: restaurant.id,
            dataJson: '{}',
          ),
          r,
          p,
        );
        if (name == 'delivery.tracking') return DeliveryModule.tracking(w, d);
        Json page(List<Json> rows) => {'rows': rows};
        return (await DeliveryModule.query(w, name, d, 30, 0, page))!;
      });
    }

    Future<PurchaseOrder> order(int id) async =>
        (await PurchaseOrder.db.findById(builder.build(), id))!;
    Future<DeliveryAssignment> job(int orderId) async =>
        (await DeliveryAssignment.db.findFirstRow(
          builder.build(),
          where: (t) => t.orderId.equals(orderId),
        ))!;
    Future<Driver> card(String user) async => (await Driver.db.findFirstRow(
      builder.build(),
      where: (t) => t.userId.equals(user),
    ))!;

    /// A paid delivery order to [lat], [lng] (about 1 km from the café).
    Future<int> placeDelivery({double lat = 40.7500, double lng = -74.0000}) async {
      final q = await OrderingModule.quote(
        customer.build(),
        CreateQuote(
          requestKey: key(),
          restaurantId: restaurant.id!,
          fulfillment: 'delivery',
          linesJson: jsonEncode([
            {'productId': bowl, 'quantity': 2},
          ]),
          addressJson: jsonEncode({
            'line': '1 Fixture Avenue',
            'city': 'New York',
            'country': 'US',
            'latitude': lat,
            'longitude': lng,
            'instructions': 'Ring twice',
          }),
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
      // Paid the way a capture leaves it; the payment path has its own tests.
      final s = builder.build();
      final o = await order(placed['orderId'] as int);
      o
        ..paymentStatus = 'paid'
        ..status = 'submitted';
      await PurchaseOrder.db.updateRow(s, o);
      return o.id!;
    }

    Future<Json> step(int orderId, String status) async =>
        OrderingModule.transition(
          owner.build(),
          command({'status': status}, id: orderId, version: (await order(orderId)).version),
        );

    Future<void> ready(int orderId) async {
      if ((await order(orderId)).status == 'submitted') {
        await step(orderId, 'accepted');
      }
      await step(orderId, 'preparing');
      final s = builder.build();
      for (final t in await KitchenProgress.db.find(
        s,
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

    Future<Json> available(TestSessionBuilder courier) =>
        DeliveryModule.availability(
          courier.build(),
          command({'status': 'available'}),
        );
    Future<Json> offer(int assignmentId, int driverId) => DeliveryModule.offer(
      owner.build(),
      command({'driverId': driverId}, id: assignmentId),
    );
    Future<Json> respond(TestSessionBuilder who, int offerId, String answer) =>
        DeliveryModule.respond(
          who.build(),
          command({'answer': answer}, id: offerId),
        );
    Future<Json> move(TestSessionBuilder who, int orderId, String status) async {
      final a = await job(orderId);
      return OrderingModule.delivery(
        who.build(),
        command({'status': status}, id: a.id, version: a.version),
      );
    }

    Future<void> stepUp() => SecurityGrant.db.insertRow(
      builder.build(),
      SecurityGrant(
        userId: 'delivery-owner',
        kind: 'recent_auth',
        proofHash: sha256
            .convert(utf8.encode('stepup:delivery-owner:$ownerAuth:recent_auth'))
            .toString(),
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
        createdAt: DateTime.now().toUtc(),
      ),
    );

    setUp(() async {
      owner = session('delivery-owner', authId: ownerAuth);
      courierA = session('delivery-courier-a');
      courierB = session('delivery-courier-b');
      customer = session('delivery-customer');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final (user, name) in [
        ('delivery-owner', 'Owner'),
        ('delivery-courier-a', 'Amal Courier'),
        ('delivery-courier-b', 'Bruno Courier'),
        ('delivery-customer', 'Chloe'),
        ('delivery-stranger', 'Stranger'),
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
          dataJson: '{"name":"Delivery fixture","currency":"USD"}',
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
          {'latitude': venue.lat, 'longitude': venue.lng, 'radiusKm': 3},
        ],
        'deliveryFeeMinor': 299,
        'deliveryMinimumMinor': 0,
        'deliveryProof': 'code',
        'driverPayPerDeliveryMinor': 300,
        'hours': [
          for (var day = 1; day <= 7; day++)
            {'day': day, 'start': 0, 'end': 1440},
        ],
      });
      await RestaurantPolicy.db.updateRow(s, policy);
      for (final user in ['delivery-courier-a', 'delivery-courier-b']) {
        await Membership.db.insertRow(
          s,
          Membership(
            restaurantId: restaurant.id!,
            userId: user,
            role: 'courier',
            active: true,
          ),
        );
      }
      bowl = (await CatalogueModule.saveItem(
        owner.build(),
        command({
          'name': 'Bowl',
          'category': 'Mains',
          'priceMinor': 1000,
        }, version: 1),
      ))['id'] as int;
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      AiBudget.environment = () => Platform.environment;
      ProviderClients.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
    });

    test('a distance fee is base plus per km of the road estimate, capped', () async {
      final settings = {
        ...CatalogueModule.defaults,
        'deliveryZones': [
          {'latitude': venue.lat, 'longitude': venue.lng, 'radiusKm': 3},
        ],
        'deliveryFeeMinor': 299,
        'deliveryFeeMode': 'distance',
        'deliveryFeeBaseMinor': 200,
        'deliveryFeePerKmMinor': 100,
        'deliveryFeeMaxMinor': 450,
      };
      final near = {'latitude': 40.7500, 'longitude': -74.0000};
      final meters = DeliveryModule.road(venue, (lat: 40.75, lng: -74.0));
      expect(meters, greaterThan(1000));
      expect(
        DeliveryModule.fee(settings, near),
        200 + (meters / 1000 * 100).round(),
      );
      expect(
        DeliveryModule.fee(settings, {'latitude': 40.70, 'longitude': -73.95}),
        450,
      );
      expect(DeliveryModule.fee(settings, {'line': 'no coordinates'}), 299);
      expect(DeliveryModule.fee({...settings, 'deliveryFeeMode': 'flat'}, near), 299);

      await patchSettings({
        'deliveryFeeMode': 'distance',
        'deliveryFeeBaseMinor': 200,
        'deliveryFeePerKmMinor': 100,
        'deliveryFeeMaxMinor': 450,
      });
      final placed = await order(await placeDelivery());
      expect(placed.deliveryFeeMinor, 200 + (meters / 1000 * 100).round());
    });

    test('a courier goes available, and the first accept wins', () async {
      final a = await available(courierA);
      expect(a['status'], 'available');
      final cardA = await card('delivery-courier-a');
      expect(cardA.name, 'Amal Courier');
      await available(courierB);
      final cardB = await card('delivery-courier-b');
      final orderId = await placeDelivery();
      final assignment = await job(orderId);
      expect(assignment.status, 'unassigned');

      final first = await offer(assignment.id!, cardA.id!);
      final s = builder.build();
      expect(
        await UserNotification.db.count(
          s,
          where: (t) =>
              t.userId.equals('delivery-courier-a') &
              t.kind.equals('delivery.offer'),
        ),
        1,
      );
      final second = await offer(assignment.id!, cardB.id!);
      // A newer offer withdraws the open one.
      expect(
        (await respond(courierA, first['offerId'] as int, 'accept'))['state'],
        'withdrawn',
      );
      // Amal can neither see nor answer Bruno's offer.
      await expectLater(
        respond(courierA, second['offerId'] as int, 'accept'),
        refused('not_found'),
      );
      final accepted = await respond(courierB, second['offerId'] as int, 'accept');
      expect(accepted['state'], 'accepted');
      final taken = await job(orderId);
      expect(taken.status, 'assigned');
      expect(taken.driverId, cardB.id);
      expect(taken.courierId, 'delivery-courier-b');
      expect(taken.etaAt, isNotNull);
      expect(taken.codeHash, isNotNull);
      expect(taken.feeMinor, 299);
      expect((await card('delivery-courier-b')).status, 'busy');
      await expectLater(
        offer(assignment.id!, cardA.id!),
        refused('invalid_transition'),
      );
      final board = await read('delivery-owner', 'delivery.board');
      final row = (board['rows'] as List).cast<Json>().single;
      expect(row['driver']['name'], 'Bruno Courier');
      expect(row['eta']['estimate'], true);
      expect(board['venue'], {'latitude': venue.lat, 'longitude': venue.lng});
    });

    test('an offer lapses after 90 seconds and the sweep expires it', () async {
      await available(courierA);
      final cardA = await card('delivery-courier-a');
      final assignment = await job(await placeDelivery());
      final s = builder.build();
      Future<void> lapse(int offerId) async {
        final row = (await DeliveryOffer.db.findById(s, offerId))!;
        row.expiresAt = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
        await DeliveryOffer.db.updateRow(s, row);
      }

      final first = await offer(assignment.id!, cardA.id!);
      expect(
        DateTime.parse(first['expiresAt'] as String)
            .difference(DateTime.now().toUtc())
            .inSeconds,
        inInclusiveRange(85, 90),
      );
      await lapse(first['offerId'] as int);
      expect(
        (await respond(courierA, first['offerId'] as int, 'accept'))['state'],
        'expired',
      );
      final second = await offer(assignment.id!, cardA.id!);
      await lapse(second['offerId'] as int);
      await DeliveryModule.sweep(s);
      expect(
        (await DeliveryOffer.db.findById(s, second['offerId'] as int))!.state,
        'expired',
      );
      expect(
        await PlatformJob.db.count(s, where: (t) => t.kind.equals('dispatch.auto')),
        1,
      );
      expect((await job(assignment.orderId)).status, 'unassigned');
    });

    test('collect, ride with consented pings, and hand over against the code', () async {
      await available(courierA);
      final orderId = await placeDelivery();
      final a = await job(orderId);
      await OrderingModule.assignCourier(
        owner.build(),
        command({'courierId': 'delivery-courier-a'}, id: a.id, version: a.version),
      );
      await expectLater(move(courierA, orderId, 'collected'), refused('not_ready'));
      await ready(orderId);
      await move(courierA, orderId, 'collected');
      expect((await job(orderId)).pickedUpAt, isNotNull);
      await move(courierA, orderId, 'outForDelivery');
      final before = await job(orderId);
      final shared = await OrderingModule.location(
        courierA.build(),
        command({
          'consent': true,
          'latitude': 40.7460,
          'longitude': -74.0030,
          'accuracy': 12,
        }, id: before.id),
      );
      expect(shared['version'], before.version);
      final s = builder.build();
      expect(
        await DeliveryPing.db.count(s, where: (t) => t.assignmentId.equals(before.id!)),
        1,
      );
      final tracking = await read('delivery-customer', 'delivery.tracking', {
        'orderId': orderId,
      });
      expect(tracking['status'], 'outForDelivery');
      expect(tracking['location']['latitude'], 40.746);
      expect(tracking['eta']['estimate'], true);
      expect(tracking['eta']['prepMinutes'], 0);
      expect(tracking['driver'], {'name': 'Amal', 'vehicle': 'bike', 'partner': false});
      final code = tracking['code'] as String;
      expect(code, matches(RegExp(r'^\d{4}$')));
      await expectLater(
        read('delivery-stranger', 'delivery.tracking', {'orderId': orderId}),
        refused('forbidden'),
      );
      // The courier's own jobs carry the full address, never the code.
      final mine = await read('delivery-courier-a', 'courier.jobs');
      final carried = (mine['jobs'] as List).cast<Json>().single;
      expect(carried['address']['instructions'], 'Ring twice');
      expect(carried.containsKey('code'), isFalse);
      expect(jsonEncode(mine), isNot(contains('"$code"')));

      await expectLater(move(courierA, orderId, 'delivered'), refused('proof_required'));
      final wrong = code == '0000' ? '1111' : '0000';
      final miss = await DeliveryModule.proof(
        courierA.build(),
        command({'code': wrong}, id: before.id, version: before.version),
      );
      expect(miss['delivered'], false);
      expect(miss['attemptsLeft'], 4);
      final done = await DeliveryModule.proof(
        courierA.build(),
        command({'code': code}, id: before.id, version: before.version),
      );
      expect(done['delivered'], true);
      final finished = await job(orderId);
      expect(finished.status, 'delivered');
      expect(finished.proofKind, 'code');
      expect(finished.deliveredAt, isNotNull);
      expect(finished.locationJson, isNull);
      expect((await order(orderId)).status, 'delivered');
      expect(
        await DeliveryPing.db.count(s, where: (t) => t.assignmentId.equals(before.id!)),
        0,
      );
      expect((await card('delivery-courier-a')).status, 'available');
    });

    test('withdrawn consent forgets the trail; five wrong codes need a manager', () async {
      await available(courierA);
      final orderId = await placeDelivery();
      final a = await job(orderId);
      await OrderingModule.assignCourier(
        owner.build(),
        command({'courierId': 'delivery-courier-a'}, id: a.id, version: a.version),
      );
      await ready(orderId);
      await move(courierA, orderId, 'collected');
      await move(courierA, orderId, 'outForDelivery');
      final s = builder.build();
      final current = await job(orderId);
      for (final consent in [true, false]) {
        await OrderingModule.location(
          courierA.build(),
          command({
            'consent': consent,
            if (consent) 'latitude': 40.7450,
            if (consent) 'longitude': -74.0020,
          }, id: current.id),
        );
      }
      expect(
        await DeliveryPing.db.count(s, where: (t) => t.assignmentId.equals(current.id!)),
        0,
      );
      final code = DeliveryModule.dropoffCode(await order(orderId));
      final wrong = code == '0000' ? '1111' : '0000';
      for (var i = 0; i < 5; i++) {
        await DeliveryModule.proof(
          courierA.build(),
          command({'code': wrong}, id: current.id, version: current.version),
        );
      }
      await expectLater(
        DeliveryModule.proof(
          courierA.build(),
          command({'code': code}, id: current.id, version: current.version),
        ),
        refused('code_locked'),
      );
      await expectLater(
        DeliveryModule.proof(
          courierA.build(),
          command({'override': true}, id: current.id, version: current.version),
        ),
        refused('forbidden'),
      );
      await DeliveryModule.proof(
        owner.build(),
        command({'override': true}, id: current.id, version: current.version),
      );
      expect((await job(orderId)).proofKind, 'manager');
    });

    test('suggest ranks free drivers by minutes and load; off, it says so', () async {
      await available(courierA);
      await available(courierB);
      final cardB = await card('delivery-courier-b');
      final busyOrder = await placeDelivery();
      final busy = await job(busyOrder);
      await OrderingModule.assignCourier(
        owner.build(),
        command({'driverId': cardB.id}, id: busy.id, version: busy.version),
      );
      final open = await job(await placeDelivery());
      final suggestion = await DispatchAgent.suggest(
        owner.build(),
        command({'assignmentId': open.id}),
      );
      expect(suggestion['ai'], 'off');
      final ranking = (suggestion['ranking'] as List).cast<Json>();
      expect(ranking.first['name'], 'Amal Courier');
      expect(ranking.first['activeJobs'], 0);
      expect(ranking.last['activeJobs'], 1);
      expect(
        (ranking.first['score'] as num) > (ranking.last['score'] as num),
        isTrue,
      );
      await expectLater(
        DispatchAgent.suggest(courierA.build(), command({'assignmentId': open.id})),
        refused('forbidden'),
      );
    });

    test('with dispatchAuto, an accepted order is offered by the ranking alone', () async {
      await patchSettings({'dispatchAuto': true});
      await available(courierA);
      final cardA = await card('delivery-courier-a');
      final orderId = await placeDelivery();
      await step(orderId, 'accepted');
      final s = builder.build();
      final queued = await PlatformJob.db.find(
        s,
        where: (t) => t.kind.equals('dispatch.auto'),
      );
      expect(queued, hasLength(1));
      final a = await job(orderId);
      await DispatchAgent.autoJob(s, a.id!);
      final sent = (await DeliveryOffer.db.findFirstRow(
        s,
        where: (t) => t.assignmentId.equals(a.id!),
      ))!;
      expect(sent.driverId, cardA.id);
      expect(jsonDecode(sent.reasonJson)['by'], 'agent');
      final action = (await AgentAction.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(restaurant.id!) &
            t.command.equals('delivery.offer'),
      ))!;
      expect(action.status, 'auto');
      expect(action.rationale, contains('AI dispatcher is off'));
      // Declined, and nobody else is free: the managers hear about it.
      await respond(courierA, sent.id!, 'decline');
      await DispatchAgent.autoJob(s, a.id!);
      expect(
        await DeliveryOffer.db.count(s, where: (t) => t.assignmentId.equals(a.id!)),
        1,
      );
      expect(
        await UserNotification.db.count(
          s,
          where: (t) =>
              t.userId.equals('delivery-owner') &
              t.kind.equals('delivery.unassigned'),
        ),
        1,
      );
    });

    test('the AI dispatcher proposes an offer that a manager approves', () async {
      await available(courierA);
      await available(courierB);
      final cardB = await card('delivery-courier-b');
      final open = await job(await placeDelivery());
      final upstream = MoneyAgentsUpstream(
        gemini: (turn, body) {
          if (turn == 1) {
            return [
              {
                'functionCall': {'name': 'read_board', 'args': {}},
              },
              {
                'functionCall': {'name': 'read_drivers', 'args': {}},
              },
            ];
          }
          final drivers = (toolResults(body)['read_drivers']!['drivers'] as List)
              .cast<Map>();
          expect(drivers, hasLength(2));
          return [
            {
              'functionCall': {
                'name': 'propose_offer',
                'args': {
                  'driverId': cardB.id,
                  'rationale':
                      'Bruno is about as close and has no job on hand; times are estimates.',
                },
              },
            },
          ];
        },
      );
      ProviderClients.httpClient = upstream.client;
      ProviderClients.environment = () => {
        ...Platform.environment,
        'GEMINI_API_KEY': 'fixture-key',
      };
      AgentModule.environment = () => {
        ...Platform.environment,
        'RAYSTO_AGENT_DISPATCH_ENABLED': 'true',
      };
      AiBudget.environment = () => {
        ...Platform.environment,
        'RAYSTO_AI_BUDGET_STAGE': 'hackathon',
        'RAYSTO_AI_INPUT_USD_PER_MILLION': '0.75',
        'RAYSTO_AI_OUTPUT_USD_PER_MILLION': '3.75',
        'RAYSTO_AI_TENANT_DAILY_MICROS': '2000000',
      };
      final suggestion = await DispatchAgent.suggest(
        owner.build(),
        command({'assignmentId': open.id}),
      );
      expect(suggestion['ai'], 'queued');
      final s = builder.build();
      await AgentModule.run(s, suggestion['taskId'] as int);
      final task = (await AgentTask.db.findById(s, suggestion['taskId'] as int))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      final action = (await AgentAction.db.findFirstRow(
        s,
        where: (t) => t.taskId.equals(task.id!),
      ))!;
      expect(action.status, 'pending');
      expect(jsonDecode(action.payloadJson), {
        'assignmentId': open.id,
        'driverId': cardB.id,
      });
      expect(jsonDecode(action.evidenceJson)['estimate'], true);
      // Nothing is offered until a manager approves.
      expect(
        await DeliveryOffer.db.count(s, where: (t) => t.assignmentId.equals(open.id!)),
        0,
      );
      await stepUp();
      await AgentModule.decide(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          restaurantId: restaurant.id,
          resourceId: action.id,
          expectedVersion: action.version,
          dataJson: '{"decision":"approve"}',
        ),
      );
      final sent = (await DeliveryOffer.db.findFirstRow(
        s,
        where: (t) => t.assignmentId.equals(open.id!),
      ))!;
      expect(sent.driverId, cardB.id);
      expect(sent.state, 'offered');
    });

    test('a phone-dispatched driver, and drivers paid per delivery', () async {
      await stepUp();
      final sam = await DeliveryModule.saveDriver(
        owner.build(),
        command({'name': 'Sam', 'vehicle': 'scooter', 'payoutEmail': 'Sam@Example.test'}),
      );
      await expectLater(
        DeliveryModule.saveDriver(courierA.build(), command({'name': 'Me'})),
        refused('forbidden'),
      );
      await DeliveryModule.availability(
        owner.build(),
        command({'status': 'available'}, id: sam['id'] as int),
      );
      final orderId = await placeDelivery();
      final a = await job(orderId);
      final sent = await offer(a.id!, sam['id'] as int);
      expect(sent['hasLogin'], false);
      // Sam has no app: the dispatcher records the answer given by phone.
      final accepted = await respond(owner, sent['offerId'] as int, 'accept');
      expect(accepted['state'], 'accepted');
      final assigned = await job(orderId);
      expect(assigned.courierId, isNull);
      expect(assigned.driverId, sam['id']);
      await ready(orderId);
      await move(owner, orderId, 'collected');
      await move(owner, orderId, 'outForDelivery');
      // A manager may confirm without the code.
      await move(owner, orderId, 'delivered');
      final done = await job(orderId);
      expect(done.proofKind, 'manager');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      final pay = await DeliveryModule.driverPay(
        s,
        restaurant.id!,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(minutes: 1)),
        {...CatalogueModule.defaults, 'driverPayPerDeliveryMinor': 300},
      );
      final people = (pay['people'] as List).cast<Json>();
      expect(people.single['recipientEmail'], 'sam@example.test');
      expect(people.single['amountMinor'], 300);
      expect(people.single['deliveries'], 1);
      final task = await AgentTask.db.insertRow(
        s,
        AgentTask(
          restaurantId: restaurant.id!,
          agent: 'payroll',
          trigger: 'request',
          dedupeKey: 'delivery-pay-fixture',
          status: 'running',
          title: 'Pay run',
          inputJson: '{}',
          stateJson: '{}',
          traceJson: '[]',
          feature: 'agents',
          reservedMicros: 0,
          chargedMicros: 0,
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final batch = (await DeliveryModule.payBatch(
        s,
        task,
        now.subtract(const Duration(days: 1)),
        now.add(const Duration(minutes: 1)),
        'USD',
      ))!;
      expect(batch.kind, 'delivery');
      expect(batch.totalMinor, 300);
      expect(batch.state, 'proposed');
      final items = await PayoutItem.db.find(s, where: (t) => t.batchId.equals(batch.id!));
      expect(items.single.recipientEmail, 'sam@example.test');
      expect(jsonDecode(items.single.shiftIdsJson), [a.id]);
    });
  });
}
