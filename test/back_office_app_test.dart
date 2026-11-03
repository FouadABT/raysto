import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

String iso(DateTime at) => at.toUtc().toIso8601String();

Map<String, dynamic> shift(
  int id,
  String name,
  String role,
  DateTime start, {
  String? userId,
  DateTime? clockIn,
  DateTime? clockOut,
}) => {
  'id': id,
  'name': name,
  'role': role,
  'userId': userId,
  'startsAt': iso(start),
  'endsAt': iso(start.add(const Duration(hours: 6))),
  'clockInAt': clockIn == null ? null : iso(clockIn),
  'clockOutAt': clockOut == null ? null : iso(clockOut),
  'hourlyRateMinor': 1400,
};

/// A fake backend: three shifts today (one is mine), two later in the week,
/// a paid order, and a record of every command sent.
class OfficeApi extends PlatformApi {
  OfficeApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'me',
        headers: () async => {},
      );
  final sent = <PendingCommand>[];
  final params = <String, Map<String, dynamic>>{};
  bool clockedIn = false;
  Map<String, dynamic>? complaint;
  Map<String, dynamic>? run;

  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> p = const {},
  ]) async {
    params[operation] = p;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    return switch (operation) {
      'shifts' => {
        'rows': [
          shift(
            1,
            'Sam',
            'waiter',
            today,
            userId: 'me',
            clockIn: clockedIn ? now.subtract(const Duration(minutes: 5)) : null,
          ),
          shift(
            2,
            'Nour',
            'kitchen',
            today,
            userId: 'u2',
            clockIn: today,
          ),
          shift(3, 'Leo', 'waiter', today.add(const Duration(hours: 7))),
          shift(4, 'Nour', 'kitchen', today.add(const Duration(days: 1))),
          shift(5, 'Sam', 'waiter', today.add(const Duration(days: 2))),
        ],
      },
      'order' => {
        'id': 12,
        'number': 7,
        'status': 'completed',
        'paymentStatus': 'paid',
        'fulfillment': 'pickup',
        'origin': 'online',
        'currency': 'USD',
        'totalMinor': 2150,
        'version': 2,
        'lines': [
          {'lineKey': 'l0', 'name': 'Croissant', 'quantity': 1, 'unitPriceMinor': 220},
        ],
        'complaint': ?complaint,
      },
      'assistant.run' => run ?? {'status': 'running'},
      _ => {},
    };
  }

  @override
  Future<Map<String, dynamic>> submit(PendingCommand command) async {
    sent.add(command);
    if (command.operation == 'shift.clock') {
      clockedIn = command.body['action'] == 'in';
    }
    if (command.operation == 'complaint.open') {
      complaint = {'status': 'open'};
    }
    return switch (command.operation) {
      'assistant.approve' => {'kind': 'basket', 'quoteId': 9},
      'order.submit' => {'orderId': 7, 'status': 'awaitingPayment', 'number': 7},
      'payment.allocate' => {'checkoutId': 5, 'state': 'reserved'},
      'payment.checkout' => {
        'checkoutId': 5,
        'state': 'created',
        'approvalUrl': 'https://www.sandbox.paypal.com/checkoutnow?token=T',
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
    if (operation == 'assistant.start') return {'runId': 41, 'status': 'queued'};
    return {'version': 2};
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

void main() {
  test('a shift reads its state from the clock stamps', () {
    final at = DateTime(2026, 11, 3, 9);
    expect(StaffShift(shift(1, 'Sam', 'waiter', at)).state, 'scheduled');
    expect(StaffShift(shift(1, 'Sam', 'waiter', at, clockIn: at)).state, 'working');
    expect(
      StaffShift(shift(1, 'Sam', 'waiter', at, clockIn: at, clockOut: at)).state,
      'done',
    );
    expect(weekStart(DateTime(2026, 11, 5, 15)), DateTime(2026, 11, 2));
    expect(weekStart(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    expect(tipFor(2150, 10), 215);
    expect(tipFor(999, 5), 50);
  });

  testWidgets('the shifts board clocks my shift in and out at 320 px, 2x', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = OfficeApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'waiter');
    await tester.pumpWidget(host(ShiftsBoard(live: live)));
    await tester.pumpAndSettle();
    expect(api.params['shifts']!['restaurantId'], 1);
    expect(api.params['shifts']!.containsKey('from'), isTrue);
    expect(find.text('Today · 3'), findsOneWidget);
    expect(find.text('Sam'), findsWidgets);
    // Cards are built as they scroll into view.
    final list = find.byType(ListView);
    await tester.dragUntilVisible(find.text('Nour'), list, const Offset(0, -300));
    expect(find.textContaining('On shift since'), findsOneWidget); // Nour
    await tester.drag(list, const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clock in'));
    await tester.pumpAndSettle();
    final clock = api.sent.single;
    expect(clock.operation, 'shift.clock');
    expect(clock.body, {'restaurantId': 1, 'shiftId': 1, 'action': 'in'});
    expect(find.text('Clock out'), findsOneWidget);
    expect(find.textContaining('On shift since'), findsWidgets);
    await tester.tap(find.text('Clock out'));
    await tester.pumpAndSettle();
    expect(api.sent.last.body['action'], 'out');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the shifts board groups the week by day in Arabic', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = OfficeApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'owner');
    await tester.pumpWidget(host(ShiftsBoard(live: live), locale: 'ar'));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل الحضور'), findsOneWidget);
    expect(find.textContaining('اليوم · 3'), findsOneWidget);
    final list = find.byType(ListView);
    await tester.dragUntilVisible(
      find.text('هذا الأسبوع'),
      list,
      const Offset(0, -300),
    );
    // Three days hold shifts: today and the two that follow.
    await tester.drag(list, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.byType(AppDisclosure), findsAtLeastNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('on a tablet the shifts board keeps the clock button wide', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = OfficeApi();
    final live = LiveContext(Runtime(api), restaurantId: 1, role: 'waiter');
    await tester.pumpWidget(host(ShiftsBoard(live: live), scale: 1));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text('Clock in')).height, greaterThan(0));
    expect(find.text('Shifts'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a tip chosen on the basket goes into the payment', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final opened = <Uri>[];
    final browser = launchProvider;
    addTearDown(() => launchProvider = browser);
    launchProvider = (uri) async {
      opened.add(uri);
      return true;
    };
    final api = OfficeApi()
      ..run = {
        'id': 41,
        'status': 'review',
        'answer': {'text': 'Here is lunch.'},
        'proposal': {
          'id': 5,
          'kind': 'basket',
          'status': 'review',
          'version': 1,
          'payload': {
            'quote': {
              'currency': 'USD',
              'totalMinor': 2150,
              'lines': [
                {'name': 'Risotto', 'quantity': 1},
              ],
            },
          },
        },
      };
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(AskRaystoPage(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A quick lunch for two'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('No tip'), findsOneWidget);
    final ten = find.text('10% · 2.15 USD');
    await tester.ensureVisible(ten);
    await tester.tap(ten);
    await tester.pumpAndSettle();
    expect(find.text('23.65 USD'), findsOneWidget);
    final pay = find.text('Order and approve in PayPal');
    await tester.ensureVisible(pay);
    await tester.tap(pay);
    await tester.pumpAndSettle();
    final allocate = api.sent.firstWhere((c) => c.operation == 'payment.allocate');
    expect(allocate.body, {
      'restaurantId': 1,
      'orderId': 7,
      'method': 'paypal',
      'tipMinor': 215,
    });
    expect(opened.single.host, 'www.sandbox.paypal.com');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('no tip sends no tip field', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final browser = launchProvider;
    addTearDown(() => launchProvider = browser);
    launchProvider = (uri) async => true;
    final api = OfficeApi()
      ..run = {
        'id': 41,
        'status': 'review',
        'answer': {'text': 'Here is lunch.'},
        'proposal': {
          'id': 5,
          'kind': 'basket',
          'status': 'review',
          'version': 1,
          'payload': {
            'quote': {
              'currency': 'USD',
              'totalMinor': 2150,
              'lines': [
                {'name': 'Risotto', 'quantity': 1},
              ],
            },
          },
        },
      };
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(AskRaystoPage(live: live), scale: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A quick lunch for two'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final pay = find.text('Order and approve in PayPal');
    await tester.ensureVisible(pay);
    await tester.tap(pay);
    await tester.pumpAndSettle();
    final allocate = api.sent.firstWhere((c) => c.operation == 'payment.allocate');
    expect(allocate.body.containsKey('tipMinor'), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a complaint is sent from a paid order and its draft is guarded', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = OfficeApi();
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(orderPage(live, 12), scale: 1));
    await tester.pumpAndSettle();
    final open = find.text('Something was wrong?');
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'The croissant was missing');
    await tester.pump();
    // Leaving with unsent text asks first; keeping it keeps the sheet.
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Discard your message?'), findsOneWidget);
    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();
    expect(find.text('Send to the café'), findsOneWidget);
    await tester.tap(find.text('Send to the café'));
    await tester.pumpAndSettle();
    final sent = api.sent.single;
    expect(sent.operation, 'complaint.open');
    expect(sent.body, {
      'restaurantId': 1,
      'orderId': 12,
      'text': 'The croissant was missing',
    });
    expect(find.text('Sent. The café will reply.'), findsOneWidget);
    expect(find.text('Something was wrong?'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a refunded complaint shows the amount', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = OfficeApi()
      ..complaint = {'status': 'refunded', 'refundedMinor': 220, 'currency': 'USD'};
    final live = LiveContext(Runtime(api), restaurantId: 1);
    await tester.pumpWidget(host(orderPage(live, 12), scale: 1));
    await tester.pumpAndSettle();
    expect(find.text('Refunded 2.20 USD'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
