import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/payment_service.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:raysto_server/src/services/sandbox_payment_service.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Standalone sandbox payments', (builder, endpoints) {
    final owner = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        'sandbox-owner',
        {},
      ),
    );
    final stranger = builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        'sandbox-stranger',
        {},
      ),
    );
    const providerId = 'TESTORDER123456789';
    late String providerState;
    late int creates, captures, gets;
    late Map<String, dynamic>? createBody;
    late String? createKey;
    late String? captureKey;
    late bool loseCaptureResponse;
    late bool verify;
    int paymentId = 0;
    Map<String, dynamic> completed({
      String value = '1.00',
      String merchant = 'MERCHANT',
      String? reference,
    }) => {
      'id': providerId,
      'status': 'COMPLETED',
      'purchase_units': [
        {
          'reference_id': reference ?? 'raysto-sandbox-$paymentId',
          'payee': {'merchant_id': merchant},
          'payments': {
            'captures': [
              {
                'id': 'CAPTURE123',
                'status': 'COMPLETED',
                'final_capture': true,
                'amount': {'currency_code': 'USD', 'value': value},
              },
            ],
          },
        },
      ],
    };
    PayPalGateway gateway() => PayPalGateway(
      client: MockClient((request) async {
        if (request.url.path == '/v1/oauth2/token') {
          return http.Response('{"access_token":"test-only"}', 200);
        }
        if (request.url.path == '/v1/notifications/verify-webhook-signature') {
          return http.Response(
            jsonEncode({'verification_status': verify ? 'SUCCESS' : 'FAILURE'}),
            200,
          );
        }
        if (request.method == 'POST' &&
            request.url.path == '/v2/checkout/orders') {
          creates++;
          createBody = jsonDecode(request.body) as Map<String, dynamic>;
          createKey = request.headers['PayPal-Request-Id'];
          return http.Response(
            jsonEncode({
              'id': providerId,
              'status': 'PAYER_ACTION_REQUIRED',
              'links': [
                {
                  'rel': 'payer-action',
                  'href':
                      'https://www.sandbox.paypal.com/checkoutnow?token=$providerId',
                },
              ],
            }),
            201,
          );
        }
        if (request.method == 'GET') {
          gets++;
          return http.Response(
            jsonEncode(
              providerState == 'COMPLETED'
                  ? completed()
                  : {'id': providerId, 'status': providerState},
            ),
            200,
          );
        }
        captures++;
        captureKey = request.headers['PayPal-Request-Id'];
        providerState = 'COMPLETED';
        if (loseCaptureResponse) throw http.ClientException('Response lost');
        return http.Response(jsonEncode(completed()), 201);
      }),
      clientId: 'test',
      secret: 'test',
      merchantId: 'MERCHANT',
      webhookId: 'WEBHOOK',
      returnUrl: Uri.https('api.rays.to', '/payments/return'),
      cancelUrl: Uri.https('api.rays.to', '/payments/cancel'),
    );

    Future<SandboxPayment> prepared() async {
      final payment = await SandboxPaymentService.start(
        owner.build(),
        'sandbox_test_request_001',
      );
      paymentId = payment.id!;
      return SandboxPaymentService(
        gateway(),
      ).checkout(owner.build(), paymentId);
    }

    setUp(() {
      providerState = 'PAYER_ACTION_REQUIRED';
      creates = 0;
      captures = 0;
      gets = 0;
      createBody = null;
      createKey = null;
      captureKey = null;
      loseCaptureResponse = false;
      verify = true;
    });

    test(
      'fixed USD1 session retries are isolated from commerce and other owners',
      () async {
        final a = await SandboxPaymentService.start(
          owner.build(),
          'sandbox_test_request_001',
        );
        final b = await SandboxPaymentService.start(
          owner.build(),
          'sandbox_test_request_001',
        );
        expect(a.id, b.id);
        expect(a.amountMinor, 100);
        expect(a.currency, 'USD');
        await expectLater(
          SandboxPaymentService.own(stranger.build(), a.id!),
          throwsA(
            isA<DomainError>().having((e) => e.code, 'code', 'not_found'),
          ),
        );
        await expectLater(
          SandboxPaymentService.start(owner.build(), 'short'),
          throwsA(isA<DomainError>()),
        );
        expect(await PurchaseOrder.db.count(builder.build()), 0);
        expect(await PaymentAttempt.db.count(builder.build()), 0);
      },
    );
    test(
      'checkout pins amount, reference, merchant, callbacks and idempotency',
      () async {
        final payment = await prepared();
        final again = await SandboxPaymentService(
          gateway(),
        ).checkout(owner.build(), paymentId);
        expect(creates, 1);
        expect(again.providerOrderId, payment.providerOrderId);
        expect(createKey, payment.providerRequestId);
        final unit = (createBody!['purchase_units'] as List).single as Map;
        expect(unit['reference_id'], 'raysto-sandbox-$paymentId');
        expect(unit['amount'], {'currency_code': 'USD', 'value': '1.00'});
        expect(unit['payee'], {'merchant_id': 'MERCHANT'});
        final context =
            ((createBody!['payment_source'] as Map)['paypal']
                    as Map)['experience_context']
                as Map;
        expect(context['return_url'], 'https://api.rays.to/payments/return');
        expect(
          payment.approvalUrl,
          contains('sandbox.paypal.com/checkoutnow?token=$providerId'),
        );
      },
    );
    test(
      'approval is required and another owner cannot create or capture',
      () async {
        await prepared();
        await expectLater(
          SandboxPaymentService(gateway()).capture(owner.build(), paymentId),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'approval_required',
            ),
          ),
        );
        await expectLater(
          SandboxPaymentService(gateway()).capture(stranger.build(), paymentId),
          throwsA(isA<DomainError>()),
        );
        await expectLater(
          SandboxPaymentService(
            gateway(),
          ).checkout(stranger.build(), paymentId),
          throwsA(isA<DomainError>()),
        );
        expect(captures, 0);
      },
    );
    test(
      'capture recovers a lost response without a second capture or commerce effects',
      () async {
        final payment = await prepared();
        providerState = 'APPROVED';
        loseCaptureResponse = true;
        await expectLater(
          SandboxPaymentService(gateway()).capture(owner.build(), paymentId),
          throwsA(isA<http.ClientException>()),
        );
        final recovered = await SandboxPaymentService(
          gateway(),
        ).capture(owner.build(), paymentId);
        final again = await SandboxPaymentService(
          gateway(),
        ).capture(owner.build(), paymentId);
        expect(recovered.state, 'captured');
        expect(again.captureId, 'CAPTURE123');
        expect(captures, 1);
        expect(gets, 2);
        expect(captureKey, '${payment.providerRequestId}-capture');
        expect(recovered.webhookReceivedAt, isNull);
        expect(await PaymentReceipt.db.count(builder.build()), 0);
        expect(await OutboxEvent.db.count(builder.build()), 0);
      },
    );
    for (final mismatch in ['amount', 'merchant', 'reference']) {
      test('rejects mismatched $mismatch', () async {
        await prepared();
        final service = SandboxPaymentService(gateway());
        await expectLater(
          service.reconcile(
            owner.build(),
            paymentId,
            completed(
              value: mismatch == 'amount' ? '2.00' : '1.00',
              merchant: mismatch == 'merchant' ? 'OTHER' : 'MERCHANT',
              reference: mismatch == 'reference' ? 'another-order' : null,
            ),
          ),
          throwsA(isA<DomainError>()),
        );
        service.gateway.close();
        expect(
          (await SandboxPaymentService.own(owner.build(), paymentId)).captureId,
          isNull,
        );
      });
    }
    test(
      'verified webhook reconciles and duplicate delivery is idempotent',
      () async {
        await prepared();
        providerState = 'COMPLETED';
        final event = <String, dynamic>{
          'id': 'WEBHOOK-EVENT-1',
          'event_type': 'PAYMENT.CAPTURE.COMPLETED',
          'resource': {
            'supplementary_data': {
              'related_ids': {'order_id': providerId},
            },
          },
        };
        final headers = {
          for (final key in [
            'paypal-auth-algo',
            'paypal-cert-url',
            'paypal-transmission-id',
            'paypal-transmission-sig',
            'paypal-transmission-time',
          ])
            key: 'test',
        };
        verify = false;
        await expectLater(
          PaymentService(gateway()).webhook(builder.build(), headers, event),
          throwsA(isA<DomainError>()),
        );
        expect(
          (await SandboxPaymentService.own(
            owner.build(),
            paymentId,
          )).webhookReceivedAt,
          isNull,
        );
        verify = true;
        await PaymentService(
          gateway(),
        ).webhook(builder.build(), headers, event);
        await PaymentService(
          gateway(),
        ).webhook(builder.build(), headers, event);
        final receipt = await SandboxPaymentService.own(
          owner.build(),
          paymentId,
        );
        expect(receipt.state, 'captured');
        expect(receipt.webhookEventId, 'WEBHOOK-EVENT-1');
        expect(receipt.webhookReceivedAt, isNotNull);
        expect(await WebhookEvent.db.count(builder.build()), 1);
        expect(captures, 0);
        expect(gets, 1);
      },
    );
  });
}
