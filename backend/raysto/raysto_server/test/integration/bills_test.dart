import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import '../fixtures/money_agents_fixture.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Bills the café owes: read by the accountant agent from a file, approved by
// a person, paid through PayPal Payouts or elsewhere with a proof. Isolated
// Raysto test database only; the model is scripted and PayPal is a fake.
void main() {
  withServerpod('Bills and the accountant agent', (builder, endpoints) {
    late AccountantWorld world;
    final now = DateTime.now().toUtc();
    String iso(Duration d) => now.add(d).toIso8601String();

    setUp(() async {
      world = AccountantWorld(builder, 'bills');
      await world.setUp();
    });
    tearDown(() => world.tearDown());

    /// The model: looks up the vendor, then proposes the bill as read.
    void readsAndProposes(String vendor, String category, int amount, {bool recurring = true}) {
      world.script = (turn, body) => turn == 1
          ? [
              {
                'functionCall': {
                  'name': 'read_bills',
                  'args': {'vendor': vendor},
                },
              },
            ]
          : [
              {
                'functionCall': {
                  'name': 'propose_bill',
                  'args': {
                    'category': category,
                    'amountMinor': amount,
                    'recurring': recurring,
                    'explanation':
                        '$vendor $category bill of ${amount / 100} USD; ${(toolResults(body)['read_bills']!['count'] as int)} earlier bill(s) on file.',
                  },
                },
              },
            ];
    }

    Future<AgentTask> snapAndRun(int mediaId) async {
      final snapped = await BillsModule.snap(world.owner.build(), world.command({'mediaId': mediaId}));
      expect(snapped['taskId'], isA<int>(), reason: jsonEncode(snapped));
      final s = builder.build();
      await AgentModule.run(s, snapped['taskId'] as int);
      final task = (await AgentTask.db.findById(s, snapped['taskId'] as int))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      return task;
    }

    Future<Json> decide(AgentAction action) => AgentModule.decide(
      world.owner.build(),
      PlatformCommand(
        requestKey: world.key(),
        restaurantId: world.restaurant.id,
        resourceId: action.id,
        expectedVersion: action.version,
        dataJson: '{"decision":"approve"}',
      ),
    );

    test('a bill read from a PDF waits in review, is paid through PayPal Payouts after the identity check, and leaves next month expected', () async {
      world.vision = {
        'vendor': 'Power Co',
        'category': 'electricity',
        'reference': 'INV-1001',
        'amountMinor': 19610,
        'vatMinor': 1610,
        'currency': 'USD',
        'issuedAt': iso(const Duration(days: -2)),
        'dueAt': iso(const Duration(days: 12)),
        'payeeEmail': 'billing@power.example',
        'recurring': true,
        'confidence': 0.94,
      };
      readsAndProposes('Power Co', 'electricity', 19610);
      final media = await world.file('bill', 'power-october');
      final task = await snapAndRun(media);
      expect(world.visionCalls, 1);
      expect(world.upstream.geminiTools.toSet(), {'read_bills', 'propose_bill'});
      final s = builder.build();
      final bill = (await Bill.db.findFirstRow(s, where: (t) => t.taskId.equals(task.id!)))!;
      expect(bill.state, 'review');
      expect(bill.vendor, 'Power Co');
      expect(bill.amountMinor, 19610);
      expect(bill.vatMinor, 1610);
      expect(bill.payVia, 'paypal');
      expect(bill.recurring, 'monthly');
      expect(bill.sourceMediaId, media);
      expect(jsonDecode(bill.readJson)['from'], 'ai');
      expect(jsonDecode(bill.readJson)['explanation'], contains('Power Co'));

      // The same file again is caught before any AI is spent.
      final again = await BillsModule.snap(world.owner.build(), world.command({'mediaId': media}));
      expect(again['duplicateOfId'], bill.id);
      expect(again['taskId'], isNull);
      expect(world.visionCalls, 1);

      final action = (await AgentAction.db.find(s, where: (t) => t.taskId.equals(task.id!))).single;
      expect(action.command, 'bill.pay');
      expect(action.risk, 'money');
      expect(jsonDecode(action.previewJson)['payeeEmail'], 'billing@power.example');
      final held = await decide(action);
      expect(held['needs'], 'reauthentication_required');
      expect(world.upstream.payouts, isEmpty);
      await world.stepUp();
      final done = await decide(action);
      expect(done['state'], 'executed', reason: jsonEncode(done));
      expect(world.upstream.payouts.length, 1);
      final sent = world.upstream.payouts.single['body'] as Map;
      final item = (sent['items'] as List).cast<Map>().single;
      expect(item['receiver'], 'billing@power.example');
      expect((item['amount'] as Map)['value'], '196.10');
      final paying = (await Bill.db.findById(s, bill.id!))!;
      expect(paying.state, 'paying');
      final batch = (await PayoutBatch.db.findById(s, paying.payoutBatchId!))!;
      expect(batch.kind, 'bill');
      expect(batch.state, 'sent');
      expect(batch.providerBatchId, 'BATCH-1');

      // Paying the same bill again asks PayPal for nothing more.
      final repeat = await BillsModule.pay(world.owner.build(), world.command({}, id: bill.id));
      expect(repeat['state'], 'paying');
      expect(world.upstream.payouts.length, 1);

      await PayrollAgent.poll(s, batch.id!, 0);
      final list = await world.read('bills');
      final rows = (list['rows'] as List).cast<Map>();
      final paid = rows.firstWhere((r) => r['id'] == bill.id);
      expect(paid['state'], 'paid');
      expect(paid['providerBatchId'], 'BATCH-1');
      expect(paid['payoutState'], 'completed');
      final expected = rows.firstWhere((r) => r['state'] == 'expected');
      expect(expected['vendor'], 'Power Co');
      expect(expected['recurringOfId'], bill.id);
      expect(DateTime.parse(expected['dueAt'] as String).isAfter(bill.dueAt!), isTrue);

      final j = await world.read('ledger.journal');
      expect(j['balanced'], isTrue);
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      expect(totals['6100']!['debitMinor'], 18000);
      expect(totals['2110']!['debitMinor'], 1610);
      expect(totals['2000']!['balanceMinor'], 0);
      expect(totals['1000']!['creditMinor'], greaterThanOrEqualTo(19610));
      final payoutLine = (j['rows'] as List).cast<Map>().firstWhere(
        (l) => (l['source'] as Map)['type'] == 'payout',
      );
      expect((payoutLine['source'] as Map)['providerId'], 'BATCH-1');
    });

    test('a vendor without a PayPal email is paid elsewhere, and only with a proof', () async {
      final rent = await world.bill({
        'vendor': 'Rent Ltd',
        'category': 'rent',
        'amountMinor': 180000,
        'issuedAt': iso(const Duration(days: -1)),
      }, approve: true);
      await world.stepUp();
      await world.expectFailure(
        () => BillsModule.pay(world.owner.build(), world.command({}, id: rent['id'] as int)),
        'payee_missing',
      );
      expect(world.upstream.payouts, isEmpty);
      await world.expectFailure(
        () => BillsModule.markPaid(world.owner.build(), world.command({}, id: rent['id'] as int)),
        'invalid_input',
      );
      final proof = await world.file('receipt', 'rent-transfer-proof');
      final paid = await BillsModule.markPaid(
        world.owner.build(),
        world.command({'proofMediaId': proof, 'note': 'Bank transfer'}, id: rent['id'] as int),
      );
      expect(paid['state'], 'paidElsewhere');
      expect(paid['proofMediaId'], proof);
      expect(paid['payVia'], 'elsewhere');
      final j = await world.read('ledger.journal');
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      expect(totals['6110']!['debitMinor'], 180000);
      expect(totals['2000']!['balanceMinor'], 0);
      expect(totals['1010']!['creditMinor'], 180000);
    });

    test('a likely duplicate is flagged and waits for a person to confirm', () async {
      final first = await world.bill({
        'vendor': 'City Water',
        'category': 'water',
        'reference': 'W-11',
        'amountMinor': 4200,
      }, approve: true);
      final second = await world.bill({
        'vendor': 'city water ',
        'category': 'water',
        'reference': 'W-11',
        'amountMinor': 4200,
      });
      expect(second['duplicateOfId'], first['id']);
      final findings = (await world.read('accountant.anomalies'))['rows'] as List;
      expect(
        findings.cast<Map>().any((f) => f['kind'] == 'duplicate_bill' && f['billId'] == second['id']),
        isTrue,
      );
      await world.expectFailure(
        () => BillsModule.approve(world.owner.build(), world.command({}, id: second['id'] as int)),
        'duplicate_bill',
      );
      final ok = await BillsModule.approve(
        world.owner.build(),
        world.command({'notDuplicate': true}, id: second['id'] as int),
      );
      expect(ok['state'], 'approved');
      expect(ok['duplicateOfId'], isNull);
      final voided = await BillsModule.voidBill(
        world.owner.build(),
        world.command({'reason': 'Entered twice'}, id: second['id'] as int),
      );
      expect(voided['state'], 'void');
    });

    test('within the owner\'s limit a monthly bill to a known payee is paid by the agent itself; above it, a person approves', () async {
      await world.patchSettings({
        'autonomy': {
          ...CatalogueModule.validateAutonomy({}),
          'billsMaxMinor': 30000,
          'billsPerDay': 3,
          'billsKnownPayeesOnly': true,
        },
      });
      // Last month's internet bill, paid through PayPal by a person.
      final last = await world.bill({
        'vendor': 'Fiber ISP',
        'category': 'internet',
        'amountMinor': 4990,
        'payeeEmail': 'billing@isp.example',
        'recurring': 'monthly',
        'issuedAt': iso(const Duration(days: -30)),
        'dueAt': iso(const Duration(days: -20)),
      }, approve: true);
      await world.stepUp();
      final claim = await BillsModule.pay(world.owner.build(), world.command({}, id: last['id'] as int));
      await PayrollAgent.poll(builder.build(), claim['batchId'] as int, 0);
      final before = (await world.read('bills'))['rows'] as List;
      expect(before.cast<Map>().firstWhere((r) => r['id'] == last['id'])['state'], 'paid');
      expect(before.cast<Map>().where((r) => r['state'] == 'expected').length, 1);

      // This month's arrives as a file and is paid within the limit.
      world.vision = {
        'vendor': 'Fiber ISP',
        'category': 'internet',
        'amountMinor': 4990,
        'currency': 'USD',
        'issuedAt': iso(Duration.zero),
        'dueAt': iso(const Duration(days: 10)),
        'payeeEmail': 'billing@isp.example',
        'recurring': true,
      };
      readsAndProposes('Fiber ISP', 'internet', 4990);
      final task = await snapAndRun(await world.file('bill', 'isp-november'));
      expect(task.summary, contains('within your limit'));
      expect(world.upstream.payouts.length, 2);
      final s = builder.build();
      final auto = (await AgentAction.db.find(s, where: (t) => t.taskId.equals(task.id!))).single;
      expect(auto.status, 'auto');
      expect(auto.command, 'bill.pay');
      final rows = ((await world.read('bills'))['rows'] as List).cast<Map>();
      final current = rows.firstWhere((r) => r['taskId'] == task.id);
      expect(current['state'], 'paying');
      expect(current['recurring'], 'monthly');
      // The expected copy was replaced by the real bill.
      expect(rows.where((r) => r['state'] == 'expected'), isEmpty);
      final audit = await AuditRecord.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(world.restaurant.id!) & t.kind.equals('agent.auto_executed'),
      );
      expect(audit, isNotNull);

      // A bill above the limit waits for a person, even to a known payee.
      world.upstream.turn = 0;
      world.vision = {...world.vision, 'amountMinor': 45000, 'reference': 'BIG-1'};
      readsAndProposes('Fiber ISP', 'internet', 45000);
      final big = await snapAndRun(await world.file('bill', 'isp-upgrade'));
      final action = (await AgentAction.db.find(s, where: (t) => t.taskId.equals(big.id!))).single;
      expect(action.status, isNot('auto'));
      expect(action.command, 'bill.pay');
      expect(world.upstream.payouts.length, 2);
    });

    test('the review explains only the findings the rules list, and proposes the fixes', () async {
      final late = await world.bill({
        'vendor': 'City Water',
        'category': 'water',
        'amountMinor': 4200,
        'payeeEmail': 'pay@water.example',
        'dueAt': iso(const Duration(days: -3)),
      }, approve: true);
      final anomalies = ((await world.read('accountant.anomalies'))['rows'] as List).cast<Map>();
      final overdue = anomalies.firstWhere((a) => a['kind'] == 'bill_overdue');
      expect(overdue['ref'], 'bill:${late['id']}');
      expect((overdue['fix'] as Map)['command'], 'bill.pay');

      world.script = (turn, body) => switch (turn) {
        1 => [
          {
            'functionCall': {'name': 'find_anomalies', 'args': {}},
          },
        ],
        2 => [
          {
            'functionCall': {
              'name': 'report',
              'args': {
                'summary': 'One bill is late.',
                'findings': [
                  {'ref': 'bill:999999', 'explanation': 'Invented.'},
                ],
              },
            },
          },
        ],
        _ => [
          {
            'functionCall': {
              'name': 'report',
              'args': {
                'summary': 'One bill is late: City Water, 42.00 USD.',
                'findings': [
                  {'ref': 'bill:${late['id']}', 'explanation': 'The water bill is three days late; pay it today to avoid a fee.'},
                ],
              },
            },
          },
        ],
      };
      final started = await AccountantAgent.runCommand(world.owner.build(), world.command({'mode': 'anomalies'}));
      final s = builder.build();
      await AgentModule.run(s, started['taskId'] as int);
      final task = (await AgentTask.db.findById(s, started['taskId'] as int))!;
      expect(task.status, 'done', reason: '${task.summary} ${task.stateJson}');
      expect(task.summary, contains('City Water'));
      final action = (await AgentAction.db.find(s, where: (t) => t.taskId.equals(task.id!))).single;
      expect(action.command, 'bill.pay');
      expect(action.rationale, contains('three days late'));
      expect(jsonDecode(action.payloadJson), {'billId': late['id']});
    });
  });
}
