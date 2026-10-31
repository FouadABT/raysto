part of 'platform.dart';

/// An equal split freezes every payer's minor-unit share. A later payer never
/// divides the already-reduced remaining bill a second time.
class EqualShares {
  static Map<String, List<Json>> distribute(
    List<Json> charges,
    List<String> people,
  ) {
    if (people.isEmpty || people.toSet().length != people.length) {
      _fail('invalid_input', 'Choose unique payers.');
    }
    final payers = [...people]..sort();
    final result = {for (final user in payers) user: <Json>[]};
    for (final charge in charges) {
      final amounts = OrderingModule.distribute(
        charge['availableMinor'] as int,
        List.filled(payers.length, 1),
      );
      for (var i = 0; i < payers.length; i++) {
        if (amounts[i] > 0) {
          result[payers[i]]!.add({
            'chargeId': charge['chargeId'],
            'amountMinor': amounts[i],
            'label': charge['label'],
          });
        }
      }
    }
    return result;
  }

  static Future<Json> prepare(
    Work w,
    ConversationRoom room,
    List<String> people,
    List<Json> charges,
  ) async {
    final payers = [...people]..sort();
    var plan = await BillSplitPlan.db.findFirstRow(
      w.s,
      where: (t) => t.activeRoomId.equals(room.id!),
      transaction: w.tx,
    );
    final originalIds = plan == null
        ? <int>{}
        : _json(plan.sharesJson).values
              .whereType<List>()
              .expand((v) => v)
              .map((v) => _object(v)['chargeId'] as int)
              .toSet();
    if (plan != null &&
        charges
            .where((c) => originalIds.contains(c['chargeId']))
            .every(
              (c) =>
                  (c['availableMinor'] as int) == 0 &&
                  (c['reservedMinor'] as int) == 0,
            )) {
      plan.activeRoomId = null;
      await BillSplitPlan.db.updateRow(w.s, plan, transaction: w.tx);
      plan = null;
    }
    if (plan == null) {
      if (charges.any((c) => (c['reservedMinor'] as int) > 0)) {
        _fail('payment_pending', 'Wait for the current payer to finish.');
      }
      plan = await BillSplitPlan.db.insertRow(
        w.s,
        BillSplitPlan(
          restaurantId: w.tenant,
          roomId: room.id!,
          activeRoomId: room.id,
          createdBy: w.user,
          payersJson: jsonEncode(payers),
          sharesJson: jsonEncode(distribute(charges, payers)),
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
    }
    if (plan.payersJson != jsonEncode(payers)) {
      _fail(
        'split_in_progress',
        'An equal split is already in progress. Ask the host to reset its unpaid proposals before choosing a different group.',
      );
    }
    final intents = await CheckoutIntent.db.find(
      w.s,
      where: (t) => t.splitPlanId.equals(plan!.id!) & t.userId.equals(w.user),
      limit: 501,
      transaction: w.tx,
    );
    if (intents.length > 500) {
      _fail('limit_exceeded', 'Ask staff to review this split.');
    }
    final paid = <int, int>{};
    for (final intent in intents) {
      final allocations = await PaymentAllocation.db.find(
        w.s,
        where: (t) =>
            t.checkoutId.equals(intent.id!) & t.state.equals('settled'),
        transaction: w.tx,
      );
      for (final a in allocations) {
        paid[a.chargeId] = (paid[a.chargeId] ?? 0) + a.amountMinor;
      }
    }
    final shares = <Json>[];
    for (final raw in (_json(plan.sharesJson)[w.user] as List? ?? [])) {
      final frozen = _object(raw);
      final id = frozen['chargeId'] as int;
      final amount = max(0, (frozen['amountMinor'] as int) - (paid[id] ?? 0));
      if (amount == 0) continue;
      final charge = charges.where((c) => c['chargeId'] == id).firstOrNull;
      if (charge == null || amount > (charge['availableMinor'] as int)) {
        _fail(
          'split_changed',
          'The bill changed outside this split. Ask the host to reset unpaid proposals and review the remaining balance.',
        );
      }
      shares.add({
        ...frozen,
        'amountMinor': amount,
        'expectedVersion': charge['version'],
      });
    }
    return {
      'splitPlanId': plan.id,
      'shares': shares,
      'payers': payers,
      'basis':
          'Each share uses the original frozen split. Later rounds are excluded.',
    };
  }

  /// The equal split without the assistant: the same frozen shares a diner
  /// would get from an approved AI proposal, so splitting never needs AI.
  static Future<Json> equal(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'room.split.equal', (w, d) async {
    _keys(d, {'payers'});
    final room = await ConversationModule.room(w, _id(c), write: true);
    if (room.visitId == null) {
      _fail('invalid_input', 'Equal shares split a table bill.');
    }
    final raw = _list(d, 'payers', max: 50);
    if (raw.any((p) => p is! String)) _fail('invalid_input', 'Invalid payers.');
    final payers = raw.cast<String>().toList();
    final diners = await ConversationModule.diners(w, room);
    if (payers.isEmpty ||
        payers.toSet().length != payers.length ||
        !payers.contains(w.user) ||
        payers.any((p) => !diners.contains(p))) {
      _fail('invalid_input', 'Choose current diners including yourself.');
    }
    final bill = await AssistantModule.bill(w, room);
    return prepare(w, room, payers, (bill['charges'] as List).cast<Json>());
  });

  /// The caller's remaining frozen share of an active equal split, used by
  /// payment.allocate to refuse any amount other than that exact share.
  static Future<List<Json>> mine(Work w, int splitPlanId, int visitId) async {
    final plan = await BillSplitPlan.db.findById(
      w.s,
      splitPlanId,
      transaction: w.tx,
    );
    final room = plan?.activeRoomId == null
        ? null
        : await ConversationRoom.db.findById(
            w.s,
            plan!.activeRoomId!,
            transaction: w.tx,
          );
    if (plan == null ||
        plan.restaurantId != w.tenant ||
        room == null ||
        room.visitId != visitId) {
      _fail('stale_proposal', 'This equal split was reset. Review a new share.');
    }
    final bill = await AssistantModule.bill(w, room);
    final split = await prepare(
      w,
      room,
      (jsonDecode(plan.payersJson) as List).cast<String>(),
      (bill['charges'] as List).cast<Json>(),
    );
    // A fully paid plan is replaced by prepare; a payment must not be
    // stamped with the old one, or the new plan would not count it.
    if (split['splitPlanId'] != plan.id) {
      _fail('stale_proposal', 'This equal split was reset. Review a new share.');
    }
    return (split['shares'] as List).cast<Json>();
  }

  static Future<Json> reset(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'room.split.reset', (w, d) async {
    _keys(d, {});
    final room = await ConversationModule.room(w, _id(c), write: true);
    if (room.hostUserId != w.user) await w.role(_managers);
    final plan = await BillSplitPlan.db.findFirstRow(
      s,
      where: (t) => t.activeRoomId.equals(room.id!),
      transaction: w.tx,
    );
    if (plan == null) return {'reset': true};
    final pending = await CheckoutIntent.db.count(
      s,
      where: (t) =>
          t.splitPlanId.equals(plan.id!) &
          t.state.inSet({
            'reserved',
            'creating',
            'created',
            'approved',
            'capturing',
            'uncertain',
          }),
      transaction: w.tx,
    );
    if (pending > 0) {
      _fail(
        'payment_pending',
        'Finish or reconcile pending payments before resetting the split.',
      );
    }
    plan.activeRoomId = null;
    await BillSplitPlan.db.updateRow(s, plan, transaction: w.tx);
    room.version++;
    await ConversationRoom.db.updateRow(s, room, transaction: w.tx);
    await ConversationModule.append(w, room, 'split.reset', {
      'text':
          'Unpaid equal-share proposals were reset. Completed payments remain recorded.',
    });
    return {'reset': true};
  });
}
