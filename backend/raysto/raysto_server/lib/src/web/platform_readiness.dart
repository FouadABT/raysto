import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'api_routes.dart';

/// Readiness checks local schema/configuration only; never probes providers.
class PlatformReadinessRoute extends Route {
  @override
  Future<Result> handleCall(Session s, Request r) async {
    try {
      await s.db.unsafeQuery('SELECT 1');
      final enabled =
          Platform.environment['RAYSTO_PLATFORM_V2_ENABLED'] == 'true';
      if (!enabled) {
        return jsonResponse(200, {
          'status': 'ready',
          'platformV2': 'disabled',
          'providers': 'not_probed',
        });
      }
      final schema = await s.db.unsafeQuery(
        "SELECT to_regclass('raysto_payment_exception') IS NOT NULL AND EXISTS(SELECT 1 FROM pg_constraint WHERE conname='bill_nonnegative') AS ready",
      );
      final keys = [
        'FIREBASE_PROJECT_ID',
        'FIREBASE_PROJECT_NUMBER',
        'FIREBASE_ALLOWED_APP_IDS',
        'GOOGLE_APPLICATION_CREDENTIALS',
      ];
      final missing = keys
          .where((k) => (Platform.environment[k] ?? '').isEmpty)
          .toList();
      final ready = schema.first.first == true && missing.isEmpty;
      return jsonResponse(ready ? 200 : 503, {
        'status': ready ? 'ready' : 'not_ready',
        'platformV2': 'enabled',
        'schemaReady': schema.first.first == true,
        'missingConfiguration': missing,
        'providers': 'not_probed',
      });
    } catch (_) {
      return jsonResponse(503, {
        'status': 'not_ready',
        'database': 'unavailable',
      });
    }
  }
}
