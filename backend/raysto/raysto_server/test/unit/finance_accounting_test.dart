import 'package:raysto_server/src/platform/platform.dart';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:test/test.dart';

// Independent accounting expectations for a complete illustrative café cycle.
// Integration tests separately exercise the actual business-event hooks.
void main() {
  List<Json> event(String id, List<Json> entries) => LedgerModule.ledgerFor({
    'type': 'management',
    'id': id,
    'date': '2026-11-05',
    'at': '2026-11-05T12:00:00Z',
    'currency': 'USD',
    'venueId': 1,
    'entries': entries,
  });
  Json d(String account, int amount) => {
    'account': account,
    'debitMinor': amount,
    'creditMinor': 0,
  };
  Json c(String account, int amount) => {
    'account': account,
    'debitMinor': 0,
    'creditMinor': amount,
  };
  test('a deposit and tip do not inflate recognized sales', () {
    final lines = event('collection', [
      d('1000', 1200),
      c('2300', 1100),
      c('2200', 100),
    ]);
    expect(LedgerModule.balanced(lines), true);
    expect(LedgerModule.pnl(lines)['revenueMinor'], 0);
    expect(LedgerModule.totals(lines)['2300']!['balanceMinor'], 1100);
  });
  test('receipt, invoice and settlement acquire inventory only once', () {
    final lines = [
      ...event('receipt', [d('1200', 1000), c('2050', 1000)]),
      ...event('invoice', [d('2050', 1000), d('2110', 100), c('2000', 1100)]),
      ...event('supplierPayment', [d('2000', 1100), c('1000', 1100)]),
    ];
    final totals = LedgerModule.totals(lines);
    expect(LedgerModule.balanced(lines), true);
    expect(totals['1200']!['debitMinor'], 1000);
    expect(totals['2050']!['balanceMinor'], 0);
    expect(totals['2000']!['balanceMinor'], 0);
    expect(LedgerModule.pnl(lines)['costsMinor'], 0);
  });
  test(
    'earning sales releases the advance and consumption recognizes cost',
    () {
      final lines = [
        ...event('collection', [d('1000', 1100), c('2300', 1100)]),
        ...event('completion', [
          d('1100', 1100),
          c('4000', 1000),
          c('2100', 100),
          d('2300', 1100),
          c('1100', 1100),
        ]),
        ...event('consumption', [d('5000', 350), c('1200', 350)]),
      ];
      expect(LedgerModule.balanced(lines), true);
      expect(LedgerModule.pnl(lines)['revenueMinor'], 1000);
      expect(LedgerModule.pnl(lines)['costsMinor'], 350);
      expect(LedgerModule.pnl(lines)['netMinor'], 650);
      expect(LedgerModule.totals(lines)['2300']!['balanceMinor'], 0);
      expect(LedgerModule.totals(lines)['1100']!['balanceMinor'], 0);
    },
  );
  test('wages are incurred once and settled without another expense', () {
    final lines = [
      ...event('earnedWages', [d('6020', 5000), c('2250', 5000)]),
      ...event('paidWages', [d('2250', 5000), c('1000', 5000)]),
    ];
    expect(LedgerModule.pnl(lines)['costsMinor'], 5000);
    expect(LedgerModule.totals(lines)['2250']!['balanceMinor'], 0);
  });
  test('refund components reverse tax and sales, without restoring stock', () {
    final lines = event('refund', [
      d('4090', 1000),
      d('2100', 100),
      d('2200', 100),
      c('1000', 1200),
    ]);
    expect(LedgerModule.balanced(lines), true);
    expect(LedgerModule.pnl(lines)['revenueMinor'], -1000);
    expect(LedgerModule.totals(lines).containsKey('1200'), false);
  });
  test('an unbalanced financial event cannot render as a journal', () {
    expect(
      () => event('invalid', [d('1000', 100), c('2300', 99)]),
      throwsA(isA<DomainError>()),
    );
  });
  test(
    'daily close separates opening positions, stock and bill settlement',
    () {
      Json fact(String id, List<Json> entries, {String? kind}) => {
        'type': 'management',
        'id': id,
        'entries': entries,
        'date': '2026-11-05',
        'currency': 'USD',
        'evidence': {
          'type': id == 'opening' ? 'reviewedOpening' : 'fixture',
          'kind': ?kind,
        },
        'issues': <String>[],
      };
      final close = LedgerModule.managementClose([
        fact('opening', [d('1000', 5000), c('3000', 5000)]),
        fact('receipt:1', [d('1200', 1000), c('2050', 1000)]),
        fact('bill:1', [d('2050', 1000), c('2000', 1000)]),
        fact('payoutItem:1', [d('2000', 1000), c('1000', 1000)], kind: 'bill'),
      ]);
      expect(close['cashInMinor'], 0);
      expect(close['cashOutMinor'], 1000);
      expect(close['supplierDeliveriesMinor'], 1000);
      expect(close['billsRecognisedMinor'], 1000);
      expect(close['payoutsMinor'], {'bill': 1000});
      expect(close['operatingResultMinor'], 0);
      expect(close['balanced'], true);
    },
  );
  test('daily close with missing costing cannot claim a complete result', () {
    final close = LedgerModule.managementClose([
      {
        'type': 'management',
        'id': 'consumption:1',
        'entries': [d('5000', 300), c('1200', 300)],
        'evidence': {'type': 'orderCost'},
        'issues': ['Ingredient cost missing'],
      },
    ]);
    expect(close['recordedResultMinor'], -300);
    expect(close['operatingResultMinor'], null);
    expect(close['complete'], false);
  });
}
