part of 'platform.dart';

/// Kill timed-out decoders/scanners rather than leaving orphan subprocesses.
Future<ProcessResult> _boundedProcess(
  String binary,
  List<String> arguments,
  Duration timeout,
) async {
  final process = await Process.start(binary, arguments, runInShell: false);
  Future<String> collect(Stream<List<int>> stream) async {
    final buffer = BytesBuilder(copy: false);
    await for (final bytes in stream) {
      if (buffer.length < 65536) {
        buffer.add(bytes.take(65536 - buffer.length).toList());
      }
    }
    return utf8.decode(buffer.takeBytes(), allowMalformed: true);
  }

  final output = collect(process.stdout);
  final error = collect(process.stderr);
  final timer = Timer(timeout, () => process.kill(ProcessSignal.sigkill));
  try {
    final code = await process.exitCode;
    return ProcessResult(process.pid, code, await output, await error);
  } finally {
    timer.cancel();
  }
}

class PlatformFiles {
  /// Parse untrusted image bytes once; malformed codecs are terminal rejections.
  static (Uint8List, Json) sanitizeImage(Uint8List bytes) {
    try {
      final decoder = img.findDecoderForData(bytes);
      final info = decoder?.startDecode(bytes);
      if (info == null ||
          info.width < 1 ||
          info.height < 1 ||
          info.width * info.height > 20000000 ||
          info.numFrames != 1) {
        _fail('invalid_file', 'Image dimensions or frame count exceed limits.');
      }
      final image = decoder!.decodeFrame(0);
      if (image == null) _fail('invalid_file', 'Image cannot be decoded.');
      return (
        Uint8List.fromList(
          img.encodeJpg(
            img.copyResize(image, width: min(2400, image.width)),
            quality: 88,
          ),
        ),
        {'width': info.width, 'height': info.height},
      );
    } on DomainError {
      rethrow;
    } catch (_) {
      _fail('invalid_file', 'Image is malformed or cannot be decoded.');
    }
  }

  static Future<(Uint8List, String)> read(Session s, int id) async {
    PlatformApi.enabled();
    final a = await MediaAsset.db.findById(s, id);
    if (a == null || a.status != 'approved') {
      _fail('not_found', 'File not found.');
    }
    var public = false;
    if (a.public && a.restaurantId != null && a.purpose == 'menuImage') {
      final r = await Restaurant.db.findById(s, a.restaurantId!);
      final p = await RestaurantPolicy.db.findFirstRow(
        s,
        where: (t) => t.restaurantId.equals(a.restaurantId!),
      );
      public = r?.published == true && p?.suspended == false;
    }
    if (!public) {
      await PlatformApi.guard(s);
      final actor = await _actor(s);
      if (a.userId != actor.userId) {
        if (a.purpose == 'export') _fail('not_found', 'File not found.');
        var recipient = false;
        if (a.purpose == 'support') {
          final messages = await SupportMessage.db.find(
            s,
            where: (t) => t.mediaId.equals(a.id!),
            limit: 101,
          );
          for (final message in messages) {
            final conversation = await SupportConversation.db.findById(
              s,
              message.conversationId,
            );
            if (conversation?.userId == actor.userId &&
                conversation?.restaurantId == a.restaurantId) {
              recipient = true;
              break;
            }
          }
        }
        if (!recipient) {
          if (a.restaurantId == null) {
            await s.db.transaction((tx) async {
              await _admin(
                Work(
                  s,
                  tx,
                  actor,
                  PlatformCommand(requestKey: _uuid(), dataJson: '{}'),
                  null,
                  null,
                ),
              );
            });
          } else {
            await _role(s, actor.userId, a.restaurantId!, _managers);
          }
        }
      }
      if (a.purpose == 'export' &&
          DateTime.parse(
            _json(a.metadataJson)['expiresAt'] as String,
          ).isBefore(_now())) {
        _fail('not_found', 'Export has expired.');
      }
    }
    return (await ProviderClients.getFile(a.objectName), a.mime);
  }
}
