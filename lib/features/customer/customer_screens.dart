import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../design_system/design_system.dart';
import '../../domain/domain.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/shared.dart';
import '../../mobile/experience_widgets.dart';
import '../../mobile/table_map.dart';
import '../scanning/qr_camera_screen.dart';

part 'shopping.dart';
part 'checkout.dart';
part 'visits.dart';
part 'restaurant_menu.dart';
part 'dining_room.dart';

void openAssistedOrder(BuildContext context, DemoStore store, String visitId) {
  guarded(context, () {
    store.configureCart(mode: ServiceMode.dineIn, visitId: visitId);
    return openPage(context, RestaurantScreen(store: store));
  });
}

class CustomerBranch extends StatelessWidget {
  const CustomerBranch({super.key, required this.store, required this.section});
  final DemoStore store;
  final String section;
  @override
  Widget build(BuildContext context) => switch (section) {
    'orders' => OrdersScreen(store: store, embedded: true),
    'assistant' => AssistantScreen(store: store, embedded: true),
    _ => DiscoveryScreen(store: store),
  };
}

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  String _query = '';
  ServiceMode _mode = ServiceMode.dineIn;
  bool _favorites = false, _openOnly = false;
  String _sort = 'Recommended';
  final _search = TextEditingController();
  final _recent = <String>[];
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final restaurants = store.restaurants
        .where(
          (r) =>
              r.published &&
              r.services.contains(_mode) &&
              (!_openOnly || store.isRestaurantOpen(r)) &&
              (!_favorites || store.currentAccount.favorites.contains(r.id)) &&
              ('${r.name} ${r.description}'.toLowerCase().contains(
                _query.toLowerCase(),
              )),
        )
        .toList();
    if (_sort == 'Name') restaurants.sort((a, b) => a.name.compareTo(b.name));
    final dishes = _query.trim().isEmpty
        ? <MenuItem>[]
        : store.menuItems
              .where(
                (m) =>
                    m.name.toLowerCase().contains(_query.toLowerCase()) &&
                    store.restaurants.any(
                      (r) => r.id == m.restaurantId && r.published,
                    ),
              )
              .toList();
    return ListView(
      key: const PageStorageKey('discovery'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () =>
                    openPage(context, LocationScreen(store: store)),
                icon: const Icon(Icons.location_on_outlined),
                label: Text(context.tr('Central district')),
              ),
            ),
            IconButton(
              onPressed: () => openPage(context, FavoritesScreen(store: store)),
              tooltip: context.tr('Favorites'),
              icon: const Icon(Icons.favorite_border),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RaystoStoryHeader(
          eyebrow: context.tr('Pull up a chair'),
          title: context.tr('Good food.\nYour way.'),
          message: context.tr(
            'A neighborhood table, a quick pickup, or dinner at your door.',
          ),
          tableArt: true,
          compact: true,
        ),
        const SizedBox(height: 20),
        SearchBar(
          controller: _search,
          hintText: context.tr('Restaurant, dish, or craving'),
          leading: const Icon(Icons.search),
          trailing: [
            if (_query.isNotEmpty)
              IconButton(
                tooltip: context.tr('Clear search'),
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close),
              ),
          ],
          onChanged: (s) => setState(() => _query = s),
          onSubmitted: (s) {
            if (s.trim().isNotEmpty) {
              setState(() {
                _recent.remove(s);
                _recent.insert(0, s);
              });
            }
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final mode in ServiceMode.values)
              ChoiceChip(
                label: Text(context.tr(modeLabel(mode))),
                selected: _mode == mode,
                onSelected: (_) => setState(() => _mode = mode),
              ),
            FilterChip(
              label: Text(context.tr('Open now')),
              selected: _openOnly,
              onSelected: (v) => setState(() => _openOnly = v),
            ),
            FilterChip(
              label: Text(context.tr('Favorites')),
              selected: _favorites,
              onSelected: (v) => setState(() => _favorites = v),
            ),
            PopupMenuButton<String>(
              tooltip: context.tr('Sort results'),
              initialValue: _sort,
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => ['Recommended', 'Name']
                  .map(
                    (s) => PopupMenuItem(value: s, child: Text(context.tr(s))),
                  )
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.tr('Sort')),
              ),
            ),
          ],
        ),
        if (_query.isEmpty && _recent.isNotEmpty)
          Wrap(
            spacing: 8,
            children: [
              for (final q in _recent.take(4))
                ActionChip(
                  label: Text(q),
                  avatar: const Icon(Icons.history, size: 16),
                  onPressed: () {
                    _search.text = q;
                    setState(() => _query = q);
                  },
                ),
            ],
          ),
        const SizedBox(height: 16),
        ExperienceAction(
          icon: Icons.qr_code_scanner,
          title: 'Scan, sit, enjoy.',
          subtitle: 'Open your camera to find your table and menu.',
          onTap: () => openPage(context, ScanScreen(store: store)),
        ),
        const SizedBox(height: 12),
        ExperienceAction(
          icon: Icons.map_outlined,
          title: 'Explore the dining room',
          subtitle: 'See the layout, zones and available seats.',
          onTap: () => openPage(context, DiningRoomScreen(store: store)),
        ),
        if (store.activeVisit != null) ...[
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainer,
            leading: const Icon(Icons.table_restaurant_outlined),
            title: Text(context.tr('Your active visit')),
            subtitle: Text(
              context.tr('Orders, table requests and shared bill'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openPage(
              context,
              VisitScreen(store: store, visitId: store.activeVisit!.id),
            ),
          ),
        ],
        const SizedBox(height: 28),
        AppSectionTitle(
          title: context.tr(
            _query.isEmpty ? 'Around your neighborhood' : 'Search results',
          ),
          subtitle: context.tr('Independent kitchens. Plenty to discover.'),
        ),
        const SizedBox(height: 16),
        if (restaurants.isEmpty && dishes.isEmpty)
          EmptyState(
            title: 'No matches yet',
            message: 'Try another dish or clear your filters.',
            action: OutlinedButton(
              onPressed: () => setState(() {
                _query = '';
                _search.clear();
                _favorites = false;
                _openOnly = false;
              }),
              child: Text(context.tr('Clear filters')),
            ),
          ),
        for (final restaurant in restaurants)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RestaurantCard(
              store: store,
              restaurant: restaurant,
              onTap: () {
                store.selectRestaurant(restaurant.id);
                store.configureCart(mode: _mode);
                openPage(context, RestaurantScreen(store: store));
              },
            ),
          ),
        for (final item in dishes)
          MenuRow(
            store: store,
            item: item,
            onTap: () {
              store.selectRestaurant(item.restaurantId);
              openPage(context, ItemScreen(store: store, itemId: item.id));
            },
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () =>
                  openPage(context, ReservationsScreen(store: store)),
              icon: const Icon(Icons.event_available_outlined),
              label: Text(context.tr('Book a table')),
            ),
            OutlinedButton.icon(
              onPressed: () => openPage(context, WaitlistScreen(store: store)),
              icon: const Icon(Icons.people_outline),
              label: Text(context.tr('Join the waitlist')),
            ),
          ],
        ),
      ],
    );
  }
}

String modeLabel(ServiceMode mode) => switch (mode) {
  ServiceMode.dineIn => 'Dine in',
  ServiceMode.pickup => 'Pickup',
  ServiceMode.delivery => 'Delivery',
};

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.store,
    required this.restaurant,
    required this.onTap,
  });
  final DemoStore store;
  final Restaurant restaurant;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AppMedia(
                asset: restaurant.cover,
                semanticLabel: context.tr('Illustrative menu photography'),
                height: 180,
              ),
              PositionedDirectional(
                end: 12,
                top: 12,
                child: IconButton.filledTonal(
                  tooltip: context.tr('Favorite restaurant'),
                  onPressed: () => store.toggleFavorite(restaurant.id),
                  icon: Icon(
                    store.currentAccount.favorites.contains(restaurant.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(restaurant.logoAsset),
                  radius: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(restaurant.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      store.isRestaurantOpen(restaurant)
                          ? 'Open now'
                          : 'Closed',
                      icon: Icons.schedule,
                    ),
                    for (final mode in restaurant.services)
                      StatusBadge(
                        modeLabel(mode),
                        icon: switch (mode) {
                          ServiceMode.dineIn => Icons.restaurant_outlined,
                          ServiceMode.pickup => Icons.shopping_bag_outlined,
                          ServiceMode.delivery => Icons.pedal_bike,
                        },
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

class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.store,
    required this.item,
    required this.onTap,
  });
  final DemoStore store;
  final MenuItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, c) {
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MoneyText(item.priceMinor),
                      if (!item.available)
                        StatusBadge(
                          'Unavailable',
                          icon: Icons.remove_circle_outline,
                        ),
                    ],
                  ),
                ],
              );
              final photo = ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: Image.asset(
                    item.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.restaurant_outlined),
                  ),
                ),
              );
              return MediaQuery.textScalerOf(context).scale(1) > 1.5
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [photo, const SizedBox(height: 12), details],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: details),
                        const SizedBox(width: 12),
                        photo,
                      ],
                    );
            },
          ),
        ),
      ),
    ),
  );
}
