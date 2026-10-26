import 'package:flutter/material.dart';
import '../demo/gallery/gallery_screen.dart';
import '../design_system/design_system.dart';
import '../features/preview/preview_screens.dart';
import 'navigation.dart';
import 'preview_store.dart';

class FoundationPreviewApp extends StatefulWidget {
  const FoundationPreviewApp({super.key, this.store, this.initialRoute});
  final PreviewStore? store;
  final String? initialRoute;
  @override
  State<FoundationPreviewApp> createState() => _FoundationPreviewAppState();
}

class _FoundationPreviewAppState extends State<FoundationPreviewApp> {
  late final PreviewStore _store = widget.store ?? PreviewStore();
  @override
  void dispose() {
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  Route<dynamic> _route(RouteSettings settings) {
    final path = Uri.tryParse(settings.name ?? '/')?.path ?? '/';
    Widget page;
    if (path == '/') {
      page = RaystoShell(store: _store);
    } else if (path == '/gallery') {
      page = const GalleryScreen();
    } else if (path == '/preferences') {
      page = PreferencesScreen(store: _store);
    } else if (path.startsWith('/dish/')) {
      final id = path.split('/').last;
      final matches = sampleDishes.where((dish) => dish.id == id);
      page = matches.isEmpty
          ? const MissingScreen()
          : DishScreen(dish: matches.first, store: _store);
    } else {
      page = const MissingScreen();
    }
    return MaterialPageRoute<Object?>(settings: settings, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _store,
    builder: (context, _) => MotionScope(
      reducedMotion: _store.reducedMotion,
      child: MaterialApp(
        title: 'Raysto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: widget.initialRoute,
        onGenerateInitialRoutes: (route) => [
          if (route != '/') _route(const RouteSettings(name: '/')),
          _route(RouteSettings(name: route)),
        ],
        onGenerateRoute: _route,
      ),
    ),
  );
}

class RaystoShell extends StatefulWidget {
  const RaystoShell({super.key, required this.store});
  final PreviewStore store;
  @override
  State<RaystoShell> createState() => _RaystoShellState();
}

class _RaystoShellState extends State<RaystoShell> {
  int get _index => widget.store.destination;
  bool _routeOpen = false;
  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.store.destination = index;
  }

  Future<void> _open(String route) async {
    if (_routeOpen) return;
    _routeOpen = true;
    final result = await Navigator.of(context).pushNamed(route);
    _routeOpen = false;
    if (mounted && result == 'saved') _select(2);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index != 0) _select(0);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: true,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 6, 20, 14),
          child: RaystoDock(index: _index, onChanged: _select),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bottom =
                RaystoDock.contentHeight(context, constraints.maxWidth - 40) +
                48 +
                MediaQuery.viewPaddingOf(context).bottom;
            return Stack(
              children: [
                RetainedBranches(
                  index: _index,
                  children: [
                    DiscoverScreen(
                      bottomPadding: bottom,
                      onMenu: () => _select(1),
                      onDish: (dish) => _open('/dish/${dish.id}'),
                      onPreferences: () => _open('/preferences'),
                    ),
                    MenuScreen(
                      bottomPadding: bottom,
                      store: widget.store,
                      onDish: (dish) => _open('/dish/${dish.id}'),
                      onPreferences: () => _open('/preferences'),
                    ),
                    SavedScreen(
                      bottomPadding: bottom,
                      store: widget.store,
                      onBrowse: () => _select(1),
                      onDish: (dish) => _open('/dish/${dish.id}'),
                      onPreferences: () => _open('/preferences'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
