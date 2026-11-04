part of 'platform.dart';

/// The derived double-entry journal (plan section 3): one function turns
/// captures, refunds, fees, payouts, expenses, bills and requests into
/// balanced lines. Only manual facts are stored (LedgerAdjustment).
/// Owner: stream S1.
class LedgerModule {
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

  /// Who may read the journal and the accountant's pages.
  static const roles = _finance;
}
