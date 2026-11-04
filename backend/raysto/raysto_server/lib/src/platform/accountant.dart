part of 'platform.dart';

/// Bills the café owes (payables): intake by photo or PDF, approval, and
/// payment through PayPal Payouts or "paid elsewhere" with proof.
/// Owner: stream S1.
class BillsModule {
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

/// Money the café is owed (receivables): Orders v2 pay links today, PayPal
/// invoices once Invoicing is enabled on the Sandbox app. Owner: stream S1.
class PaymentRequestModule {
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
