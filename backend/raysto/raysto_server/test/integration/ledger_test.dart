import 'dart:convert';
import 'package:raysto_server/src/generated/protocol.dart';
import 'package:raysto_server/src/platform/platform.dart';
import 'package:test/test.dart';
import 'accountant_fixture.dart';
import 'test_tools/serverpod_test_tools.dart';

// The derived journal over real records: sales, a receipt, bills and a
// manual adjustment. Isolated Raysto test database only; PayPal is a fake.
void main() {
  withServerpod('The derived ledger', (builder, endpoints) {
    late AccountantWorld world;
    setUp(() async {
      world = AccountantWorld(builder, 'ledger');
      await world.setUp();
    });
    tearDown(() => world.tearDown());

    test('a tipped PayPal sale posts sales, VAT and tips owed, with the fee flagged as an estimate', () async {
      await world.sale(quantity: 2, tipMinor: 300);
      final j = await world.read('ledger.journal');
      expect(j['balanced'], isTrue);
      expect(j['feesEstimated'], isTrue);
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      // 2 × 9.00 + 10% tax = 19.80, plus a 3.00 tip.
      expect(totals['1000']!['debitMinor'], 2280);
      expect(totals['4000']!['creditMinor'], 1800);
      expect(totals['2100']!['creditMinor'], 180);
      expect(totals['2200']!['creditMinor'], 300);
      expect(totals['6000']!['debitMinor'], LedgerModule.feeEstimate(2280));
      final capture = (j['rows'] as List).cast<Map>().firstWhere(
        (l) => (l['source'] as Map)['type'] == 'capture',
      );
      expect((capture['source'] as Map)['providerId'], startsWith('CAPTURE-'));
    });

    test('profit and loss, VAT and cash flow read the same journal', () async {
      await world.sale(quantity: 1);
      await BackOfficeModule.recordExpense(
        world.owner.build(),
        world.command({
          'category': 'cleaning',
          'amountMinor': 1100,
          'vatMinor': 100,
          'spentAt': DateTime.now().toUtc().toIso8601String(),
          'merchant': 'Clean Co',
        }),
      );
      final water = await world.bill({
        'vendor': 'City Water',
        'category': 'water',
        'amountMinor': 4400,
        'vatMinor': 400,
        'issuedAt': DateTime.now().toUtc().toIso8601String(),
        'dueAt': DateTime.now().toUtc().add(const Duration(days: 10)).toIso8601String(),
      }, approve: true);
      expect(water['state'], 'approved');
      final pnl = await world.read('ledger.pnl', {
        'month': DateTime.now().toUtc().toIso8601String().substring(0, 7),
      });
      final fee = LedgerModule.feeEstimate(990);
      expect(pnl['revenueMinor'], 900);
      expect(pnl['costsMinor'], fee + 1000 + 4000);
      expect(pnl['netMinor'], 900 - fee - 5000);
      final rows = (pnl['rows'] as List).cast<Map>();
      expect(rows.map((r) => r['account']).toSet(), containsAll(['4000', '6000', '6050', '6100']));
      expect(rows.firstWhere((r) => r['account'] == '6100')['accountName'], 'Utilities');

      final vat = await world.read('ledger.vat');
      expect(vat['collectedMinor'], 90);
      expect(vat['paidMinor'], 100 + 400);
      expect(vat['dueMinor'], 90 - 500);

      final flow = await world.read('ledger.cashflow', {'days': 14});
      expect((flow['forecast'] as List).length, 14);
      final due = [
        for (final d in (flow['forecast'] as List).cast<Map>()) ...(d['items'] as List).cast<Map>(),
      ];
      expect(due.single['vendor'], 'City Water');
      expect(due.single['kind'], 'billDue');
      expect(flow['basis'], contains('estimate'));
    });

    test('an adjustment is the owner\'s, needs a reason, and keeps the books balanced', () async {
      final made = await LedgerModule.adjust(
        world.owner.build(),
        world.command({
          'debitAccount': '1010',
          'creditAccount': '3000',
          'amountMinor': 50000,
          'reason': 'Opening cash in the till',
        }),
      );
      expect(made['adjustmentId'], isA<int>());
      await world.expectFailure(
        () => LedgerModule.adjust(
          world.owner.build(),
          world.command({'debitAccount': '1010', 'creditAccount': '1010', 'amountMinor': 1, 'reason': 'x'}),
        ),
        'invalid_input',
      );
      await world.expectFailure(
        () => LedgerModule.adjust(
          world.customer.build(),
          world.command({'debitAccount': '1010', 'creditAccount': '3000', 'amountMinor': 1, 'reason': 'x'}),
        ),
        'forbidden',
      );
      final j = await world.read('ledger.journal');
      expect(j['balanced'], isTrue);
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      expect(totals['1010']!['balanceMinor'], 50000);
      expect(totals['3000']!['balanceMinor'], 50000);
      final audit = await AuditRecord.db.findFirstRow(
        builder.build(),
        where: (t) => t.restaurantId.equals(world.restaurant.id!) & t.kind.equals('ledger.adjusted'),
      );
      expect(audit, isNotNull);
    });

    test('only finance roles read the journal', () async {
      await world.expectFailure(
        () => LedgerModule.read(
          world.customer.build(),
          restaurantId: world.restaurant.id!,
          name: 'ledger.journal',
        ),
        'forbidden',
      );
    });

    test('the daily close reads the day\'s books from the journal', () async {
      await world.sale(quantity: 1);
      await world.bill({
        'vendor': 'Power Co',
        'category': 'electricity',
        'amountMinor': 7000,
        'issuedAt': DateTime.now().toUtc().toIso8601String(),
      }, approve: true);
      final day = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      final read = await CloseAgent.readDay(builder.build(), world.restaurant.id!, day);
      final books = read['books'] as Map;
      expect(books['billsRecognisedMinor'], 7000);
      expect(books['cashInMinor'], 990);
      expect(books['balanced'], isTrue);
      expect(books['netProfitMinor'], 900 - LedgerModule.feeEstimate(990) - 7000);
      // The existing figures of the close are unchanged.
      expect(read['paypalCapturedMinor'], 990);
      expect(jsonEncode(read), isNot(contains('"error"')));
    });

    test('a cash refund leaves the till, and a judges\' café\'s sample rows say so', () async {
      final s = builder.build();
      final rid = world.restaurant.id!;
      final now = DateTime.now().toUtc();
      // Cash at the till, one item handed back in cash; the requestKey of a
      // judges' café's stored history marks it as a sample.
      Future<void> cash(String key, int amount, {int refund = 0, DateTime? spent}) async {
        final i = await CheckoutIntent.db.insertRow(
          s,
          CheckoutIntent(
            restaurantId: rid,
            userId: world.ownerId,
            requestKey: key,
            requestHash: 'h',
            providerRequestId: key,
            merchantId: 'cash',
            state: 'completed',
            method: 'cash',
            currency: 'USD',
            amountMinor: amount,
            commissionMinor: 0,
            commissionBps: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
        final c = await PaymentCapture.db.insertRow(
          s,
          PaymentCapture(
            restaurantId: rid,
            checkoutId: i.id!,
            providerCaptureId: 'cash:$key',
            amountMinor: amount,
            refundedMinor: refund,
            currency: 'USD',
            state: 'completed',
            createdAt: now,
          ),
        );
        if (refund > 0) {
          await PaymentRefund.db.insertRow(
            s,
            PaymentRefund(
              restaurantId: rid,
              captureId: c.id!,
              requestKey: '$key:refund',
              providerRefundId: 'cash-refund:$key',
              allocationJson: '{"allocations":[]}',
              amountMinor: refund,
              commissionMinor: 0,
              reason: 'Handed back at the counter',
              state: 'completed',
              createdBy: world.ownerId,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }

      await cash('till-1', 1500, refund: 400);
      await cash('sample:$rid:2026-10-14:001', 2000, refund: 300);
      final j = await world.read('ledger.journal');
      expect(j['balanced'], isTrue);
      final totals = {for (final t in (j['totals'] as List).cast<Map>()) t['account']: t};
      expect(totals['1010']!['debitMinor'], 3500);
      expect(totals['1010']!['creditMinor'], 700, reason: 'cash refunds leave the till');
      expect(totals['4090']!['debitMinor'], 700);
      expect(totals.containsKey('1000'), isFalse, reason: 'no PayPal money moved');
      expect(totals.containsKey('6000'), isFalse, reason: 'no PayPal fee on cash');
      final rows = (j['rows'] as List).cast<Map>();
      Map source(String type, String provider) => rows
          .firstWhere(
            (l) =>
                (l['source'] as Map)['type'] == type &&
                (l['source'] as Map)['providerId'] == provider,
          )['source'] as Map;
      expect(source('capture', 'cash:till-1').containsKey('sample'), isFalse);
      expect(source('refund', 'cash-refund:till-1').containsKey('sample'), isFalse);
      expect(source('capture', 'cash:sample:$rid:2026-10-14:001')['sample'], isTrue);
      expect(source('refund', 'cash-refund:sample:$rid:2026-10-14:001')['sample'], isTrue);

      // A seeded cost on a judges' café carries the flag too; a person's
      // expense of the same kind does not.
      world.env['RAYSTO_JUDGE_RESTAURANT_ID'] = '$rid';
      final spent = now.subtract(const Duration(hours: 3));
      for (final created in [spent, now]) {
        await Expense.db.insertRow(
          s,
          Expense(
            restaurantId: rid,
            category: 'staff',
            amountMinor: 44800,
            currency: 'USD',
            vatMinor: 0,
            spentAt: spent,
            merchant: JudgeHistory.payroll,
            createdAt: created,
          ),
        );
      }
      final expenses = [
        for (final l in ((await world.read('ledger.journal'))['rows'] as List).cast<Map>())
          if ((l['source'] as Map)['type'] == 'expense' && l['account'] == '6020') l['source'] as Map,
      ];
      expect(expenses, hasLength(2));
      expect(expenses.where((x) => x['sample'] == true), hasLength(1));
    });
  });
}
