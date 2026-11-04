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
  content: (c, d, refresh) {
    final due =
        d['paymentStatus'] != 'paid' &&
        !{'cancelled', 'rejected'}.contains(d['status']);
    final staff = live.operator || live.role == 'kitchen';
    // One primary action: paying first, then the staff's next step, then
    // talking to the restaurant. The others stay available, quieter.
    return [
      AppSectionTitle(title: c.tr('Your order')),
      orderCard(c, d),
      if (due)
        AppButton(
          label: 'Pay outstanding balance',
          icon: Icons.payments_outlined,
          onPressed: () => allocate(
            c,
            live,
            orderId: d['visitId'] == null ? id : null,
            visitId: d['visitId'],
            totalMinor: d['visitId'] == null
                ? (d['totalMinor'] as num?)?.toInt()
                : null,
            currency: '${d['currency'] ?? ''}',
          ),
        ),
      if (!due &&
          live.role == 'customer' &&
          const {'paid', 'partiallyRefunded'}.contains(d['paymentStatus']))
        complaintTile(c, live, id, obj(d['complaint']), refresh),
      if (staff)
        AppButton(
          label: 'Update order',
          secondary: due,
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
      AppButton(
        label: 'Open conversation',
        icon: Icons.forum_outlined,
        secondary: due || staff,
        onPressed: () => push(c, TableRoomPage(live: live, orderId: id)),
      ),
      if (d['visitId'] != null)
        tile(
          'Shared table bill',
          Icons.groups_outlined,
          () => push(c, visitPage(live, d['visitId'])),
        ),
      if (d['fulfillment'] == 'delivery')
        tile(
          'Delivery tracking',
          Icons.delivery_dining,
          // 0.16 (S2): the live map, the estimate and the handover code.
          () => push(c, trackingMapPage(live, orderId: id)),
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
      if (records(d['timeline']).isNotEmpty)
        AppDisclosure(
          title: c.tr('Timeline'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in records(d['timeline']))
                Text('${friendly('${e['kind']}')} · ${e['at']}'),
            ],
          ),
        ),
    ];
  },
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

/// Asks the diner for a tip on [amountMinor] before PayPal. Returns the tip
/// in minor units, 0 when they chose none, or null when they went back.
Future<int?> chooseTip(BuildContext c, int amountMinor, String currency) =>
    showModalBottomSheet<int>(
      context: c,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        var tip = 0;
        return StatefulBuilder(
          builder: (sheet, setState) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                20 + MediaQuery.viewInsetsOf(sheet).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TipChooser(
                    amountMinor: amountMinor,
                    currency: currency,
                    tipMinor: tip,
                    onChanged: (v) => setState(() => tip = v),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: c.tr('Continue to PayPal'),
                    icon: Icons.lock_outline,
                    onPressed: () => Navigator.pop(sheet, tip),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

/// "Something was wrong?" on a paid order: the diner says what in a sentence,
/// the café's complaints agent reads the ticket and the PayPal payment, and
/// the manager decides on a refund. Once sent, the tile shows where it stands.
Widget complaintTile(
  BuildContext c,
  LiveContext live,
  int orderId,
  Json complaint,
  Future<void> Function() refresh,
) {
  if (complaint['status'] != null) {
    final refunded = (complaint['refundedMinor'] as num? ?? 0).toInt();
    final status = '${complaint['status']}';
    return AppNotice(
      title: c.tr(switch (status) {
        'refunded' => 'Refunded',
        'declined' => 'The café looked into it',
        _ => 'Sent. The café will reply.',
      }),
      message: refunded > 0
          ? '${c.tr('Refunded')} ${money(refunded, '${complaint['currency'] ?? ''}')}'
          : c.tr('Your message about this order has reached the café.'),
      icon: status == 'refunded' ? Icons.undo : Icons.mark_email_read_outlined,
    );
  }
  return tile(
    c.tr('Something was wrong?'),
    Icons.report_problem_outlined,
    () async {
      final sent = await openComplaint(c, live, orderId);
      if (sent) await refresh();
    },
    subtitle: c.tr('Tell the café in a sentence; a manager decides on a refund.'),
  );
}

/// The complaint sheet. Unfinished text is protected: swiping or tapping
/// away asks before discarding it. Returns true once sent.
Future<bool> openComplaint(BuildContext c, LiveContext live, int orderId) async {
  final sent = await showModalBottomSheet<bool>(
    context: c,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    showDragHandle: true,
    builder: (_) => ComplaintSheet(live: live, orderId: orderId),
  );
  return sent == true;
}

class ComplaintSheet extends StatefulWidget {
  const ComplaintSheet({super.key, required this.live, required this.orderId});
  final LiveContext live;
  final int orderId;
  @override
  State<ComplaintSheet> createState() => _ComplaintSheetState();
}

class _ComplaintSheetState extends State<ComplaintSheet> {
  final controller = TextEditingController();
  bool busy = false, sent = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Whether to stay: unsent text asks first.
  Future<bool> keep() async {
    if (controller.text.trim().isEmpty || sent) return false;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(context.tr('Discard your message?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(context.tr('Keep writing')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(context.tr('Discard')),
          ),
        ],
      ),
    );
    return discard != true;
  }

  Future<void> leave() async {
    if (!await keep() && mounted) Navigator.pop(context, sent);
  }

  Future<void> send() async {
    setState(() => busy = true);
    await perform(context, () async {
      await widget.live.api.submit(
        PendingCommand(
          'complaint.open',
          widget.live.params({
            'orderId': widget.orderId,
            'text': controller.text.trim(),
          }),
        ),
      );
      sent = true;
    });
    if (!mounted) return;
    setState(() => busy = false);
    if (sent) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            20 + MediaQuery.viewInsetsOf(c).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                c.tr('Something was wrong?'),
                style: Theme.of(c).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                c.tr(
                  'Say what happened. The café checks your order and its PayPal payment, and a manager replies.',
                ),
                style: Theme.of(c).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: c.tr('What went wrong'),
                controller: controller,
                maxLines: 3,
                hint: c.tr('The croissant was missing from my bag'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: c.tr('Send to the café'),
                icon: Icons.send_outlined,
                busy: busy,
                onPressed: busy || controller.text.trim().isEmpty ? null : send,
              ),
              TextButton(
                onPressed: busy ? null : leave,
                child: Text(c.tr('Not now')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> allocate(
  BuildContext c,
  LiveContext live, {
  int? orderId,
  int? visitId,
  List<Json> charges = const [],
  int? totalMinor,
  String currency = '',
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
  // A diner paying a whole bill with PayPal may add a tip; staff and
  // partial payments go straight on.
  int? tipMinor;
  if (form['method'] == 'paypal' &&
      form['split'] == 'wholeBill' &&
      !live.operator &&
      totalMinor != null &&
      totalMinor > 0) {
    tipMinor = await chooseTip(c, totalMinor, currency);
    if (tipMinor == null || !c.mounted) return;
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
      if ((tipMinor ?? 0) > 0) 'tipMinor': tipMinor,
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
  content: (c, d, refresh) {
    final canOpen =
        d['approvalUrl'] != null &&
        {'created', 'approved'}.contains(d['state']);
    final canConfirm = {
      'created',
      'approved',
      'capturing',
      'uncertain',
    }.contains(d['state']);
    // One primary step at a time: reach PayPal, approve there, then confirm.
    // Once PayPal reports the approval, confirming is the step that matters.
    final openFirst = canOpen && d['state'] == 'created';
    final open = AppButton(
      label: 'Open PayPal',
      icon: Icons.open_in_new,
      secondary: !openFirst,
      onPressed: () => perform(c, () => openProvider(d['approvalUrl'])),
    );
    return [
      AppSectionTitle(title: c.tr('Payment')),
      checkoutCard(
        c,
        d,
        d['state'] == 'completed'
            ? 'Payment confirmed'
            : 'Payment ${friendly('${d['state']}')}',
        d['state'] == 'completed' ? 'The backend has recorded this payment.' : 'PayPal approval and the confirmed receipt are separate steps. Refresh to recover a pending payment.',
      ),
      if (d['state'] == 'reserved')
        AppButton(
          label: 'Continue to PayPal',
          icon: Icons.lock_outline,
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
      if (canOpen && openFirst) open,
      if (canConfirm)
        AppButton(
          label: {'capturing', 'uncertain'}.contains(d['state'])
              ? 'Check again with PayPal'
              : 'I approved in PayPal · confirm payment',
          secondary: openFirst,
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
      if (canOpen && !openFirst) open,
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
    ];
  },
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
        } else if (ref['deliveryId'] != null &&
            ref['restaurantId'] != null &&
            '${n['kind']}'.startsWith('delivery.') &&
            c.mounted) {
          // 0.16 (S2): an offer or a job opens the courier's deliveries.
          await push(
            c,
            CourierHome(
              live: live.tenant(ref['restaurantId'], role: 'courier'),
            ),
          );
        } else if (n['kind'] == 'delivery.assigned' &&
            ref['orderId'] != null &&
            ref['restaurantId'] != null &&
            c.mounted) {
          // A diner's driver is on the way: open the tracking map.
          await push(
            c,
            trackingMapPage(
              live.tenant(ref['restaurantId']),
              orderId: ref['orderId'] as int,
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
