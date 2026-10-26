import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// A deliberately read-only MCP client. It never exposes the provider's tool
/// catalogue or credentials to the language model or accepts a caller's host.
class PayPalMcpClient {
  PayPalMcpClient({required this.accessToken, http.Client? client})
    : _client = client ?? http.Client(),
      _stdio = null;

  /// Executable paths come only from deployment configuration, never a tool.
  /// The official server receives a short-lived token through its environment.
  PayPalMcpClient.stdio({
    required this.accessToken,
    required String executable,
    required String script,
  }) : _client = http.Client(),
       _stdio = _PayPalStdio(executable, script);

  factory PayPalMcpClient.configured(
    Map<String, String> environment, {
    required Future<String> Function() accessToken,
  }) {
    switch (environment['RAYSTO_PAYPAL_MCP_TRANSPORT'] ?? 'http') {
      case 'http':
        return PayPalMcpClient(accessToken: accessToken);
      case 'stdio':
        final executable = environment['RAYSTO_PAYPAL_MCP_NODE'] ?? '';
        final script = environment['RAYSTO_PAYPAL_MCP_SCRIPT'] ?? '';
        if (!File(executable).isAbsolute || !File(script).isAbsolute) {
          throw const McpFailure('mcp_configuration_invalid');
        }
        return PayPalMcpClient.stdio(
          accessToken: accessToken,
          executable: executable,
          script: script,
        );
      default:
        throw const McpFailure('mcp_configuration_invalid');
    }
  }
  final Future<String> Function() accessToken;
  final http.Client _client;
  final _PayPalStdio? _stdio;
  bool _closed = false;
  String get transport => _stdio == null ? 'streamable_http' : 'stdio';
  String? _session;
  String? _bearer;
  String _protocol = '2025-03-26';
  int _counter = 0;
  final Map<String, Map<String, dynamic>> _schemas = {};
  static final endpoint = Uri.parse('https://mcp.sandbox.paypal.com/http');
  static const allowed = {'get_order', 'get_refund'};

  void close() {
    _closed = true;
    _client.close();
    _stdio?.close();
  }

  Future<Map<String, dynamic>> _rpc(
    String method,
    Map<String, dynamic> params, {
    bool notification = false,
  }) async {
    final id = '${++_counter}';
    final body = {
      'jsonrpc': '2.0',
      if (!notification) 'id': id,
      'method': method,
      'params': params,
    };
    final bearer = _bearer ??= await accessToken();
    if (_closed) throw const McpFailure('mcp_closed');
    if (_stdio != null) {
      final envelope = await _stdio.request(body, bearer);
      return notification ? {} : _result(envelope, id);
    }
    final request = http.Request('POST', endpoint)
      ..followRedirects = false
      ..headers.addAll({
        'Authorization': 'Bearer $bearer',
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        if (method != 'initialize') 'MCP-Protocol-Version': _protocol,
        'Mcp-Session-Id': ?_session,
      })
      ..body = jsonEncode(body);
    final response = await _client
        .send(request)
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.stream.listen(null).cancel();
      throw McpFailure(
        'mcp_${method.replaceAll('/', '_')}_http_${response.statusCode}',
      );
    }
    if (method == 'initialize') _session = response.headers['mcp-session-id'];
    if (notification) {
      await response.stream.listen(null).cancel();
      return {};
    }
    var size = 0;
    final bounded = response.stream
        .map((bytes) {
          size += bytes.length;
          if (size > 1048576) throw const McpFailure('mcp_response_limit');
          return bytes;
        })
        .timeout(const Duration(seconds: 8));
    Map<String, dynamic>? envelope;
    if (response.headers['content-type']?.contains('text/event-stream') ==
        true) {
      final data = <String>[];
      await for (final line
          in bounded.transform(utf8.decoder).transform(const LineSplitter())) {
        if (line.startsWith('data:')) data.add(line.substring(5).trimLeft());
        if (line.isEmpty && data.isNotEmpty) {
          final value = jsonDecode(data.join('\n'));
          data.clear();
          if (value is Map<String, dynamic> && '${value['id']}' == id) {
            envelope = value;
            break;
          }
        }
      }
    } else {
      final value = jsonDecode(await bounded.transform(utf8.decoder).join());
      if (value is Map<String, dynamic> && '${value['id']}' == id) {
        envelope = value;
      }
    }
    return _result(envelope, id);
  }

  Map<String, dynamic> _result(Map<String, dynamic>? envelope, String id) {
    if (envelope == null ||
        envelope['jsonrpc'] != '2.0' ||
        '${envelope['id']}' != id ||
        envelope['error'] != null ||
        envelope['result'] is! Map) {
      throw const McpFailure('mcp_invalid_response');
    }
    return Map<String, dynamic>.from(envelope['result'] as Map);
  }

  Future<void> initialize() async {
    final result = await _rpc('initialize', {
      'protocolVersion': _protocol,
      'capabilities': <String, dynamic>{},
      'clientInfo': {'name': 'raysto-payment-reader', 'version': '1.0.0'},
    });
    final protocol = result['protocolVersion'];
    if (!{'2024-11-05', '2025-03-26', '2025-06-18'}.contains(protocol)) {
      throw const McpFailure('mcp_protocol_mismatch');
    }
    _protocol = protocol as String;
    await _rpc('notifications/initialized', {}, notification: true);
    String? cursor;
    for (var page = 0; page < 5; page++) {
      final result = await _rpc('tools/list', {
        'cursor': ?cursor,
      });
      final tools = result['tools'];
      if (tools is! List) throw const McpFailure('mcp_schema_mismatch');
      for (final tool in tools.whereType<Map>()) {
        final name = tool['name'];
        if (!allowed.contains(name)) continue;
        final schema = tool['inputSchema'];
        if (schema is! Map ||
            schema['type'] != 'object' ||
            schema['properties'] is! Map) {
          throw const McpFailure('mcp_schema_mismatch');
        }
        final keys = (schema['properties'] as Map).keys.toSet();
        final expected = name == 'get_refund'
            ? {'refund_id'}
            : _stdio != null
            ? {'id'} // Official pinned @paypal/agent-toolkit schema.
            : {'payment_id', 'order_id'};
        final field = keys.length == 1
            ? (schema['properties'] as Map)[keys.single]
            : null;
        if (keys.length != 1 ||
            !expected.contains(keys.single) ||
            field is! Map ||
            field['type'] != 'string' ||
            schema['required'] is! List ||
            (schema['required'] as List).length != 1 ||
            (schema['required'] as List).single != keys.single) {
          throw const McpFailure('mcp_schema_mismatch');
        }
        _schemas[name as String] = Map<String, dynamic>.from(schema);
      }
      cursor = result['nextCursor'] as String?;
      if (cursor == null) break;
    }
  }

  Future<Map<String, dynamic>> read(String tool, String providerId) async {
    return _read(tool, providerId).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        close();
        throw const McpFailure('mcp_deadline');
      },
    );
  }

  Future<Map<String, dynamic>> _read(String tool, String providerId) async {
    if (!allowed.contains(tool) ||
        !RegExp(r'^[A-Za-z0-9_-]{1,100}$').hasMatch(providerId)) {
      throw const McpFailure('mcp_forbidden_tool');
    }
    if (_schemas.isEmpty) await initialize();
    final schema = _schemas[tool];
    if (schema == null) throw const McpFailure('mcp_schema_mismatch');
    final key = (schema['properties'] as Map).keys.single as String;
    final result = await _rpc('tools/call', {
      'name': tool,
      'arguments': {key: providerId},
    });
    if (result['isError'] == true) throw const McpFailure('mcp_tool_failed');
    if (result['structuredContent'] is Map) {
      return _evidence(
        Map<String, dynamic>.from(result['structuredContent'] as Map),
      );
    }
    for (final block in (result['content'] as List? ?? []).whereType<Map>()) {
      if (block['type'] != 'text' || block['text'] is! String) continue;
      try {
        final value = jsonDecode(block['text'] as String);
        if (value is Map<String, dynamic>) return _evidence(value);
      } on FormatException {
        /* Plain prose is not financial evidence. */
      }
    }
    throw const McpFailure('mcp_unstructured_response');
  }

  Map<String, dynamic> _evidence(Map<String, dynamic> value) {
    // The official toolkit may encode a provider error as successful MCP text.
    if (value.containsKey('error') ||
        value['id'] is! String ||
        value['status'] is! String) {
      throw const McpFailure('mcp_tool_failed');
    }
    return value;
  }
}

/// One bounded, shell-free subprocess per reader. It exposes only two tools,
/// inherits no application secrets, and is never reachable over a network port.
class _PayPalStdio {
  _PayPalStdio(this.executable, this.script);
  final String executable;
  final String script;
  Process? _process;
  bool _closed = false;
  bool _exited = false;
  int _stdoutBytes = 0;
  int _stderrBytes = 0;
  final _pending = <String, Completer<Map<String, dynamic>>>{};

  Future<void> _start(String token) async {
    if (_closed) throw const McpFailure('mcp_closed');
    if (_process != null) return;
    try {
      final process = await Process.start(
        executable,
        [
          script,
          '--tools=orders.get,payments.getRefunds',
          '--paypal-environment=sandbox',
        ],
        includeParentEnvironment: false,
        environment: {
          'PAYPAL_ACCESS_TOKEN': token,
          'PAYPAL_ENVIRONMENT': 'SANDBOX',
          'NODE_OPTIONS': '--max-old-space-size=128',
          'NO_COLOR': '1',
          if (Platform.isWindows && Platform.environment['SystemRoot'] != null)
            'SystemRoot': Platform.environment['SystemRoot']!,
        },
      );
      _process = process;
      unawaited(
        process.stdin.done.then<void>(
          (_) {},
          onError: (Object _) {
            _abort(const McpFailure('mcp_process_failed'));
          },
        ),
      );
      if (_closed) {
        process.kill(ProcessSignal.sigkill);
        throw const McpFailure('mcp_closed');
      }
      process.stdout
          .map((chunk) {
            _stdoutBytes += chunk.length;
            if (_stdoutBytes > 1048576) {
              throw const McpFailure('mcp_response_limit');
            }
            return chunk;
          })
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _receive,
            onError: (Object error) => _abort(
              error is McpFailure
                  ? error
                  : const McpFailure('mcp_invalid_response'),
            ),
            cancelOnError: true,
          );
      // Never copy provider stderr into application logs: it can contain data.
      process.stderr.listen((chunk) {
        _stderrBytes += chunk.length;
        if (_stderrBytes > 65536) _abort(const McpFailure('mcp_stderr_limit'));
      }, onError: (Object _) => _abort(const McpFailure('mcp_process_failed')));
      unawaited(
        process.exitCode.then((_) {
          _exited = true;
          _abort(const McpFailure('mcp_process_exited'));
        }),
      );
    } on McpFailure {
      rethrow;
    } catch (_) {
      throw const McpFailure('mcp_process_start_failed');
    }
  }

  void _receive(String line) {
    if (_closed) return;
    try {
      final value = jsonDecode(line);
      if (value is! Map<String, dynamic> || value['jsonrpc'] != '2.0') {
        throw const McpFailure('mcp_invalid_response');
      }
      if (!value.containsKey('id') && value['method'] is String) return;
      final waiting = _pending.remove('${value['id']}');
      if (waiting == null) throw const McpFailure('mcp_invalid_response');
      waiting.complete(value);
    } catch (_) {
      _abort(const McpFailure('mcp_invalid_response'));
    }
  }

  Future<Map<String, dynamic>> request(
    Map<String, dynamic> body,
    String token,
  ) async {
    await _start(token);
    if (_closed) throw const McpFailure('mcp_closed');
    final id = body['id'] as String?;
    final pending = id == null ? null : Completer<Map<String, dynamic>>();
    if (id != null) _pending[id] = pending!;
    try {
      _process!.stdin.writeln(jsonEncode(body));
    } catch (_) {
      _abort(const McpFailure('mcp_process_failed'));
    }
    return pending == null ? {} : pending.future;
  }

  void _abort(McpFailure failure) {
    if (_closed) return;
    _closed = true;
    for (final waiting in _pending.values) {
      waiting.completeError(failure);
    }
    _pending.clear();
    final process = _process;
    if (process != null && !_exited) {
      process.kill();
      Timer(const Duration(seconds: 1), () {
        if (!_exited) process.kill(ProcessSignal.sigkill);
      });
    }
  }

  void close() => _abort(const McpFailure('mcp_closed'));
}

class McpFailure implements Exception {
  const McpFailure(this.code);
  final String code;
  @override
  String toString() => code;
}
