import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto/backend/platform_api.dart';
import 'package:raysto/features/connected/forms.dart';
import 'package:raysto/design_system/design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'unknown mutation outcome recovers the same key across API instances',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final keys = <String>[];
      var fail = true;
      final transport = MockClient((r) async {
        keys.add((jsonDecode(r.body) as Map)['requestKey'] as String);
        expect(r.headers['authorization'], 'Bearer fixture');
        expect(r.headers['x-raysto-firebase-token'], 'firebase-proof');
        if (fail) {
          fail = false;
          throw http.ClientException('lost response');
        }
        return http.Response('{"data":{"orderId":23}}', 200);
      });
      PlatformApi client() => PlatformApi(
        origin: Uri.parse('https://api.example.test'),
        identity: () => 'u1',
        headers: () async => {
          'Authorization': 'Bearer fixture',
          'X-Raysto-Firebase-Token': 'firebase-proof',
        },
        journal: const FlutterSecureStorage(),
        transport: transport,
      );
      await expectLater(
        client().submit(
          PendingCommand('order.submit', {'restaurantId': 1, 'quoteId': 2}),
        ),
        throwsA(isA<PlatformFailure>()),
      );
      expect(
        await client().submit(
          PendingCommand('order.submit', {'restaurantId': 1, 'quoteId': 2}),
        ),
        {'orderId': 23},
      );
      expect(keys[0], keys[1]);
    },
  );
  test(
    'late account response cannot expose previous identity records',
    () async {
      String? identity = 'first';
      final response = Completer<http.Response>();
      final api = PlatformApi(
        origin: Uri.parse('https://api.example.test'),
        identity: () => identity,
        headers: () async => {},
        transport: MockClient((_) => response.future),
      );
      final result = api.query('orders');
      await Future<void>.delayed(Duration.zero);
      identity = null;
      response.complete(http.Response('{"data":{"rows":[{"id":1}]}}', 200));
      await expectLater(
        result,
        throwsA(
          isA<PlatformFailure>().having(
            (e) => e.code,
            'code',
            'session_changed',
          ),
        ),
      );
    },
  );
  test(
    'authorization refresh retries a command with identical payload',
    () async {
      var calls = 0, refreshed = 0;
      final bodies = <String>[];
      final api = PlatformApi(
        origin: Uri.parse('https://api.example.test'),
        identity: () => 'u',
        headers: () async => {},
        refreshCredentials: () async {
          refreshed++;
        },
        transport: MockClient((r) async {
          bodies.add(r.body);
          return ++calls == 1
              ? http.Response('{"error":{"code":"unauthorized"}}', 401)
              : http.Response('{"data":{"saved":true}}', 200);
        }),
      );
      await api.command(
        'cart.save',
        {'lines': []},
        restaurantId: 1,
        version: 0,
      );
      expect(refreshed, 1);
      expect(bodies.first, bodies.last);
    },
  );
  testWidgets(
    'money editing preserves cents and required nested details prevent submission',
    (tester) async {
      RecordData? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: RecordEditor(
            title: 'Dish',
            submit: 'Save',
            initial: const {'priceMinor': 1299},
            fields: const [
              InputSpec('priceMinor', 'Price', kind: 'money'),
              InputSpec(
                'details',
                'Details',
                kind: 'object',
                children: [InputSpec('name', 'Name')],
              ),
            ],
            save: (d) async {
              saved = d;
              return d;
            },
          ),
        ),
      );
      expect(find.text('12.99'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text('Complete details before saving.'), findsOneWidget);
    },
  );
  testWidgets(
    'small-screen large-text form remains usable and saves exact amounts',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      RecordData? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (_, child) => MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: RecordEditor(
            title: 'Payment',
            submit: 'Confirm amount',
            initial: const {'amountMinor': 1299},
            fields: const [InputSpec('amountMinor', 'Amount', kind: 'money')],
            save: (d) async {
              saved = d;
              return d;
            },
          ),
        ),
      );
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
      expect(saved?['amountMinor'], 1299);
      expect(tester.takeException(), isNull);
    },
  );
}
