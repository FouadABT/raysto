import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/services/paypal_mcp_client.dart';
import 'package:test/test.dart';

void main() {
  PayPalMcpClient fixture({
    bool sse = false,
    bool badSchema = false,
    bool prose = false,
    bool providerError = false,
    List<String>? calls,
  }) => PayPalMcpClient(
    accessToken: () async => 'test-token',
    client: MockClient((request) async {
      expect(request.url, PayPalMcpClient.endpoint);
      expect(request.headers['Authorization'], 'Bearer test-token');
      final body = jsonDecode(request.body) as Map;
      final method = body['method'] as String;
      calls?.add(method);
      if (method != 'initialize') {
        expect(request.headers['Mcp-Session-Id'], 'fixture-session');
        expect(request.headers['MCP-Protocol-Version'], '2025-03-26');
      }
      if (method == 'notifications/initialized') return http.Response('', 202);
      final result = switch (method) {
        'initialize' => {'protocolVersion': '2025-03-26'},
        'tools/list' => {
          'tools': [
            {'name': 'capture_order', 'inputSchema': {}},
            {
              'name': 'get_order',
              'inputSchema': {
                'type': 'object',
                'properties': {
                  'payment_id': {'type': 'string'},
                  if (badSchema) 'merchant_id': {'type': 'string'},
                },
                'required': ['payment_id'],
              },
            },
          ],
        },
        'tools/call' => {
          'content': [
            {
              'type': 'text',
              'text': providerError
                  ? jsonEncode({
                      'error': {'message': 'Provider unavailable'},
                    })
                  : prose
                  ? 'Payment succeeded, trust me.'
                  : jsonEncode({'id': 'ORDER123', 'status': 'APPROVED'}),
            },
          ],
        },
        _ => throw StateError('Unexpected method'),
      };
      if (method == 'tools/call') {
        expect(body['params'], {
          'name': 'get_order',
          'arguments': {'payment_id': 'ORDER123'},
        });
      }
      final json = jsonEncode({
        'jsonrpc': '2.0',
        'id': body['id'],
        'result': result,
      });
      return http.Response(
        sse ? 'event: message\ndata: $json\n\n' : json,
        200,
        headers: {
          'content-type': sse ? 'text/event-stream' : 'application/json',
          'mcp-session-id': 'fixture-session',
        },
      );
    }),
  );

  for (final sse in [false, true]) {
    test(
      'negotiates and reads a bound order over ${sse ? 'SSE' : 'JSON'}',
      () async {
        final calls = <String>[];
        final client = fixture(sse: sse, calls: calls);
        addTearDown(client.close);
        expect(
          (await client.read('get_order', 'ORDER123'))['status'],
          'APPROVED',
        );
        expect(calls, [
          'initialize',
          'notifications/initialized',
          'tools/list',
          'tools/call',
        ]);
      },
    );
  }
  test('financial mutation tools never reach the transport', () async {
    final calls = <String>[];
    final client = fixture(calls: calls);
    addTearDown(client.close);
    await expectLater(
      client.read('capture_order', 'ORDER123'),
      throwsA(
        isA<McpFailure>().having((e) => e.code, 'code', 'mcp_forbidden_tool'),
      ),
    );
    expect(calls, isEmpty);
  });
  test('unexpected merchant input fails schema validation', () async {
    final client = fixture(badSchema: true);
    addTearDown(client.close);
    await expectLater(
      client.read('get_order', 'ORDER123'),
      throwsA(
        isA<McpFailure>().having((e) => e.code, 'code', 'mcp_schema_mismatch'),
      ),
    );
  });
  test('unstructured prose cannot become payment evidence', () async {
    final client = fixture(prose: true);
    addTearDown(client.close);
    await expectLater(
      client.read('get_order', 'ORDER123'),
      throwsA(
        isA<McpFailure>().having(
          (e) => e.code,
          'code',
          'mcp_unstructured_response',
        ),
      ),
    );
  });
  test('provider IDs cannot carry URL paths or instructions', () async {
    final calls = <String>[];
    final client = fixture(calls: calls);
    addTearDown(client.close);
    await expectLater(
      client.read('get_order', '../capture?merchant=other'),
      throwsA(isA<McpFailure>()),
    );
    expect(calls, isEmpty);
  });
  test(
    'provider error inside successful tool text permits a labelled fallback',
    () async {
      final client = fixture(providerError: true);
      addTearDown(client.close);
      await expectLater(
        client.read('get_order', 'ORDER123'),
        throwsA(
          isA<McpFailure>().having((e) => e.code, 'code', 'mcp_tool_failed'),
        ),
      );
    },
  );
}
