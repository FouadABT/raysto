part of 'connected_app.dart';

/// Where an order may be moved on a board, and why not when it may not. It
/// mirrors `order.transition` (ordering.dart): one step forward at a time,
/// never back; the server stays the authority and refuses anything else.
@immutable
class MoveRule {
  const MoveRule({this.to, this.needsCode = false, this.reason});

  /// The next status, or null when the order cannot be moved from here.
  final String? to;

  /// Handing over an online pickup asks for the code on the diner's phone.
  final bool needsCode;

  /// Why the move is not offered, in words a person reads on the card.
  final String? reason;

  bool get allowed => to != null && reason == null;
}

/// The one move a board offers for [order]. A rejection is never a move; it
/// stays a deliberate button with a reason. [kitchen] boards only mark an
/// order ready once every line is ticked. [payFirst] restaurants do not
/// accept an order before PayPal (or the counter) confirmed the payment.
MoveRule allowedNext(
  StaffOrder order,
  LiveContext live, {
  bool kitchen = false,
  bool payFirst = false,
}) {
  if (order.status == 'awaitingPayment') {
    return const MoveRule(reason: 'Awaiting payment');
  }
  if (order.status == 'ready' &&
      order.fulfillment != 'dineIn' &&
      order.fulfillment != 'pickup') {
    return const MoveRule(reason: 'Delivery flow');
  }
  final next = order.next.where((s) => s != 'rejected').firstOrNull;
  if (next == null) return const MoveRule();
  if (!canAdvance(live, order, next)) {
    return MoveRule(to: next, reason: 'Not your role');
  }
  if (next == 'accepted' && payFirst && !order.paid) {
    return MoveRule(to: next, reason: 'Awaiting payment');
  }
  if (next == 'ready' && kitchen) {
    final open = order.tickets.any(
      (t) =>
          (t['completedQuantity'] as num? ?? 0) < (t['quantity'] as num? ?? 0),
    );
    if (open) return MoveRule(to: next, reason: 'Tick every line first');
  }
  final needsCode =
      next == 'collected' &&
      order.origin != 'counter' &&
      order.pickupCode != null &&
      !live.manager;
  return MoveRule(to: next, needsCode: needsCode);
}

/// Sends one status step for an order, at the version it expects.
typedef MoveSender =
    Future<void> Function(int orderId, String status, int expectedVersion);

/// A move that has not been sent yet.
@immutable
class PendingMove {
  const PendingMove({
    required this.orderId,
    required this.from,
    required this.steps,
    required this.version,
  });
  final int orderId;

  /// The status the order had before any of these steps.
  final String from;

  /// The steps to send, in order, each one forward from the last.
  final List<String> steps;

  /// The order's version when the first step was chosen.
  final int version;

  String get to => steps.last;
}

/// Board moves with an Undo: a move shows at once and is sent after a grace
/// period unless undone. Nothing on the server ever needs reversing.
///
/// - A second move of the same order adds a step (accepted, then preparing);
///   moving it back to where it started undoes it.
/// - [flush] sends everything now: on leaving the board, on dispose and when
///   the app goes to the background.
/// - [overlay] applies pending moves to fresh data, so a live refresh never
///   snaps a card back.
/// - When the server refuses, the card returns and [onRefused] says why.
class PendingMoves extends ChangeNotifier with WidgetsBindingObserver {
  PendingMoves({
    required this.send,
    this.grace = const Duration(seconds: 5),
    this.onRefused,
    this.onSent,
  }) {
    WidgetsBinding.instance.addObserver(this);
  }

  final MoveSender send;
  final Duration grace;
  final void Function(PendingMove move, Object error)? onRefused;
  final void Function(PendingMove move)? onSent;

  final Map<int, PendingMove> _moves = {};
  final Map<int, Timer> _timers = {};
  bool _disposed = false;

  Iterable<PendingMove> get pending => _moves.values;

  String? statusOf(int orderId) => _moves[orderId]?.to;

  /// Shows [order] at [to] and sends it after [grace].
  void schedule(StaffOrder order, String to) {
    final existing = _moves[order.id];
    _timers.remove(order.id)?.cancel();
    if (existing != null && to == existing.from) {
      _moves.remove(order.id);
      notifyListeners();
      return;
    }
    _moves[order.id] = existing == null
        ? PendingMove(
            orderId: order.id,
            from: order.status,
            steps: [to],
            version: order.version,
          )
        : PendingMove(
            orderId: order.id,
            from: existing.from,
            steps: [...existing.steps, to],
            version: existing.version,
          );
    _timers[order.id] = Timer(grace, () => _send(order.id));
    notifyListeners();
  }

  /// Cancels a move that has not been sent. Returns whether there was one.
  bool undo(int orderId) {
    _timers.remove(orderId)?.cancel();
    final removed = _moves.remove(orderId) != null;
    if (removed) notifyListeners();
    return removed;
  }

  /// Sends every pending move now.
  Future<void> flush() =>
      Future.wait([for (final id in _moves.keys.toList()) _send(id)]);

  Future<void> _send(int orderId) async {
    _timers.remove(orderId)?.cancel();
    final move = _moves.remove(orderId);
    if (move == null) return;
    if (!_disposed) notifyListeners();
    try {
      for (final (i, step) in move.steps.indexed) {
        // Each step moves the order one version forward.
        await send(orderId, step, move.version + i);
      }
      onSent?.call(move);
    } catch (e) {
      onRefused?.call(move, e);
    }
  }

  /// [orders] as the board shows them, with pending moves applied.
  List<StaffOrder> overlay(List<StaffOrder> orders) => [
    for (final o in orders)
      if (_moves[o.id] case final PendingMove m)
        StaffOrder({...o.raw, 'status': m.to})
      else
        o,
  ];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposed = true;
    // Leaving the board sends what was chosen; nothing is silently dropped.
    unawaited(flush());
    super.dispose();
  }
}
