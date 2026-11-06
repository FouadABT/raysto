import 'dart:io';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  setUp(
    () => Finance017.environment = () => {'RAYSTO_FINANCE_017_ENABLED': 'true'},
  );
  tearDown(() => Finance017.environment = () => Platform.environment);
  test(
    'a clearly recorded matching currency can continue to document review',
    () {
      expect(
        () => SuppliesAgent.requireDocumentCurrency({'currency': 'USD'}, 'USD'),
        returnsNormally,
      );
    },
  );
  for (final currency in [null, 'EUR', '']) {
    test(
      'unknown or conflicting document currency remains unconfirmed: $currency',
      () {
        expect(
          () => SuppliesAgent.requireDocumentCurrency({
            'currency': currency,
          }, 'USD'),
          throwsA(
            isA<DomainError>().having(
              (e) => e.code,
              'code',
              'currency_review_required',
            ),
          ),
        );
      },
    );
  }
}
