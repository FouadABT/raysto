import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../app/preview_store.dart';
import '../../design_system/design_system.dart';

typedef DishCallback = void Function(Dish dish);

class _PreviewAppBar extends StatelessWidget {
  const _PreviewAppBar({required this.onPreferences});
  final VoidCallback onPreferences;
  @override
  Widget build(BuildContext context) => SliverAppBar(
    floating: true,
    snap: true,
    toolbarHeight: 74,
    titleSpacing: 22,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            PhosphorIconsRegular.forkKnife,
            color: AppColors.lime,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'raysto',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
      ],
    ),
    actions: [
      AppIconButton(
        label: 'Open preferences',
        icon: PhosphorIconsRegular.slidersHorizontal,
        onPressed: onPreferences,
      ),
      const SizedBox(width: 14),
    ],
  );
}

class _PreviewScroll extends StatelessWidget {
  const _PreviewScroll({
    required this.storageKey,
    required this.bottomPadding,
    required this.onPreferences,
    required this.children,
  });
  final String storageKey;
  final double bottomPadding;
  final VoidCallback onPreferences;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: PageStorageKey(storageKey),
    slivers: [
      _PreviewAppBar(onPreferences: onPreferences),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(22, 12, 22, bottomPadding),
        sliver: SliverList.list(children: children),
      ),
    ],
  );
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({
    super.key,
    required this.bottomPadding,
    required this.onMenu,
    required this.onDish,
    required this.onPreferences,
  });
  final double bottomPadding;
  final VoidCallback onMenu;
  final DishCallback onDish;
  final VoidCallback onPreferences;
  @override
  Widget build(BuildContext context) => _PreviewScroll(
    storageKey: 'discover-scroll',
    bottomPadding: bottomPadding,
    onPreferences: onPreferences,
    children: [
      const AppEyebrow('A TASTE OF SOMETHING GOOD'),
      const SizedBox(height: 10),
      Text(
        'Good food.\nGood moments.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      Text(
        'A few thoughtful choices for your next meal.',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
      ),
      const SizedBox(height: 24),
      ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: AppColors.forest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AppMedia(
                    asset: sampleDishes.first.asset,
                    semanticLabel:
                        'Illustrative seasonal bowl with avocado, chickpeas and fresh vegetables',
                    height: 210,
                  ),
                  const Positioned(
                    left: 16,
                    top: 16,
                    child: AppPill(
                      label: 'THE GREEN TABLE',
                      color: AppColors.paper,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppEyebrow(
                      'FRESH PERSPECTIVES',
                      color: AppColors.lime,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Simple things.\nBeautifully together.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Meet the seasonal bowl.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.mint),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Take a closer look',
                      icon: PhosphorIconsRegular.arrowUpRight,
                      secondary: true,
                      onPressed: () => onDish(sampleDishes.first),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 28),
      AppSectionTitle(
        title: 'Find your kind of good',
        trailing: AppIconButton(
          label: 'Browse all menu ideas',
          icon: PhosphorIconsRegular.arrowRight,
          onPressed: onMenu,
        ),
      ),
      const SizedBox(height: 14),
      AppTapSurface(
        onTap: onMenu,
        label: 'Browse the sample menu',
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(PhosphorIconsRegular.bowlFood, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A little inspiration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fresh favorites & familiar comforts',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(PhosphorIconsRegular.arrowUpRight, size: 20),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const _PreviewCaption(),
    ],
  );
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.bottomPadding,
    required this.store,
    required this.onDish,
    required this.onPreferences,
  });
  final double bottomPadding;
  final PreviewStore store;
  final DishCallback onDish;
  final VoidCallback onPreferences;
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _category = 'All';
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dishes = sampleDishes
        .where(
          (dish) =>
              (_category == 'All' || dish.category == _category) &&
              ('${dish.name} ${dish.ingredients}').toLowerCase().contains(
                _search.text.trim().toLowerCase(),
              ),
        )
        .toList();
    return _PreviewScroll(
      storageKey: 'menu-scroll',
      bottomPadding: widget.bottomPadding,
      onPreferences: widget.onPreferences,
      children: [
        const AppEyebrow('THE SAMPLE MENU'),
        const SizedBox(height: 10),
        Text(
          'What sounds good?',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Explore an idea. Keep the ones you love.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Search the menu',
          hint: 'Try tomato, basil or avocado',
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'Fresh', 'Comfort']
              .map(
                (category) => AppChip(
                  label: category,
                  selected: _category == category,
                  onSelected: () => setState(() => _category = category),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        if (dishes.isEmpty)
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(PhosphorIconsRegular.magnifyingGlass, size: 40),
                const SizedBox(height: 16),
                Text(
                  'A different kind of craving?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No ideas match this search. Try another ingredient or see the whole menu.',
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Show the whole menu',
                  secondary: true,
                  onPressed: () => setState(() {
                    _search.clear();
                    _category = 'All';
                  }),
                ),
              ],
            ),
          ),
        for (final dish in dishes)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) => _DishCard(
                dish: dish,
                saved: widget.store.find(dish.id) != null,
                onTap: () => widget.onDish(dish),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const _PreviewCaption(),
      ],
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({
    required this.dish,
    required this.onTap,
    this.saved = false,
  });
  final Dish dish;
  final VoidCallback onTap;
  final bool saved;
  @override
  Widget build(BuildContext context) => AppTapSurface(
    onTap: onTap,
    label: 'View ${dish.name}${saved ? ', saved' : ''}',
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppMedia(
          asset: dish.asset,
          semanticLabel: 'Illustrative photograph of ${dish.name}',
          height: 180,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppEyebrow(dish.category.toUpperCase()),
                    const SizedBox(height: 7),
                    Text(
                      dish.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dish.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                saved
                    ? PhosphorIconsFill.bookmarkSimple
                    : PhosphorIconsRegular.arrowUpRight,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    super.key,
    required this.bottomPadding,
    required this.store,
    required this.onBrowse,
    required this.onDish,
    required this.onPreferences,
  });
  final double bottomPadding;
  final PreviewStore store;
  final VoidCallback onBrowse;
  final DishCallback onDish;
  final VoidCallback onPreferences;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => _PreviewScroll(
      storageKey: 'saved-scroll',
      bottomPadding: bottomPadding,
      onPreferences: onPreferences,
      children: [
        const AppEyebrow('YOUR LITTLE COLLECTION'),
        const SizedBox(height: 10),
        Text(
          'Good things,\nkept close.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Your ideas and notes, together for this session.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 28),
        if (store.saved.isEmpty)
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.bookmarkSimple,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Make room for a favorite.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Find something that speaks to you, then save it here with a little note.',
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Explore the menu',
                  icon: PhosphorIconsRegular.arrowRight,
                  onPressed: onBrowse,
                ),
              ],
            ),
          ),
        for (final item in store.saved)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppMedia(
                    asset: item.dish.asset,
                    semanticLabel:
                        'Illustrative photograph of ${item.dish.name}',
                    height: 160,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppPill(
                          label: item.collection,
                          icon: PhosphorIconsRegular.bookmarkSimple,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.dish.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (item.note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(item.note),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppButton(
                              label: 'View & edit',
                              icon: PhosphorIconsRegular.pencilSimple,
                              secondary: true,
                              expanded: false,
                              onPressed: () => onDish(item.dish),
                            ),
                            AppIconButton(
                              label: 'Remove ${item.dish.name}',
                              icon: PhosphorIconsRegular.trash,
                              onPressed: () {
                                final removed = store.remove(item.dish.id);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.dish.name} removed.',
                                      ),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () => store.restore(
                                          item.dish.id,
                                          removed,
                                        ),
                                      ),
                                    ),
                                  );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 22),
        const _PreviewCaption(),
      ],
    ),
  );
}

class DishScreen extends StatefulWidget {
  const DishScreen({super.key, required this.dish, required this.store});
  final Dish dish;
  final PreviewStore store;
  @override
  State<DishScreen> createState() => _DishScreenState();
}

class _DishScreenState extends State<DishScreen> {
  bool _sheetOpen = false;
  Future<void> _edit() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    final previous = widget.store.find(widget.dish.id);
    final result = await showAppSheet<SavedDish>(
      context,
      enableDrag: false,
      child: _SaveIdeaForm(dish: widget.dish, previous: previous),
    );
    _sheetOpen = false;
    if (!mounted || result == null) return;
    widget.store.save(result);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            previous == null
                ? 'Idea saved for this session.'
                : 'Your saved idea has been updated.',
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => widget.store.restore(widget.dish.id, previous),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final saved = widget.store.find(widget.dish.id);
      return Scaffold(
        appBar: AppBar(
          title: const Text('A closer look'),
          leading: AppIconButton(
            label: 'Back',
            icon: PhosphorIconsRegular.arrowLeft,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            AppMedia(
              asset: widget.dish.asset,
              semanticLabel: 'Illustrative photograph of ${widget.dish.name}',
              height: 260,
            ),
            const SizedBox(height: 24),
            AppEyebrow(widget.dish.category.toUpperCase()),
            const SizedBox(height: 10),
            Text(
              widget.dish.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              widget.dish.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            AppDisclosure(
              title: 'A few good ingredients',
              child: Text(widget.dish.ingredients),
            ),
            const SizedBox(height: 16),
            if (saved != null)
              AppNotice(
                title: 'A good idea, saved.',
                message: saved.note.isEmpty
                    ? saved.collection
                    : '${saved.collection}\n${saved.note}',
                icon: PhosphorIconsRegular.checkCircle,
                color: AppColors.mint,
              ),
            const SizedBox(height: 24),
            Text(
              'Illustrative menu idea and stock photograph. Ingredients are sample content, not verified dietary information.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(22, 12, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: saved == null ? 'Save this idea' : 'Edit saved idea',
                icon: saved == null
                    ? PhosphorIconsRegular.bookmarkSimple
                    : PhosphorIconsRegular.pencilSimple,
                onPressed: _edit,
              ),
              if (saved != null) ...[
                const SizedBox(height: 8),
                AppButton(
                  label: 'View saved ideas',
                  secondary: true,
                  onPressed: () {
                    widget.store.destination = 2;
                    Navigator.of(context).pop('saved');
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _SaveIdeaForm extends StatefulWidget {
  const _SaveIdeaForm({required this.dish, this.previous});
  final Dish dish;
  final SavedDish? previous;
  @override
  State<_SaveIdeaForm> createState() => _SaveIdeaFormState();
}

class _SaveIdeaFormState extends State<_SaveIdeaForm> {
  late final _note = TextEditingController(text: widget.previous?.note ?? '');
  late String _collection = widget.previous?.collection ?? 'Want to try';
  bool _submitting = false;
  bool _discarding = false;
  bool _confirmOpen = false;
  bool get _dirty =>
      _note.text != (widget.previous?.note ?? '') ||
      _collection != (widget.previous?.collection ?? 'Want to try');
  Future<void> _cancel() async {
    if (_confirmOpen || _submitting || _discarding) return;
    if (_dirty) {
      _confirmOpen = true;
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard these changes?'),
          content: const Text(
            'Your unsaved note and collection choice will be cleared.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard changes'),
            ),
          ],
        ),
      );
      _confirmOpen = false;
      if (!mounted || discard != true) return;
    }
    setState(() => _discarding = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty || _submitting || _discarding,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _cancel();
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppEyebrow('KEEP A GOOD THING'),
        const SizedBox(height: 10),
        Text(
          widget.previous == null
              ? 'A place for this idea.'
              : 'Make it your own.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(widget.dish.name),
        const SizedBox(height: 22),
        ...['Want to try', 'A favorite'].map(
          (choice) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppChoice(
              title: choice,
              selected: _collection == choice,
              onTap: () => setState(() => _collection = choice),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AppTextField(
          label: 'A little note (optional)',
          hint: 'Something to remember…',
          controller: _note,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        Text(
          'Kept only while the app is open. This preview does not place an order.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Save idea',
          icon: PhosphorIconsRegular.check,
          onPressed: _submitting || _discarding
              ? null
              : () {
                  if (_submitting || _discarding || _confirmOpen) return;
                  setState(() => _submitting = true);
                  final result = SavedDish(
                    dish: widget.dish,
                    note: _note.text.trim(),
                    collection: _collection,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) Navigator.pop(context, result);
                  });
                },
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Cancel',
          secondary: true,
          onPressed: _submitting || _discarding ? null : _cancel,
        ),
      ],
    ),
  );
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key, required this.store});
  final PreviewStore store;
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _opening = false;
  Future<void> _gallery() async {
    if (_opening) return;
    _opening = true;
    await Navigator.pushNamed(context, '/gallery');
    _opening = false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your preferences'),
      leading: AppIconButton(
        label: 'Back',
        icon: PhosphorIconsRegular.arrowLeft,
        onPressed: () => Navigator.maybePop(context),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const AppEyebrow('A LITTLE MORE YOU'),
        const SizedBox(height: 12),
        Text(
          'Comfort comes first.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text('Make this preview feel right for you.'),
        const SizedBox(height: 28),
        ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) => AppPanel(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: const Text('Reduce motion'),
              subtitle: const Text(
                'Use immediate changes. Device accessibility preferences always take priority.',
              ),
              value: widget.store.reducedMotion,
              onChanged: (value) => widget.store.reducedMotion = value,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const AppSectionTitle(title: 'Made to feel consistent'),
        const SizedBox(height: 14),
        AppTapSurface(
          onTap: _gallery,
          label: 'Open component gallery',
          color: AppColors.forest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                PhosphorIconsRegular.stack,
                color: AppColors.lime,
                size: 32,
              ),
              const SizedBox(height: 20),
              Text(
                'The design studio',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Explore the colors, components and little interactions behind Raysto.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.mint),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Open component gallery',
                      style: TextStyle(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    PhosphorIconsRegular.arrowUpRight,
                    color: AppColors.lime,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const AppDisclosure(
          title: 'About this first version',
          child: Text(
            'Raysto 0.1 is a mobile design foundation for Android and iOS. The restaurant, menu and photographs are illustrative. Saved ideas and preferences last for the current app session. There are no live orders, accounts, payments or AI services.',
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Fonts & open-source licenses',
          icon: PhosphorIconsRegular.fileText,
          secondary: true,
          onPressed: () => showLicensePage(
            context: context,
            applicationName: 'Raysto',
            applicationVersion: '0.1.0',
          ),
        ),
        const SizedBox(height: 28),
        const _PreviewCaption(),
      ],
    ),
  );
}

class MissingScreen extends StatelessWidget {
  const MissingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Something went missing')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(PhosphorIconsRegular.compass, size: 48),
          const SizedBox(height: 24),
          Text(
            'Let’s find your way back.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'This page is not part of the preview. Your session is still here.',
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Back to Discover',
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (_) => false),
          ),
        ],
      ),
    ),
  );
}

class _PreviewCaption extends StatelessWidget {
  const _PreviewCaption();
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 2),
        child: Icon(
          PhosphorIconsRegular.flower,
          size: 16,
          color: AppColors.secondaryText,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'A Raysto design preview · Sample content',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
