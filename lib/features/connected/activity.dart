part of 'connected_app.dart';

Widget activityHome(LiveContext live) => DataPage(
  title: 'Your activity',
  load: () async => {},
  content: (c, d, refresh) => [
    const RaystoStoryHeader(
      eyebrow: 'At your table',
      title: 'Every good moment,\nin one place.',
      message: 'Your orders, shared tables and the places you love.',
      scene: RaystoScene.receipt,
      compact: true,
    ),
    tile(
      'Orders',
      Icons.receipt_long_outlined,
      () => push(c, ordersPage(live)),
    ),
    tile(
      'Current visits',
      Icons.table_restaurant_outlined,
      () => push(
        c,
        rowsPage(
          live,
          'Visits',
          'visits',
          (c, v, _) => tile(
            'Table ${v['tableId']}',
            Icons.table_restaurant,
            () => push(
              c,
              TableRoomPage(
                live: live.tenant(v['restaurantId']),
                visitId: v['id'],
              ),
            ),
            subtitle: '${v['status']}',
          ),
        ),
      ),
    ),
    tile(
      'Payments and receipts',
      Icons.payments_outlined,
      () => push(c, checkoutsPage(live)),
    ),
    tile(
      'Saved restaurants',
      Icons.favorite_border,
      () => push(
        c,
        rowsPage(
          live,
          'Favorites',
          'favorites',
          (c, v, _) => tile(
            'Restaurant ${v['restaurantId']}',
            Icons.restaurant,
            () => push(c, StorefrontPage(live: live.tenant(v['restaurantId']))),
          ),
        ),
      ),
    ),
    tile(
      'Notifications',
      Icons.notifications_outlined,
      () => push(c, notificationsPage(live)),
    ),
    tile(
      'Help and conversations',
      Icons.chat_bubble_outline,
      () => push(c, supportHome(live)),
    ),
  ],
);

Widget ordersPage(LiveContext live, {bool staff = false}) => rowsPage(
  live,
  'Orders',
  'orders',
  (c, order, _) => tile(
    'Order #${order['id']}',
    Icons.receipt_long,
    () => push(
      c,
      orderPage(
        live.restaurantId == null ? live.tenant(order['restaurantId']) : live,
        order['id'],
      ),
    ),
    subtitle:
        '${friendly('${order['status']}')} · ${money(order['totalMinor'], '${order['currency']}')} · ${friendly('${order['paymentStatus']}')}',
  ),
  parameters: {'staff': staff},
  poll: true,
);

Widget orderPage(LiveContext live, int id) => DataPage(
  title: 'Order #$id',
  poll: true,
  load: () => live.api.query('order', live.params({'id': id})),
  content: (c, d, refresh) => [
    AppButton(
      label: 'Open conversation',
      icon: Icons.forum_outlined,
      onPressed: () => push(c, TableRoomPage(live: live, orderId: id)),
    ),
    RecordSummary(d),
    if (d['paymentStatus'] != 'paid' &&
        !{'cancelled', 'rejected'}.contains(d['status']))
      AppButton(
        label: 'Pay outstanding balance',
        onPressed: () => allocate(
          c,
          live,
          orderId: d['visitId'] == null ? id : null,
          visitId: d['visitId'],
        ),
      ),
    if (d['visitId'] != null)
      tile(
        'Shared table bill',
        Icons.groups_outlined,
        () => push(c, visitPage(live, d['visitId'])),
      ),
    if (live.operator || live.role == 'kitchen')
      AppButton(
        label: 'Update order',
        onPressed: () async {
          await live.action(
            c,
            'Update order',
            'order.transition',
            id: id,
            version: d['version'],
            fields: [
              InputSpec(
                'status',
                'Next status',
                options: live.role == 'kitchen'
                    ? ['preparing', 'ready']
                    : [
                        'accepted',
                        'preparing',
                        'ready',
                        'served',
                        'collected',
                        'completed',
                        'rejected',
                      ],
              ),
              const InputSpec('reason', 'Reason', optional: true),
            ],
          );
          await refresh();
        },
      ),
    if (!{'completed', 'cancelled', 'rejected'}.contains(d['status']))
      OutlinedButton(
        onPressed: () async {
          await live.action(
            c,
            'Cancel order',
            'order.cancel',
            id: id,
            version: d['version'],
            fields: [
              const InputSpec('reason', 'Reason'),
              if (live.manager)
                const InputSpec(
                  'approve',
                  'Approve cancellation',
                  kind: 'bool',
                  value: true,
                ),
            ],
          );
          await refresh();
        },
        child: const Text('Request cancellation'),
      ),
    if (d['fulfillment'] == 'delivery')
      tile(
        'Delivery tracking',
        Icons.delivery_dining,
        () => push(
          c,
          DataPage(
            title: 'Delivery',
            poll: true,
            load: () => live.api.query(
              'delivery.tracking',
              live.params({'orderId': id}),
            ),
            content: (_, state, _) => [RecordSummary(state)],
          ),
        ),
      ),
    if (d['status'] == 'completed' && live.role == 'customer')
      tile(
        'Leave a review',
        Icons.star_border,
        () => live.action(
          c,
          'Review your meal',
          'review.save',
          id: id,
          fields: const [
            InputSpec('rating', 'Rating from 1 to 5', kind: 'int'),
            InputSpec('text', 'Your review', kind: 'long'),
          ],
        ),
      ),
    tile(
      'Get help with this order',
      Icons.help_outline,
      () => openSupport(c, live, orderId: id),
    ),
  ],
);

Widget visitPage(LiveContext live, int id) => DataPage(
  title: 'Your table',
  poll: true,
  load: () => live.api.query('visit', live.params({'id': id, 'limit': 100})),
  content: (c, d, refresh) => [
    AppButton(
      label: 'Open table room',
      icon: Icons.forum_outlined,
      onPressed: () => push(c, TableRoomPage(live: live, visitId: id)),
    ),
    RaystoStoryHeader(
      eyebrow: 'Around the table',
      title: 'Table ${d['tableId']}',
      message: '${d['guestCount']} guests · ${friendly('${d['status']}')}',
      compact: true,
      scene: RaystoScene.table,
    ),
    AppPanel(
      child: RecordSummary({
        'Table': d['tableId'],
        'Guests': d['guestCount'],
        'Status': d['status'],
        'Participants': d['participantCount'],
      }),
    ),
    if (d['status'] == 'active') ...[
      AppButton(
        label: 'Order another round',
        icon: Icons.restaurant_menu,
        onPressed: () => push(c, StorefrontPage(live: live, visitId: id)),
      ),
      AppButton(
        label: 'Pay or split the bill',
        icon: Icons.payments_outlined,
        secondary: true,
        onPressed: () =>
            allocate(c, live, visitId: id, charges: records(d['rows'])),
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final kind in ['water', 'cutlery', 'help', 'bill'])
            OutlinedButton(
              onPressed: () async {
                await live.action(
                  c,
                  'Request $kind',
                  'service.create',
                  id: id,
                  fixed: {'kind': kind},
                );
                await refresh();
              },
              child: Text(friendly(kind)),
            ),
        ],
      ),
      tile(
        'Service requests',
        Icons.room_service_outlined,
        () => push(
          c,
          rowsPage(
            live,
            'Service requests',
            'services',
            (c, r, reload) => Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('${r['kind']}'),
                    subtitle: Text('${r['status']}'),
                  ),
                  if (live.operator)
                    TextButton(
                      onPressed: () async {
                        await live.action(
                          c,
                          'Update request',
                          'service.transition',
                          id: r['id'],
                          version: r['version'],
                          fields: const [
                            InputSpec(
                              'status',
                              'Status',
                              options: [
                                'acknowledged',
                                'completed',
                                'cancelled',
                              ],
                            ),
                            InputSpec('reason', 'Reason', optional: true),
                          ],
                        );
                        await reload();
                      },
                      child: const Text('Update'),
                    ),
                ],
              ),
            ),
            parameters: {'visitId': id},
            poll: true,
          ),
        ),
      ),
      tile(
        'Invite someone to the table',
        Icons.person_add_alt,
        () => perform(c, () async {
          final invite = await live.action(
            c,
            'Create visit invitation',
            'visit.invite',
            id: id,
            fixed: {'kind': 'visit'},
            fields: const [
              InputSpec(
                'uses',
                'Number of guests allowed',
                kind: 'int',
                value: 1,
              ),
            ],
          );
          if (invite != null && c.mounted) {
            await notice(c, 'Share this invitation privately', invite);
          }
        }),
      ),
      if (live.operator)
        tile(
          'Move party',
          Icons.swap_horiz,
          () => perform(c, () async {
            final floor = await live.api.query('floor', live.params());
            if (!c.mounted) return;
            final table = await showDialog<int>(
              context: c,
              builder: (dialog) => SimpleDialog(
                title: const Text('Choose destination'),
                children: [
                  for (final t in records(floor['rows']).where(
                    (t) => t['visitId'] == null && t['needsReset'] != true,
                  ))
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(dialog, t['id']),
                      child: Text('${t['label']} · ${t['capacity']} seats'),
                    ),
                ],
              ),
            );
            if (table == null || !c.mounted) return;
            await live.action(
              c,
              'Confirm table move',
              'visit.move',
              id: id,
              version: d['version'],
              fixed: {
                'tableId': table,
                'confirm': true,
                'guestCount': d['guestCount'],
              },
            );
            await refresh();
          }),
        ),
      if (live.operator)
        tile('Close visit', Icons.task_alt, () async {
          await live.action(
            c,
            'Close visit',
            'visit.close',
            id: id,
            version: d['version'],
          );
          await refresh();
        })
      else
        TextButton(
          onPressed: () async {
            await live.action(c, 'Leave visit', 'visit.leave', id: id);
            if (c.mounted) Navigator.pop(c);
          },
          child: const Text('Leave this visit'),
        ),
    ],
    const Text('Bill details'),
    for (final charge in records(d['rows']))
      ListTile(
        title: Text('${charge['kind']} · ${charge['itemKey']}'),
        subtitle: Text('Remaining ${money(charge['remainingMinor'])}'),
      ),
    if (d['nextCursor'] != null)
      const Text(
        'This bill has more items. Whole-bill and custom payments include the complete balance.',
      ),
  ],
);

Future<void> allocate(
  BuildContext c,
  LiveContext live, {
  int? orderId,
  int? visitId,
  List<Json> charges = const [],
}) async {
  final form = await editFields(c, 'Choose how to pay', [
    InputSpec(
      'method',
      'Payment method',
      options: live.operator ? ['paypal', 'cash'] : ['paypal'],
      value: 'paypal',
    ),
    const InputSpec(
      'split',
      'Pay',
      options: ['wholeBill', 'customAmount', 'selectedItems'],
      value: 'wholeBill',
    ),
    const InputSpec(
      'amountMinor',
      'Custom amount',
      kind: 'money',
      optional: true,
    ),
  ], submit: 'Continue');
  if (form == null || !c.mounted) return;
  if (form['split'] == 'customAmount' &&
      ((form['amountMinor'] as int?) ?? 0) <= 0) {
    await notice(c, 'Enter a custom amount greater than zero', {});
    return;
  }
  List<String>? selected;
  if (form['split'] == 'selectedItems') {
    if (charges.isEmpty) {
      await notice(c, 'Open your shared table bill to choose items', {});
      return;
    }
    final keys = <String>{};
    selected = await showDialog<List<String>>(
      context: c,
      builder: (dialog) => StatefulBuilder(
        builder: (_, state) => AlertDialog(
          title: const Text('Choose items to pay'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final ch in charges.where(
                  (v) => (v['remainingMinor'] as num) > 0,
                ))
                  CheckboxListTile(
                    title: Text(
                      '${ch['itemKey']} · ${money(ch['remainingMinor'])}',
                    ),
                    value: keys.contains(ch['itemKey']),
                    onChanged: (v) => state(() {
                      if (v == true) {
                        keys.add(ch['itemKey']);
                      } else {
                        keys.remove(ch['itemKey']);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: keys.isEmpty
                  ? null
                  : () => Navigator.pop(dialog, keys.toList()),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !c.mounted) return;
  }
  final result = await live.action(
    c,
    form['method'] == 'cash' ? 'Confirm cash received' : 'Reserve payment',
    'payment.allocate',
    typed: true,
    fixed: {
      'method': form['method'],
      'orderId': ?orderId,
      'visitId': ?visitId,
      if (form['split'] == 'customAmount') 'amountMinor': form['amountMinor'],
      'lineKeys': ?selected,
    },
  );
  if (result != null && c.mounted) {
    await push(c, checkoutPage(live, result['checkoutId']));
  }
}

Widget checkoutsPage(LiveContext live, {bool staff = false}) => rowsPage(
  live,
  'Payments and receipts',
  'checkouts',
  (c, row, _) => tile(
    'Payment #${row['id'] ?? row['checkoutId']}',
    Icons.payments,
    () => push(
      c,
      checkoutPage(
        live.restaurantId == null ? live.tenant(row['restaurantId']) : live,
        row['id'] ?? row['checkoutId'],
      ),
    ),
    subtitle:
        '${row['state']} · ${money(row['amountMinor'], '${row['currency']}')}',
  ),
  parameters: {'staff': staff},
  poll: true,
);

Widget checkoutPage(LiveContext live, int id) => DataPage(
  title: 'Payment #$id',
  poll: true,
  load: () => live.api.query('checkout', live.params({'id': id})),
  content: (c, d, refresh) => [
    AppNotice(
      title: d['state'] == 'completed'
          ? 'Payment confirmed'
          : 'Payment ${friendly('${d['state']}')}',
      message: d['state'] == 'completed'
          ? 'The backend has recorded this payment.'
          : 'PayPal approval and the confirmed receipt are separate steps. Refresh to recover a pending payment.',
    ),
    RecordSummary(d),
    if (d['state'] == 'reserved')
      AppButton(
        label: 'Continue to PayPal',
        onPressed: () => perform(c, () async {
          final created = await live.action(
            c,
            'Open PayPal checkout',
            'payment.checkout',
            id: id,
          );
          if (created?['approvalUrl'] != null) {
            await openProvider(created!['approvalUrl']);
          }
          await refresh();
        }),
      ),
    if (d['approvalUrl'] != null &&
        {'created', 'approved'}.contains(d['state']))
      AppButton(
        label: 'Open PayPal',
        onPressed: () => perform(c, () => openProvider(d['approvalUrl'])),
      ),
    if ({'created', 'approved', 'capturing', 'uncertain'}.contains(d['state']))
      AppButton(
        label: {'capturing', 'uncertain'}.contains(d['state'])
            ? 'Check again with PayPal'
            : 'I approved in PayPal · confirm payment',
        onPressed: () async {
          await live.action(
            c,
            'Confirm payment with PayPal',
            'payment.capture',
            id: id,
          );
          await refresh();
        },
      ),
    if ({'reserved', 'created', 'approved'}.contains(d['state']))
      TextButton(
        onPressed: () async {
          await live.action(
            c,
            'Cancel this checkout',
            'payment.cancel',
            id: id,
          );
          await refresh();
        },
        child: const Text('Cancel checkout'),
      ),
    if (live.manager && {'capturing', 'uncertain'}.contains(d['state']))
      OutlinedButton(
        onPressed: () async {
          await live.action(
            c,
            'Release this checkout',
            'payment.release',
            id: id,
          );
          await refresh();
        },
        child: const Text('Release checkout (manager)'),
      ),
    if (live.manager && d['captureId'] != null)
      OutlinedButton(
        onPressed: () async {
          await live.action(
            c,
            'Request refund',
            'payment.refund',
            typed: true,
            fixed: {'captureId': d['captureId'], 'orderId': ?d['orderId']},
            fields: const [
              InputSpec('amountMinor', 'Amount to refund', kind: 'money'),
              InputSpec('reason', 'Reason for refund'),
            ],
          );
          await refresh();
        },
        child: const Text('Refund payment'),
      ),
  ],
);

Widget reservationsPage(LiveContext live, {bool staff = false}) => rowsPage(
  live,
  'Reservations',
  'reservations',
  (c, r, refresh) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RecordSummary(r),
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Update reservation',
                'reservation.transition',
                id: r['id'],
                version: r['version'],
                fields: [
                  InputSpec(
                    'status',
                    'Action',
                    options: staff
                        ? [
                            'confirmed',
                            'arrived',
                            'seated',
                            'noShow',
                            'cancelled',
                            'modified',
                          ]
                        : ['confirmed', 'cancelled', 'modified'],
                  ),
                  const InputSpec(
                    'startsAt',
                    'New time for modification',
                    kind: 'date',
                    optional: true,
                  ),
                  const InputSpec(
                    'partySize',
                    'New party size',
                    kind: 'int',
                    optional: true,
                  ),
                  const InputSpec(
                    'tableId',
                    'New table for modification',
                    kind: 'int',
                    optional: true,
                  ),
                ],
              );
              await refresh();
            },
            child: const Text('Update reservation'),
          ),
        ],
      ),
    ),
  ),
  parameters: {'staff': staff},
);

Widget notificationsPage(LiveContext live) => rowsPage(
  live,
  'Notifications',
  'notifications',
  (c, n, refresh) => Card(
    child: ListTile(
      leading: Icon(
        n['read'] == true
            ? Icons.mark_email_read_outlined
            : Icons.mark_email_unread_outlined,
      ),
      title: Text(friendly('${n['kind']}')),
      subtitle: Text('${n['createdAt']}'),
      onTap: () => perform(c, () async {
        await live.api.command('notification.update', {
          'dismiss': false,
        }, resourceId: n['id']);
        final ref = obj(n['reference']);
        if (ref['roomId'] != null && ref['restaurantId'] != null && c.mounted) {
          await push(
            c,
            TableRoomPage(
              live: live.tenant(ref['restaurantId']),
              roomId: ref['roomId'],
            ),
          );
        } else if (ref['orderId'] != null &&
            ref['restaurantId'] != null &&
            c.mounted) {
          await push(
            c,
            orderPage(live.tenant(ref['restaurantId']), ref['orderId']),
          );
        }
        await refresh();
      }),
      trailing: IconButton(
        tooltip: 'Dismiss',
        icon: const Icon(Icons.close),
        onPressed: () => perform(c, () async {
          await live.api.command('notification.update', {
            'dismiss': true,
          }, resourceId: n['id']);
          await refresh();
        }),
      ),
    ),
  ),
  poll: true,
);

Widget supportHome(LiveContext live, {bool staff = false}) => rowsPage(
  live,
  'Conversations',
  'support.inbox',
  (c, r, _) => tile(
    '${r['subject']}',
    Icons.chat_bubble_outline,
    () => push(
      c,
      conversationPage(
        live.restaurantId == null && r['restaurantId'] != null
            ? live.tenant(r['restaurantId'])
            : live,
        r['id'],
      ),
    ),
    subtitle: '${r['status']}',
  ),
  parameters: {'staff': staff},
  before: (c, d, refresh) => [
    AppButton(
      label: 'Start a conversation',
      onPressed: () async {
        await openSupport(c, live);
        await refresh();
      },
    ),
  ],
);
Future<void> openSupport(
  BuildContext c,
  LiveContext live, {
  int? orderId,
}) async {
  final result = await live.action(
    c,
    'Contact support',
    'support.open',
    fixed: {'orderId': ?orderId},
    fields: const [
      InputSpec('subject', 'Subject'),
      InputSpec('text', 'How can we help?', kind: 'long'),
      InputSpec('abuse', 'Report abuse', kind: 'bool', value: false),
    ],
  );
  if (result != null && c.mounted) {
    await push(c, conversationPage(live, result['id']));
  }
}

Widget conversationPage(LiveContext live, int id) => rowsPage(
  live,
  'Conversation',
  'support',
  (c, m, _) => Card(
    child: ListTile(
      title: Text('${m['text']}'),
      subtitle: Text(
        '${m['own'] == true ? 'You' : 'Support'} · ${m['createdAt']}',
      ),
      trailing: m['mediaId'] == null
          ? null
          : IconButton(
              tooltip: 'Attachment',
              icon: const Icon(Icons.attachment),
              onPressed: () => showFile(c, live, m['mediaId']),
            ),
    ),
  ),
  parameters: {'id': id},
  poll: true,
  before: (c, d, refresh) => [
    Text('${d['subject']}'),
    AppButton(
      label: 'Write a message',
      onPressed: () async {
        await live.action(
          c,
          'Reply',
          'support.message',
          id: id,
          fields: const [
            InputSpec('text', 'Message', kind: 'long'),
            InputSpec(
              'mediaId',
              'Attachment reference',
              kind: 'int',
              optional: true,
            ),
          ],
        );
        await refresh();
      },
    ),
    OutlinedButton(
      onPressed: () async {
        await uploadFile(c, live, purpose: 'support');
      },
      child: const Text('Upload attachment'),
    ),
    TextButton(
      onPressed: () async {
        await live.action(
          c,
          'Conversation options',
          'support.transition',
          id: id,
          version: d['version'],
          fields: const [
            InputSpec('status', 'Status', options: ['open', 'closed']),
            InputSpec(
              'escalate',
              'Escalate to Raysto',
              kind: 'bool',
              value: false,
            ),
          ],
        );
        await refresh();
      },
      child: const Text('Close or escalate'),
    ),
  ],
);

Widget accountHome(
  LiveContext live,
  Future<void> Function() signOut,
) => DataPage(
  title: 'Your account',
  load: () => live.api.query('me'),
  content: (c, d, refresh) => [
    if (d['platformAdmin'] == true)
      tile(
        'Platform administration',
        Icons.admin_panel_settings_outlined,
        () => push(c, administrationPage(live)),
      ),
    if (d['guest'] == true)
      const Text(
        'Save your guest activity, then sign in and choose “Link saved guest activity” within 10 minutes.',
      ),
    if (d['guest'] == true)
      AppButton(
        label: 'Save guest activity to an account',
        onPressed: () => perform(c, () async {
          await live.runtime.saveGuestClaim();
          await signOut();
        }),
      ),
    if (d['guest'] != true)
      TextButton(
        onPressed: () => perform(c, () async {
          await live.runtime.claimGuestActivity();
          if (c.mounted) await notice(c, 'Guest activity linked', {});
        }),
        child: const Text('Link saved guest activity'),
      ),
    RaystoStoryHeader(
      eyebrow: 'A place for you',
      title:
          '${obj(d['profile'])['displayName'] ?? live.runtime.firebase.currentUser?.email ?? 'Your account'}',
      message: 'Your details, your favorites, your way.',
      compact: true,
      scene: RaystoScene.sprout,
    ),
    tile('Profile, addresses and preferences', Icons.person_outline, () async {
      await live.action(
        c,
        'Your profile',
        'identity.profile',
        fields: profileFields,
        initial: obj(d['profile']),
        version: d['version'],
      );
      await refresh();
    }),
    if (d['guest'] != true)
      tile(
        'Account security',
        Icons.security,
        () => push(c, SecurityPage(runtime: live.runtime)),
      ),
    if (d['guest'] != true)
      tile(
        'Enable order notifications',
        Icons.notifications_active_outlined,
        () => perform(c, () async {
          await live.runtime.enableNotifications();
          if (c.mounted) await notice(c, 'Notifications enabled', {});
        }),
      ),
    if (d['guest'] != true)
      tile('Accept team invitation', Icons.group_add_outlined, () async {
        final invite = await editFields(c, 'Restaurant invitation', const [
          InputSpec('restaurantId', 'Restaurant reference', kind: 'int'),
          InputSpec('token', 'Invitation code'),
        ]);
        if (invite != null && c.mounted) {
          await live
              .tenant(invite['restaurantId'])
              .action(
                c,
                'Join restaurant team',
                'team.accept',
                fixed: {'token': invite['token']},
              );
        }
        await refresh();
      }),
    tile(
      'Export my information',
      Icons.download_outlined,
      () => live.action(
        c,
        'Request account export',
        'identity.privacy',
        fixed: {'action': 'export'},
      ),
    ),
    tile(
      'My exports',
      Icons.folder_outlined,
      () => push(
        c,
        rowsPage(
          live,
          'Account exports',
          'exports',
          (c, r, _) => tile(
            'Export #${r['id']}',
            Icons.file_download_outlined,
            () => showFile(c, live, r['id']),
            subtitle: 'Expires ${r['expiresAt']}',
          ),
        ),
      ),
    ),
    tile(
      'Sign out other sessions',
      Icons.phonelink_lock,
      () => perform(c, () async {
        await live.action(c, 'Revoke sessions', 'identity.revokeSessions');
        await signOut();
      }),
    ),
    tile(
      'Test PayPal Sandbox',
      Icons.science_outlined,
      () => push(c, SandboxTestScreen(runtime: live.runtime)),
      subtitle: 'Separate test checkout with PayPal Sandbox',
    ),
    TextButton(
      onPressed: () async {
        final result = await live.action(
          c,
          'Request account deletion',
          'identity.privacy',
          fixed: {'action': 'delete'},
        );
        if (result != null) await signOut();
      },
      child: const Text('Delete account'),
    ),
    OutlinedButton(onPressed: signOut, child: const Text('Sign out')),
  ],
);
