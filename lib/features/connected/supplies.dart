part of 'connected_app.dart';

/// Supplies on the phone (stream S3): what is running low and when it runs
/// out, a fast stock count, a delivery received by photographing its note
/// (checked line by line against the order and the supplier's bill), and the
/// supply planner's proposed orders to approve. The forecast is arithmetic on
/// the server; the AI explains it and proposes, a manager approves.
Widget suppliesPage(LiveContext live) => SuppliesPage(live: live);

/// Picks a delivery note: bytes and MIME type, or null when cancelled.
/// Replaced in tests; the app uses the camera or the file picker.
typedef SupplyNotePicker = Future<(Uint8List, String)?> Function({required bool camera});

Future<(Uint8List, String)?> _pickNote({required bool camera}) async {
  if (camera) {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      maxHeight: 2400,
      imageQuality: 88,
    );
    if (photo == null) return null;
    return (await photo.readAsBytes(), 'image/jpeg');
  }
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
  );
  if (file == null) return null;
  final mime = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'pdf': 'application/pdf',
  }[file.extension?.toLowerCase()];
  if (mime == null) {
    throw const PlatformFailure('unsupported', 'Choose JPEG, PNG, WebP or PDF.');
  }
  return (await file.xFile.readAsBytes(), mime);
}

/* ---------- Pure helpers (tested in test/supplies_app_test.dart) ---------- */

/// A quantity without trailing zeros, with its unit: "2.5 kg", "26 piece".
String supplyQty(num? n, [String? unit]) {
  if (n == null) return '';
  final text = n == n.roundToDouble()
      ? n.round().toString()
      : n.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  return unit == null || unit.isEmpty ? text : '$text $unit';
}

/// A typed count: "2,5" and "2.5" both read 2.5; anything else is null.
double? supplyParse(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(t)) return null;
  return double.tryParse(t);
}

/// reorder, low or ok: the same three states as the console.
String supplyState(Json row) => row['reorder'] == true
    ? 'reorder'
    : row['low'] == true
    ? 'low'
    : 'ok';

const _supplyFlags = {
  'short': 'Short',
  'over': 'More than ordered',
  'missing': 'Missing',
  'not_ordered': 'Not ordered',
  'price_up': 'Dearer',
  'price_down': 'Cheaper',
  'billed_differs': 'Bill differs',
};
String supplyFlagLabel(String flag) => _supplyFlags[flag] ?? flag;
bool supplyFlagAgainst(String flag) =>
    const {'short', 'missing', 'price_up', 'billed_differs'}.contains(flag);

/// One match line in English words, so colour is never the only signal.
String supplyMatchText(Json l, String currency) {
  final flags = ((l['flags'] as List?) ?? const []).map((f) => '$f').toList();
  final unit = l['unit'] as String?;
  if (flags.contains('not_ordered')) {
    return '${supplyQty(l['deliveredQty'] as num?, unit)} arrived but were not ordered.';
  }
  if (flags.contains('missing')) {
    return 'Nothing arrived of ${supplyQty(l['orderedQty'] as num?, unit)} ordered.';
  }
  final parts = <String>[];
  if (flags.contains('short')) {
    parts.add(
      '${supplyQty((l['qtyVariance'] as num).abs(), unit)} short (${supplyQty(l['deliveredQty'] as num?)} of ${supplyQty(l['orderedQty'] as num?, unit)})',
    );
  }
  if (flags.contains('over')) {
    parts.add('${supplyQty(l['qtyVariance'] as num?, unit)} more than ordered');
  }
  if ((flags.contains('price_up') || flags.contains('price_down')) &&
      l['deliveredUnitMinor'] != null &&
      l['orderedUnitMinor'] != null) {
    final pct = l['priceVariancePct'] as num? ?? 0;
    parts.add(
      '${money(l['deliveredUnitMinor'], currency).trim()} instead of ${money(l['orderedUnitMinor'], currency).trim()} a unit (${pct > 0 ? '+' : ''}$pct%)',
    );
  }
  if (flags.contains('billed_differs') && l['billedUnitMinor'] != null) {
    parts.add('the bill charges ${money(l['billedUnitMinor'], currency).trim()} a unit');
  }
  return parts.isEmpty ? 'As ordered.' : '${parts.join('; ')}.';
}

/* ---------- The page ---------- */

class SuppliesPage extends StatefulWidget {
  const SuppliesPage({super.key, required this.live, this.pickNote});
  final LiveContext live;
  final SupplyNotePicker? pickNote;
  @override
  State<SuppliesPage> createState() => _SuppliesPageState();
}

class _SuppliesPageState extends State<SuppliesPage> {
  LiveContext get live => widget.live;
  Json? forecast;
  List<Json> inbox = const [];
  List<Json> orders = const [];
  String? error;
  bool loading = true;

  /// Counts typed but not saved yet: the draft a back gesture must not lose.
  final counts = <int, TextEditingController>{};
  final pendingCounts = <String, PendingCommand>{};
  final decisions = <String, PendingCommand>{};
  PendingCommand? plan;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in counts.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final results = await Future.wait([
        live.api.query('stock.forecast', live.params()),
        live.api.query('agent.inbox', live.params()).catchError((_) => <String, dynamic>{'rows': []}),
        live.api.query('supplier.orders', live.params({'limit': 50})).catchError((_) => <String, dynamic>{'rows': []}),
      ]);
      if (!mounted) return;
      setState(() {
        forecast = results[0];
        inbox = records(results[1]['rows']);
        orders = records(results[2]['rows']);
        error = null;
        loading = false;
      });
    } on PlatformFailure catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          loading = false;
        });
      }
    }
  }

  List<Json> get rows => records(forecast?['rows']);
  String get currency => '${forecast?['currency'] ?? ''}';
  bool get drafting => counts.values.any((c) => c.text.trim().isNotEmpty);

  TextEditingController countFor(int id) =>
      counts.putIfAbsent(id, () => TextEditingController()..addListener(() => setState(() {})));

  Future<void> decide(Json a, String decision) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final key = '${a['id']}:${a['version']}:$decision';
      decisions[key] ??= live.api.prepare(
        'agent.decide',
        {'decision': decision},
        restaurantId: live.restaurantId,
        resourceId: a['id'] as int,
        version: a['version'] as int?,
      );
      final result = await live.api.submit(decisions[key]!);
      if (!mounted) return;
      final done = result['state'] == 'executed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'reject'
                ? context.tr('Dismissed.')
                : done
                ? context.tr('Approved. The draft order is ready to send.')
                : '${obj(result['result'])['message'] ?? context.tr('It could not be completed.')}',
          ),
        ),
      );
      await load();
    } on PlatformFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> askPlanner() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      plan ??= live.api.prepare('supplies.plan', const {}, restaurantId: live.restaurantId);
      await live.api.submit(plan!);
      plan = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('The supply planner is reading your stock. Its proposals appear here shortly.'))),
        );
      }
    } on PlatformFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> saveCounts() async {
    if (busy) return;
    final byId = {for (final r in rows) r['stockItemId'] as int: r};
    final typed = <(Json, double)>[];
    for (final e in counts.entries) {
      final v = supplyParse(e.value.text);
      final row = byId[e.key];
      if (v != null && row != null) typed.add((row, v));
    }
    if (typed.isEmpty) return;
    setState(() => busy = true);
    final notes = <String>[];
    try {
      for (final (row, value) in typed) {
        final id = row['stockItemId'] as int;
        final key = '$id:$value:${row['version']}';
        pendingCounts[key] ??= live.api.prepare(
          'stock.count',
          {'stockItemId': id, 'quantity': value},
          restaurantId: live.restaurantId,
        );
        final result = await live.api.submit(pendingCounts[key]!);
        pendingCounts.remove(key);
        counts[id]?.clear();
        final variance = (result['variance'] as num?) ?? 0;
        if (variance != 0) {
          notes.add('${row['name']} ${variance > 0 ? '+' : ''}${supplyQty(variance, row['unit'] as String?)}');
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            notes.isEmpty
                ? context.tr('Counts saved. Everything matched.')
                : '${context.tr('Counts saved. Differences')}: ${notes.join(', ')}',
          ),
        ),
      );
      await load();
    } on PlatformFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<bool> confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.tr('Discard your counts?')),
        content: Text(c.tr('The numbers you typed are not saved yet.')),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(c.tr('Keep counting'))),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text(c.tr('Discard'))),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !drafting,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      if (await confirmDiscard() && context.mounted) {
        for (final c in counts.values) {
          c.clear();
        }
        Navigator.of(context).pop();
      }
    },
    child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('Supplies')),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: context.tr('Low stock')),
              Tab(text: context.tr('Count')),
              Tab(text: context.tr('Receive')),
            ],
          ),
        ),
        body: SafeArea(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    AppNotice(title: context.tr('Supplies could not load'), message: error, icon: Icons.info_outline),
                    AppButton(label: context.tr('Try again'), icon: Icons.refresh, onPressed: load),
                  ],
                )
              : TabBarView(
                  children: [
                    RefreshIndicator(onRefresh: load, child: stockTab(context)),
                    countTab(context),
                    _ReceiveTab(
                      live: live,
                      orders: orders.where((o) => o['state'] == 'sent' || o['state'] == 'partiallyReceived').toList(),
                      pickNote: widget.pickNote ?? _pickNote,
                      onDone: load,
                    ),
                  ],
                ),
        ),
      ),
    ),
  );

  Widget stockTab(BuildContext c) {
    final sorted = [...rows]
      ..sort((a, b) {
        const order = {'reorder': 0, 'low': 1, 'ok': 2};
        final s = order[supplyState(a)]!.compareTo(order[supplyState(b)]!);
        if (s != 0) return s;
        return ((a['daysCover'] as num?) ?? 1e9).compareTo((b['daysCover'] as num?) ?? 1e9);
      });
    final reorder = rows.where((r) => r['reorder'] == true).length;
    final low = rows.where((r) => r['low'] == true).length;
    final proposals = inbox.where((a) => a['command'] == 'supplier.order.propose' && a['status'] == 'pending').toList();
    final basis = forecast?['basis'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            AppPill(
              label: '$reorder ${c.tr('to reorder now')}',
              icon: Icons.priority_high,
              color: reorder > 0 ? Theme.of(c).colorScheme.errorContainer : null,
            ),
            AppPill(label: '$low ${c.tr('at or under the low mark')}'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          basis == 'none'
              ? c.tr('No usage recorded yet: add recipes so each completed order counts down stock.')
              : c.tr('Usage from the last 28 days of sales and waste.'),
          style: Theme.of(c).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        for (final a in proposals) _proposal(c, a),
        AppButton(
          label: c.tr('Ask the planner what to order'),
          icon: Icons.auto_awesome,
          secondary: proposals.isNotEmpty,
          busy: busy && plan != null,
          onPressed: busy ? null : askPlanner,
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          RaystoEmptyState(
            title: c.tr('No stock items yet'),
            message: c.tr('They appear when a delivery note is read.'),
            scene: RaystoScene.bag,
          ),
        for (final r in sorted) _stockTile(c, r),
      ],
    );
  }

  Widget _stockTile(BuildContext c, Json r) {
    final state = supplyState(r);
    final scheme = Theme.of(c).colorScheme;
    final cover = r['daysCover'] as num?;
    final out = r['stockOutAt'] == null ? null : DateTime.tryParse('${r['stockOutAt']}')?.toLocal();
    final unit = r['unit'] as String?;
    return Semantics(
      container: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('${r['name']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                '${supplyQty(r['quantity'] as num?, unit)} ${c.tr('on hand')}',
                if (cover == null) c.tr('No recent use') else '${supplyQty(cover)} ${c.tr('days of cover')}',
                if (out != null) '${c.tr('runs out')} ${MaterialLocalizations.of(c).formatMediumDate(out)}',
                if (r['supplierName'] != null) '${r['supplierName']}',
              ].join(' · '),
            ),
            const SizedBox(height: 6),
            AppPill(
              label: switch (state) {
                'reorder' => '${c.tr('Reorder')} ${supplyQty(r['suggestedQty'] as num?, unit)}',
                'low' => c.tr('Low'),
                _ => c.tr('Covered'),
              },
              icon: state == 'ok' ? Icons.check : Icons.priority_high,
              color: switch (state) {
                'reorder' => scheme.errorContainer,
                'low' => scheme.tertiaryContainer,
                _ => null,
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _proposal(BuildContext c, Json a) {
    final evidence = obj(a['evidence']);
    final preview = obj(a['preview']);
    final lines = records(evidence['lines']);
    final alerts = records(evidence['priceAlerts']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(c.tr('Supply planner'), style: Theme.of(c).textTheme.labelLarge)),
              ],
            ),
            const SizedBox(height: 6),
            Text('${a['title']}', style: Theme.of(c).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${a['rationale']}'),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• ${l['name']}: ${supplyQty(l['qty'] as num?)}${l['reason'] == null ? '' : ' · ${l['reason']}'}'),
              ),
            if (alerts.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final p in alerts)
                    AppPill(
                      label: '${p['name']} ${(p['changePct'] as num) > 0 ? '+' : ''}${p['changePct']}%',
                      icon: Icons.trending_up,
                      color: Theme.of(c).colorScheme.errorContainer,
                    ),
                ],
              ),
            ],
            if (preview['totalMinor'] != null) ...[
              const SizedBox(height: 6),
              Text('${c.tr('Total')} ${money(preview['totalMinor'], '${preview['currency'] ?? currency}')}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 10),
            AppButton(
              label: c.tr('Approve the draft order'),
              icon: Icons.check,
              busy: busy,
              onPressed: busy ? null : () => decide(a, 'approve'),
            ),
            const SizedBox(height: 6),
            AppButton(
              label: c.tr('Dismiss'),
              secondary: true,
              onPressed: busy ? null : () => decide(a, 'reject'),
            ),
          ],
        ),
      ),
    );
  }

  Widget countTab(BuildContext c) {
    final typed = counts.values.where((t) => supplyParse(t.text) != null).length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            children: [
              Text(
                c.tr('Type what is on the shelf. Only the items you type are saved; the difference is kept so the forecast learns.'),
                style: Theme.of(c).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final r in rows) _countRow(c, r),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: typed == 0 ? c.tr('Type a count to save it') : '${c.tr('Save counts')} · $typed',
                icon: Icons.save_outlined,
                busy: busy && pendingCounts.isNotEmpty,
                onPressed: typed == 0 || busy ? null : saveCounts,
              ),
              if (drafting) ...[
                const SizedBox(height: 6),
                AppButton(
                  label: c.tr('Clear what I typed'),
                  secondary: true,
                  onPressed: busy
                      ? null
                      : () => setState(() {
                          for (final t in counts.values) {
                            t.clear();
                          }
                        }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _countRow(BuildContext c, Json r) {
    final id = r['stockItemId'] as int;
    final controller = countFor(id);
    final unit = '${r['unit'] ?? ''}';
    final invalid = controller.text.trim().isNotEmpty && supplyParse(controller.text) == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, box) {
          final narrow = box.maxWidth < 360 || MediaQuery.textScalerOf(context).scale(1) > 1.5;
          final label = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r['name']}', style: Theme.of(context).textTheme.titleSmall),
              Text('${c.tr('Now')}: ${supplyQty(r['quantity'] as num?, unit)}', style: Theme.of(context).textTheme.bodySmall),
            ],
          );
          final field = TextField(
            key: ValueKey('supply-count-$id'),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            decoration: InputDecoration(
              labelText: '${c.tr('Counted')} (${c.tr(unit)})',
              errorText: invalid ? c.tr('Use a number') : null,
              border: const OutlineInputBorder(),
            ),
          );
          return narrow
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [label, const SizedBox(height: 6), field])
              : Row(
                  children: [
                    Expanded(child: label),
                    const SizedBox(width: 12),
                    SizedBox(width: 160, child: field),
                  ],
                );
        },
      ),
    );
  }
}

/* ---------- Receive a delivery ---------- */

class _ReceiveTab extends StatefulWidget {
  const _ReceiveTab({required this.live, required this.orders, required this.pickNote, required this.onDone});
  final LiveContext live;
  final List<Json> orders;
  final SupplyNotePicker pickNote;
  final Future<void> Function() onDone;
  @override
  State<_ReceiveTab> createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<_ReceiveTab> with AutomaticKeepAliveClientMixin {
  LiveContext get live => widget.live;

  /// pick → uploading → checking → reading → result (or failed).
  String stage = 'pick';
  int? orderId;
  String? message;
  Json? task;
  Json? match;
  List<Json> actions = const [];
  final decisions = <String, PendingCommand>{};
  PendingCommand? receive;
  bool busy = false;
  final scroll = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.orders.length == 1) orderId = widget.orders.single['id'] as int;
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  /// Each stage starts at the top, so its summary is what the person sees
  /// first (the pick stage is often scrolled down to its buttons).
  void toTop() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && scroll.hasClients) scroll.jumpTo(0);
  });

  Future<void> start({required bool camera}) async {
    if (busy) return;
    (Uint8List, String)? picked;
    try {
      picked = await widget.pickNote(camera: camera);
    } on PlatformFailure catch (e) {
      setState(() => message = e.message);
      return;
    }
    if (picked == null || !mounted) return;
    final (bytes, mime) = picked;
    if (bytes.length > 8388608) {
      setState(() => message = context.tr('Choose a file smaller than 8 MB.'));
      return;
    }
    setState(() {
      busy = true;
      message = null;
      stage = 'uploading';
    });
    toTop();
    try {
      final intent = await live.api.command('media.upload', {
        'purpose': 'deliveryNote',
        'mime': mime,
        'byteLength': bytes.length,
        'sha256': sha256.convert(bytes).toString(),
      }, restaurantId: live.restaurantId);
      final id = intent['mediaId'] as int;
      await live.api.upload(id, bytes);
      if (!mounted) return;
      setState(() => stage = 'checking');
      // Every upload is scanned and cleaned before the agent may read it.
      for (var tries = 0; ; tries++) {
        final media = await live.api.query('media', live.params({'cursor': id - 1, 'limit': 1}));
        final status = records(media['rows']).where((r) => r['id'] == id).firstOrNull?['status'];
        if (status == 'approved') break;
        if (status == 'rejected') {
          throw const PlatformFailure('media_rejected', 'This photo could not be used. Try another photo or a PDF.');
        }
        if (tries > 60) {
          throw const PlatformFailure('media_pending', 'The photo is still being checked. Try again shortly.');
        }
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
      receive = live.api.prepare(
        'supply.receive',
        {'mediaId': id, 'supplierOrderId': ?orderId},
        restaurantId: live.restaurantId,
      );
      final started = await live.api.submit(receive!);
      if (!mounted) return;
      setState(() => stage = 'reading');
      final taskId = started['taskId'] as int;
      for (var tries = 0; tries < 120; tries++) {
        final t = await live.api.query('agent.task', live.params({'id': taskId}));
        if (!mounted) return;
        task = t;
        if (t['status'] == 'done' || t['status'] == 'failed') break;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      final t = task ?? const {};
      if (t['status'] != 'done') {
        setState(() {
          stage = 'failed';
          message = '${t['summary'] ?? 'The note could not be read.'}';
        });
        toTop();
        return;
      }
      Json? found;
      if (orderId != null) {
        final order = await live.api.query('supplier.order', live.params({'id': orderId}));
        final m = obj(order['delivery'])['match'];
        if (m is Map) found = obj(m);
      }
      if (!mounted) return;
      setState(() {
        match = found;
        actions = records(t['actions']).where((a) => a['status'] == 'pending').toList();
        stage = 'result';
      });
      toTop();
    } on PlatformFailure catch (e) {
      if (mounted) {
        setState(() {
          stage = 'failed';
          message = e.message;
        });
        toTop();
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> decide(Json a, String decision) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final key = '${a['id']}:${a['version']}:$decision';
      decisions[key] ??= live.api.prepare(
        'agent.decide',
        {'decision': decision},
        restaurantId: live.restaurantId,
        resourceId: a['id'] as int,
        version: a['version'] as int?,
      );
      final result = await live.api.submit(decisions[key]!);
      if (!mounted) return;
      final state = '${result['state']}';
      setState(() {
        actions = [
          for (final x in actions)
            if (x['id'] == a['id']) {...x, 'status': state == 'executed' ? 'executed' : decision == 'reject' ? 'rejected' : state} else x,
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'reject'
                ? context.tr('Dismissed.')
                : state == 'executed'
                ? (a['command'] == 'bill.match'
                      ? context.tr('Bill approved. Paying it is a separate step.')
                      : context.tr('Received. Stock is up.'))
                : '${obj(result['result'])['message'] ?? context.tr('It could not be completed.')}',
          ),
        ),
      );
      await widget.onDone();
    } on PlatformFailure catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void reset() {
    setState(() {
      stage = 'pick';
      message = null;
      task = null;
      match = null;
      actions = const [];
      receive = null;
    });
    toTop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.all(16),
      children: switch (stage) {
        'uploading' || 'checking' || 'reading' => progress(context),
        'result' => result(context),
        _ => pick(context),
      },
    );
  }

  List<Widget> pick(BuildContext c) => [
    RaystoStoryHeader(
      eyebrow: c.tr('Supplies agent'),
      title: c.tr('Receive a delivery.'),
      message: c.tr(
        'Photograph the supplier\'s note. Raysto reads it, checks every line against the order and the bill, and prepares the receipt for you to approve.',
      ),
      scene: RaystoScene.receipt,
      compact: true,
    ),
    if (stage == 'failed' && message != null)
      AppNotice(title: c.tr('That did not work'), message: message, icon: Icons.info_outline)
    else if (message != null)
      AppNotice(title: c.tr('Check the file'), message: message, icon: Icons.info_outline),
    AppSectionTitle(title: c.tr('Which order is this?')),
    RadioGroup<int?>(
      groupValue: orderId,
      onChanged: busy ? (_) {} : (v) => setState(() => orderId = v),
      child: Column(
        children: [
          for (final o in widget.orders)
            RadioListTile<int?>(
              contentPadding: EdgeInsets.zero,
              value: o['id'] as int,
              title: Text('PO-${o['id']} · ${o['supplierName'] ?? c.tr('No supplier')}'),
              subtitle: Text('${records(o['lines']).length} ${c.tr('lines')} · ${money(o['totalMinor'], '${o['currency'] ?? ''}')}'),
            ),
          RadioListTile<int?>(
            contentPadding: EdgeInsets.zero,
            value: null,
            title: Text(c.tr('No order: just read the note')),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    AppButton(
      label: c.tr('Photograph the delivery note'),
      icon: Icons.photo_camera_outlined,
      onPressed: busy ? null : () => start(camera: true),
    ),
    const SizedBox(height: 8),
    AppButton(
      label: c.tr('Choose a photo or PDF'),
      icon: Icons.upload_file,
      secondary: true,
      onPressed: busy ? null : () => start(camera: false),
    ),
  ];

  List<Widget> progress(BuildContext c) {
    final steps = [
      (c.tr('Sending the note'), stage != 'uploading'),
      (c.tr('Checking the file'), stage == 'reading'),
      (orderId == null ? c.tr('Reading the note') : c.tr('Reading the note and checking it against the order'), false),
    ];
    return [
      RaystoStoryHeader(
        eyebrow: c.tr('Supplies agent'),
        title: c.tr('Reading the delivery note…'),
        message: c.tr('This takes about half a minute. You can keep this screen open.'),
        scene: RaystoScene.receipt,
        compact: true,
      ),
      const LinearProgressIndicator(),
      const SizedBox(height: 16),
      for (final (label, done) in steps)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked),
          title: Text(label),
        ),
    ];
  }

  List<Widget> result(BuildContext c) => [
    if (match != null) SupplyMatchView(match: match!) else AppNotice(title: c.tr('Supplies agent'), message: '${task?['summary'] ?? ''}', icon: Icons.auto_awesome),
    const SizedBox(height: 12),
    for (final a in actions) ...[
      AppPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${a['title']}', style: Theme.of(c).textTheme.titleMedium),
            if (a['command'] == 'bill.match')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(c.tr('Approving puts the bill in payables; paying it is a separate step.')),
              ),
            const SizedBox(height: 10),
            if (a['status'] == 'pending') ...[
              AppButton(
                label: a['command'] == 'bill.match' ? c.tr('Approve the bill') : c.tr('Receive into stock'),
                icon: Icons.check,
                busy: busy,
                onPressed: busy ? null : () => decide(a, 'approve'),
              ),
              const SizedBox(height: 6),
              AppButton(label: c.tr('Dismiss'), secondary: true, onPressed: busy ? null : () => decide(a, 'reject')),
            ] else
              AppPill(
                label: a['status'] == 'executed' ? c.tr('Done') : c.tr('${a['status']}'),
                icon: a['status'] == 'executed' ? Icons.check : Icons.info_outline,
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
    ],
    AppButton(label: c.tr('Receive another delivery'), icon: Icons.add, secondary: true, onPressed: busy ? null : reset),
  ];
}

/// The 3-way match: each line of the order against the delivery note and
/// the bill, with every difference as a coloured label and in words.
class SupplyMatchView extends StatelessWidget {
  const SupplyMatchView({super.key, required this.match});
  final Json match;

  @override
  Widget build(BuildContext c) {
    final scheme = Theme.of(c).colorScheme;
    final code = '${match['currency'] ?? ''}';
    final lines = records(match['lines']);
    final flagged = (match['flagged'] as num?)?.toInt() ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionTitle(
          title: match['clean'] == true
              ? c.tr('Everything agrees')
              : '$flagged ${flagged == 1 ? c.tr('line differs') : c.tr('lines differ')}',
          subtitle: '${c.tr('Order')} PO-${match['supplierOrderId']}${match['reference'] == null ? '' : ' · ${match['reference']}'}',
        ),
        if (match['explanation'] != null)
          AppNotice(title: c.tr('Supplies agent'), message: '${match['explanation']}', icon: Icons.auto_awesome),
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppPanel(
              accent: ((l['flags'] as List?) ?? const []).isEmpty ? null : scheme.error,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l['name']}', style: Theme.of(c).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    '${c.tr('Ordered')} ${supplyQty(l['orderedQty'] as num?, l['unit'] as String?)} · ${c.tr('Arrived')} ${l['deliveredQty'] == null ? c.tr('None') : supplyQty(l['deliveredQty'] as num?, l['unit'] as String?)}',
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (((l['flags'] as List?) ?? const []).isEmpty)
                        AppPill(label: c.tr('Matches'), icon: Icons.check)
                      else
                        for (final f in (l['flags'] as List).map((f) => '$f'))
                          AppPill(
                            label: c.tr(supplyFlagLabel(f)),
                            icon: supplyFlagAgainst(f) ? Icons.priority_high : Icons.info_outline,
                            color: supplyFlagAgainst(f) ? scheme.errorContainer : scheme.tertiaryContainer,
                          ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(supplyMatchText(l, code), style: Theme.of(c).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            AppPill(label: '${c.tr('Ordered')} ${money(match['orderedTotalMinor'], code)}'),
            AppPill(label: '${c.tr('On the note')} ${money(match['deliveredTotalMinor'], code)}'),
            AppPill(
              label: match['billTotalMinor'] == null
                  ? c.tr('No bill yet')
                  : '${c.tr('Bill')} ${money(match['billTotalMinor'], code)}',
              color: match['billDiffers'] == true ? scheme.errorContainer : null,
            ),
          ],
        ),
      ],
    );
  }
}
