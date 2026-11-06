@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Scripted provider responses verify tool boundaries; these are not model
// success-rate or live Gemini latency measurements.
void main() {
  withServerpod('Bounded financial investigation', (builder, endpoints) {
    late AccountantWorld world;
    Json call(String tool, [Json args = const {}]) => {
      'functionCall': {'name': tool, 'args': args},
    };
    setUp(() async {
      world = AccountantWorld(builder, 'financeAI');
      await world.setUp(settings: {'taxBps': 0});
      Finance017.environment = () => {
        'RAYSTO_FINANCE_017_ENABLED': 'true',
        'RAYSTO_PRICING_ENABLED': 'true',
        'RAYSTO_STUDIO_AI_ENABLED': 'true',
      };
      AgentModule.environment = () => {
        ...Platform.environment,
        'RAYSTO_AGENT_PRICING_ENABLED': 'true',
      };
      final stock =
          (await BackOfficeModule.saveStock(
                world.owner.build(),
                world.command({
                  'name': 'Prepared ingredients',
                  'unit': 'kg',
                  'quantity': 5,
                  'costMinor': 1100,
                  'lowAt': 1,
                }),
              ))['stockId']
              as int;
      await StockMovement.db.insertRow(
        builder.build(),
        StockMovement(
          restaurantId: world.restaurant.id!,
          stockItemId: stock,
          kind: 'receive',
          quantity: 5,
          unitCostMinor: 1100,
          purchaseUnit: 'kg',
          refType: 'fixture',
          refId: world.key(),
          at: DateTime.now().toUtc(),
        ),
      );
      await Finance017.saveRecipe(
        world.owner.build(),
        world.command({
          'productId': world.burger,
          'lines': [
            {
              'stockItemId': stock,
              'quantity': '350',
              'unit': 'g',
              'yieldBps': 10000,
              'packSize': '1',
            },
          ],
          'packagingMinor': 0,
          'packagingConfirmed': true,
        }, version: 0),
      );
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
    Future<Json> start({bool studio = false}) => Finance017.investigate(
      world.owner.build(),
      world.command({
        'text':
            'Investigate the recorded cost and prepare a price scenario for my review.',
        'productId': world.burger,
      }),
      studio: studio,
    );
    test(
      'model tools calculate on the server and leave only a pending price proposal',
      () async {
        world.script = (turn, _) => switch (turn) {
          1 => [call('read_costing')],
          2 => [
            call('calculate_scenario', {
              'baselineUnits': 100,
              'volumeChangeBps': -1000,
            }),
          ],
          3 => [call('prepare_price_proposal')],
          _ => [
            call('report', {
              'summary':
                  'The scenario price is 9.70 USD. Volume response is assumed, not predicted.',
              'view': 'scenario',
            }),
          ],
        };
        final started = await start();
        await AgentModule.run(builder.build(), started['taskId'] as int);
        final task = (await AgentTask.db.findById(
          builder.build(),
          started['taskId'] as int,
        ))!;
        expect(
          task.status,
          'done',
          reason: '${task.summary} ${task.stateJson}',
        );
        expect(task.feature, 'agents');
        final actions = await AgentAction.db.find(
          builder.build(),
          where: (t) => t.taskId.equals(task.id!),
        );
        expect(actions.single.command, 'menu.price.apply');
        expect(actions.single.status, 'pending');
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          900,
        );
        final analysis = await world.read('finance.analysis', {'id': task.id});
        expect(analysis['source'], 'gemini');
        expect(analysis['scenario']['recommended']['priceMinor'], 970);
        expect(
          jsonDecode(actions.single.evidenceJson)['productId'],
          world.burger,
        );
      },
    );
    test('evidenced final text retains the calculated comparison', () async {
      final original = await FinanceDecisions.save(
        world.owner.build(),
        world.command({'productId': world.burger, 'baselineUnits': 100}),
        revise: false,
      );
      world.script = (turn, _) => turn == 1
          ? [
              call('calculate_comparison', {'maxIncreaseBps': 500}),
            ]
          : [
              {
                'text':
                    'At 9.00 USD the contribution is 5.15 USD. The narrower cap cannot meet the target.',
              },
            ];
      final started = await Finance017.investigate(
        world.owner.build(),
        world.command({
          'text': 'Use a five percent cap.',
          'productId': world.burger,
          'comparisonId': original['id'],
        }),
        studio: true,
      );
      await AgentModule.run(builder.build(), started['taskId'] as int);
      final analysis = await world.read('finance.analysis', {
        'id': started['taskId'],
      });
      expect(analysis['source'], 'gemini');
      expect(analysis['reportDelivery'], 'validated-final-text');
      expect(analysis['comparison']['parentId'], original['id']);
      expect(analysis['comparison']['feasible'], false);
      expect(analysis['proposalsPrepared'], 0);
      expect(
        (await MenuProduct.db.findById(
          builder.build(),
          world.burger,
        ))!.priceMinor,
        900,
      );
    });
    for (final mode in ['unsupported-amount', 'no-evidence', 'oversized']) {
      test('final text cannot bypass report validation: $mode', () async {
        world.script = (turn, _) => turn == 1 && mode != 'no-evidence'
            ? [call('read_costing')]
            : [
                {
                  'text': mode == 'oversized'
                      ? List.filled(1201, 'a').join()
                      : 'The cost is 9999.99 USD.',
                },
              ];
        final started = await start(studio: true);
        await AgentModule.run(builder.build(), started['taskId'] as int);
        final analysis = await world.read('finance.analysis', {
          'id': started['taskId'],
        });
        expect(analysis['source'], 'deterministic-fallback');
        expect(
          await AgentAction.db.count(
            builder.build(),
            where: (t) => t.taskId.equals(started['taskId'] as int),
          ),
          0,
        );
      });
    }
    test('Studio work uses the existing chat allowance', () async {
      final started = await start(studio: true);
      expect(
        (await AgentTask.db.findById(
          builder.build(),
          started['taskId'] as int,
        ))!.feature,
        'chat',
      );
    });
    test(
      'typed challenges revise evidence and configure the view without publishing',
      () async {
        final c = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        world.script = (turn, _) => switch (turn) {
          1 => [call('read_comparison')],
          2 => [
            call('calculate_comparison', {
              'maxIncreaseBps': 500,
              'volumeChangeBps': -1000,
            }),
          ],
          3 => [
            call('configure_view', {
              'arrangement': 'side-by-side',
              'columns': ['name', 'cost', 'contribution'],
              'completeness': 'all',
              'sort': 'contribution',
              'widgets': ['comparison', 'evidence'],
            }),
          ],
          _ => [
            call('report', {
              'summary':
                  'The lower limit does not reach the target. Compare the recorded evidence before deciding.',
              'view': 'scenario',
            }),
          ],
        };
        final task = await Finance017.investigate(
          world.owner.build(),
          world.command({
            'text':
                'Limit this comparison to five percent and put its evidence beside it.',
            'productId': world.burger,
            'comparisonId': c['id'],
          }),
          studio: true,
        );
        await AgentModule.run(builder.build(), task['taskId'] as int);
        final result = await world.read('finance.analysis', {
          'id': task['taskId'],
        });
        expect(result['source'], 'gemini');
        expect(result['comparison']['parentId'], c['id']);
        expect(result['comparison']['feasible'], false);
        expect(result['presentation']['columns'], [
          'name',
          'cost',
          'contribution',
        ]);
        expect(
          (await MenuProduct.db.findById(
            builder.build(),
            world.burger,
          ))!.priceMinor,
          900,
        );
        expect(
          await AgentAction.db.count(
            builder.build(),
            where: (t) => t.taskId.equals(task['taskId'] as int),
          ),
          0,
        );
      },
    );
    test(
      'AI proposal retains the selected comparison and requesting person',
      () async {
        final c = await FinanceDecisions.save(
          world.owner.build(),
          world.command({'productId': world.burger, 'baselineUnits': 100}),
          revise: false,
        );
        world.script = (turn, _) => turn == 1
            ? [call('read_comparison')]
            : turn == 2
            ? [call('prepare_price_proposal')]
            : [
                call('report', {
                  'summary': 'A price proposal is ready for manual review.',
                  'view': 'scenario',
                }),
              ];
        final task = await Finance017.investigate(
          world.owner.build(),
          world.command({
            'text': 'Prepare this recommendation for review.',
            'productId': world.burger,
            'comparisonId': c['id'],
          }),
          studio: true,
        );
        await AgentModule.run(builder.build(), task['taskId'] as int);
        final decisions =
            (await world.read('pricing.decisions'))['rows'] as List;
        expect(decisions, hasLength(1));
        expect(decisions.single['comparisonId'], c['id']);
        expect(decisions.single['actor'], world.ownerId);
        expect(
          (await world.read('pricing.decision', {
            'id': decisions.single['id'],
          }))['approval']['status'],
          'pending',
        );
      },
    );
    test(
      'unsupported amounts fail safely and leave deterministic evidence access',
      () async {
        world.script = (turn, _) => turn == 1
            ? [call('read_costing')]
            : [
                call('report', {
                  'summary': 'The cost is 9999.99 USD.',
                  'view': 'costing',
                }),
              ];
        final started = await start();
        await AgentModule.run(builder.build(), started['taskId'] as int);
        final task = (await AgentTask.db.findById(
          builder.build(),
          started['taskId'] as int,
        ))!;
        expect(task.status, 'failed');
        final fallback = await world.read('finance.analysis', {'id': task.id});
        expect(fallback['source'], 'deterministic-fallback');
        expect(fallback['businessChanges'], false);
        expect(
          await AgentAction.db.count(
            builder.build(),
            where: (t) => t.taskId.equals(task.id!),
          ),
          0,
        );
      },
    );
    test(
      'role revocation is rechecked before any tool result is returned',
      () async {
        world.script = (_, _) => [call('read_costing')];
        final started = await start();
        final member = (await Membership.db.findFirstRow(
          builder.build(),
          where: (t) =>
              t.restaurantId.equals(world.restaurant.id!) &
              t.userId.equals(world.ownerId),
        ))!;
        member.active = false;
        await Membership.db.updateRow(builder.build(), member);
        await AgentModule.run(builder.build(), started['taskId'] as int);
        expect(
          (await AgentTask.db.findById(
            builder.build(),
            started['taskId'] as int,
          ))!.status,
          'failed',
        );
        expect(
          await FinanceRecord.db.count(
            builder.build(),
            where: (t) =>
                t.restaurantId.equals(world.restaurant.id!) &
                t.kind.equals('analysis'),
          ),
          0,
        );
      },
    );
  });
}
