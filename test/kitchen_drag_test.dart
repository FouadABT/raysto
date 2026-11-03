import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

Map<String, dynamic> order(
  int id,
  String status, {
  bool allDone = false,
}) => {
  'id': id,
  'number': id,
  'origin': 'online',
  'fulfillment': 'pickup',
  'status': status,
  'paymentStatus': 'paid',
  'version': 4,
  'currency': 'USD',
  'totalMinor': 1250,
  'customerLabel': null,
  'pickupCode': null,
  'visitId': null,
  'createdAt': DateTime.now()
      .subtract(const Duration(minutes: 3))
      .toUtc()
      .toIso8601String(),
  'lines': [
    {'lineKey': 'l1', 'name': 'Croque monsieur', 'quantity': 1},
  ],
  'tickets': [
    {
      'id': id * 10,
      'lineKey': 'l1',
      'quantity': 1,
      'completedQuantity': allDone ? 1 : 0,
      'version': 1,
    },
  ],
};

/// The pass: one new ticket, one cooking with a line still open, one ready.
class KitchenApi extends PlatformApi {
  KitchenApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'kitchen',
        headers: () async => {},
      );
  final sent = <String>[];
  final orders = [
    order(3, 'submitted'),
    order(2, 'preparing'),
    order(1, 'ready', allDone: true),
  ];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'kitchen' => {'rows': orders, 'nextCursor': null},
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> command(
    String operation,
    Map<String, dynamic> data, {
    int? restaurantId,
    int? resourceId,
    int? version,
  }) async {
    sent.add('$operation:$resourceId:${data['status']}@$version');
    return {'version': (version ?? 0) + 1};
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

Future<void> board(
  WidgetTester tester,
  KitchenApi api, {
  Size size = const Size(1280, 800),
  double scale = 1,
  String locale = 'en',
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
  await tester.pumpWidget(
    host(KitchenBoard(live: live), scale: scale, locale: locale),
  );
  await tester.pumpAndSettle();
}

/// Long-presses [ticket] and carries it onto [lane]'s heading.
Future<void> carry(WidgetTester tester, Finder ticket, Finder lane) async {
  final gesture = await tester.startGesture(tester.getCenter(ticket));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
  final target = tester.getCenter(lane) + const Offset(0, 40);
  await gesture.moveTo(target);
  await tester.pump();
  await gesture.moveTo(target + const Offset(2, 2));
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('a ticket carried to the next lane is sent after the Undo window', (
    tester,
  ) async {
    final api = KitchenApi();
    await board(tester, api);
    await carry(tester, find.text('#3'), find.text('In progress · 1'));
    // It moves at once on the board; nothing is sent yet.
    expect(find.text('In progress · 2'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(api.sent, isEmpty);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(api.sent, ['order.transition:3:accepted@4']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Undo keeps the ticket where it was and sends nothing', (
    tester,
  ) async {
    final api = KitchenApi();
    await board(tester, api);
    await carry(tester, find.text('#3'), find.text('In progress · 1'));
    // Let the snackbar arrive before pressing its action.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('New · 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(api.sent, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a ticket with an open line is refused by Ready', (tester) async {
    final api = KitchenApi();
    await board(tester, api);
    await carry(tester, find.text('#2'), find.text('Ready · 1'));
    expect(find.text('Ready · 1'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    expect(api.sent, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the buttons still work on a tablet, without dragging', (
    tester,
  ) async {
    final api = KitchenApi();
    await board(tester, api);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(api.sent, ['order.transition:3:accepted@4']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a phone keeps buttons only, even at double size in Arabic', (
    tester,
  ) async {
    final api = KitchenApi();
    await board(tester, api, size: const Size(320, 800), scale: 2, locale: 'ar');
    expect(find.byType(DraggableTicket), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a landscape phone at double size keeps working', (tester) async {
    final api = KitchenApi();
    await board(tester, api, size: const Size(800, 360), scale: 2);
    expect(find.byType(DraggableTicket), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a landscape tablet lays the lanes side by side', (tester) async {
    final api = KitchenApi();
    await board(tester, api, size: const Size(1280, 800), scale: 2);
    expect(find.byType(DraggableTicket), findsNWidgets(3));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
