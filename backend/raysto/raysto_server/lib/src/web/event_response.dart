import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';

/// Relic 2.0.0-rc.2's standard IO response flushes after addStream completes.
/// Its supported Hijack result lets this bounded SSE response flush each frame.
/// Authentication and the first authorization check happen before this result;
/// the source stream continues checking revocation and membership every tick.
Result eventResponse(Stream<Uint8List> events) => Hijack((channel) async {
  var disconnected = false;
  final incoming = channel.stream.listen(
    (_) {},
    onDone: () => disconnected = true,
    onError: (Object _) => disconnected = true,
  );
  final sink = channel.sink;
  try {
    sink.add(
      utf8.encode(
        'HTTP/1.1 200 OK\r\n'
        'Content-Type: text/event-stream; charset=utf-8\r\n'
        'Cache-Control: no-store, no-transform\r\n'
        'X-Accel-Buffering: no\r\n'
        'X-Content-Type-Options: nosniff\r\n'
        'Connection: close\r\n\r\n',
      ),
    );
    await for (final frame in events.timeout(const Duration(seconds: 15))) {
      if (disconnected) break;
      sink.add(frame);
      if (sink is IOSink) await sink.flush();
    }
  } catch (_) {
    // Closing makes clients reconnect and reauthorize; never stream exceptions
    // or provider details after response headers have been sent.
  } finally {
    try {
      await sink.close();
    } catch (_) {}
    await incoming.cancel();
  }
});
