import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test(
    'equal shares conserve every charge and are independent of payer order',
    () {
      final charges = <Json>[
        {'chargeId': 1, 'label': 'Shared starter', 'availableMinor': 1001},
        {'chargeId': 2, 'label': 'Drinks', 'availableMinor': 2},
      ];
      final split = EqualShares.distribute(charges, ['b', 'a', 'c']);
      expect(split, EqualShares.distribute(charges, ['c', 'b', 'a']));
      expect(split['a']![0]['amountMinor'], 334);
      expect(split['c']![0]['amountMinor'], 333);
      for (final charge in charges) {
        final sum = split.values
            .expand((v) => v)
            .where((s) => s['chargeId'] == charge['chargeId'])
            .fold<int>(0, (sum, s) => sum + (s['amountMinor'] as int));
        expect(sum, charge['availableMinor']);
      }
    },
  );
  test('invalid payer groups cannot divide a bill', () {
    expect(() => EqualShares.distribute([], []), throwsA(isA<DomainError>()));
    expect(
      () => EqualShares.distribute([], ['a', 'a']),
      throwsA(isA<DomainError>()),
    );
  });
}
