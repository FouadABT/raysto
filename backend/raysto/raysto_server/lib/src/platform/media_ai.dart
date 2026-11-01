part of 'platform.dart';

/// Photo generators for menu dishes: Gemini or OpenAI, chosen by the owner.
/// Only the dish's own text is sent. The returned image then goes through
/// the same quarantine, virus scan and re-encode as any upload.
class ImageProviders {
  static const providers = {'gemini', 'openai'};
  static const maxBytes = 12582912;

  static String label(String provider) =>
      provider == 'gemini' ? 'Gemini' : 'OpenAI';

  static String model(String provider) {
    final env = ProviderClients.environment();
    return provider == 'gemini'
        ? (env['GEMINI_IMAGE_MODEL'] ?? 'gemini-3.1-flash-image')
        : (env['OPENAI_IMAGE_MODEL'] ?? 'gpt-image-1');
  }

  static String _key(String provider) =>
      (ProviderClients.environment()[provider == 'gemini'
                  ? 'GEMINI_API_KEY'
                  : 'OPENAI_API_KEY'] ??
              '')
          .trim();

  static bool configured(String provider) => _key(provider).isNotEmpty;

  /// One image's price in micros, from configuration.
  static int price(String provider) {
    final usd = double.tryParse(
      ProviderClients.environment()[provider == 'gemini'
              ? 'RAYSTO_AI_IMAGE_USD_GEMINI'
              : 'RAYSTO_AI_IMAGE_USD_OPENAI'] ??
          '',
    );
    return ((usd ?? (provider == 'gemini' ? 0.04 : 0.05)) * 1000000).round();
  }

  /// One photo for [prompt]. Never retried once sent: a second request
  /// would be a second charge.
  static Future<({Uint8List bytes, String mime})> generate(
    String provider,
    String prompt,
  ) async {
    if (!configured(provider)) {
      _fail('unavailable', '${label(provider)} images are not set up yet.');
    }
    final client = ProviderClients.httpClient();
    try {
      final request = provider == 'gemini'
          ? (http.Request(
              'POST',
              Uri.https(
                'generativelanguage.googleapis.com',
                '/v1beta/models/${model(provider)}:generateContent',
              ),
            )..headers['x-goog-api-key'] = _key(provider))
          : (http.Request(
              'POST',
              Uri.https('api.openai.com', '/v1/images/generations'),
            )..headers['authorization'] = 'Bearer ${_key(provider)}');
      request
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode(
          provider == 'gemini'
              ? {
                  'contents': [
                    {
                      'role': 'user',
                      'parts': [
                        {'text': prompt},
                      ],
                    },
                  ],
                  'generationConfig': {
                    'responseModalities': ['IMAGE'],
                    'imageConfig': {'aspectRatio': '4:3'},
                  },
                }
              : {
                  'model': model(provider),
                  'prompt': prompt,
                  'n': 1,
                  'size': '1536x1024',
                  'quality': 'medium',
                  'output_format': 'jpeg',
                },
        );
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 120));
      final body = await ProviderClients.bounded(response, maxBytes: maxBytes);
      if (response.statusCode == 429) {
        _fail(
          'ai_capacity',
          '${label(provider)} images are busy or out of quota. Try later.',
        );
      }
      if (response.statusCode != 200) {
        _fail(
          'ai_unavailable',
          '${label(provider)} did not return a photo (HTTP ${response.statusCode}).',
        );
      }
      final json = _object(jsonDecode(utf8.decode(body)));
      String? data;
      var mime = 'image/jpeg';
      if (provider == 'gemini') {
        for (final c in (json['candidates'] as List? ?? const [])) {
          for (final p
              in (_object(_object(c)['content'])['parts'] as List? ??
                  const [])) {
            final inline = _object(p)['inlineData'];
            if (inline is Map && inline['data'] is String) {
              data = inline['data'] as String;
              mime = '${inline['mimeType'] ?? 'image/png'}';
            }
          }
        }
      } else {
        final first = (json['data'] as List? ?? const []).firstOrNull;
        data = first is Map ? first['b64_json'] as String? : null;
      }
      if (data == null) {
        _fail(
          'ai_unavailable',
          '${label(provider)} declined to draw this dish. Try the other provider.',
        );
      }
      final bytes = base64Decode(data);
      if (!{'image/jpeg', 'image/png', 'image/webp'}.contains(mime) ||
          bytes.length < 1000) {
        _fail('ai_unavailable', '${label(provider)} returned no usable photo.');
      }
      return (bytes: bytes, mime: mime);
    } on TimeoutException {
      _fail(
        'ai_timeout',
        '${label(provider)} took too long to draw the photo.',
      );
    } finally {
      client.close();
    }
  }
}
