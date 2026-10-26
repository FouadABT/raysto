part of 'operations.dart';

class _Menu extends StatefulWidget {
  const _Menu({required this.store, this.availabilityOnly = false});
  final DemoStore store;
  final bool availabilityOnly;
  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  String query = '', category = 'All', sort = 'Category';
  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final items = s.restaurantMenu
        .where(
          (i) =>
              (category == 'All' || i.category == category) &&
              '${i.name} ${i.description}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    items.sort(
      (a, b) => sort == 'Price'
          ? a.priceMinor.compareTo(b.priceMinor)
          : sort == 'Name'
          ? a.name.compareTo(b.name)
          : '${a.category}${a.name}'.compareTo('${b.category}${b.name}'),
    );
    return _List(
      storageKey: 'operations-menu',
      children: [
        _Heading(
          widget.availabilityOnly ? 'Item availability' : 'Your menu',
          subtitle: widget.availabilityOnly
              ? 'Availability affects new baskets. Existing orders keep their purchased items.'
              : 'A clear catalogue for customers and your team.',
        ),
        if (!widget.availabilityOnly) ...[
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => RestaurantScreen(store: s)),
            ),
            icon: const Icon(Icons.visibility_outlined),
            label: Text(context.tr('Preview guest menu')),
          ),
          ExperienceHero(
            eyebrow: 'MENU STUDIO',
            title: 'A menu worth exploring.',
            message: 'Build a clear menu, review the details and preview what your guests see.',
            icon: Icons.restaurant_menu,
            action: FilledButton.tonalIcon(
              onPressed: () => openOperation(context, s, 'menu-builder'),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(context.tr('Create a menu draft')),
            ),
          ),
          ExperienceMetrics(
            values: [
              (
                '${s.restaurantMenu.length}',
                'Dishes',
                Icons.restaurant_outlined,
              ),
              (
                '${s.restaurantMenu.map((i) => i.category).toSet().length}',
                'Categories',
                Icons.category_outlined,
              ),
              (
                '${s.restaurantMenu.where((i) => i.available).length}',
                'Available',
                Icons.check_circle_outline,
              ),
            ],
          ),
          if (s.importDraft.isNotEmpty)
            ExperienceAction(
              icon: Icons.edit_note_outlined,
              title: 'Continue your menu draft',
              subtitle: 'Your saved items are ready for review.',
              onTap: () => openOperation(context, s, 'menu-builder'),
            ),
          ExpansionTile(
            title: Text(context.tr('Menu readiness')),
            leading: const Icon(Icons.fact_check_outlined),
            children: [
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(context.tr('Add clear descriptions')),
                trailing: Text(
                  '${s.restaurantMenu.where((i) => i.description.trim().isEmpty).length}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: Text(context.tr('Confirm dietary information')),
                trailing: Text(
                  '${s.restaurantMenu.where((i) => !i.dietaryKnown).length}',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.tr(
                    'These counts highlight details to review. They never fill in dietary claims automatically.',
                  ),
                ),
              ),
            ],
          ),
        ],
        TextField(
          decoration: InputDecoration(
            labelText: context.tr('Search menu'),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => query = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final c in [
              'All',
              ...s.restaurantMenu.map((i) => i.category).toSet(),
            ])
              FilterChip(
                label: Text(context.tr(c)),
                selected: category == c,
                onSelected: (_) => setState(() => category = c),
              ),
          ],
        ),
        if (!widget.availabilityOnly) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => openOperation(context, s, 'item'),
                icon: const Icon(Icons.add),
                label: Text(context.tr('Add item')),
              ),
              OutlinedButton.icon(
                onPressed: () => openOperation(context, s, 'import'),
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(context.tr('Import sample menu')),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: sort,
            decoration: InputDecoration(labelText: context.tr('Sort by')),
            items: [
              for (final v in ['Category', 'Name', 'Price'])
                DropdownMenuItem(value: v, child: Text(context.tr(v))),
            ],
            onChanged: (v) => setState(() => sort = v!),
          ),
          TextButton.icon(
            onPressed: () => _categories(context, s),
            icon: const Icon(Icons.category_outlined),
            label: Text(context.tr('Manage categories')),
          ),
        ],
        if (items.isEmpty)
          _Empty(
            title: context.tr('No matching menu items'),
            message: context.tr('Try another search or category.'),
          ),
        for (final item in items)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item.asset,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (_, error, stack) =>
                            const SizedBox.square(
                              dimension: 64,
                              child: Icon(Icons.restaurant_outlined),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${item.category} · ${_money(context, item.priceMinor)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr(item.available ? 'Available' : 'Unavailable'),
                  ),
                  subtitle: Text(context.tr('Applies to future orders')),
                  value: item.available,
                  onChanged: (value) =>
                      _act(context, () => s.setAvailability(item.id, value)),
                ),
                if (!widget.availabilityOnly)
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            openOperation(context, s, 'item', id: item.id),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(context.tr('Edit')),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _act(context, () => s.duplicateMenuItem(item.id)),
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(context.tr('Duplicate')),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> _categories(BuildContext context, DemoStore s) async {
  await showAppSheet<void>(
    context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          'Categories',
          subtitle: 'Rename a category across all of its current items. Create a new category in the item editor.',
        ),
        for (final category in s.restaurantMenu.map((i) => i.category).toSet())
          ListTile(
            title: Text(category),
            subtitle: Text(
              '${s.restaurantMenu.where((i) => i.category == category).length} ${context.tr('items')}',
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () async {
              final name = await _ask(
                context,
                'Rename category',
                label: 'Category name',
                initial: category,
              );
              if (name != null && context.mounted) {
                _act(context, () {
                  for (final item
                      in s.restaurantMenu
                          .where((i) => i.category == category)
                          .toList()) {
                    s.saveMenuItem(item.copyWith(category: name));
                  }
                  Navigator.pop(context);
                });
              }
            },
          ),
      ],
    ),
  );
}

class _ItemEditor extends StatefulWidget {
  const _ItemEditor({required this.store, this.id, this.initial, this.onSave});
  final DemoStore store;
  final String? id;
  final MenuItem? initial;
  final ValueChanged<MenuItem>? onSave;
  @override
  State<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends State<_ItemEditor> {
  late final MenuItem original =
      widget.initial ??
      widget.store.restaurantMenu.where((i) => i.id == widget.id).firstOrNull ??
      MenuItem(
        id: _uniqueId(
          '${widget.store.currentRestaurant.id}-item',
          widget.store.menuItems.map((i) => i.id),
        ),
        restaurantId: widget.store.currentRestaurant.id,
        name: '',
        category: 'Mains',
        priceMinor: 0,
      );
  late final name = TextEditingController(text: original.name),
      category = TextEditingController(text: original.category),
      description = TextEditingController(text: original.description),
      price = TextEditingController(
        text: (original.priceMinor / 100).toStringAsFixed(2),
      ),
      ingredients = TextEditingController(
        text: original.ingredients.join(', '),
      );
  late String asset = original.asset;
  late bool known = original.dietaryKnown, available = original.available;
  late List<String> dietary = List.of(original.dietary);
  late List<ModifierGroup> groups = List.of(original.modifierGroups);
  final form = GlobalKey<FormState>();
  bool dirty = false;
  @override
  void initState() {
    super.initState();
    for (final c in [name, category, description, price, ingredients]) {
      c.addListener(() => setState(() => dirty = true));
    }
  }

  @override
  void dispose() {
    for (final c in [name, category, description, price, ingredients]) {
      c.dispose();
    }
    super.dispose();
  }

  MenuItem get draft => original.copyWith(
    name: name.text.trim(),
    category: category.text.trim(),
    description: description.text.trim(),
    priceMinor: ((double.tryParse(price.text.replaceAll(',', '.')) ?? 0) * 100)
        .round(),
    ingredients: ingredients.text
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList(),
    asset: asset,
    dietary: List.of(dietary),
    dietaryKnown: known,
    available: available,
    modifierGroups: List.of(groups),
    reviewFlags: [],
  );
  @override
  Widget build(BuildContext context) {
    if (!_manager(widget.store)) {
      return _Empty(
        title: context.tr('Access denied'),
        message: context.tr(
          'Only a manager or owner can edit catalogue information.',
        ),
      );
    }
    return _DraftGuard(
      dirty: dirty,
      child: Form(
        key: form,
        child: _List(
          children: [
            _Heading(
              widget.id == null && widget.initial == null
                  ? 'Create an item'
                  : 'Edit item',
              subtitle: 'Saved menu changes apply to future orders.',
            ),
            _field(context, 'Item name', name),
            _field(context, 'Category', category),
            _field(context, 'Description', description, lines: 3),
            _field(
              context,
              'Price in EUR',
              price,
              type: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final amount = double.tryParse((v ?? '').replaceAll(',', '.'));
                return amount == null || amount < 0
                    ? context.tr('Enter a valid price')
                    : null;
              },
            ),
            _field(
              context,
              'Ingredients, separated by commas',
              ingredients,
              lines: 2,
              validator: (_) => null,
            ),
            _Heading(
              'Illustrative photo',
              subtitle: 'Bundled photography illustrates the dish type.',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in {
                  'assets/images/salad_bowl.jpg': 'Garden bowl',
                  'assets/images/tomato_pasta.jpg': 'Tomato pasta',
                  'assets/images/wood_fired_pizza.jpg': 'Pizza',
                }.entries)
                  SizedBox(
                    width: 88,
                    child: InkWell(
                      onTap: () => setState(() {
                        asset = entry.key;
                        dirty = true;
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: asset == entry.key
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.asset(
                                entry.key,
                                width: 82,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            context.tr(entry.value),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Dietary information provided')),
              subtitle: Text(
                context.tr(
                  'When off, customers are asked to check with staff.',
                ),
              ),
              value: known,
              onChanged: (v) => setState(() {
                known = v;
                dirty = true;
              }),
            ),
            if (known)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in [
                    'Vegetarian',
                    'Vegan',
                    'Contains gluten',
                    'Contains dairy',
                    'Contains nuts',
                  ])
                    FilterChip(
                      label: Text(context.tr(tag)),
                      selected: dietary.contains(tag),
                      onSelected: (v) => setState(() {
                        v ? dietary.add(tag) : dietary.remove(tag);
                        dirty = true;
                      }),
                    ),
                ],
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('Available to order')),
              value: available,
              onChanged: (v) => setState(() {
                available = v;
                dirty = true;
              }),
            ),
            _Heading(
              'Modifier groups',
              subtitle: 'Minimum and maximum choices are validated before an item enters a basket.',
            ),
            for (final group in groups)
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${group.minSelections}–${group.maxSelections} ${context.tr('choices')}',
                    ),
                    Text(
                      group.options
                          .map(
                            (o) => '${o.name} ${_money(context, o.priceMinor)}',
                          )
                          .join(' · '),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => editGroup(group),
                          child: Text(context.tr('Edit')),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            groups.remove(group);
                            dirty = true;
                          }),
                          child: Text(context.tr('Remove')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => editGroup(null),
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add modifier group')),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  showAppSheet<void>(context, child: _ItemPreview(item: draft)),
              icon: const Icon(Icons.visibility_outlined),
              label: Text(context.tr('Customer preview')),
            ),
            AppButton(
              label: context.tr('Save item'),
              onPressed: () {
                if (!form.currentState!.validate()) return;
                _act(context, () {
                  if (widget.onSave != null) {
                    widget.onSave!(draft);
                  } else {
                    widget.store.saveMenuItem(draft);
                  }
                  setState(() => dirty = false);
                  Navigator.pop(context);
                });
              },
            ),
            if (widget.id != null)
              TextButton.icon(
                onPressed: () async {
                  if (await _confirm(
                        context,
                        'Archive item?',
                        'Historical orders remain unchanged. The item will be removed from new ordering.',
                        action: 'Archive',
                      ) &&
                      context.mounted) {
                    _act(context, () {
                      widget.store.archiveMenuItem(original.id);
                      Navigator.pop(context);
                    });
                  }
                },
                icon: const Icon(Icons.archive_outlined),
                label: Text(context.tr('Archive item')),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> editGroup(ModifierGroup? group) async {
    final result = await Navigator.of(context).push<ModifierGroup>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(context.tr('Modifier group'))),
          body: _ModifierEditor(
            group: group,
            identifier: _uniqueId(
              '${original.id}-group',
              groups.map((g) => g.id),
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        groups = [
          for (final g in groups)
            if (g.id != result.id) g,
          result,
        ];
        dirty = true;
      });
    }
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.item});
  final MenuItem item;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppMedia(
        asset: item.asset,
        semanticLabel: context.tr('Illustrative food photo'),
      ),
      _Heading(item.name, subtitle: item.description),
      const SizedBox(height: 12),
      Text(
        _money(context, item.priceMinor),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        item.dietaryKnown
            ? item.dietary.join(' · ')
            : context.tr('Dietary information not provided. Please ask staff.'),
      ),
      for (final g in item.modifierGroups)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '${g.name} · ${g.minSelections}–${g.maxSelections} ${context.tr('choices')}',
          ),
        ),
    ],
  );
}

class _ModifierEditor extends StatefulWidget {
  const _ModifierEditor({this.group, required this.identifier});
  final ModifierGroup? group;
  final String identifier;
  @override
  State<_ModifierEditor> createState() => _ModifierEditorState();
}

class _ModifierEditorState extends State<_ModifierEditor> {
  late final name = TextEditingController(text: widget.group?.name ?? ''),
      minimum = TextEditingController(
        text: '${widget.group?.minSelections ?? 0}',
      ),
      maximum = TextEditingController(
        text: '${widget.group?.maxSelections ?? 1}',
      );
  late List<ModifierOption> options = List.of(widget.group?.options ?? []);
  bool dirty = false;
  final form = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    for (final c in [name, minimum, maximum]) {
      c.addListener(() => setState(() => dirty = true));
    }
  }

  @override
  void dispose() {
    name.dispose();
    minimum.dispose();
    maximum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _DraftGuard(
    dirty: dirty,
    child: Form(
      key: form,
      child: _List(
        children: [
          _Heading(
            'Choices that make sense',
            subtitle: 'Use a maximum of one for mutually exclusive options.',
          ),
          _field(context, 'Group name', name),
          _field(
            context,
            'Minimum selections',
            minimum,
            type: TextInputType.number,
          ),
          _field(
            context,
            'Maximum selections',
            maximum,
            type: TextInputType.number,
          ),
          for (final option in options)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailLine(option.name, _money(context, option.priceMinor)),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => editOption(option),
                        child: Text(context.tr('Edit')),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          options.remove(option);
                          dirty = true;
                        }),
                        child: Text(context.tr('Remove')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => editOption(null),
            icon: const Icon(Icons.add),
            label: Text(context.tr('Add option')),
          ),
          AppButton(
            label: context.tr('Save group'),
            onPressed: () {
              if (!form.currentState!.validate()) return;
              final min = int.tryParse(minimum.text) ?? -1,
                  max = int.tryParse(maximum.text) ?? -1;
              if (min < 0 || max < 1 || max < min || max > options.length) {
                _act(
                  context,
                  () => throw const DomainException(
                    'Choose valid limits: 0 ≤ minimum ≤ maximum ≤ number of options.',
                  ),
                );
                return;
              }
              if (options.map((o) => o.name.toLowerCase()).toSet().length !=
                  options.length) {
                _act(
                  context,
                  () =>
                      throw const DomainException('Options need unique names.'),
                );
                return;
              }
              Navigator.pop(
                context,
                ModifierGroup(
                  id: widget.group?.id ?? widget.identifier,
                  name: name.text.trim(),
                  options: List.of(options),
                  minSelections: min,
                  maxSelections: max,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
  Future<void> editOption(ModifierOption? original) async {
    final n = TextEditingController(text: original?.name ?? ''),
        p = TextEditingController(
          text: ((original?.priceMinor ?? 0) / 100).toStringAsFixed(2),
        );
    final key = GlobalKey<FormState>();
    final option = await showDialog<ModifierOption>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Modifier option')),
        content: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(context, 'Name', n),
                const SizedBox(height: 16),
                _field(
                  context,
                  'Additional price in EUR',
                  p,
                  type: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => double.tryParse(v ?? '') == null
                      ? context.tr('Enter a number')
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate()) {
                Navigator.pop(
                  context,
                  ModifierOption(
                    id:
                        original?.id ??
                        _uniqueId(
                          '${widget.identifier}-option',
                          options.map((o) => o.id),
                        ),
                    name: n.text.trim(),
                    priceMinor: (double.parse(p.text) * 100).round(),
                  ),
                );
              }
            },
            child: Text(context.tr('Save')),
          ),
        ],
      ),
    );
    n.dispose();
    p.dispose();
    if (option != null && mounted) {
      setState(() {
        options = [
          for (final o in options)
            if (o.id != option.id) o,
          option,
        ];
        dirty = true;
      });
    }
  }
}

class _MenuImport extends StatefulWidget {
  const _MenuImport({required this.store});
  final DemoStore store;
  @override
  State<_MenuImport> createState() => _MenuImportState();
}

class _MenuImportState extends State<_MenuImport> {
  bool busy = false;
  String? error;
  int operation = 0;
  String fixture = 'Menu photo';
  late List<MenuItem> draft = List.of(widget.store.importDraft);
  @override
  void dispose() {
    operation++;
    super.dispose();
  }

  Future<void> extract() async {
    final token = ++operation,
        generation = widget.store.generation,
        account = widget.store.currentAccount.id,
        restaurant = widget.store.currentRestaurant.id;
    setState(() {
      busy = true;
      error = null;
    });
    await Future<void>.delayed(
      Duration(
        milliseconds: widget.store.delayMode == 'instant'
            ? 0
            : widget.store.delayMode == 'slow'
            ? 1800
            : 400,
      ),
    );
    if (!mounted ||
        token != operation ||
        generation != widget.store.generation ||
        account != widget.store.currentAccount.id ||
        restaurant != widget.store.currentRestaurant.id) {
      return;
    }
    try {
      if (!widget.store.online) {
        throw const DomainException(
          'Demo extraction is offline. Your draft is preserved; reconnect and retry.',
        );
      }
      final items = widget.store.importSampleMenu();
      setState(() {
        draft = List.of(items);
        busy = false;
      });
      widget.store.saveImportDraft(draft);
    } catch (e) {
      setState(() {
        busy = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final duplicates = draft
        .where(
          (i) => widget.store.restaurantMenu.any(
            (m) => m.name.toLowerCase() == i.name.toLowerCase(),
          ),
        )
        .map((i) => i.id)
        .toSet();
    final flags = draft.fold<int>(0, (n, i) => n + i.reviewFlags.length);
    return _List(
      children: [
        _Heading(
          'Import a sample menu',
          subtitle: 'Deterministic local extraction. No document is uploaded and no live AI service is called.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in ['Menu photo', 'Menu document'])
              ChoiceChip(
                label: Text(context.tr(f)),
                selected: fixture == f,
                onSelected: busy ? null : (_) => setState(() => fixture = f),
              ),
          ],
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Bundled fixture'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Image.asset(
                'assets/fixtures/olive-menu.png',
                semanticLabel: context.tr(
                  'Bundled menu fixture with two review fields',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fixture == 'Menu document'
                    ? context.tr(
                        'Source: bundled olive-menu.pdf. The image above is its page preview.',
                      )
                    : context.tr('Source: bundled olive-menu.png.'),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  'Review the unclear price and missing dietary information before publishing.',
                ),
              ),
            ],
          ),
        ),
        if (busy) ...[
          LinearProgressIndicator(
            semanticsLabel: context.tr('Extracting sample menu'),
          ),
          Text(context.tr('Reading the bundled sample…')),
          OutlinedButton(
            onPressed: () => setState(() {
              operation++;
              busy = false;
            }),
            child: Text(context.tr('Cancel extraction')),
          ),
        ] else
          AppButton(
            label: context.tr(
              draft.isEmpty ? 'Extract sample' : 'Extract again',
            ),
            icon: Icons.auto_awesome_outlined,
            onPressed: extract,
          ),
        if (error != null)
          _Empty(
            title: context.tr('Extraction paused'),
            message: error!,
            action: OutlinedButton(
              onPressed: extract,
              child: Text(context.tr('Retry')),
            ),
          ),
        if (draft.isNotEmpty) ...[
          _Heading(
            'Review extracted items',
            subtitle:
                '$flags ${context.tr('fields need review')} · ${duplicates.length} ${context.tr('possible duplicates')}',
          ),
          for (final item in draft)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailLine(item.name, _money(context, item.priceMinor)),
                  Text(item.category),
                  if (item.reviewFlags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Badge(
                      item.reviewFlags.join(' · '),
                      icon: Icons.error_outline,
                      attention: true,
                    ),
                  ],
                  if (duplicates.contains(item.id))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _Badge(
                        'Possible duplicate — rename or remove',
                        icon: Icons.copy_outlined,
                        attention: true,
                      ),
                    ),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(context.tr('Review item')),
                                ),
                                body: _ItemEditor(
                                  store: widget.store,
                                  initial: item,
                                  onSave: (value) {
                                    setState(
                                      () => draft = [
                                        for (final d in draft)
                                          d.id == value.id ? value : d,
                                      ],
                                    );
                                    widget.store.saveImportDraft(draft);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(context.tr('Review')),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          draft.remove(item);
                          widget.store.saveImportDraft(draft);
                        }),
                        child: Text(context.tr('Remove')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Text(
            context.tr(
              'The draft is saved locally. Nothing appears in the menu until you approve publication.',
            ),
          ),
          AppButton(
            label: context.tr('Approve & publish locally'),
            onPressed: flags == 0 && duplicates.isEmpty
                ? () async {
                    if (await _confirm(
                          context,
                          'Publish these items?',
                          'The reviewed items will become available in this local restaurant menu.',
                          action: 'Publish locally',
                        ) &&
                        context.mounted) {
                      _act(context, () {
                        widget.store.publishImport(draft);
                        widget.store.clearImportDraft();
                        setState(() => draft = []);
                      });
                    }
                  }
                : null,
          ),
          TextButton(
            onPressed: () async {
              if (await _confirm(
                    context,
                    'Discard import draft?',
                    'The current restaurant menu stays unchanged.',
                    action: 'Discard',
                  ) &&
                  mounted) {
                widget.store.clearImportDraft();
                setState(() => draft = []);
              }
            },
            child: Text(context.tr('Discard draft')),
          ),
        ],
      ],
    );
  }
}
