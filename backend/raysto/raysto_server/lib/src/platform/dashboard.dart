part of 'platform.dart';

/// The owner's dashboard: paid sales over today, 7 or 30 days in the café's
/// own time zone, with the period before for comparison, the channel mix,
/// the kitchen right now, the latest orders, who moved them, and the day's
/// target. The contract is `docs/dashboard-contract.md`.
///
/// Money uses the same basis as `analytics`: paid (or partly refunded)
/// orders, not cancelled, rejected or expired, counted when placed.
class DashboardModule {
  static const ranges = {'today', '7d', '30d'};
  static const basis = 'paidOrdersByCreatedAt';
  static const sampleLabel = 'Sample history · illustrative, not sales';
  static const _kitchen = ['submitted', 'accepted', 'preparing', 'ready'];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static Future<Json> read(Work w, Json d) async {
    final range = _str(
      {'range': d['range'] ?? 'today'},
      'range',
      choices: ranges,
    );
    final s = w.s;
    final tx = w.tx;
    final timezone = w.settings['timezone'] as String;
    final zone = CatalogueModule.zone(timezone);
    final now = _now();
    final local = tz.TZDateTime.from(now, zone);
    final midnight = tz.TZDateTime(zone, local.year, local.month, local.day);

    // Bucket starts, oldest first, and the window [from, to).
    final List<tz.TZDateTime> starts;
    final tz.TZDateTime to;
    final DateTime prevFrom, prevTo;
    if (range == 'today') {
      starts = [
        for (var h = 0; h <= local.hour; h++)
          tz.TZDateTime(zone, local.year, local.month, local.day, h),
      ];
      to = tz.TZDateTime(
        zone,
        local.year,
        local.month,
        local.day,
        local.hour + 1,
      );
      // Yesterday up to the same local time.
      prevFrom = tz.TZDateTime(zone, local.year, local.month, local.day - 1);
      prevTo = tz.TZDateTime(
        zone,
        local.year,
        local.month,
        local.day - 1,
        local.hour,
        local.minute,
        local.second,
      );
    } else {
      final days = range == '7d' ? 7 : 30;
      starts = [
        for (var i = days - 1; i >= 0; i--)
          tz.TZDateTime(zone, local.year, local.month, local.day - i),
      ];
      to = tz.TZDateTime(zone, local.year, local.month, local.day + 1);
      prevFrom = tz.TZDateTime(
        zone,
        local.year,
        local.month,
        local.day - 2 * days + 1,
      );
      prevTo = starts.first;
    }
    final from = starts.first;

    Future<List<PurchaseOrder>> paid(DateTime a, DateTime b) =>
        PurchaseOrder.db.find(
          s,
          where: (t) =>
              t.restaurantId.equals(w.tenant) &
              (t.createdAt >= a) &
              (t.createdAt < b) &
              t.paymentStatus.inSet({'paid', 'partiallyRefunded'}) &
              t.status.notInSet({'cancelled', 'rejected', 'expired'}),
          limit: 20000,
          transaction: tx,
        );
    Future<Map<int, int>> tipsOf(Iterable<int> ids) async {
      if (ids.isEmpty) return {};
      final rows = await BillCharge.db.find(
        s,
        where: (t) => t.orderId.inSet(ids.toSet()) & t.kind.equals('tip'),
        transaction: tx,
      );
      final tips = <int, int>{};
      for (final b in rows) {
        tips[b.orderId] = (tips[b.orderId] ?? 0) + b.settledMinor;
      }
      return tips;
    }

    final orders = await paid(from, to);
    final previous = await paid(prevFrom, prevTo);
    final tips = await tipsOf(orders.map((o) => o.id!));
    final prevTips = await tipsOf(previous.map((o) => o.id!));

    // One bucket per hour or day; empty buckets stay with zeros.
    final n = starts.length;
    final sales = List<int>.filled(n, 0);
    final counts = List<int>.filled(n, 0);
    final tipSeries = List<int>.filled(n, 0);
    int bucket(DateTime at) {
      for (var i = n - 1; i >= 0; i--) {
        if (!at.isBefore(starts[i])) return i;
      }
      return 0;
    }

    final contexts = orders.isEmpty
        ? const <OrderContext>[]
        : await OrderContext.db.find(
            s,
            where: (t) => t.orderId.inSet({for (final o in orders) o.id!}),
            transaction: tx,
          );
    final origin = {for (final c in contexts) c.orderId: c.origin};
    final channels = <String, ({int sales, int orders})>{};
    for (final o in orders) {
      final i = bucket(o.createdAt);
      sales[i] += o.totalMinor;
      counts[i] += 1;
      tipSeries[i] += tips[o.id] ?? 0;
      final channel =
          OrderingModule.isWalkIn(o.customerId) || origin[o.id] == 'counter'
          ? 'counter'
          : o.fulfillment == 'dineIn'
          ? 'table'
          : o.fulfillment;
      final c = channels[channel];
      channels[channel] = (
        sales: (c?.sales ?? 0) + o.totalMinor,
        orders: (c?.orders ?? 0) + 1,
      );
    }

    int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);
    int average(int total, int count) =>
        count == 0 ? 0 : (total / count).round();
    final salesValue = sum(sales);
    final ordersValue = sum(counts);
    final prevSales = sum(previous.map((o) => o.totalMinor));
    final prevOrders = previous.length;

    String label(tz.TZDateTime t) => range == 'today'
        ? '${t.hour}:00'
        : range == '7d'
        ? _weekdays[t.weekday - 1]
        : '${_months[t.month - 1]} ${t.day}';
    final points = [
      for (var i = 0; i < n; i++)
        {
          'start': starts[i].toUtc().toIso8601String(),
          'label': label(starts[i]),
          'salesMinor': sales[i],
          'orders': counts[i],
        },
    ];

    // The kitchen right now, whatever the range.
    final open = await PurchaseOrder.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) & t.status.inSet(_kitchen.toSet()),
      limit: 500,
      transaction: tx,
    );
    final kitchen = <String, dynamic>{
      for (final k in _kitchen) k: open.where((o) => o.status == k).length,
      'oldestMinutes': open.isEmpty
          ? 0
          : open.map((o) => now.difference(o.createdAt).inMinutes).reduce(max),
    };

    final newest = await PurchaseOrder.db.find(
      s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id.desc(),
      limit: 8,
      transaction: tx,
    );
    final newestContexts = newest.isEmpty
        ? const <OrderContext>[]
        : await OrderContext.db.find(
            s,
            where: (t) => t.orderId.inSet({for (final o in newest) o.id!}),
            transaction: tx,
          );
    final byOrder = {for (final c in newestContexts) c.orderId: c};
    final latest = [
      for (final o in newest)
        {
          'id': o.id,
          'number': byOrder[o.id]?.orderNumber,
          'status': o.status,
          'paymentStatus': o.paymentStatus,
          'fulfillment': o.fulfillment,
          'origin': byOrder[o.id]?.origin ?? 'online',
          'totalMinor': o.totalMinor,
          'currency': o.currency,
          'createdAt': o.createdAt.toIso8601String(),
          'customerLabel': byOrder[o.id]?.customerLabel,
        },
    ];

    final todaySales = range == 'today'
        ? salesValue
        : sum((await paid(midnight, to)).map((o) => o.totalMinor));

    return {
      'range': range,
      'timezone': timezone,
      'currency': w.restaurant!.currency,
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
      'granularity': range == 'today' ? 'hour' : 'day',
      'basis': basis,
      'points': points,
      'kpis': {
        'sales': {'value': salesValue, 'previous': prevSales, 'series': sales},
        'orders': {
          'value': ordersValue,
          'previous': prevOrders,
          'series': counts,
        },
        'averageTicket': {
          'value': average(salesValue, ordersValue),
          'previous': average(prevSales, prevOrders),
          'series': [for (var i = 0; i < n; i++) average(sales[i], counts[i])],
        },
        'tips': {
          'value': sum(tipSeries),
          'previous': sum(prevTips.values),
          'series': tipSeries,
        },
      },
      'channels': [
        for (final e
            in channels.entries.toList()
              ..sort((a, b) => b.value.sales.compareTo(a.value.sales)))
          {
            'channel': e.key,
            'salesMinor': e.value.sales,
            'orders': e.value.orders,
          },
      ],
      'kitchen': kitchen,
      'latest': latest,
      'staff': await _staff(w, from, to),
      'target': {
        'dailyTargetMinor': (w.settings['dailyTargetMinor'] as int?) ?? 0,
        'todayMinor': todaySales,
      },
      'sample': range != 'today' && JudgeModule.sampleHistory(w.tenant)
          ? sample(
              starts,
              label,
              (w.settings['dailyTargetMinor'] as int?) ?? 0,
            )
          : null,
    };
  }

  /// Up to five people: the order changes they made in the window (their
  /// `order.*` audit rows) and the hours they worked. Only members of the
  /// restaurant count, so agents and the system never appear.
  static Future<List<Json>> _staff(Work w, DateTime from, DateTime to) async {
    final s = w.s;
    final tx = w.tx;
    final members = await Membership.db.find(
      s,
      where: (t) => t.restaurantId.equals(w.tenant) & t.active.equals(true),
      transaction: tx,
    );
    final roles = {for (final m in members) m.userId: m.role};
    final audits = roles.isEmpty
        ? const <AuditRecord>[]
        : await AuditRecord.db.find(
            s,
            where: (t) =>
                t.restaurantId.equals(w.tenant) &
                (t.createdAt >= from) &
                (t.createdAt < to) &
                t.kind.like('order.%') &
                t.userId.inSet(roles.keys.toSet()),
            limit: 20000,
            transaction: tx,
          );
    final shifts = await StaffShift.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          (t.startsAt >= from) &
          (t.startsAt < to),
      limit: 5000,
      transaction: tx,
    );
    final userIds = {
      ...audits.map((a) => a.userId),
      ...shifts.map((x) => x.userId).nonNulls,
    };
    final profiles = userIds.isEmpty
        ? const <ActorProfile>[]
        : await ActorProfile.db.find(
            s,
            where: (t) => t.userId.inSet(userIds),
            transaction: tx,
          );
    final names = <String, String>{
      for (final p in profiles)
        if (((_json(p.dataJson)['displayName'] as String?) ?? '')
            .trim()
            .isNotEmpty)
          p.userId: (_json(p.dataJson)['displayName'] as String).trim(),
    };
    // A person is a user id when we have one, else the name on the shift.
    final moved = <String, int>{};
    final minutes = <String, int>{};
    final label = <String, String>{};
    for (final a in audits) {
      moved[a.userId] = (moved[a.userId] ?? 0) + 1;
    }
    for (final x in shifts) {
      final key = x.userId ?? 'shift:${x.name.trim().toLowerCase()}';
      minutes[key] = (minutes[key] ?? 0) + BackOfficeModule.workedMinutes(x);
      label.putIfAbsent(key, () => x.name.trim());
    }
    String nameOf(String key) {
      if (key.startsWith('shift:')) return label[key]!;
      final role = roles[key] ?? 'staff';
      return names[key] ??
          label[key] ??
          '${role[0].toUpperCase()}${role.substring(1)}';
    }

    final people =
        {...moved.keys, ...minutes.keys}
            .map(
              (key) => {
                'name': nameOf(key),
                'ordersMoved': moved[key] ?? 0,
                'hours': ((minutes[key] ?? 0) / 6).round() / 10,
              },
            )
            .toList()
          ..sort((a, b) {
            final byMoved = (b['ordersMoved'] as int).compareTo(
              a['ordersMoved'] as int,
            );
            return byMoved != 0
                ? byMoved
                : (b['hours'] as double).compareTo(a['hours'] as double);
          });
    return people.take(5).toList();
  }

  /// A fixed weekly pattern, labelled and never stored. Each weekday sits
  /// between 40% and 90% of the daily target (or $120–$270 without one),
  /// nudged per week so a month does not repeat exactly, with orders at
  /// about $15 each. It exists only so the judges' café charts have a
  /// café-sized shape; no figure comes from it.
  static Json sample(
    List<tz.TZDateTime> starts,
    String Function(tz.TZDateTime) label,
    int dailyTargetMinor,
  ) {
    // Where each weekday falls between the low and high ends, Mon..Sun.
    const shape = [0.10, 0.20, 0.40, 0.55, 0.80, 1.00, 0.60];
    const nudge = [0.0, -0.05, 0.05, -0.02, 0.03];
    final low = dailyTargetMinor > 0 ? dailyTargetMinor * 0.40 : 12000;
    final high = dailyTargetMinor > 0 ? dailyTargetMinor * 0.90 : 27000;
    return {
      'label': sampleLabel,
      'points': [
        for (var i = 0; i < starts.length; i++)
          () {
            final week = (starts.length - 1 - i) ~/ 7 % nudge.length;
            final at = (shape[starts[i].weekday - 1] + nudge[week]).clamp(
              0.0,
              1.0,
            );
            final sales = (low + (high - low) * at).round();
            return {
              'start': starts[i].toUtc().toIso8601String(),
              'label': label(starts[i]),
              'salesMinor': sales,
              'orders': max(1, (sales / 1500).round()),
            };
          }(),
      ],
    };
  }
}
