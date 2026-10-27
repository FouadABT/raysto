import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Sanitized diagnostics only. Never retain provider bodies, prompts or tokens.
class GeminiFailure implements Exception {
  const GeminiFailure(this.code, this.stage, {this.httpStatus});
  final String code;
  final String stage;
  final int? httpStatus;
  bool get retryable =>
      {'ai_timeout', 'ai_capacity', 'ai_unavailable'}.contains(code);
  String get message => switch (code) {
    'ai_timeout' =>
      'Raysto could not finish in time. No order or payment was made. You can try again.',
    'ai_capacity' =>
      'Raysto’s AI provider is busy. Try again shortly, or continue with Menu and Bill.',
    'ai_configuration' =>
      'Raysto’s AI connection needs attention. You can still use Menu, Order and Bill.',
    'ai_input_too_large' =>
      'Narrow the conversation or menu search and try again.',
    _ =>
      'Raysto’s AI is temporarily unavailable. No order or payment was made.',
  };
  @override
  String toString() => 'GeminiFailure($code, $stage, $httpStatus)';
}

class GeminiTransport {
  static const maxBytes = 2097152;
  static Future<Map<String, dynamic>> post(
    http.Client client,
    Uri uri,
    Map<String, dynamic> body, {
    required String stage,
    required Duration timeout,
    Map<String, String> headers = const {},
    bool streaming = false,
  }) async {
    if (timeout <= Duration.zero) throw GeminiFailure('ai_timeout', stage);
    try {
      return await (() async {
        final response = await client.send(
          http.Request('POST', uri)
            ..followRedirects = false
            ..headers.addAll({'Content-Type': 'application/json', ...headers})
            ..body = jsonEncode(body),
        );
        // Do not buffer error bodies: they may echo private document text.
        if (response.statusCode < 200 || response.statusCode >= 300) {
          await response.stream.listen((_) {}).cancel();
          final code = switch (response.statusCode) {
            408 || 504 => 'ai_timeout',
            429 || 503 => 'ai_capacity',
            400 || 401 || 403 || 404 => 'ai_configuration',
            _ => 'ai_unavailable',
          };
          throw GeminiFailure(code, stage, httpStatus: response.statusCode);
        }
        if ((response.contentLength ?? 0) > maxBytes) {
          await response.stream.listen((_) {}).cancel();
          throw GeminiFailure('ai_response_invalid', stage);
        }
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response.stream.timeout(timeout)) {
          if (bytes.length + chunk.length > maxBytes) {
            throw GeminiFailure('ai_response_invalid', stage);
          }
          bytes.add(chunk);
        }
        final text = utf8.decode(bytes.takeBytes());
        if (streaming) return assemble(text, stage);
        final decoded = jsonDecode(text);
        if (decoded is! Map<String, dynamic>) {
          throw GeminiFailure('ai_response_invalid', stage);
        }
        return decoded;
      })().timeout(timeout);
    } on GeminiFailure {
      rethrow;
    } on TimeoutException {
      throw GeminiFailure('ai_timeout', stage);
    } on FormatException {
      throw GeminiFailure('ai_response_invalid', stage);
    } on http.ClientException {
      throw GeminiFailure('ai_unavailable', stage);
    }
  }

  /// Buffer bounded SSE until STOP. Partial tool calls must never execute.
  /// Keep each provider part/signature intact for the next function-call round.
  static Map<String, dynamic> assemble(String input, String stage) {
    final parts = <Map<String, dynamic>>[];
    Map<String, dynamic>? usage;
    String? finish;
    for (final frame in input.replaceAll('\r\n', '\n').split('\n\n')) {
      final data = frame
          .split('\n')
          .where((l) => l.startsWith('data:'))
          .map((l) => l.substring(5).trimLeft())
          .join('\n');
      if (data.isEmpty || data == '[DONE]') continue;
      final value = jsonDecode(data);
      if (value is! Map<String, dynamic> || value['error'] != null) {
        throw GeminiFailure('ai_response_invalid', stage);
      }
      if (value['usageMetadata'] is Map<String, dynamic>) {
        usage = value['usageMetadata'] as Map<String, dynamic>;
      }
      for (final candidate in value['candidates'] as List? ?? []) {
        if (candidate is! Map || (candidate['index'] ?? 0) != 0) {
          throw GeminiFailure('ai_response_invalid', stage);
        }
        final content = candidate['content'];
        if (content is Map) {
          for (final part in content['parts'] as List? ?? []) {
            if (part is! Map<String, dynamic>) {
              throw GeminiFailure('ai_response_invalid', stage);
            }
            parts.add(part);
          }
        }
        if (candidate['finishReason'] is String) {
          finish = candidate['finishReason'];
        }
      }
    }
    if (finish != 'STOP' || parts.isEmpty) {
      throw GeminiFailure('ai_response_incomplete', stage);
    }
    return {
      'candidates': [
        {
          'content': {'role': 'model', 'parts': parts},
          'finishReason': finish,
        },
      ],
      'usageMetadata': ?usage,
    };
  }
}
