import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'persistence.dart';

part 'fixtures.dart';

/// One local world. Domain operations are owned by this store, never by a screen.
class DemoStore extends ChangeNotifier {
  DemoStore({DemoPersistence? persistence})
    : persistence = persistence ?? MemoryDemoPersistence() {
    _seed();
  }
  final DemoPersistence persistence;
  static const schemaVersion = 1;
  static const fixtureVersion = 1;
  static const demoPassword = 'RaystoDemo123!';
  static const demoVerificationCode = '123456';
  final List<DemoAccount> _accounts = [];
  final List<Restaurant> _restaurants = [];
  final List<MenuItem> _menuItems = [];
  final List<DemoTable> _tables = [];
  final List<FloorObject> _floorObjects = [];
  final List<TableVisit> _visits = [];
  final List<Cart> _carts = [];
  final List<Order> _orders = [];
  final List<CheckoutAttempt> _attempts = [];
  final List<Payment> _payments = [];
  final List<Refund> _refunds = [];
  final List<ServiceRequest> _requests = [];
  final List<DeliveryTask> _deliveries = [];
  final List<Reservation> _reservations = [];
  final List<WaitlistEntry> _waitlist = [];
  final List<DemoNotification> _notifications = [];
  final List<ActivityEvent> _activity = [];
  final List<SupportMessage> _supportMessages = [];
  final List<LocalReview> _reviews = [];
  final Map<String, List<MenuItem>> _importDrafts = {};
  final Map<String, Future<CheckoutAttempt>> _runningPayments = {};
  final Map<String, Timer> _paymentTimers = {};
  final Map<String, Completer<CheckoutAttempt>> _paymentCompleters = {};
  DemoSettings settings = DemoSettings();
  DateTime now = DateTime.utc(2026, 10, 24, 12);
  int generation = 0, _sequence = 100;
  String _accountId = 'guest', _restaurantId = 'olive';
  bool sessionActive = false, online = true, _disposed = false;
  String delayMode = 'normal', scenario = 'A';
  PaymentOutcome nextPaymentOutcome = PaymentOutcome.success;
  String? persistenceError, restorationNotice;
  Future<void> _pendingWrite = Future<void>.value();

  static Future<DemoStore> open({DemoPersistence? persistence}) async {
    final store = DemoStore(
      persistence: persistence ?? SharedPreferencesDemoPersistence(),
    );
    await store.restore();
    return store;
  }

  List<DemoAccount> get accounts => List.unmodifiable(_accounts);
  List<Restaurant> get restaurants => List.unmodifiable(_restaurants);
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  List<DemoTable> get tables => List.unmodifiable(_tables);
  List<FloorObject> get floorObjects => List.unmodifiable(_floorObjects);
  List<TableVisit> get visits => List.unmodifiable(_visits);
  List<Order> get orders => List.unmodifiable(_orders);
  List<CheckoutAttempt> get attempts => List.unmodifiable(_attempts);
  List<Payment> get payments => List.unmodifiable(_payments);
  List<Refund> get refunds => List.unmodifiable(_refunds);
  List<ServiceRequest> get requests => List.unmodifiable(_requests);
  List<DeliveryTask> get deliveries => List.unmodifiable(_deliveries);
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<WaitlistEntry> get waitlist => List.unmodifiable(_waitlist);
  List<DemoNotification> get notifications => List.unmodifiable(_notifications);
  List<ActivityEvent> get activity => List.unmodifiable(_activity);
  List<SupportMessage> get supportMessages =>
      _supportMessages.where((m) => m.accountId == _accountId).toList();
  List<LocalReview> get reviews =>
      _reviews.where((r) => r.accountId == _accountId).toList();
  List<MenuItem> get importDraft =>
      List.unmodifiable(_importDrafts[_restaurantId] ?? []);
  List<CheckoutAttempt> get visibleAttempts => _attempts
      .where(
        (a) => currentAccount.isStaff
            ? _isManagement && a.restaurantId == currentAccount.restaurantId
            : a.accountId == _accountId ||
                  a.visitId != null && _canAccessVisitId(a.visitId!),
      )
      .toList();
  DemoAccount get currentAccount =>
      _accounts.firstWhere((a) => a.id == _accountId);
  Restaurant get currentRestaurant => restaurantById(_restaurantId);
  List<MenuItem> get restaurantMenu => _menuItems
      .where((m) => m.restaurantId == _restaurantId && !m.archived)
      .toList();
  List<DemoTable> get restaurantTables =>
      _tables.where((t) => t.restaurantId == _restaurantId).toList();
  List<Order> get visibleOrders =>
      _orders.where(canAccessOrder).toList().reversed.toList();
  List<ServiceRequest> get visibleRequests => _requests
      .where((r) => _canAccessVisitId(r.visitId))
      .toList()
      .reversed
      .toList();
  List<DeliveryTask> get visibleDeliveries => _deliveries
      .where(
        (d) =>
            d.restaurantId == _restaurantId &&
            (currentAccount.role == DemoRole.courier
                ? d.courierId == _accountId
                : _isManagement),
      )
      .toList();
  List<Reservation> get visibleReservations => _reservations
      .where(
        (r) => currentAccount.isStaff
            ? r.restaurantId == _restaurantId
            : r.accountId == _accountId,
      )
      .toList();
  List<DemoNotification> get visibleNotifications => _notifications
      .where(
        (n) =>
            !n.dismissed &&
            (n.accountId == _accountId ||
                (n.accountId == 'staff' &&
                    currentAccount.isStaff &&
                    n.restaurantId == _restaurantId)),
      )
      .toList()
      .reversed
      .toList();
  List<ActivityEvent> get visibleActivity => _activity
      .where(
        (e) =>
            e.restaurantId == _restaurantId &&
            (currentAccount.isStaff || e.accountId == _accountId),
      )
      .toList()
      .reversed
      .toList();
  TableVisit? get activeVisit => _visits
      .where(
        (v) =>
            v.active &&
            v.restaurantId == _restaurantId &&
            v.participantIds.contains(_accountId),
      )
      .firstOrNull;
  Cart get cart => _cartFor(_accountId, _restaurantId);
  bool get _isManagement =>
      [DemoRole.owner, DemoRole.manager].contains(currentAccount.role);
  bool get isManagement => _isManagement;
  bool get isStaff => currentAccount.isStaff;
  String _id(String prefix) => '$prefix-${++_sequence}';
  Restaurant restaurantById(String id) => _restaurants.firstWhere(
    (r) => r.id == id,
    orElse: () => throw const DomainException('Restaurant not found.'),
  );
  List<OpeningInterval> parseOpeningHours(String hours) {
    final pattern = RegExp(r'(\d{1,2}):(\d{2})\s*[–—-]\s*(\d{1,2}):(\d{2})');
    final matches = pattern.allMatches(hours).toList();
    final remainder = hours.replaceAll(pattern, '').trim();
    if (matches.isEmpty ||
        !RegExp(
          r'^(?:every\s*day|daily|mon\s*[–—-]\s*sun)?[\s·,:;]*$',
          caseSensitive: false,
        ).hasMatch(remainder)) {
      throw const DomainException(
        'Use daily opening intervals such as 11:00–22:00 or 11:00–14:00, 18:00–22:00.',
      );
    }
    return matches.map((m) {
      final startHour = int.parse(m[1]!),
          startMinute = int.parse(m[2]!),
          endHour = int.parse(m[3]!),
          endMinute = int.parse(m[4]!);
      final start = startHour * 60 + startMinute,
          end = endHour * 60 + endMinute;
      if (startHour > 23 ||
          startMinute > 59 ||
          endHour > 24 ||
          endMinute > 59 ||
          endHour == 24 && endMinute != 0 ||
          start == end) {
        throw const DomainException(
          'Use valid 24-hour times and a closing time different from opening.',
        );
      }
      return OpeningInterval(start, end);
    }).toList();
  }

  bool isRestaurantOpen(Restaurant restaurant, {DateTime? at}) {
    if (!restaurant.open) {
      return false;
    }
    try {
      return parseOpeningHours(
        restaurant.hours,
      ).any((interval) => interval.contains(at ?? now));
    } on DomainException {
      return false;
    }
  }

  MenuItem itemById(String id) => _menuItems.firstWhere(
    (m) => m.id == id,
    orElse: () => throw const DomainException('Menu item not found.'),
  );
  DemoTable tableById(String id) => _tables.firstWhere(
    (t) => t.id == id,
    orElse: () => throw const DomainException('Table not found.'),
  );
  TableVisit visitById(String id) => _visits.firstWhere(
    (v) => v.id == id,
    orElse: () => throw const DomainException('Visit not found.'),
  );
  Order orderById(String id) => _orders.firstWhere(
    (o) => o.id == id,
    orElse: () => throw const DomainException('Order not found.'),
  );
  CheckoutAttempt attemptById(String id) => _attempts.firstWhere(
    (a) => a.id == id,
    orElse: () => throw const DomainException('Payment attempt not found.'),
  );

  void _changed() {
    if (_disposed) return;
    final encoded = jsonEncode(toJson());
    _pendingWrite = _pendingWrite.catchError((Object _) {}).then((_) async {
      final previousError = persistenceError;
      try {
        await persistence.write(encoded);
        persistenceError = null;
      } catch (_) {
        persistenceError =
            'Changes are in memory. Local storage could not be updated; retry saving.';
      }
      if (!_disposed && previousError != persistenceError) {
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> flush() async {
    await _pendingWrite;
  }

  Future<void> retryPersistence() async {
    _changed();
    await flush();
  }

  Future<void> restore() async {
    try {
      final stored = await persistence.read();
      if (stored != null) {
        final j = jsonDecode(stored) as Map<String, dynamic>;
        if (j['schemaVersion'] == schemaVersion &&
            j['fixtureVersion'] == fixtureVersion) {
          _load(j);
        } else {
          restorationNotice =
              'The demo fixtures were updated; a fresh local world is ready.';
        }
      }
    } catch (_) {
      _seed();
      restorationNotice =
          'The saved demo could not be read; the original fixtures were restored.';
    }
    _changed();
  }

  Json toJson() => {
    'schemaVersion': schemaVersion,
    'fixtureVersion': fixtureVersion,
    'generation': generation,
    'sequence': _sequence,
    'now': now.toIso8601String(),
    'accountId': _accountId,
    'restaurantId': _restaurantId,
    'sessionActive': sessionActive,
    'online': online,
    'delayMode': delayMode,
    'scenario': scenario,
    'nextPaymentOutcome': nextPaymentOutcome.name,
    'settings': settings.toJson(),
    'accounts': _accounts.map((e) => e.toJson()).toList(),
    'restaurants': _restaurants.map((e) => e.toJson()).toList(),
    'menuItems': _menuItems.map((e) => e.toJson()).toList(),
    'tables': _tables.map((e) => e.toJson()).toList(),
    'floorObjects': _floorObjects.map((e) => e.toJson()).toList(),
    'visits': _visits.map((e) => e.toJson()).toList(),
    'carts': _carts.map((e) => e.toJson()).toList(),
    'orders': _orders.map((e) => e.toJson()).toList(),
    'attempts': _attempts.map((e) => e.toJson()).toList(),
    'payments': _payments.map((e) => e.toJson()).toList(),
    'refunds': _refunds.map((e) => e.toJson()).toList(),
    'requests': _requests.map((e) => e.toJson()).toList(),
    'deliveries': _deliveries.map((e) => e.toJson()).toList(),
    'reservations': _reservations.map((e) => e.toJson()).toList(),
    'waitlist': _waitlist.map((e) => e.toJson()).toList(),
    'notifications': _notifications.map((e) => e.toJson()).toList(),
    'activity': _activity.map((e) => e.toJson()).toList(),
    'supportMessages': _supportMessages.map((e) => e.toJson()).toList(),
    'reviews': _reviews.map((e) => e.toJson()).toList(),
    'importDrafts': _importDrafts.map(
      (k, v) => MapEntry(k, v.map((i) => i.toJson()).toList()),
    ),
  };
  void _load(Json j) {
    void replace<T>(List<T> target, String key, T Function(Json) parse) {
      target
        ..clear()
        ..addAll(readList(j, key, parse));
    }

    replace(_accounts, 'accounts', DemoAccount.fromJson);
    replace(_restaurants, 'restaurants', Restaurant.fromJson);
    replace(_menuItems, 'menuItems', MenuItem.fromJson);
    replace(_tables, 'tables', DemoTable.fromJson);
    replace(_floorObjects, 'floorObjects', FloorObject.fromJson);
    replace(_visits, 'visits', TableVisit.fromJson);
    replace(_carts, 'carts', Cart.fromJson);
    replace(_orders, 'orders', Order.fromJson);
    replace(_attempts, 'attempts', CheckoutAttempt.fromJson);
    replace(_payments, 'payments', Payment.fromJson);
    replace(_refunds, 'refunds', Refund.fromJson);
    replace(_requests, 'requests', ServiceRequest.fromJson);
    replace(_deliveries, 'deliveries', DeliveryTask.fromJson);
    replace(_reservations, 'reservations', Reservation.fromJson);
    replace(_waitlist, 'waitlist', WaitlistEntry.fromJson);
    replace(_notifications, 'notifications', DemoNotification.fromJson);
    replace(_activity, 'activity', ActivityEvent.fromJson);
    replace(_supportMessages, 'supportMessages', SupportMessage.fromJson);
    replace(_reviews, 'reviews', LocalReview.fromJson);
    _importDrafts.clear();
    (j['importDrafts'] as Map? ?? {}).forEach((k, v) {
      _importDrafts[k as String] = (v as List)
          .map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
    generation = j['generation'] ?? 0;
    _sequence = j['sequence'] ?? 100;
    now = date(j['now']);
    _accountId = j['accountId'] ?? 'guest';
    _restaurantId = j['restaurantId'] ?? 'olive';
    sessionActive = j['sessionActive'] ?? false;
    online = j['online'] ?? true;
    delayMode = j['delayMode'] ?? 'normal';
    scenario = j['scenario'] ?? 'A';
    nextPaymentOutcome = enumValue(
      PaymentOutcome.values,
      j['nextPaymentOutcome'],
      PaymentOutcome.success,
    );
    settings = DemoSettings.fromJson(
      Map<String, dynamic>.from(j['settings'] ?? {}),
    );
    if (!_accounts.any((a) => a.id == _accountId) ||
        !_restaurants.any((r) => r.id == _restaurantId)) {
      throw const FormatException('Invalid demo identity');
    }
  }

  void _event(
    String title, {
    String? restaurantId,
    String? accountId,
    String target = '',
    String detail = '',
  }) {
    _activity.add(
      ActivityEvent(
        id: _id('event'),
        restaurantId: restaurantId ?? _restaurantId,
        accountId: accountId ?? _accountId,
        title: title,
        createdAt: now,
        target: target,
        detail: detail,
      ),
    );
  }

  void _notify(
    String title,
    String body, {
    required String accountId,
    String? restaurantId,
    String target = '',
  }) {
    _notifications.add(
      DemoNotification(
        id: _id('notice'),
        accountId: accountId,
        restaurantId: restaurantId ?? _restaurantId,
        title: title,
        body: body,
        createdAt: now,
        target: target,
      ),
    );
  }

  void _requireStaff(String restaurantId, List<DemoRole> allowed) {
    if (!currentAccount.active ||
        !currentAccount.hasRestaurantAccess(restaurantId) ||
        !allowed.contains(currentAccount.role)) {
      throw const DomainException(
        'This account does not have permission for this restaurant action.',
      );
    }
  }

  void requireManagement([String? restaurantId]) => _requireStaff(
    restaurantId ?? _restaurantId,
    [DemoRole.owner, DemoRole.manager],
  );
  bool canAccessOrder(Order order) {
    if (currentAccount.isStaff) {
      if (order.restaurantId != currentAccount.restaurantId ||
          order.restaurantId != _restaurantId) {
        return false;
      }
      if (currentAccount.role == DemoRole.courier) {
        return _deliveries.any(
          (d) => d.orderId == order.id && d.courierId == _accountId,
        );
      }
      if (currentAccount.role == DemoRole.waiter && order.visitId != null) {
        return _waiterAssigned(visitById(order.visitId!).tableId);
      }
      return true;
    }
    return order.accountId == _accountId ||
        (order.visitId != null &&
            _visits.any(
              (v) =>
                  v.id == order.visitId &&
                  v.participantIds.contains(_accountId),
            ));
  }

  bool _waiterAssigned(String tableId) =>
      currentAccount.role != DemoRole.waiter ||
      currentAccount.assignedTableIds.contains(tableId);
  bool _canAccessVisitId(String id) {
    final v = visitById(id);
    if (currentAccount.isStaff) {
      return currentAccount.restaurantId == v.restaurantId &&
          [
            DemoRole.owner,
            DemoRole.manager,
            DemoRole.waiter,
          ].contains(currentAccount.role) &&
          _waiterAssigned(v.tableId);
    }
    return v.participantIds.contains(_accountId);
  }

  bool canAccessVisit(TableVisit visit) => _canAccessVisitId(visit.id);
  void _requireVisit(String id, {bool staff = false}) {
    if (!_canAccessVisitId(id) || staff && !currentAccount.isStaff) {
      throw const DomainException(
        'This visit belongs to another party or is outside your assignments.',
      );
    }
  }

  void switchAccount(String id) {
    final a = _accounts.firstWhere(
      (a) => a.id == id,
      orElse: () => throw const DomainException('Demo account not found.'),
    );
    if (!a.active) {
      throw const DomainException('This demo team account is deactivated.');
    }
    _accountId = a.id;
    if (a.restaurantId != null) _restaurantId = a.restaurantId!;
    sessionActive = true;
    _changed();
  }

  void selectRestaurant(String id) {
    final r = restaurantById(id);
    if (currentAccount.isStaff && !currentAccount.hasRestaurantAccess(id)) {
      throw const DomainException(
        'This staff account only has access to its assigned restaurant.',
      );
    }
    if (!currentAccount.isStaff && !r.published) {
      throw const DomainException('This restaurant is still a local draft.');
    }
    _restaurantId = id;
    if (currentAccount.isStaff) {
      currentAccount.restaurantId = id;
    }
    _changed();
  }

  void signIn(String email, String password) {
    final a = _accounts
        .where((a) => a.email.toLowerCase() == email.trim().toLowerCase())
        .firstOrNull;
    if (a == null || password != demoPassword) {
      throw const DomainException(
        'Use a listed demo email and RaystoDemo123!.',
      );
    }
    switchAccount(a.id);
  }

  DemoAccount createAccount(String name, String email, String password) {
    if (name.trim().length < 2) {
      throw const DomainException('Enter a name with at least two characters.');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) {
      throw const DomainException(
        'Enter a valid email format for this local demo.',
      );
    }
    if (password.length < 8) {
      throw const DomainException(
        'Use at least eight characters for the demonstration.',
      );
    }
    if (_accounts.any(
      (a) => a.email.toLowerCase() == email.trim().toLowerCase(),
    )) {
      throw const DomainException(
        'This local email already has a demo account.',
      );
    }
    final a = DemoAccount(
      id: _id('customer'),
      email: email.trim(),
      name: name.trim(),
      role: DemoRole.customer,
    );
    _accounts.add(a);
    switchAccount(a.id);
    return a;
  }

  void signOut() {
    sessionActive = false;
    _accountId = 'guest';
    _changed();
  }

  void updateProfile({String? name, String? avatar}) {
    if (name != null && name.trim().length < 2) {
      throw const DomainException('Enter at least two characters.');
    }
    if (name != null) currentAccount.name = name.trim();
    if (avatar != null) currentAccount.avatar = avatar;
    _changed();
  }

  void updateOnboardingStep(int step) {
    currentAccount.onboardingStep = step.clamp(0, 10);
    _changed();
  }

  void completeOnboarding() {
    currentAccount.onboardingComplete = true;
    currentAccount.onboardingStep = 10;
    _changed();
  }

  void replayOnboarding() {
    currentAccount.onboardingComplete = false;
    currentAccount.onboardingStep = 0;
    _changed();
  }

  void updateSettings({
    String? locale,
    String? appearance,
    bool? reducedMotion,
    bool? haptics,
    double? textScale,
  }) {
    if (locale != null && ['en', 'fr', 'ar'].contains(locale)) {
      settings.locale = locale;
    }
    if (appearance != null &&
        ['system', 'light', 'dark'].contains(appearance)) {
      settings.appearance = appearance;
    }
    if (reducedMotion != null) settings.reducedMotion = reducedMotion;
    if (haptics != null) settings.haptics = haptics;
    if (textScale != null) settings.textScale = textScale.clamp(1.0, 2.0);
    _changed();
  }

  void setPermission(String key, String value) {
    settings.permissions[key] = value;
    _changed();
  }

  void setNotificationPreference(String key, bool value) {
    settings.notifications[key] = value;
    _changed();
  }

  void setPreference(String key, bool value) {
    currentAccount.preferences[key] = value;
    _changed();
  }

  void toggleFavorite(String id) {
    if (!currentAccount.favorites.add(id)) currentAccount.favorites.remove(id);
    _changed();
  }

  void saveAddress(Address address) {
    if (address.street.trim().length < 4 || address.city.trim().isEmpty) {
      throw const DomainException('Enter a street address and city.');
    }
    final a = address.copyWith(
      eligible: [
        'demo central',
        'central',
      ].contains(address.city.trim().toLowerCase()),
    );
    final addresses = currentAccount.addresses;
    final index = addresses.indexWhere((v) => v.id == a.id);
    if (index < 0) {
      addresses.add(a);
    } else {
      addresses[index] = a;
    }
    if (a.isDefault) {
      currentAccount.addresses = addresses
          .map((v) => v.copyWith(isDefault: v.id == a.id))
          .toList();
    }
    _changed();
  }

  void deleteAddress(String id) {
    currentAccount.addresses.removeWhere((a) => a.id == id);
    _changed();
  }

  void setDefaultAddress(String id) {
    if (!currentAccount.addresses.any((a) => a.id == id)) {
      throw const DomainException('Address not found.');
    }
    currentAccount.addresses = currentAccount.addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
    _changed();
  }

  void resetPersonal() {
    currentAccount.preferences.clear();
    currentAccount.favorites.clear();
    currentAccount.addresses.clear();
    currentAccount.onboardingComplete = false;
    currentAccount.onboardingStep = 0;
    _carts.removeWhere((c) => c.accountId == _accountId);
    _supportMessages.removeWhere((m) => m.accountId == _accountId);
    _reviews.removeWhere((r) => r.accountId == _accountId);
    settings = DemoSettings();
    _changed();
  }

  void resetWorld() {
    generation++;
    _cancelDomainOperations();
    _seed();
    _changed();
  }

  void setConnectivity(bool value) {
    online = value;
    _changed();
  }

  void setPaymentOutcome(PaymentOutcome value) {
    nextPaymentOutcome = value;
    _changed();
  }

  void setDelayMode(String value) {
    if (!['instant', 'normal', 'slow'].contains(value)) {
      throw const DomainException('Unknown delay preset.');
    }
    delayMode = value;
    _changed();
  }

  void advanceTime(Duration value) {
    if (value.isNegative) {
      throw const DomainException('The demo clock only moves forward.');
    }
    now = now.add(value);
    _changed();
  }

  Future<void> simulateViewDelay() => Future<void>.delayed(
    Duration(
      milliseconds: delayMode == 'instant'
          ? 0
          : delayMode == 'slow'
          ? 1800
          : 350,
    ),
  );

  Cart _cartFor(String accountId, String restaurantId) {
    final existing = _carts
        .where(
          (c) => c.accountId == accountId && c.restaurantId == restaurantId,
        )
        .firstOrNull;
    if (existing != null) return existing;
    final c = Cart(
      accountId: accountId,
      restaurantId: restaurantId,
      pickupSlot: 'As soon as possible',
    );
    _carts.add(c);
    return c;
  }

  CartTotals cartTotals([Cart? value]) {
    final c = value ?? cart;
    final r = restaurantById(c.restaurantId);
    final subtotal = c.lines.fold<int>(0, (s, l) => s + l.subtotalMinor);
    return CartTotals(
      subtotalMinor: subtotal,
      discountMinor: c.coupon == 'FRESH10' ? (subtotal * 0.1).round() : 0,
      deliveryFeeMinor: c.mode == ServiceMode.delivery ? r.deliveryFeeMinor : 0,
      tipMinor: c.tipMinor,
      currency: r.currency,
    );
  }

  CartLine _line(
    MenuItem item, {
    required String id,
    int quantity = 1,
    Map<String, List<String>> selections = const {},
    String note = '',
  }) {
    if (quantity < 1 || quantity > 99) {
      throw const DomainException('Choose a quantity from 1 to 99.');
    }
    if (!item.available || item.archived) {
      throw DomainException(
        '${item.name} is unavailable. Remove it or choose a replacement.',
      );
    }
    final modifiers = <ModifierOption>[];
    for (final key in selections.keys) {
      if (!item.modifierGroups.any((g) => g.id == key)) {
        throw const DomainException(
          'A selected modifier group is no longer available.',
        );
      }
    }
    for (final g in item.modifierGroups) {
      final selected = selections[g.id] ?? [];
      if (selected.toSet().length != selected.length ||
          selected.length < g.minSelections ||
          selected.length > g.maxSelections) {
        throw DomainException(
          'Choose ${g.minSelections}–${g.maxSelections} options for ${g.name}.',
        );
      }
      for (final id in selected) {
        final o = g.options.where((o) => o.id == id).firstOrNull;
        if (o == null) {
          throw DomainException(
            'An option in ${g.name} is no longer available.',
          );
        }
        modifiers.add(o);
      }
    }
    return CartLine(
      id: id,
      itemId: item.id,
      name: item.name,
      unitPriceMinor: item.priceMinor,
      quantity: quantity,
      modifiers: List.unmodifiable(modifiers),
      selections: selections.map(
        (k, v) => MapEntry(k, List<String>.unmodifiable(v)),
      ),
      note: note.trim(),
    );
  }

  void addToCart(
    String itemId, {
    int quantity = 1,
    Map<String, List<String>> selections = const {},
    String note = '',
  }) {
    final m = itemById(itemId);
    if (m.restaurantId != _restaurantId) {
      throw const DomainException(
        'Switch to this restaurant before adding its dishes.',
      );
    }
    if (currentAccount.isStaff &&
        ![
          DemoRole.owner,
          DemoRole.manager,
          DemoRole.waiter,
        ].contains(currentAccount.role)) {
      throw const DomainException('This role cannot build customer orders.');
    }
    cart.lines.add(
      _line(
        m,
        id: _id('line'),
        quantity: quantity,
        selections: selections,
        note: note,
      ),
    );
    cart.revision++;
    _changed();
  }

  void updateCartLine(
    String lineId, {
    int? quantity,
    String? note,
    Map<String, List<String>>? selections,
  }) {
    final index = cart.lines.indexWhere((l) => l.id == lineId);
    if (index < 0) throw const DomainException('Cart item not found.');
    final old = cart.lines[index];
    cart.lines[index] = _line(
      itemById(old.itemId),
      id: old.id,
      quantity: quantity ?? old.quantity,
      note: note ?? old.note,
      selections: selections ?? old.selections,
    );
    cart.revision++;
    _changed();
  }

  CartLine removeCartLine(String lineId) {
    final line = cart.lines.firstWhere(
      (l) => l.id == lineId,
      orElse: () => throw const DomainException('Cart item not found.'),
    );
    cart.lines.remove(line);
    cart.revision++;
    _changed();
    return line;
  }

  void restoreCartLine(CartLine line) {
    if (cart.lines.any((l) => l.id == line.id)) return;
    if (itemById(line.itemId).restaurantId != _restaurantId) {
      throw const DomainException(
        'Switch back to the original restaurant to restore this item.',
      );
    }
    cart.lines.add(line);
    cart.revision++;
    _changed();
  }

  void clearCart() {
    cart.lines.clear();
    cart.coupon = '';
    cart.tipMinor = 0;
    cart.revision++;
    _changed();
  }

  void configureCart({
    ServiceMode? mode,
    String? visitId,
    String? addressId,
    String? pickupSlot,
    int? tipMinor,
  }) {
    if (mode != null) {
      if (!currentRestaurant.services.contains(mode)) {
        throw const DomainException('This service is not enabled.');
      }
    }
    if (visitId != null) {
      _requireVisit(visitId);
      final v = visitById(visitId);
      if (!v.active || v.restaurantId != _restaurantId) {
        throw const DomainException(
          'This visit is no longer active in this restaurant.',
        );
      }
    }
    if (pickupSlot != null) {
      if (!currentRestaurant.pickupSlots.contains(
        pickupSlot == 'As soon as possible' ? 'ASAP' : pickupSlot,
      )) {
        throw const DomainException('Choose an available demo pickup slot.');
      }
    }
    if (tipMinor != null) {
      if (tipMinor < 0) {
        throw const DomainException('A tip cannot be negative.');
      }
    }
    if (mode != null) {
      cart.mode = mode;
      if (mode != ServiceMode.dineIn) {
        cart.visitId = null;
      }
    }
    if (visitId != null) {
      cart.visitId = visitId;
      cart.mode = ServiceMode.dineIn;
    }
    if (addressId != null) {
      cart.addressId = addressId;
    }
    if (pickupSlot != null) {
      cart.pickupSlot = pickupSlot;
    }
    if (tipMinor != null) {
      cart.tipMinor = tipMinor;
    }
    cart.revision++;
    _changed();
  }

  void applyCoupon(String code) {
    final value = code.trim().toUpperCase();
    if (value == 'EXPIRED') {
      throw const DomainException('This demo coupon has expired. Try FRESH10.');
    }
    if (value.isNotEmpty && value != 'FRESH10') {
      throw const DomainException(
        'Coupon not found. The demo code is FRESH10.',
      );
    }
    cart.coupon = value;
    cart.revision++;
    _changed();
  }

  List<CartLine> proposeBasket({
    int budgetMinor = 2500,
    bool vegetarian = true,
  }) {
    final ids = [
      '$_restaurantId-bowl',
      '$_restaurantId-wrap',
      '$_restaurantId-lemonade',
    ];
    final candidates = <MenuItem>[];
    for (final id in ids) {
      final desired = _menuItems
          .where((m) => m.id == id && m.available && !m.archived)
          .firstOrNull;
      final fallback = restaurantMenu
          .where(
            (m) =>
                m.available &&
                !candidates.contains(m) &&
                (candidates.isNotEmpty ||
                    !vegetarian ||
                    m.dietary.contains('vegetarian')),
          )
          .firstOrNull;
      if (desired != null) {
        candidates.add(desired);
      } else if (fallback != null) {
        candidates.add(fallback);
      }
    }
    final lines = <CartLine>[];
    for (final item in candidates) {
      final selections = <String, List<String>>{};
      for (final g in item.modifierGroups) {
        selections[g.id] = g.options
            .take(g.minSelections)
            .map((o) => o.id)
            .toList();
      }
      lines.add(_line(item, id: _id('proposal'), selections: selections));
    }
    final proposal = Cart(
      accountId: _accountId,
      restaurantId: _restaurantId,
      lines: lines,
      mode: cart.mode,
    );
    while (lines.isNotEmpty && cartTotals(proposal).totalMinor > budgetMinor) {
      lines.removeLast();
    }
    if (lines.isEmpty) {
      throw const DomainException(
        'No available basket fits this budget. Increase it or ask staff.',
      );
    }
    return lines;
  }

  void applyProposal(List<CartLine> lines) {
    final validated = lines.map((l) {
      final item = itemById(l.itemId);
      if (item.restaurantId != _restaurantId) {
        throw const DomainException(
          'The proposal belongs to another restaurant.',
        );
      }
      return _line(
        item,
        id: _id('line'),
        quantity: l.quantity,
        selections: l.selections,
        note: l.note,
      );
    }).toList();
    cart.lines = validated;
    cart.revision++;
    _changed();
  }

  void referenceBasket() => applyProposal(proposeBasket());
  void reorder(String orderId) {
    final order = orderById(orderId);
    if (!canAccessOrder(order)) {
      throw const DomainException(
        'This order is not available to this account.',
      );
    }
    selectRestaurant(order.restaurantId);
    final lines = order.lines
        .map(
          (l) => _line(
            itemById(l.itemId),
            id: _id('line'),
            quantity: l.quantity,
            selections: l.selections,
            note: l.note,
          ),
        )
        .toList();
    cart.lines = lines;
    cart.revision++;
    _changed();
  }

  void _validateCart(Cart c) {
    final r = restaurantById(c.restaurantId);
    if (!isRestaurantOpen(r) || !r.published) {
      throw const DomainException(
        'This restaurant is not taking new orders. Your basket is saved.',
      );
    }
    if (!r.services.contains(c.mode)) {
      throw const DomainException(
        'This service is currently paused. Choose another service.',
      );
    }
    if (c.lines.isEmpty) {
      throw const DomainException('Add at least one item before checkout.');
    }
    for (final l in c.lines) {
      final latest = _line(
        itemById(l.itemId),
        id: l.id,
        quantity: l.quantity,
        selections: l.selections,
        note: l.note,
      );
      if (latest.subtotalMinor != l.subtotalMinor) {
        throw DomainException(
          '${l.name} has a new price. Edit the basket item to review it.',
        );
      }
    }
    if (c.mode == ServiceMode.dineIn) {
      if (c.visitId == null) {
        throw const DomainException(
          'Start or join a table visit before dine-in checkout.',
        );
      }
      _requireVisit(c.visitId!);
      if (!visitById(c.visitId!).active) {
        throw const DomainException('This table visit has closed.');
      }
    }
    if (c.mode == ServiceMode.delivery) {
      final address = currentAccount.addresses
          .where((a) => a.id == c.addressId)
          .firstOrNull;
      if (address == null || !address.eligible) {
        throw const DomainException('Choose an address inside Demo Central.');
      }
      if (cartTotals(c).subtotalMinor < r.minimumDeliveryMinor) {
        throw const DomainException(
          'The delivery minimum has not been reached.',
        );
      }
    }
    if (c.mode == ServiceMode.pickup &&
        (c.pickupSlot == null ||
            !r.pickupSlots.contains(
              c.pickupSlot == 'As soon as possible' ? 'ASAP' : c.pickupSlot,
            ))) {
      throw const DomainException('Choose an available pickup slot.');
    }
    if (c.mode == ServiceMode.delivery && r.deliverySlots.isEmpty) {
      throw const DomainException(
        'Delivery slots are currently unavailable. Your basket is saved.',
      );
    }
  }

  CheckoutAttempt beginCheckout({
    bool payAtEnd = false,
    String method = 'Demo PayPal',
  }) {
    if (method.toLowerCase().contains('cash')) {
      throw const DomainException(
        'Cash collection requires the explicit authorized staff bill action.',
      );
    }
    final c = cart;
    final duplicate = _attempts
        .where(
          (a) =>
              a.accountId == _accountId &&
              a.restaurantId == _restaurantId &&
              (a.status == AttemptStatus.pending ||
                  (a.cartRevision == c.revision &&
                      a.status == AttemptStatus.succeeded)) &&
              a.allocations.isEmpty,
        )
        .lastOrNull;
    if (duplicate != null) return duplicate;
    _validateCart(c);
    if (payAtEnd &&
        (c.mode != ServiceMode.dineIn ||
            (!currentRestaurant.payAtEnd && !currentAccount.isStaff))) {
      throw const DomainException(
        'Pay at end is only available for an eligible table visit.',
      );
    }
    if (payAtEnd && currentAccount.isStaff) {
      _requireStaff(c.restaurantId, [
        DemoRole.owner,
        DemoRole.manager,
        DemoRole.waiter,
      ]);
    }
    if (c.visitId != null &&
        !payAtEnd &&
        _attempts.any(
          (a) => a.visitId == c.visitId && a.status == AttemptStatus.pending,
        )) {
      throw const DomainException(
        'A payment is already in progress for this visit. Resume it before starting another.',
      );
    }
    final frozen = Cart.fromJson(c.toJson());
    final totals = cartTotals(frozen);
    final address = currentAccount.addresses
        .where((a) => a.id == c.addressId)
        .firstOrNull;
    final a = CheckoutAttempt(
      id: _id('attempt'),
      accountId: _accountId,
      restaurantId: _restaurantId,
      totalMinor: totals.totalMinor,
      createdAt: now,
      snapshot: frozen,
      visitId: c.visitId,
      cartRevision: c.revision,
      generation: generation,
      method: payAtEnd ? 'Pay at end' : method,
      deliveryFeeMinor: totals.deliveryFeeMinor,
      discountMinor: totals.discountMinor,
      tipMinor: totals.tipMinor,
      address: address == null
          ? null
          : '${address.street}, ${address.city}\n${address.instructions}',
    );
    _attempts.add(a);
    if (payAtEnd) {
      a.status = AttemptStatus.succeeded;
      a.orderId = _releaseOrder(a).id;
      _consumeCart(a);
    }
    _event(
      payAtEnd ? 'Unpaid order submitted' : 'Demo checkout started',
      target: a.id,
    );
    _changed();
    return a;
  }

  Order _releaseOrder(CheckoutAttempt a) {
    if (a.orderId != null) return orderById(a.orderId!);
    final c = a.snapshot;
    final order = Order(
      id: _id('order'),
      restaurantId: a.restaurantId,
      accountId: a.accountId,
      mode: c.mode,
      lines: c.lines.map((l) => CartLine.fromJson(l.toJson())).toList(),
      totalMinor: a.totalMinor,
      createdAt: now,
      visitId: a.visitId,
      deliveryFeeMinor: a.deliveryFeeMinor,
      discountMinor: a.discountMinor,
      tipMinor: a.tipMinor,
      address: a.address,
      pickupSlot: c.pickupSlot,
      events: ['${now.toIso8601String()} · submitted'],
    );
    _orders.add(order);
    a.orderId = order.id;
    if (order.mode == ServiceMode.delivery) {
      _deliveries.add(
        DeliveryTask(
          id: _id('delivery'),
          restaurantId: order.restaurantId,
          orderId: order.id,
          address: order.address ?? 'Demo Central',
          createdAt: now,
        ),
      );
    }
    _notify(
      'New order',
      order.id,
      accountId: 'staff',
      restaurantId: order.restaurantId,
      target: order.id,
    );
    _notify(
      'Order submitted',
      'The restaurant can now accept your order.',
      accountId: order.accountId,
      restaurantId: order.restaurantId,
      target: order.id,
    );
    return order;
  }

  void _consumeCart(CheckoutAttempt a) {
    final c = _cartFor(a.accountId, a.restaurantId);
    if (c.revision == a.cartRevision) {
      c.lines.clear();
      c.coupon = '';
      c.tipMinor = 0;
    } else {
      final frozenIds = a.snapshot.lines.map((l) => l.id).toSet();
      c.lines.removeWhere(
        (l) =>
            frozenIds.contains(l.id) &&
            a.snapshot.lines.any(
              (f) =>
                  f.id == l.id &&
                  jsonEncode(f.toJson()) == jsonEncode(l.toJson()),
            ),
      );
    }
  }

  Future<CheckoutAttempt> simulatePayment(String attemptId) {
    _authorizeAttempt(attemptById(attemptId));
    final existing = _runningPayments[attemptId];
    if (existing != null) return existing;
    final a = attemptById(attemptId);
    final capturedGeneration = generation;
    final outcome = nextPaymentOutcome;
    final completer = Completer<CheckoutAttempt>();
    _paymentCompleters[attemptId] = completer;
    _runningPayments[attemptId] = completer.future;
    _paymentTimers[attemptId] = Timer(
      Duration(
        milliseconds: delayMode == 'instant'
            ? 0
            : delayMode == 'slow'
            ? 1800
            : 350,
      ),
      () {
        _paymentTimers.remove(attemptId);
        _paymentCompleters.remove(attemptId);
        _runningPayments.remove(attemptId);
        if (!_disposed &&
            capturedGeneration == generation &&
            _attempts.contains(a)) {
          _resolvePayment(a, outcome);
        }
        if (!completer.isCompleted) {
          completer.complete(a);
        }
      },
    );
    return completer.future;
  }

  void _cancelDomainOperations() {
    for (final timer in _paymentTimers.values) {
      timer.cancel();
    }
    for (final entry in _paymentCompleters.entries) {
      final attempt = _attempts.where((a) => a.id == entry.key).firstOrNull;
      if (attempt != null && !entry.value.isCompleted) {
        entry.value.complete(attempt);
      }
    }
    _paymentTimers.clear();
    _paymentCompleters.clear();
    _runningPayments.clear();
  }

  void resolvePayment(String attemptId, PaymentOutcome outcome) {
    final a = attemptById(attemptId);
    _authorizeAttempt(a);
    _resolvePayment(a, outcome);
  }

  void _authorizeAttempt(CheckoutAttempt a) {
    if (a.accountId != _accountId &&
        !_isManagement &&
        !(a.visitId != null && _canAccessVisitId(a.visitId!))) {
      throw const DomainException('This checkout belongs to another account.');
    }
    if (currentAccount.isStaff &&
        a.restaurantId != currentAccount.restaurantId) {
      throw const DomainException(
        'This checkout belongs to another restaurant.',
      );
    }
  }

  void _resolvePayment(CheckoutAttempt a, PaymentOutcome outcome) {
    if (a.status != AttemptStatus.pending || a.generation != generation) return;
    if (outcome == PaymentOutcome.pending) {
      _changed();
      return;
    }
    a.status = switch (outcome) {
      PaymentOutcome.success => AttemptStatus.succeeded,
      PaymentOutcome.failed => AttemptStatus.failed,
      PaymentOutcome.cancelled => AttemptStatus.cancelled,
      PaymentOutcome.pending => AttemptStatus.pending,
    };
    if (outcome == PaymentOutcome.success) {
      final allocations = <String, int>{};
      if (a.allocations.isEmpty) {
        final order = _releaseOrder(a);
        allocations[order.id] = a.totalMinor;
        _consumeCart(a);
      } else {
        for (final entry in a.allocations.entries) {
          final due = orderBalance(entry.key);
          if (entry.value > due) {
            a.status = AttemptStatus.failed;
            _notify(
              'Payment needs review',
              'The frozen bill changed. Start a new checkout.',
              accountId: a.accountId,
              restaurantId: a.restaurantId,
              target: a.id,
            );
            _changed();
            return;
          }
          allocations[entry.key] = entry.value;
        }
      }
      if (!_payments.any((p) => p.attemptId == a.id)) {
        _payments.add(
          Payment(
            id: _id('payment'),
            attemptId: a.id,
            restaurantId: a.restaurantId,
            accountId: a.accountId,
            amountMinor: a.totalMinor,
            allocations: Map.unmodifiable(allocations),
            createdAt: now,
            method: a.method,
            visitId: a.visitId,
          ),
        );
      }
      _notify(
        'Demo payment complete',
        'No real payment was made.',
        accountId: a.accountId,
        restaurantId: a.restaurantId,
        target: a.orderId ?? a.id,
      );
    }
    _event(
      'Payment ${a.status.name}',
      restaurantId: a.restaurantId,
      accountId: a.accountId,
      target: a.id,
    );
    _changed();
  }

  CheckoutAttempt beginVisitPayment(
    String visitId, {
    String method = 'Demo PayPal',
  }) {
    _requireVisit(visitId);
    final v = visitById(visitId);
    if (!v.active) throw const DomainException('This visit is closed.');
    final pending = _attempts
        .where((a) => a.visitId == visitId && a.status == AttemptStatus.pending)
        .firstOrNull;
    if (pending != null) return pending;
    final allocations = <String, int>{};
    for (final o in _orders.where((o) => o.visitId == visitId)) {
      final balance = orderBalance(o.id);
      if (balance > 0) allocations[o.id] = balance;
    }
    if (allocations.isEmpty) {
      throw const DomainException('This visit has no outstanding balance.');
    }
    final a = CheckoutAttempt(
      id: _id('attempt'),
      accountId: _accountId,
      restaurantId: v.restaurantId,
      totalMinor: allocations.values.fold(0, (s, n) => s + n),
      createdAt: now,
      snapshot: Cart(
        accountId: _accountId,
        restaurantId: v.restaurantId,
        mode: ServiceMode.dineIn,
        visitId: visitId,
      ),
      visitId: visitId,
      allocations: allocations,
      generation: generation,
      method: method,
    );
    _attempts.add(a);
    _changed();
    return a;
  }

  CheckoutAttempt collectCash(String visitId) {
    final v = visitById(visitId);
    _requireStaff(v.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.waiter,
    ]);
    _requireVisit(visitId, staff: true);
    if (_attempts.any(
      (a) => a.visitId == visitId && a.status == AttemptStatus.pending,
    )) {
      throw const DomainException(
        'Resolve the pending checkout before collecting cash.',
      );
    }
    final a = beginVisitPayment(visitId, method: 'Demo cash');
    _resolvePayment(a, PaymentOutcome.success);
    return a;
  }

  int orderPaid(String orderId) =>
      _payments.fold<int>(0, (sum, p) => sum + (p.allocations[orderId] ?? 0));
  int orderBalance(String orderId) {
    final o = orderById(orderId);
    return o.cancelled ? 0 : math.max(0, o.totalMinor - orderPaid(orderId));
  }

  List<Order> visitOrders(String id) {
    _requireVisit(id);
    return _orders.where((o) => o.visitId == id).toList();
  }

  int visitBalance(String id) => _orders
      .where((o) => o.visitId == id)
      .fold<int>(0, (sum, o) => sum + orderBalance(o.id));
  Refund refundOrder(String orderId, {String reason = 'Customer request'}) {
    final o = orderById(orderId);
    requireManagement(o.restaurantId);
    if (reason.trim().isEmpty) {
      throw const DomainException('Enter a refund reason.');
    }
    final already = _refunds
        .where((r) => r.orderId == orderId)
        .fold<int>(0, (s, r) => s + r.amountMinor);
    final amount = orderPaid(orderId) - already;
    if (amount <= 0) {
      final prior = _refunds.where((r) => r.orderId == orderId).firstOrNull;
      if (prior != null) return prior;
      throw const DomainException(
        'This order has no captured payment to refund.',
      );
    }
    final r = Refund(
      id: _id('refund'),
      orderId: orderId,
      restaurantId: o.restaurantId,
      amountMinor: amount,
      reason: reason,
      createdAt: now,
    );
    _refunds.add(r);
    _event('Demo refund recorded', target: orderId, detail: reason);
    _notify(
      'Demo refund recorded',
      'The preparation history is unchanged.',
      accountId: o.accountId,
      restaurantId: o.restaurantId,
      target: o.id,
    );
    _changed();
    return r;
  }

  List<OrderStatus> allowedOrderTransitions(Order o) {
    if (!canAccessOrder(o)) return [];
    if (!currentAccount.isStaff) {
      return [
        if (o.status == OrderStatus.submitted) OrderStatus.cancelled,
        if (o.status == OrderStatus.ready &&
            o.mode == ServiceMode.pickup &&
            o.accountId == _accountId)
          OrderStatus.collected,
      ];
    }
    final role = currentAccount.role;
    final management = [DemoRole.owner, DemoRole.manager].contains(role);
    final kitchen = management || role == DemoRole.kitchen;
    final waiter = management || role == DemoRole.waiter;
    return switch (o.status) {
      OrderStatus.submitted =>
        management
            ? [
                OrderStatus.accepted,
                OrderStatus.rejected,
                OrderStatus.cancelled,
              ]
            : [],
      OrderStatus.accepted => [
        if (kitchen) OrderStatus.preparing,
        if (management) OrderStatus.cancelled,
      ],
      OrderStatus.preparing => [
        if (kitchen) OrderStatus.ready,
        if (management) OrderStatus.cancelled,
      ],
      OrderStatus.ready => [
        if (o.mode == ServiceMode.dineIn && waiter) OrderStatus.served,
        if (o.mode == ServiceMode.pickup && waiter) OrderStatus.collected,
        if (management) OrderStatus.cancelled,
      ],
      OrderStatus.served ||
      OrderStatus.collected ||
      OrderStatus.delivered => management ? [OrderStatus.completed] : [],
      _ => [],
    };
  }

  void transitionOrder(String id, OrderStatus next, {String reason = ''}) {
    final o = orderById(id);
    if (!allowedOrderTransitions(o).contains(next)) {
      throw const DomainException(
        'This order transition is not permitted for the current role and status.',
      );
    }
    if ([OrderStatus.cancelled, OrderStatus.rejected].contains(next) &&
        reason.trim().isEmpty) {
      throw const DomainException(
        'Enter a reason so the customer knows what happened.',
      );
    }
    if ([OrderStatus.cancelled, OrderStatus.rejected].contains(next) &&
        _attempts.any(
          (a) =>
              a.status == AttemptStatus.pending &&
              a.allocations.containsKey(id),
        )) {
      throw const DomainException(
        'Resolve or cancel the pending bill payment before cancelling this order.',
      );
    }
    o.status = next;
    o.reason = reason;
    o.events.add('${now.toIso8601String()} · ${next.name}');
    if (next == OrderStatus.ready) {
      o.lines = o.lines.map((l) => l.copyWith(completed: true)).toList();
    }
    _event('Order ${next.name}', target: id, detail: reason);
    _notify(
      'Order ${next.name}',
      reason.isEmpty
          ? 'Your preparation and payment statuses are tracked separately.'
          : reason,
      accountId: o.accountId,
      restaurantId: o.restaurantId,
      target: id,
    );
    _changed();
  }

  void completeOrderItem(String orderId, String lineId, bool completed) {
    final o = orderById(orderId);
    _requireStaff(o.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.kitchen,
    ]);
    if (![OrderStatus.accepted, OrderStatus.preparing].contains(o.status)) {
      throw const DomainException(
        'Start this ticket before completing its items.',
      );
    }
    if (o.status == OrderStatus.accepted) o.status = OrderStatus.preparing;
    o.lines = o.lines
        .map((l) => l.id == lineId ? l.copyWith(completed: completed) : l)
        .toList();
    _changed();
  }

  String tablePayload(String tableId) {
    final t = tableById(tableId);
    return 'raysto://table/${t.restaurantId}/${t.id}';
  }

  DemoTable parseTablePayload(String payload) {
    final uri = Uri.tryParse(payload.trim());
    if (uri == null ||
        uri.scheme != 'raysto' ||
        uri.host != 'table' ||
        uri.pathSegments.length != 2) {
      throw const DomainException(
        'Use a Raysto demo table link, for example the bundled Table 06 code.',
      );
    }
    final t = tableById(uri.pathSegments[1]);
    if (t.restaurantId != uri.pathSegments[0] || !t.active) {
      throw const DomainException('This table code is unknown or inactive.');
    }
    return t;
  }

  TableVisit startVisit(String tableId, {int guests = 2}) {
    final t = tableById(tableId);
    final restaurant = restaurantById(t.restaurantId);
    if (!isRestaurantOpen(restaurant) ||
        !restaurant.services.contains(ServiceMode.dineIn)) {
      throw const DomainException(
        'This restaurant is not starting new dine-in visits at the current demo time.',
      );
    }
    if (currentAccount.isStaff) {
      _requireStaff(t.restaurantId, [
        DemoRole.owner,
        DemoRole.manager,
        DemoRole.waiter,
      ]);
      if (!_waiterAssigned(tableId)) {
        throw const DomainException('This table is outside your assignment.');
      }
    }
    if (guests < 1 || guests > t.seats) {
      throw const DomainException(
        'Choose a guest count within this table capacity.',
      );
    }
    if (!t.active ||
        t.status != TableStatus.available ||
        _visits.any((v) => v.active && v.tableId == tableId)) {
      throw const DomainException(
        'This table is unavailable. Ask staff for a current invitation; a table code cannot open another party’s bill.',
      );
    }
    final id = _id('visit');
    final v = TableVisit(
      id: id,
      restaurantId: t.restaurantId,
      tableId: t.id,
      startedAt: now,
      invitation: 'RAYSTO-JOIN-${id.toUpperCase()}',
      invitationExpiresAt: now.add(const Duration(hours: 8)),
      guestCount: guests,
      participantIds: currentAccount.isStaff ? [] : [_accountId],
    );
    _visits.add(v);
    _replaceTable(t.copyWith(status: TableStatus.occupied));
    _restaurantId = t.restaurantId;
    if (!currentAccount.isStaff) {
      cart.mode = ServiceMode.dineIn;
      cart.visitId = v.id;
      cart.revision++;
    }
    _event('Visit started', restaurantId: t.restaurantId, target: v.id);
    _changed();
    return v;
  }

  TableVisit joinVisit(String invitation) {
    final v = _visits
        .where((v) => v.invitation == invitation.trim())
        .firstOrNull;
    if (v == null || !v.active || !now.isBefore(v.invitationExpiresAt)) {
      throw const DomainException(
        'This visit invitation is invalid, expired or closed. Ask staff for a current invitation.',
      );
    }
    if (currentAccount.isStaff) {
      throw const DomainException(
        'Switch to a customer account to join a party.',
      );
    }
    if (!v.participantIds.contains(_accountId)) {
      v.participantIds.add(_accountId);
    }
    _restaurantId = v.restaurantId;
    cart.mode = ServiceMode.dineIn;
    cart.visitId = v.id;
    cart.revision++;
    _changed();
    return v;
  }

  void moveVisit(String visitId, String tableId) {
    final v = visitById(visitId);
    _requireStaff(v.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.waiter,
    ]);
    _requireVisit(visitId, staff: true);
    final target = tableById(tableId);
    if (!v.active ||
        target.restaurantId != v.restaurantId ||
        target.status != TableStatus.available ||
        !target.active ||
        target.seats < v.guestCount) {
      throw const DomainException(
        'Choose an available table in this restaurant with enough seats.',
      );
    }
    final old = tableById(v.tableId);
    _replaceTable(old.copyWith(status: TableStatus.needsReset));
    _replaceTable(target.copyWith(status: TableStatus.occupied));
    v.tableId = target.id;
    _event(
      'Visit moved',
      target: v.id,
      detail: '${old.label} → ${target.label}',
    );
    _changed();
  }

  bool canCloseVisit(String id) {
    final v = visitById(id);
    return v.active &&
        visitBalance(id) == 0 &&
        !_orders.any((o) => o.visitId == id && o.actionable) &&
        !_requests.any(
          (r) =>
              r.visitId == id &&
              [
                RequestStatus.sent,
                RequestStatus.acknowledged,
              ].contains(r.status),
        ) &&
        !_attempts.any(
          (a) => a.visitId == id && a.status == AttemptStatus.pending,
        );
  }

  void closeVisit(String id) {
    final v = visitById(id);
    _requireStaff(v.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.waiter,
    ]);
    _requireVisit(id, staff: true);
    if (!canCloseVisit(id)) {
      throw const DomainException(
        'Settle the bill and resolve active orders, requests and pending payments before closing this visit.',
      );
    }
    v.closedAt = now;
    _replaceTable(
      tableById(v.tableId).copyWith(status: TableStatus.needsReset),
    );
    _event('Visit closed', target: id);
    _changed();
  }

  void resetTable(String id) {
    final t = tableById(id);
    _requireStaff(t.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.waiter,
    ]);
    if (!_waiterAssigned(id) ||
        t.status != TableStatus.needsReset ||
        _visits.any((v) => v.active && v.tableId == id)) {
      throw const DomainException(
        'Only a resolved table awaiting reset can be marked ready.',
      );
    }
    _replaceTable(t.copyWith(status: TableStatus.available));
    _event('Table marked ready', target: id);
    _changed();
  }

  void _replaceTable(DemoTable t) {
    final i = _tables.indexWhere((e) => e.id == t.id);
    if (i < 0) {
      _tables.add(t);
    } else {
      _tables[i] = t;
    }
  }

  void _validateTable(DemoTable table, Iterable<DemoTable> against) {
    if (table.label.trim().isEmpty || table.seats < 1 || table.seats > 20) {
      throw const DomainException('A table needs a label and 1–20 seats.');
    }
    if (table.x < 0 ||
        table.y < 0 ||
        table.x > 1200 ||
        table.y > 1200 ||
        table.width < 24 ||
        table.height < 24 ||
        table.width > 400 ||
        table.height > 400) {
      throw const DomainException(
        'Keep the table inside the room with a sensible size.',
      );
    }
    if (against.any(
      (t) =>
          t.id != table.id &&
          t.restaurantId == table.restaurantId &&
          t.label.trim().toLowerCase() == table.label.trim().toLowerCase(),
    )) {
      throw const DomainException(
        'Table labels must be unique within a restaurant.',
      );
    }
    final occupied = _visits.any((v) => v.active && v.tableId == table.id);
    if (_visits.any(
      (v) => v.active && v.tableId == table.id && v.guestCount > table.seats,
    )) {
      throw const DomainException(
        'Capacity cannot be reduced below the current party size.',
      );
    }
    if (occupied && !table.active) {
      throw const DomainException(
        'Move or close the active visit before deactivating this table.',
      );
    }
  }

  void saveTable(DemoTable table) {
    requireManagement(table.restaurantId);
    _validateTable(table, _tables);
    final previous = _tables.where((t) => t.id == table.id).firstOrNull;
    if (previous != null && previous.restaurantId != table.restaurantId) {
      throw const DomainException(
        'A table ID cannot be reassigned to another restaurant.',
      );
    }
    _replaceTable(
      previous == null ? table : table.copyWith(status: previous.status),
    );
    _changed();
  }

  void deleteTable(String id) {
    final t = tableById(id);
    requireManagement(t.restaurantId);
    if (_visits.any((v) => v.active && v.tableId == id)) {
      throw const DomainException(
        'An occupied table cannot be deleted. Explicitly move or close its visit first.',
      );
    }
    _tables.removeWhere((t) => t.id == id);
    _changed();
  }

  void saveFloorPlan(List<DemoTable> tables, List<FloorObject> objects) {
    requireManagement();
    if (tables.any(
          (t) => _tables.any(
            (old) => old.id == t.id && old.restaurantId != t.restaurantId,
          ),
        ) ||
        objects.any(
          (o) => _floorObjects.any(
            (old) => old.id == o.id && old.restaurantId != o.restaurantId,
          ),
        )) {
      throw const DomainException(
        'Floor object IDs cannot be moved between restaurants.',
      );
    }
    if (tables.any((t) => t.restaurantId != _restaurantId) ||
        objects.any((o) => o.restaurantId != _restaurantId)) {
      throw const DomainException(
        'A floor plan cannot contain another restaurant’s objects.',
      );
    }
    if (tables.map((t) => t.id).toSet().length != tables.length ||
        objects.map((o) => o.id).toSet().length != objects.length) {
      throw const DomainException('Floor object IDs must be unique.');
    }
    for (final old in restaurantTables) {
      if (!tables.any((t) => t.id == old.id) &&
          _visits.any((v) => v.active && v.tableId == old.id)) {
        throw const DomainException(
          'An occupied table cannot be removed from the plan.',
        );
      }
    }
    for (final table in tables) {
      _validateTable(table, tables);
    }
    for (final o in objects) {
      if (o.x < 0 ||
          o.y < 0 ||
          o.x > 1200 ||
          o.y > 1200 ||
          o.width <= 0 ||
          o.height <= 0) {
        throw const DomainException('Keep floor objects within the room.');
      }
    }
    final oldStatuses = {for (final t in restaurantTables) t.id: t.status};
    _tables.removeWhere((t) => t.restaurantId == _restaurantId);
    _tables.addAll(
      tables.map(
        (t) => t.copyWith(status: oldStatuses[t.id] ?? TableStatus.available),
      ),
    );
    _floorObjects.removeWhere((o) => o.restaurantId == _restaurantId);
    _floorObjects.addAll(objects);
    _event('Floor plan saved');
    _changed();
  }

  ServiceRequest requestService(
    String kind, {
    String? visitId,
    String note = '',
  }) {
    final v = visitById(
      visitId ??
          activeVisit?.id ??
          (throw const DomainException(
            'Join a table visit before requesting service.',
          )),
    );
    _requireVisit(v.id);
    if (!v.active) throw const DomainException('This visit is closed.');
    final duplicate = _requests
        .where(
          (r) =>
              r.visitId == v.id &&
              r.kind == kind &&
              [
                RequestStatus.sent,
                RequestStatus.acknowledged,
              ].contains(r.status),
        )
        .firstOrNull;
    if (duplicate != null) return duplicate;
    final r = ServiceRequest(
      id: _id('request'),
      restaurantId: v.restaurantId,
      visitId: v.id,
      accountId: _accountId,
      kind: kind,
      createdAt: now,
      note: note,
    );
    _requests.add(r);
    _event(
      'Service requested',
      restaurantId: v.restaurantId,
      target: r.id,
      detail: kind,
    );
    _notify(
      'Table service request',
      kind,
      accountId: 'staff',
      restaurantId: v.restaurantId,
      target: r.id,
    );
    _changed();
    return r;
  }

  void transitionRequest(
    String id,
    RequestStatus next, {
    String reason = '',
    String? assigneeId,
  }) {
    final r = _requests.firstWhere((r) => r.id == id);
    _requireVisit(r.visitId);
    if (next != RequestStatus.cancelled) {
      _requireStaff(r.restaurantId, [
        DemoRole.owner,
        DemoRole.manager,
        DemoRole.waiter,
      ]);
    }
    if (![RequestStatus.sent, RequestStatus.acknowledged].contains(r.status)) {
      throw const DomainException('This request is already resolved.');
    }
    if (next == RequestStatus.sent) {
      throw const DomainException('A request cannot return to sent.');
    }
    if (next == RequestStatus.cancelled && reason.trim().isEmpty) {
      throw const DomainException('Enter a cancellation reason.');
    }
    if (assigneeId != null) {
      requireManagement(r.restaurantId);
      final a = _accounts.firstWhere((a) => a.id == assigneeId);
      if (a.restaurantId != r.restaurantId ||
          !a.active ||
          a.role != DemoRole.waiter) {
        throw const DomainException(
          'Choose an active waiter at this restaurant.',
        );
      }
      r.assigneeId = assigneeId;
    }
    r.status = next;
    r.reason = reason;
    _event('Service request ${next.name}', target: id);
    _changed();
  }

  void _validateMenuItem(MenuItem item) {
    requireManagement(item.restaurantId);
    if (_menuItems.any(
      (old) => old.id == item.id && old.restaurantId != item.restaurantId,
    )) {
      throw const DomainException(
        'A menu item ID cannot be reassigned to another restaurant.',
      );
    }
    if (item.name.trim().length < 2 ||
        item.category.trim().isEmpty ||
        item.priceMinor < 0) {
      throw const DomainException(
        'Enter an item name, category and a valid non-negative price.',
      );
    }
    for (final g in item.modifierGroups) {
      if (g.name.trim().isEmpty ||
          g.minSelections < 0 ||
          g.maxSelections < g.minSelections ||
          g.maxSelections > g.options.length ||
          g.options.any((o) => o.name.trim().isEmpty || o.priceMinor < 0)) {
        throw const DomainException(
          'Check modifier names, prices and selection limits.',
        );
      }
    }
    if (item.modifierGroups.map((g) => g.id).toSet().length !=
            item.modifierGroups.length ||
        item.modifierGroups.any(
          (g) => g.options.map((o) => o.id).toSet().length != g.options.length,
        )) {
      throw const DomainException(
        'Modifier groups and options need unique IDs.',
      );
    }
  }

  void saveMenuItem(MenuItem item) {
    _validateMenuItem(item);
    final i = _menuItems.indexWhere((m) => m.id == item.id);
    if (i < 0) {
      _menuItems.add(item);
    } else {
      _menuItems[i] = item;
    }
    _event('Menu item saved', target: item.id);
    _changed();
  }

  MenuItem duplicateMenuItem(String id) {
    final old = itemById(id);
    final item = old.copyWith(id: _id('menu'), name: '${old.name} copy');
    saveMenuItem(item);
    return item;
  }

  void archiveMenuItem(String id) =>
      saveMenuItem(itemById(id).copyWith(archived: true));
  void setAvailability(String id, bool value) {
    final item = itemById(id);
    _requireStaff(item.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.kitchen,
    ]);
    _menuItems[_menuItems.indexOf(item)] = item.copyWith(available: value);
    _event(
      value ? 'Item available' : 'Item unavailable',
      target: id,
      detail: item.name,
    );
    _changed();
  }

  void saveRestaurant(Restaurant value) {
    requireManagement(value.id);
    parseOpeningHours(value.hours);
    final old = restaurantById(value.id);
    if (currentAccount.role == DemoRole.manager &&
        (old.plan != value.plan ||
            old.payAtEnd != value.payAtEnd ||
            old.paypalConnected != value.paypalConnected)) {
      throw const DomainException(
        'Only the owner may change billing or payment policy.',
      );
    }
    if (value.name.trim().length < 2 ||
        value.deliveryFeeMinor < 0 ||
        value.minimumDeliveryMinor < 0 ||
        value.preparationMinutes < 1 ||
        value.hours.trim().isEmpty) {
      throw const DomainException(
        'Check the restaurant name, hours, fees and preparation time.',
      );
    }
    _restaurants[_restaurants.indexOf(old)] = value;
    _event('Restaurant settings saved');
    _changed();
  }

  Restaurant createRestaurantDraft(String name) {
    if (currentAccount.role != DemoRole.owner) {
      throw const DomainException(
        'Only an owner can create a demo restaurant draft.',
      );
    }
    if (name.trim().length < 2) {
      throw const DomainException('Enter a restaurant name.');
    }
    final r = Restaurant(
      id: _id('restaurant'),
      name: name.trim(),
      published: false,
      description: 'Local setup draft',
      address: 'Demo Central',
    );
    _restaurants.add(r);
    currentAccount.workspaceIds.add(r.id);
    currentAccount.restaurantId = r.id;
    _restaurantId = r.id;
    _changed();
    return r;
  }

  void publishRestaurant(bool publish) {
    if (publish &&
        (currentRestaurant.address.trim().isEmpty || restaurantMenu.isEmpty)) {
      throw const DomainException(
        'Add an address and at least one menu item before publishing locally.',
      );
    }
    saveRestaurant(currentRestaurant.copyWith(published: publish));
  }

  List<MenuItem> importSampleMenu() {
    requireManagement();
    return [
      MenuItem(
        id: _id('import'),
        restaurantId: _restaurantId,
        name: 'Garden bowl',
        category: 'Bowls',
        priceMinor: 900,
        description:
            'Bundled menu extraction preview. Review before publishing.',
        dietary: ['vegetarian'],
        reviewFlags: [
          if (restaurantMenu.any((m) => m.name == 'Garden bowl'))
            'Possible duplicate: Garden bowl',
        ],
      ),
      MenuItem(
        id: _id('import'),
        restaurantId: _restaurantId,
        name: 'Soup of the day',
        category: 'Small plates',
        priceMinor: 700,
        dietaryKnown: false,
        reviewFlags: ['Confirm ingredients and dietary information'],
      ),
      MenuItem(
        id: _id('import'),
        restaurantId: _restaurantId,
        name: 'Grilled chicken wrap',
        category: 'Wraps',
        priceMinor: 1000,
        description: 'Grilled chicken, crisp salad, flatbread.',
        reviewFlags: [
          if (restaurantMenu.any((m) => m.name == 'Grilled chicken wrap'))
            'Possible duplicate: Grilled chicken wrap',
        ],
      ),
      MenuItem(
        id: _id('import'),
        restaurantId: _restaurantId,
        name: 'House lemonade',
        category: 'Drinks',
        priceMinor: 300,
        description:
            'Lemon, water, a little sugar. Price is a provisional extraction of EUR 3.?0.',
        reviewFlags: ['Confirm unclear lemonade price'],
      ),
    ];
  }

  void publishImport(List<MenuItem> items) {
    requireManagement();
    if (items.any((i) => i.reviewFlags.isNotEmpty)) {
      throw const DomainException(
        'Resolve every flagged field before publishing the import.',
      );
    }
    if (items.any((i) => i.restaurantId != _restaurantId)) {
      throw const DomainException('This import belongs to another restaurant.');
    }
    final names = <String>{...restaurantMenu.map((i) => i.name.toLowerCase())};
    for (final i in items) {
      _validateMenuItem(i);
      if (!names.add(i.name.toLowerCase())) {
        throw DomainException(
          '${i.name} duplicates an existing item. Rename it or discard the duplicate.',
        );
      }
    }
    for (final i in items) {
      final index = _menuItems.indexWhere((old) => old.id == i.id);
      if (index < 0) {
        _menuItems.add(i);
      } else {
        _menuItems[index] = i;
      }
    }
    _importDrafts.remove(_restaurantId);
    _event(
      'Menu import published locally',
      detail: '${items.length} reviewed items',
    );
    _changed();
  }

  void saveImportDraft(List<MenuItem> items) {
    requireManagement();
    if (items.any((i) => i.restaurantId != _restaurantId)) {
      throw const DomainException('This import belongs to another restaurant.');
    }
    _importDrafts[_restaurantId] = List.from(items);
    _changed();
  }

  void clearImportDraft() {
    requireManagement();
    _importDrafts.remove(_restaurantId);
    _changed();
  }

  void updateVisit(String id, {int? guests, String? note}) {
    final visit = visitById(id);
    _requireStaff(visit.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.waiter,
    ]);
    _requireVisit(id, staff: true);
    if (!visit.active) {
      throw const DomainException('This visit has closed.');
    }
    if (guests != null) {
      if (guests < 1 || guests > tableById(visit.tableId).seats) {
        throw const DomainException(
          'Choose a guest count within this table capacity.',
        );
      }
      visit.guestCount = guests;
    }
    if (note != null) {
      visit.note = note;
    }
    _changed();
  }

  void noShowReservation(String id) {
    final reservation = _reservations.firstWhere((r) => r.id == id);
    requireManagement(reservation.restaurantId);
    if (reservation.status != ReservationStatus.confirmed) {
      throw const DomainException(
        'Only an expected reservation can be marked no-show.',
      );
    }
    reservation.status = ReservationStatus.noShow;
    _changed();
  }

  TableVisit seatWaitlist(String id, String tableId) {
    final entry = _waitlist.firstWhere((w) => w.id == id);
    requireManagement(entry.restaurantId);
    if (!entry.active ||
        tableById(tableId).restaurantId != entry.restaurantId) {
      throw const DomainException(
        'Choose an active waiting party and a table in this restaurant.',
      );
    }
    final visit = startVisit(tableId, guests: entry.guests);
    visit.participantIds.add(entry.accountId);
    entry.active = false;
    _changed();
    return visit;
  }

  void setTeamActive(String id, bool value) {
    requireManagement();
    final a = _accounts.firstWhere((a) => a.id == id);
    if (a.restaurantId != _restaurantId ||
        a.role == DemoRole.owner ||
        a.id == _accountId) {
      throw const DomainException('This team account cannot be changed here.');
    }
    a.active = value;
    _event(
      value ? 'Team member activated' : 'Team member deactivated',
      target: id,
    );
    _changed();
  }

  void assignStaff(String accountId, List<String> tableIds) {
    requireManagement();
    final a = _accounts.firstWhere((a) => a.id == accountId);
    if (a.restaurantId != _restaurantId ||
        a.role != DemoRole.waiter ||
        tableIds.any((id) => tableById(id).restaurantId != _restaurantId)) {
      throw const DomainException(
        'Assign restaurant tables to a waiter in this team.',
      );
    }
    a.assignedTableIds = List.from(tableIds);
    for (final table
        in restaurantTables
            .where((t) => t.assignedStaffId == a.id && !tableIds.contains(t.id))
            .toList()) {
      _replaceTable(
        DemoTable.fromJson({...table.toJson(), 'assignedStaffId': null}),
      );
    }
    for (final other in _accounts.where(
      (member) =>
          member.id != a.id &&
          member.restaurantId == _restaurantId &&
          member.role == DemoRole.waiter,
    )) {
      other.assignedTableIds.removeWhere(tableIds.contains);
    }
    for (final id in tableIds) {
      _replaceTable(tableById(id).copyWith(assignedStaffId: a.id));
    }
    _changed();
  }

  DemoAccount inviteTeam({
    required String name,
    required String email,
    required DemoRole role,
  }) {
    requireManagement();
    if (![
          DemoRole.manager,
          DemoRole.waiter,
          DemoRole.kitchen,
          DemoRole.courier,
        ].contains(role) ||
        name.trim().length < 2 ||
        !email.endsWith('.test')) {
      throw const DomainException(
        'Use a name, a fictional .test email and a staff role.',
      );
    }
    if (_accounts.any((a) => a.email == email)) {
      throw const DomainException('That demo team email is already in use.');
    }
    final a = DemoAccount(
      id: _id('staff'),
      email: email,
      name: name,
      role: role,
      restaurantId: _restaurantId,
    );
    _accounts.add(a);
    _event(
      'Local invitation created',
      target: a.id,
      detail: 'No email was sent.',
    );
    _changed();
    return a;
  }

  void assignDelivery(String taskId, String courierId) {
    final d = _deliveries.firstWhere((d) => d.id == taskId);
    requireManagement(d.restaurantId);
    final a = _accounts.firstWhere((a) => a.id == courierId);
    if (a.role != DemoRole.courier ||
        a.restaurantId != d.restaurantId ||
        !a.active ||
        [
          DeliveryStatus.collected,
          DeliveryStatus.outForDelivery,
          DeliveryStatus.delivered,
        ].contains(d.status)) {
      throw const DomainException(
        'Choose an active courier before collection.',
      );
    }
    d.courierId = a.id;
    d.status = DeliveryStatus.assigned;
    _event('Courier assigned', target: d.id);
    _changed();
  }

  void progressDelivery(String id, DeliveryStatus next, {String note = ''}) {
    final d = _deliveries.firstWhere((d) => d.id == id);
    _requireStaff(d.restaurantId, [
      DemoRole.owner,
      DemoRole.manager,
      DemoRole.courier,
    ]);
    if (currentAccount.role == DemoRole.courier && d.courierId != _accountId) {
      throw const DomainException(
        'This delivery is assigned to another courier.',
      );
    }
    final o = orderById(d.orderId);
    final allowed = switch (d.status) {
      DeliveryStatus.assigned => [
        DeliveryStatus.collected,
        DeliveryStatus.issue,
      ],
      DeliveryStatus.collected => [
        DeliveryStatus.outForDelivery,
        DeliveryStatus.issue,
      ],
      DeliveryStatus.outForDelivery => [
        DeliveryStatus.delivered,
        DeliveryStatus.issue,
      ],
      _ => <DeliveryStatus>[],
    };
    if (!allowed.contains(next)) {
      throw const DomainException('This delivery transition is not available.');
    }
    if (next == DeliveryStatus.collected && o.status != OrderStatus.ready) {
      throw const DomainException(
        'The kitchen must mark the order ready before collection.',
      );
    }
    if (next == DeliveryStatus.issue && note.trim().isEmpty) {
      throw const DomainException('Describe the delivery issue.');
    }
    d.status = next;
    d.note = note;
    if (next == DeliveryStatus.issue) d.issue = note;
    if (next == DeliveryStatus.collected) o.status = OrderStatus.collected;
    if (next == DeliveryStatus.delivered) o.status = OrderStatus.delivered;
    o.events.add('${now.toIso8601String()} · delivery ${next.name}');
    _event('Delivery ${next.name}', target: id, detail: note);
    _notify(
      'Delivery ${next.name}',
      note.isEmpty ? 'This is a local delivery simulation.' : note,
      accountId: o.accountId,
      restaurantId: o.restaurantId,
      target: o.id,
    );
    _changed();
  }

  void resolveDeliveryIssue(String id) {
    final d = _deliveries.firstWhere((d) => d.id == id);
    requireManagement(d.restaurantId);
    if (d.status != DeliveryStatus.issue) {
      throw const DomainException('This delivery has no open issue.');
    }
    d.issue = '';
    d.status = orderById(d.orderId).status == OrderStatus.collected
        ? DeliveryStatus.outForDelivery
        : DeliveryStatus.assigned;
    _event('Delivery issue resolved', target: id);
    _changed();
  }

  Reservation bookReservation({
    required String restaurantId,
    required DateTime at,
    required int guests,
    String note = '',
  }) {
    final restaurant = restaurantById(restaurantId);
    if (!restaurant.open || !restaurant.services.contains(ServiceMode.dineIn)) {
      throw const DomainException(
        'Reservations are unavailable at this restaurant.',
      );
    }
    if (!at.isAfter(now) ||
        guests < 1 ||
        guests > 8 ||
        !isRestaurantOpen(restaurant, at: at)) {
      throw const DomainException(
        'Choose a future slot during the restaurant’s opening hours for 1–8 guests.',
      );
    }
    final r = Reservation(
      id: _id('reservation'),
      restaurantId: restaurantId,
      accountId: _accountId,
      at: at,
      guests: guests,
      note: note,
    );
    _reservations.add(r);
    _notify(
      'Reservation confirmed',
      'Saved in this local demo.',
      accountId: _accountId,
      restaurantId: restaurantId,
      target: r.id,
    );
    _changed();
    return r;
  }

  Reservation _reservation(String id) {
    final r = _reservations.firstWhere((r) => r.id == id);
    if (r.accountId != _accountId) requireManagement(r.restaurantId);
    return r;
  }

  void modifyReservation(String id, {DateTime? at, int? guests}) {
    final r = _reservation(id);
    if (r.status != ReservationStatus.confirmed) {
      throw const DomainException(
        'Only a confirmed reservation can be edited.',
      );
    }
    if (at != null &&
            (!at.isAfter(now) ||
                !isRestaurantOpen(restaurantById(r.restaurantId), at: at)) ||
        guests != null && (guests < 1 || guests > 8)) {
      throw const DomainException('Choose an eligible time and 1–8 guests.');
    }
    if (at != null) r.at = at;
    if (guests != null) r.guests = guests;
    _changed();
  }

  void cancelReservation(String id) {
    final r = _reservation(id);
    if (![
      ReservationStatus.confirmed,
      ReservationStatus.arrived,
    ].contains(r.status)) {
      throw const DomainException('This reservation cannot be cancelled now.');
    }
    r.status = ReservationStatus.cancelled;
    _changed();
  }

  void arriveReservation(String id) {
    final r = _reservation(id);
    if (r.status != ReservationStatus.confirmed) {
      throw const DomainException('This reservation is not awaiting arrival.');
    }
    r.status = ReservationStatus.arrived;
    _changed();
  }

  TableVisit seatReservation(String id, String tableId) {
    final r = _reservations.firstWhere((r) => r.id == id);
    requireManagement(r.restaurantId);
    if (![
          ReservationStatus.confirmed,
          ReservationStatus.arrived,
        ].contains(r.status) ||
        tableById(tableId).restaurantId != r.restaurantId) {
      throw const DomainException('Choose an eligible reservation and table.');
    }
    final table = tableById(tableId);
    if (!table.active ||
        table.seats < r.guests ||
        _visits.any((v) => v.active && v.tableId == tableId)) {
      throw const DomainException(
        'Choose an eligible table with enough seats and no active visit.',
      );
    }
    if (table.status == TableStatus.reserved) {
      _replaceTable(table.copyWith(status: TableStatus.available));
    }
    final v = startVisit(tableId, guests: r.guests);
    v.participantIds.add(r.accountId);
    r.status = ReservationStatus.seated;
    r.visitId = v.id;
    _changed();
    return v;
  }

  WaitlistEntry joinWaitlist({int guests = 2}) {
    if (!isRestaurantOpen(currentRestaurant) ||
        !currentRestaurant.services.contains(ServiceMode.dineIn) ||
        guests < 1 ||
        guests > 8) {
      throw const DomainException(
        'Waitlist unavailable; choose 1–8 guests at an open restaurant.',
      );
    }
    final existing = _waitlist
        .where(
          (w) =>
              w.accountId == _accountId &&
              w.restaurantId == _restaurantId &&
              w.active,
        )
        .firstOrNull;
    if (existing != null) return existing;
    final w = WaitlistEntry(
      id: _id('waitlist'),
      restaurantId: _restaurantId,
      accountId: _accountId,
      createdAt: now,
      guests: guests,
    );
    _waitlist.add(w);
    _changed();
    return w;
  }

  void leaveWaitlist(String id) {
    final w = _waitlist.firstWhere((w) => w.id == id);
    if (w.accountId != _accountId) requireManagement(w.restaurantId);
    w.active = false;
    _changed();
  }

  void notifyWaitlist(String id) {
    final w = _waitlist.firstWhere((w) => w.id == id);
    requireManagement(w.restaurantId);
    w.notified = true;
    _notify(
      'Your table may be ready',
      'This is an in-app demo notification. Ask staff to seat your party.',
      accountId: w.accountId,
      restaurantId: w.restaurantId,
      target: w.id,
    );
    _changed();
  }

  void markNotificationRead(String id) {
    final n = visibleNotifications.firstWhere(
      (n) => n.id == id,
      orElse: () => throw const DomainException('Notification not found.'),
    );
    n.read = true;
    _changed();
  }

  void dismissNotification(String id) {
    final n = visibleNotifications.firstWhere(
      (n) => n.id == id,
      orElse: () => throw const DomainException('Notification not found.'),
    );
    n.dismissed = true;
    _changed();
  }

  void addSupportMessage(String text, {String? orderId}) {
    if (text.trim().isEmpty) {
      throw const DomainException('Write a message first.');
    }
    if (orderId != null && !canAccessOrder(orderById(orderId))) {
      throw const DomainException('This order is not available.');
    }
    _supportMessages.add(
      SupportMessage(
        id: _id('message'),
        accountId: _accountId,
        text: text.trim(),
        createdAt: now,
        orderId: orderId,
      ),
    );
    _supportMessages.add(
      SupportMessage(
        id: _id('message'),
        accountId: _accountId,
        text:
            'Local support preview: your note is saved on this device. For this demo, use order tracking or ask a staff demo account to review the issue. No message was sent externally.',
        createdAt: now,
        orderId: orderId,
        fromSupport: true,
      ),
    );
    _changed();
  }

  void saveReview(String orderId, int rating, String note) {
    final o = orderById(orderId);
    if (o.accountId != _accountId || rating < 1 || rating > 5) {
      throw const DomainException('Choose 1–5 stars for your own order.');
    }
    _reviews.removeWhere(
      (r) => r.orderId == orderId && r.accountId == _accountId,
    );
    _reviews.add(
      LocalReview(
        orderId: orderId,
        accountId: _accountId,
        rating: rating,
        note: note,
      ),
    );
    _changed();
  }

  DemoReport report({DateTime? from, DateTime? to}) {
    requireManagement();
    bool within(DateTime d) =>
        (from == null || !d.isBefore(from)) && (to == null || !d.isAfter(to));
    final selected = _orders
        .where(
          (o) =>
              o.restaurantId == _restaurantId &&
              !o.cancelled &&
              within(o.createdAt),
        )
        .toList();
    final mix = <ServiceMode, int>{};
    final items = <String, int>{};
    for (final o in selected) {
      mix[o.mode] = (mix[o.mode] ?? 0) + 1;
      for (final l in o.lines) {
        items[l.name] = (items[l.name] ?? 0) + l.quantity;
      }
    }
    return DemoReport(
      salesMinor: selected.fold(0, (s, o) => s + o.totalMinor),
      capturedMinor: _payments
          .where((p) => p.restaurantId == _restaurantId && within(p.createdAt))
          .fold(0, (s, p) => s + p.amountMinor),
      refundedMinor: _refunds
          .where((r) => r.restaurantId == _restaurantId && within(r.createdAt))
          .fold(0, (s, r) => s + r.amountMinor),
      outstandingMinor: selected.fold(0, (s, o) => s + orderBalance(o.id)),
      orderCount: selected.length,
      channelCounts: mix,
      topItems: items,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    generation++;
    _cancelDomainOperations();
    super.dispose();
  }
}
