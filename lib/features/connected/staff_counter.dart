part of 'connected_app.dart';

/// One sale in progress. Each server step keeps its request, so a retry after
/// a dropped connection replays the same request and the server answers with
/// the result it already recorded: never a second order or a second payment.
class _Sale {
  _Sale(this.lines, this.label);
  final List<Json> lines;
  final String label;
  PendingCommand? quoteRequest, submitRequest, allocateRequest, checkoutRequest;
  Json? quote;
  int? orderId, checkoutId;
  String? method, approvalUrl, checkoutState;
  Json? order;
  bool get placed => orderId != null;
  bool get paid =>
      order != null &&
      const {
        'paid',
        'partiallyRefunded',
        'refunded',
      }.contains(order!['paymentStatus']);
}

/// The till. Staff ring up a takeaway for a walk-in; the customer pays cash
/// or scans a PayPal QR on their own phone. Only the server confirms capture.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key, required this.live});
  final LiveContext live;
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  Json? menu;
  String? error, category;
  final lines = <Json>[];
  final label = TextEditingController();
  _Sale? sale;
  Timer? poll;
  DateTime? waitingSince;
  bool busy = false, checking = false;

  LiveContext get live => widget.live;
  String get currency => '${menu?['currency'] ?? 'EUR'}';

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    poll?.cancel();
    label.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final d = await live.api.query('counter.menu', live.params());
      if (mounted) {
        setState(() {
          menu = d;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is PlatformFailure
              ? e.message
              : 'The menu could not be loaded.',
        );
      }
    }
  }

  Json? item(int productId) => records(
    menu?['menu'],
  ).where((i) => i['productId'] == productId).firstOrNull;

  int unitPrice(Json line) {
    final it = item(line['productId'] as int);
    if (it == null) return 0;
    var price = (it['priceMinor'] as num).toInt();
    final chosen = List<String>.from(line['options'] as List? ?? const []);
    for (final g in records(it['modifiers'])) {
      for (final o in records(g['options'])) {
        if (chosen.contains('${g['id']}:${o['id']}')) {
          price += (o['priceMinor'] as num? ?? 0).toInt();
        }
      }
    }
    return price;
  }

  /// The basket's own estimate. The amount actually collected is always the
  /// server's quote, shown before any money is taken.
  int get estimate =>
      lines.fold(0, (n, l) => n + unitPrice(l) * (l['quantity'] as int));

  void changed() {
    // Any change before the order exists starts a fresh quote.
    if (sale != null && !sale!.placed) sale = null;
  }

  Future<void> add(Json it) async {
    if (sale?.placed == true) return;
    final line = records(it['modifiers']).isEmpty
        ? <String, dynamic>{
            'productId': it['productId'],
            'quantity': 1,
            'options': <String>[],
            'note': '',
          }
        : await chooseItem(context, it, currency);
    if (line == null || !mounted) return;
    setState(() {
      changed();
      final same = lines.indexWhere(
        (l) =>
            l['productId'] == line['productId'] &&
            jsonEncode(l['options']) == jsonEncode(line['options']) &&
            l['note'] == line['note'],
      );
      if (same >= 0) {
        lines[same]['quantity'] =
            (lines[same]['quantity'] as int) + (line['quantity'] as int);
      } else {
        lines.add(line);
      }
    });
  }

  void adjust(Json line, int delta) => setState(() {
    changed();
    final q = (line['quantity'] as int) + delta;
    if (q <= 0) {
      lines.remove(line);
    } else {
      line['quantity'] = q;
    }
  });

  // Set in build, so failures after an await never need the context.
  String resumeNote = '';
  String noLink = '';

  Future<T> step<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformFailure catch (e) {
      throw PlatformFailure(e.code, '${e.message} $resumeNote');
    }
  }

  /// Runs the sale from its first unfinished step. Safe to call again.
  Future<void> charge(String method) async {
    if (lines.isEmpty || busy) return;
    setState(() => busy = true);
    try {
      final s = sale ??= _Sale(
        [for (final l in lines) Map<String, dynamic>.from(l)],
        label.text.trim(),
      );
      s.quoteRequest ??= PendingCommand(
        'quote.create',
        live.params({
          'fulfillment': 'pickup',
          'linesJson': jsonEncode(s.lines),
          'tipMinor': 0,
          'onBehalf': true,
          if (s.label.isNotEmpty) 'customerLabel': s.label,
        }),
      );
      if (!s.placed) {
        s.quote ??= await step(() => live.api.submit(s.quoteRequest!));
        if (!mounted) return;
        if (method == 'cash' && !await confirmCash(s.quote!['totalMinor'])) {
          return;
        }
        s.submitRequest ??= PendingCommand(
          'order.submit',
          live.params({'quoteId': s.quote!['id']}),
        );
        final placed = await step(() => live.api.submit(s.submitRequest!));
        s.orderId = placed['orderId'] as int;
      } else if (method == 'cash' &&
          s.method != 'cash' &&
          !await confirmCash(s.quote?['totalMinor'])) {
        return;
      }
      if (s.method != method) {
        // A new payment method for the same order is a new collection.
        s
          ..method = method
          ..allocateRequest = null
          ..checkoutRequest = null
          ..checkoutId = null
          ..approvalUrl = null
          ..checkoutState = null;
      }
      s.allocateRequest ??= PendingCommand(
        'payment.allocate',
        live.params({'orderId': s.orderId, 'method': method}),
      );
      s.checkoutId ??=
          (await step(() => live.api.submit(s.allocateRequest!)))['checkoutId']
              as int;
      if (method == 'paypal') {
        s.checkoutRequest ??= live.api.prepare(
          'payment.checkout',
          const {},
          restaurantId: live.restaurantId,
          resourceId: s.checkoutId,
        );
        final created = await step(() => live.api.submit(s.checkoutRequest!));
        s
          ..approvalUrl = created['approvalUrl'] as String?
          ..checkoutState = '${created['state']}';
        if (s.approvalUrl == null) {
          throw PlatformFailure('paypal_unavailable', noLink);
        }
        startPolling();
      }
      s.order = await step(
        () => live.api.query('order', live.params({'id': s.orderId})),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PlatformFailure
                  ? e.message
                  : 'The sale could not be completed. Please retry.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> confirmCash(dynamic totalMinor) async {
    final amount = money((totalMinor as num? ?? 0).toInt(), currency);
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(c.tr('Collect cash')),
            content: Text(
              '${c.tr('Take')} $amount ${c.tr('from the customer, then confirm.')}',
              style: Theme.of(c).textTheme.titleMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(c.tr('Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: Text('${c.tr('Cash received')} · $amount'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void startPolling() {
    poll?.cancel();
    waitingSince = DateTime.now();
    var ticks = 0;
    poll = Timer.periodic(const Duration(seconds: 2), (_) => check(++ticks));
  }

  /// Reads the checkout; every third read also asks the server to look at
  /// PayPal and capture if the customer approved, so the till does not wait
  /// for the webhook. The server refuses anything PayPal has not approved.
  Future<void> check(int tick) async {
    final s = sale;
    final id = s?.checkoutId;
    if (s == null || id == null || checking) return;
    checking = true;
    try {
      if (tick % 3 == 0 && {'created', 'approved'}.contains(s.checkoutState)) {
        try {
          await live.api.command(
            'payment.capture',
            {},
            restaurantId: live.restaurantId,
            resourceId: id,
          );
        } catch (_) {
          // A refused check is normal while the customer is still in PayPal.
        }
      }
      final c = await live.api.query('checkout', live.params({'id': id}));
      if (!mounted || sale != s) return;
      final state = '${c['state']}';
      if (state == 'completed') {
        poll?.cancel();
        final order = await live.api.query(
          'order',
          live.params({'id': s.orderId}),
        );
        if (mounted && sale == s) setState(() => s.order = order);
      } else if (state == 'cancelled' || state == 'failed') {
        // The order stays; the cashier picks a payment method again.
        poll?.cancel();
        setState(() {
          s
            ..method = null
            ..checkoutId = null
            ..allocateRequest = null
            ..checkoutRequest = null
            ..approvalUrl = null
            ..checkoutState = null;
        });
      } else {
        setState(() => s.checkoutState = state);
      }
    } catch (_) {
      // Keep polling; the next read may succeed.
    } finally {
      checking = false;
    }
  }

  Future<void> cancelPayment() async {
    final id = sale?.checkoutId;
    if (id == null) return;
    await perform(context, () async {
      await live.api.command(
        'payment.cancel',
        {},
        restaurantId: live.restaurantId,
        resourceId: id,
      );
    });
    await check(1);
  }

  /// Cancels an unpaid walk-in order, for a customer who walked away.
  Future<void> voidSale() async {
    final s = sale;
    if (s?.orderId == null) {
      reset();
      return;
    }
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(c.tr('Void this sale?')),
            content: Text(
              c.tr('The unpaid order is cancelled and leaves the kitchen board.'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(c.tr('Keep sale')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: Text(c.tr('Void sale')),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    await perform(context, () async {
      if (s!.checkoutId != null) {
        try {
          await live.api.command(
            'payment.cancel',
            {},
            restaurantId: live.restaurantId,
            resourceId: s.checkoutId,
          );
        } catch (_) {}
      }
      final order = await live.api.query(
        'order',
        live.params({'id': s.orderId}),
      );
      await live.api.command(
        'order.cancel',
        {'reason': 'Voided at the counter', 'approve': true},
        restaurantId: live.restaurantId,
        resourceId: s.orderId,
        version: order['version'] as int?,
      );
      reset();
    });
  }

  void reset() => setState(() {
    poll?.cancel();
    lines.clear();
    label.clear();
    sale = null;
  });

  @override
  Widget build(BuildContext context) {
    resumeNote = context.tr(
      'Your sale is kept: retry to continue where it stopped.',
    );
    noLink = context.tr('PayPal did not return a payment link. Retry.');
    final s = sale;
    final inProgress = s != null && !s.paid && (s.placed || lines.isNotEmpty);
    return PopScope(
      // A sale on the till is never dropped by a stray back gesture.
      canPop: !inProgress,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Counter')),
          actions: [
            IconButton(
              tooltip: context.tr('Refresh menu'),
              onPressed: load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              if (error != null && menu == null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    AppNotice(
                      title: context.tr('Connection needs attention'),
                      message: error,
                      action: AppButton(
                        label: context.tr('Retry'),
                        onPressed: load,
                      ),
                    ),
                  ],
                );
              }
              if (menu == null) {
                return const Center(
                  child: RaystoIllustration(scene: RaystoScene.menu),
                );
              }
              final ticketSide = ticket(context);
              if (box.maxWidth >= 840) {
                // Tablet: the menu on the left, the sale always in view.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: menuGrid(context, columns: true)),
                    SizedBox(
                      width: box.maxWidth >= 1100 ? 420 : 360,
                      child: Material(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: ticketSide,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (sale?.approvalUrl == null && sale?.paid != true)
                    menuGrid(context, columns: false),
                  const Divider(height: 32),
                  ...ticketSide,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget menuGrid(BuildContext context, {required bool columns}) {
    final all = records(menu!['menu']);
    final groups = all.map((i) => '${i['category']}').toSet().toList();
    final shown = all
        .where((i) => category == null || i['category'] == category)
        .toList();
    final locked = busy || sale?.placed == true;
    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final g in groups)
          AppChip(
            label: g,
            selected: category == g,
            onSelected: () =>
                setState(() => category = category == g ? null : g),
          ),
      ],
    );
    if (!columns) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chips,
          const SizedBox(height: 8),
          for (final it in shown)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${it['name']}'),
              subtitle: Text(money(it['priceMinor'], currency)),
              trailing: IconButton.filledTonal(
                tooltip: '${context.tr('Add')} ${it['name']}',
                onPressed: locked ? null : () => add(it),
                icon: const Icon(Icons.add),
              ),
              onTap: locked ? null : () => add(it),
            ),
        ],
      );
    }
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(child: chips),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 112,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: shown.length,
            itemBuilder: (c, i) {
              final it = shown[i];
              return Material(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.card),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: locked ? null : () => add(it),
                  child: Semantics(
                    button: true,
                    label: '${c.tr('Add')} ${it['name']}',
                    excludeSemantics: true,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${it['name']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            money(it['priceMinor'], currency),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> ticket(BuildContext context) {
    final s = sale;
    if (s != null && s.paid) return paidTicket(context, s);
    if (s?.approvalUrl != null) return qr(context, s!);
    return basket(context);
  }

  List<Widget> paidTicket(BuildContext context, _Sale s) {
    final order = s.order!;
    final theme = Theme.of(context);
    return [
      AppNotice(
        title: context.tr('Payment received'),
        icon: Icons.check_circle_outline,
        color: theme.extension<AppStatusColors>()?.success,
        message: s.method == 'cash'
            ? context.tr('Cash recorded. The kitchen has the ticket.')
            : context.tr(
                'PayPal confirmed the payment. The kitchen has the ticket.',
              ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          order['number'] == null ? '#${order['id']}' : '#${order['number']}',
          style: theme.textTheme.displayMedium,
        ),
      ),
      if (order['pickupCode'] != null)
        Center(
          child: Text(
            '${context.tr('Pickup code')} ${order['pickupCode']}',
            style: theme.textTheme.titleLarge,
          ),
        ),
      const SizedBox(height: 12),
      for (final line in records(order['lines'])) orderLineText(context, line),
      const SizedBox(height: 8),
      Text(
        '${context.tr('Total')} ${money(order['totalMinor'], currency)}',
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 24),
      AppButton(
        label: context.tr('New sale'),
        icon: Icons.add,
        onPressed: reset,
      ),
    ];
  }

  List<Widget> qr(BuildContext context, _Sale s) {
    final theme = Theme.of(context);
    final waited = waitingSince == null
        ? 0
        : DateTime.now().difference(waitingSince!).inMinutes;
    return [
      Text(
        '${context.tr('Scan with PayPal')} · ${money(s.quote?['totalMinor'] ?? estimate, currency)}',
        style: theme.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: QrImageView(
            data: s.approvalUrl!,
            size: 220,
            backgroundColor: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        s.checkoutState == 'approved' || s.checkoutState == 'capturing'
            ? context.tr('Approved · confirming with PayPal…')
            : context.tr('Waiting for the customer to approve in PayPal…'),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      if (AppMotion.reduced(context))
        Text(
          context.tr('Checking every few seconds.'),
          textAlign: TextAlign.center,
        )
      else
        const LinearProgressIndicator(),
      if (waited >= 10) ...[
        const SizedBox(height: 12),
        AppNotice(
          title: context.tr('Still waiting for PayPal'),
          message: context.tr(
            'Cancel this payment to take cash or try PayPal again.',
          ),
        ),
      ],
      const SizedBox(height: 24),
      AppButton(
        label: context.tr('Cancel payment'),
        secondary: true,
        onPressed: busy ? null : cancelPayment,
      ),
      const SizedBox(height: 8),
      Text(
        context.tr('Sandbox: no real money moves.'),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> basket(BuildContext context) {
    final theme = Theme.of(context);
    final s = sale;
    final placed = s?.placed == true;
    return [
      AppSectionTitle(
        title: placed
            ? '${context.tr('Order')} #${s!.order?['number'] ?? s.orderId} · ${context.tr('choose payment')}'
            : context.tr('This sale'),
      ),
      const SizedBox(height: 8),
      if (lines.isEmpty)
        Text(
          context.tr('Tap items to add them.'),
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      for (final line in lines)
        Row(
          children: [
            Expanded(
              child: Text(
                '${item(line['productId'] as int)?['name'] ?? 'Item'}'
                '${(line['options'] as List).isEmpty ? '' : ' · ${(line['options'] as List).length} ${context.tr('options')}'}',
              ),
            ),
            IconButton(
              tooltip: context.tr('Fewer'),
              onPressed: placed ? null : () => adjust(line, -1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('${line['quantity']}', style: theme.textTheme.titleMedium),
            IconButton(
              tooltip: context.tr('More'),
              onPressed: placed ? null : () => adjust(line, 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
            SizedBox(
              width: 80,
              child: Text(
                money(unitPrice(line) * (line['quantity'] as int),
                  currency,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      const SizedBox(height: 8),
      TextField(
        controller: label,
        enabled: !placed,
        maxLength: 80,
        onChanged: (_) => setState(changed),
        decoration: InputDecoration(
          labelText: context.tr('Customer name (optional)'),
          counterText: '',
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Text(
              context.tr('Total'),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            money(s?.quote?['totalMinor'] ?? estimate, currency),
            style: theme.textTheme.headlineSmall,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: AppButton(
              label: context.tr('Cash'),
              icon: Icons.payments_outlined,
              secondary: true,
              busy: busy,
              onPressed: lines.isEmpty ? null : () => charge('cash'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: context.tr('PayPal QR'),
              icon: Icons.qr_code_2,
              busy: busy,
              onPressed: lines.isEmpty ? null : () => charge('paypal'),
            ),
          ),
        ],
      ),
      if (placed || lines.isNotEmpty) ...[
        const SizedBox(height: 8),
        TextButton(
          onPressed: busy ? null : voidSale,
          child: Text(context.tr(placed ? 'Void sale' : 'Clear')),
        ),
      ],
    ];
  }
}

/// A line with its chosen options by name, as staff need to read it.
Widget orderLineText(BuildContext context, Json line) {
  final options = optionNames(line);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      '${line['quantity']}× ${line['name']}'
      '${options.isEmpty ? '' : ' · $options'}',
      textAlign: TextAlign.center,
    ),
  );
}
