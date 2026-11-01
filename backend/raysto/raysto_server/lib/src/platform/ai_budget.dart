part of 'platform.dart';

/// USD millionths. Budget reservations survive lost provider responses and are
/// never released on an unknown outcome, preventing retries from overspending.
///
/// The `hackathon` stage adds two ceilings under its $100 total: one per
/// feature (images, menu, voice, …) and one per restaurant per day, so a
/// single agent or tenant cannot spend everyone's allowance. Rows are locked
/// in a fixed order (stage, feature, tenant) so concurrent reservations
/// cannot deadlock.
class AiBudget {
  /// Test seam, like [ProviderClients.environment].
  static Map<String, String> Function() environment = () =>
      Platform.environment;
  static String get stage => switch (environment()['RAYSTO_AI_BUDGET_STAGE']) {
    'review' => 'review',
    'hackathon' => 'hackathon',
    _ => 'development',
  };
  static const _stageLimits = {
    'review': 15000000,
    'development': 35000000,
    'hackathon': 100000000,
  };
  static const features = {
    'images': 30000000,
    'menu': 20000000,
    'voice': 8000000,
    'agents': 10000000,
    'catering': 5000000,
    'marketing': 7000000,
    'chat': 5000000,
    'evals': 5000000,
  };
  static int get tenantDailyLimit =>
      int.tryParse(
        environment()['RAYSTO_AI_TENANT_DAILY_MICROS'] ?? '',
      ) ??
      5000000;

  static double rate(String name) {
    final value = double.tryParse(environment()[name] ?? '');
    if (value == null || !value.isFinite || value <= 0 || value > 1000) {
      _fail(
        'ai_pricing_required',
        'Configure current model token prices before using AI.',
      );
    }
    return value;
  }

  static int cost(int input, int output) =>
      (max(0, input) * rate('RAYSTO_AI_INPUT_USD_PER_MILLION') +
              max(0, output) * rate('RAYSTO_AI_OUTPUT_USD_PER_MILLION'))
          .ceil();

  static String _day(DateTime at) => at.toIso8601String().substring(0, 10);

  /// The budget rows an entry draws on, in lock order.
  static List<(String, int)> _rows(
    String stage,
    String? feature,
    int? restaurantId,
    DateTime at,
  ) => [
    (stage, _stageLimits[stage]!),
    if (stage == 'hackathon' && feature != null)
      ('$stage:feature:$feature', features[feature] ?? 0),
    if (stage == 'hackathon' && restaurantId != null)
      ('$stage:tenant:$restaurantId:${_day(at)}', tenantDailyLimit),
  ];

  static Future<int> reserve(
    Session s,
    String key, {
    int rounds = 4,
    int output = 4096,
    String feature = 'chat',
    int? restaurantId,
    int? flatMicros,
  }) => s.db.transaction((tx) async {
    final amount = flatMicros ?? cost(16384 * rounds, output * rounds);
    final currentStage = stage;
    if (currentStage == 'hackathon' && !features.containsKey(feature)) {
      _fail('ai_feature_unknown', 'This AI feature has no allowance.');
    }
    final rows = <AiSpendBudget>[];
    for (final (name, limit) in _rows(
      currentStage,
      feature,
      restaurantId,
      _now(),
    )) {
      await AiSpendBudget.db.insert(
        s,
        [
          AiSpendBudget(
            stage: name,
            limitMicros: limit,
            reservedMicros: 0,
            spentMicros: 0,
          ),
        ],
        ignoreConflicts: true,
        transaction: tx,
      );
      rows.add(
        (await AiSpendBudget.db.findFirstRow(
          s,
          where: (t) => t.stage.equals(name),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ))!,
      );
    }
    final old = await AiSpendEntry.db.findFirstRow(
      s,
      where: (t) => t.sourceKey.equals(key),
      transaction: tx,
    );
    if (old != null) {
      _fail(
        'ai_run_already_reserved',
        'This AI attempt already consumed its budget reservation.',
      );
    }
    if (rows.any(
      (b) => b.spentMicros + b.reservedMicros + amount > b.limitMicros,
    )) {
      _fail(
        'ai_budget_exhausted',
        'AI allowance reached. Menu, ordering and payment remain available.',
      );
    }
    for (final b in rows) {
      b.reservedMicros += amount;
      await AiSpendBudget.db.updateRow(s, b, transaction: tx);
    }
    await AiSpendEntry.db.insertRow(
      s,
      AiSpendEntry(
        sourceKey: key,
        stage: currentStage,
        reservedMicros: amount,
        chargedMicros: 0,
        settled: false,
        feature: feature,
        restaurantId: restaurantId,
        createdAt: _now(),
      ),
      transaction: tx,
    );
    return amount;
  });

  static Future<int> settle(Session s, String key, {int? actualMicros}) =>
      s.db.transaction((tx) async {
        final entry = await AiSpendEntry.db.findFirstRow(
          s,
          where: (t) => t.sourceKey.equals(key),
          transaction: tx,
        );
        if (entry == null) return 0;
        final rows = <AiSpendBudget>[];
        for (final (name, _) in _rows(
          entry.stage,
          entry.feature,
          entry.restaurantId,
          entry.createdAt,
        )) {
          final b = await AiSpendBudget.db.findFirstRow(
            s,
            where: (t) => t.stage.equals(name),
            transaction: tx,
            lockMode: LockMode.forUpdate,
          );
          if (b != null) rows.add(b);
        }
        final fresh = (await AiSpendEntry.db.findById(
          s,
          entry.id!,
          transaction: tx,
        ))!;
        if (fresh.settled) return fresh.chargedMicros;
        final charged = max(0, actualMicros ?? fresh.reservedMicros);
        for (final b in rows) {
          b.reservedMicros -= fresh.reservedMicros;
          b.spentMicros += charged;
          await AiSpendBudget.db.updateRow(s, b, transaction: tx);
        }
        fresh.chargedMicros = charged;
        fresh.settled = true;
        await AiSpendEntry.db.updateRow(s, fresh, transaction: tx);
        return fresh.chargedMicros;
      });

  static int? usageCost(Json response) {
    final usage = response['usageMetadata'];
    if (usage is! Map ||
        usage['promptTokenCount'] is! int ||
        usage['totalTokenCount'] is! int) {
      return null;
    }
    final input = usage['promptTokenCount'] as int;
    // Cached tokens are conservatively billed at the regular input price.
    return cost(input, max(0, (usage['totalTokenCount'] as int) - input));
  }
}
