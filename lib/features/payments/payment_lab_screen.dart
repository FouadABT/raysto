import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import '../../payments/payment_controller.dart';
import '../../payments/payment_models.dart';
import '../../payments/testing/payment_lab.dart';
import 'payment_panel.dart';

class PaymentLabScreen extends StatefulWidget {
  const PaymentLabScreen({super.key});
  @override
  State<PaymentLabScreen> createState() => _PaymentLabScreenState();
}

class _PaymentLabScreenState extends State<PaymentLabScreen> {
  final _backend = LabPaymentBackend();
  final _store = MemoryPaymentStore();
  final _browser = LabPaymentBrowser();
  late PaymentController _controller;
  @override
  void initState() {
    super.initState();
    _create();
  }

  void _create() {
    _controller = PaymentController(
      backend: _backend,
      store: _store,
      browser: _browser,
      links: PayPalLinkPolicy(callbackOrigin: Uri.parse('https://api.rays.to')),
    );
    unawaited(_controller.connect('local-lab'));
  }

  Future<void> _restart() async {
    _controller.dispose();
    setState(_create);
  }

  void _reset() {
    _controller.dispose();
    _backend
      ..online = true
      ..approved = false
      ..paid = false
      ..loseNextCaptureResponse = false
      ..prepareCalls = 0
      ..captureCalls = 0;
    _store.values.clear();
    _browser.opens = 0;
    setState(_create);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final state = _controller.snapshot;
      return MobilePage(
        title: 'Payment test lab',
        children: [
          AppNotice(
            title: context.tr('Local simulation — no PayPal requests'),
            message: context.tr(
              'These controls exercise the reusable payment core without an account, restaurant or real transaction.',
            ),
          ),
          PaymentPanel(controller: _controller, simulated: true),
          if (state.payment == null && !state.busy)
            AppButton(
              label: context.tr('Prepare test checkout'),
              icon: Icons.science_outlined,
              onPressed: () => _controller.prepare('LAB-001'),
            ),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.tr('Try interrupted checkout'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  key: const ValueKey('lab-network'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Simulate network available')),
                  value: _backend.online,
                  onChanged: state.busy
                      ? null
                      : (v) => setState(() => _backend.online = v),
                ),
                SwitchListTile(
                  key: const ValueKey('lab-response-loss'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Lose the next capture response')),
                  subtitle: Text(
                    context.tr(
                      'The simulated backend settles; the app must recover by checking status.',
                    ),
                  ),
                  value: _backend.loseNextCaptureResponse,
                  onChanged: state.busy
                      ? null
                      : (v) => setState(
                          () => _backend.loseNextCaptureResponse = v,
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed:
                      state.busy ||
                          state.payment?.approval == null ||
                          state.paid
                      ? null
                      : () async {
                          _backend.approved = true;
                          await _controller.handleReturn(
                            Uri.parse(
                              'https://api.rays.to/payments/return?token=LABORDER123456',
                            ),
                          );
                        },
                  child: Text(context.tr('Simulate buyer approval and return')),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed:
                      state.busy ||
                          state.payment?.approval == null ||
                          state.paid
                      ? null
                      : () => _controller.handleReturn(
                          Uri.parse(
                            'https://api.rays.to/payments/cancel?token=LABORDER123456',
                          ),
                        ),
                  child: Text(context.tr('Simulate cancellation return')),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: state.busy ? null : _restart,
                  child: Text(context.tr('Recreate payment controller')),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Recovery here uses memory to imitate a restart. Connected payments use encrypted device storage.',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: state.busy ? null : _reset,
                  child: Text(context.tr('Reset local test')),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
