import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

/// A microphone that "records" a fixed half second of silence.
class FakeMic implements CounterMic {
  int started = 0, stopped = 0, cancelled = 0;
  @override
  Future<bool> allowed() async => true;
  @override
  Future<void> start() async => started++;
  @override
  Future<Uint8List> stop() async {
    stopped++;
    return wavFromPcm16(Uint8List(16000), CounterMic.sampleRate);
  }

  @override
  Future<void> cancel() async => cancelled++;
  @override
  void dispose() {}
}

/// A till with a burger and a coffee that takes oat milk. The voice agent
/// hears two burgers without onion, an oat-milk coffee, Sam and a lemonade.
class CounterApi extends PlatformApi {
  CounterApi({this.voice = true})
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'cashier',
        headers: () async => {},
      );
  final bool voice;
  final sent = <(int, int, String)>[];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'counter.menu' => {
      'id': 1,
      'currency': 'EUR',
      'voice': voice,
      'menu': [
        {
          'productId': 1,
          'name': 'Burger',
          'category': 'Mains',
          'priceMinor': 900,
          'modifiers': [],
        },
        {
          'productId': 2,
          'name': 'Coffee',
          'category': 'Drinks',
          'priceMinor': 300,
          'modifiers': [
            {
              'id': 'milk',
              'name': 'Milk',
              'min': 0,
              'max': 1,
              'options': [
                {'id': 'oat', 'name': 'Oat milk', 'priceMinor': 40},
              ],
            },
          ],
        },
      ],
    },
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> listen(
    int restaurantId,
    Uint8List audio,
    String mime,
  ) async {
    sent.add((restaurantId, audio.length, mime));
    return {
      'lines': [
        {'productId': 1, 'quantity': 2, 'options': [], 'note': 'no onion'},
        {
          'productId': 2,
          'quantity': 1,
          'options': ['milk:oat'],
          'note': '',
        },
      ],
      'customerLabel': 'Sam',
      'unmatched': ['lemonade'],
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

void main() {
  late FakeMic mic;
  setUp(() {
    mic = FakeMic();
    CounterMic.create = () => mic;
  });

  testWidgets('a spoken order fills the ticket for the cashier to check', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = CounterApi();
    final live = LiveContext(Runtime(api), restaurantId: 7, role: 'owner');
    await tester.pumpWidget(host(CounterScreen(live: live)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Say the order'));
    await tester.pump();
    expect(mic.started, 1);
    expect(
      find.text('Listening… say the dishes, options and a name.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.textContaining('Done · add to the ticket'));
    await tester.pumpAndSettle();
    expect(mic.stopped, 1);
    expect(api.sent.single, (7, 16044, 'audio/wav'));
    expect(find.text('Added from what was said'), findsOneWidget);
    expect(find.textContaining('2× Burger, 1× Coffee'), findsOneWidget);
    expect(find.textContaining('Not on the menu: lemonade'), findsOneWidget);
    expect(find.text('Burger · no onion'), findsOneWidget);
    expect(find.text('Coffee · 1 options'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Sam'), findsOneWidget);
    // 2 × 9.00 + 3.00 + 0.40 oat milk.
    expect(find.textContaining('21.40'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('recording stops by itself at the limit', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = CounterApi();
    final live = LiveContext(Runtime(api), restaurantId: 7, role: 'owner');
    await tester.pumpWidget(host(CounterScreen(live: live)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Say the order'));
    await tester.pump();
    for (var i = 0; i < 21; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();
    expect(mic.stopped, 1);
    expect(api.sent, hasLength(1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the microphone stays hidden while voice ordering is off', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final live = LiveContext(
      Runtime(CounterApi(voice: false)),
      restaurantId: 7,
      role: 'owner',
    );
    await tester.pumpWidget(host(CounterScreen(live: live)));
    await tester.pumpAndSettle();
    expect(find.text('Say the order'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('voice ordering fits a 320 px phone in Arabic at 2x text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final live = LiveContext(
      Runtime(CounterApi()),
      restaurantId: 7,
      role: 'owner',
    );
    await tester.pumpWidget(
      host(CounterScreen(live: live), scale: 2, locale: 'ar'),
    );
    await tester.pumpAndSettle();
    // The page scrolls; the section chips scroll sideways on their own.
    await tester.scrollUntilVisible(
      find.text('قل الطلب'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('قل الطلب'));
    await tester.pump();
    await tester.tap(find.textContaining('تم · أضف إلى التذكرة'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('أضيف مما قيل'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('the recording is a 16 kHz mono WAV', () {
    final wav = wavFromPcm16(Uint8List(32000), 16000);
    final b = ByteData.sublistView(wav);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    expect(b.getUint32(4, Endian.little), 36 + 32000);
    expect(b.getUint16(22, Endian.little), 1);
    expect(b.getUint32(24, Endian.little), 16000);
    expect(b.getUint32(40, Endian.little), 32000);
    expect(wav.length, 32044);
  });
}
