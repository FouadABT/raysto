import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

Map<String, dynamic> fixture(String range) => jsonDecode(
  File('docs/fixtures/dashboard-${range == '30d' ? '7d' : range}.json')
      .readAsStringSync(),
) as Map<String, dynamic>;

/// A fake backend answering `dashboard` from the frozen contract fixtures.
class TodayApi extends PlatformApi {
  TodayApi({this.empty = false})
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'owner',
        headers: () async => {},
      );
  final bool empty;
  final ranges = <String>[];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async {
    if (operation == 'me') {
      return {
        'userId': 'owner',
        'profile': {'displayName': 'Fouad Abt'},
      };
    }
    if (operation != 'dashboard') return {};
    final range = '${params['range']}';
    ranges.add(range);
    final d = fixture(range);
    if (!empty) return d;
    // A café with no paid order yet: every figure is zero, nothing listed.
    final kpis = d['kpis'] as Map<String, dynamic>;
    return {
      ...d,
      'points': [
        for (final p in d['points'] as List)
          {...p as Map<String, dynamic>, 'salesMinor': 0, 'orders': 0},
      ],
      'kpis': {
        for (final k in kpis.keys)
          k: {
            'value': 0,
            'previous': 0,
            'series': [for (final _ in kpis[k]['series'] as List) 0],
          },
      },
      'channels': const [],
      'latest': const [],
      'staff': const [],
      'kitchen': const {
        'submitted': 0,
        'accepted': 0,
        'preparing': 0,
        'ready': 0,
        'oldestMinutes': 0,
      },
      'target': const {'dailyTargetMinor': 30000, 'todayMinor': 0},
      'sample': null,
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

Widget host(
  Widget child, {
  double scale = 1,
  String locale = 'en',
  ThemeData? theme,
}) => MotionScope(
  reducedMotion: true,
  child: MaterialApp(
    theme: theme ?? AppTheme.light,
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: child,
  ),
);

Widget today(TodayApi api) => TodayBoard(
  live: LiveContext(Runtime(api), restaurantId: 5, role: 'owner'),
  now: () => DateTime(2026, 11, 3, 19),
);

/// The device's own size, so layout and MediaQuery agree.
Future<void> size(WidgetTester tester, Size s) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets(
    'dark Today headings and empty kitchen chips retain readable contrast',
    (tester) async {
      await size(tester, const Size(320, 800));
      await tester.pumpWidget(
        host(today(TodayApi(empty: true)), theme: AppTheme.dark, scale: 2),
      );
      await tester.pumpAndSettle();
      double contrast(Color foreground, Color background) {
        final a = foreground.computeLuminance(),
            b = background.computeLuminance();
        return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      }

      final title = tester.widget<Text>(
        find.descendant(of: find.byType(AppBar), matching: find.text('Today')),
      );
      expect(
        contrast(title.style!.color!, AppTheme.dark.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      final greeting = tester.widget<RichText>(
        find
            .descendant(
              of: find.byType(Greeting),
              matching: find.byType(RichText),
            )
            .first,
      );
      final span = greeting.text as TextSpan;
      expect(
        contrast(span.style!.color!, AppTheme.dark.colorScheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      await tester.ensureVisible(find.text('Kitchen live'));
      await tester.pumpAndSettle();
      for (final pill in find.byType(AppPill).evaluate()) {
        final parent = find.byWidget(pill.widget);
        final background = tester.widget<DecoratedBox>(
          find
              .descendant(of: parent, matching: find.byType(DecoratedBox))
              .first,
        );
        final text = tester.widget<RichText>(
          find.descendant(of: parent, matching: find.byType(RichText)).first,
        );
        expect(
          contrast(
            text.text.style!.color!,
            (background.decoration as BoxDecoration).color!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
  group('dashboard words', () {
    test('greetings follow the hour', () {
      expect(greetingFor(8), 'Good morning');
      expect(greetingFor(13), 'Good afternoon');
      expect(greetingFor(19), 'Good evening');
    });
    test('a first name, or none', () {
      expect(firstName('Fouad Abt'), 'Fouad');
      expect(firstName(null), isNull);
      expect(firstName('  '), isNull);
    });
    test('the view reads the contract fixture', () {
      final d = Dashboard(fixture('7d'));
      expect(d.value('sales'), 19530);
      expect(d.inKitchen, 4);
      expect(d.target, 30000);
      expect(d.sample, isNotNull);
      expect(d.hasSales, isTrue);
      expect(Dashboard(fixture('today')).sample, isNull);
    });
  });

  testWidgets('a phone shows one figure, the kitchen and the latest orders', (
    tester,
  ) async {
    await size(tester, const Size(320, 800));
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(today(TodayApi()), scale: 2));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Good evening', findRichText: true),
      findsWidgets,
    );
    expect(find.textContaining('Fouad', findRichText: true), findsWidgets);
    expect(find.text('21.50 USD'), findsWidgets);
    // The hero reads as one value to assistive technology.
    final hero = tester.getSemantics(find.bySemanticsLabel('Paid sales').first);
    expect(hero.value, '21.50 USD');
    // No trend chart on a phone: one figure, not a wall of cards.
    expect(find.byType(RaystoAreaChart), findsNothing);
    await tester.ensureVisible(find.text('Latest orders'));
    expect(find.text('Kitchen live'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets(
    'a tablet shows the trend with the labelled sample beside the kitchen',
    (tester) async {
      await size(tester, const Size(1280, 800));
      final api = TodayApi();
      await tester.pumpWidget(host(today(api)));
      await tester.pumpAndSettle();
      expect(find.text('KITCHEN LIVE'), findsOneWidget);
      expect(find.byType(RaystoDonut), findsOneWidget);
      await tester.tap(find.text('7 days'));
      await tester.pumpAndSettle();
      expect(api.ranges.last, '7d');
      expect(find.byType(RaystoAreaChart), findsOneWidget);
      // The sample is always named as such, never shown as sales.
      expect(find.text('Sample · not real sales'), findsOneWidget);
      expect(find.text('195.30 USD'), findsWidgets);
      final kitchen = tester.getTopLeft(find.text('KITCHEN LIVE'));
      final hero = tester.getTopLeft(find.textContaining('Paid sales ·'));
      expect(kitchen.dx, greaterThan(hero.dx));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('with no paid order yet it says so and draws no chart', (
    tester,
  ) async {
    await size(tester, const Size(1280, 800));
    await tester.pumpWidget(host(today(TodayApi(empty: true))));
    await tester.pumpAndSettle();
    expect(find.text('No paid orders in this period yet.'), findsOneWidget);
    expect(
      find.text('When a paid order comes in, it shows here.'),
      findsOneWidget,
    );
    expect(find.byType(RaystoAreaChart), findsNothing);
    expect(find.byType(RaystoSparkline), findsNothing);
    expect(find.byType(RaystoDonut), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Arabic at double size in landscape lays out without overflow', (
    tester,
  ) async {
    await size(tester, const Size(800, 360));
    await tester.pumpWidget(host(today(TodayApi()), scale: 2, locale: 'ar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('مساء الخير', findRichText: true), findsWidgets);
    await tester.ensureVisible(find.text('أحدث الطلبات'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
