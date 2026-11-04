part of 'platform.dart';

/// The derived double-entry journal (plan section 3). One function,
/// [ledgerFor], turns each money fact Raysto already records (a capture, a
/// refund, a payout, an expense, a bill, a payment request, a commission, a
/// stock movement) into balanced lines; [LedgerModule.journal] gathers the
/// facts of a window and maps them. Nothing is posted twice and nothing is
/// stored except the manual facts a person enters (LedgerAdjustment), so the
/// close, the P&L and the group views read the same truth.
class LedgerModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {'ledger.adjust': adjust};

  /// Who may read the journal and the accountant's pages.
  static const roles = _finance;

  /// The fixed chart of accounts: code → name. 1xxx assets, 2xxx
  /// liabilities, 3xxx equity, 4xxx revenue (4090 is a contra account),
  /// 5xxx cost of goods, 6xxx expenses.
  static const accounts = <String, String>{
    '1000': 'PayPal balance',
    '1010': 'Cash and bank',
    '1100': 'Receivables',
    '1200': 'Inventory',
    '2000': 'Payables',
    '2100': 'VAT collected',
    '2110': 'VAT paid',
    '2200': 'Tips owed to staff',
    '3000': 'Owner equity',
    '4000': 'Sales',
    '4010': 'Delivery fees',
    '4090': 'Refunds',
    '4200': 'Catering and payment requests',
    '5000': 'Cost of goods',
    '6000': 'PayPal fees',
    '6010': 'Platform commission',
    '6020': 'Wages',
    '6025': 'Delivery drivers',
    '6050': 'Supplies and cleaning',
    '6090': 'Waste',
    '6100': 'Utilities',
    '6110': 'Rent',
    '6120': 'Equipment',
    '6130': 'Marketing',
    '6140': 'Internet and phone',
    '6150': 'Insurance',
    '6160': 'Maintenance',
    '6170': 'Taxes and licences',
    '6190': 'Other expenses',
    '6200': 'Delivery partners',
  };

  /// Where a bill's cost goes, by its category.
  static const billAccounts = <String, String>{
    'electricity': '6100',
    'water': '6100',
    'gas': '6100',
    'rent': '6110',
    'internet': '6140',
    'phone': '6140',
    'insurance': '6150',
    'supplier': '1200',
    'maintenance': '6160',
    'tax': '6170',
    'other': '6190',
  };

  /// Where a receipt's cost goes, by its expense category.
  static const expenseAccounts = <String, String>{
    'food': '5000',
    'drinks': '5000',
    'packaging': '5000',
    'supplies': '6050',
    'cleaning': '6050',
    'rent': '6110',
    'utilities': '6100',
    'staff': '6020',
    'fees': '6000',
    'marketing': '6130',
    'equipment': '6120',
    'other': '6190',
  };

  /// What a Payouts batch pays off, by its kind.
  static const payoutAccounts = <String, String>{
    'tips': '2200',
    'wages': '6020',
    'supplier': '2000',
    'bill': '2000',
    'delivery': '6025',
    'partner': '6200',
  };

  /// Bill states whose cost is in the books (owed or paid).
  static const recognised = {'approved', 'paying', 'paid', 'paidElsewhere'};

  static bool revenue(String code) => code.startsWith('4');
  static bool cost(String code) => code.startsWith('5') || code.startsWith('6');
  static bool cash(String code) => code == '1000' || code == '1010';

  // ---- One fact → balanced lines -------------------------------------------

  static Json _line(Json fact, String account, {int debit = 0, int credit = 0}) => {
    'date': fact['date'],
    'at': fact['at'],
    'account': account,
    'accountName': accounts[account] ?? account,
    'debitMinor': debit,
    'creditMinor': credit,
    'currency': fact['currency'],
    'venueId': fact['venueId'],
    'memo': fact['memo'] ?? '',
    'source': {
      'type': fact['type'],
      'id': fact['id'],
      if (fact['providerId'] != null) 'providerId': fact['providerId'],
      if (fact['estimated'] == true) 'estimated': true,
    },
  };

  /// The journal lines of one money fact. Pure: the same fact always gives
  /// the same lines, and their debits always equal their credits.
  static List<Json> ledgerFor(Json fact) {
    int n(String k) => (fact[k] as int?) ?? 0;
    final amount = n('amountMinor');
    if (amount == 0) return const [];
    List<Json> pair(String debit, String credit) => [
      _line(fact, debit, debit: amount),
      _line(fact, credit, credit: amount),
    ];
    switch (fact['type']) {
      case 'capture':
        final money = fact['method'] == 'cash' ? '1010' : '1000';
        if (fact['requestId'] != null) return pair(money, '1100');
        final tip = n('tipMinor').clamp(0, amount);
        final delivery = n('deliveryMinor').clamp(0, amount - tip);
        final vat = n('vatMinor').clamp(0, amount - tip - delivery);
        final sales = amount - tip - delivery - vat;
        return [
          _line(fact, money, debit: amount),
          if (sales != 0) _line(fact, '4000', credit: sales),
          if (delivery != 0) _line(fact, '4010', credit: delivery),
          if (vat != 0) _line(fact, '2100', credit: vat),
          if (tip != 0) _line(fact, '2200', credit: tip),
        ];
      case 'refund':
      case 'reversal':
        return pair('4090', '1000');
      case 'fee':
        return pair('6000', '1000');
      case 'commission':
        return amount > 0
            ? pair('6010', '1000')
            : [
                _line(fact, '1000', debit: -amount),
                _line(fact, '6010', credit: -amount),
              ];
      case 'payout':
        return pair(payoutAccounts[fact['kind']] ?? '6190', '1000');
      case 'expense':
        final vat = n('vatMinor').clamp(0, amount);
        return [
          _line(fact, expenseAccounts[fact['category']] ?? '6190', debit: amount - vat),
          if (vat != 0) _line(fact, '2110', debit: vat),
          _line(fact, fact['paypal'] == true ? '1000' : '1010', credit: amount),
        ];
      case 'bill':
        final vat = n('vatMinor').clamp(0, amount);
        return [
          _line(fact, billAccounts[fact['category']] ?? '6190', debit: amount - vat),
          if (vat != 0) _line(fact, '2110', debit: vat),
          _line(fact, '2000', credit: amount),
        ];
      case 'billPaidElsewhere':
        return pair('2000', '1010');
      case 'request':
        return pair('1100', fact['partner'] == true ? '4000' : '4200');
      case 'invoicePaid':
        return pair('1000', '4200');
      case 'stockIn':
        return pair('1200', '2000');
      case 'cogs':
        return pair('5000', '1200');
      case 'waste':
        return pair('6090', '1200');
      case 'adjustment':
        final debit = '${fact['debitAccount']}';
        final credit = '${fact['creditAccount']}';
        return pair(debit, credit);
      default:
        return const [];
    }
  }

  // ---- Gathering the facts of a window --------------------------------------

  /// PayPal's fee on one capture when the real fee is not available:
  /// 3.49% + 0.49, the same estimate the analytics use, flagged as such.
  static int feeEstimate(int amountMinor) =>
      (amountMinor * 349 / 10000).round() + 49;

  /// Every money fact between [from] and [to], ready for [ledgerFor].
  static Future<List<Json>> facts(Work w, DateTime from, DateTime to) async {
    final s = w.s;
    final tx = w.tx;
    final rid = w.tenant;
    final currency = w.restaurant!.currency;
    final settings = {'timezone': 'UTC', ...w.settings};
    final out = <Json>[];
    Json base(String type, Object? id, DateTime at, {String? memo}) => {
      'type': type,
      'id': id,
      'at': at.toIso8601String(),
      'date': BackOfficeModule.localDay(settings, at),
      'currency': currency,
      'venueId': rid,
      'memo': ?memo,
    };

    // Captures, with their tips and delivery fees from the charges they
    // settled, and the payment requests they paid.
    final captures = await PaymentCapture.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.createdAt >= from) &
          (t.createdAt < to) &
          t.state.inSet({'completed', 'reversed'}),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    final checkoutIds = {for (final c in captures) c.checkoutId};
    final intents = checkoutIds.isEmpty
        ? <CheckoutIntent>[]
        : await CheckoutIntent.db.find(
            s,
            where: (t) => t.id.inSet(checkoutIds),
            transaction: tx,
          );
    final intentById = {for (final i in intents) i.id!: i};
    final requests = checkoutIds.isEmpty
        ? <PaymentRequest>[]
        : await PaymentRequest.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(rid) & t.checkoutIntentId.inSet(checkoutIds),
            transaction: tx,
          );
    final requestByCheckout = {for (final r in requests) r.checkoutIntentId!: r};
    final split = <int, Map<String, int>>{};
    if (checkoutIds.isNotEmpty) {
      final rows = await s.db.unsafeQuery(
        '''SELECT a."checkoutId", b.kind, COALESCE(SUM(a."amountMinor"),0),
                  COALESCE(SUM(a."foodNetMinor"),0)
           FROM raysto_payment_allocation a
           JOIN raysto_bill_charge b ON b.id=a."chargeId"
           WHERE a."restaurantId"=@tenant AND a."checkoutId" = ANY(@ids)
           GROUP BY a."checkoutId", b.kind''',
        parameters: QueryParameters.named({
          'tenant': rid,
          'ids': checkoutIds.toList(),
        }),
        transaction: tx,
      );
      for (final r in rows) {
        final kinds = split[r[0] as int] ??= {};
        final kind = '${r[1]}';
        final amount = int.parse('${r[2]}');
        kinds[kind] = (kinds[kind] ?? 0) + amount;
        // Each charge keeps its amount net of tax, so the VAT inside a
        // payment is exactly what the order charged, not an estimate.
        if (kind != 'tip' && kind != 'delivery') {
          kinds['_vat'] = (kinds['_vat'] ?? 0) + amount - int.parse('${r[3]}');
        }
      }
    }
    for (final c in captures) {
      final i = intentById[c.checkoutId];
      final request = requestByCheckout[c.checkoutId];
      final kinds = split[c.checkoutId] ?? const {};
      final tip = kinds['tip'] ?? 0;
      final delivery = kinds['delivery'] ?? 0;
      out.add({
        ...base('capture', c.id, c.createdAt,
            memo: request != null
                ? 'Payment request: ${request.description}'
                : i?.orderId != null
                ? 'Order ${i!.orderId}'
                : 'Table bill'),
        'providerId': c.providerCaptureId,
        'method': i?.method ?? 'paypal',
        'amountMinor': c.amountMinor,
        'tipMinor': tip,
        'deliveryMinor': delivery,
        'vatMinor': request == null ? max(0, kinds['_vat'] ?? 0) : 0,
        if (request != null) 'requestId': request.id,
      });
      if (c.state == 'reversed' && c.amountMinor > c.refundedMinor) {
        out.add({
          ...base('reversal', c.id, c.createdAt, memo: 'Reversed by PayPal after a dispute'),
          'providerId': c.providerCaptureId,
          'amountMinor': c.amountMinor - c.refundedMinor,
        });
      }
      if ((i?.method ?? 'paypal') == 'paypal') {
        out.add({
          ...base('fee', c.id, c.createdAt, memo: 'PayPal fee (estimate)'),
          'providerId': c.providerCaptureId,
          'amountMinor': feeEstimate(c.amountMinor),
          'estimated': true,
        });
      }
    }

    final refunds = await PaymentRefund.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.updatedAt >= from) &
          (t.updatedAt < to) &
          t.state.equals('completed'),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    for (final r in refunds) {
      out.add({
        ...base('refund', r.id, r.updatedAt, memo: r.reason),
        'providerId': r.providerRefundId,
        'amountMinor': r.amountMinor,
      });
    }

    final commissions = await CommissionEntry.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) & (t.createdAt >= from) & (t.createdAt < to),
      transaction: tx,
    );
    for (final c in commissions) {
      out.add({
        ...base('commission', c.id, c.createdAt, memo: 'Platform commission'),
        // A reversal row already carries a negative amount.
        'amountMinor': c.amountMinor,
      });
    }

    final batches = await PayoutBatch.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.updatedAt >= from) &
          (t.updatedAt < to) &
          t.state.inSet({'sent', 'completed'}),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    for (final b in batches) {
      out.add({
        ...base('payout', b.id, b.updatedAt, memo: 'PayPal Payouts: ${b.kind}'),
        'providerId': b.providerBatchId,
        'kind': b.kind,
        'amountMinor': b.totalMinor,
      });
      // PayPal's own Payouts fee, as its batch read reported it.
      final fees = _json(b.summaryJson)['feesMinor'];
      if (fees is int && fees > 0) {
        out.add({
          ...base('fee', 'payout:${b.id}', b.updatedAt, memo: 'PayPal Payouts fee'),
          'providerId': b.providerBatchId,
          'amountMinor': fees,
        });
      }
    }

    final expenses = await Expense.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) & (t.spentAt >= from) & (t.spentAt < to),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    for (final e in expenses) {
      out.add({
        ...base('expense', e.id, e.spentAt, memo: e.merchant),
        'providerId': e.paypalTransactionId,
        'category': e.category,
        'amountMinor': e.amountMinor,
        'vatMinor': e.vatMinor,
        'paypal': e.paypalTransactionId != null,
      });
    }

    final bills = await Bill.db.find(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.state.notEquals('void'),
      transaction: tx,
    );
    // A supplier order with a bill is costed by its bill, not its delivery.
    final billedOrders = {
      for (final b in bills)
        if (b.supplierOrderId != null) b.supplierOrderId!,
    };
    for (final b in bills.where((b) => recognised.contains(b.state))) {
      final at = b.issuedAt ?? b.createdAt;
      if (!at.isBefore(from) && at.isBefore(to)) {
        out.add({
          ...base('bill', b.id, at, memo: '${b.vendor}${b.reference == null ? '' : ' ${b.reference}'}'),
          'category': b.category,
          'amountMinor': b.amountMinor,
          'vatMinor': b.vatMinor,
        });
      }
      final paid = b.paidAt;
      if (b.state == 'paidElsewhere' &&
          paid != null &&
          !paid.isBefore(from) &&
          paid.isBefore(to)) {
        out.add({
          ...base('billPaidElsewhere', b.id, paid, memo: '${b.vendor}, paid outside PayPal'),
          'amountMinor': b.amountMinor,
        });
      }
    }

    final deliveries = await SupplyDelivery.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.createdAt >= from) &
          (t.createdAt < to) &
          t.state.inSet({'received', 'paid'}),
      transaction: tx,
    );
    for (final d in deliveries) {
      if (d.supplierOrderId != null && billedOrders.contains(d.supplierOrderId)) {
        continue;
      }
      out.add({
        ...base('stockIn', d.id, d.createdAt, memo: 'Supplier delivery'),
        'amountMinor': d.totalMinor,
      });
    }

    final payRequests = await PaymentRequest.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.createdAt >= from) &
          (t.createdAt < to) &
          t.state.inSet({'sent', 'paid'}),
      transaction: tx,
    );
    for (final r in payRequests) {
      out.add({
        ...base('request', r.id, r.createdAt, memo: '${r.payerName}: ${r.description}'),
        'amountMinor': r.amountMinor,
        'partner': r.partnerAppId != null,
      });
    }

    final catering = await CateringRequest.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.updatedAt >= from) &
          (t.updatedAt < to) &
          t.status.equals('paid'),
      transaction: tx,
    );
    for (final c in catering) {
      out.add({
        ...base('invoicePaid', c.id, c.updatedAt, memo: 'Catering invoice ${c.invoiceNumber ?? ''}'.trim()),
        'providerId': c.providerInvoiceId,
        'amountMinor': c.totalMinor,
      });
    }

    final movements = await StockMovement.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (t.at >= from) &
          (t.at < to) &
          t.kind.inSet({'sale', 'waste'}),
      transaction: tx,
    );
    for (final m in movements) {
      final value = (m.quantity.abs() * (m.unitCostMinor ?? 0)).round();
      if (value == 0) continue;
      out.add({
        ...base(m.kind == 'sale' ? 'cogs' : 'waste', m.id, m.at,
            memo: m.kind == 'sale' ? 'Stock used by sales' : 'Waste'),
        'amountMinor': value,
      });
    }

    final adjustments = await LedgerAdjustment.db.find(
      s,
      where: (t) => t.restaurantId.equals(rid) & (t.at >= from) & (t.at < to),
      transaction: tx,
    );
    for (final a in adjustments) {
      out.add({
        ...base('adjustment', a.id, a.at, memo: a.reason),
        'debitAccount': a.debitAccount,
        'creditAccount': a.creditAccount,
        'amountMinor': a.amountMinor,
      });
    }
    out.sort((a, b) => '${a['at']}'.compareTo('${b['at']}'));
    return out;
  }

  /// The journal of a window: every line, and whether it balances.
  static Future<List<Json>> journal(Work w, DateTime from, DateTime to) async => [
    for (final f in await facts(w, from, to)) ...ledgerFor(f),
  ];

  /// Totals by account: debit, credit and the balance the account's side
  /// reads (assets and costs debit-positive, the rest credit-positive).
  static Map<String, Json> totals(List<Json> lines) {
    final out = <String, Json>{};
    for (final l in lines) {
      final a = l['account'] as String;
      final row = out[a] ??= {
        'account': a,
        'name': accounts[a] ?? a,
        'debitMinor': 0,
        'creditMinor': 0,
      };
      row['debitMinor'] = (row['debitMinor'] as int) + (l['debitMinor'] as int);
      row['creditMinor'] = (row['creditMinor'] as int) + (l['creditMinor'] as int);
    }
    for (final row in out.values) {
      final a = row['account'] as String;
      final debitSide = a.startsWith('1') || cost(a);
      row['balanceMinor'] = debitSide
          ? (row['debitMinor'] as int) - (row['creditMinor'] as int)
          : (row['creditMinor'] as int) - (row['debitMinor'] as int);
    }
    return out;
  }

  /// Profit and loss of a set of lines: revenue less refunds, then costs.
  static Json pnl(List<Json> lines) {
    final t = totals(lines);
    var revenueMinor = 0, costsMinor = 0;
    final revenueRows = <Json>[], costRows = <Json>[];
    for (final row in t.values) {
      final a = row['account'] as String;
      if (revenue(a)) {
        final v = (row['creditMinor'] as int) - (row['debitMinor'] as int);
        revenueMinor += v;
        revenueRows.add({...row, 'amountMinor': v});
      } else if (cost(a)) {
        final v = (row['debitMinor'] as int) - (row['creditMinor'] as int);
        costsMinor += v;
        costRows.add({...row, 'amountMinor': v});
      }
    }
    int byCode(Json a, Json b) => '${a['account']}'.compareTo('${b['account']}');
    return {
      'revenue': revenueRows..sort(byCode),
      'costs': costRows..sort(byCode),
      'revenueMinor': revenueMinor,
      'costsMinor': costsMinor,
      'netMinor': revenueMinor - costsMinor,
    };
  }

  /// One local calendar day's books for the daily close.
  static Future<Json> dayBooks(Work w, DateTime from, DateTime to) async {
    final f = await facts(w, from, to);
    final lines = [for (final x in f) ...ledgerFor(x)];
    int sum(bool Function(Json) test) =>
        f.where(test).fold<int>(0, (n, x) => n + ((x['amountMinor'] as int?) ?? 0));
    final payouts = <String, int>{};
    for (final x in f.where((x) => x['type'] == 'payout')) {
      payouts['${x['kind']}'] =
          (payouts['${x['kind']}'] ?? 0) + (x['amountMinor'] as int);
    }
    var cashIn = 0, cashOut = 0;
    for (final l in lines.where((l) => cash(l['account'] as String))) {
      cashIn += l['debitMinor'] as int;
      cashOut += l['creditMinor'] as int;
    }
    final p = pnl(lines);
    return {
      'expensesMinor': sum((x) => x['type'] == 'expense'),
      'billsRecognisedMinor': sum((x) => x['type'] == 'bill'),
      'billsPaidElsewhereMinor': sum((x) => x['type'] == 'billPaidElsewhere'),
      'payoutsMinor': payouts,
      'supplierDeliveriesMinor': sum((x) => x['type'] == 'stockIn'),
      'requestsIssuedMinor': sum((x) => x['type'] == 'request'),
      'requestsPaidMinor': sum((x) => x['type'] == 'capture' && x['requestId'] != null),
      'commissionsMinor': sum((x) => x['type'] == 'commission'),
      'feesEstimatedMinor': sum((x) => x['type'] == 'fee'),
      'cashInMinor': cashIn,
      'cashOutMinor': cashOut,
      'netProfitMinor': p['netMinor'],
      'balanced': balanced(lines),
    };
  }

  static bool balanced(List<Json> lines) =>
      lines.fold<int>(0, (n, l) => n + (l['debitMinor'] as int)) ==
      lines.fold<int>(0, (n, l) => n + (l['creditMinor'] as int));

  // ---- Windows --------------------------------------------------------------

  /// A window from `from`/`to`, or a `month` (yyyy-mm, local), or the last
  /// [defaultDays]; at most 400 days.
  static (DateTime, DateTime) window(Json settings, Json d, {int defaultDays = 31}) {
    if (d['month'] != null) {
      final month = _str(d, 'month', max: 7);
      if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(month)) {
        _fail('invalid_input', 'Invalid month.');
      }
      final zone = CatalogueModule.zone(
        (settings['timezone'] as String?) ?? 'UTC',
      );
      final y = int.parse(month.substring(0, 4));
      final m = int.parse(month.substring(5, 7));
      if (m < 1 || m > 12) _fail('invalid_input', 'Invalid month.');
      return (
        tz.TZDateTime(zone, y, m).toUtc(),
        m == 12
            ? tz.TZDateTime(zone, y + 1).toUtc()
            : tz.TZDateTime(zone, y, m + 1).toUtc(),
      );
    }
    final to = d['to'] == null ? _now() : _date(d, 'to');
    final from = d['from'] == null
        ? to.subtract(Duration(days: defaultDays))
        : _date(d, 'from');
    if (!to.isAfter(from) || to.difference(from).inDays > 400) {
      _fail('invalid_input', 'Choose a window of up to 400 days.');
    }
    return (from, to);
  }

  // ---- Queries --------------------------------------------------------------

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    switch (name) {
      case 'ledger.journal':
        await w.role(roles);
        final (from, to) = window(w.settings, d);
        final lines = await journal(w, from, to);
        return {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
          'currency': w.restaurant!.currency,
          'rows': lines.length > 2000 ? lines.sublist(lines.length - 2000) : lines,
          'truncated': lines.length > 2000,
          'totals': totals(lines).values.toList()
            ..sort((a, b) => '${a['account']}'.compareTo('${b['account']}')),
          'balanced': balanced(lines),
          'feesEstimated': lines.any(
            (l) => (l['source'] as Json)['estimated'] == true,
          ),
          'accounts': accounts,
        };
      case 'ledger.pnl':
        await w.role(roles);
        final (from, to) = window(w.settings, d, defaultDays: 92);
        final lines = await journal(w, from, to);
        final byMonth = <String, Json>{};
        for (final l in lines) {
          final a = l['account'] as String;
          if (!revenue(a) && !cost(a)) continue;
          final month = '${l['date']}'.substring(0, 7);
          final key = '$month:$a';
          final row = byMonth[key] ??= {
            'month': month,
            'account': a,
            'accountName': accounts[a] ?? a,
            'group': revenue(a) ? 'Revenue' : 'Costs',
            'amountMinor': 0,
          };
          row['amountMinor'] = (row['amountMinor'] as int) +
              (revenue(a)
                  ? (l['creditMinor'] as int) - (l['debitMinor'] as int)
                  : (l['debitMinor'] as int) - (l['creditMinor'] as int));
        }
        return {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
          'currency': w.restaurant!.currency,
          ...pnl(lines),
          'rows': byMonth.values.toList()
            ..sort((a, b) => '${a['month']}${a['account']}'.compareTo('${b['month']}${b['account']}')),
          'feesEstimated': lines.any(
            (l) => (l['source'] as Json)['estimated'] == true,
          ),
        };
      case 'ledger.cashflow':
        await w.role(roles);
        // Over HTTP a query's values arrive as text.
        final days = d['days'] is String ? int.tryParse(d['days'] as String) : d['days'];
        return cashflow(w, _int({'days': days}, 'days', min: 7, max: 92, fallback: 30));
      case 'ledger.vat':
        await w.role(roles);
        final (from, to) = window(w.settings, d, defaultDays: 92);
        final lines = await journal(w, from, to);
        final months = <String, Json>{};
        var collected = 0, paid = 0;
        for (final l in lines) {
          final a = l['account'] as String;
          if (a != '2100' && a != '2110') continue;
          final month = '${l['date']}'.substring(0, 7);
          final row = months[month] ??= {
            'month': month,
            'collectedMinor': 0,
            'paidMinor': 0,
          };
          if (a == '2100') {
            final v = (l['creditMinor'] as int) - (l['debitMinor'] as int);
            collected += v;
            row['collectedMinor'] = (row['collectedMinor'] as int) + v;
          } else {
            final v = (l['debitMinor'] as int) - (l['creditMinor'] as int);
            paid += v;
            row['paidMinor'] = (row['paidMinor'] as int) + v;
          }
        }
        for (final row in months.values) {
          row['dueMinor'] = (row['collectedMinor'] as int) - (row['paidMinor'] as int);
        }
        return {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
          'currency': w.restaurant!.currency,
          'taxBps': w.settings['taxBps'] ?? 0,
          'taxConfigured': w.settings['taxConfigured'] == true,
          'collectedMinor': collected,
          'paidMinor': paid,
          'dueMinor': collected - paid,
          'rows': months.values.toList()
            ..sort((a, b) => '${a['month']}'.compareTo('${b['month']}')),
        };
    }
    return null;
  }

  /// The last month of cash in and out of PayPal and the till, and the next
  /// [days] forecast from bills due, monthly bills coming round again and
  /// the average day. Every forecast point says what it is made of.
  static Future<Json> cashflow(Work w, int days) async {
    final now = _now();
    final from = now.subtract(const Duration(days: 30));
    final lines = await journal(w, from, now);
    final daily = <String, Json>{};
    for (final l in lines.where((l) => cash(l['account'] as String))) {
      final row = daily['${l['date']}'] ??= {
        'date': l['date'],
        'inMinor': 0,
        'outMinor': 0,
      };
      row['inMinor'] = (row['inMinor'] as int) + (l['debitMinor'] as int);
      row['outMinor'] = (row['outMinor'] as int) + (l['creditMinor'] as int);
    }
    final history = daily.values.toList()
      ..sort((a, b) => '${a['date']}'.compareTo('${b['date']}'));
    for (final row in history) {
      row['netMinor'] = (row['inMinor'] as int) - (row['outMinor'] as int);
    }
    final netTotal = history.fold<int>(0, (n, r) => n + (r['netMinor'] as int));
    final inTotal = history.fold<int>(0, (n, r) => n + (r['inMinor'] as int));
    final averageIn = (inTotal / 30).round();
    // Bills to pay, and next month's expected copy of each monthly bill
    // already paid (BillsModule leaves one when a monthly bill is paid).
    final open = await Bill.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.state.inSet({'expected', 'review', 'approved', 'paying'}),
      transaction: w.tx,
    );
    final dueItems = <String, List<Json>>{};
    final settings = {'timezone': 'UTC', ...w.settings};
    String dayOf(DateTime at) => BackOfficeModule.localDay(settings, at);
    final today = dayOf(now);
    final last = now.add(Duration(days: days));
    for (final b in open) {
      final due = b.dueAt ?? now.add(const Duration(days: 7));
      final day = due.isBefore(now) ? today : dayOf(due);
      if (due.isAfter(last)) continue;
      (dueItems[day] ??= []).add({
        'kind': switch (b.state) {
          'expected' => 'recurringExpected',
          'review' => 'billToReview',
          _ => 'billDue',
        },
        'billId': b.id,
        'vendor': b.vendor,
        'amountMinor': b.amountMinor,
        'overdue': b.state != 'expected' && due.isBefore(now),
      });
    }
    final forecast = <Json>[];
    final totals = LedgerModule.totals(await journal(w, DateTime.utc(2020), now));
    var balance = ['1000', '1010'].fold<int>(
      0,
      (n, a) => n + ((totals[a]?['balanceMinor'] as int?) ?? 0),
    );
    final opening = balance;
    for (var i = 1; i <= days; i++) {
      final day = dayOf(now.add(Duration(days: i)));
      final items = dueItems[day] ?? const <Json>[];
      final out = items.fold<int>(0, (n, x) => n + (x['amountMinor'] as int));
      balance += averageIn - out;
      forecast.add({
        'date': day,
        'inMinor': averageIn,
        'outMinor': out,
        'balanceMinor': balance,
        'items': items,
      });
    }
    final overdue = (dueItems[today] ?? const <Json>[])
        .where((x) => x['overdue'] == true)
        .toList();
    return {
      'currency': w.restaurant!.currency,
      'history': history,
      'forecast': forecast,
      'openingMinor': opening,
      'averageDailyInMinor': averageIn,
      'averageDailyNetMinor': (netTotal / 30).round(),
      'overdue': overdue,
      'lowestMinor': forecast.isEmpty
          ? opening
          : forecast.map((f) => f['balanceMinor'] as int).reduce(min),
      'basis':
          'Money in is the last 30 days\' average; money out is bills due and monthly bills expected. An estimate, not a promise.',
    };
  }

  // ---- Commands -------------------------------------------------------------

  /// A manual fact the derived journal cannot know: an opening balance, a
  /// cash count, a reclassification. Owners and accountants only, always
  /// with a reason, and audited.
  static Future<Json> adjust(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'ledger.adjust',
    (w, d) async {
      _keys(d, {'at', 'debitAccount', 'creditAccount', 'amountMinor', 'reason'});
      final debit = _str(d, 'debitAccount', max: 4, choices: accounts.keys.toSet());
      final credit = _str(d, 'creditAccount', max: 4, choices: accounts.keys.toSet());
      if (debit == credit) {
        _fail('invalid_input', 'Debit and credit must be different accounts.');
      }
      final row = await LedgerAdjustment.db.insertRow(
        s,
        LedgerAdjustment(
          restaurantId: w.tenant,
          at: d['at'] == null ? _now() : _date(d, 'at'),
          debitAccount: debit,
          creditAccount: credit,
          amountMinor: _int(d, 'amountMinor', min: 1, max: 100000000),
          currency: w.restaurant!.currency,
          reason: _str(d, 'reason', max: 300),
          userId: w.user,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('ledger.adjusted', 'ledgerAdjustment', row.id, {
        'debitAccount': debit,
        'creditAccount': credit,
        'amountMinor': row.amountMinor,
      });
      return {'adjustmentId': row.id};
    },
    roles: {'owner', 'accountant'},
  );

  // ---- Reads for agents and tests -------------------------------------------

  /// The money queries (ledger, bills, requests) for a session without an
  /// HTTP request: one transaction, the caller's own roles.
  static Future<Json> read(
    Session s, {
    required int restaurantId,
    required String name,
    Json d = const {},
    int limit = 30,
    int cursor = 0,
  }) async {
    final actor = await _actor(s);
    return s.db.transaction((tx) async {
      final restaurant = await Restaurant.db.findById(s, restaurantId, transaction: tx);
      if (restaurant == null) _fail('not_found', 'Restaurant not found.');
      final policy = await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(restaurantId),
        transaction: tx,
      );
      final w = Work(
        s,
        tx,
        actor,
        PlatformCommand(requestKey: _uuid(), restaurantId: restaurantId, dataJson: '{}'),
        restaurant,
        policy,
      );
      Json page(List<Json> rows) => {
        'rows': rows,
        'nextCursor': rows.length == limit ? rows.last['id'] : null,
      };
      return await query(w, name, d, limit, cursor, page) ??
          await BillsModule.query(w, name, d, limit, cursor, page) ??
          await PaymentRequestModule.query(w, name, d, limit, cursor, page) ??
          _fail('not_found', 'Unknown query.');
    });
  }
}
