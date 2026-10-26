import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../demo/gallery/gallery_screen.dart';
import '../design_system/design_system.dart';
import '../domain/domain.dart';
import '../features/account/account_screens.dart';
import '../features/customer/customer_screens.dart';
import '../features/operations/operations.dart';
import '../l10n/app_localizations.dart';
import '../mobile/shared.dart';
import 'foundation_preview_app.dart';
import 'navigation.dart';
import 'preview_store.dart';

class RaystoApp extends StatefulWidget {
  const RaystoApp({
    super.key,
    this.store,
    this.demoStore,
    this.initialRoute,
    this.onlineAccountBuilder,
    this.paymentReturnBuilder,
  });
  final PreviewStore? store;
  final DemoStore? demoStore;
  final String? initialRoute;
  final WidgetBuilder? onlineAccountBuilder;
  final Widget Function(BuildContext, Uri)? paymentReturnBuilder;
  @override
  State<RaystoApp> createState() => _RaystoAppState();
}

class _RaystoAppState extends State<RaystoApp> {
  DemoStore? _demo;
  Object? _error;
  bool _entered = false;
  bool _demoMode = false;
  String? _accountId;
  int _navigatorRevision = 0;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    if (widget.store == null) _restore();
  }

  Future<void> _restore() async {
    setState(() => _error = null);
    try {
      final store = widget.demoStore ?? await DemoStore.open();
      if (!mounted) {
        if (widget.demoStore == null) store.dispose();
        return;
      }
      setState(() {
        _demo = store;
        _entered =
            store.sessionActive && store.currentAccount.onboardingComplete;
        _accountId = store.currentAccount.id;
        _generation = store.generation;
      });
      store.addListener(_changed);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _changed() {
    final store = _demo!;
    if (!mounted) return;
    setState(() {
      if (_accountId != store.currentAccount.id) {
        _accountId = store.currentAccount.id;
        if (_entered) _navigatorRevision++;
        if (!store.currentAccount.onboardingComplete) _entered = false;
      }
      if (_generation != store.generation) {
        _generation = store.generation;
        _navigatorRevision++;
        _entered =
            store.sessionActive && store.currentAccount.onboardingComplete;
      }
      if (!store.sessionActive) _entered = false;
    });
  }

  @override
  void dispose() {
    _demo?.removeListener(_changed);
    if (widget.demoStore == null) _demo?.dispose();
    super.dispose();
  }

  Route<dynamic> _route(RouteSettings settings) {
    final store = _demo!,
        path = Uri.tryParse(settings.name ?? '/')?.path ?? '/';
    Widget page;
    if (path == '/demo') _demoMode = true;
    Widget entry() => EntryScreen(
      store: store,
      onlineAccountBuilder: widget.onlineAccountBuilder,
      onComplete: () {
        setState(() {
          _entered = true;
          _navigatorRevision++;
        });
      },
    );
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri != null &&
        {'/payments/return', '/payments/cancel'}.contains(path) &&
        widget.paymentReturnBuilder != null) {
      page = Builder(
        builder: (context) => widget.paymentReturnBuilder!(context, uri),
      );
    } else if ((path == '/' || path.isEmpty) &&
        widget.onlineAccountBuilder != null &&
        !_demoMode) {
      page = Builder(builder: widget.onlineAccountBuilder!);
    } else if (path == '/' || path.isEmpty || path == '/demo') {
      page = _entered ? MobileShell(store: store) : entry();
    } else if (!_entered) {
      page = entry();
    } else if (path == '/gallery') {
      page = const GalleryScreen();
    } else if (path == '/settings' || path == '/preferences') {
      page = SettingsScreen(store: store);
    } else if (Uri.tryParse(settings.name ?? '')?.host == 'table' ||
        store.tables.any((t) => path == '/${t.restaurantId}/${t.id}')) {
      try {
        // Android's built-in Flutter handler forwards a custom URL's path
        // without its host. Resolve that native form through the same parser.
        final payload = Uri.tryParse(settings.name ?? '')?.host == 'table'
            ? settings.name!
            : 'raysto://table$path';
        final table = store.parseTablePayload(payload);
        page = TableConfirmationScreen(store: store, tableId: table.id);
      } catch (_) {
        page = ScanScreen(store: store);
      }
    } else if (path == '/scan' || path.startsWith('/table')) {
      page = ScanScreen(store: store);
    } else if (path.startsWith('/order/')) {
      page = OrderDetailScreen(store: store, orderId: path.split('/').last);
    } else if (path.startsWith('/visit/')) {
      page = VisitScreen(store: store, visitId: path.split('/').last);
    } else if (path.startsWith('/item/')) {
      page = ItemScreen(store: store, itemId: path.split('/').last);
    } else if (path.startsWith('/operations/')) {
      final requested = path.split('/').last;
      final permitted = switch (store.currentAccount.role) {
        DemoRole.owner ||
        DemoRole.manager => ['overview', 'orders', 'tables', 'menu', 'more'],
        DemoRole.waiter => ['shift', 'tables', 'orders', 'requests', 'more'],
        DemoRole.kitchen => ['queue', 'availability', 'more'],
        DemoRole.courier => ['tasks', 'activity', 'profile'],
        _ => <String>[],
      };
      page = permitted.contains(requested)
          ? Scaffold(
              appBar: AppBar(title: const Text('Raysto')),
              body: OperationsPage(store: store, section: requested),
            )
          : const MobilePage(
              title: 'Access denied',
              children: [
                EmptyState(
                  title: 'This area is for restaurant staff',
                  message: 'Use Explore demo accounts to switch to an authorized role.',
                ),
              ],
            );
    } else {
      page = const MobilePage(
        title: 'Page unavailable',
        children: [
          EmptyState(
            title: 'This link is not part of the demo',
            message: 'Go back to discover restaurants and your current orders.',
          ),
        ],
      );
    }
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.store != null) {
      return FoundationPreviewApp(
        store: widget.store,
        initialRoute: widget.initialRoute,
      );
    }
    final store = _demo;
    if (store == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _error == null
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'raysto',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Restoring your local demo…'),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 48),
                          const SizedBox(height: 16),
                          const Text('The local demo could not be restored.'),
                          const SizedBox(height: 12),
                          Text(_error.toString()),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _restore,
                            child: const Text('Retry restoration'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    }
    return MotionScope(
      reducedMotion: store.settings.reducedMotion,
      child: MaterialApp(
        key: ValueKey('$_navigatorRevision|$_entered'),
        title: 'Raysto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: switch (store.settings.appearance) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        locale: Locale(store.settings.locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeAnimationDuration: store.settings.reducedMotion
            ? Duration.zero
            : AppMotion.selection,
        initialRoute:
            widget.initialRoute ??
            WidgetsBinding.instance.platformDispatcher.defaultRouteName,
        onGenerateInitialRoutes: (route) => [
          if (route != '/') _route(const RouteSettings(name: '/')),
          _route(RouteSettings(name: route)),
        ],
        onGenerateRoute: _route,
        builder: (context, child) {
          final media = MediaQuery.of(context),
              scheme = Theme.of(context).colorScheme;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: scheme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: scheme.surface,
              systemNavigationBarIconBrightness:
                  scheme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: MediaQuery(
              data: media.copyWith(
                textScaler: _CooperativeTextScaler(
                  media.textScaler,
                  store.settings.textScale,
                ),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

class _CooperativeTextScaler extends TextScaler {
  const _CooperativeTextScaler(this.system, this.factor);
  final TextScaler system;
  final double factor;
  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;
  @override
  double get textScaleFactor => system.scale(14) / 14 * factor;
}

class MobileShell extends StatefulWidget {
  const MobileShell({super.key, required this.store});
  final DemoStore store;
  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _index = 0;
  bool _routeOpen = false;
  List<(String, String, IconData)> get _destinations =>
      switch (widget.store.currentAccount.role) {
        DemoRole.owner || DemoRole.manager => [
          ('overview', 'Overview', Icons.dashboard_outlined),
          ('orders', 'Orders', Icons.receipt_long_outlined),
          ('tables', 'Tables', Icons.table_restaurant_outlined),
          ('menu', 'Menu', Icons.restaurant_menu),
          ('more', 'More', Icons.more_horiz),
        ],
        DemoRole.waiter => [
          ('shift', 'Shift', Icons.wb_sunny_outlined),
          ('tables', 'Tables', Icons.table_restaurant_outlined),
          ('orders', 'Orders', Icons.receipt_long_outlined),
          ('requests', 'Requests', Icons.room_service_outlined),
          ('more', 'More', Icons.more_horiz),
        ],
        DemoRole.kitchen => [
          ('queue', 'Queue', Icons.restaurant_outlined),
          ('availability', 'Availability', Icons.inventory_2_outlined),
          ('more', 'More', Icons.more_horiz),
        ],
        DemoRole.courier => [
          ('tasks', 'Tasks', Icons.delivery_dining),
          ('activity', 'Activity', Icons.history),
          ('profile', 'Profile', Icons.person_outline),
        ],
        _ => [
          ('discover', 'Discover', Icons.explore_outlined),
          ('orders', 'Orders', Icons.receipt_long_outlined),
          ('assistant', 'Assistant', Icons.auto_awesome_outlined),
          ('profile', 'Profile', Icons.person_outline),
        ],
      };
  Future<void> _open(Widget page) async {
    if (_routeOpen) return;
    _routeOpen = true;
    await openPage(context, page);
    _routeOpen = false;
  }

  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.store.settings.haptics) HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => _buildShell(context),
  );

  Widget _buildShell(BuildContext context) {
    final store = widget.store, destinations = _destinations;
    final selected = destinations[_index];
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.textScalerOf(context).scale(1) > 1.5
              ? 120
              : store.currentAccount.isStaff
              ? 72
              : 64,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(selected.$2)),
              if (store.currentAccount.isStaff)
                Text(
                  store.currentRestaurant.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: context.tr('Notifications'),
              onPressed: () => _open(NotificationsScreen(store: store)),
              icon: Badge(
                isLabelVisible: store.visibleNotifications.any((n) => !n.read),
                child: const Icon(Icons.notifications_none),
              ),
            ),
            IconButton(
              tooltip: context.tr('Settings and demo accounts'),
              onPressed: () => _open(SettingsScreen(store: store)),
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: Column(
          children: [
            if (!store.online)
              Material(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr(
                            'Offline demo · local changes are saved on this device.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: RetainedBranches(
                index: _index,
                children: [
                  for (final destination in destinations)
                    destination.$1 == 'profile'
                        ? SettingsScreen(store: store, embedded: true)
                        : store.currentAccount.isStaff
                        ? OperationsPage(store: store, section: destination.$1)
                        : CustomerBranch(store: store, section: destination.$1),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: RaystoAdaptiveDock(
          index: _index,
          onChanged: _select,
          navigateLabel: context.tr('Navigate'),
          options: [
            for (final destination in destinations)
              DockDestination(
                context.tr(destination.$2),
                destination.$3,
                destination.$3,
              ),
          ],
        ),
      ),
    );
  }
}
