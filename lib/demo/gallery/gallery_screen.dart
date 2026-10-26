import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../design_system/design_system.dart';

enum _Collection {
  foundations('Foundations'),
  actions('Actions'),
  selection('Selection'),
  inputs('Inputs'),
  feedback('Feedback'),
  surfaces('Surfaces');

  const _Collection(this.label);
  final String label;
}

enum _StatePreview {
  firstUse('First use'),
  noMatches('No matches'),
  loading('Loading'),
  refreshing('Refreshing'),
  error('Error'),
  offline('Offline'),
  permission('Permission'),
  session('Session'),
  partial('Partial'),
  success('Success'),
  removed('Removed');

  const _StatePreview(this.label);
  final String label;
}

@immutable
class _DiningNote {
  const _DiningNote(this.title, this.note);

  final String title;
  final String note;
}

/// An isolated, interactive review space. Nothing here edits product records.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _initialNote = _DiningNote(
    'Dinner with friends',
    'A quiet corner, if one is available.',
  );
  static const _paces = ['A quick bite', 'A relaxed meal', 'No rush'];

  final _titleController = TextEditingController(text: _initialNote.title);
  final _noteController = TextEditingController(text: _initialNote.note);
  _Collection _collection = _Collection.foundations;
  _StatePreview _preview = _StatePreview.firstUse;
  _DiningNote _savedNote = _initialNote;
  _DiningNote? _previousNote;
  String? _titleError;
  String? _formFeedback;
  bool _reducedMotion = false;
  bool _busy = false;
  bool _actionSaved = false;
  bool _savedPlace = true;
  bool _sheetOpen = false;
  bool _allowExit = false;
  int _seating = 0;
  int _pace = 1;
  int _progress = 0;
  final Set<String> _preferences = {'Vegetarian'};

  bool get _draftDirty =>
      _titleController.text != _savedNote.title ||
      _noteController.text != _savedNote.note;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _savedNote = _initialNote;
      _previousNote = null;
      _titleController.text = _initialNote.title;
      _noteController.text = _initialNote.note;
      _titleError = null;
      _formFeedback = null;
      _busy = false;
      _actionSaved = false;
      _savedPlace = true;
      _seating = 0;
      _pace = 1;
      _progress = 0;
      _preview = _StatePreview.firstUse;
      _preferences
        ..clear()
        ..add('Vegetarian');
    });
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    if (title.length < 3 || title.length > 60) {
      setState(() {
        _titleError = 'Use a name with 3 to 60 characters.';
        _formFeedback = null;
      });
      return;
    }
    if (!_draftDirty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _previousNote = _savedNote;
      _savedNote = _DiningNote(title, _noteController.text);
      _titleController.text = title;
      _titleError = null;
      _formFeedback = 'Your sample dining note has been saved in this gallery.';
    });
  }

  void _discardDraft() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _titleController.text = _savedNote.title;
      _noteController.text = _savedNote.note;
      _titleError = null;
      _formFeedback = 'Draft discarded. Your saved sample is unchanged.';
    });
  }

  void _undoNote() {
    final previous = _previousNote;
    if (previous == null || _draftDirty) return;
    setState(() {
      _savedNote = previous;
      _titleController.text = previous.title;
      _noteController.text = previous.note;
      _previousNote = null;
      _titleError = null;
      _formFeedback = 'Previous name and note restored.';
    });
  }

  Future<T?> _gallerySheet<T>(BuildContext context, {required Widget child}) =>
      showAppSheet<T>(
        context,
        child: MotionScope(
          reducedMotion: AppMotion.reduced(context),
          child: child,
        ),
      );

  Future<void> _confirmLeave(BuildContext context) async {
    if (_sheetOpen) return;
    final navigator = Navigator.of(context);
    _sheetOpen = true;
    final leave = await _gallerySheet<bool>(
      context,
      child: Builder(
        builder: (sheetContext) => _SheetContent(
          title: 'Leave this draft?',
          message:
              'Your unsaved dining note will be discarded. Gallery examples '
              'reset when you leave.',
          children: [
            AppButton(
              label: 'Keep editing',
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
            AppButton(
              label: 'Discard draft and leave',
              secondary: true,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _sheetOpen = false;
    if (leave != true) return;
    setState(() => _allowExit = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) navigator.pop();
    });
  }

  Future<void> _choosePace(BuildContext context) async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    var draft = _pace;
    final result = await _gallerySheet<int>(
      context,
      child: StatefulBuilder(
        builder: (sheetContext, updateSheet) => _SheetContent(
          title: 'Make time for your meal',
          message: 'Choose a pace for this example. Apply to keep your choice.',
          children: [
            for (var index = 0; index < _paces.length; index++)
              AppChoice(
                title: _paces[index],
                selected: draft == index,
                onTap: () => updateSheet(() => draft = index),
              ),
            const SizedBox(height: 4),
            AppButton(
              label: 'Apply pace',
              onPressed: () => Navigator.of(sheetContext).pop(draft),
            ),
            AppButton(
              label: 'Cancel',
              secondary: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _sheetOpen = false;
    if (result != null) setState(() => _pace = result);
  }

  Future<void> _removePlace(BuildContext context) async {
    if (_sheetOpen || !_savedPlace) return;
    _sheetOpen = true;
    final remove = await _gallerySheet<bool>(
      context,
      child: Builder(
        builder: (sheetContext) => _SheetContent(
          title: 'Remove this sample place?',
          message:
              'Market Table will leave the gallery shortlist. You can undo '
              'this change here after removing it.',
          children: [
            AppButton(
              label: 'Remove sample place',
              icon: PhosphorIconsRegular.trash,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
            AppButton(
              label: 'Keep place',
              secondary: true,
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    _sheetOpen = false;
    if (remove == true) setState(() => _savedPlace = false);
  }

  @override
  Widget build(BuildContext context) {
    return MotionScope(
      reducedMotion: _reducedMotion || AppMotion.reduced(context),
      child: Builder(
        builder: (context) => PopScope(
          canPop: !_draftDirty || _allowExit,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _confirmLeave(context);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              bottom: false,
              child: CustomScrollView(
                key: const PageStorageKey('design-gallery-scroll'),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    leading: AppIconButton(
                      label: 'Back to Raysto',
                      icon: Directionality.of(context) == TextDirection.rtl
                          ? PhosphorIconsRegular.arrowRight
                          : PhosphorIconsRegular.arrowLeft,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: Text(
                      'Studio',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    actions: [
                      AppIconButton(
                        label: 'Reset all gallery examples',
                        icon: PhosphorIconsRegular.arrowCounterClockwise,
                        onPressed: _reset,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
                    sliver: SliverList.list(
                      children: [
                        const AppEyebrow('RAYSTO / DESIGN SYSTEM'),
                        const SizedBox(height: 12),
                        Text(
                          'Made to feel\nnatural.',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A living collection of the details that make '
                          'Raysto feel like Raysto. Tap, choose, and try them.',
                        ),
                        const SizedBox(height: 16),
                        AppPill(
                          label: 'Isolated sample data',
                          icon: PhosphorIconsRegular.flask,
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        const SizedBox(height: 22),
                        AppDisclosure(
                          title: 'Preview settings',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Reduce gallery motion'),
                                subtitle: const Text(
                                  'Gallery only. Device and app preferences '
                                  'still take priority.',
                                ),
                                value: _reducedMotion,
                                onChanged: (value) =>
                                    setState(() => _reducedMotion = value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Examples stay in memory while this gallery '
                                'is open. They never change your dining plans.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Reset all examples',
                                secondary: true,
                                icon:
                                    PhosphorIconsRegular.arrowCounterClockwise,
                                onPressed: _reset,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final collection in _Collection.values)
                              AppChip(
                                label: collection.label,
                                selected: _collection == collection,
                                onSelected: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() => _collection = collection);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _ContentChange(
                          child: KeyedSubtree(
                            key: ValueKey(_collection),
                            child: switch (_collection) {
                              _Collection.foundations => _foundations(context),
                              _Collection.actions => _actions(context),
                              _Collection.selection => _selection(context),
                              _Collection.inputs => _inputs(context),
                              _Collection.feedback => _feedback(context),
                              _Collection.surfaces => _surfaces(context),
                            },
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.paddingOf(context).bottom + 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _foundations(BuildContext context) {
    final type = Theme.of(context).textTheme;
    return _CollectionBody(
      children: [
        const AppSectionTitle(
          title: 'Warmth, with intention',
          subtitle: 'Paper to settle in. Forest to guide. Lime to choose.',
        ),
        AppPanel(
          color: AppColors.forest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppEyebrow('THE RAYSTO PALETTE', color: AppColors.lime),
              const SizedBox(height: 12),
              Text(
                'Good food.\nGood company.',
                style: type.headlineMedium?.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'A little space to discover your next favourite table.',
                style: type.bodyMedium?.copyWith(color: AppColors.mint),
              ),
            ],
          ),
        ),
        const _Palette(),
        const AppDisclosure(
          title: 'Semantic status colors',
          child: _StatusColors(),
        ),
        const SizedBox(height: 10),
        const AppSectionTitle(
          title: 'A voice you can read',
          subtitle: 'Plus Jakarta Sans, with space for every word.',
        ),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppEyebrow('SMALL DETAILS, CLEARLY NAMED'),
              const SizedBox(height: 16),
              Text('Pull up a chair.', style: type.headlineMedium),
              const SizedBox(height: 16),
              Text('Something worth sharing', style: type.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'A relaxed lunch, a new favourite place, or a familiar meal '
                'with someone you love. Start with what sounds good.',
              ),
              const SizedBox(height: 12),
              Text(
                'Supporting copy stays readable as your text size grows.',
                style: type.bodySmall,
              ),
            ],
          ),
        ),
        const AppDisclosure(
          title: 'Spacing, shape & motion',
          child: _FoundationDetails(),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context) => _CollectionBody(
    children: [
      const AppSectionTitle(
        title: 'One useful next step',
        subtitle:
            'Clear verbs, comfortable targets, and feedback you can feel.',
      ),
      AppPanel(
        child: _CollectionBody(
          gap: 12,
          children: [
            Text(
              'Primary action',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('Try saving this sample to a local gallery shortlist.'),
            AppButton(
              label: _actionSaved
                  ? 'Saved to sample shortlist'
                  : 'Save this place',
              icon: _actionSaved
                  ? PhosphorIconsRegular.check
                  : PhosphorIconsRegular.bookmarkSimple,
              onPressed: _actionSaved
                  ? null
                  : () => setState(() => _actionSaved = true),
            ),
            AppButton(
              label: 'Undo save',
              secondary: true,
              icon: PhosphorIconsRegular.arrowCounterClockwise,
              onPressed: _actionSaved
                  ? () => setState(() => _actionSaved = false)
                  : null,
            ),
            if (_actionSaved)
              const _ResultText(
                'The sample shortlist now contains this place.',
              ),
          ],
        ),
      ),
      AppPanel(
        child: _CollectionBody(
          gap: 12,
          children: [
            Text(
              'Busy & disabled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Preview a busy button'),
              subtitle: const Text(
                'A manual preview. No request is being sent.',
              ),
              value: _busy,
              onChanged: (value) => setState(() => _busy = value),
            ),
            AppButton(
              label: _busy ? 'Saving sample…' : 'Preview saving',
              icon: PhosphorIconsRegular.bookmarkSimple,
              busy: _busy,
              onPressed: () => setState(() => _busy = true),
            ),
            const AppButton(label: 'Choose a time first', onPressed: null),
            Text(
              'A disabled action explains what is missing. The busy state '
              'prevents a second submission.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      AppPanel(
        child: _CollectionBody(
          gap: 12,
          children: [
            Text('Icon action', style: Theme.of(context).textTheme.titleMedium),
            const Text('A compact symbol with a full touch target and a name.'),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppIconButton(
                label: 'Reset action examples',
                icon: PhosphorIconsRegular.arrowCounterClockwise,
                onPressed: () => setState(() {
                  _actionSaved = false;
                  _busy = false;
                }),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _selection(BuildContext context) => _CollectionBody(
    children: [
      const AppSectionTitle(
        title: 'A choice that feels easy',
        subtitle: 'Selection is visible through a check, a shape, and a label.',
      ),
      AppChoice(
        title: 'In the courtyard',
        subtitle: 'Fresh air and a little afternoon sunshine.',
        icon: PhosphorIconsRegular.sun,
        selected: _seating == 0,
        onTap: () => setState(() => _seating = 0),
      ),
      AppChoice(
        title: 'Inside, by the window',
        subtitle: 'A calm corner for a longer conversation.',
        icon: PhosphorIconsRegular.armchair,
        selected: _seating == 1,
        onTap: () => setState(() => _seating = 1),
      ),
      _ResultText(
        _seating == 0
            ? 'Selected: courtyard seating.'
            : 'Selected: indoor window seating.',
      ),
      const SizedBox(height: 10),
      const AppSectionTitle(
        title: 'A little more your taste',
        subtitle:
            'Multiple choices. These sample preferences stay in the gallery.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final preference in [
            'Vegetarian',
            'Outdoor tables',
            'Quiet spots',
          ])
            AppChip(
              label: preference,
              selected: _preferences.contains(preference),
              onSelected: () => setState(() {
                if (!_preferences.remove(preference)) {
                  _preferences.add(preference);
                }
              }),
            ),
        ],
      ),
      AppNotice(
        title: _preferences.isEmpty
            ? 'Open to anything'
            : 'Your sample choices',
        message: _preferences.isEmpty
            ? 'No preference filters are selected.'
            : _preferences.join(' · '),
        icon: PhosphorIconsRegular.slidersHorizontal,
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      const SizedBox(height: 10),
      const AppSectionTitle(
        title: 'Context, without another button',
        subtitle: 'Metadata pills name a detail. They are not interactive.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppPill(label: 'Seasonal menu', icon: PhosphorIconsRegular.leaf),
          AppPill(
            label: 'Sample restaurant',
            icon: PhosphorIconsRegular.forkKnife,
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        ],
      ),
    ],
  );

  Widget _inputs(BuildContext context) => _CollectionBody(
    children: [
      const AppSectionTitle(
        title: 'Room for your own words',
        subtitle: 'Draft, validate, save, and undo without losing your work.',
      ),
      AppPanel(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: _CollectionBody(
          gap: 8,
          children: [
            const AppEyebrow('SAVED SAMPLE'),
            Text(
              _savedNote.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              _savedNote.note.isEmpty ? 'No optional note.' : _savedNote.note,
            ),
          ],
        ),
      ),
      AppPanel(
        child: _CollectionBody(
          gap: 16,
          children: [
            AppTextField(
              label: 'Plan name',
              hint: 'For example, Friday lunch',
              controller: _titleController,
              error: _titleError,
              onChanged: (_) => setState(() {
                _titleError = null;
                _formFeedback = null;
              }),
            ),
            Text(
              'Required, 3–60 characters. Try an empty name to see validation.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            AppTextField(
              label: 'Note (optional)',
              hint: 'Anything you would like to remember',
              controller: _noteController,
              maxLines: 3,
              onChanged: (_) => setState(() => _formFeedback = null),
            ),
            AppButton(
              label: 'Save sample note',
              icon: PhosphorIconsRegular.check,
              onPressed: _draftDirty ? _saveNote : null,
            ),
            AppButton(
              label: 'Discard draft',
              secondary: true,
              onPressed: _draftDirty ? _discardDraft : null,
            ),
          ],
        ),
      ),
      if (_formFeedback != null) _ResultText(_formFeedback!),
      if (_previousNote != null)
        AppButton(
          label: 'Undo last save',
          icon: PhosphorIconsRegular.arrowCounterClockwise,
          secondary: true,
          onPressed: _draftDirty ? null : _undoNote,
        ),
      if (_previousNote != null && _draftDirty)
        Text(
          'Save or discard the current draft before undoing the previous save.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      const AppDisclosure(
        title: 'What happens to this draft?',
        child: Text(
          'Changing collections keeps your draft. Save changes the sample '
          'above; undo restores its exact previous name and note. Discard '
          'returns to the saved version. Leaving with a draft asks first. '
          'Nothing is written to a device or account.',
        ),
      ),
    ],
  );

  Widget _feedback(BuildContext context) => _CollectionBody(
    children: [
      const AppSectionTitle(
        title: 'Every state deserves care',
        subtitle: 'Explicit previews of what someone sees when plans change.',
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final preview in _StatePreview.values)
            AppChip(
              label: preview.label,
              selected: _preview == preview,
              onSelected: () => setState(() => _preview = preview),
            ),
        ],
      ),
      const AppEyebrow('SAMPLE STATE / NO LIVE REQUEST'),
      _ContentChange(
        child: KeyedSubtree(
          key: ValueKey(_preview),
          child: _stateExample(context),
        ),
      ),
      const SizedBox(height: 10),
      const AppSectionTitle(
        title: 'Progress that means something',
        subtitle: 'Add three sample places. Each tap changes the actual count.',
      ),
      AppPanel(
        child: _CollectionBody(
          gap: 16,
          children: [
            AppProgress(
              value: _progress / 3,
              label: '$_progress of 3 sample places added',
            ),
            if (_progress == 3)
              _CompletionMark(
                title: 'Your sample shortlist is ready',
                message:
                    'Three examples added. Reset to try the transition again.',
              ),
            AppButton(
              label: _progress == 3
                  ? 'Three places added'
                  : 'Add a sample place',
              icon: _progress == 3
                  ? PhosphorIconsRegular.check
                  : PhosphorIconsRegular.plus,
              onPressed: _progress == 3
                  ? null
                  : () => setState(() => _progress++),
            ),
            AppButton(
              label: 'Reset progress',
              secondary: true,
              onPressed: _progress == 0
                  ? null
                  : () => setState(() => _progress = 0),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _stateExample(BuildContext context) {
    void showSampleResult() => setState(() => _preview = _StatePreview.success);
    switch (_preview) {
      case _StatePreview.firstUse:
        return AppNotice(
          title: 'Keep a place for later',
          message:
              'Your saved restaurants will live here. Start with one you like.',
          icon: PhosphorIconsRegular.bookmarkSimple,
          action: AppButton(
            label: 'Add a sample place',
            onPressed: showSampleResult,
          ),
        );
      case _StatePreview.noMatches:
        return AppNotice(
          title: 'No places match these choices',
          message: 'Try fewer filters or look in a different neighbourhood.',
          icon: PhosphorIconsRegular.magnifyingGlass,
          action: AppButton(
            label: 'Clear sample filters',
            secondary: true,
            onPressed: () => setState(() => _preview = _StatePreview.partial),
          ),
        );
      case _StatePreview.loading:
        return AppPanel(
          child: _CollectionBody(
            gap: 16,
            children: [
              Text(
                'Finding a table',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Text('Loading layout preview. No request is in progress.'),
              const ExcludeSemantics(child: _QuietSkeleton()),
              AppButton(
                label: 'Show sample result',
                secondary: true,
                onPressed: showSampleResult,
              ),
            ],
          ),
        );
      case _StatePreview.refreshing:
        return AppPanel(
          child: _CollectionBody(
            gap: 16,
            children: [
              Text(
                'Market Table',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Seasonal menu · Courtyard seating'),
              AppNotice(
                title: 'Refreshing preview',
                message:
                    'Existing results stay readable while new details arrive.',
                icon: PhosphorIconsRegular.arrowsClockwise,
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              AppButton(
                label: 'Show refreshed sample',
                secondary: true,
                onPressed: showSampleResult,
              ),
            ],
          ),
        );
      case _StatePreview.error:
        return AppNotice(
          title: 'The menu did not load',
          message:
              'Your dining note is still here. Try loading the menu again.',
          icon: PhosphorIconsRegular.warningCircle,
          color: Theme.of(context).colorScheme.errorContainer,
          action: AppButton(
            label: 'Preview a successful retry',
            secondary: true,
            onPressed: showSampleResult,
          ),
        );
      case _StatePreview.offline:
        return AppNotice(
          title: 'Connection unavailable',
          message:
              'In this preview, your current in-memory note stays available. '
              'Live menus would need a connection. No offline download is claimed.',
          icon: PhosphorIconsRegular.wifiSlash,
          color: Theme.of(context).colorScheme.tertiaryContainer,
          action: AppButton(
            label: 'Show connected sample',
            secondary: true,
            onPressed: showSampleResult,
          ),
        );
      case _StatePreview.permission:
        return AppNotice(
          title: 'Find places without location',
          message:
              'Location access is unavailable in this example. Choosing a '
              'city is still an option. This preview does not request permission.',
          icon: PhosphorIconsRegular.mapPin,
          color: Theme.of(context).colorScheme.tertiaryContainer,
          action: AppButton(
            label: 'Preview city search results',
            secondary: true,
            onPressed: () => setState(() => _preview = _StatePreview.partial),
          ),
        );
      case _StatePreview.session:
        return AppNotice(
          title: 'Your session has ended',
          message:
              'Your current draft is preserved. A connected app would ask you '
              'to sign in again before saving to your account.',
          icon: PhosphorIconsRegular.lockKey,
          color: Theme.of(context).colorScheme.tertiaryContainer,
          action: AppButton(
            label: 'Show restored-session preview',
            secondary: true,
            onPressed: showSampleResult,
          ),
        );
      case _StatePreview.partial:
        return AppPanel(
          child: _CollectionBody(
            gap: 16,
            children: [
              Text(
                'Market Table',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Seasonal cooking · Courtyard tables'),
              AppNotice(
                title: 'One detail is missing',
                message:
                    'The sample place is available, but its opening hours '
                    'could not be loaded. Do not assume it is open.',
                icon: PhosphorIconsRegular.clock,
                color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              AppButton(
                label: 'Preview a complete result',
                secondary: true,
                onPressed: showSampleResult,
              ),
            ],
          ),
        );
      case _StatePreview.success:
        return AppPanel(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: const _CompletionMark(
            title: 'Sample result is ready',
            message:
                'The success preview is now visible. No reservation or account '
                'change has been made.',
          ),
        );
      case _StatePreview.removed:
        return AppNotice(
          title: 'Sample removal state',
          message:
              'A removed item should be named, with a clear recovery path. '
              'Try the working remove-and-undo example in Surfaces.',
          icon: PhosphorIconsRegular.trash,
          action: AppButton(
            label: 'Try removal example',
            secondary: true,
            onPressed: () => setState(() => _collection = _Collection.surfaces),
          ),
        );
    }
  }

  Widget _surfaces(BuildContext context) => _CollectionBody(
    children: [
      const AppSectionTitle(
        title: 'A little depth, a lot of clarity',
        subtitle: 'Surfaces group a task. Details appear when you need them.',
      ),
      AppTapSurface(
        label: 'Choose the pace for this sample meal',
        onTap: () => _choosePace(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              PhosphorIconsRegular.clock,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your pace',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(_paces[_pace]),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to choose in a sheet',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              PhosphorIconsRegular.caretDown,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
      const AppDisclosure(
        title: 'Why keep the detail tucked away?',
        child: Text(
          'The meal is the main idea. A pace, a note, and a few extra details '
          'can wait until they are useful. This disclosure expands in place '
          'and removes hidden content from focus and screen-reader navigation.',
        ),
      ),
      const SizedBox(height: 10),
      const AppSectionTitle(
        title: 'Confirm, then make it real',
        subtitle: 'A focused sheet explains a change before it happens.',
      ),
      if (_savedPlace)
        AppPanel(
          child: _CollectionBody(
            gap: 12,
            children: [
              const AppEyebrow('SAMPLE SHORTLIST / 1 PLACE'),
              Text(
                'Market Table',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'Seasonal cooking, a sunny courtyard, and time to linger.',
              ),
              AppButton(
                label: 'Remove sample place',
                icon: PhosphorIconsRegular.trash,
                secondary: true,
                onPressed: () => _removePlace(context),
              ),
            ],
          ),
        )
      else
        AppNotice(
          title: 'Market Table removed',
          message:
              'Your gallery shortlist is now empty. Undo restores the place.',
          icon: PhosphorIconsRegular.check,
          color: Theme.of(context).colorScheme.surfaceContainer,
          action: AppButton(
            label: 'Undo removal',
            secondary: true,
            icon: PhosphorIconsRegular.arrowCounterClockwise,
            onPressed: () => setState(() => _savedPlace = true),
          ),
        ),
      const SizedBox(height: 10),
      const AppSectionTitle(
        title: 'A deliberate media fallback',
        subtitle: 'The image area stays steady when a photo is unavailable.',
      ),
      const AppMedia(
        asset: 'assets/images/gallery-unavailable-preview.webp',
        semanticLabel: 'Intentional unavailable restaurant photo preview',
        height: 180,
      ),
      Text(
        'This example intentionally uses an unavailable image to reveal the '
        'shared fallback. Restaurant photos appear in the main app.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _CollectionBody extends StatelessWidget {
  const _CollectionBody({required this.children, this.gap = 16});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var index = 0; index < children.length; index++) ...[
        if (index > 0) SizedBox(height: gap),
        children[index],
      ],
    ],
  );
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.title,
    required this.message,
    required this.children,
  });

  final String title;
  final String message;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => _CollectionBody(
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      Text(message),
      const SizedBox(height: 4),
      ...children,
    ],
  );
}

class _ResultText extends StatelessWidget {
  const _ResultText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: ExcludeSemantics(
            child: Icon(PhosphorIconsRegular.checkCircle, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

/// The outgoing view paints its fade but cannot receive interaction or focus.
class _ContentChange extends StatelessWidget {
  const _ContentChange({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    return AnimatedSwitcher(
      duration: AppMotion.selection,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topLeft,
        children: [
          for (final previous in previousChildren)
            IgnorePointer(
              child: ExcludeFocus(child: ExcludeSemantics(child: previous)),
            ),
          ?currentChild,
        ],
      ),
      child: SizedBox(width: double.infinity, key: child.key, child: child),
    );
  }
}

class _CompletionMark extends StatelessWidget {
  const _CompletionMark({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final mark = ExcludeSemantics(
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.lime,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          PhosphorIconsRegular.check,
          size: 40,
          color: AppColors.ink,
        ),
      ),
    );
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (AppMotion.reduced(context))
            mark
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1),
              duration: AppMotion.milestone,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: mark,
            ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}

class _QuietSkeleton extends StatelessWidget {
  const _QuietSkeleton();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 112,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      const SizedBox(height: 16),
      FractionallySizedBox(
        widthFactor: 0.7,
        child: Container(
          height: 14,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      const SizedBox(height: 10),
      FractionallySizedBox(
        widthFactor: 0.45,
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ],
  );
}

class _Palette extends StatelessWidget {
  const _Palette();

  static const _colors = [
    ('Paper', '#F6F7F2', AppColors.paper),
    ('White', '#FFFFFF', AppColors.white),
    ('Ink', '#173E34', AppColors.ink),
    ('Forest', '#173F35', AppColors.forest),
    ('Muted', '#68756C', AppColors.muted),
    ('Lime', '#D7F978', AppColors.lime),
    ('Mint', '#E6EDE2', AppColors.mint),
    ('Peach', '#F3E8DB', AppColors.peach),
    ('Line', '#DCE2D9', AppColors.line),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 21;
      final columns = largeText ? 1 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (name, hex, color) in _colors)
            SizedBox(
              width: width,
              child: AppPanel(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(name, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(hex, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _FoundationDetails extends StatelessWidget {
  const _FoundationDetails();

  @override
  Widget build(BuildContext context) => const _CollectionBody(
    gap: 12,
    children: [
      Text('Spacing: 4 · 8 · 12 · 16 · 20 · 22 · 24 · 32 logical pixels.'),
      Text('Shape: 24 for panels, 22 for buttons, 28 for sheet edges.'),
      Text(
        'Targets: at least 48 × 48 logical pixels; content grows with text.',
      ),
      Text('Feedback 140 ms · Selection 240 ms · Branch 400 ms.'),
      Text('Sheet 360 ms · Completion 440 ms. Reduced motion is immediate.'),
      Text('Phosphor regular icons keep one consistent visual language.'),
    ],
  );
}

class _StatusColors extends StatelessWidget {
  const _StatusColors();

  @override
  Widget build(BuildContext context) => _CollectionBody(
    gap: 12,
    children: [
      for (final (label, message, color, foreground, icon) in [
        (
          'Error',
          'Name the problem and explain the correction.',
          Theme.of(context).colorScheme.error,
          Theme.of(context).colorScheme.onError,
          PhosphorIconsRegular.warningCircle,
        ),
        (
          'Warning',
          'Explain the choice or missing information.',
          Theme.of(context).extension<AppStatusColors>()!.warning,
          Theme.of(context).extension<AppStatusColors>()!.onWarning,
          PhosphorIconsRegular.warning,
        ),
        (
          'Success',
          'Confirm what actually changed.',
          Theme.of(context).extension<AppStatusColors>()!.success,
          Theme.of(context).extension<AppStatusColors>()!.onSuccess,
          PhosphorIconsRegular.checkCircle,
        ),
      ])
        AppPanel(
          color: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(child: Icon(icon, color: foreground)),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: foreground),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
    ],
  );
}
