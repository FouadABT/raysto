import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A deliberately read-only MCP client. It never exposes the provider's tool
/// catalogue or credentials to the language model or accepts a caller's host.
class PayPalMcpClient {
  PayPalMcpClient({required this.accessToken, http.Client? client})
    : _client = client ?? http.Client();
  final Future<String> Function() accessToken;
  final http.Client _client;
  String? _session;
  String? _bearer;
  String _protocol = '2025-03-26';
  int _counter = 0;
  final Map<String, Map<String, dynamic>> _schemas = {};
  static final endpoint = Uri.parse('https://mcp.sandbox.paypal.com/http');
  static const allowed = {'get_order', 'get_refund'};

  void close() => _client.close();

  Future<Map<String, dynamic>> _rpc(
    String method,
    Map<String, dynamic> params, {
    bool notification = false,
  }) async {
    final id = '${++_counter}';
    final request = http.Request('POST', endpoint)
      ..followRedirects = false
      ..headers.addAll({
        'Authorization': 'Bearer ${_bearer ??= await accessToken()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json, text/event-stream',
        if (method != 'initialize') 'MCP-Protocol-Version': _protocol,
        'Mcp-Session-Id': ?_session,
      })
      ..body = jsonEncode({
        'jsonrpc': '2.0',
        if (!notification) 'id': id,
        'method': method,
        'params': params,
      });
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
    if (envelope == null ||
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
            : {'payment_id', 'order_id'};
        if (keys.length != 1 ||
            !expected.contains(keys.single) ||
            (schema['properties'] as Map)[keys.single]['type'] != 'string' ||
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
      return Map<String, dynamic>.from(result['structuredContent'] as Map);
    }
    for (final block in (result['content'] as List? ?? []).whereType<Map>()) {
      if (block['type'] != 'text' || block['text'] is! String) continue;
      try {
        final value = jsonDecode(block['text'] as String);
        if (value is Map<String, dynamic>) return value;
      } on FormatException {
        /* Plain prose is not financial evidence. */
      }
    }
    throw const McpFailure('mcp_unstructured_response');
  }
}

class McpFailure implements Exception {
  const McpFailure(this.code);
  final String code;
  @override
  String toString() => code;
}
