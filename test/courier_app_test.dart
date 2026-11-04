import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

// The courier's home and the diner's tracking map (stream S2) on a fake
// backend, with blank map tiles: an offer with its countdown, the steps to
// the door, location shared only with consent while the order is on its
// way, and the handover code. Every screen at 320 px with 2x text, in
// Arabic, in landscape and on a tablet, with reduced motion.

class DeliveryApi extends PlatformApi {
  DeliveryApi({this.status = 'outForDelivery', this.offer = true})
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'me',
        headers: () async => {},
      );
  final String status;
  final bool offer;
  final sent = <(String, Map<String, dynamic>, int?)>[];

  static const venue = {'latitude': 40.7424, 'longitude': -74.006};
  static const door = {'latitude': 40.7484, 'longitude': -73.9967};
  static final eta = {
    'estimate': true,
    'prepMinutes': 0,
    'rideMinutes': 9,
    'minutes': 9,
    'distanceMeters': 1430,
    'basis': 'Straight line × 1.3 at 15 km/h.',
  };

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> p = const {},
  ]) async => switch (operation) {
    'courier.jobs' => {
      'driver': {
        'id': 1,
        'name': 'Amal Courier',
        'vehicle': 'bike',
        'status': 'busy',
        'deliveredToday': 2,
      },
      'offers': [
        if (offer)
          {
            'offerId': 41,
            'assignmentId': 15,
            'expiresAt': DateTime.now().add(const Duration(seconds: 80)).toUtc().toIso8601String(),
            'number': 15,
            'items': 3,
            'area': 'New York',
            'eta': eta,
          },
      ],
      'jobs': [
        {
          'id': 14,
          'orderId': 114,
          'number': 14,
          'status': status,
          'version': 4,
          'orderStatus': status == 'assigned' ? 'ready' : 'outForDelivery',
          'ready': true,
          'customerLabel': null,
          'items': [
            {'name': 'Bowl', 'quantity': 2},
          ],
          'address': {
            'line': 'Sample drop-off 1 · not a real address',
            'city': 'New York',
            'instructions': 'Ring twice',
          },
          'dropoff': door,
          'eta': eta,
          'locationConsent': false,
        },
      ],
      'venue': venue,
      'proofMode': 'code',
      'offerSeconds': 90,
    },
    'delivery.tracking' => {
      'status': 'outForDelivery',
      'orderStatus': 'outForDelivery',
      'version': 5,
      'location': {'latitude': 40.746, 'longitude': -74.003},
      'eta': eta,
      'venue': venue,
      'dropoff': door,
      'driver': {'name': 'Amal', 'vehicle': 'bike', 'partner': false},
      'proofMode': 'code',
      'code': '4821',
      'number': 14,
    },
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
    sent.add((operation, data, resourceId));
    return switch (operation) {
      'delivery.respond' => {'state': 'accepted', 'offerId': resourceId},
      'delivery.proof' =>
        data['code'] == '4821'
            ? {'delivered': true}
            : {'delivered': false, 'attemptsLeft': 4},
      _ => {},
    };
  }

  @override
  Future<Map<String, dynamic>> upload(int id, Uint8List bytes) async => {};

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

LiveContext courier(DeliveryApi api) =>
    LiveContext(Runtime(api), restaurantId: 7, role: 'courier', name: 'Fixture café');

Future<void> size(WidgetTester tester, Size s) async {
  await tester.binding.setSurfaceSize(s);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// Closes the page so its timers and location stream stop.
Future<void> close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() => RaystoOsmMap.tiles = BlankTileProvider());
  tearDown(() => RaystoOsmMap.tiles = null);

  testWidgets('an offer counts down and is accepted in one tap', (tester) async {
    await size(tester, const Size(390, 1600));
    final api = DeliveryApi();
    await tester.pumpWidget(host(CourierHome(live: courier(api)), scale: 1));
    await settle(tester);
    expect(find.textContaining('New offer'), findsOneWidget);
    expect(find.textContaining('#15'), findsWidgets);
    expect(find.text('Times are estimates.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final before = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;
    expect(before, inInclusiveRange(0.8, 0.9));
    await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
    await settle(tester);
    final respond = api.sent.firstWhere((s) => s.$1 == 'delivery.respond');
    expect(respond.$2, {'answer': 'accept'});
    expect(respond.$3, 41);
    expect(find.text('The job is yours. Head to the café.'), findsOneWidget);
    await close(tester);
  });

  testWidgets('location goes only with consent, and the code completes the handover', (tester) async {
    await size(tester, const Size(390, 2200));
    final api = DeliveryApi(offer: false);
    final positions = StreamController<CourierFix>.broadcast();
    var listening = 0;
    await tester.pumpWidget(
      host(
        CourierHome(
          live: courier(api),
          positions: () {
            listening++;
            return positions.stream;
          },
        ),
        scale: 1,
      ),
    );
    await settle(tester);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    expect(find.textContaining('Ring twice'), findsOneWidget);
    // No consent, no position read.
    expect(listening, 0);
    await tester.tap(find.text('Share my location with the customer'));
    await settle(tester);
    expect(listening, 1);
    positions.add((latitude: 40.746, longitude: -74.003, accuracy: 12.0));
    await settle(tester);
    final shared = api.sent.where((s) => s.$1 == 'delivery.location').toList();
    expect(shared.single.$2, {'consent': true, 'latitude': 40.746, 'longitude': -74.003, 'accuracy': 12.0});
    expect(shared.single.$3, 14);
    // A second fix within 15 seconds is not sent.
    positions.add((latitude: 40.747, longitude: -74.002, accuracy: 10.0));
    await settle(tester);
    expect(api.sent.where((s) => s.$1 == 'delivery.location'), hasLength(1));
    await tester.tap(find.text('Share my location with the customer'));
    await settle(tester);
    expect(api.sent.last.$2, {'consent': false});

    await tester.enterText(find.byType(TextField), '1111');
    await tester.tap(find.widgetWithText(FilledButton, 'Delivered'));
    await settle(tester);
    expect(find.text('That code does not match. 4 tries left.'), findsOneWidget);
    // Let that message go before the next one.
    ScaffoldMessenger.of(tester.element(find.byType(CourierHome))).hideCurrentSnackBar();
    await settle(tester);
    await tester.enterText(find.byType(TextField), '4821');
    await tester.tap(find.widgetWithText(FilledButton, 'Delivered'));
    await settle(tester);
    final proof = api.sent.lastWhere((s) => s.$1 == 'delivery.proof');
    expect(proof.$2, {'code': '4821'});
    expect(proof.$3, 14);
    expect(find.text('Delivered. Thank you!'), findsOneWidget);
    await positions.close();
    await close(tester);
  });

  testWidgets('the tracking map shows the estimate, the driver and the code', (tester) async {
    await size(tester, const Size(390, 1400));
    final api = DeliveryApi();
    await tester.pumpWidget(
      host(trackingMapPage(courier(api).tenant(7), orderId: 114), scale: 1),
    );
    await settle(tester);
    expect(find.text('On the way'), findsWidgets);
    expect(find.text('About 9 min'), findsOneWidget);
    expect(find.text('Estimate'), findsOneWidget);
    expect(find.text('4821'), findsOneWidget);
    expect(find.text('Amal'), findsOneWidget);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Your delivery on the map: The café; Your door; Amal')),
      findsOneWidget,
    );
    await close(tester);
  });

  for (final (name, s, scale, locale) in [
    ('320 px, 2x text', const Size(320, 800), 2.0, 'en'),
    ('Arabic', const Size(320, 800), 2.0, 'ar'),
    ('landscape', const Size(800, 360), 1.0, 'en'),
    ('tablet', const Size(1280, 800), 1.0, 'fr'),
  ]) {
    testWidgets('the courier home and the tracking map fit: $name', (tester) async {
      await size(tester, s);
      for (final page in [
        (DeliveryApi api) => CourierHome(live: courier(api)),
        (DeliveryApi api) => trackingMapPage(courier(api).tenant(7), orderId: 114),
      ]) {
        await tester.pumpWidget(host(page(DeliveryApi(status: 'assigned')), scale: scale, locale: locale));
        await settle(tester);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.textContaining('OpenStreetMap'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
        // Scroll to the end: every part of the page lays out.
        await tester.drag(find.byType(ListView).first, const Offset(0, -3000));
        await settle(tester);
        expect(tester.takeException(), isNull);
        await close(tester);
      }
    });
  }
}
