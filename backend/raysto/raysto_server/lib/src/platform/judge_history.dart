part of 'platform.dart';

/// The judges' cafés' stored sample history: the 30 local days before today
/// (never today, so a judge's own activity stays clean), as plain rows.
///
/// Each day is counter sales paid in cash at the till (the only way to pay
/// outside PayPal the data model has), with tips on some of them and, now
/// and then, one item refunded in cash; and the day's matching costs: the
/// produce bought from the café's supplier and the team's wages, both paid
/// by bank transfer. Because they are stored, the dashboard, the analytics,
/// the derived ledger, the P&L, the cash flow, the close, the group pages and
/// AG Studio all read the same numbers.
///
/// Nothing here is PayPal: no checkout, capture or refund carries a PayPal
/// id, and no row is ever given one. Every row is marked as a sample in a way
/// code can read: request keys start with `sample:`, a capture's id with
/// `cash:sample:`, a refund's request key with `sample:` (and its reason with
/// "Sample:"), an order's context carries `"sample": true`, and a sample cost
/// is recorded at the very moment it was spent (see [expense]). Payroll never
/// pays a sample tip: those were handed out in cash on the day.
///
/// The rows are inserted directly, never through a command, so nothing they
/// touch audits, notifies, queues a job or wakes an agent. The history is
/// deterministic (seeded by café and day), topped up one missing day at a
/// time by the daily reset, and days older than the window are removed, so
/// a reset never duplicates a day and the row count stays bounded.
class JudgeHistory {
  /// How many local days before today the history covers.
  static const days = 30;

  /// Every sample order, checkout and refund request key starts with this.
  static const keyPrefix = 'sample:';

  /// Who sells the café its produce, and how the team is paid.
  static const produce = 'Marché Dupont';
  static const payroll = 'Team wages (bank transfer)';

  /// The merchants of seeded costs: the history's two, and the two receipts
  /// the judges' seed has always added ("last week's expenses").
  static const _costMerchants = {
    produce,
    payroll,
    'Greenline Cleaning Supplies',
  };

  /// A sample order: a counter sale whose request key says so.
  static bool order(PurchaseOrder o) =>
      OrderingModule.isWalkIn(o.customerId) && o.requestKey.startsWith(keyPrefix);

  /// A sample capture: cash, with a sample id.
  static bool capture(PaymentCapture c) =>
      c.providerCaptureId.startsWith('cash:$keyPrefix');

  /// A sample refund: made by the history, never by a person.
  static bool refund(PaymentRefund r) => r.requestKey.startsWith(keyPrefix);

  /// A seeded cost: on a judges' café, from a seeded merchant, with no
  /// receipt, no agent task and no PayPal id, and recorded at the very
  /// moment it was spent (anything a person or an agent records is always
  /// recorded after it).
  static bool expense(Expense e) =>
      JudgeModule.venue(e.restaurantId) &&
      _costMerchants.contains(e.merchant) &&
      e.mediaId == null &&
      e.taskId == null &&
      e.paypalTransactionId == null &&
      e.createdAt.isAtSameMomentAs(e.spentAt);

  /// Each café's business. The first is the busy one with Nadia, Omar and
  /// Lina (the team the seed puts on this week's shifts, at the same rates,
  /// eight hours each); the second, by the harbour, is quieter, with two.
  static const first = HistoryProfile(
    key: 'atelier',
    ordersPerWeekday: 49.5,
    team: 'Nadia, Omar and Lina',
    wagesMinor: 8 * 1600 + 8 * 1800 + 8 * 2200,
    produceShare: 0.30,
  );
  static const second = HistoryProfile(
    key: 'harbour',
    ordersPerWeekday: 29.8,
    team: 'two staff',
    wagesMinor: 8 * 1600 + 7 * 1800,
    produceShare: 0.30,
  );

  /// Orders by weekday, Monday to Sunday: a quiet Tuesday, busy weekends.
  static const _weekday = [1.0, 0.82, 1.0, 1.05, 1.18, 1.42, 1.30];

  /// When orders come in, by local hour: breakfast, a lunch peak and a
  /// dinner peak on weekdays; a later, longer brunch at weekends.
  static const _weekdayHours = {
    7: 0.5, 8: 1.2, 9: 1.0, 10: 0.6, 11: 0.8, 12: 1.9, 13: 1.7, //
    14: 0.7, 15: 0.5, 16: 0.5, 17: 0.6, 18: 1.2, 19: 1.4, 20: 0.8,
  };
  static const _weekendHours = {
    8: 0.6, 9: 1.2, 10: 1.4, 11: 1.4, 12: 1.6, 13: 1.4, 14: 0.8, //
    15: 0.6, 16: 0.5, 17: 0.6, 18: 1.1, 19: 1.3, 20: 0.7,
  };

  /// What one person orders at each time of day, by dish name.
  static const _pastries = {
    'Butter croissant': 0.45,
    'Pain au chocolat': 0.30,
    'Granola bowl': 0.25,
  };
  static const _lunch = {
    'Chicken club': 0.25,
    'Croque monsieur': 0.25,
    'Falafel wrap': 0.20,
    'Quiche lorraine & green salad': 0.20,
    'Mushroom risotto': 0.10,
  };
  static const _dinner = {
    'Mushroom risotto': 0.35,
    'Quiche lorraine & green salad': 0.30,
    'Chicken club': 0.15,
    'Croque monsieur': 0.10,
    'Falafel wrap': 0.10,
  };
  static const _morningDrinks = {
    'Cappuccino': 0.55,
    'Espresso': 0.25,
    'Fresh orange juice': 0.20,
  };
  static const _mealDrinks = {
    'Fresh orange juice': 0.38,
    'Espresso': 0.34,
    'Cappuccino': 0.28,
  };

  /// How likely a person takes the dish's one option.
  static const _optionRate = {'Croque monsieur': 0.30, 'Cappuccino': 0.25};

  static const _refundReasons = [
    'Sample: a cold drink, refunded at the counter',
    'Sample: the wrong pastry was handed over, refunded at the counter',
    'Sample: one item was missing from the bag, refunded at the counter',
  ];

  /// The day's sample sales and costs, worked out without touching the
  /// database. The same café, day and menu always give the same result.
  static HistoryDay plan({
    required HistoryProfile profile,
    required String day,
    required tz.Location zone,
    required Map<String, HistoryDish> menu,
    int taxBps = 0,
    bool pricesIncludeTax = true,
  }) {
    final parts = day.split('-').map(int.parse).toList();
    final date = tz.TZDateTime(zone, parts[0], parts[1], parts[2]);
    final weekend = date.weekday >= DateTime.saturday;
    final rng = Random(_seed('${profile.key}:$day'));
    final count = (profile.ordersPerWeekday *
            _weekday[date.weekday - 1] *
            (0.95 + 0.10 * rng.nextDouble()))
        .round();
    final hours = weekend ? _weekendHours : _weekdayHours;

    String? pick(Map<String, double> weights) {
      final live = {
        for (final e in weights.entries)
          if (menu.containsKey(e.key)) e.key: e.value,
      };
      if (live.isEmpty) return null;
      final total = live.values.fold<double>(0, (a, b) => a + b);
      var r = rng.nextDouble() * total;
      for (final e in live.entries) {
        r -= e.value;
        if (r < 0) return e.key;
      }
      return live.keys.last;
    }

    int party(List<double> weights) {
      final total = weights.fold<double>(0, (a, b) => a + b);
      var r = rng.nextDouble() * total;
      for (var i = 0; i < weights.length; i++) {
        r -= weights[i];
        if (r < 0) return i + 1;
      }
      return weights.length;
    }

    final times = <tz.TZDateTime>[];
    final hourTotal = hours.values.fold<double>(0, (a, b) => a + b);
    for (var i = 0; i < count; i++) {
      var r = rng.nextDouble() * hourTotal;
      var hour = hours.keys.last;
      for (final e in hours.entries) {
        r -= e.value;
        if (r < 0) {
          hour = e.key;
          break;
        }
      }
      times.add(
        tz.TZDateTime(
          zone,
          date.year,
          date.month,
          date.day,
          hour,
          rng.nextInt(60),
          rng.nextInt(60),
        ),
      );
    }
    times.sort();

    final sales = <HistorySale>[];
    var foodMinor = 0;
    for (final (i, at) in times.indexed) {
      final hour = at.hour;
      // dish name and option → quantity, in the order first chosen.
      final basket = <(String, bool), int>{};
      void add(String? name) {
        if (name == null) return;
        final option =
            menu[name]!.option != null &&
            rng.nextDouble() < (_optionRate[name] ?? 0);
        basket[(name, option)] = (basket[(name, option)] ?? 0) + 1;
      }

      if (hour < 11) {
        for (var p = party([0.50, 0.38, 0.12]); p > 0; p--) {
          add(pick(_morningDrinks));
          if (rng.nextDouble() < 0.85) add(pick(_pastries));
        }
      } else if (hour < 15) {
        for (var p = party([0.40, 0.42, 0.12, 0.06]); p > 0; p--) {
          add(pick(_lunch));
          if (rng.nextDouble() < 0.80) add(pick(_mealDrinks));
          if (rng.nextDouble() < 0.10) add(pick(_pastries));
        }
      } else if (hour < 17) {
        for (var p = party([0.70, 0.30]); p > 0; p--) {
          add(pick(_morningDrinks));
          if (rng.nextDouble() < 0.60) add(pick(_pastries));
        }
      } else {
        for (var p = party([0.33, 0.47, 0.13, 0.07]); p > 0; p--) {
          add(pick(_dinner));
          if (rng.nextDouble() < 0.75) add(pick(_mealDrinks));
        }
      }
      if (basket.isEmpty) continue;

      final lines = <HistoryLine>[];
      for (final MapEntry(key: (name, option), value: quantity)
          in basket.entries) {
        final dish = menu[name]!;
        lines.add(
          HistoryLine(
            dish: dish,
            withOption: option,
            quantity: quantity,
            unitPriceMinor:
                dish.priceMinor + (option ? dish.option!.priceMinor : 0),
          ),
        );
      }
      // Units as an order's charges are made: one per item, tax inside or
      // on top as the café's settings say.
      final units = <HistoryUnit>[];
      var subtotal = 0, tax = 0, food = 0;
      for (final (l, line) in lines.indexed) {
        subtotal += line.unitPriceMinor * line.quantity;
        for (var u = 0; u < line.quantity; u++) {
          final price = line.unitPriceMinor;
          final net = pricesIncludeTax
              ? (price * 10000 + (10000 + taxBps) ~/ 2) ~/ (10000 + taxBps)
              : price;
          final unitTax = pricesIncludeTax
              ? price - net
              : (net * taxBps + 5000) ~/ 10000;
          units.add(
            HistoryUnit('l$l:u$u', 'food', net + unitTax, net),
          );
          tax += unitTax;
          food += net + unitTax;
        }
      }
      // A quarter of diners leave a tip in the jar: 10–18%, to the quarter.
      var tip = 0;
      if (rng.nextDouble() < 0.25) {
        tip = max(50, ((food * (0.10 + 0.08 * rng.nextDouble())) / 25).round() * 25);
        units.add(HistoryUnit('tip', 'tip', tip, 0));
      }
      // Now and then one item goes back: never a whole order.
      int? refunded;
      String? reason;
      final foodUnits = units.where((u) => u.kind == 'food').length;
      if (foodUnits >= 2 && rng.nextDouble() < 0.007) {
        var cheapest = 0;
        for (var u = 1; u < foodUnits; u++) {
          if (units[u].amountMinor < units[cheapest].amountMinor) cheapest = u;
        }
        refunded = cheapest;
        reason = _refundReasons[rng.nextInt(_refundReasons.length)];
      }
      foodMinor += food;
      sales.add(
        HistorySale(
          number: i + 1,
          at: _utc(at),
          paidAfter: Duration(seconds: 40 + rng.nextInt(180)),
          completedAfter: Duration(minutes: 12 + rng.nextInt(20)),
          lines: lines,
          units: units,
          subtotalMinor: subtotal,
          taxMinor: tax,
          tipMinor: tip,
          refundedUnit: refunded,
          refundReason: reason,
        ),
      );
    }
    // The produce for the day, bought at 6:40 from the café's supplier; the
    // team's wages for the day, paid by bank transfer at 21:30.
    final costs = Random(_seed('${profile.key}:$day:costs'));
    return HistoryDay(
      day: day,
      sales: sales,
      produceMinor:
          (foodMinor * profile.produceShare * (0.94 + 0.12 * costs.nextDouble()))
              .round(),
      produceAt: _utc(tz.TZDateTime(zone, date.year, date.month, date.day, 6, 40)),
      wagesMinor: profile.wagesMinor,
      wagesAt: _utc(tz.TZDateTime(zone, date.year, date.month, date.day, 21, 30)),
    );
  }

  /// A plain UTC instant (a zoned time is not a DateTime to the driver).
  static DateTime _utc(DateTime t) =>
      DateTime.fromMicrosecondsSinceEpoch(t.microsecondsSinceEpoch, isUtc: true);

  /// FNV-1a: a stable seed from text, the same on every machine.
  static int _seed(String text) {
    var h = 0x811c9dc5;
    for (final c in utf8.encode(text)) {
      h = ((h ^ c) * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  /// The local days of the window, oldest first, and its first instant.
  static (List<String>, DateTime) window(tz.Location zone, DateTime now) {
    final local = tz.TZDateTime.from(now, zone);
    String day(tz.TZDateTime t) =>
        '${t.year.toString().padLeft(4, '0')}-'
        '${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
    return (
      [
        for (var i = days; i >= 1; i--)
          day(tz.TZDateTime(zone, local.year, local.month, local.day - i)),
      ],
      _utc(tz.TZDateTime(zone, local.year, local.month, local.day - days)),
    );
  }

  /// The café's dishes by name, at the prices of its current menu.
  static Future<Map<String, HistoryDish>> _menu(Work w) async {
    final definitions = {
      for (final d in await MenuDefinition.db.find(
        w.s,
        where: (t) => t.restaurantId.equals(w.tenant) & t.archived.equals(false),
        transaction: w.tx,
      ))
        d.productId,
    };
    final options = {
      for (final dish in JudgeModule.menu)
        if (dish['modifiers'] is List)
          (dish['name'] as String).toLowerCase():
              ((dish['modifiers'] as List).first as Json)['options'][0] as Json,
    };
    final out = <String, HistoryDish>{};
    for (final p in await MenuProduct.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant),
      orderBy: (t) => t.id,
      transaction: w.tx,
    )) {
      if (!definitions.contains(p.id) || !p.available) continue;
      final option = options[p.name.toLowerCase()];
      out.putIfAbsent(
        p.name,
        () => HistoryDish(
          productId: p.id!,
          productVersion: p.version,
          name: p.name,
          priceMinor: p.priceMinor,
          option: option == null
              ? null
              : HistoryOption(
                  option['name'] as String,
                  option['priceMinor'] as int,
                ),
        ),
      );
    }
    return out;
  }

  /// On unless `RAYSTO_JUDGE_HISTORY=off`: then a reset neither adds nor
  /// removes history (integration tests that do not need a month of rows
  /// switch it off to stay quick).
  static bool get enabled =>
      ProviderClients.environment()['RAYSTO_JUDGE_HISTORY'] != 'off';

  /// Brings the café's history up to date: removes days that left the
  /// window, then adds each missing day's sales and costs. Run by the full
  /// daily reset after the menu is restored, inside its transaction.
  static Future<Json> seed(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    await _receipts(w);
    if (!enabled) {
      return {'days': 0, 'orders': 0, 'expenses': 0, 'pruned': 0, 'off': true};
    }
    final profile = rid == JudgeModule.secondRestaurantId ? second : first;
    final zone = CatalogueModule.zone(w.settings['timezone'] as String);
    final (window, start) = JudgeHistory.window(zone, _now());
    final walkIn = OrderingModule.walkIn(rid);
    final pruned = await _prune(w, start);

    final have = {
      for (final r in await s.db.unsafeQuery(
        '''SELECT DISTINCT split_part("requestKey", ':', 3) FROM raysto_order
           WHERE "restaurantId"=@tenant AND "customerId"=@walkIn
             AND "requestKey" LIKE 'sample:%' AND "createdAt">=@start''',
        parameters: QueryParameters.named({
          'tenant': rid,
          'walkIn': walkIn,
          'start': start,
        }),
        transaction: w.tx,
      ))
        '${r[0]}',
    };
    final menu = await _menu(w);
    if (menu.isEmpty) return {'days': 0, 'orders': 0, 'expenses': 0, 'pruned': pruned};
    final taxBps = (w.settings['taxBps'] as int?) ?? 0;
    final inclusive = w.settings['pricesIncludeTax'] != false;
    final plans = [
      for (final day in window)
        plan(
          profile: profile,
          day: day,
          zone: zone,
          menu: menu,
          taxBps: taxBps,
          pricesIncludeTax: inclusive,
        ),
    ];
    final missing = plans.where((p) => !have.contains(p.day)).toList();
    final owner = await JudgeModule._owner(w);
    final orders = missing.isEmpty
        ? 0
        : await _insert(w, missing, owner: owner, walkIn: walkIn);
    final expenses = await _costs(w, plans, start);
    return {
      'days': missing.length,
      'orders': orders,
      'expenses': expenses,
      'pruned': pruned,
    };
  }

  /// Inserts the sales of the missing days: each order with its context,
  /// its charges (one per item, plus the tip), a cash checkout that settled
  /// them, the cash capture and, for the odd returned item, the cash refund.
  /// One set-based statement per table (a month is thousands of rows), each
  /// row found again by its sample request key.
  static Future<int> _insert(
    Work w,
    List<HistoryDay> days, {
    required String owner,
    required String walkIn,
  }) async {
    final s = w.s;
    final tx = w.tx;
    final rid = w.tenant;
    final currency = w.restaurant!.currency;
    // Numbers carry on after any real order of the same day.
    final numbered = await OrderContext.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.serviceDay.inSet(<String>{for (final d in days) d.day}) &
          t.orderNumber.notEquals(null),
      transaction: tx,
    );
    final last = <String, int>{};
    for (final c in numbered) {
      last[c.serviceDay!] = max(last[c.serviceDay!] ?? 0, c.orderNumber!);
    }
    String key(HistoryDay d, HistorySale x) =>
        '$keyPrefix$rid:${d.day}:${x.number.toString().padLeft(3, '0')}';
    final all = [
      for (final d in days)
        for (final x in d.sales) (d, x),
    ];
    if (all.isEmpty) return 0;
    final keys = [for (final (d, x) in all) key(d, x)];
    final paidAt = [for (final (_, x) in all) x.at.add(x.paidAfter)];
    final units = [
      for (final (i, (_, x)) in all.indexed)
        for (final (u, unit) in x.units.indexed)
          (key: keys[i], unit: unit, refunded: x.refundedUnit == u ? unit.amountMinor : 0),
    ];
    final refunds = [
      for (final (i, (_, x)) in all.indexed)
        if (x.refundedUnit != null) (key: keys[i], sale: x),
    ];
    Future<int> run(String sql, Map<String, Object?> values) =>
        s.db.unsafeExecute(
          sql,
          parameters: QueryParameters.named({
            for (final e in {
              'rid': rid,
              'walkIn': walkIn,
              'owner': owner,
              'currency': currency,
            }.entries)
              if (RegExp('@${e.key}\\b').hasMatch(sql)) e.key: e.value,
            ...values,
          }),
          transaction: tx,
        );
    // The order rows a statement attaches to, by their sample key.
    const order = '''JOIN raysto_order o ON o."restaurantId"=@rid
           AND o."customerId"=@walkIn AND o."requestKey"=x.k''';
    const checkout = '''JOIN raysto_checkout_intent i ON i."restaurantId"=@rid
           AND i."userId"=@owner AND i."requestKey"=x.k''';

    final inserted = await run(
      '''INSERT INTO raysto_order ("restaurantId", "customerId", "requestKey",
           "requestHash", "fulfillment", "lines", "currency", "subtotalMinor",
           "deliveryFeeMinor", "totalMinor", "status", "paymentStatus",
           "version", "createdAt", "updatedAt")
         SELECT @rid, @walkIn, x.k, x.h, 'pickup', x.l::json, @currency, x.sub,
           0, x.tot, 'completed', x.ps, 1, x.ca, x.ua
         FROM unnest(@k::text[], @h::text[], @l::text[], @sub::bigint[],
           @tot::bigint[], @ps::text[], @ca::timestamp[], @ua::timestamp[])
           AS x(k, h, l, sub, tot, ps, ca, ua)''',
      {
        'k': keys,
        'h': [for (final k in keys) _hash(k)],
        'l': [
          for (final (_, x) in all)
            jsonEncode([
              for (final l in x.lines)
                OrderLine(
                  productId: l.dish.productId,
                  name: l.dish.name,
                  quantity: l.quantity,
                  unitPriceMinor: l.unitPriceMinor,
                ).toJson(),
            ]),
        ],
        'sub': [for (final (_, x) in all) x.subtotalMinor],
        'tot': [for (final (_, x) in all) x.totalMinor],
        'ps': [
          for (final (_, x) in all)
            x.refundedUnit == null ? 'paid' : 'partiallyRefunded',
        ],
        'ca': [for (final (_, x) in all) x.at],
        'ua': [for (final (_, x) in all) x.at.add(x.completedAfter)],
      },
    );
    await run(
      '''INSERT INTO raysto_order_context ("restaurantId", "orderId",
           "detailsJson", "paymentTiming", "cancellationRequested",
           "stockReleased", "origin", "serviceDay", "orderNumber", "createdAt")
         SELECT @rid, o.id, x.d, 'before', false, false, 'counter', x.sd, x.n,
           x.ca
         FROM unnest(@k::text[], @d::text[], @sd::text[], @n::bigint[],
           @ca::timestamp[]) AS x(k, d, sd, n, ca)
         $order''',
      {
        'k': keys,
        'd': [
          for (final (_, x) in all)
            jsonEncode({
              'sample': true,
              'note': 'Sample counter sale, paid in cash',
              'fulfillment': 'pickup',
              'lines': [
                for (final (i, l) in x.lines.indexed)
                  {
                    'lineKey': 'l$i',
                    'productId': l.dish.productId,
                    'productVersion': l.dish.productVersion,
                    'name': l.dish.name,
                    'quantity': l.quantity,
                    'unitPriceMinor': l.unitPriceMinor,
                    'options': [
                      if (l.withOption)
                        {
                          'id': 'options:o0',
                          'name': l.dish.option!.name,
                          'priceMinor': l.dish.option!.priceMinor,
                        },
                    ],
                    'note': null,
                  },
              ],
              'charges': [
                for (final u in x.units)
                  {
                    'lineKey': u.lineKey,
                    'kind': u.kind,
                    'amountMinor': u.amountMinor,
                    'foodNetMinor': u.foodNetMinor,
                  },
              ],
              'subtotalMinor': x.subtotalMinor,
              'discountMinor': 0,
              'taxMinor': x.taxMinor,
              'deliveryFeeMinor': 0,
              'tipMinor': x.tipMinor,
              'totalMinor': x.totalMinor,
              'currency': currency,
              'paymentTiming': 'before',
              'origin': 'counter',
            }),
        ],
        'sd': [for (final (d, _) in all) d.day],
        'n': [for (final (d, x) in all) (last[d.day] ?? 0) + x.number],
        'ca': [for (final (_, x) in all) x.at],
      },
    );
    await run(
      '''INSERT INTO raysto_bill_charge ("restaurantId", "orderId", "lineKey",
           "kind", "amountMinor", "creditedMinor", "settledMinor",
           "reservedMinor", "foodNetMinor", "version")
         SELECT @rid, o.id, x.lk, x.kind, x.amt, x.cr, x.amt - x.cr, 0, x.net, 1
         FROM unnest(@k::text[], @lk::text[], @kind::text[], @amt::bigint[],
           @cr::bigint[], @net::bigint[]) AS x(k, lk, kind, amt, cr, net)
         $order''',
      {
        'k': [for (final u in units) u.key],
        'lk': [for (final u in units) u.unit.lineKey],
        'kind': [for (final u in units) u.unit.kind],
        'amt': [for (final u in units) u.unit.amountMinor],
        'cr': [for (final u in units) u.refunded],
        'net': [for (final u in units) u.unit.foodNetMinor],
      },
    );
    // Rung up by the café's owner at the till: a cash checkout, settled.
    await run(
      '''INSERT INTO raysto_checkout_intent ("restaurantId", "userId", "orderId",
           "requestKey", "requestHash", "providerRequestId", "merchantId",
           "providerMode", "state", "method", "currency", "amountMinor",
           "commissionMinor", "commissionBps", "createdAt", "updatedAt")
         SELECT @rid, @owner, o.id, x.k, x.h, x.k, 'cash', 'marketplace',
           'completed', 'cash', @currency, x.tot, 0, 0, x.ca, x.ca
         FROM unnest(@k::text[], @h::text[], @tot::bigint[], @ca::timestamp[])
           AS x(k, h, tot, ca)
         $order''',
      {
        'k': keys,
        'h': [for (final k in keys) _hash(k)],
        'tot': [for (final (_, x) in all) x.totalMinor],
        'ca': paidAt,
      },
    );
    await run(
      '''INSERT INTO raysto_payment_allocation ("restaurantId", "checkoutId",
           "chargeId", "amountMinor", "foodNetMinor", "refundedMinor", "state")
         SELECT @rid, i.id, b.id, x.amt, x.net, x.rf, 'settled'
         FROM unnest(@k::text[], @lk::text[], @amt::bigint[], @net::bigint[],
           @rf::bigint[]) AS x(k, lk, amt, net, rf)
         $order
         $checkout AND i."orderId"=o.id
         JOIN raysto_bill_charge b ON b."orderId"=o.id AND b."lineKey"=x.lk''',
      {
        'k': [for (final u in units) u.key],
        'lk': [for (final u in units) u.unit.lineKey],
        'amt': [for (final u in units) u.unit.amountMinor],
        'net': [for (final u in units) u.unit.foodNetMinor],
        'rf': [for (final u in units) u.refunded],
      },
    );
    await run(
      '''INSERT INTO raysto_payment_capture ("restaurantId", "checkoutId",
           "providerCaptureId", "amountMinor", "refundedMinor", "currency",
           "state", "createdAt")
         SELECT @rid, i.id, 'cash:' || x.k, x.tot, x.rf, @currency,
           'completed', x.ca
         FROM unnest(@k::text[], @tot::bigint[], @rf::bigint[],
           @ca::timestamp[]) AS x(k, tot, rf, ca)
         $checkout''',
      {
        'k': keys,
        'tot': [for (final (_, x) in all) x.totalMinor],
        'rf': [for (final (_, x) in all) x.refundMinor],
        'ca': paidAt,
      },
    );
    if (refunds.isNotEmpty) {
      await run(
        '''INSERT INTO raysto_payment_refund ("restaurantId", "captureId",
             "requestKey", "providerRefundId", "allocationJson", "amountMinor",
             "commissionMinor", "reason", "state", "createdBy", "createdAt",
             "updatedAt")
           SELECT @rid, p.id, x.k || ':refund', 'cash-refund:' || x.k,
             json_build_object('allocations', json_build_array(
               json_build_object('id', a.id, 'amount', x.amt)))::text,
             x.amt, 0, x.reason, 'completed', @owner, x.at, x.at
           FROM unnest(@k::text[], @lk::text[], @amt::bigint[], @reason::text[],
             @at::timestamp[]) AS x(k, lk, amt, reason, at)
           $order
           $checkout AND i."orderId"=o.id
           JOIN raysto_payment_capture p ON p."checkoutId"=i.id
           JOIN raysto_bill_charge b ON b."orderId"=o.id AND b."lineKey"=x.lk
           JOIN raysto_payment_allocation a ON a."checkoutId"=i.id
             AND a."chargeId"=b.id''',
        {
          'k': [for (final r in refunds) r.key],
          'lk': [
            for (final r in refunds) r.sale.units[r.sale.refundedUnit!].lineKey,
          ],
          'amt': [for (final r in refunds) r.sale.refundMinor],
          'reason': [for (final r in refunds) r.sale.refundReason!],
          'at': [
            for (final r in refunds)
              r.sale.at
                  .add(r.sale.completedAfter)
                  .add(const Duration(minutes: 5)),
          ],
        },
      );
    }
    return inserted;
  }

  /// Marks the seed's two older receipts ("last week's expenses") as
  /// samples, the way every seeded cost is marked, and takes back the PayPal
  /// id one of them was once given: it was never a PayPal transaction.
  static Future<void> _receipts(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    final legacy = await Expense.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.mediaId.equals(null) &
          t.taskId.equals(null) &
          ((t.merchant.equals(produce) &
                  t.category.equals('food') &
                  t.amountMinor.equals(47980)) |
              (t.merchant.equals('Greenline Cleaning Supplies') &
                  t.category.equals('other') &
                  t.amountMinor.equals(7956))),
      transaction: w.tx,
    );
    for (final e in legacy) {
      if (e.createdAt.isAtSameMomentAs(e.spentAt) &&
          e.paypalTransactionId == null) {
        continue;
      }
      e
        ..createdAt = e.spentAt
        ..paypalTransactionId = null;
      await Expense.db.updateRow(s, e, transaction: w.tx);
    }
  }

  /// The window's costs: each day's produce and wages, added when missing.
  static Future<int> _costs(
    Work w,
    List<HistoryDay> plans,
    DateTime start,
  ) async {
    final s = w.s;
    final rid = w.tenant;
    final existing = {
      for (final e in await Expense.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(rid) &
            (t.spentAt >= start) &
            t.merchant.inSet({produce, payroll}),
        transaction: w.tx,
      ))
        if (expense(e)) '${e.merchant}@${e.spentAt.microsecondsSinceEpoch}',
    };
    final currency = w.restaurant!.currency;
    final rows = <Expense>[];
    for (final p in plans) {
      for (final (merchant, category, amount, at) in [
        (produce, 'food', p.produceMinor, p.produceAt),
        (payroll, 'staff', p.wagesMinor, p.wagesAt),
      ]) {
        if (amount <= 0 ||
            existing.contains('$merchant@${at.microsecondsSinceEpoch}')) {
          continue;
        }
        rows.add(
          Expense(
            restaurantId: rid,
            category: category,
            amountMinor: amount,
            currency: currency,
            vatMinor: 0,
            spentAt: at,
            merchant: merchant,
            createdAt: at,
          ),
        );
      }
    }
    if (rows.isNotEmpty) await Expense.db.insert(s, rows, transaction: w.tx);
    return rows.length;
  }

  /// Removes sample days that left the window: their orders and everything
  /// hanging off them, and their costs. An order something real points at
  /// (a complaint, a review, a room, a PayPal checkout, a refund a person
  /// made, a commission or a payment exception) is left alone.
  static Future<int> _prune(Work w, DateTime start) async {
    final s = w.s;
    final rid = w.tenant;
    final rows = await s.db.unsafeQuery(
      '''SELECT o.id FROM raysto_order o
         WHERE o."restaurantId"=@tenant AND o."customerId"=@walkIn
           AND o."requestKey" LIKE 'sample:%' AND o."createdAt"<@start
           AND NOT EXISTS (SELECT 1 FROM raysto_complaint x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_conversation_room x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_customer_review x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_delivery_assignment x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_kitchen_progress x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_outbox x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_payment_attempt x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_payment_receipt x WHERE x."orderId"=o.id)
           AND NOT EXISTS (SELECT 1 FROM raysto_service_request x WHERE x."orderId"=o.id)
           AND NOT EXISTS (
             SELECT 1 FROM raysto_checkout_intent i
             WHERE i."orderId"=o.id AND i."requestKey" NOT LIKE 'sample:%')
           AND NOT EXISTS (
             SELECT 1 FROM raysto_checkout_intent i
             JOIN raysto_payment_capture p ON p."checkoutId"=i.id
             WHERE i."orderId"=o.id AND (
               EXISTS (SELECT 1 FROM raysto_commission_entry x WHERE x."captureId"=p.id)
               OR EXISTS (SELECT 1 FROM raysto_payment_exception x WHERE x."captureId"=p.id)
               OR EXISTS (SELECT 1 FROM raysto_payment_refund x
                          WHERE x."captureId"=p.id AND x."requestKey" NOT LIKE 'sample:%')))
         LIMIT 5000''',
      parameters: QueryParameters.named({
        'tenant': rid,
        'walkIn': OrderingModule.walkIn(rid),
        'start': start,
      }),
      transaction: w.tx,
    );
    final ids = [for (final r in rows) r[0] as int];
    if (ids.isNotEmpty) {
      final p = QueryParameters.named({'ids': ids});
      for (final sql in [
        '''DELETE FROM raysto_payment_refund WHERE "captureId" IN (
             SELECT p.id FROM raysto_payment_capture p
             JOIN raysto_checkout_intent i ON i.id=p."checkoutId"
             WHERE i."orderId" = ANY(@ids))''',
        '''DELETE FROM raysto_payment_capture WHERE "checkoutId" IN (
             SELECT id FROM raysto_checkout_intent WHERE "orderId" = ANY(@ids))''',
        '''DELETE FROM raysto_payment_allocation WHERE "checkoutId" IN (
             SELECT id FROM raysto_checkout_intent WHERE "orderId" = ANY(@ids))''',
        'DELETE FROM raysto_checkout_intent WHERE "orderId" = ANY(@ids)',
        'DELETE FROM raysto_bill_charge WHERE "orderId" = ANY(@ids)',
        'DELETE FROM raysto_order_context WHERE "orderId" = ANY(@ids)',
        'DELETE FROM raysto_order WHERE id = ANY(@ids)',
      ]) {
        await s.db.unsafeExecute(sql, parameters: p, transaction: w.tx);
      }
    }
    final old = [
      for (final e in await Expense.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(rid) &
            (t.spentAt < start) &
            t.merchant.inSet({produce, payroll}),
        transaction: w.tx,
      ))
        if (expense(e)) e.id!,
    ];
    if (old.isNotEmpty) {
      await Expense.db.deleteWhere(
        s,
        where: (t) => t.id.inSet(old.toSet()),
        transaction: w.tx,
      );
    }
    return ids.length;
  }
}

/// One café's sample business.
class HistoryProfile {
  const HistoryProfile({
    required this.key,
    required this.ordersPerWeekday,
    required this.team,
    required this.wagesMinor,
    required this.produceShare,
  });

  /// Seeds the café's randomness, so its days never match the other's.
  final String key;

  /// Orders on a plain Monday; other days scale from it.
  final double ordersPerWeekday;

  /// Who the day's wages are for, and what they come to.
  final String team;
  final int wagesMinor;

  /// The day's produce as a share of its food sales.
  final double produceShare;
}

class HistoryOption {
  const HistoryOption(this.name, this.priceMinor);
  final String name;
  final int priceMinor;
}

class HistoryDish {
  const HistoryDish({
    required this.productId,
    required this.productVersion,
    required this.name,
    required this.priceMinor,
    this.option,
  });
  final int productId;
  final int productVersion;
  final String name;
  final int priceMinor;
  final HistoryOption? option;
}

class HistoryLine {
  const HistoryLine({
    required this.dish,
    required this.withOption,
    required this.quantity,
    required this.unitPriceMinor,
  });
  final HistoryDish dish;
  final bool withOption;
  final int quantity;
  final int unitPriceMinor;
}

class HistoryUnit {
  const HistoryUnit(this.lineKey, this.kind, this.amountMinor, this.foodNetMinor);
  final String lineKey;
  final String kind;
  final int amountMinor;
  final int foodNetMinor;
}

class HistorySale {
  const HistorySale({
    required this.number,
    required this.at,
    required this.paidAfter,
    required this.completedAfter,
    required this.lines,
    required this.units,
    required this.subtotalMinor,
    required this.taxMinor,
    required this.tipMinor,
    this.refundedUnit,
    this.refundReason,
  });
  final int number;
  final DateTime at;
  final Duration paidAfter;
  final Duration completedAfter;
  final List<HistoryLine> lines;
  final List<HistoryUnit> units;
  final int subtotalMinor;
  final int taxMinor;
  final int tipMinor;
  final int? refundedUnit;
  final String? refundReason;

  int get foodMinor => units
      .where((u) => u.kind == 'food')
      .fold<int>(0, (n, u) => n + u.amountMinor);
  int get totalMinor => foodMinor + tipMinor;
  int get refundMinor => refundedUnit == null ? 0 : units[refundedUnit!].amountMinor;
}

class HistoryDay {
  const HistoryDay({
    required this.day,
    required this.sales,
    required this.produceMinor,
    required this.produceAt,
    required this.wagesMinor,
    required this.wagesAt,
  });
  final String day;
  final List<HistorySale> sales;
  final int produceMinor;
  final DateTime produceAt;
  final int wagesMinor;
  final DateTime wagesAt;
}
