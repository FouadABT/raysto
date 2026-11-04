part of 'connected_app.dart';

/// The AI accountant on the phone (stream S1): snap a bill and the
/// accountant reads it; approve it, pay it through PayPal Payouts after the
/// identity check, or mark it paid elsewhere with a photo of the proof;
/// create a pay link and show its QR code at the table. Every PayPal step
/// shows PayPal's own id; nothing claims a payment PayPal did not confirm.
Widget accountantPage(LiveContext live) => AccountantPage(live: live);

/// Picks a bill or a proof: bytes and MIME type, or null when cancelled.
/// Replaced in tests; the app uses the camera or the file picker.
typedef AccountantFilePicker = Future<(Uint8List, String)?> Function({required bool camera});

Future<(Uint8List, String)?> _pickAccountantFile({required bool camera}) async {
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

/* ---------- Pure helpers (tested in test/accountant_app_test.dart) ---------- */

const accountantBillStates = {
  'expected': 'Expected',
  'review': 'To review',
  'approved': 'Approved',
  'paying': 'Paying via PayPal',
  'paid': 'Paid via PayPal',
  'paidElsewhere': 'Paid elsewhere',
  'void': 'Void',
};

/// What a person may do with a bill, the one useful next step first.
List<String> accountantBillActions(Json b) {
  final payable = b['payVia'] == 'paypal' && '${b['payeeEmail'] ?? ''}'.isNotEmpty && b['duplicateOfId'] == null;
  return switch (b['state']) {
    'review' => [if (payable) 'pay', 'approve', 'markPaid'],
    'approved' => [if (payable) 'pay', 'markPaid'],
    'expected' => ['markPaid'],
    _ => const [],
  };
}

/// PayPal's side of a bill: its batch and item ids, or the proof. Empty
/// until PayPal has answered.
String accountantEvidence(Json b) {
  if (b['state'] == 'paidElsewhere') {
    return b['proofMediaId'] == null ? 'Paid elsewhere' : 'Paid elsewhere · proof #${b['proofMediaId']}';
  }
  final batch = b['providerBatchId'];
  if (batch is String && batch.isNotEmpty) {
    final item = b['providerItemId'] is String ? ' · item ${b['providerItemId']}' : '';
    return 'PayPal Payouts $batch$item · ${b['payoutState'] ?? 'sent'}';
  }
  if (b['state'] == 'paying') return 'Asking PayPal…';
  return '';
}

/// "120.50" → 12050; null for anything that is not a positive amount with at most two decimals.
int? accountantMinor(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,6}(\.\d{1,2})?$').hasMatch(t)) return null;
  final minor = (double.parse(t) * 100).round();
  return minor > 0 ? minor : null;
}

/* ---------- The page ---------- */

class AccountantPage extends StatefulWidget {
  const AccountantPage({super.key, required this.live, this.pickFile});
  final LiveContext live;
  final AccountantFilePicker? pickFile;
  @override
  State<AccountantPage> createState() => _AccountantPageState();
}

class _AccountantPageState extends State<AccountantPage> {
  LiveContext get live => widget.live;
  Json? bills, requests;
  List<Json> inbox = const [];
  String? error, note;
  bool busy = false;
  String? stage;

  @override
  void initState() {
    super.initState();
    unawaited(load());
  }

  Future<void> load() async {
    try {
      final results = await Future.wait([
        live.api.query('bills', live.params()),
        live.api.query('requests', live.params()),
        live.api.query('agent.inbox', live.params()).catchError((_) => <String, dynamic>{'rows': []}),
      ]);
      if (!mounted) return;
      setState(() {
        bills = results[0];
        requests = results[1];
        inbox = records(results[2]['rows']).where((a) => a['agent'] == 'accountant').toList();
        error = null;
      });
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  String get currency => '${bills?['currency'] ?? requests?['currency'] ?? ''}';

  /// Reserves, sends and waits for the scan; returns the approved media id.
  Future<int?> upload(String purpose, {required bool camera}) async {
    final picked = await (widget.pickFile ?? _pickAccountantFile)(camera: camera);
    if (picked == null) return null;
    final (bytes, mime) = picked;
    if (bytes.length > 8388608) {
      throw const PlatformFailure('too_large', 'Choose a file smaller than 8 MB.');
    }
    if (mounted) setState(() => stage = context.tr('Sending…'));
    final intent = await live.api.command('media.upload', {
      'purpose': purpose,
      'mime': mime,
      'byteLength': bytes.length,
      'sha256': sha256.convert(bytes).toString(),
    }, restaurantId: live.restaurantId);
    final id = intent['mediaId'] as int;
    await live.api.upload(id, bytes);
    if (mounted) setState(() => stage = context.tr('Scanning for safety…'));
    for (var tries = 0; ; tries++) {
      final media = await live.api.query('media', {'cursor': id - 1, 'limit': 1});
      final status = records(media['rows']).where((r) => r['id'] == id).firstOrNull?['status'];
      if (status == 'approved') return id;
      if (status == 'rejected') {
        throw const PlatformFailure('media_rejected', 'This file could not be used. Try another photo or a PDF.');
      }
      if (tries > 60) {
        throw const PlatformFailure('media_pending', 'The file is still being checked. Try again shortly.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }
  }

  Future<void> run(Future<String?> Function() work) async {
    if (busy) return;
    setState(() {
      busy = true;
      note = null;
    });
    try {
      final said = await work();
      if (!mounted) return;
      if (said != null) showRaystoSnackBar(context, said);
      await load();
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => note = e.message);
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          stage = null;
        });
      }
    }
  }

  Future<void> snap({required bool camera}) => run(() async {
    final id = await upload('bill', camera: camera);
    if (id == null || !mounted) return null;
    final r = await live.api.command('bill.snap', {'mediaId': id}, restaurantId: live.restaurantId);
    if (!mounted) return null;
    if (r['duplicateOfId'] != null) {
      return '${context.tr('This file is already bill')} #${r['duplicateOfId']}.';
    }
    // The accountant reads it in a few seconds; look again then.
    unawaited(Future<void>.delayed(const Duration(seconds: 6), () => mounted ? load() : null));
    return context.tr('The accountant is reading the bill. It appears here in a few seconds.');
  });

  /// A money command after the identity check; the same request key carries the retry.
  Future<Json> submitMoney(PendingCommand pending) async {
    try {
      return await live.api.submit(pending);
    } on PlatformFailure catch (e) {
      if (!{'reauthentication_required', 'mfa_required'}.contains(e.code) || !mounted) rethrow;
      final ok = await verifyIdentity(context, live.runtime);
      if (!ok) throw PlatformFailure(e.code, 'Payment paused until you confirm it is you.');
      return live.api.submit(pending);
    }
  }

  Future<void> pay(Json b) => run(() async {
    final r = await submitMoney(
      live.api.prepare(
        'bill.pay',
        b['state'] == 'review' ? {'approve': true} : {},
        restaurantId: live.restaurantId,
        resourceId: b['id'] as int,
      ),
    );
    if (!mounted) return null;
    final batch = r['providerBatchId'];
    return batch is String
        ? '${context.tr('Sent to PayPal Payouts')}: $batch'
        : context.tr('Sent to PayPal Payouts');
  });

  Future<void> approve(Json b) => run(() async {
    await live.api.command('bill.approve', {}, restaurantId: live.restaurantId, resourceId: b['id'] as int, version: b['version'] as int?);
    return mounted ? context.tr('Approved.') : null;
  });

  Future<void> paidElsewhere(Json b) => run(() async {
    final proof = await upload('receipt', camera: true);
    if (proof == null) return null;
    await live.api.command('bill.markPaid', {'proofMediaId': proof}, restaurantId: live.restaurantId, resourceId: b['id'] as int, version: b['version'] as int?);
    return mounted ? '${context.tr('Marked paid elsewhere, with proof')} #$proof' : null;
  });

  Future<void> createLink() async {
    final r = await showModalBottomSheet<Json>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PayLinkForm(live: live, currency: currency),
    );
    if (r != null && mounted) {
      await load();
      if (mounted) await showLink(r);
    }
  }

  Future<void> showLink(Json r) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => _PayLinkSheet(request: r),
  );

  Future<void> openBill(Json b) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (c) => _BillSheet(
      bill: b,
      onAction: (action) {
        Navigator.of(c).pop();
        switch (action) {
          case 'pay':
            unawaited(pay(b));
          case 'approve':
            unawaited(approve(b));
          case 'markPaid':
            unawaited(paidElsewhere(b));
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final billRows = records(bills?['rows']).where((b) => b['state'] != 'void').toList();
    final requestRows = records(requests?['rows']).where((r) => r['state'] != 'cancelled').toList();
    final bs = obj(bills?['summary']);
    final rs = obj(requests?['summary']);
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Accountant'))),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              if (error != null)
                RaystoEmptyState(title: context.tr('The books could not load'), message: error!)
              else if (bills == null)
                const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
              else ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Figure(label: context.tr('Bills to pay'), value: money(bs['dueMinor'], currency)),
                    _Figure(
                      label: context.tr('Overdue'),
                      value: money((bs['overdueMinor'] as num? ?? 0) + (rs['overdueMinor'] as num? ?? 0), currency),
                      alert: ((bs['overdueMinor'] as num? ?? 0) + (rs['overdueMinor'] as num? ?? 0)) > 0,
                    ),
                    _Figure(label: context.tr('Owed to you'), value: money(rs['outstandingMinor'], currency)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: busy ? null : () => snap(camera: true),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(context.tr('Snap a bill')),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => snap(camera: false),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(context.tr('Choose a file')),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : createLink,
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(context.tr('New pay link')),
                    ),
                  ],
                ),
                if (stage != null || note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(stage ?? note!, style: TextStyle(color: note != null && stage == null ? Theme.of(context).colorScheme.error : null)),
                    ),
                  ),
                for (final a in inbox)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AgentActionCard(live: live, action: a, onDone: load),
                  ),
                const SizedBox(height: 20),
                Text(context.tr('Bills'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (billRows.isEmpty)
                  Text(context.tr('No bills yet. Snap one: the accountant reads it and puts it in review.'))
                else
                  for (final b in billRows) _BillTile(bill: b, onTap: () => openBill(b)),
                const SizedBox(height: 20),
                Text(context.tr('Payment requests'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (requestRows.isEmpty)
                  Text(context.tr('No payment requests yet.'))
                else
                  for (final r in requestRows) _RequestTile(request: r, onTap: () => showLink(r)),
                const SizedBox(height: 16),
                Text(
                  context.tr('PayPal Sandbox: no real money moves.'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value, this.alert = false});
  final String label, value;
  final bool alert;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 260),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: alert ? scheme.error : null,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill, required this.onTap});
  final Json bill;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final state = context.tr(accountantBillStates['${bill['state']}'] ?? '${bill['state']}');
    final evidence = accountantEvidence(bill);
    final overdue = bill['overdue'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        minVerticalPadding: 12,
        onTap: onTap,
        leading: Icon(
          bill['state'] == 'paid' || bill['state'] == 'paidElsewhere' ? Icons.task_alt : Icons.receipt_long_outlined,
        ),
        title: Text('${bill['vendor']} · ${money(bill['amountMinor'], '${bill['currency']}')}'),
        subtitle: Text(
          [
            overdue ? context.tr('Overdue') : state,
            if (bill['dueAt'] != null) '${context.tr('Due')} ${'${bill['dueAt']}'.substring(0, 10)}',
            if (evidence.isNotEmpty) evidence,
          ].join(' · '),
          style: overdue ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _BillSheet extends StatelessWidget {
  const _BillSheet({required this.bill, required this.onAction});
  final Json bill;
  final void Function(String action) onAction;
  @override
  Widget build(BuildContext context) {
    final actions = accountantBillActions(bill);
    final read = obj(bill['read']);
    final evidence = accountantEvidence(bill);
    final amount = money(bill['amountMinor'], '${bill['currency']}');
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${bill['vendor']}: $amount', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(context.tr(accountantBillStates['${bill['state']}'] ?? '${bill['state']}')),
            if (bill['state'] == 'paid') ...[
              const SizedBox(height: 8),
              Align(alignment: AlignmentDirectional.centerStart, child: Chip(avatar: const Icon(Icons.verified_outlined), label: Text(context.tr('PAID')))),
            ],
            if (read['explanation'] != null) ...[const SizedBox(height: 12), Text('${read['explanation']}')],
            if (evidence.isNotEmpty) ...[const SizedBox(height: 12), SelectableText(evidence)],
            if (bill['duplicateOfId'] != null) ...[
              const SizedBox(height: 12),
              Text(
                '${context.tr('This looks like bill')} #${bill['duplicateOfId']}.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (bill['payVia'] == 'paypal' && bill['payeeEmail'] != null) ...[
              const SizedBox(height: 12),
              Text('${context.tr('Pays to')} ${bill['payeeEmail']}'),
            ],
            const SizedBox(height: 20),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: switch (a) {
                  'pay' => FilledButton.icon(
                    onPressed: () => onAction('pay'),
                    icon: const Icon(Icons.payments_outlined),
                    label: Text('${context.tr('Pay')} $amount ${context.tr('via PayPal (identity check)')}'),
                  ),
                  'approve' => OutlinedButton.icon(
                    onPressed: () => onAction('approve'),
                    icon: const Icon(Icons.check),
                    label: Text(context.tr('Approve')),
                  ),
                  _ => OutlinedButton.icon(
                    onPressed: () => onAction('markPaid'),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.tr('Paid elsewhere: photograph the proof')),
                  ),
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request, required this.onTap});
  final Json request;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final paid = request['state'] == 'paid';
    final capture = request['providerCaptureId'];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        minVerticalPadding: 12,
        onTap: onTap,
        leading: Icon(paid ? Icons.task_alt : Icons.qr_code_2),
        title: Text('${request['payerName']} · ${money(request['amountMinor'], '${request['currency']}')}'),
        subtitle: Text(
          [
            '${request['description']}',
            paid ? context.tr('Paid') : request['overdue'] == true ? context.tr('Overdue') : context.tr('Waiting'),
            if (capture is String) 'PayPal $capture',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _PayLinkSheet extends StatelessWidget {
  const _PayLinkSheet({required this.request});
  final Json request;
  @override
  Widget build(BuildContext context) {
    final url = request['payUrl'];
    final payable = {'open', 'sent'}.contains(request['state']);
    final amount = money(request['amountMinor'], '${request['currency']}');
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            Text('${request['payerName']}: $amount', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${request['description']}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (url is String && payable) ...[
              Semantics(
                label: '${context.tr('QR code to pay')} $amount',
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(data: url, size: 220, backgroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(url, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) showRaystoSnackBar(context, context.tr('Copied'));
                },
                icon: const Icon(Icons.copy),
                label: Text(context.tr('Copy the link')),
              ),
              const SizedBox(height: 8),
              Text(context.tr('The payer scans it and pays in PayPal’s own checkout.'), textAlign: TextAlign.center),
            ] else if (request['state'] == 'paid')
              Chip(avatar: const Icon(Icons.verified_outlined), label: Text('${context.tr('PAID')} · PayPal ${request['providerCaptureId'] ?? ''}'))
            else
              Text(context.tr(requestWords['${request['state']}'] ?? '${request['state']}')),
          ],
        ),
      ),
    );
  }
}

const requestWords = {'draft': 'Draft', 'open': 'Link ready', 'sent': 'Sent', 'paid': 'Paid', 'cancelled': 'Cancelled'};

class _PayLinkForm extends StatefulWidget {
  const _PayLinkForm({required this.live, required this.currency});
  final LiveContext live;
  final String currency;
  @override
  State<_PayLinkForm> createState() => _PayLinkFormState();
}

class _PayLinkFormState extends State<_PayLinkForm> {
  final name = TextEditingController();
  final email = TextEditingController();
  final what = TextEditingController();
  final amount = TextEditingController();
  String? error;
  bool busy = false;
  PendingCommand? pending;
  String? fingerprint;

  @override
  void dispose() {
    for (final c in [name, email, what, amount]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    final minor = accountantMinor(amount.text);
    if (name.text.trim().isEmpty || what.text.trim().isEmpty || minor == null) {
      setState(() => error = context.tr('Name who pays, what it is for, and an amount with at most two decimals.'));
      return;
    }
    final data = {
      'kind': 'link',
      'payerName': name.text.trim(),
      if (email.text.trim().isNotEmpty) 'payerEmail': email.text.trim(),
      'description': what.text.trim(),
      'amountMinor': minor,
    };
    // A retry of the same form keeps its request key: never two links.
    final next = jsonEncode(data);
    if (pending == null || next != fingerprint) {
      pending = widget.live.api.prepare('request.create', data, restaurantId: widget.live.restaurantId);
      fingerprint = next;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final r = await widget.live.api.submit(pending!);
      if (mounted) Navigator.of(context).pop(r);
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.tr('New pay link'), style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            TextField(controller: name, decoration: InputDecoration(labelText: context.tr('Who pays')), textInputAction: TextInputAction.next),
            const SizedBox(height: 8),
            TextField(controller: what, decoration: InputDecoration(labelText: context.tr('For')), textInputAction: TextInputAction.next),
            const SizedBox(height: 8),
            TextField(
              controller: amount,
              decoration: InputDecoration(labelText: '${context.tr('Amount')} (${widget.currency})'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: context.tr('Their email (optional)')),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => submit(),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy ? null : submit,
              icon: const Icon(Icons.qr_code_2),
              label: Text(context.tr('Create the pay link')),
            ),
          ],
        ),
      ),
    ),
  );
}
