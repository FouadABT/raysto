import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../platform/platform.dart';

/// `/pay/{token}`: a payment request's stable link. It opens (or refreshes)
/// the request's own Orders v2 checkout and redirects to PayPal; a paid or
/// cancelled request says so in plain words. The token is checked by its
/// hash only, and the page never shows the payer's or the café's data.
class PayLinkRoute extends Route {
  PayLinkRoute() : super(methods: {Method.get});

  static final _token = RegExp(r'^[a-f0-9]{32}$');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final segments = request.url.pathSegments.where((p) => p.isNotEmpty).toList();
    final token = segments.isEmpty ? '' : segments.last;
    if (!_token.hasMatch(token)) {
      return _page(404, 'This payment link is not valid.');
    }
    try {
      final result = await PaymentRequestModule.open(session, token);
      if (result.redirect != null) {
        return Response.found(
          Uri.parse(result.redirect!),
          headers: Headers.build(
            (h) => h.cacheControl = CacheControlHeader(noStore: true),
          ),
        );
      }
      return _page(result.status, result.message);
    } on DomainError catch (e) {
      return _page(
        e.code == 'rate_limited' ? 429 : 503,
        e.code == 'rate_limited'
            ? 'Too many attempts. Wait a minute and open the link again.'
            : 'PayPal is not available for this request right now. Try again later.',
      );
    } catch (_) {
      return _page(503, 'PayPal is not answering right now. Try again in a minute.');
    }
  }

  static Response _page(int status, String message) {
    final safe = message
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return Response(
      status,
      headers: Headers.build(
        (h) => h..cacheControl = CacheControlHeader(noStore: true),
      ),
      body: Body.fromString(
        '<!doctype html><html lang="en"><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>Raysto payment</title><style>'
        'body{font-family:system-ui,sans-serif;background:#f6f7f2;color:#173e34;'
        'display:grid;place-items:center;min-height:100vh;margin:0;padding:16px}'
        'main{max-width:420px;background:#fff;border-radius:16px;padding:24px;'
        'box-shadow:0 1px 3px rgba(0,0,0,.08)}h1{font-size:20px;margin:0 0 8px}'
        'p{margin:0;line-height:1.5}</style></head><body><main>'
        '<h1>Raysto payment</h1><p>$safe</p></main></body></html>',
        mimeType: MimeType.html,
      ),
    );
  }
}

