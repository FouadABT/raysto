import 'package:serverpod/serverpod.dart';
import 'api_routes.dart';

/// `/pay/{token}`: a stable pay link that refreshes its Orders v2 checkout
/// and redirects to PayPal. Owner: stream S1. Not built yet.
class PayLinkRoute extends Route {
  PayLinkRoute() : super(methods: {Method.get});

  @override
  Future<Result> handleCall(Session session, Request request) async =>
      jsonResponse(404, {'error': 'not_found'});
}
