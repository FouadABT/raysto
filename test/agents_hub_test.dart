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

/// A fake backend with two agent suggestions: a service change and a money
/// release that needs the manager's identity check.
class AgentsApi extends PlatformApi {
  AgentsApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'manager',
        headers: () async => {},
      );
  final decided = <String>[];
  final keys = <String>[];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'agent.inbox' => {
      'rows': [
        {
          'id': 1,
          'agent': 'copilot',
          'command': 'settings.patch',
          'title': 'Pause online orders for 20 minutes',
          'rationale': 'Nine orders are waiting and the oldest is 24 minutes old.',
          'risk': 'ops',
          'status': 'pending',
          'version': 1,
          'preview': {
            'paused': {'from': false, 'to': true},
          },
          'evidence': {},
        },
        {
          'id': 2,
          'agent': 'payments',
          'command': 'payment.release',
          'title': 'Release abandoned checkout 12',
          'rationale': 'The customer opened PayPal 40 minutes ago but never approved it.',
          'risk': 'money',
          'status': 'pending',
          'version': 1,
          'preview': {'checkoutId': 12, 'state': 'created'},
          'evidence': {
            'paypalStatus': 'NO_PAYPAL_ORDER',
            'paypalSource': 'paypal_mcp',
            'amountMinor': 1350,
            'currency': 'USD',
            'ledgerState': 'created',
          },
        },
      ],
    },
    'agent.activity' => {
      'rows': [
        {
          'id': 7,
          'agent': 'payments',
          'title': 'Check payment 12',
          'summary': 'Abandoned at PayPal; release suggested.',
          'status': 'done',
          'chargedMicros': 1800,
          'state': {'ms': 4200},
        },
      ],
    },
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    decided.add('${command.operation}:${command.body['dataJson'] ?? command.body}');
    keys.add(command.key);
    return {'state': 'executed', 'actionId': 1};
  }

  @override
  Stream<Map<String, dynamic>> watchRestaurant(int restaurantId, int after) =>
      const Stream.empty();
}

/// One generated photo waiting for the owner, and a menu with one dish.
class PhotoApi extends AgentsApi {
  // A 1×1 PNG.
  static final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1kAAAAASUVORK5CYII=',
  );
  final downloads = <int>[];

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => switch (operation) {
    'agent.inbox' => {
      'rows': [
        {
          'id': 9,
          'agent': 'images',
          'command': 'menu.image',
          'title': 'Use this photo for Burger',
          'rationale':
              'Drawn by OpenAI (gpt-image-1) from the dish’s own name, description and ingredients.',
          'risk': 'catalogue',
          'status': 'pending',
          'version': 1,
          'preview': {'dish': 'Burger', 'mediaId': 44, 'provider': 'openai'},
          'evidence': {'provider': 'openai', 'model': 'gpt-image-1'},
        },
      ],
    },
    'agent.activity' => {'rows': const []},
    'menu.manage' => {
      'menuVersion': 3,
      'rows': [
        {
          'id': 1,
          'productId': 10,
          'version': 2,
          'archived': false,
          'definition': {'name': 'Burger', 'category': 'Mains'},
        },
      ],
      'nextCursor': null,
    },
    _ => {},
  };

  @override
  Future<Uint8List> download(int id) async {
    downloads.add(id);
    return png;
  }
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
  testWidgets('the inbox shows what each agent found and why', (tester) async {
    final api = AgentsApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(agentsPage(live)));
    await tester.pumpAndSettle();
    expect(find.text('Pause online orders for 20 minutes'), findsOneWidget);
    expect(find.text('Online orders: open → paused'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Approve and confirm'), 300);
    expect(find.text('Release abandoned checkout 12'), findsOneWidget);
    expect(find.text('Checked through PayPal MCP'), findsOneWidget);
    expect(find.text('PayPal: NO_PAYPAL_ORDER'), findsOneWidget);
    expect(find.textContaining('13.50'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Check payment 12'), 300);
    expect(find.textContaining('\$0.002'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('approving a service change sends one decision', (tester) async {
    final api = AgentsApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(agentsPage(live)));
    await tester.pumpAndSettle();
    final approve = find.widgetWithText(AppButton, 'Approve');
    await tester.ensureVisible(approve);
    await tester.pumpAndSettle();
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(api.decided, hasLength(1));
    expect(api.decided.single, contains('agent.decide'));
    expect(api.decided.single, contains('approve'));
    expect(find.text('Done.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the inbox fits a 320 px phone in Arabic at 2x text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final live = LiveContext(Runtime(AgentsApi()), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(agentsPage(live), scale: 2, locale: 'ar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('موافقة وتأكيد'), 300);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a generated photo is shown for approval with who drew it', (
    tester,
  ) async {
    final api = PhotoApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(agentsPage(live)));
    await tester.pumpAndSettle();
    expect(find.text('Use this photo for Burger'), findsOneWidget);
    expect(find.text('Drawn by OpenAI · gpt-image-1'), findsOneWidget);
    expect(api.downloads, [44]);
    expect(find.byType(Image), findsOneWidget);
    final approve = find.widgetWithText(AppButton, 'Approve');
    await tester.ensureVisible(approve);
    await tester.pumpAndSettle();
    await tester.tap(approve);
    await tester.pumpAndSettle();
    expect(api.decided.single, contains('agent.decide'));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a dish asks the image studio for a photo', (tester) async {
    final api = PhotoApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(Scaffold(body: menuPage(live))));
    await tester.pumpAndSettle();
    expect(find.text('Fill missing photos with AI'), findsOneWidget);
    await tester.tap(find.text('Photo with AI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draw with OpenAI'));
    await tester.pumpAndSettle();
    expect(api.decided.single, startsWith('menu.photo:'));
    expect(api.decided.single, contains('"productIds":[10]'));
    expect(api.decided.single, contains('"provider":"openai"'));
    expect(
      find.text(
        'The image studio is drawing. Photos wait in Agents for your approval.',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
