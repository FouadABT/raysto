part of 'connected_app.dart';

Widget teamsHome(LiveContext live) => DataPage(
  title: 'Your restaurants',
  load: () => live.api.query('me'),
  content: (c, d, refresh) => [
    const RaystoStoryHeader(
      eyebrow: 'Behind the pass',
      title: 'Make room for\nsomething good.',
      message: 'Your restaurants, your people, your next service.',
      scene: RaystoScene.kitchen,
      compact: true,
      dark: true,
    ),
    for (final membership in records(d['memberships']))
      tile(
        '${membership['name'] ?? 'Restaurant ${membership['restaurantId']}'}',
        Icons.storefront,
        () => push(
          c,
          restaurantHome(
            live.tenant(
              membership['restaurantId'],
              role: membership['role'],
              name: membership['name'],
            ),
          ),
        ),
        subtitle: friendly('${membership['role']}'),
      ),
    if (records(d['memberships']).isEmpty)
      empty('You have no restaurant memberships yet'),
    AppButton(
      label: 'Create my restaurant',
      icon: Icons.add_business,
      onPressed: () async {
        final result = await live.action(
          c,
          'Create restaurant',
          'restaurant.create',
          fields: const [
            InputSpec('name', 'Restaurant name'),
            InputSpec('currency', 'Currency', options: ['EUR', 'USD', 'GBP']),
          ],
        );
        if (result != null && c.mounted) {
          await push(
            c,
            restaurantHome(live.tenant(result['id'], role: 'owner')),
          );
        }
        await refresh();
      },
    ),
  ],
);

Widget restaurantHome(LiveContext live) => DataPage(
  title: live.name,
  load: () => live.api.query('me'),
  content: (c, d, refresh) {
    final current = records(d['memberships'])
        .where((m) => m['restaurantId'] == live.restaurantId)
        .firstOrNull;
    if (current == null) {
      return [empty('Your access to this restaurant has ended')];
    }
    final authorized = live.tenant(
      live.restaurantId!,
      role: current['role'],
      name: current['name'],
    );
    return [
      RaystoStoryHeader(
        eyebrow: 'Your service · ${friendly(authorized.role)}',
        title: authorized.name,
        message: 'A little care in every detail.',
        scene: authorized.role == 'courier'
            ? RaystoScene.bag
            : RaystoScene.kitchen,
        compact: true,
        dark: true,
      ),
      if (authorized.operator) ...[
        tile(
          'Orders',
          Icons.receipt_long_outlined,
          () => push(c, ordersPage(authorized, staff: true)),
        ),
        tile(
          'Tables and service',
          Icons.table_restaurant_outlined,
          () => push(c, floorPage(authorized)),
        ),
        tile(
          'Reservations',
          Icons.event_available_outlined,
          () => push(c, reservationsPage(authorized, staff: true)),
        ),
        tile(
          'Waiting list',
          Icons.hourglass_empty,
          () => push(c, waitlistPage(authorized)),
        ),
      ],
      if (authorized.manager || authorized.role == 'kitchen') ...[
        tile(
          'Kitchen queue',
          Icons.restaurant_outlined,
          () => push(c, kitchenPage(authorized)),
        ),
        tile(
          'Menu and availability',
          Icons.menu_book_outlined,
          () => push(c, menuPage(authorized)),
        ),
      ],
      if (authorized.manager || authorized.role == 'courier')
        tile(
          'Deliveries',
          Icons.delivery_dining,
          () => push(c, deliveriesPage(authorized)),
        ),
      if (authorized.manager) ...[
        tile(
          'Restaurant setup',
          Icons.tune,
          () => push(c, configurePage(authorized)),
        ),
        tile(
          'Team',
          Icons.groups_outlined,
          () => push(c, teamPage(authorized)),
        ),
        tile(
          'Payments and refunds',
          Icons.payments_outlined,
          () => push(c, checkoutsPage(authorized, staff: true)),
        ),
        tile('Reports', Icons.insights, () => push(c, reportsPage(authorized))),
        tile(
          'Customer reviews',
          Icons.rate_review_outlined,
          () => push(c, reviewsPage(authorized)),
        ),
        tile(
          'Menu drafts',
          Icons.edit_note,
          () => push(c, draftsPage(authorized)),
        ),
        tile(
          'Photos and imports',
          Icons.photo_library_outlined,
          () => push(c, mediaPage(authorized)),
        ),
        tile(
          'Menu assistant',
          Icons.auto_awesome,
          () => push(c, aiHome(authorized)),
        ),
        tile(
          'Customer support',
          Icons.support_agent,
          () => push(c, supportHome(authorized, staff: true)),
        ),
        tile(
          'Payment exceptions',
          Icons.report_outlined,
          () => push(
            c,
            rowsPage(
              authorized,
              'Payment exceptions',
              'payment.exceptions',
              (c, row, _) => AppPanel(child: RecordSummary(row)),
            ),
          ),
        ),
      ],
      if (authorized.role == 'owner')
        tile(
          'Merchant and subscription',
          Icons.account_balance_outlined,
          () => push(c, billingPage(authorized)),
        ),
      tile(
        'Verify identity for sensitive changes',
        Icons.security,
        () => push(c, SecurityPage(runtime: live.runtime)),
      ),
    ];
  },
);

Widget configurePage(LiveContext live) => DataPage(
  title: 'Restaurant setup',
  load: () => live.api.query('restaurant.manage', live.params()),
  content: (c, d, refresh) => [
    RecordSummary(d),
    AppButton(
      label: 'Edit restaurant settings',
      onPressed: () async {
        await live.action(
          c,
          'Restaurant settings',
          'restaurant.configure',
          version: d['version'],
          initial: d,
          fields: [
            const InputSpec('name', 'Restaurant name'),
            const InputSpec(
              'currency',
              'Currency',
              options: ['EUR', 'USD', 'GBP'],
            ),
            const InputSpec(
              'settings',
              'Services, hours and prices',
              kind: 'object',
              children: settingsFields,
            ),
          ],
        );
        await refresh();
      },
    ),
    AppButton(
      label: d['published'] == true
          ? 'Unpublish restaurant'
          : 'Publish restaurant',
      secondary: true,
      onPressed: () async {
        await live.action(
          c,
          d['published'] == true
              ? 'Unpublish restaurant'
              : 'Publish restaurant',
          'restaurant.publish',
          fixed: {'published': d['published'] != true},
        );
        await refresh();
      },
    ),
  ],
);

Widget menuPage(LiveContext live) => rowsPage(
  live,
  'Menu',
  'menu.manage',
  (c, r, refresh) => Card(
    child: Column(
      children: [
        ListTile(
          title: Text('${obj(r['definition'])['name']}'),
          subtitle: Text(
            '${obj(r['definition'])['category']} · ${r['archived'] == true ? 'Archived' : 'Active'}',
          ),
        ),
        Wrap(
          children: [
            if (live.manager)
              TextButton(
                onPressed: () => perform(c, () async {
                  final latest = await live.api.query(
                    'menu.manage',
                    live.params(),
                  );
                  if (!c.mounted) return;
                  await live.action(
                    c,
                    'Edit menu item',
                    'menu.save',
                    version: latest['menuVersion'],
                    initial: obj(r['definition']),
                    fixed: {'productId': r['productId']},
                    fields: menuFields,
                  );
                  await refresh();
                }),
                child: const Text('Edit item'),
              ),
            TextButton(
              onPressed: () async {
                await live.action(
                  c,
                  'Item availability',
                  'menu.availability',
                  id: r['productId'],
                  version: r['version'],
                  initial: {
                    'available': obj(r['definition'])['available'],
                    'stockRemaining': r['stockRemaining'],
                  },
                  fields: const [
                    InputSpec('available', 'Available', kind: 'bool'),
                    InputSpec(
                      'stockRemaining',
                      'Quantity available',
                      kind: 'int',
                      optional: true,
                    ),
                  ],
                );
                await refresh();
              },
              child: const Text('Availability'),
            ),
          ],
        ),
      ],
    ),
  ),
  before: (c, d, refresh) => [
    if (live.manager)
      AppButton(
        label: 'Add a dish',
        icon: Icons.add,
        onPressed: () async {
          await live.action(
            c,
            'New menu item',
            'menu.save',
            version: d['menuVersion'],
            fields: menuFields,
          );
          await refresh();
        },
      ),
  ],
);

Widget draftsPage(LiveContext live) => rowsPage(
  live,
  'Menu drafts',
  'menu.drafts',
  (c, r, refresh) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Draft #${r['id']} · ${r['status']}'),
        Text('${records(r['items']).length} dishes'),
        if (r['status'] == 'draft') ...[
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Review menu draft',
                'menu.draft',
                id: r['id'],
                version: r['version'],
                initial: {'items': r['items']},
                fields: const [
                  InputSpec(
                    'items',
                    'Menu items',
                    kind: 'list',
                    children: menuFields,
                  ),
                ],
              );
              await refresh();
            },
            child: const Text('Review and edit'),
          ),
          AppButton(
            label: 'Publish this menu',
            onPressed: () async {
              await live.action(
                c,
                'Replace published menu with this draft',
                'menu.publishDraft',
                id: r['id'],
                version: r['version'],
                fixed: {'confirm': true},
              );
              await refresh();
            },
          ),
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Discard draft',
                'menu.draft',
                id: r['id'],
                version: r['version'],
                fixed: {'discard': true, 'items': r['items']},
              );
              await refresh();
            },
            child: const Text('Discard'),
          ),
        ],
      ],
    ),
  ),
  before: (c, d, refresh) => [
    AppButton(
      label: 'Create menu draft',
      onPressed: () async {
        await live.action(
          c,
          'New menu draft',
          'menu.draft',
          fields: const [
            InputSpec(
              'items',
              'Menu items',
              kind: 'list',
              value: [],
              children: menuFields,
            ),
          ],
        );
        await refresh();
      },
    ),
  ],
);

Widget floorPage(LiveContext live) => DataPage(
  title: 'Tables and floor plan',
  poll: true,
  load: () => live.api.query('floor', live.params({'limit': 100})),
  content: (c, d, refresh) => [
    if (live.manager)
      Wrap(
        spacing: 8,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit room'),
            onPressed: () async {
              await live.action(
                c,
                'Floor plan',
                'floor.save',
                version: d['version'],
                initial: obj(d['layout']),
                fields: floorFields,
              );
              await refresh();
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add table'),
            onPressed: () async {
              await live.action(
                c,
                'New table',
                'table.save',
                fields: tableFields,
              );
              await refresh();
            },
          ),
        ],
      ),
    if (d['layout'] != null)
      FloorPreview(
        layout: obj(d['layout']),
        tables: records(d['rows']),
        onTap: (table) async {
          await push(c, tablePage(live, table));
          await refresh();
        },
      ),
    for (final t in records(d['rows']))
      tile(
        '${t['label']} · ${t['zone']}',
        Icons.table_restaurant,
        () async {
          await push(c, tablePage(live, t));
          await refresh();
        },
        subtitle:
            '${t['capacity']} seats · ${t['visitId'] != null
                ? 'Occupied'
                : t['needsReset'] == true
                ? 'Needs reset'
                : 'Available'}',
      ),
  ],
);

class FloorPreview extends StatelessWidget {
  const FloorPreview({
    super.key,
    required this.layout,
    required this.tables,
    required this.onTap,
  });
  final Json layout;
  final List<Json> tables;
  final void Function(Json) onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 320,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: InteractiveViewer(
        minScale: .3,
        maxScale: 3,
        constrained: false,
        child: Container(
          width: (layout['width'] as num).toDouble(),
          height: (layout['height'] as num).toDouble(),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Stack(
            children: [
              for (final object in records(layout['objects']))
                Positioned(
                  left: (obj(object['geometry'])['x'] as num).toDouble(),
                  top: (obj(object['geometry'])['y'] as num).toDouble(),
                  child: Container(
                    width: (obj(object['geometry'])['width'] as num).toDouble(),
                    height: (obj(object['geometry'])['height'] as num)
                        .toDouble(),
                    color: object['kind'] == 'wall'
                        ? Colors.grey.shade400
                        : Colors.transparent,
                    child: Text('${object['label']}'),
                  ),
                ),
              for (final t in tables)
                Positioned(
                  left: (obj(t['geometry'])['x'] as num).toDouble(),
                  top: (obj(t['geometry'])['y'] as num).toDouble(),
                  child: Transform.rotate(
                    angle:
                        (obj(t['geometry'])['rotation'] as num) *
                        3.14159265 /
                        180,
                    child: SizedBox(
                      width: ((obj(t['geometry'])['width'] as num).toDouble())
                          .clamp(48, 10000),
                      height: ((obj(t['geometry'])['height'] as num).toDouble())
                          .clamp(48, 10000),
                      child: FilledButton.tonal(
                        onPressed: () => onTap(t),
                        style: FilledButton.styleFrom(
                          shape: obj(t['geometry'])['shape'] == 'round'
                              ? const CircleBorder()
                              : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                        ),
                        child: Text(
                          '${t['label']}\n${t['visitId'] != null ? 'In use' : 'Free'}',
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
  );
}

Widget tablePage(LiveContext live, Json table) => DataPage(
  title: 'Table ${table['label']}',
  load: () async => table,
  content: (c, d, refresh) => [
    Center(
      child: QrImageView(
        data: 'https://rays.to/t/${d['qr']}',
        size: 220,
        backgroundColor: Colors.white,
      ),
    ),
    Text(
      'Printed code for table ${d['label']}. Current bills require a separate invitation.',
    ),
    if (d['visitId'] != null)
      AppButton(
        label: 'Open current visit',
        onPressed: () => push(c, visitPage(live, d['visitId'])),
      )
    else if (d['needsReset'] == true)
      AppButton(
        label: 'Confirm table reset',
        onPressed: () async {
          final result = await live.action(
            c,
            'Reset table',
            'table.reset',
            id: d['id'],
            version: d['version'],
          );
          if (result != null && c.mounted) Navigator.pop(c);
        },
      )
    else
      AppButton(
        label: 'Seat a party',
        onPressed: () async {
          final result = await live.action(
            c,
            'Start visit',
            'visit.start',
            typed: true,
            fixed: {'tableId': d['id']},
            fields: const [
              InputSpec('guestCount', 'Party size', kind: 'int', value: 2),
            ],
          );
          if (result != null && c.mounted) {
            await push(c, visitPage(live, result['id']));
          }
        },
      ),
    if (live.manager)
      OutlinedButton(
        onPressed: () async {
          await live.action(
            c,
            'Edit table',
            'table.save',
            id: d['id'],
            version: d['version'],
            initial: d,
            fields: tableFields,
          );
          if (c.mounted) Navigator.pop(c);
        },
        child: const Text('Edit table'),
      ),
    TextButton(
      onPressed: () => perform(c, () async {
        final invite = await live.action(
          c,
          'Create seating invitation',
          'visit.invite',
          id: d['id'],
          fixed: {'kind': 'seating', 'uses': 1},
        );
        if (invite != null && c.mounted) {
          await notice(c, 'Seating invitation', invite);
        }
      }),
      child: const Text('Create seating invitation'),
    ),
  ],
);

Widget waitlistPage(LiveContext live) => rowsPage(
  live,
  'Waiting list',
  'waitlist',
  (c, row, refresh) => AppPanel(
    child: Column(
      children: [
        RecordSummary(row),
        TextButton(
          onPressed: () async {
            await live.action(
              c,
              'Update waiting party',
              'waitlist.transition',
              id: row['id'],
              version: row['version'],
              fields: const [
                InputSpec(
                  'status',
                  'Status',
                  options: ['offered', 'seated', 'left', 'waiting'],
                ),
                InputSpec(
                  'tableId',
                  'Table reference',
                  kind: 'int',
                  optional: true,
                ),
              ],
            );
            await refresh();
          },
          child: const Text('Offer table or seat'),
        ),
      ],
    ),
  ),
  poll: true,
);

Widget kitchenPage(LiveContext live) => rowsPage(
  live,
  'Kitchen queue',
  'kitchen',
  (c, order, refresh) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Order #${order['id']} · ${order['status']}',
          style: Theme.of(c).textTheme.titleLarge,
        ),
        for (final line in records(order['lines']))
          ListTile(
            title: Text('${line['name']} × ${line['quantity']}'),
            subtitle: Text('${line['note'] ?? ''}'),
          ),
        for (final ticket in records(order['tickets']))
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Kitchen progress',
                'kitchen.progress',
                id: order['id'],
                version: ticket['version'],
                fixed: {'lineKey': ticket['lineKey']},
                fields: [
                  InputSpec(
                    'completedQuantity',
                    'Quantity ready',
                    kind: 'int',
                    value: ticket['quantity'],
                  ),
                ],
              );
              await refresh();
            },
            child: Text(
              'Ready ${ticket['completedQuantity']}/${ticket['quantity']} · ${ticket['lineKey']}',
            ),
          ),
        FilledButton(
          onPressed: () async {
            await live.action(
              c,
              'Update order',
              'order.transition',
              id: order['id'],
              version: order['version'],
              fields: [
                InputSpec(
                  'status',
                  'Status',
                  options: live.manager
                      ? ['accepted', 'preparing', 'ready']
                      : ['preparing', 'ready'],
                ),
              ],
            );
            await refresh();
          },
          child: const Text('Update preparation'),
        ),
      ],
    ),
  ),
  poll: true,
);

Widget deliveriesPage(LiveContext live) => rowsPage(
  live,
  'Delivery tasks',
  'deliveries',
  (c, task, refresh) => AppPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RecordSummary(task),
        if (live.manager)
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Assign courier',
                'delivery.assign',
                id: task['id'],
                version: task['version'],
                fields: const [
                  InputSpec('courierId', 'Courier account reference'),
                ],
              );
              await refresh();
            },
            child: const Text('Assign courier'),
          ),
        AppButton(
          label: 'Update delivery',
          onPressed: () async {
            await live.action(
              c,
              'Delivery progress',
              'delivery.transition',
              id: task['id'],
              version: task['version'],
              fields: [
                InputSpec(
                  'status',
                  'Status',
                  options: [
                    'collected',
                    'outForDelivery',
                    'delivered',
                    'issue',
                    if (live.manager) 'resolved',
                  ],
                ),
                const InputSpec(
                  'reason',
                  'Issue description',
                  kind: 'long',
                  optional: true,
                ),
                const InputSpec('resolution', 'Resolution', optional: true),
              ],
            );
            await refresh();
          },
        ),
        if (live.role == 'courier' &&
            {
              'assigned',
              'collected',
              'outForDelivery',
            }.contains(task['status'])) ...[
          OutlinedButton(
            onPressed: () => perform(c, () async {
              final consent = await editFields(
                c,
                'Share this location with the customer',
                const [
                  InputSpec(
                    'consent',
                    'Share my current location for this active delivery',
                    kind: 'bool',
                    value: false,
                  ),
                ],
                submit: 'Continue',
              );
              if (consent?['consent'] != true) return;
              var permission = await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
              }
              if (permission == LocationPermission.denied ||
                  permission == LocationPermission.deniedForever) {
                throw const PlatformFailure(
                  'permission_required',
                  'Location permission is required.',
                );
              }
              final location = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  timeLimit: Duration(seconds: 20),
                ),
              );
              await live.api.command(
                'delivery.location',
                {
                  'consent': true,
                  'latitude': location.latitude,
                  'longitude': location.longitude,
                },
                restaurantId: live.restaurantId,
                resourceId: task['id'],
              );
              await refresh();
            }),
            child: const Text('Share current location for 5 minutes'),
          ),
          TextButton(
            onPressed: () => perform(c, () async {
              await live.api.command(
                'delivery.location',
                {'consent': false},
                restaurantId: live.restaurantId,
                resourceId: task['id'],
              );
              await refresh();
            }),
            child: const Text('Stop sharing location'),
          ),
        ],
      ],
    ),
  ),
  poll: true,
);

Widget teamPage(LiveContext live) => rowsPage(
  live,
  'Restaurant team',
  'team',
  (c, member, refresh) => AppPanel(
    child: Column(
      children: [
        RecordSummary(member),
        if (member['role'] != 'owner' &&
            (live.role == 'owner' || member['role'] != 'manager'))
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Edit team member',
                'team.membership',
                initial: member,
                fixed: {'userId': member['userId']},
                fields: [
                  InputSpec(
                    'role',
                    'Role',
                    options: [
                      if (live.role == 'owner') 'manager',
                      'waiter',
                      'kitchen',
                      'courier',
                    ],
                  ),
                  const InputSpec('active', 'Active membership', kind: 'bool'),
                ],
              );
              await refresh();
            },
            child: const Text('Edit access'),
          ),
        if (live.role == 'owner' && member['role'] == 'manager')
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Transfer restaurant ownership',
                'team.transfer',
                fixed: {'newOwnerId': member['userId']},
              );
              await refresh();
            },
            child: const Text('Transfer ownership'),
          ),
      ],
    ),
  ),
  before: (c, d, refresh) => [
    AppButton(
      label: 'Invite team member',
      onPressed: () async {
        final invite = await live.action(
          c,
          'Invite colleague',
          'team.invite',
          fields: [
            const InputSpec('email', 'Their verified email'),
            InputSpec(
              'role',
              'Role',
              options: [
                if (live.role == 'owner') 'manager',
                'waiter',
                'kitchen',
                'courier',
              ],
            ),
          ],
        );
        if (invite != null && c.mounted) {
          await notice(c, 'Share invitation with your colleague', invite);
        }
        await refresh();
      },
    ),
  ],
);

Widget reportsPage(LiveContext live) => DataPage(
  title: 'Reports',
  load: () async => {},
  content: (c, d, refresh) => [
    for (final kind in [
      'summary',
      'orders',
      'collections',
      'refunds',
      'commission',
      'audit',
    ])
      tile(friendly(kind), Icons.bar_chart, () async {
        final range = await editFields(c, 'Report period', const [
          InputSpec('from', 'From', kind: 'date'),
          InputSpec('until', 'Until', kind: 'date'),
        ], submit: 'View report');
        if (range == null || !c.mounted) return;
        await push(
          c,
          DataPage(
            title: friendly(kind),
            load: () => live.api.query(
              'report',
              live.params({...range, 'report': kind, 'limit': 100}),
            ),
            content: (c, report, _) => [
              RecordSummary(report),
              for (final row in records(report['rows']))
                AppPanel(child: RecordSummary(row)),
              OutlinedButton(
                onPressed: () => Clipboard.setData(
                  ClipboardData(
                    text: const JsonEncoder.withIndent('  ').convert(report),
                  ),
                ),
                child: const Text('Copy this report page'),
              ),
            ],
          ),
        );
      }),
  ],
);

Widget billingPage(LiveContext live) => DataPage(
  title: 'Merchant and subscription',
  load: () => live.api.query('billing', live.params()),
  content: (c, d, refresh) => [
    const AppNotice(
      title: 'Restaurant payments',
      message: 'Connect your restaurant’s own PayPal business account. Raysto verifies payment eligibility before enabling checkout.',
    ),
    AppButton(
      label: 'Connect PayPal merchant',
      onPressed: () => perform(c, () async {
        final result = await live.action(
          c,
          'Connect merchant account',
          'merchant.connect',
          fields: const [
            InputSpec(
              'shareDataConsent',
              'I agree to share merchant information with PayPal for onboarding',
              kind: 'bool',
              value: false,
            ),
          ],
        );
        final url = result?['approvalUrl'] ?? result?['onboardingUrl'];
        if (url != null) await openProvider(url);
        await refresh();
      }),
    ),
    OutlinedButton(
      onPressed: () async {
        final result = await live.action(
          c,
          'Verify merchant connection',
          'merchant.refresh',
        );
        if (result != null && c.mounted) {
          await notice(c, 'Merchant status', result);
        }
        await refresh();
      },
      child: const Text('Check merchant status'),
    ),
    const Text('Subscription'),
    if (d['subscription'] != null) RecordSummary(obj(d['subscription'])),
    if (obj(d['subscription'])['approvalUrl'] != null)
      OutlinedButton(
        onPressed: () => perform(
          c,
          () => openProvider(obj(d['subscription'])['approvalUrl']),
        ),
        child: const Text('Continue subscription approval'),
      ),
    for (final plan in records(d['plans']))
      AppPanel(
        child: Column(
          children: [
            RecordSummary(plan),
            AppButton(
              label: 'Choose this plan',
              onPressed: () => perform(c, () async {
                final result = await live.action(
                  c,
                  'Subscribe to ${plan['code']}',
                  'billing.subscribe',
                  fixed: {'planId': plan['id']},
                );
                if (result?['approvalUrl'] != null) {
                  await openProvider(result!['approvalUrl']);
                }
                await refresh();
              }),
            ),
          ],
        ),
      ),
    if (records(d['plans']).isEmpty)
      const Text('No subscription plans are available yet.'),
    TextButton(
      onPressed: () async {
        await live.action(c, 'Refresh subscription', 'billing.refresh');
        await refresh();
      },
      child: const Text('Refresh subscription'),
    ),
    TextButton(
      onPressed: () async {
        await live.action(
          c,
          'Cancel subscription',
          'billing.cancel',
          fields: const [InputSpec('reason', 'Reason')],
        );
        await refresh();
      },
      child: const Text('Cancel subscription'),
    ),
    tile(
      'Billing history',
      Icons.history,
      () => push(
        c,
        rowsPage(
          live,
          'Billing history',
          'billing.history',
          (c, row, _) => AppPanel(child: RecordSummary(row)),
        ),
      ),
    ),
  ],
);

Widget mediaPage(LiveContext live) => rowsPage(
  live,
  'Photos and imports',
  'media',
  (c, asset, refresh) => AppPanel(
    child: Column(
      children: [
        RecordSummary(asset),
        TextButton(
          onPressed: () => showFile(c, live, asset['id']),
          child: const Text('Preview'),
        ),
        if (asset['purpose'] == 'menuImage')
          TextButton(
            onPressed: () async {
              await live.action(
                c,
                'Publish approved menu image',
                'media.publish',
                id: asset['id'],
                fixed: {'published': asset['published'] != true},
              );
              await refresh();
            },
            child: Text(
              asset['published'] == true
                  ? 'Make private'
                  : 'Approve publication',
            ),
          ),
      ],
    ),
  ),
  before: (c, d, refresh) => [
    Wrap(
      spacing: 8,
      children: [
        FilledButton(
          onPressed: () async {
            await uploadFile(c, live, purpose: 'menuImage');
            await refresh();
          },
          child: const Text('Upload photo'),
        ),
        OutlinedButton(
          onPressed: () async {
            await uploadFile(c, live, purpose: 'menuSource');
            await refresh();
          },
          child: const Text('Import menu document'),
        ),
        OutlinedButton(
          onPressed: () async {
            await uploadFile(c, live, purpose: 'menuImage', camera: true);
            await refresh();
          },
          child: const Text('Take photo'),
        ),
      ],
    ),
  ],
  poll: true,
);

Future<void> uploadFile(
  BuildContext c,
  LiveContext live, {
  required String purpose,
  bool camera = false,
}) => perform(c, () async {
  Uint8List? bytes;
  String? extension;
  if (camera) {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 3000,
      maxHeight: 3000,
      imageQuality: 90,
    );
    if (photo == null) return;
    if (await photo.length() > 8388608) {
      throw const PlatformFailure(
        'too_large',
        'Choose a file smaller than 8 MB.',
      );
    }
    bytes = await photo.readAsBytes();
    extension = photo.name.split('.').last.toLowerCase();
  } else {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: purpose == 'menuImage'
          ? ['jpg', 'jpeg', 'png', 'webp']
          : ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (result == null) return;
    final file = result;
    if ((await file.length() ?? 8388609) > 8388608) {
      throw const PlatformFailure(
        'too_large',
        'Choose a file smaller than 8 MB.',
      );
    }
    bytes = await file.xFile.readAsBytes();
    extension = file.extension?.toLowerCase();
  }
  if (!c.mounted) return;
  if (bytes.length > 8388608) {
    throw const PlatformFailure(
      'too_large',
      'Choose a file smaller than 8 MB.',
    );
  }
  final mime = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
  }[extension];
  if (mime == null) {
    throw const PlatformFailure(
      'unsupported',
      'Choose JPEG, PNG, WebP or PDF.',
    );
  }
  final intent = await live.action(
    c,
    'Upload this file',
    'media.upload',
    fixed: {
      'purpose': purpose,
      'mime': mime,
      'byteLength': bytes.length,
      'sha256': sha256.convert(bytes).toString(),
    },
  );
  if (intent == null) return;
  await live.api.upload(intent['mediaId'], bytes);
  if (c.mounted) {
    await notice(c, 'File uploaded for validation', {
      'mediaId': intent['mediaId'],
      'status': 'Processing. Refresh files to see approval.',
    });
  }
});

Future<void> showFile(BuildContext c, LiveContext live, int id) =>
    perform(c, () async {
      final bytes = await live.api.download(id);
      if (!c.mounted) return;
      await push(
        c,
        Scaffold(
          appBar: AppBar(title: const Text('Private file')),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: InteractiveViewer(
                    child: Image.memory(
                      bytes,
                      errorBuilder: (_, _, _) => const Center(
                        child: Text('This document can be saved for viewing.'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => perform(c, () async {
                      final pdf =
                          bytes.length > 4 &&
                          String.fromCharCodes(bytes.take(4)) == '%PDF';
                      await FilePicker.saveFile(
                        dialogTitle: 'Save private file',
                        fileName: 'raysto-$id.${pdf ? 'pdf' : 'bin'}',
                        bytes: bytes,
                      );
                    }),
                    child: const Text('Save to device'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

Widget aiHome(LiveContext live, {bool customer = false}) => rowsPage(
  live,
  customer ? 'Menu assistant' : 'Menu studio',
  'ai.jobs',
  (c, job, _) => tile(
    '${friendly('${job['kind']}')} #${job['id']}',
    Icons.auto_awesome,
    () => push(c, aiPage(live, job['id'])),
    subtitle: '${job['status']}',
  ),
  before: (c, d, refresh) => [
    RaystoStoryHeader(
      eyebrow: customer ? 'At your service' : 'The creative kitchen',
      title: customer
          ? 'A little help choosing.'
          : 'Your menu,\nwith a little imagination.',
      message: customer
          ? 'Explore the menu, then review every choice.'
          : 'Turn an idea into a draft. You have the final say.',
      compact: true,
      scene: RaystoScene.menu,
    ),
    const Text(
      'Suggestions are drafts. Check prices, ingredients and allergens before approving.',
    ),
    AppButton(
      label: customer ? 'Ask about this menu' : 'Create an AI draft',
      onPressed: () async {
        final result = await live.action(
          c,
          customer ? 'Ask the menu assistant' : 'Create a draft',
          'ai.start',
          fields: [
            InputSpec(
              'kind',
              'Task',
              options: customer
                  ? ['recommend']
                  : ['menuExtract', 'menuGenerate', 'translate'],
              value: customer ? 'recommend' : 'menuGenerate',
            ),
            const InputSpec(
              'text',
              'What would you like?',
              kind: 'long',
              optional: true,
            ),
            const InputSpec(
              'mediaId',
              'Uploaded menu reference',
              kind: 'int',
              optional: true,
            ),
            const InputSpec(
              'locale',
              'Language',
              options: ['en', 'fr', 'ar'],
              value: 'en',
            ),
          ],
        );
        if (result != null && c.mounted) {
          await push(c, aiPage(live, result['operationId']));
        }
        await refresh();
      },
    ),
  ],
  poll: true,
);

Widget aiPage(LiveContext live, int id) => DataPage(
  title: 'Review suggestion',
  poll: true,
  load: () => live.api.query('ai', live.params({'id': id})),
  content: (c, d, refresh) => [
    RecordSummary(d),
    if (d['status'] == 'review' || d['status'] == 'ready')
      AppButton(
        label: 'Review and approve',
        onPressed: () async {
          final result = await live.action(
            c,
            'Approve this revision',
            'ai.approve',
            id: id,
            version: d['version'],
            fixed: {'confirm': true},
            initial: {'items': obj(d['output'])['items']},
            fields: d['kind'] == 'recommend'
                ? []
                : const [
                    InputSpec(
                      'items',
                      'Reviewed menu items',
                      kind: 'list',
                      children: menuFields,
                    ),
                  ],
          );
          if (result != null && c.mounted) {
            if (d['kind'] == 'recommend') {
              await perform(c, () async {
                final cart = await live.api.query('cart', live.params());
                if (cart['version'] != result['cartVersion']) {
                  throw const PlatformFailure(
                    'stale_proposal',
                    'Your basket changed. Request a new suggestion.',
                  );
                }
                if (!c.mounted) return;
                final saved = await live.action(
                  c,
                  'Add approved items to basket',
                  'cart.save',
                  version: cart['version'],
                  fixed: {
                    'lines': [
                      ...records(cart['lines']),
                      ...records(result['proposalLines']),
                    ],
                  },
                );
                if (saved == null || !c.mounted) return;
                final storefront = await live.api.query(
                  'storefront',
                  live.params(),
                );
                if (c.mounted) {
                  await push(c, BasketPage(live: live, storefront: storefront));
                }
              });
            } else {
              await notice(
                c,
                'Draft saved — publish after reviewing the menu',
                result,
              );
            }
          }
          await refresh();
        },
      ),
    if (!{'approved', 'cancelled'}.contains(d['status']))
      TextButton(
        onPressed: () async {
          await live.action(
            c,
            'Cancel suggestion',
            'ai.cancel',
            id: id,
            version: d['version'],
          );
          await refresh();
        },
        child: const Text('Cancel'),
      ),
  ],
);
