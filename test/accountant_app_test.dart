import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

// The accountant on the phone (stream S1), on a fake backend: bills with
// PayPal's ids, paying one, snapping a bill, and a pay link's QR code. At
// 320 px with 2x text, in Arabic, in landscape and on a tablet, with
// reduced motion.

Map<String, dynamic> bill(int id, String vendor, int amount, String state, {Map<String, dynamic> extra = const {}}) => {
  'id': id,
  'vendor': vendor,
  'category': 'electricity',
  'amountMinor': amount,
  'vatMinor': 0,
  'currency': 'USD',
  'state': state,
  'payVia': 'elsewhere',
  'overdue': false,
  'version': 2,
  'read': {},
  ...extra,
};

class AccountantApi extends PlatformApi {
  AccountantApi()
    : super(origin: Uri.parse('https://fixture.invalid'), identity: () => 'me', headers: () async => {});
  final sent = <PendingCommand>[];
  final commands = <String, Map<String, dynamic>>{};
  final uploads = <int>[];

  @override
  Future<Map<String, dynamic>> query(String operation, [Map<String, dynamic> p = const {}]) async => switch (operation) {
    'bills' => {
      'currency': 'USD',
      'rows': [
        bill(41, 'Power Co', 19610, 'review', extra: {
          'payVia': 'paypal',
          'payeeEmail': 'billing@power.example',
          'dueAt': '2026-11-16T00:00:00Z',
          'read': {'explanation': 'Electricity for October, 8% above September.'},
        }),
        bill(40, 'City Water', 4200, 'approved', extra: {'overdue': true, 'dueAt': '2026-11-01T00:00:00Z'}),
        bill(38, 'Fiber ISP', 4990, 'paid', extra: {
          'payVia': 'paypal',
          'payeeEmail': 'billing@isp.example',
          'providerBatchId': 'BATCH-38',
          'providerItemId': 'ITEM-38',
          'payoutState': 'completed',
        }),
        bill(39, 'Rent Ltd', 180000, 'paidElsewhere', extra: {'proofMediaId': 77}),
      ],
      'summary': {'dueMinor': 23810, 'overdueMinor': 4200},
    },
    'requests' => {
      'currency': 'USD',
      'rows': [
        {
          'id': 7,
          'kind': 'link',
          'payerName': 'Acme Offices',
          'description': 'Team lunch',
          'amountMinor': 12000,
          'currency': 'USD',
          'state': 'open',
          'overdue': false,
          'payUrl': 'https://api.rays.to/pay/0123456789abcdef0123456789abcdef',
        },
        {
          'id': 6,
          'kind': 'link',
          'payerName': 'Nadia',
          'description': 'Deposit',
          'amountMinor': 5000,
          'currency': 'USD',
          'state': 'paid',
          'overdue': false,
          'providerCaptureId': 'CAPTURE-6',
        },
      ],
      'summary': {'outstandingMinor': 12000, 'overdueMinor': 0},
    },
    'agent.inbox' => {'rows': []},
    'media' => {
      'rows': [
        {'id': 31, 'status': 'approved'},
      ],
    },
    _ => {},
  };

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    sent.add(command);
    return switch (command.operation) {
      'bill.pay' => {'billId': 41, 'state': 'paying', 'providerBatchId': 'BATCH-9'},
      'request.create' => {
        'id': 8,
        'kind': 'link',
        'payerName': 'Lina',
        'description': 'Cake',
        'amountMinor': 2550,
        'currency': 'USD',
        'state': 'open',
        'payUrl': 'https://api.rays.to/pay/ffffffffffffffffffffffffffffffff',
      },
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
    return switch (operation) {
      'media.upload' => {'mediaId': 31, 'state': 'awaitingUpload'},
      'bill.snap' => {'mediaId': 31, 'taskId': 50, 'duplicateOfId': null},
      _ => {},
    };
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

Future<(Uint8List, String)?> pdf({required bool camera}) async => (Uint8List.fromList(utf8.encode('%PDF-1.4 bill')), 'application/pdf');

void main() {
  late AccountantApi api;
  late LiveContext live;
  setUp(() {
    api = AccountantApi();
    live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner', name: 'Atelier');
  });

  test('a bill offers its next step, and PayPal ids or the proof, never a bare claim', () {
    expect(accountantBillActions({'state': 'review', 'payVia': 'paypal', 'payeeEmail': 'a@b.co'}), ['pay', 'approve', 'markPaid']);
    expect(accountantBillActions({'state': 'review', 'payVia': 'paypal', 'payeeEmail': 'a@b.co', 'duplicateOfId': 3}), ['approve', 'markPaid']);
    expect(accountantBillActions({'state': 'approved', 'payVia': 'elsewhere'}), ['markPaid']);
    expect(accountantBillActions({'state': 'paid'}), isEmpty);
    expect(accountantEvidence({'state': 'paid', 'providerBatchId': 'B', 'providerItemId': 'I', 'payoutState': 'completed'}), 'PayPal Payouts B · item I · completed');
    expect(accountantEvidence({'state': 'paidElsewhere', 'proofMediaId': 9}), 'Paid elsewhere · proof #9');
    expect(accountantEvidence({'state': 'review'}), '');
    expect(accountantMinor('12,50'), 1250);
    expect(accountantMinor('0'), isNull);
    expect(accountantMinor('1.234'), isNull);
  });

  testWidgets('bills show PayPal ids, and paying one sends bill.pay once with approval', (tester) async {
    await size(tester, const Size(320, 800));
    await tester.pumpWidget(host(AccountantPage(live: live, pickFile: pdf)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final list = find.byType(Scrollable).first;
    for (final text in ['City Water', 'PayPal Payouts BATCH-38 · item ITEM-38', 'Paid elsewhere · proof #77']) {
      await tester.scrollUntilVisible(find.textContaining(text), 200, scrollable: list);
      expect(find.textContaining(text), findsOneWidget);
    }
    await tester.drag(list, const Offset(0, 4000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('Power Co'), 100, scrollable: list);
    await tester.ensureVisible(find.textContaining('Power Co'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Power Co'));
    await tester.pumpAndSettle();
    expect(find.text('Electricity for October, 8% above September.'), findsOneWidget);
    final pay = find.textContaining('via PayPal (identity check)');
    await tester.ensureVisible(pay);
    await tester.tap(pay);
    await tester.pumpAndSettle();
    final sent = api.sent.where((c) => c.operation == 'bill.pay').toList();
    expect(sent, hasLength(1));
    expect(sent.single.body['resourceId'], 41);
    expect(jsonDecode(sent.single.body['dataJson'] as String), {'approve': true});
    expect(find.textContaining('BATCH-9'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a snapped bill is uploaded, scanned and handed to the accountant', (tester) async {
    await size(tester, const Size(800, 360));
    await tester.pumpWidget(host(AccountantPage(live: live, pickFile: pdf), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a file'));
    await tester.pumpAndSettle();
    expect(api.commands['media.upload']?['purpose'], 'bill');
    expect(api.commands['media.upload']?['mime'], 'application/pdf');
    expect(api.uploads, [31]);
    expect(api.commands['bill.snap'], {'mediaId': 31});
    expect(find.textContaining('The accountant is reading the bill'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pay link shows its QR code, and a new one is created once', (tester) async {
    await size(tester, const Size(1280, 800));
    await tester.pumpWidget(host(AccountantPage(live: live, pickFile: pdf), scale: 1));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.textContaining('Acme Offices'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.textContaining('Acme Offices'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('https://api.rays.to/pay/0123456789abcdef0123456789abcdef'), findsOneWidget);
    Navigator.of(tester.element(find.byType(QrImageView))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('New pay link'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Who pays'), 'Lina');
    await tester.enterText(find.widgetWithText(TextField, 'For'), 'Cake');
    await tester.enterText(find.widgetWithText(TextField, 'Amount (USD)'), '25.555');
    await tester.tap(find.text('Create the pay link'));
    await tester.pumpAndSettle();
    expect(find.textContaining('at most two decimals'), findsOneWidget);
    expect(api.sent.where((c) => c.operation == 'request.create'), isEmpty);
    await tester.enterText(find.widgetWithText(TextField, 'Amount (USD)'), '25.50');
    await tester.tap(find.text('Create the pay link'));
    await tester.pumpAndSettle();
    final created = api.sent.where((c) => c.operation == 'request.create').toList();
    expect(created, hasLength(1));
    expect(jsonDecode(created.single.body['dataJson'] as String)['amountMinor'], 2550);
    expect(find.text('https://api.rays.to/pay/ffffffffffffffffffffffffffffffff'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic at 320 px with 2x text lays out without overflow', (tester) async {
    await size(tester, const Size(320, 800));
    await tester.pumpWidget(host(AccountantPage(live: live, pickFile: pdf), locale: 'ar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('المحاسب'), findsOneWidget);
    expect(find.text('صوّر فاتورة'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
