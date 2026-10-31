part of 'connected_app.dart';

/// One order as the staff boards see it, read from the v2 `orders`, `kitchen`
/// and `order` queries. Everything stays a view over the raw record.
class StaffOrder {
  const StaffOrder(this.raw);
  final Json raw;
  int get id => raw['id'] as int;
  int? get number => raw['number'] as int?;
  String get origin => '${raw['origin'] ?? 'online'}';
  String get fulfillment => '${raw['fulfillment']}';
  String get status => '${raw['status']}';
  String get paymentStatus => '${raw['paymentStatus']}';
  int get totalMinor => (raw['totalMinor'] as num? ?? 0).toInt();
  String get currency => '${raw['currency'] ?? 'EUR'}';
  int get version => raw['version'] as int? ?? 1;
  int? get visitId => raw['visitId'] as int?;
  String? get customerLabel => raw['customerLabel'] as String?;
  String? get pickupCode => raw['pickupCode'] as String?;
  DateTime? get createdAt => DateTime.tryParse('${raw['createdAt'] ?? ''}');
  List<Json> get lines => records(raw['lines']);
  List<Json> get tickets => records(raw['tickets']);
  bool get paid =>
      const {'paid', 'partiallyRefunded', 'refunded'}.contains(paymentStatus);
  bool get open => !const {'completed', 'cancelled', 'rejected'}.contains(status);
  String get title => number == null ? 'Order $id' : '#$number';
  String get channel => origin == 'counter'
      ? 'Counter'
      : switch (fulfillment) {
          'dineIn' => 'Dine-in',
          'delivery' => 'Delivery',
          _ => 'Pickup',
        };
  String get summary =>
      lines.map((l) => '${l['quantity']}× ${l['name']}').join(', ');
  int ageMinutes([DateTime? now]) {
    final at = createdAt;
    return at == null ? 0 : (now ?? DateTime.now()).difference(at).inMinutes;
  }

  /// The statuses the order engine accepts next, as order.transition does.
  List<String> get next => switch (status) {
    'submitted' => const ['accepted', 'rejected'],
    'accepted' => const ['preparing'],
    'preparing' => const ['ready'],
    'ready' => switch (fulfillment) {
      'dineIn' => const ['served'],
      'pickup' => const ['collected'],
      _ => const <String>[],
    },
    'served' || 'collected' || 'delivered' => const ['completed'],
    _ => const <String>[],
  };
}

String actionLabel(String next) => switch (next) {
  'accepted' => 'Accept',
  'preparing' => 'Start cooking',
  'ready' => 'Mark ready',
  'served' => 'Served',
  'collected' => 'Collected',
  'completed' => 'Complete',
  'rejected' => 'Reject',
  _ => friendly(next),
};

/// Whether this member of staff may move the order to [next]. The server is
/// the authority; this only keeps buttons that would be refused off screen.
bool canAdvance(LiveContext live, StaffOrder o, String next) {
  if (live.manager) return true;
  return switch (next) {
    'accepted' || 'rejected' =>
      live.role == 'waiter' && (o.visitId != null || live.can('counter')) ||
          live.role == 'kitchen' && live.can('acceptOrders'),
    'preparing' || 'ready' => live.role == 'kitchen',
    _ => live.role == 'waiter' && (o.visitId != null || live.can('counter')),
  };
}

List<StaffOrder> filterOrders(
  List<StaffOrder> orders, {
  String query = '',
  String status = 'Active',
  String channel = 'All',
  String payment = 'All',
}) {
  final q = query.trim().toLowerCase();
  return orders.where((o) {
    if (q.isNotEmpty &&
        !'${o.number ?? ''} ${o.id} ${o.pickupCode ?? ''} ${o.customerLabel ?? ''} ${o.summary}'
            .toLowerCase()
            .contains(q)) {
      return false;
    }
    final group = switch (o.status) {
      'awaitingPayment' || 'submitted' => 'New',
      'accepted' || 'preparing' => 'Preparing',
      'ready' ||
      'served' ||
      'collected' ||
      'outForDelivery' ||
      'delivered' => 'Ready',
      _ => 'Done',
    };
    if (status == 'Active' ? !o.open : status != 'All' && group != status) {
      return false;
    }
    if (channel != 'All' && o.channel != channel) return false;
    if (payment == 'Unpaid' && o.paid) return false;
    if (payment == 'Paid' && !o.paid) return false;
    return true;
  }).toList()..sort(
    (a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
  );
}

/// Restaurant-wide change notices for the staff boards. A board refreshes when
/// one arrives. The stream starts at the newest change (cursor -1) rather than
/// replaying history; after a drop it reconnects with backoff from the last
/// cursor it saw, and a slow poll keeps the board honest meanwhile.
class RestaurantFeed extends ChangeNotifier {
  RestaurantFeed(this.live);
  final LiveContext live;
  StreamSubscription<Json>? _events;
  Timer? _poll, _debounce, _retry;
  int _cursor = -1, _failures = 0;
  bool _closed = false;

  void start() {
    final id = live.restaurantId;
    if (id == null || _closed) return;
    _events?.cancel();
    _events = live.api
        .watchRestaurant(id, _cursor)
        .listen(
          (e) {
            if (e['cursor'] is int) _cursor = e['cursor'] as int;
            _failures = 0;
            _poll?.cancel();
            _poll = null;
            if (e['kind'] == 'snapshot.changed') ping();
          },
          onError: (Object _) => _reconnect(),
          onDone: _reconnect,
          cancelOnError: true,
        );
  }

  /// Coalesces bursts of notices into one refresh.
  void ping() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), notifyListeners);
  }

  void _reconnect() {
    if (_closed) return;
    _poll ??= Timer.periodic(const Duration(seconds: 10), (_) => ping());
    ping(); // Catch up on whatever happened while disconnected.
    final wait = Duration(seconds: min(60, 2 << min(_failures++, 5)));
    _retry?.cancel();
    _retry = Timer(wait, start);
  }

  @override
  void dispose() {
    _closed = true;
    _events?.cancel();
    _poll?.cancel();
    _debounce?.cancel();
    _retry?.cancel();
    super.dispose();
  }
}

/// A line's chosen options by name, e.g. "No onion, Large".
String optionNames(Json line) => [
  for (final o in line['options'] as List? ?? const [])
    o is Map ? '${o['name'] ?? ''}' : '$o',
].where((n) => n.isNotEmpty).join(', ');

Widget staffChips(
  BuildContext c,
  List<String> values,
  String selected,
  ValueChanged<String> onSelect,
) => Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    for (final v in values)
      AppChip(
        label: c.tr(v),
        selected: v == selected,
        onSelected: () => onSelect(v),
      ),
  ],
);

/// Age of an order as a pill; late orders stand out.
Widget agePill(BuildContext c, int minutes) => AppPill(
  label: minutes < 1 ? c.tr('just now') : '$minutes ${c.tr('min')}',
  icon: Icons.schedule,
  color: minutes >= 15
      ? Theme.of(c).colorScheme.errorContainer
      : minutes >= 8
      ? Theme.of(c).colorScheme.tertiaryContainer
      : null,
);
