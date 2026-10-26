import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raysto_client/raysto_client.dart' as api;

import '../../backend/auth/session_controller.dart';
import '../../backend/live_runtime.dart';
import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import 'connected_payments_screen.dart';
import 'payment_panel.dart';

/// Dispatches cold/warm returns using the account's recovered reference.
class PaymentReturnScreen extends StatefulWidget {
  const PaymentReturnScreen({
    super.key,
    required this.runtime,
    required this.callback,
  });
  final LiveRuntime runtime;
  final Uri callback;
  @override
  State<PaymentReturnScreen> createState() => _PaymentReturnScreenState();
}

class _PaymentReturnScreenState extends State<PaymentReturnScreen> {
  bool? _sandbox;
  @override
  void initState() {
    super.initState();
    widget.runtime.payments.addListener(_choose);
    WidgetsBinding.instance.addPostFrameCallback((_) => _choose());
  }

  void _choose() {
    final controller = widget.runtime.payments;
    if (!mounted ||
        _sandbox != null ||
        controller.owner == null ||
        controller.snapshot.busy) {
      return;
    }
    setState(
      () => _sandbox =
          controller.snapshot.payment?.reference.startsWith('sandbox:') == true,
    );
  }

  @override
  void dispose() {
    widget.runtime.payments.removeListener(_choose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (_sandbox) {
    null => const MobilePage(
      title: 'PayPal Sandbox',
      children: [LinearProgressIndicator()],
    ),
    true => SandboxTestScreen(
      runtime: widget.runtime,
      callback: widget.callback,
    ),
    false => ConnectedPaymentsScreen(
      runtime: widget.runtime,
      callback: widget.callback,
    ),
  };
}

class SandboxTestScreen extends StatefulWidget {
  const SandboxTestScreen({super.key, required this.runtime, this.callback});
  final LiveRuntime runtime;
  final Uri? callback;
  @override
  State<SandboxTestScreen> createState() => _SandboxTestScreenState();
}

class _SandboxTestScreenState extends State<SandboxTestScreen>
    with WidgetsBindingObserver {
  late final _session = widget.runtime.createSession();
  late final _controller = widget.runtime.payments;
  api.SandboxPayment? _receipt;
  bool _busy = false,
      _error = false,
      _callbackHandled = false,
      _unmatched = false;
  String? _loadedOwner;
  bool get _connected =>
      _session.phase == SessionPhase.ready &&
      !_session.busy &&
      _controller.owner == _session.userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_changed);
    _session.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  void _changed() {
    if (!mounted) return;
    if (!_connected) {
      _receipt = null;
      _loadedOwner = null;
    } else {
      if (!_busy && _loadedOwner != _session.userId) unawaited(_restore());
      if (!_controller.snapshot.busy &&
          widget.callback != null &&
          !_callbackHandled) {
        _callbackHandled = true;
        unawaited(_handleReturn());
      }
      if (_controller.snapshot.paid &&
          _receipt?.state != 'captured' &&
          !_busy) {
        unawaited(_restore());
      }
    }
    setState(() {});
  }

  Future<void> _handleReturn() async {
    final matched = await _controller.handleReturn(widget.callback!);
    if (mounted) setState(() => _unmatched = !matched);
  }

  Future<void> _operation(Future<void> Function(String owner) action) async {
    if (!_connected || _busy) return;
    final owner = _session.userId!;
    setState(() {
      _busy = true;
      _error = false;
    });
    try {
      await action(owner);
    } catch (_) {
      if (mounted && _session.userId == owner) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _accept(String owner, api.SandboxPayment? receipt) {
    if (!mounted || !_connected || _session.userId != owner) return;
    if (receipt != null &&
        (receipt.userId != owner ||
            receipt.amountMinor != 100 ||
            receipt.currency != 'USD')) {
      throw StateError('Unexpected sandbox checkout');
    }
    setState(() {
      _receipt = receipt;
      _loadedOwner = owner;
    });
  }

  Future<void> _restore() => _operation((owner) async {
    // Read the saved request key; this never creates a PayPal order or captures.
    _loadedOwner = owner;
    final pending = _controller.snapshot.payment;
    if (pending?.reference.startsWith('sandbox:') == true) {
      final receipt = await widget.runtime.connection.client.sandboxPayments
          .read(int.parse(pending!.reference.substring(8)));
      _accept(owner, receipt);
    } else {
      _accept(owner, await widget.runtime.sandboxCheckout.restore(owner));
    }
  });

  Future<void> _start() => _operation((owner) async {
    final receipt = await widget.runtime.sandboxCheckout.start(owner);
    _accept(owner, receipt);
    if (!mounted || !_connected || _session.userId != owner) return;
    await _controller.prepare('sandbox:${receipt.id}');
    if (!mounted || !_connected || _session.userId != owner) return;
    if (_controller.snapshot.canOpen) await _controller.openApproval();
  });

  Future<void> _another() => _operation((owner) async {
    if (_receipt?.state != 'captured') return;
    await _controller.forget();
    await widget.runtime.sandboxCheckout.clear(owner);
    _accept(owner, null);
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _connected) {
      unawaited(_controller.refresh());
      unawaited(_restore());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_changed);
    _session.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.snapshot;
    final otherCheckout =
        state.payment != null &&
        !state.payment!.reference.startsWith('sandbox:');
    return MobilePage(
      title: 'Test PayPal Sandbox',
      children: [
        AppNotice(
          title: context.tr('A real Sandbox checkout'),
          message: context.tr(
            'PayPal opens in your browser. Approve USD 1.00 with a Sandbox Personal buyer account, then return and complete the payment. No real money is charged.',
          ),
        ),
        if (!_connected)
          AppNotice(title: context.tr('Connect your account first')),
        if (_busy) const LinearProgressIndicator(),
        if (_error)
          AppNotice(
            title: context.tr('Connection needs attention'),
            message: context.tr(
              'Your checkout is kept. Retry before starting another payment.',
            ),
            action: AppButton(
              label: context.tr('Retry recovery'),
              onPressed: _busy ? null : _restore,
            ),
          ),
        if (_unmatched)
          AppNotice(title: context.tr('Return link could not be matched')),
        if (_connected && otherCheckout)
          AppNotice(
            title: context.tr('Finish your saved checkout first'),
            action: AppButton(
              label: context.tr('Open saved checkout'),
              onPressed: () => openPage(
                context,
                ConnectedPaymentsScreen(runtime: widget.runtime),
              ),
            ),
          ),
        if (_connected && !otherCheckout) ...[
          if (state.payment != null || state.problem != null)
            PaymentPanel(controller: _controller),
          if (state.payment == null && _receipt?.state != 'captured')
            AppButton(
              label: context.tr('Test USD 1.00 with PayPal'),
              icon: Icons.open_in_new,
              onPressed: _busy || state.busy || _error ? null : _start,
            ),
          if (_receipt != null) SandboxReceipt(payment: _receipt!),
          if (_receipt?.state == 'captured')
            OutlinedButton(
              onPressed: _busy || state.busy ? null : _another,
              child: Text(context.tr('Start another test')),
            ),
          TextButton(
            onPressed: _busy || state.busy
                ? null
                : () async {
                    await _controller.refresh();
                    await _restore();
                  },
            child: Text(context.tr('Refresh receipt')),
          ),
        ],
      ],
    );
  }
}

class SandboxReceipt extends StatelessWidget {
  const SandboxReceipt({super.key, required this.payment});
  final api.SandboxPayment payment;
  @override
  Widget build(BuildContext context) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr(
            payment.state == 'captured'
                ? 'Sandbox capture confirmed'
                : 'Sandbox receipt',
          ),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Text('USD 1.00', textDirection: TextDirection.ltr),
        SelectableText(
          '${context.tr('PayPal order')}: ${payment.providerOrderId ?? '—'}',
          textDirection: TextDirection.ltr,
        ),
        SelectableText(
          '${context.tr('Capture ID')}: ${payment.captureId ?? '—'}',
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(height: 12),
        Text(
          context.tr(
            payment.webhookReceivedAt == null
                ? 'Webhook: waiting for PayPal delivery'
                : 'Webhook: verified and received',
          ),
        ),
      ],
    ),
  );
}
