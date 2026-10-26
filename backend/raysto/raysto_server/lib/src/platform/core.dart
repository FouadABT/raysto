part of 'platform.dart';

class Work {
  final Session s;
  final Transaction tx;
  final ActorProfile actor;
  final PlatformCommand command;
  final Restaurant? restaurant;
  final RestaurantPolicy? policy;
  Work(this.s, this.tx, this.actor, this.command, this.restaurant, this.policy);
  String get user => actor.userId;
  int get tenant => restaurant!.id!;
  Json get settings => policy == null ? {} : _json(policy!.settingsJson);
  Future<Membership> role(Set<String> roles) =>
      _role(s, user, tenant, roles, tx: tx);
  Future<void> audit(
    String kind,
    String type,
    int? id, [
    Json details = const {},
  ]) async {
    await AuditRecord.db.insertRow(
      s,
      AuditRecord(
        restaurantId: restaurant?.id,
        userId: user,
        requestKey: command.requestKey,
        kind: kind,
        entityType: type,
        entityId: id,
        detailsJson: jsonEncode(details),
        createdAt: _now(),
      ),
      transaction: tx,
    );
  }

  Future<void> job(
    String kind,
    String key,
    Json data, {
    String? targetUser,
    DateTime? at,
  }) async {
    await PlatformJob.db.insert(
      s,
      [
        PlatformJob(
          restaurantId: restaurant?.id,
          userId: targetUser ?? user,
          kind: kind,
          dedupeKey: key,
          payloadJson: jsonEncode(data),
          state: 'pending',
          attempts: 0,
          availableAt: at ?? _now(),
          createdAt: _now(),
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
  }

  Future<void> notify(
    String target,
    String kind,
    Json reference,
    String key,
  ) async {
    await UserNotification.db.insert(
      s,
      [
        UserNotification(
          userId: target,
          restaurantId: restaurant?.id,
          eventKey: key,
          kind: kind,
          referenceJson: jsonEncode({
            if (restaurant != null) 'restaurantId': restaurant!.id,
            ...reference,
          }),
          createdAt: _now(),
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    await job('push', 'push:$target:$key', {
      'kind': kind,
      'reference': reference,
      'eventId': key,
    }, targetUser: target);
    if (Platform.environment['RAYSTO_TRANSACTIONAL_EMAIL_ENABLED'] == 'true') {
      await job('email.notification', 'email:$target:$key', {
        'kind': kind,
        'eventId': key,
      }, targetUser: target);
    }
  }
}

Future<ActorProfile> _actor(
  Session s, {
  Transaction? tx,
  bool lock = false,
}) async {
  final user =
      s.authenticated?.userIdentifier ??
      _fail('unauthorized', 'Sign in or start a guest session.');
  var p = await ActorProfile.db.findFirstRow(
    s,
    where: (t) => t.userId.equals(user),
    transaction: tx,
    lockMode: lock ? LockMode.forUpdate : null,
  );
  if (p == null) {
    final account = await AuthServices.instance.firebaseIdp.admin
        .findAccountByAuthUserId(s, authUserId: UuidValue.fromString(user));
    if (account == null) _fail('unauthorized', 'Account is not initialized.');
    await ActorProfile.db.insert(
      s,
      [
        ActorProfile(
          userId: user,
          firebaseUid: account.userIdentifier,
          isGuest: false,
          disabled: false,
          dataJson: '{}',
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    p = await ActorProfile.db.findFirstRow(
      s,
      where: (t) => t.userId.equals(user),
      transaction: tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
  }
  if (p == null || p.disabled || p.claimedBy != null) {
    _fail('unauthorized', 'This session no longer has access.');
  }
  return p;
}

Future<Membership> _role(
  Session s,
  String user,
  int tenant,
  Set<String> roles, {
  Transaction? tx,
}) async {
  final actor = await ActorProfile.db.findFirstRow(
    s,
    where: (t) => t.userId.equals(user),
    transaction: tx,
  );
  if (actor == null ||
      actor.isGuest ||
      actor.disabled ||
      actor.claimedBy != null) {
    _fail('forbidden', 'A current registered team account is required.');
  }
  final m = await Membership.db.findFirstRow(
    s,
    where: (t) => t.restaurantId.equals(tenant) & t.userId.equals(user),
    transaction: tx,
  );
  if (m == null || !m.active || !roles.contains(m.role)) {
    _fail('forbidden', 'This action is not permitted.');
  }
  return m;
}

Future<Json> _mutate(
  Session s,
  PlatformCommand c,
  String operation,
  Future<Json> Function(Work, Json) action, {
  Set<String>? roles,
  bool active = false,
  bool registered = false,
}) async {
  if (!RegExp(r'^[A-Za-z0-9_-]{16,100}$').hasMatch(c.requestKey)) {
    _fail('invalid_input', 'Use a stable 16–100 character requestKey.');
  }
  final data = _json(c.dataJson);
  final fingerprint = _hash(
    jsonEncode([
      operation,
      c.restaurantId,
      c.resourceId,
      c.expectedVersion,
      data,
    ]),
  );
  return s.db.transaction((tx) async {
    Restaurant? restaurant;
    RestaurantPolicy? policy;
    if (c.restaurantId != null) {
      restaurant = await Restaurant.db.findById(
        s,
        c.restaurantId!,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (restaurant == null) _fail('not_found', 'Restaurant not found.');
      policy = await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(c.restaurantId!),
        transaction: tx,
      );
    }
    final actor = await _actor(s, tx: tx, lock: true);
    if (registered && actor.isGuest) {
      _fail(
        'verified_account_required',
        'Use a verified account for this action.',
      );
    }
    if (roles != null) await _role(s, actor.userId, _rid(c), roles, tx: tx);
    final previous = await MutationReceipt.db.findFirstRow(
      s,
      where: (t) =>
          t.userId.equals(actor.userId) & t.requestKey.equals(c.requestKey),
      transaction: tx,
    );
    if (previous != null) {
      if (previous.requestHash != fingerprint) {
        _fail(
          'idempotency_conflict',
          'This request key belongs to a different operation.',
        );
      }
      return _json(previous.resultJson);
    }
    if (active) {
      if (policy == null || policy.suspended || restaurant?.published != true) {
        _fail('unavailable', 'Restaurant is not accepting new activity.');
      }
      await _entitled(s, c.restaurantId!, tx);
    }
    await _rate(s, 'actor:${actor.userId}', 120, tx);
    final result = await action(
      Work(s, tx, actor, c, restaurant, policy),
      data,
    );
    await MutationReceipt.db.insertRow(
      s,
      MutationReceipt(
        userId: actor.userId,
        requestKey: c.requestKey,
        operation: operation,
        requestHash: fingerprint,
        resultJson: jsonEncode(result),
        createdAt: _now(),
      ),
      transaction: tx,
    );
    return result;
  });
}

Future<void> _rate(
  Session s,
  String bucket,
  int limit,
  Transaction tx, {
  int minutes = 1,
}) async {
  final ticks = _now().millisecondsSinceEpoch ~/ (minutes * 60000);
  final start = DateTime.fromMillisecondsSinceEpoch(
    ticks * minutes * 60000,
    isUtc: true,
  );
  await RateWindow.db.insert(
    s,
    [RateWindow(bucket: bucket, windowStart: start, requests: 0)],
    ignoreConflicts: true,
    transaction: tx,
  );
  final row = (await RateWindow.db.findFirstRow(
    s,
    where: (t) => t.bucket.equals(bucket) & t.windowStart.equals(start),
    lockMode: LockMode.forUpdate,
    transaction: tx,
  ))!;
  if (row.requests >= limit) {
    _fail('rate_limited', 'Too many requests. Try again later.');
  }
  row.requests++;
  await RateWindow.db.updateRow(s, row, transaction: tx);
}

Future<void> _entitled(Session s, int tenant, Transaction tx) async {
  if (Platform.environment['RAYSTO_BILLING_ENFORCED'] != 'true') return;
  final sub = await RestaurantSubscription.db.findFirstRow(
    s,
    where: (t) => t.restaurantId.equals(tenant),
    transaction: tx,
  );
  final current =
      sub != null &&
      (sub.graceEndsAt != null
          ? sub.graceEndsAt!.isAfter(_now())
          : sub.status == 'active' &&
                sub.periodEndsAt != null &&
                sub.periodEndsAt!.isAfter(_now()));
  if (!current) {
    _fail(
      'subscription_required',
      'Restaurant subscription requires attention. Existing service and refunds remain available.',
    );
  }
}

Future<void> _stepUp(Work w, {bool mfa = false}) async {
  if (w.actor.isGuest) {
    _fail('verified_account_required', 'A verified account is required.');
  }
  final grant = await SecurityGrant.db.findFirstRow(
    w.s,
    where: (t) =>
        t.userId.equals(w.user) &
        t.kind.equals(mfa ? 'mfa' : 'recent_auth') &
        t.proofHash.equals(
          _hash(
            'stepup:${w.user}:${w.s.authenticated!.authId}:${mfa ? 'mfa' : 'recent_auth'}',
          ),
        ) &
        (t.expiresAt > _now()),
    transaction: w.tx,
  );
  if (grant == null) {
    _fail(
      mfa ? 'mfa_required' : 'reauthentication_required',
      'Confirm your identity before this sensitive action.',
    );
  }
}

bool _platformAdmin(String user) =>
    (Platform.environment['RAYSTO_ADMIN_USER_IDS'] ?? '')
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .contains(user);

Future<void> _admin(Work w) async {
  if (w.actor.disabled || w.actor.claimedBy != null || w.actor.isGuest) {
    _fail('forbidden', 'An active registered administrator is required.');
  }
  if (!_platformAdmin(w.user)) {
    _fail('forbidden', 'Platform administrator access is required.');
  }
  await _stepUp(w, mfa: true);
}

Future<void> _visitAccess(
  Work w,
  DiningVisit visit, {
  bool staffOnly = false,
}) async {
  if (visit.restaurantId != w.tenant) _fail('not_found', 'Visit not found.');
  final m = await Membership.db.findFirstRow(
    w.s,
    where: (t) =>
        t.restaurantId.equals(w.tenant) &
        t.userId.equals(w.user) &
        t.active.equals(true),
    transaction: w.tx,
  );
  if (m != null && _operators.contains(m.role)) {
    if (m.role == 'waiter') {
      final table = await DiningTable.db.findById(
        w.s,
        visit.tableId,
        transaction: w.tx,
      );
      if (table?.assignedWaiterId != w.user) {
        _fail('forbidden', 'This table is not assigned to you.');
      }
    }
    return;
  }
  if (!staffOnly) {
    final p = await VisitParticipant.db.findFirstRow(
      w.s,
      where: (t) =>
          t.visitId.equals(visit.id!) &
          t.userId.equals(w.user) &
          t.active.equals(true),
      transaction: w.tx,
    );
    if (p != null) return;
  }
  _fail('not_found', 'Visit not found.');
}

Future<void> _orderAccess(
  Work w,
  PurchaseOrder order, {
  bool manage = false,
}) async {
  if (order.restaurantId != w.tenant) _fail('not_found', 'Order not found.');
  if (!manage && order.customerId == w.user) return;
  final context = await OrderContext.db.findFirstRow(
    w.s,
    where: (t) => t.orderId.equals(order.id!),
    transaction: w.tx,
  );
  if (context?.visitId != null) {
    final visit = await DiningVisit.db.findById(
      w.s,
      context!.visitId!,
      transaction: w.tx,
    );
    if (visit != null) {
      await _visitAccess(w, visit, staffOnly: manage);
      return;
    }
  }
  await w.role(_managers);
}

Json _safeOrder(
  PurchaseOrder o,
  OrderContext? context, {
  bool contact = false,
}) => {
  'id': o.id,
  'restaurantId': o.restaurantId,
  'fulfillment': o.fulfillment,
  'status': o.status,
  'paymentStatus': o.paymentStatus,
  'version': o.version,
  'currency': o.currency,
  'totalMinor': o.totalMinor,
  'createdAt': o.createdAt.toIso8601String(),
  'visitId': context?.visitId,
  if (contact) 'address': o.address,
  'lines': context == null
      ? o.lines
            .map(
              (l) => {
                'name': l.name,
                'quantity': l.quantity,
                'unitPriceMinor': l.unitPriceMinor,
              },
            )
            .toList()
      : _json(context.detailsJson)['lines'],
};
