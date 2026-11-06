part of 'platform.dart';

/// The judges' café: a Sandbox restaurant whose manager login is published
/// for the hackathon judges. Its name, opening and team stay with its owner,
/// and once a day it returns to the same menu and settings: older orders are
/// closed, abandoned PayPal checkouts released and stale proposals expired.
class JudgeModule {
  static const name = 'Atelier Café · Judges';

  /// The second café of the judges' franchise demo, and its group. Nothing
  /// about them is a real business: both cafés are demo cafés ([venue], the
  /// `demo` flag the console reads), and the console shows one "Demo café"
  /// badge rather than a suffix on every name.
  static const secondName = 'Atelier Harbour';
  static const groupName = 'Atelier Group';

  static int? _id(String key) =>
      int.tryParse(ProviderClients.environment()[key] ?? '');

  static int? get restaurantId => _id('RAYSTO_JUDGE_RESTAURANT_ID');
  static int? get secondRestaurantId => _id('RAYSTO_JUDGE_SECOND_RESTAURANT_ID');
  static int? get groupId => _id('RAYSTO_JUDGE_GROUP_ID');
  static int? get simulatorPartnerId => _id('RAYSTO_SIM_PARTNER_APP_ID');

  /// Either judges' café: both keep their identity and start fresh daily.
  static bool venue(int? tenant) =>
      tenant != null &&
      (tenant == restaurantId || tenant == secondRestaurantId);

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
    'address': 'Demo café · Hudson Street, New York',
    'timezone': 'America/New_York',
    'country': 'US',
    'languages': ['en', 'fr', 'ar'],
    // Delivery (0.16): a 3 km zone around the café's corner of Manhattan, a
    // flat fee, and a handover code the courier asks for at the door.
    'modes': ['pickup', 'delivery'],
    'deliveryZones': [
      {'latitude': 40.7424, 'longitude': -74.0060, 'radiusKm': 3},
    ],
    'deliveryFeeMinor': 299,
    'deliveryMinimumMinor': 800,
    'deliveryProof': 'code',
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
    // The day's goal the dashboard's ring shows; a setting, not a result.
    // About a usual day of the stored 30-day history (JudgeHistory).
    'dailyTargetMinor': 100000,
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

  /// The second café returns to the first café's settings, by the harbour,
  /// for pickup and dine-in only.
  static Map<String, dynamic> get secondSettings => {
    ...settings,
    'address': 'Demo café · by the harbour, New York',
    'modes': ['pickup', 'dineIn'],
    'deliveryZones': [],
    'deliveryFeeMinor': 0,
    'deliveryMinimumMinor': 0,
    'deliveryProof': 'none',
    'dailyTargetMinor': 65000,
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

  static final _queued = <String>{}, _tidied = <String>{};

  /// Queues each café's daily reset at 09:00 UTC, night across the Americas,
  /// and an hourly tidy so finished demo orders do not stay open in the
  /// kitchen. The first café resets before the second: the group lives with
  /// the first.
  static Future<void> schedule(Session s) async {
    final now = _now();
    final day = now.toIso8601String().substring(0, 10);
    final hour = now.toIso8601String().substring(0, 13);
    // Only today's keys matter; older ones are dropped.
    _queued.removeWhere((k) => !k.endsWith(day));
    _tidied.removeWhere((k) => !k.endsWith(hour));
    for (final rid in [restaurantId, secondRestaurantId].whereType<int>()) {
      final jobs = [
        if (now.hour >= 9 && !_queued.contains('$rid:$day'))
          ('judge.reset', 'judge-reset:$rid:$day'),
        if (!_tidied.contains('$rid:$hour'))
          ('judge.tidy', 'judge-tidy:$rid:$hour'),
      ];
      if (jobs.isEmpty) continue;
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
      if (now.hour >= 9) _queued.add('$rid:$day');
      _tidied.add('$rid:$hour');
    }
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
  /// suppliers, stock, last week's expenses, two regulars and the stored
  /// month of sample history (JudgeHistory). Shifts are re-made each day,
  /// except those whose wages PayPal already paid; the rest is added only
  /// when missing, and the hourly tidy never touches any of it.
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

    // Shifts are re-made each day, except a shift whose wages PayPal Payouts
    // already paid: it stays as it was, so a later pay run knows it is paid
    // and never pays the same week's wages again.
    final paid = await PayrollAgent.paidShiftIds(w);
    await StaffShift.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          (paid.isEmpty ? Constant.bool(true) : t.id.notInSet(paid)),
      transaction: w.tx,
    );
    final kept = {
      for (final x in await StaffShift.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        transaction: w.tx,
      ))
        '${x.name}@${x.startsAt.microsecondsSinceEpoch}',
    };
    const team = [
      ('Nadia', 'floor', 1600, 9, 17),
      ('Omar', 'kitchen', 1800, 8, 16),
      ('Lina', 'manager', 2200, 10, 18),
    ];
    final shifts = <StaffShift>[];
    var week = 0;
    for (var day = 0; day < 6; day++) {
      final date = monday.add(Duration(days: day));
      for (final (i, (name, role, rate, from, to)) in team.indexed) {
        final startsAt = tz.TZDateTime(zone, date.year, date.month, date.day, from).toUtc();
        final endsAt = tz.TZDateTime(zone, date.year, date.month, date.day, to).toUtc();
        week++;
        if (kept.contains('$name@${startsAt.microsecondsSinceEpoch}')) continue;
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
    if (shifts.isNotEmpty) {
      await StaffShift.db.insert(s, shifts, transaction: w.tx);
    }

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
      // Never a sample sale: those were paid in cash and nobody complained.
      final paid = await PurchaseOrder.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(rid) &
            t.paymentStatus.equals('paid') &
            t.status.notInSet({'cancelled', 'rejected', 'expired'}) &
            t.requestKey.notLike('${JudgeHistory.keyPrefix}%'),
        orderBy: (t) => t.createdAt,
        limit: 50,
        transaction: w.tx,
      );
      for (final o in paid.reversed) {
        final checkout = await CheckoutIntent.db.findFirstRow(
          s,
          where: (t) =>
              t.orderId.equals(o.id!) &
              t.state.equals('completed') &
              t.method.equals('paypal'),
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
    final stockItems = await _seedStock(w, dupont);

    // Last week's two receipts, added once. Like every seeded cost they are
    // recorded at the moment they were spent (JudgeHistory.expense) and
    // carry no PayPal id: neither was a PayPal transaction.
    final receipts = await Expense.db.count(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.mediaId.equals(null) &
          t.taskId.equals(null) &
          ((t.merchant.equals('Marché Dupont') & t.amountMinor.equals(47980)) |
              (t.merchant.equals('Greenline Cleaning Supplies') &
                  t.amountMinor.equals(7956))),
      transaction: w.tx,
    );
    if (receipts == 0) {
      final food = _now().subtract(const Duration(days: 6));
      final cleaning = _now().subtract(const Duration(days: 4));
      await Expense.db.insert(s, [
        Expense(
          restaurantId: rid,
          category: 'food',
          amountMinor: 47980,
          currency: w.restaurant!.currency,
          vatMinor: 0,
          spentAt: food,
          merchant: 'Marché Dupont',
          createdAt: food,
        ),
        Expense(
          restaurantId: rid,
          category: 'other',
          amountMinor: 7956,
          currency: w.restaurant!.currency,
          vatMinor: 589,
          spentAt: cleaning,
          merchant: 'Greenline Cleaning Supplies',
          createdAt: cleaning,
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
    // 0.16: recipes, the three supplier orders, the four bills, the drivers,
    // the simulator partner, the deposit pay link and the franchise group.
    final recipes = await _seedRecipes(w, stockItems);
    final supplierOrders = await _seedSupplierOrders(w, dupont, stockItems);
    final bills = await _seedBills(w, email, supplierId: dupont);
    final drivers = await _seedDrivers(w, email);
    final partner = await _seedPartner(w);
    final payLink = await _seedPayLink(w, email);
    final group = await _seedGroup(w);
    // The 30 days before today, stored: sales, tips, refunds and costs.
    final history = await JudgeHistory.seed(w);
    return {
      'shifts': week,
      'catering': catering,
      'complaint': complaint,
      'dispute': dispute,
      'stock': stockItems.length,
      'recipes': recipes,
      'supplierOrders': supplierOrders,
      'bills': bills,
      'drivers': drivers,
      'partner': partner,
      'payLink': payLink,
      'group': group,
      'history': history,
    };
  }

  /// Marks a seeded row so a judge, and code, can always tell sample data
  /// from what really happened: a JSON flag ([sampleJson]), a note ("Sample:
  /// …" on a supplier order or a refund, "(sample)" on a pay link), a
  /// `sample:` request key (JudgeHistory), or, for the few rows with no room
  /// for either (drivers, the group, the second café), being one of the
  /// seed's own names on a demo café ([sampleDriver], [venue]). Names carry
  /// no suffix any more: the console shows one "Demo café" badge.
  static String sampleJson([Json extra = const {}]) =>
      jsonEncode({'sample': true, ...extra});

  /// The suffix seeded names carried until 0.16.2; the reset takes it off
  /// rows that still have it, in place.
  static const legacySuffix = '· Sample';
  static String plain(String name) => name.endsWith(legacySuffix)
      ? name.substring(0, name.length - legacySuffix.length).trimRight()
      : name;

  /// The two simulated drivers, who have no login.
  static const sampleDrivers = {'Sam', 'Ines'};
  static bool sampleDriver(Driver d) =>
      venue(d.restaurantId) &&
      d.userId == null &&
      d.partnerAppId == null &&
      sampleDrivers.contains(plain(d.name));

  /// A bill the seed made (its JSON says so).
  static bool _sampleBill(Bill b) => _json(b.readJson)['sample'] == true;
  static const _sampleBillJson = '%"sample":true%';

  /// The seeded bills' vendors.
  static const _power = 'Hudson Power & Light';

  /// The seeded pay link's note: its description ends "(sample)".
  static const _sampleLink = '%(sample)';

  /// Takes the legacy suffix off the café's bill vendors and payers' names.
  /// A row a judge touched in the last ten minutes is left until later.
  static Future<int> _renameLegacy(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    final quiet = _now().subtract(const Duration(minutes: 10));
    var renamed = 0;
    for (final b in await Bill.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) & t.vendor.like('%$legacySuffix'),
      transaction: w.tx,
    )) {
      if (!_sampleBill(b) && b.state != 'expected' && b.updatedAt.isAfter(quiet)) {
        continue;
      }
      b
        ..vendor = plain(b.vendor)
        ..version += 1
        ..updatedAt = _now();
      await Bill.db.updateRow(s, b, transaction: w.tx);
      renamed++;
    }
    for (final r in await PaymentRequest.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) & t.payerName.like('%$legacySuffix'),
      transaction: w.tx,
    )) {
      r
        ..payerName = plain(r.payerName)
        ..version += 1
        ..updatedAt = _now();
      await PaymentRequest.db.updateRow(s, r, transaction: w.tx);
      renamed++;
    }
    return renamed;
  }

  /// The café's stock at the start of each day: by name, with par levels
  /// and lead times for the supply planner. Three items start below their
  /// low mark, so the planner always has a reorder to propose. A quantity
  /// put back by the reset is an audited `adjust` movement, never a silent
  /// overwrite.
  static Future<Map<String, StockItem>> _seedStock(Work w, int? supplierId) async {
    final s = w.s;
    final rid = w.tenant;
    const items = [
      // name, unit, quantity, cost, low mark, par level, lead days
      ('Flour T55', 'kg', 12.0, 120, 10.0, 30.0, 2),
      ('Butter AOP', 'kg', 3.5, 980, 4.0, 10.0, 2),
      ('Free-range eggs', 'pcs', 60.0, 32, 48.0, 180.0, 1),
      ('Button mushrooms', 'kg', 1.5, 650, 2.0, 6.0, 1),
      ('Arborio rice', 'kg', 6.0, 390, 3.0, 10.0, 3),
      ('Espresso beans', 'kg', 2.0, 2200, 2.5, 6.0, 3),
      ('Oranges', 'kg', 8.0, 210, 6.0, 20.0, 1),
      ('Gruyère', 'kg', 1.2, 1800, 1.0, 4.0, 2),
    ];
    final existing = {
      for (final x in await StockItem.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        transaction: w.tx,
      ))
        x.name: x,
    };
    // One audited adjustment per item per reset.
    final at = _now().toIso8601String();
    final result = <String, StockItem>{};
    for (final (name, unit, quantity, cost, low, par, lead) in items) {
      var item = existing[name];
      if (item == null) {
        item = await StockItem.db.insertRow(
          s,
          StockItem(
            restaurantId: rid,
            name: name,
            unit: unit,
            quantity: quantity,
            costMinor: cost,
            supplierId: supplierId,
            lowAt: low,
            parLevel: par,
            leadDays: lead,
            version: 1,
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
      } else {
        final delta = quantity - item.quantity;
        if (delta.abs() > 1e-9) {
          await StockMovement.db.insert(s, [
            StockMovement(
              restaurantId: rid,
              stockItemId: item.id!,
              kind: 'adjust',
              quantity: delta,
              unitCostMinor: cost,
              refType: 'judge.reset',
              refId: at,
              at: _now(),
            ),
          ], transaction: w.tx, ignoreConflicts: true);
        }
        item
          ..quantity = quantity
          ..costMinor = cost
          ..lowAt = low
          ..parLevel = par
          ..leadDays = lead
          ..supplierId ??= supplierId
          ..version += 1
          ..updatedAt = _now();
        item = await StockItem.db.updateRow(s, item, transaction: w.tx);
      }
      result[name] = item;
    }
    return result;
  }

  /// What each dish uses from stock, so sales draw stock down and the
  /// planner can forecast a stock-out. The granola bowl uses nothing stocked.
  static const _recipes = <String, List<(String, double)>>{
    'Butter croissant': [('Flour T55', 0.06), ('Butter AOP', 0.03)],
    'Pain au chocolat': [('Flour T55', 0.06), ('Butter AOP', 0.03)],
    'Croque monsieur': [('Flour T55', 0.1), ('Butter AOP', 0.01), ('Gruyère', 0.04)],
    'Falafel wrap': [('Flour T55', 0.08)],
    'Chicken club': [('Flour T55', 0.1), ('Free-range eggs', 1.0)],
    'Quiche lorraine & green salad': [
      ('Flour T55', 0.08),
      ('Butter AOP', 0.03),
      ('Free-range eggs', 3.0),
      ('Gruyère', 0.03),
    ],
    'Mushroom risotto': [
      ('Arborio rice', 0.09),
      ('Button mushrooms', 0.12),
      ('Butter AOP', 0.02),
    ],
    'Espresso': [('Espresso beans', 0.018)],
    'Cappuccino': [('Espresso beans', 0.018)],
    'Fresh orange juice': [('Oranges', 0.5)],
  };

  static Future<int> _seedRecipes(Work w, Map<String, StockItem> stock) async {
    final s = w.s;
    final rid = w.tenant;
    final products = {
      for (final p in await MenuProduct.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        orderBy: (t) => t.id,
        transaction: w.tx,
      ))
        p.name.toLowerCase(): p,
    };
    final lines = <RecipeLine>[];
    for (final MapEntry(key: dish, value: uses) in _recipes.entries) {
      final product = products[dish.toLowerCase()];
      if (product == null) continue;
      for (final (item, quantity) in uses) {
        final stockItem = stock[item];
        if (stockItem == null) continue;
        lines.add(
          RecipeLine(
            restaurantId: rid,
            productId: product.id!,
            stockItemId: stockItem.id!,
            quantity: quantity,
            updatedAt: _now(),
          ),
        );
      }
    }
    // A recipe a manager already changed stays as they left it.
    final added = await RecipeLine.db.insert(
      s,
      lines,
      transaction: w.tx,
      ignoreConflicts: true,
    );
    return added.length;
  }

  /// Three sample supplier orders to Marché Dupont: a draft as the planner
  /// would propose it, one sent and waiting, and one received with a price
  /// change on the butter. Re-made when missing; a judge's own drafts from
  /// earlier days are removed, sent or received orders are kept.
  static Future<int> _seedSupplierOrders(
    Work w,
    int? supplierId,
    Map<String, StockItem> stock,
  ) async {
    final s = w.s;
    final rid = w.tenant;
    await SupplierOrder.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.state.equals('draft') &
          (t.updatedAt < _now().subtract(const Duration(minutes: 10))) &
          (t.note.equals(null) | t.note.notLike('%Sample%')),
      transaction: w.tx,
    );
    final have = await SupplierOrder.db.count(
      s,
      where: (t) => t.restaurantId.equals(rid) & t.note.like('%Sample%'),
      transaction: w.tx,
    );
    if (have > 0 || supplierId == null) return 0;
    final owner = await _owner(w);
    Json line(String name, double qty, {double? received, int? receivedCost}) {
      final item = stock[name]!;
      return {
        'stockItemId': item.id,
        'name': item.name,
        'unit': item.unit,
        'qty': qty,
        'unitCostMinor': item.costMinor,
        'receivedQty': ?received,
        'receivedUnitCostMinor': ?receivedCost,
      };
    }

    int total(List<Json> lines) => lines.fold(
      0,
      (n, l) => n + ((l['qty'] as double) * (l['unitCostMinor'] as int)).round(),
    );
    final draft = [line('Espresso beans', 4.0), line('Butter AOP', 6.5)];
    final sent = [line('Flour T55', 25.0), line('Free-range eggs', 120.0)];
    final received = [
      line('Button mushrooms', 6.0, received: 6.0, receivedCost: 650),
      // The butter came in at 10.40, not 9.80: a 6% price change to flag.
      line('Butter AOP', 10.0, received: 10.0, receivedCost: 1040),
    ];
    final orders = [
      ('draft', draft, 'Sample draft: what the supply planner proposes', null, null),
      (
        'sent',
        sent,
        'Sample: sent to Marché Dupont, expected tomorrow',
        _now().subtract(const Duration(hours: 20)),
        null,
      ),
      (
        'received',
        received,
        'Sample: received with a butter price change',
        _now().subtract(const Duration(days: 3)),
        _now().subtract(const Duration(days: 2)),
      ),
    ];
    for (final (state, lines, note, sentAt, receivedAt) in orders) {
      await SupplierOrder.db.insertRow(
        s,
        SupplierOrder(
          restaurantId: rid,
          supplierId: supplierId,
          state: state,
          linesJson: jsonEncode(lines),
          totalMinor: total(lines),
          currency: w.restaurant!.currency,
          expectedAt: _now().add(const Duration(days: 1)),
          sentAt: sentAt,
          receivedAt: receivedAt,
          note: note,
          createdBy: owner,
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
    }
    return orders.length;
  }

  /// The café's four sample bills. Electricity last month was paid by bank
  /// transfer; water waits, unpaid; the rent was paid elsewhere because the
  /// landlord has no PayPal; the internet bill goes to a Sandbox PayPal
  /// account, so paying it is a real Sandbox Payout. A judge's own unpaid
  /// bills from earlier days are removed; anything paid stays.
  ///
  /// Two more rows make the Try cards work end to end: this month's
  /// electricity is `expected` (the accountant's forecast, which the bill a
  /// judge reads from the sample PDF replaces, taking over the vendor's
  /// Sandbox PayPal email), and Marché Dupont's bill for the received
  /// supplier order completes its 3-way match.
  static Future<int> _seedBills(
    Work w,
    String Function(int) email, {
    int? supplierId,
  }) async {
    final s = w.s;
    final rid = w.tenant;
    await _renameLegacy(w);
    await Bill.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.state.inSet({'review', 'approved', 'void'}) &
          (t.updatedAt < _now().subtract(const Duration(minutes: 10))),
      transaction: w.tx,
    );
    final today = _now();
    final month = today.toIso8601String().substring(0, 7).replaceAll('-', '');
    final paypal = email(1).isEmpty ? email(0) : email(1);
    final bills = [
      Bill(
        restaurantId: rid,
        vendor: _power,
        category: 'electricity',
        reference: 'HPL-$month-PREV',
        amountMinor: 17680,
        vatMinor: 1310,
        currency: w.restaurant!.currency,
        issuedAt: today.subtract(const Duration(days: 33)),
        dueAt: today.subtract(const Duration(days: 19)),
        periodFrom: today.subtract(const Duration(days: 63)),
        periodTo: today.subtract(const Duration(days: 34)),
        state: 'paidElsewhere',
        payVia: 'elsewhere',
        // The utility now takes PayPal: this month's bill can be paid there.
        payeeEmail: email(0).isEmpty ? null : email(0),
        recurring: 'monthly',
        readJson: sampleJson({
          'note': 'Sample: last month, paid by bank transfer before Raysto; '
              'the utility also takes PayPal (a Sandbox account)',
        }),
        paidAt: today.subtract(const Duration(days: 23)),
        version: 1,
        createdAt: today,
        updatedAt: today,
      ),
      Bill(
        restaurantId: rid,
        vendor: 'Metro Water',
        category: 'water',
        reference: 'MW-$month',
        amountMinor: 4120,
        vatMinor: 0,
        currency: w.restaurant!.currency,
        issuedAt: today.subtract(const Duration(days: 9)),
        dueAt: today.add(const Duration(days: 5)),
        state: 'approved',
        payVia: 'elsewhere',
        recurring: 'monthly',
        readJson: sampleJson({'note': 'Sample: the water company does not take PayPal'}),
        version: 1,
        createdAt: today,
        updatedAt: today,
      ),
      Bill(
        restaurantId: rid,
        vendor: 'Harbour Properties',
        category: 'rent',
        reference: 'RENT-$month',
        amountMinor: 180000,
        vatMinor: 0,
        currency: w.restaurant!.currency,
        issuedAt: today.subtract(const Duration(days: 4)),
        dueAt: today.add(const Duration(days: 2)),
        state: 'paidElsewhere',
        payVia: 'elsewhere',
        recurring: 'monthly',
        readJson: sampleJson({
          'note': 'Sample: paid by bank transfer; the landlord has no PayPal',
        }),
        paidAt: today.subtract(const Duration(days: 1)),
        version: 1,
        createdAt: today,
        updatedAt: today,
      ),
      Bill(
        restaurantId: rid,
        vendor: 'Metro Fiber',
        category: 'internet',
        reference: 'MF-${today.toIso8601String().substring(0, 10).replaceAll('-', '')}',
        amountMinor: 5999,
        vatMinor: 0,
        currency: w.restaurant!.currency,
        issuedAt: today.subtract(const Duration(days: 2)),
        dueAt: today.add(const Duration(days: 7)),
        state: 'approved',
        payVia: paypal.isEmpty ? 'elsewhere' : 'paypal',
        payeeEmail: paypal.isEmpty ? null : paypal,
        recurring: 'monthly',
        readJson: sampleJson({
          'note': paypal.isEmpty
              ? 'Sample: no Sandbox PayPal account configured for this payee'
              : 'Sample: the payee is a PayPal Sandbox account, so paying it is a real Sandbox Payout',
        }),
        version: 1,
        createdAt: today,
        updatedAt: today,
      ),
    ];
    final existing = {
      for (final b in await Bill.db.find(
        s,
        where: (t) => t.restaurantId.equals(rid),
        transaction: w.tx,
      ))
        if (_sampleBill(b) && b.state != 'void') b.category,
    };
    final missing = [
      for (final b in bills)
        if (!existing.contains(b.category) ||
            // Once paid, the internet bill comes back unpaid each day so the
            // next judge can pay it too.
            (b.category == 'internet' && !await _unpaidSample(w, 'internet')))
          b,
    ];
    var added = 0;
    if (missing.isNotEmpty) {
      await Bill.db.insert(s, missing, transaction: w.tx);
      added += missing.length;
    }
    added += await _seedExpectedPower(w);
    if (supplierId != null) added += await _seedSupplierBill(w, supplierId);
    return added;
  }

  /// This month's electricity as the accountant expects it: same vendor,
  /// same amount as last month, the vendor's Sandbox PayPal email. When a
  /// judge's read of the sample PDF arrives it replaces this copy and keeps
  /// the email, so paying it is a real Sandbox Payout. Not a debt: the
  /// ledger ignores `expected` bills.
  static Future<int> _seedExpectedPower(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    // The utility's bills, however the AI read its name ("HUDSON POWER &
    // LIGHT", or the sample PDF's "Hudson Power & Light · Sample").
    final power = [
      for (final b in await Bill.db.find(
        s,
        where: (t) =>
            t.restaurantId.equals(rid) &
            t.category.equals('electricity') &
            t.state.notEquals('void'),
        orderBy: (t) => t.id.desc(),
        transaction: w.tx,
      ))
        if (BillsModule._vendorKey(b.vendor) == BillsModule._vendorKey(_power)) b,
    ];
    if (power.any((b) => {'expected', 'review', 'approved', 'paying'}.contains(b.state))) {
      return 0;
    }
    final last = power.where((b) => b.recurring == 'monthly').firstOrNull;
    if (last == null) return 0;
    final base = last.dueAt ?? last.issuedAt ?? last.createdAt;
    await Bill.db.insertRow(
      s,
      Bill(
        restaurantId: rid,
        vendor: last.vendor,
        category: 'electricity',
        amountMinor: last.amountMinor,
        vatMinor: last.vatMinor,
        currency: last.currency,
        dueAt: base.add(const Duration(days: 30)),
        state: 'expected',
        payVia: last.payeeEmail == null ? 'elsewhere' : 'paypal',
        payeeEmail: last.payeeEmail,
        recurring: 'monthly',
        recurringOfId: last.id,
        readJson: sampleJson({
          'expected': true,
          'basis': 'Same as last month; the real bill replaces it when it arrives.',
        }),
        version: 1,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
    return 1;
  }

  /// Marché Dupont's bill for the received sample order, at the prices on
  /// the delivery note: the butter at 10.40 a kilo against 9.80 ordered.
  /// Waiting in review, so the supply planner's 3-way match has its third
  /// paper. Re-made by each full reset, like the other unpaid bills.
  static Future<int> _seedSupplierBill(Work w, int supplierId) async {
    final s = w.s;
    final rid = w.tenant;
    final received = await SupplierOrder.db.findFirstRow(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.state.equals('received') &
          t.note.like('%Sample%'),
      orderBy: (t) => t.id.desc(),
      transaction: w.tx,
    );
    if (received == null) return 0;
    final billed = await Bill.db.count(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.supplierOrderId.equals(received.id!) &
          t.state.notEquals('void'),
      transaction: w.tx,
    );
    if (billed > 0) return 0;
    var amount = 0;
    for (final l in (jsonDecode(received.linesJson) as List).cast<Json>()) {
      final qty = ((l['receivedQty'] ?? l['qty']) as num).toDouble();
      final unit = ((l['receivedUnitCostMinor'] ?? l['unitCostMinor']) as num).toDouble();
      amount += (qty * unit).round();
    }
    final today = _now();
    await Bill.db.insertRow(
      s,
      Bill(
        restaurantId: rid,
        vendor: 'Marché Dupont',
        category: 'supplier',
        reference: 'MD-${received.id}',
        amountMinor: amount,
        vatMinor: 0,
        currency: received.currency,
        issuedAt: received.receivedAt ?? today,
        dueAt: today.add(const Duration(days: 12)),
        state: 'review',
        payVia: 'elsewhere',
        supplierId: supplierId,
        supplierOrderId: received.id,
        readJson: sampleJson({
          'note': 'Sample: the supplier\'s bill for the received order; '
              'the butter is billed at 10.40 a kilo, not the 9.80 ordered',
        }),
        version: 1,
        createdAt: today,
        updatedAt: today,
      ),
      transaction: w.tx,
    );
    return 1;
  }

  /// A judge's bill read from a sample file and since paid is kept, with
  /// its PayPal batch, but released for the next judge: its file hash is
  /// cleared and its reference marked, so reading the same sample again is
  /// a new bill, not a duplicate of an earlier demo run; the reading task's
  /// dedupe key is retired for the same reason. Money records stay as they
  /// were. Runs with the hourly tidy for bills older than [before].
  static Future<int> _releaseReadBills(Work w, DateTime before) async {
    final s = w.s;
    final rid = w.tenant;
    final read = await Bill.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.sourceMediaId.notEquals(null) &
          t.contentSha.notEquals(null) &
          t.state.inSet({'paid', 'paidElsewhere'}) &
          (t.updatedAt < before),
      transaction: w.tx,
    );
    for (final b in read) {
      b
        ..contentSha = null
        ..reference = b.reference == null ? null : '${b.reference} (earlier demo run)'
        ..readJson = jsonEncode({..._json(b.readJson), 'releasedAt': _now().toIso8601String()})
        ..version += 1
        ..updatedAt = _now();
      await Bill.db.updateRow(s, b, transaction: w.tx);
    }
    final tasks = await AgentTask.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.dedupeKey.like('bill:$rid:%') &
          t.dedupeKey.notLike('%:run%') &
          t.status.inSet({'done', 'failed'}) &
          (t.updatedAt < before),
      transaction: w.tx,
    );
    for (final t in tasks) {
      t.dedupeKey = '${t.dedupeKey}:run${t.id}';
      await AgentTask.db.updateRow(s, t, transaction: w.tx);
    }
    return read.length;
  }

  static Future<bool> _unpaidSample(Work w, String category) async =>
      await Bill.db.count(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.category.equals(category) &
            t.readJson.like(_sampleBillJson) &
            t.state.inSet({'review', 'approved', 'paying'}),
        transaction: w.tx,
      ) >
      0;

  /// Three drivers: the published courier login, when the café has one,
  /// and two simulated drivers with no login ([sampleDrivers]). Their
  /// availability starts fresh each day. A driver still named with the old
  /// suffix ("Sam · Sample") is renamed in place, never duplicated.
  static Future<int> _seedDrivers(Work w, String Function(int) email) async {
    final s = w.s;
    final rid = w.tenant;
    final courier = await Membership.db.findFirstRow(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.role.equals('courier') &
          t.active.equals(true),
      transaction: w.tx,
    );
    final existing = <String, Driver>{};
    for (final d in await Driver.db.find(
      s,
      where: (t) => t.restaurantId.equals(rid),
      orderBy: (t) => t.id,
      transaction: w.tx,
    )) {
      final name = plain(d.name);
      if (name == d.name) {
        existing[name] = d;
        continue;
      }
      if (existing.containsKey(name) ||
          await Driver.db.count(
                s,
                where: (t) => t.restaurantId.equals(rid) & t.name.equals(name),
                transaction: w.tx,
              ) >
              0) {
        // Its plain twin already exists: retire the old copy, keep its jobs.
        d
          ..active = false
          ..status = 'offline'
          ..version += 1
          ..updatedAt = _now();
        await Driver.db.updateRow(s, d, transaction: w.tx);
        continue;
      }
      d
        ..name = name
        ..version += 1
        ..updatedAt = _now();
      existing[name] = await Driver.db.updateRow(s, d, transaction: w.tx);
    }
    final wanted = [
      if (courier != null)
        ('Courier (demo login)', courier.userId, 'bike', email(1).isEmpty ? null : email(1), 'offline'),
      ('Sam', null, 'bike', null, 'available'),
      ('Ines', null, 'scooter', null, 'available'),
    ];
    var added = 0;
    for (final (name, userId, vehicle, payout, status) in wanted) {
      final d = existing[name];
      if (d == null) {
        await Driver.db.insertRow(
          s,
          Driver(
            restaurantId: rid,
            kind: 'staff',
            userId: userId,
            name: name,
            vehicle: vehicle,
            payoutEmail: payout,
            status: status,
            lastSeenAt: status == 'available' ? _now() : null,
            active: true,
            version: 1,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        added++;
      } else if (userId == null) {
        d
          ..status = status
          ..active = true
          ..lastSeenAt = _now()
          ..version += 1
          ..updatedAt = _now();
        await Driver.db.updateRow(s, d, transaction: w.tx);
      }
    }
    return added;
  }

  /// The simulator partner, "Demo Delivery Co.", is created through
  /// `partner.app.save` so its key is shown once and kept outside the
  /// database (see `tool/judge_restaurant.cjs partner`). The reset only keeps
  /// it named, marked as a simulator and switched on.
  static Future<int> _seedPartner(Work w) async {
    final id = simulatorPartnerId;
    if (id == null) return 0;
    final app = await PartnerApp.db.findById(w.s, id, transaction: w.tx);
    if (app == null || app.restaurantId != w.tenant) return 0;
    app
      ..name = 'Demo Delivery Co. (simulator)'
      ..simulator = true
      ..active = true
      ..version += 1
      ..updatedAt = _now();
    await PartnerApp.db.updateRow(w.s, app, transaction: w.tx);
    return 1;
  }

  /// A catering deposit already asked for, so the receivables page has
  /// something owed: a pay link (`link`, `open`) made the way
  /// `request.create` makes one, so its QR code really opens PayPal Sandbox.
  /// A judge's own links nobody opened (no checkout yet) are removed after
  /// a while; anything opened or paid stays.
  static Future<int> _seedPayLink(Work w, String Function(int) email) async {
    final s = w.s;
    final rid = w.tenant;
    await PaymentRequest.db.deleteWhere(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.kind.equals('link') &
          t.state.equals('open') &
          t.checkoutIntentId.equals(null) &
          t.description.notLike(_sampleLink) &
          (t.createdAt < _now().subtract(const Duration(minutes: 10))),
      transaction: w.tx,
    );
    final have = await PaymentRequest.db.count(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.description.like(_sampleLink) &
          t.state.inSet({'draft', 'open', 'sent'}),
      transaction: w.tx,
    );
    if (have > 0) return 0;
    final catering = await CateringRequest.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(rid),
      orderBy: (t) => t.id.desc(),
      transaction: w.tx,
    );
    // Whole seconds: the link's token is derived from the creation time.
    final now = _now();
    final created = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch ~/ 1000 * 1000,
      isUtc: true,
    );
    var r = await PaymentRequest.db.insertRow(
      s,
      PaymentRequest(
        restaurantId: rid,
        kind: 'link',
        payerName: 'Studio Lumen',
        payerEmail: email(0).isEmpty ? null : email(0),
        description: 'Catering deposit · Friday lunch for 12 (sample)',
        amountMinor: 3555,
        currency: w.restaurant!.currency,
        dueAt: created.add(const Duration(days: 2)),
        state: 'open',
        linkTokenHash: 'pending:${_uuid()}',
        remindersSent: 0,
        cateringRequestId: catering?.id,
        createdBy: await _owner(w),
        version: 1,
        createdAt: created,
        updatedAt: created,
      ),
      transaction: w.tx,
    );
    try {
      r.linkTokenHash = _hash(PaymentRequestModule.token(r));
      r = await PaymentRequest.db.updateRow(s, r, transaction: w.tx);
    } on DomainError {
      // No pay-link secret on this deployment: the request is listed, but
      // its link cannot be opened until one is configured.
    }
    return 1;
  }

  /// The franchise demo: "Atelier Group · Sample" holds both judges' cafés.
  /// The café's owner owns the group and its published manager is an area
  /// manager, who may read the group's pages but changes nothing in a café
  /// without that café's own membership. Uses `RAYSTO_JUDGE_GROUP_ID` when
  /// set; otherwise the group the café already belongs to, or a new one.
  static Future<int> _seedGroup(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    final second = secondRestaurantId;
    if (rid != restaurantId || second == null) return 0;
    final owner = await _owner(w);
    RestaurantGroup? group;
    if (groupId != null) {
      group = await RestaurantGroup.db.findById(s, groupId!, transaction: w.tx);
    }
    if (group == null) {
      final link = await GroupVenue.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(rid),
        transaction: w.tx,
      );
      if (link != null) {
        group = await RestaurantGroup.db.findById(s, link.groupId, transaction: w.tx);
      }
    }
    var created = 0;
    group ??= await () async {
      created = 1;
      return RestaurantGroup.db.insertRow(
        s,
        RestaurantGroup(
          name: groupName,
          ownerUserId: owner,
          currency: w.restaurant!.currency,
          version: 1,
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
    }();
    if (group.name != groupName) {
      group
        ..name = groupName
        ..version += 1
        ..updatedAt = _now();
      group = await RestaurantGroup.db.updateRow(s, group, transaction: w.tx);
    }
    final gid = group.id!;
    await GroupVenue.db.insert(s, [
      for (final venueId in [rid, second])
        GroupVenue(
          groupId: gid,
          restaurantId: venueId,
          attachedBy: owner,
          attachedAt: _now(),
        ),
    ], transaction: w.tx, ignoreConflicts: true);
    final managers = await Membership.db.find(
      s,
      where: (t) =>
          t.restaurantId.equals(rid) &
          t.role.equals('manager') &
          t.active.equals(true),
      transaction: w.tx,
    );
    await GroupMembership.db.insert(s, [
      GroupMembership(
        groupId: gid,
        userId: owner,
        role: 'owner',
        active: true,
        version: 1,
        createdAt: _now(),
      ),
      for (final m in managers)
        GroupMembership(
          groupId: gid,
          userId: m.userId,
          role: 'areaManager',
          active: true,
          version: 1,
          createdAt: _now(),
        ),
    ], transaction: w.tx, ignoreConflicts: true);
    return created;
  }

  static Future<String> _owner(Work w) async {
    final m = await Membership.db.findFirstRow(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.role.equals('owner') &
          t.active.equals(true),
      transaction: w.tx,
    );
    return m?.userId ?? w.user;
  }

  /// The second café's back office: its own stock, its bills and its own
  /// stored sample history (a quieter café than the first, with two staff),
  /// so the group pages compare a busy café with a quiet one.
  static Future<Json> seedSecond(Work w) async {
    final s = w.s;
    final rid = w.tenant;
    final suppliers = await Supplier.db.find(
      s,
      where: (t) => t.restaurantId.equals(rid),
      transaction: w.tx,
    );
    final supplier = suppliers.isNotEmpty
        ? suppliers.first
        : await Supplier.db.insertRow(
            s,
            Supplier(
              restaurantId: rid,
              name: 'Marché Dupont',
              payoutEmail: 'supplier-harbour@example.com',
              version: 1,
              createdAt: _now(),
            ),
            transaction: w.tx,
          );
    final stock = await _seedStock(w, supplier.id);
    final recipes = await _seedRecipes(w, stock);
    final bills = await _seedBills(w, (_) => '');
    final history = await JudgeHistory.seed(w);
    return {
      'stock': stock.length,
      'recipes': recipes,
      'bills': bills,
      'history': history,
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
    if (JudgeStory017.active) {
      await AgentModule.asAgent(s, rid, JudgeStory017.beforeReset);
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
      await JudgeStory017.finishReset(w);
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
      final readBills = menuOnly ? 0 : await _releaseReadBills(w, before);
      if (!full) {
        final result = {
          'released': released,
          'completed': completed,
          'cancelled': cancelled,
          'expired': expired,
          'readBills': readBills,
        };
        if (result.values.any((n) => n > 0)) {
          await w.audit('judge.tidy', 'restaurant', rid, result);
        }
        return result;
      }

      final second = rid == secondRestaurantId;
      final policy = w.policy!;
      final target = second ? secondSettings : settings;
      policy.settingsJson = jsonEncode(
        CatalogueModule.validateSettings({
          ..._json(policy.settingsJson),
          ...target,
        }),
      );
      policy.version++;
      policy.updatedAt = _now();
      await RestaurantPolicy.db.updateRow(s, policy, transaction: w.tx);
      w.restaurant!.name = second ? secondName : name;
      w.restaurant!.deliveryFeeMinor = target['deliveryFeeMinor'] as int;
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
      final seeded = menuOnly
          ? const <String, dynamic>{}
          : second
          ? await seedSecond(w)
          : await seed(w);
      final result = {
        'released': released,
        'completed': completed,
        'cancelled': cancelled,
        'expired': expired,
        'readBills': readBills,
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
