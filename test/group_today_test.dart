import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

/// A fake backend with one group of two venues in two currencies.
class GroupApi extends PlatformApi {
  GroupApi({this.none = false})
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'owner',
        headers: () async => {},
      );
  final bool none;
  final ranges = <String>[];

  static const cafe = {
    'restaurantId': 5,
    'name': 'Atelier Café · Sample',
    'currency': 'USD',
    'role': 'owner',
  };
  static const harbour = {
    'restaurantId': 6,
    'name': 'Atelier Harbour · Sample',
    'currency': 'EUR',
    'role': 'manager',
  };

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async {
    if (operation == 'group.list') {
      return {
        'rows': none
            ? const []
            : [
                {
                  'id': 7,
                  'name': 'Atelier Group · Sample',
                  'role': 'owner',
                  'version': 1,
                  'venues': [cafe, harbour],
                },
              ],
      };
    }
    if (operation == 'group.overview') {
      ranges.add('${params['range']}');
      return {
        'groupId': 7,
        'range': params['range'],
        'venues': [
          {
            ...cafe,
            'paidSalesMinor': 184250,
            'orders': 61,
            'averageTicketMinor': 3020,
            'refundsMinor': 1250,
            'payoutsMinor': 28800,
            'billsDue': 2,
            'billsDueMinor': 31640,
            'lowStock': 3,
            'liveDeliveries': 1,
          },
          {
            ...harbour,
            'paidSalesMinor': 96400,
            'orders': 28,
            'averageTicketMinor': 3443,
            'refundsMinor': 0,
            'payoutsMinor': 0,
            'billsDue': 1,
            'billsDueMinor': 12900,
            'lowStock': 1,
            'liveDeliveries': 0,
          },
        ],
        'totals': const [],
      };
    }
    return {};
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
  bool reduced = true,
}) => MotionScope(
  reducedMotion: reduced,
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
        disableAnimations: reduced,
      ),
      child: child!,
    ),
    home: child,
  ),
);

Widget board(GroupApi api) => GroupTodayBoard(
  live: LiveContext(Runtime(api), restaurantId: 5, role: 'owner'),
);

/// The page is a lazy list: drag it until [f] is built.
Future<void> reach(WidgetTester tester, Finder f) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;
  for (var i = 0; i < 60 && f.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -160));
    await tester.pumpAndSettle();
  }
  expect(f, findsWidgets);
}

Future<void> size(WidgetTester tester, Size s) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s;
  addTearDown(tester.view.reset);
}

void main() {
  test('totals are kept per currency, never added across currencies', () {
    final totals = groupTotalsByCurrency([
      {'currency': 'USD', 'paidSalesMinor': 1000, 'orders': 2, 'lowStock': 1},
      {'currency': 'eur', 'paidSalesMinor': 700, 'orders': 1},
      {'currency': 'USD', 'paidSalesMinor': 250, 'orders': 1, 'billsDueMinor': 90},
    ]);
    expect(totals.map((t) => t['currency']), ['EUR', 'USD']);
    expect(totals.last['paidSalesMinor'], 1250);
    expect(totals.last['venues'], 2);
    expect(totals.last['billsDueMinor'], 90);
    expect(totals.first['paidSalesMinor'], 700);
  });

  test('the group is the one holding this venue, unless another is chosen', () {
    final groups = [
      {
        'id': 1,
        'venues': [
          {'restaurantId': 9},
        ],
      },
      {
        'id': 2,
        'venues': [
          {'restaurantId': 5},
        ],
      },
    ];
    expect(groupForVenue(groups, 5)?['id'], 2);
    expect(groupForVenue(groups, 5, 1)?['id'], 1);
    expect(groupForVenue(groups, 42)?['id'], 1);
    expect(groupForVenue(const [], 5), isNull);
  });

  testWidgets('a phone at double text size: one total per currency, then each venue', (
    tester,
  ) async {
    await size(tester, const Size(320, 800));
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(board(GroupApi()), scale: 2));
    await tester.pumpAndSettle();
    expect(find.text('Atelier Group · Sample'), findsOneWidget);
    final sandbox = find.textContaining(
      'share one Sandbox merchant',
      findRichText: true,
    );
    await reach(tester, sandbox);
    // Two currencies, two totals: never one sum.
    await reach(tester, find.text('964.00 EUR'));
    await reach(tester, find.text('1842.50 USD'));
    expect(find.textContaining('2806'), findsNothing);
    await reach(tester, find.text('Each venue'));
    await reach(tester, find.text('Deliveries out'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
  });

  testWidgets('a tablet puts the venues side by side and changes the period', (
    tester,
  ) async {
    await size(tester, const Size(1280, 800));
    final api = GroupApi();
    await tester.pumpWidget(host(board(api)));
    await tester.pumpAndSettle();
    expect(api.ranges, ['today']);
    await tester.tap(find.text('7 days'));
    await tester.pumpAndSettle();
    expect(api.ranges.last, '7d');
    await reach(tester, find.text('Average ticket'));
    final cafe = find.text('Atelier Café · Sample').last;
    final harbour = find.text('Atelier Harbour · Sample').last;
    expect(
      (tester.getTopLeft(cafe).dy - tester.getTopLeft(harbour).dy).abs(),
      lessThan(4),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Arabic at double size in landscape lays out without overflow', (
    tester,
  ) async {
    await size(tester, const Size(800, 360));
    await tester.pumpWidget(host(board(GroupApi()), scale: 2, locale: 'ar'));
    await tester.pumpAndSettle();
    expect(find.text('المجموعة'), findsWidgets);
    await reach(tester, find.text('كل مطعم'));
    await reach(tester, find.text('توصيلات جارية'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('with reduced motion the totals show at once', (tester) async {
    await size(tester, const Size(1280, 800));
    await tester.pumpWidget(host(board(GroupApi())));
    // Two frames: the load resolves, then the page draws; no animation runs.
    await tester.pump();
    await tester.pump();
    // The count-up lands on its value in the first frame instead of counting.
    expect(find.text('964.00 EUR'), findsWidgets);
    expect(find.text('0.00 EUR'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a venue outside any group says how a group is made', (
    tester,
  ) async {
    await size(tester, const Size(320, 800));
    await tester.pumpWidget(host(board(GroupApi(none: true)), scale: 2));
    await tester.pumpAndSettle();
    expect(find.text('This venue is not in a group'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
