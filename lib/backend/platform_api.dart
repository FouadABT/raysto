import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

typedef RecordData = Map<String, dynamic>;

class PlatformFailure implements Exception {
  const PlatformFailure(this.code, this.message, {this.requestId});
  final String code;
  final String message;
  final String? requestId;
  @override
  String toString() => message;
}

/// A request is retained after an unknown outcome. Retrying reuses its key and
/// payload; changed input creates a different request only after explicit edit.
class PendingCommand {
  PendingCommand(this.operation, this.body) : key = PlatformApi.newKey();
  final String operation;
  final RecordData body;
  final String key;
}

class PlatformApi {
  PlatformApi({
    required this.origin,
    required this.headers,
    required this.identity,
    this.refreshCredentials,
    this.journal,
    http.Client? transport,
  }) : _http = transport ?? http.Client();
  final Uri origin;
  final Future<Map<String, String>> Function() headers;
  final String? Function() identity;
  final Future<void> Function()? refreshCredentials;
  final FlutterSecureStorage? journal;
  Future<void> _journalWrites = Future.value();
  final http.Client _http;
  static String newKey() =>
      base64UrlEncode(List.generate(24, (_) => Random.secure().nextInt(256)))
          .replaceAll('=', '');

  Future<RecordData> query(String name, [RecordData parameters = const {}]) =>
      _request('GET', 'queries/$name', parameters: parameters);

  Future<RecordData> submit(PendingCommand command) async {
    final owner = identity();
    final store = journal;
    final fingerprint = sha256
        .convert(
          utf8.encode(
            jsonEncode([
              origin.toString(),
              owner,
              command.operation,
              command.body,
            ]),
          ),
        )
        .toString();
    final storageKey = 'raysto.v2.mutation.$fingerprint';
    var requestKey = command.key;
    if (store != null && command.operation != 'identity.stepUp') {
      final write = _journalWrites.then((_) async {
        requestKey = await store.read(key: storageKey) ?? command.key;
        await store.write(key: storageKey, value: requestKey);
      });
      _journalWrites = write.catchError((Object _) {});
      await write;
    }
    _sameIdentity(owner);
    final result = await _request(
      'POST',
      'commands/${command.operation}',
      body: {'requestKey': requestKey, ...command.body},
    );
    if (store != null) await store.delete(key: storageKey);
    return result;
  }

  PendingCommand prepare(
    String operation,
    RecordData data, {
    int? restaurantId,
    int? resourceId,
    int? version,
  }) => PendingCommand(operation, {
    'restaurantId': ?restaurantId,
    'resourceId': ?resourceId,
    'expectedVersion': ?version,
    'dataJson': jsonEncode(data),
  });

  Future<RecordData> command(
    String operation,
    RecordData data, {
    int? restaurantId,
    int? resourceId,
    int? version,
  }) => submit(
    prepare(
      operation,
      data,
      restaurantId: restaurantId,
      resourceId: resourceId,
      version: version,
    ),
  );

  Future<RecordData> upload(int id, Uint8List bytes) =>
      _request('PUT', 'media/$id/content', bytes: bytes);

  Future<Uint8List> download(int id) async {
    final owner = identity();
    final response = await _http
        .get(origin.resolve('/api/v2/media/$id'), headers: await headers())
        .timeout(const Duration(seconds: 30));
    _sameIdentity(owner);
    if (response.statusCode != 200) {
      throw const PlatformFailure(
        'download_failed',
        'The file is unavailable or its access has expired.',
      );
    }
    return response.bodyBytes;
  }

  void _sameIdentity(String? owner) {
    if (owner != identity()) {
      throw const PlatformFailure(
        'session_changed',
        'Your account changed. Reopen this screen.',
      );
    }
  }

  Future<RecordData> _request(
    String method,
    String path, {
    RecordData? parameters,
    RecordData? body,
    Uint8List? bytes,
  }) async {
    final owner = identity();
    final url = origin
        .resolve('/api/v2/$path')
        .replace(
          queryParameters: parameters == null
              ? null
              : {
                  for (final entry in parameters.entries)
                    if (entry.value != null) entry.key: '${entry.value}',
                },
        );
    for (var attempt = 0; attempt < 2; attempt++) {
      final h = await headers();
      _sameIdentity(owner);
      http.Response response;
      try {
        response =
            await (method == 'GET'
                    ? _http.get(url, headers: h)
                    : method == 'PUT'
                    ? _http.put(
                        url,
                        headers: {
                          ...h,
                          'Content-Type': 'application/octet-stream',
                        },
                        body: bytes,
                      )
                    : _http.post(
                        url,
                        headers: {...h, 'Content-Type': 'application/json'},
                        body: jsonEncode(body),
                      ))
                .timeout(const Duration(seconds: 45));
      } on TimeoutException {
        throw const PlatformFailure(
          'outcome_unknown',
          'The response timed out. Retry this same request to recover its result.',
        );
      } on http.ClientException {
        throw const PlatformFailure(
          'connection_failed',
          'Connection interrupted. Retry to recover the result.',
        );
      }
      _sameIdentity(owner);
      if (response.statusCode == 401 &&
          attempt == 0 &&
          refreshCredentials != null) {
        await refreshCredentials!();
        _sameIdentity(owner);
        continue;
      }
      RecordData result;
      try {
        result = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      } catch (_) {
        throw const PlatformFailure(
          'unavailable',
          'Raysto is temporarily unavailable. Please retry.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = result['error'];
        final detail = error is Map ? error : result;
        throw PlatformFailure(
          '${detail['code'] ?? error ?? 'request_failed'}',
          '${detail['message'] ?? 'This action could not be completed. Refresh and retry.'}',
          requestId: result['requestId']?.toString(),
        );
      }
      return Map<String, dynamic>.from((result['data'] ?? result) as Map);
    }
    throw const PlatformFailure(
      'sign_in_required',
      'Sign in again to continue.',
    );
  }
}
