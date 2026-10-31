part of 'connected_app.dart';

/// Every order of the restaurant, newest first, with one-tap next steps.
class OrdersBoard extends StatefulWidget {
  const OrdersBoard({super.key, required this.live});
  final LiveContext live;
  @override
  State<OrdersBoard> createState() => _OrdersBoardState();
}

class _OrdersBoardState extends State<OrdersBoard> {
  String query = '', status = 'Active', channel = 'All', payment = 'All';
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  final search = TextEditingController();

  @override
  void dispose() {
    feed.dispose();
    search.dispose();
    super.dispose();
  }

  /// A short number is looked up on the server (ticket number or pickup
  /// code); anything else filters the loaded page locally.
  String? get code =>
      RegExp(r'^\d{1,8}$').hasMatch(query.trim()) ? query.trim() : null;

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    return DataPage(
      title: context.tr('Orders'),
      poll: true,
      trigger: feed,
      load: () => live.api.query(
        'orders',
        live.params({
          'staff': true,
          'order': 'desc',
          'limit': 50,
          if (code != null) 'q': code,
        }),
      ),
      content: (c, d, refresh) {
        final orders = filterOrders(
          records(d['rows']).map(StaffOrder.new).toList(),
          query: code == null ? query : '',
          status: code == null ? status : 'All',
          channel: channel,
          payment: payment,
        );
        return [
          TextField(
            controller: search,
            decoration: InputDecoration(
              labelText: c.tr('Search by number, code or item'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: c.tr('Clear'),
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        search.clear();
                        setState(() => query = '');
                        feed.ping();
                      },
                    ),
            ),
            onChanged: (v) {
              final lookup = code;
              setState(() => query = v);
              if (lookup != code) feed.ping();
            },
          ),
          staffChips(c, const [
            'Active',
            'New',
            'Preparing',
            'Ready',
            'Done',
            'All',
          ], status, (v) => setState(() => status = v)),
          staffChips(c, const [
            'All',
            'Counter',
            'Pickup',
            'Dine-in',
            'Delivery',
          ], channel, (v) => setState(() => channel = v)),
          staffChips(c, const [
            'All',
            'Unpaid',
            'Paid',
          ], payment, (v) => setState(() => payment = v)),
          if (orders.isEmpty)
            RaystoEmptyState(
              title: c.tr('No matching orders'),
              message: c.tr('Change the filters, or wait for the next order.'),
              scene: RaystoScene.receipt,
            ),
          // A tablet shows the cards as a grid; a phone as a list.
          LayoutBuilder(
            builder: (c, box) {
              final columns = box.maxWidth >= 1100
                  ? 3
                  : box.maxWidth >= 700
                  ? 2
                  : 1;
              final width = (box.maxWidth - 16 * (columns - 1)) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final o in orders)
                    SizedBox(
                      width: width,
                      child: OrderCard(
                        key: ValueKey(o.id),
                        live: live,
                        order: o,
                        refresh: refresh,
                      ),
                    ),
                ],
              );
            },
          ),
        ];
      },
    );
  }
}

Future<void> advanceOrder(
  BuildContext c,
  LiveContext live,
  StaffOrder o,
  String next,
  Future<void> Function() refresh, {
  String? reason,
}) async {
  String? code;
  // An app pickup is handed over against the code on the customer's phone.
  if (next == 'collected' && o.origin != 'counter' && o.fulfillment == 'pickup') {
    code = await askPickupCode(c);
    if (code == null || !c.mounted) return;
  }
  await perform(c, () async {
    await live.api.command(
      'order.transition',
      {'status': next, 'reason': ?reason, 'code': ?code},
      restaurantId: live.restaurantId,
      resourceId: o.id,
      version: o.version,
    );
    await refresh();
  });
}

Future<String?> askPickupCode(BuildContext context) async {
  final field = TextEditingController();
  try {
    return await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.tr('Pickup code')),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: c.tr('Code on the customer\'s phone'),
            counterText: '',
          ),
          onSubmitted: (v) => Navigator.pop(c, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(c.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, field.text.trim()),
            child: Text(c.tr('Hand over')),
          ),
        ],
      ),
    );
  } finally {
    field.dispose();
  }
}

Future<void> rejectOrder(
  BuildContext c,
  LiveContext live,
  StaffOrder o,
  Future<void> Function() refresh,
) async {
  final form = await editFields(c, 'Reject this order', const [
    InputSpec('reason', 'Reason for the customer'),
  ], submit: 'Reject order');
  if (form == null || !c.mounted) return;
  await advanceOrder(c, live, o, 'rejected', refresh, reason: form['reason']);
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.live,
    required this.order,
    required this.refresh,
  });
  final LiveContext live;
  final StaffOrder order;
  final Future<void> Function() refresh;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final next = o.next.where((n) => n != 'rejected').firstOrNull;
    final theme = Theme.of(context);
    return AppPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => push(context, OrderDetailPage(live: live, id: o.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.panel),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(o.title, style: theme.textTheme.titleLarge),
                  AppPill(label: context.tr(o.channel)),
                  AppPill(label: friendly(o.status)),
                  AppPill(
                    label: context.tr(o.paid ? 'Paid' : 'Unpaid'),
                    icon: o.paid ? Icons.check_circle_outline : Icons.schedule,
                    color: o.paid
                        ? theme.extension<AppStatusColors>()?.success
                        : null,
                  ),
                  if (o.open) agePill(context, o.ageMinutes()),
                ],
              ),
              const SizedBox(height: 8),
              Text(o.summary, style: theme.textTheme.bodyMedium),
              if (o.customerLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  o.customerLabel!,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (o.pickupCode != null && o.status == 'ready') ...[
                const SizedBox(height: 4),
                Text(
                  '${context.tr('Pickup code')} ${o.pickupCode}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    money(o.totalMinor, o.currency),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (next != null && canAdvance(live, o, next))
                    AppButton(
                      expanded: false,
                      label: context.tr(actionLabel(next)),
                      onPressed: () =>
                          advanceOrder(context, live, o, next, refresh),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One order in full: lines, money, code, timeline and every allowed action.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.live, required this.id});
  final LiveContext live;
  final int id;

  @override
  Widget build(BuildContext context) => DataPage(
    title: context.tr('Order'),
    poll: true,
    load: () => live.api.query('order', live.params({'id': id})),
    content: (c, d, refresh) {
      final o = StaffOrder(d);
      final theme = Theme.of(c);
      final cash = o.open && !o.paid && (live.manager || live.can('counter'));
      return [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(o.title, style: theme.textTheme.headlineSmall),
            AppPill(label: c.tr(o.channel)),
            AppPill(label: friendly(o.status)),
            AppPill(label: friendly(o.paymentStatus)),
            if (o.open) agePill(c, o.ageMinutes()),
          ],
        ),
        if (o.customerLabel != null) Text(o.customerLabel!),
        if (o.pickupCode != null)
          AppNotice(
            title: '${c.tr('Pickup code')} ${o.pickupCode}',
            message: c.tr('The customer gives this code at collection.'),
            icon: Icons.confirmation_number_outlined,
          ),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final line in o.lines)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${line['quantity']}× ${line['name']}'),
                  subtitle:
                      optionNames(line).isEmpty &&
                          '${line['note'] ?? ''}'.isEmpty
                      ? null
                      : Text(
                          [
                            if (optionNames(line).isNotEmpty) optionNames(line),
                            if ('${line['note'] ?? ''}'.isNotEmpty)
                              '${line['note']}',
                          ].join(' · '),
                        ),
                  trailing: line['unitPriceMinor'] == null
                      ? null
                      : Text(
                          money(
                            (line['unitPriceMinor'] as num) *
                                (line['quantity'] as num),
                            o.currency,
                          ),
                        ),
                ),
              const Divider(),
              Row(
                children: [
                  Expanded(child: Text(c.tr('Total'))),
                  Text(
                    money(o.totalMinor, o.currency),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final next in o.next)
          if (canAdvance(live, o, next))
            next == 'rejected'
                ? OutlinedButton(
                    onPressed: () => rejectOrder(c, live, o, refresh),
                    child: Text(c.tr('Reject')),
                  )
                : AppButton(
                    label: c.tr(actionLabel(next)),
                    onPressed: () => advanceOrder(c, live, o, next, refresh),
                  ),
        if (cash)
          AppButton(
            label: c.tr('Record cash'),
            icon: Icons.payments_outlined,
            secondary: true,
            onPressed: () async {
              final ok =
                  await showDialog<bool>(
                    context: c,
                    builder: (d) => AlertDialog(
                      title: Text(d.tr('Collect cash')),
                      content: Text(
                        '${d.tr('Take')} ${money(o.totalMinor, o.currency)} ${d.tr('from the customer, then confirm.')}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(d, false),
                          child: Text(d.tr('Cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(d, true),
                          child: Text(d.tr('Cash received')),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!ok || !c.mounted) return;
              await perform(c, () async {
                await live.api.submit(
                  PendingCommand(
                    'payment.allocate',
                    live.params({'orderId': o.id, 'method': 'cash'}),
                  ),
                );
                await refresh();
              });
            },
          ),
        if (o.visitId != null)
          tile(
            c.tr('Table conversation'),
            Icons.forum_outlined,
            () => push(c, TableRoomPage(live: live, orderId: o.id)),
          ),
        if (live.manager)
          tile(
            c.tr('Payments and refunds'),
            Icons.receipt_outlined,
            () => push(c, checkoutsPage(live, staff: true)),
          ),
        if (live.manager && o.open)
          TextButton(
            onPressed: () async {
              final form = await editFields(c, 'Cancel this order', const [
                InputSpec('reason', 'Reason'),
              ], submit: 'Cancel order');
              if (form == null || !c.mounted) return;
              await perform(c, () async {
                await live.api.command(
                  'order.cancel',
                  {'reason': form['reason'], 'approve': true},
                  restaurantId: live.restaurantId,
                  resourceId: o.id,
                  version: o.version,
                );
                await refresh();
              });
            },
            child: Text(c.tr('Cancel order')),
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
}
