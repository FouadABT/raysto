import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// Money the café is owed: a pay link that opens a PayPal Orders v2 checkout,
// and a PayPal invoice when Invoicing is enabled. Isolated Raysto test
// database only; PayPal is a fake and no email is sent.
void main() {
  withServerpod('Payment requests', (builder, endpoints) {
    late AccountantWorld world;
    setUp(() async {
      world = AccountantWorld(builder, 'payreq');
      await world.setUp();
    });
    tearDown(() => world.tearDown());

    Future<Json> request({String kind = 'link', String? email, int amount = 12000, Duration? due}) =>
        PaymentRequestModule.create(
          world.owner.build(),
          world.command({
            'kind': kind,
            'payerName': 'Acme Offices',
            'payerEmail': ?email,
            'description': 'Team lunch, 12 people',
            'amountMinor': amount,
            if (due != null) 'dueAt': DateTime.now().toUtc().add(due).toIso8601String(),
          }),
        );

    String tokenOf(Json r) => Uri.parse(r['payUrl'] as String).pathSegments.last;

    test('a pay link opens one PayPal checkout for the exact amount, and its capture pays the request and the books', () async {
      final r = await request(email: 'office@acme.example');
      expect(r['state'], 'open');
      expect(r['payUrl'], startsWith('https://api.example.test/pay/'));
      final token = tokenOf(r);
      expect(token, matches(RegExp(r'^[a-f0-9]{32}$')));
      // The same link again shows the same token: it is derived, not stored.
      final listed = ((await world.read('requests'))['rows'] as List).cast<Map>().single;
      expect(listed['payUrl'], r['payUrl']);

      final s = builder.build();
      final opened = await PaymentRequestModule.open(s, token);
      expect(opened.status, 302);
      expect(opened.redirect, startsWith('https://www.sandbox.paypal.com/'));
      expect(world.upstream.amountMinor, 12000);
      expect(world.upstream.calls.where((c) => c == 'POST /v2/checkout/orders').length, 1);
      // Opening it again reuses the checkout: no second PayPal order.
      final reopened = await PaymentRequestModule.open(s, token);
      expect(reopened.redirect, opened.redirect);
      expect(world.upstream.calls.where((c) => c == 'POST /v2/checkout/orders').length, 1);
      final checkout = (await PaymentRequest.db.findById(s, r['id'] as int))!.checkoutIntentId!;
      final intent = (await CheckoutIntent.db.findById(s, checkout))!;
      expect(intent.commissionMinor, 0);
      expect(intent.orderId, isNull);

      // The payer approves at PayPal; the return page settles it.
      world.upstream.status = 'APPROVED';
      final settled = await MoneyModule.settleApproved(s, checkout);
      expect(settled['state'], 'completed');
      final paid = (await world.read('request', {'id': r['id']}));
      expect(paid['state'], 'paid');
      expect(paid['providerCaptureId'], 'CAPTURE-$checkout');
      final after = await PaymentRequestModule.open(s, token);
      expect(after.status, 200);
      expect(after.message, contains('paid'));

      final j = await world.read('ledger.journal');
      expect(j['balanced'], isTrue);
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      expect(totals['4200']!['creditMinor'], 12000);
      expect(totals['1100']!['balanceMinor'], 0);
      expect(totals['1000']!['debitMinor'], 12000);
      expect(totals.containsKey('4000'), isFalse);
      final summary = (await world.read('requests'))['summary'] as Map;
      expect(summary['outstandingMinor'], 0);
      expect(summary['paidThisMonthMinor'], 12000);
    });

    test('an unknown or cancelled link says so plainly, and cancelling frees the open checkout', () async {
      final s = builder.build();
      final unknown = await PaymentRequestModule.open(s, 'a' * 32);
      expect(unknown.status, 404);
      final r = await request();
      await PaymentRequestModule.open(s, tokenOf(r));
      final checkout = (await PaymentRequest.db.findById(s, r['id'] as int))!.checkoutIntentId!;
      final cancelled = await PaymentRequestModule.cancel(world.owner.build(), world.command({}, id: r['id'] as int));
      expect(cancelled['state'], 'cancelled');
      expect((await CheckoutIntent.db.findById(s, checkout))!.state, 'cancelled');
      final gone = await PaymentRequestModule.open(s, tokenOf(r));
      expect(gone.status, 410);
    });

    test('without an email channel a send fails honestly and nothing is marked sent', () async {
      final r = await request(email: 'office@acme.example');
      await world.expectFailure(
        () => PaymentRequestModule.send(world.owner.build(), world.command({}, id: r['id'] as int)),
        'not_configured',
      );
      final fresh = await world.read('request', {'id': r['id']});
      expect(fresh['state'], 'open');
      final noEmail = await request();
      await world.expectFailure(
        () => PaymentRequestModule.send(world.owner.build(), world.command({}, id: noEmail['id'] as int)),
        'invalid_input',
      );
    });

    test('an invoice stays a draft when PayPal\'s MCP server does not create it', () async {
      await world.expectFailure(() => request(kind: 'invoice'), 'invalid_input');
      final r = await request(kind: 'invoice', email: 'office@acme.example');
      expect(r['state'], 'draft');
      expect(r['payUrl'], isNull);
      final failure = await world.expectFailure(
        () => PaymentRequestModule.send(world.owner.build(), world.command({}, id: r['id'] as int)),
        'provider_unavailable',
      );
      expect(failure['message'], contains('MCP'));
      final fresh = await world.read('request', {'id': r['id']});
      expect(fresh['state'], 'draft');
      expect(fresh['providerInvoiceId'], isNull);
    });

    test('an overdue request is found by the rules with a reminder to propose', () async {
      final r = await request(email: 'office@acme.example', due: const Duration(days: -2));
      final rows = ((await world.read('accountant.anomalies'))['rows'] as List).cast<Map>();
      final overdue = rows.firstWhere((a) => a['kind'] == 'request_overdue');
      expect(overdue['ref'], 'request:${r['id']}');
      expect((overdue['fix'] as Map)['command'], 'request.remind');
      final listed = ((await world.read('requests'))['rows'] as List).cast<Map>().single;
      expect(listed['overdue'], isTrue);
    });
  });
}
