part of 'platform.dart';

/// Money is integer minor units. Restaurant locks serialize balance reservations;
/// provider calls happen only after the reservation transaction commits.
class MoneyModule {
  static Future<Json> allocate(Session s, AllocatePayment r) async {
    final c = PlatformCommand(
      requestKey: r.requestKey,
      restaurantId: r.restaurantId,
      dataJson: jsonEncode({
        'visitId': r.visitId,
        'orderId': r.orderId,
        'amountMinor': r.amountMinor,
        'lineKeys': r.lineKeys,
        'shares': r.shares?.map((s) => s.toJson()).toList(),
        'assistantProposalId': r.assistantProposalId,
        if (r.splitPlanId != null) 'splitPlanId': r.splitPlanId,
        'method': r.method,
      }),
    );
    return _mutate(s, c, 'payment.allocate', (w, d) async {
      AssistantProposal? proposal;
      int? splitPlanId;
      if (r.assistantProposalId != null) {
        proposal = await AssistantModule.validProposal(
          w,
          r.assistantProposalId!,
          'payment',
          state: 'approved',
        );
        final p = _json(proposal.payloadJson);
        final expected = (p['shares'] as List)
            .map(
              (v) => {
                'chargeId': v['chargeId'],
                'amountMinor': v['amountMinor'],
                'expectedVersion': v['expectedVersion'],
              },
            )
            .toList();
        final actual = r.shares
            ?.map(
              (v) => {
                'chargeId': v.chargeId,
                'amountMinor': v.amountMinor,
                'expectedVersion': v.expectedVersion,
              },
            )
            .toList();
        if (r.method != 'paypal' ||
            p['visitId'] != r.visitId ||
            p['orderId'] != r.orderId ||
            jsonEncode(expected) != jsonEncode(actual)) {
          _fail(
            'stale_proposal',
            'Payment must match the exact approved share.',
          );
        }
        splitPlanId = p['splitPlanId'] as int?;
        if (splitPlanId != null) {
          final split = await BillSplitPlan.db.findById(
            s,
            splitPlanId,
            transaction: w.tx,
          );
          if (split == null ||
              split.restaurantId != w.tenant ||
              split.activeRoomId != proposal.roomId) {
            _fail(
              'stale_proposal',
              'This equal split was reset. Review a new share.',
            );
          }
        }
      }
      if (r.splitPlanId != null) {
        // An equal share chosen without the assistant binds to the same
        // frozen plan, and only that payer's exact remaining share is accepted.
        if (proposal != null || r.visitId == null || r.shares == null) {
          _fail('invalid_input', 'An equal share pays exact shares of a visit.');
        }
        final expected = [
          for (final v in await EqualShares.mine(w, r.splitPlanId!, r.visitId!))
            {
              'chargeId': v['chargeId'],
              'amountMinor': v['amountMinor'],
              'expectedVersion': v['expectedVersion'],
            },
        ];
        final actual = [
          for (final v in r.shares!)
            {
              'chargeId': v.chargeId,
              'amountMinor': v.amountMinor,
              'expectedVersion': v.expectedVersion,
            },
        ];
        if (expected.isEmpty || jsonEncode(expected) != jsonEncode(actual)) {
          _fail('stale_proposal', 'Payment must match your exact equal share.');
        }
        splitPlanId = r.splitPlanId;
      }
      if ((r.visitId == null) == (r.orderId == null)) {
        _fail('invalid_input', 'Choose one visit or order.');
      }
      if (!{'paypal', 'cash'}.contains(r.method)) {
        _fail('invalid_input', 'Unsupported collection method.');
      }
      if (r.visitId != null) {
        final v = await DiningModule._visit(w, r.visitId!);
        await _visitAccess(w, v, staffOnly: r.method == 'cash');
        if (v.status != 'active') {
          _fail('invalid_transition', 'Visit is closed.');
        }
      }
      if (r.orderId != null) {
        final (o, ctx) = await OrderingModule._order(w, r.orderId!);
        await _orderAccess(
          w,
          o,
          manage: r.method == 'cash',
          walkInOnly: true,
        );
        if (ctx.visitId != null) {
          _fail('invalid_input', 'Pay this order through its shared visit.');
        }
      }
      // Order cash was authorized above (manager or counter); table cash is
      // collected by the floor team.
      if (r.method == 'cash' && r.visitId != null) await w.role(_operators);
      if (r.orderId != null &&
          await CheckoutIntent.db.findFirstRow(
                s,
                where: (t) =>
                    t.orderId.equals(r.orderId) &
                    t.state.inSet({
                      'reserved',
                      'creating',
                      'created',
                      'approved',
                      'capturing',
                      'uncertain',
                    }),
                transaction: w.tx,
              ) !=
              null) {
        _fail(
          'payment_pending',
          'Finish or reconcile the active order checkout first.',
        );
      }
      if (r.visitId != null &&
          await CheckoutIntent.db.findFirstRow(
                s,
                where: (t) => t.activeVisitId.equals(r.visitId),
                transaction: w.tx,
              ) !=
              null) {
        _fail(
          'payment_pending',
          'Finish or reconcile the active checkout first.',
        );
      }
      final charges = await BillCharge.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            (r.visitId != null
                ? t.visitId.equals(r.visitId)
                : t.orderId.equals(r.orderId!)),
        orderBy: (t) => t.id,
        transaction: w.tx,
      );
      final selected = r.lineKeys?.toSet();
      final exact = r.shares;
      if (exact != null &&
          (exact.isEmpty ||
              exact.length > 200 ||
              exact.map((e) => e.chargeId).toSet().length != exact.length ||
              selected != null ||
              r.amountMinor != null)) {
        _fail(
          'invalid_input',
          'Choose exact shares, selected items, or an amount.',
        );
      }
      if (exact != null) {
        for (final share in exact) {
          final b = charges.where((b) => b.id == share.chargeId).firstOrNull;
          if (b == null) _fail('not_found', 'Bill charge not found.');
          _version(b.version, share.expectedVersion);
          if (share.amountMinor < 1 ||
              share.amountMinor >
                  b.amountMinor -
                      b.creditedMinor -
                      b.settledMinor -
                      b.reservedMinor) {
            _fail('invalid_amount', 'This share exceeds the available charge.');
          }
        }
      }
      if (selected != null &&
          (selected.isEmpty ||
              selected.length > 200 ||
              selected.length != r.lineKeys!.length ||
              r.amountMinor != null)) {
        _fail('invalid_input', 'Select unique item units or an amount.');
      }
      if (selected != null &&
          selected.any(
            (key) => !charges.any((b) => '${b.orderId}:${b.lineKey}' == key),
          )) {
        _fail('invalid_input', 'Unknown selected item.');
      }
      final available = <BillCharge, int>{};
      for (final b in charges) {
        if (exact != null) {
          final share = exact.where((e) => e.chargeId == b.id).firstOrNull;
          if (share != null) available[b] = share.amountMinor;
          continue;
        }
        final balance = max(
          0,
          b.amountMinor - b.creditedMinor - b.settledMinor - b.reservedMinor,
        );
        if (balance > 0 &&
            (selected == null ||
                selected.contains('${b.orderId}:${b.lineKey}'))) {
          available[b] = balance;
        }
      }
      final total = available.values.fold<int>(0, (a, b) => a + b);
      final amount = r.amountMinor ?? total;
      if (amount < 1 || amount > total || amount > 1000000) {
        _fail('invalid_amount', 'Amount exceeds the available balance.');
      }
      MerchantConnection? merchant;
      final single =
          r.method == 'paypal' && ProviderClients.singleRestaurant(w.tenant);
      if (r.method == 'paypal' && !single) {
        merchant = await MerchantConnection.db.findFirstRow(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              t.environment.equals(ProviderClients.paypalEnvironment),
          transaction: w.tx,
        );
        if (merchant?.status != 'ready' ||
            merchant?.merchantId == null ||
            merchant?.verifiedAt == null ||
            _now().difference(merchant!.verifiedAt!).inHours > 24) {
          _fail(
            'merchant_unavailable',
            'Refresh the restaurant merchant connection before checkout.',
          );
        }
      }
      final sub = await RestaurantSubscription.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      final plan = sub == null
          ? null
          : await RestaurantPlan.db.findById(s, sub.planId, transaction: w.tx);
      if (r.method == 'paypal' && !single && plan == null) {
        _fail(
          'billing_configuration_required',
          'Configure the restaurant commission plan first.',
        );
      }
      var remaining = amount;
      var fee = 0;
      final parts = <BillCharge, int>{};
      for (final entry in available.entries) {
        if (remaining == 0) break;
        final n = min(entry.value, remaining);
        parts[entry.key] = n;
        remaining -= n;
        // Cumulative rounding prevents repeated tiny payments from avoiding
        // the configured commission. Cash portions remain commission-free.
        final b = entry.key;
        final bps = r.method == 'cash' || single ? 0 : plan!.commissionBps;
        if (b.amountMinor > 0) {
          fee +=
              (b.foodNetMinor *
                  (b.settledMinor + n) *
                  bps ~/
                  (b.amountMinor * 10000)) -
              (b.foodNetMinor *
                  b.settledMinor *
                  bps ~/
                  (b.amountMinor * 10000));
        }
      }
      final intent = await CheckoutIntent.db.insertRow(
        s,
        CheckoutIntent(
          restaurantId: w.tenant,
          userId: w.user,
          visitId: r.visitId,
          activeVisitId: r.visitId,
          orderId: r.orderId,
          splitPlanId: splitPlanId,
          requestKey: r.requestKey,
          requestHash: _hash(c.dataJson),
          providerRequestId: _uuid(),
          merchantId: single
              ? ProviderClients.required('PAYPAL_SANDBOX_MERCHANT_ID')
              : merchant?.merchantId ?? 'cash',
          providerMode: single ? 'singleMerchantSandbox' : 'marketplace',
          state: 'reserved',
          method: r.method,
          currency: w.restaurant!.currency,
          amountMinor: amount,
          commissionMinor: fee,
          commissionBps: single ? 0 : plan?.commissionBps ?? 0,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      for (final entry in parts.entries) {
        final b = entry.key;
        b.reservedMinor += entry.value;
        b.version++;
        await BillCharge.db.updateRow(s, b, transaction: w.tx);
        await PaymentAllocation.db.insertRow(
          s,
          PaymentAllocation(
            restaurantId: w.tenant,
            checkoutId: intent.id!,
            chargeId: b.id!,
            amountMinor: entry.value,
            foodNetMinor: b.amountMinor == 0
                ? 0
                : (b.foodNetMinor *
                          (b.settledMinor + entry.value) ~/
                          b.amountMinor) -
                      (b.foodNetMinor * b.settledMinor ~/ b.amountMinor),
            refundedMinor: 0,
            state: 'reserved',
          ),
          transaction: w.tx,
        );
      }
      await w.audit('payment.reserved', 'checkout', intent.id);
      if (proposal != null) {
        proposal.status = 'executed';
        proposal.version++;
        proposal.payloadJson = jsonEncode({
          ..._json(proposal.payloadJson),
          'checkoutId': intent.id,
        });
        await AssistantProposal.db.updateRow(s, proposal, transaction: w.tx);
      }
      if (r.method == 'cash') {
        await _settle(w, intent, 'cash:${intent.providerRequestId}');
      } else {
        await w.job('payment.reconcile', 'payment:${intent.id}', {
          'checkoutId': intent.id,
        }, at: _now().add(const Duration(minutes: 2)));
      }
      return {
        'checkoutId': intent.id,
        'state': intent.state,
        'amountMinor': amount,
        'currency': intent.currency,
      };
    });
  }

  static Future<CheckoutIntent> _intent(Work w, int id) async {
    final i = await CheckoutIntent.db.findById(w.s, id, transaction: w.tx);
    if (i == null || i.restaurantId != w.tenant) {
      _fail('not_found', 'Checkout not found.');
    }
    if (i.userId != w.user) {
      if (i.visitId != null) {
        await _visitAccess(
          w,
          await DiningModule._visit(w, i.visitId!),
          staffOnly: true,
        );
      } else {
        final order = i.orderId == null
            ? null
            : await PurchaseOrder.db.findById(
                w.s,
                i.orderId!,
                transaction: w.tx,
              );
        // A walk-in sale belongs to the till, not to the cashier who rang it.
        if (order != null && OrderingModule.isWalkIn(order.customerId)) {
          await _capable(w, 'counter');
        } else {
          await w.role(_managers);
        }
      }
    }
    return i;
  }

  static Future<Json> checkout(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'payment.checkout', (w, d) async {
      _keys(d, {});
      final i = await _intent(w, _id(c));
      if (i.method != 'paypal') {
        _fail('invalid_transition', 'This is a cash collection.');
      }
      return {'checkoutId': i.id};
    });
    return reconcile(s, _id(c), create: true);
  }

  static Future<Json> capture(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'payment.capture', (w, d) async {
      _keys(d, {});
      final i = await _intent(w, _id(c));
      if (i.method != 'paypal') {
        _fail('invalid_transition', 'Cash is already recorded.');
      }
      if (!{
        'approved',
        'created',
        'capturing',
        'uncertain',
        'completed',
      }.contains(i.state)) {
        _fail('invalid_transition', 'Checkout is not ready.');
      }
      if (i.state != 'completed') {
        i.state = 'capturing';
        i.updatedAt = _now();
        await CheckoutIntent.db.updateRow(s, i, transaction: w.tx);
      }
      return {'checkoutId': i.id};
    });
    return reconcile(s, _id(c), capture: true);
  }

  /// Reads the checkout and, when PayPal shows the buyer approved it, captures
  /// at once so payment never waits for the payer to come back to the app.
  /// Webhooks, the retry job and the PayPal return page all land here.
  static Future<Json> settleApproved(Session s, int id) async {
    final read = await reconcile(s, id, audit: true);
    if (read['state'] != 'approved') return read;
    final i = (await CheckoutIntent.db.findById(s, id))!;
    final leased = await locked(s, i.restaurantId, i.userId, (w) async {
      final row = (await CheckoutIntent.db.findById(s, id, transaction: w.tx))!;
      if (row.method != 'paypal' || row.state != 'approved') return false;
      row.state = 'capturing';
      row.updatedAt = _now();
      await CheckoutIntent.db.updateRow(s, row, transaction: w.tx);
      return true;
    });
    return leased ? reconcile(s, id, capture: true) : read;
  }

  static Future<Json> cancel(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'payment.cancel',
    (w, d) async {
      _keys(d, {});
      final i = await _intent(w, _id(c));
      // A create/capture lease is recorded before any provider call, so a late
      // response cannot race a local cancellation and settle released funds.
      if (!{'reserved', 'created', 'approved', 'cancelled'}.contains(i.state)) {
        _fail(
          'payment_pending',
          'Reconcile the uncertain provider outcome first.',
        );
      }
      if (i.state != 'cancelled') await _release(w, i, 'cancelled');
      return {'state': i.state};
    },
  );

  /// Manager release for a PayPal checkout that automatic recovery cannot
  /// settle or free. PayPal is read first: a capture there is reconciled,
  /// never released, and the row must not change while the read runs.
  static Future<Json> release(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'payment.release', (w, d) async {
      _keys(d, {});
      await _stepUp(w);
      final i = await _intent(w, _id(c));
      if (i.method != 'paypal') {
        _fail('invalid_transition', 'Cash is already recorded.');
      }
      await w.audit('payment.release_requested', 'checkout', i.id);
      return {'checkoutId': i.id};
    }, roles: _managers);
    final id = _id(c);
    final before = (await CheckoutIntent.db.findById(s, id))!;
    if ({'completed', 'cancelled', 'failed'}.contains(before.state)) {
      return {...view(before), 'released': false};
    }
    // Provider calls are bounded well under three minutes, so an older lease
    // cannot still have a capture request on the wire.
    if ({'creating', 'capturing', 'uncertain'}.contains(before.state) &&
        _now().difference(before.updatedAt).inMinutes < 3) {
      _fail(
        'payment_pending',
        'A PayPal request may still be running. Try again in a few minutes.',
      );
    }
    if (before.providerOrderId != null) {
      final provider = await ProviderClients.paypal(
        'GET',
        '/v2/checkout/orders/${before.providerOrderId}',
        singleMerchant: before.providerMode == 'singleMerchantSandbox',
      );
      validateOrder(before, provider);
      final unit = _object((provider['purchase_units'] as List).single);
      if (((unit['payments'] as Map?)?['captures'] as List? ?? [])
          .isNotEmpty) {
        return {...await reconcile(s, id), 'released': false};
      }
    }
    return locked(s, before.restaurantId, before.userId, (w) async {
      final row = (await CheckoutIntent.db.findById(s, id, transaction: w.tx))!;
      if ({'completed', 'cancelled', 'failed'}.contains(row.state)) {
        return {...view(row), 'released': false};
      }
      if (row.updatedAt.millisecondsSinceEpoch !=
          before.updatedAt.millisecondsSinceEpoch) {
        _fail(
          'payment_pending',
          'The checkout changed while PayPal was checked. Try again.',
        );
      }
      await _release(w, row, 'cancelled');
      return {...view(row), 'released': true};
    });
  }
  static Future<void> _release(Work w, CheckoutIntent i, String state) async {
    final allocations = await PaymentAllocation.db.find(
      w.s,
      where: (t) => t.checkoutId.equals(i.id!) & t.state.equals('reserved'),
      transaction: w.tx,
    );
    for (final a in allocations) {
      final b = (await BillCharge.db.findById(
        w.s,
        a.chargeId,
        transaction: w.tx,
      ))!;
      b.reservedMinor -= a.amountMinor;
      b.version++;
      await BillCharge.db.updateRow(w.s, b, transaction: w.tx);
      a.state = 'released';
      await PaymentAllocation.db.updateRow(w.s, a, transaction: w.tx);
    }
    i.state = state;
    i.activeVisitId = null;
    i.updatedAt = _now();
    await CheckoutIntent.db.updateRow(w.s, i, transaction: w.tx);
    await w.audit('payment.$state', 'checkout', i.id);
  }

  static Future<void> _settle(
    Work w,
    CheckoutIntent i,
    String providerCapture,
  ) async {
    if (i.state == 'completed') return;
    if ({'cancelled', 'failed'}.contains(i.state)) {
      _fail(
        'payment_mismatch',
        'A released checkout cannot settle automatically.',
      );
    }
    final allocations = await PaymentAllocation.db.find(
      w.s,
      where: (t) => t.checkoutId.equals(i.id!),
      transaction: w.tx,
    );
    if (allocations.any((a) => a.state != 'reserved')) {
      _fail('payment_mismatch', 'Allocation requires operator review.');
    }
    final capture = await PaymentCapture.db.insertRow(
      w.s,
      PaymentCapture(
        restaurantId: w.tenant,
        checkoutId: i.id!,
        providerCaptureId: providerCapture,
        amountMinor: i.amountMinor,
        refundedMinor: 0,
        currency: i.currency,
        state: 'completed',
        createdAt: _now(),
      ),
      transaction: w.tx,
    );
    final orders = <int>{};
    for (final a in allocations) {
      final b = (await BillCharge.db.findById(
        w.s,
        a.chargeId,
        transaction: w.tx,
      ))!;
      b.reservedMinor -= a.amountMinor;
      b.settledMinor += a.amountMinor;
      b.version++;
      await BillCharge.db.updateRow(w.s, b, transaction: w.tx);
      a.state = 'settled';
      await PaymentAllocation.db.updateRow(w.s, a, transaction: w.tx);
      orders.add(b.orderId);
    }
    for (final id in orders) {
      final o = (await PurchaseOrder.db.findById(w.s, id, transaction: w.tx))!;
      final balances = await BillCharge.db.find(
        w.s,
        where: (t) => t.orderId.equals(id),
        transaction: w.tx,
      );
      o.paymentStatus =
          balances.every(
            (b) => b.settledMinor + b.creditedMinor >= b.amountMinor,
          )
          ? 'paid'
          : 'partiallyPaid';
      final released =
          o.paymentStatus == 'paid' && o.status == 'awaitingPayment';
      if (released) {
        // A counter sale was taken by staff, so it is already accepted; other
        // paid orders follow the restaurant's auto-accept setting.
        final ctx = await OrderContext.db.findFirstRow(
          w.s,
          where: (t) => t.orderId.equals(id),
          transaction: w.tx,
        );
        o.status =
            ctx?.origin == 'counter' || w.settings['autoAcceptPaid'] == true
            ? 'accepted'
            : 'submitted';
      }
      await OrderingModule._changed(w, o, 'order.payment_recorded');
      if (released) await OrderingModule.alertTeam(w, o);
    }
    if (i.commissionMinor > 0) {
      await CommissionEntry.db.insertRow(
        w.s,
        CommissionEntry(
          restaurantId: w.tenant,
          captureId: capture.id!,
          eventKey: 'capture:${capture.id}',
          amountMinor: i.commissionMinor,
          currency: i.currency,
          state: 'earned',
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
    }
    i.state = 'completed';
    i.activeVisitId = null;
    i.updatedAt = _now();
    await CheckoutIntent.db.updateRow(w.s, i, transaction: w.tx);
    await w.notify(i.userId, 'payment.completed', {
      'checkoutId': i.id,
      'captureId': capture.id,
    }, 'capture:${capture.id}');
    await w.audit('payment.completed', 'capture', capture.id);
  }

  static Future<T> locked<T>(
    Session s,
    int tenant,
    String user,
    Future<T> Function(Work) action,
  ) => s.db.transaction((tx) async {
    final restaurant = await Restaurant.db.findById(
      s,
      tenant,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (restaurant == null) _fail('not_found', 'Restaurant not found.');
    final actor = await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(user),
      transaction: tx,
    );
    if (actor == null) _fail('not_found', 'Actor not found.');
    final policy = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(tenant),
      transaction: tx,
    );
    return action(
      Work(
        s,
        tx,
        actor,
        PlatformCommand(
          requestKey: _uuid(),
          restaurantId: tenant,
          dataJson: '{}',
        ),
        restaurant,
        policy,
      ),
    );
  });
  static Future<Json> reconcile(
    Session s,
    int id, {
    bool create = false,
    bool capture = false,
    bool audit = false,
  }) async {
    var i = await CheckoutIntent.db.findById(s, id);
    if (i == null) _fail('not_found', 'Checkout not found.');
    var doCreate = false;
    var doCapture = false;
    // Set when this call takes the create/capture lease. Only the lease holder
    // may undo `capturing`, and only while no other writer has touched the row.
    DateTime? lease;
    var posted = false;
    i = await locked(s, i.restaurantId, i.userId, (w) async {
      final row = (await CheckoutIntent.db.findById(s, id, transaction: w.tx))!;
      if (row.state == 'reserved' && create) {
        row.state = 'creating';
        doCreate = true;
      } else if (row.state == 'creating' &&
          _now().difference(row.updatedAt).inMinutes >= 2 &&
          _now().difference(row.createdAt).inHours < 5) {
        doCreate = true;
      }
      // Capture retries always reuse the same provider request ID.
      if (capture && row.state == 'capturing') doCapture = true;
      if (!capture &&
          {'capturing', 'uncertain'}.contains(row.state) &&
          row.providerOrderId != null &&
          _now().difference(row.updatedAt).inMinutes >= 2 &&
          _now().difference(row.createdAt).inHours < 5) {
        doCapture = true;
      }
      if (doCreate || doCapture) {
        row.updatedAt = _now();
        lease = row.updatedAt;
        await CheckoutIntent.db.updateRow(s, row, transaction: w.tx);
      }
      return row;
    });
    bool held(CheckoutIntent row) =>
        lease != null &&
        row.updatedAt.millisecondsSinceEpoch == lease!.millisecondsSinceEpoch;
    if ({'completed', 'cancelled', 'failed'}.contains(i.state)) {
      if (audit && i.state != 'completed') await _auditReleased(s, i);
      return view(i);
    }
    try {
      Json provider;
      if (doCreate) {
        provider = await ProviderClients.createCheckout(i);
      } else if (i.providerOrderId != null) {
        provider = await ProviderClients.paypal(
          'GET',
          '/v2/checkout/orders/${i.providerOrderId}',
          singleMerchant: i.providerMode == 'singleMerchantSandbox',
        );
      } else {
        return view(i);
      }
      validateOrder(i, provider);
      if (doCapture && provider['status'] == 'APPROVED') {
        // Renew the lease under the lock just before the capture request. A
        // manager release must then wait out this request's whole time limit,
        // and a newer capture call takes over instead of racing this one.
        final renewed = await locked(s, i.restaurantId, i.userId, (w) async {
          final row = (await CheckoutIntent.db.findById(
            s,
            id,
            transaction: w.tx,
          ))!;
          if (row.state != 'capturing' || !held(row)) return false;
          row.updatedAt = _now();
          lease = row.updatedAt;
          await CheckoutIntent.db.updateRow(s, row, transaction: w.tx);
          return true;
        });
        if (!renewed) return view((await CheckoutIntent.db.findById(s, id))!);
        posted = true;
        provider = await ProviderClients.paypal(
          'POST',
          '/v2/checkout/orders/${provider['id']}/capture',
          body: {},
          requestId: 'cap-${i.providerRequestId}',
          merchant: i.merchantId,
          singleMerchant: i.providerMode == 'singleMerchantSandbox',
        );
        validateOrder(i, provider);
      }
      return await locked(s, i.restaurantId, i.userId, (w) async {
        final current = (await CheckoutIntent.db.findById(
          s,
          id,
          transaction: w.tx,
        ))!;
        if ({'completed', 'cancelled', 'failed'}.contains(current.state)) {
          return view(current);
        }
        final before = (
          current.state,
          current.providerOrderId,
          current.approvalUrl,
        );
        current.providerOrderId = _str(provider, 'id', max: 50);
        current.approvalUrl = ProviderClients.approval(provider);
        final units = provider['purchase_units'] as List;
        final payments = _object(units.single)['payments'] as Map?;
        final captures = payments?['captures'] as List? ?? [];
        if (captures.isNotEmpty) {
          if (captures.length != 1) {
            _fail('payment_mismatch', 'Unexpected capture count.');
          }
          final p = _object(captures.single);
          final amount = _object(p['amount']);
          if (amount['currency_code'] != current.currency ||
              PayPalGateway.parseMoney(_str(amount, 'value')) !=
                  current.amountMinor ||
              p['final_capture'] != true) {
            _fail(
              'payment_mismatch',
              'Capture differs from the frozen amount.',
            );
          }
          if (p['status'] == 'COMPLETED') {
            await _settle(w, current, _str(p, 'id', max: 50));
          } else if ({'DECLINED', 'FAILED'}.contains(p['status'])) {
            await _release(w, current, 'failed');
          } else {
            current.state = 'uncertain';
          }
        } else if (provider['status'] == 'VOIDED') {
          await _release(w, current, 'failed');
        } else if (!{'capturing', 'uncertain'}.contains(current.state)) {
          current.state = provider['status'] == 'APPROVED'
              ? 'approved'
              : 'created';
        } else if (!posted && held(current)) {
          // This call held the lease and sent no capture, and the provider shows
          // none, so nothing can settle later: make the checkout cancellable.
          current.state = provider['status'] == 'APPROVED'
              ? 'approved'
              : 'created';
        }
        // A plain read that changes nothing leaves the row alone: its time
        // stamp is the capture lease and the manager-release guard.
        if (before !=
            (current.state, current.providerOrderId, current.approvalUrl)) {
          current.updatedAt = _now();
          await CheckoutIntent.db.updateRow(s, current, transaction: w.tx);
          if (current.state == 'uncertain') {
            await w.audit('payment.uncertain', 'checkout', current.id);
          }
        }
        return view(current);
      });
    } catch (e) {
      // A failed read proves nothing either way, so it keeps the current state
      // for the next read to decide. Only an unanswered capture or a provider
      // record that contradicts the frozen checkout is uncertain.
      final unknown =
          posted || (e is DomainError && e.code == 'payment_mismatch');
      await locked(s, i.restaurantId, i.userId, (w) async {
        final row = (await CheckoutIntent.db.findById(
          s,
          id,
          transaction: w.tx,
        ))!;
        if (!{'completed', 'cancelled', 'failed'}.contains(row.state) &&
            (row.providerOrderId == null || unknown)) {
          row.state = row.providerOrderId == null ? 'creating' : 'uncertain';
          row.updatedAt = _now();
          await CheckoutIntent.db.updateRow(s, row, transaction: w.tx);
          if (row.state == 'uncertain') {
            await w.audit('payment.uncertain', 'checkout', row.id);
          }
        }
      });
      rethrow;
    }
  }

  /// A checkout released or failed in Raysto must never hold money at PayPal.
  /// If PayPal shows a capture anyway (a capture that finished after a
  /// release), record it for review instead of returning quietly.
  static Future<void> _auditReleased(Session s, CheckoutIntent i) async {
    if (i.providerOrderId == null || i.method != 'paypal') return;
    final Json provider;
    try {
      provider = await ProviderClients.paypal(
        'GET',
        '/v2/checkout/orders/${i.providerOrderId}',
        singleMerchant: i.providerMode == 'singleMerchantSandbox',
      );
    } catch (_) {
      return; // The next webhook or job retries the read.
    }
    final unit = _object((provider['purchase_units'] as List).single);
    final captures = (unit['payments'] as Map?)?['captures'] as List? ?? [];
    for (final raw in captures) {
      final p = _object(raw);
      if (!{'COMPLETED', 'PENDING'}.contains(p['status'])) continue;
      final providerCapture = _str(p, 'id', max: 50);
      await locked(s, i.restaurantId, i.userId, (w) async {
        final known = await PaymentCapture.db.findFirstRow(
          s,
          where: (t) => t.providerCaptureId.equals(providerCapture),
          transaction: w.tx,
        );
        if (known != null) return;
        final amount = _object(p['amount']);
        final minor = PayPalGateway.parseMoney(_str(amount, 'value'));
        final capture = await PaymentCapture.db.insertRow(
          s,
          PaymentCapture(
            restaurantId: i.restaurantId,
            checkoutId: i.id!,
            providerCaptureId: providerCapture,
            amountMinor: minor,
            refundedMinor: 0,
            currency: _str(amount, 'currency_code', max: 3),
            state: 'review',
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await PaymentException.db.insertRow(
          s,
          PaymentException(
            restaurantId: i.restaurantId,
            captureId: capture.id!,
            providerEventId: 'released-capture:$providerCapture',
            kind: 'captureAfterRelease',
            status: 'review',
            amountMinor: minor,
            currency: capture.currency,
            evidenceJson: jsonEncode({
              'checkoutState': i.state,
              'providerStatus': p['status'],
            }),
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.audit('payment.capture_after_release', 'checkout', i.id);
      });
    }
  }

  static void validateOrder(CheckoutIntent i, Json p) {
    final units = p['purchase_units'];
    if (units is! List || units.length != 1) {
      _fail('payment_mismatch', 'Unexpected purchase units.');
    }
    final u = _object(units.single);
    final a = _object(u['amount']);
    if (p['intent'] != 'CAPTURE' ||
        (i.providerOrderId != null && p['id'] != i.providerOrderId) ||
        u['custom_id'] != 'raysto-v2:${i.id}' ||
        _object(u['payee'])['merchant_id'] != i.merchantId ||
        a['currency_code'] != i.currency ||
        PayPalGateway.parseMoney(_str(a, 'value')) != i.amountMinor) {
      _fail('payment_mismatch', 'PayPal order does not match checkout.');
    }
  }

  static Json view(CheckoutIntent i) => {
    'checkoutId': i.id,
    'visitId': i.visitId,
    'orderId': i.orderId,
    'state': i.state,
    'approvalUrl': i.approvalUrl,
    'amountMinor': i.amountMinor,
    'currency': i.currency,
  };
  static Future<Json> refund(Session s, RequestRefund r) async {
    final result = await _mutate(
      s,
      PlatformCommand(
        requestKey: r.requestKey,
        restaurantId: r.restaurantId,
        resourceId: r.captureId,
        dataJson: jsonEncode({
          'amountMinor': r.amountMinor,
          'reason': r.reason,
          'orderId': ?r.orderId,
        }),
      ),
      'payment.refund',
      (w, d) async {
        await _stepUp(w);
        final p = await PaymentCapture.db.findById(
          s,
          r.captureId,
          transaction: w.tx,
        );
        if (p == null || p.restaurantId != w.tenant || p.state != 'completed') {
          _fail('not_found', 'Capture not found.');
        }
        final pending = await PaymentRefund.db.find(
          s,
          where: (t) => t.captureId.equals(p.id!) & t.state.notEquals('failed'),
          transaction: w.tx,
        );
        final committed = pending.fold<int>(0, (sum, x) => sum + x.amountMinor);
        if (r.amountMinor < 1 || r.amountMinor > p.amountMinor - committed) {
          _fail('invalid_amount', 'Refund exceeds the unrefunded capture.');
        }
        final i = (await CheckoutIntent.db.findById(
          s,
          p.checkoutId,
          transaction: w.tx,
        ))!;
        var allocations = await PaymentAllocation.db.find(
          s,
          where: (t) => t.checkoutId.equals(i.id!),
          orderBy: (t) => t.id,
          transaction: w.tx,
        );
        // One capture can pay several orders: a refund for one order consumes
        // only that order's charges, so the others keep their payment status.
        if (r.orderId != null) {
          final charges = await BillCharge.db.find(
            s,
            where: (t) =>
                t.orderId.equals(r.orderId!) & t.restaurantId.equals(w.tenant),
            transaction: w.tx,
          );
          final ids = {for (final b in charges) b.id};
          allocations = allocations
              .where((a) => ids.contains(a.chargeId))
              .toList();
          if (allocations.isEmpty) {
            _fail('not_found', 'This capture did not pay that order.');
          }
        }
        final used = <int, int>{};
        for (final f in pending) {
          for (final a
              in (_json(f.allocationJson)['allocations'] as List)
                  .cast<Json>()) {
            used[a['id']] = (used[a['id']] ?? 0) + (a['amount'] as int);
          }
        }
        var remaining = r.amountMinor;
        var food = 0;
        final parts = <Json>[];
        for (final a in allocations) {
          final n = min(remaining, a.amountMinor - (used[a.id] ?? 0));
          if (n <= 0) continue;
          parts.add({'id': a.id, 'amount': n});
          food += a.foodNetMinor * n ~/ a.amountMinor;
          remaining -= n;
          if (remaining == 0) break;
        }
        if (remaining != 0) {
          _fail(
            'payment_mismatch',
            'Refund allocations require reconciliation.',
          );
        }
        final feeRemaining =
            i.commissionMinor -
            pending.fold<int>(0, (n, f) => n + f.commissionMinor);
        final fee = r.amountMinor == p.amountMinor - committed
            ? feeRemaining
            : min(feeRemaining, food * i.commissionBps ~/ 10000);
        final row = await PaymentRefund.db.insertRow(
          s,
          PaymentRefund(
            restaurantId: w.tenant,
            captureId: p.id!,
            requestKey: r.requestKey,
            allocationJson: jsonEncode({'allocations': parts}),
            amountMinor: r.amountMinor,
            commissionMinor: fee,
            reason: _str(d, 'reason', max: 500),
            state: 'pending',
            createdBy: w.user,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.job('payment.refund', 'refund:${row.id}', {'refundId': row.id});
        await w.audit('payment.refund_requested', 'refund', row.id);
        return {'refundId': row.id, 'state': row.state};
      },
      roles: _managers,
    );
    return result;
  }

  static Future<void> processRefund(Session s, int id) async {
    final r = await PaymentRefund.db.findById(s, id);
    if (r == null || {'completed', 'failed'}.contains(r.state)) return;
    if (r.providerRefundId == null &&
        _now().difference(r.createdAt).inHours >= 5) {
      _fail(
        'manual_reconciliation_required',
        'Read provider refund history before retrying an aged request.',
      );
    }
    final p = (await PaymentCapture.db.findById(s, r.captureId))!;
    final i = (await CheckoutIntent.db.findById(s, p.checkoutId))!;
    final result = i.method == 'cash'
        ? <String, dynamic>{
            'id': 'cash-refund:$id',
            'status': 'COMPLETED',
            'amount': {
              'value': PayPalGateway.money(r.amountMinor),
              'currency_code': p.currency,
            },
          }
        : r.providerRefundId != null
        ? await ProviderClients.paypal(
            'GET',
            '/v2/payments/refunds/${r.providerRefundId}',
            merchant: i.merchantId,
            singleMerchant: i.providerMode == 'singleMerchantSandbox',
          )
        : await ProviderClients.paypal(
            'POST',
            '/v2/payments/captures/${p.providerCaptureId}/refund',
            merchant: i.merchantId,
            singleMerchant: i.providerMode == 'singleMerchantSandbox',
            requestId: 'refund-$id',
            body: {
              'amount': {
                'value': PayPalGateway.money(r.amountMinor),
                'currency_code': p.currency,
              },
              if (r.commissionMinor > 0)
                'payment_instruction': {
                  'platform_fees': [
                    {
                      'amount': {
                        'value': PayPalGateway.money(r.commissionMinor),
                        'currency_code': p.currency,
                      },
                    },
                  ],
                },
            },
          );
    final amount = _object(result['amount']);
    if (amount['currency_code'] != p.currency ||
        PayPalGateway.parseMoney(_str(amount, 'value')) != r.amountMinor) {
      _fail('payment_mismatch', 'Refund amount differs.');
    }
    await locked(s, r.restaurantId, r.createdBy, (w) async {
      final row = (await PaymentRefund.db.findById(s, id, transaction: w.tx))!;
      if (row.state == 'completed') return;
      row.providerRefundId = _str(result, 'id', max: 100);
      row.updatedAt = _now();
      if (result['status'] == 'COMPLETED') {
        row.state = 'completed';
        final capture = (await PaymentCapture.db.findById(
          s,
          p.id!,
          transaction: w.tx,
        ))!;
        capture.refundedMinor += row.amountMinor;
        await PaymentCapture.db.updateRow(s, capture, transaction: w.tx);
        for (final part
            in (_json(row.allocationJson)['allocations'] as List)
                .cast<Json>()) {
          final a = (await PaymentAllocation.db.findById(
            s,
            part['id'] as int,
            transaction: w.tx,
          ))!;
          final n = part['amount'] as int;
          a.refundedMinor += n;
          await PaymentAllocation.db.updateRow(s, a, transaction: w.tx);
          final b = (await BillCharge.db.findById(
            s,
            a.chargeId,
            transaction: w.tx,
          ))!;
          b.settledMinor -= n;
          b.creditedMinor = min(b.amountMinor, b.creditedMinor + n);
          b.version++;
          await BillCharge.db.updateRow(s, b, transaction: w.tx);
          final order = (await PurchaseOrder.db.findById(
            s,
            b.orderId,
            transaction: w.tx,
          ))!;
          final all = await BillCharge.db.find(
            s,
            where: (t) => t.orderId.equals(b.orderId),
            transaction: w.tx,
          );
          order.paymentStatus =
              all.every(
                (x) => x.settledMinor == 0 && x.creditedMinor >= x.amountMinor,
              )
              ? 'refunded'
              : 'partiallyRefunded';
          await OrderingModule._changed(w, order, 'order.refund_recorded');
        }
        if (row.commissionMinor > 0) {
          await CommissionEntry.db.insertRow(
            s,
            CommissionEntry(
              restaurantId: w.tenant,
              captureId: p.id!,
              refundId: row.id,
              eventKey: 'refund:$id',
              amountMinor: -row.commissionMinor,
              currency: p.currency,
              state: 'reversed',
              createdAt: _now(),
            ),
            transaction: w.tx,
          );
        }
        await w.audit('payment.refunded', 'refund', id);
        await w.notify(i.userId, 'payment.refunded', {
          'refundId': id,
        }, 'refund:$id');
      } else {
        row.state = {'FAILED', 'CANCELLED'}.contains(result['status'])
            ? 'failed'
            : 'pending';
      }
      await PaymentRefund.db.updateRow(s, row, transaction: w.tx);
    });
    if (result['status'] == 'PENDING') {
      _fail('provider_pending', 'Refund is still pending.');
    }
  }

  static Future<Json> connectMerchant(Session s, PlatformCommand c) async {
    final r = await _mutate(s, c, 'merchant.connect', (w, d) async {
      _keys(d, {'shareDataConsent'});
      if (!_bool(d, 'shareDataConsent')) {
        _fail(
          'consent_required',
          'Explicit consent to share onboarding data with PayPal is required.',
        );
      }
      await _stepUp(w, mfa: true);
      var m = await MerchantConnection.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.environment.equals(ProviderClients.paypalEnvironment),
        transaction: w.tx,
      );
      m ??= await MerchantConnection.db.insertRow(
        s,
        MerchantConnection(
          restaurantId: w.tenant,
          trackingId: _uuid(),
          environment: ProviderClients.paypalEnvironment,
          status: 'pending',
          capabilitiesJson: '{}',
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('merchant.onboarding', 'merchant', m.id);
      return {'connectionId': m.id, 'trackingId': m.trackingId};
    }, roles: {'owner'});
    final response = await ProviderClients.paypal(
      'POST',
      '/v2/customer/partner-referrals',
      requestId: c.requestKey,
      body: {
        'tracking_id': r['trackingId'],
        'operations': [
          {
            'operation': 'API_INTEGRATION',
            'api_integration_preference': {
              'rest_api_integration': {
                'integration_method': 'PAYPAL',
                'integration_type': 'THIRD_PARTY',
                'third_party_details': {
                  'features': ['PAYMENT', 'REFUND', 'PARTNER_FEE'],
                },
              },
            },
          },
        ],
        'products': ['PPCP'],
        'legal_consents': [
          {'type': 'SHARE_DATA_CONSENT', 'granted': true},
        ],
      },
    );
    return {
      ...r,
      'onboardingUrl': ProviderClients.approval(response, rel: 'action_url'),
    };
  }

  static Future<Json> refreshMerchant(Session s, PlatformCommand c) async {
    final r = await _mutate(s, c, 'merchant.refresh', (w, d) async {
      _keys(d, {});
      await _stepUp(w, mfa: true);
      final m = await MerchantConnection.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.environment.equals(ProviderClients.paypalEnvironment),
        transaction: w.tx,
      );
      if (m == null) _fail('not_found', 'Start onboarding first.');
      return {'id': m.id, 'trackingId': m.trackingId};
    }, roles: {'owner'});
    final partner = ProviderClients.required('PAYPAL_PLATFORM_MERCHANT_ID');
    final response = await ProviderClients.paypal(
      'GET',
      '/v1/customer/partners/$partner/merchant-integrations?tracking_id=${Uri.encodeQueryComponent(r['trackingId'] as String)}',
    );
    final entries = response['merchant_id'] is String
        ? [response]
        : response['merchant_integrations'] as List? ?? [];
    if (entries.length != 1) {
      _fail('merchant_pending', 'Merchant consent is not complete.');
    }
    final merchant = _str(_object(entries.single), 'merchant_id', max: 50);
    final details = await ProviderClients.paypal(
      'GET',
      '/v1/customer/partners/$partner/merchant-integrations/$merchant',
    );
    if (details['merchant_id'] != merchant ||
        details['tracking_id'] != r['trackingId']) {
      _fail('merchant_mismatch', 'PayPal onboarding identity differs.');
    }
    final consent = (details['oauth_integrations'] as List? ?? [])
        .whereType<Map>()
        .expand((i) => i['oauth_third_party'] as List? ?? [])
        .whereType<Map>()
        .any(
          (i) =>
              i['partner_client_id'] ==
                  ProviderClients.required('PAYPAL_PLATFORM_CLIENT_ID') &&
              (i['scopes'] as List? ?? []).contains(
                'https://uri.paypal.com/services/payments/refund',
              ) &&
              (i['scopes'] as List? ?? []).contains(
                'https://uri.paypal.com/services/payments/payment/authcapture',
              ),
        );
    final ready =
        consent &&
        details['payments_receivable'] == true &&
        details['primary_email_confirmed'] == true &&
        (details['products'] as List? ?? []).any(
          (p) =>
              p is Map &&
              {'PPCP', 'PPCP_STANDARD', 'PPCP_CUSTOM'}.contains(p['name']) &&
              p['vetting_status'] == 'SUBSCRIBED',
        ) &&
        ProviderClients.merchantCountryAllowed(details);
    return MoneyModule.locked(
      s,
      c.restaurantId!,
      s.authenticated!.userIdentifier,
      (w) async {
        await w.role({'owner'});
        final m = (await MerchantConnection.db.findById(
          s,
          r['id'] as int,
          transaction: w.tx,
        ))!;
        m.merchantId = merchant;
        m.status = ready ? 'ready' : 'restricted';
        m.verifiedAt = _now();
        m.capabilitiesJson = jsonEncode({
          'paymentsReceivable': details['payments_receivable'] == true,
          'country': details['country'],
          'consentVerified': consent,
          'products': details['products'],
          'capabilities': details['capabilities'],
          'reviewRequired': details['country'] is! String,
        });
        await MerchantConnection.db.updateRow(s, m, transaction: w.tx);
        await w.audit('merchant.verified', 'merchant', m.id);
        return {'status': m.status};
      },
    );
  }
}
