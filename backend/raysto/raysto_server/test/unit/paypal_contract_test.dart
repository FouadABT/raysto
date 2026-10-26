import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';

void main() {
  test(
    'sandbox order uses frozen minor units, configured payee and stable request ID',
    () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api-m.sandbox.paypal.com');
        if (request.url.path == '/v1/oauth2/token') {
          expect(request.body, 'grant_type=client_credentials');
          return http.Response('{"access_token":"token"}', 200);
        }
        expect(request.headers['PayPal-Request-Id'], 'persisted-request');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['intent'], 'CAPTURE');
        final unit = (body['purchase_units'] as List).single as Map;
        expect(unit['amount'], {'currency_code': 'EUR', 'value': '22.00'});
        expect(unit['payee'], {'merchant_id': 'MERCHANT'});
        expect(unit['reference_id'], '10');
        return http.Response('{"id":"PAYPAL1"}', 201);
      });
      final gateway = PayPalGateway(
        client: client,
        clientId: 'test',
        secret: 'test',
        merchantId: 'MERCHANT',
        webhookId: 'WEBHOOK',
        returnUrl: Uri.https('example.test', '/return'),
        cancelUrl: Uri.https('example.test', '/cancel'),
      );
      final now = DateTime.now().toUtc();
      final order = PurchaseOrder(
        id: 10,
        restaurantId: 1,
        customerId: 'customer',
        requestKey: 'request-key',
        requestHash: 'hash',
        fulfillment: 'delivery',
        address: 'Test',
        lines: [],
        currency: 'EUR',
        subtotalMinor: 2000,
        deliveryFeeMinor: 200,
        totalMinor: 2200,
        status: 'placed',
        paymentStatus: 'unpaid',
        version: 1,
        createdAt: now,
        updatedAt: now,
      );
      await gateway.create(order, 'persisted-request');
      gateway.close();
    },
  );

  test(
    'webhook verification transmits signature headers and configured webhook ID to PayPal',
    () async {
      final client = MockClient((request) async {
        if (request.url.path == '/v1/oauth2/token') {
          return http.Response('{"access_token":"token"}', 200);
        }
        expect(request.url.path, '/v1/notifications/verify-webhook-signature');
        final body = jsonDecode(request.body) as Map;
        expect(body['webhook_id'], 'WEBHOOK');
        expect(body['transmission_sig'], 'signature');
        expect(body['webhook_event'], {'id': 'EVENT'});
        return http.Response('{"verification_status":"SUCCESS"}', 200);
      });
      final gateway = PayPalGateway(
        client: client,
        clientId: 'test',
        secret: 'test',
        merchantId: 'MERCHANT',
        webhookId: 'WEBHOOK',
        returnUrl: Uri.https('example.test', '/return'),
        cancelUrl: Uri.https('example.test', '/cancel'),
      );
      expect(
        await gateway.verifyWebhook(
          {
            'paypal-auth-algo': 'SHA256withRSA',
            'paypal-cert-url': 'https://example.test/cert',
            'paypal-transmission-id': 'transmission',
            'paypal-transmission-sig': 'signature',
            'paypal-transmission-time': '2026-10-24T12:00:00Z',
          },
          {'id': 'EVENT'},
        ),
        isTrue,
      );
      gateway.close();
    },
  );
}
