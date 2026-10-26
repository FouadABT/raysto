import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  group('Image quarantine', () {
    test('a malformed PNG is a terminal rejection, not a worker retry', () {
      final malformed = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1kAAAAASUVORK5CYII=',
      );
      expect(
        () => PlatformFiles.sanitizeImage(malformed),
        throwsA(
          isA<DomainError>().having((e) => e.code, 'code', 'invalid_file'),
        ),
      );
    });
    test('valid PNG is sanitized to a decodable JPEG', () {
      final source = Uint8List.fromList(
        img.encodePng(img.Image(width: 2, height: 2)),
      );
      final (clean, dimensions) = PlatformFiles.sanitizeImage(source);
      expect(img.decodeJpg(clean)?.width, 2);
      expect(dimensions, {'width': 2, 'height': 2});
    });
  });
  group('Minor-unit apportionment', () {
    test('ties use stable order and preserve the exact total', () {
      expect(OrderingModule.distribute(2, [1, 1, 1]), [1, 1, 0]);
    });
    test('zero-weight lines cannot receive a discount', () {
      expect(OrderingModule.distribute(7, [0, 10, 0]), [0, 7, 0]);
    });
    test('all bounded generated cases conserve amount', () {
      for (var total = 0; total < 100; total++) {
        for (var a = 1; a < 10; a++) {
          final result = OrderingModule.distribute(total, [a, 11, 23]);
          expect(result.reduce((x, y) => x + y), total);
          expect(result.every((v) => v >= 0), isTrue);
        }
      }
    });
    test('negative and empty nonzero allocations are rejected', () {
      expect(
        () => OrderingModule.distribute(1, []),
        throwsA(isA<DomainError>()),
      );
      expect(
        () => OrderingModule.distribute(-1, [1]),
        throwsA(isA<DomainError>()),
      );
    });
  });
  group('Untrusted customer and AI input', () {
    test('client price cannot enter a cart line', () {
      expect(
        () => OrderingModule.lines([
          {'productId': 1, 'quantity': 1, 'priceMinor': 1},
        ]),
        throwsA(isA<DomainError>()),
      );
    });
    test('duplicate selected modifiers are rejected', () {
      expect(
        () => OrderingModule.lines([
          {
            'productId': 1,
            'quantity': 1,
            'options': ['size:L', 'size:L'],
          },
        ]),
        throwsA(isA<DomainError>()),
      );
    });
    test('missing allergens remain unknown', () {
      final item = CatalogueModule.validateItem({
        'name': 'Soup',
        'category': 'Lunch',
        'priceMinor': 500,
      });
      expect(item['allergens'], isNull);
    });
    test('nonfinite coordinates are rejected', () {
      expect(
        () => CatalogueModule.coordinate(double.nan, 90),
        throwsA(isA<DomainError>()),
      );
    });
  });
  group('PayPal evidence binding', () {
    final intent = CheckoutIntent(
      id: 42,
      restaurantId: 1,
      userId: 'u',
      requestKey: 'test_request_000001',
      requestHash: 'hash',
      providerRequestId: 'request',
      merchantId: 'SELLER',
      state: 'created',
      method: 'paypal',
      currency: 'EUR',
      amountMinor: 1001,
      commissionMinor: 0,
      commissionBps: 0,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    Map<String, dynamic> provider({
      String seller = 'SELLER',
      String amount = '10.01',
      String reference = 'raysto-v2:42',
      String currency = 'EUR',
    }) => {
      'intent': 'CAPTURE',
      'purchase_units': [
        {
          'custom_id': reference,
          'payee': {'merchant_id': seller},
          'amount': {'value': amount, 'currency_code': currency},
        },
      ],
    };
    test('matching evidence is accepted', () {
      MoneyModule.validateOrder(intent, provider());
    });
    test('foreign merchant, currency, amount and reference are rejected', () {
      for (final p in [
        provider(seller: 'OTHER'),
        provider(amount: '10.00'),
        provider(reference: 'raysto-v2:43'),
        provider(currency: 'USD'),
      ]) {
        expect(
          () => MoneyModule.validateOrder(intent, p),
          throwsA(isA<DomainError>()),
        );
      }
    });
    test('provider redirect cannot point to an arbitrary host', () {
      expect(
        ProviderClients.approval({
          'links': [
            {'rel': 'approve', 'href': 'https://evil.example/'},
          ],
        }),
        isNull,
      );
    });
  });
}
