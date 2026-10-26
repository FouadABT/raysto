import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/app.dart';
import 'package:raysto/domain/domain.dart';
import 'package:raysto/features/customer/customer_screens.dart';
import 'package:raysto/l10n/app_localizations.dart';
import 'package:raysto/mobile/shared.dart' show openPage;

void main() {
  setUpAll(() async {
    await (FontLoader('PlusJakartaSans')
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
          ..addFont(
            rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'),
          )
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf')))
        .load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });

  BuildContext shellContext(WidgetTester tester) =>
      tester.element(find.byType(MobileShell));

  Future<Finder> reveal(WidgetTester tester, Finder candidates) async {
    // A lazy list may not have mounted the target yet. Select a particular
    // match only after scrolling has produced an element.
    for (var step = 0; step < 50; step++) {
      if (candidates.evaluate().isNotEmpty) {
        final target = candidates.first;
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (target.hitTestable().evaluate().isNotEmpty) {
          expect(target.hitTestable(), findsOneWidget);
          return target;
        }
      }
      final scrollables = find.byType(Scrollable);
      expect(
        scrollables.evaluate(),
        isNotEmpty,
        reason: 'A scrollable must expose the requested control',
      );
      await tester.drag(scrollables.last, const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    fail(
      'The requested control did not become visible after scrolling: $candidates',
    );
  }

  testWidgets(
    'customer viewport matrix preserves search and primary actions with real fonts',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.view.resetViewInsets);
      for (final example
          in <({Size size, String locale, double scale, String page})>[
            (
              size: const Size(360, 800),
              locale: 'en',
              scale: 1,
              page: 'discovery',
            ),
            (
              size: const Size(390, 844),
              locale: 'fr',
              scale: 2,
              page: 'restaurant',
            ),
            (
              size: const Size(430, 900),
              locale: 'ar',
              scale: 2,
              page: 'checkout',
            ),
            (
              size: const Size(640, 360),
              locale: 'en',
              scale: 2,
              page: 'checkout',
            ),
          ]) {
        final store = DemoStore()
          ..loadScenario('B')
          ..referenceBasket();
        store.updateSettings(
          locale: example.locale,
          appearance: example.locale == 'ar' ? 'dark' : 'light',
          textScale: example.scale,
          reducedMotion: true,
        );
        await tester.binding.setSurfaceSize(example.size);
        await tester.pumpWidget(RaystoApp(demoStore: store));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${example.page} shell at ${example.size} ${example.locale}',
        );
        if (example.page == 'discovery') {
          final search = await reveal(
            tester,
            find.descendant(
              of: find.byType(DiscoveryScreen),
              matching: find.byType(TextField),
            ),
          );
          await tester.tap(search);
          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await tester.enterText(search, 'Olive');
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '360px discovery search with keyboard',
          );
          tester.view.resetViewInsets();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await reveal(tester, find.text('Olive Kitchen'));
        } else if (example.page == 'restaurant') {
          openPage(shellContext(tester), RestaurantScreen(store: store));
          await tester.pumpAndSettle();
          final pageContext = tester.element(find.byType(RestaurantScreen));
          final cartAction = find.ancestor(
            of: find.textContaining(pageContext.tr('View cart')),
            matching: find.byWidgetPredicate((w) => w is FilledButton),
          );
          await reveal(tester, cartAction);
          final search = await reveal(
            tester,
            find.descendant(
              of: find.byType(RestaurantScreen),
              matching: find.byType(TextField),
            ),
          );
          await tester.tap(search);
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.enterText(search, 'Garden');
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '390px French 2x restaurant with keyboard',
          );
          tester.view.resetViewInsets();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          await reveal(tester, cartAction);
        } else {
          openPage(shellContext(tester), CheckoutScreen(store: store));
          await tester.pumpAndSettle();
          final pageContext = tester.element(find.byType(CheckoutScreen));
          final confirm = find.ancestor(
            of: find.text(pageContext.tr('Confirm demo payment')),
            matching: find.byWidgetPredicate((w) => w is FilledButton),
          );
          await reveal(tester, confirm);
          expect(tester.getSize(confirm).height, greaterThanOrEqualTo(48));
          expect(store.cartTotals().totalMinor, 2200);
          expect(
            store.attempts.where((a) => a.accountId == 'diner'),
            isEmpty,
            reason: 'Layout review does not submit payment',
          );
        }
        expect(
          tester.takeException(),
          isNull,
          reason:
              '${example.page} at ${example.size} ${example.locale} ${example.scale}x',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        store.dispose();
      }
    },
  );

  testWidgets(
    'full owner shell keeps French and Arabic 2x header and navigation readable',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final example in <({double width, String locale})>[
        (width: 360, locale: 'fr'),
        (width: 430, locale: 'ar'),
      ]) {
        final store = DemoStore()..switchAccount('owner');
        store.updateSettings(
          locale: example.locale,
          textScale: 2,
          reducedMotion: true,
          appearance: example.locale == 'ar' ? 'dark' : 'light',
        );
        await tester.binding.setSurfaceSize(Size(example.width, 844));
        await tester.pumpWidget(RaystoApp(demoStore: store));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Owner app bar ${example.width}px ${example.locale} at 2x',
        );
        final context = shellContext(tester);
        expect(MediaQuery.textScalerOf(context).scale(16), 32);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Olive Kitchen'),
          ),
          findsOneWidget,
        );
        final navigation = find.ancestor(
          of: find.textContaining(context.tr('Navigate')),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        );
        expect(navigation.hitTestable(), findsOneWidget);
        await tester.tap(navigation);
        await tester.pumpAndSettle();
        final menu = find.widgetWithText(ListTile, context.tr('Menu'));
        await reveal(tester, menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Translated destination header after navigation',
        );
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(context.tr('Menu')),
          ),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        store.dispose();
      }
    },
  );
}
