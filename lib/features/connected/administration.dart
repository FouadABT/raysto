part of 'connected_app.dart';

Widget reviewsPage(LiveContext live, {bool admin = false}) => rowsPage(
  live,
  admin ? 'Review moderation' : 'Customer reviews',
  admin ? 'admin.reviews' : 'reviews.manage',
  (c, row, refresh) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${row['rating']} / 5', style: Theme.of(c).textTheme.titleMedium),
        Text('${row['text']}'),
        if (row['response'] != null) Text('Your response: ${row['response']}'),
        Text('Status: ${friendly('${row['status']}')}'),
        TextButton(
          onPressed: () async {
            await live
                .tenant(row['restaurantId'])
                .action(
                  c,
                  admin ? 'Moderate review' : 'Reply to review',
                  'review.moderate',
                  id: row['id'],
                  version: row['version'],
                  initial: admin
                      ? {'status': row['status']}
                      : {'response': row['response'] ?? ''},
                  fields: admin
                      ? const [
                          InputSpec(
                            'status',
                            'Visibility',
                            options: ['published', 'hidden', 'pending'],
                          ),
                          InputSpec('reason', 'Reason'),
                        ]
                      : const [
                          InputSpec(
                            'response',
                            'Public response',
                            kind: 'long',
                          ),
                        ],
                );
            await refresh();
          },
          child: Text(admin ? 'Review visibility' : 'Reply'),
        ),
      ],
    ),
  ),
);

Widget administrationPage(LiveContext live) => DataPage(
  title: 'Platform administration',
  load: () => live.api.query('me'),
  content: (c, d, refresh) => d['platformAdmin'] != true
      ? [empty('Platform administrator access is required')]
      : [
          const Text(
            'Confirm your identity with a second factor before administrative actions. Every change is audited.',
          ),
          tile(
            'Verify identity',
            Icons.security,
            () => push(c, SecurityPage(runtime: live.runtime)),
          ),
          tile(
            'Revenue',
            Icons.insights,
            () => push(
              c,
              DataPage(
                title: 'Platform revenue',
                load: () => live.api.query('admin.revenue', {
                  'from': DateTime.now()
                      .toUtc()
                      .subtract(const Duration(days: 30))
                      .toIso8601String(),
                  'until': DateTime.now().toUtc().toIso8601String(),
                }),
                content: (_, data, _) => [RecordSummary(data)],
              ),
            ),
          ),
          tile(
            'Reviews awaiting moderation',
            Icons.rate_review_outlined,
            () => push(c, reviewsPage(live, admin: true)),
          ),
          tile(
            'Failed background jobs',
            Icons.pending_actions,
            () => push(
              c,
              rowsPage(
                live,
                'Failed jobs',
                'admin.jobs',
                (c, row, reload) => AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecordSummary(row),
                      TextButton(
                        onPressed: () async {
                          final scope = row['restaurantId'] == null
                              ? live
                              : live.tenant(row['restaurantId']);
                          await scope.action(
                            c,
                            'Retry failed job',
                            'admin.replayJob',
                            id: row['id'],
                            fields: const [
                              InputSpec('reason', 'Reason for replay'),
                            ],
                          );
                          await reload();
                        },
                        child: const Text('Review and retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          tile(
            'Provider events needing review',
            Icons.event_note,
            () => push(
              c,
              rowsPage(
                live,
                'Provider events',
                'admin.paymentExceptions',
                (_, row, _) => AppPanel(child: RecordSummary(row)),
              ),
            ),
          ),
          tile(
            'Financial exceptions',
            Icons.report_outlined,
            () => push(
              c,
              rowsPage(
                live,
                'Financial exceptions',
                'admin.financialCases',
                (c, row, reload) => AppPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RecordSummary(row),
                      if (row['status'] == 'review')
                        TextButton(
                          onPressed: () async {
                            await live
                                .tenant(row['restaurantId'])
                                .action(
                                  c,
                                  'Resolve exception',
                                  'admin.paymentException',
                                  id: row['id'],
                                  version: row['version'],
                                  fields: const [
                                    InputSpec(
                                      'resolution',
                                      'Resolution',
                                      options: [
                                        'evidenceReviewed',
                                        'recordReversal',
                                      ],
                                    ),
                                    InputSpec(
                                      'reason',
                                      'Evidence and reason',
                                      kind: 'long',
                                    ),
                                  ],
                                );
                            await reload();
                          },
                          child: const Text('Review resolution'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          tile(
            'Reconcile an existing refund',
            Icons.receipt_long_outlined,
            () async {
              final refs = await editFields(c, 'Refund references', const [
                InputSpec('restaurantId', 'Restaurant reference', kind: 'int'),
                InputSpec('captureId', 'Capture reference', kind: 'int'),
              ]);
              if (refs == null || !c.mounted) return;
              await live
                  .tenant(refs['restaurantId'])
                  .action(
                    c,
                    'Verify existing provider refund',
                    'admin.reconcileRefund',
                    id: refs['captureId'],
                    fields: const [
                      InputSpec('providerRefundId', 'PayPal refund reference'),
                      InputSpec(
                        'localRefundId',
                        'Raysto refund reference',
                        kind: 'int',
                        optional: true,
                      ),
                      InputSpec('reason', 'Evidence and reason', kind: 'long'),
                    ],
                  );
            },
          ),
          tile('Restaurant suspension', Icons.storefront_outlined, () async {
            final refs = await editFields(c, 'Restaurant reference', const [
              InputSpec('restaurantId', 'Restaurant reference', kind: 'int'),
            ]);
            if (refs == null || !c.mounted) return;
            await live
                .tenant(refs['restaurantId'])
                .action(
                  c,
                  'Restaurant suspension',
                  'admin.suspend',
                  fields: const [
                    InputSpec(
                      'suspended',
                      'Suspend new activity',
                      kind: 'bool',
                    ),
                    InputSpec('reason', 'Reason'),
                  ],
                );
          }),
          tile(
            'Create a plan revision',
            Icons.price_change_outlined,
            () => live.action(
              c,
              'New subscription plan revision',
              'admin.plan',
              fields: const [
                InputSpec('code', 'Plan code'),
                InputSpec(
                  'currency',
                  'Currency',
                  options: ['EUR', 'USD', 'GBP'],
                ),
                InputSpec(
                  'priceMinor',
                  'Subscription price in cents / pence',
                  kind: 'int',
                ),
                InputSpec(
                  'commissionBps',
                  'Commission basis points (100 = 1%)',
                  kind: 'int',
                ),
                InputSpec(
                  'providerPlanId',
                  'PayPal subscription plan ID',
                  optional: true,
                ),
                InputSpec(
                  'active',
                  'Active for new subscriptions',
                  kind: 'bool',
                ),
                InputSpec(
                  'features',
                  'Plan allowances',
                  kind: 'object',
                  children: [
                    InputSpec('dineIn', 'Dine-in', kind: 'bool'),
                    InputSpec('pickup', 'Pickup', kind: 'bool'),
                    InputSpec('delivery', 'Delivery', kind: 'bool'),
                    InputSpec(
                      'aiImportsPerDay',
                      'AI jobs per day',
                      kind: 'int',
                    ),
                    InputSpec(
                      'aiTokenBudgetPerDay',
                      'AI token budget per day',
                      kind: 'int',
                    ),
                    InputSpec(
                      'maxTeamMembers',
                      'Team member limit',
                      kind: 'int',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
);
