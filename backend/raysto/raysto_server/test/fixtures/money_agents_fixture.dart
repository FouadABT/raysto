import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/platform/platform.dart' show Json;
import 'package:raysto_server/src/services/paypal_gateway.dart';

/// One fake upstream for the money agents' tests: PayPal Sandbox (checkout,
/// capture, Transaction Search, Payouts) and Gemini, told apart by host. The
/// model's turns are scripted by [gemini], which sees the request body so a
/// turn can echo tool results back as the real model would.
class MoneyAgentsUpstream {
  MoneyAgentsUpstream({required this.gemini});

  /// Returns the parts of the model's reply for this turn, given the request
  /// body and the turn number (1-based).
  final List<Json> Function(int turn, Json body) gemini;

  int turn = 0;
  final geminiTools = <String>[];

  /// PayPal checkout fakes, keyed by checkout id, as FakePayPal does.
  String status = 'CREATED';
  bool captured = false;
  int checkoutId = 0;
  int amountMinor = 0;
  String currency = 'USD';

  /// Transaction Search: `null` answers 403 NOT_AUTHORIZED.
  List<Json>? transactions;

  /// Payouts received, and the status the fake reports back.
  final payouts = <Json>[];
  String payoutStatus = 'SUCCESS';

  final calls = <String>[];

  /// A JSON reply as PayPal sends it: UTF-8 with its charset declared.
  static http.Response json(Object body, int status) => http.Response.bytes(
    utf8.encode(body is String ? body : jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  Json get _amount => {
    'currency_code': currency,
    'value': PayPalGateway.money(amountMinor),
  };

  Json order() => {
    'id': 'PP-ORDER-$checkoutId',
    'intent': 'CAPTURE',
    'status': captured ? 'COMPLETED' : status,
    'purchase_units': [
      {
        'custom_id': 'raysto-v2:$checkoutId',
        'payee': {'merchant_id': 'MERCHANT-FIXTURE'},
        'amount': _amount,
        if (captured)
          'payments': {
            'captures': [
              {
                'id': 'CAPTURE-$checkoutId',
                'status': 'COMPLETED',
                'final_capture': true,
                'amount': _amount,
              },
            ],
          },
      },
    ],
    'links': [
      {
        'rel': 'payer-action',
        'href':
            'https://www.sandbox.paypal.com/checkoutnow?token=PP-ORDER-$checkoutId',
      },
    ],
  };

  String sse(List<Json> parts) =>
      'data: ${jsonEncode({
        'candidates': [
          {
            'index': 0,
            'content': {'role': 'model', 'parts': parts},
            'finishReason': 'STOP',
          },
        ],
        'usageMetadata': {
          'promptTokenCount': 400,
          'candidatesTokenCount': 60,
          'totalTokenCount': 460,
        },
      })}\r\n\r\n';

  http.Client client() => MockClient((r) async {
    final path = r.url.path;
    calls.add('${r.method} $path');
    if (r.url.host.contains('generativelanguage')) {
      if (path.endsWith(':countTokens')) {
        return json('{"totalTokens": 400}', 200);
      }
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      geminiTools.addAll([
        for (final d
            in (body['tools'] as List).single['functionDeclarations'] as List)
          d['name'] as String,
      ]);
      turn++;
      return http.Response.bytes(
        utf8.encode(sse(gemini(turn, body))),
        200,
        headers: {'content-type': 'text/event-stream; charset=utf-8'},
      );
    }
    if (path == '/v1/oauth2/token') {
      return json({'access_token': 'fixture-token'}, 200);
    }
    if (r.method == 'POST' && path == '/v2/checkout/orders') {
      final body = jsonDecode(r.body) as Map;
      final unit = (body['purchase_units'] as List).single as Map;
      checkoutId = int.parse((unit['custom_id'] as String).split(':').last);
      final amount = unit['amount'] as Map;
      amountMinor = PayPalGateway.parseMoney(amount['value'] as String);
      currency = amount['currency_code'] as String;
      captured = false;
      return json(order(), 201);
    }
    if (r.method == 'GET' && path == '/v2/checkout/orders/PP-ORDER-$checkoutId') {
      return json(order(), 200);
    }
    if (r.method == 'POST' &&
        path == '/v2/checkout/orders/PP-ORDER-$checkoutId/capture') {
      if (status != 'APPROVED') {
        return json('{"name":"UNPROCESSABLE_ENTITY"}', 422);
      }
      captured = true;
      return json(order(), 201);
    }
    if (r.method == 'GET' && path == '/v1/reporting/transactions') {
      final rows = transactions;
      if (rows == null) {
        return json(
          '{"name":"NOT_AUTHORIZED","message":"Authorization failed due to insufficient permissions."}',
          403,
        );
      }
      return json(
        ({
          'transaction_details': [
            for (final t in rows)
              {
                'transaction_info': {
                  'transaction_id': t['id'],
                  'transaction_event_code': t['eventCode'] ?? 'T0006',
                  'transaction_status': t['status'] ?? 'S',
                  'transaction_amount': {
                    'currency_code': currency,
                    'value': t['value'],
                  },
                  'fee_amount': {
                    'currency_code': currency,
                    'value': t['fee'] ?? '0.00',
                  },
                  if (t['customId'] != null) 'custom_field': t['customId'],
                },
              },
          ],
          'total_items': rows.length,
          'total_pages': 1,
        }),
        200,
      );
    }
    if (r.method == 'POST' && path == '/v1/payments/payouts') {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      payouts.add({
        'requestId': r.headers['PayPal-Request-Id'],
        'body': body,
      });
      return json(
        ({
          'batch_header': {
            'payout_batch_id': 'BATCH-${payouts.length}',
            'batch_status': 'PENDING',
            'sender_batch_header': body['sender_batch_header'],
          },
        }),
        201,
      );
    }
    if (r.method == 'GET' && path.startsWith('/v1/payments/payouts/')) {
      final id = path.split('/').last;
      final n = int.tryParse(id.replaceFirst('BATCH-', '')) ?? 0;
      if (n < 1 || n > payouts.length) return json('{}', 404);
      final items = ((payouts[n - 1]['body'] as Map)['items'] as List)
          .cast<Map>();
      return json(
        ({
          'batch_header': {
            'payout_batch_id': id,
            'batch_status': payoutStatus,
            'fees': {'currency': currency, 'value': '0.50'},
          },
          'items': [
            for (var i = 0; i < items.length; i++)
              {
                'payout_item_id': 'ITEM-$n-$i',
                'transaction_id': 'TXN-$n-$i',
                'transaction_status': payoutStatus == 'SUCCESS'
                    ? 'SUCCESS'
                    : 'FAILED',
                'payout_item': {
                  'sender_item_id': items[i]['sender_item_id'],
                  'amount': items[i]['amount'],
                },
              },
          ],
        }),
        200,
      );
    }
    return json('{}', 404);
  });
}

/// The function responses the model received in its latest turn, by tool.
Map<String, Json> toolResults(Json body) {
  final out = <String, Json>{};
  for (final content in (body['contents'] as List).cast<Map>()) {
    for (final part in (content['parts'] as List).cast<Map>()) {
      final fr = part['functionResponse'];
      if (fr is Map) {
        out[fr['name'] as String] = Map<String, dynamic>.from(
          fr['response'] as Map,
        );
      }
    }
  }
  return out;
}
