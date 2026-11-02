// Explicit visual-review capture of the staff app on a tablet and a phone,
// with bundled fonts and a fixed fake restaurant. Not part of the test suite.
// flutter test tool/render_staff_test.dart --update-goldens
// Writes build/staff-review/*.png.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/navigation.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

Map<String, dynamic> order(
  int id,
  String status, {
  required int number,
  String origin = 'online',
  String fulfillment = 'pickup',
  String? label,
  String? code,
  int minutes = 3,
  List<(String, int, int)> lines = const [('Croque monsieur', 1, 750)],
  int done = 0,
}) => {
  'id': id,
  'number': number,
  'origin': origin,
  'fulfillment': fulfillment,
  'status': status,
  'paymentStatus': 'paid',
  'version': 1,
  'currency': 'EUR',
  'totalMinor': lines.fold<int>(0, (n, l) => n + l.$2 * l.$3),
  'customerLabel': label,
  'pickupCode': code,
  'visitId': null,
  'createdAt': DateTime.now()
      .subtract(Duration(minutes: minutes))
      .toUtc()
      .toIso8601String(),
  'lines': [
    for (final (i, l) in lines.indexed)
      {
        'lineKey': 'l$i',
        'name': l.$1,
        'quantity': l.$2,
        'unitPriceMinor': l.$3,
      },
  ],
  'tickets': [
    for (final (i, l) in lines.indexed)
      {
        'id': id * 10 + i,
        'lineKey': 'l$i',
        'quantity': l.$2,
        'completedQuantity': i < done ? l.$2 : 0,
        'version': 1,
      },
  ],
};

final orders = [
  order(
    9,
    'submitted',
    number: 18,
    origin: 'counter',
    label: 'Sam',
    minutes: 1,
    lines: [('Croque monsieur', 2, 750), ('Cappuccino', 1, 320)],
  ),
  order(
    8,
    'submitted',
    number: 17,
    minutes: 2,
    code: '4821',
    lines: [('Mushroom risotto', 1, 1350), ('Lemon tart', 1, 450)],
  ),
  order(
    7,
    'accepted',
    number: 16,
    minutes: 6,
    lines: [('Falafel wrap', 2, 800), ('Fresh orange juice', 2, 400)],
  ),
  order(
    6,
    'preparing',
    number: 15,
    minutes: 12,
    label: 'Lina',
    origin: 'counter',
    lines: [('Quiche lorraine', 1, 1100), ('Espresso', 2, 180)],
    done: 1,
  ),
  order(
    5,
    'preparing',
    number: 14,
    minutes: 24,
    fulfillment: 'dineIn',
    lines: [('Chicken club', 2, 950), ('Granola bowl', 1, 650)],
    done: 1,
  ),
  order(
    4,
    'ready',
    number: 13,
    minutes: 9,
    code: '5530',
    lines: [('Butter croissant', 3, 220)],
    done: 1,
  ),
];

final menu = [
  for (final (i, (name, category, price)) in [
    ('Butter croissant', 'Breakfast', 220),
    ('Pain au chocolat', 'Breakfast', 240),
    ('Granola bowl', 'Breakfast', 650),
    ('Croque monsieur', 'Sandwiches', 750),
    ('Falafel wrap', 'Sandwiches', 800),
    ('Chicken club', 'Sandwiches', 950),
    ('Quiche lorraine', 'Plates', 1100),
    ('Mushroom risotto', 'Plates', 1350),
    ('Espresso', 'Drinks', 180),
    ('Cappuccino', 'Drinks', 320),
    ('Fresh orange juice', 'Drinks', 400),
    ('Lemon tart', 'Sweets', 450),
  ].indexed)
    {
      'productId': 100 + i,
      'name': name,
      'category': category,
      'priceMinor': price,
      'modifiers': const [],
      'available': true,
    },
];

class ReviewApi extends PlatformApi {
  ReviewApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'owner',
        headers: () async => {},
      );

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'kitchen' || 'orders' => {'rows': orders, 'nextCursor': null},
    'counter.menu' || 'storefront' => {
      'id': 1,
      'name': 'Atelier Café',
      'currency': 'EUR',
      'voice': true,
      'settings': {
        'modes': ['pickup'],
      },
      'menu': menu,
    },
    'agent.inbox' => {
      'rows': [
        {
          'id': 2,
          'agent': 'payments',
          'command': 'payment.release',
          'title': 'Release abandoned checkout 10',
          'rationale': 'The customer opened PayPal 31 minutes ago and never approved the €12.00 pickup order. Releasing it frees the order for another payment.',
          'risk': 'money',
          'status': 'pending',
          'version': 1,
          'preview': {'checkoutId': 10, 'state': 'created'},
          'evidence': {
            'paypalStatus': 'PAYER_ACTION_REQUIRED',
            'paypalSource': 'paypal_mcp',
            'amountMinor': 1200,
            'currency': 'EUR',
            'ledgerState': 'created',
          },
        },
        {
          'id': 3,
          'agent': 'copilot',
          'command': 'settings.patch',
          'title':
              'Promise 35 minutes instead of 20 while the kitchen catches up',
          'rationale': 'Seven orders are open and the oldest is 14 minutes past its promise. 35 minutes is a time the kitchen can keep.',
          'risk': 'ops',
          'status': 'pending',
          'version': 1,
          'preview': {
            'preparationMinutes': {'from': 20, 'to': 35},
          },
          'evidence': {'queue': 7, 'oldestOpenMinutes': 34},
        },
      ],
    },
    'agent.activity' => {
      'rows': [
        {
          'id': 7,
          'agent': 'menu',
          'title': 'Read a menu photo',
          'summary': 'Read your photo: 14 dishes in 5 sections. 1 price to check before they go on sale.',
          'status': 'done',
          'chargedMicros': 13309,
          'state': {'ms': 18200},
        },
        {
          'id': 6,
          'agent': 'payments',
          'title': 'Check payment 10',
          'summary': 'Abandoned at PayPal; release suggested.',
          'status': 'done',
          'chargedMicros': 3231,
          'state': {'ms': 11300},
        },
      ],
    },
    'me' => {'userId': 'owner'},
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
  // A worktree without its own .tooling uses the SDK running the test.
  const font = 'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = [
    File('.tooling/flutter/$font'),
    if (root != null) File('$root/$font'),
  ].firstWhere((f) => f.existsSync());
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
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

  for (final (name, size) in [
    ('tablet', const Size(1280, 800)),
    ('phone', const Size(390, 844)),
  ]) {
    testWidgets('capture the staff app on a $name', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      const boundary = Key('review-canvas');
      final live = LiveContext(
        Runtime(ReviewApi()),
        restaurantId: 1,
        role: 'owner',
        name: 'Atelier Café',
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MotionScope(
            reducedMotion: true,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: StaffShell(
                live: live,
                memberships: const [
                  {'restaurantId': 1, 'role': 'owner', 'name': 'Atelier Café'},
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String screen) => expectLater(
        find.byKey(boundary),
        matchesGoldenFile('../build/staff-review/$name-$screen.png'),
      );
      Future<void> go(String label) async {
        final rail = find.byKey(const ValueKey('staff-navigation'));
        if (rail.evaluate().isNotEmpty) {
          await tester.tap(
            find.descendant(of: rail, matching: find.text(label)),
          );
        } else {
          // The phone dock may label only the current tab; tap its icon.
          final icon = switch (label) {
            'Counter' => Icons.storefront_outlined,
            'Kitchen' => Icons.restaurant_outlined,
            'Agents' => Icons.auto_awesome_outlined,
            _ => Icons.receipt_long_outlined,
          };
          await tester.tap(
            find
                .descendant(
                  of: find.byType(RaystoAdaptiveDock),
                  matching: find.byIcon(icon),
                )
                .first,
          );
        }
        await tester.pumpAndSettle();
      }

      await capture('orders');
      await go('Counter');
      await capture('counter');
      for (final dish in ['Croque monsieur', 'Croque monsieur', 'Cappuccino']) {
        final tile = find.text(dish).first;
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
      }
      await capture('counter-sale');
      await go('Kitchen');
      await capture('kitchen');
      await go('Agents');
      await capture('agents');
    });
  }

  // The orders board's filters on the narrowest phone at double text size.
  for (final locale in ['en', 'ar']) {
    testWidgets('capture the orders board at 320 px and 2x in $locale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 900);
      addTearDown(tester.view.reset);
      const boundary = Key('review-canvas');
      final live = LiveContext(
        Runtime(ReviewApi()),
        restaurantId: 1,
        role: 'owner',
        name: 'Atelier Café',
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MotionScope(
            reducedMotion: true,
            child: MaterialApp(
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
                    .copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: OrdersBoard(live: live),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('../build/staff-review/narrow-2x-$locale-orders.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }
}
