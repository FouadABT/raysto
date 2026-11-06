part of 'platform.dart';

/// Calendar boundaries deliberately avoid adding 24-hour durations across DST.
class DecisionObservationPeriod {
  DecisionObservationPeriod(
    DateTime? publication,
    DateTime clock,
    String timezone,
  ) {
    zone = CatalogueModule.zone(timezone);
    final now = tz.TZDateTime.from(clock, zone);
    today = tz.TZDateTime(zone, now.year, now.month, now.day);
    if (publication == null) return;
    final local = tz.TZDateTime.from(publication, zone);
    tz.TZDateTime day(int offset) =>
        tz.TZDateTime(zone, local.year, local.month, local.day + offset);
    beforeStart = day(-7);
    beforeEnd = day(0);
    afterStart = day(1);
    afterEnd = day(8);
    elapsedCompleteDays = max(
      0,
      min(
        7,
        DateTime.utc(today.year, today.month, today.day)
            .difference(DateTime.utc(local.year, local.month, local.day + 1))
            .inDays,
      ),
    );
    observedEnd = elapsedCompleteDays == 0
        ? afterStart
        : today.isBefore(afterEnd!)
        ? today
        : afterEnd;
  }
  late final tz.Location zone;
  late final tz.TZDateTime today;
  tz.TZDateTime? beforeStart, beforeEnd, afterStart, afterEnd, observedEnd;
  int elapsedCompleteDays = 0;
}

class FinanceOutcomes {
  static Future<Json> read(Work w, Json decision) async {
    final comparison = _json(
      (await FinanceDecisions.get(
        w,
        decision['comparisonId'] as int,
        'comparison',
      )).payloadJson,
    );
    final history = await FinanceRecord.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) & t.kind.equals('priceHistory'),
      transaction: w.tx,
    );
    final publication = history
        .map((r) => {..._json(r.payloadJson), 'id': r.id})
        .where(
          (r) =>
              decision['actionId'] != null &&
              r['actionId'] == decision['actionId'],
        )
        .firstOrNull;
    final effective = publication == null
        ? null
        : DateTime.parse(publication['effectiveAt'] as String);
    final window = DecisionObservationPeriod(
      effective,
      _now(),
      (w.settings['timezone'] as String?) ?? 'UTC',
    );
    final zone = window.zone, today = window.today;
    final beforeStart = window.beforeStart,
        beforeEnd = window.beforeEnd,
        afterStart = window.afterStart,
        afterEnd = window.afterEnd,
        observedEnd = window.observedEnd;
    final counts = <String, Json>{
      for (final key in ['before', 'after'])
        key: {
          'orders': 0,
          'units': 0,
          'costedOrders': 0,
          'knownNetRevenueMinor': 0,
          'knownConsumptionCostMinor': 0,
          'unknownRevenueOrders': 0,
          'unknownCostOrders': 0,
          'newPriceUnits': 0,
          'frozenEarlierPriceUnits': 0,
          'laterRevisionUnits': 0,
          'unknownVersionUnits': 0,
        },
    };
    final orders = await PurchaseOrder.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id,
      limit: 20001,
      transaction: w.tx,
    );
    if (orders.length > 20000) {
      _fail(
        'scope_too_large',
        'Outcome exceeds the supported scan. No partial business totals are returned.',
      );
    }
    final events = <Json>[];
    var unknownCompletion = 0;
    final productId = decision['productId'] as int;
    for (final order in orders) {
      if (order.currency != w.restaurant!.currency ||
          !order.lines.any((l) => l.productId == productId)) {
        continue;
      }
      final frozen = await Finance017.record(w, 'orderRecipe', '${order.id}');
      final accepted = frozen == null
          ? <Json>[]
          : (_json(frozen.payloadJson)['lines'] as List)
                .map(_object)
                .where((l) => _object(l['cost'])['productId'] == productId)
                .toList();
      final costRecord = await Finance017.record(w, 'orderCost', '${order.id}');
      final cost = costRecord == null
          ? <String, dynamic>{}
          : _json(costRecord.payloadJson);
      final earned = await Finance017.record(
        w,
        'financeFact',
        'earned:${order.id}',
      );
      final completedAt = earned == null
          ? null
          : DateTime.parse(_json(earned.payloadJson)['at'] as String);
      final acceptedAt = frozen == null
          ? order.createdAt
          : DateTime.parse(_json(frozen.payloadJson)['frozenAt'] as String);
      final immediate = effective != null && !acceptedAt.isBefore(effective);
      String? period;
      if (completedAt != null &&
          beforeStart != null &&
          !completedAt.isBefore(beforeStart) &&
          completedAt.isBefore(beforeEnd!)) {
        period = 'before';
      }
      if (completedAt != null &&
          afterStart != null &&
          observedEnd != null &&
          !completedAt.isBefore(afterStart) &&
          completedAt.isBefore(observedEnd)) {
        period = 'after';
      }
      if (completedAt == null &&
          {'completed', 'delivered'}.contains(order.status)) {
        unknownCompletion++;
      }
      if (period == null && !immediate) continue;
      final charges = await BillCharge.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) & t.orderId.equals(order.id!),
        transaction: w.tx,
      );
      final lineKeys = accepted
          .map((l) => l['lineKey'])
          .whereType<String>()
          .toSet();
      final dishCharges = charges
          .where(
            (c) => lineKeys.any(
              (k) => c.lineKey == k || c.lineKey.startsWith('$k:'),
            ),
          )
          .toList();
      final checkoutIds = <int>{};
      var refundUnallocated = false;
      for (final charge in charges) {
        for (final a in await PaymentAllocation.db.find(
          w.s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.chargeId.equals(charge.id!),
          transaction: w.tx,
        )) {
          checkoutIds.add(a.checkoutId);
          if (a.refundedMinor > 0) refundUnallocated = true;
        }
      }
      final captures = <Json>[];
      for (final checkout in checkoutIds) {
        for (final c in await PaymentCapture.db.find(
          w.s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) & t.checkoutId.equals(checkout),
          transaction: w.tx,
        )) {
          captures.add({
            'id': c.id,
            'checkoutId': checkout,
            'providerCaptureId': c.providerCaptureId,
            'amountMinor': c.amountMinor,
            'refundedMinor': c.refundedMinor,
            'currency': c.currency,
            'state': c.state,
          });
          if (c.refundedMinor > 0) refundUnallocated = true;
        }
      }
      final recordedCosts = (cost['products'] as List? ?? const [])
          .map(_object)
          .where((l) => l['productId'] == productId)
          .toList();
      final knownCost =
          cost['complete'] == true &&
          recordedCosts.isNotEmpty &&
          recordedCosts.every((l) => l['costMinor'] is int);
      final knownRevenue =
          completedAt != null && dishCharges.isNotEmpty && !refundUnallocated;
      final net = knownRevenue
          ? dishCharges.fold<int>(
              0,
              (sum, c) =>
                  sum +
                  (c.amountMinor == 0
                      ? 0
                      : RestaurantCosting.divide(
                          c.foodNetMinor * (c.amountMinor - c.creditedMinor),
                          c.amountMinor,
                        )),
            )
          : null;
      final expense = knownCost
          ? recordedCosts.fold<int>(
              0,
              (sum, l) => sum + (l['costMinor'] as int),
            )
          : null;
      final units = order.lines
          .where((l) => l.productId == productId)
          .fold<int>(0, (sum, l) => sum + l.quantity);
      int cohort(bool Function(Json) match) => accepted
          .where(match)
          .fold<int>(0, (sum, l) => sum + (l['quantity'] as int));
      final exact = cohort(
        (l) =>
            publication != null &&
            l['acceptedProductVersion'] == publication['version'] &&
            (l['acceptedBasePriceMinor'] ?? l['acceptedUnitPriceMinor']) ==
                publication['toMinor'],
      );
      final earlier = cohort(
        (l) =>
            publication != null &&
            l['acceptedProductVersion'] is int &&
            (l['acceptedProductVersion'] as int) <
                (publication['version'] as int),
      );
      final later = cohort(
        (l) =>
            publication != null &&
            l['acceptedProductVersion'] is int &&
            (l['acceptedProductVersion'] as int) >
                (publication['version'] as int),
      );
      final unknown = units - exact - earlier - later;
      if (period != null) {
        final c = counts[period]!;
        void add(String key, int value) => c[key] = (c[key] as int) + value;
        add('orders', 1);
        add('units', units);
        add('newPriceUnits', exact);
        add('unknownVersionUnits', unknown);
        add('frozenEarlierPriceUnits', earlier);
        add('laterRevisionUnits', later);
        if (net == null) {
          add('unknownRevenueOrders', 1);
        } else {
          add('knownNetRevenueMinor', net);
        }
        if (expense == null) {
          add('unknownCostOrders', 1);
        } else {
          add('knownConsumptionCostMinor', expense);
          add('costedOrders', 1);
        }
      }
      events.add({
        'orderId': order.id,
        'state': order.status,
        'acceptedAt': acceptedAt.toIso8601String(),
        'earnedAt': completedAt?.toIso8601String(),
        'units': units,
        'newPriceUnits': exact,
        'frozenEarlierPriceUnits': earlier,
        'laterRevisionUnits': later,
        'unknownVersionUnits': unknown,
        'netRevenueMinor': net,
        'consumptionCostMinor': expense,
        'contributionMinor': net == null || expense == null
            ? null
            : net - expense,
        'refundAllocationUncertain': refundUnallocated,
        'captures': captures,
        'recipeSnapshotId': frozen?.id,
        'costSnapshotId': costRecord?.id,
        'recipeVersions': accepted
            .map((l) => _object(l['cost'])['recipeVersion'])
            .toSet()
            .toList(),
        'recordedCreditMinor': dishCharges.fold<int>(
          0,
          (sum, c) => sum + c.creditedMinor,
        ),
        'acceptedPricesMinor': accepted
            .map((l) => l['acceptedUnitPriceMinor'])
            .toSet()
            .toList(),
        'period': period,
      });
    }
    final policy = await FinanceAccounting.policy(w);
    final cutover = policy == null
        ? null
        : DateTime.parse(_json(policy.payloadJson)['cutoverAt'] as String);
    for (final key in counts.keys) {
      final c = counts[key]!,
          start = key == 'before' ? beforeStart : afterStart;
      c['supportedAccountingPeriod'] =
          cutover != null && start != null && !cutover.isAfter(start);
      c['complete'] =
          c['supportedAccountingPeriod'] == true &&
          unknownCompletion == 0 &&
          c['unknownRevenueOrders'] == 0 &&
          c['unknownCostOrders'] == 0;
      c['contributionMinor'] = (c['complete'] == true && c['orders'] != 0)
          ? (c['knownNetRevenueMinor'] as int) -
                (c['knownConsumptionCostMinor'] as int)
          : null;
    }
    final billIds = <int>{};
    for (final line
        in (_object(comparison['evidence'])['lines'] as List? ?? const []).map(
          _object,
        )) {
      final receipt = _object(line['source'])['id'];
      if (receipt is! int) continue;
      final source = await Finance017.query(w, 'finance.evidence', {
        'id': receipt,
      });
      if (source['billId'] is int) billIds.add(source['billId'] as int);
    }
    final suppliers = <Json>[];
    for (final id in billIds) {
      final b = await Bill.db.findById(w.s, id, transaction: w.tx);
      if (b == null || b.restaurantId != w.tenant) continue;
      final batch = b.payoutBatchId == null
          ? null
          : await PayoutBatch.db.findById(
              w.s,
              b.payoutBatchId!,
              transaction: w.tx,
            );
      final items = batch == null
          ? <PayoutItem>[]
          : await PayoutItem.db.find(
              w.s,
              where: (t) =>
                  t.restaurantId.equals(w.tenant) & t.batchId.equals(batch.id!),
              transaction: w.tx,
            );
      suppliers.add({
        'billId': b.id,
        'state': b.state,
        'amountMinor': b.amountMinor,
        'currency': b.currency,
        'batchState': batch?.state,
        'providerBatchId': batch?.providerBatchId,
        'items': [
          for (final i in items)
            {
              'id': i.id,
              'state': i.state,
              'amountMinor': i.amountMinor,
              'providerItemId': i.providerItemId,
            },
        ],
      });
    }
    return {
      'publication': publication,
      'observationStatus': effective == null
          ? 'not_published'
          : today.isBefore(afterEnd!)
          ? 'partial_period'
          : 'seven_days_available',
      'timezone': zone.name,
      'before': {
        'from': beforeStart?.toUtc().toIso8601String(),
        'to': beforeEnd?.toUtc().toIso8601String(),
        ...counts['before']!,
        'supportedAccountingPeriod':
            cutover != null &&
            beforeStart != null &&
            !cutover.isAfter(beforeStart),
      },
      'after': {
        'from': afterStart?.toUtc().toIso8601String(),
        'to': afterEnd?.toUtc().toIso8601String(),
        'observedThrough': window.elapsedCompleteDays == 0
            ? null
            : observedEnd?.toUtc().toIso8601String(),
        'elapsedCompleteDays': window.elapsedCompleteDays,
        ...counts['after']!,
      },
      'orders': events.take(100).toList(),
      'ordersTruncated': events.length > 100,
      'matchedOrderCount': events.length,
      'unknownCompletionCount': unknownCompletion,
      'supplierPayments': suppliers,
      'limitations': [
        'Descriptive observations do not establish that a price change caused a demand or profit change.',
        'The publication day is excluded. Full before/after periods use seven complete local days.',
        'Capture amounts cover their checkout, not this dish alone. Collections are separate from earned revenue.',
        'Contribution excludes payment fees and shared overhead. Historical costs use consumption snapshots and recorded packaging assumptions.',
        if (cutover == null ||
            beforeStart == null ||
            cutover.isAfter(beforeStart))
          'The preceding period lacks a complete supported accounting basis; historical comparison is incomplete.',
        if (unknownCompletion > 0)
          'Some completed orders lack an earned timestamp and cannot be placed in a daily comparison.',
        'Unallocated refunds and missing historical costs remain unknown. Availability, seasonality and other unrecorded changes may affect outcomes.',
      ],
    };
  }
}
