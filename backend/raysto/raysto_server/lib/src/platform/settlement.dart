part of 'platform.dart';

class SettlementModule {
  /// Reconcile an already existing provider refund. This command only reads
  /// PayPal; it never creates or repeats a financial provider operation.
  static Future<Json> reconcileRefund(Session s, PlatformCommand c) async {
    final context = await _mutate(s, c, 'admin.reconcileRefund', (w, d) async {
      await _admin(w);
      _keys(d, {'providerRefundId', 'localRefundId', 'reason'});
      final capture = await PaymentCapture.db.findById(
        s,
        _id(c),
        transaction: w.tx,
      );
      if (capture == null ||
          capture.restaurantId != w.tenant ||
          capture.state != 'completed') {
        _fail('not_found', 'Capture not found.');
      }
      final intent = (await CheckoutIntent.db.findById(
        s,
        capture.checkoutId,
        transaction: w.tx,
      ))!;
      if (intent.method != 'paypal' ||
          intent.merchantId.startsWith('legacy-')) {
        _fail(
          'legacy_reconciliation_required',
          'Use the original payment integration for this capture.',
        );
      }
      final providerId = _str(d, 'providerRefundId', max: 100);
      if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(providerId)) {
        _fail('invalid_input', 'Invalid provider refund identifier.');
      }
      await w.audit(
        'payment.refund_reconciliation_requested',
        'capture',
        capture.id,
        {
          'reason': _str(d, 'reason', max: 1000),
          'providerRefundId': providerId,
        },
      );
      return {
        'captureId': capture.id,
        'merchantId': intent.merchantId,
        'providerCaptureId': capture.providerCaptureId,
        'providerRefundId': providerId,
        'localRefundId': d['localRefundId'] == null
            ? null
            : _int(d, 'localRefundId', min: 1),
      };
    });
    final provider = await ProviderClients.paypal(
      'GET',
      '/v2/payments/refunds/${context['providerRefundId']}',
      merchant: context['merchantId'] as String,
    );
    final belongs = (provider['links'] as List? ?? []).whereType<Map>().any((
      link,
    ) {
      final uri = Uri.tryParse('${link['href']}');
      return link['rel'] == 'up' &&
          uri?.scheme == 'https' &&
          {
            'api-m.paypal.com',
            'api-m.sandbox.paypal.com',
            'api.paypal.com',
            'api.sandbox.paypal.com',
          }.contains(uri?.host) &&
          uri?.path == '/v2/payments/captures/${context['providerCaptureId']}';
    });
    if (!belongs ||
        provider['id'] != context['providerRefundId'] ||
        !{'COMPLETED', 'PENDING'}.contains(provider['status'])) {
      _fail(
        'provider_evidence_required',
        'An existing refund linked to this capture is required.',
      );
    }
    final amount = _object(provider['amount']);
    final minor = PayPalGateway.parseMoney(_str(amount, 'value'));
    final result = await MoneyModule.locked(
      s,
      c.restaurantId!,
      s.authenticated!.userIdentifier,
      (w) async {
        await _admin(w);
        final capture = (await PaymentCapture.db.findById(
          s,
          context['captureId'] as int,
          transaction: w.tx,
        ))!;
        if (minor < 1 ||
            amount['currency_code'] != capture.currency ||
            capture.state != 'completed') {
          _fail(
            'payment_mismatch',
            'Refund currency or capture state differs.',
          );
        }
        final known = await PaymentRefund.db.findFirstRow(
          s,
          where: (t) =>
              t.providerRefundId.equals(context['providerRefundId'] as String),
          transaction: w.tx,
        );
        if (known != null) {
          if (known.captureId != capture.id) {
            _fail('payment_mismatch', 'Refund belongs to another capture.');
          }
          return {'refundId': known.id, 'state': known.state};
        }
        PaymentRefund row;
        if (context['localRefundId'] != null) {
          row =
              await PaymentRefund.db.findById(
                s,
                context['localRefundId'] as int,
                transaction: w.tx,
              ) ??
              _fail('not_found', 'Local refund not found.');
          if (row.captureId != capture.id ||
              row.amountMinor != minor ||
              row.providerRefundId != null ||
              row.state != 'pending') {
            _fail(
              'payment_mismatch',
              'Local request does not match provider evidence.',
            );
          }
        } else {
          final prior = await PaymentRefund.db.find(
            s,
            where: (t) =>
                t.captureId.equals(capture.id!) & t.state.notEquals('failed'),
            transaction: w.tx,
          );
          if (prior.any((r) => r.state != 'completed')) {
            _fail(
              'ambiguous_refund',
              'Match the existing unresolved refund request before importing another.',
            );
          }
          if (minor > capture.amountMinor - capture.refundedMinor) {
            _fail('invalid_amount', 'Refund exceeds the unrefunded capture.');
          }
          final allocations = await PaymentAllocation.db.find(
            s,
            where: (t) => t.checkoutId.equals(capture.checkoutId),
            orderBy: (t) => t.id,
            transaction: w.tx,
          );
          var remaining = minor;
          final parts = <Json>[];
          for (final allocation in allocations) {
            final n = min(
              remaining,
              allocation.amountMinor - allocation.refundedMinor,
            );
            if (n > 0) parts.add({'id': allocation.id, 'amount': n});
            remaining -= n;
            if (remaining == 0) break;
          }
          if (remaining != 0) {
            _fail('payment_mismatch', 'Refund allocation differs.');
          }
          // Dashboard refunds may not return partner fees. Record only verified
          // returned fees, leaving any commercial adjustment to explicit review.
          final breakdown = provider['seller_payable_breakdown'] as Map? ?? {};
          var returnedFee = 0;
          for (final fee in breakdown['platform_fees'] as List? ?? []) {
            final value = _object(fee['amount']);
            if (value['currency_code'] != capture.currency) {
              _fail('payment_mismatch', 'Refund fee currency differs.');
            }
            returnedFee += PayPalGateway.parseMoney(_str(value, 'value'));
          }
          final entries = await CommissionEntry.db.find(
            s,
            where: (t) => t.captureId.equals(capture.id!),
            transaction: w.tx,
          );
          if (returnedFee > entries.fold<int>(0, (n, e) => n + e.amountMinor) ||
              returnedFee > minor) {
            _fail('payment_mismatch', 'Refund partner fee differs.');
          }
          row = await PaymentRefund.db.insertRow(
            s,
            PaymentRefund(
              restaurantId: w.tenant,
              captureId: capture.id!,
              requestKey: 'import-${context['providerRefundId']}',
              allocationJson: jsonEncode({'allocations': parts}),
              amountMinor: minor,
              commissionMinor: returnedFee,
              reason: 'Verified external provider refund',
              state: 'pending',
              createdBy: w.user,
              createdAt: _now(),
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
        }
        row.providerRefundId = context['providerRefundId'] as String;
        await PaymentRefund.db.updateRow(s, row, transaction: w.tx);
        await w.job(
          'payment.refund',
          'refund-import:${row.id}:${row.providerRefundId}',
          {'refundId': row.id},
        );
        await w.audit('payment.refund_evidence_linked', 'refund', row.id);
        return {'refundId': row.id, 'state': row.state};
      },
    );
    await MoneyModule.processRefund(s, result['refundId'] as int);
    return {
      'refundId': result['refundId'],
      'state': (await PaymentRefund.db.findById(
        s,
        result['refundId'] as int,
      ))!.state,
    };
  }

  static Future<void> exception(
    Session s,
    ProviderInbox inbox,
    Json resource,
  ) async {
    final isDispute = inbox.eventType.contains('DISPUTE');
    Json evidence;
    String providerCapture;
    if (isDispute) {
      evidence = await ProviderClients.paypal(
        'GET',
        '/v1/customer/disputes/${_str(resource, 'dispute_id', max: 100)}',
      );
      final transactions = evidence['disputed_transactions'] as List? ?? [];
      if (transactions.length != 1) {
        _fail(
          'manual_reconciliation_required',
          'Dispute has multiple transactions.',
        );
      }
      providerCapture = _str(
        _object(transactions.single),
        'seller_transaction_id',
        max: 100,
      );
    } else {
      providerCapture = _str(resource, 'id', max: 100);
      evidence = await ProviderClients.paypal(
        'GET',
        '/v2/payments/captures/$providerCapture',
      );
    }
    final capture = await PaymentCapture.db.findFirstRow(
      s,
      where: (t) => t.providerCaptureId.equals(providerCapture),
    );
    if (capture == null) {
      _fail(
        'manual_reconciliation_required',
        'Exception does not match a recorded capture.',
      );
    }
    final intent = (await CheckoutIntent.db.findById(s, capture.checkoutId))!;
    await MoneyModule.locked(s, capture.restaurantId, intent.userId, (w) async {
      if (await PaymentException.db.findFirstRow(
            s,
            where: (t) => t.providerEventId.equals(inbox.eventId),
            transaction: w.tx,
          ) !=
          null) {
        return;
      }
      final amount = isDispute
          ? _object(evidence['dispute_amount'])
          : _object(evidence['amount']);
      final currency = amount['currency_code'];
      final minor = PayPalGateway.parseMoney(_str(amount, 'value'));
      if (currency != capture.currency || minor > capture.amountMinor) {
        _fail('payment_mismatch', 'Exception amount differs from capture.');
      }
      await PaymentException.db.insertRow(
        s,
        PaymentException(
          restaurantId: w.tenant,
          captureId: capture.id!,
          providerEventId: inbox.eventId,
          kind: isDispute ? 'dispute' : 'reversal',
          status: 'review',
          amountMinor: minor,
          currency: capture.currency,
          evidenceJson: jsonEncode({
            'providerStatus': evidence['status'],
            'verifiedEventType': inbox.eventType,
            'providerId': isDispute ? evidence['dispute_id'] : evidence['id'],
          }),
          version: 1,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('payment.exception_received', 'capture', capture.id, {
        'kind': isDispute ? 'dispute' : 'reversal',
        'eventId': inbox.eventId,
      });
    });
  }

  static Future<Json> resolve(Session s, PlatformCommand c) =>
      _mutate(s, c, 'admin.paymentException', (w, d) async {
        await _admin(w);
        _keys(d, {'resolution', 'reason'});
        final e = await PaymentException.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (e == null || e.restaurantId != w.tenant) {
          _fail('not_found', 'Payment exception not found.');
        }
        _version(e.version, c.expectedVersion);
        if (e.status != 'review') {
          _fail('invalid_transition', 'Exception is already resolved.');
        }
        final resolution = _str(
          d,
          'resolution',
          choices: {'evidenceReviewed', 'recordReversal'},
        );
        final capture = (await PaymentCapture.db.findById(
          s,
          e.captureId,
          transaction: w.tx,
        ))!;
        final intent = (await CheckoutIntent.db.findById(
          s,
          capture.checkoutId,
          transaction: w.tx,
        ))!;
        if (resolution == 'recordReversal') {
          if (e.kind != 'reversal' ||
              _json(e.evidenceJson)['verifiedEventType'] !=
                  'PAYMENT.CAPTURE.REVERSED') {
            _fail(
              'provider_evidence_required',
              'A verified reversed capture is required.',
            );
          }
          if (capture.state != 'reversed') {
            final allocations = await PaymentAllocation.db.find(
              s,
              where: (t) => t.checkoutId.equals(intent.id!),
              transaction: w.tx,
            );
            for (final a in allocations) {
              final remaining = a.amountMinor - a.refundedMinor;
              final b = (await BillCharge.db.findById(
                s,
                a.chargeId,
                transaction: w.tx,
              ))!;
              b.settledMinor = max(0, b.settledMinor - remaining);
              b.version++;
              await BillCharge.db.updateRow(s, b, transaction: w.tx);
              a.state = 'reversed';
              await PaymentAllocation.db.updateRow(s, a, transaction: w.tx);
              final order = (await PurchaseOrder.db.findById(
                s,
                b.orderId,
                transaction: w.tx,
              ))!;
              order.paymentStatus = 'reversed';
              await OrderingModule._changed(w, order, 'payment.reversed');
            }
            capture.state = 'reversed';
            await PaymentCapture.db.updateRow(s, capture, transaction: w.tx);
            final fees = await CommissionEntry.db.find(
              s,
              where: (t) => t.captureId.equals(capture.id!),
              transaction: w.tx,
            );
            final remainingFee = fees.fold<int>(0, (n, x) => n + x.amountMinor);
            if (remainingFee > 0) {
              await CommissionEntry.db.insert(
                s,
                [
                  CommissionEntry(
                    restaurantId: w.tenant,
                    captureId: capture.id!,
                    eventKey: 'reversal:${capture.id}',
                    amountMinor: -remainingFee,
                    currency: capture.currency,
                    state: 'reversed',
                    createdAt: _now(),
                  ),
                ],
                ignoreConflicts: true,
                transaction: w.tx,
              );
            }
          }
        }
        e.status = resolution;
        e.version++;
        await PaymentException.db.updateRow(s, e, transaction: w.tx);
        await w.audit('payment.exception_resolved', 'exception', e.id, {
          'resolution': resolution,
          'reason': _str(d, 'reason', max: 1000),
        });
        return {'version': e.version, 'status': e.status};
      });
}
