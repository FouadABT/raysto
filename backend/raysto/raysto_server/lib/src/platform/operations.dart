part of 'platform.dart';

class OperationsModule {
  static Json contact(Json d) {
    _keys(d, {'name', 'email', 'phone'});
    final name = _str(d, 'name', max: 100);
    final email = d['email'] == null ? null : _str(d, 'email', max: 254);
    final phone = d['phone'] == null ? null : _str(d, 'phone', max: 30);
    if (email != null &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _fail('invalid_input', 'Invalid email.');
    }
    if (email == null && phone == null) {
      _fail('invalid_input', 'A contact method is required.');
    }
    return {'name': name, 'email': email, 'phone': phone};
  }

  static Future<Json> favorite(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'favorite.set',
    (w, d) async {
      _keys(d, {'productId', 'enabled'});
      final product = d['productId'] == null
          ? null
          : _int(d, 'productId', min: 1);
      if (product != null) {
        final p = await MenuProduct.db.findById(s, product, transaction: w.tx);
        if (p?.restaurantId != w.tenant) _fail('not_found', 'Dish not found.');
      }
      final key = '${w.tenant}:${product ?? 0}';
      final old = await CustomerFavorite.db.findFirstRow(
        s,
        where: (t) => t.userId.equals(w.user) & t.targetKey.equals(key),
        transaction: w.tx,
      );
      if (_bool(d, 'enabled') && old == null) {
        await CustomerFavorite.db.insertRow(
          s,
          CustomerFavorite(
            userId: w.user,
            restaurantId: w.tenant,
            productId: product,
            targetKey: key,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
      }
      if (!_bool(d, 'enabled') && old != null) {
        await CustomerFavorite.db.deleteRow(s, old, transaction: w.tx);
      }
      return {'enabled': _bool(d, 'enabled')};
    },
  );
  static Future<Json> review(Session s, PlatformCommand c) =>
      _mutate(s, c, 'review.save', (w, d) async {
        _keys(d, {'rating', 'text'});
        final (o, ctx) = await OrderingModule._order(w, _id(c));
        if (o.customerId != w.user || o.status != 'completed') {
          _fail('forbidden', 'Reviews require your completed order.');
        }
        var r = await CustomerReview.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(o.id!),
          transaction: w.tx,
        );
        if (r != null) _version(r.version, c.expectedVersion);
        r ??= CustomerReview(
          restaurantId: w.tenant,
          orderId: o.id!,
          userId: w.user,
          rating: 1,
          text: '',
          status: 'pending',
          version: 0,
          createdAt: _now(),
        );
        r.rating = _int(d, 'rating', min: 1, max: 5);
        r.text = _str(d, 'text', max: 2000);
        r.status = 'pending';
        r.version++;
        r = r.id == null
            ? await CustomerReview.db.insertRow(s, r, transaction: w.tx)
            : await CustomerReview.db.updateRow(s, r, transaction: w.tx);
        return {'reviewId': r.id, 'version': r.version, 'status': r.status};
      }, registered: true);
  static Future<Json> moderateReview(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'review.moderate', (w, d) async {
    _keys(d, {'response', 'status', 'reason'});
    final r = await CustomerReview.db.findById(s, _id(c), transaction: w.tx);
    if (r == null || r.restaurantId != w.tenant) {
      _fail('not_found', 'Review not found.');
    }
    _version(r.version, c.expectedVersion);
    if (d.containsKey('response')) {
      await w.role(_managers);
      r.response = _str(d, 'response', max: 1500);
    }
    if (d.containsKey('status')) {
      await _admin(w);
      r.status = _str(d, 'status', choices: {'published', 'hidden', 'pending'});
      await w.audit('review.moderated', 'review', r.id, {
        'reason': _str(d, 'reason', max: 500),
      });
    }
    r.version++;
    await CustomerReview.db.updateRow(s, r, transaction: w.tx);
    return {'version': r.version};
  });
  static Future<SupportConversation> conversation(
    Work w,
    int id, {
    bool manage = false,
  }) async {
    final c = await SupportConversation.db.findById(w.s, id, transaction: w.tx);
    if (c == null || c.restaurantId != w.restaurant?.id) {
      _fail('not_found', 'Conversation not found.');
    }
    if (c.userId != w.user || manage) {
      if (c.escalated && c.restaurantId == null) {
        await _admin(w);
      } else {
        await w.role(_managers);
      }
    }
    return c;
  }

  static Future<Json> openConversation(Session s, PlatformCommand c) =>
      _mutate(s, c, 'support.open', (w, d) async {
        _keys(d, {'subject', 'orderId', 'text', 'abuse'});
        final order = d['orderId'] == null ? null : _int(d, 'orderId', min: 1);
        if (order != null) {
          final (o, ctx) = await OrderingModule._order(w, order);
          if (o.customerId != w.user) await w.role(_managers);
        }
        final row = await SupportConversation.db.insertRow(
          s,
          SupportConversation(
            restaurantId: w.restaurant?.id,
            orderId: order,
            userId: w.user,
            status: 'open',
            subject: _str(d, 'subject', max: 150),
            escalated: _bool(d, 'abuse') || w.restaurant == null,
            version: 1,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await SupportMessage.db.insertRow(
          s,
          SupportMessage(
            conversationId: row.id!,
            userId: w.user,
            text: _str(d, 'text', max: 4000),
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        await w.audit('support.opened', 'conversation', row.id);
        return {'conversationId': row.id, 'version': row.version};
      });
  static Future<Json> message(Session s, PlatformCommand c) =>
      _mutate(s, c, 'support.message', (w, d) async {
        _keys(d, {'text', 'mediaId'});
        final row = await conversation(w, _id(c));
        if (row.status == 'closed') {
          _fail('invalid_transition', 'Conversation is closed.');
        }
        final media = d['mediaId'] == null ? null : _int(d, 'mediaId', min: 1);
        if (media != null) {
          final m = await MediaAsset.db.findById(s, media, transaction: w.tx);
          if (m == null ||
              m.userId != w.user ||
              m.restaurantId != w.restaurant?.id ||
              m.purpose != 'support' ||
              m.status != 'approved') {
            _fail('not_found', 'Attachment is unavailable.');
          }
        }
        final msg = await SupportMessage.db.insertRow(
          s,
          SupportMessage(
            conversationId: row.id!,
            userId: w.user,
            text: _str(d, 'text', max: 4000),
            mediaId: media,
            createdAt: _now(),
          ),
          transaction: w.tx,
        );
        row.version++;
        await SupportConversation.db.updateRow(s, row, transaction: w.tx);
        if (row.userId != w.user) {
          await w.notify(row.userId, 'support.message', {
            'conversationId': row.id,
          }, 'support:${msg.id}');
        }
        return {'messageId': msg.id, 'version': row.version};
      });
  static Future<Json> supportTransition(Session s, PlatformCommand c) =>
      _mutate(s, c, 'support.transition', (w, d) async {
        _keys(d, {'status', 'escalate'});
        final row = await conversation(w, _id(c));
        _version(row.version, c.expectedVersion);
        row.status = _str(d, 'status', choices: {'open', 'closed'});
        if (_bool(d, 'escalate')) row.escalated = true;
        row.version++;
        await SupportConversation.db.updateRow(s, row, transaction: w.tx);
        await w.audit('support.updated', 'conversation', row.id);
        return {'version': row.version};
      });
  static Future<Json> notification(Session s, PlatformCommand c) =>
      _mutate(s, c, 'notification.update', (w, d) async {
        _keys(d, {'dismiss'});
        final n = await UserNotification.db.findById(
          s,
          _id(c),
          transaction: w.tx,
        );
        if (n == null || n.userId != w.user) {
          _fail('not_found', 'Notification not found.');
        }
        n.readAt ??= _now();
        if (_bool(d, 'dismiss')) n.dismissedAt = _now();
        await UserNotification.db.updateRow(s, n, transaction: w.tx);
        return {'read': true, 'dismissed': n.dismissedAt != null};
      });
  static Future<Json> plan(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'admin.plan',
    (w, d) async {
      await _admin(w);
      _keys(d, {
        'code',
        'currency',
        'priceMinor',
        'commissionBps',
        'features',
        'providerPlanId',
        'active',
      });
      final code = _str(d, 'code', max: 50);
      final old = await RestaurantPlan.db.findFirstRow(
        s,
        where: (t) => t.code.equals(code),
        orderBy: (t) => t.version.desc(),
        transaction: w.tx,
      );
      final features = _object(d['features']);
      _keys(features, {
        'dineIn',
        'pickup',
        'delivery',
        'aiImportsPerDay',
        'aiTokenBudgetPerDay',
        'maxTeamMembers',
      });
      for (final key in ['dineIn', 'pickup', 'delivery']) {
        _bool(features, key);
      }
      for (final key in [
        'aiImportsPerDay',
        'aiTokenBudgetPerDay',
        'maxTeamMembers',
      ]) {
        _int(features, key, max: 1000000);
      }
      final p = await RestaurantPlan.db.insertRow(
        s,
        RestaurantPlan(
          code: code,
          version: (old?.version ?? 0) + 1,
          currency: _str(d, 'currency', choices: {'EUR', 'USD', 'GBP'}),
          priceMinor: _int(d, 'priceMinor', min: 1),
          commissionBps: _int(d, 'commissionBps', max: 3000),
          featuresJson: jsonEncode(features),
          providerPlanId: d['providerPlanId'] == null
              ? null
              : _str(d, 'providerPlanId', max: 80),
          active: _bool(d, 'active'),
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('billing.plan_created', 'plan', p.id);
      return {'planId': p.id, 'version': p.version};
    },
    registered: true,
  );
  static Future<Json> subscribe(Session s, PlatformCommand c) async {
    final result = await _mutate(s, c, 'billing.subscribe', (w, d) async {
      _keys(d, {'planId'});
      await _stepUp(w, mfa: true);
      final plan = await RestaurantPlan.db.findById(
        s,
        _int(d, 'planId', min: 1),
        transaction: w.tx,
      );
      if (plan == null ||
          !plan.active ||
          plan.providerPlanId == null ||
          plan.currency != w.restaurant!.currency) {
        _fail('invalid_plan', 'Plan is not available.');
      }
      final old = await RestaurantSubscription.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      if (old != null && !{'cancelled', 'expired'}.contains(old.status)) {
        _fail(
          'subscription_pending',
          'Refresh or cancel the existing subscription first.',
        );
      }
      final sub =
          old ??
          RestaurantSubscription(
            restaurantId: w.tenant,
            planId: plan.id!,
            status: 'creating',
            requestKey: c.requestKey,
            updatedAt: _now(),
          );
      sub.planId = plan.id!;
      sub.status = 'creating';
      sub.requestKey = c.requestKey;
      sub.providerSubscriptionId = null;
      sub.graceEndsAt = null;
      sub.periodEndsAt = null;
      final saved = old == null
          ? await RestaurantSubscription.db.insertRow(s, sub, transaction: w.tx)
          : await RestaurantSubscription.db.updateRow(
              s,
              sub,
              transaction: w.tx,
            );
      await w.job('billing.create', 'billing:${saved.id}:${c.requestKey}', {
        'subscriptionId': saved.id,
      });
      await w.audit('billing.checkout_requested', 'subscription', saved.id);
      return {'subscriptionId': saved.id, 'state': saved.status};
    }, roles: {'owner'});
    return result;
  }

  static Future<void> createSubscription(Session s, int id) async {
    final sub = await RestaurantSubscription.db.findById(s, id);
    if (sub == null || sub.status != 'creating') return;
    if (_now().difference(sub.updatedAt).inHours >= 5) {
      _fail(
        'reconciliation_required',
        'Subscription creation exceeded safe retry window.',
      );
    }
    final plan = (await RestaurantPlan.db.findById(s, sub.planId))!;
    final providerPlan = await ProviderClients.paypal(
      'GET',
      '/v1/billing/plans/${plan.providerPlanId}',
      billing: true,
    );
    final cycles = providerPlan['billing_cycles'] as List? ?? [];
    final regular = cycles.where((x) => x['tenure_type'] == 'REGULAR').toList();
    if (providerPlan['status'] != 'ACTIVE' ||
        cycles.length != 1 ||
        regular.length != 1 ||
        regular.single['frequency']?['interval_unit'] != 'MONTH' ||
        regular.single['frequency']?['interval_count'] != 1 ||
        regular.single['total_cycles'] != 0 ||
        (providerPlan['taxes']?['percentage'] != null &&
            num.tryParse('${providerPlan['taxes']['percentage']}') != 0) ||
        (providerPlan['payment_preferences']?['setup_fee']?['value'] != null &&
            PayPalGateway.parseMoney(
                  '${providerPlan['payment_preferences']['setup_fee']['value']}',
                ) !=
                0) ||
        regular.single['pricing_scheme']['fixed_price']['currency_code'] !=
            plan.currency ||
        PayPalGateway.parseMoney(
              regular.single['pricing_scheme']['fixed_price']['value']
                  as String,
            ) !=
            plan.priceMinor) {
      _fail(
        'billing_mismatch',
        'Provider plan does not match configured pricing.',
      );
    }
    final response = await ProviderClients.paypal(
      'POST',
      '/v1/billing/subscriptions',
      billing: true,
      requestId: sub.requestKey,
      body: {
        'plan_id': plan.providerPlanId,
        'custom_id': 'raysto-restaurant:${sub.restaurantId}',
        'application_context': {
          'return_url': ProviderClients.callback(
            'PAYPAL_BILLING_RETURN_URL',
          ).toString(),
          'cancel_url': ProviderClients.callback(
            'PAYPAL_BILLING_CANCEL_URL',
          ).toString(),
          'user_action': 'SUBSCRIBE_NOW',
        },
      },
    );
    await s.db.transaction((tx) async {
      final row = (await RestaurantSubscription.db.findById(
        s,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      if (row.requestKey != sub.requestKey || row.status != 'creating') return;
      row.providerSubscriptionId = _str(response, 'id', max: 100);
      row.approvalUrl = ProviderClients.approval(response);
      row.status = 'approvalPending';
      row.updatedAt = _now();
      await RestaurantSubscription.db.updateRow(s, row, transaction: tx);
    });
  }

  static Future<Json> refreshSubscription(Session s, PlatformCommand c) async {
    final result = await _mutate(s, c, 'billing.refresh', (w, d) async {
      _keys(d, {});
      final row = await RestaurantSubscription.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(w.tenant),
        transaction: w.tx,
      );
      if (row == null) _fail('not_found', 'Subscription not found.');
      return {'id': row.id};
    }, roles: {'owner'});
    await syncSubscription(s, result['id'] as int);
    final row = (await RestaurantSubscription.db.findById(
      s,
      result['id'] as int,
    ))!;
    return {
      'status': row.status,
      'approvalUrl': row.approvalUrl,
      'periodEndsAt': row.periodEndsAt?.toIso8601String(),
      'graceEndsAt': row.graceEndsAt?.toIso8601String(),
    };
  }

  static Future<void> syncSubscription(Session s, int id) async {
    final sub = await RestaurantSubscription.db.findById(s, id);
    if (sub == null || sub.providerSubscriptionId == null) return;
    final p = await ProviderClients.paypal(
      'GET',
      '/v1/billing/subscriptions/${sub.providerSubscriptionId}',
      billing: true,
    );
    final plan = (await RestaurantPlan.db.findById(s, sub.planId))!;
    if (p['plan_id'] != plan.providerPlanId ||
        p['custom_id'] != 'raysto-restaurant:${sub.restaurantId}') {
      _fail('billing_mismatch', 'Subscription identity differs.');
    }
    await s.db.transaction((tx) async {
      final row = (await RestaurantSubscription.db.findById(
        s,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      ))!;
      if (row.providerSubscriptionId != sub.providerSubscriptionId) return;
      row.status = switch (p['status']) {
        'ACTIVE' => 'active',
        'SUSPENDED' => 'suspended',
        'CANCELLED' => 'cancelled',
        'EXPIRED' => 'expired',
        _ => 'approvalPending',
      };
      final info = p['billing_info'] as Map? ?? {};
      final next = DateTime.tryParse('${info['next_billing_time'] ?? ''}');
      row.periodEndsAt = next?.toUtc();
      if ((info['failed_payments_count'] as num? ?? 0) > 0) {
        final failAt =
            DateTime.tryParse(
              '${info['last_failed_payment']?['time'] ?? ''}',
            ) ??
            _now();
        row.graceEndsAt ??= failAt.add(
          Duration(
            days:
                int.tryParse(
                  Platform.environment['RAYSTO_SUBSCRIPTION_GRACE_DAYS'] ?? '7',
                ) ??
                7,
          ),
        );
      } else {
        row.graceEndsAt = null;
      }
      if ({'cancelled', 'expired'}.contains(row.status)) row.graceEndsAt = null;
      row.updatedAt = _now();
      await RestaurantSubscription.db.updateRow(s, row, transaction: tx);
      final evidence = {
        'status': row.status,
        'periodEndsAt': row.periodEndsAt?.toIso8601String(),
        'graceEndsAt': row.graceEndsAt?.toIso8601String(),
        'lastPayment': info['last_payment'],
        'outstandingBalance': info['outstanding_balance'],
      };
      await BillingHistory.db.insert(
        s,
        [
          BillingHistory(
            restaurantId: row.restaurantId,
            providerSubscriptionId: row.providerSubscriptionId!,
            eventKey:
                '${row.providerSubscriptionId}:${_hash(jsonEncode(evidence))}',
            status: row.status,
            detailsJson: jsonEncode(evidence),
            createdAt: _now(),
          ),
        ],
        ignoreConflicts: true,
        transaction: tx,
      );
    });
  }

  static Future<Json> cancelSubscription(Session s, PlatformCommand c) =>
      _mutate(s, c, 'billing.cancel', (w, d) async {
        _keys(d, {'reason'});
        await _stepUp(w, mfa: true);
        final row = await RestaurantSubscription.db.findFirstRow(
          s,
          where: (t) => t.restaurantId.equals(w.tenant),
          transaction: w.tx,
        );
        if (row == null || row.providerSubscriptionId == null) {
          _fail(
            'subscription_pending',
            'Reconcile subscription creation first.',
          );
        }
        await w.job('billing.cancel', 'billing-cancel:${row.id}', {
          'subscriptionId': row.id,
          'reason': _str(d, 'reason', max: 128),
        });
        await w.audit('billing.cancellation_requested', 'subscription', row.id);
        return {'state': 'cancellationRequested'};
      }, roles: {'owner'});
  static Future<Json> suspend(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'admin.suspend',
    (w, d) async {
      await _admin(w);
      _keys(d, {'suspended', 'reason'});
      if (w.policy == null) _fail('not_found', 'Restaurant policy not found.');
      w.policy!.suspended = _bool(d, 'suspended');
      w.policy!.version++;
      await RestaurantPolicy.db.updateRow(s, w.policy!, transaction: w.tx);
      await w.audit('restaurant.suspension', 'restaurant', w.tenant, {
        'reason': _str(d, 'reason', max: 500),
        'suspended': w.policy!.suspended,
      });
      return {'version': w.policy!.version};
    },
  );
  static Future<Json> replay(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'admin.replayJob', (w, d) async {
    await _admin(w);
    _keys(d, {'reason'});
    final job = await PlatformJob.db.findById(s, _id(c), transaction: w.tx);
    if (job == null ||
        job.restaurantId != w.restaurant?.id ||
        job.state != 'dead') {
      _fail('not_found', 'Failed job not found.');
    }
    // Financial jobs keep stable request IDs; operator replay never creates a new checkout.
    if (job.kind == 'ai.run') {
      _fail(
        'new_ai_request_required',
        'Create a new AI operation so its quota and approval revision are reserved explicitly.',
      );
    }
    if ({'payment.refund', 'billing.create'}.contains(job.kind) &&
        _now().difference(job.createdAt).inHours >= 5) {
      _fail(
        'manual_reconciliation_required',
        'Reconcile provider history before replaying an aged financial request.',
      );
    }
    job.state = 'pending';
    job.attempts = 0;
    job.availableAt = _now();
    job.leaseToken = null;
    job.leaseUntil = null;
    await PlatformJob.db.updateRow(s, job, transaction: w.tx);
    await w.audit('job.replayed', 'job', job.id, {
      'reason': _str(d, 'reason', max: 500),
    });
    return {'state': job.state};
  });
}
