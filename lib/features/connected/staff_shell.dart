part of 'connected_app.dart';

/// Staff land here: the boards for their role, with the customer app beneath.
class StaffShell extends StatefulWidget {
  const StaffShell({
    super.key,
    required this.live,
    required this.memberships,
    this.initial,
  });
  final LiveContext live;
  final List<Json> memberships;
  final Json? initial;
  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  late Json membership = widget.initial ?? widget.memberships.first;
  int index = 0;
  LiveContext get live => widget.live.forMembership(membership);

  List<(DockDestination, Widget)> branches(BuildContext context) {
    final l = live;
    return [
      if (l.role == 'kitchen')
        (
          DockDestination(
            context.tr('Kitchen'),
            Icons.restaurant_outlined,
            Icons.restaurant,
          ),
          KitchenBoard(live: l),
        ),
      if (l.operator)
        (
          DockDestination(
            context.tr('Orders'),
            Icons.receipt_long_outlined,
            Icons.receipt_long,
          ),
          OrdersBoard(live: l),
        ),
      if (l.can('counter'))
        (
          DockDestination(
            context.tr('Counter'),
            Icons.storefront_outlined,
            Icons.storefront,
          ),
          CounterScreen(live: l),
        ),
      if (l.manager)
        (
          DockDestination(
            context.tr('Kitchen'),
            Icons.restaurant_outlined,
            Icons.restaurant,
          ),
          KitchenBoard(live: l),
        ),
      if (l.role == 'courier')
        (
          DockDestination(
            context.tr('Deliveries'),
            Icons.delivery_dining,
            Icons.delivery_dining,
          ),
          deliveriesPage(l),
        ),
      (
        DockDestination(context.tr('More'), Icons.more_horiz, Icons.more_horiz),
        staffMore(l, widget.memberships, (m) {
          setState(() {
            membership = m;
            index = 0;
          });
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = branches(context);
    final i = index.clamp(0, items.length - 1);
    final body = RetainedBranches(
      key: ValueKey(membership['restaurantId']),
      index: i,
      children: [for (final b in items) b.$2],
    );
    // Tablets get a side rail, so the counter and the boards keep their height.
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth >= 840
          ? wide(items, i, body)
          : narrow(items, i, body),
    );
  }

  Widget wide(List<(DockDestination, Widget)> items, int i, Widget body) =>
      Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: i,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (v) => setState(() => index = v),
                destinations: [
                  for (final b in items)
                    NavigationRailDestination(
                      icon: Icon(b.$1.icon),
                      selectedIcon: Icon(b.$1.selectedIcon),
                      label: Text(b.$1.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        ),
      );

  Widget narrow(List<(DockDestination, Widget)> items, int i, Widget body) =>
      Scaffold(
        body: body,
        bottomNavigationBar: RaystoAdaptiveDock(
          index: i,
          onChanged: (v) => setState(() => index = v),
          options: [for (final b in items) b.$1],
          navigateLabel: context.tr('Navigate'),
        ),
      );
}

Widget staffMore(
  LiveContext live,
  List<Json> memberships,
  ValueChanged<Json> onSwitch,
) => DataPage(
  title: live.name,
  load: () => live.api.query('me'),
  content: (c, d, refresh) => [
    RaystoStoryHeader(
      eyebrow: '${c.tr('Your service')} · ${friendly(live.role)}',
      title: live.name,
      message: c.tr('A little care in every detail.'),
      scene: live.role == 'courier' ? RaystoScene.bag : RaystoScene.kitchen,
      compact: true,
      dark: true,
    ),
    if (memberships.length > 1)
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in memberships)
            AppChip(
              label: '${m['name'] ?? m['restaurantId']}',
              selected: m['restaurantId'] == live.restaurantId,
              onSelected: () => onSwitch(m),
            ),
        ],
      ),
    if (live.manager)
      tile(
        c.tr('Ask Raysto about today'),
        Icons.auto_awesome,
        () => push(c, AskRaystoPage(live: live, manager: true)),
        subtitle: c.tr('Sales, kitchen load, pickups and PayPal payments.'),
      ),
    ...staffTiles(c, live),
    AppButton(
      label: c.tr('Switch to customer mode'),
      icon: Icons.person_outline,
      secondary: true,
      onPressed: () => Navigator.of(c).pop(),
    ),
  ],
);
