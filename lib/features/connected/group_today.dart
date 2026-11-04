part of 'connected_app.dart';

/// The franchise view on the phone: every venue of the person's group side
/// by side, and a combined total per currency. A dollar is never added to a
/// euro: a group with venues in two currencies shows two totals. Reads
/// `group.list` and `group.overview`; nothing here writes. Reached from More.
Widget groupTodayPage(LiveContext live) => GroupTodayBoard(live: live);

/// The group a venue belongs to, else the person's first group.
Json? groupForVenue(List<Json> groups, int? restaurantId, [int? chosen]) {
  if (groups.isEmpty) return null;
  for (final g in groups) {
    if (chosen != null && g['id'] == chosen) return g;
  }
  for (final g in groups) {
    if (records(g['venues']).any((v) => v['restaurantId'] == restaurantId)) {
      return g;
    }
  }
  return groups.first;
}

/// Venue figures summed per currency, in a stable order; each total also
/// counts its venues. Amounts in different currencies are never added.
List<Json> groupTotalsByCurrency(List<Json> venues) {
  final by = <String, Json>{};
  for (final v in venues) {
    final code = '${v['currency'] ?? ''}'.toUpperCase();
    final t = by.putIfAbsent(
      code,
      () => {
        'currency': code,
        'venues': 0,
        'paidSalesMinor': 0,
        'orders': 0,
        'billsDueMinor': 0,
        'lowStock': 0,
      },
    );
    t['venues'] = (t['venues'] as int) + 1;
    for (final k in ['paidSalesMinor', 'orders', 'billsDueMinor', 'lowStock']) {
      t[k] = (t[k] as int) + ((v[k] as num?)?.toInt() ?? 0);
    }
  }
  final list = by.values.toList()
    ..sort((a, b) => '${a['currency']}'.compareTo('${b['currency']}'));
  return list;
}

class GroupTodayBoard extends StatefulWidget {
  const GroupTodayBoard({super.key, required this.live});
  final LiveContext live;
  @override
  State<GroupTodayBoard> createState() => _GroupTodayBoardState();
}

class _GroupTodayBoardState extends State<GroupTodayBoard> {
  String range = 'today';
  int? chosen;

  Future<Json> load() async {
    final live = widget.live;
    final groups = records((await live.api.query('group.list'))['rows']);
    final group = groupForVenue(groups, live.restaurantId, chosen);
    if (group == null) return {'groups': <Json>[]};
    final overview = await live.api.query('group.overview', {
      'groupId': group['id'],
      'range': range,
    });
    return {'groups': groups, 'group': group, 'overview': overview};
  }

  @override
  Widget build(BuildContext context) => DataPage(
    title: context.l('Group', 'Groupe', 'المجموعة'),
    large: true,
    load: load,
    content: (c, d, refresh) {
      final groups = records(d['groups']);
      if (groups.isEmpty) {
        return [
          RaystoEmptyState(
            title: c.l(
              'This venue is not in a group',
              'Ce restaurant n’appartient à aucun groupe',
              'هذا المطعم ليس ضمن مجموعة',
            ),
            message: c.l(
              'An owner puts up to twelve venues in a group from the web console. Each keeps its own PayPal, team and records.',
              'Un propriétaire regroupe jusqu’à douze restaurants depuis la console web. Chacun garde son PayPal, son équipe et ses données.',
              'يجمع المالك حتى اثني عشر مطعمًا في مجموعة من لوحة الويب. ويحتفظ كل مطعم بحساب PayPal وفريقه وسجلاته.',
            ),
          ),
        ];
      }
      final group = obj(d['group']);
      final overview = obj(d['overview']);
      final venues = records(overview['venues']);
      final totals = groupTotalsByCurrency(venues);
      return [
        GroupHeader(
          group: group,
          groups: groups,
          onChoose: (id) {
            setState(() => chosen = id);
            refresh();
          },
        ),
        const SizedBox(height: 14),
        RangePicker(
          range: range,
          onChanged: (r) {
            setState(() => range = r);
            refresh();
          },
        ),
        const SizedBox(height: 14),
        AppNotice(
          icon: Icons.science_outlined,
          title: c.l('PayPal Sandbox', 'PayPal Sandbox', 'PayPal Sandbox'),
          message: venues.length == 2
              ? c.l(
                  'Both venues share one Sandbox merchant; in production each connects its own PayPal.',
                  'Les deux restaurants partagent un marchand Sandbox ; en production, chacun connecte son propre PayPal.',
                  'يتشارك المطعمان تاجر Sandbox واحدًا؛ وفي الإنتاج يربط كل مطعم حساب PayPal الخاص به.',
                )
              : c.l(
                  'These venues share one Sandbox merchant; in production each connects its own PayPal.',
                  'Ces restaurants partagent un marchand Sandbox ; en production, chacun connecte son propre PayPal.',
                  'تتشارك هذه المطاعم تاجر Sandbox واحدًا؛ وفي الإنتاج يربط كل مطعم حساب PayPal الخاص به.',
                ),
        ),
        const SizedBox(height: 22),
        AppSectionTitle(
          title: c.l('Combined', 'Cumulé', 'الإجمالي'),
          subtitle: totals.length > 1
              ? c.l(
                  'One total per currency; amounts in different currencies are never added.',
                  'Un total par devise ; des montants en devises différentes ne sont jamais additionnés.',
                  'إجمالي لكل عملة؛ لا تُجمع المبالغ بعملات مختلفة أبدًا.',
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (venues.isEmpty)
          Text(
            c.l(
              'No venue in this group yet.',
              'Aucun restaurant dans ce groupe pour l’instant.',
              'لا توجد مطاعم في هذه المجموعة بعد.',
            ),
          )
        else
          _Columns(
            children: [
              for (final t in totals)
                CurrencyTotalCard(
                  total: t,
                  venues: venues
                      .where(
                        (v) =>
                            '${v['currency']}'.toUpperCase() == t['currency'],
                      )
                      .toList(),
                ),
            ],
          ),
        const SizedBox(height: 22),
        AppSectionTitle(title: c.l('Each venue', 'Par restaurant', 'كل مطعم')),
        const SizedBox(height: 12),
        _Columns(children: [for (final v in venues) VenueCard(venue: v)]),
      ];
    },
  );
}

/// One column on a phone, two on a tablet, three on a wide one; each card
/// keeps its natural height so long words wrap instead of clipping.
class _Columns extends StatelessWidget {
  const _Columns({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, box) {
      final count = box.maxWidth >= 1080
          ? 3
          : box.maxWidth >= 640
          ? 2
          : 1;
      const gap = 14.0;
      final width = (box.maxWidth - gap * (count - 1)) / count;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class GroupHeader extends StatelessWidget {
  const GroupHeader({
    super.key,
    required this.group,
    required this.groups,
    required this.onChoose,
  });
  final Json group;
  final List<Json> groups;
  final ValueChanged<int> onChoose;

  String _role(BuildContext c, String role) => switch (role) {
    'owner' => c.l('Owner', 'Propriétaire', 'المالك'),
    'accountant' => c.l('Accountant', 'Comptable', 'المحاسب'),
    _ => c.l('Area manager', 'Responsable de secteur', 'مدير المنطقة'),
  };

  @override
  Widget build(BuildContext context) {
    final c = context;
    final venues = records(group['venues']);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppEyebrow(
          '${_role(c, '${group['role']}')} · ${venues.length} ${venues.length == 1 ? c.l('venue', 'restaurant', 'مطعم') : c.l('venues', 'restaurants', 'مطاعم')}',
        ),
        const SizedBox(height: 6),
        Semantics(
          header: true,
          child: Text(
            '${group['name'] ?? ''}',
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          venues.map((v) => '${v['name']}').join(' · '),
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (groups.length > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in groups)
                ChoiceChip(
                  label: Text('${g['name']}'),
                  selected: g['id'] == group['id'],
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  onSelected: (_) => onChoose(g['id'] as int),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A currency's combined figures and each venue's share of its sales.
class CurrencyTotalCard extends StatelessWidget {
  const CurrencyTotalCard({
    super.key,
    required this.total,
    required this.venues,
  });
  final Json total;
  final List<Json> venues;

  @override
  Widget build(BuildContext context) {
    final c = context;
    final theme = Theme.of(context);
    final code = '${total['currency']}';
    final sales = (total['paidSalesMinor'] as num?)?.toInt() ?? 0;
    final count = total['venues'] as int? ?? 0;
    final label = c.l('Paid sales', 'Ventes payées', 'المبيعات المدفوعة');
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppEyebrow(
            '$code · $count ${count == 1 ? c.l('venue', 'restaurant', 'مطعم') : c.l('venues', 'restaurants', 'مطاعم')}',
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelLarge),
          CountUp(
            value: sales,
            format: (v) => money(v.round(), code),
            semanticsLabel: '$label, $code',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppPill(
                icon: Icons.receipt_long_outlined,
                label:
                    '${total['orders']} ${c.l('paid orders', 'commandes payées', 'طلبات مدفوعة')}',
              ),
              AppPill(
                icon: Icons.event_note_outlined,
                label:
                    '${c.l('Bills due in 7 days', 'Factures à 7 jours', 'فواتير خلال 7 أيام')}: ${money(total['billsDueMinor'], code)}',
              ),
              AppPill(
                icon: Icons.inventory_2_outlined,
                label: total['lowStock'] == 1
                    ? c.l('1 item low', '1 article bas', 'صنف واحد منخفض')
                    : '${total['lowStock']} ${c.l('items low', 'articles bas', 'أصناف منخفضة')}',
              ),
            ],
          ),
          if (venues.length > 1 && sales > 0) ...[
            const SizedBox(height: 14),
            for (final v in venues) ...[
              AppProgress(
                value: ((v['paidSalesMinor'] as num?) ?? 0) / sales,
                label:
                    '${v['name']}: ${(((v['paidSalesMinor'] as num?) ?? 0) * 100 / sales).round()}%',
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

/// One venue's figures for the period, in its own currency.
class VenueCard extends StatelessWidget {
  const VenueCard({super.key, required this.venue});
  final Json venue;

  @override
  Widget build(BuildContext context) {
    final c = context;
    final theme = Theme.of(context);
    final code = '${venue['currency']}'.toUpperCase();
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final low = (venue['lowStock'] as num?)?.toInt() ?? 0;
    final due = (venue['billsDue'] as num?)?.toInt() ?? 0;
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              '${venue['name']}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 2),
          Text(code, style: theme.textTheme.labelMedium),
          const SizedBox(height: 10),
          row(
            c.l('Paid sales', 'Ventes payées', 'المبيعات المدفوعة'),
            money(venue['paidSalesMinor'], code),
          ),
          row(
            c.l('Paid orders', 'Commandes payées', 'الطلبات المدفوعة'),
            '${venue['orders'] ?? 0}',
          ),
          row(
            c.l('Average ticket', 'Ticket moyen', 'متوسط الفاتورة'),
            money(venue['averageTicketMinor'], code),
          ),
          row(
            c.l('Refunds', 'Remboursements', 'المبالغ المستردة'),
            money(venue['refundsMinor'], code),
          ),
          row(
            c.l('Bills due in 7 days', 'Factures à 7 jours', 'فواتير خلال 7 أيام'),
            '$due · ${money(venue['billsDueMinor'], code)}',
          ),
          row(
            c.l('Items low on stock', 'Articles en stock bas', 'أصناف منخفضة المخزون'),
            '$low',
          ),
          row(
            c.l('Deliveries out', 'Livraisons en cours', 'توصيلات جارية'),
            '${venue['liveDeliveries'] ?? 0}',
          ),
        ],
      ),
    );
  }
}
