part of 'connected_app.dart';

/// How each AI coworker introduces itself.
(String, IconData) agentFace(BuildContext c, String agent) => switch (agent) {
  'payments' => (c.tr('Payments agent'), Icons.account_balance_wallet_outlined),
  'menu' => (c.tr('Menu agent'), Icons.menu_book_outlined),
  'images' => (c.tr('Image studio'), Icons.photo_camera_outlined),
  'orders' => (c.tr('Order agent'), Icons.shopping_bag_outlined),
  'counter' => (c.tr('Counter voice'), Icons.mic_none),
  'catering' => (c.tr('Catering agent'), Icons.celebration_outlined),
  'copilot' => (c.tr('Copilot'), Icons.insights_outlined),
  'translator' => (c.tr('Translator'), Icons.translate),
  'marketing' => (c.tr('Marketing studio'), Icons.campaign_outlined),
  'reviews' => (c.tr('Review replies'), Icons.reviews_outlined),
  _ => (friendly(agent), Icons.auto_awesome),
};

String agentCost(Object? micros) =>
    '\$${((micros as num? ?? 0) / 1000000).toStringAsFixed(3)}';

/// The AI coworkers' inbox: what each agent prepared, with its evidence,
/// waiting for a person. Nothing changes until someone approves; money also
/// needs a fresh identity check.
Widget agentsPage(LiveContext live) => DataPage(
  title: 'AI coworkers',
  poll: true,
  load: () async {
    final inbox = await live.api.query('agent.inbox', live.params());
    final activity = live.manager
        ? await live.api.query('agent.activity', live.params({'limit': 20}))
        : <String, dynamic>{'rows': []};
    return {'inbox': inbox['rows'], 'activity': activity['rows']};
  },
  content: (c, d, refresh) => [
    RaystoStoryHeader(
      eyebrow: c.tr('AI coworkers'),
      title: c.tr('They do the work. You decide.'),
      message: c.tr(
        'Every change waits for your approval. Money also needs your identity check.',
      ),
      scene: RaystoScene.kitchen,
      compact: true,
    ),
    if (live.manager)
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          AppButton(
            label: c.tr('Snap your menu'),
            icon: Icons.photo_camera_outlined,
            expanded: false,
            onPressed: () => push(c, MenuSnapPage(live: live)),
          ),
        ],
      ),
    AppSectionTitle(title: c.tr('Waiting for you')),
    if (records(d['inbox']).isEmpty)
      RaystoEmptyState(
        title: c.tr('Nothing is waiting'),
        message: c.tr('Agents ask here when something needs you.'),
        scene: RaystoScene.receipt,
      ),
    for (final a in records(d['inbox']))
      AgentActionCard(
        key: ValueKey('agent-action-${a['id']}-${a['version']}'),
        live: live,
        action: a,
        onDone: refresh,
      ),
    if (live.manager) ...[
      AppSectionTitle(title: c.tr('What the agents did')),
      if (records(d['activity']).isEmpty)
        Text(c.tr('No agent work yet.')),
      for (final t in records(d['activity'])) agentTaskTile(c, t),
    ],
  ],
);

class AgentActionCard extends StatefulWidget {
  const AgentActionCard({
    super.key,
    required this.live,
    required this.action,
    required this.onDone,
  });
  final LiveContext live;
  final Json action;
  final Future<void> Function() onDone;
  @override
  State<AgentActionCard> createState() => _AgentActionCardState();
}

class _AgentActionCardState extends State<AgentActionCard> {
  bool busy = false;
  String? note;
  PendingCommand? pending;
  String? decision;

  Json get a => widget.action;

  Future<void> decide(String choice) async {
    if (busy) return;
    final live = widget.live;
    // One request per decision, so a retry after the identity check resumes
    // the same approval instead of starting another.
    if (pending == null || decision != choice) {
      pending = live.api.prepare(
        'agent.decide',
        {'decision': choice},
        restaurantId: live.restaurantId,
        resourceId: a['id'] as int,
        version: a['version'] as int?,
      );
      decision = choice;
    }
    setState(() {
      busy = true;
      note = null;
    });
    try {
      var result = await live.api.submit(pending!);
      if ({'reauthentication_required', 'mfa_required'}.contains(result['needs'])) {
        if (!mounted) return;
        final ok = await verifyIdentity(context, live.runtime);
        if (!ok) {
          if (mounted) {
            setState(() => note = context.tr('Approval paused until you confirm it is you.'));
          }
          return;
        }
        result = await live.api.submit(pending!);
      }
      if (!mounted) return;
      final message = switch (result['state']) {
        'executed' => context.tr('Done.'),
        'rejected' => context.tr('Dismissed.'),
        'stale' => context.tr('Things changed since the agent looked. It will check again.'),
        'expired' => context.tr('This suggestion expired.'),
        'failed' => '${obj(result['result'])['message'] ?? context.tr('It could not be completed.')}',
        _ => context.tr('Approved.'),
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      await widget.onDone();
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => note = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (name, icon) = agentFace(context, '${a['agent']}');
    final evidence = obj(a['evidence']);
    final preview = obj(a['preview']);
    final money = a['risk'] == 'money';
    final theme = Theme.of(context);
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(icon, size: 20),
              Text(name, style: theme.textTheme.labelLarge),
              AppPill(
                label: money
                    ? context.tr('Money · needs your check')
                    : a['risk'] == 'ops'
                    ? context.tr('Service')
                    : context.tr('Menu'),
                icon: money ? Icons.lock_outline : null,
                color: money ? theme.colorScheme.tertiaryContainer : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${a['title']}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('${a['rationale']}'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final chip in evidenceChips(context, evidence, preview))
                AppPill(label: chip),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(note!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              AppButton(
                label: money ? context.tr('Approve and confirm') : context.tr('Approve'),
                icon: Icons.check,
                busy: busy && decision == 'approve',
                expanded: false,
                onPressed: busy ? null : () => decide('approve'),
              ),
              AppButton(
                label: context.tr('Not now'),
                secondary: true,
                expanded: false,
                onPressed: busy ? null : () => decide('reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The facts behind a suggestion, as short labels: what PayPal reports and
/// from where, what Raysto recorded, and what would change.
List<String> evidenceChips(BuildContext c, Json evidence, Json preview) => [
  if (evidence['paypalStatus'] != null)
    '${c.tr('PayPal')}: ${evidence['paypalStatus']}',
  if (evidence['paypalSource'] == 'paypal_mcp')
    c.tr('Checked through PayPal MCP')
  else if (evidence['paypalSource'] == 'paypal_rest')
    c.tr('Checked through PayPal REST'),
  if (evidence['amountMinor'] != null)
    money(evidence['amountMinor'], '${evidence['currency'] ?? ''}'),
  if (evidence['ledgerState'] != null)
    '${c.tr('Raysto')}: ${statusLabel(c, '${evidence['ledgerState']}')}',
  if (evidence['queue'] != null) '${c.tr('Orders open')}: ${evidence['queue']}',
  if (evidence['oldestOpenMinutes'] != null)
    '${c.tr('Oldest order')}: ${evidence['oldestOpenMinutes']} ${c.tr('min')}',
  if (preview['item'] != null) '${preview['item']}: ${c.tr('sold out')}',
  for (final e in preview.entries)
    if (e.value is Map && obj(e.value).containsKey('to'))
      settingChange(c, e.key, obj(e.value)['from'], obj(e.value)['to']),
];

/// A restaurant setting change in words: "Online orders: open → paused".
String settingChange(BuildContext c, String key, Object? from, Object? to) {
  String value(Object? v) => switch (key) {
    'paused' => v == true ? c.tr('paused') : c.tr('open'),
    'preparationMinutes' => '$v ${c.tr('min')}',
    _ => '$v',
  };
  final label = switch (key) {
    'paused' => c.tr('Online orders'),
    'preparationMinutes' => c.tr('Prep time'),
    'slotCapacity' => c.tr('Orders per slot'),
    _ => friendly(key),
  };
  return '$label: ${value(from)} → ${value(to)}';
}

Widget agentTaskTile(BuildContext c, Json t) {
  final (name, icon) = agentFace(c, '${t['agent']}');
  final state = obj(t['state']);
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text('${t['title']}'),
    subtitle: Text(
      [
        name,
        if (t['summary'] != null) '${t['summary']}',
      ].join(' · '),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(statusLabel(c, '${t['status']}')),
        Text(
          [
            agentCost(t['chargedMicros']),
            if (state['ms'] != null)
              '${((state['ms'] as num) / 1000).toStringAsFixed(1)} s',
          ].join(' · '),
          style: Theme.of(c).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
