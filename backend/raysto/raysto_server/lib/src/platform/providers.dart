part of 'platform.dart';

/// Fixed-host transports. Response bodies and credentials never enter client errors.
class ProviderClients {
  // Only used after PlatformApi.guard has cryptographically verified this proof.
  static int identityAuthTime(Session s) {
    final token = PlatformApi.requestHeader(s, 'x-raysto-firebase-token');
    if (token == null) {
      _fail('firebase_proof_required', 'A current Firebase proof is required.');
    }
    final claims = _json(
      utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))),
    );
    return _int(claims, 'auth_time', min: 1, max: 9007199254740991);
  }

  static bool singleRestaurant(int tenant) =>
      paypalEnvironment == 'sandbox' &&
      Platform.environment['RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED'] ==
          'true' &&
      int.tryParse(
            Platform.environment['RAYSTO_SANDBOX_RESTAURANT_ID'] ?? '',
          ) ==
          tenant;

  static Future<String> paypalReadToken() async {
    if (paypalEnvironment != 'sandbox' ||
        Platform.environment['RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED'] !=
            'true') {
      _fail('not_configured', 'Sandbox merchant reads are not enabled.');
    }
    final client = http.Client();
    try {
      final id = required('PAYPAL_SANDBOX_CLIENT_ID');
      final secret = required('PAYPAL_SANDBOX_CLIENT_SECRET');
      final token = await sendJson(
        client,
        http.Request('POST', Uri.https(paypalHost, '/v1/oauth2/token'))
          ..followRedirects = false
          ..headers.addAll({
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$id:$secret'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          })
          ..body = 'grant_type=client_credentials',
      );
      return _str(token, 'access_token', max: 16000);
    } finally {
      client.close();
    }
  }

  static String required(String key) =>
      Platform.environment[key]?.trim().isNotEmpty == true
      ? Platform.environment[key]!.trim()
      : _fail('not_configured', 'Missing server configuration: $key.');
  static String get paypalEnvironment =>
      Platform.environment['RAYSTO_PAYPAL_ENVIRONMENT'] ?? 'sandbox';
  static String get paypalHost {
    if (paypalEnvironment == 'sandbox') return 'api-m.sandbox.paypal.com';
    if (paypalEnvironment == 'live' &&
        Platform.environment['RAYSTO_LIVE_PAYMENTS_APPROVED'] == 'true') {
      return 'api-m.paypal.com';
    }
    return _fail(
      'not_configured',
      'Live platform processing has not been enabled.',
    );
  }

  static Future<Uint8List> bounded(
    http.StreamedResponse r, {
    int maxBytes = 2097152,
  }) async {
    if ((r.contentLength ?? 0) > maxBytes) {
      _fail(
        'provider_response_too_large',
        'Provider response exceeded its limit.',
      );
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in r.stream.timeout(const Duration(seconds: 30))) {
      if (bytes.length + chunk.length > maxBytes) {
        _fail(
          'provider_response_too_large',
          'Provider response exceeded its limit.',
        );
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  static Future<Json> sendJson(http.Client client, http.Request request) async {
    final r = await client.send(request).timeout(const Duration(seconds: 25));
    final bytes = await bounded(r);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      _fail(
        'provider_unavailable',
        'The provider did not confirm this operation. Keep the existing request ID.',
      );
    }
    return bytes.isEmpty ? {} : _json(utf8.decode(bytes), maxBytes: 2097152);
  }

  static Future<Json> paypal(
    String method,
    String path, {
    Json? body,
    String? requestId,
    String? merchant,
    bool billing = false,
    bool singleMerchant = false,
  }) async {
    if (!path.startsWith('/') ||
        path.startsWith('//') ||
        path.contains('://')) {
      _fail('invalid_input', 'Invalid provider path.');
    }
    if (singleMerchant &&
        (billing ||
            paypalEnvironment != 'sandbox' ||
            Platform.environment['RAYSTO_SINGLE_MERCHANT_SANDBOX_ENABLED'] !=
                'true' ||
            (merchant != null &&
                merchant != required('PAYPAL_SANDBOX_MERCHANT_ID')))) {
      _fail('not_configured', 'Invalid direct Sandbox merchant configuration.');
    }
    final prefix = billing
        ? 'PAYPAL_BILLING'
        : singleMerchant
        ? 'PAYPAL_SANDBOX'
        : 'PAYPAL_PLATFORM';
    final clientId = required('${prefix}_CLIENT_ID');
    final secret = required('${prefix}_CLIENT_SECRET');
    if (billing &&
        required('PAYPAL_BILLING_MERCHANT_ID') ==
            required('PAYPAL_PLATFORM_MERCHANT_ID')) {
      _fail(
        'not_configured',
        'Subscriptions require a separate direct seller account.',
      );
    }
    final client = http.Client();
    try {
      final token = await sendJson(
        client,
        http.Request('POST', Uri.https(paypalHost, '/v1/oauth2/token'))
          ..headers.addAll({
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
            'Content-Type': 'application/x-www-form-urlencoded',
          })
          ..body = 'grant_type=client_credentials',
      );
      final req = http.Request(method, Uri.parse('https://$paypalHost$path'))
        ..followRedirects = false;
      req.headers.addAll({
        'Authorization': 'Bearer ${_str(token, 'access_token', max: 16000)}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
        'PayPal-Request-Id': ?requestId,
        if (!billing && !singleMerchant)
          'PayPal-Partner-Attribution-Id': required('PAYPAL_PLATFORM_BN_CODE'),
      });
      if (merchant != null && !singleMerchant) {
        String enc(Json x) =>
            base64UrlEncode(utf8.encode(jsonEncode(x))).replaceAll('=', '');
        req.headers['PayPal-Auth-Assertion'] =
            '${enc({'alg': 'none'})}.${enc({'iss': clientId, 'payer_id': merchant})}.';
      }
      if (body != null) req.body = jsonEncode(body);
      return await sendJson(client, req);
    } finally {
      client.close();
    }
  }

  static Uri callback(String key) {
    final u = Uri.parse(required(key));
    if (u.scheme != 'https' ||
        u.host.isEmpty ||
        u.userInfo.isNotEmpty ||
        u.hasFragment) {
      _fail('not_configured', 'Callbacks require HTTPS.');
    }
    return u;
  }

  static Future<Json> createCheckout(CheckoutIntent i) => paypal(
    'POST',
    '/v2/checkout/orders',
    merchant: i.merchantId,
    singleMerchant: i.providerMode == 'singleMerchantSandbox',
    requestId: 'new-${i.providerRequestId}',
    body: {
      'intent': 'CAPTURE',
      'purchase_units': [
        {
          'reference_id': 'raysto-v2:${i.id}',
          'custom_id': 'raysto-v2:${i.id}',
          'payee': {'merchant_id': i.merchantId},
          'amount': {
            'currency_code': i.currency,
            'value': PayPalGateway.money(i.amountMinor),
          },
          if (i.commissionMinor > 0)
            'payment_instruction': {
              'disbursement_mode': 'INSTANT',
              'platform_fees': [
                {
                  'amount': {
                    'currency_code': i.currency,
                    'value': PayPalGateway.money(i.commissionMinor),
                  },
                  'payee': {
                    'merchant_id': required('PAYPAL_PLATFORM_MERCHANT_ID'),
                  },
                },
              ],
            },
        },
      ],
      'payment_source': {
        'paypal': {
          'experience_context': {
            'return_url': callback('PAYPAL_V2_RETURN_URL')
                .replace(
                  queryParameters: {
                    'v': '2',
                    'checkoutId': '${i.id}',
                    'restaurantId': '${i.restaurantId}',
                  },
                )
                .toString(),
            'cancel_url': callback('PAYPAL_V2_CANCEL_URL')
                .replace(
                  queryParameters: {
                    'v': '2',
                    'checkoutId': '${i.id}',
                    'restaurantId': '${i.restaurantId}',
                  },
                )
                .toString(),
            'user_action': 'PAY_NOW',
            'shipping_preference': 'NO_SHIPPING',
          },
        },
      },
    },
  );
  static String? approval(Json r, {String rel = 'payer-action'}) {
    final links = r['links'] as List? ?? [];
    for (final l in links) {
      if (l is! Map ||
          !(l['rel'] == rel ||
              rel == 'payer-action' && l['rel'] == 'approve')) {
        continue;
      }
      final u = Uri.tryParse(l['href'] as String? ?? '');
      if (u != null &&
          u.scheme == 'https' &&
          u.userInfo.isEmpty &&
          {
            'www.paypal.com',
            'paypal.com',
            'www.sandbox.paypal.com',
            'sandbox.paypal.com',
          }.contains(u.host)) {
        return u.toString();
      }
    }
    return null;
  }

  static bool merchantCountryAllowed(Json d) {
    final allow = required(
      'PAYPAL_ALLOWED_MERCHANT_COUNTRIES',
    ).split(',').map((c) => c.trim().toUpperCase()).toSet();
    return d['country'] is String && allow.contains(d['country']);
  }

  static Future<void> verifyWebhook(
    Json event,
    Map<String, String> headers, {
    bool billing = false,
    bool singleMerchant = false,
  }) async {
    final cert = Uri.tryParse(headers['paypal-cert-url'] ?? '');
    if (cert == null ||
        cert.scheme != 'https' ||
        !{
          'api.paypal.com',
          'api.sandbox.paypal.com',
          'api-m.paypal.com',
          'api-m.sandbox.paypal.com',
        }.contains(cert.host)) {
      _fail('forbidden', 'Invalid webhook certificate location.');
    }
    final result = await paypal(
      'POST',
      '/v1/notifications/verify-webhook-signature',
      billing: billing,
      singleMerchant: singleMerchant,
      body: {
        'auth_algo': headers['paypal-auth-algo'],
        'cert_url': cert.toString(),
        'transmission_id': headers['paypal-transmission-id'],
        'transmission_sig': headers['paypal-transmission-sig'],
        'transmission_time': headers['paypal-transmission-time'],
        'webhook_id': required(
          billing
              ? 'PAYPAL_BILLING_WEBHOOK_ID'
              : singleMerchant
              ? 'PAYPAL_SANDBOX_WEBHOOK_ID'
              : 'PAYPAL_PLATFORM_WEBHOOK_ID',
        ),
        'webhook_event': event,
      },
    );
    if (result['verification_status'] != 'SUCCESS') {
      _fail('forbidden', 'Webhook verification failed.');
    }
  }

  // Reuse Google's auto-refreshing token and HTTP connection pool per isolate.
  // Revocation lookups still reach Firebase; this caches no user authorization.
  static Future<AutoRefreshingAuthClient>? _googleClient;

  static Future<AutoRefreshingAuthClient> _sharedGoogleClient() =>
      _googleClient ??= (() async {
        try {
          return await clientViaServiceAccount(
            ServiceAccountCredentials.fromJson(
              await File(
                required('GOOGLE_APPLICATION_CREDENTIALS'),
              ).readAsString(),
            ),
            ['https://www.googleapis.com/auth/cloud-platform'],
          ).timeout(const Duration(seconds: 15));
        } catch (_) {
          _googleClient = null;
          rethrow;
        }
      })();

  static Future<T> google<T>(
    Future<AutoRefreshingAuthClient> Function()? factory,
    Future<T> Function(AutoRefreshingAuthClient) action,
  ) async {
    final client = await (factory?.call() ?? _sharedGoogleClient());
    try {
      return await action(client);
    } finally {
      if (factory != null) client.close();
    }
  }

  static Future<Json> googleJson(String method, Uri uri, {Json? body}) =>
      google(null, (client) async {
        final request = http.Request(method, uri)
          ..followRedirects = false
          ..headers['Content-Type'] = 'application/json';
        if (body != null) request.body = jsonEncode(body);
        return sendJson(client, request);
      });
  static Future<Json> lookupIdentity(String uid) => googleJson(
    'POST',
    Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/projects/${required('FIREBASE_PROJECT_ID')}/accounts:lookup',
    ),
    body: {
      'localId': [uid],
    },
  );
  static Future<Json> verifyIdentity(
    Session s,
    String token,
    String uid, {
    bool recent = true,
  }) async {
    final details = await AuthServices.instance.firebaseIdp.utils
        .fetchAccountDetails(s, idToken: token);
    if (details.userIdentifier != uid || details.verifiedEmail != true) {
      _fail('unauthorized', 'Identity does not match the verified account.');
    }
    final claims = _json(
      utf8.decode(base64Url.decode(base64Url.normalize(token.split('.')[1]))),
    );
    final authTime = claims['auth_time'];
    if (authTime is! int ||
        recent &&
            (_now().millisecondsSinceEpoch ~/ 1000 - authTime).abs() > 300) {
      _fail('reauthentication_required', 'Sign in again to continue.');
    }
    final lookup = await lookupIdentity(uid);
    final users = lookup['users'] as List? ?? [];
    if (users.length != 1 ||
        users.single['disabled'] == true ||
        authTime < (int.tryParse('${users.single['validSince'] ?? 0}') ?? 0)) {
      final backendIdentity = s.authenticated;
      if (backendIdentity != null) {
        await AuthServices.instance.tokenManager.revokeAllTokens(
          s,
          authUserId: UuidValue.fromString(backendIdentity.userIdentifier),
        );
      }
      _fail('unauthorized', 'Firebase session has been revoked.');
    }
    return {
      'authTime': authTime,
      'mfa': (claims['firebase'] as Map?)?['sign_in_second_factor'] != null,
    };
  }

  static List<Json> _appKeys = [];
  static DateTime? _keysUntil;
  static Future<void> checkApp(
    Session s, {
    String? token,
    bool required = false,
  }) async {
    final enforce =
        required || Platform.environment['RAYSTO_APPCHECK_MODE'] == 'enforce';
    token ??= PlatformApi.requestHeader(s, 'x-firebase-appcheck');
    if (token == null) {
      if (enforce) _fail('app_check_required', 'App verification is required.');
      return;
    }
    try {
      if (token.length > 16000) throw const FormatException();
      final parts = token.split('.');
      if (parts.length != 3) throw const FormatException();
      final header = _json(
        utf8.decode(base64Url.decode(base64Url.normalize(parts.first))),
      );
      if (header['alg'] != 'RS256' || header['typ'] != 'JWT') {
        throw const FormatException();
      }
      if (_keysUntil == null || _keysUntil!.isBefore(_now())) {
        final client = http.Client();
        try {
          final keys = await sendJson(
            client,
            http.Request(
              'GET',
              Uri.https('firebaseappcheck.googleapis.com', '/v1/jwks'),
            ),
          );
          _appKeys = (keys['keys'] as List).cast<Json>();
          _keysUntil = _now().add(const Duration(hours: 1));
        } finally {
          client.close();
        }
      }
      final keys = _appKeys
          .where((k) => k['kid'] == header['kid'] && k['kty'] == 'RSA')
          .toList();
      if (keys.length != 1) throw const FormatException();
      final verified = jwt.JWT.verify(token, jwt.JWTKey.fromJWK(keys.single));
      final p = _object(verified.payload);
      final number = ProviderClients.required('FIREBASE_PROJECT_NUMBER');
      if (p['iss'] != 'https://firebaseappcheck.googleapis.com/$number' ||
          p['aud'] is! List ||
          !(p['aud'] as List).contains('projects/$number') ||
          p['exp'] is! int ||
          (p['exp'] as int) <= _now().millisecondsSinceEpoch ~/ 1000 ||
          !(ProviderClients.required(
            'FIREBASE_ALLOWED_APP_IDS',
          ).split(',')).contains(p['sub'])) {
        throw const FormatException();
      }
    } catch (_) {
      if (enforce) _fail('invalid_app_check', 'App verification failed.');
      s.log('App Check observation: invalid token', level: LogLevel.warning);
    }
  }

  static Future<void> putFile(
    String name,
    Uint8List bytes,
    String mime,
  ) => google(null, (client) async {
    final req =
        http.Request(
            'POST',
            Uri.https(
              'storage.googleapis.com',
              '/upload/storage/v1/b/${required('FIREBASE_STORAGE_BUCKET')}/o',
              {'uploadType': 'media', 'name': name, 'ifGenerationMatch': '0'},
            ),
          )
          ..headers['Content-Type'] = mime
          ..bodyBytes = bytes;
    final response = await client
        .send(req)
        .timeout(const Duration(seconds: 30));
    await bounded(response);
    if (response.statusCode == 412) {
      final existing = await client.send(
        http.Request('GET', storageUri(name, download: true)),
      );
      if (existing.statusCode == 200 &&
          sha256
                  .convert(await bounded(existing, maxBytes: 8388608))
                  .toString() ==
              sha256.convert(bytes).toString()) {
        return;
      }
    }
    if (response.statusCode != 200) {
      _fail('storage_unavailable', 'Private upload was not confirmed.');
    }
  });
  static Future<Uint8List> getFile(
    String name, {
    int maxBytes = 8388608,
  }) => google(null, (client) async {
    final r = await client.send(
      http.Request(
        'GET',
        storageUri(name, download: true),
      ),
    );
    if (r.statusCode != 200) {
      _fail('storage_unavailable', 'File is unavailable.');
    }
    return bounded(r, maxBytes: maxBytes);
  });
  static Future<void> deleteFile(String name) => google(null, (client) async {
    final r = await client
        .delete(
          storageUri(name),
        )
        .timeout(const Duration(seconds: 20));
    if (!{204, 404}.contains(r.statusCode)) {
      _fail('storage_unavailable', 'File removal was not confirmed.');
    }
  });
  static Uri storageUri(String name, {bool download = false}) => Uri.parse(
    'https://storage.googleapis.com/storage/v1/b/${Uri.encodeComponent(required('FIREBASE_STORAGE_BUCKET'))}/o/${Uri.encodeComponent(name)}${download ? '?alt=media' : ''}',
  );
  // Token counting refreshes the cached Google credential. Generation uses a
  // dedicated transport so a timeout closes only this model request, never
  // Firebase identity checks or another assistant run. No automatic paid retry.
  static Future<Json> geminiRequest(
    Json body,
    Json config, {
    Duration deadline = const Duration(seconds: 30),
    void Function(String stage)? onStage,
  }) async {
    final watch = Stopwatch()..start();
    Duration remaining() => deadline - watch.elapsed;
    final path =
        '/v1/projects/${required('GOOGLE_CLOUD_PROJECT')}/locations/eu/publishers/google/models/gemini-3.8-flash';
    onStage?.call('google_auth');
    return google(null, (auth) async {
      onStage?.call('count_tokens');
      final estimate = await GeminiTransport.post(
        auth,
        Uri.https('aiplatform.eu.rep.googleapis.com', '$path:countTokens'),
        body,
        stage: 'count_tokens',
        timeout: remaining(),
      );
      if (estimate['totalTokens'] is! int || estimate['totalTokens'] > 16384) {
        throw const GeminiFailure('ai_input_too_large', 'count_tokens');
      }
      onStage?.call('generate');
      final transport = http.Client();
      try {
        return await GeminiTransport.post(
          transport,
          Uri.https(
            'aiplatform.eu.rep.googleapis.com',
            '$path:streamGenerateContent',
            {'alt': 'sse'},
          ),
          {...body, 'generationConfig': config},
          stage: 'generate',
          timeout: remaining(),
          streaming: true,
          headers: {
            'Authorization': 'Bearer ${auth.credentials.accessToken.data}',
          },
        );
      } finally {
        transport.close();
      }
    });
  }

  static Future<Json> gemini(String instruction, List<Json> parts) =>
      geminiRequest(
        {
          'systemInstruction': {
            'parts': [
              {'text': instruction},
            ],
          },
          'contents': [
            {'role': 'user', 'parts': parts},
          ],
        },
        {
          'maxOutputTokens': 8192,
          'responseMimeType': 'application/json',
          'thinkingConfig': {'thinkingLevel': 'LOW'},
        },
        deadline: const Duration(seconds: 60),
      );

  static Future<Json> geminiTurn(
    String instruction,
    List<Json> contents,
    List<Json> declarations, {
    Duration deadline = const Duration(seconds: 30),
    void Function(String stage)? onStage,
  }) => geminiRequest(
    {
      'systemInstruction': {
        'parts': [
          {'text': instruction},
        ],
      },
      'contents': contents,
      'tools': [
        {'functionDeclarations': declarations},
      ],
    },
    {
      'maxOutputTokens': 4096,
      'thinkingConfig': {'thinkingLevel': 'LOW'},
    },
    deadline: deadline,
    onStage: onStage,
  );

  static Future<void> email(String to, String subject, String text) async {
    final region = required('AWS_SES_REGION');
    final access = required('RAYSTO_AWS_ACCESS_KEY_ID');
    final secret = required('RAYSTO_AWS_SECRET_ACCESS_KEY');
    final date =
        '${_now().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.').first}Z';
    final day = date.substring(0, 8);
    final host = 'email.$region.amazonaws.com';
    final body = jsonEncode({
      'FromEmailAddress': required('RAYSTO_EMAIL_FROM'),
      'Destination': {
        'ToAddresses': [to],
      },
      'Content': {
        'Simple': {
          'Subject': {'Data': subject, 'Charset': 'UTF-8'},
          'Body': {
            'Text': {'Data': text, 'Charset': 'UTF-8'},
          },
        },
      },
    });
    final headers = <String, String>{
      'content-type': 'application/json',
      'host': host,
      'x-amz-date': date,
      if (Platform.environment['RAYSTO_AWS_SESSION_TOKEN'] != null)
        'x-amz-security-token':
            Platform.environment['RAYSTO_AWS_SESSION_TOKEN']!,
    };
    final names = headers.keys.toList()..sort();
    final signed = names.join(';');
    final canonical =
        'POST\n/v2/email/outbound-emails\n\n${names.map((n) => '$n:${headers[n]}\n').join()}\n$signed\n${_hash(body)}';
    final scope = '$day/$region/ses/aws4_request';
    final message = 'AWS4-HMAC-SHA256\n$date\n$scope\n${_hash(canonical)}';
    List<int> sign(List<int> key, String data) =>
        Hmac(sha256, key).convert(utf8.encode(data)).bytes;
    final key = sign(
      sign(sign(sign(utf8.encode('AWS4$secret'), day), region), 'ses'),
      'aws4_request',
    );
    final signature = sign(
      key,
      message,
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    headers['Authorization'] =
        'AWS4-HMAC-SHA256 Credential=$access/$scope, SignedHeaders=$signed, Signature=$signature';
    final client = http.Client();
    try {
      await sendJson(
        client,
        http.Request('POST', Uri.https(host, '/v2/email/outbound-emails'))
          ..headers.addAll(headers)
          ..body = body,
      );
    } finally {
      client.close();
    }
  }
}
