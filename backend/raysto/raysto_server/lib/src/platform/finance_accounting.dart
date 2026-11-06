part of 'platform.dart';

/// Versioned business-event snapshots feed the existing derived journal. This
/// is deliberately a prospective cutover: provider history is never rewritten.
class FinanceAccounting {
  static const basis = 'management-accrual-v1';
  static Future<FinanceRecord?> policy(Work w) =>
      Finance017.record(w, 'financePolicy', 'current');

  static Future<void> guardPayout(Work w, PayoutBatch b) async {
    if (!Finance017.active || await policy(w) == null) return;
    if (b.kind == 'supplier') {
      _fail(
        'bill_required',
        'Match and approve the supplier invoice, then use its bill-payment review. Receiving stock does not approve its settlement.',
      );
    }
  }

  static Future<Json> activate(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'finance.policy.save',
    (w, d) async {
      Finance017.enabled();
      _keys(d, {'reviewed', 'reason', 'opening'});
      if (!_bool(d, 'reviewed')) {
        _fail(
          'review_required',
          'Review the accounting cutover and opening balances first.',
        );
      }
      if (await policy(w) != null) {
        _fail(
          'already_configured',
          'The accounting cutover is immutable. Use reviewed journal adjustments for corrections.',
        );
      }
      _version(0, c.expectedVersion);
      final entries = <Json>[];
      for (final raw in _list(d, 'opening', max: 100)) {
        final line = _object(raw);
        _keys(line, {'account', 'debitMinor', 'creditMinor'});
        final account = _str(
          line,
          'account',
          choices: LedgerModule.accounts.keys.toSet(),
        );
        if (LedgerModule.cost(account) || LedgerModule.revenue(account)) {
          _fail(
            'invalid_input',
            'Opening balances use balance-sheet accounts, not revenue or cost accounts.',
          );
        }
        final debit = _int(line, 'debitMinor', max: 100000000, fallback: 0);
        final credit = _int(line, 'creditMinor', max: 100000000, fallback: 0);
        if ((debit == 0) == (credit == 0)) {
          _fail(
            'invalid_input',
            'Each opening line has one positive debit or credit.',
          );
        }
        entries.add({
          'account': account,
          'debitMinor': debit,
          'creditMinor': credit,
        });
      }
      if (!validEntries(entries)) {
        _fail('unbalanced', 'Opening debits and credits must agree.');
      }
      final at = _now();
      final saved = await Finance017.put(w, 'financePolicy', 'current', {
        'basis': basis,
        'cutoverAt': at.toIso8601String(),
        'reviewedBy': w.user,
        'reason': _str(d, 'reason', max: 1000),
        'opening': entries,
        'inventoryValuation': 'frozen-consumption-receipt-cost',
      }, immutable: true);
      await post(
        w,
        'opening',
        entries,
        source: {'type': 'reviewedOpening', 'id': saved.id},
        at: at,
      );
      await w.audit('finance.cutover.accepted', 'financeRecord', saved.id);
      return {'version': saved.version, ..._json(saved.payloadJson)};
    },
    roles: {'owner'},
    registered: true,
  );

  static bool validEntries(List<Json> entries) =>
      entries.every(
        (e) =>
            LedgerModule.accounts.containsKey(e['account']) &&
            e['debitMinor'] is int &&
            e['creditMinor'] is int &&
            (e['debitMinor'] as int) >= 0 &&
            (e['creditMinor'] as int) >= 0 &&
            ((e['debitMinor'] as int) == 0 || (e['creditMinor'] as int) == 0),
      ) &&
      entries.fold<int>(
            0,
            (n, e) => n + (e['debitMinor'] as int) - (e['creditMinor'] as int),
          ) ==
          0;
  static Json debit(String account, int value) => {
    'account': account,
    'debitMinor': value,
    'creditMinor': 0,
  };
  static Json credit(String account, int value) => {
    'account': account,
    'debitMinor': 0,
    'creditMinor': value,
  };

  static Future<void> post(
    Work w,
    String key,
    List<Json> entries, {
    required Json source,
    List<String> issues = const [],
    DateTime? at,
  }) async {
    if (entries.any(
          (e) => (e['debitMinor'] as int) < 0 || (e['creditMinor'] as int) < 0,
        ) ||
        !validEntries(entries)) {
      _fail(
        'unbalanced',
        'The financial event did not balance. No changes were saved.',
      );
    }
    final time = at ?? _now();
    await Finance017.put(w, 'financeFact', key, {
      'type': 'management',
      'id': key,
      'at': time.toIso8601String(),
      'date': BackOfficeModule.localDay(w.settings, time),
      'currency': w.restaurant!.currency,
      'venueId': w.tenant,
      'basis': basis,
      'entries': entries,
      'evidence': source,
      'providerId': ?source['providerId'],
      'memo': source['type'],
      'issues': issues,
      'sample': JudgeModule.venue(w.tenant),
      if (source['estimated'] == true) 'estimated': true,
    }, immutable: true);
  }

  static Future<List<Json>> facts(Work w, DateTime from, DateTime to) async {
    final p = await policy(w);
    if (p == null) {
      _fail(
        'policy_required',
        'The owner must review the accounting cutover first.',
      );
    }
    final cutover = DateTime.parse(_json(p.payloadJson)['cutoverAt'] as String);
    if (from.isBefore(cutover)) {
      _fail(
        'unsupported_period',
        'Select a period beginning at the accounting cutover, or select the legacy basis.',
      );
    }
    final rows = await FinanceRecord.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.kind.equals('financeFact') &
          (t.createdAt >= cutover) &
          (t.createdAt < to),
      transaction: w.tx,
    );
    for (final row in rows) {
      if (_json(row.payloadJson)['currency'] != w.restaurant!.currency) {
        _fail(
          'currency_mismatch',
          'Financial evidence uses another currency. Review it separately; no combined total is available.',
        );
      }
    }
    return [
      for (final r in rows)
        if (!DateTime.parse(
          _json(r.payloadJson)['at'] as String,
        ).isBefore(from))
          _json(r.payloadJson),
    ];
  }

  /// Sources are frozen in the same transaction as their business transition.
  /// A provider retry can never create another fact with the same source key.
  static Future<void> observe(
    Work w,
    String event,
    String type,
    int? id,
  ) async {
    if (!Finance017.active ||
        w.restaurant == null ||
        id == null ||
        await policy(w) == null) {
      return;
    }
    if (event == 'payment.completed' && type == 'capture') {
      await collection(w, id);
    }
    if (event == 'order.completed' && type == 'order') await earned(w, id);
    if (event == 'supplier.order.received') await receipt(w, id);
    if (event == 'stock.received' && type == 'delivery') {
      await receipt(w, id, delivery: true);
    }
    if (event == 'stock.counted' || event == 'stock.wasted') {
      final movement = await StockMovement.db.findFirstRow(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.stockItemId.equals(id) &
            t.kind.equals(event == 'stock.counted' ? 'count' : 'waste'),
        orderBy: (t) => t.id.desc(),
        transaction: w.tx,
      );
      if (movement != null) {
        final amount = (movement.quantity.abs() * (movement.unitCostMinor ?? 0))
            .round();
        await post(
          w,
          'inventoryCorrection:${movement.id}',
          movement.quantity > 0
              ? [debit('1200', amount), credit('6090', amount)]
              : [debit('6090', amount), credit('1200', amount)],
          source: {'type': 'stockMovement', 'id': movement.id},
          issues: movement.unitCostMinor == null
              ? ['Inventory correction has no confirmed cost.']
              : const [],
        );
      }
    }
    if (event == 'bill.approved' || event == 'bill.matched') await bill(w, id);
    if (event == 'bill.corrected') {
      final fact = await Finance017.record(w, 'financeFact', 'bill:$id');
      if (fact != null) {
        final source = _object(_json(fact.payloadJson)['evidence']);
        final b = (await Bill.db.findById(w.s, id, transaction: w.tx))!;
        if (source['amountMinor'] != b.amountMinor ||
            source['vatMinor'] != b.vatMinor ||
            source['category'] != b.category ||
            source['supplierOrderId'] != b.supplierOrderId) {
          _fail(
            'recognized_record',
            'A recognized bill needs a reviewed correction. Void the unpaid bill and review its replacement; historical accounting is preserved.',
          );
        }
      }
    }
    if (event == 'bill.voided') {
      final original = await Finance017.record(w, 'financeFact', 'bill:$id');
      if (original != null) {
        final entries = [
          for (final e
              in (_json(original.payloadJson)['entries'] as List).cast<Json>())
            {
              'account': e['account'],
              'debitMinor': e['creditMinor'],
              'creditMinor': e['debitMinor'],
            },
        ];
        await post(
          w,
          'billVoid:$id',
          entries,
          source: {'type': 'billVoid', 'id': id, 'originalFactId': original.id},
        );
      }
    }
    if (event == 'bill.paid_elsewhere') {
      final b = await Bill.db.findById(w.s, id, transaction: w.tx);
      if (b != null) {
        await post(
          w,
          'billSettlement:$id',
          [debit('2000', b.amountMinor), credit('1010', b.amountMinor)],
          source: {
            'type': 'bill',
            'id': id,
            'externalEvidenceMediaId': b.proofMediaId,
          },
        );
      }
    }
    if (event.startsWith('payout.') && type == 'payoutBatch') {
      await settlements(w, id);
    }
    if (event == 'bill.paid') {
      final b = await Bill.db.findById(w.s, id, transaction: w.tx);
      if (b?.payoutBatchId != null) await settlements(w, b!.payoutBatchId!);
    }
    if (event == 'shift.clock_out') {
      final shift = await StaffShift.db.findById(w.s, id, transaction: w.tx);
      if (shift?.clockInAt != null && shift?.clockOutAt != null) {
        final amount = RestaurantCosting.divide(
          shift!.clockOutAt!.difference(shift.clockInAt!).inMinutes *
              shift.hourlyRateMinor,
          60,
        );
        await post(
          w,
          'wages:$id',
          [debit('6020', amount), credit('2250', amount)],
          source: {'type': 'shift', 'id': id},
        );
      }
    }
    if (event == 'payment.refunded') await refund(w, id);
    if (event == 'payment.exception_resolved') {
      final exception = await PaymentException.db.findById(
        w.s,
        id,
        transaction: w.tx,
      );
      if (exception?.status == 'recordReversal') await reversal(w, exception!);
    }
    if (event == 'expense.recorded') {
      final e = await Expense.db.findById(w.s, id, transaction: w.tx);
      if (e != null) {
        await post(
          w,
          'expense:$id',
          [
            debit(
              LedgerModule.expenseAccounts[e.category] ?? '6190',
              e.amountMinor - e.vatMinor,
            ),
            debit('2110', e.vatMinor),
            credit(
              e.paypalTransactionId == null ? '1010' : '1000',
              e.amountMinor,
            ),
          ],
          source: {'type': 'expense', 'id': id},
        );
        await Finance017.put(w, 'expenseClassification', '$id', {
          'category': e.category,
        });
      }
    }
    if (event == 'expense.categorised') {
      final previous = await Finance017.record(
        w,
        'expenseClassification',
        '$id',
      );
      final expense = await Expense.db.findById(w.s, id, transaction: w.tx);
      if (previous != null && expense != null) {
        final old =
            LedgerModule.expenseAccounts[_json(
              previous.payloadJson,
            )['category']] ??
            '6190';
        final next = LedgerModule.expenseAccounts[expense.category] ?? '6190';
        final net = expense.amountMinor - expense.vatMinor;
        if (old != next) {
          await post(
            w,
            'expenseReclassification:$id:${w.command.requestKey}',
            [debit(next, net), credit(old, net)],
            source: {'type': 'expenseReclassification', 'id': id},
          );
        }
        await Finance017.put(w, 'expenseClassification', '$id', {
          'category': expense.category,
        });
      }
    }
    if (event == 'ledger.adjusted') {
      final a = await LedgerAdjustment.db.findById(w.s, id, transaction: w.tx);
      if (a != null) {
        await post(
          w,
          'adjustment:$id',
          [
            debit(a.debitAccount, a.amountMinor),
            credit(a.creditAccount, a.amountMinor),
          ],
          source: {'type': 'adjustment', 'id': id, 'reason': a.reason},
        );
      }
    }
  }

  static Future<void> collection(Work w, int id) async {
    final c = (await PaymentCapture.db.findById(w.s, id, transaction: w.tx))!;
    final i = (await CheckoutIntent.db.findById(
      w.s,
      c.checkoutId,
      transaction: w.tx,
    ))!;
    final entries = [
      debit(i.method == 'cash' ? '1010' : '1000', c.amountMinor),
    ];
    final allocations = await PaymentAllocation.db.find(
      w.s,
      where: (t) => t.checkoutId.equals(c.checkoutId),
      transaction: w.tx,
    );
    var assigned = 0;
    for (final a in allocations) {
      final charge = (await BillCharge.db.findById(
        w.s,
        a.chargeId,
        transaction: w.tx,
      ))!;
      final recognized =
          await Finance017.record(
            w,
            'financeFact',
            'earned:${charge.orderId}',
          ) !=
          null;
      entries.add(
        credit(
          charge.kind == 'tip'
              ? '2200'
              : recognized
              ? '1100'
              : '2300',
          a.amountMinor,
        ),
      );
      assigned += a.amountMinor;
    }
    final issues = <String>[];
    if (assigned != c.amountMinor) {
      if (assigned > c.amountMinor) {
        _fail(
          'allocation_mismatch',
          'Payment allocations exceed the collection.',
        );
      }
      entries.add(credit('2300', c.amountMinor - assigned));
      issues.add(
        'Unallocated collection is held as a customer deposit until its earning evidence is reviewed.',
      );
    }
    await post(
      w,
      'collection:$id',
      entries,
      source: {'type': 'capture', 'id': id, 'providerId': c.providerCaptureId},
      issues: issues,
    );
    if (i.method == 'paypal') {
      final reported = await Finance017.record(w, 'captureFeeEvidence', '$id');
      final evidence = reported == null
          ? <String, dynamic>{}
          : _json(reported.payloadJson);
      final actual =
          evidence['providerCaptureId'] == c.providerCaptureId &&
              evidence['currency'] == c.currency
          ? evidence['amountMinor'] as int?
          : null;
      final fee = actual ?? LedgerModule.feeEstimate(c.amountMinor);
      await post(
        w,
        'captureFee:$id',
        [debit('6000', fee), credit('1000', fee)],
        source: {
          'type': 'captureFee',
          'id': id,
          'providerId': c.providerCaptureId,
          'estimated': actual == null,
          'feeEvidenceId': reported?.id,
        },
      );
    }
    final commission = await CommissionEntry.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.captureId.equals(id) &
          t.refundId.equals(null),
      transaction: w.tx,
    );
    for (final entry in commission) {
      if (entry.amountMinor > 0) {
        await post(
          w,
          'commission:${entry.id}',
          [debit('6010', entry.amountMinor), credit('1000', entry.amountMinor)],
          source: {'type': 'commission', 'id': entry.id},
        );
      }
    }
  }

  static Future<void> earned(Work w, int id) async {
    if (await Finance017.record(w, 'financeFact', 'earned:$id') != null) return;
    final charges = await BillCharge.db.find(
      w.s,
      where: (t) => t.orderId.equals(id),
      transaction: w.tx,
    );
    final entries = <Json>[];
    var gross = 0, advance = 0;
    for (final charge in charges) {
      if (charge.kind == 'tip') continue;
      final amount = charge.amountMinor - charge.creditedMinor;
      final net = charge.kind == 'delivery'
          ? amount
          : charge.amountMinor == 0
          ? 0
          : RestaurantCosting.divide(
              charge.foodNetMinor * amount,
              charge.amountMinor,
            );
      gross += amount;
      entries.add(credit(charge.kind == 'delivery' ? '4010' : '4000', net));
      entries.add(credit('2100', amount - net));
      advance += min(amount, charge.settledMinor);
    }
    entries.add(debit('1100', gross));
    if (advance > 0) {
      entries.addAll([debit('2300', advance), credit('1100', advance)]);
    }
    final issues = <String>[];
    final recipe = await Finance017.record(w, 'orderRecipe', '$id');
    if (recipe == null) {
      issues.add(
        'The order predates frozen costing. Opening balances and historical cost evidence need review.',
      );
    }
    await post(
      w,
      'earned:$id',
      entries,
      source: {'type': 'order', 'id': id},
      issues: issues,
    );
    final cost = await Finance017.record(w, 'orderCost', '$id');
    if (cost != null) {
      final data = _json(cost.payloadJson),
          amount = data['knownCostMinor'] as int;
      await post(
        w,
        'consumption:$id',
        [debit('5000', amount), credit('1200', amount)],
        source: {'type': 'orderCost', 'id': cost.id},
        issues: [
          ...(data['issues'] as List).cast<String>(),
          if ((data['packagingMinor'] as int? ?? 0) > 0)
            'Standalone packaging cost has no matched stock movement. Record packaging as an ingredient or review its expense evidence.',
        ],
      );
    }
  }

  static Future<void> receipt(
    Work w,
    int orderId, {
    bool delivery = false,
  }) async {
    final cutover = DateTime.parse(
      _json((await policy(w))!.payloadJson)['cutoverAt'] as String,
    );
    final linked = delivery
        ? await SupplyDelivery.db.findById(w.s, orderId, transaction: w.tx)
        : null;
    final movements = await StockMovement.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.refType.equals(delivery ? 'supplyDelivery' : 'supplierOrder') &
          t.kind.equals('receive'),
      transaction: w.tx,
    );
    for (final m in movements) {
      if (m.at.isBefore(cutover)) continue;
      // Receipt references include order id and the command key (partial deliveries).
      if (m.refId != '$orderId' && !m.refId.startsWith('$orderId:')) continue;
      final amount = (m.quantity * (m.unitCostMinor ?? 0)).round();
      await post(
        w,
        'receipt:${m.id}',
        [debit('1200', amount), credit('2050', amount)],
        source: {
          'type': 'stockMovement',
          'id': m.id,
          'supplierOrderId': delivery ? linked?.supplierOrderId : orderId,
        },
        issues: m.unitCostMinor == null
            ? ['Receipt cost is missing.']
            : const [],
      );
    }
  }

  static Future<void> bill(Work w, int id) async {
    if (await Finance017.record(w, 'financeFact', 'bill:$id') != null) return;
    final b = (await Bill.db.findById(w.s, id, transaction: w.tx))!;
    if (b.currency != w.restaurant!.currency) {
      _fail(
        'currency_mismatch',
        'Review this bill in its own currency; currencies are never combined.',
      );
    }
    final net = b.amountMinor - b.vatMinor;
    final entries = <Json>[];
    if (b.category == 'supplier') {
      if (b.supplierOrderId == null) {
        _fail(
          'receipt_required',
          'Link and review the confirmed supplier receipt before approving this stock invoice.',
        );
      }
      final receipts = await FinanceRecord.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.kind.equals('financeFact'),
        transaction: w.tx,
      );
      var received = 0;
      for (final r in receipts) {
        final f = _json(r.payloadJson),
            evidence = _object(_json(r.payloadJson)['evidence']);
        if (evidence['supplierOrderId'] != b.supplierOrderId) continue;
        received += (_list(f, 'entries', max: 100)
            .map(_object)
            .where((e) => e['account'] == '1200')
            .fold<int>(0, (n, e) => n + (e['debitMinor'] as int)));
      }
      if (received != net) {
        _fail(
          'receipt_mismatch',
          'The confirmed receipt and net invoice differ. Correct or review the source records before approval; no forced match is posted.',
        );
      }
      final matched = await Finance017.record(
        w,
        'invoiceMatch',
        '${b.supplierOrderId}',
      );
      if (matched != null) {
        final previousBill = await Bill.db.findById(
          w.s,
          _json(matched.payloadJson)['billId'] as int,
          transaction: w.tx,
        );
        if (previousBill?.state != 'void') {
          _fail(
            'already_matched',
            'This receipt is already matched to an approved invoice.',
          );
        }
      }
      entries.add(debit('2050', received));
      await Finance017.put(w, 'invoiceMatch', '${b.supplierOrderId}', {
        'billId': id,
        'netMinor': net,
      });
    } else {
      entries.add(debit(LedgerModule.billAccounts[b.category] ?? '6190', net));
    }
    entries.addAll([debit('2110', b.vatMinor), credit('2000', b.amountMinor)]);
    await post(
      w,
      'bill:$id',
      entries,
      source: {
        'type': 'bill',
        'id': id,
        'amountMinor': b.amountMinor,
        'vatMinor': b.vatMinor,
        'category': b.category,
        'supplierOrderId': b.supplierOrderId,
      },
    );
  }

  static Future<void> settlements(Work w, int id) async {
    final b = (await PayoutBatch.db.findById(w.s, id, transaction: w.tx))!;
    final items = await PayoutItem.db.find(
      w.s,
      where: (t) => t.batchId.equals(id),
      transaction: w.tx,
    );
    for (final item in items.where((i) => i.state == 'completed')) {
      final account = b.kind == 'wages'
          ? '2250'
          : LedgerModule.payoutAccounts[b.kind] ?? '6190';
      await post(
        w,
        'payoutItem:${item.id}',
        [debit(account, item.amountMinor), credit('1000', item.amountMinor)],
        source: {
          'type': 'payoutItem',
          'id': item.id,
          'providerId': item.providerItemId,
          'batchId': id,
          'kind': b.kind,
        },
        issues: b.kind == 'supplier'
            ? [
                'Legacy supplier payout requires a reviewed payable/opening-balance link. New supplier payments use the approved bill workflow.',
              ]
            : const [],
      );
    }
    final fee = _json(b.summaryJson)['feesMinor'];
    if (fee is int && fee > 0) {
      await post(
        w,
        'payoutFee:$id',
        [debit('6000', fee), credit('1000', fee)],
        source: {
          'type': 'payoutFee',
          'id': id,
          'providerId': b.providerBatchId,
        },
      );
    }
  }

  static Future<void> refund(Work w, int id) async {
    final r = (await PaymentRefund.db.findById(w.s, id, transaction: w.tx))!;
    final c = (await PaymentCapture.db.findById(
      w.s,
      r.captureId,
      transaction: w.tx,
    ))!;
    final intent = (await CheckoutIntent.db.findById(
      w.s,
      c.checkoutId,
      transaction: w.tx,
    ))!;
    final entries = <Json>[];
    var allocated = 0;
    for (final part in _list(
      _json(r.allocationJson),
      'allocations',
      max: 500,
    ).map(_object)) {
      final a = (await PaymentAllocation.db.findById(
        w.s,
        part['id'] as int,
        transaction: w.tx,
      ))!;
      final charge = (await BillCharge.db.findById(
        w.s,
        a.chargeId,
        transaction: w.tx,
      ))!;
      final amount = part['amount'] as int;
      final recognized =
          await Finance017.record(
            w,
            'financeFact',
            'earned:${charge.orderId}',
          ) !=
          null;
      if (charge.kind == 'tip') {
        entries.add(debit('2200', amount));
      } else if (!recognized) {
        entries.add(debit('2300', amount));
      } else {
        final net = charge.kind == 'delivery'
            ? amount
            : a.amountMinor == 0
            ? 0
            : RestaurantCosting.divide(
                    a.foodNetMinor * a.refundedMinor,
                    a.amountMinor,
                  ) -
                  RestaurantCosting.divide(
                    a.foodNetMinor * (a.refundedMinor - amount),
                    a.amountMinor,
                  );
        entries.addAll([debit('4090', net), debit('2100', amount - net)]);
      }
      allocated += amount;
    }
    if (allocated != r.amountMinor) {
      _fail('allocation_mismatch', 'Refund components do not reconcile.');
    }
    entries.add(
      credit(intent.method == 'cash' ? '1010' : '1000', r.amountMinor),
    );
    await post(
      w,
      'refund:$id',
      entries,
      source: {'type': 'refund', 'id': id, 'providerId': r.providerRefundId},
    );
    if (r.commissionMinor > 0) {
      await post(
        w,
        'refundCommission:$id',
        [debit('1000', r.commissionMinor), credit('6010', r.commissionMinor)],
        source: {'type': 'refundCommission', 'id': id},
      );
    }
    // Prepared ingredients remain consumed; a refund never invents a stock return.
  }

  static Future<void> reversal(Work w, PaymentException exception) async {
    final capture = (await PaymentCapture.db.findById(
      w.s,
      exception.captureId,
      transaction: w.tx,
    ))!;
    final allocations = await PaymentAllocation.db.find(
      w.s,
      where: (t) => t.checkoutId.equals(capture.checkoutId),
      transaction: w.tx,
    );
    final entries = <Json>[];
    var allocated = 0;
    for (final a in allocations) {
      final amount = a.amountMinor - a.refundedMinor;
      final charge = (await BillCharge.db.findById(
        w.s,
        a.chargeId,
        transaction: w.tx,
      ))!;
      final earned =
          await Finance017.record(
            w,
            'financeFact',
            'earned:${charge.orderId}',
          ) !=
          null;
      entries.add(
        debit(
          charge.kind == 'tip'
              ? '2200'
              : earned
              ? '1100'
              : '2300',
          amount,
        ),
      );
      allocated += amount;
    }
    final remaining = capture.amountMinor - capture.refundedMinor;
    if (allocated < remaining) {
      entries.add(debit('2300', remaining - allocated));
    }
    entries.add(credit('1000', remaining));
    await post(
      w,
      'reversal:${capture.id}',
      entries,
      source: {
        'type': 'verifiedReversal',
        'id': exception.id,
        'providerId': capture.providerCaptureId,
        'providerEventId': exception.providerEventId,
      },
    );
    final commissions = await CommissionEntry.db.find(
      w.s,
      where: (t) =>
          t.captureId.equals(capture.id!) &
          t.eventKey.equals('reversal:${capture.id}'),
      transaction: w.tx,
    );
    for (final c in commissions) {
      if (c.amountMinor < 0) {
        await post(
          w,
          'reversedCommission:${c.id}',
          [debit('1000', -c.amountMinor), credit('6010', -c.amountMinor)],
          source: {'type': 'commissionReversal', 'id': c.id},
        );
      }
    }
  }
}
