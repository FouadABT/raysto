import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Gemini is a fixture; the refund path is
// the real one up to the queued provider job.
void main() {
  withServerpod('The complaints coworker', (builder, endpoints) {
    late MoneyAgentsFixture f;

    setUp(() async {
      f = MoneyAgentsFixture(builder, 'complaints');
      await f.setUp(agents: {'complaints'});
    });
    tearDown(() => f.tearDown());

    Future<(int, AgentTask)> complain(String text) async {
      final s = builder.build();
      final orderId = await f.paidOrder();
      final opened = await BackOfficeModule.openComplaint(
        f.customer.build(),
        f.command({'text': text}, id: orderId),
      );
      final complaintId = opened['complaintId'] as int;
      final task = await AgentTask.db.findFirstRow(
        s,
        where: (t) => t.dedupeKey.equals('complaint:$complaintId'),
      );
      expect(task, isNotNull, reason: 'the complaint wakes the agent');
      return (complaintId, task!);
    }

    test('a cold burger becomes a partial refund proposal with the capture and amount', () async {
      final s = builder.build();
      final (complaintId, task) = await complain('My burger was cold.');
      final prompts = <String>[];
      f.scriptGemini([
        [
          {'name': 'read_complaint', 'args': {}},
          {'name': 'read_payment', 'args': {}},
        ],
        [
          {
            'name': 'propose_remedy',
            'args': {
              'kind': 'partial',
              'amountMinor': 450,
              'rationale': 'The burger was served cold; half its price back.',
            },
          },
        ],
      ], prompts: prompts);
      await AgentModule.run(s, task.id!);
      final done = (await AgentTask.db.findById(s, task.id!))!;
      expect(done.status, 'done', reason: '${done.summary} ${done.stateJson}');
      final actions = await f.actionsOf(task.id!);
      expect(actions, hasLength(1));
      final a = actions.single;
      expect(a.command, 'payment.refund');
      expect(a.status, 'pending');
      final payload = jsonDecode(a.payloadJson) as Map;
      final complaint = (await Complaint.db.findById(s, complaintId))!;
      expect(payload['captureId'], complaint.captureId);
      expect(payload['amountMinor'], 450);
      expect(payload['orderId'], complaint.orderId);
      expect(complaint.status, 'proposed');
      expect(prompts.first, isNot(contains('you reported')));
      final rows = (await BackOfficeModule.read(
        f.owner.build(),
        restaurantId: f.restaurant.id!,
        name: 'complaints',
      ))['rows'] as List;
      final row = rows.firstWhere((r) => r['id'] == complaintId) as Map;
      expect(row['status'], 'proposed');
      expect((row['proposal'] as Map)['amountMinor'], 450);
      expect((row['proposal'] as Map)['kind'], 'partial');

      // Rejected by the manager: the complaint reads as declined.
      await f.decide(a, decision: 'reject');
      final again = (await BackOfficeModule.read(
        f.owner.build(),
        restaurantId: f.restaurant.id!,
        name: 'complaints',
      ))['rows'] as List;
      expect((again.firstWhere((r) => r['id'] == complaintId) as Map)['status'], 'declined');
    });

    test('inside the owner\'s limit the agent refunds by itself and says so', () async {
      final s = builder.build();
      await f.patchSettings({
        'autonomy': {'refundsMaxMinor': 500, 'refundsPerDay': 1, 'remindersAuto': false},
      });
      final (complaintId, task) = await complain('The fries were missing.');
      f.scriptGemini([
        [
          {'name': 'read_complaint', 'args': {}},
          {'name': 'read_payment', 'args': {}},
        ],
        [
          {
            'name': 'propose_remedy',
            'args': {
              'kind': 'partial',
              'amountMinor': 300,
              'rationale': 'The fries were not made; their price back.',
            },
          },
        ],
      ]);
      await AgentModule.run(s, task.id!);
      final done = (await AgentTask.db.findById(s, task.id!))!;
      expect(done.status, 'done', reason: '${done.summary} ${done.stateJson}');
      expect(done.summary, contains('within your limit'));
      final actions = await f.actionsOf(task.id!);
      expect(actions, hasLength(1));
      expect(actions.single.status, 'auto');
      expect(actions.single.executionKey, 'complaint:$complaintId');
      final refund = await PaymentRefund.db.findFirstRow(
        s,
        where: (t) => t.requestKey.equals('complaint:$complaintId'),
      );
      expect(refund, isNotNull);
      expect(refund!.amountMinor, 300);
      final complaint = (await Complaint.db.findById(s, complaintId))!;
      expect(complaint.status, 'refunded');
      expect(complaint.refundId, refund.id);
      final audit = await AuditRecord.db.findFirstRow(
        s,
        where: (t) => t.kind.equals('agent.auto_executed') & t.entityId.equals(complaintId),
      );
      expect(audit, isNotNull);

      // The daily allowance is spent: the next one waits for a manager.
      final (_, second) = await complain('Cold again.');
      f.scriptGemini([
        [
          {'name': 'read_complaint', 'args': {}},
          {'name': 'read_payment', 'args': {}},
        ],
        [
          {
            'name': 'propose_remedy',
            'args': {'kind': 'partial', 'amountMinor': 200, 'rationale': 'Cold.'},
          },
        ],
      ]);
      await AgentModule.run(s, second.id!);
      final waiting = await f.actionsOf(second.id!);
      expect(waiting.single.status, 'pending');
    });

    test('a complaint the agent finds baseless is declined without a proposal', () async {
      final s = builder.build();
      final (complaintId, task) = await complain('I want a free meal next time.');
      f.scriptGemini([
        [
          {'name': 'read_complaint', 'args': {}},
          {'name': 'read_payment', 'args': {}},
        ],
        [
          {
            'name': 'propose_remedy',
            'args': {'kind': 'none', 'rationale': 'Nothing about this order went wrong.'},
          },
        ],
      ]);
      await AgentModule.run(s, task.id!);
      expect(await f.actionsOf(task.id!), isEmpty);
      expect((await Complaint.db.findById(s, complaintId))!.status, 'declined');
    });
  });
}
