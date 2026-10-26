import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'paypal_gateway.dart';
import 'raysto_service.dart';

/// Actual Sandbox API operations, isolated from commerce and fulfillment.
class SandboxPaymentService {
  SandboxPaymentService(this.gateway);
  final PayPalGateway gateway;
  factory SandboxPaymentService.configured() =>
      SandboxPaymentService(PayPalGateway.fromEnvironment());

  static Future<SandboxPayment> own(Session s, int id) async {
    final user = RaystoService.user(s);
    final payment = await SandboxPayment.db.findById(s, id);
    if (payment == null || payment.userId != user) {
      RaystoService.fail('not_found', 'Sandbox checkout not found.');
    }
    return payment;
  }

  static Future<SandboxPayment> start(Session s, String key) async {
    final user = RaystoService.user(s);
    if (!RegExp(r'^[a-zA-Z0-9_-]{20,80}$').hasMatch(key)) {
      RaystoService.fail('invalid_input', 'Invalid checkout request key.');
    }
    Future<SandboxPayment?> existing() => SandboxPayment.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(user) & t.requestKey.equals(key),
    );
    final saved = await existing();
    if (saved != null) return saved;
    final now = DateTime.now().toUtc();
    final recent = await SandboxPayment.db.count(
      s,
      where: (t) =>
          t.userId.equals(user) &
          t.createdAt.between(now.subtract(const Duration(days: 1)), now),
    );
    if (recent >= 10) {
      RaystoService.fail(
        'rate_limited',
        'Daily sandbox test limit reached. Resume a saved checkout.',
      );
    }
    try {
      return await SandboxPayment.db.insertRow(
        s,
        SandboxPayment(
          userId: user,
          requestKey: key,
          providerRequestId: const Uuid().v4(),
          amountMinor: 100,
          currency: 'USD',
          state: 'created',
          createdAt: now,
        ),
      );
    } catch (_) {
      // The unique owner/key index also protects simultaneous retries.
      final raced = await existing();
      if (raced != null) return raced;
      rethrow;
    }
  }

  Future<SandboxPayment> checkout(Session s, int id) async {
    try {
      final payment = await own(s, id);
      if (payment.providerOrderId != null || payment.state == 'captured') {
        return payment;
      }
      if (DateTime.now().toUtc().difference(payment.createdAt) >
          const Duration(hours: 3)) {
        RaystoService.fail(
          'reconciliation_required',
          'This checkout needs review before retrying.',
        );
      }
      final response = await gateway.createCheckout(
        reference: 'raysto-sandbox-$id',
        amountMinor: payment.amountMinor,
        currency: payment.currency,
        requestId: payment.providerRequestId,
        description: 'Raysto Sandbox payment test',
      );
      final providerId = response['id'] as String?;
      final links = response['links'] as List? ?? [];
      final link = links
          .whereType<Map>()
          .where((l) => l['rel'] == 'payer-action' || l['rel'] == 'approve')
          .firstOrNull;
      final url = Uri.tryParse(link?['href'] as String? ?? '');
      if (providerId == null ||
          !RegExp(r'^[A-Z0-9]{8,40}$').hasMatch(providerId) ||
          url == null ||
          url.scheme != 'https' ||
          url.userInfo.isNotEmpty ||
          url.fragment.isNotEmpty ||
          url.port != 443 ||
          !{
            'sandbox.paypal.com',
            'www.sandbox.paypal.com',
          }.contains(url.host) ||
          url.path != '/checkoutnow' ||
          url.queryParametersAll['token']?.length != 1 ||
          url.queryParameters['token'] != providerId) {
        RaystoService.fail(
          'payment_mismatch',
          'Invalid PayPal approval details.',
        );
      }
      return await s.db.transaction((tx) async {
        final current = (await SandboxPayment.db.findById(
          s,
          id,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ))!;
        if (current.providerOrderId != null &&
            current.providerOrderId != providerId) {
          RaystoService.fail(
            'payment_mismatch',
            'Conflicting PayPal checkout.',
          );
        }
        current.providerOrderId = providerId;
        current.approvalUrl = url.toString();
        if (current.state != 'captured') current.state = 'awaitingApproval';
        return SandboxPayment.db.updateRow(s, current, transaction: tx);
      });
    } finally {
      gateway.close();
    }
  }

  Future<SandboxPayment> capture(Session s, int id) async {
    try {
      final payment = await own(s, id);
      if (payment.state == 'captured') return payment;
      final providerId = payment.providerOrderId;
      if (providerId == null) {
        RaystoService.fail('conflict', 'Prepare checkout first.');
      }
      var response = await gateway.getOrder(providerId);
      if (response['status'] != 'COMPLETED') {
        if (response['status'] != 'APPROVED') {
          RaystoService.fail(
            'approval_required',
            'Approve this checkout in PayPal first.',
          );
        }
        response = await gateway.capture(
          providerId,
          '${payment.providerRequestId}-capture',
        );
      }
      return await reconcile(s, id, response);
    } finally {
      gateway.close();
    }
  }

  Future<SandboxPayment> reconcile(
    Session s,
    int id,
    Map<String, dynamic> result,
  ) => s.db.transaction((tx) async {
    final payment = (await SandboxPayment.db.findById(
      s,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    ))!;
    final units = result['purchase_units'] as List? ?? [];
    if (result['id'] != payment.providerOrderId ||
        result['status'] != 'COMPLETED' ||
        units.length != 1) {
      RaystoService.fail(
        'payment_mismatch',
        'PayPal has not confirmed this checkout.',
      );
    }
    final unit = units.single as Map;
    final captures = (unit['payments'] as Map?)?['captures'] as List? ?? [];
    if (captures.length != 1) {
      RaystoService.fail('payment_mismatch', 'Unexpected captures.');
    }
    final capture = captures.single as Map;
    final amount = capture['amount'] as Map? ?? {};
    final captureId = capture['id'] as String?;
    if (unit['reference_id'] != 'raysto-sandbox-$id' ||
        (unit['payee'] as Map?)?['merchant_id'] != gateway.merchantId ||
        capture['status'] != 'COMPLETED' ||
        capture['final_capture'] != true ||
        amount['currency_code'] != payment.currency ||
        PayPalGateway.parseMoney(amount['value'] as String? ?? '') !=
            payment.amountMinor ||
        captureId == null ||
        captureId.isEmpty ||
        (payment.captureId != null && payment.captureId != captureId)) {
      RaystoService.fail(
        'payment_mismatch',
        'Capture does not match the sandbox checkout.',
      );
    }
    payment.state = 'captured';
    payment.captureId = captureId;
    payment.capturedAt ??= DateTime.now().toUtc();
    return SandboxPayment.db.updateRow(s, payment, transaction: tx);
  });

  Future<void> webhook(
    Session s,
    SandboxPayment payment,
    String eventId,
    String type,
  ) async {
    // Called only after signature verification. Re-query PayPal independently.
    await reconcile(
      s,
      payment.id!,
      await gateway.getOrder(payment.providerOrderId!),
    );
    await s.db.transaction((tx) async {
      final current = (await SandboxPayment.db.findById(
        s,
        payment.id!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      if (await WebhookEvent.db.findFirstRow(
            s,
            where: (t) => t.providerEventId.equals(eventId),
            transaction: tx,
          ) !=
          null) {
        return;
      }
      final now = DateTime.now().toUtc();
      await WebhookEvent.db.insertRow(
        s,
        WebhookEvent(
          providerEventId: eventId,
          eventType: type,
          receivedAt: now,
        ),
        transaction: tx,
      );
      current.webhookEventId = eventId;
      current.webhookReceivedAt = now;
      await SandboxPayment.db.updateRow(s, current, transaction: tx);
    });
  }
}
