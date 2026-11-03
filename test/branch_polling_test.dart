import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/l10n/app_localizations.dart';

/// Counts every live subscription the boards open.
class FeedApi extends PlatformApi {
  FeedApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'staff',
        headers: () async => {},
      );
  var watches = 0;
  final _events = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> watchRestaurant(int restaurantId, int after) {
    watches++;
    return _events.stream;
  }
}

class Runtime implements LiveRuntime {
  Runtime(this.platform);
  @override
  final PlatformApi platform;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// A board as the staff screens build one: its own feed, a polling page.
class Board extends StatefulWidget {
  const Board({super.key, required this.live, required this.load});
  final LiveContext live;
  final Future<Map<String, dynamic>> Function() load;
  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late final RestaurantFeed feed = RestaurantFeed(widget.live)..start();
  @override
  void dispose() {
    feed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DataPage(
    title: 'Board',
    poll: true,
    trigger: feed,
    load: widget.load,
    content: (c, d, refresh) => [Text('loaded ${d['n']}')],
  );
}

Widget host(Widget child) => MotionScope(
  reducedMotion: true,
  child: MaterialApp(
    theme: AppTheme.light,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  ),
);

void main() {
  testWidgets('a hidden branch neither loads, polls nor listens', (
    tester,
  ) async {
    final api = FeedApi();
    final live = LiveContext(Runtime(api), restaurantId: 5, role: 'manager');
    var loads = 0;
    Future<Map<String, dynamic>> load() async => {'n': ++loads};
    late StateSetter update;
    var visible = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return TickerMode(
              enabled: visible,
              child: Board(live: live, load: load),
            );
          },
        ),
      ),
    );
    for (var s = 0; s < 60; s++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(loads, 0);
    expect(api.watches, 0);

    // Shown: one load to catch up, one subscription, then the usual poll.
    update(() => visible = true);
    await tester.pump();
    await tester.pump();
    expect(loads, 1);
    expect(api.watches, 1);
    expect(find.text('loaded 1'), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    expect(loads, 2);

    // Hidden again: nothing more, however long it stays hidden.
    update(() => visible = false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 60));
    expect(loads, 2);
    expect(api.watches, 1);

    // Back: it catches up from the same feed rather than a new history.
    update(() => visible = true);
    await tester.pump();
    await tester.pump();
    expect(loads, 3);
    expect(api.watches, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
