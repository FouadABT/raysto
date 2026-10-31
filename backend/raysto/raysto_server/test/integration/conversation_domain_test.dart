import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Only the isolated localhost:61810 test cluster. No provider calls.
void main() {
  withServerpod('Conversation, proposal and budget boundaries', (
    builder,
    endpoints,
  ) {
    late TestSessionBuilder owner, first, second, outsider;
    late Restaurant restaurant;
    late DiningVisit visit;
    late ConversationRoom room;
    late BillCharge charge;
    var serial = 0;
    String key() => 'room_fixture_${++serial}_command';
    PlatformCommand command(
      Json data, {
      int? id,
      int? version,
      String? requestKey,
    }) => PlatformCommand(
      requestKey: requestKey ?? key(),
      restaurantId: restaurant.id,
      resourceId: id,
      expectedVersion: version,
      dataJson: jsonEncode(data),
    );
    Future<T> work<T>(String user, Future<T> Function(Work) fn) =>
        MoneyModule.locked(builder.build(), restaurant.id!, user, fn);
    setUp(() async {
      owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'room-owner',
          {},
        ),
      );
      first = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'diner-a',
          {},
        ),
      );
      second = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'diner-b',
          {},
        ),
      );
      outsider = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'outsider',
          {},
        ),
      );
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final id in ['room-owner', 'diner-a', 'diner-b', 'outsider']) {
        await ActorProfile.db.insertRow(
          s,
          ActorProfile(
            userId: id,
            isGuest: id != 'room-owner',
            disabled: false,
            dataJson: '{}',
            version: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      final made = await IdentityModule.createRestaurant(
        owner.build(),
        PlatformCommand(
          requestKey: key(),
          dataJson: '{"name":"Room fixture","currency":"USD"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, made['id']))!;
      final table = await DiningTable.db.insertRow(
        s,
        DiningTable(
          restaurantId: restaurant.id!,
          label: 'A',
          zone: 'Main',
          capacity: 4,
          active: true,
          needsReset: false,
          qrKey: key(),
          geometryJson: '{}',
          version: 1,
        ),
      );
      visit = await DiningVisit.db.insertRow(
        s,
        DiningVisit(
          restaurantId: restaurant.id!,
          tableId: table.id!,
          activeTableId: table.id!,
          guestCount: 2,
          status: 'active',
          version: 1,
          openedBy: 'room-owner',
          createdAt: now,
        ),
      );
      for (final user in ['diner-a', 'diner-b']) {
        await VisitParticipant.db.insertRow(
          s,
          VisitParticipant(
            restaurantId: restaurant.id!,
            visitId: visit.id!,
            userId: user,
            active: true,
            joinedAt: now,
          ),
        );
      }
      final opened = await ConversationModule.open(
        first.build(),
        command({'visitId': visit.id}),
      );
      room = (await ConversationRoom.db.findById(s, opened['roomId']))!;
      final order = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurant.id!,
          customerId: 'diner-a',
          requestKey: key(),
          requestHash: 'fixture',
          fulfillment: 'dineIn',
          lines: [],
          currency: 'USD',
          subtotalMinor: 1001,
          deliveryFeeMinor: 0,
          totalMinor: 1001,
          status: 'submitted',
          paymentStatus: 'unpaid',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await OrderContext.db.insertRow(
        s,
        OrderContext(
          restaurantId: restaurant.id!,
          orderId: order.id!,
          visitId: visit.id,
          detailsJson: '{}',
          paymentTiming: 'end',
          cancellationRequested: false,
          stockReleased: false,
          createdAt: now,
        ),
      );
      charge = await BillCharge.db.insertRow(
        s,
        BillCharge(
          restaurantId: restaurant.id!,
          orderId: order.id!,
          visitId: visit.id,
          lineKey: 'starter:1',
          kind: 'food',
          amountMinor: 1001,
          creditedMinor: 0,
          settledMinor: 0,
          reservedMinor: 0,
          foodNetMinor: 1001,
          version: 1,
        ),
      );
    });
    test(
      'QR knowledge, foreign rooms and revoked participation grant no room access',
      () async {
        await expectLater(
          ConversationModule.open(
            outsider.build(),
            command({'visitId': visit.id}),
          ),
          throwsA(isA<DomainError>()),
        );
        final other = await IdentityModule.createRestaurant(
          owner.build(),
          PlatformCommand(
            requestKey: key(),
            dataJson: '{"name":"Other","currency":"USD"}',
          ),
        );
        await expectLater(
          MoneyModule.locked(
            builder.build(),
            other['id'],
            'room-owner',
            (w) => ConversationModule.room(w, room.id!),
          ),
          throwsA(isA<DomainError>()),
        );
        await work(
          'diner-b',
          (w) => ConversationModule.eventPage(w, {'id': room.id, 'after': 0}),
        );
        final member = (await VisitParticipant.db.findFirstRow(
          builder.build(),
          where: (t) =>
              t.visitId.equals(visit.id!) & t.userId.equals('diner-b'),
        ))!;
        member.active = false;
        await VisitParticipant.db.updateRow(builder.build(), member);
        await expectLater(
          work(
            'diner-b',
            (w) => ConversationModule.eventPage(w, {'id': room.id, 'after': 0}),
          ),
          throwsA(isA<DomainError>()),
        );
        await expectLater(
          ConversationModule.send(
            second.build(),
            command({
              'text': 'No access',
              'clientMessageId': key(),
            }, id: room.id),
          ),
          throwsA(isA<DomainError>()),
        );
      },
    );
    test(
      'message retries, reply boundaries and cursors preserve one ordered history',
      () async {
        final clientKey = key();
        final a = await ConversationModule.send(
          first.build(),
          command({
            'text': 'Hello table',
            'clientMessageId': clientKey,
          }, id: room.id),
        );
        final b = await ConversationModule.send(
          first.build(),
          command({
            'text': 'Hello table',
            'clientMessageId': clientKey,
          }, id: room.id),
        );
        expect(a, b);
        await expectLater(
          ConversationModule.send(
            first.build(),
            command({
              'text': 'Changed',
              'clientMessageId': clientKey,
            }, id: room.id),
          ),
          throwsA(isA<DomainError>()),
        );
        final history = await work(
          'diner-a',
          (w) => ConversationModule.eventPage(w, {'id': room.id, 'after': 0}),
        );
        final cursor = history['cursor'] as int;
        expect(
          (history['events'] as List)
              .where((e) => e['kind'] == 'message')
              .length,
          1,
        );
        expect(
          (await work(
            'diner-a',
            (w) => ConversationModule.eventPage(w, {
              'id': room.id,
              'after': cursor,
            }),
          ))['events'],
          isEmpty,
        );
        await expectLater(
          ConversationModule.send(
            first.build(),
            command({
              'text': 'Reply',
              'clientMessageId': key(),
              'replyToId': 999999,
            }, id: room.id),
          ),
          throwsA(isA<DomainError>()),
        );
      },
    );
    test('private preferences never enter the table AI context', () async {
      await ConversationModule.preferences(
        first.build(),
        command({
          'preferences': ['private dietary note'],
          'shareWithTable': false,
          'muted': false,
        }, id: room.id),
      );
      final shared = await work(
        'diner-b',
        (w) => AssistantModule.sharedContext(w, room),
      );
      expect(jsonEncode(shared), isNot(contains('private dietary note')));
      await ConversationModule.preferences(
        first.build(),
        command({
          'preferences': ['vegetarian'],
          'shareWithTable': true,
          'muted': false,
        }, id: room.id),
      );
      expect(
        jsonEncode(
          await work('diner-b', (w) => AssistantModule.sharedContext(w, room)),
        ),
        contains('vegetarian'),
      );
    });
    test(
      'host authority, expiry and menu revisions bind an exact proposal',
      () async {
        final now = DateTime.now().toUtc();
        final run = await AssistantRun.db.insertRow(
          builder.build(),
          AssistantRun(
            restaurantId: restaurant.id!,
            roomId: room.id,
            userId: 'diner-a',
            requestKey: key(),
            status: 'completed',
            inputJson: '{}',
            outputJson: '{}',
            traceJson: '[]',
            reservedMicros: 0,
            chargedMicros: 0,
            budgetStage: 'development',
            version: 1,
            createdAt: now,
          ),
        );
        final hash = await work(
          'diner-a',
          (w) => AssistantModule.contextHash(w, room, 'basket'),
        );
        final proposal = await AssistantProposal.db.insertRow(
          builder.build(),
          AssistantProposal(
            restaurantId: restaurant.id!,
            roomId: room.id,
            runId: run.id!,
            userId: 'diner-a',
            kind: 'basket',
            payloadJson: '{}',
            contextHash: hash,
            status: 'review',
            version: 1,
            expiresAt: now.add(const Duration(minutes: 5)),
            createdAt: now,
          ),
        );
        await work(
          'diner-a',
          (w) => AssistantModule.validProposal(
            w,
            proposal.id!,
            'basket',
            state: 'review',
          ),
        );
        await expectLater(
          work(
            'diner-b',
            (w) => AssistantModule.validProposal(
              w,
              proposal.id!,
              'basket',
              state: 'review',
            ),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'forbidden'),
          ),
        );
        final policy = (await RestaurantPolicy.db.findFirstRow(
          builder.build(),
          where: (t) => t.restaurantId.equals(restaurant.id!),
        ))!;
        policy.menuVersion++;
        await RestaurantPolicy.db.updateRow(builder.build(), policy);
        await expectLater(
          work(
            'diner-a',
            (w) => AssistantModule.validProposal(
              w,
              proposal.id!,
              'basket',
              state: 'review',
            ),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'stale_proposal'),
          ),
        );
        proposal.contextHash = await work(
          'diner-a',
          (w) => AssistantModule.contextHash(w, room, 'basket'),
        );
        proposal.expiresAt = now.subtract(const Duration(seconds: 1));
        await AssistantProposal.db.updateRow(builder.build(), proposal);
        await expectLater(
          work(
            'diner-a',
            (w) => AssistantModule.validProposal(
              w,
              proposal.id!,
              'basket',
              state: 'review',
            ),
          ),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'stale_proposal'),
          ),
        );
      },
    );
    test('second diner keeps the frozen share after the first settles', () async {
      Future<Json> share(String user) => work(
        user,
        (w) async => EqualShares.prepare(
          w,
          room,
          ['diner-a', 'diner-b'],
          ((await AssistantModule.bill(w, room))['charges'] as List)
              .cast<Json>(),
        ),
      );
      final a = await share('diner-a');
      expect((a['shares'] as List).single['amountMinor'], 501);
      final s = owner.build();
      final paid = await MoneyModule.allocate(
        s,
        AllocatePayment(
          requestKey: key(),
          restaurantId: restaurant.id!,
          visitId: visit.id,
          method: 'cash',
          amountMinor: 501,
        ),
      );
      final intent = (await CheckoutIntent.db.findById(s, paid['checkoutId']))!;
      // Simulate the first diner's verified capture attribution without a provider call.
      intent.userId = 'diner-a';
      intent.splitPlanId = a['splitPlanId'];
      await CheckoutIntent.db.updateRow(s, intent);
      final b = await share('diner-b');
      expect((b['shares'] as List).single['amountMinor'], 500);
      expect((await share('diner-a'))['shares'], isEmpty);
      await MoneyModule.allocate(
        s,
        AllocatePayment(
          requestKey: key(),
          restaurantId: restaurant.id!,
          visitId: visit.id,
          method: 'cash',
          amountMinor: 500,
        ),
      );
      expect((await BillCharge.db.findById(s, charge.id!))!.settledMinor, 1001);
      await expectLater(
        MoneyModule.allocate(
          s,
          AllocatePayment(
            requestKey: key(),
            restaurantId: restaurant.id!,
            visitId: visit.id,
            method: 'cash',
            amountMinor: 1,
          ),
        ),
        throwsA(isA<DomainError>()),
      );
    });
    test('an equal split works without the assistant and binds exact shares', () async {
      final split = await EqualShares.equal(
        first.build(),
        command({
          'payers': ['diner-a', 'diner-b'],
        }, id: room.id),
      );
      final mine = (split['shares'] as List).cast<Json>();
      expect(mine.single['amountMinor'], 501);
      AllocatePayment pay(int amount) => AllocatePayment(
        requestKey: key(),
        restaurantId: restaurant.id!,
        visitId: visit.id,
        splitPlanId: split['splitPlanId'] as int,
        shares: [
          ChargeShare(
            chargeId: mine.single['chargeId'] as int,
            amountMinor: amount,
            expectedVersion: mine.single['expectedVersion'] as int,
          ),
        ],
        method: 'paypal',
      );
      await expectLater(
        MoneyModule.allocate(first.build(), pay(1001)),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'stale_proposal'),
        ),
      );
      ProviderClients.environment = () => {
        ...Platform.environment,
        'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
        'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': 'true',
        'RAYSTO_SANDBOX_RESTAURANT_ID': '${restaurant.id}',
        'PAYPAL_SANDBOX_MERCHANT_ID': 'MERCHANT-FIXTURE',
      };
      try {
        final reserved = await MoneyModule.allocate(first.build(), pay(501));
        final intent = (await CheckoutIntent.db.findById(
          builder.build(),
          reserved['checkoutId'] as int,
        ))!;
        expect(intent.splitPlanId, split['splitPlanId']);
        expect(intent.amountMinor, 501);
      } finally {
        ProviderClients.environment = () => Platform.environment;
      }
    });
    test(
      'implicit payment lookup uses only this payer and conversation',
      () async {
        final s = builder.build();
        final now = DateTime.now().toUtc();
        Future<CheckoutIntent> add(String user, int? visitId) =>
            CheckoutIntent.db.insertRow(
              s,
              CheckoutIntent(
                restaurantId: restaurant.id!,
                userId: user,
                visitId: visitId,
                requestKey: key(),
                requestHash: 'fixture',
                providerRequestId: key(),
                merchantId: 'fixture',
                state: 'created',
                method: 'paypal',
                currency: 'USD',
                amountMinor: 500,
                commissionMinor: 0,
                commissionBps: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
        final mine = await add('diner-a', visit.id);
        final someoneElse = await add('diner-b', visit.id);
        final otherConversation = await add('diner-a', null);
        final found = await work(
          'diner-a',
          (w) => AssistantModule.paymentIntent(w, roomId: room.id),
        );
        expect(found.id, mine.id);
        for (final denied in [someoneElse.id, otherConversation.id]) {
          await expectLater(
            work(
              'diner-a',
              (w) => AssistantModule.paymentIntent(
                w,
                roomId: room.id,
                checkoutId: denied,
              ),
            ),
            throwsA(isA<DomainError>()),
          );
        }
      },
    );
    test(
      'saved workspace rejects foreign tables and unsupported tabs',
      () async {
        final s = owner.build();
        Future<Json> save(Json state, int version) =>
            WorkspaceModule.saveLayout(
              s,
              command({
                'state': {'pages': [], ...state},
              }, version: version),
            );
        await save({'selectedTableId': visit.tableId, 'tab': 'payments'}, 0);
        final snapshot = await work(
          'room-owner',
          (w) => WorkspaceModule.snapshot(w, {}),
        );
        expect(snapshot['layout']['selectedTableId'], visit.tableId);
        expect(snapshot['layout']['tab'], 'payments');
        final foreign = await IdentityModule.createRestaurant(
          s,
          PlatformCommand(
            requestKey: key(),
            dataJson: '{"name":"Other fixture","currency":"USD"}',
          ),
        );
        final original = (await DiningTable.db.findById(s, visit.tableId))!;
        final otherTable = await DiningTable.db.insertRow(
          s,
          original.copyWith(
            id: null,
            restaurantId: foreign['id'],
            qrKey: key(),
          ),
        );
        await expectLater(
          save({'selectedTableId': otherTable.id, 'tab': 'orders'}, 1),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'not_found'),
          ),
        );
        await expectLater(save({'tab': 'sql'}, 1), throwsA(isA<DomainError>()));
      },
    );
    test(
      'unknown AI cost is retained and budget exhaustion rejects new work',
      () async {
        final s = builder.build();
        final reservation = await AiBudget.reserve(s, key());
        final source = key();
        final amount = await AiBudget.reserve(s, source);
        expect(await AiBudget.settle(s, source), amount);
        expect(await AiBudget.settle(s, source, actualMicros: 0), amount);
        final budget = (await AiSpendBudget.db.findFirstRow(
          s,
          where: (t) => t.stage.equals('development'),
        ))!;
        expect(budget.reservedMicros, reservation);
        budget.spentMicros = budget.limitMicros - budget.reservedMicros;
        await AiSpendBudget.db.updateRow(s, budget);
        await expectLater(
          AiBudget.reserve(s, key()),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'ai_budget_exhausted',
            ),
          ),
        );
      },
    );
  });
}
