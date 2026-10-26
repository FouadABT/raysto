part of 'operations.dart';

class _Tables extends StatefulWidget {
  const _Tables({required this.store, this.occupiedOnly = false});
  final DemoStore store;
  final bool occupiedOnly;
  @override
  State<_Tables> createState() => _TablesState();
}

class _TablesState extends State<_Tables> {
  String zone = 'All', view = 'Plan';
  late bool occupiedOnly = widget.occupiedOnly;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final tables = s.restaurantTables
        .where(
          (t) =>
              (zone == 'All' || t.zone == zone) &&
              (!occupiedOnly || t.status == TableStatus.occupied) &&
              (s.currentAccount.role != DemoRole.waiter ||
                  s.currentAccount.assignedTableIds.contains(t.id)),
        )
        .toList();
    final zones = s.restaurantTables.map((t) => t.zone).toSet();
    return _List(
      storageKey: 'operations-tables',
      children: [
        _Heading(
          'Live tables',
          subtitle: 'Occupancy, requests and payment are shown separately.',
        ),
        ExperienceMetrics(
          values: [
            (
              '${tables.where((t) => t.status == TableStatus.available).length}',
              'Available',
              Icons.check_circle_outline,
            ),
            (
              '${tables.where((t) => t.status == TableStatus.occupied).length}',
              'Occupied',
              Icons.people_outline,
            ),
            (
              '${tables.where((t) => t.status == TableStatus.needsReset).length}',
              'Needs reset',
              Icons.cleaning_services_outlined,
            ),
          ],
        ),
        FilterChip(
          label: Text(context.tr('Occupied only')),
          selected: occupiedOnly,
          onSelected: (value) => setState(() => occupiedOnly = value),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final mode in ['List', 'Grid', 'Plan'])
              ChoiceChip(
                label: Text(context.tr(mode)),
                selected: view == mode,
                onSelected: (_) => setState(() => view = mode),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final value in ['All', ...zones])
              FilterChip(
                label: Text(context.tr(value)),
                selected: zone == value,
                onSelected: (_) => setState(() => zone = value),
              ),
          ],
        ),
        if (_manager(s))
          OutlinedButton.icon(
            onPressed: () => openOperation(context, s, 'floor'),
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.tr('Edit floor plan')),
          ),
        if (tables.isEmpty)
          _Empty(
            title: context.tr('No tables in this view'),
            message: context.tr(
              'Choose another zone or ask a manager to assign tables.',
            ),
          ),
        if (view == 'Plan') ...[
          const TableStatusLegend(),
          SizedBox(
            height: 370,
            child: DiningFloorMap(
              tables: tables,
              objects: s.floorObjects
                  .where((o) => o.restaurantId == s.currentRestaurant.id)
                  .toList(),
              onSelect: (id) => _openTable(context, s, id),
            ),
          ),
          Text(
            context.tr('Pinch to zoom. Tap a table to open its current visit.'),
          ),
          AppSectionTitle(
            title: context.tr('Table details'),
            subtitle: context.tr('The same tables, in an accessible list.'),
          ),
          ...tables.map((t) => _TableTile(store: s, table: t)),
        ] else if (view == 'Grid')
          LayoutBuilder(
            builder: (context, c) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tables
                  .map(
                    (t) => SizedBox(
                      width:
                          c.maxWidth >= 360 &&
                              MediaQuery.textScalerOf(context).scale(1) < 1.4
                          ? (c.maxWidth - 12) / 2
                          : c.maxWidth,
                      child: _TableTile(store: s, table: t),
                    ),
                  )
                  .toList(),
            ),
          )
        else
          ...tables.map((t) => _TableTile(store: s, table: t)),
      ],
    );
  }
}

void _openTable(BuildContext context, DemoStore s, String id) {
  final visit = s.visits.where((v) => v.tableId == id && v.active).firstOrNull;
  openOperation(
    context,
    s,
    visit == null ? 'table' : 'visit',
    id: visit?.id ?? id,
  );
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.store, required this.table});
  final DemoStore store;
  final DemoTable table;
  @override
  Widget build(BuildContext context) {
    final visit = store.visits
        .where((v) => v.tableId == table.id && v.active)
        .firstOrNull;
    final requests = visit == null
        ? 0
        : store.visibleRequests
              .where(
                (r) =>
                    r.visitId == visit.id &&
                    [
                      RequestStatus.sent,
                      RequestStatus.acknowledged,
                    ].contains(r.status),
              )
              .length;
    return _Card(
      onTap: () => _openTable(context, store, table.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_restaurant_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  table.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${table.seats} ${context.tr('seats')} · ${table.zone}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(_words(table.status), icon: Icons.people_outline),
              if (visit != null)
                _Badge(
                  _money(context, store.visitBalance(visit.id)),
                  icon: Icons.payments_outlined,
                ),
              if (requests > 0)
                _Badge(
                  '$requests ${context.tr('requests')}',
                  icon: Icons.notifications_outlined,
                  attention: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableDetail extends StatefulWidget {
  const _TableDetail({required this.store, required this.id});
  final DemoStore store;
  final String id;
  @override
  State<_TableDetail> createState() => _TableDetailState();
}

class _TableDetailState extends State<_TableDetail> {
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final table = s.restaurantTables
        .where((t) => t.id == widget.id)
        .firstOrNull;
    if (table == null ||
        (s.currentAccount.role == DemoRole.waiter &&
            !s.currentAccount.assignedTableIds.contains(table.id))) {
      return _Empty(
        title: context.tr('Table unavailable'),
        message: context.tr('This account cannot access that table.'),
      );
    }
    final payload = s.tablePayload(table.id);
    return _List(
      children: [
        _Heading(
          table.label,
          subtitle: '${table.zone} · ${table.seats} ${context.tr('seats')}',
        ),
        _Badge(_words(table.status), icon: Icons.table_restaurant_outlined),
        if (table.status == TableStatus.available && table.active)
          AppButton(
            label: context.tr('Start a new visit'),
            onPressed: () async {
              final guests = await _ask(
                context,
                'New table visit',
                label: 'Number of guests',
                initial: '2',
              );
              if (guests != null && context.mounted) {
                _act(context, () {
                  final visit = s.startVisit(
                    table.id,
                    guests: int.tryParse(guests) ?? 0,
                  );
                  openOperation(context, s, 'visit', id: visit.id);
                });
              }
            },
          ),
        if (table.status == TableStatus.needsReset)
          AppButton(
            label: context.tr('Mark table ready'),
            icon: Icons.cleaning_services_outlined,
            onPressed: () => _act(context, () => s.resetTable(table.id)),
          ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Table QR'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  'This code identifies the table. Joining an existing party also requires its current invitation.',
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Semantics(
                  label: context.tr('Local table QR code'),
                  child: ColoredBox(
                    color: Colors.white,
                    child: QrImageView(
                      data: payload,
                      size: 210,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(payload),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: payload));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.tr('Table link copied'))),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined),
                label: Text(context.tr('Copy table link')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _act(context, () {
                  final parsed = s.parseTablePayload(payload);
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(parsed.label),
                      content: Text(
                        '${s.currentRestaurant.name}\n${context.tr('Valid table link. An invitation is needed to join an occupied visit.')}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(context.tr('Done')),
                        ),
                      ],
                    ),
                  );
                }),
                icon: const Icon(Icons.link),
                label: Text(context.tr('Open demo link')),
              ),
            ],
          ),
        ),
        if (_manager(s))
          OutlinedButton.icon(
            onPressed: () => _editTable(context, s, table),
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.tr('Edit table')),
          ),
        if (_manager(s))
          TextButton.icon(
            onPressed: () async {
              if (await _confirm(
                    context,
                    'Delete table?',
                    'An occupied table cannot be deleted. This removes the physical table from the local plan.',
                    action: 'Delete',
                  ) &&
                  context.mounted) {
                _act(context, () {
                  s.deleteTable(table.id);
                  Navigator.pop(context);
                });
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(context.tr('Delete table')),
          ),
      ],
    );
  }
}

Future<void> _editTable(
  BuildContext context,
  DemoStore store,
  DemoTable table,
) async {
  final label = TextEditingController(text: table.label),
      seats = TextEditingController(text: '${table.seats}'),
      zone = TextEditingController(text: table.zone);
  var shape = table.shape, active = table.active;
  final key = GlobalKey<FormState>();
  await showAppSheet<void>(
    context,
    enableDrag: false,
    child: StatefulBuilder(
      builder: (sheet, setState) => _InputDraft(
        controllers: [label, seats, zone],
        changed: shape != table.shape || active != table.active,
        child: Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Heading('Edit table'),
              const SizedBox(height: 16),
              _field(sheet, 'Table name', label),
              const SizedBox(height: 16),
              _field(
                sheet,
                'Seats',
                seats,
                type: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                    ? null
                    : sheet.tr('Enter a positive capacity'),
              ),
              const SizedBox(height: 16),
              _field(sheet, 'Zone', zone),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in ['round', 'rectangle'])
                    ChoiceChip(
                      label: Text(sheet.tr(value)),
                      selected: shape == value,
                      onSelected: (_) => setState(() => shape = value),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(sheet.tr('Active table')),
                value: active,
                onChanged: (v) => setState(() => active = v),
              ),
              AppButton(
                label: sheet.tr('Save table'),
                onPressed: () {
                  if (key.currentState!.validate()) {
                    _act(sheet, () {
                      store.saveTable(
                        table.copyWith(
                          label: label.text.trim(),
                          seats: int.parse(seats.text),
                          zone: zone.text.trim(),
                          shape: shape,
                          active: active,
                        ),
                      );
                      Navigator.pop(sheet);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
  label.dispose();
  seats.dispose();
  zone.dispose();
}

class _VisitDetail extends StatelessWidget {
  const _VisitDetail({required this.store, required this.id});
  final DemoStore store;
  final String id;
  @override
  Widget build(BuildContext context) {
    final visit = store.visits
        .where(
          (v) => v.id == id && v.restaurantId == store.currentRestaurant.id,
        )
        .firstOrNull;
    if (visit == null ||
        (store.currentAccount.role == DemoRole.waiter &&
            !store.currentAccount.assignedTableIds.contains(visit.tableId))) {
      return _Empty(
        title: context.tr('Visit unavailable'),
        message: context.tr('No visit is accessible for this account.'),
      );
    }
    final orders = store.visitOrders(id);
    final pending = store.attempts
        .where((a) => a.visitId == id && a.status == AttemptStatus.pending)
        .firstOrNull;
    final requests = store.visibleRequests
        .where((r) => r.visitId == id)
        .toList();
    final eligible = store.restaurantTables
        .where(
          (t) =>
              t.status == TableStatus.available &&
              t.active &&
              t.seats >= visit.guestCount,
        )
        .toList();
    return _List(
      children: [
        _Heading(
          _tableForVisit(store, id),
          subtitle:
              '${visit.guestCount} ${context.tr('guests')} · ${math.max(0, store.now.difference(visit.startedAt).inMinutes)} ${context.tr('min')}',
        ),
        _Badge(
          visit.active ? 'Active visit' : 'Visit closed',
          icon: Icons.people_outline,
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailLine('Participants', '${visit.participantIds.length}'),
              _DetailLine(
                'Outstanding',
                _money(context, store.visitBalance(id)),
              ),
              if (visit.note.isNotEmpty) Text(visit.note),
              TextButton.icon(
                onPressed: () async {
                  final note = await _ask(
                    context,
                    'Visit note',
                    label: 'Note',
                    initial: visit.note,
                    required: false,
                  );
                  if (note != null && context.mounted) {
                    _act(context, () => store.updateVisit(id, note: note));
                  }
                },
                icon: const Icon(Icons.edit_note),
                label: Text(context.tr('Edit visit note')),
              ),
            ],
          ),
        ),
        if (visit.active)
          AppButton(
            label: context.tr('Take an order'),
            icon: Icons.add,
            onPressed: () => openAssistedOrder(context, store, id),
          ),
        if (visit.active)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Current party invitation'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SelectableText(visit.invitation),
                Text(
                  '${context.tr('Valid until')} ${_time(visit.invitationExpiresAt)}',
                ),
                Center(
                  child: ColoredBox(
                    color: Colors.white,
                    child: QrImageView(
                      data: visit.invitation,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        _Heading('Orders'),
        if (orders.isEmpty) Text(context.tr('No orders yet.')),
        ...orders.map((o) => _OrderCard(store: store, order: o)),
        _Heading('Bill collection'),
        if (pending != null)
          _Card(
            tonal: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Payment in progress'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${pending.id} · ${_money(context, pending.totalMinor)}'),
                Text(
                  context.tr(
                    'This attempt reserves its own amounts. Another round stays separate.',
                  ),
                ),
              ],
            ),
          ),
        if (visit.active && store.visitBalance(id) > 0 && pending == null)
          AppButton(
            label: context.tr('Record demo cash collection'),
            icon: Icons.payments_outlined,
            onPressed: () async {
              if (await _confirm(
                    context,
                    'Confirm cash collected?',
                    'This explicitly records a simulated staff cash collection. No real payment is processed.',
                    action: 'Record collection',
                  ) &&
                  context.mounted) {
                _act(context, () => store.collectCash(id));
              }
            },
          ),
        if (visit.active && store.visitBalance(id) > 0)
          Text(
            context.tr(
              'Customers can pay from their shared table bill using the current invitation. Demo checkout — no real payment.',
            ),
          ),
        _Heading('Service requests'),
        ...requests.map((r) => _RequestCard(store: store, request: r)),
        if (visit.active)
          OutlinedButton.icon(
            onPressed: () async {
              final kind = await _ask(
                context,
                'Request for this table',
                label: 'Request',
                initial: 'Water',
              );
              if (kind != null && context.mounted) {
                _act(context, () => store.requestService(kind, visitId: id));
              }
            },
            icon: const Icon(Icons.notifications_outlined),
            label: Text(context.tr('Create request')),
          ),
        if (visit.active && _manager(store))
          OutlinedButton.icon(
            onPressed: () => showAppSheet<void>(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Heading(
                    'Move visit',
                    subtitle: 'The visit, orders and bill move together. The old table will need reset.',
                  ),
                  const SizedBox(height: 16),
                  if (eligible.isEmpty)
                    Text(context.tr('No eligible destination table.')),
                  for (final t in eligible)
                    ListTile(
                      title: Text(t.label),
                      subtitle: Text(
                        '${t.seats} ${context.tr('seats')} · ${t.zone}',
                      ),
                      onTap: () async {
                        if (await _confirm(
                              context,
                              'Move this party?',
                              '${_tableForVisit(store, id)} → ${t.label}',
                              action: 'Move visit',
                            ) &&
                            context.mounted) {
                          _act(context, () {
                            store.moveVisit(id, t.id);
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                ],
              ),
            ),
            icon: const Icon(Icons.swap_horiz),
            label: Text(context.tr('Move to another table')),
          ),
        if (visit.active)
          AppButton(
            label: context.tr('Close visit'),
            secondary: true,
            onPressed: store.canCloseVisit(id)
                ? () async {
                    if (await _confirm(
                          context,
                          'Close visit?',
                          'All orders and balances are resolved. The table will need a reset before the next party.',
                          action: 'Close visit',
                        ) &&
                        context.mounted) {
                      _act(context, () => store.closeVisit(id));
                    }
                  }
                : null,
          ),
        if (visit.active && !store.canCloseVisit(id))
          Text(
            context.tr(
              'Resolve active orders and settle the balance before closing this visit.',
            ),
          ),
        if (!visit.active)
          AppButton(
            label: context.tr('Open table reset'),
            onPressed: () =>
                openOperation(context, store, 'table', id: visit.tableId),
          ),
      ],
    );
  }
}
