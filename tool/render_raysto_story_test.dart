// Deliberate review captures of production widgets with isolated fixtures.
// No Firebase account, restaurant, payment or network request is created.
// flutter test tool/render_raysto_story_test.dart --update-goldens
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/auth/session_controller.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/account/live_account_screen.dart';
import 'package:raysto/features/connected/connected_app.dart';

import '../test/support/session_fakes.dart';

class _Auth implements FirebaseAuth {
  @override
  User? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Fixtures implements PlatformApi {
  @override
  Future<RecordData> query(
    String name, [
    RecordData parameters = const {},
  ]) async => switch (name) {
    'discovery' => {
      'rows': [
        {
          'id': 1,
          'name': 'Olive Kitchen',
          'open': true,
          'address': '12 Garden Lane',
        },
        {
          'id': 2,
          'name': 'Harbor Café',
          'open': true,
          'address': '8 Riverside Walk',
        },
      ],
    },
    'me' => {
      'memberships': [
        {'restaurantId': 1, 'name': 'Olive Kitchen', 'role': 'owner'},
      ],
    },
    'storefront' => {
      'name': 'Olive Kitchen',
      'currency': 'EUR',
      'settings': {
        'address': '12 Garden Lane',
        'modes': ['dineIn', 'pickup'],
      },
      'menu': [
        {
          'productId': 1,
          'name': 'Garden bowl',
          'description': 'Roasted vegetables, herbs and lemon dressing.',
          'priceMinor': 1450,
          'category': 'Seasonal plates',
        },
        {
          'productId': 2,
          'name': 'Olive flatbread',
          'description': 'Warm bread, olive oil and fresh herbs.',
          'priceMinor': 850,
          'category': 'To share',
        },
      ],
    },
    _ => {'rows': []},
  };
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Runtime implements LiveRuntime {
  _Runtime(this.session);
  final SessionController session;
  @override
  Future<void> Function(FirebaseAuthMultiFactorException)? resolveMultiFactor;
  @override
  SessionController createSession() => session;
  @override
  FirebaseAuth get firebase => _Auth();
  @override
  PlatformApi get platform => _Fixtures();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });

  testWidgets('capture Raysto story in actual connected screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final session = SessionController(
      identity: IdentityFake(),
      backend: SessionFake(),
    );
    final runtime = _Runtime(session);
    addTearDown(session.dispose);
    const boundary = Key('story-review');

    Future<void> show(
      Widget page, {
      bool dark = false,
      double scale = 1,
      bool rtl = false,
    }) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: MotionScope(
                reducedMotion: true,
                child: RepaintBoundary(key: boundary, child: child!),
              ),
            ),
          ),
          home: page,
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/images/raysto-table-story.png'),
          tester.element(find.byType(Scaffold).first),
        );
      });
      await tester.pumpAndSettle();
    }

    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull, reason: name);
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('../docs/screenshots/story/$name.png'),
      );
    }

    await show(LiveAccountScreen(runtime: runtime));
    await capture('welcome');
    await show(ConnectedApp(runtime: runtime, onSignOut: () async {}));
    await capture('discover');
    await tester.tap(find.byKey(const ValueKey('dock-1')));
    await tester.pumpAndSettle();
    await capture('activity');
    await tester.tap(find.byKey(const ValueKey('dock-2')));
    await tester.pumpAndSettle();
    await capture('restaurants');
    await show(
      restaurantHome(
        LiveContext(
          runtime,
          restaurantId: 1,
          role: 'owner',
          name: 'Olive Kitchen',
        ),
      ),
    );
    await capture('service');
    await show(
      StorefrontPage(
        live: LiveContext(runtime, restaurantId: 1, name: 'Olive Kitchen'),
      ),
    );
    await capture('menu');
    await show(ordersPage(LiveContext(runtime)));
    await capture('empty');
    await show(
      ConnectedApp(runtime: runtime, onSignOut: () async {}),
      dark: true,
    );
    await capture('discover-dark');
    tester.view.physicalSize = const Size(320, 850);
    await show(
      ConnectedApp(runtime: runtime, onSignOut: () async {}),
      dark: true,
      scale: 2,
      rtl: true,
    );
    await capture('accessible-320');
    await tester.pumpWidget(const SizedBox());
  });
}
