@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Only the dedicated Raysto test cluster; no provider or production calls.
void main() {
  withServerpod('Shared restaurant costing and approvals', (
    builder,
    endpoints,
  ) {
    late AccountantWorld world;
    late int ingredient;
    Future<Json> read(String name, [Json data = const {}]) =>
        world.read(name, data);
    Future<Json> recipe({String quantity = '350', int? version}) =>
        Finance017.saveRecipe(
          world.owner.build(),
          world.command({
            'productId': world.burger,
            'lines': [
              {
                'stockItemId': ingredient,
                'quantity': quantity,
                'unit': 'g',
                'packSize': '1',
                'yieldBps': 10000,
              },
            ],
            'packagingMinor': 0,
            'packagingConfirmed': true,
          }, version: version ?? 0),
        );
    Future<Json> scenario() => Finance017.createScenario(
      world.owner.build(),
      world.command({'productId': world.burger}),
    );
    Future<Json> activate() => FinanceAccounting.activate(
      world.owner.build(),
      world.command({
        'reviewed': true,
        'reason': 'Reviewed zero opening balances for isolated fixture',
        'opening': [],
      }, version: 0),
    );
    setUp(() async {
      world = AccountantWorld(builder, 'finance017');
      await world.setUp(settings: {'taxBps': 0});
      Finance017.environment = () => {
        'RAYSTO_FINANCE_017_ENABLED': 'true',
        'RAYSTO_PRICING_ENABLED': 'true',
      };
      ingredient =
          (await BackOfficeModule.saveStock(
                world.owner.build(),
                world.command({
                  'name': 'Coffee ingredient',
                  'unit': 'kg',
                  'quantity': 10,
                  'costMinor': 1100,
                  'lowAt': 1,
                }),
              ))['stockId']
              as int;
      await StockMovement.db.insertRow(
        builder.build(),
        StockMovement(
          restaurantId: world.restaurant.id!,
          stockItemId: ingredient,
          kind: 'receive',
          quantity: 10,
          unitCostMinor: 1100,
          purchaseUnit: 'kg',
          refType: 'fixture',
          refId: world.key(),
          at: DateTime.now().toUtc(),
        ),
      );
      await recipe();
      await Finance017.savePolicy(
        world.owner.build(),
        world.command({
          'targetBps': 6000,
          'maxIncreaseBps': 1000,
          'incrementMinor': 10,
          'excludedProducts': [],
        }, version: 0),
      );
    });
    tearDown(() {
      Finance017.environment = () => Platform.environment;
      world.tearDown();
    });

    test(
      'comparison revisions preserve evidence and cannot expand owner limits',
      () async {
        final first = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        final next = await FinanceDecisions.save(
          world.owner.build(),
          world.command({
            'parentId': first['id'],
            'maxIncreaseBps': 500,
            'volumeChangeBps': -1500,
            'candidatePriceMinor': 950,
          }),
          revise: true,
        );
        expect(next['parentId'], first['id']);
        expect(next['revision'], 2);
        expect(next['feasible'], false);
        expect(
          (await read('pricing.comparison', {
            'id': first['id'],
          }))['inputs']['maxIncreaseBps'],
          1000,
        );
        await world.expectFailure(
          () => FinanceDecisions.save(
            world.owner.build(),
            world.command({'parentId': first['id'], 'maxIncreaseBps': 1100}),
            revise: true,
          ),
          'policy_limit',
        );
        await world.expectFailure(
          () => Finance017.propose(
            world.owner.build(),
            world.command({'comparisonId': next['id'], 'option': 'custom'}),
          ),
          'analysis_only',
        );
      },
    );

    test(
      'comparison proposal and keep decision never publish directly',
      () async {
        final comparison = await FinanceDecisions.save(
          world.owner.build(),
          world.command({
            'productId': world.burger,
            'baselineUnits': 100,
            'candidatePriceMinor': 980,
          }),
          revise: false,
        );
        final proposal = await Finance017.propose(
          world.owner.build(),
          world.command({'comparisonId': comparison['id'], 'option': 'custom'}),
        );
        expect(proposal['preview']['toMinor'], 980);
        expect(
          (await read('costing.product', {'id': world.burger}))['priceMinor'],
          900,
        );
        final decision = await FinanceDecisions.decide(
          world.owner.build(),
          world.command({
            'comparisonId': comparison['id'],
            'choice': 'keep',
            'reason': 'customer_sensitivity',
          }),
        );
        expect(decision['businessChanges'], false);
        expect((await read('pricing.decisions'))['rows'], hasLength(2));
        expect(
          (await read('pricing.decision', {
            'id': decision['id'],
          }))['comparison']['id'],
          comparison['id'],
        );
        await recipe(quantity: '400', version: 1);
        expect(
          (await read('pricing.comparison', {
            'id': comparison['id'],
          }))['invalidReason'],
          'stale',
        );
        await world.expectFailure(
          () => FinanceDecisions.decide(
            world.owner.build(),
            world.command({
              'comparisonId': comparison['id'],
              'choice': 'keep',
              'reason': 'timing',
            }),
          ),
          'stale',
        );
      },
    );

    test(
      'one-dish progress persists without accounting cutover or stock mutations',
      () async {
        final receipts = await StockMovement.db.count(builder.build());
        final first = await FinanceDecisions.checkpoint(
          world.owner.build(),
          world.command({'productId': world.burger}),
        );
        expect(first['ready'], true);
        expect(first['accountingCutoverRequired'], false);
        expect(first['alreadyCompleteAtStart'], true);
        expect(first['elapsedSetupSeconds'], 0);
        expect(
          (await read('costing.investigation', {
            'productId': world.burger,
          }))['startedAt'],
          first['startedAt'],
        );
        expect(await StockMovement.db.count(builder.build()), receipts);
        expect((await read('finance.policy'))['configured'], false);
      },
    );

    test(
      'decision recording is idempotent and anonymous readers cannot inspect comparisons',
      () async {
        final c = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        final command = world.command({
          'comparisonId': c['id'],
          'choice': 'defer',
          'reason': 'missing_evidence',
        });
        final first = await FinanceDecisions.decide(
          world.owner.build(),
          command,
        );
        expect(
          await FinanceDecisions.decide(world.owner.build(), command),
          first,
        );
        expect((await read('pricing.decisions'))['rows'], hasLength(1));
        await expectLater(
          LedgerModule.read(
            world.customer.build(),
            restaurantId: world.restaurant.id!,
            name: 'pricing.comparison',
            d: {'id': c['id']},
          ),
          throwsA(isA<DomainError>()),
        );
        final outcome = await read('pricing.decision.outcome', {
          'id': first['id'],
        });
        expect(outcome['observationStatus'], 'not_published');
        expect(outcome['before']['contributionMinor'], null);
        expect(outcome['orders'], isEmpty);
      },
    );

    test(
      'expired comparisons remain readable but cannot authorize publication',
      () async {
        final c = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        final row = (await FinanceRecord.db.findById(
          builder.build(),
          c['id'] as int,
        ))!;
        final data = jsonDecode(row.payloadJson) as Json;
        data['expiresAt'] = DateTime.now()
            .toUtc()
            .subtract(const Duration(minutes: 1))
            .toIso8601String();
        row.payloadJson = jsonEncode(data);
        await FinanceRecord.db.updateRow(builder.build(), row);
        expect(
          (await read('pricing.comparison', {'id': row.id}))['invalidReason'],
          'expired',
        );
        await world.expectFailure(
          () => Finance017.propose(
            world.owner.build(),
            world.command({'comparisonId': row.id, 'option': 'recommended'}),
          ),
          'expired',
        );
      },
    );

    test(
      'post-decision capture is a collection and not earned sales',
      () async {
        await activate();
        final c = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        final action = await Finance017.propose(
          world.owner.build(),
          world.command({'comparisonId': c['id'], 'option': 'recommended'}),
        );
        await AgentModule.decide(
          world.owner.build(),
          world.command(
            {'decision': 'approve'},
            id: action['actionId'],
            version: action['version'],
          ),
        );
        await world.sale(quantity: 1);
        final decision = (await read('pricing.decisions'))['rows'].single;
        final outcome = await read('pricing.decision.outcome', {
          'id': decision['id'],
        });
        expect(outcome['observationStatus'], 'partial_period');
        expect(outcome['after']['elapsedCompleteDays'], 0);
        expect(outcome['orders'], hasLength(1));
        final order = outcome['orders'].single;
        expect(order['newPriceUnits'], 1);
        expect(order['earnedAt'], null);
        expect(order['netRevenueMinor'], null);
        expect(order['captures'].single['state'], 'completed');
        expect(order['captures'].single['amountMinor'], 970);
        expect(outcome['after']['orders'], 0);
        expect(outcome['after']['contributionMinor'], null);
      },
    );

    test('comparison requires an explicit volume assumption', () async {
      await world.expectFailure(
        () => FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger}),
          revise: false,
        ),
        'invalid_input',
      );
    });

    test(
      'receipt, conversion and policy produce the lowest bounded price',
      () async {
        final p = await read('costing.product', {'id': world.burger});
        expect(p['complete'], true);
        expect(p['replacementCostMinor'], 385);
        expect((p['lines'] as List).single['source']['id'], isA<int>());
        final s = await scenario();
        expect(s['recommended']['priceMinor'], 970);
        expect(s['current']['priceMinor'], 900);
        expect(s['sensitivity'].length, 3);
      },
    );
    test(
      'missing confirmed cost remains unknown and prevents a recommendation',
      () async {
        await StockMovement.db.deleteWhere(
          builder.build(),
          where: (t) => t.stockItemId.equals(ingredient),
        );
        final p = await read('costing.product', {'id': world.burger});
        expect(p['replacementCostMinor'], null);
        expect(p['complete'], false);
        await world.expectFailure(scenario, 'incomplete_cost');
      },
    );
    test(
      'a legacy receipt unit is unknown until a manager explicitly reviews it',
      () async {
        final receipt = (await StockMovement.db.findFirstRow(
          builder.build(),
          where: (t) => t.stockItemId.equals(ingredient),
        ))!;
        receipt.purchaseUnit = null;
        await StockMovement.db.updateRow(builder.build(), receipt);
        expect(
          (await read('costing.product', {'id': world.burger}))['complete'],
          false,
        );
        await Finance017.confirmReceipt(
          world.owner.build(),
          world.command({
            'purchaseUnit': 'kg',
            'reviewed': true,
            'reason': 'Original fixture receipt explicitly states kilograms',
          }, id: receipt.id),
        );
        expect(
          (await read('costing.product', {
            'id': world.burger,
          }))['replacementCostMinor'],
          385,
        );
        expect(
          (await StockMovement.db.findById(
            builder.build(),
            receipt.id!,
          ))!.unitCostMinor,
          1100,
        );
      },
    );
    test(
      'a tracked stock unit and cost cannot silently reinterpret receipt history',
      () async {
        final item = (await StockItem.db.findById(
          builder.build(),
          ingredient,
        ))!;
        await world.expectFailure(
          () => BackOfficeModule.saveStock(
            world.owner.build(),
            world.command(
              {
                'name': item.name,
                'unit': 'g',
                'quantity': item.quantity,
                'costMinor': item.costMinor,
                'lowAt': item.lowAt,
              },
              id: item.id,
              version: item.version,
            ),
          ),
          'tracked_stock',
        );
        expect(
          (await read('costing.product', {
            'id': world.burger,
          }))['replacementCostMinor'],
          385,
        );
      },
    );
    test(
      'a saved scenario cannot bypass the action approval registry',
      () async {
        final s = await scenario();
        await world.expectFailure(
          () => Finance017.applyPrice(
            world.owner.build(),
            world.command({'scenarioId': s['id']}),
          ),
          'approval_required',
        );
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          900,
        );
      },
    );
    test(
      'an approved price executes once and leaves prior quotes governed by menu version',
      () async {
        final s = await scenario();
        final action = await Finance017.propose(
          world.owner.build(),
          world.command({'scenarioId': s['id']}),
        );
        final command = world.command(
          {'decision': 'approve'},
          id: action['actionId'],
          version: action['version'],
        );
        final first = await AgentModule.decide(world.owner.build(), command);
        final replay = await AgentModule.decide(world.owner.build(), command);
        expect(first['state'], 'executed');
        expect(replay, first);
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          970,
        );
        expect((await read('pricing.history'))['rows'].length, 1);
        final published = (await read('pricing.history'))['rows'].single;
        final restoration = await Finance017.restoreScenario(
          world.owner.build(),
          world.command({}, id: published['id']),
        );
        expect(restoration['kind'], 'price-restoration');
        expect(restoration['targetMet'], false);
        expect(restoration['recommended']['priceMinor'], 900);
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          970,
        );
        final restoredAction = await Finance017.propose(
          world.owner.build(),
          world.command({'scenarioId': restoration['id']}),
        );
        await AgentModule.decide(
          world.owner.build(),
          world.command(
            {'decision': 'approve'},
            id: restoredAction['actionId'],
            version: restoredAction['version'],
          ),
        );
        final history = (await read('pricing.history'))['rows'];
        expect(history.length, 2);
        expect(history.first['restoresHistoryId'], published['id']);
        expect(history.last['toMinor'], 970);
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          900,
        );
        await world.expectFailure(
          () => Finance017.restoreScenario(
            world.owner.build(),
            world.command({}, id: published['id']),
          ),
          'stale',
        );
      },
    );
    test(
      'a receipt change invalidates the proposal before execution',
      () async {
        final s = await scenario();
        final action = await Finance017.propose(
          world.owner.build(),
          world.command({'scenarioId': s['id']}),
        );
        await StockMovement.db.insertRow(
          builder.build(),
          StockMovement(
            restaurantId: world.restaurant.id!,
            stockItemId: ingredient,
            kind: 'receive',
            quantity: 1,
            unitCostMinor: 1200,
            purchaseUnit: 'kg',
            refType: 'fixture',
            refId: world.key(),
            at: DateTime.now().toUtc(),
          ),
        );
        final value = await read('pricing.scenario', {'id': s['id']});
        expect(value['validForPublication'], false);
        expect(value['publicationIssue'], 'stale');
        await world.expectFailure(
          () => AgentModule.decide(
            world.owner.build(),
            world.command(
              {'decision': 'approve'},
              id: action['actionId'],
              version: action['version'],
            ),
          ),
          'stale',
        );
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          900,
        );
      },
    );
    test('recipe edits preserve immutable historical revisions', () async {
      await recipe(quantity: '400', version: 1);
      final r = await FinanceRecord.db.findFirstRow(
        builder.build(),
        where: (t) =>
            t.restaurantId.equals(world.restaurant.id!) &
            t.kind.equals('recipeRevision') &
            t.recordKey.equals('${world.burger}:1'),
      );
      expect(
        jsonDecode(r!.payloadJson)['lines'][0]['quantityMicros'],
        350000000,
      );
      expect(
        (await read('costing.product', {
          'id': world.burger,
        }))['replacementCostMinor'],
        440,
      );
    });
    test(
      'recorded costs lock venue currency even with finance switched off',
      () async {
        Finance017.environment = () => {};
        final policy = (await RestaurantPolicy.db.findFirstRow(
          builder.build(),
          where: (t) => t.restaurantId.equals(world.restaurant.id!),
        ))!;
        await world.expectFailure(
          () => CatalogueModule.configure(
            world.owner.build(),
            world.command({
              'name': world.restaurant.name,
              'currency': 'EUR',
              'settings': <String, dynamic>{},
            }, version: policy.version),
          ),
          'currency_locked',
        );
      },
    );
    test('diners cannot read finance or change policy', () async {
      await world.expectFailure(
        () => LedgerModule.read(
          world.customer.build(),
          restaurantId: world.restaurant.id!,
          name: 'finance.payments',
        ),
        'forbidden',
      );
      await world.expectFailure(
        () => LedgerModule.read(
          world.customer.build(),
          restaurantId: world.restaurant.id!,
          name: 'costing.products',
        ),
        'forbidden',
      );
      await world.expectFailure(
        () => Finance017.savePolicy(
          world.customer.build(),
          world.command({'targetBps': 5000}, version: 1),
        ),
        'forbidden',
      );
    });
    test(
      'payment evidence reports item states without exposing recipient identity',
      () async {
        final now = DateTime.now().toUtc();
        final batch = await PayoutBatch.db.insertRow(
          builder.build(),
          PayoutBatch(
            restaurantId: world.restaurant.id!,
            kind: 'bill',
            periodFrom: now,
            periodTo: now,
            totalMinor: 1500,
            currency: 'USD',
            state: 'sent',
            providerBatchId: 'FIXTURE-BATCH',
            requestKey: world.key(),
            summaryJson: '{}',
            createdAt: now,
            updatedAt: now,
          ),
        );
        for (final state in ['completed', 'failed']) {
          await PayoutItem.db.insertRow(
            builder.build(),
            PayoutItem(
              restaurantId: world.restaurant.id!,
              batchId: batch.id!,
              recipientEmail: 'private@example.test',
              recipientName: 'Private recipient',
              shiftIdsJson: '[]',
              amountMinor: 750,
              note: 'Private note',
              providerItemId: 'FIXTURE-$state',
              state: state,
            ),
          );
        }
        final page = await read('finance.payments');
        final row = (page['rows'] as List).single as Json;
        expect(row['state'], 'sent');
        expect(row['totalMinor'], 1500);
        expect((row['items'] as List).map((i) => i['state']), [
          'completed',
          'failed',
        ]);
        expect(jsonEncode(page), isNot(contains('private@example.test')));
        expect(jsonEncode(page), isNot(contains('Private note')));
        expect(row['reviews'], isEmpty);
      },
    );
    test(
      'another venue product cannot become a recipe or scenario source',
      () async {
        final other = await Restaurant.db.insertRow(
          builder.build(),
          world.restaurant.copyWith(id: null, name: 'Other fixture'),
        );
        final product = (await MenuProduct.db.findById(
          builder.build(),
          world.burger,
        ))!.copyWith(id: null, restaurantId: other.id!);
        final foreign = await MenuProduct.db.insertRow(
          builder.build(),
          product,
        );
        await world.expectFailure(
          () => Finance017.createScenario(
            world.owner.build(),
            world.command({'productId': foreign.id}),
          ),
          'not_found',
        );
      },
    );
    test('cutover is explicit, balanced and immutable', () async {
      await world.expectFailure(
        () => FinanceAccounting.activate(
          world.owner.build(),
          world.command({
            'reviewed': true,
            'reason': 'Unbalanced fixture',
            'opening': [
              {'account': '1010', 'debitMinor': 100},
            ],
          }, version: 0),
        ),
        'unbalanced',
      );
      await activate();
      await world.expectFailure(activate, 'already_configured');
      final summary = await read('finance.summary');
      expect(summary['basis'], FinanceAccounting.basis);
      expect(summary['balanced'], true);
      final legacy = await read('finance.summary', {
        'basis': 'legacy-recorded-transactions',
      });
      expect(legacy['basis'], 'legacy-recorded-transactions');
      expect(legacy['operatingResultMinor'], null);
    });
    test(
      'foreign-currency financial evidence cannot enter a combined summary',
      () async {
        await activate();
        final row = (await FinanceRecord.db.findFirstRow(
          builder.build(),
          where: (t) =>
              t.restaurantId.equals(world.restaurant.id!) &
              t.kind.equals('financeFact'),
        ))!;
        row.payloadJson = jsonEncode({
          ...jsonDecode(row.payloadJson) as Json,
          'currency': 'EUR',
        });
        await FinanceRecord.db.updateRow(builder.build(), row);
        await world.expectFailure(
          () => read('finance.summary'),
          'currency_mismatch',
        );
      },
    );
    test(
      'prepayment is a deposit, then completion earns revenue and frozen stock cost once',
      () async {
        await activate();
        final checkout = await world.sale(quantity: 1, tipMinor: 100);
        await recipe(quantity: '400', version: 1);
        final before = await read('finance.summary');
        expect(before['netSalesMinor'], 0);
        expect(before['customerDepositsMovementMinor'], 900);
        final intent = (await CheckoutIntent.db.findById(
          builder.build(),
          checkout,
        ))!;
        // Use the production transition helper through a scoped agent transaction
        // to isolate the accounting and stock hook from kitchen checklist setup.
        await AgentModule.asAgent(builder.build(), world.restaurant.id!, (
          w,
        ) async {
          final order = (await PurchaseOrder.db.findById(
            w.s,
            intent.orderId!,
            transaction: w.tx,
          ))!;
          order.status = 'completed';
          await PurchaseOrder.db.updateRow(w.s, order, transaction: w.tx);
          await w.audit('order.completed', 'order', order.id);
          await w.audit('order.completed', 'order', order.id);
        });
        final after = await read('finance.summary');
        expect(after['netSalesMinor'], 900);
        expect(after['customerDepositsMovementMinor'], 0);
        expect(after['balanced'], true);
        final costs = await FinanceRecord.db.find(
          builder.build(),
          where: (t) =>
              t.restaurantId.equals(world.restaurant.id!) &
              t.kind.equals('orderCost'),
        );
        expect(costs.length, 1);
        expect(jsonDecode(costs.single.payloadJson)['knownCostMinor'], 385);
        expect(
          (await StockItem.db.findById(builder.build(), ingredient))!.quantity,
          closeTo(9.65, 0.000001),
        );
        final journal = await world.read('ledger.journal');
        final accounts = {for (final a in journal['totals']) a['account']: a};
        expect(accounts['4000']['creditMinor'], after['netSalesMinor']);
        expect(accounts['2200']['creditMinor'], 100);
        await StockMovement.db.insertRow(
          builder.build(),
          StockMovement(
            restaurantId: world.restaurant.id!,
            stockItemId: ingredient,
            kind: 'receive',
            quantity: 1,
            unitCostMinor: 1300,
            purchaseUnit: 'kg',
            refType: 'fixture',
            refId: world.key(),
            at: DateTime.now().toUtc(),
          ),
        );
        expect(
          (await read('costing.product', {
            'id': world.burger,
          }))['replacementCostMinor'],
          520,
        );
        expect(
          jsonDecode(
            (await FinanceRecord.db.findById(
              builder.build(),
              costs.single.id!,
            ))!.payloadJson,
          )['knownCostMinor'],
          385,
        );
      },
    );
    test(
      'a receipt, matched invoice and settlement acquire stock once',
      () async {
        await activate();
        final now = DateTime.now().toUtc();
        final order = await SupplierOrder.db.insertRow(
          builder.build(),
          SupplierOrder(
            restaurantId: world.restaurant.id!,
            state: 'sent',
            linesJson: jsonEncode([
              {
                'stockItemId': ingredient,
                'name': 'Ingredients',
                'unit': 'kg',
                'qty': 1,
                'unitCostMinor': 1100,
                'receivedQty': 0,
              },
            ]),
            totalMinor: 1100,
            currency: 'USD',
            createdBy: world.ownerId,
            version: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
        await PurchasingModule.receiveOrder(
          world.owner.build(),
          world.command(
            {
              'lines': [
                {'stockItemId': ingredient, 'qty': 1, 'unitCostMinor': 1100},
              ],
            },
            id: order.id,
            version: 1,
          ),
        );
        final supplier = await Supplier.db.insertRow(
          builder.build(),
          Supplier(
            restaurantId: world.restaurant.id!,
            name: 'Fixture supplier',
            payoutEmail: '',
            version: 1,
            createdAt: now,
          ),
        );
        final draft = await AgentModule.asAgent(
          builder.build(),
          world.restaurant.id!,
          (w) => PurchasingModule.supplierBill(
            w,
            supplierId: supplier.id!,
            supplierOrderId: order.id,
            amountMinor: 1210,
            currency: 'USD',
          ),
        );
        final bill = await BillsModule.save(
          world.owner.build(),
          world.command(
            {
              'vendor': 'Fixture supplier',
              'category': 'supplier',
              'amountMinor': 1210,
              'vatMinor': 110,
              'approve': true,
            },
            id: draft.id,
            version: draft.version,
          ),
        );
        final before = await read('finance.summary');
        expect(before['payablesMinor'], 1210);
        expect(before['recognizedCostsMinor'], 0);
        final proof = await world.file(
          'receipt',
          'fixture-paid-elsewhere-proof',
        );
        await BillsModule.markPaid(
          world.owner.build(),
          world.command(
            {
              'proofMediaId': proof,
              'note': 'Recorded external settlement proof',
            },
            id: bill['id'],
            version: bill['version'],
          ),
        );
        final after = await read('finance.summary');
        expect(after['payablesMinor'], 0);
        expect(after['recognizedCostsMinor'], 0);
        final journal = await world.read('ledger.journal');
        final accounts = {for (final a in journal['totals']) a['account']: a};
        expect(accounts['1200']['debitMinor'], 1100);
        expect(accounts['2050']['balanceMinor'], 0);
        expect(accounts['1000']?['balanceMinor'] ?? 0, 0);
        expect(accounts['1010']['balanceMinor'], -1210);
      },
    );
    test(
      'only completed payout items settle obligations, not a batch submission',
      () async {
        await activate();
        final now = DateTime.now().toUtc();
        final batch = await PayoutBatch.db.insertRow(
          builder.build(),
          PayoutBatch(
            restaurantId: world.restaurant.id!,
            kind: 'supplier',
            periodFrom: now,
            periodTo: now,
            totalMinor: 5000,
            currency: 'USD',
            state: 'sent',
            providerBatchId: 'TEST-BATCH',
            requestKey: world.key(),
            summaryJson: '{}',
            createdAt: now,
            updatedAt: now,
          ),
        );
        for (final part in [('completed', 3000), ('unclaimed', 2000)]) {
          await PayoutItem.db.insertRow(
            builder.build(),
            PayoutItem(
              restaurantId: world.restaurant.id!,
              batchId: batch.id!,
              recipientEmail: 'fixture@example.test',
              recipientName: 'Fixture supplier',
              shiftIdsJson: '[]',
              amountMinor: part.$2,
              note: 'Provider fixture only',
              state: part.$1,
            ),
          );
        }
        await AgentModule.asAgent(
          builder.build(),
          world.restaurant.id!,
          (w) => w.audit('payout.sent', 'payoutBatch', batch.id),
        );
        final summary = await read('finance.summary');
        expect(summary['recordedCashMovementMinor'], -3000);
        final facts = await FinanceRecord.db.find(
          builder.build(),
          where: (t) =>
              t.restaurantId.equals(world.restaurant.id!) &
              t.kind.equals('financeFact'),
        );
        expect(
          facts.where((f) => f.recordKey.startsWith('payoutItem:')).length,
          1,
        );
      },
    );
    test(
      'guided runs exclude another session and protect the fixture from reset',
      () async {
        Finance017.environment = () => {
          'RAYSTO_FINANCE_017_ENABLED': 'true',
          'RAYSTO_PRICING_ENABLED': 'true',
          'RAYSTO_JUDGE_STORY_017_ENABLED': 'true',
        };
        world.env['RAYSTO_JUDGE_RESTAURANT_ID'] = '${world.restaurant.id}';
        final now = DateTime.now().toUtc();
        await FinanceRecord.db.insertRow(
          builder.build(),
          FinanceRecord(
            restaurantId: world.restaurant.id!,
            kind: 'judgeStoryFixture',
            recordKey: 'current',
            payloadJson: jsonEncode({
              'productId': world.burger,
              'sample': true,
            }),
            createdBy: world.ownerId,
            version: 1,
            createdAt: now,
            updatedAt: now,
          ),
        );
        final run = await JudgeStory017.start(
          world.owner.build(),
          world.command({}),
        );
        expect(run['active'], true);
        expect(run['run']['runId'], isA<String>());
        final otherSession = world.session(
          world.ownerId,
          authId: 'another-review-session',
        );
        await world.expectFailure(
          () => JudgeStory017.start(otherSession.build(), world.command({})),
          'busy',
        );
        await world.expectFailure(
          () => AgentModule.asAgent(
            builder.build(),
            world.restaurant.id!,
            JudgeStory017.beforeReset,
          ),
          'busy',
        );
        final records = await FinanceRecord.db.find(
          builder.build(),
          where: (t) =>
              t.restaurantId.equals(world.restaurant.id!) &
              t.kind.equals('judgeRun'),
        );
        expect(records.length, 1);
        expect(
          await PaymentCapture.db.count(
            builder.build(),
            where: (t) => t.restaurantId.equals(world.restaurant.id!),
          ),
          0,
        );
      },
    );
  });
}
