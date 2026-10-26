import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/services/payment_service.dart';
import 'package:raysto_server/src/services/paypal_gateway.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Committed concurrent requests', (builder, api) {
    test(
      'independent transactions deduplicate ordering and capture receipts',
      () async {
        final owner = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'owner',
            {},
          ),
        );
        final customer = builder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'customer',
            {},
          ),
        );
        final restaurant = await api.restaurant.create(
          owner,
          'Concurrent',
          'EUR',
          0,
        );
        final product = await api.restaurant.saveProduct(
          owner,
          restaurant.id!,
          null,
          'Meal',
          '',
          1000,
          true,
        );
        await api.restaurant.publish(owner, restaurant.id!, true);
        final orders = await Future.wait(
          List.generate(
            4,
            (_) => api.commerce.placeOrder(
              customer,
              restaurant.id!,
              [CartLine(productId: product.id!, quantity: 1)],
              'pickup',
              null,
              'concurrent_request_001',
            ),
          ),
        );
        expect(orders.map((o) => o.id).toSet(), hasLength(1));
        expect(await PurchaseOrder.db.count(builder.build()), 1);
        final order = orders.first;
        await PaymentAttempt.db.insertRow(
          builder.build(),
          PaymentAttempt(
            orderId: order.id!,
            requestId: 'attempt',
            providerOrderId: 'PROVIDER',
            state: 'awaitingApproval',
            createdAt: DateTime.now().toUtc(),
          ),
        );
        final gateway = PayPalGateway(
          client: MockClient((_) async => http.Response('{}', 500)),
          clientId: 'test',
          secret: 'test',
          merchantId: 'MERCHANT',
          webhookId: 'WEBHOOK',
          returnUrl: Uri.https('example.test', '/return'),
          cancelUrl: Uri.https('example.test', '/cancel'),
        );
        final result = <String, dynamic>{
          'id': 'PROVIDER',
          'status': 'COMPLETED',
          'purchase_units': [
            {
              'reference_id': order.id.toString(),
              'payee': {'merchant_id': 'MERCHANT'},
              'payments': {
                'captures': [
                  {
                    'id': 'CAPTURE',
                    'status': 'COMPLETED',
                    'final_capture': true,
                    'amount': {'currency_code': 'EUR', 'value': '10.00'},
                  },
                ],
              },
            },
          ],
        };
        await Future.wait(
          List.generate(
            4,
            (_) => PaymentService(
              gateway,
            ).reconcile(builder.build(), order.id!, result),
          ),
        );
        expect(await PaymentReceipt.db.count(builder.build()), 1);
        expect(await OutboxEvent.db.count(builder.build()), 1);
        gateway.close();
      },
    );
  }, rollbackDatabase: RollbackDatabase.disabled);
}
