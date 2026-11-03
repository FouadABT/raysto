part of 'connected_app.dart';

/// The owner's and manager's "Today", read from the `dashboard` query
/// (docs/dashboard-contract.md). A phone shows one figure that matters and the
/// kitchen; a tablet adds the trend, the channels and the team beside it.
/// Every number is a real paid sale; the judges' café may add a sample
/// outline, always labelled and never mixed into a figure.
Widget todayPage(LiveContext live) => TodayBoard(live: live);

/// The three windows the dashboard answers for.
const dashboardRanges = ['today', '7d', '30d'];

class TodayBoard extends StatefulWidget {
  const TodayBoard({super.key, required this.live, this.now});
  final LiveContext live;

  /// The clock the greeting reads; tests pin it.
  final DateTime Function()? now;
  @override
  State<TodayBoard> createState() => _TodayBoardState();
}

class _TodayBoardState extends State<TodayBoard> {
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  String range = 'today';

  @override
  void dispose() {
    feed.dispose();
    super.dispose();
  }

  Future<Json> load() async {
    final live = widget.live;
    final results = await Future.wait([
      live.api.query('dashboard', live.params({'range': range})),
      // The greeting's name is a nicety; the dashboard does not wait on it.
      live.api.query('me').catchError((Object _) => <String, dynamic>{}),
    ]);
    return {...results[0], '_me': results[1]};
  }

  @override
  Widget build(BuildContext context) => DataPage(
    title: context.tr('Today'),
    large: true,
    trigger: feed,
    load: load,
    content: (c, d, refresh) {
      final dash = Dashboard(d);
      final hour = (widget.now ?? DateTime.now)().hour;
      final name = firstName(obj(obj(d['_me'])['profile'])['displayName']);
      final picker = RangePicker(
        range: range,
        onChanged: (r) {
          setState(() => range = r);
          refresh();
        },
      );
      final greeting = Greeting(hour: hour, name: name);
      return [
        LayoutBuilder(
          builder: (c, box) => box.maxWidth >= 680
              ? _tablet(dash, greeting, picker)
              : _phone(dash, greeting, picker),
        ),
      ];
    },
  );

  Widget _tablet(Dashboard dash, Widget greeting, Widget picker) => _stack([
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [greeting, picker],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _stack([
                  HeroSales(dashboard: dash),
                  if (dash.hasSales) SalesTrend(dashboard: dash),
                  if (dash.hasSales) Trends(dashboard: dash, wide: true),
                  LatestOrders(live: widget.live, dashboard: dash),
                ]),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _stack([
                  KitchenLive(dashboard: dash),
                  if (dash.channels.isNotEmpty) ChannelMix(dashboard: dash),
                  if (dash.staff.isNotEmpty) TeamBoard(dashboard: dash),
                ]),
              ),
            ],
          ),
        ]);

  /// A phone: one figure, the kitchen, then the details below the fold.
  Widget _phone(Dashboard dash, Widget greeting, Widget picker) => _stack([
    greeting,
    picker,
    HeroSales(dashboard: dash),
    KitchenChips(dashboard: dash),
    LatestOrders(live: widget.live, dashboard: dash),
    if (dash.hasSales) Trends(dashboard: dash, wide: false),
  ]);

  Widget _stack(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (i, w) in children.indexed) ...[
        if (i > 0) const SizedBox(height: 16),
        w,
      ],
    ],
  );
}

/// A read-only view over the `dashboard` response.
class Dashboard {
  const Dashboard(this.raw);
  final Json raw;
  String get range => '${raw['range'] ?? 'today'}';
  String get currency => '${raw['currency'] ?? ''}';
  List<Json> get points => records(raw['points']);
  Json kpi(String name) => obj(obj(raw['kpis'])[name]);
  num value(String name) => kpi(name)['value'] as num? ?? 0;
  num previous(String name) => kpi(name)['previous'] as num? ?? 0;
  List<num> series(String name) => [
    for (final v in (kpi(name)['series'] as List? ?? const [])) v as num,
  ];
  List<Json> get channels => records(raw['channels']);
  Json get kitchen => obj(raw['kitchen']);
  int kitchenCount(String status) => (kitchen[status] as num? ?? 0).toInt();
  int get inKitchen => const [
    'submitted',
    'accepted',
    'preparing',
    'ready',
  ].fold(0, (n, s) => n + kitchenCount(s));
  List<Json> get latest => records(raw['latest']);
  List<Json> get staff => records(raw['staff']);
  int get target => (obj(raw['target'])['dailyTargetMinor'] as num? ?? 0).toInt();
  int get todaySales => (obj(raw['target'])['todayMinor'] as num? ?? 0).toInt();
  Json? get sample => raw['sample'] is Map ? obj(raw['sample']) : null;

  /// Whether any paid sale exists in the window: charts only then.
  bool get hasSales => value('sales') > 0 || value('orders') > 0;
}

/// "Fouad" from "Fouad Abt"; nothing when the profile has no name.
String? firstName(Object? displayName) {
  final words = '${displayName ?? ''}'.trim().split(RegExp(r'\s+'));
  return words.first.isEmpty ? null : words.first;
}

/// The greeting for the café's hour: morning until noon, afternoon until six.
String greetingFor(int hour) => hour < 12
    ? 'Good morning'
    : hour < 18
    ? 'Good afternoon'
    : 'Good evening';

/// The change against the window before, in words: "Up 215%", "Down 40%",
/// "Same", or "New" when there was nothing before.
String deltaWords(BuildContext c, num value, num previous) {
  if (previous == 0) return value == 0 ? c.tr('Same') : c.tr('New');
  final change = ((value - previous) * 100 / previous).round();
  if (change == 0) return c.tr('Same');
  return '${c.tr(change > 0 ? 'Up' : 'Down')} ${change.abs()}%';
}

/// What the previous window was, for the range in view.
String previousWindow(BuildContext c, String range) => c.tr(switch (range) {
  '7d' => 'vs the previous 7 days',
  '30d' => 'vs the previous 30 days',
  _ => 'vs yesterday at this time',
});

String rangeName(BuildContext c, String range) => c.tr(switch (range) {
  '7d' => '7 days',
  '30d' => '30 days',
  _ => 'Today',
});

String channelName(BuildContext c, String channel) => c.tr(switch (channel) {
  'counter' => 'Counter',
  'table' => 'Table',
  'dineIn' => 'Dine-in',
  'delivery' => 'Delivery',
  _ => 'Pickup',
});

class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.hour, this.name});
  final int hour;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final base = AppType.style(26, weight: FontWeight.w700, height: 1.2);
    final hello = context.tr(greetingFor(hour));
    return Semantics(
      header: true,
      label: name == null ? hello : '$hello, $name',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            style: base,
            children: [
              TextSpan(text: name == null ? hello : '$hello, '),
              if (name != null)
                TextSpan(text: name, style: AppType.emphasis(28)),
            ],
          ),
        ),
      ),
    );
  }
}

class RangePicker extends StatelessWidget {
  const RangePicker({super.key, required this.range, required this.onChanged});
  final String range;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        for (final r in dashboardRanges)
          ButtonSegment(value: r, label: Text(rangeName(context, r))),
      ],
      selected: {range},
      onSelectionChanged: (s) => onChanged(s.first),
    ),
  );
}

/// The one figure that matters: paid sales, with the target beside it.
class HeroSales extends StatelessWidget {
  const HeroSales({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final theme = Theme.of(context);
    final onLime = theme.colorScheme.onSecondaryContainer;
    String format(num v) => money(v.round(), d.currency);
    final ring = d.target > 0
        ? RaystoRing(
            value: d.todaySales / d.target,
            size: 92,
            color: AppColors.forest,
            semanticLabel: context.tr('Daily target'),
            semanticValue:
                '${format(d.todaySales)} ${context.tr('of')} ${format(d.target)}',
            center: Text(
              '${(d.todaySales * 100 / d.target).round()}%',
              style: AppType.style(18, weight: FontWeight.w700, color: onLime),
            ),
          )
        : null;
    final figure = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.tr('Paid sales')} · ${rangeName(context, d.range)}',
          style: theme.textTheme.titleMedium!.copyWith(color: onLime),
        ),
        const SizedBox(height: 6),
        CountUp(
          value: d.value('sales'),
          format: format,
          semanticsLabel: context.tr('Paid sales'),
          style: AppType.style(40, weight: FontWeight.w700, color: onLime),
        ),
        const SizedBox(height: 6),
        Text(
          d.hasSales
              ? '${deltaWords(context, d.value('sales'), d.previous('sales'))} · '
                    '${previousWindow(context, d.range)}'
              : context.tr('No paid orders in this period yet.'),
          style: theme.textTheme.bodyMedium!.copyWith(color: onLime),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('Paid sales, counted when ordered'),
          style: theme.textTheme.bodySmall!.copyWith(color: onLime),
        ),
      ],
    );
    return AppPanel(
      color: theme.colorScheme.secondaryContainer,
      child: ring == null
          ? figure
          : Wrap(
              spacing: 20,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                figure,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ring,
                    const SizedBox(height: 6),
                    Text(
                      context.tr('Daily target'),
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: onLime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// The kitchen right now, as labelled chips: a phone's quick read.
class KitchenChips extends StatelessWidget {
  const KitchenChips({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionTitle(title: context.tr('Kitchen live')),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in const ['submitted', 'accepted', 'preparing', 'ready'])
              AppPill(
                label: '${statusLabel(context, s)} ${d.kitchenCount(s)}',
                color: d.kitchenCount(s) > 0 ? null : AppColors.mint,
              ),
            if (d.inKitchen > 0)
              AppPill(
                icon: Icons.schedule,
                label:
                    '${context.tr('Oldest waiting')} '
                    '${ageLabel(context, (d.kitchen['oldestMinutes'] as num? ?? 0).toInt())}',
              ),
          ],
        ),
      ],
    );
  }
}

/// The kitchen right now on a tablet: the inverse surface, the count and a
/// bar per stage. It moves only when a real change notice arrives.
class KitchenLive extends StatelessWidget {
  const KitchenLive({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final scheme = Theme.of(context).colorScheme;
    final on = scheme.onInverseSurface;
    final most = [
      for (final s in const ['submitted', 'accepted', 'preparing', 'ready'])
        d.kitchenCount(s),
    ].fold(1, max);
    return AppPanel(
      color: scheme.inverseSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.inversePrimary,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 10),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.tr('Kitchen live').toUpperCase(),
                  style: AppType.style(
                    13,
                    weight: FontWeight.w700,
                    color: scheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CountUp(
            value: d.inKitchen,
            format: (v) => '${v.round()}',
            semanticsLabel: context.tr('Orders in the kitchen'),
            style: AppType.style(44, weight: FontWeight.w700, color: on),
          ),
          Text(
            context.tr('Orders in the kitchen'),
            style: AppType.style(14, weight: FontWeight.w600, color: on),
          ),
          const SizedBox(height: 14),
          for (final s in const ['submitted', 'accepted', 'preparing', 'ready'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      statusLabel(context, s),
                      style: AppType.style(14, color: on),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppShape.full),
                      child: LinearProgressIndicator(
                        value: d.kitchenCount(s) / most,
                        minHeight: 8,
                        color: scheme.inversePrimary,
                        backgroundColor: on.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${d.kitchenCount(s)}',
                    style: AppType.style(
                      15,
                      weight: FontWeight.w700,
                      color: on,
                    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ),
          if (d.inKitchen > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('Oldest waiting')} '
              '${ageLabel(context, (d.kitchen['oldestMinutes'] as num? ?? 0).toInt())}',
              style: AppType.style(14, color: on),
            ),
          ],
        ],
      ),
    );
  }
}

/// Paid sales over the window, with the labelled sample outline when the
/// judges' café has it switched on.
class SalesTrend extends StatelessWidget {
  const SalesTrend({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final sample = d.sample;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(title: context.tr('Paid sales')),
          const SizedBox(height: 8),
          RaystoAreaChart(
            points: [
              for (final p in d.points)
                ChartPoint('${p['label']}', p['salesMinor'] as num? ?? 0),
            ],
            format: (v) => money(v.round(), d.currency),
            semanticLabel:
                '${context.tr('Paid sales')} · ${rangeName(context, d.range)}',
            sample: sample == null
                ? null
                : [
                    for (final p in records(sample['points']))
                      p['salesMinor'] as num? ?? 0,
                  ],
            sampleLabel: context.tr('Sample · not real sales'),
          ),
        ],
      ),
    );
  }
}

/// Orders, average ticket and tips, each with its trend line.
class Trends extends StatelessWidget {
  const Trends({super.key, required this.dashboard, required this.wide});
  final Dashboard dashboard;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final theme = Theme.of(context);
    final items = [
      ('Orders', 'orders', (num v) => '${v.round()}'),
      ('Average ticket', 'averageTicket', (num v) => money(v.round(), d.currency)),
      ('Tips', 'tips', (num v) => money(v.round(), d.currency)),
    ];
    Widget item((String, String, String Function(num)) t) {
      final (label, key, format) = t;
      return AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr(label), style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            CountUp(
              value: d.value(key),
              format: format,
              semanticsLabel: context.tr(label),
              style: AppType.style(24, weight: FontWeight.w700),
            ),
            Text(
              '${deltaWords(context, d.value(key), d.previous(key))} · '
              '${previousWindow(context, d.range)}',
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            RaystoSparkline(
              values: d.series(key),
              semanticLabel: '${context.tr(label)} · ${rangeName(context, d.range)}',
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionTitle(title: context.tr('Trends')),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (c, box) {
            final columns = wide && box.maxWidth >= 540 ? 3 : 1;
            final width = (box.maxWidth - 12 * (columns - 1)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in items) SizedBox(width: width, child: item(t)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ChannelMix extends StatelessWidget {
  const ChannelMix({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: context.tr('Sales by channel')),
          const SizedBox(height: 10),
          RaystoDonut(
            slices: [
              for (final ch in d.channels)
                ChartSlice(
                  channelName(context, '${ch['channel']}'),
                  ch['salesMinor'] as num? ?? 0,
                ),
            ],
            format: (v) => money(v.round(), d.currency),
            semanticLabel: context.tr('Sales by channel'),
          ),
        ],
      ),
    );
  }
}

/// Who moved the orders in the window, and the hours they worked.
class TeamBoard extends StatelessWidget {
  const TeamBoard({super.key, required this.dashboard});
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final theme = Theme.of(context);
    final most = d.staff.fold<num>(
      1,
      (m, p) => max(m, p['ordersMoved'] as num? ?? 0),
    );
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(title: context.tr('Team')),
          for (final p in d.staff)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Semantics(
                label:
                    '${p['name']}: ${p['ordersMoved']} ${context.tr('orders')}, '
                    '${p['hours']} ${context.tr('h')}',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        children: [
                          Text('${p['name']}', style: theme.textTheme.titleSmall),
                          Text(
                            '${p['ordersMoved']} ${context.tr('orders')} · '
                            '${p['hours']} ${context.tr('h')}',
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppShape.full),
                        child: LinearProgressIndicator(
                          value: (p['ordersMoved'] as num? ?? 0) / most,
                          minHeight: 8,
                          color: AppColors.forest,
                          backgroundColor: RaystoChartColors.of(context).track,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The newest orders; each opens in full.
class LatestOrders extends StatelessWidget {
  const LatestOrders({super.key, required this.live, required this.dashboard});
  final LiveContext live;
  final Dashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final d = dashboard;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionTitle(title: context.tr('Latest orders')),
        if (d.latest.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.tr('When a paid order comes in, it shows here.'),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final o in d.latest.map(StaffOrder.new))
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 8,
              leading: DecoratedBox(
                decoration: BoxDecoration(
                  color: stateAccent(o.status),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 12),
              ),
              title: Text(
                '${o.title} · ${statusLabel(context, o.status)}',
                style: theme.textTheme.titleSmall,
              ),
              subtitle: Text(
                [
                  context.tr(o.channel),
                  ?o.customerLabel,
                  ageLabel(context, o.ageMinutes()),
                ].join(' · '),
              ),
              trailing: Text(
                money(o.totalMinor, o.currency),
                style: theme.textTheme.titleSmall!.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              onTap: () => push(context, OrderDetailPage(live: live, id: o.id)),
            ),
          ),
      ],
    );
  }
}
