part of 'platform.dart';

/// The café's back office records: shifts, suppliers and stock, expenses,
/// complaints, catering requests, payouts, daily closes and customers. These
/// are the plain records the money agents read and propose against; the
/// agents themselves live in `agent_*.dart`. Money only leaves through an
/// approved agent action, never through a command here.
class BackOfficeModule {
  /// What a PayPal Payouts batch can pay: the team, suppliers, bills,
  /// delivery drivers and delivery partners.
  static const payoutKinds = {
    'tips',
    'wages',
    'supplier',
    'bill',
    'delivery',
    'partner',
  };
  static const expenseCategories = {
    'food',
    'drinks',
    'supplies',
    'cleaning',
    'packaging',
    'rent',
    'utilities',
    'staff',
    'fees',
    'marketing',
    'equipment',
    'other',
  };

  static String _email(Json d, String k) {
    final v = _str(d, k, max: 254).toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      _fail('invalid_input', 'Invalid $k.');
    }
    return v;
  }

  static double _amount(Json d, String k, {double max = 1000000}) {
    final v = d[k];
    if (v is! num || !v.isFinite || v < 0 || v > max) {
      _fail('invalid_input', 'Invalid $k.');
    }
    return v.toDouble();
  }

  static Future<T> _own<T>(Work w, T? row, int? tenant, String what) async {
    if (row == null || tenant != w.tenant) {
      _fail('not_found', '$what not found.');
    }
    return row;
  }

  // ---- Team and shifts -----------------------------------------------------

  /// A planned shift for a member of the team (or a named helper without a
  /// login). Pay is hours × rate; the payout goes to the member's PayPal email.
  static Future<Json> saveShift(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'shift.save',
    (w, d) async {
      _keys(d, {
        'userId',
        'name',
        'role',
        'startsAt',
        'endsAt',
        'hourlyRateMinor',
        'payoutEmail',
      });
      StaffShift? shift;
      if (c.resourceId != null) {
        final found = await StaffShift.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        shift = await _own<StaffShift>(w, found, found?.restaurantId, 'Shift');
        _version(shift.version, c.expectedVersion);
      }
      final starts = _date(d, 'startsAt');
      final ends = _date(d, 'endsAt');
      if (!ends.isAfter(starts) || ends.difference(starts).inHours > 16) {
        _fail('invalid_input', 'A shift lasts up to 16 hours.');
      }
      String? userId;
      if (d['userId'] != null) {
        userId = _str(d, 'userId', max: 100);
        final m = await Membership.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.userId.equals(userId!) &
              t.active.equals(true),
          transaction: w.tx,
        );
        if (m == null) _fail('not_found', 'This person is not on the team.');
      }
      shift ??= StaffShift(
        restaurantId: w.tenant,
        name: '',
        role: '',
        startsAt: starts,
        endsAt: ends,
        hourlyRateMinor: 0,
        version: 0,
        createdAt: _now(),
      );
      shift
        ..userId = userId
        ..name = _str(d, 'name', max: 80)
        ..role = _str(
          d,
          'role',
          choices: {'counter', 'kitchen', 'floor', 'manager', 'courier'},
        )
        ..startsAt = starts
        ..endsAt = ends
        ..hourlyRateMinor = _int(d, 'hourlyRateMinor', max: 100000)
        ..payoutEmail = d['payoutEmail'] == null
            ? null
            : _email(d, 'payoutEmail')
        ..version += 1;
      shift = shift.id == null
          ? await StaffShift.db.insertRow(s, shift, transaction: w.tx)
          : await StaffShift.db.updateRow(s, shift, transaction: w.tx);
      await w.audit('shift.saved', 'shift', shift.id);
      return {'shiftId': shift.id, 'version': shift.version};
    },
    roles: _managers,
  );

  /// Clock in or out of one's own shift (managers may clock anyone).
  static Future<Json> clock(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'shift.clock',
    (w, d) async {
      _keys(d, {'action'});
      final action = _str(d, 'action', choices: {'in', 'out'});
      final shift = await _own(
        w,
        await StaffShift.db.findById(s, _id(c), transaction: w.tx),
        (await StaffShift.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        ))?.restaurantId,
        'Shift',
      );
      if (shift.userId != w.user) await w.role(_managers);
      final now = _now();
      if (action == 'in') {
        if (shift.clockInAt != null) {
          _fail('invalid_transition', 'Already clocked in.');
        }
        if (now.difference(shift.startsAt).abs() > const Duration(hours: 4)) {
          _fail('invalid_transition', 'Too far from the shift start.');
        }
        shift.clockInAt = now;
      } else {
        if (shift.clockInAt == null || shift.clockOutAt != null) {
          _fail('invalid_transition', 'Not clocked in.');
        }
        shift.clockOutAt = now;
      }
      shift.version++;
      await StaffShift.db.updateRow(s, shift, transaction: w.tx);
      await w.audit('shift.clock_$action', 'shift', shift.id);
      return {
        'shiftId': shift.id,
        'clockInAt': shift.clockInAt?.toIso8601String(),
        'clockOutAt': shift.clockOutAt?.toIso8601String(),
        'version': shift.version,
      };
    },
    active: true,
  );

  /// Worked minutes: the clock when both punches exist, else the plan.
  static int workedMinutes(StaffShift x) {
    final from = x.clockInAt ?? x.startsAt;
    final to = x.clockOutAt ?? x.endsAt;
    return max(0, min(to.difference(from).inMinutes, 16 * 60));
  }

  static Json shiftView(StaffShift x) => {
    'id': x.id,
    'userId': x.userId,
    'name': x.name,
    'role': x.role,
    'startsAt': x.startsAt.toIso8601String(),
    'endsAt': x.endsAt.toIso8601String(),
    'clockInAt': x.clockInAt?.toIso8601String(),
    'clockOutAt': x.clockOutAt?.toIso8601String(),
    'hourlyRateMinor': x.hourlyRateMinor,
    'payoutEmail': x.payoutEmail,
    'workedMinutes': workedMinutes(x),
    'version': x.version,
  };

  // ---- Suppliers and stock -------------------------------------------------

  static Future<Json> saveSupplier(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.save',
    (w, d) async {
      // `email` (where supplier orders are sent) and `leadDays` are optional;
      // leaving them out keeps what is saved.
      _keys(d, {'name', 'payoutEmail', 'email', 'leadDays'});
      Supplier? row;
      if (c.resourceId != null) {
        final found = await Supplier.db.findById(s, _id(c), transaction: w.tx);
        row = await _own<Supplier>(w, found, found?.restaurantId, 'Supplier');
        _version(row.version, c.expectedVersion);
      }
      row ??= Supplier(
        restaurantId: w.tenant,
        name: '',
        payoutEmail: '',
        version: 0,
        createdAt: _now(),
      );
      row
        ..name = _str(d, 'name', max: 120)
        ..payoutEmail = _email(d, 'payoutEmail')
        ..version += 1;
      if (d.containsKey('email')) {
        row.email = d['email'] == null || d['email'] == ''
            ? null
            : _email(d, 'email');
      }
      if (d.containsKey('leadDays')) {
        row.leadDays = d['leadDays'] == null
            ? null
            : _int(d, 'leadDays', min: 0, max: 60);
      }
      row = row.id == null
          ? await Supplier.db.insertRow(s, row, transaction: w.tx)
          : await Supplier.db.updateRow(s, row, transaction: w.tx);
      await w.audit('supplier.saved', 'supplier', row.id);
      return {'supplierId': row.id, 'version': row.version};
    },
    roles: _managers,
  );

  static Future<Json> saveStock(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'stock.save',
    (w, d) async {
      // `parLevel` (order up to) and `leadDays` are optional; leaving them out
      // keeps what is saved.
      _keys(d, {
        'name',
        'unit',
        'quantity',
        'costMinor',
        'supplierId',
        'lowAt',
        'parLevel',
        'leadDays',
      });
      StockItem? row;
      if (c.resourceId != null) {
        final found = await StockItem.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        row = await _own<StockItem>(
          w,
          found,
          found?.restaurantId,
          'Stock item',
        );
        _version(row.version, c.expectedVersion);
      }
      int? supplierId;
      if (d['supplierId'] != null) {
        supplierId = _int(d, 'supplierId', min: 1);
        final sup = await Supplier.db.findById(
          s,
          supplierId,
          transaction: w.tx,
        );
        await _own(w, sup, sup?.restaurantId, 'Supplier');
      }
      row ??= StockItem(
        restaurantId: w.tenant,
        name: '',
        unit: '',
        quantity: 0,
        costMinor: 0,
        lowAt: 0,
        version: 0,
        updatedAt: _now(),
      );
      if (Finance017.active && row.id != null) {
        final stockId = row.id!;
        final tracked = await StockMovement.db.count(s, where: (t) => t.restaurantId.equals(w.tenant) &
          t.stockItemId.equals(stockId), transaction: w.tx);
        if (tracked > 0 && (d['unit'] != row.unit || _amount(d, 'quantity') != row.quantity ||
            _int(d, 'costMinor', max: 10000000) != row.costMinor)) {
          _fail('tracked_stock', 'Use a recorded count for quantity and a confirmed receipt for purchase cost. A tracked stock unit cannot be changed in place.');
        }
      }
      row
        ..name = _str(d, 'name', max: 120)
        ..unit = _str(
          d,
          'unit',
          choices: {'kg', 'g', 'l', 'ml', 'piece', 'box'},
        )
        ..quantity = _amount(d, 'quantity')
        ..costMinor = _int(d, 'costMinor', max: 10000000)
        ..supplierId = supplierId
        ..lowAt = _amount(d, 'lowAt')
        ..updatedAt = _now()
        ..version += 1;
      if (d.containsKey('parLevel')) {
        row.parLevel = d['parLevel'] == null ? null : _amount(d, 'parLevel');
      }
      if (d.containsKey('leadDays')) {
        row.leadDays = d['leadDays'] == null
            ? null
            : _int(d, 'leadDays', min: 0, max: 60);
      }
      row = row.id == null
          ? await StockItem.db.insertRow(s, row, transaction: w.tx)
          : await StockItem.db.updateRow(s, row, transaction: w.tx);
      await w.audit('stock.saved', 'stock', row.id);
      return {'stockId': row.id, 'version': row.version};
    },
    roles: _managers,
  );

  // ---- Expenses -------------------------------------------------------------

  /// A receipt recorded by hand (the expenses agent records what it read the
  /// same way, through an approved action).
  static Future<Json> recordExpense(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'expense.record',
    (w, d) async {
      _keys(d, {
        'category',
        'amountMinor',
        'vatMinor',
        'spentAt',
        'mediaId',
        'merchant',
        'paypalTransactionId',
      });
      int? mediaId;
      if (d['mediaId'] != null) {
        mediaId = _int(d, 'mediaId', min: 1);
        final m = await MediaAsset.db.findById(s, mediaId, transaction: w.tx);
        if (m == null || m.restaurantId != w.tenant) {
          _fail('not_found', 'Receipt photo not found.');
        }
      }
      final row = await Expense.db.insertRow(
        s,
        Expense(
          restaurantId: w.tenant,
          category: _str(d, 'category', choices: expenseCategories),
          amountMinor: _int(d, 'amountMinor', min: 1, max: 100000000),
          currency: w.restaurant!.currency,
          vatMinor: _int(d, 'vatMinor', max: 100000000, fallback: 0),
          spentAt: _date(d, 'spentAt'),
          mediaId: mediaId,
          merchant: _str(d, 'merchant', max: 120),
          paypalTransactionId: d['paypalTransactionId'] == null
              ? null
              : _str(d, 'paypalTransactionId', max: 50),
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('expense.recorded', 'expense', row.id, {
        'amountMinor': row.amountMinor,
        'category': row.category,
      });
      return {'expenseId': row.id};
    },
    roles: _managers,
  );

  // ---- Complaints -----------------------------------------------------------

  /// A diner (or a manager on their behalf) says something was wrong with an
  /// order. The complaints agent reads the ticket and PayPal's capture and
  /// proposes the refund; nothing is refunded here.
  static Future<Json> openComplaint(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'complaint.open',
    (w, d) async {
      _keys(d, {'text'});
      final (o, _) = await OrderingModule._order(w, _id(c));
      if (o.customerId != w.user) await w.role(_managers);
      if ({'cancelled', 'rejected', 'expired'}.contains(o.status) ||
          !{'paid', 'partiallyPaid', 'partiallyRefunded', 'refundDue'}.contains(
            o.paymentStatus,
          )) {
        _fail('invalid_transition', 'Complaints need a paid order.');
      }
      final open = await Complaint.db.findFirstRow(
        s,
        where: (t) =>
            t.orderId.equals(o.id!) & t.status.inSet({'open', 'proposed'}),
        transaction: w.tx,
      );
      if (open != null) {
        _fail(
          'invalid_transition',
          'This order already has an open complaint.',
        );
      }
      final checkout = await CheckoutIntent.db.findFirstRow(
        s,
        where: (t) => t.orderId.equals(o.id!) & t.state.equals('completed'),
        transaction: w.tx,
      );
      final capture = checkout == null
          ? null
          : await PaymentCapture.db.findFirstRow(
              s,
              where: (t) => t.checkoutId.equals(checkout.id!),
              transaction: w.tx,
            );
      final row = await Complaint.db.insertRow(
        s,
        Complaint(
          restaurantId: w.tenant,
          orderId: o.id!,
          captureId: capture?.id,
          userId: o.customerId == w.user ? w.user : null,
          text: _str(d, 'text', max: 2000),
          status: 'open',
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('complaint.opened', 'complaint', row.id, {
        'orderId': o.id,
        'captureId': capture?.id,
      });
      await ComplaintAgent.enqueueFor(w, row);
      return {'complaintId': row.id, 'version': row.version};
    },
    registered: true,
  );

  // ---- Catering -------------------------------------------------------------

  /// A catering request, from the console or a customer form. The catering
  /// agent prices it; the owner approves; PayPal sends the invoice.
  static Future<Json> requestCatering(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'catering.request',
    (w, d) async {
      _keys(d, {'customerEmail', 'customerName', 'text', 'eventAt'});
      final row = await CateringRequest.db.insertRow(
        s,
        CateringRequest(
          restaurantId: w.tenant,
          customerEmail: _email(d, 'customerEmail'),
          customerName: d['customerName'] == null
              ? null
              : _str(d, 'customerName', max: 120),
          text: _str(d, 'text', max: 4000),
          eventAt: d['eventAt'] == null ? null : _date(d, 'eventAt'),
          quoteJson: '{}',
          status: 'requested',
          depositMinor: 0,
          totalMinor: 0,
          currency: w.restaurant!.currency,
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('catering.requested', 'catering', row.id);
      await CateringAgent.enqueueFor(w, row);
      return {'cateringId': row.id, 'version': row.version};
    },
    roles: _managers,
  );

  static Json cateringView(CateringRequest x) => {
    'id': x.id,
    'customerEmail': x.customerEmail,
    'customerName': x.customerName,
    'text': x.text,
    'eventAt': x.eventAt?.toIso8601String(),
    'quote': _json(x.quoteJson),
    'status': x.status,
    'providerInvoiceId': x.providerInvoiceId,
    'invoiceNumber': x.invoiceNumber,
    'qrMediaId': x.qrMediaId,
    'orderId': x.orderId,
    'depositMinor': x.depositMinor,
    'totalMinor': x.totalMinor,
    'currency': x.currency,
    'dueAt': x.dueAt?.toIso8601String(),
    'remindedAt': x.remindedAt?.toIso8601String(),
    'taskId': x.taskId,
    'version': x.version,
    'createdAt': x.createdAt.toIso8601String(),
  };

  // ---- Queries --------------------------------------------------------------

  /// The same reads as the query endpoint, for agents and tests that hold a
  /// session but no HTTP request: one transaction, the caller's own roles.
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
      final restaurant = await Restaurant.db.findById(
        s,
        restaurantId,
        transaction: tx,
      );
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
        PlatformCommand(
          requestKey: _uuid(),
          restaurantId: restaurantId,
          dataJson: '{}',
        ),
        restaurant,
        policy,
      );
      return await query(
            w,
            name,
            d,
            limit,
            cursor,
            (rows) => {
              'rows': rows,
              'nextCursor': rows.length == limit ? rows.last['id'] : null,
            },
          ) ??
          _fail('not_found', 'Unknown query.');
    });
  }

  /// Manager reads of the back-office records, newest first, paged by id.
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    final s = w.s;
    final tx = w.tx;
    switch (name) {
      case 'shifts':
        await w.role({..._managers, 'waiter', 'kitchen', 'courier'});
        final from = d['from'] == null
            ? _now().subtract(const Duration(days: 7))
            : _date(d, 'from');
        final to = d['to'] == null
            ? _now().add(const Duration(days: 14))
            : _date(d, 'to');
        final rows = await StaffShift.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (t.startsAt >= from) &
              (t.startsAt <= to),
          orderBy: (t) => t.startsAt,
          limit: 500,
          transaction: tx,
        );
        return {'rows': rows.map(shiftView).toList(), 'nextCursor': null};
      case 'suppliers':
        await w.role(_managers);
        final rows = await Supplier.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
          orderBy: (t) => t.id,
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows)
            {
              'id': x.id,
              'name': x.name,
              'payoutEmail': x.payoutEmail,
              'version': x.version,
            },
        ]);
      case 'stock':
        await w.role({..._managers, 'kitchen'});
        final rows = await StockItem.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
          orderBy: (t) => t.id,
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows)
            {
              'id': x.id,
              'name': x.name,
              'unit': x.unit,
              'quantity': x.quantity,
              'costMinor': x.costMinor,
              'supplierId': x.supplierId,
              'lowAt': x.lowAt,
              'low': x.quantity <= x.lowAt,
              'version': x.version,
              'updatedAt': x.updatedAt.toIso8601String(),
            },
        ]);
      // Renamed from `deliveries` in 0.16 (stream S3); accountants read it
      // for the 3-way match.
      case 'supply.deliveries':
        await w.role(_finance);
        final rows = await SupplyDelivery.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows)
            {
              'id': x.id,
              'supplierId': x.supplierId,
              'mediaId': x.mediaId,
              'lines': jsonDecode(x.linesJson),
              'totalMinor': x.totalMinor,
              'currency': x.currency,
              'state': x.state,
              'payoutBatchId': x.payoutBatchId,
              'taskId': x.taskId,
              'supplierOrderId': x.supplierOrderId,
              'match': x.matchJson == null ? null : jsonDecode(x.matchJson!),
              'version': x.version,
              'createdAt': x.createdAt.toIso8601String(),
            },
        ]);
      case 'expenses':
        await w.role(_managers);
        final from = d['from'] == null
            ? _now().subtract(const Duration(days: 31))
            : _date(d, 'from');
        final to = d['to'] == null ? _now() : _date(d, 'to');
        final rows = await Expense.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (t.spentAt >= from) &
              (t.spentAt <= to),
          orderBy: (t) => t.spentAt.desc(),
          limit: 500,
          transaction: tx,
        );
        return {
          'rows': [
            for (final x in rows)
              {
                'id': x.id,
                'category': x.category,
                'amountMinor': x.amountMinor,
                'currency': x.currency,
                'vatMinor': x.vatMinor,
                'spentAt': x.spentAt.toIso8601String(),
                'mediaId': x.mediaId,
                'merchant': x.merchant,
                'paypalTransactionId': x.paypalTransactionId,
                'taskId': x.taskId,
                if (JudgeHistory.expense(x)) 'sample': true,
              },
          ],
          'nextCursor': null,
          'totalMinor': rows.fold<int>(0, (a, x) => a + x.amountMinor),
        };
      case 'complaints':
        await w.role(_managers);
        final rows = await Complaint.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows) await ComplaintAgent.view(s, x, tx: tx),
        ]);
      case 'catering':
        await w.role(_managers);
        final rows = await CateringRequest.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page(rows.map(CateringAgent.view).toList());
      case 'catering.request':
        await w.role(_managers);
        final x = await CateringRequest.db.findById(
          s,
          _int(d, 'id', min: 1),
          transaction: tx,
        );
        return CateringAgent.view(await _own(w, x, x?.restaurantId, 'Request'));
      case 'payouts':
        await w.role(_managers);
        final rows = await PayoutBatch.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        final items = await _itemsView(s, [for (final x in rows) x.id!], tx);
        return page([
          for (final x in rows)
            {...payoutView(x), 'items': items[x.id] ?? <Json>[]},
        ]);
      case 'payout':
        await w.role(_managers);
        final x = await PayoutBatch.db.findById(
          s,
          _int(d, 'id', min: 1),
          transaction: tx,
        );
        final batch = await _own(w, x, x?.restaurantId, 'Payout');
        final items = await _itemsView(s, [batch.id!], tx);
        return {...payoutView(batch), 'items': items[batch.id] ?? <Json>[]};
      case 'backoffice.closes':
        await w.role(_managers);
        final rows = await DailyClose.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page([for (final x in rows) closeView(x)]);
      case 'backoffice.close':
        await w.role(_managers);
        final day = d['day'] == null
            ? localDay(w.settings, _now())
            : _str(d, 'day', max: 10);
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(day)) {
          _fail('invalid_input', 'Invalid day.');
        }
        final x = await DailyClose.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(w.tenant) & t.day.equals(day),
          transaction: tx,
        );
        return x == null ? {'day': day, 'state': 'none'} : closeView(x);
      case 'customers':
        await w.role(_managers);
        final rows = await CustomerProfile.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant) & (t.id > cursor),
          orderBy: (t) => t.id,
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows)
            {
              'id': x.id,
              'displayName': x.displayName,
              'visits': x.visits,
              'spentMinor': x.spentMinor,
              'lastSeenAt': x.lastSeenAt.toIso8601String(),
              'tags': jsonDecode(x.tagsJson),
              'couponCode': x.couponCode,
              'daysSinceSeen': _now().difference(x.lastSeenAt).inDays,
            },
        ]);
      case 'disputes':
        await w.role(_managers);
        final rows = await DisputeCase.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final x in rows)
            {
              'id': x.id,
              'providerDisputeId': x.providerDisputeId,
              'captureId': x.captureId,
              'reason': x.reason,
              'amountMinor': x.amountMinor,
              'currency': x.currency,
              'status': x.status,
              'evidence': jsonDecode(x.evidenceJson),
              'replyText': x.replyText,
              'taskId': x.taskId,
              'version': x.version,
              'createdAt': x.createdAt.toIso8601String(),
            },
        ]);
      case 'analytics':
        await w.role(_managers);
        return analytics(w, d);
      case 'dashboard':
        await w.role(_managers);
        return DashboardModule.read(w, d);
    }
    return null;
  }

  /// Where the money went over a period: sales by hour and channel, PayPal
  /// fees (from PayPal's own list when reporting is enabled, else an
  /// estimate that says so), refunds, tips, staff cost, expenses, and the
  /// margin of dishes whose ingredients are stock items.
  static Future<Json> analytics(Work w, Json d) async {
    final s = w.s;
    final tx = w.tx;
    final to = d['to'] == null ? _now() : _date(d, 'to');
    final from = d['from'] == null
        ? to.subtract(const Duration(days: 7))
        : _date(d, 'from');
    if (!to.isAfter(from) || to.difference(from).inDays > 92) {
      _fail('invalid_input', 'Ask for a period of up to 92 days.');
    }
    final zone = CatalogueModule.zone(w.settings['timezone'] as String);
    final orders = await PurchaseOrder.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.createdAt >= from) &
          (t.createdAt <= to) &
          t.paymentStatus.inSet({'paid', 'partiallyRefunded'}) &
          t.status.notInSet({'cancelled', 'rejected', 'expired'}),
      limit: 20000,
      transaction: tx,
    );
    final ids = {for (final o in orders) o.id!};
    final contexts = ids.isEmpty
        ? const <OrderContext>[]
        : await OrderContext.db.find(
            s,
            where: (t) => t.orderId.inSet(ids),
            transaction: tx,
          );
    final origin = {for (final c in contexts) c.orderId: c.origin};
    final byHour = List.generate(
      24,
      (h) => <String, dynamic>{'hour': h, 'salesMinor': 0, 'orders': 0},
    );
    final byChannel = <String, int>{};
    for (final o in orders) {
      final hour = tz.TZDateTime.from(o.createdAt, zone).hour;
      byHour[hour]['salesMinor'] =
          (byHour[hour]['salesMinor'] as int) + o.totalMinor;
      byHour[hour]['orders'] = (byHour[hour]['orders'] as int) + 1;
      final channel = OrderingModule.isWalkIn(o.customerId)
          ? 'counter'
          : origin[o.id] == 'counter'
          ? 'counter'
          : o.fulfillment == 'dineIn'
          ? 'table'
          : o.fulfillment;
      byChannel[channel] = (byChannel[channel] ?? 0) + o.totalMinor;
    }
    // PayPal's own captures: a cash collection at the till ("cash:…") is
    // neither captured by PayPal nor charged a PayPal fee.
    final captures = await PaymentCapture.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.createdAt >= from) &
          (t.createdAt <= to) &
          t.state.equals('completed') &
          t.providerCaptureId.notLike('cash:%'),
      limit: 20000,
      transaction: tx,
    );
    final refunds = await PaymentRefund.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.createdAt >= from) &
          (t.createdAt <= to) &
          t.state.notInSet({'failed', 'denied'}),
      limit: 20000,
      transaction: tx,
    );
    final tips = ids.isEmpty
        ? const <BillCharge>[]
        : await BillCharge.db.find(
            s,
            where: (t) => t.orderId.inSet(ids) & t.kind.equals('tip'),
            transaction: tx,
          );
    final shifts = await StaffShift.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.startsAt >= from) &
          (t.startsAt <= to),
      limit: 5000,
      transaction: tx,
    );
    final expenses = await Expense.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.spentAt >= from) &
          (t.spentAt <= to),
      limit: 5000,
      transaction: tx,
    );
    int fees;
    var estimated = true;
    String feeSource = 'estimate';
    if (ProviderClients.environment()['RAYSTO_PAYPAL_REPORTING_ENABLED'] ==
            'true' &&
        to.difference(from).inDays <= 31) {
      try {
        final rows = await ProviderClients.listTransactions(
          from,
          to,
          account: await MerchantAppModule.forRestaurant(s, w.tenant),
        );
        fees = rows.fold<int>(0, (n, t) => n - ((t['feeMinor'] as int?) ?? 0));
        estimated = false;
        feeSource = 'paypal_transactions';
      } on DomainError {
        fees = _feeEstimate(captures);
      }
    } else {
      fees = _feeEstimate(captures);
    }
    final products = await MenuProduct.db.find(
      s,
      where: (t) => t.restaurantId.equals(w.tenant),
      limit: 500,
      transaction: tx,
    );
    final definitions = products.isEmpty
        ? const <MenuDefinition>[]
        : await MenuDefinition.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) & t.archived.equals(false),
            transaction: tx,
          );
    final stock = {
      for (final x in await StockItem.db.find(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        limit: 500,
        transaction: tx,
      ))
        x.name.toLowerCase(): x,
    };
    final byProduct = {for (final p in products) p.id: p};
    final margin = <Json>[];
    for (final def in definitions) {
      final p = byProduct[def.productId];
      final ingredients = (_json(def.definitionJson)['ingredients'] as List?)
          ?.whereType<String>()
          .toList();
      if (p == null || ingredients == null || ingredients.isEmpty) continue;
      final matched = [
        for (final i in ingredients)
          if (stock[i.toLowerCase()] != null) stock[i.toLowerCase()]!,
      ];
      if (matched.isEmpty) continue;
      margin.add({
        'name': p.name,
        'priceMinor': p.priceMinor,
        'costMinor': matched.fold<int>(0, (n, x) => n + x.costMinor),
        'ingredientsCosted': matched.length,
        'ingredients': ingredients.length,
      });
    }
    return {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'currency': w.restaurant!.currency,
      'byHour': byHour,
      'byChannel': [
        for (final e in byChannel.entries)
          {'channel': e.key, 'salesMinor': e.value},
      ],
      'salesMinor': orders.fold<int>(0, (n, o) => n + o.totalMinor),
      'orders': orders.length,
      'paypalCapturedMinor': captures.fold<int>(0, (n, c) => n + c.amountMinor),
      'feesMinor': fees,
      'feesEstimated': estimated,
      'feesSource': feeSource,
      'refundsMinor': refunds.fold<int>(0, (n, r) => n + r.amountMinor),
      'tipsMinor': tips.fold<int>(0, (n, t) => n + t.settledMinor),
      'staffCostMinor': shifts.fold<int>(
        0,
        (n, x) => n + workedMinutes(x) * x.hourlyRateMinor ~/ 60,
      ),
      'expensesMinor': expenses.fold<int>(0, (n, e) => n + e.amountMinor),
      'marginByDish': margin,
    };
  }

  /// PayPal's published Sandbox-era card rate, used only when the real
  /// transaction list is not available, and labelled as an estimate.
  static int _feeEstimate(List<PaymentCapture> captures) => captures.fold<int>(
    0,
    (n, c) => n + (c.amountMinor * 349 / 10000).round() + 49,
  );

  static Json payoutView(PayoutBatch x) => {
    'id': x.id,
    'kind': x.kind,
    'periodFrom': x.periodFrom.toIso8601String(),
    'periodTo': x.periodTo.toIso8601String(),
    'totalMinor': x.totalMinor,
    'currency': x.currency,
    'state': x.state,
    'providerBatchId': x.providerBatchId,
    'taskId': x.taskId,
    'summary': _json(x.summaryJson),
    'createdAt': x.createdAt.toIso8601String(),
    'updatedAt': x.updatedAt.toIso8601String(),
  };

  /// The lines of each listed batch, read in one query: the list and the
  /// single-batch query show the same items.
  static Future<Map<int, List<Json>>> _itemsView(
    Session s,
    List<int> batchIds,
    Transaction? tx,
  ) async {
    if (batchIds.isEmpty) return {};
    final items = await PayoutItem.db.find(
      s,
      where: (t) => t.batchId.inSet(batchIds.toSet()),
      orderBy: (t) => t.id,
      transaction: tx,
    );
    final byBatch = <int, List<Json>>{};
    for (final i in items) {
      (byBatch[i.batchId] ??= []).add({
        'id': i.id,
        'recipientEmail': i.recipientEmail,
        'recipientName': i.recipientName,
        'shiftIds': jsonDecode(i.shiftIdsJson),
        'amountMinor': i.amountMinor,
        'note': i.note,
        'providerItemId': i.providerItemId,
        'state': i.state,
      });
    }
    return byBatch;
  }

  static Json closeView(DailyClose x) => {
    'id': x.id,
    'day': x.day,
    'source': x.source,
    'summary': _json(x.summaryJson),
    'gaps': jsonDecode(x.gapsJson),
    'state': x.state,
    'signedBy': x.signedBy,
    'taskId': x.taskId,
    'version': x.version,
    'createdAt': x.createdAt.toIso8601String(),
    'updatedAt': x.updatedAt.toIso8601String(),
  };

  /// The café's calendar day for an instant, as `yyyy-mm-dd`.
  static String localDay(Json settings, DateTime at) {
    final local = tz.TZDateTime.from(
      at,
      CatalogueModule.zone(settings['timezone'] as String),
    );
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
