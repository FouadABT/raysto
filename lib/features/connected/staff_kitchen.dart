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

  /// Drags on a tablet: a ticket moves at once and the step is sent after
  /// the Undo window, so nothing on the server ever needs taking back.
  late final PendingMoves moves = PendingMoves(
    send: (id, status, version) => widget.live.api.command(
      'order.transition',
      {'status': status},
      restaurantId: widget.live.restaurantId,
      resourceId: id,
      version: version,
    ),
    onSent: (_) => feed.ping(),
    onRefused: (move, error) {
      feed.ping();
      if (!mounted) return;
      showRaystoSnackBar(
        context,
        error is PlatformFailure
            ? error.message
            : context.tr('The order could not be moved. Please try again.'),
      );
    },
  )..addListener(_moved);

  void _moved() {
    if (mounted) setState(() {});
  }

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
    moves
      ..removeListener(_moved)
      ..dispose();
    feed.dispose();
    super.dispose();
  }

  /// Moves [order] to [lane] when that lane holds its next step.
  void drop(BuildContext c, StaffOrder order, Set<String> lane) {
    final rule = allowedNext(order, widget.live, kitchen: true);
    if (!rule.allowed || !lane.contains(rule.to)) return;
    moves.schedule(order, rule.to!);
    showRaystoSnackBar(
      c,
      '${order.title} · ${statusLabel(c, rule.to!)}',
      undoLabel: c.tr('Undo'),
      onUndo: () => moves.undo(order.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    return DataPage(
      title: context.tr('Kitchen'),
      large: true,
      poll: true,
      trigger: feed,
      load: () => live.api.query('kitchen', live.params({'limit': 100})),
      content: (c, d, refresh) {
        final orders = moves.overlay(
          records(d['rows']).map(StaffOrder.new).toList(),
        );
        List<StaffOrder> at(Set<String> states) =>
            orders.where((o) => states.contains(o.status)).toList();
        // Each stage is a lane: its color, its count, its tickets.
        Widget column(
          String title,
          String state,
          Set<String> lane,
          List<StaffOrder> rows, {
          required bool wide,
        }) => DragTarget<StaffOrder>(
          onWillAcceptWithDetails: (details) {
            final rule = allowedNext(details.data, live, kitchen: true);
            return rule.allowed && lane.contains(rule.to);
          },
          onAcceptWithDetails: (details) => drop(c, details.data, lane),
          builder: (c, accepted, rejected) {
            final scheme = Theme.of(c).colorScheme;
            // A refused lane says why in words, not only by colour.
            final refusal = rejected.whereType<StaffOrder>().firstOrNull;
            final reason = refusal == null || lane.contains(refusal.status)
                ? null
                : allowedNext(refusal, live, kitchen: true).reason ??
                      'Not the next step';
            return AnimatedContainer(
              duration: AppMotion.duration(c, AppMotion.feedback),
              curve: AppMotion.effects,
              decoration: BoxDecoration(
                color: accepted.isNotEmpty
                    ? Color.alphaBlend(
                        scheme.primary.withValues(alpha: AppStateLayer.dragged),
                        scheme.surfaceContainerLow,
                      )
                    : scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppShape.extraLarge),
                border: Border.all(
                  color: accepted.isNotEmpty
                      ? scheme.primary
                      : scheme.surfaceContainerLow,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: stateAccent(state),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.forest.withValues(alpha: 0.15),
                              ),
                            ),
                            child: const SizedBox.square(dimension: 12),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${c.tr(title)} · ${rows.length}',
                              style: AppType.style(
                                19,
                                weight: FontWeight.w700,
                                color: Theme.of(c).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reason != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Text(
                          c.tr(reason),
                          style: Theme.of(c).textTheme.bodyMedium!.copyWith(
                            color: scheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (rows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 18,
                        ),
                        child: Text(
                          c.tr('Nothing here right now.'),
                          style: Theme.of(c).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(c).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    for (final o in rows) ...[
                      wide
                          ? DraggableTicket(
                              key: ValueKey(o.id),
                              order: o,
                              child: KitchenTicket(
                                live: live,
                                order: o,
                                refresh: refresh,
                              ),
                            )
                          : KitchenTicket(
                              key: ValueKey(o.id),
                              live: live,
                              order: o,
                              refresh: refresh,
                            ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            );
          },
        );
        const fresh = {'submitted'}, cooking = {'accepted', 'preparing'};
        const done = {'ready'};
        List<Widget> columns({required bool wide}) => [
          column('New', 'submitted', fresh, at(fresh), wide: wide),
          column('In progress', 'preparing', cooking, at(cooking), wide: wide),
          column('Ready', 'ready', done, at(done), wide: wide),
        ];
        // A tablet on the pass shows the three stages side by side, and a
        // ticket can be carried from one to the next.
        return [
          LayoutBuilder(
            builder: (c, box) => box.maxWidth >= 860
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, col) in columns(wide: true).indexed) ...[
                        if (i > 0) const SizedBox(width: 14),
                        Expanded(child: col),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, col) in columns(wide: false).indexed) ...[
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
    final minutes = o.ageMinutes();
    final status = theme.extension<AppStatusColors>();
    // Fresh, then warning at 8 minutes, then late at 15: seen across a kitchen.
    final (band, onBand) = minutes >= 15
        ? (theme.colorScheme.errorContainer, theme.colorScheme.onErrorContainer)
        : minutes >= 8
        ? (
            status?.warning ?? AppColors.peach,
            status?.onWarning ?? AppColors.ink,
          )
        : (AppColors.mint, AppColors.ink);
    return AppPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: band,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 16, 12),
              // Wraps at large text sizes rather than squeezing the number.
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    o.title,
                    style: AppType.style(
                      26,
                      weight: FontWeight.w700,
                      color: onBand,
                      height: 1.1,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 18, color: onBand),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          ageLabel(context, minutes),
                          style:
                              AppType.style(
                                17,
                                weight: FontWeight.w700,
                                color: onBand,
                              ).copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppPill(label: context.tr(o.channel), icon: channelIcon(o)),
                    if (o.customerLabel != null)
                      AppPill(label: o.customerLabel!),
                  ],
                ),
                const SizedBox(height: 4),
                for (final line in o.lines)
                  Builder(
                    builder: (c) {
                      final t = tickets['${line['lineKey']}'];
                      final done =
                          t != null &&
                          (t['completedQuantity'] as num) >=
                              (t['quantity'] as num);
                      final details = [
                        if (optionNames(line).isNotEmpty) optionNames(line),
                        if ('${line['note'] ?? ''}'.isNotEmpty)
                          '${line['note']}',
                      ];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        minVerticalPadding: 6,
                        title: Text(
                          '${line['quantity']}× ${line['name']}',
                          style: done
                              ? theme.textTheme.titleMedium!.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : theme.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                        ),
                        subtitle: details.isEmpty
                            ? null
                            : Text(
                                details.join(' · '),
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (c, box) {
                    final reject =
                        o.status == 'submitted' &&
                            canAdvance(live, o, 'rejected')
                        ? TextButton(
                            onPressed: () =>
                                rejectOrder(context, live, o, refresh),
                            child: Text(context.tr('Reject')),
                          )
                        : null;
                    final advance = next != null && canAdvance(live, o, next)
                        ? AppButton(
                            label: context.tr(actionLabel(next)),
                            icon: next == 'ready'
                                ? Icons.notifications_active_outlined
                                : next == 'collected'
                                ? Icons.shopping_bag_outlined
                                : Icons.local_fire_department_outlined,
                            onPressed: () => next == 'ready'
                                ? markReady(context)
                                : advanceOrder(context, live, o, next, refresh),
                          )
                        : null;
                    // Narrow tickets stack the actions; the next step first.
                    if (box.maxWidth < 300) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [?advance, ?reject],
                      );
                    }
                    return Row(
                      children: [
                        if (reject != null) ...[
                          reject,
                          const SizedBox(width: 8),
                        ],
                        if (advance != null) Expanded(child: advance),
                      ],
                    );
                  },
                ),
              ],
            ),
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

/// A ticket a tablet can carry to the next lane: a long press lifts it, the
/// lanes say where it may go, and its buttons still work without dragging.
class DraggableTicket extends StatelessWidget {
  const DraggableTicket({super.key, required this.order, required this.child});
  final StaffOrder order;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, box) => LongPressDraggable<StaffOrder>(
      data: order,
      feedback: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: box.maxWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33173F35),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                ExcludeSemantics(child: IgnorePointer(child: child)),
                // Material's dragged state layer over the lifted card.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        color: AppColors.forest.withValues(
                          alpha: AppStateLayer.dragged,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    ),
  );
}
