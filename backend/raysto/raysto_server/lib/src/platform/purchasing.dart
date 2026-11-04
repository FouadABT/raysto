part of 'platform.dart';

/// Supplier orders, recipes and stock movements (plan section 5).
/// Owner: stream S3.
class PurchasingModule {
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
