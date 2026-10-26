import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart' as uuid;

import '../generated/protocol.dart';
import 'paypal_gateway.dart';
import 'raysto_service.dart';
import 'sandbox_payment_service.dart';

class PaymentService {
  final PayPalGateway gateway;
  PaymentService(this.gateway);
  factory PaymentService.configured() =>
      PaymentService(PayPalGateway.fromEnvironment());

  Future<CheckoutResult> checkout(Session s, int orderId) async {
    try {
      if (await OrderContext.db.findFirstRow(
            s,
            where: (t) => t.orderId.equals(orderId),
          ) !=
          null) {
        RaystoService.fail(
          'client_upgrade_required',
          'Use the shared-bill payment API for this order.',
        );
      }
      final order = await RaystoService.ownOrder(s, orderId);
      final attempt = await s.db.transaction((tx) async {
        final locked = (await PurchaseOrder.db.findById(
          s,
          orderId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ))!;
        if (locked.paymentStatus == 'paid') {
          RaystoService.fail('conflict', 'Order is already paid.');
        }
        final existing = await PaymentAttempt.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(orderId),
          transaction: tx,
        );
        if (existing != null) return existing;
        return PaymentAttempt.db.insertRow(
          s,
          PaymentAttempt(
            orderId: orderId,
            requestId: const uuid.Uuid().v4(),
            state: 'creating',
            createdAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        );
      });
      if (attempt.providerOrderId == null) {
        // Never create a second payment after the provider's idempotency retention window.
        if (DateTime.now().toUtc().difference(attempt.createdAt) >
            const Duration(hours: 3)) {
          RaystoService.fail(
            'reconciliation_required',
            'An operator must reconcile this checkout before retrying.',
          );
        }
        final result = await gateway.create(order, attempt.requestId);
        final id = result['id'] as String;
        final links = (result['links'] as List).cast<Map<String, dynamic>>();
        final link = links
            .where((l) => l['rel'] == 'payer-action' || l['rel'] == 'approve')
            .firstOrNull;
        final approvalUrl = Uri.tryParse(link?['href'] as String? ?? '');
        if (approvalUrl == null ||
            approvalUrl.scheme != 'https' ||
            approvalUrl.userInfo.isNotEmpty ||
            !(approvalUrl.host == 'www.sandbox.paypal.com' ||
                approvalUrl.host == 'sandbox.paypal.com')) {
          RaystoService.fail(
            'provider_unavailable',
            'PayPal approval URL is invalid.',
          );
        }
        return await s.db.transaction((tx) async {
          final current = (await PaymentAttempt.db.findById(
            s,
            attempt.id!,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          ))!;
          if (current.providerOrderId != null &&
              current.providerOrderId != id) {
            RaystoService.fail(
              'payment_mismatch',
              'Conflicting provider order.',
            );
          }
          current.providerOrderId = id;
          current.approvalUrl = approvalUrl.toString();
          current.state = 'awaitingApproval';
          await PaymentAttempt.db.updateRow(s, current, transaction: tx);
          return CheckoutResult(
            orderId: orderId,
            providerOrderId: id,
            approvalUrl: current.approvalUrl!,
          );
        });
      }
      return CheckoutResult(
        orderId: orderId,
        providerOrderId: attempt.providerOrderId!,
        approvalUrl: attempt.approvalUrl!,
      );
    } finally {
      gateway.close();
    }
  }

  Future<PurchaseOrder> capture(Session s, int orderId) async {
    if (await OrderContext.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(orderId),
        ) !=
        null) {
      RaystoService.fail(
        'client_upgrade_required',
        'Use the shared-bill payment API for this order.',
      );
    }
    try {
      final order = await RaystoService.ownOrder(s, orderId);
      if (order.paymentStatus == 'paid') return order;
      final attempt = await PaymentAttempt.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(orderId),
      );
      if (attempt?.providerOrderId == null) {
        RaystoService.fail('conflict', 'Create checkout before capture.');
      }
      // GET first recovers a successful capture whose HTTP response was lost.
      var result = await gateway.getOrder(attempt!.providerOrderId!);
      if (result['status'] != 'COMPLETED') {
        result = await gateway.capture(
          attempt.providerOrderId!,
          '${attempt.requestId}-capture',
        );
      }
      return await reconcile(s, orderId, result);
    } finally {
      gateway.close();
    }
  }

  Future<PurchaseOrder> reconcile(
    Session s,
    int orderId,
    Map<String, dynamic> result,
  ) async {
    return s.db.transaction((tx) async {
      final order =
          await PurchaseOrder.db.findById(
            s,
            orderId,
            transaction: tx,
            lockMode: LockMode.forUpdate,
          ) ??
          RaystoService.fail('not_found', 'Order not found.');
      final attempt = await PaymentAttempt.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(orderId),
        transaction: tx,
      );
      if (attempt == null ||
          result['id'] != attempt.providerOrderId ||
          result['status'] != 'COMPLETED') {
        RaystoService.fail(
          'payment_mismatch',
          'Provider order has not completed.',
        );
      }
      final units = result['purchase_units'] as List;
      if (units.length != 1) {
        RaystoService.fail('payment_mismatch', 'Unexpected payment units.');
      }
      final unit = units.single as Map<String, dynamic>;
      final captures =
          (unit['payments'] as Map<String, dynamic>)['captures'] as List;
      if (captures.length != 1) {
        RaystoService.fail('payment_mismatch', 'Unexpected payment captures.');
      }
      final capture = captures.single as Map<String, dynamic>;
      final amount = capture['amount'] as Map<String, dynamic>;
      final captureId = capture['id'] as String;
      if (unit['reference_id'] != orderId.toString() ||
          (unit['payee'] as Map<String, dynamic>)['merchant_id'] !=
              gateway.merchantId ||
          capture['status'] != 'COMPLETED' ||
          capture['final_capture'] != true ||
          amount['currency_code'] != order.currency ||
          PayPalGateway.parseMoney(amount['value'] as String) !=
              order.totalMinor) {
        RaystoService.fail(
          'payment_mismatch',
          'Payment does not match the frozen order.',
        );
      }
      final existing = await PaymentReceipt.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(orderId),
        transaction: tx,
      );
      if (existing != null) {
        if (existing.captureId != captureId) {
          RaystoService.fail(
            'payment_mismatch',
            'Order has a different capture.',
          );
        }
        return order;
      }
      await PaymentReceipt.db.insertRow(
        s,
        PaymentReceipt(
          orderId: orderId,
          captureId: captureId,
          amountMinor: order.totalMinor,
          currency: order.currency,
          createdAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
      attempt.state = 'captured';
      await PaymentAttempt.db.updateRow(s, attempt, transaction: tx);
      order.paymentStatus = 'paid';
      order.updatedAt = DateTime.now().toUtc();
      order.version++;
      await PurchaseOrder.db.updateRow(s, order, transaction: tx);
      await RaystoService.emit(s, order, 'payment.confirmed', tx);
      return order;
    });
  }

  Future<void> webhook(
    Session s,
    Map<String, String> headers,
    Map<String, dynamic> event,
  ) async {
    try {
      if (!await gateway.verifyWebhook(headers, event)) {
        RaystoService.fail('forbidden', 'Invalid webhook signature.');
      }
      final eventId = RaystoService.text(event['id'] as String, 200);
      final type = event['event_type'] as String;
      if (await WebhookEvent.db.findFirstRow(
            s,
            where: (t) => t.providerEventId.equals(eventId),
          ) !=
          null) {
        return;
      }
      // Subscribe only to this event until refund/dispute workflows are implemented.
      if (type != 'PAYMENT.CAPTURE.COMPLETED') return;
      final resource = event['resource'] as Map<String, dynamic>;
      final related =
          (resource['supplementary_data']
                  as Map<String, dynamic>)['related_ids']
              as Map<String, dynamic>;
      final providerId = related['order_id'] as String;
      final sandbox = await SandboxPayment.db.findFirstRow(
        s,
        where: (t) => t.providerOrderId.equals(providerId),
      );
      if (sandbox != null) {
        await SandboxPaymentService(gateway).webhook(s, sandbox, eventId, type);
        return;
      }
      final attempt = await PaymentAttempt.db.findFirstRow(
        s,
        where: (t) => t.providerOrderId.equals(providerId),
      );
      // Retry later if a webhook wins the race against checkout persistence.
      if (attempt == null) {
        RaystoService.fail('retry', 'Checkout not yet persisted.');
      }
      await reconcile(s, attempt.orderId, await gateway.getOrder(providerId));
      // Reconciliation is independently idempotent, including a crash before event insertion.
      await s.db.transaction((tx) async {
        await PurchaseOrder.db.findById(
          s,
          attempt.orderId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (await WebhookEvent.db.findFirstRow(
              s,
              where: (t) => t.providerEventId.equals(eventId),
              transaction: tx,
            ) ==
            null) {
          await WebhookEvent.db.insertRow(
            s,
            WebhookEvent(
              providerEventId: eventId,
              eventType: type,
              receivedAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
        }
      });
    } finally {
      gateway.close();
    }
  }
}
