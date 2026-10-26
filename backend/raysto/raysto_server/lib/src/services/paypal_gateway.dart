import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';
import 'raysto_service.dart';

/// Sandbox-only gateway. Runtime payments do not depend on an agent/MCP server.
class PayPalGateway {
  final http.Client client;
  final String clientId;
  final String secret;
  final String merchantId;
  final String webhookId;
  final Uri returnUrl;
  final Uri cancelUrl;
  static final base = Uri.parse('https://api-m.sandbox.paypal.com');

  PayPalGateway({
    required this.client,
    required this.clientId,
    required this.secret,
    required this.merchantId,
    required this.webhookId,
    required this.returnUrl,
    required this.cancelUrl,
  });

  factory PayPalGateway.fromEnvironment() {
    String requiredValue(String key) {
      final value = Platform.environment[key];
      if (value == null || value.trim().isEmpty) {
        RaystoService.fail(
          'not_configured',
          'PayPal sandbox is not configured.',
        );
      }
      return value;
    }

    Uri callback(String key) {
      final uri = Uri.parse(requiredValue(key));
      if (uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty) {
        RaystoService.fail(
          'not_configured',
          'PayPal callbacks must be HTTPS URLs.',
        );
      }
      return uri;
    }

    return PayPalGateway(
      client: http.Client(),
      clientId: requiredValue('PAYPAL_CLIENT_ID'),
      secret: requiredValue('PAYPAL_CLIENT_SECRET'),
      merchantId: requiredValue('PAYPAL_MERCHANT_ID'),
      webhookId: requiredValue('PAYPAL_WEBHOOK_ID'),
      returnUrl: callback('PAYPAL_RETURN_URL'),
      cancelUrl: callback('PAYPAL_CANCEL_URL'),
    );
  }

  void close() => client.close();

  Future<String> _token() async {
    final response = await client
        .post(
          base.resolve('/v1/oauth2/token'),
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: 'grant_type=client_credentials',
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      RaystoService.fail(
        'provider_unavailable',
        'PayPal authorization failed.',
      );
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['access_token']
        as String;
  }

  Future<Map<String, dynamic>> call(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? requestId,
  }) async {
    final request = http.Request(method, base.resolve(path));
    request.headers.addAll({
      'Authorization': 'Bearer ${await _token()}',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
      'PayPal-Request-Id': ?requestId,
    });
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await client.send(request).timeout(const Duration(seconds: 25)),
    ).timeout(const Duration(seconds: 25));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Expose only a known actionable code, never the provider response body.
      try {
        final failure = jsonDecode(response.body) as Map<String, dynamic>;
        final details = failure['details'] as List? ?? [];
        if (details.any(
          (d) => d is Map && d['issue'] == 'ORDER_NOT_APPROVED',
        )) {
          RaystoService.fail(
            'approval_required',
            'Approve this checkout in PayPal first.',
          );
        }
      } on FormatException catch (_) {
        // A non-JSON upstream failure remains an uncertain operation.
      }
      // Do not expose provider bodies, credentials, or customer details to clients/logs.
      RaystoService.fail(
        'provider_unavailable',
        'PayPal did not confirm the operation. Retry using the same order.',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static String money(int minor) =>
      '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';

  static int parseMoney(String value) {
    if (!RegExp(r'^\d{1,8}\.\d{2}$').hasMatch(value)) {
      RaystoService.fail('payment_mismatch', 'Invalid provider amount.');
    }
    final parts = value.split('.');
    return int.parse(parts[0]) * 100 + int.parse(parts[1]);
  }

  Future<Map<String, dynamic>> create(PurchaseOrder order, String requestId) =>
      createCheckout(
        reference: order.id.toString(),
        amountMinor: order.totalMinor,
        currency: order.currency,
        requestId: requestId,
      );

  Future<Map<String, dynamic>> createCheckout({
    required String reference,
    required int amountMinor,
    required String currency,
    required String requestId,
    String? description,
  }) => call(
    'POST',
    '/v2/checkout/orders',
    requestId: requestId,
    body: {
      'intent': 'CAPTURE',
      'purchase_units': [
        {
          'reference_id': reference,
          'custom_id': reference,
          'description': ?description,
          'payee': {'merchant_id': merchantId},
          'amount': {
            'currency_code': currency,
            'value': money(amountMinor),
          },
        },
      ],
      'payment_source': {
        'paypal': {
          'experience_context': {
            'return_url': returnUrl.toString(),
            'cancel_url': cancelUrl.toString(),
            'user_action': 'PAY_NOW',
            'shipping_preference': 'NO_SHIPPING',
          },
        },
      },
    },
  );

  Future<Map<String, dynamic>> getOrder(String id) =>
      call('GET', '/v2/checkout/orders/${Uri.encodeComponent(id)}');
  Future<Map<String, dynamic>> capture(String id, String key) => call(
    'POST',
    '/v2/checkout/orders/${Uri.encodeComponent(id)}/capture',
    requestId: key,
    body: {},
  );

  Future<bool> verifyWebhook(
    Map<String, String> headers,
    Map<String, dynamic> event,
  ) async {
    const required = [
      'paypal-auth-algo',
      'paypal-cert-url',
      'paypal-transmission-id',
      'paypal-transmission-sig',
      'paypal-transmission-time',
    ];
    if (required.any((key) => !headers.containsKey(key))) return false;
    final result = await call(
      'POST',
      '/v1/notifications/verify-webhook-signature',
      body: {
        'auth_algo': headers['paypal-auth-algo'],
        'cert_url': headers['paypal-cert-url'],
        'transmission_id': headers['paypal-transmission-id'],
        'transmission_sig': headers['paypal-transmission-sig'],
        'transmission_time': headers['paypal-transmission-time'],
        'webhook_id': webhookId,
        'webhook_event': event,
      },
    );
    return result['verification_status'] == 'SUCCESS';
  }
}
