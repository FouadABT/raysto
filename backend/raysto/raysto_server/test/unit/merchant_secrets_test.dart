import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

// The sealing of a restaurant's own PayPal app secret (AES-256-GCM under the
// server-only key) and the own-app key check. A mock transport; no provider
// request is made.
void main() {
  late Map<String, String> env;
  final basics = <String>[];

  setUp(() {
    basics.clear();
    env = {
      ...Platform.environment,
      'RAYSTO_PAYPAL_ENVIRONMENT': 'sandbox',
      'RAYSTO_MERCHANT_SECRET_KEY': base64.encode(List.generate(32, (i) => i)),
    };
    ProviderClients.environment = () => env;
    ProviderClients.httpClient = () => MockClient((request) async {
      if (request.url.path == '/v1/oauth2/token') {
        final basic = request.headers['Authorization']!;
        basics.add(basic);
        final pair = utf8.decode(base64.decode(basic.substring(6)));
        return pair == 'GOODCLIENTAAAAAAAAAAAAAAAA:GOODSECRETAAAAAAAAAAAAAAAA'
            ? http.Response(
                jsonEncode({
                  'access_token': 'tok',
                  'app_id': 'APP-1',
                  'expires_in': 32400,
                }),
                200,
              )
            : http.Response('{"error":"invalid_client"}', 401);
      }
      return http.Response('{}', 500);
    });
  });
  tearDown(() {
    ProviderClients.environment = () => Platform.environment;
    ProviderClients.httpClient = http.Client.new;
  });

  DomainError failure(void Function() f) {
    try {
      f();
    } on DomainError catch (e) {
      return e;
    }
    fail('expected a DomainError');
  }

  test('a sealed secret opens only with its key and its own context', () {
    final aad = MerchantSecrets.aad(7, 'sandbox', 'CLIENT-7');
    final sealed = MerchantSecrets.seal('the-secret', aad);
    expect(sealed, isNot(contains('the-secret')));
    expect(MerchantSecrets.open(sealed, aad), 'the-secret');
    // A fresh nonce every time.
    expect(MerchantSecrets.seal('the-secret', aad), isNot(sealed));
    // Another restaurant, another client id or another key: it does not open.
    expect(
      failure(
        () => MerchantSecrets.open(
          sealed,
          MerchantSecrets.aad(8, 'sandbox', 'CLIENT-7'),
        ),
      ).code,
      'merchant_keys_unreadable',
    );
    expect(
      failure(
        () => MerchantSecrets.open(
          sealed,
          MerchantSecrets.aad(7, 'sandbox', 'CLIENT-8'),
        ),
      ).code,
      'merchant_keys_unreadable',
    );
    final bytes = base64.decode(sealed);
    bytes[bytes.length - 1] ^= 1;
    expect(
      failure(() => MerchantSecrets.open(base64.encode(bytes), aad)).code,
      'merchant_keys_unreadable',
    );
    env['RAYSTO_MERCHANT_SECRET_KEY'] = base64.encode(
      List.generate(32, (i) => 255 - i),
    );
    expect(
      failure(() => MerchantSecrets.open(sealed, aad)).code,
      'merchant_keys_unreadable',
    );
    // A key version change makes the context differ, so the owner re-saves.
    env['RAYSTO_MERCHANT_SECRET_KEY'] = base64.encode(
      List.generate(32, (i) => i),
    );
    env['RAYSTO_MERCHANT_SECRET_KEY_VERSION'] = '2';
    expect(
      failure(
        () => MerchantSecrets.open(
          sealed,
          MerchantSecrets.aad(7, 'sandbox', 'CLIENT-7'),
        ),
      ).code,
      'merchant_keys_unreadable',
    );
  });

  test('without a 32-byte server key nothing is stored', () {
    env['RAYSTO_MERCHANT_SECRET_KEY'] = base64.encode(List.filled(16, 1));
    expect(MerchantSecrets.configured, isFalse);
    expect(
      failure(() => MerchantSecrets.seal('x', 'aad')).code,
      'not_configured',
    );
    env.remove('RAYSTO_MERCHANT_SECRET_KEY');
    expect(MerchantSecrets.configured, isFalse);
  });

  test(
    'PayPal decides whether pasted keys are good, and only in Sandbox',
    () async {
      final ok = await ProviderClients.ownAppToken(
        'GOODCLIENTAAAAAAAAAAAAAAAA',
        'GOODSECRETAAAAAAAAAAAAAAAA',
      );
      expect(ok, {'appId': 'APP-1', 'expiresIn': 32400});
      await expectLater(
        ProviderClients.ownAppToken(
          'GOODCLIENTAAAAAAAAAAAAAAAA',
          'WRONGSECRETAAAAAAAAAAAAAAA',
        ),
        throwsA(
          isA<DomainError>()
              .having((e) => e.code, 'code', 'paypal_keys_invalid')
              .having((e) => e.message, 'message', isNot(contains('WRONG'))),
        ),
      );
      env['RAYSTO_PAYPAL_ENVIRONMENT'] = 'live';
      await expectLater(
        ProviderClients.ownAppToken(
          'GOODCLIENTAAAAAAAAAAAAAAAA',
          'GOODSECRETAAAAAAAAAAAAAAAA',
        ),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'not_configured'),
        ),
      );
      expect(basics.length, 2);
    },
  );
}
