/// Money literals in model prose must be present in authorized backend results.
/// This is a numeric guard, not a claim that all causal language is verified.
class FinancialNarrative {
  static bool amountsSupported(String prose, Object? evidence) {
    final amounts = <int>{}, rates = <int>{}, currencies = <String>{};
    void visit(Object? value, [String key = '']) {
      if (value is Map) {
        for (final e in value.entries) {
          visit(e.value, '${e.key}');
        }
      } else if (value is List) {
        for (final e in value) {
          visit(e, key);
        }
      } else if (value is int && key.endsWith('Minor')) {
        amounts.add(value);
      } else if (value is int && key.endsWith('Bps')) {
        rates.add(value.abs());
      } else if (value is String && key == 'currency') {
        currencies.add(value);
      }
    }

    visit(evidence);
    // Percentages must be backend results too: otherwise a model could invent
    // a margin for a price that the candidate search never evaluated.
    final percentages = RegExp(
      r'(-?\d[\d,]*(?:\.\d+)?)\s*(%|percent\b|per cent\b|bps\b|basis points?\b)',
      caseSensitive: false,
    );
    for (final match in percentages.allMatches(prose)) {
      final raw = match[1]!.replaceAll(',', '').replaceFirst('-', '');
      final parts = raw.split('.');
      final isBps = match[2]!.toLowerCase().startsWith('b');
      if (isBps && parts.length > 1 ||
          !isBps && parts.length > 1 && parts[1].length > 2) {
        return false;
      }
      final rate = isBps
          ? int.parse(raw)
          : int.parse(parts[0]) * 100 +
                int.parse((parts.length == 1 ? '' : parts[1]).padRight(2, '0'));
      if (!rates.contains(rate)) return false;
    }
    final normalized = prose.replaceAllMapped(
      RegExp(r'-\s*(USD|EUR|GBP|[$€£])\s*'),
      (m) => '${m[1]}-',
    );
    final money = RegExp(
      r'([$€£]|\bUSD|\bEUR|\bGBP)\s*(-?\d[\d,]*(?:\.\d{1,2})?)(?!\d|\.\d|[A-Za-z_])|(-?\d[\d,]*(?:\.\d{1,2})?)\s*(USD|EUR|GBP)\b',
    );
    for (final m in money.allMatches(normalized)) {
      final code = m[4] ?? {'\$': 'USD', '€': 'EUR', '£': 'GBP'}[m[1]] ?? m[1]!;
      if (!currencies.contains(code)) return false;
      final raw = (m[2] ?? m[3]!).replaceAll(',', '');
      final parts = raw.replaceFirst('-', '').split('.');
      final minor =
          (int.parse(parts[0]) * 100 +
              int.parse((parts.length == 1 ? '' : parts[1]).padRight(2, '0'))) *
          (raw.startsWith('-') ? -1 : 1);
      if (!amounts.contains(minor)) return false;
    }
    if (RegExp(
      r'([$€£]|\bUSD|\bEUR|\bGBP)\s*-?\d',
    ).hasMatch(normalized.replaceAll(money, ''))) {
      return false;
    }
    // The runtime asks for currency-symbol/code notation so unitless wording
    // cannot evade the check by calling an invented number "dollars".
    if (RegExp(
      r'\d[\d,.]*\s*(?:dollars?|euros?|pounds?|cents?)\b',
      caseSensitive: false,
    ).hasMatch(prose)) {
      return false;
    }
    return true;
  }
}
