import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

/// PayPal Sandbox as several apps see it: each app has its own keys, its own
/// account (merchant id), its own orders and its own webhooks, and one app
/// cannot read another's orders. Calls are recorded with the app that made
/// them, so a test can prove whose keys were used.
class FakePayPal {
  /// Client id → secret.
  final apps = <String, String>{};

  /// Client id → the PayPal account it belongs to.
  final merchants = <String, String>{};

  /// Client id → features its PayPal app does not have.
  final disabled = <String, Set<String>>{};
  final calls = <({String app, String method, String path})>[];
  final orders = <String, Map<String, dynamic>>{};
  final webhooks = <String, ({String app, String url})>{};
  final deleted = <String>[];
  final payouts = <({String app, Map body})>[];
  var webhookExists = false;
  var partnerApproved = false;
  Map<String, dynamic>? integration;
  var _n = 0;

  static http.Response json(Object body, int status) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  Map<String, dynamic> view(String id) {
    final o = orders[id]!;
    final amount = {
      'currency_code': o['currency'],
      'value': PayPalGateway.money(o['amountMinor'] as int),
    };
    return {
      'id': id,
      'intent': 'CAPTURE',
      'status': o['captured'] == true ? 'COMPLETED' : o['status'],
      'purchase_units': [
        {
          'custom_id': o['customId'],
          'payee': {'merchant_id': o['payee']},
          'amount': amount,
          if (o['captured'] == true)
            'payments': {
              'captures': [
                {
                  'id': 'CAP-$id',
                  'status': 'COMPLETED',
                  'final_capture': true,
                  'amount': amount,
                },
              ],
            },
        },
      ],
      'links': [
        {
          'rel': 'payer-action',
          'href': 'https://www.sandbox.paypal.com/checkoutnow?token=$id',
        },
      ],
    };
  }

  http.Client client() => MockClient((r) async {
    final path = r.url.path;
    final auth = r.headers['Authorization'] ?? r.headers['authorization'] ?? '';
    if (path == '/v1/oauth2/token') {
      final pair = utf8.decode(base64.decode(auth.substring('Basic '.length)));
      final cut = pair.indexOf(':');
      final id = pair.substring(0, cut);
      calls.add((app: id, method: r.method, path: path));
      if (apps[id] != pair.substring(cut + 1)) {
        return json({'error': 'invalid_client'}, 401);
      }
      return json({
        'access_token': 'tok:$id',
        'app_id': 'APP-${id.substring(0, 6)}',
        'expires_in': 32400,
        'scope': 'https://uri.paypal.com/services/payments/payment',
      }, 200);
    }
    if (!auth.startsWith('Bearer tok:')) {
      return json({'name': 'AUTHENTICATION_FAILURE'}, 401);
    }
    final app = auth.substring('Bearer tok:'.length);
    calls.add((app: app, method: r.method, path: path));
    final off = disabled[app] ?? const <String>{};
    final body = r.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(r.body) as Map<String, dynamic>;
    const notAuthorized = {
      'name': 'NOT_AUTHORIZED',
      'message': 'Authorization failed due to insufficient permissions.',
    };
    // The read-only checklist probes.
    if (path.endsWith('/RAYSTOPROBE00000')) {
      if (path.startsWith('/v1/payments/payouts/') && off.contains('payouts')) {
        return json(notAuthorized, 403);
      }
      return json({'name': 'RESOURCE_NOT_FOUND'}, 404);
    }
    if (path == '/v2/invoicing/invoices') {
      return off.contains('invoicing')
          ? json(notAuthorized, 403)
          : json({'items': []}, 200);
    }
    if (path == '/v1/reporting/transactions') {
      return off.contains('transactionSearch')
          ? json(notAuthorized, 403)
          : json({
              'transaction_details': [],
              'account_number': merchants[app],
            }, 200);
    }
    if (path == '/v1/customer/disputes') return json({'items': []}, 200);
    // Webhooks on the calling app.
    if (path == '/v1/notifications/webhooks' && r.method == 'POST') {
      if (webhookExists) {
        webhooks['WH-OLD-$app'] = (app: app, url: body['url'] as String);
        return json({'name': 'WEBHOOK_URL_ALREADY_EXISTS'}, 400);
      }
      final id = 'WH-${++_n}';
      webhooks[id] = (app: app, url: body['url'] as String);
      return json({'id': id, 'url': body['url']}, 201);
    }
    if (path == '/v1/notifications/webhooks' && r.method == 'GET') {
      return json({
        'webhooks': [
          for (final e in webhooks.entries)
            if (e.value.app == app) {'id': e.key, 'url': e.value.url},
        ],
      }, 200);
    }
    if (path.startsWith('/v1/notifications/webhooks/') &&
        r.method == 'DELETE') {
      deleted.add(path.split('/').last);
      return http.Response('', 204);
    }
    if (path == '/v1/notifications/verify-webhook-signature') {
      final hook = webhooks[body['webhook_id']];
      return json({
        'verification_status': hook != null && hook.app == app
            ? 'SUCCESS'
            : 'FAILURE',
      }, 200);
    }
    // Orders: each app sees only its own.
    if (path == '/v2/checkout/orders' && r.method == 'POST') {
      final unit = (body['purchase_units'] as List).single as Map;
      final payee = (unit['payee'] as Map?)?['merchant_id'] ?? merchants[app];
      if (payee != merchants[app]) {
        return json({'name': 'UNPROCESSABLE_ENTITY'}, 422);
      }
      final amount = unit['amount'] as Map;
      final id = 'ORDER-${++_n}';
      orders[id] = {
        'app': app,
        'customId': unit['custom_id'],
        'payee': payee,
        'amountMinor': PayPalGateway.parseMoney(amount['value'] as String),
        'currency': amount['currency_code'],
        'status': 'CREATED',
        'captured': false,
      };
      return json(view(id), 201);
    }
    final order = RegExp(
      r'^/v2/checkout/orders/([A-Z0-9-]+)(/capture)?$',
    ).firstMatch(path);
    if (order != null) {
      final id = order.group(1)!;
      if (orders[id]?['app'] != app) {
        return json({'name': 'RESOURCE_NOT_FOUND'}, 404);
      }
      if (order.group(2) != null) {
        if (orders[id]!['status'] != 'APPROVED') {
          return json({'name': 'UNPROCESSABLE_ENTITY'}, 422);
        }
        orders[id]!['captured'] = true;
        return json(view(id), 201);
      }
      return json(view(id), 200);
    }
    if (path == '/v1/payments/payouts' && r.method == 'POST') {
      if (off.contains('payouts')) return json(notAuthorized, 403);
      payouts.add((app: app, body: body));
      return json({
        'batch_header': {
          'payout_batch_id': 'BATCH-${payouts.length}',
          'batch_status': 'PENDING',
        },
      }, 201);
    }
    // Partner Referrals: only for an approved partner.
    if (path == '/v2/customer/partner-referrals') {
      if (!partnerApproved) return json(notAuthorized, 403);
      return json({
        'links': [
          {
            'rel': 'action_url',
            'href':
                'https://www.sandbox.paypal.com/bizsignup/partner/entry?token=X',
          },
        ],
      }, 201);
    }
    if (path.startsWith('/v1/customer/partners/') && integration != null) {
      return json(integration!, 200);
    }
    return json({'name': 'UNEXPECTED', 'path': path}, 500);
  });

  void approve(String orderId) => orders[orderId]!['status'] = 'APPROVED';
  Iterable<String> appsFor(String pathPart) =>
      calls.where((c) => c.path.contains(pathPart)).map((c) => c.app);
}

// Each restaurant's own PayPal app (0.16, stream S6): keys checked with
// PayPal and sealed, payments and payouts routed through the café's own app,
// its webhook verified with that app, and the partner path honest about
// needing PayPal's approval. Isolated Raysto test database; PayPal is a fake.
void main() {
  withServerpod('Each restaurant\'s own PayPal app', (builder, endpoints) {
    late AccountantWorld a, b;
    late FakePayPal paypal;
    const ownId = 'OWNAPPCLIENTAAAAAAAAAAAAAAAAAAAA';
    const ownSecret = 'OWNAPPSECRETAAAAAAAAAAAAAAAAAAAAAAAA';
    const ownMerchant = 'OWNMERCHANT01';
    final certHeaders = {
      'paypal-auth-algo': 'SHA256withRSA',
      'paypal-cert-url':
          'https://api-m.sandbox.paypal.com/v1/notifications/certs/CERT-1',
      'paypal-transmission-id': 'T-1',
      'paypal-transmission-sig': 'SIG',
      'paypal-transmission-time': '2026-11-04T10:00:00Z',
    };

    setUp(() async {
      a = AccountantWorld(builder, 'mappa');
      await a.setUp();
      b = AccountantWorld(builder, 'mappb');
      await b.setUp();
      paypal = FakePayPal()
        ..apps['fixture-client'] = 'fixture-secret'
        ..merchants['fixture-client'] = 'MERCHANT-FIXTURE'
        ..apps[ownId] = ownSecret
        ..merchants[ownId] = ownMerchant
        ..disabled[ownId] = {'invoicing'};
      ProviderClients.httpClient = paypal.client;
      ProviderClients.forgetOwnTokens();
      // The active settings are b's map: both cafés take shared Sandbox
      // payments until one connects its own app.
      b.env
        ..['RAYSTO_SANDBOX_RESTAURANT_ID'] =
            '${a.restaurant.id},${b.restaurant.id}'
        ..['RAYSTO_MERCHANT_SECRET_KEY'] = base64.encode(
          List.generate(32, (i) => i * 7 + 3),
        )
        ..['RAYSTO_PUBLIC_API_URL'] = 'https://api.example.test';
    });
    tearDown(() {
      a.tearDown();
      b.tearDown();
      ProviderClients.forgetOwnTokens();
    });

    // An MFA step-up grant, as identity.stepUp records it (once per session).
    Future<void> mfa(AccountantWorld w) =>
        SecurityGrant.db.insert(builder.build(), [
          SecurityGrant(
            userId: w.ownerId,
            kind: 'mfa',
            proofHash: sha256
                .convert(utf8.encode('stepup:${w.ownerId}:${w.ownerAuth}:mfa'))
                .toString(),
            expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
            createdAt: DateTime.now().toUtc(),
          ),
        ], ignoreConflicts: true);

    Future<Json> save(
      AccountantWorld w, {
      String id = ownId,
      String secret = ownSecret,
    }) => MerchantAppModule.save(
      w.owner.build(),
      w.command({'clientId': id, 'clientSecret': secret}),
    );

    Future<MerchantApp?> row(AccountantWorld w) => MerchantApp.db.findFirstRow(
      builder.build(),
      where: (t) => t.restaurantId.equals(w.restaurant.id!),
    );

    /// A pickup order put to PayPal checkout; returns the checkout.
    Future<CheckoutIntent> checkout(AccountantWorld w) async {
      final q = await OrderingModule.quote(
        w.customer.build(),
        CreateQuote(
          requestKey: w.key(),
          restaurantId: w.restaurant.id!,
          fulfillment: 'pickup',
          tipMinor: 0,
          linesJson: jsonEncode([
            {'productId': w.burger, 'quantity': 1},
          ]),
        ),
      );
      final order =
          (await OrderingModule.submit(
                w.customer.build(),
                SubmitOrder(
                  requestKey: w.key(),
                  restaurantId: w.restaurant.id!,
                  quoteId: q['id'] as int,
                ),
              ))['orderId']
              as int;
      final id =
          (await MoneyModule.allocate(
                w.customer.build(),
                AllocatePayment(
                  requestKey: w.key(),
                  restaurantId: w.restaurant.id!,
                  orderId: order,
                  method: 'paypal',
                ),
              ))['checkoutId']
              as int;
      await MoneyModule.checkout(w.customer.build(), w.command({}, id: id));
      return (await CheckoutIntent.db.findById(builder.build(), id))!;
    }

    test(
      'PayPal must accept the keys; the secret is sealed and never shown',
      () async {
        await mfa(a);
        final status = await save(a);
        expect(status['mode'], 'ownApp');
        final own = status['ownApp'] as Map;
        expect(own['clientIdEnd'], ownId.substring(ownId.length - 4));
        expect(own['webhook'], 'registered');
        // Learned from PayPal's own reporting answer, not typed or invented.
        expect(own['merchantId'], ownMerchant);
        final states = {
          for (final f in own['features'] as List) f['name']: f['state'],
        };
        expect(states, {
          'orders': 'enabled',
          'refunds': 'enabled',
          'payouts': 'enabled',
          'invoicing': 'notEnabled',
          'transactionSearch': 'enabled',
          'disputes': 'enabled',
        });
        expect(jsonEncode(status), isNot(contains(ownSecret)));

        final s = builder.build();
        final stored = (await row(a))!;
        expect(stored.secretCipher, isNot(contains(ownSecret)));
        expect(
          utf8.decode(base64.decode(stored.secretCipher), allowMalformed: true),
          isNot(contains(ownSecret)),
        );
        expect(
          MerchantSecrets.open(
            stored.secretCipher,
            MerchantSecrets.aad(a.restaurant.id!, 'sandbox', ownId),
          ),
          ownSecret,
        );
        // Sealed for this café only: the same ciphertext does not open for another.
        expect(
          () => MerchantSecrets.open(
            stored.secretCipher,
            MerchantSecrets.aad(b.restaurant.id!, 'sandbox', ownId),
          ),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'merchant_keys_unreadable',
            ),
          ),
        );
        for (final r in await AuditRecord.db.find(
          s,
          where: (t) => t.restaurantId.equals(a.restaurant.id!),
        )) {
          expect(r.detailsJson, isNot(contains(ownSecret)));
        }
        for (final r in await MutationReceipt.db.find(
          s,
          where: (t) => t.userId.equals(a.ownerId),
        )) {
          expect(r.resultJson, isNot(contains(ownSecret)));
          expect(r.requestHash, isNot(contains(ownSecret)));
        }
        // The webhook points at this café's opaque address on its own app.
        final hook = paypal.webhooks.values.single;
        expect(hook.app, ownId);
        expect(
          hook.url,
          'https://api.example.test/api/v2/webhooks/paypal-app/${stored.webhookToken}',
        );
      },
    );

    test(
      'wrong keys, a missing identity check and a non-owner are refused',
      () async {
        await a.expectFailure(() => save(a), 'mfa_required');
        await a.stepUp(); // a fresh sign-in is not enough by default
        await a.expectFailure(() => save(a), 'mfa_required');
        await a.expectFailure(
          () => MerchantAppModule.save(
            a.customer.build(),
            a.command({'clientId': ownId, 'clientSecret': ownSecret}),
          ),
          'forbidden',
        );
        await mfa(a);
        final wrong = await a.expectFailure(
          () => save(a, secret: 'WRONGSECRETAAAAAAAAAAAAAAAAAAAAA'),
          'paypal_keys_invalid',
        );
        expect(wrong['message'], isNot(contains('WRONGSECRET')));
        await a.expectFailure(() => save(a, id: 'short'), 'invalid_input');
        expect(await row(a), isNull);
        // A deployment may accept a fresh sign-in instead of MFA, explicitly.
        b.env['RAYSTO_MERCHANT_APP_STEP_UP'] = 'recent_auth';
        await b.stepUp();
        expect((await save(b))['mode'], 'ownApp');
      },
    );

    test(
      'the webhook is registered once and an existing one is reused',
      () async {
        await mfa(a);
        await save(a);
        await MerchantAppModule.recheck(a.owner.build(), a.command({}));
        expect(paypal.webhooks.length, 1);
        // The same app on PayPal already has Raysto's address: reuse it.
        paypal
          ..webhookExists = true
          ..apps['OWNAPPCLIENTBBBBBBBBBBBBBBBBBBBB'] =
              'OWNAPPSECRETBBBBBBBBBBBBBBBBBBBBBBBB'
          ..merchants['OWNAPPCLIENTBBBBBBBBBBBBBBBBBBBB'] = 'OWNMERCHANT02';
        await mfa(b);
        final status = await save(
          b,
          id: 'OWNAPPCLIENTBBBBBBBBBBBBBBBBBBBB',
          secret: 'OWNAPPSECRETBBBBBBBBBBBBBBBBBBBBBBBB',
        );
        expect((status['ownApp'] as Map)['webhook'], 'registered');
        expect(
          (await row(b))!.webhookId,
          'WH-OLD-OWNAPPCLIENTBBBBBBBBBBBBBBBBBBBB',
        );
        // One PayPal app per restaurant.
        await mfa(b);
        await b.expectFailure(() => save(b), 'merchant_app_in_use');
      },
    );

    test(
      'payments and payouts use the café\'s own app; the other café is untouched',
      () async {
        await mfa(a);
        await save(a);
        final own = await checkout(a);
        final shared = await checkout(b);
        expect(own.providerMode, 'ownApp');
        expect(own.merchantId, ownMerchant);
        expect(own.commissionMinor, 0);
        expect(paypal.orders[own.providerOrderId]!['app'], ownId);
        expect(shared.providerMode, 'singleMerchantSandbox');
        expect(paypal.orders[shared.providerOrderId]!['app'], 'fixture-client');

        // PayPal says approved, through the café's own webhook: Raysto captures
        // with the café's keys and the payment completes.
        paypal.approve(own.providerOrderId!);
        final app = (await row(a))!;
        final s = builder.build();
        await PlatformWorker.inbox(
          s,
          {
            'id': 'EVT-OWN-1',
            'event_type': 'CHECKOUT.ORDER.APPROVED',
            'resource': {'id': own.providerOrderId},
          },
          certHeaders,
          appToken: app.webhookToken,
        );
        final event = (await ProviderInbox.db.findFirstRow(
          s,
          where: (t) => t.eventId.equals('EVT-OWN-1'),
        ))!;
        expect(event.provider, 'paypal-app:${app.id}');
        await PlatformWorker.processInbox(s, event.id!);
        expect(
          (await CheckoutIntent.db.findById(s, own.id!))!.state,
          'completed',
        );
        expect(paypal.orders[own.providerOrderId]!['captured'], isTrue);
        // The shared app never touched the café's order.
        expect(
          paypal.calls
              .where((c) => c.path.contains(own.providerOrderId!))
              .map((c) => c.app)
              .toSet(),
          {ownId},
        );

        // The same event on the shared channel is refused: wrong channel.
        paypal.approve(shared.providerOrderId!);
        await ProviderInbox.db.insertRow(
          s,
          ProviderInbox(
            provider: 'paypal-app:${app.id}',
            eventId: 'EVT-CROSS-1',
            eventType: 'CHECKOUT.ORDER.APPROVED',
            payloadJson: jsonEncode({
              'resource': {'id': shared.providerOrderId},
            }),
            status: 'pending',
            receivedAt: DateTime.now().toUtc(),
          ),
        );
        final cross = (await ProviderInbox.db.findFirstRow(
          s,
          where: (t) => t.eventId.equals('EVT-CROSS-1'),
        ))!;
        await expectLater(
          PlatformWorker.processInbox(s, cross.id!),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'provider_mismatch',
            ),
          ),
        );

        // Payouts: the café's own app sends and reads its batch.
        final account = await MerchantAppModule.forRestaurant(
          s,
          a.restaurant.id!,
        );
        expect(account, isNotNull);
        expect(
          await MerchantAppModule.forRestaurant(s, b.restaurant.id!),
          isNull,
        );
        final sent = await ProviderClients.createPayout(
          batchId: 'mapp-batch-1',
          currency: 'USD',
          items: [
            {
              'email': 'staff@example.test',
              'amountMinor': 500,
              'note': 'Tips',
              'itemId': 'item-1',
            },
          ],
          account: account,
        );
        expect(sent['id'], 'BATCH-1');
        expect(paypal.payouts.single.app, ownId);
        expect(account.toString(), isNot(contains(ownSecret)));
      },
    );

    test(
      'own-app webhooks verify with that app; unknown addresses are 404',
      () async {
        await mfa(a);
        await save(a);
        final s = builder.build();
        await a.expectFailure(
          () => PlatformWorker.inbox(
            s,
            {'id': 'E-1', 'event_type': 'X', 'resource': {}},
            certHeaders,
            appToken: 'f' * 32,
          ),
          'not_found',
        );
        final app = (await row(a))!;
        // Another app's webhook id does not verify on this app.
        paypal.webhooks[app.webhookId!] = (app: 'fixture-client', url: 'x');
        await a.expectFailure(
          () => PlatformWorker.inbox(
            s,
            {'id': 'E-2', 'event_type': 'X', 'resource': {}},
            certHeaders,
            appToken: app.webhookToken,
          ),
          'forbidden',
        );
      },
    );

    test(
      'removing the app waits for open payments, then falls back to the shared merchant',
      () async {
        await mfa(a);
        await save(a);
        final open = await checkout(a);
        await mfa(a);
        await a.expectFailure(
          () => MerchantAppModule.remove(a.owner.build(), a.command({})),
          'merchant_busy',
        );
        paypal.approve(open.providerOrderId!);
        await MoneyModule.capture(
          a.customer.build(),
          a.command({}, id: open.id),
        );
        final hookId = (await row(a))!.webhookId;
        final status = await MerchantAppModule.remove(
          a.owner.build(),
          a.command({}),
        );
        expect(status['mode'], 'sharedSandbox');
        expect(status['ownApp'], isNull);
        final removed = (await row(a))!;
        expect(removed.status, 'removed');
        expect(removed.secretCipher, '');
        expect(paypal.deleted, [hookId]);
        expect(
          await MerchantAppModule.forRestaurant(
            builder.build(),
            a.restaurant.id!,
          ),
          isNull,
        );
        final next = await checkout(a);
        expect(next.providerMode, 'singleMerchantSandbox');
        expect(paypal.orders[next.providerOrderId]!['app'], 'fixture-client');
      },
    );

    test(
      'Connect with PayPal says it needs partner approval, and its webhooks update the status',
      () async {
        await mfa(a);
        final missing = await a.expectFailure(
          () => MoneyModule.connectMerchant(
            a.owner.build(),
            a.command({'shareDataConsent': true}),
          ),
          'partner_approval_required',
        );
        expect(missing['message'], contains('partner approval'));
        b.env
          ..['PAYPAL_PLATFORM_CLIENT_ID'] = 'platform-client'
          ..['PAYPAL_PLATFORM_CLIENT_SECRET'] = 'platform-secret'
          ..['PAYPAL_PLATFORM_MERCHANT_ID'] = 'PLATFORM0001'
          ..['PAYPAL_PLATFORM_BN_CODE'] = 'RAYSTO_BN'
          ..['PAYPAL_ALLOWED_MERCHANT_COUNTRIES'] = 'US';
        paypal.apps['platform-client'] = 'platform-secret';
        await mfa(a);
        // PayPal's NOT_AUTHORIZED for a partner that is not approved yet.
        await a.expectFailure(
          () => MoneyModule.connectMerchant(
            a.owner.build(),
            a.command({'shareDataConsent': true}),
          ),
          'partner_approval_required',
        );
        final s = builder.build();
        final connection = (await MerchantConnection.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(a.restaurant.id!),
        ))!;
        expect(connection.status, 'approvalRequired');
        final status = await MerchantAppModule.status(
          s,
          a.restaurant.id!,
          a.ownerId,
        );
        expect(
          (status['partner'] as Map)['note'],
          MerchantAppModule.partnerNote,
        );
        expect(status['mode'], 'sharedSandbox');

        // Once approved, PayPal reports the seller's onboarding by webhook.
        paypal.integration = {
          'merchant_id': 'SELLER0000001',
          'tracking_id': connection.trackingId,
          'payments_receivable': true,
          'primary_email_confirmed': true,
          'country': 'US',
          'products': [
            {'name': 'PPCP_STANDARD', 'vetting_status': 'SUBSCRIBED'},
          ],
          'oauth_integrations': [
            {
              'oauth_third_party': [
                {
                  'partner_client_id': 'platform-client',
                  'scopes': [
                    'https://uri.paypal.com/services/payments/refund',
                    'https://uri.paypal.com/services/payments/payment/authcapture',
                  ],
                },
              ],
            },
          ],
        };
        Future<void> deliver(String id, String type) async {
          final e = await ProviderInbox.db.insertRow(
            s,
            ProviderInbox(
              provider: 'paypal-platform',
              eventId: id,
              eventType: type,
              payloadJson: jsonEncode({
                'resource': {'merchant_id': 'SELLER0000001'},
              }),
              status: 'pending',
              receivedAt: DateTime.now().toUtc(),
            ),
          );
          await PlatformWorker.processInbox(s, e.id!);
        }

        await deliver('EVT-ONB-1', 'MERCHANT.ONBOARDING.COMPLETED');
        var fresh = (await MerchantConnection.db.findById(s, connection.id!))!;
        expect(fresh.status, 'ready');
        expect(fresh.merchantId, 'SELLER0000001');
        await deliver('EVT-REV-1', 'MERCHANT.PARTNER-CONSENT.REVOKED');
        fresh = (await MerchantConnection.db.findById(s, connection.id!))!;
        expect(fresh.status, 'revoked');
        expect(fresh.verifiedAt, isNull);
      },
    );
  });
}
