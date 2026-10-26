part of 'customer_screens.dart';

class DiningRoomScreen extends StatefulWidget {
  const DiningRoomScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<DiningRoomScreen> createState() => _DiningRoomScreenState();
}

class _DiningRoomScreenState extends State<DiningRoomScreen> {
  String _zone = 'All';
  int _guests = 2;
  bool _available = false;
  String? _selected;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final all = store.restaurantTables.where((t) => t.active).toList();
      final tables = all
          .where(
            (t) =>
                (_zone == 'All' || t.zone == _zone) &&
                t.seats >= _guests &&
                (!_available || t.status == TableStatus.available),
          )
          .toList();
      final selected = tables.where((t) => t.id == _selected).firstOrNull;
      return MobilePage(
        title: 'The dining room',
        children: [
          Text(
            store.currentRestaurant.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            context.tr('Choose a spot. Make it yours.'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          ExperienceMetrics(
            values: [
              (
                '${all.where((t) => t.status == TableStatus.available).length}',
                'Available',
                Icons.check_circle_outline,
              ),
              ('${all.length}', 'Tables', Icons.table_restaurant_outlined),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final z in ['All', ...all.map((t) => t.zone).toSet()])
                ChoiceChip(
                  label: Text(context.tr(z)),
                  selected: _zone == z,
                  onSelected: (_) => setState(() => _zone = z),
                ),
            ],
          ),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Guests in your party'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                QuantityStepper(
                  value: _guests,
                  max: 12,
                  onChanged: (v) => setState(() => _guests = v),
                ),
                const SizedBox(height: 10),
                FilterChip(
                  label: Text(context.tr('Available only')),
                  selected: _available,
                  onSelected: (v) => setState(() => _available = v),
                ),
              ],
            ),
          ),
          const TableStatusLegend(),
          SizedBox(
            height: 340,
            child: DiningFloorMap(
              tables: tables,
              objects: store.floorObjects
                  .where((o) => o.restaurantId == store.currentRestaurant.id)
                  .toList(),
              selected: selected?.id,
              onSelect: (id) => setState(() => _selected = id),
            ),
          ),
          Text(
            context.tr(
              'Pinch to explore. The list below offers the same tables.',
            ),
          ),
          if (selected != null)
            AppNotice(
              title: selected.label,
              message:
                  '${selected.zone} · ${selected.seats} ${context.tr('seats')} · ${context.tr(selected.status.name)}',
              action: AppButton(
                label: context.tr('Review this table'),
                onPressed: () => openPage(
                  context,
                  TableConfirmationScreen(
                    store: store,
                    tableId: selected.id,
                    initialGuests: _guests,
                  ),
                ),
              ),
            ),
          if (tables.isEmpty)
            const EmptyState(
              title: 'No matching tables',
              message: 'Try another zone or a smaller party.',
            ),
          for (final table in tables)
            AppPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: tableStatusColor(context, table.status),
                  child: Icon(
                    Icons.table_restaurant_outlined,
                    color: tableStatusForeground(context, table.status),
                  ),
                ),
                title: Text(table.label),
                subtitle: Text(
                  '${table.zone} · ${table.seats} ${context.tr('seats')} · ${context.tr(table.status.name)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(
                  context,
                  TableConfirmationScreen(
                    store: store,
                    tableId: table.id,
                    initialGuests: _guests,
                  ),
                ),
              ),
            ),
          Text(
            context.tr(
              'Preview of the local restaurant layout. Joining always requires confirmation.',
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => openPage(context, ScanScreen(store: store)),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(context.tr('Scan a table')),
          ),
        ],
      );
    },
  );
}
