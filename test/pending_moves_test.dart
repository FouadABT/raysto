import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/features/connected/connected_app.dart';

class Runtime implements LiveRuntime {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

StaffOrder order(
  String status, {
  int id = 7,
  int version = 3,
  String fulfillment = 'pickup',
  String origin = 'online',
  String paymentStatus = 'paid',
  String? code = '0271',
  bool linesDone = true,
}) => StaffOrder({
  'id': id,
  'status': status,
  'version': version,
  'fulfillment': fulfillment,
  'origin': origin,
  'paymentStatus': paymentStatus,
  'pickupCode': code,
  'tickets': [
    {'id': 1, 'lineKey': 'l1', 'quantity': 1, 'completedQuantity': 1},
    {
      'id': 2,
      'lineKey': 'l2',
      'quantity': 2,
      'completedQuantity': linesDone ? 2 : 1,
    },
  ],
});

LiveContext as(String role, {List<String> capabilities = const []}) =>
    LiveContext(Runtime(), restaurantId: 5, role: role, capabilities: capabilities);

void main() {
  group('PendingMoves', () {
    late List<(int, String, int)> sent;
    late List<String> refused;
    late PendingMoves moves;
    var failWith = '';

    setUp(() {
      sent = [];
      refused = [];
      failWith = '';
    });

    PendingMoves make() => PendingMoves(
      send: (id, status, version) async {
        if (failWith.isNotEmpty) {
          throw PlatformFailure('version_conflict', failWith);
        }
        sent.add((id, status, version));
      },
      onRefused: (move, e) => refused.add(
        '${move.orderId}: ${e is PlatformFailure ? e.message : e}',
      ),
    );

    testWidgets('a move is shown at once and sent after the grace period', (
      tester,
    ) async {
      moves = make();
      moves.schedule(order('submitted'), 'accepted');
      expect(moves.statusOf(7), 'accepted');
      expect(moves.overlay([order('submitted')]).single.status, 'accepted');
      await tester.pump(const Duration(milliseconds: 4900));
      expect(sent, isEmpty);
      await tester.pump(const Duration(milliseconds: 100));
      expect(sent, [(7, 'accepted', 3)]);
      expect(moves.statusOf(7), isNull);
      moves.dispose();
    });

    testWidgets('Undo sends nothing', (tester) async {
      moves = make();
      moves.schedule(order('submitted'), 'accepted');
      await tester.pump(const Duration(seconds: 2));
      expect(moves.undo(7), isTrue);
      await tester.pump(const Duration(seconds: 10));
      expect(sent, isEmpty);
      expect(moves.undo(7), isFalse);
      moves.dispose();
    });

    testWidgets('a second move adds a step at the next version', (
      tester,
    ) async {
      moves = make();
      moves.schedule(order('submitted'), 'accepted');
      await tester.pump(const Duration(seconds: 3));
      moves.schedule(order('submitted'), 'preparing');
      await tester.pump(const Duration(seconds: 4));
      expect(sent, isEmpty, reason: 'the grace period starts again');
      await tester.pump(const Duration(seconds: 1));
      expect(sent, [(7, 'accepted', 3), (7, 'preparing', 4)]);
      moves.dispose();
    });

    testWidgets('moving a card back to where it started undoes the move', (
      tester,
    ) async {
      moves = make();
      moves.schedule(order('accepted'), 'preparing');
      moves.schedule(order('accepted'), 'accepted');
      expect(moves.statusOf(7), isNull);
      await tester.pump(const Duration(seconds: 10));
      expect(sent, isEmpty);
      moves.dispose();
    });

    testWidgets('flush sends everything now; dispose flushes too', (
      tester,
    ) async {
      moves = make();
      moves.schedule(order('submitted', id: 1), 'accepted');
      moves.schedule(order('ready', id: 2), 'collected');
      await moves.flush();
      expect(sent, [(1, 'accepted', 3), (2, 'collected', 3)]);
      moves.schedule(order('preparing', id: 3), 'ready');
      moves.dispose();
      await tester.pump();
      expect(sent.last, (3, 'ready', 3));
    });

    testWidgets('going to the background sends what was chosen', (
      tester,
    ) async {
      moves = make();
      moves.schedule(order('submitted'), 'accepted');
      moves.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      expect(sent, [(7, 'accepted', 3)]);
      moves.dispose();
    });

    testWidgets('a refusal returns the card and says why', (tester) async {
      moves = make();
      failWith = 'The order changed.';
      moves.schedule(order('submitted'), 'accepted');
      await tester.pump(const Duration(seconds: 5));
      expect(sent, isEmpty);
      expect(refused.single, contains('The order changed.'));
      expect(moves.overlay([order('submitted')]).single.status, 'submitted');
      moves.dispose();
    });
  });

  group('allowedNext mirrors order.transition', () {
    final manager = as('manager');
    final kitchen = as('kitchen');
    final waiter = as('waiter', capabilities: ['counter']);

    test('one step forward, never a rejection', () {
      expect(allowedNext(order('submitted'), manager).to, 'accepted');
      expect(allowedNext(order('accepted'), manager).to, 'preparing');
      expect(allowedNext(order('preparing'), manager).to, 'ready');
      expect(allowedNext(order('ready'), manager).to, 'collected');
      expect(
        allowedNext(order('ready', fulfillment: 'dineIn'), manager).to,
        'served',
      );
      expect(allowedNext(order('collected'), manager).to, 'completed');
      expect(allowedNext(order('completed'), manager).to, isNull);
      expect(allowedNext(order('cancelled'), manager).to, isNull);
    });

    test('orders that cannot move say why', () {
      expect(
        allowedNext(order('awaitingPayment'), manager).reason,
        'Awaiting payment',
      );
      expect(
        allowedNext(order('ready', fulfillment: 'delivery'), manager).reason,
        'Delivery flow',
      );
      expect(
        allowedNext(
          order('submitted', paymentStatus: 'unpaid'),
          manager,
          payFirst: true,
        ).reason,
        'Awaiting payment',
      );
      expect(
        allowedNext(order('preparing', linesDone: false), kitchen, kitchen: true)
            .reason,
        'Tick every line first',
      );
      expect(
        allowedNext(order('preparing', linesDone: false), manager).allowed,
        isTrue,
        reason: 'the console ticks open lines with the move',
      );
    });

    test('roles follow the server', () {
      expect(allowedNext(order('preparing'), kitchen).allowed, isTrue);
      expect(allowedNext(order('preparing'), waiter).reason, 'Not your role');
      expect(allowedNext(order('ready'), kitchen).reason, 'Not your role');
    });

    test('an online pickup is handed over against its code', () {
      expect(allowedNext(order('ready'), waiter).needsCode, isTrue);
      expect(allowedNext(order('ready'), manager).needsCode, isFalse);
      expect(
        allowedNext(order('ready', origin: 'counter'), waiter).needsCode,
        isFalse,
      );
    });
  });
}
