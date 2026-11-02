// Product-video captures of real Flutter widgets using read-only QA snapshots.
// Input stays private in .tooling/video-data.json; no network or payment writes.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/design_system/design_system.dart';
import 'package:raysto/features/connected/connected_app.dart';

class CaptureApi extends PlatformApi {
  CaptureApi(this.data)
    : super(
        origin: Uri.parse('https://capture.invalid'),
        identity: () => '${data['room']['currentUserId']}',
        headers: () async => {},
      );
  final Map<String, dynamic> data;
  List<int>? messageIndices;
  bool replayReview = false;
  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async {
    if (operation == 'room') {
      final room = Map<String, dynamic>.from(data['room']);
      final messages = room['messages'] as List;
      return {
        ...room,
        'messages': [
          for (final i in messageIndices ?? [1, 2, 3])
            if (replayReview && obj(obj(messages[i])['body'])['proposal'] != null)
              {
                ...obj(messages[i]),
                'body': {
                  ...obj(obj(messages[i])['body']),
                  'proposal': {
                    ...obj(obj(obj(messages[i])['body'])['proposal']),
                    'status': 'review',
                    'expiresAt': '2050-01-01T00:00:00Z',
                  },
                },
              }
            else messages[i],
        ],
        'lastReadSequence': 1000,
        'beforeCursor': null,
      };
    }
    if (operation == 'discovery') {
      return {
        'rows': [
          {
            'id': 3,
            'name': data['storefront']['name'],
            'open': true,
            'address': 'Sandbox demonstration',
          },
        ],
      };
    }
    if (operation == 'me') {
      return {
        'memberships': [
          {
            'restaurantId': 3,
            'name': data['storefront']['name'],
            'role': 'owner',
          },
        ],
      };
    }
    return Map<String, dynamic>.from(data[operation] ?? {'rows': []});
  }

  @override
  Future<Map<String, dynamic>> command(
    String operation,
    Map<String, dynamic> data, {
    int? restaurantId,
    int? resourceId,
    int? version,
  }) async => {};
  @override
  Stream<Map<String, dynamic>> watchRoom(
    int restaurantId,
    int roomId,
    int after,
  ) => const Stream.empty();
  @override
  Future<Map<String, dynamic>?> readRoomDraft(
    int restaurantId,
    int roomId,
  ) async => null;
  @override
  Future<void> saveRoomDraft(
    int restaurantId,
    int roomId,
    Map<String, dynamic>? draft,
  ) async {}
}

class CaptureRuntime implements LiveRuntime {
  CaptureRuntime(this.platform);
  @override
  final PlatformApi platform;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('PlusJakartaSans');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('capture the real mobile interface for the product film', (
    tester,
  ) async {
    final data = Map<String, dynamic>.from(
      jsonDecode(File('.tooling/video-data.json').readAsStringSync()),
    );
    final api = CaptureApi(data), runtime = CaptureRuntime(CaptureApi(data));
    final roomRuntime = CaptureRuntime(api);
    final live = LiveContext(
      runtime,
      restaurantId: 3,
      name: 'Raysto Sandbox Table · QA',
      role: 'owner',
    );
    final diner = LiveContext(roomRuntime, restaurantId: 3, name: 'Garden 1');
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);
    const boundary = Key('video-capture');
    bool artWarmed = false;
    Future<void> show(Widget page) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (c, child) => MotionScope(
            reducedMotion: true,
            child: RepaintBoundary(key: boundary, child: child!),
          ),
          home: page,
        ),
      );
      await tester.pumpAndSettle();
      if (!artWarmed) {
        await tester.runAsync(() async {
          await precacheImage(
            const AssetImage('assets/images/raysto-table-story.png'),
            tester.element(find.byType(Scaffold).first),
          );
        });
        artWarmed = true;
      }
      await tester.pumpAndSettle();
    }

    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull, reason: name);
      await tester.runAsync(() async {
        final render = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundary),
        );
        final image = await render.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = File('video/public/screens/$name.png');
        output.parent.createSync(recursive: true);
        output.writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
      debugPrint('Captured $name');
    }

    await show(DiscoveryPage(live: live));
    await capture('discovery');
    await show(StorefrontPage(live: live));
    await capture('menu');
    api.messageIndices = [1, 2];
    await show(TableRoomPage(live: diner, roomId: 1));
    await capture('conversation');
    await tester.tap(find.byTooltip('People at your table'));
    await tester.pumpAndSettle();
    await capture('people');
    await show(TableRoomPage(live: diner, roomId: 1));
    await tester.tap(find.text('Ask Raysto').first);
    await tester.enterText(find.byType(TextField).first,
        'There are two of us, both prefer vegetarian food. Keep the food total under \$30 and suggest something to share.');
    await tester.pump();
    await capture('composer');
    api.messageIndices = [3];
    await show(TableRoomPage(live: diner, roomId: 1));
    await capture('ai-basket');
    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();
    await capture('ai-tools');
    // Explicit demo replay of the historical review step. No server mutation.
    api.replayReview = true;
    await show(TableRoomPage(live: diner, roomId: 1));
    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Review & confirm order'));
    await tester.tap(find.text('Review & confirm order'));
    await tester.pumpAndSettle();
    await capture('review-order');
    api.replayReview = false;
    api.messageIndices = [4, 6, 7];
    await show(TableRoomPage(live: diner, roomId: 1));
    await capture('service-handoff');
    await show(kitchenPage(live));
    await capture('kitchen');
    await show(orderPage(live, 2));
    await capture('order');
    api.messageIndices = [9];
    await show(TableRoomPage(live: diner, roomId: 1));
    await capture('share');
    api.replayReview = true;
    await show(TableRoomPage(live: diner, roomId: 1));
    await tester.drag(find.byType(ListView).first, const Offset(0, -650));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Review & pay my share'));
    await tester.tap(find.text('Review & pay my share'));
    await tester.pumpAndSettle();
    await capture('review-share');
    await tester.pumpWidget(const SizedBox());
  });
}
