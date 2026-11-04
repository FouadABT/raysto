part of 'platform.dart';

/// Supplier orders, recipes and stock movements: what the café buys, what
/// its dishes use, and every change to stock with its reason. The arithmetic
/// that forecasts a stock-out is plain code here; the supply planner
/// (agent_supplies_plan.dart) only explains it and proposes orders.
/// Owner: stream S3.
class PurchasingModule {
  static const units = SuppliesAgent.units;
  static const windowDays = 28;
  static const defaultLeadDays = 2;
  static const wasteReasons = {'spoiled', 'expired', 'dropped', 'prep', 'other'};

  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'supplier.order.save': saveOrder,
    'supplier.order.cancel': cancelOrder,
    'supplier.order.send': sendOrder,
    'supplier.order.receive': receiveOrder,
    'recipe.save': saveRecipe,
    'stock.count': countStock,
    'stock.waste': wasteStock,
    'supplies.plan': SupplyPlanner.start,
  };

  // ---- Supplier orders -----------------------------------------------------

  static int _total(List<Json> lines) => lines.fold<int>(
    0,
    (n, l) => n + ((l['qty'] as num) * (l['unitCostMinor'] as int)).round(),
  );

  /// Order lines checked against the café's own stock items; the name and
  /// unit always come from the stock item, the price from the line or the
  /// item's last cost.
  static Future<List<Json>> _lines(Work w, Json d) async {
    final raw = _list(d, 'lines', max: 60).map(_object).toList();
    if (raw.isEmpty) _fail('invalid_input', 'Add at least one line.');
    final items = {
      for (final x in await StockItem.db.find(
        w.s,
        where: (t) => t.restaurantId.equals(w.tenant),
        limit: 1000,
        transaction: w.tx,
      ))
        x.id!: x,
    };
    final seen = <int>{};
    final lines = <Json>[];
    for (final l in raw) {
      _keys(l, {'stockItemId', 'name', 'unit', 'qty', 'unitCostMinor'});
      final id = _int(l, 'stockItemId', min: 1, max: 1 << 31);
      final item = items[id] ?? _fail('not_found', 'Stock item not found.');
      if (!seen.add(id)) {
        _fail('invalid_input', 'Each stock item appears once per order.');
      }
      final qty = BackOfficeModule._amount(l, 'qty', max: 100000);
      if (qty <= 0) _fail('invalid_input', 'Invalid qty.');
      lines.add({
        'stockItemId': id,
        'name': item.name,
        'unit': item.unit,
        'qty': qty,
        'unitCostMinor': l['unitCostMinor'] == null
            ? item.costMinor
            : _int(l, 'unitCostMinor', max: 10000000),
        'receivedQty': 0.0,
      });
    }
    return lines;
  }

  static Future<SupplierOrder> _order(Work w, PlatformCommand c) async {
    final found = await SupplierOrder.db.findById(
      w.s,
      _id(c),
      transaction: w.tx,
    );
    final row = await BackOfficeModule._own<SupplierOrder>(
      w,
      found,
      found?.restaurantId,
      'Supplier order',
    );
    _version(row.version, c.expectedVersion);
    return row;
  }

  static Json _result(SupplierOrder o) => {
    'orderId': o.id,
    'state': o.state,
    'version': o.version,
    'totalMinor': o.totalMinor,
  };

  /// A draft order to a supplier, or a change to a draft; `state:
  /// "cancelled"` cancels a draft or a sent order instead.
  static Future<Json> saveOrder(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.order.save',
    (w, d) async {
      _keys(d, {'supplierId', 'lines', 'expectedAt', 'note', 'state'});
      SupplierOrder? row;
      if (c.resourceId != null) row = await _order(w, c);
      if (d.containsKey('state')) {
        _str(d, 'state', choices: {'cancelled'});
        if (row == null) _fail('invalid_input', 'Choose the order to cancel.');
        return _cancel(w, row);
      }
      if (row != null && row.state != 'draft') {
        _fail('invalid_transition', 'Only a draft can be edited.');
      }
      return _result(await _draft(w, d, row));
    },
    roles: _managers,
  );

  /// `supplier.order.cancel`: the same as saving `state: "cancelled"`.
  static Future<Json> cancelOrder(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.order.cancel',
    (w, d) async {
      _keys(d, {});
      return _cancel(w, await _order(w, c));
    },
    roles: _managers,
  );

  static Future<Json> _cancel(Work w, SupplierOrder row) async {
    if (!{'draft', 'sent'}.contains(row.state)) {
      _fail(
        'invalid_transition',
        'Only a draft or a sent order can be cancelled.',
      );
    }
    row
      ..state = 'cancelled'
      ..version += 1
      ..updatedAt = _now();
    await SupplierOrder.db.updateRow(w.s, row, transaction: w.tx);
    await w.audit('supplier.order.cancelled', 'supplierOrder', row.id);
    return _result(row);
  }

  /// The draft an approved planner proposal becomes (`supplier.order.propose`),
  /// on the approving manager's session; it keeps the planner's task.
  static Future<Json> proposeOrder(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.order.propose',
    (w, d) async {
      _keys(d, {'supplierId', 'lines', 'note', 'taskId'});
      final taskId = _int(d, 'taskId', min: 1, max: 1 << 31);
      final existing = await SupplierOrder.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.taskId.equals(taskId) &
            (d['supplierId'] == null
                ? t.supplierId.equals(null)
                : t.supplierId.equals(d['supplierId'] as int)),
        transaction: w.tx,
      );
      if (existing != null) return _result(existing);
      final row = await _draft(w, {...d}..remove('taskId'), null, taskId: taskId);
      return _result(row);
    },
    roles: _managers,
  );

  static Future<SupplierOrder> _draft(
    Work w,
    Json d,
    SupplierOrder? row, {
    int? taskId,
  }) async {
    final s = w.s;
    Supplier? supplier;
    if (d['supplierId'] != null) {
      final found = await Supplier.db.findById(
        s,
        _int(d, 'supplierId', min: 1, max: 1 << 31),
        transaction: w.tx,
      );
      supplier = await BackOfficeModule._own<Supplier>(
        w,
        found,
        found?.restaurantId,
        'Supplier',
      );
    }
    final lines = await _lines(w, d);
    row ??= SupplierOrder(
      restaurantId: w.tenant,
      state: 'draft',
      linesJson: '[]',
      totalMinor: 0,
      currency: w.restaurant!.currency,
      taskId: taskId,
      createdBy: w.user,
      version: 0,
      createdAt: _now(),
      updatedAt: _now(),
    );
    row
      ..supplierId = supplier?.id
      ..linesJson = jsonEncode(lines)
      ..totalMinor = _total(lines)
      ..expectedAt = d['expectedAt'] == null
          ? _now().add(Duration(days: supplier?.leadDays ?? defaultLeadDays))
          : _date(d, 'expectedAt')
      ..note = d['note'] == null ? null : _str(d, 'note', max: 500)
      ..version += 1
      ..updatedAt = _now();
    row = row.id == null
        ? await SupplierOrder.db.insertRow(s, row, transaction: w.tx)
        : await SupplierOrder.db.updateRow(s, row, transaction: w.tx);
    await w.audit('supplier.order.saved', 'supplierOrder', row.id, {
      'lines': lines.length,
      'totalMinor': row.totalMinor,
      'taskId': ?taskId,
    });
    return row;
  }

  /// The draft goes to the supplier: an email with the lines, when the
  /// supplier has an email on file; otherwise it is marked sent and the
  /// answer says the manager sends it themselves.
  static Future<Json> sendOrder(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.order.send',
    (w, d) async {
      _keys(d, {'email'});
      final row = await _order(w, c);
      if (row.state != 'draft') {
        _fail('invalid_transition', 'Only a draft can be sent.');
      }
      if (row.supplierId == null) {
        _fail('invalid_input', 'Choose the supplier first.');
      }
      final supplier = (await Supplier.db.findById(
        s,
        row.supplierId!,
        transaction: w.tx,
      ))!;
      // An order email typed at send time is kept on the supplier.
      if (d['email'] != null) {
        final typed = BackOfficeModule._email(d, 'email');
        if (typed != supplier.email) {
          supplier
            ..email = typed
            ..version += 1;
          await Supplier.db.updateRow(s, supplier, transaction: w.tx);
        }
      }
      final email = (supplier.email ?? '').trim().isEmpty
          ? null
          : supplier.email!.trim();
      row
        ..state = 'sent'
        ..sentAt = _now()
        ..expectedAt ??= _now().add(
          Duration(days: supplier.leadDays ?? defaultLeadDays),
        )
        ..version += 1
        ..updatedAt = _now();
      await SupplierOrder.db.updateRow(s, row, transaction: w.tx);
      if (email != null) {
        await w.job('email.supplierOrder', 'supplier-order:${row.id}', {
          'orderId': row.id,
        });
      }
      await w.audit('supplier.order.sent', 'supplierOrder', row.id, {
        'emailed': email != null,
      });
      return {..._result(row), 'emailed': email != null, 'to': email};
    },
    roles: _managers,
  );

  /// The email job: the order as the supplier reads it.
  static Future<void> emailOrder(Session s, int orderId) async {
    final o = await SupplierOrder.db.findById(s, orderId);
    if (o == null || o.state == 'cancelled' || o.supplierId == null) return;
    final supplier = await Supplier.db.findById(s, o.supplierId!);
    final restaurant = await Restaurant.db.findById(s, o.restaurantId);
    final to = (supplier?.email ?? '').trim();
    if (to.isEmpty || restaurant == null) return;
    final lines = (jsonDecode(o.linesJson) as List).cast<Json>();
    String money(int minor) => '${PayPalGateway.money(minor)} ${o.currency}';
    final text = StringBuffer()
      ..writeln('Purchase order PO-${o.id} from ${restaurant.name}.')
      ..writeln()
      ..writeln([
        for (final l in lines)
          '- ${l['qty']} ${l['unit']} ${l['name']} at ${money(l['unitCostMinor'] as int)}',
      ].join('\n'))
      ..writeln()
      ..writeln('Total: ${money(o.totalMinor)}')
      ..writeln(
        o.expectedAt == null
            ? ''
            : 'Expected by: ${o.expectedAt!.toIso8601String().substring(0, 10)}',
      )
      ..writeln(o.note == null ? '' : 'Note: ${o.note}');
    await ProviderClients.email(
      to,
      'Purchase order PO-${o.id} from ${restaurant.name}',
      text.toString().trim(),
    );
  }

  /// Goods arrive: some or all of each line. Stock goes up at the price
  /// paid, each line keeps what has arrived, and the order is partly or
  /// fully received. A delivery note read by the supplies agent may be
  /// linked to the order at the same time.
  static Future<Json> receiveOrder(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'supplier.order.receive',
    (w, d) async {
      _keys(d, {'lines', 'deliveryId'});
      final row = await _order(w, c);
      if (!{'sent', 'partiallyReceived'}.contains(row.state)) {
        _fail(
          'invalid_transition',
          'Only a sent order can be received.',
        );
      }
      final lines = (jsonDecode(row.linesJson) as List).cast<Json>();
      final arrived = _list(d, 'lines', max: 60).map(_object).toList();
      if (arrived.isEmpty) _fail('invalid_input', 'Add what arrived.');
      final ref = '${row.id}:${row.version}';
      final seen = <int>{};
      for (final a in arrived) {
        _keys(a, {'stockItemId', 'qty', 'unitCostMinor'});
        final id = _int(a, 'stockItemId', min: 1, max: 1 << 31);
        if (!seen.add(id)) {
          _fail('invalid_input', 'Each item appears once per receipt.');
        }
        final line = lines.firstWhere(
          (l) => l['stockItemId'] == id,
          orElse: () => _fail('invalid_input', 'That item is not on this order.'),
        );
        final qty = BackOfficeModule._amount(a, 'qty', max: 100000);
        if (qty <= 0) _fail('invalid_input', 'Invalid qty.');
        final cost = a['unitCostMinor'] == null
            ? line['unitCostMinor'] as int
            : _int(a, 'unitCostMinor', max: 10000000);
        line['receivedQty'] = ((line['receivedQty'] as num?) ?? 0) + qty;
        line['receivedUnitCostMinor'] = cost;
        await _move(
          w,
          id,
          qty,
          kind: 'receive',
          unitCostMinor: cost,
          refType: 'supplierOrder',
          refId: ref,
          setCost: cost,
        );
      }
      final complete = lines.every(
        (l) => ((l['receivedQty'] as num?) ?? 0) >= (l['qty'] as num),
      );
      row
        ..linesJson = jsonEncode(lines)
        ..state = complete ? 'received' : 'partiallyReceived'
        ..receivedAt = complete ? _now() : row.receivedAt
        ..version += 1
        ..updatedAt = _now();
      await SupplierOrder.db.updateRow(s, row, transaction: w.tx);
      if (d['deliveryId'] != null) {
        final found = await SupplyDelivery.db.findById(
          s,
          _int(d, 'deliveryId', min: 1, max: 1 << 31),
          transaction: w.tx,
        );
        final delivery = await BackOfficeModule._own<SupplyDelivery>(
          w,
          found,
          found?.restaurantId,
          'Delivery',
        );
        delivery
          ..supplierOrderId = row.id
          ..version += 1;
        await SupplyDelivery.db.updateRow(s, delivery, transaction: w.tx);
      }
      await w.audit('supplier.order.received', 'supplierOrder', row.id, {
        'lines': arrived.length,
        'complete': complete,
      });
      return {..._result(row), 'complete': complete};
    },
    roles: _managers,
  );

  /// One change to a stock item with its reason, written once: a second
  /// write for the same reference and item is ignored (and changes nothing).
  /// Returns false when it had already been written.
  static Future<bool> _move(
    Work w,
    int stockItemId,
    double quantity, {
    required String kind,
    required String refType,
    required String refId,
    int? unitCostMinor,
    int? setCost,
    double? setQuantity,
  }) async {
    final seen = await StockMovement.db.count(
      w.s,
      where: (t) =>
          t.refType.equals(refType) &
          t.refId.equals(refId) &
          t.stockItemId.equals(stockItemId),
      transaction: w.tx,
    );
    if (seen > 0) return false;
    final item = await StockItem.db.findById(
      w.s,
      stockItemId,
      transaction: w.tx,
    );
    if (item == null || item.restaurantId != w.tenant) {
      _fail('not_found', 'Stock item not found.');
    }
    await StockMovement.db.insert(
      w.s,
      [
        StockMovement(
          restaurantId: w.tenant,
          stockItemId: stockItemId,
          kind: kind,
          quantity: quantity,
          unitCostMinor: unitCostMinor ?? item.costMinor,
          refType: refType,
          refId: refId,
          at: _now(),
          userId: w.user,
        ),
      ],
      ignoreConflicts: true,
      transaction: w.tx,
    );
    item
      ..quantity = setQuantity ?? max(0, item.quantity + quantity)
      ..costMinor = setCost ?? item.costMinor
      ..updatedAt = _now()
      ..version += 1;
    await StockItem.db.updateRow(w.s, item, transaction: w.tx);
    return true;
  }

  // ---- Recipes, counts and waste -------------------------------------------

  /// What one dish uses: stock items and quantities per portion. Saving
  /// replaces the dish's whole recipe.
  static Future<Json> saveRecipe(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'recipe.save',
    (w, d) async {
      _keys(d, {'productId', 'lines'});
      final productId = _int(d, 'productId', min: 1, max: 1 << 31);
      final product = await MenuProduct.db.findById(
        s,
        productId,
        transaction: w.tx,
      );
      await BackOfficeModule._own(w, product, product?.restaurantId, 'Dish');
      final raw = _list(d, 'lines', max: 30).map(_object).toList();
      final items = {
        for (final x in await StockItem.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          limit: 1000,
          transaction: w.tx,
        ))
          x.id!: x,
      };
      final seen = <int>{};
      final rows = <RecipeLine>[];
      for (final l in raw) {
        _keys(l, {'stockItemId', 'quantity'});
        final id = _int(l, 'stockItemId', min: 1, max: 1 << 31);
        if (!items.containsKey(id)) _fail('not_found', 'Stock item not found.');
        if (!seen.add(id)) {
          _fail('invalid_input', 'Each stock item appears once per dish.');
        }
        final quantity = BackOfficeModule._amount(l, 'quantity', max: 1000);
        if (quantity <= 0) _fail('invalid_input', 'Invalid quantity.');
        rows.add(
          RecipeLine(
            restaurantId: w.tenant,
            productId: productId,
            stockItemId: id,
            quantity: quantity,
            updatedAt: _now(),
          ),
        );
      }
      await RecipeLine.db.deleteWhere(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.productId.equals(productId),
        transaction: w.tx,
      );
      if (rows.isNotEmpty) {
        await RecipeLine.db.insert(s, rows, transaction: w.tx);
      }
      await w.audit('recipe.saved', 'product', productId, {
        'lines': rows.length,
      });
      return {'productId': productId, 'lines': rows.length};
    },
    roles: _managers,
  );

  /// A physical count: the item becomes what was counted, and the
  /// difference is kept as a movement so the forecast can learn from it.
  static Future<Json> countStock(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'stock.count',
    (w, d) async {
      _keys(d, {'stockItemId', 'quantity'});
      final id = _int(d, 'stockItemId', min: 1, max: 1 << 31);
      final counted = BackOfficeModule._amount(d, 'quantity', max: 1000000);
      final item = await StockItem.db.findById(s, id, transaction: w.tx);
      await BackOfficeModule._own(w, item, item?.restaurantId, 'Stock item');
      final variance = _round(counted - item!.quantity, 3);
      await _move(
        w,
        id,
        variance,
        kind: 'count',
        refType: 'count',
        refId: '$id:${item.version}',
        setQuantity: counted,
      );
      await w.audit('stock.counted', 'stock', id, {
        'quantity': counted,
        'variance': variance,
      });
      return {'stockItemId': id, 'quantity': counted, 'variance': variance};
    },
    roles: {..._managers, 'kitchen'},
  );

  /// Thrown away, with why; the forecast counts waste as usage.
  static Future<Json> wasteStock(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'stock.waste',
    (w, d) async {
      _keys(d, {'stockItemId', 'quantity', 'reason'});
      final id = _int(d, 'stockItemId', min: 1, max: 1 << 31);
      final quantity = BackOfficeModule._amount(d, 'quantity', max: 100000);
      if (quantity <= 0) _fail('invalid_input', 'Invalid quantity.');
      final reason = _str(d, 'reason', choices: wasteReasons);
      final item = await StockItem.db.findById(s, id, transaction: w.tx);
      await BackOfficeModule._own(w, item, item?.restaurantId, 'Stock item');
      await _move(
        w,
        id,
        -quantity,
        kind: 'waste',
        refType: 'waste',
        refId: '$id:${item!.version}:$reason',
      );
      await w.audit('stock.wasted', 'stock', id, {
        'quantity': quantity,
        'reason': reason,
        'valueMinor': (quantity * item.costMinor).round(),
      });
      return {'stockItemId': id, 'quantity': quantity, 'reason': reason};
    },
    roles: {..._managers, 'kitchen'},
  );

  /// Wakes on every completed customer order (an audit trigger): what the
  /// dishes used, by their recipes, leaves stock once. Never throws; a café
  /// without recipes is untouched.
  static Future<void> onOrderCompleted(
    Work w,
    String type,
    int? id,
    Json details,
  ) async {
    if (type != 'order' || id == null) return;
    final order = await PurchaseOrder.db.findById(w.s, id, transaction: w.tx);
    if (order == null || order.restaurantId != w.tenant) return;
    final products = {for (final l in order.lines) l.productId};
    if (products.isEmpty) return;
    final recipes = await RecipeLine.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) & t.productId.inSet(products),
      transaction: w.tx,
    );
    if (recipes.isEmpty) return;
    // A recipe may still name an item deleted since; skip it rather than
    // fail the order (this runs inside the order's own transaction).
    final live = {
      for (final x in await StockItem.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.id.inSet(<int>{for (final r in recipes) r.stockItemId}),
        transaction: w.tx,
      ))
        x.id!,
    };
    final used = usage(order.lines, recipes);
    for (final e in used.entries) {
      if (!live.contains(e.key) || e.value <= 0) continue;
      await _move(
        w,
        e.key,
        -e.value,
        kind: 'sale',
        refType: 'order',
        refId: '$id',
      );
    }
  }

  /// Stock used by order lines, by recipe: item id → quantity.
  static Map<int, double> usage(
    Iterable<OrderLine> lines,
    Iterable<RecipeLine> recipes,
  ) {
    final byProduct = <int, List<RecipeLine>>{};
    for (final r in recipes) {
      (byProduct[r.productId] ??= []).add(r);
    }
    final used = <int, double>{};
    for (final line in lines) {
      for (final r in byProduct[line.productId] ?? const <RecipeLine>[]) {
        used[r.stockItemId] =
            (used[r.stockItemId] ?? 0) + line.quantity * r.quantity;
      }
    }
    return {for (final e in used.entries) e.key: _round(e.value, 3)};
  }

  // ---- The forecast (plain arithmetic) -------------------------------------

  static double _round(num v, int places) {
    final f = pow(10, places);
    return (v * f).round() / f;
  }

  /// How much to order of something sold by the piece or the box is whole.
  static double roundQty(double q, String unit) =>
      {'piece', 'box'}.contains(unit) ? q.ceilToDouble() : _round(q, 2);

  /// The forecast for one stock item. `consumed` is how much was used over
  /// `windowDays` (sales and waste, as a positive number). Reorder when the
  /// stock left at the end of the lead time would be below the low mark;
  /// order up to the par level (or, without one, twice the low mark or a
  /// week past the lead time).
  static Json forecast({
    required double quantity,
    required double lowAt,
    double? parLevel,
    required int leadDays,
    required double consumed,
    required String unit,
    required DateTime now,
    int window = windowDays,
  }) {
    final daily = window > 0 && consumed > 0 ? consumed / window : 0.0;
    final cover = daily > 0 ? quantity / daily : null;
    final atArrival = quantity - daily * leadDays;
    final par = parLevel ?? max(lowAt * 2, daily * (leadDays + 7));
    final short = daily > 0 ? atArrival < lowAt : quantity < lowAt;
    final suggested = short
        ? roundQty(max(0, par - max(0, atArrival)).toDouble(), unit)
        : 0.0;
    return {
      'dailyUsage': _round(daily, 3),
      'daysCover': cover == null ? null : _round(cover, 1),
      'stockOutAt': cover == null
          ? null
          : now.add(Duration(minutes: (cover * 1440).round())).toIso8601String(),
      'atArrival': _round(atArrival, 3),
      'parLevel': _round(par, 3),
      'reorder': short && suggested > 0,
      'suggestedQty': suggested,
    };
  }

  /// Every stock item with its forecast, its supplier and its value. Usage
  /// comes from the movements of the last 28 days (sales and waste); when
  /// there are none yet, from completed orders × recipes; else "none".
  static Future<Json> forecastAll(Work w) async {
    final s = w.s;
    final tx = w.tx;
    final now = _now();
    final since = now.subtract(const Duration(days: windowDays));
    final items = await StockItem.db.find(
      s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.name,
      limit: 1000,
      transaction: tx,
    );
    final suppliers = {
      for (final x in await Supplier.db.find(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        limit: 500,
        transaction: tx,
      ))
        x.id!: x,
    };
    final moves = await StockMovement.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.at >= since) &
          t.kind.inSet({'sale', 'waste'}),
      limit: 20000,
      transaction: tx,
    );
    final consumed = <int, double>{};
    for (final m in moves) {
      consumed[m.stockItemId] = (consumed[m.stockItemId] ?? 0) - m.quantity;
    }
    var basis = moves.isEmpty ? 'none' : 'movements';
    if (moves.isEmpty) {
      final recipes = await RecipeLine.db.find(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        limit: 5000,
        transaction: tx,
      );
      if (recipes.isNotEmpty) {
        final orders = await PurchaseOrder.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (t.createdAt >= since) &
              t.status.equals('completed'),
          limit: 5000,
          transaction: tx,
        );
        if (orders.isNotEmpty) {
          basis = 'recipes';
          final used = usage([for (final o in orders) ...o.lines], recipes);
          consumed.addAll(used);
        }
      }
    }
    final rows = <Json>[];
    for (final x in items) {
      final supplier = x.supplierId == null ? null : suppliers[x.supplierId];
      final lead = x.leadDays ?? supplier?.leadDays ?? defaultLeadDays;
      final f = forecast(
        quantity: x.quantity,
        lowAt: x.lowAt,
        parLevel: x.parLevel,
        leadDays: lead,
        consumed: consumed[x.id] ?? 0,
        unit: x.unit,
        now: now,
      );
      rows.add({
        'stockItemId': x.id,
        'name': x.name,
        'unit': x.unit,
        'quantity': x.quantity,
        'lowAt': x.lowAt,
        'low': x.quantity <= x.lowAt,
        'costMinor': x.costMinor,
        'valueMinor': (x.quantity * x.costMinor).round(),
        'leadDays': lead,
        'supplierId': supplier?.id,
        'supplierName': supplier?.name,
        'version': x.version,
        ...f,
      });
    }
    final waste = await StockMovement.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.at >= since) &
          t.kind.equals('waste'),
      orderBy: (t) => t.at.desc(),
      limit: 50,
      transaction: tx,
    );
    final names = {for (final x in items) x.id!: x};
    return {
      'rows': rows,
      'basis': basis,
      'windowDays': windowDays,
      'currency': w.restaurant!.currency,
      'waste': [
        for (final m in waste)
          {
            'stockItemId': m.stockItemId,
            'name': names[m.stockItemId]?.name,
            'unit': names[m.stockItemId]?.unit,
            'quantity': -m.quantity,
            'valueMinor': (-m.quantity * (m.unitCostMinor ?? 0)).round(),
            'reason': m.refId.split(':').last,
            'at': m.at.toIso8601String(),
          },
      ],
      'nextCursor': null,
    };
  }

  // ---- The 3-way match (plain comparison) ----------------------------------

  static String _key(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// The purchase order against what the delivery note says arrived and,
  /// when there is one, what the supplier's bill charges: per line, the
  /// quantity and price differences, with flags a person reads. Prices
  /// differing by more than 5% are flagged; quantities by any amount.
  static Json match({
    required List<Json> ordered,
    required List<Json> delivered,
    List<Json>? billed,
    int? billTotalMinor,
  }) {
    final out = <Json>[];
    final deliveredBy = {for (final l in delivered) _key(l['name'] as String): l};
    final billedBy = {
      for (final l in billed ?? const <Json>[]) _key(l['name'] as String): l,
    };
    final used = <String>{};
    var flagged = 0;
    for (final o in ordered) {
      final k = _key(o['name'] as String);
      used.add(k);
      final d = deliveredBy[k];
      final b = billedBy[k];
      final orderedQty = (o['qty'] as num).toDouble();
      final orderedUnit = o['unitCostMinor'] as int;
      final flags = <String>[];
      double? deliveredQty;
      int? deliveredUnit;
      if (d == null) {
        flags.add('missing');
      } else {
        deliveredQty = (d['quantity'] as num).toDouble();
        deliveredUnit = d['unitCostMinor'] as int;
        if (deliveredQty < orderedQty) flags.add('short');
        if (deliveredQty > orderedQty) flags.add('over');
        if (orderedUnit > 0) {
          final change = (deliveredUnit - orderedUnit) / orderedUnit;
          if (change > 0.05) flags.add('price_up');
          if (change < -0.05) flags.add('price_down');
        }
      }
      final billedUnit = b == null ? null : b['unitCostMinor'] as int?;
      if (billedUnit != null &&
          deliveredUnit != null &&
          billedUnit != deliveredUnit) {
        flags.add('billed_differs');
      }
      if (flags.isNotEmpty) flagged++;
      out.add({
        'name': o['name'],
        'stockItemId': o['stockItemId'],
        'unit': o['unit'],
        'orderedQty': orderedQty,
        'deliveredQty': deliveredQty,
        'qtyVariance': deliveredQty == null ? -orderedQty : _round(deliveredQty - orderedQty, 3),
        'orderedUnitMinor': orderedUnit,
        'deliveredUnitMinor': deliveredUnit,
        'billedUnitMinor': billedUnit,
        'priceVariancePct': deliveredUnit == null || orderedUnit == 0
            ? null
            : _round((deliveredUnit - orderedUnit) * 100 / orderedUnit, 1),
        'flags': flags,
      });
    }
    for (final d in delivered) {
      final k = _key(d['name'] as String);
      if (used.contains(k)) continue;
      flagged++;
      out.add({
        'name': d['name'],
        'stockItemId': null,
        'unit': d['unit'],
        'orderedQty': 0.0,
        'deliveredQty': (d['quantity'] as num).toDouble(),
        'qtyVariance': (d['quantity'] as num).toDouble(),
        'orderedUnitMinor': null,
        'deliveredUnitMinor': d['unitCostMinor'],
        'billedUnitMinor': null,
        'priceVariancePct': null,
        'flags': ['not_ordered'],
      });
    }
    int sum(List<Json> lines, String q, String p) => lines.fold<int>(
      0,
      (n, l) => n + ((l[q] as num) * (l[p] as num)).round(),
    );
    final orderedTotal = sum(ordered, 'qty', 'unitCostMinor');
    final deliveredTotal = sum(delivered, 'quantity', 'unitCostMinor');
    return {
      'lines': out,
      'flagged': flagged,
      'orderedTotalMinor': orderedTotal,
      'deliveredTotalMinor': deliveredTotal,
      'billTotalMinor': billTotalMinor,
      'billDiffers': billTotalMinor != null && billTotalMinor != deliveredTotal,
      'clean': flagged == 0 &&
          (billTotalMinor == null || billTotalMinor == deliveredTotal),
    };
  }

  // ---- Supplier bills (into the accountant's payables) ---------------------

  /// A supplier's bill waiting for review in the accountant's payables. The
  /// accountant's own flows (stream S1) approve and pay it; `bill.match`
  /// approves it once the 3-way match is read.
  static Future<Bill> supplierBill(
    Work w, {
    required int supplierId,
    required int amountMinor,
    required String currency,
    int? supplierOrderId,
    int? sourceMediaId,
    String? reference,
    DateTime? dueAt,
    Json read = const {},
  }) async {
    final supplier = (await Supplier.db.findById(
      w.s,
      supplierId,
      transaction: w.tx,
    ))!;
    final email = supplier.payoutEmail.trim().isEmpty
        ? null
        : supplier.payoutEmail.trim();
    return Bill.db.insertRow(
      w.s,
      Bill(
        restaurantId: w.tenant,
        vendor: supplier.name,
        category: 'supplier',
        reference: reference,
        amountMinor: amountMinor,
        vatMinor: 0,
        currency: currency,
        issuedAt: _now(),
        dueAt: dueAt,
        state: 'review',
        payVia: email == null ? 'elsewhere' : 'paypal',
        payeeEmail: email,
        sourceMediaId: sourceMediaId,
        supplierId: supplierId,
        supplierOrderId: supplierOrderId,
        readJson: jsonEncode(read),
        version: 1,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
  }

  /// The approved supplier bill for an order: the order's bill when one is
  /// waiting in review, else a new one for what the delivery note charges.
  /// Moves a received order to `billed`. Runs on the approver's session.
  static Future<Json> approveSupplierBill(Session s, PlatformCommand c) =>
      _mutate(s, c, 'bill.match', (w, d) async {
        _keys(d, {'deliveryId'});
        final found = await SupplyDelivery.db.findById(
          s,
          _int(d, 'deliveryId', min: 1, max: 1 << 31),
          transaction: w.tx,
        );
        final delivery = await BackOfficeModule._own<SupplyDelivery>(
          w,
          found,
          found?.restaurantId,
          'Delivery',
        );
        if (delivery.supplierOrderId == null || delivery.supplierId == null) {
          _fail('invalid_input', 'Receive this delivery against an order first.');
        }
        final order = (await SupplierOrder.db.findById(
          s,
          delivery.supplierOrderId!,
          transaction: w.tx,
        ))!;
        var bill = order.billId == null
            ? await Bill.db.findFirstRow(
                s,
                where: (t) =>
                    t.restaurantId.equals(w.tenant) &
                    t.supplierOrderId.equals(order.id!) &
                    t.state.inSet({'review', 'approved'}),
                transaction: w.tx,
              )
            : await Bill.db.findById(s, order.billId!, transaction: w.tx);
        bill ??= await supplierBill(
          w,
          supplierId: delivery.supplierId!,
          amountMinor: delivery.totalMinor,
          currency: delivery.currency,
          supplierOrderId: order.id,
          sourceMediaId: delivery.mediaId,
          reference: 'PO-${order.id}',
          dueAt: _now().add(const Duration(days: 7)),
          read: {'from': 'deliveryNote', 'deliveryId': delivery.id},
        );
        if (!{'review', 'approved'}.contains(bill.state)) {
          _fail('invalid_transition', 'This bill is already ${bill.state}.');
        }
        bill
          ..state = 'approved'
          ..version += 1
          ..updatedAt = _now();
        await Bill.db.updateRow(s, bill, transaction: w.tx);
        order
          ..billId = bill.id
          ..state = {'received', 'partiallyReceived'}.contains(order.state)
              ? 'billed'
              : order.state
          ..version += 1
          ..updatedAt = _now();
        await SupplierOrder.db.updateRow(s, order, transaction: w.tx);
        await w.audit('bill.matched', 'bill', bill.id, {
          'supplierOrderId': order.id,
          'deliveryId': delivery.id,
          'amountMinor': bill.amountMinor,
        });
        return {
          'billId': bill.id,
          'state': bill.state,
          'amountMinor': bill.amountMinor,
          'supplierOrderId': order.id,
        };
      }, roles: _finance);

  // ---- Reads ----------------------------------------------------------------

  /// An order as the console shows it; a paid bill shows the order as paid.
  static Json orderView(
    SupplierOrder o, {
    Supplier? supplier,
    Bill? bill,
  }) => {
    'id': o.id,
    'supplierId': o.supplierId,
    'supplierName': supplier?.name,
    'supplierEmail': supplier?.email,
    'state': bill != null && {'paid', 'paidElsewhere'}.contains(bill.state)
        ? 'paid'
        : o.state,
    'lines': jsonDecode(o.linesJson),
    'totalMinor': o.totalMinor,
    'currency': o.currency,
    'expectedAt': o.expectedAt?.toIso8601String(),
    'sentAt': o.sentAt?.toIso8601String(),
    'receivedAt': o.receivedAt?.toIso8601String(),
    'billId': o.billId,
    'billState': bill?.state,
    'taskId': o.taskId,
    'note': o.note,
    'createdBy': o.createdBy,
    'version': o.version,
    'createdAt': o.createdAt.toIso8601String(),
    'updatedAt': o.updatedAt.toIso8601String(),
  };

  static Future<List<Json>> _views(Work w, List<SupplierOrder> rows) async {
    final supplierIds = {for (final o in rows) ?o.supplierId};
    final billIds = {for (final o in rows) ?o.billId};
    final suppliers = supplierIds.isEmpty
        ? const <int, Supplier>{}
        : {
            for (final x in await Supplier.db.find(
              w.s,
              where: (t) => t.id.inSet(supplierIds),
              transaction: w.tx,
            ))
              x.id!: x,
          };
    final bills = billIds.isEmpty
        ? const <int, Bill>{}
        : {
            for (final x in await Bill.db.find(
              w.s,
              where: (t) => t.id.inSet(billIds),
              transaction: w.tx,
            ))
              x.id!: x,
          };
    return [
      for (final o in rows)
        orderView(
          o,
          supplier: suppliers[o.supplierId],
          bill: bills[o.billId],
        ),
    ];
  }

  /// Per supplier: on-time deliveries, how much of what was ordered arrived,
  /// and how far prices moved from the order, over its received orders.
  static Future<Json> scorecards(Work w) async {
    final orders = await SupplierOrder.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.state.inSet({
            'partiallyReceived',
            'received',
            'billed',
            'paid',
          }),
      limit: 2000,
      transaction: w.tx,
    );
    final suppliers = await Supplier.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.name,
      limit: 500,
      transaction: w.tx,
    );
    final rows = <Json>[];
    for (final sup in suppliers) {
      final mine = orders.where((o) => o.supplierId == sup.id).toList();
      var timed = 0, onTime = 0;
      double ordered = 0, received = 0, orderedValue = 0, paidValue = 0;
      DateTime? last;
      for (final o in mine) {
        if (o.expectedAt != null && o.receivedAt != null) {
          timed++;
          if (!o.receivedAt!.isAfter(o.expectedAt!.add(const Duration(hours: 12)))) {
            onTime++;
          }
        }
        if (last == null || o.createdAt.isAfter(last)) last = o.createdAt;
        for (final l in (jsonDecode(o.linesJson) as List).cast<Json>()) {
          final q = (l['qty'] as num).toDouble();
          final r = ((l['receivedQty'] as num?) ?? 0).toDouble();
          final unit = (l['unitCostMinor'] as num).toDouble();
          final paidUnit = ((l['receivedUnitCostMinor'] as num?) ?? unit)
              .toDouble();
          ordered += q;
          received += min(r, q);
          if (r > 0) {
            orderedValue += r * unit;
            paidValue += r * paidUnit;
          }
        }
      }
      rows.add({
        'supplierId': sup.id,
        'name': sup.name,
        'orders': mine.length,
        'onTimePct': timed == 0 ? null : _round(onTime * 100 / timed, 1),
        'fillRatePct': ordered == 0 ? null : _round(received * 100 / ordered, 1),
        'priceVariancePct': orderedValue == 0
            ? null
            : _round((paidValue - orderedValue) * 100 / orderedValue, 1),
        'lastOrderAt': last?.toIso8601String(),
        'leadDays': sup.leadDays ?? defaultLeadDays,
        'hasEmail': (sup.email ?? '').trim().isNotEmpty,
        'hasPayPal': sup.payoutEmail.trim().isNotEmpty,
      });
    }
    return {'rows': rows, 'nextCursor': null};
  }

  /// A direct read for tests and jobs, like BackOfficeModule.read: the
  /// caller's own role checks still apply.
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
      Json page(List<Json> rows) => {
        'rows': rows,
        'nextCursor': rows.length == limit ? rows.last['id'] : null,
      };
      return await query(w, name, d, limit, cursor, page) ??
          await BackOfficeModule.query(w, name, d, limit, cursor, page) ??
          _fail('not_found', 'Unknown query.');
    });
  }

  /// Queries this module answers; null means "not mine".
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
      case 'supplier.orders':
        await w.role(_finance);
        final rows = await SupplierOrder.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page(await _views(w, rows));
      case 'supplier.order':
        await w.role(_finance);
        final row = await SupplierOrder.db.findById(
          s,
          _int(d, 'id', min: 1, max: 1 << 31),
          transaction: tx,
        );
        await BackOfficeModule._own(w, row, row?.restaurantId, 'Supplier order');
        final delivery = await SupplyDelivery.db.findFirstRow(
          s,
          where: (t) => t.supplierOrderId.equals(row!.id!),
          orderBy: (t) => t.id.desc(),
          transaction: tx,
        );
        return {
          ...(await _views(w, [row!])).single,
          'delivery': delivery == null
              ? null
              : {
                  'id': delivery.id,
                  'state': delivery.state,
                  'totalMinor': delivery.totalMinor,
                  'mediaId': delivery.mediaId,
                  'match': delivery.matchJson == null
                      ? null
                      : jsonDecode(delivery.matchJson!),
                },
        };
      case 'recipes':
        await w.role({..._managers, 'kitchen'});
        final products = await MenuProduct.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          orderBy: (t) => t.name,
          limit: 500,
          transaction: tx,
        );
        final recipes = await RecipeLine.db.find(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          orderBy: (t) => t.id,
          limit: 5000,
          transaction: tx,
        );
        final items = {
          for (final x in await StockItem.db.find(
            s,
            where: (t) => t.restaurantId.equals(w.tenant),
            limit: 1000,
            transaction: tx,
          ))
            x.id!: x,
        };
        return {
          'rows': [
            for (final p in products)
              {
                'productId': p.id,
                'name': p.name,
                'priceMinor': p.priceMinor,
                'available': p.available,
                'lines': [
                  for (final r in recipes.where((r) => r.productId == p.id))
                    {
                      'stockItemId': r.stockItemId,
                      'name': items[r.stockItemId]?.name,
                      'unit': items[r.stockItemId]?.unit,
                      'quantity': r.quantity,
                      'costMinor': ((items[r.stockItemId]?.costMinor ?? 0) * r.quantity).round(),
                    },
                ],
              },
          ],
          'nextCursor': null,
        };
      case 'stock.movements':
        // Every change to stock with its reason, newest first; optionally
        // for one item.
        await w.role({..._finance, 'kitchen'});
        final item = d['stockItemId'] == null
            ? null
            : _int(d, 'stockItemId', min: 1, max: 1 << 31);
        final rows = await StockMovement.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (item == null ? Constant.bool(true) : t.stockItemId.equals(item)) &
              (cursor == 0 ? Constant.bool(true) : t.id < cursor),
          orderBy: (t) => t.id.desc(),
          limit: limit,
          transaction: tx,
        );
        return page([
          for (final m in rows)
            {
              'id': m.id,
              'stockItemId': m.stockItemId,
              'kind': m.kind,
              'quantity': m.quantity,
              'unitCostMinor': m.unitCostMinor,
              'refType': m.refType,
              'refId': m.refId,
              'at': m.at.toIso8601String(),
            },
        ]);
      case 'stock.forecast':
        await w.role({..._finance, 'kitchen'});
        return forecastAll(w);
      case 'supplier.scorecards':
        await w.role(_finance);
        return scorecards(w);
    }
    return null;
  }
}
