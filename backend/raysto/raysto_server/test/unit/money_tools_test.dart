import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

// The money-out and ledger reads on the Sandbox app: Payouts, Transaction
// Search and Disputes. A mock transport; no provider request is made.
void main() {
  final calls = <String>[];
  late Map<String, http.Response Function(http.Request)> routes;

  setUp(() {
    calls.clear();
    routes = {};
    ProviderClients.httpClient = () => MockClient((request) async {
      final route = '${request.method} ${request.url.path}';
      calls.add(route);
      if (request.url.path == '/v1/oauth2/token') {
        return http.Response(jsonEncode({'access_token': 'fixture'}), 200);
      }
      final handler = routes[route];
      return handler == null ? http.Response('{}', 404) : handler(request);
    });
    ProviderClients.environment = () => {
      ...Platform.environment,
      'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
      'RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED': 'true',
      'PAYPAL_SANDBOX_MERCHANT_ID': 'MERCHANT-FIXTURE',
      'PAYPAL_SANDBOX_CLIENT_ID': 'fixture-client',
      'PAYPAL_SANDBOX_CLIENT_SECRET': 'fixture-secret',
    };
  });
  tearDown(() {
    ProviderClients.httpClient = http.Client.new;
    ProviderClients.environment = () => Platform.environment;
  });

  test('a payout batch is sent once with its idempotency key and read back', () async {
    Map<String, dynamic>? sent;
    String? requestId;
    routes['POST /v1/payments/payouts'] = (r) {
      sent = jsonDecode(r.body) as Map<String, dynamic>;
      requestId = r.headers['PayPal-Request-Id'];
      return http.Response(
        jsonEncode({
          'batch_header': {'payout_batch_id': 'BATCH1', 'batch_status': 'PENDING'},
        }),
        201,
      );
    };
    routes['GET /v1/payments/payouts/BATCH1'] = (r) => http.Response(
      jsonEncode({
        'batch_header': {
          'payout_batch_id': 'BATCH1',
          'batch_status': 'SUCCESS',
          'fees': {'value': '0.50', 'currency': 'USD'},
        },
        'items': [
          {
            'payout_item_id': 'ITEM1',
            'transaction_status': 'SUCCESS',
            'transaction_id': 'TX1',
            'payout_item': {
              'sender_item_id': 'tips-1',
              'amount': {'value': '12.50', 'currency': 'USD'},
            },
          },
        ],
      }),
      200,
    );
    final created = await ProviderClients.createPayout(
      batchId: 'tips-2026-11-03',
      currency: 'USD',
      items: [
        {'email': 'staff@example.test', 'amountMinor': 1250, 'note': 'Tips', 'itemId': 'tips-1'},
      ],
    );
    expect(created, {'id': 'BATCH1', 'status': 'PENDING'});
    expect(requestId, 'payout-tips-2026-11-03');
    expect(sent!['sender_batch_header']['sender_batch_id'], 'tips-2026-11-03');
    final item = (sent!['items'] as List).single as Map;
    expect(item['receiver'], 'staff@example.test');
    expect(item['amount'], {'value': '12.50', 'currency': 'USD'});
    final read = await ProviderClients.readPayout('BATCH1');
    expect(read['status'], 'SUCCESS');
    expect(read['feesMinor'], 50);
    final first = (read['items'] as List).single as Map;
    expect(first['amountMinor'], 1250);
    expect(first['transactionId'], 'TX1');
    expect(first['itemId'], 'tips-1');
  });

  test('a disabled Sandbox feature is reported as such, not as unavailable', () async {
    routes['GET /v1/reporting/transactions'] = (r) => http.Response(
      jsonEncode({'name': 'NOT_AUTHORIZED', 'message': 'Authorization failed'}),
      403,
    );
    await expectLater(
      ProviderClients.listTransactions(
        DateTime.utc(2026, 11, 2),
        DateTime.utc(2026, 11, 3),
      ),
      throwsA(
        isA<DomainError>().having((e) => e.code, 'code', 'provider_feature_disabled'),
      ),
    );
  });

  test('transactions and fees come back in minor units with their sign', () async {
    routes['GET /v1/reporting/transactions'] = (r) {
      expect(r.url.queryParameters['start_date'], '2026-11-02T00:00:00Z');
      expect(r.url.queryParameters['end_date'], '2026-11-03T00:00:00Z');
      return http.Response(
        jsonEncode({
          'transaction_details': [
            {
              'transaction_info': {
                'transaction_id': 'T1',
                'transaction_event_code': 'T0006',
                'transaction_status': 'S',
                'transaction_initiation_date': '2026-11-02T12:00:00+0000',
                'transaction_amount': {'currency_code': 'USD', 'value': '21.50'},
                'fee_amount': {'currency_code': 'USD', 'value': '-0.92'},
                'custom_field': 'raysto-v2:9',
              },
            },
            {
              'transaction_info': {
                'transaction_id': 'T2',
                'transaction_event_code': 'T1107',
                'transaction_status': 'S',
                'transaction_amount': {'currency_code': 'USD', 'value': '-2.20'},
              },
            },
          ],
        }),
        200,
      );
    };
    final rows = await ProviderClients.listTransactions(
      DateTime.utc(2026, 11, 2),
      DateTime.utc(2026, 11, 3),
    );
    expect(rows.length, 2);
    expect(rows[0]['amountMinor'], 2150);
    expect(rows[0]['feeMinor'], -92);
    expect(rows[0]['customId'], 'raysto-v2:9');
    expect(rows[1]['amountMinor'], -220);
    expect(rows[1]['feeMinor'], 0);
    expect(
      () => ProviderClients.listTransactions(
        DateTime.utc(2026, 10, 1),
        DateTime.utc(2026, 11, 3),
      ),
      throwsA(isA<DomainError>()),
    );
  });

  test('disputes are listed and read with their disputed captures', () async {
    final dispute = {
      'dispute_id': 'PP-D-1',
      'reason': 'MERCHANDISE_OR_SERVICE_NOT_AS_DESCRIBED',
      'status': 'WAITING_FOR_SELLER_RESPONSE',
      'dispute_life_cycle_stage': 'INQUIRY',
      'dispute_amount': {'currency_code': 'USD', 'value': '7.50'},
      'create_time': '2026-11-02T10:00:00Z',
      'seller_response_due_date': '2026-11-09T10:00:00Z',
      'disputed_transactions': [
        {'seller_transaction_id': 'CAP1'},
      ],
    };
    routes['GET /v1/customer/disputes'] = (r) =>
        http.Response(jsonEncode({'items': [dispute]}), 200);
    routes['GET /v1/customer/disputes/PP-D-1'] = (r) =>
        http.Response(jsonEncode(dispute), 200);
    final listed = await ProviderClients.listDisputes();
    expect(listed.single['id'], 'PP-D-1');
    expect(listed.single['amountMinor'], 750);
    expect(listed.single['captureIds'], ['CAP1']);
    final one = await ProviderClients.getDispute('PP-D-1');
    expect(one['stage'], 'INQUIRY');
    expect(() => ProviderClients.getDispute('../x'), throwsA(isA<DomainError>()));
  });
}
