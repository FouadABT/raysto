// Explicit visual-review capture of the diner's basket, order review, order
// and payment screens, with bundled fonts and a fixed fake restaurant.
// Not part of the test suite.
// flutter test tool/render_customer_test.dart --update-goldens
// Writes build/customer-review/*.png.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    'modes': ['pickup', 'dineIn'],
  },
  'menu': [
    {
      'productId': 101,
      'name': 'Croque monsieur',
      'category': 'Sandwiches',
      'priceMinor': 750,
      'modifiers': [
        {
          'id': 'g1',
          'name': 'Extras',
          'min': 0,
          'max': 2,
          'options': [
            {'id': 'egg', 'name': 'Fried egg', 'priceMinor': 120},
            {'id': 'salad', 'name': 'Side salad', 'priceMinor': 250},
          ],
        },
      ],
    },
    {
      'productId': 102,
      'name': 'Cappuccino',
      'category': 'Drinks',
      'priceMinor': 320,
      'modifiers': [
        {
          'id': 'g2',
          'name': 'Milk',
          'min': 0,
          'max': 1,
          'options': [
            {'id': 'oat', 'name': 'Oat milk', 'priceMinor': 40},
          ],
        },
      ],
    },
    {
      'productId': 103,
      'name': 'Lemon tart',
      'category': 'Sweets',
      'priceMinor': 450,
      'modifiers': const [],
    },
  ],
};

final cart = <String, dynamic>{
  'version': 3,
  'lines': [
    {
      'productId': 101,
      'quantity': 2,
      'options': ['g1:egg'],
      'note': 'Cut in half',
    },
    {
      'productId': 102,
      'quantity': 1,
      'options': ['g2:oat'],
      'note': '',
    },
    {'productId': 103, 'quantity': 1, 'options': const [], 'note': ''},
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
  {
    'lineKey': 'l1',
    'name': 'Cappuccino',
    'quantity': 1,
    'unitPriceMinor': 360,
    'options': [
      {'id': 'g2:oat', 'name': 'Oat milk', 'priceMinor': 40},
    ],
  },
  {'lineKey': 'l2', 'name': 'Lemon tart', 'quantity': 1, 'unitPriceMinor': 450},
];

Map<String, dynamic> quote() {
  final now = DateTime.now();
  return {
    'id': 9,
    'fulfillment': 'pickup',
    'slot': DateTime(
      now.year,
      now.month,
      now.day,
      12,
      30,
    ).toUtc().toIso8601String(),
    'currency': 'EUR',
    'lines': lines,
    'subtotalMinor': 2550,
    'discountMinor': 0,
    'taxMinor': 232,
    'deliveryFeeMinor': 0,
    'tipMinor': 100,
    'totalMinor': 2650,
    'paymentTiming': 'before',
    'expiresAt': now.add(const Duration(minutes: 10)).toUtc().toIso8601String(),
  };
}

Map<String, dynamic> order(String status, String payment) => {
  'id': 12,
  'number': 7,
  'restaurantId': 1,
  'status': status,
  'paymentStatus': payment,
  'fulfillment': 'pickup',
  'origin': 'online',
  'currency': 'EUR',
  'totalMinor': 2650,
  'pickupCode': '4821',
  'version': 2,
  'createdAt': DateTime.now().toUtc().toIso8601String(),
  'lines': lines,
  'timeline': [
    {'kind': 'order.submitted', 'at': '2026-11-02T11:58:00Z'},
  ],
};

Map<String, dynamic> checkout(String state) => {
  'checkoutId': 5,
  'orderId': 12,
  'visitId': null,
  'state': state,
  'approvalUrl': state == 'created'
      ? 'https://www.sandbox.paypal.com/checkoutnow?token=T'
      : null,
  'amountMinor': 2650,
  'currency': 'EUR',
  'captureId': state == 'completed' ? 31 : null,
  'refundedMinor': 0,
};

class ReviewApi extends PlatformApi {
  ReviewApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'diner',
        headers: () async => {},
      );
  Map<String, dynamic> orderRow = order('awaitingPayment', 'unpaid');
  Map<String, dynamic> checkoutRow = checkout('created');

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'cart' => cart,
    'storefront' => storefront,
    'order' => orderRow,
    'checkout' => checkoutRow,
    _ => {'rows': const []},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async => {};

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

/// The Material icon font from the project toolchain; a worktree without its
/// own `.tooling` uses the one the test run was started with.
File materialIcons() {
  const font = 'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  return [
    File('.tooling/flutter/$font'),
    if (root != null) File('$root/$font'),
  ].firstWhere((f) => f.existsSync());
}

Future<void> loadFonts() async {
  final jakarta = FontLoader('PlusJakartaSans');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    jakarta.addFont(
      rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'),
    );
  }
  await jakarta.load();
  await (FontLoader(
    'NotoSansArabic',
  )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  await (FontLoader('MaterialIcons')..addFont(
        Future.value(ByteData.sublistView(materialIcons().readAsBytesSync())),
      ))
      .load();
  for (final (family, file) in [
    ('PhosphorRegular', 'Phosphor.ttf'),
    ('PhosphorFill', 'Phosphor-Fill.ttf'),
  ]) {
    await (FontLoader('packages/phosphor_flutter/$family')..addFont(
          rootBundle.load('packages/phosphor_flutter/lib/fonts/$file'),
        ))
        .load();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadFonts);

  for (final (name, size, scale, locale) in [
    ('phone', const Size(390, 1500), 1.0, 'en'),
    ('narrow-2x', const Size(320, 3000), 2.0, 'en'),
    ('arabic', const Size(390, 1500), 1.0, 'ar'),
  ]) {
    testWidgets('capture the diner checkout on a $name', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      const boundary = Key('review-canvas');
      final api = ReviewApi();
      final live = LiveContext(
        Runtime(api),
        restaurantId: 1,
        name: 'Atelier Café',
      );
      Future<void> show(String screen, Widget page) async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MotionScope(
              reducedMotion: true,
              child: MaterialApp(
                key: ValueKey(screen),
                debugShowCheckedModeBanner: false,
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
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: page,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(boundary),
          matchesGoldenFile('../build/customer-review/$name-$screen.png'),
        );
      }

      await show('basket', BasketPage(live: live, storefront: storefront));
      await show('review', QuotePage(live: live, quote: quote()));
      await show('order-unpaid', orderPage(live, 12));
      api.orderRow = order('ready', 'paid');
      await show('order-ready', orderPage(live, 12));
      await show('payment-created', checkoutPage(live, 5));
      api.checkoutRow = checkout('completed');
      await show('payment-confirmed', checkoutPage(live, 5));
      await tester.pumpWidget(const SizedBox());
    });
  }
}
