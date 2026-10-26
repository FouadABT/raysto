import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raysto_client/raysto_client.dart' as api;

import '../../backend/auth/session_controller.dart';
import '../../backend/live_runtime.dart';
import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import 'payment_lab_screen.dart';
import 'payment_panel.dart';

class ConnectedPaymentsScreen extends StatefulWidget {
  const ConnectedPaymentsScreen({
    super.key,
    required this.runtime,
    this.callback,
  });
  final LiveRuntime runtime;
  final Uri? callback;
  @override
  State<ConnectedPaymentsScreen> createState() =>
      _ConnectedPaymentsScreenState();
}

class _ConnectedPaymentsScreenState extends State<ConnectedPaymentsScreen>
    with WidgetsBindingObserver {
  late final _session = widget.runtime.createSession();
  late final _controller = widget.runtime.payments;
  final List<api.PurchaseOrder> _orders = [];
  bool _loading = false,
      _error = false,
      _more = true,
      _callbackHandled = false,
      _unmatched = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_changed);
    _session.addListener(_changed);
    unawaited(_load());
    WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
  }

  bool get _connected =>
      _session.phase == SessionPhase.ready &&
      !_session.busy &&
      _controller.owner == _session.userId;
  void _changed() {
    if (!mounted) return;
    if (_connected &&
        !_controller.snapshot.busy &&
        widget.callback != null &&
        !_callbackHandled) {
      _callbackHandled = true;
      unawaited(_handleReturn());
    }
    setState(() {});
  }

  Future<void> _handleReturn() async {
    final matched = await _controller.handleReturn(widget.callback!);
    if (mounted) setState(() => _unmatched = !matched);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading || _session.phase != SessionPhase.ready || _session.busy) {
      return;
    }
    final owner = _session.userId;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final page = await widget.runtime.connection.client.commerce.myOrders(
        reset ? 0 : _orders.length,
      );
      if (mounted &&
          owner == _session.userId &&
          _session.phase == SessionPhase.ready) {
        setState(() {
          if (reset) _orders.clear();
          _orders.addAll(page);
          _more = page.length == 50;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _connected) {
      unawaited(_controller.refresh());
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
    if (!_connected) {
      return MobilePage(
        title: 'PayPal Sandbox',
        children: [
          AppNotice(
            title: context.tr('Connect your account first'),
            message: context.tr(
              'Your saved checkout is private to the account that started it.',
            ),
          ),
        ],
      );
    }
    final state = _controller.snapshot;
    return MobilePage(
      title: 'PayPal Sandbox',
      actions: [
        IconButton(
          tooltip: context.tr('Refresh'),
          onPressed: _loading
              ? null
              : () async {
                  await _controller.refresh();
                  await _load(reset: true);
                },
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        AppNotice(
          title: context.tr('Sandbox payments only'),
          message: context.tr(
            'Use a PayPal sandbox Personal account to approve. No real money is charged.',
          ),
        ),
        if (_unmatched)
          AppNotice(
            title: context.tr('Return link could not be matched'),
            message: context.tr(
              'No payment was confirmed from this link. Reopen your order and check its status.',
            ),
          ),
        PaymentPanel(controller: _controller),
        if (_loading) const LinearProgressIndicator(),
        if (_error)
          AppNotice(
            title: context.tr('Connection needs attention'),
            action: AppButton(
              label: context.tr('Retry'),
              onPressed: () => _load(reset: true),
            ),
          ),
        Section(
          title: 'Your orders',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_orders.isEmpty && !_loading && !_error)
                Text(
                  context.tr(
                    'No connected orders yet. This payment core is ready for future order flows; the local test lab works without an order.',
                  ),
                ),
              for (final order in _orders)
                Card(
                  child: ListTile(
                    title: Text(
                      '#${order.id} · ${(order.totalMinor / 100).toStringAsFixed(2)} ${order.currency}',
                    ),
                    subtitle: Text(context.tr(order.paymentStatus)),
                    trailing: Icon(
                      order.paymentStatus == 'paid'
                          ? Icons.verified_outlined
                          : Icons.chevron_right,
                    ),
                    onTap:
                        state.busy ||
                            state.payment != null ||
                            order.paymentStatus == 'paid'
                        ? null
                        : () => _controller.prepare('${order.id}'),
                  ),
                ),
              if (_more && _orders.isNotEmpty)
                TextButton(
                  onPressed: _loading ? null : () => _load(),
                  child: Text(context.tr('Load more')),
                ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => openPage(context, const PaymentLabScreen()),
          icon: const Icon(Icons.science_outlined),
          label: Text(context.tr('Payment test lab')),
        ),
      ],
    );
  }
}
