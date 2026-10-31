part of 'connected_app.dart';

/// The pass: new tickets, what is cooking and what is ready, oldest first.
class KitchenBoard extends StatefulWidget {
  const KitchenBoard({super.key, required this.live});
  final LiveContext live;
  @override
  State<KitchenBoard> createState() => _KitchenBoardState();
}

class _KitchenBoardState extends State<KitchenBoard> {
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    // Ages move on even when nothing else changes.
    ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    feed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    return DataPage(
      title: context.tr('Kitchen'),
      poll: true,
      trigger: feed,
      load: () => live.api.query('kitchen', live.params({'limit': 100})),
      content: (c, d, refresh) {
        final orders = records(d['rows']).map(StaffOrder.new).toList();
        List<StaffOrder> at(Set<String> states) =>
            orders.where((o) => states.contains(o.status)).toList();
        Widget column(String title, List<StaffOrder> rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionTitle(title: '${c.tr(title)} · ${rows.length}'),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              Text(
                c.tr('Nothing here right now.'),
                style: Theme.of(c).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(c).colorScheme.onSurfaceVariant,
                ),
              ),
            for (final o in rows) ...[
              KitchenTicket(
                key: ValueKey(o.id),
                live: live,
                order: o,
                refresh: refresh,
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
        final columns = [
          column('New', at({'submitted'})),
          column('In progress', at({'accepted', 'preparing'})),
          column('Ready', at({'ready'})),
        ];
        // A tablet on the pass shows the three stages side by side.
        return [
          LayoutBuilder(
            builder: (c, box) => box.maxWidth >= 860
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, col) in columns.indexed) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: col),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, col) in columns.indexed) ...[
                        if (i > 0) const SizedBox(height: 16),
                        col,
                      ],
                    ],
                  ),
          ),
        ];
      },
    );
  }
}

class KitchenTicket extends StatelessWidget {
  const KitchenTicket({
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
    final theme = Theme.of(context);
    final tickets = {for (final t in o.tickets) '${t['lineKey']}': t};
    final next = o.next.where((n) => n != 'rejected').firstOrNull;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(o.title, style: theme.textTheme.titleLarge),
              AppPill(label: context.tr(o.channel)),
              if (o.customerLabel != null) AppPill(label: o.customerLabel!),
              agePill(context, o.ageMinutes()),
            ],
          ),
          const SizedBox(height: 6),
          for (final line in o.lines)
            Builder(
              builder: (c) {
                final t = tickets['${line['lineKey']}'];
                final done =
                    t != null &&
                    (t['completedQuantity'] as num) >= (t['quantity'] as num);
                final details = [
                  if (optionNames(line).isNotEmpty) optionNames(line),
                  if ('${line['note'] ?? ''}'.isNotEmpty) '${line['note']}',
                ];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${line['quantity']}× ${line['name']}',
                    style: done
                        ? theme.textTheme.bodyLarge!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : theme.textTheme.bodyLarge,
                  ),
                  subtitle: details.isEmpty ? null : Text(details.join(' · ')),
                  trailing: t == null || o.status != 'preparing'
                      ? null
                      : IconButton.filledTonal(
                          tooltip: c.tr(done ? 'Done' : 'Mark line done'),
                          onPressed: done
                              ? null
                              : () => perform(c, () async {
                                  await live.api.command(
                                    'kitchen.progress',
                                    {
                                      'lineKey': t['lineKey'],
                                      'completedQuantity': t['quantity'],
                                    },
                                    restaurantId: live.restaurantId,
                                    resourceId: o.id,
                                    version: t['version'] as int?,
                                  );
                                  await refresh();
                                }),
                          icon: const Icon(Icons.check),
                        ),
                );
              },
            ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (o.status == 'submitted' && canAdvance(live, o, 'rejected'))
                TextButton(
                  onPressed: () => rejectOrder(context, live, o, refresh),
                  child: Text(context.tr('Reject')),
                ),
              if (next != null && canAdvance(live, o, next))
                AppButton(
                  expanded: false,
                  label: context.tr(actionLabel(next)),
                  onPressed: () => next == 'ready'
                      ? markReady(context)
                      : advanceOrder(context, live, o, next, refresh),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Ready" ticks off any lines still open, then moves the order on, so the
  /// cook never meets a refusal for lines they forgot to tick.
  Future<void> markReady(BuildContext context) => perform(context, () async {
    for (final t in order.tickets) {
      if ((t['completedQuantity'] as num) >= (t['quantity'] as num)) continue;
      await live.api.command(
        'kitchen.progress',
        {'lineKey': t['lineKey'], 'completedQuantity': t['quantity']},
        restaurantId: live.restaurantId,
        resourceId: order.id,
        version: t['version'] as int?,
      );
    }
    await live.api.command(
      'order.transition',
      {'status': 'ready'},
      restaurantId: live.restaurantId,
      resourceId: order.id,
      version: order.version,
    );
    await refresh();
  });
}
