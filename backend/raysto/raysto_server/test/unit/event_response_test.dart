import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:raysto_server/src/web/event_response.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    'SSE flushes before source completion and ends without leaking errors',
    () async {
      final frames = StreamController<Uint8List>();
      final app = RelicApp()
        ..get('/events', (_) => eventResponse(frames.stream));
      final server = await app.serve(port: 0);
      final client = HttpClient();
      addTearDown(() async {
        client.close(force: true);
        await frames.close();
        await server.close(force: true);
      });
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${server.port}/events'),
      );
      final responseFuture = request.close();
      frames.add(utf8.encode('event: ready\ndata: {}\n\n'));
      final response = await responseFuture.timeout(const Duration(seconds: 3));
      expect(response.statusCode, 200);
      expect(response.headers.contentType?.mimeType, 'text/event-stream');
      final received = <String>[];
      final first = Completer<void>();
      final done = Completer<void>();
      response.transform(utf8.decoder).listen((chunk) {
        received.add(chunk);
        if (!first.isCompleted) first.complete();
      }, onDone: () => done.complete());
      await first.future.timeout(const Duration(seconds: 3));
      expect(frames.isClosed, isFalse);
      expect(received.join(), contains('event: ready'));
      frames.addError(StateError('sensitive provider details'));
      await done.future.timeout(const Duration(seconds: 3));
      expect(received.join(), isNot(contains('sensitive')));
    },
  );
}
