part of 'platform.dart';

/// Delivery partner apps: hashed keys, signed webhooks both ways, and the
/// event log judges see (plan section 4). Owner: stream S2.
class PartnerModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {};

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async => null;
}
