part of 'connected_app.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key, required this.live});
  final LiveContext live;
  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  String search = '';
  String? mode;
  bool open = false;
  @override
  Widget build(BuildContext context) => rowsPage(
    widget.live,
    'Discover',
    'discovery',
    (c, row, refresh) => RaystoRestaurantCard(
      name: '${row['name']}',
      address: '${row['address']}',
      isOpen: row['open'] == true,
      modes: [
        for (final mode in row['modes'] as List? ?? []) friendly('$mode'),
      ],
      onTap: () => push(
        c,
        StorefrontPage(live: widget.live.tenant(row['id'], name: row['name'])),
      ),
    ),
    parameters: {
      if (search.isNotEmpty) 'q': search,
      if (mode != null) 'mode': mode,
      'openNow': open,
    },
    before: (c, d, refresh) => [
      const RaystoStoryHeader(
        eyebrow: 'Pull up a chair',
        title: 'Good food.\nGood company.',
        message: 'Find a new favorite, or go back to a place you love.',
        tableArt: true,
        compact: true,
      ),
      TextFormField(
        initialValue: search,
        decoration: const InputDecoration(
          labelText: 'Restaurant or dish',
          prefixIcon: Icon(Icons.search),
        ),
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (v) => setState(() => search = v.trim()),
      ),
      Wrap(
        spacing: 8,
        children: [
          for (final value in ['dineIn', 'pickup', 'delivery'])
            ChoiceChip(
              avatar: Icon(switch (value) {
                'dineIn' => Icons.table_restaurant_outlined,
                'pickup' => Icons.shopping_bag_outlined,
                _ => Icons.delivery_dining,
              }, size: 18),
              label: Text(friendly(value)),
              selected: mode == value,
              onSelected: (_) =>
                  setState(() => mode = mode == value ? null : value),
            ),
          FilterChip(
            label: const Text('Open now'),
            selected: open,
            onSelected: (v) => setState(() => open = v),
          ),
        ],
      ),
      RaystoActionCard(
        title: 'Scan table QR',
        subtitle: 'Already here? Your table is the starting point.',
        icon: Icons.qr_code_scanner,
        featured: true,
        onTap: () => perform(c, () => scanTable(c, widget.live)),
      ),
      const AppSectionTitle(title: 'Find your next favorite'),
    ],
  );
}

Future<void> scanTable(BuildContext c, LiveContext live) async {
  final payload = await push<String>(c, const QrCameraScreen());
  if (payload == null) return;
  final uri = Uri.tryParse(payload);
  String qr;
  if (uri != null &&
      uri.scheme == 'https' &&
      uri.host == 'rays.to' &&
      uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 't') {
    qr = uri.pathSegments.last;
  } else if (RegExp(r'^[a-zA-Z0-9_-]{30,100}$').hasMatch(payload)) {
    qr = payload;
  } else {
    throw const PlatformFailure('invalid_qr', 'Scan a Raysto table code.');
  }
  final result = await live.api.query('table.resolve', {'qr': qr});
  if (!c.mounted) return;
  final tenant = live.tenant(result['restaurantId']);
  await push(
    c,
    DataPage(
      title: 'Table ${result['label']}',
      load: () async => result,
      content: (c, d, refresh) => [
        const Text(
          'A table code identifies the table. Staff can confirm your seating or share a separate invitation to join the party.',
        ),
        AppButton(
          label: 'Start a visit',
          onPressed: () async {
            final visit = await tenant.action(
              c,
              'Confirm seating',
              'visit.start',
              typed: true,
              fixed: {'tableId': d['tableId']},
              fields: const [
                InputSpec('guestCount', 'Party size', kind: 'int', value: 1),
                InputSpec('seatingToken', 'Seating invitation', optional: true),
              ],
            );
            if (visit != null && c.mounted) {
              await push(c, visitPage(tenant, visit['id']));
            }
          },
        ),
        AppButton(
          label: 'Join with invitation',
          secondary: true,
          onPressed: () async {
            final visit = await tenant.action(
              c,
              'Join your party',
              'visit.join',
              fields: const [InputSpec('token', 'Invitation code')],
            );
            if (visit != null && c.mounted) {
              await push(c, visitPage(tenant, visit['visitId']));
            }
          },
        ),
        tile(
          'View menu',
          Icons.restaurant_menu,
          () => push(c, StorefrontPage(live: tenant)),
        ),
      ],
    ),
  );
}

class StorefrontPage extends StatefulWidget {
  const StorefrontPage({super.key, required this.live, this.visitId});
  final LiveContext live;
  final int? visitId;
  @override
  State<StorefrontPage> createState() => _StorefrontPageState();
}

class _StorefrontPageState extends State<StorefrontPage> {
  String? category;
  @override
  Widget build(BuildContext context) => DataPage(
    title: widget.live.name,
    load: () => widget.live.api.query('storefront', widget.live.params()),
    content: (c, d, refresh) {
      final menu = records(d['menu']);
      final currency = '${d['currency']}';
      final groups = menu.map((i) => '${i['category']}').toSet();
      return [
        RaystoStoryHeader(
          eyebrow: 'The menu · $currency',
          title: '${d['name']}',
          message: '${obj(d['settings'])['address'] ?? ''}',
          scene: RaystoScene.menu,
          compact: true,
          dark: true,
        ),
        AppButton(
          label: widget.visitId == null ? 'Open basket' : 'Order another round',
          icon: Icons.shopping_bag_outlined,
          onPressed: () => push(
            c,
            BasketPage(
              live: widget.live,
              storefront: d,
              visitId: widget.visitId,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final group in groups)
              ChoiceChip(
                label: Text(group),
                selected: category == group,
                onSelected: (_) =>
                    setState(() => category = category == group ? null : group),
              ),
          ],
        ),
        if (menu.isEmpty) empty('The menu is being prepared'),
        for (final item in menu.where(
          (i) => category == null || i['category'] == category,
        ))
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item['mediaId'] != null)
                  Image.network(
                    widget.live.api.origin
                        .resolve('/api/v2/media/${item['mediaId']}')
                        .toString(),
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['name']}',
                        style: Theme.of(c).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${item['description']}',
                        style: Theme.of(c).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      AppPill(label: money(item['priceMinor'], currency)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: AppButton(
                    label: 'Choose options',
                    onPressed: () => perform(c, () async {
                      final line = await chooseItem(c, item, currency);
                      if (line == null) return;
                      final cart = await widget.live.api.query(
                        'cart',
                        widget.live.params(),
                      );
                      if (!c.mounted) return;
                      final saved = await widget.live.action(
                        c,
                        'Add to basket',
                        'cart.save',
                        version: cart['version'],
                        fixed: {
                          'lines': [...records(cart['lines']), line],
                        },
                        submit: 'Add item',
                      );
                      if (saved != null && c.mounted) {
                        ScaffoldMessenger.of(c).showSnackBar(
                          const SnackBar(
                            content: Text('Added to your basket.'),
                          ),
                        );
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        tile(
          'Reserve a table',
          Icons.event_available,
          () => push(c, ReservationBooking(live: widget.live)),
        ),
        tile(
          'My reservations',
          Icons.event_note,
          () => push(c, reservationsPage(widget.live)),
        ),
        tile(
          'Join waiting list',
          Icons.hourglass_empty,
          () => widget.live.action(
            c,
            'Join waiting list',
            'waitlist.join',
            fields: const [
              InputSpec('partySize', 'Party size', kind: 'int', value: 2),
              InputSpec(
                'contact',
                'Contact details',
                kind: 'object',
                children: contactFields,
              ),
            ],
          ),
        ),
        tile(
          'Save restaurant',
          Icons.favorite_border,
          () => widget.live.action(
            c,
            'Save restaurant',
            'favorite.set',
            fixed: {'enabled': true},
          ),
        ),
        tile(
          'Ask the menu assistant',
          Icons.auto_awesome,
          () => push(c, aiHome(widget.live, customer: true)),
        ),
        if (records(d['reviews']).isNotEmpty)
          ExpansionTile(
            title: const Text('Customer reviews'),
            children: [
              for (final review in records(d['reviews']))
                ListTile(
                  title: Text('${review['rating']} / 5'),
                  subtitle: Text(
                    '${review['text']}\n${review['response'] ?? ''}',
                  ),
                ),
            ],
          ),
      ];
    },
  );
}

Future<Json?> chooseItem(
  BuildContext context,
  Json item,
  String currency,
) async {
  final selected = <String>{};
  var quantity = 1;
  final note = TextEditingController();
  String? error;
  try {
    return await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => StatefulBuilder(
        builder: (c, state) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: .75,
            builder: (_, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  '${item['name']}',
                  style: Theme.of(c).textTheme.headlineSmall,
                ),
                Text(money(item['priceMinor'], currency)),
                Text(
                  item['allergens'] == null
                      ? 'Allergen information is unknown. Ask the restaurant before ordering.'
                      : 'Allergens: ${(item['allergens'] as List).join(', ')}',
                ),
                for (final group in records(item['modifiers'])) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${group['name']} · choose ${group['min']}–${group['max']}',
                  ),
                  for (final option in records(group['options']))
                    CheckboxListTile(
                      title: Text('${option['name']}'),
                      subtitle: Text(money(option['priceMinor'], currency)),
                      value: selected.contains(
                        '${group['id']}:${option['id']}',
                      ),
                      onChanged: option['available'] == false
                          ? null
                          : (v) => state(() {
                              final key = '${group['id']}:${option['id']}';
                              if (v == true) {
                                selected.add(key);
                              } else {
                                selected.remove(key);
                              }
                            }),
                    ),
                ],
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Fewer',
                      onPressed: quantity <= 1
                          ? null
                          : () => state(() => quantity--),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$quantity'),
                    IconButton(
                      tooltip: 'More',
                      onPressed: quantity >= 20
                          ? null
                          : () => state(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                TextField(
                  controller: note,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Kitchen note (optional)',
                  ),
                ),
                if (error != null)
                  Text(
                    error!,
                    style: TextStyle(color: Theme.of(c).colorScheme.error),
                  ),
                AppButton(
                  label: 'Continue',
                  onPressed: () {
                    for (final group in records(item['modifiers'])) {
                      final count = selected
                          .where((k) => k.startsWith('${group['id']}:'))
                          .length;
                      if (count < group['min'] || count > group['max']) {
                        state(
                          () =>
                              error = 'Check the choices for ${group['name']}.',
                        );
                        return;
                      }
                    }
                    Navigator.pop(c, <String, dynamic>{
                      'productId': item['productId'],
                      'quantity': quantity,
                      'options': selected.toList(),
                      'note': note.text,
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } finally {
    note.dispose();
  }
}

class BasketPage extends StatelessWidget {
  const BasketPage({
    super.key,
    required this.live,
    required this.storefront,
    this.visitId,
  });
  final LiveContext live;
  final Json storefront;
  final int? visitId;
  @override
  Widget build(BuildContext context) => DataPage(
    title: 'Your basket',
    load: () => live.api.query('cart', live.params()),
    content: (c, d, refresh) => [
      if (records(d['lines']).isNotEmpty)
        const RaystoStoryHeader(
          eyebrow: 'Made for your moment',
          title: 'A good choice.',
          message: 'One last look before we get cooking. Final prices appear at checkout.',
          scene: RaystoScene.bag,
          compact: true,
        ),
      for (final line in records(d['lines']))
        ListTile(
          title: Text(
            '${records(storefront['menu']).where((i) => i['productId'] == line['productId']).firstOrNull?['name'] ?? 'Item'} × ${line['quantity']}',
          ),
          subtitle: Text('${line['note'] ?? ''}'),
          trailing: IconButton(
            tooltip: 'Remove item',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final lines = records(d['lines']);
              lines.removeWhere((l) => jsonEncode(l) == jsonEncode(line));
              await live.action(
                c,
                'Remove item',
                'cart.save',
                version: d['version'],
                fixed: {'lines': lines},
              );
              await refresh();
            },
          ),
        ),
      if (records(d['lines']).isEmpty)
        const RaystoEmptyState(
          title: 'Your basket is empty',
          message: 'Something delicious is waiting on the menu.',
          scene: RaystoScene.bag,
        )
      else
        AppButton(
          label: 'Review checkout',
          onPressed: () async {
            final details = await editFields(c, 'Order details', [
              InputSpec(
                'fulfillment',
                'How would you like your order?',
                options: List<String>.from(
                  obj(storefront['settings'])['modes'] as List,
                ),
                value: visitId == null ? 'pickup' : 'dineIn',
              ),
              if (visitId == null)
                const InputSpec(
                  'visitId',
                  'Visit reference for dine-in',
                  kind: 'int',
                  optional: true,
                ),
              const InputSpec(
                'address',
                'Delivery address',
                kind: 'object',
                optional: true,
                children: addressFields,
              ),
              const InputSpec(
                'slot',
                'Pickup time',
                kind: 'date',
                optional: true,
              ),
              const InputSpec('couponCode', 'Discount code', optional: true),
              const InputSpec('tipMinor', 'Tip', kind: 'money', value: 0),
            ], submit: 'Get final price');
            if (details == null || !c.mounted) return;
            await perform(c, () async {
              final quoteRequest = PendingCommand(
                'quote.create',
                live.params({
                  for (final entry in details.entries)
                    if (entry.key != 'address') entry.key: entry.value,
                  if (visitId != null) 'visitId': visitId,
                  'linesJson': jsonEncode(d['lines']),
                  if (details['address'] != null)
                    'addressJson': jsonEncode(details['address']),
                }),
              );
              // Keep the authoritative quote separate from editable cart data.
              final quote = await live.api.submit(quoteRequest);
              if (c.mounted) await push(c, QuotePage(live: live, quote: quote));
              await refresh();
            });
          },
        ),
    ],
  );
}

class QuotePage extends StatelessWidget {
  QuotePage({super.key, required this.live, required this.quote})
    : request = PendingCommand(
        'order.submit',
        live.params({'quoteId': quote['id']}),
      );
  final LiveContext live;
  final Json quote;
  final PendingCommand request;
  @override
  Widget build(BuildContext context) => DataPage(
    title: 'Review your order',
    load: () async => quote,
    content: (c, d, refresh) => [
      for (final line in records(d['lines']))
        ListTile(
          title: Text('${line['name']} × ${line['quantity']}'),
          trailing: Text(
            money(
              (line['unitPriceMinor'] as num) * (line['quantity'] as num),
              '${d['currency']}',
            ),
          ),
        ),
      RecordSummary({
        for (final key in [
          'fulfillment',
          'subtotalMinor',
          'discountMinor',
          'taxMinor',
          'deliveryFeeMinor',
          'tipMinor',
          'totalMinor',
          'currency',
          'paymentTiming',
          'expiresAt',
        ])
          key: d[key],
      }),
      AppButton(
        label: 'Place order',
        onPressed: () => perform(c, () async {
          final result = await live.api.submit(request);
          if (c.mounted) {
            Navigator.of(c).pushReplacement(
              MaterialPageRoute(
                builder: (_) => orderPage(live, result['orderId']),
              ),
            );
          }
        }),
      ),
    ],
  );
}

class ReservationBooking extends StatelessWidget {
  const ReservationBooking({super.key, required this.live});
  final LiveContext live;
  @override
  Widget build(BuildContext context) => RecordEditor(
    title: 'Reserve a table',
    submit: 'Check availability',
    initial: const {},
    fields: const [
      InputSpec('startsAt', 'Arrival date and time', kind: 'date'),
      InputSpec('partySize', 'Party size', kind: 'int', value: 2),
      InputSpec(
        'contact',
        'Contact details',
        kind: 'object',
        children: contactFields,
      ),
    ],
    save: (d) async {
      final available = await live.api.query(
        'availability',
        live.params({
          'startsAt': d['startsAt'],
          'partySize': d['partySize'],
          'mode': 'reservation',
        }),
      );
      final tables = records(available['rows']);
      if (tables.isEmpty) {
        throw const PlatformFailure(
          'unavailable',
          'No tables available at that time. Try another time.',
        );
      }
      if (!context.mounted) return {};
      await push(
        context,
        DataPage(
          title: 'Available tables',
          load: () async => available,
          content: (c, _, refresh) => [
            for (final table in tables)
              tile(
                'Table for ${table['capacity']}',
                Icons.table_restaurant_outlined,
                () => perform(c, () async {
                  final held = await live.action(
                    c,
                    'Hold this table',
                    'reservation.create',
                    fixed: {...d, 'tableId': table['tableId']},
                  );
                  if (held == null || !c.mounted) return;
                  await live.action(
                    c,
                    'Confirm reservation',
                    'reservation.transition',
                    id: held['id'],
                    version: held['version'],
                    fixed: {'status': 'confirmed'},
                  );
                  if (c.mounted) await push(c, reservationsPage(live));
                }),
              ),
          ],
        ),
      );
      return available;
    },
  );
}
