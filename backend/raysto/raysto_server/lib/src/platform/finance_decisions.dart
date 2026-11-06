part of 'platform.dart';

/// Immutable analytical revisions; business execution remains in AgentAction.
class FinanceDecisions {
  static Json view(Json args) {
    _keys(args, {'arrangement', 'columns', 'completeness', 'sort', 'widgets'});
    final columns = _list(args, 'columns', max: 5);
    final widgets = _list(args, 'widgets', max: 2);
    if (columns.isEmpty ||
        columns.toSet().length != columns.length ||
        columns.any(
          (c) => !{
            'name',
            'price',
            'cost',
            'contribution',
            'complete',
          }.contains(c),
        ) ||
        widgets.isEmpty ||
        widgets.toSet().length != widgets.length ||
        widgets.any((c) => !{'comparison', 'evidence'}.contains(c))) {
      _fail(
        'invalid_field',
        'Choose declared analytical fields and widgets only.',
      );
    }
    return {
      'arrangement': _str(
        args,
        'arrangement',
        choices: {'side-by-side', 'stacked'},
      ),
      'columns': columns,
      'widgets': widgets,
      'completeness': _str(
        args,
        'completeness',
        choices: {'all', 'complete', 'incomplete'},
      ),
      'sort': _str(args, 'sort', choices: {'name', 'contribution'}),
    };
  }

  static const queries = {
    'costing.investigation',
    'pricing.comparison',
    'pricing.comparisons',
    'pricing.decision',
    'pricing.decisions',
    'pricing.decision.outcome',
  };
  static final commands =
      <String, Future<Json> Function(Session, PlatformCommand)>{
        'costing.investigation.checkpoint': checkpoint,
        'pricing.comparison.create': (s, c) => save(s, c, revise: false),
        'pricing.comparison.revise': (s, c) => save(s, c, revise: true),
        'pricing.decision.record': decide,
      };

  static Future<Json> investigation(Work w, int productId) async {
    final product = await Finance017.product(w, productId);
    final policy = Finance017.policyData(
      await Finance017.record(w, 'pricingPolicy', 'current'),
    );
    final saved = await Finance017.record(
      w,
      'investigation',
      '${w.user}:$productId',
    );
    final value = saved == null
        ? <String, dynamic>{}
        : _json(saved.payloadJson);
    final ready = product['complete'] == true && policy['confirmed'] == true;
    return {
      ...await Finance017.metadata(w),
      ...value,
      'productId': productId,
      'ready': ready,
      'recipeComplete': product['complete'],
      'policyConfirmed': policy['confirmed'],
      'missing': product['missing'],
      'stepsSaved': saved != null,
      'timingBasis':
          'elapsed wall time including pauses; observer records active setup time separately',
      'accountingCutoverRequired': false,
    };
  }

  static Future<Json> checkpoint(Session s, PlatformCommand c) =>
      _mutate(s, c, 'costing.investigation.checkpoint', (w, d) async {
        _keys(d, {'productId'});
        Finance017.enabled();
        final id = _int(d, 'productId', min: 1, max: 1 << 31);
        final state = await investigation(w, id), now = _now();
        final start = state['startedAt'] as String? ?? now.toIso8601String();
        final completed =
            state['completedAt'] as String? ??
            (state['ready'] == true ? now.toIso8601String() : null);
        await Finance017.put(w, 'investigation', '${w.user}:$id', {
          'productId': id,
          'actor': w.user,
          'startedAt': start,
          'completedAt': completed,
          'elapsedSetupSeconds': completed == null
              ? null
              : DateTime.parse(
                  completed,
                ).difference(DateTime.parse(start)).inSeconds,
          'alreadyCompleteAtStart':
              state['alreadyCompleteAtStart'] ?? state['ready'],
        });
        return investigation(w, id);
      }, roles: _finance);

  static Future<FinanceRecord> get(Work w, int id, String kind) async {
    final r = await FinanceRecord.db.findById(w.s, id, transaction: w.tx);
    if (r == null || r.restaurantId != w.tenant || r.kind != kind) {
      _fail('not_found', 'Financial decision evidence not found.');
    }
    return r;
  }

  static Future<Json> save(
    Session s,
    PlatformCommand c, {
    required bool revise,
  }) => _mutate(
    s,
    c,
    revise ? 'pricing.comparison.revise' : 'pricing.comparison.create',
    (w, d) => calculate(w, d, revise: revise, key: c.requestKey),
    roles: _finance,
  );

  static Future<Json> calculate(
    Work w,
    Json d, {
    required bool revise,
    required String key,
  }) async {
    Finance017.pricingEnabled();
    _keys(d, {
      'productId',
      'parentId',
      'baselineUnits',
      'volumeChangeBps',
      'maxIncreaseBps',
      'candidatePriceMinor',
    });
    FinanceRecord? parent;
    var assumptions = <String, dynamic>{};
    if (revise) {
      parent = await get(
        w,
        _int(d, 'parentId', min: 1, max: 1 << 31),
        'comparison',
      );
      assumptions = {..._object(_json(parent.payloadJson)['inputs'])};
    } else if (d.containsKey('parentId')) {
      _fail(
        'invalid_input',
        'Use the revision command to challenge an existing comparison.',
      );
    }
    final productId = parent == null
        ? _int(d, 'productId', min: 1, max: 1 << 31)
        : _json(parent.payloadJson)['productId'] as int;
    if (d['productId'] != null && d['productId'] != productId) {
      _fail('selection_changed', 'A revision cannot change its dish.');
    }
    assumptions.addAll({
      for (final k in [
        'baselineUnits',
        'volumeChangeBps',
        'maxIncreaseBps',
        'candidatePriceMinor',
      ])
        if (d.containsKey(k)) k: d[k],
    });
    final units = _int(assumptions, 'baselineUnits', min: 1, max: 1000000);
    final volume = _int(
      assumptions,
      'volumeChangeBps',
      min: -10000,
      max: 10000,
      fallback: 0,
    );
    final p = await Finance017.product(w, productId);
    if (p['complete'] != true) {
      _fail('incomplete_cost', (p['missing'] as List).join(' '));
    }
    final policyRecord = await Finance017.record(w, 'pricingPolicy', 'current');
    final policy = Finance017.policyData(policyRecord);
    if (policy['confirmed'] != true) {
      _fail(
        'policy_required',
        'The owner must confirm the contribution target.',
      );
    }
    if ((policy['excludedProducts'] as List).contains(productId)) {
      _fail(
        'protected_product',
        'This dish is protected from price recommendations.',
      );
    }
    final cap = _int(
      assumptions,
      'maxIncreaseBps',
      max: 10000,
      fallback: policy['maxIncreaseBps'] as int,
    );
    if (cap > (policy['maxIncreaseBps'] as int)) {
      _fail(
        'policy_limit',
        'A comparison can narrow, but cannot increase, the owner policy limit.',
      );
    }
    final candidate = assumptions['candidatePriceMinor'] == null
        ? null
        : _int(assumptions, 'candidatePriceMinor', min: 1, max: 100000000);
    Json result;
    try {
      result = RestaurantCosting.comparison(
        priceMinor: p['priceMinor'] as int,
        costMinor: p['replacementCostMinor'] as int,
        taxBps: (w.settings['taxBps'] as int?) ?? 0,
        pricesIncludeTax: w.settings['pricesIncludeTax'] == true,
        targetBps: policy['targetBps'] as int,
        maxIncreaseBps: cap,
        incrementMinor: policy['incrementMinor'] as int,
        minimumMinor: policy['minimumMinor'] as int,
        maximumMinor: policy['maximumMinor'] as int,
        feeBps: policy['feeBps'] as int,
        feeFixedMinor: policy['feeFixedMinor'] as int,
        baselineUnits: units,
        volumeChangeBps: volume,
        candidatePriceMinor: candidate,
      );
    } on ArgumentError catch (e) {
      _fail('invalid_input', '${e.message}');
    }
    final inputs = {
      'baselineUnits': units,
      'volumeChangeBps': volume,
      'maxIncreaseBps': cap,
      'candidatePriceMinor': candidate,
    };
    final previous = parent == null ? null : _json(parent.payloadJson);
    final value = {
      ...await Finance017.metadata(w),
      ...result,
      'inputs': inputs,
      'revision': parent == null ? 1 : (previous!['revision'] as int) + 1,
      'parentId': parent?.id,
      'rootId': previous?['rootId'] ?? parent?.id,
      'productId': productId,
      'productName': p['name'],
      'productFingerprint': p['fingerprint'],
      'policyVersion': policyRecord!.version,
      'policy': policy,
      'evidence': p,
      'volumeBasis': 'owner-assumption',
      'periodBasis': 'per-baseline-units',
      'expiresAt': _now().add(const Duration(minutes: 15)).toIso8601String(),
      'changes': [
        if (previous != null)
          for (final k in inputs.keys)
            if ((_object(previous['inputs']))[k] != inputs[k])
              {
                'field': k,
                'from': (_object(previous['inputs']))[k],
                'to': inputs[k],
              },
        if (previous != null &&
            previous['productFingerprint'] != p['fingerprint'])
          {
            'field': 'costEvidence',
            'from': previous['productFingerprint'],
            'to': p['fingerprint'],
          },
        if (previous != null &&
            previous['policyVersion'] != policyRecord.version)
          {
            'field': 'policyVersion',
            'from': previous['policyVersion'],
            'to': policyRecord.version,
          },
      ],
    };
    final r = await Finance017.put(
      w,
      'comparison',
      key,
      value,
      immutable: true,
    );
    await w.audit('pricing.comparison.created', 'financeRecord', r.id);
    return {
      ..._json(r.payloadJson),
      'id': r.id,
      'version': r.version,
      'valid': true,
    };
  }

  static Future<void> validate(Work w, Json v) async {
    if (!DateTime.parse(v['expiresAt'] as String).isAfter(_now())) {
      _fail('expired', 'Recalculate this expired comparison.');
    }
    final product = await Finance017.product(w, v['productId'] as int);
    final policy = await Finance017.record(w, 'pricingPolicy', 'current');
    if (product['fingerprint'] != v['productFingerprint'] ||
        policy?.version != v['policyVersion']) {
      _fail(
        'stale',
        'Recipe, costs, price, policy or tax changed. Recalculate and review.',
      );
    }
  }

  /// Materialize the selected option as an ordinary immutable approval scenario.
  static Future<Json> proposal(Work w, Json d) async {
    if (d['comparisonId'] == null) return d;
    _keys(d, {'comparisonId', 'option', 'scenarioId'});
    final r = await get(
      w,
      _int(d, 'comparisonId', min: 1, max: 1 << 31),
      'comparison',
    );
    final v = _json(r.payloadJson);
    await validate(w, v);
    final choice = _str(d, 'option', choices: {'recommended', 'custom'});
    final options = (v['options'] as List)
        .map(_object)
        .where((o) => o['key'] == choice)
        .toList();
    if (options.isEmpty || options.single['publishable'] != true) {
      _fail(
        'analysis_only',
        'This option is for analysis only and cannot publish a price.',
      );
    }
    final option = options.single;
    final scenario = await Finance017.put(
      w,
      'scenario',
      'comparison:${r.id}:$choice',
      {
        ...v,
        'kind': 'scenario',
        'recommended': option,
        'feasible': true,
        'comparisonId': r.id,
        'option': choice,
        'sensitivity': option['sensitivity'],
        'breakEvenUnits': option['breakEvenUnits'],
      },
      immutable: true,
    );
    if (d['scenarioId'] != null && d['scenarioId'] != scenario.id) {
      _fail(
        'invalid_input',
        'The scenario does not belong to this comparison option.',
      );
    }
    return {'scenarioId': scenario.id, 'comparisonId': r.id, 'option': choice};
  }

  static Future<Json> decide(Session s, PlatformCommand c) => _mutate(
    s,
    c,
    'pricing.decision.record',
    (w, d) async {
      Finance017.pricingEnabled();
      _keys(d, {'comparisonId', 'choice', 'reason', 'note'});
      final r = await get(
        w,
        _int(d, 'comparisonId', min: 1, max: 1 << 31),
        'comparison',
      );
      final v = _json(r.payloadJson);
      await validate(w, v);
      final choice = _str(d, 'choice', choices: {'keep', 'defer', 'reject'});
      final reason = _str(
        d,
        'reason',
        choices: {
          'customer_sensitivity',
          'missing_evidence',
          'timing',
          'assumptions',
          'target_met',
          'other',
        },
      );
      final row = await Finance017.put(w, 'decision', c.requestKey, {
        'comparisonId': r.id,
        'productId': v['productId'],
        'productName': v['productName'],
        'choice': choice,
        'reason': reason,
        'note': d['note'] == null || d['note'] == ''
            ? ''
            : _str(d, 'note', max: 1000),
        'actor': w.user,
        'at': _now().toIso8601String(),
        'currency': w.restaurant!.currency,
        'businessChanges': false,
      }, immutable: true);
      await w.audit('pricing.decision.recorded', 'financeRecord', row.id);
      return {..._json(row.payloadJson), 'id': row.id, 'version': row.version};
    },
    roles: _managers,
  );

  static Future<void> proposed(
    Work w,
    Json payload,
    AgentAction action, {
    String? actor,
  }) async {
    if (payload['comparisonId'] == null) return;
    final r = await get(w, payload['comparisonId'] as int, 'comparison');
    final v = _json(r.payloadJson);
    await Finance017.put(w, 'decision', 'proposal:${action.id}', {
      'comparisonId': r.id,
      'productId': v['productId'],
      'productName': v['productName'],
      'choice': 'propose',
      'option': payload['option'],
      'reason': 'prepared_for_review',
      'note': '',
      'actor': actor ?? w.user,
      'at': _now().toIso8601String(),
      'currency': w.restaurant!.currency,
      'actionId': action.id,
      'scenarioId': payload['scenarioId'],
      'businessChanges': false,
    }, immutable: true);
  }

  static Future<Json> query(Work w, String name, Json d) async {
    if (name == 'costing.investigation') {
      return investigation(w, _int(d, 'productId', min: 1, max: 1 << 31));
    }
    final meta = await Finance017.metadata(w);
    if (name == 'pricing.comparisons' || name == 'pricing.decisions') {
      final kind = name == 'pricing.comparisons' ? 'comparison' : 'decision';
      final limit = _int(d, 'limit', min: 1, max: 100, fallback: 30);
      final cursor = _int(d, 'cursor', max: 9007199254740991, fallback: 0);
      final rows = await FinanceRecord.db.find(
        w.s,
        where: (t) =>
            t.restaurantId.equals(w.tenant) &
            t.kind.equals(kind) &
            (cursor == 0 ? Constant.bool(true) : t.id < cursor),
        orderBy: (t) => t.id.desc(),
        limit: limit + 1,
        transaction: w.tx,
      );
      return {
        ...meta,
        'rows': [
          for (final r in rows.take(limit))
            {..._json(r.payloadJson), 'id': r.id, 'version': r.version},
        ],
        'nextCursor': rows.length > limit ? rows[limit - 1].id : null,
      };
    }
    final kind = name == 'pricing.comparison' ? 'comparison' : 'decision';
    final r = await get(w, _int(d, 'id', min: 1, max: 1 << 31), kind);
    final value = _json(r.payloadJson);
    if (kind == 'comparison') {
      String? issue;
      try {
        await validate(w, value);
      } on DomainError catch (e) {
        issue = e.code;
      }
      return {
        ...meta,
        ...value,
        'id': r.id,
        'version': r.version,
        'valid': issue == null,
        'invalidReason': issue,
      };
    }
    final comparison = await get(w, value['comparisonId'] as int, 'comparison');
    final action = value['actionId'] == null
        ? null
        : await AgentAction.db.findById(
            w.s,
            value['actionId'] as int,
            transaction: w.tx,
          );
    return {
      ...meta,
      ...value,
      'id': r.id,
      'version': r.version,
      'comparison': {..._json(comparison.payloadJson), 'id': comparison.id},
      'approval': action == null
          ? null
          : {
              'id': action.id,
              'status': action.status,
              'approvedBy': action.approverUserId,
              'decidedAt': action.decidedAt?.toIso8601String(),
            },
      if (name == 'pricing.decision.outcome') ...await outcome(w, value),
    };
  }

  static Future<Json> outcome(Work w, Json decision) =>
      FinanceOutcomes.read(w, decision);
}
