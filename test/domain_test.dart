import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/domain/domain.dart';

class _FalliblePersistence extends MemoryDemoPersistence {
  bool fail = true;
  int writes = 0;
  @override
  Future<void> write(String value) async {
    writes++;
    if (fail) {
      throw StateError('Fixture storage failure');
    }
    await super.write(value);
  }
}

void main() {
  test(
    'daily opening intervals, time advancement and configured slots govern new orders',
    () {
      final s = DemoStore()..switchAccount('owner');
      s.saveRestaurant(
        s.currentRestaurant.copyWith(hours: '11:00–14:00, 18:00–22:00'),
      );
      expect(s.isRestaurantOpen(s.currentRestaurant), true);
      s.advanceTime(const Duration(hours: 3));
      expect(s.isRestaurantOpen(s.currentRestaurant), false);
      s.switchAccount('diner');
      s.referenceBasket();
      expect(() => s.beginCheckout(), throwsA(isA<DomainException>()));
      expect(
        () => s.bookReservation(
          restaurantId: 'olive',
          at: s.now.add(const Duration(hours: 1)),
          guests: 2,
        ),
        throwsA(isA<DomainException>()),
      );
      s.bookReservation(
        restaurantId: 'olive',
        at: s.now.add(const Duration(hours: 4)),
        guests: 2,
      );
      s.switchAccount('owner');
      expect(
        () => s.saveRestaurant(
          s.currentRestaurant.copyWith(hours: '25:00–26:00'),
        ),
        throwsA(isA<DomainException>()),
      );
      s.saveRestaurant(
        s.currentRestaurant.copyWith(
          hours: '18:00–02:00',
          pickupSlots: ['In 60 minutes'],
        ),
      );
      s.advanceTime(const Duration(hours: 10));
      expect(s.isRestaurantOpen(s.currentRestaurant), true);
      s.switchAccount('customer');
      expect(
        () => s.configureCart(pickupSlot: 'ASAP'),
        throwsA(isA<DomainException>()),
      );
      s.configureCart(pickupSlot: 'In 60 minutes');
    },
  );
  test(
    'storage failure and recovery notify listeners without recursive saves',
    () async {
      final persistence = _FalliblePersistence();
      final store = DemoStore(persistence: persistence);
      var events = 0;
      store.addListener(() => events++);
      store.updateSettings(locale: 'fr');
      await store.flush();
      expect(store.persistenceError, isNotNull);
      expect(events, 2);
      expect(persistence.writes, 1);
      persistence.fail = false;
      await store.retryPersistence();
      expect(store.persistenceError, isNull);
      expect(events, 4);
      expect(persistence.writes, 2);
    },
  );
  DemoStore fresh([String scenario = 'B']) {
    final s = DemoStore();
    s.loadScenario(scenario);
    s.setDelayMode('instant');
    return s;
  }

  void serve(DemoStore s, String id) {
    s.switchAccount('manager');
    s.transitionOrder(id, OrderStatus.accepted);
    s.switchAccount('kitchen');
    s.transitionOrder(id, OrderStatus.preparing);
    s.transitionOrder(id, OrderStatus.ready);
    s.switchAccount('waiter');
    s.transitionOrder(id, OrderStatus.served);
  }

  test(
    'reference money, required modifiers, fees, coupon and tips use minor units',
    () {
      final s = fresh();
      expect(() => s.addToCart('olive-bowl'), throwsA(isA<DomainException>()));
      s.referenceBasket();
      expect(s.cartTotals().totalMinor, 2200);
      final bowl = s.cart.lines.first;
      s.updateCartLine(
        bowl.id,
        selections: {
          'dressing': ['lemon'],
          'extras': ['avocado'],
        },
      );
      expect(s.cartTotals().totalMinor, 2350);
      s.applyCoupon('FRESH10');
      expect(s.cartTotals().discountMinor, 235);
      s.configureCart(tipMinor: 100);
      expect(s.cartTotals().totalMinor, 2215);
      expect(() => s.applyCoupon('EXPIRED'), throwsA(isA<DomainException>()));
      s.loadScenario('D');
      expect(s.cartTotals().totalMinor, 2400);
      s.updateSettings(locale: 'ar');
      expect(s.cartTotals().totalMinor, 2400);
    },
  );
  test(
    'pay before cross-role order, request, bill and reset keep independent states',
    () {
      final s = fresh();
      s.referenceBasket();
      final a = s.beginCheckout();
      expect(s.orders.where((o) => o.visitId == 'visit-06'), isEmpty);
      s.resolvePayment(a.id, PaymentOutcome.success);
      final order = s.orderById(a.orderId!);
      expect(order.status, OrderStatus.submitted);
      expect(s.orderPaid(order.id), 2200);
      s.switchAccount('kitchen');
      expect(
        () => s.transitionOrder(order.id, OrderStatus.ready),
        throwsA(isA<DomainException>()),
      );
      serve(s, order.id);
      expect(order.status, OrderStatus.served);
      expect(s.visitBalance('visit-06'), 0);
      s.switchAccount('diner');
      final r = s.requestService('Water');
      expect(s.requestService('Water').id, r.id);
      s.switchAccount('waiter');
      expect(s.canCloseVisit('visit-06'), false);
      s.transitionRequest(r.id, RequestStatus.acknowledged);
      s.transitionRequest(r.id, RequestStatus.completed);
      s.closeVisit('visit-06');
      expect(s.tableById('olive-table-06').status, TableStatus.needsReset);
      s.resetTable('olive-table-06');
      expect(s.tableById('olive-table-06').status, TableStatus.available);
    },
  );
  test(
    'pending allocation freezes old round and exactly one checkout per visit',
    () {
      final s = fresh('C');
      s.referenceBasket();
      final first = s.beginCheckout(payAtEnd: true);
      serve(s, first.orderId!);
      s.switchAccount('diner');
      final bill = s.beginVisitPayment('visit-06');
      expect(bill.totalMinor, 2200);
      expect(s.beginVisitPayment('visit-06').id, bill.id);
      s.addToCart('olive-lemonade');
      final second = s.beginCheckout(payAtEnd: true);
      expect(s.visitBalance('visit-06'), 2500);
      s.resolvePayment(bill.id, PaymentOutcome.success);
      s.resolvePayment(bill.id, PaymentOutcome.success);
      expect(s.orderPaid(first.orderId!), 2200);
      expect(s.orderPaid(second.orderId!), 0);
      expect(s.visitBalance('visit-06'), 300);
      serve(s, second.orderId!);
      s.collectCash('visit-06');
      expect(s.visitBalance('visit-06'), 0);
      s.closeVisit('visit-06');
    },
  );
  test(
    'payment failure cancellation retry and restored pending remain idempotent',
    () async {
      final storage = MemoryDemoPersistence();
      final s = DemoStore(persistence: storage);
      s.loadScenario('F');
      s.referenceBasket();
      final failed = s.beginCheckout();
      s.resolvePayment(failed.id, PaymentOutcome.failed);
      expect(s.cart.lines.length, 3);
      final cancelled = s.beginCheckout();
      expect(cancelled.id, isNot(failed.id));
      s.resolvePayment(cancelled.id, PaymentOutcome.cancelled);
      final pending = s.beginCheckout();
      expect(s.beginCheckout().id, pending.id);
      await s.flush();
      final restored = await DemoStore.open(persistence: storage);
      expect(restored.attemptById(pending.id).status, AttemptStatus.pending);
      restored.resolvePayment(pending.id, PaymentOutcome.success);
      restored.resolvePayment(pending.id, PaymentOutcome.success);
      expect(
        restored.payments.where((p) => p.attemptId == pending.id).length,
        1,
      );
      expect(
        restored.orders
            .where((o) => o.id == restored.attemptById(pending.id).orderId)
            .length,
        1,
      );
      expect(restored.cart.lines, isEmpty);
      expect(restored.beginCheckout().id, pending.id);
    },
  );
  test(
    'payment capture survives role switching while reset invalidates old callbacks',
    () async {
      final s = fresh();
      s.setDelayMode('normal');
      s.referenceBasket();
      final attempt = s.beginCheckout();
      final pending = s.simulatePayment(attempt.id);
      s.switchAccount('manager');
      await pending;
      expect(s.attemptById(attempt.id).status, AttemptStatus.succeeded);
      expect(s.orderById(attempt.orderId!).accountId, 'diner');
      s.loadScenario('B');
      s.setDelayMode('normal');
      s.referenceBasket();
      final stale = s.beginCheckout();
      final future = s.simulatePayment(stale.id);
      s.resetWorld();
      final before = s.toJson();
      await future;
      expect(s.toJson(), before);
    },
  );
  test('paid cancellation and refund never reopen cancelled obligation', () {
    final s = fresh();
    s.referenceBasket();
    final a = s.beginCheckout();
    s.resolvePayment(a.id, PaymentOutcome.success);
    s.switchAccount('manager');
    s.transitionOrder(
      a.orderId!,
      OrderStatus.cancelled,
      reason: 'Requested locally',
    );
    expect(s.visitBalance('visit-06'), 0);
    final refund = s.refundOrder(a.orderId!);
    expect(refund.amountMinor, 2200);
    expect(s.refundOrder(a.orderId!).id, refund.id);
    expect(s.visitBalance('visit-06'), 0);
    expect(s.orderById(a.orderId!).status, OrderStatus.cancelled);
    final report = s.report();
    expect(report.refundedMinor, 3500);
    expect(report.capturedMinor, greaterThan(report.salesMinor));
  });
  test(
    'private carts, visits, restaurant scope and role permissions are enforced',
    () {
      final s = fresh();
      s.referenceBasket();
      expect(() => s.visitOrders('visit-02'), throwsA(isA<DomainException>()));
      expect(
        () => s.startVisit('olive-table-06'),
        throwsA(isA<DomainException>()),
      );
      s.switchAccount('new-customer');
      expect(s.cart.lines, isEmpty);
      expect(s.activeVisit, isNull);
      expect(
        () => s.joinVisit('RAYSTO-JOIN-INVALID'),
        throwsA(isA<DomainException>()),
      );
      s.joinVisit('RAYSTO-JOIN-06');
      expect(s.activeVisit!.id, 'visit-06');
      s.selectRestaurant('harbor');
      expect(s.cart.lines, isEmpty);
      s.switchAccount('harbor-owner');
      expect(s.visibleOrders.every((o) => o.restaurantId == 'harbor'), true);
      expect(
        () => s.setAvailability('olive-bowl', false),
        throwsA(isA<DomainException>()),
      );
      expect(
        () => s.selectRestaurant('olive'),
        throwsA(isA<DomainException>()),
      );
      s.switchAccount('manager');
      expect(
        () => s.saveRestaurant(s.currentRestaurant.copyWith(plan: 'Pro')),
        throwsA(isA<DomainException>()),
      );
    },
  );
  test(
    'foreign IDs cannot overwrite restaurant records or trigger another account payment',
    () {
      final s = fresh();
      s.switchAccount('owner');
      expect(
        () => s.saveTable(
          const DemoTable(
            id: 'harbor-table-1',
            restaurantId: 'olive',
            label: 'Hijacked',
          ),
        ),
        throwsA(isA<DomainException>()),
      );
      expect(
        () => s.saveMenuItem(
          const MenuItem(
            id: 'harbor-bowl',
            restaurantId: 'olive',
            name: 'Wrong scope',
            category: 'Bowls',
            priceMinor: 900,
          ),
        ),
        throwsA(isA<DomainException>()),
      );
      s.switchAccount('diner');
      expect(
        () => s.simulatePayment('attempt-pending'),
        throwsA(isA<DomainException>()),
      );
      s.referenceBasket();
      expect(
        () => s.beginCheckout(method: 'Demo cash'),
        throwsA(isA<DomainException>()),
      );
    },
  );
  test(
    'availability blocks new purchases while frozen history remains unchanged',
    () {
      final s = fresh();
      s.referenceBasket();
      final a = s.beginCheckout();
      s.resolvePayment(a.id, PaymentOutcome.success);
      final price = s.orderById(a.orderId!).lines.first.unitPriceMinor;
      s.switchAccount('owner');
      s.saveMenuItem(s.itemById('olive-bowl').copyWith(priceMinor: 1900));
      s.setAvailability('olive-bowl', false);
      s.switchAccount('diner');
      expect(s.orderById(a.orderId!).lines.first.unitPriceMinor, price);
      expect(() => s.reorder(a.orderId!), throwsA(isA<DomainException>()));
      expect(s.proposeBasket().every((l) => l.itemId != 'olive-bowl'), true);
    },
  );
  test(
    'checkout freezes delivery fee and address while later settings and drafts change',
    () {
      final s = fresh('D');
      final a = s.beginCheckout();
      s.updateCartLine(s.cart.lines.first.id, quantity: 2);
      s.saveAddress(
        s.currentAccount.addresses.first.copyWith(street: '99 Changed Avenue'),
      );
      s.switchAccount('owner');
      s.saveRestaurant(s.currentRestaurant.copyWith(deliveryFeeMinor: 900));
      s.resolvePayment(a.id, PaymentOutcome.success);
      final order = s.orderById(a.orderId!);
      expect(order.totalMinor, 2400);
      expect(order.deliveryFeeMinor, 200);
      expect(order.address, contains('18 Olive Lane'));
      expect(order.lines.first.quantity, 1);
      s.switchAccount('customer');
      expect(s.cart.lines.first.quantity, 2);
    },
  );
  test(
    'owner draft workspace preserves prior workspace authorization and import drafts',
    () async {
      final storage = MemoryDemoPersistence();
      final s = DemoStore(persistence: storage);
      s.switchAccount('owner');
      final draft = s.createRestaurantDraft('Second local kitchen');
      expect(s.currentAccount.workspaceIds, containsAll(['olive', draft.id]));
      final imported = s.importSampleMenu();
      s.saveImportDraft(imported);
      await s.flush();
      final restored = await DemoStore.open(persistence: storage);
      expect(restored.importDraft.length, 4);
      restored.selectRestaurant('olive');
      expect(restored.currentRestaurant.id, 'olive');
      restored.switchAccount('harbor-owner');
      expect(
        () => restored.selectRestaurant(draft.id),
        throwsA(isA<DomainException>()),
      );
    },
  );
  test(
    'occupied floor deletion blocked; explicit move retains bill and closes independently',
    () {
      final s = fresh('I');
      s.switchAccount('owner');
      expect(
        () => s.deleteTable('olive-table-06'),
        throwsA(isA<DomainException>()),
      );
      final original = s.visitById('visit-06');
      s.moveVisit(original.id, 'olive-table-01');
      expect(original.tableId, 'olive-table-01');
      expect(s.tableById('olive-table-06').status, TableStatus.needsReset);
      s.closeVisit(original.id);
      s.resetTable('olive-table-01');
      final next = s.startVisit('olive-table-01');
      expect(next.id, isNot(original.id));
      expect(s.visitOrders(next.id), isEmpty);
    },
  );
  test(
    'reservation arrival and waitlist seating create new isolated visits',
    () {
      final s = fresh('K');
      final r = s.bookReservation(
        restaurantId: 'olive',
        at: s.now.add(const Duration(hours: 2)),
        guests: 2,
      );
      s.modifyReservation(r.id, guests: 3);
      s.arriveReservation(r.id);
      s.switchAccount('manager');
      final v = s.seatReservation(r.id, 'olive-table-01');
      expect(v.participantIds, ['customer']);
      expect(s.visitOrders(v.id), isEmpty);
      s.switchAccount('customer');
      final w = s.joinWaitlist();
      expect(s.joinWaitlist().id, w.id);
      s.leaveWaitlist(w.id);
      expect(w.active, false);
    },
  );
  test(
    'delivery goes from paid ready order through assigned courier to delivery',
    () {
      final s = fresh('D');
      final a = s.beginCheckout();
      s.resolvePayment(a.id, PaymentOutcome.success);
      s.switchAccount('manager');
      s.transitionOrder(a.orderId!, OrderStatus.accepted);
      s.switchAccount('kitchen');
      s.transitionOrder(a.orderId!, OrderStatus.preparing);
      s.transitionOrder(a.orderId!, OrderStatus.ready);
      s.switchAccount('manager');
      final task = s.deliveries.firstWhere((d) => d.orderId == a.orderId);
      s.assignDelivery(task.id, 'courier');
      s.switchAccount('courier');
      s.progressDelivery(task.id, DeliveryStatus.collected);
      s.progressDelivery(task.id, DeliveryStatus.outForDelivery);
      s.progressDelivery(
        task.id,
        DeliveryStatus.issue,
        note: 'Address needs confirmation',
      );
      s.switchAccount('manager');
      s.resolveDeliveryIssue(task.id);
      s.switchAccount('courier');
      s.progressDelivery(task.id, DeliveryStatus.delivered);
      expect(s.orderById(a.orderId!).status, OrderStatus.delivered);
      expect(s.orderPaid(a.orderId!), 2400);
    },
  );
}
