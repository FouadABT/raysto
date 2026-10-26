import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/app/app.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/domain/domain.dart';
import 'package:raysto/features/customer/customer_screens.dart';
import 'package:raysto/features/operations/operations.dart';
import 'package:raysto/mobile/shared.dart' show openPage;

void main() {
  setUpAll(() async {
    await (FontLoader('PlusJakartaSans')
          ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'))
          ..addFont(
            rootBundle.load('assets/fonts/PlusJakartaSans-SemiBold.ttf'),
          ))
        .load();
    await (FontLoader(
      'NotoSansArabic',
    )..addFont(rootBundle.load('assets/fonts/NotoSansArabic.ttf'))).load();
  });

  Future<void> tapControl(WidgetTester tester, Type type, String label) async {
    final candidates = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (w) => type == FilledButton
            ? w is FilledButton
            : type == OutlinedButton
            ? w is OutlinedButton
            : type == TextButton
            ? w is TextButton
            : w.runtimeType == type,
      ),
    );
    var finder = candidates;
    if (finder.evaluate().isEmpty ||
        finder.first.hitTestable().evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        400,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 60,
      );
    }
    finder = candidates.first;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    expect(finder.hitTestable(), findsOneWidget, reason: '$label must be reachable');
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'After $label');
  }

  BuildContext shellContext(WidgetTester tester) =>
      tester.element(find.byType(MobileShell));
  Future<void> showPage(WidgetTester tester, Widget page) async {
    Navigator.of(shellContext(tester))
        .push(MaterialPageRoute<void>(builder: (_) => page));
    await tester.pumpAndSettle();
  }

  Future<void> operate(
    WidgetTester tester,
    DemoStore store,
    String account,
    String orderId,
    List<String> actions,
  ) async {
    store.switchAccount(account);
    await tester.pumpAndSettle();
    openOperation(shellContext(tester), store, 'order', id: orderId);
    await tester.pumpAndSettle();
    for (final action in actions) {
      await tapControl(tester, AppButton, action);
      final expected = {
        'Accept order': OrderStatus.accepted,
        'Start preparing': OrderStatus.preparing,
        'Mark ready': OrderStatus.ready,
        'Confirm served': OrderStatus.served,
        'Complete order': OrderStatus.completed,
      }[action];
      if (expected != null) {
        expect(store.orderById(orderId).status, expected);
      }
    }
  }

  testWidgets(
    'table deep links confirm both full URI and Android normalized path without joining',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final route in [
        'raysto://table/olive/olive-table-06',
        '/olive/olive-table-06',
      ]) {
        final store = DemoStore()
          ..loadScenario('B')
          ..switchAccount('customer');
        addTearDown(store.dispose);
        store.addToCart('olive-coffee');
        final cartBefore = jsonEncode(store.cart.toJson());
        final visitsBefore = jsonEncode(
          store.visits.map((visit) => visit.toJson()).toList(),
        );
        expect(
          store.visitById('visit-06').participantIds,
          isNot(contains('customer')),
        );

        await tester.pumpWidget(
          RaystoApp(demoStore: store, initialRoute: route),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TableConfirmationScreen), findsOneWidget);
        expect(find.text('Confirm your table'), findsOneWidget);
        expect(find.text('Table 06'), findsOneWidget);
        expect(find.byType(VisitScreen), findsNothing);
        expect(jsonEncode(store.cart.toJson()), cartBefore, reason: route);
        expect(
          jsonEncode(store.visits.map((visit) => visit.toJson()).toList()),
          visitsBefore,
          reason: 'Opening $route must not create or join a visit',
        );
        expect(tester.takeException(), isNull, reason: route);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'invitation requires confirmation and detail route guards recover after back and role changes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = DemoStore()
        ..loadScenario('B')
        ..switchAccount('customer');
      addTearDown(store.dispose);
      store.addToCart('olive-coffee');
      final cartBefore = store.cart.toJson();
      final visit = store.visitById('visit-06');
      final participantsBefore = List<String>.from(visit.participantIds);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      openPage(shellContext(tester), ScanScreen(store: store));
      await tester.pumpAndSettle();
      await tapControl(tester, TextButton, 'Use demo invitation');
      expect(find.byType(InvitationConfirmationScreen), findsOneWidget);
      expect(visit.participantIds, participantsBefore);
      expect(
        store.cart.toJson(),
        cartBefore,
        reason: 'Previewing an invitation must not change the private basket or visit',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ScanScreen), findsOneWidget);
      expect(visit.participantIds, participantsBefore);
      expect(store.cart.toJson(), cartBefore);
      await tapControl(tester, TextButton, 'Use demo invitation');
      await tapControl(tester, FilledButton, 'Confirm and join visit');
      expect(find.byType(VisitScreen), findsOneWidget);
      expect(visit.participantIds.where((id) => id == 'customer').length, 1);
      expect(store.cart.visitId, visit.id);
      expect(store.cart.mode, ServiceMode.dineIn);
      expect(store.cart.lines.single.itemId, 'olive-coffee');
      Navigator.of(tester.element(find.byType(VisitScreen)))
          .popUntil((route) => route.isFirst);
      await tester.pumpAndSettle();

      final originalContext = shellContext(tester);
      for (var tap = 0; tap < 3; tap++) {
        openPage(
          originalContext,
          ItemScreen(store: store, itemId: 'olive-bowl'),
        );
      }
      await tester.pumpAndSettle();
      expect(
        find.byType(ItemScreen, skipOffstage: false),
        findsOneWidget,
        reason: 'Rapid activations create one item route',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ItemScreen, skipOffstage: false), findsNothing);
      openPage(
        shellContext(tester),
        ItemScreen(store: store, itemId: 'olive-bowl'),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(ItemScreen),
        findsOneWidget,
        reason: 'Back releases the route guard',
      );

      store.switchAccount('manager');
      await tester.pumpAndSettle();
      expect(find.byType(ItemScreen, skipOffstage: false), findsNothing);
      openPage(
        shellContext(tester),
        ItemScreen(store: store, itemId: 'olive-bowl'),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(ItemScreen),
        findsOneWidget,
        reason: 'A replacement Navigator has an independent route guard',
      );
      store.switchAccount('customer');
      await tester.pumpAndSettle();
      openPage(
        shellContext(tester),
        ItemScreen(store: store, itemId: 'olive-bowl'),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(ItemScreen),
        findsOneWidget,
        reason: 'Returning to the original account can reopen the same detail',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'customer approval and checkout connect to manager kitchen waiter and table request',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = DemoStore()
        ..loadScenario('B')
        ..setDelayMode('instant');
      addTearDown(store.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('dock-2')));
      await tester.pumpAndSettle();
      await tapControl(tester, FilledButton, 'Suggest a basket');
      expect(
        store.cart.lines,
        isEmpty,
        reason: 'A proposal needs explicit approval',
      );
      await tapControl(tester, FilledButton, 'Review proposed basket');
      await tapControl(tester, FilledButton, 'Approve and add to cart');
      expect(store.cartTotals().totalMinor, 2200);
      await tapControl(tester, FilledButton, 'Review checkout');
      await tapControl(tester, FilledButton, 'Confirm demo payment');
      final attempt = store.visibleAttempts.last;
      expect(attempt.status, AttemptStatus.succeeded);
      final orderId = attempt.orderId!;
      expect(store.orders.where((o) => o.visitId == 'visit-06').length, 1);
      expect(store.orderPaid(orderId), 2200);
      await operate(tester, store, 'manager', orderId, ['Accept order']);
      await operate(tester, store, 'kitchen', orderId, [
        'Start preparing',
        'Mark ready',
      ]);
      await operate(tester, store, 'waiter', orderId, ['Confirm served']);
      expect(store.orderById(orderId).status, OrderStatus.served);
      await operate(tester, store, 'manager', orderId, ['Complete order']);
      store.switchAccount('diner');
      await tester.pumpAndSettle();
      await showPage(tester, VisitScreen(store: store, visitId: 'visit-06'));
      await tapControl(tester, ActionChip, 'Water');
      final request = store.requests.last;
      expect(request.visitId, 'visit-06');
      store.switchAccount('waiter');
      await tester.pumpAndSettle();
      openOperation(shellContext(tester), store, 'requests');
      await tester.pumpAndSettle();
      await tapControl(tester, AppButton, 'Acknowledge');
      await tapControl(tester, AppButton, 'Mark completed');
      expect(request.status, RequestStatus.completed);
      expect(store.canCloseVisit('visit-06'), true);
      expect(store.visitBalance('visit-06'), 0);
    },
  );

  testWidgets(
    'pending payment exits resumes after persistence and retry creates one order',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final memory = MemoryDemoPersistence();
      final store = DemoStore(persistence: memory)
        ..loadScenario('F')
        ..setDelayMode('instant');
      addTearDown(store.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      await showPage(tester, CheckoutScreen(store: store));
      await tapControl(tester, FilledButton, 'Confirm demo payment');
      final first = store.visibleAttempts.last;
      expect(first.status, AttemptStatus.pending);
      expect(first.orderId, isNull);
      await tapControl(tester, TextButton, 'Back to the app');
      await tester.tap(find.byKey(const ValueKey('dock-1')));
      await tester.pumpAndSettle();
      await tapControl(tester, FilledButton, 'Resume checkout');
      expect(find.textContaining(first.id), findsOneWidget);
      await tester.runAsync(store.flush);
      await tester.pumpWidget(const SizedBox());
      late DemoStore restored;
      await tester.runAsync(() async {
        restored = await DemoStore.open(persistence: memory);
      });
      addTearDown(restored.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: restored));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('dock-1')));
      await tester.pumpAndSettle();
      await tapControl(tester, FilledButton, 'Resume checkout');
      await tapControl(tester, OutlinedButton, 'failed');
      expect(restored.cart.lines.length, 3);
      restored.setPaymentOutcome(PaymentOutcome.success);
      await tapControl(tester, FilledButton, 'Review and retry');
      await tapControl(tester, FilledButton, 'Confirm demo payment');
      final retry = restored.visibleAttempts.last;
      expect(retry.id, isNot(first.id));
      expect(retry.status, AttemptStatus.succeeded);
      restored.resolvePayment(retry.id, PaymentOutcome.success);
      expect(restored.payments.where((p) => p.attemptId == retry.id).length, 1);
      expect(restored.orders.where((o) => o.visitId == 'visit-06').length, 1);
      expect(restored.attemptById(first.id).status, AttemptStatus.failed);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Arabic dark reduced-motion cart and keyboard remain usable at 320 and 2x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.view.resetViewInsets);
      final store = DemoStore()
        ..loadScenario('B')
        ..referenceBasket();
      store.updateSettings(
        locale: 'ar',
        appearance: 'dark',
        reducedMotion: true,
        textScale: 2,
      );
      addTearDown(store.dispose);
      await tester.pumpWidget(RaystoApp(demoStore: store));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final shell = shellContext(tester);
      expect(Directionality.of(shell), TextDirection.rtl);
      expect(Theme.of(shell).brightness, Brightness.dark);
      expect(AppMotion.reduced(shell), true);
      expect(MediaQuery.textScalerOf(shell).scale(16), 32);
      await showPage(tester, CartScreen(store: store));
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 6; i++) {
        await tester.drag(find.byType(ListView).last, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final field = find.byType(TextField).last;
      await tester.ensureVisible(field);
      await tester.tap(field);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.enterText(field, 'FRESH10');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        store.cartTotals().totalMinor,
        2200,
        reason: 'Typing a code must not apply it before the action',
      );
      tester.view.resetViewInsets();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  );
}
