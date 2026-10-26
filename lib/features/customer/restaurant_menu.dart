part of 'customer_screens.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _search = TextEditingController();
  String _query = '', _category = 'All', _sort = 'Menu order';
  bool _vegetarian = false, _cards = true;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
    _search.clear();
    _query = '';
    _category = 'All';
    _vegetarian = false;
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store, r = store.currentRestaurant;
      final colors = Theme.of(context).colorScheme;
      final categories = store.restaurantMenu
          .map((i) => i.category)
          .toSet()
          .toList();
      final items = store.restaurantMenu
          .where(
            (i) =>
                (_category == 'All' || i.category == _category) &&
                (!_vegetarian ||
                    i.dietaryKnown && i.dietary.contains('vegetarian')) &&
                '${i.name} ${i.description} ${i.ingredients.join(' ')}'
                    .toLowerCase()
                    .contains(_query.toLowerCase()),
          )
          .toList();
      if (_sort == 'Price: low to high') {
        items.sort((a, b) => a.priceMinor.compareTo(b.priceMinor));
      }
      final groups = _sort != 'Menu order' || _category != 'All'
          ? {_category == 'All' ? 'Your selection' : _category: items}
          : {
              for (final c in categories)
                c: items.where((i) => i.category == c).toList(),
            };
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 165 + MediaQuery.textScalerOf(context).scale(80),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              title: Text(context.tr('Menu')),
              actions: [
                IconButton(
                  tooltip: context.tr('Restaurant information'),
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showAppSheet(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(r.address),
                        Text(r.hours),
                        const SizedBox(height: 12),
                        Text(
                          context.tr(
                            'This is a local demo restaurant. Images are illustrative. Ask staff about allergens.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      r.cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: colors.primary),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x99000000),
                            Color(0x22000000),
                            Color(0xDD000000),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 22,
                      end: 22,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr('Made for your next favourite.'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
              sliver: SliverList.list(
                children: [
                  Text(
                    r.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(
                        store.isRestaurantOpen(r) ? 'Open now' : 'Closed',
                        icon: Icons.schedule,
                      ),
                      StatusBadge(r.hours, icon: Icons.access_time),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final mode in r.services)
                        ChoiceChip(
                          avatar: Icon(switch (mode) {
                            ServiceMode.dineIn =>
                              Icons.table_restaurant_outlined,
                            ServiceMode.pickup => Icons.shopping_bag_outlined,
                            ServiceMode.delivery => Icons.delivery_dining,
                          }, size: 18),
                          label: Text(context.tr(modeLabel(mode))),
                          selected: store.cart.mode == mode,
                          onSelected: (_) => guarded(
                            context,
                            () => store.configureCart(mode: mode),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (r.services.contains(ServiceMode.dineIn))
                    ExperienceAction(
                      icon: Icons.table_restaurant_outlined,
                      title: store.activeVisit == null
                          ? 'Find your table'
                          : 'Your active visit',
                      subtitle: store.activeVisit == null
                          ? 'Scan a QR or explore the dining room.'
                          : 'Orders, table requests and shared bill',
                      onTap: () => openPage(
                        context,
                        store.activeVisit == null
                            ? DiningRoomScreen(store: store)
                            : VisitScreen(
                                store: store,
                                visitId: store.activeVisit!.id,
                              ),
                      ),
                    ),
                  if (!store.isRestaurantOpen(r)) ...[
                    const SizedBox(height: 16),
                    AppNotice(
                      title: context.tr('Ordering is paused'),
                      message: context.tr(
                        'You can browse and keep your draft. Try again after this restaurant reopens.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SearchBar(
                    controller: _search,
                    hintText: context.tr('Search this menu'),
                    leading: const Icon(Icons.search),
                    onChanged: (v) => setState(() => _query = v),
                    trailing: [
                      if (_query.isNotEmpty)
                        IconButton(
                          tooltip: context.tr('Clear search'),
                          onPressed: _clear,
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final c in ['All', ...categories])
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: ChoiceChip(
                              label: Text(context.tr(c)),
                              selected: _category == c,
                              onSelected: (_) => setState(() => _category = c),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilterChip(
                        avatar: const Icon(Icons.eco_outlined, size: 18),
                        label: Text(context.tr('Vegetarian')),
                        selected: _vegetarian,
                        onSelected: (v) => setState(() => _vegetarian = v),
                      ),
                      PopupMenuButton<String>(
                        tooltip: context.tr('Sort by'),
                        onSelected: (v) => setState(() => _sort = v),
                        itemBuilder: (_) => [
                          for (final value in [
                            'Menu order',
                            'Price: low to high',
                          ])
                            PopupMenuItem(
                              value: value,
                              child: Text(context.tr(value)),
                            ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sort, size: 20),
                              const SizedBox(width: 6),
                              Text(context.tr('Sort')),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: context.tr(
                          _cards ? 'Show list' : 'Show cards',
                        ),
                        onPressed: () => setState(() => _cards = !_cards),
                        icon: Icon(
                          _cards
                              ? Icons.view_list_outlined
                              : Icons.grid_view_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (items.isEmpty)
                    EmptyState(
                      title: 'No dishes found',
                      message: 'Try another search or category.',
                      action: TextButton(
                        onPressed: _clear,
                        child: Text(context.tr('Clear filters')),
                      ),
                    ),
                  for (final group in groups.entries.where(
                    (g) => g.value.isNotEmpty,
                  )) ...[
                    const SizedBox(height: 24),
                    AppSectionTitle(
                      title: context.tr(group.key),
                      subtitle: '${group.value.length} ${context.tr('dishes')}',
                    ),
                    const SizedBox(height: 14),
                    if (!_cards) ...[
                      for (final item in group.value)
                        MenuRow(
                          store: store,
                          item: item,
                          onTap: () => openPage(
                            context,
                            ItemScreen(store: store, itemId: item.id),
                          ),
                        ),
                    ] else
                      LayoutBuilder(
                        builder: (context, c) {
                          final columns = c.maxWidth >= 640
                              ? 3
                              : c.maxWidth >= 340 &&
                                    MediaQuery.textScalerOf(context).scale(1) <
                                        1.35
                              ? 2
                              : 1;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              for (final item in group.value)
                                SizedBox(
                                  width:
                                      (c.maxWidth - 12 * (columns - 1)) /
                                      columns,
                                  child: _DishCard(
                                    item: item,
                                    onTap: () => openPage(
                                      context,
                                      ItemScreen(store: store, itemId: item.id),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    context.tr(
                      'Dietary information comes from demo menu records. Information not provided is never an allergy guarantee.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: store.cart.lines.isEmpty
            ? null
            : SafeArea(
                top: false,
                minimum: const EdgeInsets.all(16),
                child: AppButton(
                  label:
                      '${context.tr('View cart')} · ${money(context, store.cartTotals().totalMinor)}',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () => openPage(context, CartScreen(store: store)),
                ),
              ),
      );
    },
  );
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.item, required this.onTap});
  final MenuItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AppPanel(
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 135,
                width: double.infinity,
                child: Image.asset(
                  item.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.restaurant_outlined, size: 36),
                  ),
                ),
              ),
              if (!item.available)
                PositionedDirectional(
                  start: 8,
                  top: 8,
                  child: StatusBadge(
                    'Unavailable',
                    icon: Icons.pause_circle_outline,
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.dietaryKnown &&
                    item.dietary.contains('vegetarian')) ...[
                  Text(
                    context.tr('Vegetarian'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MoneyText(item.priceMinor),
                    Icon(
                      item.available
                          ? Icons.add_circle_outline
                          : Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
