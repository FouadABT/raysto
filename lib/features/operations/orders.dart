part of 'operations.dart';

class _Overview extends StatelessWidget {
  const _Overview({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) {
    final restaurant = store.currentRestaurant;
    final active = store.visibleOrders
        .where(
          (o) => ![
            OrderStatus.completed,
            OrderStatus.cancelled,
            OrderStatus.rejected,
            OrderStatus.delivered,
            OrderStatus.served,
            OrderStatus.collected,
          ].contains(o.status),
        )
        .toList();
    final ready = active.where((o) => o.status == OrderStatus.ready).toList();
    final pending = store.visibleRequests
        .where(
          (r) =>
              r.status == RequestStatus.sent ||
              r.status == RequestStatus.acknowledged,
        )
        .toList();
    final occupied = store.restaurantTables
        .where((t) => t.status == TableStatus.occupied)
        .length;
    return _List(
      storageKey: 'operations-overview',
      children: [
        _Card(
          tonal: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(
                store.isRestaurantOpen(restaurant) ? 'Service open' : 'Closed',
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 16),
              Text(
                restaurant.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  _manager(store)
                      ? 'Your service, at a glance.'
                      : 'A clear view of your shift.',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_date(store.now)} · ${_time(store.now)}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ),
        _Heading('Needs your attention'),
        if (ready.isNotEmpty)
          _Link(
            'Ready to serve',
            '${ready.length} ${context.tr('orders ready')}',
            Icons.room_service_outlined,
            () => openOperation(context, store, 'orders', id: 'ready'),
          ),
        if (pending.isNotEmpty)
          _Link(
            'Service requests',
            '${pending.length} ${context.tr('requests waiting')}',
            Icons.notifications_active_outlined,
            () => openOperation(context, store, 'requests'),
          ),
        if (ready.isEmpty && pending.isEmpty)
          _Empty(
            title: context.tr('Everything is in hand'),
            message: context.tr('New orders and requests will appear here.'),
          ),
        _Heading('Live service'),
        _Link(
          'Active orders',
          '${active.length} ${context.tr('in progress')}',
          Icons.receipt_long_outlined,
          () => openOperation(context, store, 'orders', id: 'Active'),
        ),
        _Link(
          'Occupied tables',
          '$occupied / ${store.restaurantTables.length}',
          Icons.table_restaurant_outlined,
          () => openOperation(context, store, 'tables', id: 'occupied'),
        ),
        if (_manager(store)) ...[
          _Link(
            'Payment summary',
            '${context.tr('Outstanding')} ${_money(context, store.report().outstandingMinor)}',
            Icons.account_balance_wallet_outlined,
            () => openOperation(context, store, 'payments'),
          ),
          _Link(
            'Setup checklist',
            context.tr('Review your restaurant and local storefront'),
            Icons.checklist_outlined,
            () => openOperation(context, store, 'setup'),
          ),
        ],
        if (!_manager(store))
          _Link(
            'Your assignments',
            context.tr('Tables, permissions and shift help'),
            Icons.badge_outlined,
            () => openOperation(context, store, 'help'),
          ),
      ],
    );
  }
}

class _Orders extends StatefulWidget {
  const _Orders({
    required this.store,
    this.kitchen = false,
    this.initialStatus = 'All',
  });
  final DemoStore store;
  final bool kitchen;
  final String initialStatus;
  @override
  State<_Orders> createState() => _OrdersState();
}

class _OrdersState extends State<_Orders> {
  String query = '', channel = 'All', payment = 'All';
  late String status = widget.initialStatus;
  String period = 'Any time';
  bool attention = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final orders = s.visibleOrders.where((o) {
      if (widget.kitchen &&
          ![
            OrderStatus.accepted,
            OrderStatus.preparing,
            OrderStatus.ready,
          ].contains(o.status)) {
        return false;
      }
      if (query.isNotEmpty &&
          !'${o.id} ${o.lines.map((l) => l.name).join(' ')} ${o.visitId ?? ''}'
              .toLowerCase()
              .contains(query.toLowerCase())) {
        return false;
      }
      if (status == 'Active' && !o.actionable) return false;
      if (status != 'All' && status != 'Active' && _words(o.status) != status) {
        return false;
      }
      if (channel != 'All' && _words(o.mode) != channel) return false;
      if (payment == 'Unpaid' && _paid(s, o)) return false;
      if (payment == 'Paid' && !_paid(s, o)) return false;
      if (period == 'Last 30 minutes' &&
          s.now.difference(o.createdAt).inMinutes > 30) {
        return false;
      }
      if (period == 'Today' &&
          DateUtils.dateOnly(o.createdAt) != DateUtils.dateOnly(s.now)) {
        return false;
      }
      if (attention &&
          !(o.status == OrderStatus.submitted ||
              (o.actionable && s.now.difference(o.createdAt).inMinutes > 20))) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _List(
      storageKey: widget.kitchen ? 'kitchen-queue' : 'operations-orders',
      children: [
        _Heading(
          widget.kitchen ? 'Kitchen queue' : 'Orders',
          subtitle: widget.kitchen
              ? 'Preparation and payment stay independent.'
              : 'Follow each order from acceptance to fulfilment.',
        ),
        TextField(
          decoration: InputDecoration(
            labelText: context.tr('Search orders'),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final f
                in widget.kitchen
                    ? ['All', 'accepted', 'preparing', 'ready']
                    : [
                        'All',
                        'Active',
                        'submitted',
                        'accepted',
                        'preparing',
                        'ready',
                        'served',
                        'completed',
                        'cancelled',
                      ])
              FilterChip(
                label: Text(context.tr(f)),
                selected: status == f,
                onSelected: (_) => setState(() => status = f),
              ),
          ],
        ),
        if (!widget.kitchen)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(context.tr('More filters')),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final value in ['Any time', 'Last 30 minutes', 'Today'])
                    ChoiceChip(
                      label: Text(context.tr(value)),
                      selected: period == value,
                      onSelected: (_) => setState(() => period = value),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Needs attention')),
                subtitle: Text(
                  context.tr(
                    'New orders or active orders older than 20 minutes',
                  ),
                ),
                value: attention,
                onChanged: (value) => setState(() => attention = value),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final f in ['All', 'dine in', 'pickup', 'delivery'])
                    ChoiceChip(
                      label: Text(context.tr(f)),
                      selected: channel == f,
                      onSelected: (_) => setState(() => channel = f),
                    ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final f in ['All', 'Unpaid', 'Paid'])
                    ChoiceChip(
                      label: Text(context.tr(f)),
                      selected: payment == f,
                      onSelected: (_) => setState(() => payment = f),
                    ),
                ],
              ),
            ],
          ),
        if (orders.isEmpty)
          _Empty(
            title: context.tr('No matching orders'),
            message: context.tr(
              'Change the filters or return after a customer places an order.',
            ),
            action: TextButton(
              onPressed: () => setState(() {
                query = '';
                status = channel = payment = 'All';
                period = 'Any time';
                attention = false;
              }),
              child: Text(context.tr('Clear filters')),
            ),
          ),
        ...orders.map(
          (o) => _OrderCard(key: ValueKey(o.id), store: s, order: o),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({super.key, required this.store, required this.order});
  final DemoStore store;
  final Order order;
  @override
  Widget build(BuildContext context) {
    final age = store.now.difference(order.createdAt).inMinutes;
    return _Card(
      onTap: () => openOperation(context, store, 'order', id: order.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                _words(order.status),
                icon: Icons.restaurant_outlined,
                attention: age > 20 && order.status != OrderStatus.completed,
              ),
              _Badge(
                _paid(store, order) ? 'Paid' : 'Unpaid',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.id, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(order.lines.map((l) => '${l.quantity} × ${l.name}').join(' · ')),
          const SizedBox(height: 10),
          Text(
            '${context.tr(_words(order.mode))} · ${math.max(0, age)} ${context.tr('min')} · ${_money(context, order.totalMinor)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          if (order.visitId != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_tableForVisit(store, order.visitId!)),
            ),
        ],
      ),
    );
  }
}

String _tableForVisit(DemoStore store, String visitId) {
  final visits = store.visits.where((v) => v.id == visitId);
  if (visits.isEmpty) return visitId;
  final tables = store.tables.where((t) => t.id == visits.first.tableId);
  return tables.isEmpty ? visitId : tables.first.label;
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({required this.store, required this.id});
  final DemoStore store;
  final String id;
  @override
  Widget build(BuildContext context) {
    final found = store.visibleOrders.where((o) => o.id == id);
    if (found.isEmpty) {
      return _Empty(
        title: context.tr('Order unavailable'),
        message: context.tr('This account cannot access that order.'),
        icon: Icons.lock_outline,
      );
    }
    final o = found.first;
    final allowed = store.allowedOrderTransitions(o);
    final steps = [
      OrderStatus.submitted,
      OrderStatus.accepted,
      OrderStatus.preparing,
      OrderStatus.ready,
      switch (o.mode) {
        ServiceMode.dineIn => OrderStatus.served,
        ServiceMode.pickup => OrderStatus.collected,
        ServiceMode.delivery => OrderStatus.delivered,
      },
      OrderStatus.completed,
    ];
    return _List(
      children: [
        _Heading(
          o.id,
          subtitle: '${context.tr(_words(o.mode))} · ${_time(o.createdAt)}',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(_words(o.status), icon: Icons.restaurant_outlined),
            _Badge(
              _paid(store, o) ? 'Paid' : 'Unpaid',
              icon: Icons.payments_outlined,
            ),
          ],
        ),
        if (o.visitId != null)
          _Link(
            _tableForVisit(store, o.visitId!),
            'Open this visit',
            Icons.table_restaurant_outlined,
            () => openOperation(context, store, 'visit', id: o.visitId),
          ),
        _Heading('Items'),
        for (final line in o.lines)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailLine(
                  '${line.quantity} × ${line.name}',
                  _money(context, line.subtotalMinor),
                ),
                if (line.modifiers.isNotEmpty)
                  Text(line.modifiers.map((m) => m.name).join(' · ')),
                if (line.note.isNotEmpty)
                  Text('${context.tr('Note')}: ${line.note}'),
                if (store.currentAccount.role == DemoRole.kitchen &&
                    [
                      OrderStatus.accepted,
                      OrderStatus.preparing,
                    ].contains(o.status))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: line.completed,
                    onChanged: (value) => _act(
                      context,
                      () => store.completeOrderItem(
                        o.id,
                        line.id,
                        value ?? false,
                      ),
                    ),
                    title: Text(context.tr('Item prepared')),
                  ),
              ],
            ),
          ),
        if (o.note.isNotEmpty) _Card(child: Text(o.note)),
        _Card(
          child: Column(
            children: [
              _DetailLine('Order total', _money(context, o.totalMinor)),
              _DetailLine(
                'Outstanding',
                _money(context, store.orderBalance(o.id)),
              ),
            ],
          ),
        ),
        if (o.reason.isNotEmpty) _Card(tonal: true, child: Text(o.reason)),
        for (final refund in store.refunds.where((r) => r.orderId == o.id))
          _Badge(
            '${context.tr('Refunded')} ${_money(context, refund.amountMinor)}',
            icon: Icons.undo,
          ),
        _Heading('Progress'),
        for (final event in o.events) Text(event),
        _Card(
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    steps.indexOf(o.status) >= i
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(context.tr(_words(steps[i]))),
                  subtitle: steps[i] == o.status
                      ? Text(context.tr('Current stage'))
                      : null,
                ),
            ],
          ),
        ),
        for (final next in allowed.where(
          (x) => x != OrderStatus.cancelled && x != OrderStatus.rejected,
        ))
          AppButton(
            label: context.tr(_transitionLabel(next)),
            icon: Icons.arrow_forward,
            onPressed: () =>
                _act(context, () => store.transitionOrder(o.id, next)),
          ),
        for (final next in allowed.where(
          (x) => x == OrderStatus.cancelled || x == OrderStatus.rejected,
        ))
          OutlinedButton(
            onPressed: () async {
              final reason = await _ask(
                context,
                next == OrderStatus.rejected ? 'Reject order' : 'Cancel order',
              );
              if (reason != null && context.mounted) {
                _act(
                  context,
                  () => store.transitionOrder(o.id, next, reason: reason),
                );
              }
            },
            child: Text(context.tr(_transitionLabel(next))),
          ),
        if (_manager(store) &&
            [OrderStatus.cancelled, OrderStatus.rejected].contains(o.status) &&
            _paid(store, o))
          OutlinedButton.icon(
            onPressed: () async {
              if (await _confirm(
                    context,
                    'Refund payment?',
                    'Create a local demo refund. Food preparation history stays unchanged.',
                    action: 'Refund',
                  ) &&
                  context.mounted) {
                _act(context, () => store.refundOrder(o.id));
              }
            },
            icon: const Icon(Icons.undo),
            label: Text(context.tr('Create demo refund')),
          ),
      ],
    );
  }
}

String _transitionLabel(OrderStatus status) => switch (status) {
  OrderStatus.accepted => 'Accept order',
  OrderStatus.preparing => 'Start preparing',
  OrderStatus.ready => 'Mark ready',
  OrderStatus.served => 'Confirm served',
  OrderStatus.collected => 'Confirm collected',
  OrderStatus.delivered => 'Confirm delivered',
  OrderStatus.completed => 'Complete order',
  OrderStatus.rejected => 'Reject order',
  OrderStatus.cancelled => 'Cancel order',
  _ => 'Continue',
};

class _Requests extends StatefulWidget {
  const _Requests({required this.store});
  final DemoStore store;
  @override
  State<_Requests> createState() => _RequestsState();
}

class _RequestsState extends State<_Requests> {
  String filter = 'Active';
  @override
  Widget build(BuildContext context) {
    final requests = widget.store.visibleRequests
        .where(
          (r) =>
              (filter == 'All' ||
              (filter == 'Active'
                  ? [
                      RequestStatus.sent,
                      RequestStatus.acknowledged,
                    ].contains(r.status)
                  : r.status == RequestStatus.completed)),
        )
        .toList();
    return _List(
      children: [
        _Heading(
          'Service requests',
          subtitle: 'Acknowledge a request so the team knows it is in hand.',
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final f in ['Active', 'Completed', 'All'])
              ChoiceChip(
                label: Text(context.tr(f)),
                selected: filter == f,
                onSelected: (_) => setState(() => filter = f),
              ),
          ],
        ),
        if (requests.isEmpty)
          _Empty(
            title: context.tr('No requests here'),
            message: context.tr(
              'Customer requests will appear in the shared service desk.',
            ),
          ),
        for (final r in requests) _RequestCard(store: widget.store, request: r),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.store, required this.request});
  final DemoStore store;
  final ServiceRequest request;
  @override
  Widget build(BuildContext context) {
    final r = request;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(
            _words(r.status),
            icon: Icons.notifications_outlined,
            attention: r.status == RequestStatus.sent,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(r.kind),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(_tableForVisit(store, r.visitId)),
          if (r.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(r.note),
            ),
          if (r.status == RequestStatus.sent)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(
                label: context.tr('Acknowledge'),
                onPressed: () => _act(
                  context,
                  () =>
                      store.transitionRequest(r.id, RequestStatus.acknowledged),
                ),
              ),
            ),
          if (r.status == RequestStatus.acknowledged)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(
                label: context.tr('Mark completed'),
                onPressed: () => _act(
                  context,
                  () => store.transitionRequest(r.id, RequestStatus.completed),
                ),
              ),
            ),
          if (_manager(store) &&
              [
                RequestStatus.sent,
                RequestStatus.acknowledged,
              ].contains(r.status))
            TextButton.icon(
              onPressed: () => showAppSheet<void>(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Heading('Assign request'),
                    for (final person in store.accounts.where(
                      (a) =>
                          a.role == DemoRole.waiter &&
                          a.active &&
                          a.restaurantId == store.currentRestaurant.id,
                    ))
                      ListTile(
                        title: Text(person.name),
                        onTap: () => _act(context, () {
                          store.transitionRequest(
                            r.id,
                            RequestStatus.acknowledged,
                            assigneeId: person.id,
                          );
                          Navigator.pop(context);
                        }),
                      ),
                  ],
                ),
              ),
              icon: const Icon(Icons.person_outline),
              label: Text(context.tr('Assign waiter')),
            ),
          if (r.assigneeId != null)
            Text(
              '${context.tr('Assigned to')}: ${store.accounts.where((a) => a.id == r.assigneeId).firstOrNull?.name ?? r.assigneeId}',
            ),
          if ([
            RequestStatus.sent,
            RequestStatus.acknowledged,
          ].contains(r.status))
            TextButton(
              onPressed: () async {
                final reason = await _ask(context, 'Cancel request');
                if (reason != null && context.mounted) {
                  _act(
                    context,
                    () => store.transitionRequest(
                      r.id,
                      RequestStatus.cancelled,
                      reason: reason,
                    ),
                  );
                }
              },
              child: Text(context.tr('Cancel with reason')),
            ),
        ],
      ),
    );
  }
}

class _RequestRecord extends StatelessWidget {
  const _RequestRecord({required this.store, required this.id});
  final DemoStore store;
  final String id;
  @override
  Widget build(BuildContext context) {
    final request = store.visibleRequests.where((r) => r.id == id).firstOrNull;
    if (request == null) {
      return _Empty(
        title: context.tr('Request unavailable'),
        message: context.tr('This account cannot access that request.'),
      );
    }
    return _List(
      children: [
        _RequestCard(store: store, request: request),
        Text('${_date(request.createdAt)} · ${_time(request.createdAt)}'),
        if (request.reason.isNotEmpty) Text(request.reason),
        _Link(
          _tableForVisit(store, request.visitId),
          'Open this visit',
          Icons.table_restaurant_outlined,
          () => openOperation(context, store, 'visit', id: request.visitId),
        ),
      ],
    );
  }
}
