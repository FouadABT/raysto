/// Exact, provider-independent arithmetic for restaurant replacement costs and
/// price scenarios. Monetary outputs are minor units; quantities have six
/// decimal places. AI and clients never supply calculated totals.
class RestaurantCosting {
  static const scale = 1000000;
  static const version = 'replacement-cost-v1';
  static const units = <String, (String, int)>{
    'g': ('mass', 1),
    'kg': ('mass', 1000),
    'ml': ('volume', 1),
    'l': ('volume', 1000),
    'piece': ('count', 1),
    'unit': ('count', 1),
    'box': ('count', 1),
  };

  static int divide(int numerator, int denominator) {
    if (denominator <= 0 || numerator < 0) {
      throw ArgumentError(
        'A nonnegative amount and positive divisor are required.',
      );
    }
    return (numerator + denominator ~/ 2) ~/ denominator;
  }

  static int quantity(Object? value) {
    final text = '$value';
    if (!RegExp(r'^\d{1,9}(\.\d{1,6})?$').hasMatch(text)) {
      throw ArgumentError('Use a positive quantity with up to six decimals.');
    }
    final parts = text.split('.');
    final result =
        int.parse(parts[0]) * scale +
        int.parse((parts.length == 1 ? '' : parts[1]).padRight(6, '0'));
    if (result <= 0 || result > 1000000 * scale) {
      throw ArgumentError(
        'Quantity must be greater than zero and at most one million.',
      );
    }
    return result;
  }

  static int lineCostMicros({
    required int unitCostMinor,
    required int quantityMicros,
    required String recipeUnit,
    required String purchaseUnit,
    int yieldBps = 10000,
    int packSizeMicros = scale,
  }) {
    if (unitCostMinor < 0 ||
        unitCostMinor > 100000000 ||
        quantityMicros <= 0 ||
        quantityMicros > 1000000 * scale ||
        yieldBps < 1 ||
        yieldBps > 10000 ||
        packSizeMicros <= 0) {
      throw ArgumentError('Invalid cost, quantity, yield or pack size.');
    }
    final from = units[recipeUnit];
    final to = units[purchaseUnit];
    if (from == null || to == null || from.$1 != to.$1) {
      throw ArgumentError(
        'Record a supported conversion within mass, volume or count.',
      );
    }
    final n =
        BigInt.from(unitCostMinor) *
        BigInt.from(quantityMicros) *
        BigInt.from(from.$2) *
        BigInt.from(10000) *
        BigInt.from(scale);
    final d =
        BigInt.from(to.$2) *
        BigInt.from(yieldBps) *
        BigInt.from(packSizeMicros);
    final amount = (n + d ~/ BigInt.two) ~/ d;
    if (amount > BigInt.from(100000000) * BigInt.from(scale)) {
      throw ArgumentError('Recipe cost exceeds the supported range.');
    }
    return amount.toInt();
  }

  static Map<String, dynamic> scenario({
    required int priceMinor,
    required int costMinor,
    required int taxBps,
    required bool pricesIncludeTax,
    required int targetBps,
    required int maxIncreaseBps,
    required int incrementMinor,
    int minimumMinor = 1,
    int maximumMinor = 100000000,
    int feeBps = 0,
    int feeFixedMinor = 0,
    int baselineUnits = 100,
    int volumeChangeBps = 0,
    int? reviewedPriceMinor,
  }) {
    if (priceMinor < 1 ||
        priceMinor > 100000000 ||
        costMinor < 0 ||
        costMinor > 100000000 ||
        taxBps < 0 ||
        taxBps > 10000 ||
        targetBps < 0 ||
        targetBps > 9500 ||
        maxIncreaseBps < 0 ||
        maxIncreaseBps > 10000 ||
        incrementMinor < 1 ||
        incrementMinor > 100000 ||
        minimumMinor < 1 ||
        maximumMinor < minimumMinor ||
        maximumMinor > 100000000 ||
        feeBps < 0 ||
        feeBps > 5000 ||
        feeFixedMinor < 0 ||
        feeFixedMinor > 1000000 ||
        baselineUnits < 1 ||
        baselineUnits > 1000000 ||
        volumeChangeBps < -10000 ||
        volumeChangeBps > 10000) {
      throw ArgumentError('Invalid pricing constraints.');
    }
    Map<String, dynamic> at(int price) => pricePoint(
      priceMinor: price,
      costMinor: costMinor,
      taxBps: taxBps,
      pricesIncludeTax: pricesIncludeTax,
      feeBps: feeBps,
      feeFixedMinor: feeFixedMinor,
    );

    final current = at(priceMinor);
    final cap = (priceMinor * (10000 + maxIncreaseBps)) ~/ 10000;
    final upper = cap < maximumMinor ? cap : maximumMinor;
    int? recommended;
    bool meets(int p) {
      final r = at(p);
      return (r['contributionMinor'] as int) * 10000 >=
          (r['netPriceMinor'] as int) * targetBps;
    }

    // Tax and fee rounding can make a threshold non-monotonic by one cent.
    // Inspect the bounded price grid exactly rather than binary-searching it.
    final lo =
        ((minimumMinor > priceMinor ? minimumMinor : priceMinor) +
            incrementMinor -
            1) ~/
        incrementMinor;
    final hi = upper ~/ incrementMinor;
    if (hi - lo > 20000) {
      throw ArgumentError(
        'Use a larger rounding increment for this price range.',
      );
    }
    for (var step = lo; step <= hi; step++) {
      final candidate = step * incrementMinor;
      if (meets(candidate)) {
        recommended = candidate;
        break;
      }
    }
    if (priceMinor >= minimumMinor &&
        priceMinor <= maximumMinor &&
        meets(priceMinor)) {
      recommended = priceMinor;
    }
    if (reviewedPriceMinor != null) {
      if (reviewedPriceMinor < minimumMinor ||
          reviewedPriceMinor > upper ||
          reviewedPriceMinor % incrementMinor != 0) {
        throw ArgumentError(
          'The reviewed restoration price is outside the current owner limits.',
        );
      }
      recommended = reviewedPriceMinor;
    }
    final proposed = recommended == null ? null : at(recommended);
    final baseline = (current['contributionMinor'] as int) * baselineUnits;
    final contribution = proposed?['contributionMinor'] as int?;
    return {
      'calculationVersion': version,
      'kind': reviewedPriceMinor == null ? 'scenario' : 'price-restoration',
      'current': current,
      'recommended': proposed,
      'feasible': proposed != null,
      'targetBps': targetBps,
      'targetMet': recommended != null && meets(recommended),
      'capMinor': upper,
      'baselineUnits': baselineUnits,
      'baselineContributionMinor': baseline,
      'breakEvenUnits':
          contribution == null || contribution <= 0 || baseline <= 0
          ? null
          : (baseline + contribution - 1) ~/ contribution,
      'sensitivity': [
        for (final change in {0, -1000, -2000, volumeChangeBps})
          {
            'volumeChangeBps': change,
            'units': baselineUnits * (10000 + change) ~/ 10000,
            'contributionMinor': contribution == null
                ? null
                : contribution * (baselineUnits * (10000 + change) ~/ 10000),
          },
      ],
      'assumptions': [
        'Volume response is assumed, not predicted.',
        if (reviewedPriceMinor != null)
          'This restores a previous reviewed price using current costs. It may fall below the contribution target; inspect targetMet and review before publishing.',
        'Contribution excludes shared overhead, wages and unrecorded costs.',
        'Fee settings are estimates, not verified PayPal fees.',
      ],
    };
  }

  static Map<String, dynamic> pricePoint({
    required int priceMinor,
    required int costMinor,
    required int taxBps,
    required bool pricesIncludeTax,
    required int feeBps,
    required int feeFixedMinor,
  }) {
    final price = priceMinor;
    final net = pricesIncludeTax
        ? divide(price * 10000, 10000 + taxBps)
        : price;
    final gross = pricesIncludeTax
        ? price
        : price + divide(price * taxBps, 10000);
    final fee = divide(gross * feeBps, 10000) + feeFixedMinor;
    final contribution = net - costMinor - fee;
    return <String, dynamic>{
      'priceMinor': price,
      'netPriceMinor': net,
      'grossPriceMinor': gross,
      'costMinor': costMinor,
      'feeMinor': fee,
      'contributionMinor': contribution,
      'contributionBps': net == 0 ? null : (contribution * 10000 / net).round(),
    };
  }

  /// All alternatives share today's confirmed cost, never the old supplier cost.
  static Map<String, dynamic> comparison({
    required int priceMinor,
    required int costMinor,
    required int taxBps,
    required bool pricesIncludeTax,
    required int targetBps,
    required int maxIncreaseBps,
    required int incrementMinor,
    required int minimumMinor,
    required int maximumMinor,
    required int feeBps,
    required int feeFixedMinor,
    required int baselineUnits,
    required int volumeChangeBps,
    int? candidatePriceMinor,
  }) {
    final base = scenario(
      priceMinor: priceMinor,
      costMinor: costMinor,
      taxBps: taxBps,
      pricesIncludeTax: pricesIncludeTax,
      targetBps: targetBps,
      maxIncreaseBps: maxIncreaseBps,
      incrementMinor: incrementMinor,
      minimumMinor: minimumMinor,
      maximumMinor: maximumMinor,
      feeBps: feeBps,
      feeFixedMinor: feeFixedMinor,
      baselineUnits: baselineUnits,
      volumeChangeBps: volumeChangeBps,
    );
    if (candidatePriceMinor != null &&
        (candidatePriceMinor < 1 || candidatePriceMinor > 100000000)) {
      throw ArgumentError(
        'Candidate price must be a positive bounded minor-unit amount.',
      );
    }
    final current = base['current'] as Map<String, dynamic>;
    final baseline = current['contributionMinor'] as int;
    final points = <String, Map<String, dynamic>>{
      'keep': current,
      if (base['recommended'] != null)
        'recommended': base['recommended'] as Map<String, dynamic>,
      if (candidatePriceMinor != null)
        'custom': pricePoint(
          priceMinor: candidatePriceMinor,
          costMinor: costMinor,
          taxBps: taxBps,
          pricesIncludeTax: pricesIncludeTax,
          feeBps: feeBps,
          feeFixedMinor: feeFixedMinor,
        ),
    };
    final options = <Map<String, dynamic>>[];
    for (final entry in points.entries) {
      final p = entry.value;
      final price = p['priceMinor'] as int;
      final contribution = p['contributionMinor'] as int;
      final targetMet =
          contribution * 10000 >= (p['netPriceMinor'] as int) * targetBps;
      final violations = <String>[
        if (price < minimumMinor || price > maximumMinor) 'price_bounds',
        if (price > (base['capMinor'] as int)) 'increase_cap',
        if (price % incrementMinor != 0) 'rounding_increment',
        if (!targetMet) 'contribution_target',
        if (price < priceMinor) 'price_reduction_requires_separate_review',
      ];
      options.add({
        'key': entry.key,
        ...p,
        'targetMet': targetMet,
        'violations': violations,
        'publishable':
            entry.key != 'keep' && price != priceMinor && violations.isEmpty,
        'breakEvenUnits': baseline <= 0 || contribution <= 0
            ? null
            : (baseline * baselineUnits + contribution - 1) ~/ contribution,
        'sensitivity': [
          for (final response in {0, -1000, -2000, volumeChangeBps})
            {
              'volumeChangeBps': response,
              'units': baselineUnits * (10000 + response) ~/ 10000,
              'contributionMinor':
                  contribution * (baselineUnits * (10000 + response) ~/ 10000),
            },
        ],
      });
    }
    final allowedCost =
        ((current['netPriceMinor'] as int) * (10000 - targetBps)) ~/ 10000 -
        (current['feeMinor'] as int);
    return {
      ...base,
      'kind': 'comparison',
      'options': options,
      'keepPriceCostReductionMinor': costMinor > allowedCost
          ? costMinor - allowedCost
          : 0,
      'keepPriceTargetFeasibleWithNonnegativeCost': allowedCost >= 0,
      'baselineDefinition':
          'Keep the current selling price using the current confirmed cost.',
      'costReductionExplanation':
          'Required variable-cost reduction, not an available supplier or recipe saving.',
    };
  }
}
