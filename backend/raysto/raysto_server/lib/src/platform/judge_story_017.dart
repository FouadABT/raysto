part of 'platform.dart';

/// Coordinates the guided story without deleting or resetting payment history.
/// Configuration is an owner-reviewed set of existing, sample fixture records.
class JudgeStory017 {
  static bool get active =>
      Finance017.active &&
      Finance017.environment()['RAYSTO_JUDGE_STORY_017_ENABLED'] == 'true';
  static void enabled(Work w) {
    Finance017.enabled();
    if (!active || !JudgeModule.venue(w.tenant)) {
      _fail('not_enabled', 'The guided financial story is not available here.');
    }
  }

  static const queries = {'judge.story'};
  static final Map<String, Future<Json> Function(Session, PlatformCommand)>
  commands = {
    'judge.story.configure': configure,
    'judge.story.start': start,
    'judge.story.heartbeat': heartbeat,
  };
  static String sessionKey(Work w) =>
      _hash('${w.user}:${w.s.authenticated?.authId}');
  static void requireManualReview(Work w) {
    final autonomy = CatalogueModule.validateAutonomy(
      _object(w.settings['autonomy'] ?? {}),
    );
    if ((autonomy['billsMaxMinor'] as int) > 0 ||
        (autonomy['refundsMaxMinor'] as int) > 0) {
      _fail(
        'manual_review_required',
        'The guided story requires manual money approval. The owner must disable automatic bill payments and refunds for this review venue.',
      );
    }
  }

  static Future<FinanceRecord?> coordinate(Work w) =>
      Finance017.record(w, 'judgeCoordination', 'current');
  static bool live(FinanceRecord? r) =>
      r != null &&
      DateTime.parse(
        _json(r.payloadJson)['expiresAt'] as String,
      ).isAfter(_now());

  static Future<Json> configure(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'judge.story.configure', (w, d) async {
    enabled(w);
    requireManualReview(w);
    _keys(d, {
      'productId',
      'incompleteProductId',
      'supplierOrderId',
      'billId',
      'mediaId',
      'reviewed',
    });
    if (!_bool(d, 'reviewed')) {
      _fail(
        'review_required',
        'Review the sample story records before publishing the guide.',
      );
    }
    if (live(await coordinate(w))) {
      _fail('busy', 'A review or reset is already using this fixture.');
    }
    if (w.restaurant!.currency != 'USD' ||
        ProviderClients.environment()['RAYSTO_PAYPAL_ENVIRONMENT'] !=
            'sandbox') {
      _fail('sandbox_required', 'The guide requires the USD Sandbox café.');
    }
    final productId = _int(d, 'productId', min: 1, max: 1 << 31);
    final incompleteId = _int(d, 'incompleteProductId', min: 1, max: 1 << 31);
    final product = await Finance017.product(w, productId);
    final incomplete = await Finance017.product(w, incompleteId);
    if (product['complete'] != true ||
        incomplete['complete'] == true ||
        productId == incompleteId) {
      _fail(
        'fixture_incomplete',
        'Choose one fully costed dish and a different incomplete-cost example.',
      );
    }
    final order = await SupplierOrder.db.findById(
      s,
      _int(d, 'supplierOrderId', min: 1, max: 1 << 31),
      transaction: w.tx,
    );
    final bill = await Bill.db.findById(
      s,
      _int(d, 'billId', min: 1, max: 1 << 31),
      transaction: w.tx,
    );
    final media = await MediaAsset.db.findById(
      s,
      _int(d, 'mediaId', min: 1, max: 1 << 31),
      transaction: w.tx,
    );
    if (order?.restaurantId != w.tenant ||
        bill?.restaurantId != w.tenant ||
        media?.restaurantId != w.tenant ||
        media?.status != 'approved' ||
        bill?.supplierOrderId != order?.id) {
      _fail(
        'fixture_incomplete',
        'The purchasing documents must be approved and linked in this venue.',
      );
    }
    final policy = await Finance017.record(w, 'pricingPolicy', 'current');
    if (Finance017.policyData(policy)['confirmed'] != true ||
        await FinanceAccounting.policy(w) == null) {
      _fail(
        'policy_required',
        'The owner must review the pricing target and accounting cutover first.',
      );
    }
    final current = await Finance017.record(w, 'judgeStoryFixture', 'current');
    _version(current?.version ?? 0, c.expectedVersion);
    final saved = await Finance017.put(w, 'judgeStoryFixture', 'current', {
      ...d,
      'sample': true,
      'reviewedBy': w.user,
      'reviewedAt': _now().toIso8601String(),
    });
    await w.audit('judge.story.configured', 'financeRecord', saved.id);
    return {'version': saved.version, 'configured': true};
  }, roles: {'owner'});

  static Future<Json> start(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'judge.story.start', (w, d) async {
    enabled(w);
    requireManualReview(w);
    _keys(d, {});
    final fixture = await Finance017.record(w, 'judgeStoryFixture', 'current');
    if (fixture == null) {
      _fail(
        'not_ready',
        'The owner has not completed the guided fixture review. Independent exploration remains available.',
      );
    }
    final current = await coordinate(w);
    if (live(current)) {
      final value = _json(current!.payloadJson);
      if (value['session'] == sessionKey(w) && value['runId'] != null) {
        return status(w);
      }
      _fail(
        'busy',
        'Another guided review is using the café. Explore the read-only evidence or retry later.',
      );
    }
    final dish = await Finance017.product(
      w,
      _json(fixture.payloadJson)['productId'] as int,
    );
    if (dish['complete'] != true) {
      _fail(
        'not_ready',
        'The fixture cost evidence changed. The owner must review it before another guided run.',
      );
    }
    final run = _uuid(), at = _now();
    final snapshot = {
      'runId': run,
      'startedAt': at.toIso8601String(),
      'sample': true,
      'fixtureVersion': fixture.version,
      'fixture': _json(fixture.payloadJson),
      'status': 'active',
    };
    final record = await Finance017.put(
      w,
      'judgeRun',
      run,
      snapshot,
      immutable: true,
    );
    await Finance017.put(w, 'judgeCoordination', 'current', {
      'runId': run,
      'session': sessionKey(w),
      'state': 'reviewing',
      'startedAt': at.toIso8601String(),
      'expiresAt': at.add(const Duration(minutes: 20)).toIso8601String(),
    });
    await w.audit('judge.story.started', 'financeRecord', record.id);
    return status(w);
  }, roles: _managers);

  static Future<Json> heartbeat(
    Session s,
    PlatformCommand c,
  ) => _mutate(s, c, 'judge.story.heartbeat', (w, d) async {
    enabled(w);
    _keys(d, {'runId'});
    final current = await coordinate(w);
    if (!live(current)) {
      _fail(
        'expired',
        'This guided session expired. Its records and payments are preserved.',
      );
    }
    final value = _json(current!.payloadJson);
    if (value['session'] != sessionKey(w) ||
        value['runId'] != _str(d, 'runId', max: 40)) {
      _fail('busy', 'This guided review belongs to a different session.');
    }
    final last = DateTime.parse(
      value['startedAt'] as String,
    ).add(const Duration(hours: 2));
    final expiry = _now().add(const Duration(minutes: 20));
    await Finance017.put(w, 'judgeCoordination', 'current', {
      ...value,
      'expiresAt': (expiry.isBefore(last) ? expiry : last).toIso8601String(),
    });
    return status(w);
  }, roles: _managers);

  static Future<Json> status(Work w) async {
    enabled(w);
    await w.role(_finance);
    final current = await coordinate(w),
        fixture = await Finance017.record(w, 'judgeStoryFixture', 'current');
    final coord = current == null
        ? <String, dynamic>{}
        : _json(current.payloadJson);
    final mine = coord['session'] == sessionKey(w) && coord['runId'] != null;
    final run = mine
        ? await Finance017.record(w, 'judgeRun', coord['runId'] as String)
        : null;
    return {
      ...await Finance017.metadata(w),
      'configured': fixture != null,
      'busy': live(current) && !mine,
      'active': mine && live(current),
      'run': run == null
          ? null
          : {
              ..._json(run.payloadJson),
              'status': live(current) ? 'active' : 'expired',
              'expiresAt': coord['expiresAt'],
            },
      'fixture': fixture == null ? null : _json(fixture.payloadJson),
      'limitations': [
        'Illustrative restaurant records. Provider outcomes require their actual Sandbox references.',
        'A new run does not erase payments or return prices to an earlier value.',
      ],
    };
  }

  static Future<void> beforeReset(Work w) async {
    if (!active) return;
    if (live(await coordinate(w))) {
      _fail(
        'busy',
        'The café has an active guided review or reset. Retry after it finishes.',
      );
    }
    await Finance017.put(w, 'judgeCoordination', 'current', {
      'state': 'resetting',
      'expiresAt': _now().add(const Duration(minutes: 5)).toIso8601String(),
      'session': sessionKey(w),
    });
  }

  static Future<void> finishReset(Work w) async {
    if (!active) return;
    final current = await coordinate(w);
    if (live(current) && _json(current!.payloadJson)['state'] == 'reviewing') {
      _fail('busy', 'A guided review started; the fixture was not reset.');
    }
    await Finance017.put(w, 'judgeCoordination', 'current', {
      'state': 'idle',
      'expiresAt': _now().toIso8601String(),
    });
  }
}
