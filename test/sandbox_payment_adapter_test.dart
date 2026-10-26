import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:raysto/payments/payment_adapters.dart';
import 'package:raysto/payments/payment_controller.dart';
import 'package:raysto/payments/payment_models.dart';
import 'package:raysto/payments/testing/payment_lab.dart';
import 'package:raysto_client/raysto_client.dart' as api;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  api.SandboxPayment receipt({
    String owner = 'owner',
    int amount = 100,
    String state = 'awaitingApproval',
  }) => api.SandboxPayment(
    id: 7,
    userId: owner,
    requestKey: 'test-key',
    providerRequestId: 'test-provider-key',
    amountMinor: amount,
    currency: 'USD',
    state: state,
    providerOrderId: 'TESTORDER123456789',
    approvalUrl:
        'https://www.sandbox.paypal.com/checkoutnow?token=TESTORDER123456789',
    createdAt: DateTime.utc(2026, 10, 25),
    captureId: state == 'captured' ? 'CAPTURE123' : null,
  );

  test('the shared core routes a sandbox reference through typed checkout and capture APIs', () async {
    final paths = <String>[];
    var paid = false;
    final client = api.Client(
      'https://example.test/',
      httpClientOverride: MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path.endsWith('/capture')) paid = true;
        expect(jsonDecode(request.body), {'paymentId': 7});
        return http.Response(
          jsonEncode(
            receipt(state: paid ? 'captured' : 'awaitingApproval').toJson(),
          ),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final browser = LabPaymentBrowser();
    final controller = PaymentController(
      backend: ServerpodPaymentBackend(client, () => 'owner'),
      store: MemoryPaymentStore(),
      browser: browser,
      links: PayPalLinkPolicy(callbackOrigin: Uri.parse('https://api.rays.to')),
    );
    addTearDown(controller.dispose);
    await controller.connect('owner');
    await controller.prepare('sandbox:7');
    expect(controller.snapshot.canOpen, isTrue);
    await controller.openApproval();
    expect(browser.opens, 1);
    await controller.handleReturn(
      Uri.parse('https://api.rays.to/payments/return?token=TESTORDER123456789'),
    );
    expect(controller.snapshot.paid, isFalse);
    await controller.complete();
    expect(controller.snapshot.paid, isTrue);
    expect(
      paths,
      containsAll([
        '/sandboxPayments/read',
        '/sandboxPayments/checkout',
        '/sandboxPayments/capture',
      ]),
    );
    expect(paths.any((p) => p.startsWith('/commerce')), isFalse);
  });

  for (final mismatch in ['owner', 'amount']) {
    test(
      'adapter rejects unexpected $mismatch in a sandbox response',
      () async {
        final client = api.Client(
          'https://example.test/',
          httpClientOverride: MockClient(
            (_) async => http.Response(
              jsonEncode(
                receipt(
                  owner: mismatch == 'owner' ? 'another' : 'owner',
                  amount: mismatch == 'amount' ? 200 : 100,
                ).toJson(),
              ),
              200,
            ),
          ),
        );
        addTearDown(client.close);
        await expectLater(
          ServerpodPaymentBackend(client, () => 'owner').read('sandbox:7'),
          throwsA(
            isA<PaymentException>().having(
              (e) => e.problem,
              'problem',
              PaymentProblem.invalidResponse,
            ),
          ),
        );
      },
    );
  }
  test(
    'unapproved provider result maps to actionable approval state',
    () async {
      final client = api.Client(
        'https://example.test/',
        httpClientOverride: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'className': 'DomainError',
              'data': api.DomainError(
                code: 'approval_required',
                message: 'Approve first',
              ).toJson(),
            }),
            500,
          ),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        ServerpodPaymentBackend(client, () => 'owner').complete('sandbox:7'),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.problem,
            'problem',
            PaymentProblem.notApproved,
          ),
        ),
      );
    },
  );
  test('start retries reuse a securely persisted key across a lost response and owners stay isolated', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final requests = <String>[];
    var fail = true;
    final client = api.Client(
      'https://example.test/',
      httpClientOverride: MockClient((request) async {
        requests.add((jsonDecode(request.body) as Map)['requestKey'] as String);
        if (fail) {
          fail = false;
          throw http.ClientException('Response lost');
        }
        return http.Response(
          jsonEncode(receipt(state: 'created').toJson()),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final starter = SandboxCheckoutStarter(client, 'https://example.test/');
    expect(await starter.restore('owner'), isNull);
    await expectLater(starter.start('owner'), throwsA(anything));
    await starter.start('owner');
    expect(requests[0], requests[1]);
    await SandboxCheckoutStarter(
      client,
      'https://example.test/',
    ).restore('owner');
    expect(requests[2], requests[0]);
    expect(await starter.restore('another'), isNull);
    expect(
      await SandboxCheckoutStarter(
        client,
        'https://another.test/',
      ).restore('owner'),
      isNull,
    );
    await starter.clear('owner');
    await starter.start('owner');
    expect(requests.last, isNot(requests[0]));
  });
}
