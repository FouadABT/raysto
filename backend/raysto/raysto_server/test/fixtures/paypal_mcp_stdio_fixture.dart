// Local protocol fixture, not a provider simulator or payment evidence.
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.join('|') !=
          '--tools=orders.get,payments.getRefunds|--paypal-environment=sandbox' ||
      Platform.environment['PAYPAL_ACCESS_TOKEN'] != 'fixture-token' ||
      Platform.environment['PAYPAL_ENVIRONMENT'] != 'SANDBOX' ||
      Platform.environment.containsKey('PATH') ||
      Platform.environment.containsKey('USERPROFILE')) {
    exit(10);
  }
  await for (final line
      in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
    final request = jsonDecode(line) as Map;
    if (!request.containsKey('id')) continue;
    final method = request['method'];
    final params = request['params'] as Map;
    Object result;
    if (method == 'initialize') {
      result = {'protocolVersion': '2025-03-26'};
    } else if (method == 'tools/list') {
      result = {
        'tools': [
          for (final entry in {
            'get_order': 'id',
            'get_refund': 'refund_id',
          }.entries)
            {
              'name': entry.key,
              'inputSchema': {
                'type': 'object',
                'properties': {
                  entry.value: {'type': 'string'},
                },
                'required': [entry.value],
              },
            },
        ],
      };
    } else {
      final id = (params['arguments'] as Map).values.single;
      if (id == 'EXIT') exit(9);
      if (id == 'HANG') await Future<void>.delayed(const Duration(seconds: 40));
      if (id == 'MALFORMED') {
        stdout.writeln('unexpected provider prose');
        continue;
      }
      if (id == 'WRONGID') {
        stdout.writeln(
          jsonEncode({'jsonrpc': '2.0', 'id': 'other', 'result': {}}),
        );
        continue;
      }
      if (id == 'OVERFLOW') {
        stdout.writeln('x' * 1048577);
        continue;
      }
      result = {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({'id': id, 'status': 'PAYER_ACTION_REQUIRED'}),
          },
        ],
      };
    }
    // Notifications must not be confused with the response to our request.
    stdout.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'method': 'notifications/message',
        'params': {},
      }),
    );
    stdout.writeln(
      jsonEncode({'jsonrpc': '2.0', 'id': request['id'], 'result': result}),
    );
  }
}
