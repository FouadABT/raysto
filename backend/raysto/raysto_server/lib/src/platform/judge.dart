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

  static String? _queued;

  /// Queues the daily reset at 09:00 UTC, night across the Americas.
  static Future<void> schedule(Session s) async {
    final rid = restaurantId;
    final now = _now();
    final day = now.toIso8601String().substring(0, 10);
    if (rid == null || now.hour < 9 || _queued == '$rid:$day') return;
    await PlatformJob.db.insert(s, [
      PlatformJob(
        restaurantId: rid,
        kind: 'judge.reset',
        dedupeKey: 'judge-reset:$rid:$day',
        payloadJson: jsonEncode({'restaurantId': rid}),
        state: 'pending',
        attempts: 0,
        availableAt: now,
        createdAt: now,
      ),
    ], ignoreConflicts: true);
    _queued = '$rid:$day';
  }

  /// A manager of the judges' café starts it fresh. Work from the last ten
  /// minutes is kept, so another judge in the middle of a demo keeps theirs.
  static Future<Json> command(Session s, PlatformCommand c) async {
    await _mutate(s, c, 'judge.reset', (w, d) async {
      _keys(d, {});
      if (!venue(w.tenant)) {
        _fail('forbidden', 'Only the judges’ café starts fresh.');
      }
      await _rate(s, 'judge-reset:${w.tenant}', 2, w.tx);
      await w.audit('judge.reset_requested', 'restaurant', w.tenant);
      return {};
    }, roles: _managers);
    return reset(s, c.restaurantId!, quiet: const Duration(minutes: 10));
  }

  /// Returns the café to its starting menu and settings. Nothing is deleted:
  /// orders are completed or cancelled and checkouts released through the
  /// same steps staff use, and PayPal is read before any checkout is freed.
  static Future<Json> reset(
    Session s,
    int rid, {
    Duration quiet = const Duration(hours: 1),
  }) async {
    if (!venue(rid)) {
      _fail('forbidden', 'Only the judges’ café starts fresh.');
    }
    final before = _now().subtract(quiet);
    var released = 0;
    final open = await CheckoutIntent.db.find(
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
      final orders = await PurchaseOrder.db.find(
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
      final pending = await AgentAction.db.find(
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
      final result = {
        'released': released,
        'completed': completed,
        'cancelled': cancelled,
        'expired': expired,
        'dishes': items.length,
        'menuVersion': policy.menuVersion,
      };
      await w.audit('judge.reset', 'restaurant', rid, result);
      return result;
    });
  }
}
