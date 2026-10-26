import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import '../../payments/payment_controller.dart';
import '../../payments/payment_models.dart';

String paymentTitle(PaymentPhase phase) => switch (phase) {
  PaymentPhase.idle => 'Ready when you are',
  PaymentPhase.restoring => 'Restoring checkout',
  PaymentPhase.preparing => 'Preparing checkout',
  PaymentPhase.ready => 'Checkout saved',
  PaymentPhase.away => 'Continue in PayPal',
  PaymentPhase.checking => 'Checking payment',
  PaymentPhase.completing => 'Completing payment',
  PaymentPhase.paid => 'Payment confirmed',
  PaymentPhase.paused => 'Checkout paused',
  PaymentPhase.needsAttention => 'Payment needs attention',
};

String paymentMessage(PaymentSnapshot state) {
  if (state.problem != null) {
    return switch (state.problem!) {
      PaymentProblem.storage => 'Your checkout could not be saved securely. Retry recovery before continuing.',
      PaymentProblem.invalidResponse || PaymentProblem.reconciliationRequired => 'This checkout needs review. Payment details do not match or the checkout has expired. Do not start a second payment.',
      PaymentProblem.notAllowed =>
        'This checkout is unavailable for the connected account.',
      PaymentProblem.notApproved => 'Approval has not been confirmed. Continue in PayPal, then check again.',
      PaymentProblem.unavailable => 'Payment status is not confirmed. Check your connection and check again before starting another checkout.',
    };
  }
  return switch (state.phase) {
    PaymentPhase.paid =>
      'The backend confirmed payment. You can safely continue.',
    PaymentPhase.paused => 'Returning from cancellation does not cancel or refund an order. Your checkout is kept for later.',
    PaymentPhase.away => 'Approve with your sandbox buyer account, then return here and check the payment.',
    PaymentPhase.idle =>
      'Choose an unpaid order to prepare a sandbox checkout.',
    _ => 'Your total comes from the backend. Returning from PayPal alone does not confirm payment.',
  };
}

/// Reusable presentation; it never knows about menus, baskets or restaurant roles.
class PaymentPanel extends StatelessWidget {
  const PaymentPanel({
    super.key,
    required this.controller,
    this.simulated = false,
  });
  final PaymentController controller;
  final bool simulated;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.snapshot;
      final pending = state.payment;
      final completeFirst =
          pending?.opened == true && state.phase != PaymentPhase.paused;
      return AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                context.tr(paymentTitle(state.phase)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (pending != null) ...[
              const SizedBox(height: 16),
              Text(
                pending.amount.label,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('${context.tr('Order reference')}: ${pending.reference}'),
            ],
            const SizedBox(height: 12),
            Text(context.tr(paymentMessage(state))),
            if (state.busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (pending != null && !state.busy && !state.paid) ...[
              const SizedBox(height: 20),
              if (state.canOpen)
                AppButton(
                  label: context.tr(
                    completeFirst
                        ? 'Check and complete payment'
                        : simulated
                        ? 'Simulate opening PayPal'
                        : 'Open PayPal Sandbox',
                  ),
                  icon: completeFirst
                      ? Icons.verified_outlined
                      : Icons.open_in_new,
                  onPressed: completeFirst
                      ? controller.complete
                      : controller.openApproval,
                ),
              if (state.canOpen) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: completeFirst
                      ? controller.openApproval
                      : controller.complete,
                  child: Text(
                    context.tr(
                      completeFirst
                          ? simulated
                                ? 'Simulate opening PayPal'
                                : 'Open PayPal Sandbox'
                          : 'Check and complete payment',
                    ),
                  ),
                ),
              ],
              if (pending.approval == null && !state.blocked)
                AppButton(
                  label: context.tr('Recover checkout'),
                  onPressed: () => controller.prepare(pending.reference),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: controller.refresh,
                child: Text(context.tr('Check payment status')),
              ),
            ],
            if (!state.busy && state.problem == PaymentProblem.storage) ...[
              const SizedBox(height: 12),
              AppButton(
                label: context.tr('Retry recovery'),
                onPressed: controller.restore,
              ),
            ],
            if (!state.busy && (pending != null || state.problem != null))
              TextButton(
                onPressed: () async {
                  if (!state.paid &&
                      !await confirmAction(
                        context,
                        'Remove saved checkout?',
                        'This removes only this device’s recovery reference. It does not cancel, refund or change the order. You can reopen the order later.',
                      )) {
                    return;
                  }
                  await controller.forget();
                },
                child: Text(
                  context.tr(state.paid ? 'Done' : 'Remove saved checkout'),
                ),
              ),
          ],
        ),
      );
    },
  );
}
