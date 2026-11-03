import 'dart:convert';
import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. A seeded case stands in for a Sandbox
// dispute; Gemini is a fixture. Nothing reaches PayPal.
void main() {
  withServerpod('The disputes coworker', (builder, endpoints) {
    late MoneyAgentsFixture f;

    setUp(() async {
      f = MoneyAgentsFixture(builder, 'disputes');
      await f.setUp(agents: {'disputes'});
      // The fixture café is the judges' café, so it may seed a dispute.
      ProviderClients.environment = () => {
        ...Platform.environment,
        'GEMINI_API_KEY': 'fixture-key',
        'RAYSTO_JUDGE_RESTAURANT_ID': '${f.restaurant.id}',
      };
    });
    tearDown(() => f.tearDown());

    test('a seeded dispute gets an evidence pack and a reply, and is never sent to PayPal', () async {
      final s = builder.build();
      await f.paidOrder();
      final seeded = await DisputeAgent.seed(f.owner.build(), f.command({}));
      final caseId = seeded['caseId'] as int;
      final task = (await AgentTask.db.findById(s, seeded['taskId'] as int))!;
      expect(task.agent, 'disputes');
      final prompts = <String>[];
      f.scriptGemini([
        [
          {'name': 'read_dispute', 'args': {}},
        ],
        [
          {
            'name': 'propose_response',
            'args': {
              'accept': false,
              'replyText':
                  'The order was accepted, prepared and collected with its pickup code. The amount matches the ticket. We contest the claim.',
              'evidence': ['Ticket #1 accepted', 'Pickup code issued', 'Paid 9.00 USD'],
            },
          },
        ],
      ], prompts: prompts);
      await AgentModule.run(s, task.id!);
      final done = (await AgentTask.db.findById(s, task.id!))!;
      expect(done.status, 'done', reason: '${done.summary} ${done.stateJson}');
      expect(await f.actionsOf(task.id!), isEmpty, reason: 'contesting needs no PayPal action');
      final c = (await DisputeCase.db.findById(s, caseId))!;
      expect(c.status, 'seeded');
      expect(c.replyText, contains('contest'));
      final evidence = jsonDecode(c.evidenceJson) as Map;
      expect(evidence['items'], hasLength(3));
      expect(evidence['accept'], false);
      expect(evidence['paypalSource'], 'seeded');
      // The agent saw the café's own order facts, not only the claim.
      final toolResponse = prompts.last;
      expect(toolResponse, contains('pickupCode'));

      final rows = (await BackOfficeModule.read(
        f.owner.build(),
        restaurantId: f.restaurant.id!,
        name: 'disputes',
      ))['rows'] as List;
      expect((rows.single as Map)['providerDisputeId'], startsWith('SEEDED-'));

      // Accepting a seeded case is refused at preparation and at execution.
      await expectLater(
        AgentModule.asAgent(
          s,
          f.restaurant.id!,
          (w) => AgentModule.commands['dispute.accept']!.prepare(w, {'caseId': caseId}),
        ),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_transition')),
      );
      await f.grantStepUp();
      await expectLater(
        DisputeAgent.accept(f.owner.build(), f.command({}, id: caseId)),
        throwsA(isA<DomainError>().having((e) => e.code, 'code', 'invalid_transition')),
      );
      // Seeding again returns the same open case.
      final again = await DisputeAgent.seed(f.owner.build(), f.command({}));
      expect(again['caseId'], caseId);
    });

    test('when the café is in the wrong, accepting the claim is proposed as a money action', () async {
      final s = builder.build();
      final seeded = await DisputeAgent.seed(f.owner.build(), f.command({}));
      final task = (await AgentTask.db.findById(s, seeded['taskId'] as int))!;
      f.scriptGemini([
        [
          {'name': 'read_dispute', 'args': {}},
        ],
        [
          {
            'name': 'propose_response',
            'args': {
              'accept': true,
              'replyText': 'No order matches this payment; we accept the claim.',
              'evidence': ['No matching ticket'],
            },
          },
        ],
      ]);
      await AgentModule.run(s, task.id!);
      final done = (await AgentTask.db.findById(s, task.id!))!;
      expect(done.status, 'done', reason: '${done.summary} ${done.stateJson}');
      // The draft is prepared, but a seeded case refuses it, so the action is
      // skipped and recorded in the trace rather than offered to a manager.
      expect(await f.actionsOf(task.id!), isEmpty);
      final trace = jsonDecode(done.traceJson) as List;
      expect(trace.any((t) => t is Map && t['skipped'] == 'dispute.accept'), isTrue);
    });

    test('a dispute webhook for an unknown capture is ignored; a known one is recorded', () async {
      final s = builder.build();
      await DisputeAgent.onWebhook(s, {
        'dispute_id': 'PP-D-UNKNOWN',
        'reason': 'UNAUTHORISED',
        'status': 'OPEN',
        'dispute_amount': {'currency_code': 'USD', 'value': '9.00'},
        'disputed_transactions': [
          {'seller_transaction_id': 'NO-SUCH-CAPTURE'},
        ],
      });
      expect(await DisputeCase.db.count(s), 0);
      final orderId = await f.paidOrder();
      final checkout = (await CheckoutIntent.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(orderId),
      ))!;
      final capture = (await PaymentCapture.db.findFirstRow(
        s,
        where: (t) => t.checkoutId.equals(checkout.id!),
      ))!;
      await DisputeAgent.onWebhook(s, {
        'dispute_id': 'PP-D-KNOWN',
        'reason': 'MERCHANDISE_OR_SERVICE_NOT_RECEIVED',
        'status': 'OPEN',
        'dispute_amount': {'currency_code': 'USD', 'value': '9.00'},
        'disputed_transactions': [
          {'seller_transaction_id': capture.providerCaptureId},
        ],
      });
      final row = (await DisputeCase.db.findFirstRow(
        s,
        where: (t) => t.providerDisputeId.equals('PP-D-KNOWN'),
      ))!;
      expect(row.restaurantId, f.restaurant.id);
      expect(row.captureId, capture.id);
      expect(row.amountMinor, 900);
      expect(row.taskId, isNotNull);
    });
  });
}
