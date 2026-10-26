part of 'operations.dart';

class _More extends StatelessWidget {
  const _More({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => _List(
    children: [
      _Heading(
        store.currentAccount.name,
        subtitle:
            '${context.tr(_words(store.currentAccount.role))} · ${store.currentRestaurant.name}',
      ),
      if (_manager(store)) ...[
        _Link(
          'Setup checklist',
          'Review your restaurant readiness',
          Icons.checklist_outlined,
          () => openOperation(context, store, 'setup'),
        ),
        _Link(
          'Restaurant profile',
          'Identity, description and contact details',
          Icons.storefront_outlined,
          () => openOperation(context, store, 'restaurant'),
        ),
        _Link(
          'Services & hours',
          'Channels, preparation and temporary pauses',
          Icons.schedule_outlined,
          () => openOperation(context, store, 'services'),
        ),
        _Link(
          'Delivery settings',
          'Service area, fee and minimum order',
          Icons.delivery_dining_outlined,
          () => openOperation(context, store, 'delivery-settings'),
        ),
        if (_owner(store))
          _Link(
            'Payment policy',
            'Pay before or pay at end',
            Icons.payments_outlined,
            () => openOperation(context, store, 'payment-policy'),
          ),
        _Link(
          'Reservations & waitlist',
          'Arrivals, seating and waiting parties',
          Icons.event_seat_outlined,
          () => openOperation(context, store, 'reservations'),
        ),
        _Link(
          'Payments',
          'Attempts, collections and refunds',
          Icons.account_balance_wallet_outlined,
          () => openOperation(context, store, 'payments'),
        ),
        _Link(
          'Team',
          'Local invitations and table assignments',
          Icons.groups_outlined,
          () => openOperation(context, store, 'team'),
        ),
        _Link(
          'Reports',
          'Sales, captured payments and outstanding balances',
          Icons.bar_chart_outlined,
          () => openOperation(context, store, 'reports'),
        ),
        _Link(
          'Delivery desk',
          'Assign couriers and resolve delivery issues',
          Icons.local_shipping_outlined,
          () => openOperation(context, store, 'deliveries'),
        ),
        _Link(
          'Storefront preview',
          'Review and publish locally',
          Icons.visibility_outlined,
          () => openOperation(context, store, 'storefront'),
        ),
        if (_owner(store))
          _Link(
            'Plan preview',
            'Fictional subscription settings',
            Icons.workspace_premium_outlined,
            () => openOperation(context, store, 'billing'),
          ),
      ],
      _Link(
        'Notifications & activity',
        'Contextual updates from this restaurant',
        Icons.notifications_outlined,
        () => openOperation(context, store, 'notifications'),
      ),
      _Link(
        'Role & help',
        'Your permissions and local support',
        Icons.help_outline,
        () => openOperation(context, store, 'help'),
      ),
      if (store.currentAccount.role == DemoRole.courier)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.tr('Available for demo deliveries')),
          value: store.currentAccount.preferences['courierAvailable'] ?? true,
          onChanged: (value) => store.setPreference('courierAvailable', value),
        ),
      _Link(
        'App settings',
        'Language, appearance, notifications and demo accounts',
        Icons.settings_outlined,
        () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (context) => SettingsScreen(store: store)),
        ),
      ),
    ],
  );
}

class _Setup extends StatelessWidget {
  const _Setup({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) {
    final r = store.currentRestaurant;
    final tasks = <({String title, String subtitle, String route, bool done})>[
      (
        title: 'Restaurant identity',
        subtitle: 'Name, description and address',
        route: 'restaurant',
        done:
            r.name.isNotEmpty &&
            r.description.isNotEmpty &&
            r.address.isNotEmpty,
      ),
      (
        title: 'Services & hours',
        subtitle: 'Choose channels and opening times',
        route: 'services',
        done: r.services.isNotEmpty && r.hours.isNotEmpty,
      ),
      (
        title: 'Menu catalogue',
        subtitle: 'Add or import reviewed menu items',
        route: 'menu',
        done: store.restaurantMenu.isNotEmpty,
      ),
      (
        title: 'Tables & room',
        subtitle: 'Create tables and review their local QR codes',
        route: 'tables',
        done: store.restaurantTables.isNotEmpty,
      ),
      (
        title: 'Local storefront',
        subtitle: 'Approve the customer preview',
        route: 'storefront',
        done: r.published,
      ),
    ];
    final complete = tasks.where((t) => t.done).length;
    return _List(
      children: [
        _Heading(
          'Make it yours',
          subtitle: 'A local restaurant draft can be resumed at any time.',
        ),
        AppProgress(
          value: complete / tasks.length,
          label: '$complete / ${tasks.length} ${context.tr('complete')}',
        ),
        for (final task in tasks)
          _Link(
            task.title,
            task.subtitle,
            task.done
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            () => openOperation(context, store, task.route),
          ),
        if (_owner(store))
          OutlinedButton.icon(
            onPressed: () async {
              final name = await _ask(
                context,
                'Create demo restaurant',
                label: 'Restaurant name',
              );
              if (name != null && context.mounted) {
                _act(context, () => store.createRestaurantDraft(name));
              }
            },
            icon: const Icon(Icons.add_business_outlined),
            label: Text(context.tr('Create a restaurant draft')),
          ),
        Text(
          context.tr(
            'Publishing updates this installation only. No website, account or external service is created.',
          ),
        ),
      ],
    );
  }
}

class _RestaurantEditor extends StatefulWidget {
  const _RestaurantEditor({required this.store, required this.section});
  final DemoStore store;
  final String section;
  @override
  State<_RestaurantEditor> createState() => _RestaurantEditorState();
}

class _RestaurantEditorState extends State<_RestaurantEditor> {
  late final r = widget.store.currentRestaurant;
  late final name = TextEditingController(text: r.name),
      description = TextEditingController(text: r.description),
      address = TextEditingController(text: r.address),
      phone = TextEditingController(text: r.phone),
      hours = TextEditingController(text: r.hours),
      prep = TextEditingController(text: '${r.preparationMinutes}'),
      fee = TextEditingController(
        text: (r.deliveryFeeMinor / 100).toStringAsFixed(2),
      ),
      minimum = TextEditingController(
        text: (r.minimumDeliveryMinor / 100).toStringAsFixed(2),
      ),
      area = TextEditingController(text: r.serviceArea),
      deliverySlots = TextEditingController(text: r.deliverySlots.join(', ')),
      pickupSlots = TextEditingController(text: r.pickupSlots.join(', '));
  late String cover = r.cover;
  late String logo = r.logoAsset;
  late List<ServiceMode> services = List.of(r.services);
  late bool open = r.open,
      payAtEnd = r.payAtEnd,
      paypal = r.paypalConnected,
      guest = r.guestOrdering;
  bool dirty = false;
  final form = GlobalKey<FormState>();
  List<TextEditingController> get controllers => [
    name,
    description,
    address,
    phone,
    hours,
    prep,
    fee,
    minimum,
    area,
    deliverySlots,
    pickupSlots,
  ];
  @override
  void initState() {
    super.initState();
    for (final c in controllers) {
      c.addListener(() => setState(() => dirty = true));
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DraftGuard(
    dirty: dirty,
    child: Form(
      key: form,
      child: _List(
        children: [
          if (widget.section == 'restaurant') ...[
            _Heading(
              'Restaurant identity',
              subtitle: 'These details appear in the local customer preview.',
            ),
            _field(context, 'Restaurant name', name),
            _field(context, 'Description', description, lines: 3),
            _field(context, 'Address', address, lines: 2),
            _field(context, 'Contact phone', phone, type: TextInputType.phone),
            _Heading(
              'Restaurant logo',
              subtitle:
                  'Choose a bundled demo image for your restaurant avatar.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in {
                  'assets/images/salad_bowl.jpg': 'Garden bowl',
                  'assets/images/tomato_pasta.jpg': 'Tomato pasta',
                  'assets/images/wood_fired_pizza.jpg': 'Pizza',
                }.entries)
                  Semantics(
                    button: true,
                    selected: logo == entry.key,
                    label: context.tr(entry.value),
                    child: InkWell(
                      onTap: () => setState(() {
                        logo = entry.key;
                        dirty = true;
                      }),
                      borderRadius: BorderRadius.circular(48),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: logo == entry.key
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundImage: AssetImage(entry.key),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            _Heading('Cover photo'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final asset in [
                  'assets/images/salad_bowl.jpg',
                  'assets/images/tomato_pasta.jpg',
                  'assets/images/wood_fired_pizza.jpg',
                ])
                  InkWell(
                    onTap: () => setState(() {
                      cover = asset;
                      dirty = true;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: cover == asset
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          asset,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          semanticLabel: context.tr(
                            'Illustrative restaurant cover',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (widget.section == 'services') ...[
            _Heading(
              'How you serve',
              subtitle:
                  'A paused service blocks new orders while existing work remains visible.',
            ),
            for (final mode in ServiceMode.values)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr(_words(mode))),
                value: services.contains(mode),
                onChanged: (v) => setState(() {
                  v ? services.add(mode) : services.remove(mode);
                  dirty = true;
                }),
              ),
            _field(context, 'Opening hours', hours, lines: 2),
            _field(
              context,
              'Pickup slots, separated by commas',
              pickupSlots,
              lines: 2,
            ),
            Text(context.tr('Daily intervals: 11:00–14:00, 18:00–22:00.')),
            _field(
              context,
              'Preparation time in minutes',
              prep,
              type: TextInputType.number,
              validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                  ? null
                  : context.tr('Enter a positive number'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Open for new orders')),
              subtitle: Text(
                context.tr('Turn off for a temporary service pause'),
              ),
              value: open,
              onChanged: (v) => setState(() {
                open = v;
                dirty = true;
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Allow guest ordering')),
              value: guest,
              onChanged: (v) => setState(() {
                guest = v;
                dirty = true;
              }),
            ),
          ],
          if (widget.section == 'delivery-settings') ...[
            _Heading(
              'Delivery area',
              subtitle:
                  'Local eligibility uses the demo address setting; there is no live geolocation.',
            ),
            _field(context, 'Demo service area', area),
            _field(
              context,
              'Delivery slots, separated by commas',
              deliverySlots,
              lines: 2,
            ),
            _field(
              context,
              'Delivery fee in EUR',
              fee,
              type: const TextInputType.numberWithOptions(decimal: true),
              validator: _amountValidator,
            ),
            _field(
              context,
              'Minimum basket in EUR',
              minimum,
              type: const TextInputType.numberWithOptions(decimal: true),
              validator: _amountValidator,
            ),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Customer eligibility preview'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('Central demo address')}: ${context.tr('Eligible')}\n${context.tr('Outside demo area')}: ${context.tr('Pickup suggested')}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('Available slots')}: ${deliverySlots.text}',
                  ),
                ],
              ),
            ),
          ],
          if (widget.section == 'payment-policy') ...[
            _Heading(
              'Demo payment policy',
              subtitle:
                  'Demo checkout — no real payment. This setting changes when local orders are released.',
            ),
            RadioGroup<bool>(
              groupValue: payAtEnd,
              onChanged: (v) => setState(() {
                payAtEnd = v!;
                dirty = true;
              }),
              child: Column(
                children: [
                  RadioListTile(
                    value: false,
                    title: Text(context.tr('Pay before preparation')),
                    subtitle: Text(
                      context.tr(
                        'Only successful payment releases a new order.',
                      ),
                    ),
                  ),
                  RadioListTile(
                    value: true,
                    title: Text(context.tr('Pay at end for dine-in')),
                    subtitle: Text(
                      context.tr(
                        'Unpaid table orders may be accepted and prepared.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Demo PayPal connected')),
              subtitle: Text(
                context.tr(
                  'Local simulation only. No production account is connected.',
                ),
              ),
              value: paypal,
              onChanged: (v) => setState(() {
                paypal = v;
                dirty = true;
              }),
            ),
            _Card(
              child: Text(
                context.tr(
                  'Available local methods: Demo PayPal and authorized staff cash collection. Payment status never changes food preparation status.',
                ),
              ),
            ),
          ],
          AppButton(
            label: context.tr('Save changes'),
            onPressed: () {
              if (!form.currentState!.validate()) return;
              if (services.isEmpty) {
                _act(
                  context,
                  () => throw const DomainException(
                    'Select at least one service.',
                  ),
                );
                return;
              }
              _act(context, () {
                widget.store.saveRestaurant(
                  r.copyWith(
                    name: name.text.trim(),
                    description: description.text.trim(),
                    address: address.text.trim(),
                    phone: phone.text.trim(),
                    cover: cover,
                    logoAsset: logo,
                    hours: hours.text.trim(),
                    services: services,
                    preparationMinutes:
                        int.tryParse(prep.text) ?? r.preparationMinutes,
                    deliveryFeeMinor: ((double.tryParse(fee.text) ?? 0) * 100)
                        .round(),
                    minimumDeliveryMinor:
                        ((double.tryParse(minimum.text) ?? 0) * 100).round(),
                    serviceArea: area.text.trim(),
                    pickupSlots: pickupSlots.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toSet()
                        .toList(),
                    deliverySlots: deliverySlots.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toSet()
                        .toList(),
                    open: open,
                    payAtEnd: payAtEnd,
                    paypalConnected: paypal,
                    guestOrdering: guest,
                  ),
                );
                setState(() => dirty = false);
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    ),
  );
  String? _amountValidator(String? v) {
    final amount = double.tryParse(v ?? '');
    return amount == null || amount < 0 ? 'Enter a non-negative amount' : null;
  }
}

class _Storefront extends StatelessWidget {
  const _Storefront({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) {
    final r = store.currentRestaurant;
    return _List(
      children: [
        AppMedia(
          asset: r.cover,
          semanticLabel: context.tr('Illustrative restaurant cover'),
          height: 200,
        ),
        _Heading(r.name, subtitle: r.description),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Semantics(
            label: context.tr('Restaurant logo'),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(r.logoAsset),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(
              r.published ? 'Published locally' : 'Draft only',
              icon: Icons.visibility_outlined,
            ),
            _Badge(
              store.isRestaurantOpen(r) ? 'Service open' : 'Closed',
              icon: Icons.schedule_outlined,
            ),
          ],
        ),
        Text(r.address),
        Text(r.hours),
        Text(r.services.map((m) => context.tr(_words(m))).join(' · ')),
        _Heading('Customer menu'),
        for (final item in store.restaurantMenu)
          _Card(
            onTap: () =>
                showAppSheet<void>(context, child: _ItemPreview(item: item)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailLine(item.name, _money(context, item.priceMinor)),
                Text(item.description),
                if (!item.available) _Badge('Unavailable', icon: Icons.block),
              ],
            ),
          ),
        AppButton(
          label: context.tr(
            r.published ? 'Unpublish locally' : 'Publish locally',
          ),
          onPressed: () async {
            if (await _confirm(
                  context,
                  r.published
                      ? 'Unpublish this restaurant?'
                      : 'Publish this restaurant?',
                  'This changes the local demo storefront only. No public website is deployed.',
                  action: r.published ? 'Unpublish' : 'Publish locally',
                ) &&
                context.mounted) {
              _act(context, () => store.publishRestaurant(!r.published));
            }
          },
        ),
      ],
    );
  }
}

class _Payments extends StatefulWidget {
  const _Payments({required this.store});
  final DemoStore store;
  @override
  State<_Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<_Payments> {
  String filter = 'All';
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final report = s.report();
    final attempts =
        s.attempts
            .where(
              (a) =>
                  a.restaurantId == s.currentRestaurant.id &&
                  (filter == 'All' || a.status.name == filter),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _List(
      children: [
        _Heading(
          'Payment records',
          subtitle: 'Demo checkout — no real payment.',
        ),
        _Card(
          tonal: true,
          child: Column(
            children: [
              _DetailLine('Captured', _money(context, report.capturedMinor)),
              _DetailLine('Refunded', _money(context, report.refundedMinor)),
              _DetailLine(
                'Outstanding',
                _money(context, report.outstandingMinor),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in [
              'All',
              'pending',
              'succeeded',
              'failed',
              'cancelled',
            ])
              FilterChip(
                label: Text(context.tr(f)),
                selected: filter == f,
                onSelected: (_) => setState(() => filter = f),
              ),
          ],
        ),
        if (attempts.isEmpty)
          _Empty(
            title: context.tr('No matching attempts'),
            message: context.tr(
              'New checkouts will appear here, including failed and pending attempts.',
            ),
          ),
        for (final a in attempts)
          _Card(
            onTap: () => _attempt(context, s, a),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(
                  _words(a.status),
                  icon: Icons.payments_outlined,
                  attention: a.status == AttemptStatus.pending,
                ),
                const SizedBox(height: 10),
                Text(a.id, style: Theme.of(context).textTheme.titleMedium),
                _DetailLine(a.method, _money(context, a.totalMinor)),
                Text('${_date(a.createdAt)} · ${_time(a.createdAt)}'),
              ],
            ),
          ),
        _Heading('Refunds'),
        for (final refund in s.refunds.where(
          (r) => r.restaurantId == s.currentRestaurant.id,
        ))
          _Link(
            refund.orderId,
            '${_money(context, refund.amountMinor)} · ${refund.reason}',
            Icons.undo,
            () => openOperation(context, s, 'order', id: refund.orderId),
          ),
      ],
    );
  }
}

Future<void> _attempt(
  BuildContext context,
  DemoStore s,
  CheckoutAttempt a,
) async {
  await showAppSheet<void>(
    context,
    child: ListenableBuilder(
      listenable: s,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading('Checkout attempt', subtitle: a.id),
          const SizedBox(height: 12),
          _Badge(_words(a.status), icon: Icons.payments_outlined),
          _DetailLine('Frozen total', _money(context, a.totalMinor)),
          Text(context.tr('Demo checkout — no real payment.')),
          for (final line in a.snapshot.lines)
            _DetailLine(
              '${line.quantity} × ${line.name}',
              _money(context, line.subtotalMinor),
            ),
          for (final entry in a.allocations.entries)
            _DetailLine(entry.key, _money(context, entry.value)),
          if (a.orderId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openOperation(context, s, 'order', id: a.orderId);
              },
              child: Text(context.tr('Open order')),
            ),
          if (a.status == AttemptStatus.pending) ...[
            const SizedBox(height: 16),
            Text(context.tr('Resolve this pending demo event:')),
            for (final outcome in [
              PaymentOutcome.success,
              PaymentOutcome.failed,
              PaymentOutcome.cancelled,
            ])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: () =>
                      _act(context, () => s.resolvePayment(a.id, outcome)),
                  child: Text(context.tr(_words(outcome))),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class _Team extends StatelessWidget {
  const _Team({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => _List(
    children: [
      _Heading(
        'Your team',
        subtitle: 'Invitations and assignments are saved in this demo only.',
      ),
      AppButton(
        label: context.tr('Create local invitation'),
        icon: Icons.person_add_outlined,
        onPressed: () => _invite(context, store),
      ),
      for (final person in store.accounts.where(
        (a) => a.restaurantId == store.currentRestaurant.id && a.isStaff,
      ))
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: Theme.of(context).textTheme.titleLarge),
              Text(person.email),
              const SizedBox(height: 8),
              _Badge(_words(person.role), icon: Icons.badge_outlined),
              const SizedBox(height: 8),
              Text(_permissionDescription(person.role)),
              if (person.role == DemoRole.waiter)
                TextButton.icon(
                  onPressed: () => _assignTables(context, store, person),
                  icon: const Icon(Icons.table_restaurant_outlined),
                  label: Text(
                    '${context.tr('Table assignments')} (${person.assignedTableIds.length})',
                  ),
                ),
              if (person.id != store.currentAccount.id &&
                  person.role != DemoRole.owner)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.tr('Active account')),
                  value: person.active,
                  onChanged: (v) async {
                    if (v ||
                        await _confirm(
                          context,
                          'Deactivate this demo account?',
                          'Shared orders and historical records remain available.',
                          action: 'Deactivate',
                        )) {
                      if (context.mounted) {
                        _act(context, () => store.setTeamActive(person.id, v));
                      }
                    }
                  },
                ),
            ],
          ),
        ),
    ],
  );
}

String _permissionDescription(DemoRole role) => switch (role) {
  DemoRole.owner =>
    'Restaurant configuration, team, menu, operations, payments and fictional billing.',
  DemoRole.manager =>
    'Operations, menu, team and reports. Ownership and billing are restricted.',
  DemoRole.waiter =>
    'Assigned tables, assisted orders, service requests and explicit cash collection.',
  DemoRole.kitchen =>
    'Accepted tickets, preparation progress and menu availability.',
  DemoRole.courier =>
    'Assigned deliveries, pickup, progression and delivery issues.',
  _ => 'Personal customer records only.',
};
Future<void> _invite(BuildContext context, DemoStore store) async {
  final name = TextEditingController(), email = TextEditingController();
  var role = DemoRole.waiter;
  final key = GlobalKey<FormState>();
  await showAppSheet<void>(
    context,
    enableDrag: false,
    child: StatefulBuilder(
      builder: (context, update) => _InputDraft(
        controllers: [name, email],
        changed: role != DemoRole.waiter,
        child: Form(
          key: key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Heading(
                'Local invitation',
                subtitle:
                    'A fictional .test account is added locally. No email is sent.',
              ),
              const SizedBox(height: 16),
              _field(context, 'Name', name),
              const SizedBox(height: 16),
              _field(
                context,
                'Demo email',
                email,
                type: TextInputType.emailAddress,
                validator: (v) =>
                    (v ?? '').contains('@') && (v ?? '').endsWith('.test')
                    ? null
                    : context.tr('Use a fictional .test email'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DemoRole>(
                initialValue: role,
                decoration: InputDecoration(labelText: context.tr('Role')),
                items: [
                  for (final r in [
                    DemoRole.waiter,
                    DemoRole.kitchen,
                    DemoRole.courier,
                    DemoRole.manager,
                  ])
                    DropdownMenuItem(
                      value: r,
                      child: Text(context.tr(_words(r))),
                    ),
                ],
                onChanged: (v) => update(() => role = v!),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: context.tr('Save local invitation'),
                onPressed: () {
                  if (key.currentState!.validate()) {
                    _act(context, () {
                      store.inviteTeam(
                        name: name.text.trim(),
                        email: email.text.trim(),
                        role: role,
                      );
                      Navigator.pop(context);
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
  name.dispose();
  email.dispose();
}

Future<void> _assignTables(
  BuildContext context,
  DemoStore store,
  DemoAccount person,
) async {
  var selected = Set<String>.of(person.assignedTableIds);
  await showAppSheet<void>(
    context,
    enableDrag: false,
    child: StatefulBuilder(
      builder: (context, update) => _DraftGuard(
        dirty:
            selected.length != person.assignedTableIds.length ||
            !selected.containsAll(person.assignedTableIds),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Heading('Table assignments', subtitle: person.name),
            for (final table in store.restaurantTables)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(table.label),
                subtitle: Text(table.zone),
                value: selected.contains(table.id),
                onChanged: (v) => update(() {
                  v == true
                      ? selected.add(table.id)
                      : selected.remove(table.id);
                }),
              ),
            AppButton(
              label: context.tr('Save assignments'),
              onPressed: () => _act(context, () {
                store.assignStaff(person.id, selected.toList());
                Navigator.pop(context);
              }),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Reports extends StatefulWidget {
  const _Reports({required this.store});
  final DemoStore store;
  @override
  State<_Reports> createState() => _ReportsState();
}

class _ReportsState extends State<_Reports> {
  String period = 'Today';
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final start = period == 'All time'
        ? null
        : period == 'Last 7 days'
        ? s.now.subtract(const Duration(days: 7))
        : DateTime(s.now.year, s.now.month, s.now.day);
    final report = s.report(from: start);
    final orders = s.visibleOrders
        .where((o) => start == null || !o.createdAt.isBefore(start))
        .toList();
    final maxCount = math.max(
      1,
      report.channelCounts.values.fold<int>(0, math.max),
    );
    return _List(
      children: [
        _Heading(
          'Service reports',
          subtitle:
              'Derived from the same orders and money records used throughout the app.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in ['Today', 'Last 7 days', 'All time'])
              ChoiceChip(
                label: Text(context.tr(p)),
                selected: period == p,
                onSelected: (_) => setState(() => period = p),
              ),
          ],
        ),
        _Card(
          tonal: true,
          child: Column(
            children: [
              _DetailLine('Sales', _money(context, report.salesMinor)),
              _DetailLine('Orders', '${report.orderCount}'),
              _DetailLine(
                'Average order',
                _money(context, report.averageMinor),
              ),
              _DetailLine(
                'Captured payments',
                _money(context, report.capturedMinor),
              ),
              _DetailLine('Refunds', _money(context, report.refundedMinor)),
              _DetailLine(
                'Outstanding',
                _money(context, report.outstandingMinor),
              ),
            ],
          ),
        ),
        _Heading('Channel mix'),
        _Card(
          child: Column(
            children: [
              for (final entry in report.channelCounts.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Semantics(
                    label:
                        '${context.tr(_words(entry.key))}: ${entry.value} ${context.tr('orders')}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailLine(_words(entry.key), '${entry.value}'),
                        LinearProgressIndicator(
                          value: entry.value / maxCount,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Heading('Top items'),
        for (final entry in report.topItems.entries)
          _DetailLine(entry.key, '${entry.value} ${context.tr('sold')}'),
        _Heading('Underlying orders'),
        if (orders.isEmpty) Text(context.tr('No orders in this period.')),
        ...orders.map((o) => _OrderCard(store: s, order: o)),
      ],
    );
  }
}

class _Reservations extends StatefulWidget {
  const _Reservations({required this.store});
  final DemoStore store;
  @override
  State<_Reservations> createState() => _ReservationsState();
}

class _ReservationsState extends State<_Reservations> {
  String filter = 'Upcoming';
  DateTime? day;
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final reservations =
        s.visibleReservations
            .where(
              (r) =>
                  (day == null || DateUtils.dateOnly(r.at) == day) &&
                  (filter == 'All' ||
                      [
                        ReservationStatus.confirmed,
                        ReservationStatus.arrived,
                      ].contains(r.status)),
            )
            .toList()
          ..sort((a, b) => a.at.compareTo(b.at));
    return _List(
      children: [
        _Heading(
          'Reservations & waitlist',
          subtitle:
              'Seat arrivals into a fresh visit. Previous bills never follow a new party.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: day ?? s.now,
                  firstDate: s.now.subtract(const Duration(days: 365)),
                  lastDate: s.now.add(const Duration(days: 365)),
                );
                if (selected != null && mounted) {
                  setState(() => day = DateUtils.dateOnly(selected));
                }
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                day == null ? context.tr('Choose date') : _date(day!),
              ),
            ),
            if (day != null)
              TextButton(
                onPressed: () => setState(() => day = null),
                child: Text(context.tr('All dates')),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final v in ['Upcoming', 'All'])
              ChoiceChip(
                label: Text(context.tr(v)),
                selected: filter == v,
                onSelected: (_) => setState(() => filter = v),
              ),
          ],
        ),
        if (reservations.isEmpty)
          _Empty(
            title: context.tr('No reservations here'),
            message: context.tr(
              'Customer bookings appear here with their selected time.',
            ),
          ),
        for (final r in reservations)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(_words(r.status), icon: Icons.event_outlined),
                const SizedBox(height: 12),
                Text(
                  '${r.guests} ${context.tr('guests')}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text('${_date(r.at)} · ${_time(r.at)}'),
                if (r.note.isNotEmpty) Text(r.note),
                if (r.status == ReservationStatus.confirmed)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppButton(
                      label: context.tr('Mark arrived'),
                      onPressed: () =>
                          _act(context, () => s.arriveReservation(r.id)),
                    ),
                  ),
                if (r.status == ReservationStatus.arrived)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppButton(
                      label: context.tr('Choose a table'),
                      onPressed: () => _seat(context, s, r.id, r.guests),
                    ),
                  ),
                if ([
                  ReservationStatus.confirmed,
                  ReservationStatus.arrived,
                ].contains(r.status))
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => _reschedule(context, s, r),
                        child: Text(context.tr('Modify')),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (await _confirm(
                                context,
                                'Cancel reservation?',
                                'This cancels the local booking.',
                                action: 'Cancel reservation',
                              ) &&
                              context.mounted) {
                            _act(context, () => s.cancelReservation(r.id));
                          }
                        },
                        child: Text(context.tr('Cancel')),
                      ),
                      TextButton(
                        onPressed: () =>
                            _act(context, () => s.noShowReservation(r.id)),
                        child: Text(context.tr('No-show')),
                      ),
                    ],
                  ),
                if (r.visitId != null)
                  TextButton(
                    onPressed: () =>
                        openOperation(context, s, 'visit', id: r.visitId),
                    child: Text(context.tr('Open seated visit')),
                  ),
              ],
            ),
          ),
        _Heading('Waiting parties'),
        for (final entry in s.waitlist.where(
          (w) => w.restaurantId == s.currentRestaurant.id && w.active,
        ))
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.guests} ${context.tr('guests')} · ${entry.accountId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${context.tr('Joined')} ${_time(entry.createdAt)}'),
                if (entry.notified)
                  _Badge(
                    'Notified locally',
                    icon: Icons.notifications_outlined,
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _act(context, () => s.notifyWaitlist(entry.id)),
                      child: Text(context.tr('Notify locally')),
                    ),
                    TextButton(
                      onPressed: () => _seat(
                        context,
                        s,
                        entry.id,
                        entry.guests,
                        waitlist: true,
                      ),
                      child: Text(context.tr('Seat party')),
                    ),
                    TextButton(
                      onPressed: () =>
                          _act(context, () => s.leaveWaitlist(entry.id)),
                      child: Text(context.tr('Remove')),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> _seat(
  BuildContext context,
  DemoStore store,
  String id,
  int guests, {
  bool waitlist = false,
}) async {
  final eligible = store.restaurantTables
      .where(
        (t) =>
            t.active && t.status == TableStatus.available && t.seats >= guests,
      )
      .toList();
  await showAppSheet<void>(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          'Seat this party',
          subtitle: 'Only available tables with enough seats are shown.',
        ),
        if (eligible.isEmpty)
          Text(context.tr('No eligible table is available.')),
        for (final table in eligible)
          ListTile(
            title: Text(table.label),
            subtitle: Text(
              '${table.seats} ${context.tr('seats')} · ${table.zone}',
            ),
            onTap: () => _act(context, () {
              if (waitlist) {
                store.seatWaitlist(id, table.id);
              } else {
                store.seatReservation(id, table.id);
              }
              Navigator.pop(context);
            }),
          ),
      ],
    ),
  );
}

Future<void> _reschedule(
  BuildContext context,
  DemoStore store,
  Reservation r,
) async {
  final day = await showDatePicker(
    context: context,
    initialDate: r.at.isBefore(store.now) ? store.now : r.at,
    firstDate: DateTime(store.now.year, store.now.month, store.now.day),
    lastDate: store.now.add(const Duration(days: 90)),
  );
  if (day == null || !context.mounted) return;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(r.at),
  );
  if (time != null && context.mounted) {
    _act(
      context,
      () => store.modifyReservation(
        r.id,
        at: DateTime(day.year, day.month, day.day, time.hour, time.minute),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => _List(
    children: [
      _Heading('Notifications'),
      if (store.visibleNotifications.isEmpty)
        Text(context.tr('No notifications for this account.')),
      for (final n in store.visibleNotifications)
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(
                n.read ? 'Read' : 'Unread',
                icon: Icons.notifications_outlined,
              ),
              const SizedBox(height: 8),
              Text(n.title, style: Theme.of(context).textTheme.titleMedium),
              Text(n.body),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () {
                      store.markNotificationRead(n.id);
                      _openTarget(
                        context,
                        store,
                        n.target,
                        title: n.title,
                        detail: n.body,
                      );
                    },
                    child: Text(context.tr('Open update')),
                  ),
                  TextButton(
                    onPressed: () => store.dismissNotification(n.id),
                    child: Text(context.tr('Dismiss')),
                  ),
                ],
              ),
            ],
          ),
        ),
      _Heading('Restaurant activity'),
      for (final event in store.visibleActivity.reversed)
        _Link(
          event.title,
          '${event.detail}\n${_date(event.createdAt)} · ${_time(event.createdAt)}',
          Icons.history,
          () => _openTarget(
            context,
            store,
            event.target,
            title: event.title,
            detail:
                '${event.detail}\n${_date(event.createdAt)} · ${_time(event.createdAt)}',
          ),
        ),
    ],
  );
}

void _openTarget(
  BuildContext context,
  DemoStore store,
  String target, {
  String title = 'Activity recorded',
  String detail = '',
}) {
  final parts = target
      .replaceAll('/', ':')
      .split(':')
      .where((v) => v.isNotEmpty)
      .toList();
  if (parts.length >= 2 &&
      [
        'order',
        'visit',
        'table',
        'delivery',
        'request',
      ].contains(parts.first)) {
    openOperation(context, store, parts.first, id: parts.last);
    return;
  }
  if (store.visibleOrders.any((o) => o.id == target)) {
    openOperation(context, store, 'order', id: target);
    return;
  }
  if (store.visits.any(
    (v) => v.id == target && v.restaurantId == store.currentRestaurant.id,
  )) {
    openOperation(context, store, 'visit', id: target);
    return;
  }
  if (store.visibleRequests.any((r) => r.id == target)) {
    openOperation(context, store, 'request', id: target);
    return;
  }
  if (store.visibleDeliveries.any((d) => d.id == target)) {
    openOperation(context, store, 'delivery', id: target);
    return;
  }
  if (store.restaurantTables.any((t) => t.id == target) &&
      _canAccess(store, 'table')) {
    openOperation(context, store, 'table', id: target);
    return;
  }
  if (store.restaurantMenu.any((i) => i.id == target)) {
    if (_manager(store)) {
      openOperation(context, store, 'item', id: target);
      return;
    }
    if (store.currentAccount.role == DemoRole.kitchen) {
      openOperation(context, store, 'availability');
      return;
    }
  }
  if (_manager(store) && store.visibleAttempts.any((a) => a.id == target)) {
    _attempt(
      context,
      store,
      store.visibleAttempts.firstWhere((a) => a.id == target),
    );
    return;
  }
  if (_manager(store) &&
      (store.visibleReservations.any((r) => r.id == target) ||
          store.waitlist.any(
            (w) =>
                w.id == target && w.restaurantId == store.currentRestaurant.id,
          ))) {
    openOperation(context, store, 'reservations');
    return;
  }
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.tr(title)),
      content: Text(
        detail.isEmpty
            ? context.tr('This update is part of the local restaurant history.')
            : context.tr(detail),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Done')),
        ),
      ],
    ),
  );
}

class _Billing extends StatelessWidget {
  const _Billing({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => _List(
    children: [
      _Heading(
        'Fictional plan preview',
        subtitle:
            'Changing this value never purchases, charges or enables a real service.',
      ),
      _Card(
        tonal: true,
        child: _DetailLine(
          'Current preview plan',
          store.currentRestaurant.plan,
        ),
      ),
      for (final plan in ['Starter', 'Service', 'Complete'])
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan, style: Theme.of(context).textTheme.titleLarge),
              Text(
                context.tr(
                  'Local demo plan. No invoice or payment is created.',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: store.currentRestaurant.plan == plan
                    ? null
                    : () async {
                        if (await _confirm(
                              context,
                              'Change fictional plan?',
                              'This only saves your preview selection.',
                              action: 'Use this preview',
                            ) &&
                            context.mounted) {
                          _act(
                            context,
                            () => store.saveRestaurant(
                              store.currentRestaurant.copyWith(plan: plan),
                            ),
                          );
                        }
                      },
                child: Text(
                  context.tr(
                    store.currentRestaurant.plan == plan
                        ? 'Selected'
                        : 'Preview this plan',
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _RoleHelp extends StatelessWidget {
  const _RoleHelp({required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => _List(
    children: [
      _Heading('Your role', subtitle: store.currentAccount.name),
      _Badge(_words(store.currentAccount.role), icon: Icons.badge_outlined),
      Text(context.tr(_permissionDescription(store.currentAccount.role))),
      _DetailLine('Restaurant', store.currentRestaurant.name),
      if (store.currentAccount.role == DemoRole.waiter) ...[
        _Heading('Assigned tables'),
        for (final id in store.currentAccount.assignedTableIds)
          _Link(
            store.tables.where((t) => t.id == id).firstOrNull?.label ?? id,
            'Open live table',
            Icons.table_restaurant_outlined,
            () => _openTable(context, store, id),
          ),
      ],
      _Heading('Quick help'),
      for (final help in <String, String>{
        'How do I switch roles?':
            'Open app settings and choose Explore demo accounts. Shared restaurant work remains saved.',
        'Why can I not close a visit?':
            'Resolve all actionable orders and the outstanding balance first. Closing moves the table to needs-reset.',
        'What is simulated?':
            'All accounts, orders, payments, notifications, conversations and deliveries remain in this installation.',
        'How does the kitchen timer work?':
            'Elapsed labels use the controllable demo clock. Advance time from demo controls.',
      }.entries)
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(context.tr(help.key)),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(context.tr(help.value)),
            ),
          ],
        ),
      _Heading('Appearance and notifications'),
      Text(
        context.tr(
          'Use the app settings button for language, dark theme, text size, notification simulation and reduced motion.',
        ),
      ),
    ],
  );
}
