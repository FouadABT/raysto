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
    // A phone dock holds six places at most before labels break: there a
    // manager reaches the kitchen board from More (Today shows its counts).
    final phone = MediaQuery.sizeOf(context).width < 840;
    return [
      // Owners and managers start on the day: sales, kitchen, team.
      if (l.manager)
        (
          DockDestination(
            context.tr('Today'),
            Icons.insights_outlined,
            Icons.insights,
          ),
          todayPage(l),
        ),
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
      if (l.manager && !phone)
        (
          DockDestination(
            context.tr('Kitchen'),
            Icons.restaurant_outlined,
            Icons.restaurant,
          ),
          KitchenBoard(live: l),
        ),
      // AI coworkers: managers see everything, the kitchen its menu changes.
      if (l.manager || l.role == 'kitchen')
        (
          DockDestination(
            context.tr('Agents'),
            Icons.auto_awesome_outlined,
            Icons.auto_awesome,
          ),
          agentsPage(l),
        ),
      // A courier starts on their deliveries, not their shifts.
      if (l.role == 'courier')
        (
          DockDestination(
            context.tr('Deliveries'),
            Icons.delivery_dining,
            Icons.delivery_dining,
          ),
          deliveriesPage(l),
        ),
      // Everyone on the team clocks their own shift here.
      (
        DockDestination(
          context.tr('Shifts'),
          Icons.schedule_outlined,
          Icons.schedule,
        ),
        ShiftsBoard(live: l),
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
        body: Row(
          children: [
            StaffRail(
              key: const ValueKey('staff-navigation'),
              index: i,
              destinations: [for (final b in items) b.$1],
              onChanged: (v) => setState(() => index = v),
            ),
            Expanded(child: body),
          ],
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
    if (live.manager && MediaQuery.sizeOf(c).width < 840)
      tile(
        c.tr('Kitchen'),
        Icons.restaurant_outlined,
        () => push(c, KitchenBoard(live: live)),
        subtitle: c.tr('New, cooking and ready tickets, oldest first.'),
      ),
    if (live.manager)
      tile(
        c.tr('Snap your menu'),
        Icons.photo_camera_outlined,
        () => push(c, MenuSnapPage(live: live)),
        subtitle: c.tr('Photograph a paper menu; Raysto prepares it for you.'),
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

/// The tablet's side rail, in the phone dock's language: a forest column,
/// a lime pill behind the current place, labels always visible.
class StaffRail extends StatelessWidget {
  const StaffRail({
    super.key,
    required this.index,
    required this.destinations,
    required this.onChanged,
  });
  final int index;
  final List<DockDestination> destinations;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.selection);
    return Material(
      color: AppColors.forest,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: 108,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const RaystoRosette(size: 30, color: AppColors.forest),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      for (final (i, d) in destinations.indexed)
                        Semantics(
                          button: true,
                          selected: i == index,
                          label: d.label,
                          child: InkWell(
                            onTap: () => onChanged(i),
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: ExcludeSemantics(
                                child: Column(
                                  children: [
                                    // Material's rail indicator: the
                                    // lime pill grows out from the icon's
                                    // centre when its place is chosen.
                                    SizedBox(
                                      width: 64,
                                      height: 40,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: duration,
                                            curve: AppMotion.effects,
                                            width: i == index ? 64 : 28,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: i == index
                                                  ? AppColors.lime
                                                  : AppColors.lime.withValues(
                                                      alpha: 0,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.pill,
                                                  ),
                                            ),
                                          ),
                                          Icon(
                                            i == index
                                                ? d.selectedIcon
                                                : d.icon,
                                            size: 24,
                                            color: i == index
                                                ? AppColors.forest
                                                : const Color(0xFFCFDDD2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      d.label,
                                      textAlign: TextAlign.center,
                                      style: AppType.style(
                                        12.5,
                                        weight: i == index
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: i == index
                                            ? AppColors.white
                                            : const Color(0xFFCFDDD2),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
