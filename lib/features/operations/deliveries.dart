part of 'operations.dart';

class _Deliveries extends StatefulWidget {
  const _Deliveries({required this.store, this.completed = false});
  final DemoStore store;
  final bool completed;
  @override
  State<_Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<_Deliveries> {
  String filter = 'Current';
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final tasks = s.visibleDeliveries.where((d) {
      if (widget.completed) return d.status == DeliveryStatus.delivered;
      if (filter == 'Completed') return d.status == DeliveryStatus.delivered;
      if (filter == 'Unassigned') return d.status == DeliveryStatus.unassigned;
      if (filter == 'Issues') return d.status == DeliveryStatus.issue;
      return d.status != DeliveryStatus.delivered;
    }).toList();
    return _List(
      storageKey: 'deliveries-${widget.completed}',
      children: [
        _Heading(
          widget.completed
              ? 'Delivery activity'
              : _manager(s)
              ? 'Delivery desk'
              : 'Your deliveries',
          subtitle: widget.completed
              ? 'Completed local tasks and their details.'
              : 'Pickup, delivery and preparation stay connected.',
        ),
        if (!widget.completed)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in [
                'Current',
                if (_manager(s)) 'Unassigned',
                if (_manager(s)) 'Issues',
                'Completed',
              ])
                ChoiceChip(
                  label: Text(context.tr(f)),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
            ],
          ),
        if (tasks.isEmpty)
          _Empty(
            title: context.tr('No deliveries here'),
            message: context.tr(
              'An assigned task will appear here once the restaurant creates a delivery.',
            ),
          ),
        for (final task in tasks)
          _Card(
            onTap: () => openOperation(context, s, 'delivery', id: task.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(
                  _words(task.status),
                  icon: Icons.delivery_dining_outlined,
                  attention: task.status == DeliveryStatus.issue,
                ),
                const SizedBox(height: 12),
                Text(
                  task.orderId,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(task.address),
                if (task.issue.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(task.issue),
                  ),
                const SizedBox(height: 10),
                Text(
                  task.courierId == null
                      ? context.tr('Awaiting courier assignment')
                      : s.accounts
                                .where((a) => a.id == task.courierId)
                                .firstOrNull
                                ?.name ??
                            task.courierId!,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DeliveryDetail extends StatelessWidget {
  const _DeliveryDetail({required this.store, required this.id});
  final DemoStore store;
  final String id;
  @override
  Widget build(BuildContext context) {
    final task = store.visibleDeliveries.where((d) => d.id == id).firstOrNull;
    if (task == null) {
      return _Empty(
        title: context.tr('Delivery unavailable'),
        message: context.tr(
          'This account can only open authorized delivery tasks.',
        ),
      );
    }
    final order = store.orders.where((o) => o.id == task.orderId).firstOrNull;
    final couriers = store.accounts
        .where(
          (a) =>
              a.restaurantId == store.currentRestaurant.id &&
              a.role == DemoRole.courier &&
              a.active,
        )
        .toList();
    return _List(
      children: [
        _Heading(task.orderId, subtitle: store.currentRestaurant.name),
        _Badge(_words(task.status), icon: Icons.delivery_dining_outlined),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Pickup'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(store.currentRestaurant.address),
              if (order != null) ...[
                const SizedBox(height: 12),
                _Badge(_words(order.status), icon: Icons.restaurant_outlined),
                const SizedBox(height: 12),
                Text(
                  '${order.lines.fold<int>(0, (sum, l) => sum + l.quantity)} ${context.tr('items in one demo package')}',
                ),
                for (final line in order.lines)
                  Text('${line.quantity} × ${line.name}'),
              ],
              if (_manager(store))
                TextButton(
                  onPressed: () =>
                      openOperation(context, store, 'order', id: task.orderId),
                  child: Text(context.tr('Open order')),
                ),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Delivery address'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(task.address),
              if (task.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.note),
              ],
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Simulated route'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Semantics(
                label: context.tr(
                  'Schematic route from restaurant to customer. No live GPS.',
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RoutePainter(
                      Theme.of(context).colorScheme,
                      task.status,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  'Schematic map only. No live location, navigation or distance is calculated.',
                ),
              ),
            ],
          ),
        ),
        if (_manager(store) &&
            [
              DeliveryStatus.unassigned,
              DeliveryStatus.assigned,
            ].contains(task.status))
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Heading('Courier assignment'),
                const SizedBox(height: 12),
                if (couriers.isEmpty)
                  Text(context.tr('Create an active courier account in Team.')),
                RadioGroup<String>(
                  groupValue: task.courierId,
                  onChanged: (v) =>
                      _act(context, () => store.assignDelivery(task.id, v!)),
                  child: Column(
                    children: [
                      for (final courier in couriers)
                        RadioListTile<String>(
                          title: Text(courier.name),
                          subtitle: Text(courier.email),
                          value: courier.id,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (store.currentAccount.role == DemoRole.courier &&
            task.status == DeliveryStatus.assigned) ...[
          AppButton(
            label: context.tr('Confirm pickup'),
            icon: Icons.inventory_2_outlined,
            onPressed: order?.status == OrderStatus.ready
                ? () async {
                    if (await _confirm(
                          context,
                          'Confirm pickup?',
                          'Check the order reference and package before collecting.',
                          action: 'Collected',
                        ) &&
                        context.mounted) {
                      _act(
                        context,
                        () => store.progressDelivery(
                          task.id,
                          DeliveryStatus.collected,
                        ),
                      );
                    }
                  }
                : null,
          ),
          if (order?.status != OrderStatus.ready)
            Text(
              context.tr(
                'The kitchen must mark this order ready before pickup.',
              ),
            ),
        ],
        if (store.currentAccount.role == DemoRole.courier &&
            task.status == DeliveryStatus.collected)
          AppButton(
            label: context.tr('Start delivery'),
            icon: Icons.delivery_dining_outlined,
            onPressed: () => _act(
              context,
              () => store.progressDelivery(
                task.id,
                DeliveryStatus.outForDelivery,
              ),
            ),
          ),
        if (store.currentAccount.role == DemoRole.courier &&
            task.status == DeliveryStatus.outForDelivery)
          AppButton(
            label: context.tr('Confirm delivered'),
            icon: Icons.check_circle_outline,
            onPressed: () async {
              if (await _confirm(
                    context,
                    'Confirm delivered?',
                    'Confirm the package was handed over in this simulated delivery.',
                    action: 'Delivered',
                  ) &&
                  context.mounted) {
                _act(
                  context,
                  () =>
                      store.progressDelivery(task.id, DeliveryStatus.delivered),
                );
              }
            },
          ),
        if (task.status == DeliveryStatus.issue)
          _Card(
            tonal: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Delivery issue'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(task.issue),
                if (_manager(store))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppButton(
                      label: context.tr('Resolve and resume'),
                      onPressed: () => _act(
                        context,
                        () => store.resolveDeliveryIssue(task.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (store.currentAccount.role == DemoRole.courier &&
            ![
              DeliveryStatus.unassigned,
              DeliveryStatus.delivered,
              DeliveryStatus.issue,
            ].contains(task.status))
          OutlinedButton.icon(
            onPressed: () => _issue(context, store, task),
            icon: const Icon(Icons.report_problem_outlined),
            label: Text(context.tr('Report delivery issue')),
          ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) =>
                  SupportScreen(store: store, orderId: task.orderId),
            ),
          ),
          icon: const Icon(Icons.support_agent_outlined),
          label: Text(context.tr('Local support conversation')),
        ),
        _Heading('Progress'),
        for (final step in [
          DeliveryStatus.assigned,
          DeliveryStatus.collected,
          DeliveryStatus.outForDelivery,
          DeliveryStatus.delivered,
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              task.status.index >= step.index &&
                      task.status != DeliveryStatus.issue
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
            ),
            title: Text(context.tr(_words(step))),
          ),
      ],
    );
  }
}

Future<void> _issue(
  BuildContext context,
  DemoStore store,
  DeliveryTask task,
) async {
  var kind = 'Customer unavailable';
  final note = TextEditingController();
  await showAppSheet<void>(
    context,
    enableDrag: false,
    child: StatefulBuilder(
      builder: (context, update) => _InputDraft(
        controllers: [note],
        changed: kind != 'Customer unavailable',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Heading(
              'Report a delivery issue',
              subtitle: 'This local note appears in the manager delivery desk.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: kind,
              decoration: InputDecoration(labelText: context.tr('Issue type')),
              items: [
                for (final v in [
                  'Customer unavailable',
                  'Address issue',
                  'Package issue',
                  'Other',
                ])
                  DropdownMenuItem(value: v, child: Text(context.tr(v))),
              ],
              onChanged: (v) => update(() => kind = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: note,
              maxLines: 3,
              decoration: InputDecoration(labelText: context.tr('Local note')),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: context.tr('Save issue'),
              onPressed: () => _act(context, () {
                store.progressDelivery(
                  task.id,
                  DeliveryStatus.issue,
                  note:
                      '$kind${note.text.trim().isEmpty ? '' : ': ${note.text.trim()}'}',
                );
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    ),
  );
  note.dispose();
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter(this.scheme, this.status);
  final ColorScheme scheme;
  final DeliveryStatus status;
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = scheme.outlineVariant
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    for (final f in [.2, .5, .8]) {
      canvas.drawLine(
        Offset(0, size.height * f),
        Offset(size.width, size.height * f),
        road,
      );
      canvas.drawLine(
        Offset(size.width * f, 0),
        Offset(size.width * f, size.height),
        road,
      );
    }
    final start = Offset(size.width * .2, size.height * .2),
        finish = Offset(size.width * .8, size.height * .8);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(size.width * .5, start.dy)
      ..lineTo(size.width * .5, finish.dy)
      ..lineTo(finish.dx, finish.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = scheme.primary
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(start, 12, Paint()..color = scheme.primary);
    canvas.drawCircle(finish, 12, Paint()..color = scheme.tertiary);
    canvas.drawCircle(
      status == DeliveryStatus.delivered
          ? finish
          : status == DeliveryStatus.outForDelivery
          ? Offset(size.width * .5, size.height * .5)
          : start,
      6,
      Paint()..color = scheme.onPrimary,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.scheme != scheme || old.status != status;
}
