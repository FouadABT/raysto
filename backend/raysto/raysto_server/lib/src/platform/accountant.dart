part of 'platform.dart';

/// Bills the café owes (payables): intake by photo or PDF read by the
/// accountant agent, or typed by hand; approval; payment through PayPal
/// Payouts to the vendor's PayPal email, or "paid elsewhere" with a proof.
/// A monthly bill leaves an expected copy for next month once it is paid.
/// Owner: stream S1.
class BillsModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'bill.snap': snap,
    'bill.save': save,
    'bill.approve': approve,
    'bill.pay': pay,
    'bill.markPaid': markPaid,
    'bill.void': voidBill,
    'expense.categorise': categorise,
    'accountant.run': AccountantAgent.runCommand,
  };

  static const categories = {
    'electricity',
    'water',
    'gas',
    'rent',
    'internet',
    'phone',
    'insurance',
    'supplier',
    'maintenance',
    'tax',
    'other',
  };

  /// `expected` is next month's copy of a monthly bill: a forecast, not a
  /// debt, until the real bill replaces it.
  static const states = {
    'expected',
    'review',
    'approved',
    'paying',
    'paid',
    'paidElsewhere',
    'void',
  };
  static const open = {'expected', 'review', 'approved', 'paying'};
  static const _editable = {'expected', 'review', 'approved'};
  static const _filePurposes = {'bill', 'receipt'};

  // ---- Helpers --------------------------------------------------------------

  static Future<Bill> _bill(Work w, int id, {bool lock = false}) async {
    final b = await Bill.db.findById(
      w.s,
      id,
      transaction: w.tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (b == null || b.restaurantId != w.tenant) {
      _fail('not_found', 'Bill not found.');
    }
    return b;
  }

  static Future<MediaAsset> _file(Work w, int id, String what) async {
    final m = await MediaAsset.db.findById(w.s, id, transaction: w.tx);
    if (m == null ||
        m.restaurantId != w.tenant ||
        !_filePurposes.contains(m.purpose)) {
      _fail('not_found', '$what not found.');
    }
    if (m.status == 'rejected') {
      _fail('invalid_file', 'The file scanner refused this file.');
    }
    if (m.status != 'approved') {
      _fail(
        'media_pending',
        'Still checking this file. Try again in a moment.',
      );
    }
    return m;
  }

  static DateTime? _optDate(Json d, String k) =>
      d[k] == null ? null : _date(d, k);

  static DateTime _addMonth(DateTime at) {
    final next = DateTime.utc(at.year, at.month + 1, 1);
    final last = DateTime.utc(next.year, next.month + 1, 0).day;
    return DateTime.utc(
      next.year,
      next.month,
      min(at.day, last),
      at.hour,
      at.minute,
    );
  }

  /// A bill already on file that this one repeats: the same file, or the
  /// same vendor, reference and amount.
  static Future<Bill?> _duplicateOf(
    Work w, {
    required String vendor,
    required String? reference,
    required int amountMinor,
    String? contentSha,
    int? except,
  }) async {
    if (contentSha != null) {
      final same = await Bill.db.findFirstRow(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.contentSha.equals(contentSha) &
            t.state.notInSet({'void', 'expected'}),
        transaction: w.tx,
      );
      if (same != null && same.id != except) return same;
    }
    if (reference == null) return null;
    final rows = await Bill.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.reference.equals(reference) &
          t.amountMinor.equals(amountMinor) &
          t.state.notInSet({'void', 'expected'}),
      limit: 20,
      transaction: w.tx,
    );
    return rows
        .where(
          (b) =>
              b.id != except &&
              b.vendor.trim().toLowerCase() == vendor.trim().toLowerCase(),
        )
        .firstOrNull;
  }

  /// A real bill replaces last month's expected copy of the same vendor
  /// and category, and carries on its monthly chain.
  static Future<void> _replaceExpected(Work w, Bill b) async {
    final expected = await Bill.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.state.equals('expected') &
          t.category.equals(b.category),
      limit: 20,
      transaction: w.tx,
    );
    final match = expected
        .where(
          (e) =>
              e.id != b.id &&
              e.vendor.trim().toLowerCase() == b.vendor.trim().toLowerCase(),
        )
        .firstOrNull;
    if (match == null) return;
    match
      ..state = 'void'
      ..readJson = jsonEncode({..._json(match.readJson), 'replacedBy': b.id})
      ..version += 1
      ..updatedAt = _now();
    await Bill.db.updateRow(w.s, match, transaction: w.tx);
    b
      ..recurring ??= 'monthly'
      ..recurringOfId ??= match.recurringOfId
      ..payeeEmail ??= match.payeeEmail
      ..payVia = (b.payeeEmail ?? match.payeeEmail) == null
          ? 'elsewhere'
          : 'paypal'
      ..version += 1
      ..updatedAt = _now();
    await Bill.db.updateRow(w.s, b, transaction: w.tx);
  }

  /// Once a monthly bill is paid, next month's copy is expected.
  static Future<void> _next(Work w, Bill b) async {
    if (b.recurring != 'monthly') return;
    final existing = await Bill.db.count(
      w.s,
      where: (t) => t.recurringOfId.equals(b.id!),
      transaction: w.tx,
    );
    if (existing > 0) return;
    final base = b.dueAt ?? b.issuedAt ?? b.createdAt;
    final copy = await Bill.db.insertRow(
      w.s,
      Bill(
        restaurantId: b.restaurantId,
        vendor: b.vendor,
        category: b.category,
        amountMinor: b.amountMinor,
        vatMinor: b.vatMinor,
        currency: b.currency,
        dueAt: _addMonth(base),
        periodFrom: b.periodFrom == null ? null : _addMonth(b.periodFrom!),
        periodTo: b.periodTo == null ? null : _addMonth(b.periodTo!),
        state: 'expected',
        payVia: b.payVia == 'paypal' && b.payeeEmail != null
            ? 'paypal'
            : 'elsewhere',
        payeeEmail: b.payeeEmail,
        recurring: 'monthly',
        recurringOfId: b.id,
        supplierId: b.supplierId,
        readJson: jsonEncode({
          'expected': true,
          'basis':
              'Same as last month; the real bill replaces it when it arrives.',
        }),
        version: 1,
        createdAt: _now(),
        updatedAt: _now(),
      ),
      transaction: w.tx,
    );
    await w.audit('bill.expected', 'bill', copy.id, {'after': b.id});
  }

  // ---- Intake ---------------------------------------------------------------

  /// A photo or PDF of a bill goes to the accountant agent, which reads it
  /// and leaves the bill in review. The same file twice is caught here,
  /// before any AI is spent.
  static Future<Json> snap(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'bill.snap',
    (w, d) async {
      _keys(d, {'mediaId'});
      final m = await _file(
        w,
        _int(d, 'mediaId', min: 1, max: 1 << 31),
        'Bill file',
      );
      final same = await Bill.db.findFirstRow(
        s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.contentSha.equals(m.sha256) &
            t.state.notEquals('void'),
        transaction: w.tx,
      );
      if (same != null) {
        return {
          'mediaId': m.id,
          'duplicateOfId': same.id,
          'state': same.state,
          'taskId': null,
        };
      }
      final task = await AgentModule.enqueue(
        w,
        agent: AccountantAgent.agent,
        trigger: 'user',
        requestedBy: w.user,
        dedupeKey: 'bill:${w.tenant}:${m.id}',
        title: 'Read a bill',
        triggerRef: 'media:${m.id}',
        input: {'mode': 'bill', 'mediaId': m.id},
      );
      if (task == null) {
        _fail(
          'unavailable',
          'The accountant agent is switched off; enter the bill by hand.',
        );
      }
      await w.audit('bill.snapped', 'media', m.id, {'taskId': task.id});
      return {'mediaId': m.id, 'taskId': task.id, 'duplicateOfId': null};
    },
    roles: _finance,
  );

  /// The fields a person (or the agent's read) gives a bill, validated.
  static Json fields(Json d) {
    final amount = _int(d, 'amountMinor', min: 1, max: 100000000);
    final payee = d['payeeEmail'] == null || '${d['payeeEmail']}'.trim().isEmpty
        ? null
        : BackOfficeModule._email(d, 'payeeEmail');
    final reference =
        d['reference'] == null || '${d['reference']}'.trim().isEmpty
        ? null
        : _str(d, 'reference', max: 80);
    return {
      'vendor': _str(d, 'vendor', max: 120),
      'category': _str(d, 'category', choices: categories),
      'reference': reference,
      'amountMinor': amount,
      'vatMinor': _int(d, 'vatMinor', max: amount, fallback: 0),
      'issuedAt': _optDate(d, 'issuedAt'),
      'dueAt': _optDate(d, 'dueAt'),
      'periodFrom': _optDate(d, 'periodFrom'),
      'periodTo': _optDate(d, 'periodTo'),
      'payeeEmail': payee,
      'recurring': d['recurring'] == null || d['recurring'] == 'none'
          ? null
          : _str(d, 'recurring', choices: {'monthly'}),
    };
  }

  static const _fieldKeys = {
    'vendor',
    'category',
    'reference',
    'amountMinor',
    'vatMinor',
    'issuedAt',
    'dueAt',
    'periodFrom',
    'periodTo',
    'payeeEmail',
    'recurring',
  };

  /// A new bill (resourceId empty) or a correction to one not yet paid.
  /// `approve: true` approves it in the same step; a likely duplicate needs
  /// `notDuplicate: true` to be approved.
  static Future<Json> save(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'bill.save',
    (w, d) async {
      _keys(d, {..._fieldKeys, 'sourceMediaId', 'approve', 'notDuplicate'});
      final f = fields(d);
      final approveNow = _bool(d, 'approve');
      final notDuplicate = _bool(d, 'notDuplicate');
      final media = d['sourceMediaId'] == null
          ? null
          : await _file(
              w,
              _int(d, 'sourceMediaId', min: 1, max: 1 << 31),
              'Bill file',
            );
      Bill b;
      if (c.resourceId == null) {
        b = await Bill.db.insertRow(
          s,
          Bill(
            restaurantId: w.tenant,
            vendor: f['vendor'] as String,
            category: f['category'] as String,
            reference: f['reference'] as String?,
            amountMinor: f['amountMinor'] as int,
            vatMinor: f['vatMinor'] as int,
            currency: w.restaurant!.currency,
            issuedAt: f['issuedAt'] as DateTime?,
            dueAt: f['dueAt'] as DateTime?,
            periodFrom: f['periodFrom'] as DateTime?,
            periodTo: f['periodTo'] as DateTime?,
            state: 'review',
            payVia: f['payeeEmail'] == null ? 'elsewhere' : 'paypal',
            payeeEmail: f['payeeEmail'] as String?,
            recurring: f['recurring'] as String?,
            sourceMediaId: media?.id,
            contentSha: media?.sha256,
            readJson: jsonEncode({'from': 'person'}),
            version: 1,
            createdAt: _now(),
            updatedAt: _now(),
          ),
          transaction: w.tx,
        );
        await _replaceExpected(w, b);
      } else {
        b = await _bill(w, _id(c), lock: true);
        _version(b.version, c.expectedVersion);
        if (!_editable.contains(b.state)) {
          _fail('invalid_transition', 'A ${b.state} bill cannot be changed.');
        }
        b
          ..vendor = f['vendor'] as String
          ..category = f['category'] as String
          ..reference = f['reference'] as String?
          ..amountMinor = f['amountMinor'] as int
          ..vatMinor = f['vatMinor'] as int
          ..issuedAt = f['issuedAt'] as DateTime?
          ..dueAt = f['dueAt'] as DateTime?
          ..periodFrom = f['periodFrom'] as DateTime?
          ..periodTo = f['periodTo'] as DateTime?
          ..payeeEmail = f['payeeEmail'] as String?
          ..payVia = f['payeeEmail'] == null ? 'elsewhere' : 'paypal'
          ..recurring = d.containsKey('recurring')
              ? f['recurring'] as String?
              : b.recurring
          ..sourceMediaId = media?.id ?? b.sourceMediaId
          ..contentSha = media?.sha256 ?? b.contentSha
          ..state = b.state == 'expected' ? 'review' : b.state
          ..readJson = jsonEncode({..._json(b.readJson), 'correctedBy': w.user})
          ..version += 1
          ..updatedAt = _now();
      }
      final dup = await _duplicateOf(
        w,
        vendor: b.vendor,
        reference: b.reference,
        amountMinor: b.amountMinor,
        contentSha: b.contentSha,
        except: b.id,
      );
      b.duplicateOfId = notDuplicate ? null : dup?.id;
      if (approveNow) {
        if (b.duplicateOfId != null) {
          _fail(
            'duplicate_bill',
            'This looks like bill ${b.duplicateOfId}; confirm it is not a duplicate first.',
          );
        }
        if (b.state == 'review') b.state = 'approved';
      }
      b = await Bill.db.updateRow(s, b, transaction: w.tx);
      await w.audit(
        c.resourceId == null ? 'bill.created' : 'bill.corrected',
        'bill',
        b.id,
        {'amountMinor': b.amountMinor, 'state': b.state},
      );
      if (approveNow) {
        await w.audit('bill.approved', 'bill', b.id, {
          'amountMinor': b.amountMinor,
        });
      }
      return (await views(w, [b])).single;
    },
    roles: _finance,
  );

  static Future<Json> approve(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'bill.approve',
    (w, d) async {
      _keys(d, {'notDuplicate'});
      final b = await _bill(w, _id(c), lock: true);
      if (c.expectedVersion != null) _version(b.version, c.expectedVersion);
      if (b.state == 'approved') return (await views(w, [b])).single;
      if (b.state != 'review') {
        _fail('invalid_transition', 'Only a bill in review can be approved.');
      }
      _approve(b, notDuplicate: _bool(d, 'notDuplicate'));
      await Bill.db.updateRow(s, b, transaction: w.tx);
      await w.audit('bill.approved', 'bill', b.id, {
        'amountMinor': b.amountMinor,
      });
      return (await views(w, [b])).single;
    },
    roles: _finance,
  );

  static void _approve(Bill b, {bool notDuplicate = false}) {
    if (b.duplicateOfId != null && !notDuplicate) {
      _fail(
        'duplicate_bill',
        'This looks like bill ${b.duplicateOfId}; confirm it is not a duplicate first.',
      );
    }
    b
      ..duplicateOfId = null
      ..state = 'approved'
      ..version += 1
      ..updatedAt = _now();
  }

  // ---- Paying ---------------------------------------------------------------

  /// Pays an approved bill through PayPal Payouts after the identity check.
  /// The bill and its batch are claimed first; PayPal is called after that
  /// commits, under the batch's own idempotency key, so a retry after a
  /// lost answer reuses the same batch and can never pay twice.
  static Future<Json> pay(Session s, PlatformCommand c) async {
    final claim = await _mutate(
      s,
      c,
      'bill.pay',
      (w, d) async {
        _keys(d, {'approve', 'notDuplicate'});
        await _stepUp(w);
        final b = await _bill(w, _id(c), lock: true);
        return _claim(
          w,
          b,
          approve: _bool(d, 'approve'),
          notDuplicate: _bool(d, 'notDuplicate'),
        );
      },
      roles: _finance,
    );
    return _send(s, c.restaurantId!, claim);
  }

  static Future<Json> _claim(
    Work w,
    Bill b, {
    bool approve = false,
    bool notDuplicate = false,
  }) async {
    if (b.state == 'paying' || b.state == 'paid') {
      final batch = b.payoutBatchId == null
          ? null
          : await PayoutBatch.db.findById(
              w.s,
              b.payoutBatchId!,
              transaction: w.tx,
            );
      if (batch?.state == 'sending') {
        _fail(
          'payment_pending',
          'PayPal is being asked to pay this bill. Try again in a minute.',
        );
      }
      return {
        'billId': b.id,
        'state': b.state,
        'batchId': b.payoutBatchId,
        'providerBatchId': batch?.providerBatchId,
      };
    }
    if (b.state == 'review' && approve) {
      _approve(b, notDuplicate: notDuplicate);
    }
    if (b.state != 'approved') {
      _fail('invalid_transition', 'Approve this bill before paying it.');
    }
    if (b.payVia != 'paypal' || b.payeeEmail == null) {
      _fail(
        'payee_missing',
        'This vendor has no PayPal email; mark the bill paid elsewhere with a proof instead.',
      );
    }
    if (b.currency != w.restaurant!.currency) {
      _fail('invalid_input', 'The bill is in another currency.');
    }
    PayoutBatch? batch = b.payoutBatchId == null
        ? null
        : await PayoutBatch.db.findById(
            w.s,
            b.payoutBatchId!,
            transaction: w.tx,
          );
    // A batch whose PayPal call failed without an answer is reused, so its
    // idempotency key protects the retry.
    if (batch != null && batch.state != 'proposed') batch = null;
    if (batch == null) {
      batch = await PayoutBatch.db.insertRow(
        w.s,
        PayoutBatch(
          restaurantId: w.tenant,
          kind: 'bill',
          periodFrom: b.periodFrom ?? b.issuedAt ?? b.createdAt,
          periodTo: b.periodTo ?? b.dueAt ?? _now(),
          totalMinor: b.amountMinor,
          currency: b.currency,
          state: 'sending',
          requestKey: 'bill-${b.id}-${_uuid().substring(0, 8)}',
          taskId: b.taskId,
          summaryJson: jsonEncode({
            'billId': b.id,
            'vendor': b.vendor,
            'reference': b.reference,
          }),
          createdAt: _now(),
          updatedAt: _now(),
        ),
        transaction: w.tx,
      );
      await PayoutItem.db.insertRow(
        w.s,
        PayoutItem(
          restaurantId: w.tenant,
          batchId: batch.id!,
          recipientEmail: b.payeeEmail!,
          recipientName: b.vendor,
          shiftIdsJson: '[]',
          amountMinor: b.amountMinor,
          note: 'Bill ${b.reference ?? '#${b.id}'} from ${w.restaurant!.name}',
          state: 'pending',
        ),
        transaction: w.tx,
      );
    } else {
      batch
        ..state = 'sending'
        ..updatedAt = _now();
      await PayoutBatch.db.updateRow(w.s, batch, transaction: w.tx);
    }
    final items = await PayoutItem.db.find(
      w.s,
      where: (t) => t.batchId.equals(batch!.id!),
      transaction: w.tx,
    );
    b
      ..state = 'paying'
      ..payoutBatchId = batch.id
      ..version += 1
      ..updatedAt = _now();
    await Bill.db.updateRow(w.s, b, transaction: w.tx);
    await w.audit('bill.paying', 'bill', b.id, {
      'batchId': batch.id,
      'amountMinor': b.amountMinor,
    });
    return {
      'billId': b.id,
      'state': 'paying',
      'batchId': batch.id,
      'requestKey': batch.requestKey,
      'currency': batch.currency,
      'subject': 'Payment from ${w.restaurant!.name}',
      'items': [
        for (final i in items)
          {
            'email': i.recipientEmail,
            'amountMinor': i.amountMinor,
            'note': i.note,
            'itemId': 'item-${i.id}',
          },
      ],
    };
  }

  static Future<Json> _send(Session s, int rid, Json claim) async {
    if (claim['state'] != 'paying' || claim['requestKey'] == null) return claim;
    final batchId = claim['batchId'] as int;
    final billId = claim['billId'] as int;
    final current = await PayoutBatch.db.findById(s, batchId);
    if (current?.state != 'sending') {
      return {
        'billId': billId,
        'state': 'paying',
        'batchId': batchId,
        'providerBatchId': current?.providerBatchId,
      };
    }
    // 0.16 (S6): the café's own PayPal app when it has one.
    final account = await MerchantAppModule.forRestaurant(s, rid);
    Json sent;
    try {
      sent = await ProviderClients.createPayout(
        batchId: claim['requestKey'] as String,
        currency: claim['currency'] as String,
        items: (claim['items'] as List).cast<Json>(),
        subject: claim['subject'] as String,
        account: account,
      );
    } catch (_) {
      await AgentModule.asAgent(s, rid, (w) async {
        final b = await PayoutBatch.db.findById(s, batchId, transaction: w.tx);
        if (b?.state == 'sending') {
          b!
            ..state = 'proposed'
            ..updatedAt = _now();
          await PayoutBatch.db.updateRow(s, b, transaction: w.tx);
        }
        final bill = await Bill.db.findById(s, billId, transaction: w.tx);
        if (bill?.state == 'paying') {
          bill!
            ..state = 'approved'
            ..version += 1
            ..updatedAt = _now();
          await Bill.db.updateRow(s, bill, transaction: w.tx);
        }
      });
      rethrow;
    }
    return AgentModule.asAgent<Json>(s, rid, (w) async {
      final b = (await PayoutBatch.db.findById(s, batchId, transaction: w.tx))!;
      if (b.state == 'sending') {
        b
          ..state = 'sent'
          ..providerBatchId = sent['id'] as String
          ..summaryJson = jsonEncode({
            ..._json(b.summaryJson),
            'providerStatus': sent['status'],
            'paypal': MerchantAppModule.route(account),
          })
          ..updatedAt = _now();
        await PayoutBatch.db.updateRow(s, b, transaction: w.tx);
        await PayoutItem.db.updateWhere(
          s,
          columnValues: (t) => [t.state('sent')],
          where: (t) => t.batchId.equals(b.id!),
          transaction: w.tx,
        );
        await w.audit('payout.sent', 'payoutBatch', b.id, {
          'kind': 'bill',
          'billId': billId,
          'totalMinor': b.totalMinor,
          'providerBatchId': b.providerBatchId,
        });
        await w.job('payout.poll', 'payout-poll:${b.id}:0', {
          'batchId': b.id,
          'attempt': 0,
        }, at: _now().add(const Duration(seconds: 30)));
      }
      return {
        'billId': billId,
        'state': 'paying',
        'batchId': b.id,
        'providerBatchId': b.providerBatchId,
        'providerStatus': sent['status'],
      };
    });
  }

  /// Bills follow their PayPal batch: completed means paid, failed means
  /// the bill is approved again with the reason kept.
  static Future<void> sync(Work w) async {
    final paying = await Bill.db.find(
      w.s,
      where: (t) => t.restaurantId.equals(w.tenant) & t.state.equals('paying'),
      transaction: w.tx,
    );
    for (final b in paying) {
      if (b.payoutBatchId == null) continue;
      final batch = await PayoutBatch.db.findById(
        w.s,
        b.payoutBatchId!,
        transaction: w.tx,
      );
      if (batch == null) continue;
      if (batch.state == 'completed') {
        b
          ..state = 'paid'
          ..paidAt = batch.updatedAt
          ..version += 1
          ..updatedAt = _now();
        await Bill.db.updateRow(w.s, b, transaction: w.tx);
        await w.audit('bill.paid', 'bill', b.id, {
          'providerBatchId': batch.providerBatchId,
          'amountMinor': b.amountMinor,
        });
        await _next(w, b);
      } else if (batch.state == 'failed') {
        b
          ..state = 'approved'
          ..readJson = jsonEncode({
            ..._json(b.readJson),
            'payoutFailed':
                _json(batch.summaryJson)['providerStatus'] ?? 'FAILED',
            'failedBatchId': batch.id,
          })
          ..version += 1
          ..updatedAt = _now();
        await Bill.db.updateRow(w.s, b, transaction: w.tx);
        await w.audit('bill.payout_failed', 'bill', b.id, {
          'providerBatchId': batch.providerBatchId,
        });
      }
    }
  }

  /// Paid outside PayPal (bank transfer, direct debit, cash): a proof is
  /// required and kept with the bill.
  static Future<Json> markPaid(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'bill.markPaid',
    (w, d) async {
      _keys(d, {'proofMediaId', 'paidAt', 'note', 'notDuplicate'});
      final b = await _bill(w, _id(c), lock: true);
      if (c.expectedVersion != null) _version(b.version, c.expectedVersion);
      if (b.state == 'paidElsewhere') return (await views(w, [b])).single;
      if (b.state == 'paying') {
        _fail('payment_pending', 'PayPal is paying this bill already.');
      }
      if (!_editable.contains(b.state)) {
        _fail('invalid_transition', 'A ${b.state} bill cannot be marked paid.');
      }
      if (b.duplicateOfId != null && !_bool(d, 'notDuplicate')) {
        _fail(
          'duplicate_bill',
          'This looks like bill ${b.duplicateOfId}; confirm it is not a duplicate first.',
        );
      }
      final proof = await _file(
        w,
        _int(d, 'proofMediaId', min: 1, max: 1 << 31),
        'Proof of payment',
      );
      final paidAt = d['paidAt'] == null ? _now() : _date(d, 'paidAt');
      if (paidAt.isAfter(_now().add(const Duration(days: 1)))) {
        _fail('invalid_input', 'The payment date is in the future.');
      }
      b
        ..state = 'paidElsewhere'
        ..payVia = 'elsewhere'
        ..proofMediaId = proof.id
        ..paidAt = paidAt
        ..duplicateOfId = null
        ..readJson = jsonEncode({
          ..._json(b.readJson),
          if (d['note'] != null) 'paidNote': _str(d, 'note', max: 300),
          'markedPaidBy': w.user,
        })
        ..version += 1
        ..updatedAt = _now();
      await Bill.db.updateRow(s, b, transaction: w.tx);
      await w.audit('bill.paid_elsewhere', 'bill', b.id, {
        'proofMediaId': proof.id,
        'amountMinor': b.amountMinor,
      });
      await _next(w, b);
      return (await views(w, [b])).single;
    },
    roles: _finance,
  );

  static Future<Json> voidBill(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'bill.void',
    (w, d) async {
      _keys(d, {'reason'});
      final b = await _bill(w, _id(c), lock: true);
      if (c.expectedVersion != null) _version(b.version, c.expectedVersion);
      if (b.state == 'void') return (await views(w, [b])).single;
      if (!_editable.contains(b.state)) {
        _fail('invalid_transition', 'A ${b.state} bill cannot be voided.');
      }
      b
        ..state = 'void'
        ..readJson = jsonEncode({
          ..._json(b.readJson),
          'voidReason': _str(d, 'reason', max: 300),
        })
        ..version += 1
        ..updatedAt = _now();
      await Bill.db.updateRow(s, b, transaction: w.tx);
      await w.audit('bill.voided', 'bill', b.id);
      return (await views(w, [b])).single;
    },
    roles: _finance,
  );

  /// A receipt's category corrected by a person (or the accountant's
  /// proposal, approved by one).
  static Future<Json> categorise(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'expense.categorise',
    (w, d) async {
      _keys(d, {'category'});
      final e = await Expense.db.findById(s, _id(c), transaction: w.tx);
      if (e == null || e.restaurantId != w.tenant) {
        _fail('not_found', 'Expense not found.');
      }
      final category = _str(
        d,
        'category',
        choices: BackOfficeModule.expenseCategories,
      );
      final before = e.category;
      e.category = category;
      await Expense.db.updateRow(s, e, transaction: w.tx);
      await w.audit('expense.categorised', 'expense', e.id, {
        'from': before,
        'to': category,
      });
      return {'expenseId': e.id, 'category': category, 'previous': before};
    },
    roles: _finance,
  );

  // ---- Autonomy -------------------------------------------------------------

  /// Within the owner's limits a monthly bill to a payee already paid
  /// through PayPal is paid by the agent itself and recorded as an action
  /// already executed. Anything else, or anything PayPal or the ledger
  /// refuses, waits for a person. Returns null when it did not pay.
  static Future<Json?> payAsAgent(
    Session s,
    AgentTask task,
    int billId,
    String rationale,
  ) async {
    final policy = await RestaurantPolicy.db.findFirstRow(
      s,
      where: (t) => t.restaurantId.equals(task.restaurantId),
    );
    final autonomy = CatalogueModule.validateAutonomy(
      _object(_json(policy?.settingsJson ?? '{}')['autonomy'] ?? {}),
    );
    final maxMinor = autonomy['billsMaxMinor'] as int;
    final perDay = autonomy['billsPerDay'] as int;
    final knownOnly = autonomy['billsKnownPayeesOnly'] as bool;
    final b = await Bill.db.findById(s, billId);
    if (b == null ||
        maxMinor <= 0 ||
        perDay <= 0 ||
        b.amountMinor > maxMinor ||
        b.payVia != 'paypal' ||
        b.payeeEmail == null ||
        b.duplicateOfId != null ||
        !{'review', 'approved'}.contains(b.state) ||
        (b.recurring != 'monthly' && b.recurringOfId == null)) {
      return null;
    }
    final today = await AgentAction.db.count(
      s,
      where: (t) =>
          t.restaurantId.equals(task.restaurantId) &
          t.agent.equals(AccountantAgent.agent) &
          t.command.equals('bill.pay') &
          t.status.equals('auto') &
          (t.createdAt > _now().subtract(const Duration(hours: 24))),
    );
    if (today >= perDay) return null;
    if (knownOnly) {
      final known = await Bill.db.count(
        s,
        where: (t) =>
            t.restaurantId.equals(task.restaurantId) &
            t.payeeEmail.equals(b.payeeEmail!) &
            t.state.equals('paid'),
      );
      if (known == 0) return null;
    }
    Json sent;
    try {
      final claim = await AgentModule.asAgent<Json>(s, task.restaurantId, (
        w,
      ) async {
        final fresh = await _bill(w, billId, lock: true);
        return _claim(w, fresh, approve: true);
      });
      sent = await _send(s, task.restaurantId, claim);
    } on DomainError {
      return null;
    }
    final key = 'bill:$billId:auto';
    final result = {
      'billId': billId,
      'batchId': sent['batchId'],
      'providerBatchId': sent['providerBatchId'],
      'amountMinor': b.amountMinor,
      'currency': b.currency,
      'auto': true,
      'limitMinor': maxMinor,
    };
    await AgentModule.asAgent(s, task.restaurantId, (w) async {
      await AgentAction.db.insertRow(
        w.s,
        AgentAction(
          restaurantId: task.restaurantId,
          taskId: task.id!,
          agent: AccountantAgent.agent,
          ordinal: 0,
          command: 'bill.pay',
          title:
              'Paid ${b.vendor}: ${PayPalGateway.money(b.amountMinor)} ${b.currency} (within your limit)',
          rationale: rationale,
          payloadJson: jsonEncode({'billId': billId}),
          previewJson: jsonEncode({
            'vendor': b.vendor,
            'amountMinor': b.amountMinor,
            'currency': b.currency,
            'payeeEmail': b.payeeEmail,
          }),
          evidenceJson: jsonEncode({
            'recurring': true,
            'knownPayee': knownOnly,
            'limitMinor': maxMinor,
          }),
          risk: 'money',
          contextHash: _hash(key),
          status: 'auto',
          approverUserId: w.user,
          executionKey: key,
          resultJson: jsonEncode(result),
          version: 1,
          expiresAt: _now(),
          decidedAt: _now(),
          createdAt: _now(),
        ),
        transaction: w.tx,
      );
      await w.audit('agent.auto_executed', 'bill', billId, {
        'command': 'bill.pay',
        'amountMinor': b.amountMinor,
        'providerBatchId': sent['providerBatchId'],
      });
    });
    return result;
  }

  // ---- Reads ----------------------------------------------------------------

  static String bucket(int days) => days <= 30
      ? '0–30'
      : days <= 60
      ? '31–60'
      : days <= 90
      ? '61–90'
      : '90+';

  static Future<List<Json>> views(Work w, List<Bill> rows) async {
    final batchIds = {for (final b in rows) ?b.payoutBatchId};
    final batches = batchIds.isEmpty
        ? const <int, PayoutBatch>{}
        : {
            for (final x in await PayoutBatch.db.find(
              w.s,
              where: (t) => t.id.inSet(batchIds),
              transaction: w.tx,
            ))
              x.id!: x,
          };
    final items = batchIds.isEmpty
        ? const <int, PayoutItem>{}
        : {
            for (final x in await PayoutItem.db.find(
              w.s,
              where: (t) => t.batchId.inSet(batchIds),
              transaction: w.tx,
            ))
              x.batchId: x,
          };
    final now = _now();
    return [
      for (final b in rows)
        () {
          final batch = batches[b.payoutBatchId];
          final read = _json(b.readJson);
          final age = now.difference(b.issuedAt ?? b.createdAt).inDays;
          final isOpen = open.contains(b.state) && b.state != 'expected';
          return <String, dynamic>{
            'id': b.id,
            'vendor': b.vendor,
            'category': b.category,
            'account': LedgerModule.billAccounts[b.category] ?? '6190',
            'accountName': LedgerModule
                .accounts[LedgerModule.billAccounts[b.category] ?? '6190'],
            'reference': b.reference,
            'amountMinor': b.amountMinor,
            'vatMinor': b.vatMinor,
            'currency': b.currency,
            'issuedAt': b.issuedAt?.toIso8601String(),
            'dueAt': b.dueAt?.toIso8601String(),
            'periodFrom': b.periodFrom?.toIso8601String(),
            'periodTo': b.periodTo?.toIso8601String(),
            'state': b.state,
            'payVia': b.payVia,
            'payeeEmail': b.payeeEmail,
            'recurring': b.recurring,
            'recurringOfId': b.recurringOfId,
            'sourceMediaId': b.sourceMediaId,
            'proofMediaId': b.proofMediaId,
            'duplicateOfId': b.duplicateOfId,
            'supplierId': b.supplierId,
            'supplierOrderId': b.supplierOrderId,
            'payoutBatchId': b.payoutBatchId,
            'payoutState': batch?.state,
            'providerBatchId': batch?.providerBatchId,
            'providerItemId': items[b.payoutBatchId]?.providerItemId,
            'read': {
              if (read['from'] != null) 'from': read['from'],
              if (read['confidence'] != null) 'confidence': read['confidence'],
              if (read['notes'] != null) 'notes': read['notes'],
              if (read['explanation'] != null)
                'explanation': read['explanation'],
              if (read['payoutFailed'] != null)
                'payoutFailed': read['payoutFailed'],
              if (read['voidReason'] != null) 'voidReason': read['voidReason'],
              if (read['paidNote'] != null) 'paidNote': read['paidNote'],
              if (read['basis'] != null) 'basis': read['basis'],
            },
            'taskId': b.taskId,
            'paidAt': b.paidAt?.toIso8601String(),
            'overdue': isOpen && b.dueAt != null && b.dueAt!.isBefore(now),
            'ageDays': isOpen ? age : null,
            'bucket': isOpen ? bucket(age) : null,
            'version': b.version,
            'createdAt': b.createdAt.toIso8601String(),
            'updatedAt': b.updatedAt.toIso8601String(),
          };
        }(),
    ];
  }

  static Json summary(Json settings, List<Json> views) {
    int sum(bool Function(Json) test) =>
        views.where(test).fold<int>(0, (n, v) => n + (v['amountMinor'] as int));
    final month = BackOfficeModule.localDay(
      {'timezone': 'UTC', ...settings},
      _now(),
    ).substring(0, 7);
    final aging = {'0–30': 0, '31–60': 0, '61–90': 0, '90+': 0};
    for (final v in views.where((v) => v['bucket'] != null)) {
      aging[v['bucket'] as String] =
          aging[v['bucket'] as String]! + (v['amountMinor'] as int);
    }
    return {
      'dueMinor': sum(
        (v) => {'review', 'approved', 'paying'}.contains(v['state']),
      ),
      'overdueMinor': sum((v) => v['overdue'] == true),
      'overdueCount': views.where((v) => v['overdue'] == true).length,
      'reviewCount': views.where((v) => v['state'] == 'review').length,
      'expectedMinor': sum((v) => v['state'] == 'expected'),
      'paidThisMonthMinor': sum(
        (v) =>
            {'paid', 'paidElsewhere'}.contains(v['state']) &&
            '${v['paidAt']}'.startsWith(month),
      ),
      'aging': aging,
    };
  }

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    switch (name) {
      case 'bills':
        await w.role(_finance);
        await sync(w);
        final state = d['state'] == null
            ? null
            : _str(d, 'state', choices: {...states, 'open'});
        final rows = await Bill.db.find(
          w.s,
          where: (t) => state == null
              ? t.restaurantId.equals(w.tenant)
              : state == 'open'
              ? t.restaurantId.equals(w.tenant) & t.state.inSet(open)
              : t.restaurantId.equals(w.tenant) & t.state.equals(state),
          orderBy: (t) => t.id.desc(),
          limit: 500,
          transaction: w.tx,
        );
        final v = await views(w, rows);
        // The console's overview asks for the rules' findings with the bills
        // (`withFindings`), so one read serves both.
        final withFindings =
            d['withFindings'] == true || d['withFindings'] == 'true';
        if (withFindings) await PaymentRequestModule.sync(w);
        return {
          'rows': v,
          'nextCursor': null,
          'currency': w.restaurant!.currency,
          'summary': summary(w.settings, v),
          'categories': categories.toList(),
          if (withFindings) 'findings': await AccountantAgent.anomalies(w),
        };
      case 'bill':
        await w.role(_finance);
        await sync(w);
        final b = await _bill(w, _int(d, 'id', min: 1, max: 1 << 31));
        final view = (await views(w, [b])).single;
        final items = b.payoutBatchId == null
            ? const <PayoutItem>[]
            : await PayoutItem.db.find(
                w.s,
                where: (t) => t.batchId.equals(b.payoutBatchId!),
                transaction: w.tx,
              );
        return {
          ...view,
          'payoutItems': [
            for (final i in items)
              {
                'recipientEmail': i.recipientEmail,
                'amountMinor': i.amountMinor,
                'state': i.state,
                'providerItemId': i.providerItemId,
              },
          ],
        };
      case 'accountant.anomalies':
        await w.role(_finance);
        await sync(w);
        await PaymentRequestModule.sync(w);
        return {
          'rows': await AccountantAgent.anomalies(w),
          'nextCursor': null,
          'currency': w.restaurant!.currency,
        };
    }
    return null;
  }
}

/// Money the café is owed (receivables): a pay link (an Orders v2 checkout
/// made when the payer opens it) or a PayPal invoice through PayPal's MCP
/// server once Invoicing is enabled on the Sandbox app. Owner: stream S1.
class PaymentRequestModule {
  /// Commands registered in PlatformApi.commands (platform.dart, 0.16 anchor).
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'request.create': create,
    'request.send': send,
    'request.remind': remind,
    'request.cancel': cancel,
  };

  static const kinds = {'link', 'invoice'};

  /// `open`: a pay link exists; `sent`: emailed (link) or sent by PayPal
  /// (invoice); `draft`: an invoice PayPal has not sent yet.
  static const states = {'draft', 'open', 'sent', 'paid', 'cancelled'};
  static const payable = {'open', 'sent'};

  // ---- The pay link ---------------------------------------------------------

  static String _linkSecret() {
    final env = ProviderClients.environment();
    for (final k in [
      'RAYSTO_PAY_LINK_SECRET',
      'PAYPAL_SANDBOX_CLIENT_SECRET',
    ]) {
      final v = env[k]?.trim() ?? '';
      if (v.length >= 8) return v;
    }
    return _fail('not_configured', 'Pay links need RAYSTO_PAY_LINK_SECRET.');
  }

  /// The link's token: derived from the request and a server secret, so a
  /// manager can show the same QR again; only its hash is stored.
  static String token(PaymentRequest r) => _hash(
    'payreq:${r.id}:${r.restaurantId}:${r.createdAt.millisecondsSinceEpoch ~/ 1000}:${_linkSecret()}',
  ).substring(0, 32);

  static String get _base {
    final v =
        ProviderClients.environment()['RAYSTO_PUBLIC_API_URL']?.trim() ?? '';
    final base = v.isEmpty ? 'https://api.rays.to' : v;
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  static String payUrl(PaymentRequest r) => '$_base/pay/${token(r)}';

  static String? _safeUrl(PaymentRequest r) {
    try {
      return payUrl(r);
    } on DomainError {
      return null;
    }
  }

  static String? invoiceUrl(String? invoiceId) => invoiceId == null
      ? null
      : ProviderClients.paypalEnvironment == 'live'
      ? 'https://www.paypal.com/invoice/p/#$invoiceId'
      : 'https://www.sandbox.paypal.com/invoice/p/#$invoiceId';

  static Future<PaymentRequest> _request(
    Work w,
    int id, {
    bool lock = false,
  }) async {
    final r = await PaymentRequest.db.findById(
      w.s,
      id,
      transaction: w.tx,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (r == null || r.restaurantId != w.tenant) {
      _fail('not_found', 'Payment request not found.');
    }
    return r;
  }

  static String _money(int minor, String currency) =>
      '${PayPalGateway.money(minor)} $currency';

  static String _sandboxNote() => ProviderClients.paypalEnvironment == 'live'
      ? ''
      : '\n\nPayPal Sandbox: this is a test payment and no real money moves.';

  // ---- Commands -------------------------------------------------------------

  static Future<Json> create(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'request.create',
    (w, d) async {
      _keys(d, {
        'kind',
        'payerName',
        'payerEmail',
        'description',
        'amountMinor',
        'dueAt',
      });
      final kind = _str(d, 'kind', choices: kinds, fallback: 'link');
      final email =
          d['payerEmail'] == null || '${d['payerEmail']}'.trim().isEmpty
          ? null
          : BackOfficeModule._email(d, 'payerEmail');
      if (kind == 'invoice' && email == null) {
        _fail('invalid_input', 'An invoice needs the payer\'s email.');
      }
      final due = d['dueAt'] == null ? null : _date(d, 'dueAt');
      final now = _now();
      final created = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
      var r = await PaymentRequest.db.insertRow(
        s,
        PaymentRequest(
          restaurantId: w.tenant,
          kind: kind,
          payerName: _str(d, 'payerName', max: 120),
          payerEmail: email,
          description: _str(d, 'description', max: 300),
          amountMinor: _int(d, 'amountMinor', min: 1, max: 10000000),
          currency: w.restaurant!.currency,
          dueAt: due,
          state: kind == 'link' ? 'open' : 'draft',
          linkTokenHash: 'pending:${_uuid()}',
          remindersSent: 0,
          createdBy: w.user,
          version: 1,
          createdAt: created,
          updatedAt: created,
        ),
        transaction: w.tx,
      );
      try {
        r.linkTokenHash = _hash(token(r));
        r = await PaymentRequest.db.updateRow(s, r, transaction: w.tx);
      } on DomainError {
        // An invoice is paid on PayPal's own page; only a link needs a token.
        if (kind == 'link') rethrow;
      }
      await w.audit('request.created', 'paymentRequest', r.id, {
        'kind': kind,
        'amountMinor': r.amountMinor,
      });
      return (await views(w, [r])).single;
    },
    roles: _finance,
  );

  /// A link is emailed to the payer (Amazon SES); an invoice is created and
  /// sent by PayPal through its MCP server. Both say plainly when the
  /// channel is not configured, and the request stays as it was.
  static Future<Json> send(Session s, PlatformCommand c) async {
    final claim = await _mutate(
      s,
      c,
      'request.send',
      (w, d) async {
        _keys(d, {});
        final r = await _request(w, _id(c), lock: true);
        if (r.state == 'paid' || r.state == 'cancelled') {
          _fail('invalid_transition', 'This request is ${r.state}.');
        }
        if (r.kind == 'invoice' && r.state == 'sent') {
          return {'requestId': r.id, 'done': true};
        }
        if (r.payerEmail == null) {
          _fail(
            'invalid_input',
            'Add the payer\'s email, or share the QR code.',
          );
        }
        return {
          'requestId': r.id,
          'kind': r.kind,
          'user': w.user,
          'restaurant': w.restaurant!.name,
        };
      },
      roles: _finance,
    );
    final id = claim['requestId'] as int;
    final r = (await PaymentRequest.db.findById(s, id))!;
    // 0.16 (S6): the café's own PayPal app when it has one.
    final account = await MerchantAppModule.forRestaurant(s, r.restaurantId);
    if (claim['done'] == true) return _viewOf(s, r.restaurantId, id);
    String? invoiceId;
    if (r.kind == 'link') {
      final due = r.dueAt == null
          ? ''
          : '\nPlease pay by ${r.dueAt!.toIso8601String().substring(0, 10)}.';
      await ProviderClients.email(
        r.payerEmail!,
        '${claim['restaurant']}: payment request for ${_money(r.amountMinor, r.currency)}',
        'Hello ${r.payerName},\n\n${claim['restaurant']} asks you to pay '
            '${_money(r.amountMinor, r.currency)} for ${r.description}.$due\n\n'
            'Pay securely with PayPal: ${payUrl(r)}\n\n'
            'The link opens PayPal\'s own checkout; Raysto never sees your '
            'card or PayPal password.${_sandboxNote()}',
      );
    } else {
      final created = await CateringAgent._execute('create_invoice', {
        'currency_code': r.currency,
        'reference': 'raysto-request-${r.id}',
        'note': r.description,
        'invoicer_business_name': claim['restaurant'],
        'primary_recipients': [
          {
            'billing_info': {
              'email_address': r.payerEmail,
              'business_name': r.payerName,
            },
          },
        ],
        'items': [
          {
            'name': r.description.length > 200
                ? r.description.substring(0, 200)
                : r.description,
            'quantity': '1',
            'unit_amount': {
              'currency_code': r.currency,
              'value': PayPalGateway.money(r.amountMinor),
            },
            'unit_of_measure': 'QUANTITY',
          },
        ],
      }, account: account);
      invoiceId = created['id'] is String
          ? created['id'] as String
          : (created['href'] is String
                ? Uri.parse(created['href'] as String).pathSegments.last
                : null);
      if (invoiceId == null ||
          !RegExp(r'^[A-Za-z0-9_-]{1,127}$').hasMatch(invoiceId)) {
        _fail('provider_unavailable', 'PayPal returned no invoice id.');
      }
      await CateringAgent._execute('send_invoice', {
        'invoice_id': invoiceId,
        'note': 'Thank you.',
        'send_to_recipient': true,
      }, account: account);
    }
    return MoneyModule.locked(s, r.restaurantId, claim['user'] as String, (
      w,
    ) async {
      final fresh = await _request(w, id, lock: true);
      if (payable.contains(fresh.state) || fresh.state == 'draft') {
        fresh
          ..state = 'sent'
          ..providerInvoiceId = invoiceId ?? fresh.providerInvoiceId
          ..version += 1
          ..updatedAt = _now();
        await PaymentRequest.db.updateRow(s, fresh, transaction: w.tx);
        await w.audit('request.sent', 'paymentRequest', fresh.id, {
          'via': fresh.kind == 'link' ? 'email' : 'paypal_invoice',
          'providerInvoiceId': ?invoiceId,
        });
      }
      return {
        ...(await views(w, [fresh])).single,
        'emailed': fresh.kind == 'link',
      };
    });
  }

  /// One reminder per day at most: an email for a link, PayPal's own
  /// reminder for an invoice.
  static Future<Json> remind(Session s, PlatformCommand c) async {
    final claim = await _mutate(
      s,
      c,
      'request.remind',
      (w, d) async {
        _keys(d, {});
        final r = await _request(w, _id(c), lock: true);
        if (!payable.contains(r.state)) {
          _fail('invalid_transition', 'Only an unpaid request is reminded.');
        }
        if (r.payerEmail == null) {
          _fail('invalid_input', 'This request has no email to remind.');
        }
        if (r.lastRemindedAt != null &&
            _now().difference(r.lastRemindedAt!).inHours < 20) {
          _fail('rate_limited', 'A reminder already went out today.');
        }
        return {
          'requestId': r.id,
          'user': w.user,
          'restaurant': w.restaurant!.name,
        };
      },
      roles: _finance,
    );
    final id = claim['requestId'] as int;
    final r = (await PaymentRequest.db.findById(s, id))!;
    // 0.16 (S6): the café's own PayPal app when it has one.
    final account = await MerchantAppModule.forRestaurant(s, r.restaurantId);
    if (r.kind == 'invoice' && r.providerInvoiceId != null) {
      await CateringAgent._execute('send_invoice_reminder', {
        'invoice_id': r.providerInvoiceId!,
        'subject': 'Reminder: your invoice from ${claim['restaurant']}',
        'note': 'A friendly reminder that this invoice is still unpaid.',
      }, account: account);
    } else {
      await ProviderClients.email(
        r.payerEmail!,
        'Reminder: ${claim['restaurant']} payment request',
        'Hello ${r.payerName},\n\nA friendly reminder that '
            '${_money(r.amountMinor, r.currency)} for ${r.description} is '
            'still unpaid.\n\nPay with PayPal: ${payUrl(r)}${_sandboxNote()}',
      );
    }
    return MoneyModule.locked(s, r.restaurantId, claim['user'] as String, (
      w,
    ) async {
      final fresh = await _request(w, id, lock: true);
      fresh
        ..remindersSent += 1
        ..lastRemindedAt = _now()
        ..version += 1
        ..updatedAt = _now();
      await PaymentRequest.db.updateRow(s, fresh, transaction: w.tx);
      await w.audit('request.reminded', 'paymentRequest', fresh.id, {
        'count': fresh.remindersSent,
      });
      return {
        ...(await views(w, [fresh])).single,
        'reminded': true,
      };
    });
  }

  static Future<Json> cancel(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'request.cancel',
    (w, d) async {
      _keys(d, {});
      final r = await _request(w, _id(c), lock: true);
      if (r.state == 'cancelled') return (await views(w, [r])).single;
      if (r.state == 'paid') {
        _fail(
          'invalid_transition',
          'A paid request is refunded, not cancelled.',
        );
      }
      if (r.checkoutIntentId != null) {
        final i = await CheckoutIntent.db.findById(
          s,
          r.checkoutIntentId!,
          transaction: w.tx,
        );
        if (i != null) {
          if (i.state == 'completed') {
            _fail(
              'invalid_transition',
              'The payer has just paid this request.',
            );
          }
          if ({'creating', 'capturing', 'uncertain'}.contains(i.state)) {
            _fail(
              'payment_pending',
              'PayPal is still answering for this payment. Try again shortly.',
            );
          }
          if ({'reserved', 'created', 'approved'}.contains(i.state)) {
            await MoneyModule._release(w, i, 'cancelled');
          }
        }
      }
      r
        ..state = 'cancelled'
        ..version += 1
        ..updatedAt = _now();
      await PaymentRequest.db.updateRow(s, r, transaction: w.tx);
      await w.audit('request.cancelled', 'paymentRequest', r.id);
      return {
        ...(await views(w, [r])).single,
        // PayPal's MCP server offers no cancel for an invoice already sent.
        if (r.providerInvoiceId != null) 'paypalInvoiceStillOpen': true,
      };
    },
    roles: _finance,
  );

  // ---- Paid -----------------------------------------------------------------

  /// A request whose checkout completed is paid.
  static Future<void> sync(Work w) async {
    final rows = await PaymentRequest.db.find(
      w.s,
      where: (t) =>
          t.restaurantId.equals(w.tenant) &
          t.state.inSet(payable) &
          t.checkoutIntentId.notEquals(null),
      transaction: w.tx,
    );
    for (final r in rows) {
      final capture = await PaymentCapture.db.findFirstRow(
        w.s,
        where: (t) =>
            t.checkoutId.equals(r.checkoutIntentId!) &
            t.state.equals('completed'),
        transaction: w.tx,
      );
      if (capture == null) continue;
      r
        ..state = 'paid'
        ..paidAt = capture.createdAt
        ..version += 1
        ..updatedAt = _now();
      await PaymentRequest.db.updateRow(w.s, r, transaction: w.tx);
      await w.audit('request.paid', 'paymentRequest', r.id, {
        'providerCaptureId': capture.providerCaptureId,
        'amountMinor': capture.amountMinor,
      });
    }
  }

  /// PayPal's INVOICING.INVOICE.PAID webhook for a request invoice. The
  /// webhook switch (automation.dart) routes catering invoices today; this
  /// is the matching entry for requests.
  static Future<bool> onInvoicePaid(Session s, Json resource) async {
    final invoiceId = resource['id'];
    if (invoiceId is! String) return false;
    final r = await PaymentRequest.db.findFirstRow(
      s,
      where: (t) => t.providerInvoiceId.equals(invoiceId),
    );
    if (r == null) return false;
    if (r.state == 'paid') return true;
    await AgentModule.asAgent(s, r.restaurantId, (w) async {
      final fresh = await _request(w, r.id!, lock: true);
      if (fresh.state == 'paid') return;
      fresh
        ..state = 'paid'
        ..paidAt = _now()
        ..version += 1
        ..updatedAt = _now();
      await PaymentRequest.db.updateRow(s, fresh, transaction: w.tx);
      await w.audit('request.paid', 'paymentRequest', fresh.id, {
        'providerInvoiceId': invoiceId,
        'amountMinor': fresh.amountMinor,
      });
    });
    return true;
  }

  /// What `/pay/{token}` does: a paid or cancelled request says so; an
  /// invoice goes to PayPal's invoice page; a link goes to a fresh Orders
  /// v2 checkout for the exact amount.
  static Future<({int status, String? redirect, String message})> open(
    Session s,
    String token,
  ) async {
    final r = await PaymentRequest.db.findFirstRow(
      s,
      where: (t) => t.linkTokenHash.equals(_hash(token)),
    );
    if (r == null) {
      return (
        status: 404,
        redirect: null,
        message: 'This payment link is not valid.',
      );
    }
    if (r.state == 'paid') {
      return (
        status: 200,
        redirect: null,
        message: 'This request is paid. Thank you.',
      );
    }
    if (r.state == 'cancelled') {
      return (
        status: 410,
        redirect: null,
        message: 'This payment request was cancelled.',
      );
    }
    if (r.kind == 'invoice') {
      final url = invoiceUrl(r.providerInvoiceId);
      return url == null
          ? (
              status: 200,
              redirect: null,
              message: 'This invoice has not been sent yet.',
            )
          : (status: 302, redirect: url, message: 'Opening PayPal…');
    }
    final checkout = await MoneyModule.requestCheckout(s, r.id!);
    if (checkout['state'] == 'completed') {
      await MoneyModule.locked(s, r.restaurantId, r.createdBy, sync);
      return (
        status: 200,
        redirect: null,
        message: 'This request is paid. Thank you.',
      );
    }
    final url = checkout['approvalUrl'];
    if (url is String) {
      final u = Uri.tryParse(url);
      if (u != null &&
          u.scheme == 'https' &&
          (u.host == 'paypal.com' || u.host.endsWith('.paypal.com'))) {
        return (status: 302, redirect: url, message: 'Opening PayPal…');
      }
    }
    return (
      status: 503,
      redirect: null,
      message: 'PayPal is not answering right now. Try again in a minute.',
    );
  }

  // ---- Reads ----------------------------------------------------------------

  static Future<Json> _viewOf(Session s, int rid, int id) =>
      AgentModule.asAgent(s, rid, (w) async {
        final r = await _request(w, id);
        return (await views(w, [r])).single;
      });

  static Future<List<Json>> views(Work w, List<PaymentRequest> rows) async {
    final ids = {for (final r in rows) ?r.checkoutIntentId};
    final intents = ids.isEmpty
        ? const <int, CheckoutIntent>{}
        : {
            for (final i in await CheckoutIntent.db.find(
              w.s,
              where: (t) => t.id.inSet(ids),
              transaction: w.tx,
            ))
              i.id!: i,
          };
    final captures = ids.isEmpty
        ? const <int, PaymentCapture>{}
        : {
            for (final c in await PaymentCapture.db.find(
              w.s,
              where: (t) => t.checkoutId.inSet(ids),
              transaction: w.tx,
            ))
              c.checkoutId: c,
          };
    final now = _now();
    return [
      for (final r in rows)
        {
          'id': r.id,
          'kind': r.kind,
          'payerName': r.payerName,
          'payerEmail': r.payerEmail,
          'description': r.description,
          'amountMinor': r.amountMinor,
          'currency': r.currency,
          'dueAt': r.dueAt?.toIso8601String(),
          'state': r.state,
          'overdue':
              payable.contains(r.state) &&
              r.dueAt != null &&
              r.dueAt!.isBefore(now),
          'payUrl': r.kind == 'link' && r.state != 'cancelled'
              ? _safeUrl(r)
              : null,
          'providerInvoiceId': r.providerInvoiceId,
          'invoiceUrl': invoiceUrl(r.providerInvoiceId),
          'remindersSent': r.remindersSent,
          'lastRemindedAt': r.lastRemindedAt?.toIso8601String(),
          'checkoutId': r.checkoutIntentId,
          'checkoutState': intents[r.checkoutIntentId]?.state,
          'providerOrderId': intents[r.checkoutIntentId]?.providerOrderId,
          'providerCaptureId': captures[r.checkoutIntentId]?.providerCaptureId,
          'paidAt': r.paidAt?.toIso8601String(),
          'createdBy': r.createdBy,
          'version': r.version,
          'createdAt': r.createdAt.toIso8601String(),
        },
    ];
  }

  /// Queries this module answers; null means "not mine".
  static Future<Json?> query(
    Work w,
    String name,
    Json d,
    int limit,
    int cursor,
    Json Function(List<Json>) page,
  ) async {
    switch (name) {
      case 'requests':
        await w.role(_finance);
        await sync(w);
        final state = d['state'] == null
            ? null
            : _str(d, 'state', choices: states);
        final rows = await PaymentRequest.db.find(
          w.s,
          where: (t) => state == null
              ? t.restaurantId.equals(w.tenant)
              : t.restaurantId.equals(w.tenant) & t.state.equals(state),
          orderBy: (t) => t.id.desc(),
          limit: 500,
          transaction: w.tx,
        );
        final v = await views(w, rows);
        int sum(bool Function(Json) test) =>
            v.where(test).fold<int>(0, (n, x) => n + (x['amountMinor'] as int));
        final month = BackOfficeModule.localDay(
          {'timezone': 'UTC', ...w.settings},
          _now(),
        ).substring(0, 7);
        return {
          'rows': v,
          'nextCursor': null,
          'currency': w.restaurant!.currency,
          'summary': {
            'outstandingMinor': sum((x) => payable.contains(x['state'])),
            'overdueMinor': sum((x) => x['overdue'] == true),
            'paidThisMonthMinor': sum(
              (x) => x['state'] == 'paid' && '${x['paidAt']}'.startsWith(month),
            ),
          },
        };
      case 'request':
        await w.role(_finance);
        await sync(w);
        final r = await _request(w, _int(d, 'id', min: 1, max: 1 << 31));
        return (await views(w, [r])).single;
    }
    return null;
  }
}
