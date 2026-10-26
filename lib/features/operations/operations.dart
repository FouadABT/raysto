import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../design_system/design_system.dart';
import '../../domain/domain.dart';
import '../../l10n/app_localizations.dart';
import '../../mobile/experience_widgets.dart';
import '../../mobile/table_map.dart';
import '../customer/customer_screens.dart'
    show openAssistedOrder, SupportScreen, RestaurantScreen;
import '../account/account_screens.dart' show SettingsScreen;

part 'widgets.dart';
part 'orders.dart';
part 'tables.dart';
part 'floor_plan.dart';
part 'menu.dart';
part 'menu_builder.dart';
part 'business.dart';
part 'deliveries.dart';

/// A retained top-level operational destination. All records and actions come
/// from the shared demo repository; switching roles never creates a new world.
class OperationsPage extends StatelessWidget {
  const OperationsPage({
    super.key,
    required this.store,
    required this.section,
    this.embedded = true,
  });
  final DemoStore store;
  final String section;
  final bool embedded;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, child) {
      if (!_canAccess(store, section)) {
        return _Empty(
          icon: Icons.lock_outline,
          title: context.tr('Access denied'),
          message: context.tr(
            'Choose an authorized demo staff account to open restaurant operations.',
          ),
        );
      }
      return switch (section) {
        'overview' || 'shift' => _Overview(store: store),
        'orders' ||
        'queue' => _Orders(store: store, kitchen: section == 'queue'),
        'tables' => _Tables(store: store),
        'menu' || 'availability' => _Menu(
          store: store,
          availabilityOnly: section == 'availability',
        ),
        'requests' => _Requests(store: store),
        'tasks' => _Deliveries(store: store),
        'activity' => _Deliveries(store: store, completed: true),
        _ => _More(store: store),
      };
    },
  );
}

final _openRoutes = Expando<Set<String>>();

bool _canAccess(DemoStore store, String section) {
  final role = store.currentAccount.role;
  if (!store.currentAccount.isStaff) return false;
  if (['more', 'profile', 'help', 'notifications'].contains(section)) {
    return true;
  }
  if (['billing', 'payment-policy'].contains(section)) {
    return role == DemoRole.owner;
  }
  if ([DemoRole.owner, DemoRole.manager].contains(role)) return true;
  return switch (role) {
    DemoRole.waiter => [
      'shift',
      'tables',
      'table',
      'visit',
      'orders',
      'order',
      'requests',
      'request',
    ].contains(section),
    DemoRole.kitchen => ['queue', 'order', 'availability'].contains(section),
    DemoRole.courier => ['tasks', 'activity', 'delivery'].contains(section),
    _ => false,
  };
}

Future<void> openOperation(
  BuildContext context,
  DemoStore store,
  String section, {
  String? id,
}) async {
  final routeKey = '${store.currentAccount.id}:$section:${id ?? ''}';
  final navigator = Navigator.of(context);
  final routes = _openRoutes[navigator] ??= <String>{};
  if (!routes.add(routeKey)) return;
  Widget body() => switch (section) {
    'orders' => _Orders(store: store, initialStatus: id ?? 'All'),
    'queue' => _Orders(store: store, kitchen: true, initialStatus: id ?? 'All'),
    'tables' => _Tables(store: store, occupiedOnly: id == 'occupied'),
    'order' => _OrderDetail(store: store, id: id!),
    'visit' => _VisitDetail(store: store, id: id!),
    'table' => _TableDetail(store: store, id: id!),
    'floor' => _FloorEditor(store: store),
    'item' => _ItemEditor(store: store, id: id),
    'import' => _MenuImport(store: store),
    'menu-builder' => _MenuBuilder(store: store),
    'setup' => _Setup(store: store),
    'restaurant' ||
    'services' ||
    'delivery-settings' ||
    'payment-policy' => _RestaurantEditor(store: store, section: section),
    'storefront' => _Storefront(store: store),
    'payments' => _Payments(store: store),
    'team' => _Team(store: store),
    'reports' => _Reports(store: store),
    'reservations' => _Reservations(store: store),
    'notifications' => _Activity(store: store),
    'billing' => _Billing(store: store),
    'delivery' => _DeliveryDetail(store: store, id: id!),
    'deliveries' => _Deliveries(store: store),
    'requests' => _Requests(store: store),
    'request' => _RequestRecord(store: store, id: id!),
    'help' => _RoleHelp(store: store),
    _ => OperationsPage(store: store, section: section),
  };
  const titles = <String, String>{
    'order': 'Order detail',
    'visit': 'Table visit',
    'table': 'Table & QR',
    'floor': 'Floor plan',
    'item': 'Menu item',
    'import': 'Menu import',
    'menu-builder': 'Menu studio',
    'setup': 'Setup checklist',
    'restaurant': 'Restaurant profile',
    'services': 'Services & hours',
    'delivery-settings': 'Delivery settings',
    'payment-policy': 'Payment policy',
    'storefront': 'Storefront preview',
    'payments': 'Payments',
    'team': 'Team',
    'reports': 'Reports',
    'reservations': 'Reservations & waitlist',
    'notifications': 'Activity',
    'billing': 'Plan preview',
    'delivery': 'Delivery task',
    'deliveries': 'Delivery desk',
    'requests': 'Service requests',
    'request': 'Request detail',
    'help': 'Role & help',
  };
  try {
    await navigator.push<void>(
      MaterialPageRoute(
        builder: (context) => ListenableBuilder(
          listenable: store,
          builder: (context, _) => Scaffold(
            appBar: AppBar(title: Text(context.tr(titles[section] ?? section))),
            body: SafeArea(
              top: false,
              child: _canAccess(store, section)
                  ? KeyedSubtree(
                      key: ValueKey(
                        '${store.currentAccount.id}:${store.currentRestaurant.id}:${store.generation}:$section:${id ?? ''}',
                      ),
                      child: body(),
                    )
                  : _Empty(
                      title: context.tr('Access denied'),
                      message: context.tr(
                        'This role cannot open that operation.',
                      ),
                      icon: Icons.lock_outline,
                    ),
            ),
          ),
        ),
      ),
    );
  } finally {
    routes.remove(routeKey);
  }
}
