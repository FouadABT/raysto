part of 'operations.dart';

class _MenuBuilder extends StatefulWidget {
  const _MenuBuilder({required this.store});
  final DemoStore store;
  @override
  State<_MenuBuilder> createState() => _MenuBuilderState();
}

class _MenuBuilderState extends State<_MenuBuilder> {
  final _text = TextEditingController();
  late List<MenuItem> _draft = List.of(widget.store.importDraft);
  bool _sourceDirty = false;
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _duplicates {
    final names = <String>{
      ...widget.store.restaurantMenu.map((i) => i.name.trim().toLowerCase()),
    };
    return _draft.any((i) => !names.add(i.name.trim().toLowerCase()));
  }

  void _save(List<MenuItem> items) {
    widget.store.saveImportDraft(items);
    setState(() => _draft = List.of(items));
  }

  Future<void> _generate() async {
    try {
      final next = composeMenuDraft(
        _text.text,
        widget.store.currentRestaurant.id,
      );
      if (_draft.isNotEmpty &&
          !await _confirm(
            context,
            'Replace saved draft?',
            'Your current menu is unchanged. Only the saved draft will be replaced.',
          )) {
        return;
      }
      if (!mounted) return;
      _save(next);
      setState(() {
        _sourceDirty = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _edit(MenuItem? item) async {
    final original =
        item ??
        MenuItem(
          id: _uniqueId('${widget.store.currentRestaurant.id}-draft', [
            ...widget.store.menuItems.map((i) => i.id),
            ..._draft.map((i) => i.id),
          ]),
          restaurantId: widget.store.currentRestaurant.id,
          name: '',
          category: 'Mains',
          priceMinor: 0,
          asset: '',
          dietaryKnown: false,
        );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(context.tr('Review item'))),
          body: _ItemEditor(
            store: widget.store,
            initial: original,
            onSave: (value) {
              _save(
                item == null
                    ? [..._draft, value]
                    : [
                        for (final old in _draft)
                          old.id == value.id ? value : old,
                      ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    if (!await _confirm(
          context,
          'Publish these items?',
          'The reviewed items will become available in this local restaurant menu.',
          action: 'Publish locally',
        ) ||
        !mounted) {
      return;
    }
    _act(context, () {
      widget.store.publishImport(_draft);
      setState(() {
        _draft = [];
        _sourceDirty = false;
      });
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final flags = _draft.where((i) => i.reviewFlags.isNotEmpty).length;
    return _DraftGuard(
      dirty: _sourceDirty,
      child: _List(
        children: [
          ExperienceHero(
            eyebrow: 'FROM NOTES TO MENU',
            title: 'Your menu, beautifully organised.',
            message: 'Paste your dishes. We arrange a draft for you to edit and approve.',
            icon: Icons.auto_awesome_outlined,
          ),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('1. Bring your menu'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'One dish per line: Category | Dish | Price | Description. Prices are in EUR.',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _text,
                  minLines: 6,
                  maxLines: 12,
                  maxLength: 16000,
                  decoration: InputDecoration(
                    labelText: context.tr('Paste menu text'),
                    alignLabelWithHint: true,
                    hintText: 'Starters | Tomato soup | 6.50 | Roasted tomatoes and basil',
                  ),
                  onChanged: (_) => setState(() => _sourceDirty = true),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: context.tr('Generate menu draft'),
                  icon: Icons.auto_awesome_outlined,
                  onPressed: _generate,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Local formatting from your text. Dishes, prices and dietary claims are never invented.',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (_error != null)
            _Empty(title: context.tr('Check your menu text'), message: _error!),
          if (_draft.isNotEmpty) ...[
            ExperienceMetrics(
              values: [
                ('${_draft.length}', 'Dishes', Icons.restaurant_outlined),
                ('$flags', 'To review', Icons.fact_check_outlined),
                (
                  '${_draft.map((i) => i.category).toSet().length}',
                  'Categories',
                  Icons.category_outlined,
                ),
              ],
            ),
            _Heading(
              '2. Make it yours',
              subtitle: 'Your draft is saved locally. Open each dish to confirm its details.',
            ),
            for (final category in _draft.map((i) => i.category).toSet()) ...[
              Text(category, style: Theme.of(context).textTheme.titleLarge),
              for (final item in _draft.where((i) => i.category == category))
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.reviewFlags.contains(
                              'Confirm the price before publishing',
                            )
                            ? context.tr('Price needs review')
                            : _money(context, item.priceMinor),
                      ),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(item.description),
                      ],
                      const SizedBox(height: 10),
                      _Badge(
                        item.reviewFlags.isEmpty ? 'Reviewed' : 'Needs review',
                        icon: item.reviewFlags.isEmpty
                            ? Icons.check_circle_outline
                            : Icons.edit_note_outlined,
                        attention: item.reviewFlags.isNotEmpty,
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: () => _edit(item),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(context.tr('Review')),
                          ),
                          TextButton(
                            onPressed: () => _act(
                              context,
                              () => _save(
                                _draft.where((i) => i.id != item.id).toList(),
                              ),
                            ),
                            child: Text(context.tr('Remove')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
            if (_duplicates)
              _Empty(
                title: context.tr('Duplicate dish names'),
                message: context.tr(
                  'Rename or remove duplicates before publishing.',
                ),
              ),
          ],
          OutlinedButton.icon(
            onPressed: () => _edit(null),
            icon: const Icon(Icons.add),
            label: Text(context.tr('Add a dish manually')),
          ),
          if (_draft.isNotEmpty) ...[
            AppButton(
              label: context.tr('Publish locally'),
              icon: Icons.check_circle_outline,
              onPressed: flags == 0 && !_duplicates && !_sourceDirty
                  ? _publish
                  : null,
            ),
            Text(
              context.tr(
                'Publishing adds these dishes to the local restaurant menu. Existing dishes and past orders stay intact.',
              ),
            ),
            TextButton(
              onPressed: () async {
                if (await _confirm(
                      context,
                      'Discard import draft?',
                      'The current restaurant menu stays unchanged.',
                    ) &&
                    context.mounted) {
                  _act(context, () {
                    widget.store.clearImportDraft();
                    setState(() => _draft = []);
                  });
                }
              },
              child: Text(context.tr('Discard draft')),
            ),
          ],
        ],
      ),
    );
  }
}
