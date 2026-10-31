import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/services/gemini_transport.dart';
import 'package:test/test.dart';

// The Gemini Developer API path behind GEMINI_API_KEY, against a fake Google.
// No network, no key: the fixture value below is not a credential.
void main() {
  final turn = [
    {
      'role': 'user',
      'parts': [
        {'text': 'hi'},
      ],
    },
  ];
  String sse(List<Map<String, dynamic>> frames) =>
      frames.map((f) => 'data: ${jsonEncode(f)}\r\n\r\n').join();
  final answer = sse([
    {
      'candidates': [
        {
          'index': 0,
          'content': {
            'role': 'model',
            'parts': [
              {'text': 'Hello'},
            ],
          },
          'finishReason': 'STOP',
        },
      ],
      'usageMetadata': {'promptTokenCount': 3, 'candidatesTokenCount': 1},
    },
  ]);
  http.Response count() => http.Response('{"totalTokens": 12}', 200);

  setUp(() {
    ProviderClients.environment = () => {
      ...Platform.environment,
      'GEMINI_API_KEY': 'fixture-key',
    };
  });
  tearDown(() {
    ProviderClients.environment = () => Platform.environment;
    ProviderClients.httpClient = http.Client.new;
  });

  test('a key routes counting and generation to the Developer API', () async {
    final seen = <String>[];
    ProviderClients.httpClient = () => MockClient((r) async {
      seen.add(
        '${r.method} ${r.url.host}${r.url.path}?${r.url.query} '
        'key=${r.headers['x-goog-api-key']} auth=${r.headers['authorization']}',
      );
      final body = jsonDecode(r.body) as Map;
      if (r.url.path.endsWith(':countTokens')) {
        // System instructions and tools only count inside a full request.
        expect(body.keys, ['generateContentRequest']);
        final wrapped = body['generateContentRequest'] as Map;
        expect(wrapped['model'], 'models/gemini-3.6-flash');
        expect(wrapped['systemInstruction'], isNotNull);
        expect(wrapped['tools'], isNotNull);
        return count();
      }
      expect(body['generationConfig']['thinkingConfig']['thinkingLevel'], 'LOW');
      expect(body.containsKey('generateContentRequest'), isFalse);
      return http.Response(answer, 200);
    });
    final result = await ProviderClients.geminiTurn('system', turn, []);
    expect(result['candidates'][0]['content']['parts'][0]['text'], 'Hello');
    expect(result['usageMetadata']['promptTokenCount'], 3);
    expect(seen, [
      'POST generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:countTokens? key=fixture-key auth=null',
      'POST generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:streamGenerateContent?alt=sse key=fixture-key auth=null',
    ]);
  });

  test('GEMINI_MODEL overrides the model on the Developer API', () async {
    ProviderClients.environment = () => {
      ...Platform.environment,
      'GEMINI_API_KEY': 'fixture-key',
      'GEMINI_MODEL': 'gemini-3.8-flash',
    };
    final paths = <String>[];
    ProviderClients.httpClient = () => MockClient((r) async {
      paths.add(r.url.path);
      return r.url.path.endsWith(':countTokens')
          ? count()
          : http.Response(answer, 200);
    });
    await ProviderClients.geminiTurn('system', turn, []);
    expect(paths, everyElement(startsWith('/v1beta/models/gemini-3.8-flash:')));
  });

  test('a busy provider is asked again after a short wait', () async {
    var generate = 0;
    ProviderClients.httpClient = () => MockClient((r) async {
      if (r.url.path.endsWith(':countTokens')) return count();
      generate++;
      return generate < 3
          ? http.Response('busy', 429)
          : http.Response(answer, 200);
    });
    final result = await ProviderClients.geminiTurn(
      'system',
      turn,
      [],
      deadline: const Duration(seconds: 20),
    );
    expect(generate, 3);
    expect(result['candidates'], hasLength(1));
  });

  test('retries stop when the deadline is near', () async {
    var generate = 0;
    ProviderClients.httpClient = () => MockClient((r) async {
      if (r.url.path.endsWith(':countTokens')) return count();
      generate++;
      return http.Response('busy', 429);
    });
    await expectLater(
      ProviderClients.geminiTurn(
        'system',
        turn,
        [],
        deadline: const Duration(seconds: 5),
      ),
      throwsA(isA<GeminiFailure>().having((e) => e.code, 'code', 'ai_capacity')),
    );
    expect(generate, 1);
  });

  test('a timeout is never retried: its charge is unknown', () async {
    var generate = 0;
    ProviderClients.httpClient = () => MockClient((r) {
      if (r.url.path.endsWith(':countTokens')) {
        return Future.value(count());
      }
      generate++;
      return Completer<http.Response>().future;
    });
    await expectLater(
      ProviderClients.geminiTurn(
        'system',
        turn,
        [],
        deadline: const Duration(milliseconds: 300),
      ),
      throwsA(isA<GeminiFailure>().having((e) => e.code, 'code', 'ai_timeout')),
    );
    expect(generate, 1);
  });

  test('an oversized prompt is refused before any paid generation', () async {
    var generate = 0;
    ProviderClients.httpClient = () => MockClient((r) async {
      if (r.url.path.endsWith(':countTokens')) {
        return http.Response('{"totalTokens": 20000}', 200);
      }
      generate++;
      return http.Response(answer, 200);
    });
    await expectLater(
      ProviderClients.geminiTurn('system', turn, []),
      throwsA(
        isA<GeminiFailure>().having((e) => e.code, 'code', 'ai_input_too_large'),
      ),
    );
    expect(generate, 0);
  });
}
