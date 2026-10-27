part of 'connected_app.dart';

/// Collapse only adjacent updates to the same record. Conversation and unread
/// boundaries remain in order, and every original event remains inspectable.
List<Json> groupRoomActivity(List<Json> messages, {int? unreadSequence}) {
  final result = <Json>[];
  for (final message in messages) {
    final previous = result.lastOrNull;
    final body = obj(message['body']);
    final prior = obj(previous?['body']);
    if (message['kind'] == 'activity' &&
        previous?['kind'] == 'activity' &&
        message['sequence'] != unreadSequence &&
        previous?['sequence'] != unreadSequence &&
        body['entityId'] != null &&
        body['entityId'] == prior['entityId'] &&
        body['entityType'] == prior['entityType']) {
      result[result.length - 1] = {
        ...message,
        'activityHistory': [
          ...(records(previous?['activityHistory']).isEmpty
              ? [previous!]
              : records(previous?['activityHistory'])),
          message,
        ],
      };
    } else {
      result.add(message);
    }
  }
  return result;
}

class TableRoomPage extends StatefulWidget {
  const TableRoomPage({
    super.key,
    required this.live,
    this.visitId,
    this.orderId,
    this.roomId,
  });
  final LiveContext live;
  final int? visitId, orderId, roomId;
  @override
  State<TableRoomPage> createState() => _TableRoomPageState();
}

class _TableRoomPageState extends State<TableRoomPage>
    with WidgetsBindingObserver {
  final composer = TextEditingController();
  final scroll = ScrollController();
  StreamSubscription<Json>? events;
  Timer? fallback;
  Json? room;
  String? error;
  String delivery = 'Connecting';
  bool busy = false, asking = false, loading = true, foreground = true;
  int? replyTo;
  String messageId = PlatformApi.newKey();
  PendingCommand? pendingMessage;
  String? pendingFingerprint;
  int? activeRun;
  int? id;
  int? firstUnreadSequence;
  Timer? draftTimer;
  String? draftOwner;
  LiveContext get live => widget.live;
  bool get closed => room?['closed'] == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    draftOwner = live.api.identity();
    open();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    events?.cancel();
    fallback?.cancel();
    draftTimer?.cancel();
    composer.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (foreground) {
      refresh().then((_) {
        if (mounted) connect();
      });
    } else {
      events?.cancel();
      fallback?.cancel();
      unawaited(saveDraft());
    }
  }

  Future<void> open() async {
    try {
      id =
          widget.roomId ??
          (await live.api.command('room.open', {
                if (widget.visitId != null) 'visitId': widget.visitId,
                if (widget.orderId != null) 'orderId': widget.orderId,
              }, restaurantId: live.restaurantId))['roomId']
              as int;
      await refresh();
      final draft = await live.api.readRoomDraft(live.restaurantId!, id!);
      if (mounted && draft != null && !closed) {
        composer.text = '${draft['text'] ?? ''}';
        asking = draft['asking'] == true;
        replyTo = draft['replyTo'] as int?;
        messageId = '${draft['messageId'] ?? PlatformApi.newKey()}';
        pendingFingerprint = draft['fingerprint'] as String?;
        setState(() {});
      }
      if (mounted) connect();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    if (id == null) return;
    try {
      final next = await live.api.query('room', live.params({'id': id}));
      if (!mounted) return;
      firstUnreadSequence ??= (next['lastReadSequence'] as int? ?? 0) + 1;
      if (activeRun != null &&
          records(next['messages']).any(
            (m) =>
                obj(m['body'])['runId'] == activeRun &&
                m['kind'] == 'assistant.answer',
          )) {
        activeRun = null;
      }
      final older = records(room?['messages'])
          .where(
            (m) =>
                records(next['messages']).isNotEmpty &&
                (m['sequence'] as int) <
                    (records(next['messages']).first['sequence'] as int),
          )
          .toList();
      setState(() {
        room = {
          ...next,
          if (older.isNotEmpty)
            'messages': [...older, ...records(next['messages'])],
          if (older.isNotEmpty) 'beforeCursor': room?['beforeCursor'],
        };
        loading = false;
        error = null;
      });
      if (foreground && ModalRoute.of(context)?.isCurrent == true) {
        await live.api.command(
          'room.read',
          {'sequence': next['sequence']},
          restaurantId: live.restaurantId,
          resourceId: id,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    }
  }

  void connect() {
    events?.cancel();
    fallback?.cancel();
    if (id == null || room == null || !foreground) return;
    events = live.api
        .watchRoom(live.restaurantId!, id!, room!['sequence'] as int)
        .listen(
          (event) {
            if (!mounted) return;
            setState(() {
              delivery = event['kind'] == 'reconnecting'
                  ? 'Reconnecting'
                  : 'Live';
            });
            if (records(event['events']).isNotEmpty || event['reset'] == true) {
              refresh();
            }
          },
          onError: (Object e) {
            if (!mounted) return;
            final denied =
                e is PlatformFailure &&
                {'room_access_ended', 'session_changed'}.contains(e.code);
            setState(() {
              delivery = denied ? 'Access ended' : 'Periodic refresh';
              error = '$e';
              if (denied) room = null;
            });
            if (!denied) {
              fallback = Timer.periodic(const Duration(seconds: 10), (_) {
                if (foreground && ModalRoute.of(context)?.isCurrent == true) {
                  refresh();
                }
              });
            }
          },
        );
  }

  Future<void> navigate(Widget page) async {
    await saveDraft();
    await events?.cancel();
    fallback?.cancel();
    if (!mounted) return;
    await push(context, page);
    if (mounted) {
      await refresh();
      if (mounted) connect();
    }
  }

  Future<void> send() async {
    final text = composer.text.trim();
    if (text.isEmpty || busy || closed) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final fingerprint = jsonEncode([text, asking, replyTo]);
      if (pendingMessage == null || pendingFingerprint != fingerprint) {
        if (pendingFingerprint != fingerprint) messageId = PlatformApi.newKey();
        pendingFingerprint = fingerprint;
        pendingMessage = live.api.prepare(
          asking ? 'assistant.start' : 'room.message',
          asking
              ? {
                  'roomId': id,
                  'text': text,
                  'locale': Localizations.localeOf(context).languageCode,
                }
              : {
                  'text': text,
                  'clientMessageId': messageId,
                  if (replyTo != null) 'replyToId': replyTo,
                },
          restaurantId: live.restaurantId,
          resourceId: asking ? null : id,
        );
      }
      await saveDraft();
      final result = await live.api.submit(pendingMessage!);
      if (!mounted) return;
      if (asking) activeRun = result['runId'] as int?;
      composer.clear();
      replyTo = null;
      pendingMessage = null;
      pendingFingerprint = null;
      await saveDraft();
      await refresh();
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && scroll.hasClients) {
            scroll.jumpTo(scroll.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> saveDraft() async {
    draftTimer?.cancel();
    if (id == null || room == null || draftOwner != live.api.identity()) return;
    try {
      await live.api.saveRoomDraft(
        live.restaurantId!,
        id!,
        composer.text.trim().isEmpty
            ? null
            : {
                'text': composer.text,
                'asking': asking,
                'replyTo': replyTo,
                'messageId': messageId,
                'fingerprint': pendingFingerprint,
              },
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'Could not save this draft on your device. Keep this screen open to retry.',
        );
      }
    }
  }

  Future<void> preferences() async {
    final mine = obj(room!['myPreferences']);
    await live.action(
      context,
      'Preferences for this table',
      'room.preferences',
      id: id,
      initial: {...mine, 'muted': room!['muted']},
      fields: const [
        InputSpec('preferences', 'Food preferences', kind: 'strings'),
        InputSpec('budgetMinor', 'Your budget', kind: 'money', optional: true),
        InputSpec(
          'shareWithTable',
          'Share these preferences with the table and AI',
          kind: 'bool',
        ),
        InputSpec('muted', 'Mute room notifications', kind: 'bool'),
      ],
    );
    await refresh();
  }

  Future<void> people() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'People at your table',
                  style: Theme.of(c).textTheme.titleLarge,
                ),
                Text('${room!['staffDisclosure'] ?? ''}'),
                const SizedBox(height: 12),
                for (final person in records(room!['members']))
                  ListTile(
                    leading: Icon(
                      person['role'] == 'waiter'
                          ? Icons.room_service_outlined
                          : Icons.person_outline,
                    ),
                    title: Text('${person['name']}'),
                    subtitle: Text(friendly('${person['role']}')),
                    trailing:
                        !closed &&
                            person['role'] != 'waiter' &&
                            person['userId'] != room!['hostUserId'] &&
                            (live.operator ||
                                room!['hostUserId'] == room!['currentUserId'])
                        ? TextButton(
                            child: const Text('Make host'),
                            onPressed: () async {
                              await perform(
                                c,
                                () => live.api.command(
                                  'room.host',
                                  {'userId': person['userId']},
                                  restaurantId: live.restaurantId,
                                  resourceId: id,
                                  version: room!['version'],
                                ),
                              );
                              if (c.mounted) Navigator.pop(c);
                              await refresh();
                            },
                          )
                        : null,
                  ),
                const Text(
                  'Diners and the assigned waiter can read this room. Replacement staff can access the service history they need.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> approve(Json proposal) async {
    if (busy) return;
    final payload = obj(proposal['payload']);
    final basket = proposal['kind'] == 'basket';
    final quote = obj(payload['quote']);
    final amount = basket ? quote['totalMinor'] : payload['amountMinor'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          basket ? 'Confirm the group order?' : 'Review your payment share',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                money(amount, '${room!['currency']}'),
                style: Theme.of(c).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              for (final line in records(
                basket ? quote['lines'] : payload['shares'],
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    basket
                        ? '${line['quantity']} × ${line['name']} · ${money(line['lineTotalMinor'] ?? ((line['unitPriceMinor'] as num? ?? 0) * (line['quantity'] as num? ?? 1)), '${room!['currency']}')}'
                        : '${line['label']} · ${money(line['amountMinor'], '${room!['currency']}')}',
                  ),
                ),
              Text(
                basket
                    ? 'You are confirming this reviewed order as table host.'
                    : 'Only your share will be reserved. You will approve payment on PayPal’s Sandbox screen.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep reviewing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(basket ? 'Confirm order' : 'Continue to PayPal'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final approved = await live.api.command(
        'assistant.approve',
        {},
        restaurantId: live.restaurantId,
        resourceId: proposal['id'],
        version: proposal['version'],
      );
      if (basket) {
        final result = await live.api.submit(
          PendingCommand(
            'order.submit',
            live.params({'quoteId': approved['quoteId']}),
          ),
        );
        if (mounted) await navigate(orderPage(live, result['orderId'] as int));
      } else {
        final result = await live.api.submit(
          PendingCommand(
            'payment.allocate',
            live.params({
              if (approved['visitId'] != null) 'visitId': approved['visitId'],
              if (approved['orderId'] != null) 'orderId': approved['orderId'],
              'method': 'paypal',
              'assistantProposalId': approved['assistantProposalId'],
              'shares': records(approved['shares'])
                  .map(
                    (s) => {
                      'chargeId': s['chargeId'],
                      'amountMinor': s['amountMinor'],
                      'expectedVersion': s['expectedVersion'],
                    },
                  )
                  .toList(),
            }),
          ),
        );
        final checkoutId = result['checkoutId'] as int;
        final checkout = await live.api.command(
          'payment.checkout',
          {},
          restaurantId: live.restaurantId,
          resourceId: checkoutId,
        );
        if (checkout['approvalUrl'] != null) {
          await openProvider(checkout['approvalUrl']);
        }
        if (mounted) await navigate(checkoutPage(live, checkoutId));
      }
      await refresh();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String activityTitle(Json body) => switch (body['event']) {
    'service.sent' => 'Your waiter has the request',
    'service.acknowledged' => 'Your waiter acknowledged it',
    'service.completed' => 'Service request completed',
    'payment.reserved' => 'A share is reserved for checkout',
    'payment.created' => 'PayPal approval is ready',
    'payment.capturing' => 'Confirming the payment',
    'payment.uncertain' => 'Payment is being checked',
    'payment.completed' => 'Payment confirmed',
    'payment.refund_requested' => 'Refund requested',
    'payment.refunded' => 'Refund confirmed',
    'order.submitted' => 'Your order reached the restaurant',
    'order.accepted' => 'The restaurant accepted your order',
    'order.preparing' => 'The kitchen is preparing your order',
    'order.ready' => 'Your order is ready',
    'kitchen.progress' => 'An update from the kitchen',
    _ => friendly('${body['event'] ?? 'Table updated'}').replaceAll('.', ' '),
  };

  Widget activityCard(Json m) {
    final body = obj(m['body']);
    final history = records(m['activityHistory']);
    final type = '${body['entityType']}';
    final icon = type == 'serviceRequest'
        ? Icons.room_service_outlined
        : {'checkout', 'capture', 'refund'}.contains(type)
        ? Icons.payments_outlined
        : type == 'order'
        ? Icons.restaurant_outlined
        : Icons.table_restaurant_outlined;
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 8),
          Text(
            activityTitle(body),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (body['serviceKind'] != null)
            Text(friendly('${body['serviceKind']}')),
          if (body['amountMinor'] is int && body['currency'] is String)
            Text(money(body['amountMinor'], body['currency'])),
          if (body['event'] == 'service.sent')
            const Text(
              'Delivered to the room. Waiting for your waiter to acknowledge.',
            ),
          if (body['event'] == 'payment.uncertain')
            const Text(
              'Keep the existing checkout. The bill updates after verification.',
            ),
          if (history.length > 1)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('${history.length} updates'),
              children: [
                for (final event in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(activityTitle(obj(event['body']))),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget message(Json m) {
    final body = obj(m['body']);
    final mine = m['userId'] == room!['currentUserId'];
    final ai = '${m['kind']}'.startsWith('assistant.');
    final person = records(room!['members'])
        .where((p) => p['userId'] == m['userId'])
        .firstOrNull;
    final proposal = obj(body['proposal']);
    final retryRequest = records(room!['messages'])
        .where(
          (request) =>
              request['kind'] == 'assistant.request' &&
              request['userId'] == room!['currentUserId'] &&
              obj(request['body'])['runId'] == body['runId'],
        )
        .firstOrNull;
    final expires = DateTime.tryParse('${proposal['expiresAt']}');
    final expired = expires != null && !expires.isAfter(DateTime.now());
    final enabled = proposal['kind'] == 'basket'
        ? room!['hostUserId'] == room!['currentUserId']
        : proposal['userId'] == room!['currentUserId'];
    if (m['kind'] == 'activity') return activityCard(m);
    if (m['kind'] == 'preferences.changed' ||
        m['kind'] == 'staff.changed' ||
        m['kind'] == 'host.changed') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Text(
          '${body['text'] ?? friendly('${body['event']}')}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: EdgeInsetsDirectional.only(
          top: 8,
          bottom: 4,
          start: mine ? 24 : 0,
          end: mine ? 0 : 24,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ai
              ? Theme.of(context).colorScheme.secondaryContainer
              : mine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (ai)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(end: 6),
                    child: Icon(Icons.auto_awesome, size: 16),
                  ),
                Expanded(
                  child: Text(
                    m['kind'] == 'assistant.answer'
                        ? 'Raysto'
                        : mine
                        ? 'You'
                        : '${person?['name'] ?? 'Diner'}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (!closed)
                  PopupMenuButton<String>(
                    tooltip: 'Message actions',
                    onSelected: (action) async {
                      if (action == 'reply') {
                        setState(() {
                          replyTo = m['id'] as int;
                          asking = false;
                        });
                      } else {
                        await live.action(
                          context,
                          'Report message privately',
                          'room.report',
                          id: id,
                          fixed: {'messageId': m['id']},
                          fields: const [InputSpec('reason', 'Reason')],
                        );
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'reply', child: Text('Reply')),
                      PopupMenuItem(value: 'report', child: Text('Report')),
                    ],
                  ),
              ],
            ),
            if (m['replyToId'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Reply to an earlier message',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            SelectableText('${body['text'] ?? ''}'),
            if (body['retryable'] == true && retryRequest != null && !closed)
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Review question & retry'),
                onPressed: composer.text.trim().isNotEmpty || activeRun != null
                    ? null
                    : () {
                        setState(() {
                          asking = true;
                          composer.text =
                              '${obj(retryRequest['body'])['text']}';
                        });
                        unawaited(saveDraft());
                      },
              ),
            if (m['kind'] == 'assistant.suggestion' &&
                body['prompt'] is String &&
                !closed)
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Ask Raysto'),
                onPressed: () {
                  if (composer.text.trim().isNotEmpty) return;
                  setState(() {
                    asking = true;
                    composer.text = body['prompt'];
                  });
                  unawaited(saveDraft());
                },
              ),
            if (proposal.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                proposal['kind'] == 'basket'
                    ? 'A proposal for your table'
                    : proposal['userId'] == live.api.identity()
                    ? 'Your proposed share'
                    : 'Proposed payment share',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                money(
                  proposal['kind'] == 'basket'
                      ? obj(obj(proposal['payload'])['quote'])['totalMinor']
                      : obj(proposal['payload'])['amountMinor'],
                  '${room!['currency']}',
                ),
              ),
              const SizedBox(height: 8),
              if (!closed &&
                  enabled &&
                  !expired &&
                  {'review', 'approved'}.contains(proposal['status']))
                AppButton(
                  label: proposal['kind'] == 'basket'
                      ? 'Review & confirm order'
                      : 'Review & pay my share',
                  onPressed: busy ? null : () => approve(proposal),
                )
              else
                Text(
                  expired && {'review', 'approved'}.contains(proposal['status'])
                      ? 'This proposal expired. Ask Raysto for an updated one.'
                      : proposal['status'] == 'review'
                      ? 'Waiting for ${proposal['kind'] == 'basket' ? 'the table host' : 'this payer'} to review.'
                      : friendly('${proposal['status']}'),
                ),
              if (proposal['status'] == 'executed' && enabled)
                TextButton(
                  onPressed: () {
                    final p = obj(proposal['payload']);
                    if (p['checkoutId'] != null) {
                      navigate(checkoutPage(live, p['checkoutId']));
                    } else if (p['orderId'] != null) {
                      navigate(orderPage(live, p['orderId']));
                    }
                  },
                  child: Text(
                    proposal['kind'] == 'basket'
                        ? 'Open order'
                        : 'Resume payment / receipt',
                  ),
                ),
            ],
            if (records(body['steps']).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  records(body['steps'])
                      .map(
                        (s) =>
                            '${friendly('${s['tool']}')} · ${s['status']}${s['source'] == 'paypal_mcp' ? ' · PayPal MCP' : ''}',
                      )
                      .join('\n'),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            if (mine)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Delivered to room',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: composer.text.trim().isEmpty,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final leave = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Leave your draft?'),
          content: const Text('Your unsent message will be discarded.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep writing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Discard draft'),
            ),
          ],
        ),
      );
      if (leave == true && mounted) {
        composer.clear();
        await saveDraft();
        if (!mounted) return;
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Around the table'),
        actions: [
          IconButton(
            tooltip: 'Refresh connection',
            onPressed: () async {
              await refresh();
              if (mounted) connect();
            },
            icon: const Icon(Icons.refresh),
          ),
          if (room != null)
            IconButton(
              tooltip: 'Table preferences',
              onPressed: preferences,
              icon: const Icon(Icons.tune),
            ),
          if (room != null)
            IconButton(
              tooltip: 'People at your table',
              onPressed: people,
              icon: const Icon(Icons.group_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : room == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error ?? 'Conversation unavailable'),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          for (final action in [
                            (
                              'Menu',
                              Icons.menu_book_outlined,
                              () => navigate(
                                StorefrontPage(
                                  live: live,
                                  visitId: room!['visitId'],
                                ),
                              ),
                            ),
                            (
                              'Order',
                              Icons.receipt_long_outlined,
                              () => navigate(
                                room!['visitId'] != null
                                    ? visitPage(live, room!['visitId'])
                                    : orderPage(live, room!['orderId']),
                              ),
                            ),
                            (
                              'Bill',
                              Icons.payments_outlined,
                              closed
                                  ? null
                                  : () => allocate(
                                      context,
                                      live,
                                      visitId: room!['visitId'],
                                      orderId: room!['orderId'],
                                    ),
                            ),
                          ])
                            Expanded(
                              child: TextButton(
                                onPressed: action.$3,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Icon(action.$2), Text(action.$1)],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scroll,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${room!['audience']}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$delivery · ${records(room!['members']).length} people',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  children: [
                                    ActionChip(
                                      avatar: const Icon(Icons.lock_outline),
                                      label: const Text('Private help'),
                                      onPressed: () =>
                                          navigate(supportHome(live)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          if (records(room!['messages']).isEmpty)
                            const RaystoStoryHeader(
                              eyebrow: 'A little company',
                              title: 'Good food.\nShared moments.',
                              message: 'Choose together, ask your waiter, and settle your share. Ask Raysto when you want a hand.',
                              scene: RaystoScene.table,
                              compact: true,
                            ),
                          if (room!['beforeCursor'] != null)
                            TextButton(
                              onPressed: () async {
                                final previous = await live.api.query(
                                  'room',
                                  live.params({
                                    'id': id,
                                    'before': room!['beforeCursor'],
                                  }),
                                );
                                if (mounted) {
                                  setState(() {
                                    room = {
                                      ...room!,
                                      'messages': [
                                        ...records(previous['messages']),
                                        ...records(room!['messages']),
                                      ],
                                      'beforeCursor': previous['beforeCursor'],
                                    };
                                  });
                                }
                              },
                              child: const Text('Earlier messages'),
                            ),
                          for (final m in groupRoomActivity(
                            records(room!['messages']),
                            unreadSequence: firstUnreadSequence,
                          )) ...[
                            if (m['sequence'] == firstUnreadSequence)
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'New since your last visit',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            message(m),
                          ],
                        ],
                      ),
                    ),
                    if (!closed)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * .55,
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    FilterChip(
                                      label: const Text('Ask Raysto'),
                                      avatar: const Icon(
                                        Icons.auto_awesome,
                                        size: 18,
                                      ),
                                      selected: asking,
                                      onSelected: (v) => setState(() {
                                        asking = v;
                                        replyTo = null;
                                      }),
                                    ),
                                    if (room!['visitId'] != null)
                                      ActionChip(
                                        label: const Text('Request service'),
                                        onPressed: () async {
                                          await live.action(
                                            context,
                                            'Ask your waiter',
                                            'service.create',
                                            id: room!['visitId'],
                                            fields: const [
                                              InputSpec(
                                                'kind',
                                                'Request',
                                                options: [
                                                  'water',
                                                  'cutlery',
                                                  'help',
                                                  'bill',
                                                ],
                                              ),
                                            ],
                                          );
                                          await refresh();
                                        },
                                      ),
                                    if (activeRun != null)
                                      ActionChip(
                                        label: const Text('Cancel AI request'),
                                        onPressed: () async {
                                          await perform(
                                            context,
                                            () => live.api.command(
                                              'assistant.cancel',
                                              {},
                                              restaurantId: live.restaurantId,
                                              resourceId: activeRun,
                                            ),
                                          );
                                          if (mounted) {
                                            setState(() => activeRun = null);
                                          }
                                        },
                                      ),
                                    if (room!['hostUserId'] ==
                                            room!['currentUserId'] ||
                                        live.operator)
                                      ActionChip(
                                        label: const Text(
                                          'Reset unpaid equal split',
                                        ),
                                        onPressed: () async {
                                          final reset = await showDialog<bool>(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text(
                                                'Review a new equal split?',
                                              ),
                                              content: const Text(
                                                'Completed payments stay recorded. Unpaid proposals need a new review. A payment already in progress must finish first.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, false),
                                                  child: const Text(
                                                    'Keep split',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, true),
                                                  child: const Text(
                                                    'Reset unpaid proposals',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (reset == true &&
                                              context.mounted) {
                                            await perform(
                                              context,
                                              () => live.api.command(
                                                'room.split.reset',
                                                {},
                                                restaurantId: live.restaurantId,
                                                resourceId: id,
                                              ),
                                            );
                                            await refresh();
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                if (activeRun != null)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Raysto is working on your request. You can keep chatting or cancel it.',
                                    ),
                                  ),
                                if (asking)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '${room!['aiDisclosure']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                if (replyTo != null)
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text('Replying to a message'),
                                      ),
                                      IconButton(
                                        tooltip: 'Cancel reply',
                                        onPressed: () =>
                                            setState(() => replyTo = null),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: composer,
                                        minLines: 1,
                                        maxLines: 4,
                                        maxLength: asking ? 4000 : 2000,
                                        onChanged: (_) {
                                          setState(() {});
                                          draftTimer?.cancel();
                                          draftTimer = Timer(
                                            const Duration(milliseconds: 400),
                                            () => unawaited(saveDraft()),
                                          );
                                        },
                                        decoration: InputDecoration(
                                          counterText: '',
                                          hintText: asking
                                              ? 'What would help your table?'
                                              : 'Message your table',
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: IconButton.filled(
                                        tooltip: 'Send message',
                                        onPressed: busy ? null : send,
                                        icon: busy
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(Icons.arrow_upward),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'This conversation is read-only. Private help remains available.',
                        ),
                      ),
                  ],
                ),
              ),
      ),
    ),
  );
}
