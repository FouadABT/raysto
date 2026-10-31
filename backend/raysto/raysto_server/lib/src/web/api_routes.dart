import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../platform/platform.dart';
import '../services/payment_service.dart';
import '../services/raysto_service.dart';

Response jsonResponse(int status, Object value) => Response(
  status,
  body: Body.fromString(jsonEncode(value), mimeType: MimeType.json),
);

class HealthRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    await session.db.unsafeQuery('SELECT 1');
    return jsonResponse(200, {
      'status': 'ok',
      'service': 'raysto',
      'paymentEnvironment': 'sandbox',
    });
  }
}

/// Fixed, paginated order reports for the future AG Grid dashboard.
class OrderReportRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    try {
      final query = request.url.queryParameters;
      final restaurantId = int.tryParse(query['restaurantId'] ?? '');
      if (restaurantId == null) {
        return jsonResponse(400, {'error': 'restaurantId_required'});
      }
      final offset = int.tryParse(query['offset'] ?? '0');
      final limit = int.tryParse(query['limit'] ?? '50');
      if (offset == null || limit == null) {
        return jsonResponse(400, {'error': 'invalid_page'});
      }
      final rows = await RaystoService.report(
        session,
        restaurantId,
        offset,
        limit,
      );
      return jsonResponse(200, {
        'rows': [
          for (final row in rows)
            {
              'id': row.id,
              'restaurantId': row.restaurantId,
              'status': row.status,
              'paymentStatus': row.paymentStatus,
              'fulfillment': row.fulfillment,
              'totalMinor': row.totalMinor,
              'currency': row.currency,
              'createdAt': row.createdAt.toIso8601String(),
            },
        ],
        'offset': offset,
        'limit': limit,
        'nextOffset': rows.length == limit ? offset + rows.length : null,
      });
    } on DomainError catch (error) {
      return jsonResponse(
        switch (error.code) {
          'unauthorized' => 401,
          'forbidden' => 403,
          _ => 400,
        },
        {'error': error.code},
      );
    }
  }
}

class PayPalWebhookRoute extends Route {
  PayPalWebhookRoute() : super(methods: {Method.post});
  @override
  Future<Result> handleCall(Session session, Request request) async {
    try {
      final raw = await request.readAsString();
      if (raw.length > 262144) {
        return jsonResponse(413, {'error': 'event_too_large'});
      }
      final event = jsonDecode(raw) as Map<String, dynamic>;
      final headers = <String, String>{};
      for (final name in [
        'paypal-auth-algo',
        'paypal-cert-url',
        'paypal-transmission-id',
        'paypal-transmission-sig',
        'paypal-transmission-time',
      ]) {
        final value = request.headers[name];
        if (value != null) headers[name] = value.join(',');
      }
      await PaymentService.configured().webhook(session, headers, event);
      return jsonResponse(200, {'received': true});
    } on DomainError catch (error) {
      return jsonResponse(error.code == 'forbidden' ? 401 : 503, {
        'error': error.code,
      });
    } on FormatException {
      return jsonResponse(400, {'error': 'invalid_json'});
    } on TypeError {
      return jsonResponse(400, {'error': 'invalid_event'});
    }
  }
}

class PayPalReturnRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    var text =
        'Return to Raysto to check your payment status. This page does not confirm payment.';
    final q = request.url.queryParameters;
    final id = int.tryParse(q['checkoutId'] ?? '');
    // PayPal appends its order id as `token`; only the payer holds it, so a
    // match lets a walk-in without the app be captured right away. The
    // capture itself still re-reads PayPal and checks every amount.
    if (request.url.path.endsWith('/return') && q['v'] == '2' && id != null) {
      try {
        final checkout = await CheckoutIntent.db.findById(session, id);
        final token = q['token'];
        if (checkout != null &&
            token != null &&
            checkout.providerOrderId == token) {
          final result = await MoneyModule.settleApproved(session, id);
          if (result['state'] == 'completed') {
            text = 'Payment received. Thank you.';
          }
        }
      } catch (_) {
        // The neutral message stands; the worker keeps reconciling.
      }
    }
    return Response.ok(body: Body.fromString(text));
  }
}
