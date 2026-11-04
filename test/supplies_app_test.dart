import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

// Supplies on the phone (stream S3), on a fake backend: low stock first,
// a planner proposal to approve, a fast count, and a delivery note read and
// matched against its order. Every screen at 320 px with 2x text, in Arabic,
// in landscape and on a tablet, with reduced motion.

Map<String, dynamic> item(
  int id,
  String name,
  String unit,
  num quantity, {
  bool reorder = false,
  bool low = false,
  num? cover,
  num suggested = 0,
}) => {
  'stockItemId': id,
  'name': name,
  'unit': unit,
  'quantity': quantity,
  'lowAt': 1,
  'low': low,
  'costMinor': 120,
  'valueMinor': (quantity * 120).round(),
  'leadDays': 2,
  'supplierId': 1,
  'supplierName': 'Marché Dupont',
  'version': 3,
  'dailyUsage': 2,
  'daysCover': cover,
  'stockOutAt': cover == null
      ? null
      : DateTime.now().add(Duration(hours: (cover * 24).round())).toUtc().toIso8601String(),
  'atArrival': 6,
  'parLevel': 18,
  'reorder': reorder,
  'suggestedQty': suggested,
};

class SuppliesApi extends PlatformApi {
  SuppliesApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'me',
        headers: () async => {},
      );
  final sent = <PendingCommand>[];
  final commands = <String, Map<String, dynamic>>{};
  final uploads = <int>[];

  static final match = {
    'lines': [
      {
        'name': 'Flour T55',
        'stockItemId': 1,
        'unit': 'kg',
        'orderedQty': 25,
        'deliveredQty': 20,
        'qtyVariance': -5,
        'orderedUnitMinor': 120,
        'deliveredUnitMinor': 120,
        'billedUnitMinor': null,
        'priceVariancePct': 0,
        'flags': ['short'],
      },
      {
        'name': 'Butter AOP',
        'stockItemId': 2,
        'unit': 'kg',
        'orderedQty': 10,
        'deliveredQty': 10,
        'qtyVariance': 0,
        'orderedUnitMinor': 980,
        'deliveredUnitMinor': 1050,
        'billedUnitMinor': null,
        'priceVariancePct': 7.1,
        'flags': ['price_up'],
      },
    ],
    'flagged': 2,
    'orderedTotalMinor': 12800,
    'deliveredTotalMinor': 12900,
    'billTotalMinor': 12900,
    'billDiffers': false,
    'clean': false,
    'currency': 'EUR',
    'supplierOrderId': 14,
    'reference': 'DN-77',
    'explanation': 'Flour arrived 5 kg short and butter costs 7.1% more than ordered.',
  };

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> p = const {},
  ]) async => switch (operation) {
    'stock.forecast' => {
      'basis': 'movements',
      'windowDays': 28,
      'currency': 'EUR',
      'rows': [
        item(7, 'Sea salt', 'kg', 4, cover: 80),
        item(3, 'Free-range eggs', 'piece', 40, low: true, cover: 2.9),
        item(1, 'Flour T55', 'kg', 10, reorder: true, cover: 5, suggested: 12),
      ],
      'waste': [],
    },
    'agent.inbox' => {
      'rows': [
        {
          'id': 5,
          'taskId': 41,
          'agent': 'supplies',
          'command': 'supplier.order.propose',
          'title': 'Order 1 items from Marché Dupont',
          'rationale': 'Flour covers 5 days and Dupont needs 2.',
          'risk': 'ops',
          'status': 'pending',
          'version': 1,
          'preview': {'totalMinor': 1440, 'currency': 'EUR'},
          'evidence': {
            'lines': [
              {'name': 'Flour T55', 'qty': 12, 'reason': '5 days of cover.'},
            ],
            'priceAlerts': [
              {'name': 'Flour T55', 'changePct': 6.2},
            ],
          },
        },
      ],
    },
    'supplier.orders' => {
      'rows': [
        {
          'id': 14,
          'supplierName': 'Marché Dupont',
          'state': 'sent',
          'totalMinor': 12800,
          'currency': 'EUR',
          'lines': [{}, {}],
          'version': 3,
        },
        {'id': 12, 'supplierName': 'Café Nord', 'state': 'billed', 'totalMinor': 11000, 'currency': 'EUR', 'lines': [{}], 'version': 6},
      ],
    },
    'media' => {
      'rows': [
        {'id': 31, 'status': 'approved'},
      ],
    },
    'agent.task' => {
      'id': 40,
      'status': 'done',
      'summary': 'Read the note.',
      'actions': [
        {'id': 7, 'command': 'stock.receive', 'title': 'Receive PO-14 from Marché Dupont', 'status': 'pending', 'version': 1},
        {'id': 8, 'command': 'bill.match', 'title': "Approve Marché Dupont's bill for PO-14", 'status': 'pending', 'version': 1},
      ],
    },
    'supplier.order' => {
      'id': 14,
      'state': 'sent',
      'delivery': {'id': 9, 'state': 'read', 'match': match},
    },
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    sent.add(command);
    return switch (command.operation) {
      'stock.count' => {'stockItemId': 1, 'quantity': 9.5, 'variance': -0.5},
      'agent.decide' => {'state': 'executed', 'actionId': command.body['resourceId']},
      'supply.receive' => {'taskId': 40, 'status': 'queued'},
      'supplies.plan' => {'taskId': 41},
      _ => {'ok': true},
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
    commands[operation] = data;
    return operation == 'media.upload' ? {'mediaId': 31, 'state': 'awaitingUpload'} : {};
  }

  @override
  Future<Map<String, dynamic>> upload(int id, Uint8List bytes) async {
    uploads.add(id);
    return {};
  }

  @override
  Stream<Map<String, dynamic>> watchRestaurant(int restaurantId, int after) => const Stream.empty();
}

class Runtime implements LiveRuntime {
  Runtime(this.platform);
  @override
  final PlatformApi platform;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget host(Widget child, {double scale = 2, String locale = 'en'}) => MotionScope(
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

/// A first screen with a button that opens Supplies, so the back gesture is real.
Widget opener(LiveContext live, {SupplyNotePicker? pick}) => Builder(
  builder: (c) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => SuppliesPage(live: live, pickNote: pick))),
        child: const Text('Open supplies'),
      ),
    ),
  ),
);

Future<void> size(WidgetTester tester, Size s) async {
  await tester.binding.setSurfaceSize(s);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// A tab may sit off-screen in the scrolling tab bar at 2x text (to the left in Arabic).
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Map<String, dynamic> dataOf(PendingCommand c) => jsonDecode('${c.body['dataJson']}') as Map<String, dynamic>;

void main() {
  test('quantities, typed counts and match lines read as words', () {
    expect(supplyQty(2.5, 'kg'), '2.5 kg');
    expect(supplyQty(26.0, 'piece'), '26 piece');
    expect(supplyQty(0.125), '0.125');
    expect(supplyParse('2,5'), 2.5);
    expect(supplyParse('-1'), isNull);
    expect(supplyParse('abc'), isNull);
    expect(supplyState({'reorder': true, 'low': true}), 'reorder');
    expect(supplyState({'low': true}), 'low');
    expect(supplyState({}), 'ok');
    final lines = (SuppliesApi.match['lines'] as List).cast<Map<String, dynamic>>();
    expect(supplyMatchText(lines[0], 'EUR'), '5 kg short (20 of 25 kg).');
    expect(supplyMatchText(lines[1], 'EUR'), '10.50 EUR instead of 9.80 EUR a unit (+7.1%).');
    expect(supplyFlagLabel('billed_differs'), 'Bill differs');
    expect(supplyFlagAgainst('price_down'), isFalse);
  });

  testWidgets('low stock comes first, in words, and a proposed order is approved, at 320 px and 2x', (tester) async {
    await size(tester, const Size(320, 800));
    final api = SuppliesApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(SuppliesPage(live: live)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('1 to reorder now'), findsOneWidget);
    expect(find.textContaining('Flour T55: 12'), findsOneWidget);
    expect(find.text('Flour T55 +6.2%'), findsOneWidget, reason: 'a price move above 5% is flagged');
    final list = find.byType(ListView).first;
    await tester.dragUntilVisible(find.text('Reorder 12 kg'), list, const Offset(0, -300));
    await tester.dragUntilVisible(find.text('Covered'), list, const Offset(0, -300));
    await tester.dragUntilVisible(find.text('Approve the draft order'), list, const Offset(0, 300));
    await tester.tap(find.text('Approve the draft order'));
    await tester.pumpAndSettle();
    final decide = api.sent.single;
    expect(decide.operation, 'agent.decide');
    expect(decide.body['resourceId'], 5);
    expect(decide.body['expectedVersion'], 1);
    expect(dataOf(decide), {'decision': 'approve'});
    expect(find.text('Approved. The draft order is ready to send.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a fast count saves only what was typed, and the back gesture guards unsaved numbers', (tester) async {
    await size(tester, const Size(320, 800));
    final api = SuppliesApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'manager');
    await tester.pumpWidget(host(opener(live)));
    await tester.tap(find.text('Open supplies'));
    await tester.pumpAndSettle();
    await openTab(tester, 'Count');
    expect(find.text('Type a count to save it'), findsOneWidget);
    final flour = find.byKey(const ValueKey('supply-count-1'));
    await tester.dragUntilVisible(flour, find.byType(ListView).last, const Offset(0, -200));
    await tester.enterText(flour, '9,5');
    await tester.pump();
    expect(find.text('Save counts · 1'), findsOneWidget);
    await tester.tap(find.text('Save counts · 1'));
    await tester.pumpAndSettle();
    final count = api.sent.single;
    expect(count.operation, 'stock.count');
    expect(dataOf(count), {'stockItemId': 1, 'quantity': 9.5});
    expect(find.textContaining('Flour T55 -0.5 kg'), findsOneWidget);
    // A number typed and not saved is not lost to a back gesture.
    await tester.enterText(flour, '3');
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard your counts?'), findsOneWidget);
    await tester.tap(find.text('Keep counting'));
    await tester.pumpAndSettle();
    expect(find.text('Supplies'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Open supplies'), findsOneWidget);
    expect(api.sent, hasLength(1), reason: 'nothing else was sent');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a delivery note photographed is matched against its order, with the variances in words', (tester) async {
    await size(tester, const Size(320, 800));
    final api = SuppliesApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    Future<(Uint8List, String)?> pick({required bool camera}) async => (Uint8List.fromList([0xff, 0xd8, 0xff]), 'image/jpeg');
    await tester.pumpWidget(host(SuppliesPage(live: live, pickNote: pick)));
    await tester.pumpAndSettle();
    await openTab(tester, 'Receive');
    final list = find.byType(ListView).last;
    // At 320 px the story header pushes the orders below the first screen.
    await tester.dragUntilVisible(find.textContaining('PO-14'), list, const Offset(0, -200));
    expect(find.textContaining('PO-14'), findsOneWidget, reason: 'only open orders are offered');
    expect(find.textContaining('PO-12', skipOffstage: false), findsNothing);
    await tester.dragUntilVisible(find.text('Photograph the delivery note'), list, const Offset(0, -300));
    await tester.tap(find.text('Photograph the delivery note'));
    await tester.pumpAndSettle();
    expect(api.commands['media.upload']!['purpose'], 'deliveryNote');
    expect(api.uploads, [31]);
    final receive = api.sent.single;
    expect(receive.operation, 'supply.receive');
    expect(dataOf(receive), {'mediaId': 31, 'supplierOrderId': 14});
    expect(find.text('2 lines differ'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Dearer'), findsOneWidget);
    expect(find.text('5 kg short (20 of 25 kg).'), findsOneWidget);
    expect(find.textContaining('7.1% more than ordered'), findsOneWidget);
    await tester.dragUntilVisible(find.text('Receive into stock'), find.byType(ListView).last, const Offset(0, -300));
    // Built is not on screen: bring the button fully into view before tapping.
    await tester.ensureVisible(find.text('Receive into stock'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receive into stock'));
    await tester.pumpAndSettle();
    expect(api.sent.last.operation, 'agent.decide');
    expect(api.sent.last.body['resourceId'], 7);
    expect(find.text('Received. Stock is up.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('in Arabic at 320 px the tabs and states are translated', (tester) async {
    await size(tester, const Size(320, 800));
    final live = LiveContext(Runtime(SuppliesApi()), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(SuppliesPage(live: live), locale: 'ar'));
    await tester.pumpAndSettle();
    expect(find.text('الإمدادات'), findsOneWidget);
    expect(find.text('المخزون المنخفض'), findsOneWidget);
    expect(find.text('الجرد'), findsOneWidget);
    expect(find.text('1 يجب إعادة طلبها الآن'), findsOneWidget);
    await openTab(tester, 'الاستلام');
    await tester.dragUntilVisible(find.text('صوّر إيصال التسليم'), find.byType(ListView).last, const Offset(0, -300));
    expect(find.text('صوّر إيصال التسليم'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final (name, s) in [('landscape 800x360', const Size(800, 360)), ('tablet 1280x800', const Size(1280, 800))]) {
    testWidgets('every tab lays out in $name', (tester) async {
      await size(tester, s);
      final live = LiveContext(Runtime(SuppliesApi()), restaurantId: 1, role: 'owner');
      await tester.pumpWidget(host(SuppliesPage(live: live, pickNote: ({required bool camera}) async => null), scale: 1));
      await tester.pumpAndSettle();
      expect(find.text('Supplies'), findsOneWidget);
      expect(find.text('1 to reorder now'), findsOneWidget);
      if (s.width > 1000) {
        // Everything is built at once on a tablet: reorder first, then low, then covered.
        expect(tester.getTopLeft(find.text('Reorder 12 kg')).dy, lessThan(tester.getTopLeft(find.text('Low')).dy));
        expect(tester.getTopLeft(find.text('Low')).dy, lessThan(tester.getTopLeft(find.text('Covered')).dy));
      }
      for (final t in ['Count', 'Receive', 'Low stock']) {
        await openTab(tester, t);
        expect(tester.takeException(), isNull, reason: '$t in $name');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('the match view says when everything agrees', (tester) async {
    await size(tester, const Size(320, 800));
    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: SupplyMatchView(
              match: {
                ...SuppliesApi.match,
                'lines': [
                  {...(SuppliesApi.match['lines'] as List).first as Map<String, dynamic>, 'deliveredQty': 25, 'qtyVariance': 0, 'flags': []},
                ],
                'flagged': 0,
                'clean': true,
                'billTotalMinor': null,
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Everything agrees'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('As ordered.'), findsOneWidget);
    expect(find.text('No bill yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
