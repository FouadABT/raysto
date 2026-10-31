part of 'connected_app.dart';

/// Raysto's assistant outside a table: a customer building a takeaway basket,
/// or a manager asking about today. Every answer comes from server tools; a
/// basket is only ordered after the customer approves it and pays.
class AskRaystoPage extends StatefulWidget {
  const AskRaystoPage({super.key, required this.live, this.manager = false});
  final LiveContext live;
  final bool manager;
  @override
  State<AskRaystoPage> createState() => _AskRaystoPageState();
}

class _AskRaystoPageState extends State<AskRaystoPage> {
  final composer = TextEditingController();
  final thread = <Json>[];
  final threadKey = PlatformApi.newKey();
  int? runId;
  Timer? poll;
  Json? proposal;
  bool busy = false;

  LiveContext get live => widget.live;
  List<String> get starters => widget.manager
      ? const [
          'How are sales today?',
          'What is waiting in the kitchen?',
          'Which PayPal payments are unresolved?',
        ]
      : const [
          'Something vegetarian under 15 euros',
          'What can I eat without nuts?',
          'A quick lunch for two',
        ];

  @override
  void dispose() {
    poll?.cancel();
    composer.dispose();
    super.dispose();
  }

  Future<void> ask(String text) async {
    final t = text.trim();
    if (t.isEmpty || busy) return;
    setState(() {
      thread.add({'role': 'you', 'text': t});
      busy = true;
      proposal = null;
      composer.clear();
    });
    try {
      final started = await live.api.command(
        'assistant.start',
        {
          'text': t,
          'locale': Localizations.localeOf(context).languageCode,
          if (!widget.manager) 'context': 'cart',
          'threadKey': threadKey,
        },
        restaurantId: live.restaurantId,
      );
      runId = started['runId'] as int;
      poll = Timer.periodic(const Duration(milliseconds: 1500), (_) => check());
    } catch (e) {
      fail(e);
    }
  }

  bool checking = false;

  Future<void> check() async {
    final id = runId;
    if (id == null || checking) return;
    checking = true;
    try {
      final r = await live.api.query('assistant.run', live.params({'id': id}));
      final status = '${r['status']}';
      // A run that produced a proposal waits in "review" for the customer.
      if (!{'completed', 'review', 'failed', 'cancelled'}.contains(status)) {
        return;
      }
      if (runId != id) return;
      poll?.cancel();
      runId = null;
      if (!mounted) return;
      final answer = obj(r['answer']);
      final p = obj(r['proposal']);
      setState(() {
        busy = false;
        thread.add({
          'role': 'raysto',
          'text':
              answer['text'] ??
              ({'completed', 'review'}.contains(status)
                  ? ''
                  : context.tr('Raysto could not answer. Try again.')),
        });
        if (p['kind'] == 'basket' && p['status'] == 'review') proposal = p;
      });
    } catch (e) {
      poll?.cancel();
      fail(e);
    } finally {
      checking = false;
    }
  }

  void fail(Object e) {
    if (!mounted) return;
    setState(() {
      busy = false;
      runId = null;
      thread.add({
        'role': 'raysto',
        'text': e is PlatformFailure
            ? e.message
            : context.tr('Raysto is unavailable right now.'),
      });
    });
  }

  Future<void> cancel() async {
    final id = runId;
    if (id == null) return;
    poll?.cancel();
    await perform(
      context,
      () => live.api.command(
        'assistant.cancel',
        {},
        restaurantId: live.restaurantId,
        resourceId: id,
      ),
    );
    if (mounted) {
      setState(() {
        busy = false;
        runId = null;
      });
    }
  }

  Future<void> approve() async {
    final p = proposal;
    if (p == null) return;
    await perform(context, () async {
      final r = await live.api.command(
        'assistant.approve',
        {},
        restaurantId: live.restaurantId,
        resourceId: p['id'] as int,
        version: p['version'] as int?,
      );
      if (!mounted) return;
      setState(() => proposal = null);
      await push(
        context,
        QuotePage(live: live, quote: {...obj(r['quote']), 'id': r['quoteId']}),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = obj(obj(proposal?['payload'])['quote']);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(widget.manager ? 'Ask Raysto about today' : 'Ask Raysto'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppNotice(
                    title: context.tr(
                      widget.manager
                          ? 'Figures come from your orders and PayPal.'
                          : 'Suggestions you approve, then pay with PayPal.',
                    ),
                    message: context.tr(
                      widget.manager
                          ? 'Raysto reads sales, the kitchen, pickups and payment attempts. It never moves money.'
                          : 'Raysto only proposes. You review the final price and pay yourself.',
                    ),
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 16),
                  if (thread.isEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in starters)
                          ActionChip(
                            label: Text(context.tr(s)),
                            onPressed: () => ask(context.tr(s)),
                          ),
                      ],
                    ),
                  for (final m in thread)
                    Align(
                      alignment: m['role'] == 'you'
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        constraints: const BoxConstraints(maxWidth: 520),
                        decoration: BoxDecoration(
                          color: m['role'] == 'you'
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: m['role'] == 'you'
                            ? Text('${m['text']}')
                            : AssistantMessageBody(text: '${m['text']}'),
                      ),
                    ),
                  if (proposal != null)
                    AppPanel(
                      color: theme.colorScheme.secondaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.tr('Proposed basket'),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final line in records(quote['lines']))
                            Text('${line['quantity']}× ${line['name']}'),
                          const SizedBox(height: 8),
                          Text(
                            '${context.tr('Total')} ${money(quote['totalMinor'], '${quote['currency'] ?? ''}')}',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: context.tr('Approve basket'),
                            icon: Icons.check,
                            onPressed: approve,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr(
                              'You will review the final price and pay with PayPal.',
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  if (busy) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!AppMotion.reduced(context))
                          const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(context.tr('Raysto is thinking…')),
                        ),
                        TextButton(
                          onPressed: cancel,
                          child: Text(context.tr('Cancel')),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: composer,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 4000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: ask,
                      decoration: InputDecoration(
                        labelText: context.tr('Ask Raysto'),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    expanded: false,
                    label: context.tr('Ask'),
                    icon: Icons.send,
                    onPressed: busy ? null : () => ask(composer.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Splits the table bill equally between chosen diners without the assistant,
/// then reserves exactly this diner's share for PayPal.
Future<void> splitEqually(
  BuildContext context,
  LiveContext live,
  int roomId,
  Json room,
) async {
  final me = '${room['currentUserId']}';
  // Everyone at the table can share the bill, the host included; staff cannot.
  final diners = records(room['members'])
      .where((m) => m['role'] == null || {'diner', 'host'}.contains(m['role']))
      .toList();
  final chosen = <String>{me, for (final m in diners) '${m['userId']}'};
  final payers = await showDialog<List<String>>(
    context: context,
    builder: (dialog) => StatefulBuilder(
      builder: (_, state) => AlertDialog(
        title: Text(dialog.tr('Choose who shares the bill')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final m in diners)
                CheckboxListTile(
                  title: Text(
                    '${m['name'] ?? m['userId']}${m['userId'] == me ? ' (${dialog.tr('you')})' : ''}',
                  ),
                  value: chosen.contains('${m['userId']}'),
                  onChanged: '${m['userId']}' == me
                      ? null
                      : (v) => state(() {
                          if (v == true) {
                            chosen.add('${m['userId']}');
                          } else {
                            chosen.remove('${m['userId']}');
                          }
                        }),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(dialog.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, chosen.toList()),
            child: Text(dialog.tr('Pay my share with PayPal')),
          ),
        ],
      ),
    ),
  );
  if (payers == null || !context.mounted) return;
  await perform(context, () async {
    final split = await live.api.command(
      'room.split.equal',
      {'payers': payers},
      restaurantId: live.restaurantId,
      resourceId: roomId,
    );
    final shares = records(split['shares']);
    if (shares.isEmpty) {
      throw const PlatformFailure(
        'split_settled',
        'Your share of this bill is already paid.',
      );
    }
    final reserved = await live.api.submit(
      PendingCommand(
        'payment.allocate',
        live.params({
          'visitId': room['visitId'],
          'method': 'paypal',
          'splitPlanId': split['splitPlanId'],
          'shares': [
            for (final s in shares)
              {
                'chargeId': s['chargeId'],
                'amountMinor': s['amountMinor'],
                'expectedVersion': s['expectedVersion'],
              },
          ],
        }),
      ),
    );
    if (context.mounted) {
      await push(context, checkoutPage(live, reserved['checkoutId'] as int));
    }
  });
}
