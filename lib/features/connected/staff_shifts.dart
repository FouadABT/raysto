part of 'connected_app.dart';

/// One shift as the `shifts` query returns it; a view over the raw record.
class StaffShift {
  const StaffShift(this.raw);
  final Json raw;
  int get id => raw['id'] as int;
  String get name => '${raw['name'] ?? ''}';
  String get role => '${raw['role'] ?? ''}';
  String? get userId => raw['userId'] as String?;
  DateTime? get startsAt => DateTime.tryParse('${raw['startsAt'] ?? ''}');
  DateTime? get endsAt => DateTime.tryParse('${raw['endsAt'] ?? ''}');
  DateTime? get clockInAt => DateTime.tryParse('${raw['clockInAt'] ?? ''}');
  DateTime? get clockOutAt => DateTime.tryParse('${raw['clockOutAt'] ?? ''}');
  int get hourlyRateMinor => (raw['hourlyRateMinor'] as num? ?? 0).toInt();

  /// `scheduled`, `working` or `done`, from the clock stamps alone.
  String get state => clockOutAt != null
      ? 'done'
      : clockInAt != null
      ? 'working'
      : 'scheduled';

  bool sameDay(DateTime day) {
    final at = startsAt?.toLocal();
    return at != null &&
        at.year == day.year &&
        at.month == day.month &&
        at.day == day.day;
  }
}

/// Monday of the week that holds [day], at midnight local time.
DateTime weekStart(DateTime day) {
  final local = DateTime(day.year, day.month, day.day);
  return local.subtract(Duration(days: local.weekday - 1));
}

/// The shifts board: today's roster with the member's own clock button, then
/// the week by day. Staff see who is on; a manager sees the whole team.
class ShiftsBoard extends StatefulWidget {
  const ShiftsBoard({super.key, required this.live});
  final LiveContext live;
  @override
  State<ShiftsBoard> createState() => _ShiftsBoardState();
}

class _ShiftsBoardState extends State<ShiftsBoard> {
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  bool clocking = false;

  @override
  void dispose() {
    feed.dispose();
    super.dispose();
  }

  Future<void> clock(
    BuildContext c,
    StaffShift shift,
    String action,
    Future<void> Function() refresh,
  ) async {
    if (clocking) return;
    setState(() => clocking = true);
    await perform(c, () async {
      await widget.live.api.submit(
        PendingCommand(
          'shift.clock',
          widget.live.params({'shiftId': shift.id, 'action': action}),
        ),
      );
      await refresh();
    });
    if (mounted) setState(() => clocking = false);
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    final now = DateTime.now();
    final from = weekStart(now);
    final to = from.add(const Duration(days: 7));
    return DataPage(
      title: context.tr('Shifts'),
      large: true,
      poll: true,
      trigger: feed,
      load: () => live.api.query(
        'shifts',
        live.params({
          'from': from.toUtc().toIso8601String(),
          'to': to.toUtc().toIso8601String(),
        }),
      ),
      content: (c, d, refresh) {
        final shifts = records(d['rows']).map(StaffShift.new).toList()
          ..sort(
            (a, b) =>
                (a.startsAt ?? DateTime(0)).compareTo(b.startsAt ?? DateTime(0)),
          );
        final me = live.api.identity();
        final today = shifts.where((s) => s.sameDay(now)).toList();
        // The member's own shift today: the one to clock, done ones aside.
        final mine = today
            .where((s) => me != null && s.userId == me && s.state != 'done')
            .firstOrNull;
        final l = MaterialLocalizations.of(c);
        String time(DateTime? at) => at == null
            ? '—'
            : l.formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal()));
        Widget card(StaffShift s) => ShiftCard(shift: s, mine: s.userId == me);
        final days = [for (var i = 0; i < 7; i++) from.add(Duration(days: i))];
        return [
          if (mine != null)
            AppPanel(
              color: AppColors.forest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    mine.state == 'working'
                        ? '${c.tr('On shift since')} ${time(mine.clockInAt)}'
                        : '${c.tr('Your shift')} · ${time(mine.startsAt)}–${time(mine.endsAt)}',
                    style: AppType.style(
                      18,
                      weight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: c.tr(
                      mine.state == 'working' ? 'Clock out' : 'Clock in',
                    ),
                    icon: mine.state == 'working'
                        ? Icons.logout
                        : Icons.login,
                    busy: clocking,
                    onPressed: () => clock(
                      c,
                      mine,
                      mine.state == 'working' ? 'out' : 'in',
                      refresh,
                    ),
                  ),
                ],
              ),
            ),
          AppSectionTitle(title: '${c.tr('Today')} · ${today.length}'),
          if (today.isEmpty) empty(c.tr('Nobody is scheduled today.')),
          for (final s in today) card(s),
          AppSectionTitle(title: c.tr('This week')),
          for (final day in days)
            if (shifts.any((s) => s.sameDay(day)))
              AppDisclosure(
                title:
                    '${l.formatShortMonthDay(day)} · ${shifts.where((s) => s.sameDay(day)).length}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in shifts.where((s) => s.sameDay(day))) ...[
                      card(s),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
          if (shifts.isEmpty) empty(c.tr('No shifts planned this week.')),
        ];
      },
    );
  }
}

/// A person's shift: name, role, hours and whether they are on.
class ShiftCard extends StatelessWidget {
  const ShiftCard({super.key, required this.shift, this.mine = false});
  final StaffShift shift;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final s = shift;
    final theme = Theme.of(context);
    final l = MaterialLocalizations.of(context);
    String time(DateTime? at) => at == null
        ? '—'
        : l.formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal()));
    final colors = theme.extension<AppStatusColors>();
    final (label, icon, color) = switch (s.state) {
      'working' => (
        '${context.tr('On shift since')} ${time(s.clockInAt)}',
        Icons.play_circle_outline,
        colors?.success,
      ),
      'done' => (context.tr('Done'), Icons.check_circle_outline, null),
      _ => (context.tr('Scheduled'), Icons.schedule, colors?.warning),
    };
    return CustomerOrderCard(
      accent: switch (s.state) {
        'working' => AppColors.forest,
        'done' => AppColors.line,
        _ => AppColors.lime,
      },
      heading: cardHeading(
        context,
        s.name.isEmpty ? context.tr('Team member') : s.name,
        aside: '${time(s.startsAt)}–${time(s.endsAt)}',
      ),
      chips: [
        AppPill(label: context.tr(friendly(s.role)), icon: Icons.badge_outlined),
        AppPill(label: label, icon: icon, color: color),
        if (mine)
          AppPill(label: context.tr('You'), icon: Icons.person_outline),
      ],
    );
  }
}
