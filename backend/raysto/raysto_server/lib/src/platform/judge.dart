part of 'platform.dart';

/// The judges' café: a Sandbox restaurant whose manager login is published
/// for the hackathon judges. Its name, opening and team stay with its owner,
/// and once a day it returns to the same menu and settings: older orders are
/// closed, abandoned PayPal checkouts released and stale proposals expired.
class JudgeModule {
  static const name = 'Atelier Café · Judges';

  static int? get restaurantId => int.tryParse(
    ProviderClients.environment()['RAYSTO_JUDGE_RESTAURANT_ID'] ?? '',
  );

  static bool venue(int? tenant) => tenant != null && tenant == restaurantId;

  /// Refuses a change to the judges' café that only its owner may make.
  static Future<void> ownerOnly(Work w) async {
    if (!venue(w.tenant)) return;
    final m = await Membership.db.findFirstRow(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant) & t.userId.equals(w.user),
      transaction: w.tx,
    );
    if (m == null || !m.active || m.role != 'owner') {
      _fail('forbidden', 'This stays fixed on the judges’ café.');
    }
  }

  /// The settings the café returns to. Open all day for judges in any zone.
  /// Its contact email stays as the owner set it.
  static final settings = <String, dynamic>{
    'address': 'PayPal Sandbox demo for hackathon judges · not a real café',
    'timezone': 'America/New_York',
    'country': 'US',
    'languages': ['en', 'fr', 'ar'],
    'modes': ['pickup'],
    'hours': [
      for (var day = 1; day <= 7; day++) {'day': day, 'start': 0, 'end': 1440},
    ],
    'holidays': [],
    'paused': false,
    'guestOrdering': false,
    'paymentTiming': 'before',
    'autoAcceptPaid': true,
    'preparationMinutes': 15,
    'slotMinutes': 15,
    'slotCapacity': 20,
    'taxConfigured': true,
    'taxBps': 0,
    'pricesIncludeTax': true,
    'agents': {},
    'menuCategories': [
      {
        'name': 'Breakfast',
        'translations': {'fr': 'Petit-déjeuner', 'ar': 'الفطور'},
      },
      {
        'name': 'Sandwiches',
        'translations': {'fr': 'Sandwichs', 'ar': 'السندويشات'},
      },
      {
        'name': 'Plates',
        'translations': {'fr': 'Assiettes', 'ar': 'الأطباق'},
      },
      {
        'name': 'Drinks',
        'translations': {'fr': 'Boissons', 'ar': 'المشروبات'},
      },
    ],
  };

  static Json _dish(
    String category,
    String name,
    int priceMinor, {
    String description = '',
    List<String> dietary = const [],
    required Json fr,
    required Json ar,
    Json? option,
  }) => {
    'name': name,
    'description': description,
    'category': category,
    'priceMinor': priceMinor,
    'available': true,
    'dietary': dietary,
    'translations': {'fr': fr, 'ar': ar},
    if (option != null)
      'modifiers': [
        {
          'id': 'options',
          'name': 'Options',
          'min': 0,
          'max': 1,
          'options': [
            {...option, 'id': 'o0', 'available': true},
          ],
        },
      ],
  };

  /// The starting menu: the sample menu photo without its soup and sweets,
  /// and with last season's cappuccino price, so reading the photo has
  /// something to add and something to update.
  static final menu = <Json>[
    _dish(
      'Breakfast',
      'Butter croissant',
      220,
      fr: {'name': 'Croissant au beurre'},
      ar: {'name': 'كرواسون بالزبدة'},
    ),
    _dish(
      'Breakfast',
      'Pain au chocolat',
      240,
      fr: {'name': 'Pain au chocolat'},
      ar: {'name': 'خبز بالشوكولاتة'},
    ),
    _dish(
      'Breakfast',
      'Granola bowl',
      650,
      description: 'Greek yogurt, honey, red fruits',
      dietary: ['vegetarian'],
      fr: {
        'name': 'Bol de granola',
        'description': 'Yaourt grec, miel, fruits rouges',
      },
      ar: {
        'name': 'وعاء غرانولا',
        'description': 'زبادي يوناني، عسل، فواكه حمراء',
      },
    ),
    _dish(
      'Sandwiches',
      'Croque monsieur',
      750,
      description: 'Ham, emmental, béchamel',
      fr: {
        'name': 'Croque-monsieur',
        'description': 'Jambon, emmental, béchamel',
      },
      ar: {
        'name': 'كروك مسيو',
        'description': 'لحم خنزير، جبن إمنتال، صلصة بشاميل',
      },
      option: {'name': 'Fried egg (croque madame)', 'priceMinor': 100},
    ),
    _dish(
      'Sandwiches',
      'Falafel wrap',
      800,
      description: 'Hummus, pickled red onion, herbs',
      dietary: ['vegan', 'vegetarian'],
      fr: {
        'name': 'Wrap falafel (vegan)',
        'description': 'Houmous, oignon rouge mariné, herbes',
      },
      ar: {
        'name': 'لفافة فلافل (نباتية)',
        'description': 'حمص، بصل أحمر مخلل، أعشاب',
      },
    ),
    _dish(
      'Sandwiches',
      'Chicken club',
      950,
      description: 'Bacon, tomato, lettuce, mayonnaise',
      fr: {
        'name': 'Club au poulet',
        'description': 'Bacon, tomate, laitue, mayonnaise',
      },
      ar: {
        'name': 'كلوب بالدجاج',
        'description': 'لحم مقدد، طماطم، خس، مايونيز',
      },
    ),
    _dish(
      'Plates',
      'Quiche lorraine & green salad',
      1100,
      fr: {'name': 'Quiche lorraine et salade verte'},
      ar: {'name': 'كيش لورين وسلطة خضراء'},
    ),
    _dish(
      'Plates',
      'Mushroom risotto',
      1350,
      description: 'Parmesan, thyme',
      dietary: ['vegetarian'],
      fr: {
        'name': 'Risotto aux champignons (végétarien)',
        'description': 'Parmesan, thym',
      },
      ar: {'name': 'ريزوتو بالفطر (نباتي)', 'description': 'بارميزان، زعتر'},
    ),
    _dish(
      'Drinks',
      'Espresso',
      180,
      fr: {'name': 'Espresso'},
      ar: {'name': 'إسبريسو'},
    ),
    _dish(
      'Drinks',
      'Cappuccino',
      300,
      fr: {'name': 'Cappuccino'},
      ar: {'name': 'كابتشينو'},
      option: {'name': 'Oat milk', 'priceMinor': 40},
    ),
    _dish(
      'Drinks',
      'Fresh orange juice',
      400,
      fr: {'name': 'Jus d’orange frais'},
      ar: {'name': 'عصير برتقال طازج'},
    ),
  ];

  static String? _queued, _tidied;

  /// Queues the daily reset at 09:00 UTC, night across the Americas, and an
  /// hourly tidy so finished demo orders do not stay open in the kitchen.
  static Future<void> schedule(Session s) async {
    final rid = restaurantId;
    final now = _now();
    if (rid == null) return;
    final day = now.toIso8601String().substring(0, 10);
    final hour = now.toIso8601String().substring(0, 13);
    final jobs = [
      if (now.hour >= 9 && _queued != '$rid:$day')
        ('judge.reset', 'judge-reset:$rid:$day'),
      if (_tidied != '$rid:$hour') ('judge.tidy', 'judge-tidy:$rid:$hour'),
    ];
    if (jobs.isEmpty) return;
    await PlatformJob.db.insert(s, [
      for (final (kind, key) in jobs)
        PlatformJob(
          restaurantId: rid,
          kind: kind,
          dedupeKey: key,
          payloadJson: jsonEncode({'restaurantId': rid}),
          state: 'pending',
          attempts: 0,
          availableAt: now,
          createdAt: now,
        ),
    ], ignoreConflicts: true);
    if (now.hour >= 9) _queued = '$rid:$day';
    _tidied = '$rid:$hour';
  }

  /// A manager of the judges' café starts it fresh. Work from the last ten
  /// minutes is kept, so another judge in the middle of a demo keeps theirs.
  static Future<Json> command(Session s, PlatformCommand c) async {
    var menuOnly = false;
    await _mutate(s, c, 'judge.reset', (w, d) async {
      _keys(d, {'menu'});
      menuOnly = d.containsKey('menu') && _bool(d, 'menu');
      if (!venue(w.tenant)) {
        _fail('forbidden', 'Only the judges’ café starts fresh.');
      }
      await _rate(s, 'judge-reset:${w.tenant}', menuOnly ? 20 : 2, w.tx);
      await w.audit('judge.reset_requested', 'restaurant', w.tenant, {
        if (menuOnly) 'menu': true,
      });
      return {};
    }, roles: _managers);
    return reset(
      s,
      c.restaurantId!,
      quiet: const Duration(minutes: 10),
      menuOnly: menuOnly,
    );
  }

  /// The Sandbox buyer accounts standing in as the team's PayPal emails,
  /// from `RAYSTO_JUDGE_PAYOUT_EMAILS` (comma-separated). Never hardcoded.
  static List<String> get payoutEmails =>
      (ProviderClients.environment()['RAYSTO_JUDGE_PAYOUT_EMAILS'] ?? '')
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.contains('@'))
          .toList();

  /// What a judge finds in the back office: a team on shift this week, a
  /// catering request, a complaint on a paid order, a seeded dispute,
  /// suppliers, stock, last week's expenses and two regulars. Shifts are
  /// re-made each day; the rest is added only when missing, and the hourly
  /// tidy never touches any of it.
  static Future<Json> seed(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    final zone = CatalogueModule.zone(w.settings['timezone'] as String);
    final emails = payoutEmails;
    String email(int i) => emails.isEmpty ? '' : emails[i % emails.length];
    final today = tz.TZDateTime.from(_now(), zone);
    final monday = tz.TZDateTime(
      zone,
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));

    await StaffShift.db.deleteWhere(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    const team = [
      ('Nadia', 'floor', 1600, 9, 17),
      ('Omar', 'kitchen', 1800, 8, 16),
      ('Lina', 'manager', 2200, 10, 18),
    ];
    final shifts = <StaffShift>[];
    for (var day = 0; day < 6; day++) {
      final date = monday.add(Duration(days: day));
      for (final (i, (name, role, rate, from, to)) in team.indexed) {
        final startsAt = tz.TZDateTime(zone, date.year, date.month, date.day, from).toUtc();
        final endsAt = tz.TZDateTime(zone, date.year, date.month, date.day, to).toUtc();
        final past = endsAt.isBefore(_now());
        final onNow = startsAt.isBefore(_now()) && !past;
        shifts.add(
          StaffShift(
            restaurantId: rid,
            name: name,
            role: role,
            startsAt: startsAt,
            endsAt: endsAt,
            clockInAt: past || onNow ? startsAt : null,
            clockOutAt: past ? endsAt : null,
            hourlyRateMinor: rate,
            // One Sandbox account per person; the rest have no payout email
            // rather than sharing one, so a pay run never merges two people.
            payoutEmail: i < emails.length ? email(i) : null,
            version: 1,
            createdAt: _now(),
          ),
        );
      }
    }
    await StaffShift.db.insert(s, shifts, transaction: w.tx);

    // Each reset starts the catering demo again: a request that was quoted
    // but never sent (or whose send failed) is withdrawn and asked afresh.
    await CateringRequest.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) & t.status.inSet({'requested', 'quoted'}),
      transaction: w.tx,
    );
    var catering = 0;
    final asked = await CateringRequest.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.status.equals('requested'),
      transaction: w.tx,
    );
    if (asked == 0) {
      final friday = monday.add(const Duration(days: 4, hours: 12));
      await CateringRequest.db.insertRow(
        s,
        CateringRequest(
          restaurantId: rid,
          customerEmail: email(0).isEmpty ? 'caterer@example.com' : email(0),
          customerName: 'Studio Lumen',
          text:
              'Lunch for 12 on Friday, sandwiches and salads, budget \$150. '
              'Two of us are vegetarian.',
          eventAt: (friday.isBefore(today) ? friday.add(const Duration(days: 7)) : friday).toUtc(),
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
      catering = 1;
    }

    // A complaint needs a real paid order; judges' own PayPal orders qualify.
    // Likewise a complaint the agent already answered is cleared so the
    // next judge sees the agent work; refunded ones stay as history.
    await Complaint.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.status.inSet({'open', 'proposed', 'declined'}),
      transaction: w.tx,
    );
    var complaint = 0;
    final openComplaints = await Complaint.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.status.inSet({'open', 'proposed'}),
      transaction: w.tx,
    );
    PaymentCapture? capture;
    if (openComplaints == 0) {
      final paid = await PurchaseOrder.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(rid) &
            t.paymentStatus.equals('paid') &
            t.status.notInSet({'cancelled', 'rejected', 'expired'}),
        orderBy: (t) => t.createdAt,
        limit: 50,
        transaction: w.tx,
      );
      for (final o in paid.reversed) {
        final checkout = await CheckoutIntent.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(o.id!) & t.state.equals('completed'),
          transaction: w.tx,
        );
        if (checkout == null) continue;
        capture = await PaymentCapture.db.findFirstRow(
          s,
          where: (t) => t.checkoutId.equals(checkout.id!) & t.state.equals('completed'),
          transaction: w.tx,
        );
        if (capture == null || capture.amountMinor - capture.refundedMinor < 100) continue;
        final had = await Complaint.db.count(
          s,
          where: (t) => t.orderId.equals(o.id!),
          transaction: w.tx,
        );
        if (had > 0) continue;
        await Complaint.db.insertRow(
          s,
          Complaint(
            restaurantId: rid,
            orderId: o.id!,
            captureId: capture.id,
            userId: o.customerId,
            // Name a dish the order really has, so the agent can check it.
            text:
                'My ${(o.lines.isEmpty ? 'order' : o.lines.first.name).toLowerCase()} '
                'was missing from the bag.',
            status: 'open',
            version: 1,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        // The agent reads it at once, as a diner's own complaint would be.
        final seeded = await Complaint.db.findFirstRow(
          s,
          where: (t) => t.orderId.equals(o.id!) & t.status.equals('open'),
          transaction: w.tx,
        );
        if (seeded != null) await ComplaintAgent.enqueueFor(w, seeded);
        complaint = 1;
        break;
      }
    }

    var dispute = 0;
    final disputes = await DisputeCase.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.providerDisputeId.equals('SEEDED-JUDGES-1'),
      transaction: w.tx,
    );
    if (disputes == 0) {
      await DisputeCase.db.insertRow(
        s,
        DisputeCase(
          restaurantId: rid,
          providerDisputeId: 'SEEDED-JUDGES-1',
          captureId: capture?.id,
          reason: 'ITEM_NOT_RECEIVED',
          amountMinor: 750,
          currency: w.restaurant!.currency,
          status: 'open',
          evidenceJson: jsonEncode({
            'seeded': true,
            'note': 'A seeded Sandbox case: PayPal Sandbox cannot open a real dispute.',
          }),
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      dispute = 1;
    }

    final suppliers = await Supplier.db.find(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    final byName = {for (final x in suppliers) x.name: x};
    for (final (i, name) in ['Marché Dupont', 'Greenline Cleaning Supplies'].indexed) {
      if (byName.containsKey(name)) continue;
      byName[name] = await Supplier.db.insertRow(
        s,
        Supplier(
          restaurantId: rid,
          name: name,
          payoutEmail: email(i).isEmpty ? 'supplier-${i + 1}@example.com' : email(i),
          version: 1,
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
    }
    final dupont = byName['Marché Dupont']!.id;
    final stock = await StockItem.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    if (stock == 0) {
      const items = [
        ('Flour T55', 'kg', 12.0, 120, 10.0),
        ('Butter AOP', 'kg', 3.5, 980, 4.0),
        ('Free-range eggs', 'pcs', 60.0, 32, 48.0),
        ('Button mushrooms', 'kg', 1.5, 650, 2.0),
        ('Arborio rice', 'kg', 6.0, 390, 3.0),
        ('Espresso beans', 'kg', 2.0, 2200, 2.5),
      ];
      await StockItem.db.insert(s, [
        for (final (name, unit, quantity, cost, low) in items)
          StockItem(
            restaurantId: rid,
            name: name,
            unit: unit,
            quantity: quantity,
            costMinor: cost,
            supplierId: dupont,
            lowAt: low,
            version: 1,
            updatedAt: _now(),
          ),
      ], transaction: w.tx);
    }

    final expenses = await Expense.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    if (expenses == 0) {
      await Expense.db.insert(s, [
        Expense(
          restaurantId: rid,
          category: 'food',
          amountMinor: 47980,
          currency: w.restaurant!.currency,
          vatMinor: 0,
          spentAt: _now().subtract(const Duration(days: 6)),
          merchant: 'Marché Dupont',
          createdAt: _now(),
        ),
        Expense(
          restaurantId: rid,
          category: 'other',
          amountMinor: 7956,
          currency: w.restaurant!.currency,
          vatMinor: 589,
          spentAt: _now().subtract(const Duration(days: 4)),
          merchant: 'Greenline Cleaning Supplies',
          paypalTransactionId: '7XK40217PL338',
          createdAt: _now(),
        ),
      ], transaction: w.tx);
    }

    final customers = await CustomerProfile.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    if (customers == 0) {
      await CustomerProfile.db.insert(s, [
        CustomerProfile(
          restaurantId: rid,
          emailHash: _hash('judges:regular'),
          displayName: 'Maya (regular)',
          visits: 14,
          spentMinor: 18650,
          lastSeenAt: _now().subtract(const Duration(days: 1)),
          tagsJson: '["regular"]',
          updatedAt: _now(),
        ),
        CustomerProfile(
          restaurantId: rid,
          emailHash: _hash('judges:lapsed'),
          displayName: 'Tom (lapsed)',
          visits: 6,
          spentMinor: 7200,
          lastSeenAt: _now().subtract(const Duration(days: 31)),
          tagsJson: '["lapsed"]',
          updatedAt: _now(),
        ),
      ], transaction: w.tx);
    }
    return {
      'shifts': shifts.length,
      'catering': catering,
      'complaint': complaint,
      'dispute': dispute,
    };
  }

  /// Returns the café to its starting menu and settings. Nothing is deleted:
  /// orders are completed or cancelled and checkouts released through the
  /// same steps staff use, and PayPal is read before any checkout is freed.
  /// Without [full], only orders, checkouts and old proposals are closed.
  static Future<Json> reset(
    Session s,
    int rid, {
    Duration quiet = const Duration(hours: 1),
    bool full = true,
    bool menuOnly = false,
  }) async {
    if (!venue(rid)) {
      _fail('forbidden', 'Only the judges’ café starts fresh.');
    }
    final before = _now().subtract(quiet);
    var released = 0;
    final open = menuOnly
        ? <CheckoutIntent>[]
        : await CheckoutIntent.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.method.equals('paypal') &
          t.state.inSet({'reserved', 'created', 'approved'}) &
          (t.updatedAt < before),
      limit: 100,
    );
    for (final i in open) {
      try {
        final result = await MoneyModule.releaseChecked(s, i.id!);
        if (result['released'] == true) released++;
      } on DomainError {
        // PayPal could not be read: left for the payments agent and the
        // next reset.
      }
    }
    final owner = await Membership.db.findFirstRow(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.role.equals('owner') &
          t.active.equals(true),
    );
    if (owner == null) {
      _fail('not_found', 'The judges’ café has no owner.');
    }
    return MoneyModule.locked(s, rid, owner.userId, (w) async {
      var completed = 0, cancelled = 0, expired = 0;
      final orders = menuOnly
          ? <PurchaseOrder>[]
          : await PurchaseOrder.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(rid) &
                  t.status.notInSet({'completed', 'cancelled', 'rejected'}) &
                  (t.updatedAt < before),
              limit: 500,
              transaction: w.tx,
            );
      for (final row in orders) {
        final (o, ctx) = await OrderingModule._order(w, row.id!);
        if ({
          'paid',
          'partiallyRefunded',
          'refunded',
        }.contains(o.paymentStatus)) {
          o.status = 'completed';
          await OrderingModule._changed(w, o, 'order.completed');
          completed++;
          continue;
        }
        final charges = await BillCharge.db.find(
          s,
          where: (t) => t.orderId.equals(o.id!),
          transaction: w.tx,
        );
        // A checkout still open at PayPal keeps its order for the next reset.
        if (charges.any((c) => c.reservedMinor > 0)) continue;
        await OrderingModule._cancel(
          w,
          o,
          ctx,
          'cancelled',
          'Closed when the judges’ café started fresh.',
        );
        cancelled++;
      }
      final pending = menuOnly
          ? <AgentAction>[]
          : await AgentAction.db.find(
              s,
              where: (t) =>
                  t.restaurantId.equals(rid) &
                  t.status.equals('pending') &
                  (t.createdAt < before),
              transaction: w.tx,
            );
      for (final a in pending) {
        a.status = 'expired';
        a.decidedAt = _now();
        a.version++;
        await AgentAction.db.updateRow(s, a, transaction: w.tx);
        expired++;
      }
      if (!full) {
        final result = {
          'released': released,
          'completed': completed,
          'cancelled': cancelled,
          'expired': expired,
        };
        if (result.values.any((n) => n > 0)) {
          await w.audit('judge.tidy', 'restaurant', rid, result);
        }
        return result;
      }

      final policy = w.policy!;
      policy.settingsJson = jsonEncode(
        CatalogueModule.validateSettings({
          ..._json(policy.settingsJson),
          ...settings,
        }),
      );
      policy.version++;
      policy.updatedAt = _now();
      await RestaurantPolicy.db.updateRow(s, policy, transaction: w.tx);
      w.restaurant!.name = name;
      w.restaurant!.published = true;
      await Restaurant.db.updateRow(s, w.restaurant!, transaction: w.tx);

      // The starting menu, on the same products, keeping each dish's photo.
      final products = await MenuProduct.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        orderBy: (t) => t.id,
        transaction: w.tx,
      );
      final definitions = {
        for (final d in await MenuDefinition.db.find(
          s,
          where: (t) => t.restaurantId.equals(rid),
          transaction: w.tx,
        ))
          d.productId: d,
      };
      final byName = <String, MenuProduct>{};
      for (final current in [false, true]) {
        for (final p in products) {
          if ((definitions[p.id]?.archived ?? true) == current) {
            byName.putIfAbsent(p.name.toLowerCase(), () => p);
          }
        }
      }
      final items = <Json>[];
      for (final dish in menu) {
        final p = byName[(dish['name'] as String).toLowerCase()];
        final mediaId = p == null
            ? null
            : _json(definitions[p.id]?.definitionJson ?? '{}')['mediaId'];
        final media = mediaId is int
            ? await MediaAsset.db.findById(s, mediaId, transaction: w.tx)
            : null;
        items.add({
          ...dish,
          if (p != null) 'productId': p.id,
          if (media != null &&
              media.restaurantId == rid &&
              media.status == 'approved' &&
              media.purpose == 'menuImage' &&
              media.public)
            'mediaId': media.id,
        });
      }
      final draft = await MenuDraft.db.insertRow(
        s,
        MenuDraft(
          restaurantId: rid,
          userId: owner.userId,
          itemsJson: jsonEncode(items),
          baseMenuVersion: policy.menuVersion,
          version: 1,
          status: 'draft',
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await CatalogueModule.applyDraft(w, draft, merge: false);
      final seeded = menuOnly ? const <String, dynamic>{} : await seed(w);
      final result = {
        'released': released,
        'completed': completed,
        'cancelled': cancelled,
        'expired': expired,
        'dishes': items.length,
        'menuVersion': policy.menuVersion,
        if (menuOnly) 'menuOnly': true,
        ...seeded,
      };
      await w.audit(menuOnly ? 'judge.menu_restored' : 'judge.reset', 'restaurant', rid, result);
      return result;
    });
  }
}
