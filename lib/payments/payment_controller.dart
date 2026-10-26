import 'dart:async';

import 'package:flutter/foundation.dart';

import 'payment_models.dart';

/// One resumable checkout per account/backend. Restaurant rules live in adapters.
/// Logout invalidates late work immediately; saved state stays private to its owner.
class PaymentController extends ChangeNotifier {
  PaymentController({
    required this.backend,
    required this.store,
    required this.browser,
    required this.links,
    this.timeout = const Duration(seconds: 35),
  });
  final PaymentBackend backend;
  final PaymentStore store;
  final PaymentBrowser browser;
  final PayPalLinkPolicy links;
  final Duration timeout;
  PaymentSnapshot _snapshot = const PaymentSnapshot();
  PaymentSnapshot get snapshot => _snapshot;
  String? _owner;
  String? get owner => _owner;
  int _generation = 0;
  bool _disposed = false;
  bool _recoveryReady = false;
  Future<void> _writes = Future.value();

  bool _current(int generation) =>
      !_disposed && _owner != null && generation == _generation;
  void _publish(PaymentSnapshot state) {
    if (_disposed) return;
    _snapshot = state;
    notifyListeners();
  }

  Future<void> connect(String owner) async {
    if (_disposed || owner.isEmpty || _owner == owner) return;
    _owner = owner;
    _recoveryReady = false;
    _generation++;
    _publish(const PaymentSnapshot());
    await restore();
  }

  void disconnect() {
    _generation++;
    _owner = null;
    _recoveryReady = false;
    _publish(const PaymentSnapshot());
  }

  Future<void> _write(
    int generation,
    Future<void> Function(String owner) action,
  ) {
    final owner = _owner!;
    final operation = _writes.then((_) async {
      if (_current(generation)) await action(owner);
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _save(int generation, PendingPayment pending) async {
    try {
      await _write(generation, (owner) => store.write(owner, pending));
    } catch (_) {
      throw const PaymentException(PaymentProblem.storage);
    }
  }

  void _validateOrder(PaymentOrder order, PendingPayment pending) {
    if (order.reference != pending.reference ||
        !order.amount.matches(pending.amount) ||
        pending.approval != null && !links.validApproval(pending.approval!)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
  }

  Future<bool> _accept(
    int generation,
    PaymentOrder order,
    PendingPayment pending,
  ) async {
    _validateOrder(order, pending);
    if (!_current(generation)) return true;
    if (order.paid) {
      // A failed clear leaves an old reference that is safely rechecked next time.
      try {
        await _write(generation, store.clear);
      } catch (_) {}
      if (_current(generation)) {
        _publish(PaymentSnapshot(phase: PaymentPhase.paid, payment: pending));
      }
      return true;
    }
    return false;
  }

  Future<void> _run(
    PaymentPhase phase,
    Future<void> Function(int generation) action,
  ) async {
    if (_disposed || _owner == null || snapshot.busy) return;
    final generation = _generation;
    _publish(PaymentSnapshot(phase: phase, payment: snapshot.payment));
    try {
      await action(generation);
    } catch (error) {
      if (_current(generation)) {
        _publish(
          PaymentSnapshot(
            phase: PaymentPhase.needsAttention,
            payment: snapshot.payment,
            problem: error is PaymentException
                ? error.problem
                : PaymentProblem.unavailable,
          ),
        );
      }
    }
  }

  Future<void> restore() => _run(PaymentPhase.restoring, (generation) async {
    _recoveryReady = false;
    await _writes;
    if (!_current(generation)) return;
    final PendingPayment? pending;
    try {
      pending = await store.read(_owner!).timeout(timeout);
    } catch (_) {
      throw const PaymentException(PaymentProblem.storage);
    }
    if (!_current(generation)) return;
    if (pending == null) {
      _recoveryReady = true;
      _publish(const PaymentSnapshot());
      return;
    }
    _publish(PaymentSnapshot(phase: PaymentPhase.restoring, payment: pending));
    if (pending.approval != null && !links.validApproval(pending.approval!)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    _recoveryReady = true;
    final order = await backend.read(pending.reference).timeout(timeout);
    if (await _accept(generation, order, pending)) return;
    if (_current(generation)) {
      _publish(PaymentSnapshot(phase: PaymentPhase.ready, payment: pending));
    }
  });

  Future<void> prepare(String reference) => _run(PaymentPhase.preparing, (
    generation,
  ) async {
    final previous = snapshot.payment;
    if (!_recoveryReady) {
      throw const PaymentException(PaymentProblem.storage);
    }
    if (reference.isEmpty ||
        previous != null && previous.reference != reference) {
      throw const PaymentException(PaymentProblem.notAllowed);
    }
    final order = await backend.read(reference).timeout(timeout);
    if (!_current(generation)) return;
    if (order.reference != reference) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    final pending =
        previous ?? PendingPayment(reference: reference, amount: order.amount);
    if (await _accept(generation, order, pending)) return;
    // Persist the reference BEFORE creating the provider order. An uncertain
    // response is recovered by the server's stable, persisted idempotency key.
    await _save(generation, pending);
    if (!_current(generation)) return;
    _publish(PaymentSnapshot(phase: PaymentPhase.preparing, payment: pending));
    final approval = await backend.prepare(reference).timeout(timeout);
    if (!_current(generation)) return;
    if (approval.reference != reference || !links.validApproval(approval)) {
      throw const PaymentException(PaymentProblem.invalidResponse);
    }
    final ready = PendingPayment(
      reference: reference,
      amount: order.amount,
      approval: approval,
      opened: pending.opened,
    );
    await _save(generation, ready);
    if (_current(generation)) {
      _publish(PaymentSnapshot(phase: PaymentPhase.ready, payment: ready));
    }
  });

  Future<void> openApproval() async {
    if (!snapshot.canOpen || _owner == null) return;
    await _run(PaymentPhase.preparing, (generation) async {
      final pending = snapshot.payment!;
      // Recheck settlement before reopening a provider page, including webhook races.
      final order = await backend.read(pending.reference).timeout(timeout);
      if (await _accept(generation, order, pending)) return;
      if (!_current(generation)) return;
      if (!links.validApproval(pending.approval!)) {
        throw const PaymentException(PaymentProblem.invalidResponse);
      }
      final openedPayment = PendingPayment(
        reference: pending.reference,
        amount: pending.amount,
        approval: pending.approval,
        opened: true,
      );
      await _save(generation, openedPayment);
      if (!_current(generation)) return;
      final opened = await browser.open(pending.approval!.url).timeout(timeout);
      if (!_current(generation)) return;
      if (!opened) throw const PaymentException(PaymentProblem.unavailable);
      _publish(
        PaymentSnapshot(phase: PaymentPhase.away, payment: openedPayment),
      );
    });
  }

  /// Returning/resuming only reads status. Completing requires an explicit action.
  Future<void> refresh() async {
    final pending = snapshot.payment;
    if (pending == null) return;
    await _run(PaymentPhase.checking, (generation) async {
      final order = await backend.read(pending.reference).timeout(timeout);
      if (await _accept(generation, order, pending)) return;
      if (_current(generation)) {
        _publish(PaymentSnapshot(phase: PaymentPhase.ready, payment: pending));
      }
    });
  }

  Future<bool> handleReturn(Uri uri) async {
    final pending = snapshot.payment;
    if (_owner == null ||
        snapshot.busy ||
        pending == null ||
        !links.matchesCallback(uri, pending)) {
      return false;
    }
    final generation = _generation;
    await refresh();
    if (_current(generation) &&
        !snapshot.paid &&
        snapshot.problem == null &&
        uri.path == '/payments/cancel') {
      _publish(PaymentSnapshot(phase: PaymentPhase.paused, payment: pending));
    }
    return true;
  }

  Future<void> complete() async {
    if (!snapshot.canComplete) return;
    await _run(PaymentPhase.completing, (generation) async {
      final pending = snapshot.payment!;
      final current = await backend.read(pending.reference).timeout(timeout);
      if (await _accept(generation, current, pending)) return;
      if (!_current(generation)) return;
      final order = await backend.complete(pending.reference).timeout(timeout);
      if (await _accept(generation, order, pending)) return;
      if (_current(generation)) {
        _publish(
          PaymentSnapshot(
            phase: PaymentPhase.ready,
            payment: pending,
            problem: PaymentProblem.notApproved,
          ),
        );
      }
    });
  }

  /// Drops only a local recovery reference. Never cancels/refunds a provider order.
  Future<void> forget() => _run(PaymentPhase.checking, (generation) async {
    try {
      await _write(generation, store.clear);
    } catch (_) {
      throw const PaymentException(PaymentProblem.storage);
    }
    if (_current(generation)) {
      _recoveryReady = true;
      _publish(const PaymentSnapshot());
    }
  });

  @override
  void dispose() {
    _generation++;
    _disposed = true;
    super.dispose();
  }
}
