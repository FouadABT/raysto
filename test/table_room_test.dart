import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raysto/backend/live_runtime.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/features/connected/connected_app.dart';
import 'package:raysto/design_system/design_system.dart';

class RoomApi extends PlatformApi {
  RoomApi()
    : super(
        origin: Uri.parse('https://fixture.invalid'),
        identity: () => 'diner',
        headers: () async => {},
      );
  @override
  Future<Map<String, dynamic>> query(
    String operation, [
    Map<String, dynamic> params = const {},
  ]) async => {
    'id': 1,
    'restaurantId': 1,
    'visitId': 1,
    'currentUserId': 'diner',
    'hostUserId': 'diner',
    'closed': false,
    'version': 1,
    'sequence': 1,
    'audience': 'Admitted diners and your assigned waiter',
    'members': [
      {'userId': 'diner', 'name': 'Diner', 'role': 'diner'},
    ],
    'messages': [
      {
        'id': 1,
        'sequence': 1,
        'kind': 'message',
        'userId': 'other',
        'body': {'text': 'Shall we share a starter?'},
        'createdAt': '2026-10-26T12:00:00Z',
      },
    ],
    'lastReadSequence': 0,
    'myPreferences': {},
  };
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

class Runtime implements LiveRuntime {
  @override
  final PlatformApi platform = RoomApi();
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  test(
    'activity grouping preserves conversation, unread boundary and history',
    () {
      Map<String, dynamic> event(int sequence) => {
        'sequence': sequence,
        'kind': 'activity',
        'body': {
          'entityType': 'serviceRequest',
          'entityId': 7,
          'event': 'service.acknowledged',
        },
      };
      final messages = [
        event(1),
        event(2),
        {
          'sequence': 3,
          'kind': 'message',
          'body': {'text': 'Thank you'},
        },
        event(4),
        event(5),
        event(6),
      ];
      final grouped = groupRoomActivity(messages, unreadSequence: 5);
      expect(grouped.length, 5);
      expect((grouped.first['activityHistory'] as List).length, 2);
      expect(grouped[1]['kind'], 'message');
      expect(grouped[3]['sequence'], 5);
      expect(messages.length, 6);
    },
  );
  testWidgets(
    'room remains usable on a narrow phone with large text and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MotionScope(
          reducedMotion: true,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(2),
                viewInsets: const EdgeInsets.only(bottom: 240),
              ),
              child: child!,
            ),
            home: TableRoomPage(
              live: LiveContext(Runtime(), restaurantId: 1),
              roomId: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Please bring water');
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
