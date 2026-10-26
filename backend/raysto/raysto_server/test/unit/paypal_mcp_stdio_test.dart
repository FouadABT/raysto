import 'dart:io';
import 'package:raysto_server/src/services/paypal_mcp_client.dart';
import 'package:test/test.dart';

void main() {
  PayPalMcpClient fixture() {
    final client = PayPalMcpClient.stdio(
      accessToken: () async => 'fixture-token',
      executable: Platform.resolvedExecutable,
      script: File('test/fixtures/paypal_mcp_stdio_fixture.dart').absolute.path,
    );
    addTearDown(client.close);
    return client;
  }

  for (final tool in ['get_order', 'get_refund']) {
    test(
      'stdio negotiates $tool with restricted arguments and environment',
      () async {
        final client = fixture();
        final response = await client.read(tool, 'ORDER123');
        expect(client.transport, 'stdio');
        expect(response, {'id': 'ORDER123', 'status': 'PAYER_ACTION_REQUIRED'});
      },
    );
  }
  for (final entry in {
    'EXIT': 'mcp_process_exited',
    'MALFORMED': 'mcp_invalid_response',
    'WRONGID': 'mcp_invalid_response',
    'OVERFLOW': 'mcp_response_limit',
    'HANG': 'mcp_deadline',
  }.entries) {
    test('stdio rejects ${entry.key} and closes its subprocess', () async {
      final client = fixture();
      await expectLater(
        client.read('get_order', entry.key),
        throwsA(
          isA<McpFailure>().having((e) => e.code, 'code', entry.value),
        ),
      );
      await expectLater(
        client.read('get_order', 'ORDER123'),
        throwsA(isA<McpFailure>()),
      );
    });
  }
  test(
    'mutation is rejected before fetching credentials or spawning a process',
    () async {
      var tokenCalls = 0;
      final client = PayPalMcpClient.stdio(
        accessToken: () async {
          tokenCalls++;
          return 'fixture-token';
        },
        executable: 'must-not-run',
        script: 'must-not-run',
      );
      addTearDown(client.close);
      await expectLater(
        client.read('capture_order', 'ORDER123'),
        throwsA(isA<McpFailure>()),
      );
      expect(tokenCalls, 0);
    },
  );
  test(
    'invalid transport or relative executable configuration fails closed',
    () {
      for (final environment in [
        {'RAYSTO_PAYPAL_MCP_TRANSPORT': 'unknown'},
        {
          'RAYSTO_PAYPAL_MCP_TRANSPORT': 'stdio',
          'RAYSTO_PAYPAL_MCP_NODE': 'node',
        },
      ]) {
        expect(
          () => PayPalMcpClient.configured(
            environment,
            accessToken: () async => '',
          ),
          throwsA(
            isA<McpFailure>().having(
              (e) => e.code,
              'code',
              'mcp_configuration_invalid',
            ),
          ),
        );
      }
    },
  );
}
