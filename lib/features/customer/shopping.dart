part of 'customer_screens.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({
    super.key,
    required this.store,
    required this.itemId,
    this.line,
  });
  final DemoStore store;
  final String itemId;
  final CartLine? line;
  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  late int _quantity = widget.line?.quantity ?? 1;
  late final _note = TextEditingController(text: widget.line?.note ?? '');
  late final Map<String, List<String>> _selections = {
    for (final e
        in (widget.line?.selections ?? <String, List<String>>{}).entries)
      e.key: List.of(e.value),
  };
  String? _error;
  bool _dirty = false, _saved = false;
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.store.menuItems
        .where((m) => m.id == widget.itemId)
        .firstOrNull;
    if (item == null) {
      return const MobilePage(
        title: 'Item unavailable',
        children: [
          EmptyState(
            title: 'This item is no longer listed',
            message: 'Return to the menu for current choices.',
          ),
        ],
      );
    }
    final modifiers = item.modifierGroups
        .expand(
          (g) =>
              g.options.where((o) => (_selections[g.id] ?? []).contains(o.id)),
        )
        .fold<int>(0, (v, o) => v + o.priceMinor);
    return DraftGuard(
      dirty: _dirty && !_saved,
      child: MobilePage(
        title: item.name,
        actions: [
          IconButton(
            tooltip: context.tr('Favorite item'),
            onPressed: () =>
                setState(() => widget.store.toggleFavorite(item.id)),
            icon: Icon(
              widget.store.currentAccount.favorites.contains(item.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AppMedia(
              asset: item.asset,
              semanticLabel:
                  '${item.name} · ${context.tr('Illustrative photo')}',
              height: 220,
            ),
          ),
          Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
          MoneyText(item.priceMinor, large: true),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!item.dietaryKnown)
                StatusBadge(
                  'Dietary information not provided',
                  icon: Icons.info_outline,
                )
              else
                for (final d in item.dietary)
                  StatusBadge(d, icon: Icons.eco_outlined),
              if (!item.available)
                StatusBadge('Unavailable', icon: Icons.remove_circle_outline),
            ],
          ),
          AppDisclosure(
            title: context.tr('Ingredients and dietary information'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.ingredients.join(', ')),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Ask staff about allergens. The demo does not guarantee absence of cross-contact.',
                  ),
                ),
              ],
            ),
          ),
          for (final group in item.modifierGroups)
            Section(
              title: group.name,
              subtitle: group.required ? 'Required' : 'Optional',
              child: Column(
                children: [
                  Text(
                    '${context.tr('Choose')} ${group.minSelections}–${group.maxSelections}',
                  ),
                  for (final option in group.options)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.name),
                      subtitle: option.priceMinor == 0
                          ? Text(context.tr('Included'))
                          : MoneyText(option.priceMinor),
                      value: (_selections[group.id] ?? []).contains(option.id),
                      onChanged: (v) => setState(() {
                        _dirty = true;
                        final selected = _selections.putIfAbsent(
                          group.id,
                          () => [],
                        );
                        if (v == true) {
                          if (group.maxSelections == 1) selected.clear();
                          selected.add(option.id);
                        } else {
                          selected.remove(option.id);
                        }
                      }),
                    ),
                ],
              ),
            ),
          TextField(
            controller: _note,
            maxLength: 200,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.tr('Note for the kitchen'),
              hintText: context.tr('Optional · for this item only'),
            ),
            onChanged: (_) => setState(() => _dirty = true),
          ),
          QuantityStepper(
            value: _quantity,
            onChanged: (v) => setState(() {
              _quantity = v;
              _dirty = true;
            }),
          ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: AppNotice(
                title: context.tr('Check your selection'),
                message: _error,
                icon: Icons.error_outline,
              ),
            ),
          FilledButton(
            onPressed: !item.available
                ? null
                : () => guarded(context, () async {
                    for (final g in item.modifierGroups) {
                      final n = (_selections[g.id] ?? []).length;
                      if (n < g.minSelections || n > g.maxSelections) {
                        setState(
                          () => _error =
                              '${g.name}: ${context.tr('Choose')} ${g.minSelections}–${g.maxSelections}',
                        );
                        return;
                      }
                    }
                    if (widget.line == null) {
                      widget.store.addToCart(
                        item.id,
                        quantity: _quantity,
                        selections: _selections,
                        note: _note.text,
                      );
                    } else {
                      widget.store.updateCartLine(
                        widget.line!.id,
                        quantity: _quantity,
                        selections: _selections,
                        note: _note.text,
                      );
                    }
                    setState(() => _saved = true);
                    await Future<void>.delayed(Duration.zero);
                    if (context.mounted) {
                      Navigator.pop(context);
                      showMessage(
                        context,
                        widget.line == null
                            ? 'Added to your cart'
                            : 'Cart updated',
                      );
                    }
                  }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '${context.tr(widget.line == null ? 'Add to cart' : 'Update item')} · ${money(context, (item.priceMinor + modifiers) * _quantity)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.store});
  final DemoStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MobilePage(
      title: 'Favorites',
      children: [
        if (store.currentAccount.favorites.isEmpty)
          const EmptyState(
            title: 'Keep your good finds',
            message: 'Tap the heart on a restaurant or dish to find it here.',
          ),
        for (final r in store.restaurants.where(
          (r) => store.currentAccount.favorites.contains(r.id),
        ))
          RestaurantCard(
            store: store,
            restaurant: r,
            onTap: () {
              store.selectRestaurant(r.id);
              openPage(context, RestaurantScreen(store: store));
            },
          ),
        for (final i in store.menuItems.where(
          (i) => store.currentAccount.favorites.contains(i.id),
        ))
          MenuRow(
            store: store,
            item: i,
            onTap: () {
              store.selectRestaurant(i.restaurantId);
              openPage(context, ItemScreen(store: store, itemId: i.id));
            },
          ),
      ],
    ),
  );
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({
    super.key,
    required this.store,
    this.embedded = false,
  });
  final DemoStore store;
  final bool embedded;
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _prompt = TextEditingController(),
      _budget = TextEditingController(text: '25');
  bool _vegetarian = true, _busy = false;
  String? _response;
  List<CartLine>? _proposal;
  int _request = 0;
  @override
  void dispose() {
    _request++;
    _prompt.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _ask([String? value]) async {
    if (_busy) return;
    final store = widget.store,
        account = widget.store.currentAccount.id,
        restaurant = widget.store.currentRestaurant.id,
        generation = store.generation,
        request = ++_request;
    final input = (value ?? _prompt.text).toLowerCase().replaceAllMapped(
      RegExp('[٠-٩۰-۹]'),
      (m) {
        final code = m[0]!.codeUnitAt(0);
        return '${code >= 0x6f0 ? code - 0x6f0 : code - 0x660}';
      },
    );
    setState(() {
      _busy = true;
      _proposal = null;
      _response = null;
    });
    await Future<void>.delayed(
      Duration(
        milliseconds: store.delayMode == 'instant'
            ? 0
            : store.delayMode == 'slow'
            ? 1800
            : 450,
      ),
    );
    if (!mounted ||
        request != _request ||
        account != store.currentAccount.id ||
        restaurant != store.currentRestaurant.id ||
        generation != store.generation) {
      return;
    }
    try {
      if (input.contains('allerg') || input.contains('gluten')) {
        setState(
          () => _response = 'Allergen guarantees are not available in this demo. Ask restaurant staff before ordering.',
        );
      } else if (input.contains('pay') ||
          input.contains('book') ||
          input.contains('weather')) {
        setState(
          () => _response = 'I can compare this restaurant’s menu and propose a basket. Payment and booking need your explicit review in their own screens.',
        );
      } else if (input.isNotEmpty &&
          !RegExp(
            r'meal|drink|vegetar|menu|basket|compar|replace|suggest|budget|under|cheaper|repas|panier|وجبة|وجبت|قائمة',
          ).hasMatch(input)) {
        setState(
          () => _response = 'I support menu comparisons, a budget basket, and replacements for unavailable items. Try a suggestion below or ask staff for something else.',
        );
      } else {
        final mentionedBudget = RegExp(
          r'(?:under|budget|moins de|sous|أقل من|اقل من|ميزانية)\s*(?:€|eur)?\s*(\d+(?:[.,]\d+)?)',
        ).firstMatch(input)?.group(1);
        if (mentionedBudget != null) _budget.text = mentionedBudget;
        final budget =
            ((double.tryParse(_budget.text.replaceAll(',', '.')) ?? 25) * 100)
                .round();
        final proposal = store.proposeBasket(
          budgetMinor: budget,
          vegetarian: _vegetarian,
        );
        setState(() {
          _proposal = proposal;
          final comparison = input.contains('compar')
              ? store.restaurantMenu
                    .where(
                      (m) =>
                          m.available &&
                          m.dietaryKnown &&
                          m.dietary.contains('vegetarian'),
                    )
                    .take(3)
                    .map((m) => '${m.name}: ${money(context, m.priceMinor)}')
                    .join('\n')
              : '';
          _response =
              '${context.tr('This suggestion uses current menu items and required options. Review it before changing your cart.')}\n${comparison.isEmpty ? '' : '$comparison\n'}${context.tr('Suggested items')}: ${proposal.length}. ${context.tr('Budget')}: ${money(context, budget)}. ${context.tr('Availability and fees are checked again at checkout.')}';
        });
      }
    } catch (e) {
      setState(() => _response = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return MobilePage(
      title: 'Assistant',
      embedded: widget.embedded,
      children: [
        RaystoStoryHeader(
          eyebrow: context.tr('At your service'),
          title: context.tr('A little help choosing.'),
          message: context.tr(
            'Local demo assistant · suggestions from this menu only',
          ),
          scene: RaystoScene.menu,
          compact: true,
        ),
        DropdownButtonFormField<String>(
          initialValue: store.currentRestaurant.id,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: context.tr('Restaurant context'),
          ),
          items: store.restaurants
              .where((r) => r.published)
              .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
              .toList(),
          onChanged: (id) {
            if (id != null) {
              setState(() {
                _request++;
                _busy = false;
                store.selectRestaurant(id);
                _proposal = null;
                _response = null;
              });
            }
          },
        ),
        TextField(
          controller: _budget,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.tr('Budget in EUR'),
            helperText: context.tr(
              'Includes the current delivery fee, when selected',
            ),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.tr('Include a vegetarian meal')),
          value: _vegetarian,
          onChanged: (v) => setState(() => _vegetarian = v),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final text in [
              'Two meals and a drink',
              'Compare vegetarian choices',
              'Replace unavailable items',
            ])
              ActionChip(
                label: Text(context.tr(text)),
                onPressed: _busy ? null : () => _ask(text),
              ),
          ],
        ),
        TextField(
          controller: _prompt,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: context.tr('What sounds good?'),
            hintText: context.tr('Two meals and a drink under €25'),
          ),
          onSubmitted: _busy ? null : _ask,
        ),
        FilledButton.icon(
          onPressed: _busy ? null : () => _ask(),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(context.tr('Suggest a basket')),
        ),
        if (_busy)
          Semantics(
            liveRegion: true,
            child: Column(
              children: [
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(context.tr('Checking this menu and your budget…')),
              ],
            ),
          ),
        if (_response != null)
          AnimatedSwitcher(
            duration: AppMotion.duration(context, AppMotion.selection),
            child: AppNotice(
              key: ValueKey(_response),
              title: context.tr('Raysto assistant'),
              message: context.tr(_response!),
            ),
          ),
        if (_proposal != null) ...[
          Section(
            title: 'Your proposed basket',
            child: Column(
              children: [
                for (final line in _proposal!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(line.name),
                    subtitle: Text(
                      line.modifiers.map((m) => m.name).join(', '),
                    ),
                    trailing: MoneyText(line.subtotalMinor),
                  ),
                PriceRow(
                  'Items',
                  _proposal!.fold<int>(0, (s, l) => s + l.subtotalMinor),
                ),
                if (store.cart.mode == ServiceMode.delivery)
                  PriceRow(
                    'Delivery',
                    store.currentRestaurant.deliveryFeeMinor,
                  ),
              ],
            ),
          ),
          Text(
            context.tr(
              'This proposal has not changed your cart. Review quantities and choices first.',
            ),
          ),
          FilledButton(
            onPressed: () => openPage(
              context,
              ProposalScreen(store: store, proposal: _proposal!),
            ),
            child: Text(context.tr('Review proposed basket')),
          ),
        ],
      ],
    );
  }
}

class ProposalScreen extends StatefulWidget {
  const ProposalScreen({
    super.key,
    required this.store,
    required this.proposal,
  });
  final DemoStore store;
  final List<CartLine> proposal;
  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  late List<CartLine> _lines = List.of(widget.proposal);
  @override
  Widget build(BuildContext context) => MobilePage(
    title: 'Review proposed basket',
    children: [
      Text(
        context.tr(
          'Adjust quantities or remove a suggestion. You can edit modifiers from the cart before checkout.',
        ),
      ),
      for (final line in _lines)
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line.name, style: Theme.of(context).textTheme.titleMedium),
              MoneyText(line.subtotalMinor),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  QuantityStepper(
                    value: line.quantity,
                    onChanged: (v) => setState(
                      () => _lines = _lines
                          .map(
                            (l) =>
                                l.id == line.id ? l.copyWith(quantity: v) : l,
                          )
                          .toList(),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Remove suggestion'),
                    onPressed: () => setState(
                      () => _lines.removeWhere((l) => l.id == line.id),
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      PriceRow('Items', _lines.fold<int>(0, (s, l) => s + l.subtotalMinor)),
      if (widget.store.cart.mode == ServiceMode.delivery)
        PriceRow('Delivery', widget.store.currentRestaurant.deliveryFeeMinor),
      if (widget.store.cart.lines.isNotEmpty)
        Text(context.tr('Approval replaces the items in your current basket.')),
      FilledButton(
        onPressed: _lines.isEmpty
            ? null
            : () => guarded(context, () {
                widget.store.applyProposal(_lines);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => CartScreen(store: widget.store),
                  ),
                );
              }),
        child: Text(
          context.tr(
            widget.store.cart.lines.isEmpty
                ? 'Approve and add to cart'
                : 'Approve and replace basket',
          ),
        ),
      ),
    ],
  );
}
