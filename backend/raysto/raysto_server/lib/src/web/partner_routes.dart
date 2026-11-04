import 'package:serverpod/serverpod.dart';
import 'api_routes.dart';

/// `/api/partner/v1/**`: the Delivery Partner API (Bearer key, HMAC
/// signature, idempotency key). Owner: stream S2. Not built yet.
class PartnerRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async =>
      jsonResponse(404, {'error': 'not_found'});
}
