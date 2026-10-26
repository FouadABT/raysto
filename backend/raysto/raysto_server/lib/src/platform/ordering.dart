part of 'platform.dart';

class OrderingModule {
  /// Largest-remainder apportionment: deterministic, integer-only, sums exactly.
  static List<int> distribute(int amount, List<int> weights) {
    final sum = weights.fold<int>(0, (a, b) => a + b);
    if (amount < 0 || weights.any((w) => w < 0)) {
      _fail('invalid_input', 'Invalid money allocation.');
    }
    if (sum == 0) {
      if (amount != 0) {
        _fail('invalid_input', 'Cannot allocate to an empty amount.');
      }
      return List.filled(weights.length, 0);
    }
    final values = weights.map((w) => amount * w ~/ sum).toList();
    final indices = List.generate(weights.length, (i) => i)
      ..sort((a, b) {
        final v = (amount * weights[b] % sum).compareTo(
          amount * weights[a] % sum,
        );
        return v == 0 ? a.compareTo(b) : v;
      });
    final remainder = amount - values.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < remainder; i++) {
      values[indices[i]]++;
    }
    return values;
  }

  static List<Json> lines(dynamic raw) {
    if (raw is! List || raw.isEmpty || raw.length > 50) {
      _fail('invalid_input', 'Choose 1–50 order lines.');
    }
    return raw.map((v) {
      final d = _object(v);
      _keys(d, {'productId', 'quantity', 'options', 'note'});
      _int(d, 'productId', min: 1);
      _int(d, 'quantity', min: 1, max: 20);
      final options = _list(
        d,
        'options',
        max: 100,
      ).map((v) => _str({'option': v}, 'option', max: 120)).toList();
      if (options.toSet().length != options.length) {
        _fail('invalid_input', 'Duplicate modifier selection.');
      }
      if (d['note'] != null &&
          (d['note'] is! String || (d['note'] as String).length > 500)) {
        _fail('invalid_input', 'Invalid note.');
      }
      return <String, dynamic>{
        'productId': d['productId'],
        'quantity': d['quantity'],
        'options': options,
        'note': d['note'] ?? '',
      };
    }).toList();
  }

  static Future<Json> saveCart(Session s, PlatformCommand c) =>
      _mutate(s, c, 'cart.save', (w, d) async {
        _keys(d, {'lines'});
        final raw = _list(d, 'lines', max: 50);
        final validated = raw.isEmpty ? <Json>[] : lines(raw);
        for (final line in validated) {
          final p = await MenuProduct.db.findById(
            s,
            line['productId'],
            transaction: w.tx,
          );
          if (p == null || p.restaurantId != w.tenant) {
            _fail('not_found', 'Item not found.');
          }
        }
        var cart = await CustomerCart.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
          transaction: w.tx,
        );
        if (cart == null) {
          if (c.expectedVersion != 0) {
            _fail('version_conflict', 'Use version 0 for a new cart.');
          }
          cart = await CustomerCart.db.insertRow(
            s,
            CustomerCart(
              restaurantId: w.tenant,
              userId: w.user,
              linesJson: jsonEncode(validated),
              version: 1,
              updatedAt: _now(),
            ),
            transaction: w.tx,
          );
        } else {
          _version(cart.version, c.expectedVersion);
          cart.linesJson = jsonEncode(validated);
          cart.version++;
          cart.updatedAt = _now();
          await CustomerCart.db.updateRow(s, cart, transaction: w.tx);
        }
        return {'id': cart.id, 'version': cart.version};
      });
  static Future<Json> quote(Session s, CreateQuote r) => _mutate(
    s,
    PlatformCommand(
      requestKey: r.requestKey,
      restaurantId: r.restaurantId,
      dataJson: jsonEncode({
        'visitId': r.visitId,
        'fulfillment': r.fulfillment,
        'lines': jsonDecode(r.linesJson),
        'address': r.addressJson == null ? null : _json(r.addressJson!),
        'slot': r.slot?.toUtc().toIso8601String(),
        'couponCode': r.couponCode,
        'tipMinor': r.tipMinor,
      }),
    ),
    'order.quote',
    (w, d) async {
      final snapshot = await _price(w, d);
      final row = await PriceQuote.db.insertRow(
        s,
        PriceQuote(
          restaurantId: w.tenant,
          userId: w.user,
          visitId: r.visitId,
          snapshotJson: jsonEncode(snapshot),
          menuVersion: w.policy!.menuVersion,
          totalMinor: snapshot['totalMinor'],
          currency: w.restaurant!.currency,
          expiresAt: _now().add(const Duration(minutes: 10)),
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      return {
        'id': row.id,
        'expiresAt': row.expiresAt.toIso8601String(),
        ...snapshot,
      };
    },
    active: true,
  );

  static Future<Json> _price(Work w, Json input) async {
    final mode = _str(
      input,
      'fulfillment',
      choices: {'dineIn', 'pickup', 'delivery'},
    );
    if (Platform.environment['RAYSTO_BILLING_ENFORCED'] == 'true') {
      final sub = await RestaurantSubscription.db.findFirstRow(
        w.s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      final plan = sub == null
          ? null
          : await RestaurantPlan.db.findById(
              w.s,
              sub.planId,
              transaction: w.tx,
            );
      if (plan == null || _json(plan.featuresJson)[mode] != true) {
        _fail(
          'entitlement_required',
          'This service is not included in the restaurant plan.',
        );
      }
    }
    if (!(w.settings['modes'] as List).contains(mode) ||
        w.settings['paused'] == true) {
      _fail('unavailable', 'Service is currently unavailable.');
    }
    if (w.actor.isGuest && w.settings['guestOrdering'] != true) {
      _fail('account_required', 'This restaurant requires an account.');
    }
    final requestedTime = input['slot'] == null ? _now() : _date(input, 'slot');
    if (requestedTime.isBefore(_now().subtract(const Duration(seconds: 60))) ||
        requestedTime.isAfter(_now().add(const Duration(days: 7)))) {
      _fail('slot_unavailable', 'Choose a current service slot.');
    }
    if (!CatalogueModule.openAt(w.settings, requestedTime)) {
      _fail('closed', 'Restaurant is closed for this time.');
    }
    if (input['slot'] != null &&
        requestedTime.isBefore(
          _now().add(
            Duration(minutes: w.settings['preparationMinutes'] as int),
          ),
        )) {
      _fail('slot_unavailable', 'Allow the configured preparation time.');
    }
    if (input['slot'] != null) {
      final local = tz.TZDateTime.from(
        requestedTime,
        CatalogueModule.zone(w.settings['timezone']),
      );
      if (local.minute % (w.settings['slotMinutes'] as int) != 0 ||
          local.second != 0) {
        _fail('slot_unavailable', 'Choose a published slot boundary.');
      }
    }
    if (mode == 'dineIn') {
      final visit = await DiningModule._visit(
        w,
        _int(input, 'visitId', min: 1),
      );
      await _visitAccess(w, visit);
      if (visit.status != 'active') _fail('visit_closed', 'Visit is closed.');
    } else if (input['visitId'] != null) {
      _fail('invalid_input', 'Only dine-in orders have a visit.');
    }
    Json? address;
    if (mode == 'delivery') {
      address = CatalogueModule.address(_object(input['address']));
      if (!CatalogueModule.delivers(w.settings, address)) {
        _fail('outside_delivery_area', 'Address is outside the delivery area.');
      }
    }
    final selected = lines(input['lines']);
    final snapshot = <Json>[];
    final units = <Json>[];
    var subtotal = 0;
    final stockCounts = <int, int>{};
    for (var lineIndex = 0; lineIndex < selected.length; lineIndex++) {
      final line = selected[lineIndex];
      final product = await MenuProduct.db.findById(
        w.s,
        line['productId'],
        transaction: w.tx,
      );
      final def = await MenuDefinition.db.findFirstRow(
        w.s,
        where: (t) => t.productId.equals(line['productId']),
        transaction: w.tx,
      );
      if (product == null ||
          product.restaurantId != w.tenant ||
          !product.available ||
          def == null ||
          def.archived) {
        _fail('item_unavailable', 'An item is no longer available.');
      }
      final count = line['quantity'] as int;
      stockCounts[product.id!] = (stockCounts[product.id!] ?? 0) + count;
      if (def.stockRemaining != null &&
          stockCounts[product.id!]! > def.stockRemaining!) {
        _fail('insufficient_stock', 'An item has insufficient quantity.');
      }
      final definition = _json(def.definitionJson);
      final options = (line['options'] as List).cast<String>().toSet();
      final consumed = <String>{};
      final picked = <Json>[];
      var unitPrice = product.priceMinor;
      for (final raw in definition['modifiers'] as List) {
        final group = _object(raw);
        var chosen = 0;
        for (final rawOption in group['options'] as List) {
          final option = _object(rawOption);
          final key = '${group['id']}:${option['id']}';
          if (options.contains(key)) {
            if (option['available'] == false) {
              _fail(
                'modifier_unavailable',
                'A selected option is unavailable.',
              );
            }
            chosen++;
            consumed.add(key);
            unitPrice += option['priceMinor'] as int;
            picked.add({
              'id': key,
              'name': option['name'],
              'priceMinor': option['priceMinor'],
            });
          }
        }
        if (chosen < (group['min'] as int) || chosen > (group['max'] as int)) {
          _fail('modifiers_required', 'Choose the required item options.');
        }
      }
      if (consumed.length != options.length) {
        _fail(
          'invalid_modifier',
          'A selected option does not belong to this item.',
        );
      }
      final lineKey = 'l$lineIndex';
      subtotal += unitPrice * count;
      snapshot.add({
        'lineKey': lineKey,
        'productId': product.id,
        'productVersion': product.version,
        'name': product.name,
        'quantity': count,
        'unitPriceMinor': unitPrice,
        'options': picked,
        'note': line['note'],
      });
      for (var unit = 0; unit < count; unit++) {
        units.add({
          'lineKey': '$lineKey:u$unit',
          'kind': 'food',
          'amountMinor': unitPrice,
        });
      }
    }
    var discount = 0;
    String? couponCode = input['couponCode'];
    if (couponCode != null) {
      final coupon = (w.settings['coupons'] as List)
          .cast<Json>()
          .where((p) => p['code'] == couponCode)
          .firstOrNull;
      if (coupon == null) _fail('invalid_coupon', 'Coupon is invalid.');
      if (_now().isBefore(_date(coupon, 'startsAt')) ||
          !_date(coupon, 'expiresAt').isAfter(_now())) {
        _fail('expired_coupon', 'Coupon is not active.');
      }
      if (subtotal < _int(coupon, 'minimumMinor', fallback: 0)) {
        _fail('coupon_minimum', 'Coupon minimum has not been reached.');
      }
      final prior = await OrderContext.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.couponCode.equals(couponCode),
        limit: 100001,
        transaction: w.tx,
      );
      if (prior.length >= coupon['maxUses']) {
        _fail('coupon_exhausted', 'Coupon usage limit reached.');
      }
      var owned = 0;
      for (final ctx in prior) {
        final o = await PurchaseOrder.db.findById(
          w.s,
          ctx.orderId,
          transaction: w.tx,
        );
        if (o?.customerId == w.user) owned++;
      }
      if (owned >= coupon['maxPerUser']) {
        _fail('coupon_exhausted', 'Your coupon usage limit is reached.');
      }
      discount = min(
        subtotal,
        coupon['type'] == 'fixed'
            ? coupon['value'] as int
            : (subtotal * (coupon['value'] as int) + 5000) ~/ 10000,
      );
    }
    final discounts = distribute(
      discount,
      units.map((u) => u['amountMinor'] as int).toList(),
    );
    var tax = 0, food = 0;
    for (var i = 0; i < units.length; i++) {
      final discounted = (units[i]['amountMinor'] as int) - discounts[i],
          bps = w.settings['taxBps'] as int;
      final net = w.settings['pricesIncludeTax'] == true
          ? (discounted * 10000 + (10000 + bps) ~/ 2) ~/ (10000 + bps)
          : discounted;
      final unitTax = w.settings['pricesIncludeTax'] == true
          ? discounted - net
          : (net * bps + 5000) ~/ 10000;
      units[i]['amountMinor'] = net + unitTax;
      units[i]['foodNetMinor'] = net;
      tax += unitTax;
      food += net + unitTax;
    }
    if (mode == 'delivery' &&
        food < (w.settings['deliveryMinimumMinor'] as int)) {
      _fail('delivery_minimum', 'Delivery minimum has not been reached.');
    }
    final fee = mode == 'delivery' ? w.settings['deliveryFeeMinor'] as int : 0;
    final tip = _int(input, 'tipMinor', max: 100000, fallback: 0);
    if (fee > 0) {
      units.add({
        'lineKey': 'delivery',
        'kind': 'delivery',
        'amountMinor': fee,
        'foodNetMinor': 0,
      });
    }
    if (tip > 0) {
      units.add({
        'lineKey': 'tip',
        'kind': 'tip',
        'amountMinor': tip,
        'foodNetMinor': 0,
      });
    }
    if (food + fee + tip < 1 || food + fee + tip > 1000000) {
      _fail('invalid_amount', 'Checkout amount is outside supported limits.');
    }
    return {
      'fulfillment': mode,
      'visitId': input['visitId'],
      'address': address,
      'slot': input['slot'],
      'couponCode': couponCode,
      'lines': snapshot,
      'charges': units,
      'subtotalMinor': subtotal,
      'discountMinor': discount,
      'taxMinor': tax,
      'deliveryFeeMinor': fee,
      'tipMinor': tip,
      'totalMinor': food + fee + tip,
      'currency': w.restaurant!.currency,
      'paymentTiming': mode == 'dineIn'
          ? w.settings['paymentTiming']
          : 'before',
      'originalInput': input,
    };
  }

  static Future<Json> submit(Session s, SubmitOrder r) => _mutate(
    s,
    PlatformCommand(
      requestKey: r.requestKey,
      restaurantId: r.restaurantId,
      resourceId: r.quoteId,
      dataJson: '{}',
    ),
    'order.submit',
    (w, d) async {
      final q = await PriceQuote.db.findById(s, r.quoteId, transaction: w.tx);
      if (q == null || q.restaurantId != w.tenant || q.userId != w.user) {
        _fail('not_found', 'Quote not found.');
      }
      if (q.consumedOrderId != null) {
        final o = await PurchaseOrder.db.findById(
          s,
          q.consumedOrderId!,
          transaction: w.tx,
        );
        return {'orderId': o!.id, 'status': o.status};
      }
      if (q.assistantProposalId != null) {
        await AssistantModule.validProposal(
          w,
          q.assistantProposalId!,
          'basket',
          state: 'approved',
        );
      }
      if (!q.expiresAt.isAfter(_now()) ||
          q.menuVersion != w.policy!.menuVersion) {
        _fail('quote_expired', 'Refresh the quote before ordering.');
      }
      final snapshot = _json(q.snapshotJson);
      final refreshed = await _price(w, _object(snapshot['originalInput']));
      if (jsonEncode(refreshed) != jsonEncode(snapshot)) {
        _fail(
          'quote_changed',
          'Prices or availability changed. Review a new quote.',
        );
      }
      final slot = snapshot['slot'] as String?;
      String? slotKey;
      if (slot != null) {
        slotKey = '${snapshot['fulfillment']}:$slot';
        final existing = await OrderContext.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.slotKey.equals(slotKey),
          limit: 1000,
          transaction: w.tx,
        );
        var active = 0;
        for (final ctx in existing) {
          final o = await PurchaseOrder.db.findById(
            s,
            ctx.orderId,
            transaction: w.tx,
          );
          if (o != null && !{'cancelled', 'rejected'}.contains(o.status)) {
            active++;
          }
        }
        if (active >= w.settings['slotCapacity']) {
          _fail('slot_full', 'This slot is full.');
        }
      }
      final items = (snapshot['lines'] as List).cast<Json>();
      final order = await PurchaseOrder.db.insertRow(
        s,
        PurchaseOrder(
          restaurantId: w.tenant,
          customerId: w.user,
          requestKey: r.requestKey,
          requestHash: _hash(q.snapshotJson),
          fulfillment: snapshot['fulfillment'],
          address: snapshot['address'] == null
              ? null
              : jsonEncode(snapshot['address']),
          lines: items
              .map(
                (v) => OrderLine(
                  productId: v['productId'],
                  name: v['name'],
                  quantity: v['quantity'],
                  unitPriceMinor: v['unitPriceMinor'],
                ),
              )
              .toList(),
          currency: q.currency,
          subtotalMinor: snapshot['subtotalMinor'],
          deliveryFeeMinor: snapshot['deliveryFeeMinor'],
          totalMinor: q.totalMinor,
          status: snapshot['paymentTiming'] == 'before'
              ? 'awaitingPayment'
              : 'submitted',
          paymentStatus: 'unpaid',
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      await OrderContext.db.insertRow(
        s,
        OrderContext(
          restaurantId: w.tenant,
          orderId: order.id!,
          visitId: q.visitId,
          quoteId: q.id,
          detailsJson: q.snapshotJson,
          paymentTiming: snapshot['paymentTiming'],
          cancellationRequested: false,
          stockReleased: false,
          slotKey: slotKey,
          couponCode: snapshot['couponCode'],
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      for (final line in items) {
        final def = (await MenuDefinition.db.findFirstRow(
          s,
          where: (t) => t.productId.equals(line['productId']),
          transaction: w.tx,
        ))!;
        if (def.stockRemaining != null) {
          def.stockRemaining = def.stockRemaining! - (line['quantity'] as int);
          await MenuDefinition.db.updateRow(s, def, transaction: w.tx);
        }
        await KitchenProgress.db.insertRow(
          s,
          KitchenProgress(
            restaurantId: w.tenant,
            orderId: order.id!,
            lineKey: line['lineKey'],
            quantity: line['quantity'],
            completedQuantity: 0,
            version: 1,
          ),
          transaction: w.tx,
        );
      }
      for (final raw in snapshot['charges'] as List) {
        final charge = _object(raw);
        await BillCharge.db.insertRow(
          s,
          BillCharge(
            restaurantId: w.tenant,
            orderId: order.id!,
            visitId: q.visitId,
            lineKey: charge['lineKey'],
            kind: charge['kind'],
            amountMinor: charge['amountMinor'],
            creditedMinor: 0,
            settledMinor: 0,
            reservedMinor: 0,
            foodNetMinor: charge['foodNetMinor'],
            version: 1,
          ),
          transaction: w.tx,
        );
      }
      if (order.fulfillment == 'delivery') {
        await DeliveryAssignment.db.insertRow(
          s,
          DeliveryAssignment(
            restaurantId: w.tenant,
            orderId: order.id!,
            status: 'unassigned',
            issueJson: '{}',
            locationConsent: false,
            version: 1,
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
      }
      q.consumedOrderId = order.id;
      if (q.assistantProposalId != null) {
        final proposal = (await AssistantProposal.db.findById(
          s,
          q.assistantProposalId!,
          transaction: w.tx,
        ))!;
        proposal.status = 'executed';
        proposal.version++;
        proposal.payloadJson = jsonEncode({
          ..._json(proposal.payloadJson),
          'orderId': order.id,
        });
        await AssistantProposal.db.updateRow(s, proposal, transaction: w.tx);
      }
      await PriceQuote.db.updateRow(s, q, transaction: w.tx);
      await w.audit('order.submitted', 'order', order.id);
      await w.notify(w.user, 'order.created', {
        'orderId': order.id,
      }, 'order:${order.id}:created');
      if (order.status == 'awaitingPayment') {
        await w.job('order.expire', 'order:${order.id}:expire', {
          'orderId': order.id,
        }, at: _now().add(const Duration(minutes: 20)));
      }
      return {
        'orderId': order.id,
        'status': order.status,
        'paymentStatus': order.paymentStatus,
      };
    },
    active: true,
  );

  static Future<(PurchaseOrder, OrderContext)> _order(Work w, int id) async {
    final order = await PurchaseOrder.db.findById(w.s, id, transaction: w.tx);
    final context = await OrderContext.db.findFirstRow(
      w.s,
      where: (t) => t.orderId.equals(id),
      transaction: w.tx,
    );
    if (order == null || context == null || order.restaurantId != w.tenant) {
      _fail('not_found', 'Order not found.');
    }
    return (order, context);
  }

  static Future<void> _changed(Work w, PurchaseOrder o, String event) async {
    o.version++;
    o.updatedAt = _now();
    await PurchaseOrder.db.updateRow(w.s, o, transaction: w.tx);
    await w.audit(event, 'order', o.id);
    await w.notify(o.customerId, event, {
      'orderId': o.id,
    }, 'order:${o.id}:${o.version}');
  }

  static Future<Json> transition(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'order.transition', (w, d) async {
    _keys(d, {'status', 'reason'});
    final (o, ctx) = await _order(w, _id(c));
    _version(o.version, c.expectedVersion);
    final next = _str(
      d,
      'status',
      choices: {
        'accepted',
        'rejected',
        'preparing',
        'ready',
        'served',
        'collected',
        'completed',
      },
    );
    final role = await w.role({'owner', 'manager', 'waiter', 'kitchen'});
    final kitchen = {'preparing', 'ready'}.contains(next);
    if (kitchen && !{'owner', 'manager', 'kitchen'}.contains(role.role) ||
        !kitchen && !_operators.contains(role.role)) {
      _fail('forbidden', 'Your role cannot perform this action.');
    }
    if (role.role == 'waiter') await _orderAccess(w, o, manage: true);
    if (next == 'rejected') {
      if (o.status != 'submitted') {
        _fail('invalid_transition', 'Only submitted orders can be rejected.');
      }
      await _cancel(w, o, ctx, 'rejected', _str(d, 'reason', max: 500));
      return {'version': o.version, 'status': o.status};
    }
    final valid = switch (o.status) {
      'submitted' => {'accepted'},
      'accepted' => {'preparing'},
      'preparing' => {'ready'},
      'ready' =>
        o.fulfillment == 'dineIn'
            ? {'served'}
            : o.fulfillment == 'pickup'
            ? {'collected'}
            : <String>{},
      'served' || 'collected' || 'delivered' => {'completed'},
      _ => <String>{},
    };
    if (!valid.contains(next)) {
      _fail('invalid_transition', 'Invalid order transition.');
    }
    if (ctx.paymentTiming == 'before' && o.paymentStatus != 'paid') {
      _fail('payment_required', 'Payment must be verified before preparation.');
    }
    if (next == 'ready') {
      final items = await KitchenProgress.db.find(
        s,
        where: (t) => t.orderId.equals(o.id!),
        transaction: w.tx,
      );
      if (items.any((i) => i.completedQuantity < i.quantity)) {
        _fail(
          'items_incomplete',
          'Complete all kitchen items before marking ready.',
        );
      }
    }
    o.status = next;
    await _changed(w, o, 'order.$next');
    return {'version': o.version, 'status': o.status};
  });
  static Future<void> _cancel(
    Work w,
    PurchaseOrder o,
    OrderContext ctx,
    String state,
    String reason,
  ) async {
    final charges = await BillCharge.db.find(
      w.s,
      where: (t) => t.orderId.equals(o.id!),
      transaction: w.tx,
    );
    if (charges.any((c) => c.reservedMinor > 0)) {
      _fail(
        'payment_pending',
        'Reconcile or safely cancel pending payment first.',
      );
    }
    for (final c in charges) {
      c.creditedMinor = c.amountMinor;
      c.version++;
      await BillCharge.db.updateRow(w.s, c, transaction: w.tx);
    }
    if (!ctx.stockReleased &&
        {'awaitingPayment', 'submitted'}.contains(o.status)) {
      for (final line
          in (_json(ctx.detailsJson)['lines'] as List).cast<Json>()) {
        final def = await MenuDefinition.db.findFirstRow(
          w.s,
          where: (t) => t.productId.equals(line['productId']),
          transaction: w.tx,
        );
        if (def?.stockRemaining != null) {
          def!.stockRemaining = def.stockRemaining! + (line['quantity'] as int);
          await MenuDefinition.db.updateRow(w.s, def, transaction: w.tx);
        }
      }
      ctx.stockReleased = true;
    }
    ctx.cancellationRequested = false;
    await OrderContext.db.updateRow(w.s, ctx, transaction: w.tx);
    o.status = state;
    final delivery = await DeliveryAssignment.db.findFirstRow(
      w.s,
      where: (t) => t.orderId.equals(o.id!),
      transaction: w.tx,
    );
    if (delivery != null) {
      delivery.status = 'cancelled';
      delivery.locationConsent = false;
      delivery.locationJson = null;
      delivery.locationExpiresAt = null;
      delivery.version++;
      delivery.updatedAt = _now();
      await DeliveryAssignment.db.updateRow(w.s, delivery, transaction: w.tx);
      if (delivery.courierId != null) {
        await w.notify(delivery.courierId!, 'delivery.cancelled', {
          'deliveryId': delivery.id,
        }, 'delivery-cancel:${delivery.id}');
      }
    }
    if (charges.any((c) => c.settledMinor > 0)) o.paymentStatus = 'refundDue';
    await _changed(w, o, 'order.$state');
    await w.audit('order.credit_created', 'order', o.id, {'reason': reason});
  }

  static Future<Json> cancel(Session s, PlatformCommand c) =>
      _mutate(s, c, 'order.cancel', (w, d) async {
        _keys(d, {'reason', 'approve'});
        final (o, ctx) = await _order(w, _id(c));
        if (o.customerId != w.user) await _orderAccess(w, o, manage: true);
        _version(o.version, c.expectedVersion);
        final reason = _str(d, 'reason', max: 500);
        if ({
          'cancelled',
          'rejected',
          'completed',
          'served',
          'collected',
          'delivered',
        }.contains(o.status)) {
          _fail('invalid_transition', 'This order cannot be cancelled.');
        }
        if (!{'awaitingPayment', 'submitted'}.contains(o.status)) {
          if (!_bool(d, 'approve')) {
            ctx.cancellationRequested = true;
            await OrderContext.db.updateRow(s, ctx, transaction: w.tx);
            await _changed(w, o, 'order.cancellation_requested');
            return {'status': 'requested', 'version': o.version};
          }
          await w.role(_managers);
        }
        await _cancel(w, o, ctx, 'cancelled', reason);
        return {
          'status': o.status,
          'version': o.version,
          'paymentStatus': o.paymentStatus,
        };
      });
  static Future<Json> kitchen(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'kitchen.progress',
    (w, d) async {
      _keys(d, {'lineKey', 'completedQuantity'});
      final (o, ctx) = await _order(w, _id(c));
      if (!{'accepted', 'preparing'}.contains(o.status) ||
          ctx.paymentTiming == 'before' && o.paymentStatus != 'paid') {
        _fail('invalid_transition', 'Ticket is not actionable.');
      }
      final item = await KitchenProgress.db.findFirstRow(
        s,
        where: (t) =>
            t.orderId.equals(o.id!) &
            t.lineKey.equals(_str(d, 'lineKey', max: 50)),
        transaction: w.tx,
      );
      if (item == null) _fail('not_found', 'Ticket item not found.');
      _version(item.version, c.expectedVersion);
      item.completedQuantity = _int(d, 'completedQuantity', max: item.quantity);
      item.version++;
      await KitchenProgress.db.updateRow(s, item, transaction: w.tx);
      await w.audit('kitchen.progress', 'order', o.id);
      return {'version': item.version};
    },
    roles: {'owner', 'manager', 'kitchen'},
  );
  static Future<Json> assignCourier(Session s, PlatformCommand c) =>
      _mutate(s, c, 'delivery.assign', (w, d) async {
        _keys(d, {'courierId'});
        final task = await DeliveryAssignment.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (task == null || task.restaurantId != w.tenant) {
          _fail('not_found', 'Delivery not found.');
        }
        _version(task.version, c.expectedVersion);
        if (!{'unassigned', 'assigned', 'issue'}.contains(task.status)) {
          _fail('invalid_transition', 'Cannot reassign after collection.');
        }
        final courier = _str(d, 'courierId', max: 100);
        await _role(s, courier, w.tenant, {'courier'}, tx: w.tx);
        task.courierId = courier;
        task.status = 'assigned';
        task.version++;
        task.updatedAt = _now();
        await DeliveryAssignment.db.updateRow(s, task, transaction: w.tx);
        await w.notify(courier, 'delivery.assigned', {
          'deliveryId': task.id,
        }, 'delivery:${task.id}:${task.version}');
        await w.audit('delivery.assigned', 'delivery', task.id);
        return {'version': task.version};
      }, roles: _managers);
  static Future<Json> delivery(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'delivery.transition',
    (w, d) async {
      _keys(d, {'status', 'reason', 'resolution'});
      final task = await DeliveryAssignment.db.findById(
        s,
        _id(c),
        transaction: w.tx,
      );
      if (task == null || task.restaurantId != w.tenant) {
        _fail('not_found', 'Delivery not found.');
      }
      _version(task.version, c.expectedVersion);
      final member = await w.role({'owner', 'manager', 'courier'});
      if (member.role == 'courier' && task.courierId != w.user) {
        _fail('not_found', 'Delivery not found.');
      }
      final (o, ctx) = await _order(w, task.orderId);
      final next = _str(
        d,
        'status',
        choices: {
          'collected',
          'outForDelivery',
          'delivered',
          'issue',
          'resolved',
        },
      );
      if (next == 'issue') {
        if (!{
          'assigned',
          'collected',
          'outForDelivery',
        }.contains(task.status)) {
          _fail('invalid_transition', 'Delivery cannot enter an issue state.');
        }
        task.issueJson = jsonEncode({
          'reason': _str(d, 'reason', max: 500),
          'previousStatus': task.status,
        });
        task.status = 'issue';
      } else if (next == 'resolved') {
        await w.role(_managers);
        if (task.status != 'issue') {
          _fail('invalid_transition', 'No issue to resolve.');
        }
        final issue = _json(task.issueJson);
        task.status = issue['previousStatus'] as String;
        issue['resolution'] = _str(d, 'resolution', max: 500);
        task.issueJson = jsonEncode(issue);
      } else {
        final expected = {
          'assigned': 'collected',
          'collected': 'outForDelivery',
          'outForDelivery': 'delivered',
        };
        if (expected[task.status] != next) {
          _fail('invalid_transition', 'Invalid delivery transition.');
        }
        if (next == 'collected' &&
            (o.status != 'ready' || o.paymentStatus != 'paid')) {
          _fail('not_ready', 'Order must be ready and paid before handoff.');
        }
        task.status = next;
        o.status = next == 'delivered' ? 'delivered' : 'outForDelivery';
        await _changed(w, o, 'delivery.$next');
      }
      if (next == 'delivered') {
        task.locationJson = null;
        task.locationExpiresAt = null;
        task.locationConsent = false;
      }
      task.version++;
      task.updatedAt = _now();
      await DeliveryAssignment.db.updateRow(s, task, transaction: w.tx);
      await w.audit('delivery.$next', 'delivery', task.id);
      return {'version': task.version, 'status': task.status};
    },
  );
  static Future<Json> location(Session s, PlatformCommand c) =>
      _mutate(s, c, 'delivery.location', (w, d) async {
        _keys(d, {'consent', 'latitude', 'longitude'});
        final task = await DeliveryAssignment.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (task == null ||
            task.restaurantId != w.tenant ||
            task.courierId != w.user) {
          _fail('not_found', 'Delivery not found.');
        }
        if (!{'collected', 'outForDelivery'}.contains(task.status)) {
          _fail(
            'invalid_transition',
            'Location sharing requires an active delivery.',
          );
        }
        task.locationConsent = _bool(d, 'consent');
        task.locationJson = task.locationConsent
            ? jsonEncode({
                'latitude': CatalogueModule.coordinate(d['latitude'], 90),
                'longitude': CatalogueModule.coordinate(d['longitude'], 180),
                'at': _now().toIso8601String(),
              })
            : null;
        task.locationExpiresAt = task.locationConsent
            ? _now().add(const Duration(minutes: 5))
            : null;
        task.version++;
        await DeliveryAssignment.db.updateRow(s, task, transaction: w.tx);
        return {'expiresAt': task.locationExpiresAt?.toIso8601String()};
      }, roles: {'courier'});
}
