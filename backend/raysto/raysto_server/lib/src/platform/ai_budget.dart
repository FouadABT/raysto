part of 'platform.dart';

/// USD millionths. Budget reservations survive lost provider responses and are
/// never released on an unknown outcome, preventing retries from overspending.
class AiBudget {
  static String get stage =>
      Platform.environment['RAYSTO_AI_BUDGET_STAGE'] == 'review'
      ? 'review'
      : 'development';
  static double rate(String name) {
    final value = double.tryParse(Platform.environment[name] ?? '');
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

  static Future<int> reserve(
    Session s,
    String key, {
    int rounds = 4,
    int output = 4096,
  }) => s.db.transaction((tx) async {
    final amount = cost(16384 * rounds, output * rounds);
    final currentStage = stage;
    await AiSpendBudget.db.insert(
      s,
      [
        AiSpendBudget(
          stage: currentStage,
          limitMicros: currentStage == 'review' ? 15000000 : 35000000,
          reservedMicros: 0,
          spentMicros: 0,
        ),
      ],
      ignoreConflicts: true,
      transaction: tx,
    );
    final b = (await AiSpendBudget.db.findFirstRow(
      s,
      where: (t) => t.stage.equals(currentStage),
      transaction: tx,
      lockMode: LockMode.forUpdate,
    ))!;
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
    if (b.spentMicros + b.reservedMicros + amount > b.limitMicros) {
      _fail(
        'ai_budget_exhausted',
        'AI allowance reached. Menu, ordering and payment remain available.',
      );
    }
    b.reservedMicros += amount;
    await AiSpendBudget.db.updateRow(s, b, transaction: tx);
    await AiSpendEntry.db.insertRow(
      s,
      AiSpendEntry(
        sourceKey: key,
        stage: currentStage,
        reservedMicros: amount,
        chargedMicros: 0,
        settled: false,
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
        final b = (await AiSpendBudget.db.findFirstRow(
          s,
          where: (t) => t.stage.equals(entry.stage),
          transaction: tx,
          lockMode: LockMode.forUpdate,
        ))!;
        final fresh = (await AiSpendEntry.db.findById(
          s,
          entry.id!,
          transaction: tx,
        ))!;
        if (fresh.settled) return fresh.chargedMicros;
        final charged = actualMicros ?? fresh.reservedMicros;
        b.reservedMicros -= fresh.reservedMicros;
        b.spentMicros += max(0, charged);
        fresh.chargedMicros = max(0, charged);
        fresh.settled = true;
        await AiSpendBudget.db.updateRow(s, b, transaction: tx);
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
