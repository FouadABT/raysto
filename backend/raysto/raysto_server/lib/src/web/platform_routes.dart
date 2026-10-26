import 'dart:convert';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../platform/platform.dart';
import 'api_routes.dart';

/// Bounded request bodies, bearer authentication, and fixed command registry.
class PlatformRoute extends Route {
  PlatformRoute() : super(methods: {Method.get, Method.post, Method.put});
  Future<Uint8List> bytes(Request request, int limit) async {
    final out = BytesBuilder(copy: false);
    await for (final part
        in request.body
            .read(maxLength: limit)
            .timeout(const Duration(seconds: 15))) {
      out.add(part);
    }
    return out.takeBytes();
  }

  @override
  Future<Result> handleCall(Session s, Request r) async {
    final requestId = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    try {
      PlatformApi.enabled();
      PlatformApi.bindHttpHeaders(s, {
        for (final name in ['x-raysto-firebase-token', 'x-firebase-appcheck'])
          if (r.headers[name]?.first != null) name: r.headers[name]!.first,
      });
      final path = r.url.path.substring('/api/v2/'.length);
      final auth = r.headers['authorization']?.first;
      if (auth != null && auth.startsWith('Bearer ')) {
        s.updateAuthenticated(
          await AuthServices.instance.tokenManager.validateToken(
            s,
            auth.substring(7),
          ),
        );
      }
      if (path.startsWith('webhooks/') && r.method == Method.post) {
        final event =
            jsonDecode(utf8.decode(await bytes(r, 262144)))
                as Map<String, dynamic>;
        final headers = <String, String>{};
        for (final k in [
          'paypal-auth-algo',
          'paypal-cert-url',
          'paypal-transmission-id',
          'paypal-transmission-sig',
          'paypal-transmission-time',
        ]) {
          final v = r.headers[k]?.first;
          if (v != null) headers[k] = v;
        }
        if (!{
          'webhooks/paypal-platform',
          'webhooks/paypal-billing',
        }.contains(path)) {
          return jsonResponse(404, {'error': 'not_found'});
        }
        await PlatformWorker.inbox(
          s,
          event,
          headers,
          billing: path.endsWith('billing'),
        );
        return jsonResponse(200, {'received': true});
      }
      if ({'auth/firebase', 'auth/guest'}.contains(path) &&
          r.method == Method.post) {
        final d =
            jsonDecode(utf8.decode(await bytes(r, 20000)))
                as Map<String, dynamic>;
        return jsonResponse(200, {
          'requestId': requestId,
          'data': await IdentityModule.exchange(
            s,
            d,
            guest: path.endsWith('guest'),
          ),
        });
      }
      if (path.startsWith('queries/') && r.method == Method.get) {
        final d = <String, dynamic>{};
        for (final entry in r.url.queryParameters.entries) {
          d[entry.key] = {'latitude', 'longitude'}.contains(entry.key)
              ? double.tryParse(entry.value) ?? entry.value
              : {
                  'restaurantId',
                  'id',
                  'cursor',
                  'limit',
                  'visitId',
                  'orderId',
                  'partySize',
                }.contains(entry.key)
              ? int.tryParse(entry.value) ?? entry.value
              : {'staff', 'openNow'}.contains(entry.key)
              ? entry.value == 'true'
                    ? true
                    : entry.value == 'false'
                    ? false
                    : entry.value
              : entry.value;
        }
        return jsonResponse(200, {
          'requestId': requestId,
          'data': await PlatformQueries.query(s, path.substring(8), d),
        });
      }
      final file = RegExp(r'^media/(\d+)$').firstMatch(path);
      if (file != null && r.method == Method.get) {
        final (content, mime) = await PlatformFiles.read(
          s,
          int.parse(file.group(1)!),
        );
        final parts = mime.split('/');
        return Response.ok(
          body: Body.fromData(content, mimeType: MimeType(parts[0], parts[1])),
        );
      }
      await PlatformApi.guard(s);
      if (path == 'events' && r.method == Method.get) {
        final tenant = int.tryParse(
          r.url.queryParameters['restaurantId'] ?? '',
        );
        final cursor = int.tryParse(r.url.queryParameters['after'] ?? '0');
        if (tenant == null || cursor == null || cursor < 0) {
          return jsonResponse(400, {'error': 'invalid_input'});
        }
        final events = PlatformQueries.events(s, tenant, cursor).map(
          (e) => Uint8List.fromList(
            utf8.encode(
              'id: ${e.cursor}\nevent: ${e.kind}\ndata: ${jsonEncode({'cursor': e.cursor, 'kind': e.kind, 'createdAt': e.createdAt.toIso8601String()})}\n\n',
            ),
          ),
        );
        return Response.ok(
          body: Body.fromDataStream(
            events,
            mimeType: MimeType('text', 'event-stream'),
          ),
        );
      }
      final media = RegExp(r'^media/(\d+)/content$').firstMatch(path);
      if (media != null && r.method == Method.put) {
        return jsonResponse(
          200,
          await AiModule.uploadBytes(
            s,
            int.parse(media.group(1)!),
            await bytes(r, 8388608),
          ),
        );
      }
      if (!path.startsWith('commands/') || r.method != Method.post) {
        return jsonResponse(404, {'error': 'not_found'});
      }
      final d =
          jsonDecode(utf8.decode(await bytes(r, 131072)))
              as Map<String, dynamic>;
      final op = path.substring(9);
      Object result;
      switch (op) {
        case 'quote.create':
          result = await OrderingModule.quote(s, CreateQuote.fromJson(d));
        case 'order.submit':
          result = await OrderingModule.submit(s, SubmitOrder.fromJson(d));
        case 'visit.start':
          result = await DiningModule.start(s, StartVisit.fromJson(d));
        case 'payment.allocate':
          result = await MoneyModule.allocate(s, AllocatePayment.fromJson(d));
        case 'payment.refund':
          result = await MoneyModule.refund(s, RequestRefund.fromJson(d));
        default:
          final response = await PlatformApi.command(
            s,
            op,
            PlatformCommand.fromJson(d),
          );
          result = jsonDecode(response.dataJson);
      }
      return jsonResponse(200, {
        'requestId': d['requestKey'] ?? requestId,
        'data': result,
      });
    } on DomainError catch (e) {
      final status = switch (e.code) {
        'unauthorized' || 'firebase_proof_required' => 401,
        'forbidden' || 'mfa_required' || 'invalid_app_check' => 403,
        'not_found' => 404,
        'not_enabled' => 503,
        'rate_limited' || 'quota_exceeded' => 429,
        'provider_unavailable' || 'storage_unavailable' => 503,
        'version_conflict' ||
        'idempotency_conflict' ||
        'payment_pending' ||
        'stale_proposal' => 409,
        _ => 400,
      };
      return jsonResponse(status, {
        'error': {
          'code': e.code,
          'message': e.message,
          'requestId': requestId,
          'retryable': {
            'provider_unavailable',
            'payment_pending',
            'rate_limited',
          }.contains(e.code),
          'fieldErrors': <Object>[],
        },
      });
    } on FormatException {
      return jsonResponse(400, {
        'error': {'code': 'invalid_json', 'requestId': requestId},
      });
    } on TypeError {
      return jsonResponse(400, {
        'error': {'code': 'invalid_input', 'requestId': requestId},
      });
    } catch (_) {
      s.log('Platform request failed ($requestId)', level: LogLevel.error);
      return jsonResponse(500, {
        'error': {'code': 'internal_error', 'requestId': requestId},
      });
    }
  }
}
