import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Supplier orders, recipes, stock
// movements, the forecast, the supply planner and the 3-way match, with a
// scripted Gemini (the photo answer and the tool turns are fixed).
void main() {
  withServerpod('Purchasing and the supply planner', (builder, endpoints) {
    late TestSessionBuilder owner, waiter;
    late Restaurant restaurant;
    var serial = 0;
    String key() => 'purchasing_${(++serial).toString().padLeft(8, '0')}';
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
    Future<Json> read(String name, [Json d = const {}]) =>
        PurchasingModule.read(
          owner.build(),
          restaurantId: restaurant.id!,
          name: name,
          d: d,
        );
    Future<Json> decide(AgentAction a) => AgentModule.decide(
      owner.build(),
      PlatformCommand(
        requestKey: key(),
        restaurantId: restaurant.id,
        resourceId: a.id,
        expectedVersion: a.version,
        dataJson: '{"decision":"approve"}',
      ),
    );
    Future<List<AgentAction>> runTask(int taskId) async {
      final s = builder.build();
      await AgentModule.run(s, taskId);
      final task = (await AgentTask.db.findById(s, taskId))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      return AgentAction.db.find(
        s,
        where: (t) => t.taskId.equals(taskId),
        orderBy: (t) => t.ordinal,
      );
    }

    Matcher refused(String code) =>
        throwsA(isA<DomainError>().having((e) => e.code, 'code', code));

    String sse(List<Json> parts) =>
        'data: ${jsonEncode({
          'candidates': [
            {
              'index': 0,
              'content': {'role': 'model', 'parts': parts},
              'finishReason': 'STOP',
            },
          ],
          'usageMetadata': {'promptTokenCount': 900, 'candidatesTokenCount': 120, 'totalTokenCount': 1020},
        })}\r\n\r\n';
    Json call(String name, Json args) => {
      'functionCall': {'name': name, 'args': args},
    };

    /// Scripts Gemini: the photo answer, then one list of parts per turn.
    void gemini({Json? photo, required List<List<Json>> turns}) {
      var turn = 0;
      ProviderClients.httpClient = () => MockClient((r) async {
        if (r.url.path.endsWith(':countTokens')) {
          return http.Response('{"totalTokens": 900}', 200);
        }
        final parts = r.body.contains('inlineData')
            ? [
                {'text': jsonEncode(photo)},
              ]
            : turns[turn++];
        return http.Response.bytes(
          utf8.encode(sse(parts)),
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });
    }

    Future<Supplier> supplier(
      String name, {
      String? email,
      String payoutEmail = '',
      int? leadDays,
    }) => Supplier.db.insertRow(
      builder.build(),
      Supplier(
        restaurantId: restaurant.id!,
        name: name,
        payoutEmail: payoutEmail,
        email: email,
        leadDays: leadDays,
        version: 1,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    Future<StockItem> item(
      String name,
      String unit,
      double quantity,
      int costMinor, {
      double lowAt = 0,
      int? supplierId,
      double? parLevel,
      int? leadDays,
    }) => StockItem.db.insertRow(
      builder.build(),
      StockItem(
        restaurantId: restaurant.id!,
        name: name,
        unit: unit,
        quantity: quantity,
        costMinor: costMinor,
        supplierId: supplierId,
        lowAt: lowAt,
        parLevel: parLevel,
        leadDays: leadDays,
        version: 1,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    Future<StockItem> fresh(StockItem x) async =>
        (await StockItem.db.findById(builder.build(), x.id!))!;

    /// Usage in the past: one sale movement per day for [days] days.
    Future<void> sold(StockItem x, double perDay, {int days = 28}) async {
      final now = DateTime.now().toUtc();
      await StockMovement.db.insert(builder.build(), [
        for (var d = 1; d <= days; d++)
          StockMovement(
            restaurantId: restaurant.id!,
            stockItemId: x.id!,
            kind: 'sale',
            quantity: -perDay,
            unitCostMinor: x.costMinor,
            refType: 'fixture',
            refId: '${x.id}:$d',
            at: now.subtract(Duration(days: d - 1, hours: 1)),
          ),
      ]);
    }

    Future<MediaAsset> note() => MediaAsset.db.insertRow(
      builder.build(),
      MediaAsset(
        restaurantId: restaurant.id,
        userId: 'pu-owner',
        purpose: 'deliveryNote',
        objectName: 'v2/sanitized/fixture/${key()}.jpg',
        mime: 'image/jpeg',
        byteLength: 3,
        sha256: 'fixture',
        status: 'approved',
        public: false,
        metadataJson: '{}',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    /// A purchase order already sent to [sup].
    Future<Json> sentOrder(Supplier sup, List<Json> lines) async {
      final saved = await PurchasingModule.saveOrder(
        owner.build(),
        command({'supplierId': sup.id, 'lines': lines}),
      );
      return PurchasingModule.sendOrder(
        owner.build(),
        command({}, id: saved['orderId'] as int, version: saved['version'] as int),
      );
    }

    setUp(() async {
      owner = session('pu-owner');
      waiter = session('pu-waiter');
      final s = builder.build();
      final now = DateTime.now().toUtc();
      for (final (user, name) in [('pu-owner', 'Owner'), ('pu-waiter', 'Sam')]) {
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
          dataJson: '{"name":"Purchasing fixture","currency":"EUR"}',
        ),
      );
      restaurant = (await Restaurant.db.findById(s, created['id'] as int))!;
      await Membership.db.insertRow(
        s,
        Membership(restaurantId: restaurant.id!, userId: 'pu-waiter', role: 'waiter', active: true),
      );
      AgentModule.environment = () => {
        ...Platform.environment,
        'RAYSTO_AGENT_SUPPLIES_ENABLED': 'true',
      };
      ProviderClients.environment = () => {
        ...Platform.environment,
        'GEMINI_API_KEY': 'fixture-key',
      };
      AiBudget.environment = () => {
        ...Platform.environment,
        'RAYSTO_AI_BUDGET_STAGE': 'hackathon',
        'RAYSTO_AI_INPUT_USD_PER_MILLION': '0.75',
        'RAYSTO_AI_OUTPUT_USD_PER_MILLION': '3.75',
        'RAYSTO_AI_TENANT_DAILY_MICROS': '2000000',
      };
      MenuAgent.readFile = (_) async => Uint8List.fromList([0xff, 0xd8, 0xff]);
    });
    tearDown(() {
      AgentModule.environment = () => Platform.environment;
      ProviderClients.environment = () => Platform.environment;
      AiBudget.environment = () => Platform.environment;
      ProviderClients.httpClient = http.Client.new;
      MenuAgent.readFile = ProviderClients.getFile;
    });

    test('a purchase order is drafted, sent, received in part, then in full', () async {
      final s = builder.build();
      final sup = await supplier('Marché Dupont', email: 'orders@dupont.example.com', leadDays: 2);
      final flour = await item('Flour T55', 'kg', 5, 120, lowAt: 10, supplierId: sup.id);
      final eggs = await item('Eggs', 'piece', 30, 32, lowAt: 60, supplierId: sup.id);

      await expectLater(
        PurchasingModule.saveOrder(
          waiter.build(),
          command({'supplierId': sup.id, 'lines': [{'stockItemId': flour.id, 'qty': 25}]}),
        ),
        refused('forbidden'),
      );
      await expectLater(
        PurchasingModule.saveOrder(
          owner.build(),
          command({
            'supplierId': sup.id,
            'lines': [
              {'stockItemId': flour.id, 'qty': 25},
              {'stockItemId': flour.id, 'qty': 5},
            ],
          }),
        ),
        refused('invalid_input'),
      );
      final saved = await PurchasingModule.saveOrder(
        owner.build(),
        command({
          'supplierId': sup.id,
          'lines': [
            {'stockItemId': flour.id, 'qty': 25},
            {'stockItemId': eggs.id, 'qty': 180, 'unitCostMinor': 30},
          ],
        }),
      );
      final id = saved['orderId'] as int;
      expect(saved['state'], 'draft');
      expect(saved['totalMinor'], 25 * 120 + 180 * 30);
      final edited = await PurchasingModule.saveOrder(
        owner.build(),
        command({
          'supplierId': sup.id,
          'lines': [
            {'stockItemId': flour.id, 'qty': 30},
            {'stockItemId': eggs.id, 'qty': 180, 'unitCostMinor': 30},
          ],
        }, id: id, version: saved['version'] as int),
      );
      expect(edited['totalMinor'], 30 * 120 + 180 * 30);

      final sent = await PurchasingModule.sendOrder(
        owner.build(),
        command({}, id: id, version: edited['version'] as int),
      );
      expect(sent['state'], 'sent');
      expect(sent['emailed'], isTrue);
      expect(sent['to'], 'orders@dupont.example.com');
      final job = await PlatformJob.db.findFirstRow(
        s,
        where: (t) => t.dedupeKey.equals('supplier-order:$id'),
      );
      expect(job?.kind, 'email.supplierOrder');
      await expectLater(
        PurchasingModule.saveOrder(
          owner.build(),
          command({
            'supplierId': sup.id,
            'lines': [{'stockItemId': flour.id, 'qty': 1}],
          }, id: id, version: sent['version'] as int),
        ),
        refused('invalid_transition'),
      );

      final part = await PurchasingModule.receiveOrder(
        owner.build(),
        command({
          'lines': [{'stockItemId': flour.id, 'qty': 20}],
        }, id: id, version: sent['version'] as int),
      );
      expect(part['state'], 'partiallyReceived');
      expect((await fresh(flour)).quantity, 25.0);
      final full = await PurchasingModule.receiveOrder(
        owner.build(),
        command({
          'lines': [
            {'stockItemId': flour.id, 'qty': 10},
            {'stockItemId': eggs.id, 'qty': 180, 'unitCostMinor': 33},
          ],
        }, id: id, version: part['version'] as int),
      );
      expect(full['state'], 'received');
      expect((await fresh(flour)).quantity, 35.0);
      final e = await fresh(eggs);
      expect(e.quantity, 210.0);
      expect(e.costMinor, 33, reason: 'stock keeps the price paid');
      final moves = await StockMovement.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!) & t.kind.equals('receive'),
      );
      expect(moves, hasLength(3));
      expect(moves.every((m) => m.refType == 'supplierOrder'), isTrue);

      await expectLater(
        PurchasingModule.saveOrder(
          owner.build(),
          command({'state': 'cancelled'}, id: id, version: full['version'] as int),
        ),
        refused('invalid_transition'),
      );
      final other = await PurchasingModule.saveOrder(
        owner.build(),
        command({'supplierId': sup.id, 'lines': [{'stockItemId': flour.id, 'qty': 3}]}),
      );
      final cancelled = await PurchasingModule.saveOrder(
        owner.build(),
        command({'state': 'cancelled'}, id: other['orderId'] as int, version: other['version'] as int),
      );
      expect(cancelled['state'], 'cancelled');
      final third = await PurchasingModule.saveOrder(
        owner.build(),
        command({'supplierId': sup.id, 'lines': [{'stockItemId': eggs.id, 'qty': 6}]}),
      );
      final viaCancel = await PurchasingModule.cancelOrder(
        owner.build(),
        command({}, id: third['orderId'] as int, version: third['version'] as int),
      );
      expect(viaCancel['state'], 'cancelled');
      final flourMoves = (await read('stock.movements', {'stockItemId': flour.id}))['rows'] as List;
      expect(flourMoves.map((m) => m['kind']), ['receive', 'receive']);
      expect(flourMoves.map((m) => m['quantity']), [10.0, 20.0], reason: 'newest first');

      final orders = (await read('supplier.orders'))['rows'] as List;
      expect(orders, hasLength(3));
      final view = await read('supplier.order', {'id': id});
      expect(view['supplierName'], 'Marché Dupont');
      expect((view['lines'] as List).first['receivedQty'], 30.0);
      final cards = (await read('supplier.scorecards'))['rows'] as List;
      final card = cards.single as Map;
      expect(card['orders'], 1);
      expect(card['onTimePct'], 100.0);
      expect(card['fillRatePct'], 100.0);
      // 180 eggs ordered at 0.30 arrived at 0.33: 540 more on 9000.
      expect(card['priceVariancePct'], 6.0);
    });

    test('a completed order uses stock by its recipes, once', () async {
      final s = builder.build();
      final flour = await item('Flour', 'kg', 10, 120, lowAt: 2);
      final butter = await item('Butter', 'kg', 5, 980, lowAt: 1);
      final croissant = await MenuProduct.db.insertRow(
        s,
        MenuProduct(
          restaurantId: restaurant.id!,
          name: 'Croissant',
          description: 'Butter croissant',
          priceMinor: 300,
          available: true,
          version: 1,
        ),
      );
      await expectLater(
        PurchasingModule.saveRecipe(
          waiter.build(),
          command({'productId': croissant.id, 'lines': []}),
        ),
        refused('forbidden'),
      );
      final recipe = await PurchasingModule.saveRecipe(
        owner.build(),
        command({
          'productId': croissant.id,
          'lines': [
            {'stockItemId': flour.id, 'quantity': 0.05},
            {'stockItemId': butter.id, 'quantity': 0.025},
          ],
        }),
      );
      expect(recipe['lines'], 2);
      final recipes = (await read('recipes'))['rows'] as List;
      final row = recipes.single as Map;
      expect(row['name'], 'Croissant');
      expect((row['lines'] as List).map((l) => l['name']), ['Flour', 'Butter']);

      final now = DateTime.now().toUtc();
      final order = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: restaurant.id!,
          customerId: 'walk-in',
          requestKey: key(),
          requestHash: 'fixture',
          fulfillment: 'pickup',
          lines: [OrderLine(productId: croissant.id!, name: 'Croissant', quantity: 4, unitPriceMinor: 300)],
          currency: 'EUR',
          subtotalMinor: 1200,
          deliveryFeeMinor: 0,
          totalMinor: 1200,
          status: 'completed',
          paymentStatus: 'paid',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      // The audit trigger, twice (a retried completion): stock moves once.
      for (var i = 0; i < 2; i++) {
        await AgentModule.asAgent(
          s,
          restaurant.id!,
          (w) => w.audit('order.completed', 'order', order.id),
        );
      }
      final sales = await StockMovement.db.find(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!) & t.kind.equals('sale'),
      );
      expect(sales, hasLength(2));
      expect((await fresh(flour)).quantity, 9.8);
      expect((await fresh(butter)).quantity, 4.9);
      final forecast = await read('stock.forecast');
      expect(forecast['basis'], 'movements');
    });

    test('the forecast, a count and the waste log', () async {
      final sup = await supplier('Verger', leadDays: 3);
      final milk = await item('Milk', 'l', 10, 110, lowAt: 8, supplierId: sup.id);
      final eggs = await item('Eggs', 'piece', 12, 32, lowAt: 10, parLevel: 30, leadDays: 3);
      final salt = await item('Salt', 'kg', 4, 90, lowAt: 1);
      await sold(milk, 2);
      await sold(eggs, 2.5);

      await PurchasingModule.wasteStock(
        owner.build(),
        command({'stockItemId': milk.id, 'quantity': 1, 'reason': 'expired'}),
      );
      await expectLater(
        PurchasingModule.wasteStock(
          owner.build(),
          command({'stockItemId': milk.id, 'quantity': 1, 'reason': 'eaten'}),
        ),
        refused('invalid_input'),
      );
      final counted = await PurchasingModule.countStock(
        owner.build(),
        command({'stockItemId': salt.id, 'quantity': 3.5}),
      );
      expect(counted['variance'], -0.5);
      expect((await fresh(salt)).quantity, 3.5);

      final f = await read('stock.forecast');
      final rows = (f['rows'] as List).cast<Map>();
      Map row(String name) => rows.firstWhere((r) => r['name'] == name);
      // Milk: 56 sold + 1 wasted over 28 days, 9 l left, 3 days' lead.
      expect(row('Milk')['dailyUsage'], 2.036);
      expect(row('Milk')['quantity'], 9.0);
      expect(row('Milk')['leadDays'], 3, reason: "the supplier's lead time");
      expect(row('Milk')['reorder'], isTrue);
      expect(row('Milk')['supplierName'], 'Verger');
      // Eggs: 2.5 a day, 12 left, 3 days → 4.5 at arrival; up to par 30.
      expect(row('Eggs')['daysCover'], 4.8);
      expect(row('Eggs')['suggestedQty'], 26.0);
      expect(row('Salt')['reorder'], isFalse);
      final waste = (f['waste'] as List).single as Map;
      expect(waste['name'], 'Milk');
      expect(waste['reason'], 'expired');
      expect(waste['valueMinor'], 110);
    });

    test('the planner proposes orders by supplier; approving drafts the order', () async {
      final s = builder.build();
      final dupont = await supplier('Marché Dupont', email: 'orders@dupont.example.com', leadDays: 2);
      final verger = await supplier('Verger', leadDays: 1);
      final flour = await item('Flour', 'kg', 10, 120, lowAt: 8, supplierId: dupont.id);
      final eggs = await item('Eggs', 'piece', 12, 32, lowAt: 10, parLevel: 30, supplierId: verger.id);
      final salt = await item('Salt', 'kg', 40, 90, lowAt: 1, supplierId: dupont.id);
      await sold(flour, 2);
      await sold(eggs, 2.5);
      await sold(salt, 0.1);

      gemini(turns: [
        [call('read_stock', {}), call('read_usage', {}), call('read_suppliers', {})],
        // Salt is not due: refused, the model drops it.
        [
          call('propose_order', {
            'supplierId': dupont.id,
            'lines': [
              {'stockItemId': flour.id, 'qty': 12, 'reason': 'x'},
              {'stockItemId': salt.id, 'qty': 5, 'reason': 'x'},
            ],
            'explanation': 'x',
          }),
        ],
        [
          call('propose_order', {
            'supplierId': dupont.id,
            'lines': [
              {'stockItemId': flour.id, 'qty': 12, 'reason': '5 days of cover; runs out on Monday.'},
            ],
            'explanation': 'Flour covers 5 days and Dupont needs 2; ordering 12 kg brings it to par.',
          }),
          call('propose_order', {
            'supplierId': verger.id,
            'lines': [
              {'stockItemId': eggs.id, 'qty': 26, 'reason': '4.8 days of cover.'},
            ],
            'explanation': 'Eggs run out in under five days; 26 brings them to the par of 30.',
          }),
        ],
        [
          {'text': 'Two orders proposed: flour from Marché Dupont and eggs from Verger.'},
        ],
      ]);
      await expectLater(
        SupplyPlanner.start(waiter.build(), command({})),
        refused('forbidden'),
      );
      final started = await SupplyPlanner.start(owner.build(), command({}));
      final actions = await runTask(started['taskId'] as int);
      final task = (await AgentTask.db.findById(s, started['taskId'] as int))!;
      expect(
        (jsonDecode(task.traceJson) as List).any((t) => t['tool'] == 'propose_order' && t['status'] == 'rejected'),
        isTrue,
        reason: 'the item that was not due was refused',
      );
      expect(task.summary, contains('Two orders proposed'));
      expect(actions.map((a) => a.command), ['supplier.order.propose', 'supplier.order.propose']);
      final evidence = jsonDecode(actions.first.evidenceJson) as Map;
      expect(evidence['by'], 'ai');
      expect(((evidence['lines'] as List).single as Map)['daysCover'], 5.0);
      final preview = jsonDecode(actions.first.previewJson) as Map;
      expect(preview['totalMinor'], 12 * 120);

      final done = await decide(actions.first);
      expect(done['state'], 'executed', reason: '$done');
      final order = (await SupplierOrder.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurant.id!),
      ))!;
      expect(order.state, 'draft');
      expect(order.supplierId, dupont.id);
      expect(order.taskId, task.id);
      expect(order.totalMinor, 1440);
    });

    test('nothing due: the planner finishes without the AI', () async {
      final flour = await item('Flour', 'kg', 100, 120, lowAt: 8);
      await sold(flour, 1);
      ProviderClients.httpClient = () => MockClient((r) async => http.Response('unexpected', 500));
      final started = await SupplyPlanner.start(owner.build(), command({}));
      final actions = await runTask(started['taskId'] as int);
      expect(actions, isEmpty);
      final task = (await AgentTask.db.findById(builder.build(), started['taskId'] as int))!;
      expect(task.summary, startsWith('Nothing to reorder'));
    });

    test('a delivery is matched to its order and bill; bill.match approves the payable', () async {
      final s = builder.build();
      final sup = await supplier(
        'Marché Dupont',
        email: 'orders@dupont.example.com',
        payoutEmail: 'supplier-dupont@business.example.com',
        leadDays: 2,
      );
      final flour = await item('Flour T55', 'kg', 5, 120, lowAt: 10, supplierId: sup.id);
      final butter = await item('Butter AOP', 'kg', 2, 980, lowAt: 3, supplierId: sup.id);
      final sent = await sentOrder(sup, [
        {'stockItemId': flour.id, 'qty': 25},
        {'stockItemId': butter.id, 'qty': 10},
      ]);
      final orderId = sent['orderId'] as int;
      gemini(
        photo: {
          'supplierName': 'Marché Dupont',
          'payoutEmail': 'supplier-dupont@business.example.com',
          'reference': 'DN-77',
          'lines': [
            {'name': 'Farine T55', 'orderedName': 'Flour T55', 'quantity': 20, 'unit': 'kg', 'unitCostMinor': 120},
            {'name': 'Beurre AOP', 'orderedName': 'Butter AOP', 'quantity': 10, 'unit': 'kg', 'unitCostMinor': 1050},
          ],
          'totalMinor': 12900,
          'dueDays': 14,
        },
        turns: [
          [
            call('explain_match', {
              'explanation':
                  'Flour arrived 5 kg short and butter costs 7.1% more than ordered. Ask Dupont to credit the flour before paying.',
            }),
          ],
        ],
      );
      final media = await note();
      await expectLater(
        SuppliesAgent.receive(waiter.build(), command({'mediaId': media.id, 'supplierOrderId': orderId})),
        refused('forbidden'),
      );
      final started = await SuppliesAgent.receive(
        owner.build(),
        command({'mediaId': media.id, 'supplierOrderId': orderId}),
      );
      final actions = await runTask(started['taskId'] as int);
      expect(actions.map((a) => a.command), ['stock.receive', 'bill.match']);
      expect(actions.first.rationale, contains('5 kg short'));

      final delivery = ((await read('supply.deliveries'))['rows'] as List).single as Map;
      expect(delivery['supplierOrderId'], orderId);
      final match = delivery['match'] as Map;
      final lines = (match['lines'] as List).cast<Map>();
      expect(lines.firstWhere((l) => l['name'] == 'Flour T55')['flags'], ['short']);
      expect(lines.firstWhere((l) => l['name'] == 'Butter AOP')['flags'], ['price_up']);
      expect(match['flagged'], 2);
      expect(match['billTotalMinor'], 12900);
      expect(match['clean'], isFalse);
      expect(match['explanation'], contains('credit the flour'));

      final bill = (await Bill.db.findFirstRow(
        s,
        where: (t) => t.supplierOrderId.equals(orderId),
      ))!;
      expect(bill.state, 'review');
      expect(bill.category, 'supplier');
      expect(bill.supplierId, sup.id);
      expect(bill.amountMinor, 12900);
      expect(bill.payVia, 'paypal');

      final received = await decide(actions.first);
      expect(received['state'], 'executed', reason: '$received');
      expect((await fresh(flour)).quantity, 25.0);
      final b = await fresh(butter);
      expect(b.quantity, 12.0);
      expect(b.costMinor, 1050);
      final view = await read('supplier.order', {'id': orderId});
      expect(view['state'], 'partiallyReceived');
      expect((view['delivery'] as Map)['match'], isNotNull);

      final matched = await decide(actions.last);
      expect(matched['state'], 'executed', reason: '$matched');
      final approved = (await Bill.db.findById(s, bill.id!))!;
      expect(approved.state, 'approved');
      final order = (await SupplierOrder.db.findById(s, orderId))!;
      expect(order.state, 'billed');
      expect(order.billId, bill.id);
    });
  });
}
