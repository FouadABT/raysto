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
    await tester.tap(find.text('Approve').first);
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
}
