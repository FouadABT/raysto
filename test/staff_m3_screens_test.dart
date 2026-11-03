import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

Map<String, dynamic> order(int id, String status, {String payment = 'paid'}) => {
  'id': id,
  'number': id,
  'origin': 'online',
  'fulfillment': 'pickup',
  'status': status,
  'paymentStatus': payment,
  'version': 1,
  'currency': 'USD',
  'totalMinor': 1250,
  'customerLabel': null,
  'pickupCode': '1234',
  'visitId': null,
  'createdAt': DateTime.now()
      .subtract(const Duration(minutes: 3))
      .toUtc()
      .toIso8601String(),
  'lines': [
    {'lineKey': 'l1', 'name': 'Burger', 'quantity': 1, 'unitPriceMinor': 1250},
  ],
  'tickets': const [],
};

/// Orders, a counter menu, and one money suggestion PayPal executes.
class ScreensApi extends PlatformApi {
  ScreensApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'owner',
        headers: () async => {},
      );
  final commands = <String>[];
  var paid = false;

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'orders' => {
      'rows': [order(3, 'submitted')],
      'nextCursor': null,
    },
    'order' => order(7, paid ? 'accepted' : 'awaitingPayment',
        payment: paid ? 'paid' : 'unpaid'),
    'counter.menu' || 'storefront' => {
      'id': 1,
      'name': 'Snack fixture',
      'currency': 'USD',
      'settings': {
        'modes': ['pickup'],
      },
      'reviews': const [],
      'menu': [
        {
          'productId': 10,
          'name': 'Burger',
          'priceMinor': 1250,
          'category': 'Mains',
          'modifiers': const [],
        },
      ],
    },
    'agent.inbox' => {
      'rows': [
        {
          'id': 2,
          'agent': 'payroll',
          'command': 'payout.send',
          'title': 'Pay wages 448.00 USD with PayPal',
          'rationale': 'Omar worked 8 hours and Nadia 16 this week.',
          'risk': 'money',
          'status': 'pending',
          'version': 1,
          'preview': {'batchId': 1},
          'evidence': const {},
        },
      ],
    },
    'agent.activity' => {'rows': const []},
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    commands.add(command.operation);
    if (command.operation == 'payment.allocate') paid = true;
    return switch (command.operation) {
      'agent.decide' => {
        'state': 'executed',
        'result': {'providerBatchId': 'EUG58M87BKY5E', 'state': 'sent'},
      },
      'quote.create' => {'id': 9, 'totalMinor': 1250},
      'order.submit' => {'orderId': 7, 'status': 'awaitingPayment', 'number': 7},
      'payment.allocate' => {'checkoutId': 5, 'state': 'reserved'},
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
    return {'version': 2};
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

Widget host(Widget child, {double scale = 1, String locale = 'en'}) =>
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

LiveContext owner(ScreensApi api) =>
    LiveContext(Runtime(api), restaurantId: 1, role: 'owner');

/// The device's own size, so layout and MediaQuery agree.
Future<void> size(WidgetTester tester, Size s) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s;
  addTearDown(tester.view.reset);
}

void main() {
  for (final (name, s, scale, locale) in [
    ('a phone at 2x', const Size(320, 800), 2.0, 'en'),
    ('a tablet', const Size(1280, 800), 1.0, 'en'),
    ('Arabic in landscape', const Size(800, 360), 2.0, 'ar'),
  ]) {
    testWidgets('an order card opens into the full order on $name', (
      tester,
    ) async {
      await size(tester, s);
      await tester.pumpWidget(
        host(OrdersBoard(live: owner(ScreensApi())), scale: scale, locale: locale),
      );
      await tester.pumpAndSettle();
      // Lists build lazily: scroll the page until the card exists.
      await tester.scrollUntilVisible(
        find.text('#3'),
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      await tester.ensureVisible(find.text('#3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#3'));
      await tester.pumpAndSettle();
      // The detail page is up: the order's own title, reached in one move.
      expect(find.byType(OrderDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('the counter stamps a sale PAID once it is paid', (tester) async {
    await size(tester, const Size(320, 800));
    final api = ScreensApi();
    await tester.pumpWidget(
      host(
        CounterScreen(
          live: LiveContext(
            Runtime(api),
            restaurantId: 1,
            role: 'waiter',
            capabilities: const ['counter'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PaidStamp), findsNothing);
    await tester.tap(find.byTooltip('Add Burger'));
    await tester.pump();
    await tester.ensureVisible(find.text('Cash'));
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Cash received'));
    await tester.pumpAndSettle();
    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('PAID'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a stamp lands only when the payment arrives', (tester) async {
    await tester.pumpWidget(host(const Center(child: LandingPaidStamp())));
    // The first frame holds the space; the stamp lands on the next.
    expect(find.text('PAID'), findsNothing);
    await tester.pump();
    expect(find.text('PAID'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('approving a payout shows PayPal’s batch id, with no Undo', (
    tester,
  ) async {
    await size(tester, const Size(1280, 800));
    final api = ScreensApi();
    await tester.pumpWidget(host(agentsPage(owner(api))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Approve and confirm'));
    await tester.tap(find.text('Approve and confirm'));
    await tester.pumpAndSettle();
    expect(api.commands, ['agent.decide']);
    expect(find.textContaining('EUG58M87BKY5E'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a suggestion opens on its own page and can be decided there', (
    tester,
  ) async {
    await size(tester, const Size(320, 800));
    final api = ScreensApi();
    await tester.pumpWidget(host(agentsPage(owner(api)), scale: 2));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Details'), 300);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Payroll'), findsNothing);
    expect(find.text('Pay wages 448.00 USD with PayPal'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Approve and confirm').last,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Approve and confirm').last);
    await tester.pumpAndSettle();
    expect(api.commands, ['agent.decide']);
    // Deciding there returns to the inbox.
    expect(find.text('Details'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
