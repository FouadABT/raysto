import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

// The café's PayPal account on the phone (stream S6), read-only, on a fake
// backend: the café's own app with one feature off, the shared Sandbox
// account, and the partner path waiting for PayPal's approval. At 320 px
// with 2x text, in Arabic, and on a landscape tablet, with reduced motion.

Map<String, dynamic> ownStatus() => {
  'restaurantId': 1,
  'environment': 'sandbox',
  'mode': 'ownApp',
  'canEdit': true,
  'keysStorable': true,
  'stepUp': 'mfa',
  'ownApp': {
    'status': 'ready',
    'clientIdEnd': 'Q7xZ',
    'merchantId': '7XKQ2B9LMN3PA',
    'webhook': 'registered',
    'checkedAt': '2026-11-04T10:00:00Z',
    'updatedAt': '2026-11-04T10:00:00Z',
    'version': 2,
    'features': [
      {'name': 'orders', 'label': 'Take payments (Orders)', 'state': 'enabled'},
      {'name': 'refunds', 'label': 'Refunds', 'state': 'enabled'},
      {'name': 'payouts', 'label': 'Payouts', 'state': 'enabled'},
      {'name': 'invoicing', 'label': 'Invoicing', 'state': 'notEnabled'},
      {'name': 'transactionSearch', 'label': 'Transaction Search', 'state': 'enabled'},
      {'name': 'disputes', 'label': 'Disputes', 'state': 'enabled'},
    ],
  },
  'partner': {
    'available': false,
    'status': 'notConnected',
    'merchantId': null,
    'verifiedAt': null,
    'note': 'Needs PayPal\'s partner approval for Raysto. Until then, use your own PayPal app.',
  },
  'shared': true,
};

class AccountApi extends PlatformApi {
  AccountApi(this.status)
    : super(origin: Uri.parse('https://fixture.invalid'), identity: () => 'me', headers: () async => {});
  Map<String, dynamic> status;
  final asked = <String>[];

  @override
  Future<Map<String, dynamic>> query(String operation, [Map<String, dynamic> p = const {}]) async {
    asked.add(operation);
    return operation == 'merchant.status' ? status : {};
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
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: child,
  ),
);

Future<void> size(WidgetTester tester, Size s) async {
  await tester.binding.setSurfaceSize(s);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  test('modes, features and the webhook read in plain words', () {
    expect(paypalModeLabel('ownApp'), 'Your own PayPal app');
    expect(paypalModeLabel('sharedSandbox'), 'Raysto\'s shared Sandbox account');
    expect(paypalModeLabel('whatever'), 'Not connected');
    expect(paypalFeatureWord('notEnabled'), 'Not enabled in your PayPal app');
    expect(paypalFeatureWord('missing'), 'Not checked yet');
    expect(paypalWebhookWord('registered'), contains('as they happen'));
    expect(paypalFeatureLabels.keys, ['orders', 'refunds', 'payouts', 'invoicing', 'transactionSearch', 'disputes']);
  });

  testWidgets('the café\'s own app: masked client id, merchant id, what is off, and the partner note', (tester) async {
    await size(tester, const Size(320, 800));
    final api = AccountApi(ownStatus());
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner', name: 'Atelier');
    await tester.pumpWidget(host(PayPalAccountPage(live: live)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(api.asked, ['merchant.status']);
    final list = find.byType(Scrollable).first;
    for (final text in [
      'Your own PayPal app',
      '••••Q7xZ',
      '7XKQ2B9LMN3PA',
      'Not enabled in your PayPal app',
      'partner approval',
      'never pass through the phone',
    ]) {
      // The list builds lazily: drag until the line exists.
      for (var i = 0; i < 40 && find.textContaining(text).evaluate().isEmpty; i++) {
        await tester.drag(list, const Offset(0, -120));
        await tester.pumpAndSettle();
      }
      expect(find.textContaining(text), findsWidgets, reason: text);
    }
    // The phone never offers to type keys.
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a demo café on the shared Sandbox account, in Arabic and on a landscape tablet', (tester) async {
    final shared = ownStatus()
      ..['mode'] = 'sharedSandbox'
      ..['ownApp'] = null;
    final live = LiveContext(Runtime(AccountApi(shared)), restaurantId: 1, role: 'manager', name: 'Atelier');
    await size(tester, const Size(1280, 800));
    await tester.pumpWidget(host(PayPalAccountPage(live: live), locale: 'ar', scale: 1.3));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('حساب PayPal'), findsOneWidget);
    expect(find.text('حساب Sandbox المشترك لدى Raysto'), findsOneWidget);
    expect(find.textContaining('••••'), findsNothing);
    await size(tester, const Size(320, 640));
    await tester.pumpWidget(host(PayPalAccountPage(live: live)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Raysto\'s shared Sandbox account'), findsOneWidget);
  });
}
