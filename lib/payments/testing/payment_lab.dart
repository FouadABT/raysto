import '../payment_models.dart';

/// Explicit local QA ports. Never imported by the real Serverpod adapter.
class LabPaymentBackend implements PaymentBackend {
  bool online = true;
  bool approved = false;
  bool paid = false;
  bool loseNextCaptureResponse = false;
  int prepareCalls = 0;
  int captureCalls = 0;
  void _network() {
    if (!online) throw const PaymentException(PaymentProblem.unavailable);
  }

  @override
  Future<PaymentOrder> read(String reference) async {
    _network();
    return PaymentOrder(
      reference: reference,
      amount: PaymentAmount(100, 'USD'),
      paid: paid,
    );
  }

  @override
  Future<PaymentApproval> prepare(String reference) async {
    _network();
    prepareCalls++;
    return PaymentApproval(
      reference: reference,
      providerId: 'LABORDER123456',
      url: Uri.parse(
        'https://www.sandbox.paypal.com/checkoutnow?token=LABORDER123456',
      ),
    );
  }

  @override
  Future<PaymentOrder> complete(String reference) async {
    _network();
    captureCalls++;
    if (!approved) throw const PaymentException(PaymentProblem.notApproved);
    paid = true;
    if (loseNextCaptureResponse) {
      loseNextCaptureResponse = false;
      throw const PaymentException(PaymentProblem.unavailable);
    }
    return read(reference);
  }
}

class MemoryPaymentStore implements PaymentStore {
  final Map<String, PendingPayment> values = {};
  @override
  Future<PendingPayment?> read(String owner) async => values[owner];
  @override
  Future<void> write(String owner, PendingPayment payment) async {
    values[owner] = payment;
  }

  @override
  Future<void> clear(String owner) async {
    values.remove(owner);
  }
}

class LabPaymentBrowser implements PaymentBrowser {
  int opens = 0;
  @override
  Future<bool> open(Uri url) async {
    opens++;
    return true;
  }
}
