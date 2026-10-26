import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:googleapis_auth/auth_io.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'raysto_service.dart';

/// Server-only Firebase HTTP v1/GCS adapter; no service account belongs in Flutter.
class FirebaseServices {
  final String serviceAccountJson;
  final String projectId;
  final String bucket;
  FirebaseServices({
    required this.serviceAccountJson,
    required this.projectId,
    required this.bucket,
  });

  factory FirebaseServices.fromEnvironment() {
    final path = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
    final project = Platform.environment['FIREBASE_PROJECT_ID'];
    final bucket = Platform.environment['FIREBASE_STORAGE_BUCKET'];
    if (path == null || project == null || bucket == null) {
      RaystoService.fail(
        'not_configured',
        'Firebase services are not configured.',
      );
    }
    return FirebaseServices(
      serviceAccountJson: File(path).readAsStringSync(),
      projectId: project,
      bucket: bucket,
    );
  }

  Future<T> _authorized<T>(
    List<String> scopes,
    Future<T> Function(AutoRefreshingAuthClient) fn,
  ) async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }

  /// At-least-once delivery: client deduplicates on eventId. No PII in push data.
  Future<bool> send(
    String token,
    int eventId,
    int orderId,
    String kind,
  ) => _authorized(['https://www.googleapis.com/auth/firebase.messaging'], (
    client,
  ) async {
    final response = await client
        .post(
          Uri.https(
            'fcm.googleapis.com',
            '/v1/projects/$projectId/messages:send',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': {
              'token': token,
              'data': {
                'eventId': '$eventId',
                'orderId': '$orderId',
                'kind': kind,
              },
            },
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode >= 200 && response.statusCode < 300) return true;
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final details =
        (decoded['error'] as Map<String, dynamic>?)?['details'] as List? ?? [];
    if (details.any(
      (detail) => detail is Map && detail['errorCode'] == 'UNREGISTERED',
    )) {
      return false;
    }
    throw StateError('Firebase push delivery failed (${response.statusCode}).');
  });

  /// Uploads are private. Reading/publication requires an explicit serving policy.
  Future<String> uploadMenuImage(
    Session s,
    int restaurantId,
    Uint8List bytes,
    String mime,
  ) async {
    await RaystoService.requireRole(s, restaurantId, RaystoService.managers);
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    if (bytes.length > 2 * 1024 * 1024 ||
        !(mime == 'image/png' && png || mime == 'image/jpeg' && jpeg)) {
      RaystoService.fail(
        'invalid_input',
        'Only PNG/JPEG images up to 2 MB are accepted.',
      );
    }
    final random = Random.secure();
    final nonce = List.generate(
      20,
      (_) => random.nextInt(256),
    ).map((n) => n.toRadixString(16).padLeft(2, '0')).join();
    final name = 'restaurants/$restaurantId/menu/$nonce';
    return _authorized(
      ['https://www.googleapis.com/auth/devstorage.read_write'],
      (client) async {
        final uri = Uri.https(
          'storage.googleapis.com',
          '/upload/storage/v1/b/$bucket/o',
          {'uploadType': 'media', 'name': name, 'ifGenerationMatch': '0'},
        );
        final response = await client
            .post(uri, headers: {'Content-Type': mime}, body: bytes)
            .timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) {
          throw StateError(
            'Firebase storage upload failed (${response.statusCode}).',
          );
        }
        return name;
      },
    );
  }

  /// Row locks protect multiple workers. A crash before commit may repeat a push.
  Future<int> dispatchOutbox(Session s, {int limit = 25}) async {
    var delivered = 0;
    for (var index = 0; index < limit; index++) {
      final found = await s.db.transaction((tx) async {
        final now = DateTime.now().toUtc();
        final event = await OutboxEvent.db.findFirstRow(
          s,
          where: (t) => t.deliveredAt.equals(null) & (t.nextAttemptAt <= now),
          orderBy: (t) => t.id,
          lockMode: LockMode.forUpdate,
          lockBehavior: LockBehavior.skipLocked,
          transaction: tx,
        );
        if (event == null) return false;
        final tokens = await DeviceToken.db.find(
          s,
          where: (t) => t.userId.equals(event.userId),
          limit: 100,
          transaction: tx,
        );
        try {
          for (final token in tokens) {
            if (!await send(
              token.token,
              event.id!,
              event.orderId,
              event.kind,
            )) {
              await DeviceToken.db.deleteRow(s, token, transaction: tx);
            }
          }
          event.deliveredAt = now;
          delivered++;
        } catch (_) {
          event.attempts++;
          event.nextAttemptAt = now.add(
            Duration(seconds: min(3600, 15 * (1 << min(event.attempts, 8)))),
          );
        }
        await OutboxEvent.db.updateRow(s, event, transaction: tx);
        return true;
      });
      if (!found) break;
    }
    return delivered;
  }
}
