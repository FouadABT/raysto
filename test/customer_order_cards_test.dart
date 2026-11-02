import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

final storefront = <String, dynamic>{
  'id': 1,
  'name': 'Atelier Café',
  'currency': 'EUR',
  'settings': {
    'modes': ['pickup'],
  },
  'menu': [
    {
      'productId': 101,
      'name': 'Croque monsieur',
      'priceMinor': 750,
      'modifiers': [
        {
          'id': 'g1',
          'name': 'Extras',
          'min': 0,
          'max': 2,
          'options': [
            {'id': 'egg', 'name': 'Fried egg', 'priceMinor': 120},
          ],
        },
      ],
    },
    {
      'productId': 103,
      'name': 'Lemon tart',
      'priceMinor': 450,
      'modifiers': const [],
    },
  ],
};

final lines = [
  {
    'lineKey': 'l0',
    'name': 'Croque monsieur',
    'quantity': 2,
    'unitPriceMinor': 870,
    'options': [
      {'id': 'g1:egg', 'name': 'Fried egg', 'priceMinor': 120},
    ],
    'note': 'Cut in half',
  },
  {'lineKey': 'l1', 'name': 'Lemon tart', 'quantity': 1, 'unitPriceMinor': 450},
];

Map<String, dynamic> order(String status, String payment) => {
  'id': 12,
  'number': 7,
  'status': status,
  'paymentStatus': payment,
  'fulfillment': 'pickup',
  'origin': 'online',
  'currency': 'EUR',
  'totalMinor': 2190,
  'pickupCode': '4821',
  'version': 2,
  'lines': lines,
  'timeline': [
    {'kind': 'order.submitted', 'at': '2026-11-02T11:58:00Z'},
  ],
};

class CardsApi extends PlatformApi {
  CardsApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'diner',
        headers: () async => {},
      );
  final commands = <String>[];
  Map<String, dynamic> orderRow = order('awaitingPayment', 'unpaid');
  Map<String, dynamic> checkoutRow = {
    'checkoutId': 5,
    'orderId': 12,
    'state': 'created',
    'approvalUrl': 'https://www.sandbox.paypal.com/checkoutnow?token=T',
    'amountMinor': 2190,
    'currency': 'EUR',
  };

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'cart' => {
      'version': 3,
      'lines': [
        {
          'productId': 101,
          'quantity': 2,
          'options': ['g1:egg'],
          'note': 'Cut in half',
        },
        {'productId': 103, 'quantity': 1, 'options': const [], 'note': ''},
      ],
    },
    'order' => orderRow,
    'checkout' => checkoutRow,
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    commands.add(command.operation);
    return switch (command.operation) {
      'order.submit' => {'orderId': 12, 'status': 'awaitingPayment'},
      _ => {},
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

Widget host(Widget child, {String locale = 'en'}) => MotionScope(
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
        textScaler: const TextScaler.linear(2),
        disableAnimations: true,
      ),
      child: child!,
    ),
    home: child,
  ),
);

/// The labels of the primary buttons on screen; each context has one.
List<String> primaries(WidgetTester tester) => [
  for (final b in tester.widgetList<AppButton>(find.byType(AppButton)))
    if (!b.secondary) b.label,
];

void main() {
  // 320 px wide at 2x text; tall enough that every card and action is built
  // even with the wide square glyphs of the test font.
  Future<void> narrow(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 6000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('the basket lists its lines as one card with one next step', (
    tester,
  ) async {
    await narrow(tester);
    final live = LiveContext(Runtime(CardsApi()), restaurantId: 1);
    await tester.pumpWidget(
      host(BasketPage(live: live, storefront: storefront)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Items · 3'), findsOneWidget);
    expect(find.text('Fried egg · Cut in half'), findsOneWidget);
    expect(find.byTooltip('Remove item'), findsNWidgets(2));
    expect(find.text('17.40 EUR'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('21.90 EUR'), findsOneWidget);
    expect(primaries(tester), ['Review checkout']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the order review shows the quote and places the order', (
    tester,
  ) async {
    await narrow(tester);
    final api = CardsApi();
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(
      host(
        QuotePage(
          live: live,
          quote: {
            'id': 9,
            'fulfillment': 'pickup',
            'currency': 'EUR',
            'lines': lines,
            'subtotalMinor': 2190,
            'discountMinor': 0,
            'taxMinor': 199,
            'deliveryFeeMinor': 0,
            'tipMinor': 0,
            'totalMinor': 2190,
            'paymentTiming': 'before',
            'expiresAt': DateTime.now()
                .add(const Duration(minutes: 10))
                .toUtc()
                .toIso8601String(),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your order'), findsOneWidget);
    expect(find.text('Pickup as soon as it is ready'), findsOneWidget);
    expect(find.text('Pay before preparation'), findsOneWidget);
    // Prices that include tax say so rather than adding it again.
    expect(find.text('Tax included'), findsOneWidget);
    expect(find.text('Subtotal'), findsNothing);
    expect(find.text('21.90 EUR'), findsOneWidget);
    expect(find.textContaining('Price held until'), findsOneWidget);
    expect(primaries(tester), ['Place order']);
    await tester.tap(find.widgetWithText(AppButton, 'Place order'));
    await tester.pumpAndSettle();
    expect(api.commands, ['order.submit']);
    expect(find.text('Order #12'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an unpaid order leads to payment; a ready one to its code', (
    tester,
  ) async {
    await narrow(tester);
    final api = CardsApi();
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(orderPage(live, 12)));
    await tester.pumpAndSettle();
    expect(find.text('Awaiting payment'), findsOneWidget);
    expect(find.text('#7'), findsOneWidget);
    expect(find.text('Unpaid'), findsOneWidget);
    expect(find.text('Pickup code 4821'), findsOneWidget);
    expect(
      find.text('2×  Croque monsieur', findRichText: true),
      findsOneWidget,
    );
    expect(primaries(tester), ['Pay outstanding balance']);
    expect(find.text('Open conversation'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());

    api.orderRow = order('ready', 'paid');
    await tester.pumpWidget(host(orderPage(live, 12), locale: 'ar'));
    await tester.pumpAndSettle();
    expect(find.text('جاهز'), findsOneWidget);
    expect(find.text('مدفوع'), findsOneWidget);
    expect(primaries(tester), ['Open conversation']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the payment page offers PayPal first, then confirms', (
    tester,
  ) async {
    await narrow(tester);
    final opened = <Uri>[];
    final browser = launchProvider;
    addTearDown(() => launchProvider = browser);
    launchProvider = (uri) async {
      opened.add(uri);
      return true;
    };
    final api = CardsApi();
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(checkoutPage(live, 5)));
    await tester.pumpAndSettle();
    expect(find.text('Payment #5'), findsOneWidget);
    expect(find.text('21.90 EUR'), findsOneWidget);
    expect(find.text('Created'), findsOneWidget);
    expect(find.text('Order #12'), findsOneWidget);
    expect(primaries(tester), ['Open PayPal']);
    expect(find.text('I approved in PayPal · confirm payment'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Open PayPal'));
    await tester.pumpAndSettle();
    expect(opened.single.host, 'www.sandbox.paypal.com');
    await tester.pumpWidget(const SizedBox());

    // Once PayPal reports the approval, confirming becomes the next step.
    api.checkoutRow = {...api.checkoutRow, 'state': 'approved'};
    await tester.pumpWidget(host(checkoutPage(live, 5)));
    await tester.pumpAndSettle();
    expect(primaries(tester), ['I approved in PayPal · confirm payment']);
    await tester.pumpWidget(const SizedBox());

    api.checkoutRow = {
      ...api.checkoutRow,
      'state': 'completed',
      'approvalUrl': null,
      'captureId': 31,
    };
    await tester.pumpWidget(host(checkoutPage(live, 5)));
    await tester.pumpAndSettle();
    expect(find.text('Payment confirmed'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Receipt #31'), findsOneWidget);
    expect(primaries(tester), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
