import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/domain/domain.dart';
import 'package:raysto/features/operations/operations.dart';
import 'package:raysto/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('PlusJakartaSans')
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'));
    await font.load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });

  Widget host(
    DemoStore store,
    String section, {
    String locale = 'en',
    double scale = 1,
    bool dark = false,
    GlobalKey<NavigatorState>? navigatorKey,
  }) => MaterialApp(
    navigatorKey: navigatorKey,
    theme: dark ? AppTheme.dark : AppTheme.light,
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
    home: Scaffold(
      body: OperationsPage(store: store, section: section),
    ),
  );

  testWidgets(
    'operational destinations fit narrow Arabic dark mode at 2x text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.view.resetViewInsets);
      final store = DemoStore();
      addTearDown(store.dispose);
      for (final entry in <String, List<String>>{
        'owner': ['overview', 'orders', 'tables', 'menu', 'more'],
        'waiter': ['shift', 'tables', 'orders', 'requests'],
        'kitchen': ['queue', 'availability', 'more'],
        'courier': ['tasks', 'activity', 'profile'],
      }.entries) {
        store.switchAccount(entry.key);
        for (final section in entry.value) {
          await tester.pumpWidget(
            host(store, section, locale: 'ar', scale: 2, dark: true),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${entry.key}/$section initial',
          );
          for (var n = 0; n < 4; n++) {
            if (find.byType(ListView).evaluate().isEmpty) break;
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -600),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key}/$section scroll $n',
            );
          }
          await tester.pumpWidget(const SizedBox());
        }
      }
    },
  );

  testWidgets(
    'focused owner forms and records remain readable with a keyboard',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = DemoStore()..switchAccount('owner');
      addTearDown(store.dispose);
      for (final section in [
        'setup',
        'restaurant',
        'services',
        'delivery-settings',
        'payment-policy',
        'item',
        'import',
        'storefront',
        'payments',
        'team',
        'reports',
        'reservations',
        'notifications',
        'billing',
      ]) {
        final key = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          host(store, 'overview', scale: 2, navigatorKey: key),
        );
        await tester.pumpAndSettle();
        openOperation(key.currentContext!, store, section);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$section initial');
        if (find.byType(TextFormField).evaluate().isNotEmpty) {
          await tester.tap(find.byType(TextFormField).first);
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$section keyboard');
        }
        for (var n = 0; n < 5; n++) {
          if (find.byType(ListView).evaluate().isEmpty) break;
          await tester.drag(find.byType(ListView).last, const Offset(0, -600));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$section scroll $n');
        }
        await tester.pumpWidget(const SizedBox());
        tester.view.resetViewInsets();
      }
    },
  );

  testWidgets(
    'floor draft has undo, stable IDs, save and waiter view continuity',
    (tester) async {
      final store = DemoStore()..switchAccount('owner');
      addTearDown(store.dispose);
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(host(store, 'tables', navigatorKey: key));
      await tester.pumpAndSettle();
      final count = store.restaurantTables.length;
      openOperation(key.currentContext!, store, 'floor');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Add table'),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add table'));
      await tester.pumpAndSettle();
      expect(
        store.restaurantTables.length,
        count,
        reason: 'Draft does not mutate committed tables',
      );
      key.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, 'Undo'),
        -400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, 'Undo'));
      await tester.pumpAndSettle();
      expect(find.text('${count + 1}'), findsNothing);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Redo'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(AppButton, 'Save floor plan'),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.widgetWithText(AppButton, 'Save floor plan'));
      await tester.pumpAndSettle();
      expect(store.restaurantTables.length, count + 1);
      expect(store.restaurantTables.map((t) => t.id).toSet().length, count + 1);
      expect(tester.takeException(), isNull);
      store.switchAccount('waiter');
      await tester.pumpWidget(host(store, 'tables'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('direct privileged route denies kitchen access', (tester) async {
    final store = DemoStore()..switchAccount('kitchen');
    addTearDown(store.dispose);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(host(store, 'queue', navigatorKey: key));
    await tester.pumpAndSettle();
    openOperation(key.currentContext!, store, 'payments');
    await tester.pumpAndSettle();
    expect(find.text('Access denied'), findsOneWidget);
    expect(find.text('Payment records'), findsNothing);
  });
}
