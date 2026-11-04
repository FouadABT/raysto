import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';

// The derived journal's one mapping: every money fact becomes balanced
// double-entry lines on the fixed chart of accounts. Pure; no database.
void main() {
  Json fact(String type, int amount, [Json extra = const {}]) => {
    'type': type,
    'id': 7,
    'at': '2026-11-04T10:00:00.000Z',
    'date': '2026-11-04',
    'currency': 'USD',
    'venueId': 1,
    'amountMinor': amount,
    ...extra,
  };
  Map<String, (int, int)> byAccount(List<Json> lines) => {
    for (final l in lines)
      l['account'] as String: (l['debitMinor'] as int, l['creditMinor'] as int),
  };
  void balanced(List<Json> lines) {
    expect(LedgerModule.balanced(lines), isTrue, reason: '$lines');
    for (final l in lines) {
      expect(LedgerModule.accounts.containsKey(l['account']), isTrue, reason: '${l['account']}');
      expect((l['debitMinor'] as int) >= 0 && (l['creditMinor'] as int) >= 0, isTrue);
    }
  }

  test('a PayPal sale splits into sales, delivery, VAT and tips owed', () {
    final lines = LedgerModule.ledgerFor(
      fact('capture', 3300, {
        'method': 'paypal',
        'tipMinor': 300,
        'deliveryMinor': 500,
        'vatMinor': 227,
      }),
    );
    balanced(lines);
    expect(byAccount(lines), {
      '1000': (3300, 0),
      '4000': (0, 3300 - 300 - 500 - 227),
      '4010': (0, 500),
      '2100': (0, 227),
      '2200': (0, 300),
    });
    expect((lines.first['source'] as Json)['type'], 'capture');
  });

  test('cash lands in the till account; a request payment clears the receivable', () {
    expect(byAccount(LedgerModule.ledgerFor(fact('capture', 900, {'method': 'cash'}))), {
      '1010': (900, 0),
      '4000': (0, 900),
    });
    final request = LedgerModule.ledgerFor(fact('capture', 12000, {'method': 'paypal', 'requestId': 3}));
    balanced(request);
    expect(byAccount(request), {'1000': (12000, 0), '1100': (0, 12000)});
    expect(byAccount(LedgerModule.ledgerFor(fact('request', 12000))), {
      '1100': (12000, 0),
      '4200': (0, 12000),
    });
    expect(byAccount(LedgerModule.ledgerFor(fact('request', 4000, {'partner': true}))), {
      '1100': (4000, 0),
      '4000': (0, 4000),
    });
  });

  test('bills are owed when approved and cleared by a payout or a payment elsewhere', () {
    final bill = LedgerModule.ledgerFor(fact('bill', 19610, {'category': 'electricity', 'vatMinor': 1610}));
    balanced(bill);
    expect(byAccount(bill), {'6100': (18000, 0), '2110': (1610, 0), '2000': (0, 19610)});
    expect(byAccount(LedgerModule.ledgerFor(fact('bill', 180000, {'category': 'rent'}))), {
      '6110': (180000, 0),
      '2000': (0, 180000),
    });
    expect(byAccount(LedgerModule.ledgerFor(fact('bill', 5000, {'category': 'supplier'}))).keys, {'1200', '2000'});
    expect(byAccount(LedgerModule.ledgerFor(fact('bill', 5000, {'category': 'unknown'}))).keys, {'6190', '2000'});
    expect(byAccount(LedgerModule.ledgerFor(fact('payout', 19610, {'kind': 'bill'}))), {
      '2000': (19610, 0),
      '1000': (0, 19610),
    });
    expect(byAccount(LedgerModule.ledgerFor(fact('billPaidElsewhere', 180000))), {
      '2000': (180000, 0),
      '1010': (0, 180000),
    });
  });

  test('payouts post to the account they pay off', () {
    final kinds = {
      'tips': '2200',
      'wages': '6020',
      'supplier': '2000',
      'delivery': '6025',
      'partner': '6200',
    };
    for (final e in kinds.entries) {
      final lines = LedgerModule.ledgerFor(fact('payout', 1000, {'kind': e.key}));
      balanced(lines);
      expect(byAccount(lines), {e.value: (1000, 0), '1000': (0, 1000)}, reason: e.key);
    }
  });

  test('receipts go to their cost account with VAT reclaimable, paid by PayPal or cash', () {
    final paypal = LedgerModule.ledgerFor(
      fact('expense', 2400, {'category': 'cleaning', 'vatMinor': 400, 'paypal': true}),
    );
    balanced(paypal);
    expect(byAccount(paypal), {'6050': (2000, 0), '2110': (400, 0), '1000': (0, 2400)});
    final cash = LedgerModule.ledgerFor(fact('expense', 1200, {'category': 'food'}));
    expect(byAccount(cash), {'5000': (1200, 0), '1010': (0, 1200)});
  });

  test('refunds, fees, commissions and their reversal, stock and adjustments', () {
    expect(byAccount(LedgerModule.ledgerFor(fact('refund', 500))), {'4090': (500, 0), '1000': (0, 500)});
    expect(byAccount(LedgerModule.ledgerFor(fact('reversal', 500))), {'4090': (500, 0), '1000': (0, 500)});
    final fee = LedgerModule.ledgerFor(fact('fee', 164, {'estimated': true}));
    expect(byAccount(fee), {'6000': (164, 0), '1000': (0, 164)});
    expect((fee.first['source'] as Json)['estimated'], isTrue);
    expect(byAccount(LedgerModule.ledgerFor(fact('commission', 90))), {'6010': (90, 0), '1000': (0, 90)});
    expect(byAccount(LedgerModule.ledgerFor(fact('commission', -90))), {'1000': (90, 0), '6010': (0, 90)});
    expect(byAccount(LedgerModule.ledgerFor(fact('stockIn', 7000))), {'1200': (7000, 0), '2000': (0, 7000)});
    expect(byAccount(LedgerModule.ledgerFor(fact('cogs', 300))), {'5000': (300, 0), '1200': (0, 300)});
    expect(byAccount(LedgerModule.ledgerFor(fact('waste', 120))), {'6090': (120, 0), '1200': (0, 120)});
    expect(byAccount(LedgerModule.ledgerFor(fact('invoicePaid', 25000))), {'1000': (25000, 0), '4200': (0, 25000)});
    expect(
      byAccount(LedgerModule.ledgerFor(fact('adjustment', 50000, {'debitAccount': '1010', 'creditAccount': '3000'}))),
      {'1010': (50000, 0), '3000': (0, 50000)},
    );
  });

  test('nothing is posted for a zero amount or an unknown fact', () {
    expect(LedgerModule.ledgerFor(fact('capture', 0)), isEmpty);
    expect(LedgerModule.ledgerFor(fact('mystery', 100)), isEmpty);
  });

  test('profit and loss reads revenue less refunds against costs', () {
    final lines = [
      ...LedgerModule.ledgerFor(fact('capture', 10000, {'method': 'paypal', 'vatMinor': 0})),
      ...LedgerModule.ledgerFor(fact('refund', 1000)),
      ...LedgerModule.ledgerFor(fact('fee', 398)),
      ...LedgerModule.ledgerFor(fact('bill', 2000, {'category': 'water'})),
      ...LedgerModule.ledgerFor(fact('request', 5000)),
    ];
    expect(LedgerModule.balanced(lines), isTrue);
    final p = LedgerModule.pnl(lines);
    expect(p['revenueMinor'], 10000 - 1000 + 5000);
    expect(p['costsMinor'], 398 + 2000);
    expect(p['netMinor'], 14000 - 2398);
    final totals = LedgerModule.totals(lines);
    expect(totals['1000']!['balanceMinor'], 10000 - 1000 - 398);
    expect(totals['2000']!['balanceMinor'], 2000);
    expect(totals['1100']!['balanceMinor'], 5000);
  });

  test('aging buckets', () {
    expect(BillsModule.bucket(0), '0–30');
    expect(BillsModule.bucket(30), '0–30');
    expect(BillsModule.bucket(31), '31–60');
    expect(BillsModule.bucket(75), '61–90');
    expect(BillsModule.bucket(91), '90+');
  });
}
