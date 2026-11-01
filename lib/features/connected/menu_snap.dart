part of 'connected_app.dart';

/// "Snap your menu": the owner photographs a paper menu or a menu board, the
/// menu agent reads it into a categorised, translated draft, and the owner
/// reviews and publishes it. Prices are read, never guessed.
class MenuSnapPage extends StatefulWidget {
  const MenuSnapPage({super.key, required this.live});
  final LiveContext live;
  @override
  State<MenuSnapPage> createState() => _MenuSnapPageState();
}

class _SnapPage {
  _SnapPage(this.bytes, this.mime, this.name);
  final Uint8List bytes;
  final String mime;
  final String name;
}

class _MenuSnapPageState extends State<MenuSnapPage> {
  static const maxPages = 5;
  final pages = <_SnapPage>[];

  /// pick → uploading → checking → reading → review (or failed).
  String stage = 'pick';
  String? message;
  Json? task;
  Json? action;
  List<Json> dishes = const [];
  PendingCommand? snap;
  PendingCommand? publish;
  bool busy = false;

  LiveContext get live => widget.live;

  Future<void> add({required bool camera}) async {
    if (pages.length >= maxPages) return;
    await perform(context, () async {
      if (camera) {
        final photo = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: 2400,
          maxHeight: 2400,
          imageQuality: 88,
        );
        if (photo == null) return;
        final bytes = await photo.readAsBytes();
        _accept(_SnapPage(bytes, 'image/jpeg', photo.name));
      } else {
        final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        );
        if (file == null) return;
        final bytes = await file.xFile.readAsBytes();
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
        _accept(_SnapPage(bytes, mime, file.name));
      }
    });
  }

  void _accept(_SnapPage page) {
    if (page.bytes.length > 8388608) {
      throw const PlatformFailure('too_large', 'Choose a file smaller than 8 MB.');
    }
    if (mounted) setState(() => pages.add(page));
  }

  Future<void> start() async {
    if (busy || pages.isEmpty) return;
    setState(() {
      busy = true;
      message = null;
      stage = 'uploading';
    });
    try {
      final ids = <int>[];
      for (final page in pages) {
        final intent = await live.api.command('media.upload', {
          'purpose': 'menuSource',
          'mime': page.mime,
          'byteLength': page.bytes.length,
          'sha256': sha256.convert(page.bytes).toString(),
        }, restaurantId: live.restaurantId);
        final id = intent['mediaId'] as int;
        await live.api.upload(id, page.bytes);
        ids.add(id);
      }
      if (!mounted) return;
      setState(() => stage = 'checking');
      // Every upload is scanned and cleaned before anything reads it.
      final first = ids.reduce(min);
      for (var tries = 0; ; tries++) {
        final media = await live.api.query(
          'media',
          live.params({'cursor': first - 1, 'limit': 20}),
        );
        final rows = {for (final r in records(media['rows'])) r['id']: r['status']};
        if (ids.any((id) => rows[id] == 'rejected')) {
          throw const PlatformFailure(
            'media_rejected',
            'One photo could not be used. Try another photo or a PDF.',
          );
        }
        if (ids.every((id) => rows[id] == 'approved')) break;
        if (tries > 60) {
          throw const PlatformFailure('media_pending', 'The photos are still being checked. Try again shortly.');
        }
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
      snap ??= live.api.prepare('menu.snap', {'mediaIds': ids}, restaurantId: live.restaurantId);
      final started = await live.api.submit(snap!);
      if (!mounted) return;
      setState(() => stage = 'reading');
      final id = started['taskId'] as int;
      for (var tries = 0; tries < 120; tries++) {
        final t = await live.api.query('agent.task', live.params({'id': id}));
        if (!mounted) return;
        setState(() => task = t);
        if (t['status'] == 'done' || t['status'] == 'failed') break;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      final t = task ?? const {};
      final found = records(t['actions']).where((a) => a['status'] == 'pending').firstOrNull;
      if (t['status'] != 'done' || found == null) {
        setState(() {
          stage = 'failed';
          message = '${t['summary'] ?? 'The menu could not be read.'}';
        });
        return;
      }
      final draftId = obj(found['preview'])['draftId'];
      final drafts = await live.api.query('menu.drafts', live.params({'cursor': (draftId as int) - 1, 'limit': 1}));
      if (!mounted) return;
      setState(() {
        action = found;
        dishes = records(records(drafts['rows']).firstOrNull?['items']);
        stage = 'review';
      });
    } on PlatformFailure catch (e) {
      if (mounted) {
        setState(() {
          stage = 'failed';
          message = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> decide(String decision) async {
    final a = action;
    if (a == null || busy) return;
    setState(() => busy = true);
    try {
      publish ??= live.api.prepare(
        'agent.decide',
        {'decision': decision},
        restaurantId: live.restaurantId,
        resourceId: a['id'] as int,
        version: a['version'] as int?,
      );
      final result = await live.api.submit(publish!);
      if (!mounted) return;
      final done = result['state'] == 'executed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            done
                ? context.tr('Your menu is live.')
                : decision == 'reject'
                ? context.tr('Kept as a draft.')
                : '${obj(result['result'])['message'] ?? context.tr('It could not be completed.')}',
          ),
        ),
      );
      if (done || decision == 'reject') Navigator.of(context).pop();
    } on PlatformFailure catch (e) {
      if (mounted) setState(() => message = e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.tr('Snap your menu'))),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: switch (stage) {
          'review' => review(context),
          'uploading' || 'checking' || 'reading' => progress(context),
          _ => pick(context),
        },
      ),
    ),
  );

  List<Widget> pick(BuildContext c) => [
    RaystoStoryHeader(
      eyebrow: c.tr('Menu agent'),
      title: c.tr('Photograph your menu.'),
      message: c.tr(
        'Raysto reads dishes, prices and sections, translates them, and prepares your menu for you to check. Prices are read, never guessed.',
      ),
      scene: RaystoScene.menu,
      compact: true,
    ),
    if (stage == 'failed' && message != null)
      AppNotice(title: c.tr('That did not work'), message: message, icon: Icons.info_outline),
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (i, p) in pages.indexed)
          InputChip(
            avatar: Icon(p.mime == 'application/pdf' ? Icons.picture_as_pdf : Icons.photo),
            label: Text('${c.tr('Page')} ${i + 1}'),
            onDeleted: busy ? null : () => setState(() => pages.removeAt(i)),
          ),
      ],
    ),
    const SizedBox(height: 12),
    if (pages.length < maxPages)
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          AppButton(
            label: c.tr('Take a photo'),
            icon: Icons.photo_camera_outlined,
            expanded: false,
            onPressed: busy ? null : () => add(camera: true),
          ),
          AppButton(
            label: c.tr('Choose a photo or PDF'),
            icon: Icons.upload_file,
            secondary: true,
            expanded: false,
            onPressed: busy ? null : () => add(camera: false),
          ),
        ],
      ),
    const SizedBox(height: 20),
    AppButton(
      label: pages.isEmpty
          ? c.tr('Add at least one page')
          : c.tr('Read my menu'),
      icon: Icons.auto_awesome,
      busy: busy,
      onPressed: pages.isEmpty || busy ? null : start,
    ),
  ];

  List<Widget> progress(BuildContext c) {
    final trace = (task?['trace'] as List? ?? const []).whereType<Map>().toList();
    final read = trace.where((t) => t['tool'] == 'read_page').length;
    final organized = trace.any((t) => t['tool'] == 'organize');
    final steps = [
      (c.tr('Uploading your pages'), stage != 'uploading'),
      (c.tr('Checking the files'), stage == 'reading'),
      ('${c.tr('Reading the menu')} · $read/${pages.length}', read == pages.length),
      (c.tr('Sorting sections and translating'), organized),
    ];
    return [
      RaystoStoryHeader(
        eyebrow: c.tr('Menu agent'),
        title: c.tr('Reading your menu…'),
        message: c.tr('This takes about half a minute. You can keep this screen open.'),
        scene: RaystoScene.menu,
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

  List<Widget> review(BuildContext c) {
    final a = action!;
    final evidence = obj(a['evidence']);
    final check = ((evidence['checkPrices'] as List?) ?? const []).map((e) => '$e').toSet();
    final sections = <String, List<Json>>{};
    for (final d in dishes) {
      (sections['${d['category']}'] ??= []).add(d);
    }
    final order = ((evidence['sections'] as List?) ?? const []).map((e) => '$e').toList();
    final names = [
      ...order.where(sections.containsKey),
      ...sections.keys.where((k) => !order.contains(k)),
    ];
    return [
      AppNotice(
        title: '${a['title']}',
        message: '${a['rationale']}',
        icon: Icons.auto_awesome,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          AppPill(label: '${evidence['new'] ?? 0} ${c.tr('new')}'),
          AppPill(label: '${evidence['changed'] ?? 0} ${c.tr('updated')}'),
          if ((evidence['languages'] as List?)?.isNotEmpty == true)
            AppPill(
              label: '${c.tr('Translated')}: ${(evidence['languages'] as List).join(', ').toUpperCase()}',
              icon: Icons.translate,
            ),
          if (check.isNotEmpty)
            AppPill(
              label: '${check.length} ${c.tr('prices to check')}',
              icon: Icons.priority_high,
              color: Theme.of(c).colorScheme.errorContainer,
            ),
        ],
      ),
      for (final name in names) ...[
        AppSectionTitle(title: name),
        for (final d in sections[name]!)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${d['name']}'),
            subtitle: Text(
              [
                if ('${d['description'] ?? ''}'.isNotEmpty) '${d['description']}',
                if ((d['dietary'] as List?)?.isNotEmpty == true) (d['dietary'] as List).join(' · '),
                if (d['allergens'] == null) c.tr('Allergens unknown'),
              ].join('\n'),
            ),
            trailing: check.contains('${d['name']}')
                ? Text(
                    c.tr('Check price'),
                    style: TextStyle(color: Theme.of(c).colorScheme.error, fontWeight: FontWeight.w700),
                  )
                : Text(money(d['priceMinor'], '')),
          ),
      ],
      if (message != null) Text(message!, style: TextStyle(color: Theme.of(c).colorScheme.error)),
      const SizedBox(height: 12),
      AppButton(
        label: c.tr('Publish my menu'),
        icon: Icons.check,
        busy: busy,
        onPressed: busy ? null : () => decide('approve'),
      ),
      const SizedBox(height: 8),
      AppButton(
        label: c.tr('Keep as a draft'),
        secondary: true,
        onPressed: busy ? null : () => decide('reject'),
      ),
      const SizedBox(height: 8),
      Text(
        c.tr('Dishes without a readable price stay off sale until you set one. Allergens stay unknown until you add them.'),
        style: Theme.of(c).textTheme.bodySmall,
      ),
    ];
  }
}
