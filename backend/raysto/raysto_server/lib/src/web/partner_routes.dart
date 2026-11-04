import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../platform/platform.dart';
import 'api_routes.dart';

/// `/api/partner/v1/**`: the Delivery Partner API (Bearer key, HMAC
/// signature, idempotency key). Owner: stream S2. The checks and the
/// endpoints live in [PartnerModule.inbound]; this route only bounds the
/// body (64 KB, 15 seconds) and maps the answer to HTTP.
class PartnerRoute extends Route {
  PartnerRoute() : super(methods: {Method.get, Method.post});

  static const prefix = '/api/partner/v1/';

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final full = request.url.path.startsWith('/')
        ? request.url.path
        : '/${request.url.path}';
    if (!full.startsWith(prefix)) {
      return jsonResponse(404, {
        'error': {'code': 'not_found', 'message': 'Unknown endpoint.'},
      });
    }
    final out = BytesBuilder(copy: false);
    try {
      await for (final part
          in request.body
              .read(maxLength: PartnerModule.maxBytes + 1)
              .timeout(const Duration(seconds: 15))) {
        out.add(part);
        if (out.length > PartnerModule.maxBytes) break;
      }
    } on TimeoutException {
      return jsonResponse(408, {
        'error': {'code': 'timeout', 'message': 'The request body was too slow.'},
      });
    } catch (_) {
      return jsonResponse(413, {
        'error': {
          'code': 'payload_too_large',
          'message': 'Requests are limited to 64 KB.',
        },
      });
    }
    if (out.length > PartnerModule.maxBytes) {
      return jsonResponse(413, {
        'error': {
          'code': 'payload_too_large',
          'message': 'Requests are limited to 64 KB.',
        },
      });
    }
    final String body;
    try {
      body = utf8.decode(out.takeBytes());
    } on FormatException {
      return jsonResponse(400, {
        'error': {'code': 'invalid_input', 'message': 'Send UTF-8 JSON.'},
      });
    }
    final headers = <String, String>{
      for (final name in [
        'authorization',
        'x-raysto-signature',
        'idempotency-key',
      ])
        if (request.headers[name]?.first != null)
          name: request.headers[name]!.first,
    };
    try {
      final (status, value) = await PartnerModule.inbound(
        session,
        method: request.method == Method.post ? 'POST' : 'GET',
        path: full.substring(prefix.length),
        headers: headers,
        body: body,
      );
      return jsonResponse(status, value);
    } catch (_) {
      session.log('Partner request failed', level: LogLevel.error);
      return jsonResponse(500, {
        'error': {'code': 'internal_error', 'message': 'Try again shortly.'},
      });
    }
  }
}
