import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  final valid = {
    'arrangement': 'side-by-side',
    'columns': ['name', 'cost'],
    'completeness': 'all',
    'sort': 'contribution',
    'widgets': ['comparison', 'evidence'],
  };
  test(
    'valid declared presentation is retained',
    () => expect(FinanceDecisions.view(valid), valid),
  );
  for (final change in [
    {
      'columns': ['name', 'bankBalance'],
    },
    {
      'columns': [7],
    },
    {
      'columns': ['name', 'name'],
    },
    {
      'widgets': ['payment.execute'],
    },
    {'expression': 'sendMoney()'},
    {'arrangement': 'javascript:alert(1)'},
  ]) {
    test(
      'rejects unsupported configuration $change',
      () => expect(
        () => FinanceDecisions.view({...valid, ...change}),
        throwsA(isA<DomainError>()),
      ),
    );
  }
}
