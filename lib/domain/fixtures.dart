part of 'store.dart';

extension DemoFixtures on DemoStore {
  void _seed() {
    _importDrafts.clear();
    for (final list in <List>[
      _accounts,
      _restaurants,
      _menuItems,
      _tables,
      _floorObjects,
      _visits,
      _carts,
      _orders,
      _attempts,
      _payments,
      _refunds,
      _requests,
      _deliveries,
      _reservations,
      _waitlist,
      _notifications,
      _activity,
      _supportMessages,
      _reviews,
    ]) {
      list.clear();
    }
    _sequence = 100;
    now = DateTime.utc(2026, 10, 24, 12);
    _accountId = 'guest';
    _restaurantId = 'olive';
    sessionActive = false;
    online = true;
    delayMode = 'normal';
    scenario = 'A';
    nextPaymentOutcome = PaymentOutcome.success;
    settings = DemoSettings();
    const home = Address(
      id: 'customer-home',
      label: 'Home',
      street: '18 Olive Lane',
      city: 'Demo Central',
      instructions: 'Ring the green doorbell.',
      isDefault: true,
    );
    _accounts.addAll([
      DemoAccount(
        id: 'new-customer',
        email: 'new.customer@raysto.test',
        name: 'Noor',
        role: DemoRole.customer,
      ),
      DemoAccount(
        id: 'customer',
        email: 'customer@raysto.test',
        name: 'Alex Morgan',
        role: DemoRole.customer,
        onboardingComplete: true,
        addresses: [home],
        preferences: {'vegetarian': false, 'notifications': true},
        favorites: {'olive', 'olive-bowl'},
      ),
      DemoAccount(
        id: 'diner',
        email: 'diner@raysto.test',
        name: 'Sam Rivera',
        role: DemoRole.customer,
        onboardingComplete: true,
        addresses: [home.copyWith(id: 'diner-home')],
      ),
      DemoAccount(
        id: 'owner',
        email: 'owner@raysto.test',
        name: 'Lina · Owner',
        role: DemoRole.owner,
        restaurantId: 'olive',
        onboardingComplete: true,
      ),
      DemoAccount(
        id: 'manager',
        email: 'manager@raysto.test',
        name: 'Omar · Manager',
        role: DemoRole.manager,
        restaurantId: 'olive',
        onboardingComplete: true,
      ),
      DemoAccount(
        id: 'waiter',
        email: 'waiter@raysto.test',
        name: 'Jules · Waiter',
        role: DemoRole.waiter,
        restaurantId: 'olive',
        onboardingComplete: true,
        assignedTableIds: List.generate(
          12,
          (i) => 'olive-table-${(i + 1).toString().padLeft(2, '0')}',
        ),
      ),
      DemoAccount(
        id: 'kitchen',
        email: 'kitchen@raysto.test',
        name: 'Mina · Kitchen',
        role: DemoRole.kitchen,
        restaurantId: 'olive',
        onboardingComplete: true,
      ),
      DemoAccount(
        id: 'courier',
        email: 'courier@raysto.test',
        name: 'Eli · Courier',
        role: DemoRole.courier,
        restaurantId: 'olive',
        onboardingComplete: true,
      ),
      DemoAccount(
        id: 'harbor-owner',
        email: 'harbor.owner@raysto.test',
        name: 'Rosa · Harbor owner',
        role: DemoRole.owner,
        restaurantId: 'harbor',
        onboardingComplete: true,
      ),
      DemoAccount(
        id: 'guest',
        email: 'guest@raysto.test',
        name: 'Guest',
        role: DemoRole.guest,
        onboardingComplete: true,
      ),
    ]);
    _restaurants.addAll([
      const Restaurant(
        id: 'olive',
        name: 'Olive Kitchen',
        description:
            'Seasonal bowls, warm wraps and a little time around the table.',
        address: '12 Market Walk, Demo Central',
        hours: 'Every day · 11:00–22:00',
        cover: 'assets/images/salad_bowl.jpg',
      ),
      const Restaurant(
        id: 'harbor',
        name: 'Harbor Cafe',
        description: 'Bright lunches, baked favorites and a calm coffee break.',
        address: '4 Harbor Square, Demo Central',
        hours: 'Every day · 11:00–22:00',
        cover: 'assets/images/tomato_pasta.jpg',
      ),
    ]);
    const dressing = ModifierGroup(
      id: 'dressing',
      name: 'Choose your dressing',
      minSelections: 1,
      maxSelections: 1,
      options: [
        ModifierOption(id: 'lemon', name: 'Lemon & olive oil'),
        ModifierOption(id: 'tahini', name: 'Tahini'),
      ],
    );
    const extras = ModifierGroup(
      id: 'extras',
      name: 'Make it yours',
      minSelections: 0,
      maxSelections: 2,
      options: [
        ModifierOption(id: 'avocado', name: 'Extra avocado', priceMinor: 150),
        ModifierOption(id: 'feta', name: 'Feta', priceMinor: 100),
      ],
    );
    const wrapSauce = ModifierGroup(
      id: 'sauce',
      name: 'Choose your sauce',
      minSelections: 1,
      maxSelections: 1,
      options: [
        ModifierOption(id: 'herb', name: 'Herb yogurt'),
        ModifierOption(id: 'spicy', name: 'Spicy tomato'),
      ],
    );
    for (final restaurant in _restaurants) {
      final r = restaurant.id;
      _menuItems.addAll([
        MenuItem(
          id: '$r-bowl',
          restaurantId: r,
          name: 'Garden bowl',
          category: 'Bowls',
          priceMinor: 900,
          description:
              'Chickpeas, avocado, crisp seasonal leaves and bright lemon dressing.',
          ingredients: ['Chickpeas', 'Avocado', 'Lettuce', 'Tomato'],
          dietary: ['vegetarian', 'vegan'],
          modifierGroups: [dressing, extras],
        ),
        MenuItem(
          id: '$r-wrap',
          restaurantId: r,
          name: 'Grilled chicken wrap',
          category: 'Wraps',
          priceMinor: 1000,
          description:
              'Tender grilled chicken and crunchy greens in a warm flatbread. Photo is a labelled salad placeholder.',
          ingredients: ['Chicken', 'Wheat flatbread', 'Lettuce', 'Yogurt'],
          modifierGroups: [wrapSauce],
        ),
        MenuItem(
          id: '$r-lemonade',
          restaurantId: r,
          name: 'Lemonade',
          category: 'Drinks',
          priceMinor: 300,
          description:
              'Fresh lemon, sparkling water and a touch of sugar. Salad photo is an illustrative placeholder.',
          ingredients: ['Lemon', 'Water', 'Sugar'],
          dietary: ['vegetarian', 'vegan'],
        ),
        MenuItem(
          id: '$r-pasta',
          restaurantId: r,
          name: 'Tomato & basil pasta',
          category: 'Warm plates',
          priceMinor: 1200,
          description: 'Farfalle with cherry tomatoes and fragrant basil.',
          asset: 'assets/images/tomato_pasta.jpg',
          ingredients: ['Wheat pasta', 'Tomato', 'Basil'],
          dietary: ['vegetarian'],
          modifierGroups: [extras],
        ),
        MenuItem(
          id: '$r-pizza',
          restaurantId: r,
          name: 'Margherita pizza',
          category: 'Warm plates',
          priceMinor: 1300,
          description: 'Tomato, mozzarella and basil on a crisp baked base.',
          asset: 'assets/images/wood_fired_pizza.jpg',
          ingredients: ['Wheat dough', 'Tomato', 'Mozzarella', 'Basil'],
          dietary: ['vegetarian'],
        ),
        MenuItem(
          id: '$r-falafel',
          restaurantId: r,
          name: 'Falafel wrap',
          category: 'Wraps',
          priceMinor: 850,
          description:
              'Chickpea falafel, crunchy greens and tahini. Salad photo is an illustrative placeholder.',
          ingredients: ['Chickpeas', 'Wheat flatbread', 'Sesame'],
          dietary: ['vegetarian', 'vegan'],
          modifierGroups: [dressing],
        ),
        MenuItem(
          id: '$r-soup',
          restaurantId: r,
          name: 'Soup of the day',
          category: 'Small plates',
          priceMinor: 600,
          description:
              'Ask staff about today’s ingredients. Salad photo is an illustrative placeholder.',
          dietaryKnown: false,
        ),
        MenuItem(
          id: '$r-hummus',
          restaurantId: r,
          name: 'Hummus & flatbread',
          category: 'Small plates',
          priceMinor: 550,
          description:
              'Chickpea hummus with warm bread. Salad photo is an illustrative placeholder.',
          ingredients: ['Chickpeas', 'Sesame', 'Wheat'],
          dietary: ['vegetarian', 'vegan'],
        ),
        MenuItem(
          id: '$r-salad',
          restaurantId: r,
          name: 'Citrus side salad',
          category: 'Small plates',
          priceMinor: 450,
          description: 'Seasonal leaves with citrus and olive oil.',
          ingredients: ['Lettuce', 'Orange', 'Olive oil'],
          dietary: ['vegetarian', 'vegan'],
        ),
        MenuItem(
          id: '$r-cake',
          restaurantId: r,
          name: 'House cake',
          category: 'Something sweet',
          priceMinor: 500,
          description:
              'A changing slice from the kitchen. Ingredients have not been provided. Salad photo is an illustrative placeholder.',
          dietaryKnown: false,
          available: r != 'olive',
        ),
        MenuItem(
          id: '$r-coffee',
          restaurantId: r,
          name: 'Freshly brewed coffee',
          category: 'Drinks',
          priceMinor: 250,
          description:
              'A small cup of freshly brewed coffee. Salad photo is an illustrative placeholder.',
          ingredients: ['Coffee', 'Water'],
          dietary: ['vegetarian', 'vegan'],
        ),
        MenuItem(
          id: '$r-water',
          restaurantId: r,
          name: 'Sparkling water',
          category: 'Drinks',
          priceMinor: 200,
          description:
              'A chilled bottle of sparkling water. Salad photo is an illustrative placeholder.',
          ingredients: ['Water'],
          dietary: ['vegetarian', 'vegan'],
        ),
      ]);
    }
    for (var i = 1; i <= 12; i++) {
      final id = 'olive-table-${i.toString().padLeft(2, '0')}';
      _tables.add(
        DemoTable(
          id: id,
          restaurantId: 'olive',
          label: 'Table ${i.toString().padLeft(2, '0')}',
          seats: i % 4 == 0 ? 6 : 4,
          zone: i <= 6 ? 'Main room' : 'Terrace',
          shape: i.isEven ? 'round' : 'rectangle',
          x: 48 + ((i - 1) % 3) * 144.0,
          y: 56 + ((i - 1) ~/ 3) * 128.0,
          status: i == 6 || i == 2
              ? TableStatus.occupied
              : i == 3
              ? TableStatus.reserved
              : i == 4
              ? TableStatus.needsReset
              : TableStatus.available,
          assignedStaffId: 'waiter',
        ),
      );
    }
    for (var i = 1; i <= 4; i++) {
      _tables.add(
        DemoTable(
          id: 'harbor-table-$i',
          restaurantId: 'harbor',
          label: 'Table $i',
          x: 50 + i * 90.0,
          y: 80,
        ),
      );
    }
    _floorObjects.addAll([
      const FloorObject(
        id: 'olive-wall-1',
        restaurantId: 'olive',
        type: 'wall',
        label: 'Room edge',
        x: 16,
        y: 16,
        width: 480,
        height: 12,
      ),
      const FloorObject(
        id: 'olive-entrance',
        restaurantId: 'olive',
        type: 'entrance',
        label: 'Entrance',
        x: 16,
        y: 560,
        width: 80,
        height: 24,
      ),
      const FloorObject(
        id: 'olive-zone',
        restaurantId: 'olive',
        type: 'zone',
        label: 'Terrace',
        zone: 'Terrace',
        x: 16,
        y: 306,
        width: 480,
        height: 250,
      ),
    ]);
    _visits.addAll([
      TableVisit(
        id: 'visit-06',
        restaurantId: 'olive',
        tableId: 'olive-table-06',
        startedAt: now.subtract(const Duration(minutes: 12)),
        invitation: 'RAYSTO-JOIN-06',
        invitationExpiresAt: now.add(const Duration(hours: 8)),
        participantIds: ['diner'],
        guestCount: 2,
      ),
      TableVisit(
        id: 'visit-02',
        restaurantId: 'olive',
        tableId: 'olive-table-02',
        startedAt: now.subtract(const Duration(minutes: 30)),
        invitation: 'RAYSTO-JOIN-02',
        invitationExpiresAt: now.add(const Duration(hours: 8)),
        participantIds: ['fixture-party'],
        guestCount: 3,
      ),
    ]);
    CartLine sampleLine(String id, String itemId, {int quantity = 1}) {
      final item = itemById(itemId);
      return _line(
        item,
        id: id,
        quantity: quantity,
        selections: {
          for (final g in item.modifierGroups)
            g.id: g.options.take(g.minSelections).map((o) => o.id).toList(),
        },
      );
    }

    final history = Order(
      id: 'order-history',
      restaurantId: 'olive',
      accountId: 'customer',
      mode: ServiceMode.pickup,
      lines: [sampleLine('history-line', 'olive-pasta')],
      totalMinor: 1200,
      createdAt: now.subtract(const Duration(days: 1)),
      status: OrderStatus.completed,
      events: ['Collected yesterday'],
    );
    final kitchen = Order(
      id: 'order-kitchen',
      restaurantId: 'olive',
      accountId: 'fixture-party',
      mode: ServiceMode.dineIn,
      visitId: 'visit-02',
      lines: [sampleLine('kitchen-line', 'olive-pizza')],
      totalMinor: 1300,
      createdAt: now.subtract(const Duration(minutes: 15)),
      status: OrderStatus.preparing,
      events: ['Accepted', 'Preparation started'],
    );
    final delivery = Order(
      id: 'order-delivery',
      restaurantId: 'olive',
      accountId: 'customer',
      mode: ServiceMode.delivery,
      lines: [sampleLine('delivery-line', 'olive-pasta')],
      totalMinor: 1400,
      deliveryFeeMinor: 200,
      createdAt: now.subtract(const Duration(minutes: 25)),
      status: OrderStatus.ready,
      address: '18 Olive Lane, Demo Central',
      events: ['Accepted', 'Preparing', 'Ready for collection'],
    );
    final refund = Order(
      id: 'order-refund',
      restaurantId: 'olive',
      accountId: 'customer',
      mode: ServiceMode.pickup,
      lines: [sampleLine('refund-line', 'olive-pizza')],
      totalMinor: 1300,
      createdAt: now.subtract(const Duration(days: 2)),
      status: OrderStatus.cancelled,
      reason: 'Customer changed their plans',
      events: ['Paid', 'Cancelled', 'Refunded'],
    );
    final harbor = Order(
      id: 'order-harbor',
      restaurantId: 'harbor',
      accountId: 'fixture-harbor',
      mode: ServiceMode.pickup,
      lines: [sampleLine('harbor-line', 'harbor-bowl')],
      totalMinor: 900,
      createdAt: now.subtract(const Duration(minutes: 7)),
      status: OrderStatus.submitted,
    );
    _orders.addAll([history, kitchen, delivery, refund, harbor]);
    for (final order in [history, delivery, refund, harbor]) {
      _payments.add(
        Payment(
          id: 'payment-${order.id}',
          attemptId: 'seed-${order.id}',
          restaurantId: order.restaurantId,
          accountId: order.accountId,
          amountMinor: order.totalMinor,
          allocations: {order.id: order.totalMinor},
          createdAt: order.createdAt,
          method: 'Demo PayPal',
        ),
      );
    }
    _refunds.add(
      Refund(
        id: 'refund-example',
        orderId: refund.id,
        restaurantId: 'olive',
        amountMinor: 1300,
        reason: 'Customer changed their plans',
        createdAt: refund.createdAt.add(const Duration(minutes: 3)),
      ),
    );
    _deliveries.add(
      DeliveryTask(
        id: 'delivery-ready',
        restaurantId: 'olive',
        orderId: delivery.id,
        address: delivery.address!,
        createdAt: delivery.createdAt,
        courierId: 'courier',
        status: DeliveryStatus.assigned,
      ),
    );
    _requests.add(
      ServiceRequest(
        id: 'request-water',
        restaurantId: 'olive',
        visitId: 'visit-02',
        accountId: 'fixture-party',
        kind: 'Water',
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
    );
    _reservations.add(
      Reservation(
        id: 'reservation-sample',
        restaurantId: 'olive',
        accountId: 'customer',
        at: now.add(const Duration(hours: 7)),
        guests: 2,
        note: 'A quiet table if possible.',
      ),
    );
    final pendingCart = Cart(
      accountId: 'customer',
      restaurantId: 'olive',
      lines: [sampleLine('pending-line', 'olive-coffee')],
      pickupSlot: 'As soon as possible',
      revision: 500,
    );
    _attempts.add(
      CheckoutAttempt(
        id: 'attempt-pending',
        accountId: 'customer',
        restaurantId: 'olive',
        totalMinor: 250,
        createdAt: now.subtract(const Duration(minutes: 2)),
        snapshot: pendingCart,
        cartRevision: 500,
        generation: generation,
      ),
    );
    _notifications.add(
      DemoNotification(
        id: 'notice-welcome',
        accountId: 'customer',
        restaurantId: 'olive',
        title: 'Your order is ready',
        body: 'The courier can collect the local sample delivery.',
        createdAt: now,
        target: delivery.id,
      ),
    );
    _activity.add(
      ActivityEvent(
        id: 'activity-seed',
        restaurantId: 'olive',
        accountId: 'owner',
        title: 'Kitchen marked a delivery ready',
        createdAt: now.subtract(const Duration(minutes: 2)),
        target: delivery.id,
      ),
    );
  }

  /// Presets replace the world intentionally and invalidate old async callbacks.
  void loadScenario(String letter) {
    final code = letter.toUpperCase();
    if (!'ABCDEFGHIJKL'.split('').contains(code)) {
      throw const DomainException('Choose a scenario from A to L.');
    }
    generation++;
    _cancelDomainOperations();
    _seed();
    scenario = code;
    sessionActive = true;
    if (code == 'A') {
      _accountId = 'new-customer';
    }
    if (['B', 'C', 'F', 'I'].contains(code)) {
      _accountId = 'diner';
      final c = cart;
      c.mode = ServiceMode.dineIn;
      c.visitId = 'visit-06';
    }
    if (code == 'C') {
      _restaurants[0] = _restaurants[0].copyWith(payAtEnd: true);
    }
    if (code == 'D' || code == 'E' || code == 'H' || code == 'K') {
      _accountId = 'customer';
      _attempts.removeWhere((a) => a.id == 'attempt-pending');
    }
    if (code == 'D') {
      cart.mode = ServiceMode.delivery;
      cart.addressId = 'customer-home';
      referenceBasket();
    }
    if (code == 'E') {
      cart.mode = ServiceMode.pickup;
      cart.pickupSlot = 'As soon as possible';
      referenceBasket();
    }
    if (code == 'F') {
      nextPaymentOutcome = PaymentOutcome.pending;
      referenceBasket();
    }
    if (code == 'G' || code == 'J') {
      _accountId = 'owner';
    }
    if (code == 'H') {
      _menuItems[0] = _menuItems[0].copyWith(available: false);
    }
    if (code == 'L') {
      _accountId = 'customer';
      settings = DemoSettings(
        locale: 'ar',
        appearance: 'dark',
        reducedMotion: true,
        textScale: 2,
      );
      online = false;
    }
    _changed();
  }
}
