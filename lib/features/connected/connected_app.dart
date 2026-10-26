library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../backend/live_runtime.dart';
import '../../app/navigation.dart';
import '../../backend/platform_api.dart';
import '../../design_system/design_system.dart';
import '../scanning/qr_camera_screen.dart';
import '../payments/sandbox_test_screen.dart';
import 'forms.dart';
import 'schemas.dart';
import 'security.dart';
part 'shopping.dart';
part 'operations.dart';
part 'activity.dart';
part 'administration.dart';
part 'room.dart';

typedef Json = Map<String, dynamic>;
Json obj(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : {};
List<Json> records(dynamic value) => (value as List? ?? []).map(obj).toList();
String money(dynamic value, [String currency = '']) =>
    '${((value as num? ?? 0) / 100).toStringAsFixed(2)} $currency';

class LiveContext {
  const LiveContext(
    this.runtime, {
    this.restaurantId,
    this.role = 'customer',
    this.name = 'Raysto',
  });
  final LiveRuntime runtime;
  final int? restaurantId;
  final String role, name;
  PlatformApi get api => runtime.platform;
  bool get manager => {'owner', 'manager'}.contains(role);
  bool get operator => manager || role == 'waiter';
  Json params([Json extra = const {}]) => {
    if (restaurantId != null) 'restaurantId': restaurantId,
    ...extra,
  };
  LiveContext tenant(int id, {String role = 'customer', String? name}) =>
      LiveContext(
        runtime,
        restaurantId: id,
        role: role,
        name: name ?? this.name,
      );

  Future<Json?> action(
    BuildContext context,
    String title,
    String operation, {
    List<InputSpec> fields = const [],
    Json initial = const {},
    int? id,
    int? version,
    Json fixed = const {},
    bool typed = false,
    String submit = 'Confirm',
  }) async {
    PendingCommand? pending;
    String? fingerprint;
    return editFields(
      context,
      title,
      fields,
      initial: initial,
      submit: submit,
      save: (input) async {
        final data = {...fixed, ...input};
        final next = jsonEncode(data);
        if (pending == null || next != fingerprint) {
          pending = typed
              ? PendingCommand(operation, params(data))
              : api.prepare(
                  operation,
                  data,
                  restaurantId: restaurantId,
                  resourceId: id,
                  version: version,
                );
          fingerprint = next;
        }
        return api.submit(pending!);
      },
    );
  }
}

class ConnectedApp extends StatefulWidget {
  const ConnectedApp({
    super.key,
    required this.runtime,
    required this.onSignOut,
  });
  final LiveRuntime runtime;
  final Future<void> Function() onSignOut;
  @override
  State<ConnectedApp> createState() => _ConnectedAppState();
}

class _ConnectedAppState extends State<ConnectedApp> {
  int selected = 0;
  late final live = LiveContext(widget.runtime);
  StreamSubscription<RemoteMessage>? openedNotification;
  final openedIds = <String>{};
  @override
  void initState() {
    super.initState();
    openedNotification = FirebaseMessaging.onMessageOpenedApp.listen(
      openNotification,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && mounted) openNotification(message);
    }).catchError((Object _) { /* The in-app inbox remains available. */ });
  }

  void openNotification(RemoteMessage message) {
    if (!mounted || live.api.identity() == null) return;
    final event = message.messageId ?? message.data['eventId'];
    if (event != null && !openedIds.add(event)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Notification payloads never grant access; destination reauthorizes.
      final restaurant = int.tryParse('${message.data['restaurantId']}');
      final room = int.tryParse('${message.data['roomId']}');
      if (restaurant != null && room != null) {
        push(
          context,
          TableRoomPage(live: live.tenant(restaurant), roomId: room),
        );
      } else {
        push(context, notificationsPage(live));
      }
    });
  }

  @override
  void dispose() {
    openedNotification?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: KeyedSubtree(
      key: ValueKey(selected),
      child: switch (selected) {
        0 => DiscoveryPage(live: live),
        1 => activityHome(live),
        2 => teamsHome(live),
        _ => accountHome(live, widget.onSignOut),
      },
    ),
    bottomNavigationBar: RaystoAdaptiveDock(
      index: selected,
      onChanged: (i) => setState(() => selected = i),
      options: const [
        DockDestination('Discover', Icons.explore_outlined, Icons.explore),
        DockDestination(
          'Activity',
          Icons.receipt_long_outlined,
          Icons.receipt_long,
        ),
        DockDestination(
          'Restaurants',
          Icons.storefront_outlined,
          Icons.storefront,
        ),
        DockDestination('Account', Icons.person_outline, Icons.person),
      ],
    ),
  );
}

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

/// Only the visible page polls; it stops in background and never caches data
/// across identities. Every refresh still passes backend authorization.
class DataPage extends StatefulWidget {
  const DataPage({
    super.key,
    required this.title,
    required this.load,
    required this.content,
    this.poll = false,
  });
  final String title;
  final Future<Json> Function() load;
  final List<Widget> Function(BuildContext, Json, Future<void> Function())
  content;
  final bool poll;
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> with WidgetsBindingObserver {
  Json? data;
  String? error;
  bool busy = false;
  Timer? timer;
  bool foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    if (widget.poll) {
      timer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (foreground && ModalRoute.of(context)?.isCurrent == true) refresh();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (foreground && ModalRoute.of(context)?.isCurrent == true) refresh();
  }

  Future<void> refresh() async {
    if (busy || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.load();
      if (mounted) setState(() => data = result);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e is PlatformFailure
              ? e.message
              : 'Could not refresh. Please try again.';
          data = null;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: widget.title == 'Discover'
          ? const RaystoWordmark()
          : Text(widget.title),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: busy ? null : refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (busy)
              if (AppMotion.reduced(context))
                const Text('Loading…')
              else
                const LinearProgressIndicator(),
            if (busy && data == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: RaystoIllustration(scene: RaystoScene.menu),
              ),
            if (error != null)
              AppNotice(
                title: 'Connection needs attention',
                message: error,
                action: AppButton(label: 'Retry', onPressed: refresh),
              ),
            if (data != null)
              ...widget
                  .content(context, data!, refresh)
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: w,
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}

Widget tile(
  String title,
  IconData icon,
  VoidCallback onTap, {
  String? subtitle,
}) => RaystoActionCard(
  title: title,
  icon: icon,
  subtitle: subtitle,
  onTap: onTap,
);
Widget empty(String text) =>
    RaystoEmptyState(title: text, message: 'Pull down to refresh.');

Widget rowsPage(
  LiveContext live,
  String title,
  String query,
  Widget Function(BuildContext, Json, Future<void> Function()) item, {
  Json parameters = const {},
  List<Widget> Function(BuildContext, Json, Future<void> Function())? before,
  bool poll = false,
}) => PagedRecords(
  key: ValueKey('$query:${live.restaurantId}:${jsonEncode(parameters)}'),
  live: live,
  title: title,
  query: query,
  parameters: parameters,
  item: item,
  before: before,
  poll: poll,
);

class PagedRecords extends StatefulWidget {
  const PagedRecords({
    super.key,
    required this.live,
    required this.title,
    required this.query,
    required this.parameters,
    required this.item,
    this.before,
    this.poll = false,
  });
  final LiveContext live;
  final String title, query;
  final Json parameters;
  final Widget Function(BuildContext, Json, Future<void> Function()) item;
  final List<Widget> Function(BuildContext, Json, Future<void> Function())?
  before;
  final bool poll;
  @override
  State<PagedRecords> createState() => _PagedRecordsState();
}

class _PagedRecordsState extends State<PagedRecords> {
  int cursor = 0;
  @override
  Widget build(BuildContext context) => DataPage(
    key: ValueKey(cursor),
    title: widget.title,
    poll: widget.poll,
    load: () => widget.live.api.query(
      widget.query,
      widget.live.params({...widget.parameters, 'cursor': cursor, 'limit': 30}),
    ),
    content: (c, d, refresh) => [
      ...?widget.before?.call(c, d, refresh),
      if (records(d['rows']).isEmpty) _emptyRecords(widget.query),
      for (final row in records(d['rows'])) widget.item(c, row, refresh),
      if (d['nextCursor'] != null)
        OutlinedButton(
          onPressed: () => setState(() => cursor = d['nextCursor']),
          child: const Text('Next page'),
        ),
      if (cursor > 0)
        TextButton(
          onPressed: () => setState(() => cursor = 0),
          child: const Text('Back to first page'),
        ),
    ],
  );
}

Widget _emptyRecords(String query) {
  final (title, message, scene) = switch (query) {
    'discovery' => (
      'No restaurants found',
      'Try a different search or change your filters.',
      RaystoScene.table,
    ),
    'orders' => (
      'Your meals, in one place',
      'Your orders will appear here. Pull down to refresh.',
      RaystoScene.receipt,
    ),
    'favorites' => (
      'Keep a little list of favorites',
      'Save a restaurant to find it here next time.',
      RaystoScene.sprout,
    ),
    'kitchen' => (
      'Nothing on the pass yet',
      'New kitchen tickets appear here. Pull down to refresh.',
      RaystoScene.kitchen,
    ),
    'deliveries' => (
      'No delivery tasks yet',
      'Your assigned deliveries will appear here.',
      RaystoScene.bag,
    ),
    'notifications' => (
      'You’re all caught up',
      'Updates about your activity will appear here.',
      RaystoScene.receipt,
    ),
    _ => ('Nothing here yet', 'Pull down to refresh.', RaystoScene.table),
  };
  return RaystoEmptyState(title: title, message: message, scene: scene);
}

Future<void> openProvider(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      !{
        'www.sandbox.paypal.com',
        'sandbox.paypal.com',
        'www.paypal.com',
        'paypal.com',
      }.contains(uri.host)) {
    throw const PlatformFailure(
      'unsafe_link',
      'The payment provider link is invalid.',
    );
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw const PlatformFailure('browser_failed', 'Unable to open PayPal.');
  }
}

Future<void> notice(BuildContext context, String title, Json result) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: RecordSummary(result)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Done'),
          ),
        ],
      ),
    );

Future<void> perform(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is PlatformFailure
                ? e.message
                : 'The action could not be completed. Please retry.',
          ),
        ),
      );
    }
  }
}
