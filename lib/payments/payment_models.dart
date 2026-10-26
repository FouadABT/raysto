/// Provider-independent amounts use minor units; no floating-point payment math.
class PaymentAmount {
  PaymentAmount(this.minor, this.currency) {
    if (minor < 1 ||
        minor > 9999999999 ||
        !{'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'CHF'}.contains(currency)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
  }
  final int minor;
  final String currency;
  String get decimal =>
      '${minor ~/ 100}.${(minor % 100).toString().padLeft(2, '0')}';
  String get label => '$decimal $currency';
  bool matches(PaymentAmount other) =>
      minor == other.minor && currency == other.currency;
}

class PaymentOrder {
  const PaymentOrder({
    required this.reference,
    required this.amount,
    required this.paid,
  });
  final String reference;
  final PaymentAmount amount;

  /// Must come from the authenticated backend, never from a browser callback.
  final bool paid;
}

class PaymentApproval {
  const PaymentApproval({
    required this.reference,
    required this.providerId,
    required this.url,
  });
  final String reference;
  final String providerId;
  final Uri url;
}

class PendingPayment {
  const PendingPayment({
    required this.reference,
    required this.amount,
    this.approval,
    this.opened = false,
  });
  final String reference;
  final PaymentAmount amount;
  final PaymentApproval? approval;
  final bool opened;
  Map<String, Object?> toJson() => {
    'version': 1,
    'reference': reference,
    'minor': amount.minor,
    'currency': amount.currency,
    'providerId': approval?.providerId,
    'approvalUrl': approval?.url.toString(),
    'opened': opened,
  };
  factory PendingPayment.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 ||
        json['reference'] is! String ||
        json['minor'] is! int ||
        json['currency'] is! String ||
        (json['providerId'] == null) != (json['approvalUrl'] == null)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    final reference = json['reference'] as String;
    return PendingPayment(
      reference: reference,
      opened: json['opened'] == true,
      amount: PaymentAmount(json['minor'] as int, json['currency'] as String),
      approval: json['providerId'] == null
          ? null
          : PaymentApproval(
              reference: reference,
              providerId: json['providerId'] as String,
              url: Uri.parse(json['approvalUrl'] as String),
            ),
    );
  }
}

abstract interface class PaymentBackend {
  Future<PaymentOrder> read(String reference);
  Future<PaymentApproval> prepare(String reference);
  Future<PaymentOrder> complete(String reference);
}

abstract interface class PaymentStore {
  Future<PendingPayment?> read(String owner);
  Future<void> write(String owner, PendingPayment payment);
  Future<void> clear(String owner);
}

abstract interface class PaymentBrowser {
  Future<bool> open(Uri url);
}

enum PaymentProblem {
  unavailable,
  storage,
  invalidResponse,
  notApproved,
  reconciliationRequired,
  notAllowed,
}

class PaymentException implements Exception {
  const PaymentException(this.problem);
  final PaymentProblem problem;
}

enum PaymentPhase {
  idle,
  restoring,
  preparing,
  ready,
  away,
  checking,
  completing,
  paid,
  paused,
  needsAttention,
}

class PaymentSnapshot {
  const PaymentSnapshot({
    this.phase = PaymentPhase.idle,
    this.payment,
    this.problem,
  });
  final PaymentPhase phase;
  final PendingPayment? payment;
  final PaymentProblem? problem;
  bool get busy => {
    PaymentPhase.restoring,
    PaymentPhase.preparing,
    PaymentPhase.checking,
    PaymentPhase.completing,
  }.contains(phase);
  bool get paid => phase == PaymentPhase.paid;
  bool get blocked => {
    PaymentProblem.invalidResponse,
    PaymentProblem.reconciliationRequired,
    PaymentProblem.notAllowed,
    PaymentProblem.storage,
  }.contains(problem);
  bool get canOpen => !busy && !paid && !blocked && payment?.approval != null;
  bool get canComplete => canOpen;
}

/// Sandbox-only policy. A callback is an untrusted hint, never a receipt.
class PayPalLinkPolicy {
  PayPalLinkPolicy({required this.callbackOrigin});
  final Uri callbackOrigin;

  bool validApproval(PaymentApproval approval) {
    final u = approval.url;
    return RegExp(r'^[A-Z0-9]{8,40}$').hasMatch(approval.providerId) &&
        u.scheme == 'https' &&
        u.userInfo.isEmpty &&
        !u.hasFragment &&
        (!u.hasPort || u.port == 443) &&
        {'sandbox.paypal.com', 'www.sandbox.paypal.com'}.contains(u.host) &&
        u.path == '/checkoutnow' &&
        u.queryParametersAll['token']?.length == 1 &&
        u.queryParameters['token'] == approval.providerId;
  }

  /// Android may forward only the path/query through Flutter's default router.
  bool isCallback(Uri u) =>
      (u.scheme.isEmpty && !u.hasAuthority ||
          u.scheme == callbackOrigin.scheme &&
              u.host == callbackOrigin.host &&
              u.port == callbackOrigin.port) &&
      u.userInfo.isEmpty &&
      !u.hasFragment &&
      {'/payments/return', '/payments/cancel'}.contains(u.path);

  bool matchesCallback(Uri u, PendingPayment pending) =>
      isCallback(u) &&
      pending.approval != null &&
      u.queryParametersAll['token']?.length == 1 &&
      u.queryParameters['token'] == pending.approval!.providerId;
}
