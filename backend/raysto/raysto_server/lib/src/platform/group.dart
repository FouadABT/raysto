part of 'platform.dart';

/// Franchise groups: several restaurants under one owner (plan section 2).
/// Owner: stream S4. Group roles only read; every command stays per venue
/// through `_mutate` with a real membership.
class GroupModule {
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
