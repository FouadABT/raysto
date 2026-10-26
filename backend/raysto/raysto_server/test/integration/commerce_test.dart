import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/payment_service.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

final denied = throwsA(isA<DomainError>());

void main() {
  withServerpod('Persisted commerce and tenant boundaries', (builder, api) {
    late TestSessionBuilder owner;
    late TestSessionBuilder customer;
    late TestSessionBuilder stranger;
    late Restaurant restaurant;
    late MenuProduct product;
    late PurchaseOrder order;

    setUp(() async {
      owner = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo('owner', {}),
      );
      customer = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'customer',
          {},
        ),
      );
      stranger = builder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'stranger',
          {},
        ),
      );
      restaurant = await api.restaurant.create(owner, 'Olive', 'EUR', 200);
      product = await api.restaurant.saveProduct(
        owner,
        restaurant.id!,
        null,
        'Bowl',
        'Seasonal vegetables',
        1000,
        true,
      );
      await api.restaurant.publish(owner, restaurant.id!, true);
      order = await api.commerce.placeOrder(
        customer,
        restaurant.id!,
        [CartLine(productId: product.id!, quantity: 2)],
        'delivery',
        '10 Test Street',
        'request_key_000001',
      );
    });

    test('server prices and immutable snapshot survive menu changes', () async {
      expect(order.totalMinor, 2200);
      await api.restaurant.saveProduct(
        owner,
        restaurant.id!,
        product.id,
        'New name',
        '',
        5000,
        true,
      );
      final stored = await api.commerce.order(customer, order.id!);
      expect(stored.lines.single.name, 'Bowl');
      expect(stored.lines.single.unitPriceMinor, 1000);
      expect(stored.totalMinor, 2200);
    });

    test(
      'request retry returns same order; changed payload is rejected',
      () async {
        final retry = await api.commerce.placeOrder(
          customer,
          restaurant.id!,
          [CartLine(productId: product.id!, quantity: 2)],
          'delivery',
          '10 Test Street',
          'request_key_000001',
        );
        expect(retry.id, order.id);
        await expectLater(
          api.commerce.placeOrder(
            customer,
            restaurant.id!,
            [CartLine(productId: product.id!, quantity: 1)],
            'pickup',
            null,
            'request_key_000001',
          ),
          denied,
        );
        expect(await PurchaseOrder.db.count(builder.build()), 1);
      },
    );

    test('untrusted users cannot access another customer or tenant', () async {
      await expectLater(api.commerce.order(stranger, order.id!), denied);
      await expectLater(
        api.restaurant.orders(stranger, restaurant.id!, 0, 50),
        denied,
      );
      await expectLater(
        api.restaurant.setStaff(
          stranger,
          restaurant.id!,
          'stranger',
          'manager',
          true,
        ),
        denied,
      );
      await expectLater(
        api.restaurant.saveProduct(
          stranger,
          restaurant.id!,
          product.id,
          'Tampered',
          '',
          1,
          true,
        ),
        denied,
      );
    });

    test(
      'cross-restaurant and negative/duplicate lines are rejected',
      () async {
        final other = await api.restaurant.create(owner, 'Other', 'EUR', 0);
        await api.restaurant.publish(owner, other.id!, true);
        await expectLater(
          api.commerce.placeOrder(
            customer,
            other.id!,
            [CartLine(productId: product.id!, quantity: 1)],
            'pickup',
            null,
            'request_key_other01',
          ),
          denied,
        );
        await expectLater(
          api.commerce.placeOrder(
            customer,
            restaurant.id!,
            [CartLine(productId: product.id!, quantity: -1)],
            'pickup',
            null,
            'request_key_other02',
          ),
          denied,
        );
        await expectLater(
          api.commerce.placeOrder(
            customer,
            restaurant.id!,
            [
              CartLine(productId: product.id!, quantity: 1),
              CartLine(productId: product.id!, quantity: 1),
            ],
            'pickup',
            null,
            'request_key_other03',
          ),
          denied,
        );
      },
    );

    test('unpaid orders cannot enter preparation', () async {
      await expectLater(
        api.restaurant.transition(owner, order.id!, order.version, 'accepted'),
        denied,
      );
      expect((await api.commerce.order(customer, order.id!)).status, 'placed');
    });

    test(
      'courier role cannot read the tenant queue before assignment exists',
      () async {
        await api.restaurant.setStaff(
          owner,
          restaurant.id!,
          'courier',
          'courier',
          true,
        );
        final courier = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'courier',
            {},
          ),
        );
        expect(await api.restaurant.queue(courier, restaurant.id!), isEmpty);
        await expectLater(
          api.restaurant.transition(
            courier,
            order.id!,
            order.version,
            'accepted',
          ),
          denied,
        );
      },
    );

    Map<String, dynamic> completed(
      String providerId, {
      String amount = '22.00',
      String merchant = 'MERCHANT',
    }) => {
      'id': providerId,
      'status': 'COMPLETED',
      'purchase_units': [
        {
          'reference_id': order.id.toString(),
          'payee': {'merchant_id': merchant},
          'payments': {
            'captures': [
              {
                'id': 'CAPTURE1',
                'status': 'COMPLETED',
                'final_capture': true,
                'amount': {'currency_code': 'EUR', 'value': amount},
              },
            ],
          },
        },
      ],
    };

    PayPalGateway gateway(http.Client client) => PayPalGateway(
      client: client,
      clientId: 'test',
      secret: 'test',
      merchantId: 'MERCHANT',
      webhookId: 'WEBHOOK',
      returnUrl: Uri.https('example.test', '/return'),
      cancelUrl: Uri.https('example.test', '/cancel'),
    );

    Future<void> attempt() async => PaymentAttempt.db.insertRow(
      builder.build(),
      PaymentAttempt(
        orderId: order.id!,
        requestId: 'test-attempt',
        providerOrderId: 'PAYPAL1',
        approvalUrl: 'https://www.sandbox.paypal.com/checkoutnow?token=PAYPAL1',
        state: 'awaitingApproval',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    test(
      'capture checks amount and merchant before persisting a receipt',
      () async {
        await attempt();
        final payment = PaymentService(
          gateway(MockClient((_) async => http.Response('{}', 500))),
        );
        await expectLater(
          payment.reconcile(
            builder.build(),
            order.id!,
            completed('PAYPAL1', amount: '21.99'),
          ),
          denied,
        );
        await expectLater(
          payment.reconcile(
            builder.build(),
            order.id!,
            completed('PAYPAL1', merchant: 'OTHER'),
          ),
          denied,
        );
        expect(await PaymentReceipt.db.count(builder.build()), 0);
        expect(
          (await api.commerce.order(customer, order.id!)).paymentStatus,
          'unpaid',
        );
      },
    );

    test(
      'duplicate reconciliation creates one receipt and one durable notification',
      () async {
        await attempt();
        final payment = PaymentService(
          gateway(MockClient((_) async => http.Response('{}', 500))),
        );
        final paid = await payment.reconcile(
          builder.build(),
          order.id!,
          completed('PAYPAL1'),
        );
        await payment.reconcile(
          builder.build(),
          order.id!,
          completed('PAYPAL1'),
        );
        expect(paid.paymentStatus, 'paid');
        expect(await PaymentReceipt.db.count(builder.build()), 1);
        expect(await OutboxEvent.db.count(builder.build()), 1);
        final accepted = await api.restaurant.transition(
          owner,
          order.id!,
          paid.version,
          'accepted',
        );
        await expectLater(
          api.restaurant.transition(
            owner,
            order.id!,
            paid.version,
            'preparing',
          ),
          denied,
        );
        await api.restaurant.setStaff(
          owner,
          restaurant.id!,
          'chef',
          'kitchen',
          true,
        );
        final chef = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo('chef', {}),
        );
        final preparing = await api.restaurant.transition(
          chef,
          order.id!,
          accepted.version,
          'preparing',
        );
        await api.restaurant.setStaff(
          owner,
          restaurant.id!,
          'chef',
          'kitchen',
          false,
        );
        await expectLater(
          api.restaurant.transition(
            chef,
            order.id!,
            preparing.version,
            'ready',
          ),
          denied,
        );
      },
    );

    test(
      'lost capture response recovers via provider GET without a second POST',
      () async {
        await attempt();
        final calls = <String>[];
        final client = MockClient((request) async {
          calls.add('${request.method} ${request.url.path}');
          if (request.url.path == '/v1/oauth2/token') {
            return http.Response('{"access_token":"token"}', 200);
          }
          return http.Response(jsonEncode(completed('PAYPAL1')), 200);
        });
        final recovered = await PaymentService(
          gateway(client),
        ).capture(customer.build(), order.id!);
        expect(recovered.paymentStatus, 'paid');
        expect(calls, [
          'POST /v1/oauth2/token',
          'GET /v2/checkout/orders/PAYPAL1',
        ]);
      },
    );

    test('invalid webhook cannot mutate payment records', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/v1/oauth2/token') {
          return http.Response('{"access_token":"token"}', 200);
        }
        return http.Response('{"verification_status":"FAILURE"}', 200);
      });
      await expectLater(
        PaymentService(gateway(client)).webhook(builder.build(), {}, {
          'id': 'EVENT1',
          'event_type': 'PAYMENT.CAPTURE.COMPLETED',
        }),
        denied,
      );
      expect(await PaymentReceipt.db.count(builder.build()), 0);
      expect(await WebhookEvent.db.count(builder.build()), 0);
    });

    test(
      'device registration and service request are scoped to customer',
      () async {
        await api.commerce.registerDevice(customer, 'device-token');
        await expectLater(
          api.commerce.registerDevice(stranger, 'device-token'),
          denied,
        );
        final first = await api.commerce.requestService(
          customer,
          order.id!,
          'help',
        );
        final second = await api.commerce.requestService(
          customer,
          order.id!,
          'help',
        );
        expect(second.id, first.id);
        await expectLater(
          api.commerce.requestService(stranger, order.id!, 'help'),
          denied,
        );
        await api.commerce.unregisterDevice(customer, 'device-token');
        expect(await DeviceToken.db.count(builder.build()), 0);
      },
    );
  });
}
