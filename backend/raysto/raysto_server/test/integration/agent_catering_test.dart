import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'money_agents_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Isolated Raysto test database only. Gemini and PayPal's MCP server are
// fixtures: the quote, the invoice steps and the paid order are what is tested.
void main() {
  withServerpod('The catering coworker', (builder, endpoints) {
    late MoneyAgentsFixture f;

    setUp(() async {
      f = MoneyAgentsFixture(builder, 'catering');
      await f.setUp(agents: {'catering'});
    });
    tearDown(() => f.tearDown());

    test(
      'a request becomes a quote, the owner sends the invoice through PayPal MCP, and payment places the order',
      () async {
        final s = builder.build();
        final requested = await BackOfficeModule.requestCatering(
          f.owner.build(),
          f.command({
            'customerEmail': 'events@example.test',
            'customerName': 'Northside Office',
            'text': 'Twelve burgers for a team lunch on Friday, delivered.',
            'eventAt': DateTime.now()
                .toUtc()
                .add(const Duration(days: 10))
                .toIso8601String(),
          }),
        );
        final requestId = requested['cateringId'] as int;
        final task = await AgentTask.db.findFirstRow(
          s,
          where: (t) => t.dedupeKey.equals('catering:$requestId'),
        );
        expect(task, isNotNull, reason: 'the request wakes the agent');

        f.scriptGemini([
          [
            {'name': 'read_request', 'args': {}},
            {
              'name': 'read_menu',
              'args': {'search': ''},
            },
          ],
          [
            {
              'name': 'propose_quote',
              'args': {
                'lines': [
                  {'productId': f.burger, 'quantity': 12},
                ],
                'extras': [
                  {'name': 'Delivery', 'unitMinor': 1500, 'quantity': 1},
                ],
                'depositBps': 3000,
                'dueDays': 7,
                'note': 'Twelve burgers delivered for your Friday lunch.',
              },
            },
          ],
        ]);
        await AgentModule.run(s, task!.id!);
        final done = (await AgentTask.db.findById(s, task.id!))!;
        expect(done.status, 'done', reason: '${done.summary} ${done.stateJson}');
        final request = (await CateringRequest.db.findById(s, requestId))!;
        expect(request.status, 'quoted');
        expect(request.totalMinor, 12 * 900 + 1500);
        expect(request.depositMinor, 3690);
        final actions = await f.actionsOf(task.id!);
        expect(actions, hasLength(1));
        expect(actions.single.command, 'invoice.send');
        expect(actions.single.risk, 'money');
        expect(jsonDecode(actions.single.previewJson), containsPair('totalMinor', 12300));

        // Sending needs the identity check, then PayPal's MCP server creates,
        // sends and tries the QR code.
        f.useMcpFixture();
        final refused = await f.decide(actions.single);
        expect(refused['needs'], 'reauthentication_required');
        await f.grantStepUp();
        final sent = await f.decide(actions.single);
        expect(sent['state'], 'executed', reason: '$sent');
        expect((sent['result'] as Map)['providerInvoiceId'], 'INV2-FIXTURE');
        final after = (await CateringRequest.db.findById(s, requestId))!;
        expect(after.status, 'sent');
        expect(after.providerInvoiceId, 'INV2-FIXTURE');
        final audit = await AuditRecord.db.findFirstRow(
          s,
          where: (t) => t.kind.equals('invoice.sent') & t.entityId.equals(requestId),
        );
        expect(audit, isNotNull);
        final view = await BackOfficeModule.read(
          f.owner.build(),
          restaurantId: f.restaurant.id!,
          name: 'catering.request',
          d: {'id': requestId},
        );
        expect(view['status'], 'sent');
        expect((view['quote'] as Map)['lines'], hasLength(1));

        // PayPal reports it paid: the order is in the kitchen for the event.
        await CateringAgent.onInvoicePaid(s, {'id': 'INV2-FIXTURE'});
        final paid = (await CateringRequest.db.findById(s, requestId))!;
        expect(paid.status, 'paid');
        expect(paid.orderId, isNotNull);
        final order = (await PurchaseOrder.db.findById(s, paid.orderId!))!;
        expect(order.status, 'accepted');
        expect(order.paymentStatus, 'paid');
        expect(order.totalMinor, 12300);
        expect(order.lines.first.quantity, 12);
        final ctx = (await OrderContext.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(order.id!),
        ))!;
        expect(ctx.origin, 'catering');
        expect(ctx.pickupCode, isNotNull);
        // A second webhook for the same invoice changes nothing.
        await CateringAgent.onInvoicePaid(s, {'id': 'INV2-FIXTURE'});
        expect(
          await PurchaseOrder.db.count(
            s,
            where: (t) => t.requestKey.equals('catering:$requestId'),
          ),
          1,
        );
      },
    );

    test('a reminder is sent for an unpaid invoice; sending twice is refused', () async {
      final s = builder.build();
      final requested = await BackOfficeModule.requestCatering(
        f.owner.build(),
        f.command({
          'customerEmail': 'late@example.test',
          'text': 'Coffee for twenty.',
        }),
      );
      final id = requested['cateringId'] as int;
      final r = (await CateringRequest.db.findById(s, id))!;
      r
        ..status = 'sent'
        ..providerInvoiceId = 'INV2-LATE'
        ..dueAt = DateTime.now().toUtc().subtract(const Duration(days: 2));
      await CateringRequest.db.updateRow(s, r);
      f.useMcpFixture();
      final reminded = await CateringAgent.remind(
        f.owner.build(),
        f.command({}, id: id),
      );
      expect(reminded['reminded'], true);
      expect((await CateringRequest.db.findById(s, id))!.remindedAt, isNotNull);
      await expectLater(
        CateringAgent.send(f.owner.build(), f.command({}, id: id)),
        throwsA(
          isA<DomainError>().having(
            (e) => e.code,
            'code',
            'reauthentication_required',
          ),
        ),
      );
      await f.grantStepUp();
      final again = await CateringAgent.send(f.owner.build(), f.command({}, id: id));
      expect(again['status'], 'sent', reason: 'an already sent invoice is returned, not sent again');
    });
  });
}
