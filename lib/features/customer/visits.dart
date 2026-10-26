part of 'customer_screens.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;
  Future<void> _openCamera() async {
    final code = await openPage<String>(context, const QrCameraScreen());
    if (mounted && code != null) await _resolve(code);
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _resolve(String code) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (code.trim().startsWith('RAYSTO-JOIN-')) {
        final visit = widget.store.visits
            .where(
              (v) =>
                  v.invitation == code.trim() &&
                  v.active &&
                  v.invitationExpiresAt.isAfter(widget.store.now),
            )
            .firstOrNull;
        if (visit == null) {
          throw const DomainException(
            'This invitation is expired or unknown. Ask staff for a current invitation.',
          );
        }
        if (mounted) {
          await openPage(
            context,
            InvitationConfirmationScreen(
              store: widget.store,
              invitation: code.trim(),
            ),
          );
        }
      } else {
        final table = widget.store.parseTablePayload(code.trim());
        if (mounted) {
          await openPage(
            context,
            TableConfirmationScreen(store: widget.store, tableId: table.id),
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final table = store.tables.firstWhere((t) => t.id == 'olive-table-06');
    final payload = store.tablePayload(table.id);
    return MobilePage(
      title: 'Scan a table',
      children: [
        ExperienceHero(
          eyebrow: 'AT THE RESTAURANT',
          title: 'One scan. Your table.',
          message: 'Scan the code on your table to see the menu and review your visit.',
          icon: Icons.qr_code_2,
          action: FilledButton.tonalIcon(
            onPressed: _busy ? null : _openCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(context.tr('Open camera')),
          ),
        ),
        ExperienceAction(
          icon: Icons.map_outlined,
          title: 'Explore the dining room',
          subtitle: 'See the layout, zones and available seats.',
          onTap: () => openPage(context, DiningRoomScreen(store: store)),
        ),
        Text(
          context.tr(
            'A table code identifies a place. A visit invitation lets you join a specific party.',
          ),
        ),
        ExpansionTile(
          title: Text(context.tr('Try a demo code')),
          leading: const Icon(Icons.science_outlined),
          children: [
            Column(
              children: [
                Text(
                  context.tr('Bundled demo QR'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ColoredBox(
                  color: Colors.white,
                  child: QrImageView(
                    data: payload,
                    size: 210,
                    semanticsLabel: context.tr(
                      'Demo code for Olive Kitchen Table 06',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'Demo QR · the camera button above uses your device camera.',
                  ),
                ),
              ],
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _busy ? null : () => _resolve(payload),
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(context.tr('Use demo QR')),
        ),
        TextField(
          controller: _code,
          decoration: InputDecoration(
            labelText: context.tr('Table link or visit invitation'),
            hintText: 'RAYSTO-JOIN-06',
          ),
          onSubmitted: _resolve,
        ),
        OutlinedButton(
          onPressed: _busy ? null : () => _resolve(_code.text),
          child: Text(context.tr('Open entered code')),
        ),
        AppNotice(
          title: context.tr('Join the Table 06 demo party'),
          message: context.tr(
            'The invitation is valid only for its current visit. Expired invitations cannot reopen old bills.',
          ),
          action: TextButton(
            onPressed: _busy ? null : () => _resolve('RAYSTO-JOIN-06'),
            child: Text(context.tr('Use demo invitation')),
          ),
        ),
        TextButton(
          onPressed: () => _resolve(store.tablePayload('olive-table-01')),
          child: Text(context.tr('Try an available table')),
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: AppNotice(
              title: context.tr('Code not accepted'),
              message: context.tr(_error!),
              icon: Icons.error_outline,
            ),
          ),
      ],
    );
  }
}

class InvitationConfirmationScreen extends StatelessWidget {
  const InvitationConfirmationScreen({
    super.key,
    required this.store,
    required this.invitation,
  });
  final DemoStore store;
  final String invitation;
  @override
  Widget build(BuildContext context) {
    final visit = store.visits
        .where((v) => v.invitation == invitation && v.active)
        .firstOrNull;
    if (visit == null) {
      return const MobilePage(
        title: 'Invitation unavailable',
        children: [
          EmptyState(
            title: 'This visit has ended',
            message: 'Ask staff for a current invitation.',
          ),
        ],
      );
    }
    final table = store.tables.firstWhere((t) => t.id == visit.tableId);
    return MobilePage(
      title: 'Confirm your visit',
      children: [
        const Icon(Icons.table_restaurant_outlined, size: 64),
        Text(
          store.restaurants.firstWhere((r) => r.id == visit.restaurantId).name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(table.label, style: Theme.of(context).textTheme.titleLarge),
        Text('${visit.guestCount} ${context.tr('guests')}'),
        Text(
          context.tr(
            'Joining gives you access to this party’s shared orders and bill. Confirm that this is your table.',
          ),
        ),
        FilledButton(
          onPressed: () => guarded(context, () {
            final joined = store.joinVisit(invitation);
            store.configureCart(mode: ServiceMode.dineIn, visitId: joined.id);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VisitScreen(store: store, visitId: joined.id),
              ),
            );
          }),
          child: Text(context.tr('Confirm and join visit')),
        ),
      ],
    );
  }
}

class TableConfirmationScreen extends StatefulWidget {
  const TableConfirmationScreen({
    super.key,
    required this.store,
    required this.tableId,
    this.initialGuests = 2,
  });
  final DemoStore store;
  final String tableId;
  final int initialGuests;
  @override
  State<TableConfirmationScreen> createState() =>
      _TableConfirmationScreenState();
}

class _TableConfirmationScreenState extends State<TableConfirmationScreen> {
  late int _guests = widget.initialGuests
      .clamp(1, widget.store.tableById(widget.tableId).seats)
      .toInt();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store,
          table = store.tables.firstWhere((t) => t.id == widget.tableId),
          r = store.restaurants.firstWhere((r) => r.id == table.restaurantId);
      return MobilePage(
        title: 'Confirm your table',
        children: [
          const Icon(Icons.table_restaurant_outlined, size: 64),
          Text(r.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(table.label, style: Theme.of(context).textTheme.titleLarge),
          StatusBadge(table.status.name, icon: Icons.table_bar_outlined),
          Text('${table.zone} · ${table.seats} ${context.tr('seats')}'),
          if (table.status == TableStatus.available) ...[
            Section(
              title: 'Guests in your party',
              child: QuantityStepper(
                value: _guests,
                max: table.seats,
                onChanged: (v) => setState(() => _guests = v),
              ),
            ),
            FilledButton(
              onPressed: () => guarded(context, () {
                store.selectRestaurant(r.id);
                final visit = store.startVisit(table.id, guests: _guests);
                store.configureCart(
                  mode: ServiceMode.dineIn,
                  visitId: visit.id,
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        VisitScreen(store: store, visitId: visit.id),
                  ),
                );
              }),
              child: Text(context.tr('Start a fresh visit')),
            ),
          ] else
            AppNotice(
              title: context.tr('A new visit cannot start here yet'),
              message: context.tr(
                'An occupied table needs an invitation from the current party. Reserved or unreset tables need staff assistance.',
              ),
            ),
          Text(
            context.tr(
              'No previous party’s orders or bill are exposed by this table code.',
            ),
          ),
        ],
      );
    },
  );
}

class VisitScreen extends StatelessWidget {
  const VisitScreen({super.key, required this.store, required this.visitId});
  final DemoStore store;
  final String visitId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final visit = store.visits.where((v) => v.id == visitId).firstOrNull;
      final allowed = visit != null && store.canAccessVisit(visit);
      if (!allowed) {
        return const MobilePage(
          title: 'Access denied',
          children: [
            EmptyState(
              title: 'This visit belongs to another party',
              message: 'Use a valid invitation to join a current visit.',
            ),
          ],
        );
      }
      final v = visit;
      final table = store.tables.firstWhere((t) => t.id == v.tableId);
      final orders = store.visitOrders(v.id);
      final requests = store.visibleRequests.where((r) => r.visitId == v.id);
      final pending = store.attempts
          .where((a) => a.visitId == v.id && a.status == AttemptStatus.pending)
          .firstOrNull;
      return MobilePage(
        title: 'Your table visit',
        children: [
          Text(table.label, style: Theme.of(context).textTheme.headlineSmall),
          Text(
            store.restaurants.firstWhere((r) => r.id == v.restaurantId).name,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(
                v.active ? 'Active visit' : 'Visit closed',
                icon: Icons.table_restaurant_outlined,
              ),
              StatusBadge(
                '${v.guestCount} ${context.tr('guests')}',
                icon: Icons.people_outline,
              ),
            ],
          ),
          Section(
            title: 'Your party',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in v.participantIds)
                  Chip(
                    avatar: const Icon(Icons.person_outline),
                    label: Text(
                      store.accounts
                              .where((a) => a.id == id)
                              .firstOrNull
                              ?.name ??
                          context.tr('Guest party'),
                    ),
                  ),
              ],
            ),
          ),
          if (v.active) ...[
            SelectableText(
              '${context.tr('Visit invitation')}: ${v.invitation}',
            ),
            Text(
              '${context.tr('Expires')}: ${v.invitationExpiresAt.toLocal()}',
            ),
            FilledButton.icon(
              onPressed: () {
                store.selectRestaurant(v.restaurantId);
                store.configureCart(mode: ServiceMode.dineIn, visitId: v.id);
                openPage(context, RestaurantScreen(store: store));
              },
              icon: const Icon(Icons.add),
              label: Text(
                context.tr(
                  orders.isEmpty ? 'Browse and order' : 'Order another round',
                ),
              ),
            ),
          ],
          Section(
            title: 'Orders at this table',
            child: Column(
              children: [
                if (orders.isEmpty)
                  Text(context.tr('Your first round will appear here.')),
                for (final order in orders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      store: store,
                      order: order,
                      onTap: () => openPage(
                        context,
                        OrderDetailScreen(store: store, orderId: order.id),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Section(
            title: 'Shared table bill',
            child: AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final order in orders)
                    PriceRow(order.id, order.cancelled ? 0 : order.totalMinor),
                  const Divider(),
                  PriceRow(
                    'Captured',
                    orders.fold<int>(0, (s, o) => s + store.orderPaid(o.id)),
                  ),
                  PriceRow('Balance', store.visitBalance(v.id), total: true),
                  if (pending != null)
                    AppNotice(
                      title: context.tr('Payment in progress'),
                      message: context.tr(
                        'Only the frozen amount is reserved. Another round will remain separately payable.',
                      ),
                      action: pending.accountId == store.currentAccount.id
                          ? TextButton(
                              onPressed: () => openPage(
                                context,
                                PaymentScreen(
                                  store: store,
                                  attemptId: pending.id,
                                ),
                              ),
                              child: Text(context.tr('Resume checkout')),
                            )
                          : null,
                    ),
                  if (v.active &&
                      store.visitBalance(v.id) > 0 &&
                      pending == null)
                    FilledButton(
                      onPressed: () => guarded(context, () {
                        final a = store.beginVisitPayment(v.id);
                        openPage(
                          context,
                          PaymentScreen(
                            store: store,
                            attemptId: a.id,
                            autoResolve: true,
                          ),
                        );
                      }),
                      child: Text(context.tr('Pay this bill')),
                    ),
                ],
              ),
            ),
          ),
          if (v.active)
            Section(
              title: 'Need something?',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in [
                    'Water',
                    'Cutlery',
                    'Waiter assistance',
                    'Bill',
                  ])
                    ActionChip(
                      avatar: Icon(
                        kind == 'Water'
                            ? Icons.water_drop_outlined
                            : kind == 'Bill'
                            ? Icons.receipt_long_outlined
                            : Icons.room_service_outlined,
                      ),
                      label: Text(context.tr(kind)),
                      onPressed: () => guarded(
                        context,
                        () => store.requestService(kind, visitId: v.id),
                      ),
                    ),
                ],
              ),
            ),
          for (final request in requests)
            Card(
              child: ListTile(
                title: Text(context.tr(request.kind)),
                subtitle: Text(context.tr(request.status.name)),
                trailing: request.status == RequestStatus.sent
                    ? IconButton(
                        tooltip: context.tr('Cancel request'),
                        onPressed: () => guarded(
                          context,
                          () => store.transitionRequest(
                            request.id,
                            RequestStatus.cancelled,
                            reason: 'No longer needed',
                          ),
                        ),
                        icon: const Icon(Icons.close),
                      )
                    : const Icon(Icons.room_service_outlined),
              ),
            ),
          if (v.active)
            Text(
              context.tr(
                store.canCloseVisit(v.id)
                    ? 'This visit can be closed by staff.'
                    : 'Staff can close this visit after all orders and balances are resolved.',
              ),
            ),
        ],
      );
    },
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({
    super.key,
    required this.store,
    this.chooseForDelivery = false,
  });
  final DemoStore store;
  final bool chooseForDelivery;
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => MobilePage(
      title: widget.chooseForDelivery
          ? 'Delivery address'
          : 'Your neighborhood',
      children: [
        SchematicMap(),
        Text(
          context.tr(
            'Manual location works without device permission. Demo delivery is available in Demo Central.',
          ),
        ),
        for (final address in widget.store.currentAccount.addresses)
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${address.street}, ${address.city}'),
                if (address.instructions.isNotEmpty) Text(address.instructions),
                if (!address.eligible)
                  StatusBadge(
                    'Outside service area',
                    icon: Icons.location_off_outlined,
                  ),
                if (address.isDefault)
                  StatusBadge(
                    'Default address',
                    icon: Icons.check_circle_outline,
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: !address.eligible
                          ? null
                          : () {
                              widget.store.configureCart(addressId: address.id);
                              Navigator.pop(context);
                            },
                      child: Text(context.tr('Use this address')),
                    ),
                    TextButton(
                      onPressed: () => openPage(
                        context,
                        AddressEditor(store: widget.store, address: address),
                      ),
                      child: Text(context.tr('Edit')),
                    ),
                    IconButton(
                      tooltip: context.tr('Delete address'),
                      onPressed: () async {
                        if (await confirmAction(
                              context,
                              'Delete address?',
                              'This saved address will be removed from this demo account.',
                            ) &&
                            context.mounted) {
                          guarded(
                            context,
                            () => widget.store.deleteAddress(address.id),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (widget.store.currentAccount.addresses.isEmpty)
          const EmptyState(
            title: 'Where should we bring it?',
            message: 'Add a local demo address to check the service area.',
          ),
        FilledButton.icon(
          onPressed: () =>
              openPage(context, AddressEditor(store: widget.store)),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(context.tr('Add an address')),
        ),
      ],
    ),
  );
}

class AddressEditor extends StatefulWidget {
  const AddressEditor({super.key, required this.store, this.address});
  final DemoStore store;
  final Address? address;
  @override
  State<AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends State<AddressEditor> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(
        text: widget.address?.label ?? 'Home',
      ),
      _street = TextEditingController(text: widget.address?.street ?? ''),
      _city = TextEditingController(
        text: widget.address?.city ?? 'Demo Central',
      ),
      _instructions = TextEditingController(
        text: widget.address?.instructions ?? '',
      );
  bool _dirty = false, _saved = false, _default = true;
  String? _error;
  @override
  void dispose() {
    for (final c in [_label, _street, _city, _instructions]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DraftGuard(
    dirty: _dirty && !_saved,
    child: MobilePage(
      title: 'Edit address',
      children: [
        Form(
          key: _form,
          onChanged: () => setState(() => _dirty = true),
          child: Column(
            children: [
              for (final entry in [
                ('Label', _label),
                ('Street and number', _street),
                ('City', _city),
                ('Delivery instructions', _instructions),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: entry.$2,
                    decoration: InputDecoration(
                      labelText: context.tr(entry.$1),
                    ),
                    validator: (v) =>
                        entry.$1 != 'Delivery instructions' &&
                            (v?.trim().length ?? 0) < 2
                        ? context.tr('Please enter at least two characters')
                        : null,
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('Use as default')),
                value: _default,
                onChanged: (v) => setState(() => _default = v),
              ),
            ],
          ),
        ),
        Text(
          context.tr(
            'Use Demo Central for an eligible fixture address. Other cities return an out-of-area result.',
          ),
        ),
        if (_error != null)
          AppNotice(
            title: context.tr('Address needs attention'),
            message: context.tr(_error!),
          ),
        FilledButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;
            try {
              final eligible =
                  _city.text.trim().toLowerCase() == 'demo central';
              widget.store.saveAddress(
                Address(
                  id:
                      widget.address?.id ??
                      'address-${widget.store.now.microsecondsSinceEpoch}-${widget.store.currentAccount.addresses.length}',
                  label: _label.text.trim(),
                  street: _street.text.trim(),
                  city: _city.text.trim(),
                  instructions: _instructions.text.trim(),
                  isDefault: _default,
                  eligible: eligible,
                ),
              );
              setState(() => _saved = true);
              await Future<void>.delayed(Duration.zero);
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              setState(() => _error = e.toString());
            }
          },
          child: Text(context.tr('Save address')),
        ),
      ],
    ),
  );
}

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  late String _slot =
      widget.store.currentRestaurant.pickupSlots.firstOrNull ?? '';
  final _contact = TextEditingController();
  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Pickup details',
    children: [
      Text(
        widget.store.currentRestaurant.name,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(widget.store.currentRestaurant.address),
      Text(widget.store.currentRestaurant.hours),
      if (!widget.store.isRestaurantOpen(widget.store.currentRestaurant))
        const AppNotice(
          title: 'Pickup unavailable',
          message: 'The restaurant is currently closed. Keep your cart and try again later.',
        ),
      Section(
        title: 'Choose a slot',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in widget.store.currentRestaurant.pickupSlots)
              ChoiceChip(
                label: Text(context.tr(s)),
                selected: _slot == s,
                onSelected: (_) => setState(() => _slot = s),
              ),
            Chip(label: Text(context.tr('Tonight · unavailable'))),
          ],
        ),
      ),
      TextField(
        controller: _contact,
        decoration: InputDecoration(
          labelText: context.tr('Pickup name'),
          hintText: widget.store.currentAccount.name,
        ),
      ),
      FilledButton(
        onPressed: widget.store.isRestaurantOpen(widget.store.currentRestaurant)
            ? () => guarded(context, () {
                if (_contact.text.trim().isNotEmpty) {
                  widget.store.updateProfile(name: _contact.text.trim());
                }
                widget.store.configureCart(
                  pickupSlot: _slot,
                  mode: ServiceMode.pickup,
                );
                Navigator.pop(context);
              })
            : null,
        child: Text(context.tr('Confirm pickup details')),
      ),
    ],
  );
}

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  int _guests = 2, _day = 1, _hour = 19;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final selectedDay = store.now.add(Duration(days: _day));
      bool slotAvailable(int hour) => store.isRestaurantOpen(
        store.currentRestaurant,
        at: DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          hour,
        ),
      );
      return MobilePage(
        title: 'Reservations',
        children: [
          DropdownButtonFormField<String>(
            initialValue: store.currentRestaurant.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.tr('Restaurant')),
            items: store.restaurants
                .where((r) => r.published)
                .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                .toList(),
            onChanged: (id) {
              if (id != null) setState(() => store.selectRestaurant(id));
            },
          ),
          Section(
            title: 'Party size',
            child: QuantityStepper(
              value: _guests,
              max: 8,
              onChanged: (v) => setState(() => _guests = v),
            ),
          ),
          Section(
            title: 'Day',
            child: Wrap(
              spacing: 8,
              children: [
                for (final d in [1, 2, 3])
                  ChoiceChip(
                    label: Text(
                      '${store.now.add(Duration(days: d)).day}/${store.now.add(Duration(days: d)).month}',
                    ),
                    selected: _day == d,
                    onSelected: (_) => setState(() => _day = d),
                  ),
              ],
            ),
          ),
          Section(
            title: 'Available demo slots',
            child: Wrap(
              spacing: 8,
              children: [
                for (final h in [12, 13, 19, 20])
                  ChoiceChip(
                    label: Text('$h:00'),
                    selected: _hour == h,
                    onSelected: slotAvailable(h)
                        ? (_) => setState(() => _hour = h)
                        : null,
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: !slotAvailable(_hour)
                ? null
                : () => guarded(context, () {
                    final day = store.now.add(Duration(days: _day));
                    store.bookReservation(
                      restaurantId: store.currentRestaurant.id,
                      at: DateTime(day.year, day.month, day.day, _hour),
                      guests: _guests,
                    );
                    showMessage(context, 'Reservation saved locally');
                  }),
            child: Text(context.tr('Book a demo table')),
          ),
          Section(
            title: 'Your reservations',
            child: Column(
              children: [
                for (final r in store.visibleReservations)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.restaurants
                                .firstWhere((x) => x.id == r.restaurantId)
                                .name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${r.at.day}/${r.at.month} · ${r.at.hour}:00 · ${r.guests} ${context.tr('guests')}',
                          ),
                          StatusBadge(
                            r.status.name,
                            icon: Icons.event_available_outlined,
                          ),
                          if (r.status == ReservationStatus.confirmed)
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () => guarded(
                                    context,
                                    () => store.modifyReservation(
                                      r.id,
                                      at: r.at.add(const Duration(hours: 1)),
                                    ),
                                  ),
                                  child: Text(
                                    context.tr('Move one hour later'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (await confirmAction(
                                          context,
                                          'Cancel reservation?',
                                          'This demo booking will be cancelled.',
                                        ) &&
                                        context.mounted) {
                                      guarded(
                                        context,
                                        () => store.cancelReservation(r.id),
                                      );
                                    }
                                  },
                                  child: Text(context.tr('Cancel')),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  int _guests = 2;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store,
          entries = store.waitlist
              .where(
                (w) =>
                    w.accountId == store.currentAccount.id &&
                    w.restaurantId == store.currentRestaurant.id,
              )
              .toList();
      return MobilePage(
        title: 'Waitlist',
        children: [
          Text(
            store.currentRestaurant.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            context.tr(
              'Queue positions and notifications are simulated on this device.',
            ),
          ),
          QuantityStepper(
            value: _guests,
            max: 8,
            onChanged: (v) => setState(() => _guests = v),
          ),
          FilledButton(
            onPressed:
                !store.isRestaurantOpen(store.currentRestaurant) ||
                    entries.any((w) => w.active)
                ? null
                : () => guarded(
                    context,
                    () => store.joinWaitlist(guests: _guests),
                  ),
            child: Text(context.tr('Join the waitlist')),
          ),
          if (!store.isRestaurantOpen(store.currentRestaurant))
            Text(
              context.tr(
                'The waitlist is unavailable while this restaurant is closed.',
              ),
            ),
          for (final e in entries)
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.active
                        ? '${context.tr('Position')} ${store.waitlist.where((w) => w.active && w.restaurantId == e.restaurantId).toList().indexWhere((w) => w.id == e.id) + 1}'
                        : context.tr('Left waitlist'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('${e.guests} ${context.tr('guests')}'),
                  if (e.notified)
                    StatusBadge(
                      'Table-ready notification received',
                      icon: Icons.notifications_active_outlined,
                    ),
                  if (e.active)
                    OutlinedButton(
                      onPressed: () =>
                          guarded(context, () => store.leaveWaitlist(e.id)),
                      child: Text(context.tr('Leave waitlist')),
                    ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Notifications',
      children: [
        if (store.visibleNotifications.isEmpty)
          const EmptyState(
            title: 'You’re up to date',
            message: 'Order and visit updates will appear here.',
          ),
        for (final n in store.visibleNotifications)
          Card(
            child: ListTile(
              leading: Icon(
                n.read
                    ? Icons.notifications_none
                    : Icons.notifications_active_outlined,
              ),
              title: Text(n.title),
              subtitle: Text(n.body),
              onTap: () {
                store.markNotificationRead(n.id);
                final order = store.visibleOrders
                    .where(
                      (o) => o.id == n.target || n.target.endsWith('/${o.id}'),
                    )
                    .firstOrNull;
                if (order != null) {
                  openPage(
                    context,
                    OrderDetailScreen(store: store, orderId: order.id),
                  );
                } else {
                  showAppSheet(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(n.body),
                      ],
                    ),
                  );
                }
              },
              trailing: IconButton(
                tooltip: context.tr('Dismiss notification'),
                onPressed: () => store.dismissNotification(n.id),
                icon: const Icon(Icons.close),
              ),
            ),
          ),
      ],
    ),
  );
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.store, this.orderId});
  final DemoStore store;
  final String? orderId;
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _message = TextEditingController();
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    guarded(
      context,
      () =>
          widget.store.addSupportMessage(text.trim(), orderId: widget.orderId),
    );
    _message.clear();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => MobilePage(
      title: 'Restaurant conversation',
      children: [
        Text(
          context.tr(
            'Local support preview. Replies are simulated; no message leaves this device.',
          ),
        ),
        if (widget.orderId != null)
          Text('${context.tr('Order')}: ${widget.orderId}'),
        for (final m in widget.store.supportMessages.where(
          (m) =>
              m.accountId == widget.store.currentAccount.id &&
              m.orderId == widget.orderId,
        ))
          Align(
            alignment: m.fromSupport
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: AppPanel(
              color: m.fromSupport
                  ? Theme.of(context).colorScheme.surfaceContainer
                  : Theme.of(context).colorScheme.secondaryContainer,
              child: Text(m.text),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in [
              'Where is my order?',
              'Payment question',
              'Allergen information',
              'I still need help',
            ])
              ActionChip(label: Text(context.tr(s)), onPressed: () => _send(s)),
          ],
        ),
        TextField(
          controller: _message,
          maxLines: 3,
          decoration: InputDecoration(labelText: context.tr('Your message')),
          onSubmitted: _send,
        ),
        FilledButton.icon(
          onPressed: () => _send(_message.text),
          icon: const Icon(Icons.send_outlined),
          label: Text(context.tr('Add to local conversation')),
        ),
      ],
    ),
  );
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.store, required this.orderId});
  final DemoStore store;
  final String orderId;
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _note = TextEditingController();
  bool _saved = false;
  @override
  void initState() {
    super.initState();
    final old = widget.store.reviews
        .where(
          (r) =>
              r.orderId == widget.orderId &&
              r.accountId == widget.store.currentAccount.id,
        )
        .firstOrNull;
    if (old != null) {
      _rating = old.rating;
      _note.text = old.note;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Your feedback',
    children: [
      Text(
        context.tr('How was your meal?'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Wrap(
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              tooltip: '$i ${context.tr('stars')}',
              onPressed: () => setState(() {
                _rating = i;
                _saved = false;
              }),
              icon: Icon(i <= _rating ? Icons.star : Icons.star_border),
            ),
        ],
      ),
      TextField(
        controller: _note,
        maxLines: 4,
        decoration: InputDecoration(labelText: context.tr('Your local review')),
        onChanged: (_) => setState(() => _saved = false),
      ),
      FilledButton(
        onPressed: () => guarded(context, () {
          widget.store.saveReview(widget.orderId, _rating, _note.text);
          setState(() => _saved = true);
        }),
        child: Text(context.tr('Save feedback')),
      ),
      if (_saved)
        AppNotice(
          title: context.tr('Feedback saved on this device'),
          message: context.tr('It has not been published publicly.'),
        ),
    ],
  );
}
