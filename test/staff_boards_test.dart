import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

Map<String, dynamic> order(
  int id,
  String status, {
  int? number,
  String origin = 'online',
  String fulfillment = 'pickup',
  String? label,
  String? code,
  String paymentStatus = 'paid',
  int minutesAgo = 3,
}) => {
  'id': id,
  'number': number,
  'origin': origin,
  'fulfillment': fulfillment,
  'status': status,
  'paymentStatus': paymentStatus,
  'version': 1,
  'currency': 'EUR',
  'totalMinor': 1250,
  'customerLabel': label,
  'pickupCode': code,
  'visitId': null,
  'createdAt': DateTime.now()
      .subtract(Duration(minutes: minutesAgo))
      .toUtc()
      .toIso8601String(),
  'lines': [
    {'lineKey': 'l1', 'name': 'Burger', 'quantity': 1, 'unitPriceMinor': 900},
    {'lineKey': 'l2', 'name': 'Fries', 'quantity': 1, 'unitPriceMinor': 350},
  ],
  'tickets': [
    {'id': 1, 'lineKey': 'l1', 'quantity': 1, 'completedQuantity': 0, 'version': 1},
    {'id': 2, 'lineKey': 'l2', 'quantity': 1, 'completedQuantity': 1, 'version': 1},
  ],
};

/// A fake backend: three orders on the pass, a two-item menu, and a sale that
/// the server reports as paid.
class BoardApi extends PlatformApi {
  BoardApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'staff',
        headers: () async => {},
      );
  final commands = <String>[];
  final keys = <String, List<String>>{};
  var checkoutState = 'created';
  var orderPaid = false;
  var failNext = <String>{};
  Map<String, dynamic>? run;
  final orders = [
    order(3, 'submitted', number: 3, origin: 'counter', label: 'Sam'),
    order(2, 'preparing', number: 2, minutesAgo: 20),
    order(1, 'ready', number: 1, code: '4821', fulfillment: 'dineIn'),
  ];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'kitchen' || 'orders' => {'rows': orders, 'nextCursor': null},
    'storefront' || 'counter.menu' => {
      'id': 1,
      'name': 'Snack fixture',
      'currency': 'EUR',
      'settings': {
        'modes': ['pickup'],
      },
      'reviews': const [],
      'menu': [
        {
          'productId': 10,
          'name': 'Burger',
          'priceMinor': 900,
          'category': 'Mains',
          'modifiers': const [],
        },
        {
          'productId': 11,
          'name': 'Fries',
          'priceMinor': 350,
          'category': 'Sides',
          'modifiers': const [],
        },
      ],
    },
    'order' => order(
      7,
      orderPaid ? 'accepted' : 'awaitingPayment',
      number: 7,
      code: '1234',
      paymentStatus: orderPaid ? 'paid' : 'unpaid',
    ),
    'assistant.run' => run ?? {'status': 'running'},
    'checkout' => {
      'checkoutId': 5,
      'state': checkoutState,
      'amountMinor': 1250,
      'currency': 'EUR',
    },
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    commands.add(command.operation);
    (keys[command.operation] ??= []).add(command.key);
    if (failNext.remove(command.operation)) {
      throw const PlatformFailure('stream_unavailable', 'Connection lost.');
    }
    if (command.operation == 'payment.allocate' &&
        command.body['method'] == 'cash') {
      orderPaid = true;
    }
    return switch (command.operation) {
      'quote.create' => {'id': 9, 'totalMinor': 1250},
      'order.submit' => {'orderId': 7, 'status': 'awaitingPayment', 'number': 7},
      'payment.allocate' => {'checkoutId': 5, 'state': 'reserved'},
      'payment.checkout' => {
        'checkoutId': 5,
        'state': 'created',
        'approvalUrl': 'https://www.sandbox.paypal.com/checkoutnow?token=T',
      },
      _ => {},
    };
  }

  @override
  Future<Map<String, dynamic>> command(
    String operation,
    Map<String, dynamic> data, {
    int? restaurantId,
    int? resourceId,
    int? version,
  }) async {
    commands.add(operation);
    if (operation == 'payment.capture') {
      checkoutState = 'completed';
      orderPaid = true;
    }
    if (operation == 'assistant.start') return {'runId': 41, 'status': 'queued'};
    return {
      'version': 2,
      'state': 'created',
      'approvalUrl': 'https://www.sandbox.paypal.com/checkoutnow?token=T',
    };
  }

  @override
  Stream<Map<String, dynamic>> watchRestaurant(int restaurantId, int after) =>
      const Stream.empty();
}

class Runtime implements LiveRuntime {
  Runtime(this.platform);
  @override
  final PlatformApi platform;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget host(Widget child, {double scale = 2, String locale = 'en'}) =>
    MotionScope(
      reducedMotion: true,
      child: MaterialApp(
        theme: AppTheme.light,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: child,
      ),
    );

void main() {
  group('staff order model', () {
    test('filters group statuses and sort newest first', () {
      final rows = [
        StaffOrder(order(1, 'ready', minutesAgo: 30)),
        StaffOrder(order(2, 'submitted', origin: 'counter', minutesAgo: 1)),
        StaffOrder(order(3, 'completed', minutesAgo: 60)),
      ];
      expect(filterOrders(rows).map((o) => o.id), [2, 1]);
      expect(filterOrders(rows, status: 'Done').map((o) => o.id), [3]);
      expect(filterOrders(rows, channel: 'Counter').map((o) => o.id), [2]);
      expect(filterOrders(rows, status: 'All', query: 'fries').length, 3);
      expect(filterOrders(rows, status: 'All', query: 'zzz'), isEmpty);
    });
    test('next steps follow the order engine', () {
      expect(StaffOrder(order(1, 'submitted')).next, ['accepted', 'rejected']);
      expect(StaffOrder(order(1, 'ready')).next, ['collected']);
      expect(StaffOrder(order(1, 'ready', fulfillment: 'dineIn')).next, [
        'served',
      ]);
      expect(StaffOrder(order(1, 'ready', fulfillment: 'delivery')).next, isEmpty);
      expect(StaffOrder(order(1, 'cancelled')).next, isEmpty);
    });
    test('a waiter needs the counter capability for takeaway orders', () {
      final runtime = Runtime(BoardApi());
      final o = StaffOrder(order(1, 'ready'));
      expect(canAdvance(LiveContext(runtime, role: 'waiter'), o, 'collected'), isFalse);
      expect(
        canAdvance(
          LiveContext(runtime, role: 'waiter', capabilities: const ['counter']),
          o,
          'collected',
        ),
        isTrue,
      );
      expect(canAdvance(LiveContext(runtime, role: 'kitchen'), o, 'accepted'), isFalse);
      expect(
        canAdvance(
          LiveContext(runtime, role: 'kitchen', capabilities: const ['acceptOrders']),
          o,
          'accepted',
        ),
        isTrue,
      );
      expect(canAdvance(LiveContext(runtime, role: 'owner'), o, 'rejected'), isTrue);
    });
  });

  testWidgets('kitchen board groups tickets and accepts with one tap', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(KitchenBoard(live: live)));
    await tester.pumpAndSettle();
    expect(find.text('#3'), findsOneWidget);
    expect(find.text('New · 1'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    await tester.ensureVisible(find.text('Accept'));
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    // Lower sections are built as they scroll into view.
    await tester.dragUntilVisible(
      find.text('Ready · 1'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('In progress · 1'), findsOneWidget);
    expect(api.commands, ['order.transition']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('counter rings up a cash sale in a few taps', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi();
    final live = LiveContext(
      Runtime(api),
      restaurantId: 1,
      role: 'waiter',
      capabilities: const ['counter'],
    );
    await tester.pumpWidget(host(CounterScreen(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Burger'));
    await tester.pump();
    await tester.tap(find.byTooltip('Add Fries'));
    await tester.pump();
    expect(find.text('12.50 EUR'), findsOneWidget);
    await tester.ensureVisible(find.text('Cash'));
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    // The server's total is confirmed before any cash is recorded.
    expect(api.commands, ['quote.create']);
    await tester.tap(find.textContaining('Cash received'));
    await tester.pumpAndSettle();
    expect(api.commands, ['quote.create', 'order.submit', 'payment.allocate']);
    expect(find.text('#7'), findsOneWidget);
    expect(find.textContaining('1234'), findsOneWidget);
    expect(find.text('Payment received'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('counter shows a PayPal QR and finishes when the server confirms', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(CounterScreen(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Burger'));
    await tester.pump();
    await tester.ensureVisible(find.text('PayPal QR'));
    await tester.tap(find.text('PayPal QR'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('Scan with PayPal'), findsOneWidget);
    expect(api.commands, contains('payment.checkout'));
    // Three polls: the third asks the server to capture, then reads it back.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }
    expect(api.commands, contains('payment.capture'));
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a sale interrupted by the network resumes without a second order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi()..failNext = {'payment.allocate'};
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(CounterScreen(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Burger'));
    await tester.pump();
    await tester.ensureVisible(find.text('Cash'));
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Cash received'));
    await tester.pumpAndSettle();
    expect(find.textContaining('retry to continue'), findsOneWidget);
    expect(find.text('Payment received'), findsNothing);
    // The cashier taps Cash again: same order, same collection request.
    await tester.ensureVisible(find.text('Cash'));
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    expect(api.keys['quote.create'], hasLength(1));
    expect(api.keys['order.submit'], hasLength(1));
    expect(api.keys['payment.allocate'], hasLength(2));
    expect(api.keys['payment.allocate']!.toSet(), hasLength(1));
    expect(find.text('Payment received'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('on a tablet the menu and the sale sit side by side', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final live = LiveContext(Runtime(BoardApi()), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(CounterScreen(live: live), scale: 1));
    await tester.pumpAndSettle();
    final burger = tester.getCenter(find.text('Burger'));
    final sale = tester.getCenter(find.text('This sale'));
    expect(burger.dx, lessThan(sale.dx));
    expect(find.text('PayPal QR'), findsOneWidget);
    await tester.tap(find.text('Burger'));
    await tester.pump();
    expect(find.text('9.00 EUR'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('on a tablet the kitchen stages sit side by side', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final live = LiveContext(Runtime(BoardApi()), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(KitchenBoard(live: live), scale: 1));
    await tester.pumpAndSettle();
    final fresh = tester.getTopLeft(find.text('New · 1'));
    final cooking = tester.getTopLeft(find.text('In progress · 1'));
    final ready = tester.getTopLeft(find.text('Ready · 1'));
    expect(fresh.dy, cooking.dy);
    expect(cooking.dy, ready.dy);
    expect(fresh.dx < cooking.dx && cooking.dx < ready.dx, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a basket proposal waiting for review is shown for approval', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi()
      ..run = {
        'id': 41,
        'status': 'review',
        'answer': {'text': 'Here is a burger with fries.'},
        'proposal': {
          'id': 5,
          'kind': 'basket',
          'status': 'review',
          'version': 1,
          'payload': {
            'quote': {
              'currency': 'EUR',
              'totalMinor': 1250,
              'lines': [
                {'name': 'Burger', 'quantity': 1},
                {'name': 'Fries', 'quantity': 1},
              ],
            },
          },
        },
      };
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(AskRaystoPage(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A quick lunch for two'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Approve basket'), findsOneWidget);
    expect(find.textContaining('12.50'), findsOneWidget);
    expect(find.text('Raysto is thinking…'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  test('kitchen lines read options by name', () {
    expect(
      optionNames({
        'options': [
          {'id': 'g:o', 'name': 'No onion', 'priceMinor': 0},
          {'id': 'g:l', 'name': 'Large', 'priceMinor': 100},
        ],
      }),
      'No onion, Large',
    );
    expect(optionNames({'options': const []}), '');
  });

  testWidgets('orders board filters by channel in Arabic at 2x', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = BoardApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(OrdersBoard(live: live), locale: 'ar'));
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    // Cards are built lazily: check each one as it scrolls into view.
    await tester.dragUntilVisible(find.text('#3'), list, const Offset(0, -300));
    expect(find.text('#3'), findsOneWidget);
    await tester.dragUntilVisible(find.text('#2'), list, const Offset(0, -300));
    expect(find.text('#2'), findsOneWidget);
    // The channel pill on a counter order carries the same word as the chip.
    final chip = find.widgetWithText(AppChip, 'الكاشير');
    await tester.dragUntilVisible(chip, list, const Offset(0, 300));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(find.text('#3'), list, const Offset(0, -300));
    await tester.drag(list, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('#2'), findsNothing);
    expect(find.text('#1'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
