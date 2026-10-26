import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/payments/payment_controller.dart';
import 'package:raysto/payments/payment_models.dart';
import 'package:raysto/payments/testing/payment_lab.dart';

class ControlledBackend extends LabPaymentBackend {
  Completer<PaymentApproval>? prepareGate;
  Completer<PaymentOrder>? captureGate;
  bool changeAmount = false;
  @override
  Future<PaymentApproval> prepare(String reference) {
    if (prepareGate != null) {
      prepareCalls++;
      return prepareGate!.future;
    }
    return super.prepare(reference);
  }

  @override
  Future<PaymentOrder> complete(String reference) {
    if (captureGate != null) {
      captureCalls++;
      return captureGate!.future;
    }
    return super.complete(reference);
  }

  @override
  Future<PaymentOrder> read(String reference) async {
    final order = await super.read(reference);
    return changeAmount
        ? PaymentOrder(
            reference: reference,
            amount: PaymentAmount(200, 'USD'),
            paid: order.paid,
          )
        : order;
  }
}

class UnavailableStore extends MemoryPaymentStore {
  @override
  Future<void> write(String owner, PendingPayment payment) async =>
      throw StateError('device storage unavailable');
}

class FailingBrowser implements PaymentBrowser {
  @override
  Future<bool> open(Uri url) async => false;
}

class UnreadableStore extends MemoryPaymentStore {
  @override
  Future<PendingPayment?> read(String owner) async =>
      throw StateError('unreadable encrypted record');
}

void main() {
  late ControlledBackend backend;
  late MemoryPaymentStore store;
  late LabPaymentBrowser browser;
  late PaymentController controller;
  PaymentController make({
    PaymentStore? storage,
    PaymentBrowser? opener,
    Duration? timeout,
  }) => PaymentController(
    backend: backend,
    store: storage ?? store,
    browser: opener ?? browser,
    links: PayPalLinkPolicy(callbackOrigin: Uri.parse('https://api.rays.to')),
    timeout: timeout ?? const Duration(seconds: 35),
  );
  setUp(() async {
    backend = ControlledBackend();
    store = MemoryPaymentStore();
    browser = LabPaymentBrowser();
    controller = make();
    await controller.connect('alice');
  });
  tearDown(() => controller.dispose());

  test(
    'only authenticated backend settlement produces paid and clears recovery',
    () async {
      await controller.prepare('order-1');
      await controller.openApproval();
      backend.approved = true;
      expect(
        await controller.handleReturn(
          Uri.parse('https://api.rays.to/payments/return?token=LABORDER123456'),
        ),
        isTrue,
      );
      expect(controller.snapshot.paid, isFalse);
      expect(backend.captureCalls, 0);
      await controller.complete();
      expect(controller.snapshot.paid, isTrue);
      expect(store.values['alice'], isNull);
      await controller.complete();
      expect(backend.captureCalls, 1);
    },
  );
  test(
    'cancellation keeps recoverable checkout and does not capture',
    () async {
      await controller.prepare('order-1');
      await controller.openApproval();
      await controller.handleReturn(
        Uri.parse('/payments/cancel?token=LABORDER123456'),
      );
      expect(controller.snapshot.phase, PaymentPhase.paused);
      expect(store.values['alice']?.approval, isNotNull);
      expect(backend.captureCalls, 0);
    },
  );
  test(
    'wrong token, duplicate token and foreign origin callbacks do nothing',
    () async {
      await controller.prepare('order-1');
      for (final uri in [
        'https://evil.test/payments/return?token=LABORDER123456',
        '/payments/return?token=OTHERORDER',
        '/payments/return?token=LABORDER123456&token=LABORDER123456',
        'https://api.rays.to:444/payments/return?token=LABORDER123456',
        'https://api.rays.to/payments/return?token=LABORDER123456#paid',
      ]) {
        expect(await controller.handleReturn(Uri.parse(uri)), isFalse);
      }
      expect(backend.captureCalls, 0);
      expect(controller.snapshot.paid, isFalse);
    },
  );
  test(
    'second controller recovers opened checkout without creating or capturing',
    () async {
      await controller.prepare('order-1');
      await controller.openApproval();
      final restored = make();
      addTearDown(restored.dispose);
      await restored.connect('alice');
      expect(restored.snapshot.payment!.opened, isTrue);
      expect(restored.snapshot.payment!.reference, 'order-1');
      expect(backend.prepareCalls, 1);
      expect(backend.captureCalls, 0);
    },
  );
  test(
    'lost capture response is recovered by read without another capture',
    () async {
      await controller.prepare('order-1');
      backend.approved = true;
      backend.loseNextCaptureResponse = true;
      await controller.complete();
      expect(controller.snapshot.paid, isFalse);
      expect(store.values['alice'], isNotNull);
      await controller.refresh();
      expect(controller.snapshot.paid, isTrue);
      expect(backend.captureCalls, 1);
    },
  );
  test(
    'webhook-won settlement prevents extra browser launch and capture',
    () async {
      await controller.prepare('order-1');
      backend.paid = true;
      await controller.openApproval();
      expect(browser.opens, 0);
      expect(controller.snapshot.paid, isTrue);
      await controller.complete();
      expect(backend.captureCalls, 0);
    },
  );
  test(
    'double prepare taps share one operation; reference persisted before API',
    () async {
      backend.prepareGate = Completer();
      final operation = controller.prepare('order-1');
      await Future<void>.delayed(Duration.zero);
      expect(store.values['alice']?.reference, 'order-1');
      expect(store.values['alice']?.approval, isNull);
      await controller.prepare('order-1');
      backend.prepareGate!.complete(
        await LabPaymentBackend().prepare('order-1'),
      );
      await operation;
      expect(controller.snapshot.phase, PaymentPhase.ready);
    },
  );
  test(
    'logout during provider preparation cannot restore old account data',
    () async {
      backend.prepareGate = Completer();
      final operation = controller.prepare('order-1');
      await Future<void>.delayed(Duration.zero);
      controller.disconnect();
      await controller.connect('bob');
      backend.prepareGate!.complete(
        await LabPaymentBackend().prepare('order-1'),
      );
      await operation;
      expect(controller.owner, 'bob');
      expect(controller.snapshot.payment, isNull);
      expect(store.values['bob'], isNull);
      expect(store.values['alice']?.approval, isNull);
    },
  );
  test('logout during capture hides late result while original owner can reconcile', () async {
    await controller.prepare('order-1');
    backend.captureGate = Completer();
    final operation = controller.complete();
    await Future<void>.delayed(Duration.zero);
    controller.disconnect();
    await controller.connect('bob');
    backend.paid = true;
    backend.captureGate!.complete(
      PaymentOrder(
        reference: 'order-1',
        amount: PaymentAmount(100, 'USD'),
        paid: true,
      ),
    );
    await operation;
    expect(controller.snapshot.payment, isNull);
    expect(controller.snapshot.paid, isFalse);
    await controller.connect('alice');
    expect(controller.snapshot.paid, isTrue);
  });
  test(
    'storage write failure prevents checkout creation and browser launch',
    () async {
      final blocked = make(storage: UnavailableStore());
      addTearDown(blocked.dispose);
      await blocked.connect('alice');
      await blocked.prepare('order-1');
      expect(blocked.snapshot.problem, PaymentProblem.storage);
      expect(backend.prepareCalls, 0);
      expect(browser.opens, 0);
    },
  );
  test(
    'provider timeout preserves pre-create reference for same-order recovery',
    () async {
      final limited = make(timeout: const Duration(milliseconds: 5));
      addTearDown(limited.dispose);
      await limited.connect('alice');
      backend.prepareGate = Completer();
      await limited.prepare('order-1');
      expect(limited.snapshot.problem, PaymentProblem.unavailable);
      expect(store.values['alice']?.reference, 'order-1');
      backend.prepareGate!.complete(
        await LabPaymentBackend().prepare('order-1'),
      );
      backend.prepareGate = null;
      await limited.prepare('order-1');
      expect(limited.snapshot.payment!.approval, isNotNull);
    },
  );
  test('changed amount fails closed before capture', () async {
    await controller.prepare('order-1');
    backend.changeAmount = true;
    await controller.complete();
    expect(controller.snapshot.problem, PaymentProblem.invalidResponse);
    expect(backend.captureCalls, 0);
    expect(controller.snapshot.canComplete, isFalse);
  });
  test(
    'a pending order cannot be silently replaced by a different order',
    () async {
      await controller.prepare('order-1');
      await controller.prepare('order-2');
      expect(controller.snapshot.problem, PaymentProblem.notAllowed);
      expect(store.values['alice']!.reference, 'order-1');
      expect(backend.prepareCalls, 1);
    },
  );
  test('browser failure preserves the provider order for retry', () async {
    final failed = make(opener: FailingBrowser());
    addTearDown(failed.dispose);
    await failed.connect('alice');
    await failed.prepare('order-1');
    await failed.openApproval();
    expect(failed.snapshot.problem, PaymentProblem.unavailable);
    expect(store.values['alice']?.approval, isNotNull);
    expect(backend.prepareCalls, 1);
  });
  test('offline status remains uncertain and does not fabricate failure or success', () async {
    await controller.prepare('order-1');
    backend.online = false;
    await controller.refresh();
    expect(controller.snapshot.problem, PaymentProblem.unavailable);
    expect(controller.snapshot.paid, isFalse);
    expect(store.values['alice'], isNotNull);
    backend.online = true;
    await controller.refresh();
    expect(controller.snapshot.problem, isNull);
  });
  test(
    'unreadable recovery state blocks a new checkout until explicitly cleared',
    () async {
      final blocked = make(storage: UnreadableStore());
      addTearDown(blocked.dispose);
      await blocked.connect('alice');
      await blocked.prepare('order-2');
      expect(blocked.snapshot.problem, PaymentProblem.storage);
      expect(backend.prepareCalls, 0);
      await blocked.forget();
      await blocked.prepare('order-2');
      expect(backend.prepareCalls, 1);
    },
  );
  test('double capture taps cannot create concurrent calls', () async {
    await controller.prepare('order-1');
    backend.captureGate = Completer();
    final first = controller.complete();
    await Future<void>.delayed(Duration.zero);
    await controller.complete();
    backend.captureGate!.complete(
      PaymentOrder(
        reference: 'order-1',
        amount: PaymentAmount(100, 'USD'),
        paid: true,
      ),
    );
    await first;
    expect(backend.captureCalls, 1);
    expect(controller.snapshot.paid, isTrue);
  });
  test(
    'pending serialization retains integer amount and process-recovery data',
    () async {
      await controller.prepare('order-1');
      await controller.openApproval();
      final roundTrip = PendingPayment.fromJson(
        store.values['alice']!.toJson(),
      );
      expect(roundTrip.amount.decimal, '1.00');
      expect(roundTrip.opened, isTrue);
      expect(roundTrip.approval!.providerId, 'LABORDER123456');
      expect(() => PaymentAmount(100, 'JPY'), throwsA(isA<PaymentException>()));
    },
  );
  test(
    'approval policy rejects live, lookalike, credentialed and mismatched URLs',
    () {
      final policy = PayPalLinkPolicy(
        callbackOrigin: Uri.parse('https://api.rays.to'),
      );
      for (final url in [
        'https://www.paypal.com/checkoutnow?token=LABORDER123456',
        'https://www.sandbox.paypal.com.evil.test/checkoutnow?token=LABORDER123456',
        'https://user@www.sandbox.paypal.com/checkoutnow?token=LABORDER123456',
        'https://www.sandbox.paypal.com/checkoutnow?token=DIFFERENT1234',
        'https://www.sandbox.paypal.com:444/checkoutnow?token=LABORDER123456',
      ]) {
        expect(
          policy.validApproval(
            PaymentApproval(
              reference: 'order-1',
              providerId: 'LABORDER123456',
              url: Uri.parse(url),
            ),
          ),
          isFalse,
        );
      }
    },
  );
}
