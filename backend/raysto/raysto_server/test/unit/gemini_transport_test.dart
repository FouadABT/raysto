import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/services/gemini_transport.dart';
import 'package:test/test.dart';

void main() {
  final uri = Uri.https('fixture.invalid', '/generateContent');
  Future<Map<String, dynamic>> request(
    http.Client client, {
    Duration timeout = const Duration(seconds: 1),
  }) => GeminiTransport.post(
    client,
    uri,
    {'contents': []},
    stage: 'generate',
    timeout: timeout,
  );
  test(
    'busy provider is retryable, sanitized and never automatically retried',
    () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return http.Response('private prompt and token', 503);
      });
      await expectLater(
        request(client),
        throwsA(
          isA<GeminiFailure>()
              .having((e) => e.httpStatus, 'HTTP status', 503)
              .having((e) => e.retryable, 'retryable', true)
              .having(
                (e) => e.toString(),
                'safe diagnostic',
                isNot(contains('private')),
              ),
        ),
      );
      expect(calls, 1);
    },
  );
  test(
    'configuration failure does not invite repeated paid attempts',
    () async {
      await expectLater(
        request(MockClient((_) async => http.Response('secret', 403))),
        throwsA(
          isA<GeminiFailure>().having((e) => e.retryable, 'retryable', false),
        ),
      );
    },
  );
  test('missing response is bounded by the request deadline', () async {
    final pending = Completer<http.Response>();
    final result = request(
      MockClient((_) => pending.future),
      timeout: const Duration(milliseconds: 15),
    );
    await expectLater(
      result,
      throwsA(
        isA<GeminiFailure>()
            .having((e) => e.code, 'code', 'ai_timeout')
            .having((e) => e.stage, 'stage', 'generate'),
      ),
    );
    pending.complete(http.Response('{}', 200));
  });
  test(
    'malformed and oversized responses fail without exposing their body',
    () async {
      for (final body in [
        'not JSON',
        '[]',
        'x' * (GeminiTransport.maxBytes + 1),
      ]) {
        await expectLater(
          request(MockClient((_) async => http.Response(body, 200))),
          throwsA(
            isA<GeminiFailure>().having(
              (e) => e.code,
              'code',
              'ai_response_invalid',
            ),
          ),
        );
      }
    },
  );
  test('stream keeps tool arguments and signatures with final usage', () async {
    final first = {
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {
                'functionCall': {
                  'name': 'payment_status',
                  'args': {'checkoutId': 2},
                },
                'thoughtSignature': 'opaque-signature',
              },
            ],
          },
        },
      ],
    };
    final last = {
      'candidates': [
        {'finishReason': 'STOP'},
      ],
      'usageMetadata': {
        'promptTokenCount': 20,
        'candidatesTokenCount': 15,
        'thoughtsTokenCount': 7,
      },
    };
    final wire =
        'data: ${jsonEncode(first)}\r\n\r\ndata: ${jsonEncode(last)}\r\n\r\n';
    final result = await GeminiTransport.post(
      MockClient((_) async => http.Response(wire, 200)),
      uri,
      {},
      stage: 'generate',
      timeout: const Duration(seconds: 1),
      streaming: true,
    );
    expect(
      result['candidates'][0]['content']['parts'][0]['thoughtSignature'],
      'opaque-signature',
    );
    expect(
      result['candidates'][0]['content']['parts'][0]['functionCall']['args']['checkoutId'],
      2,
    );
    expect(result['usageMetadata']['thoughtsTokenCount'], 7);
  });
  test(
    'interrupted or output-limited stream cannot release a partial tool call',
    () async {
      for (final finish in [null, 'MAX_TOKENS']) {
        final wire =
            'data: ${jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'functionCall': {
                          'name': 'payment_status',
                          'args': {'checkoutId': 2},
                        },
                      },
                    ],
                  },
                  'finishReason': ?finish,
                },
              ],
            })}\n\n';
        await expectLater(
          GeminiTransport.post(
            MockClient((_) async => http.Response(wire, 200)),
            uri,
            {},
            stage: 'generate',
            timeout: const Duration(seconds: 1),
            streaming: true,
          ),
          throwsA(
            isA<GeminiFailure>().having(
              (e) => e.code,
              'code',
              'ai_response_incomplete',
            ),
          ),
        );
      }
    },
  );
  test(
    'real response metadata remains available for budget reconciliation',
    () async {
      final result = await request(
        MockClient(
          (_) async => http.Response(
            '{"usageMetadata":{"promptTokenCount":20,"candidatesTokenCount":4}}',
            200,
          ),
        ),
      );
      expect(result['usageMetadata']['candidatesTokenCount'], 4);
    },
  );
}
