/// Typed boundaries for the shared command/query responses. Clients validate
/// the server result; they never substitute zero or recalculate money.
typedef FinanceJson = Map<String, dynamic>;

class PriceComparisonDto {
  PriceComparisonDto.fromJson(FinanceJson value)
    : data = Map.unmodifiable(value),
      id = _integer(value, 'id'),
      revision = _integer(value, 'revision'),
      productId = _integer(value, 'productId'),
      currency = _text(value, 'currency'),
      valid = _boolean(value, 'valid'),
      expiresAt = DateTime.parse(_text(value, 'expiresAt')) {
    if (value['options'] is! List || (value['options'] as List).isEmpty) {
      throw const FormatException('A comparison needs calculated options.');
    }
    for (final option in value['options'] as List) {
      if (option is! FinanceJson) {
        throw const FormatException('Invalid comparison option.');
      }
      for (final key in [
        'priceMinor',
        'netPriceMinor',
        'costMinor',
        'feeMinor',
        'contributionMinor',
      ]) {
        _integer(option, key);
      }
      _boolean(option, 'publishable');
    }
  }
  final FinanceJson data;
  final int id, revision, productId;
  final String currency;
  final bool valid;
  final DateTime expiresAt;
}

int _integer(FinanceJson data, String field) {
  final value = data[field];
  if (value is! int) throw FormatException('Invalid financial field: $field');
  return value;
}

int? _optionalInteger(FinanceJson data, String field) =>
    data[field] == null ? null : _integer(data, field);
String _text(FinanceJson data, String field) {
  final value = data[field];
  if (value is! String || value.isEmpty) {
    throw FormatException('Invalid financial field: $field');
  }
  return value;
}

bool _boolean(FinanceJson data, String field) {
  final value = data[field];
  if (value is! bool) throw FormatException('Invalid financial field: $field');
  return value;
}

class FinanceSummaryDto {
  FinanceSummaryDto.fromJson(FinanceJson value)
    : data = Map.unmodifiable(value),
      currency = _text(value, 'currency'),
      basis = _text(value, 'basis'),
      netSalesMinor = _integer(value, 'netSalesMinor'),
      recognizedCostsMinor = _integer(value, 'recognizedCostsMinor'),
      operatingResultMinor = _optionalInteger(value, 'operatingResultMinor'),
      recordedResultMinor = _integer(value, 'recordedResultMinor');
  final FinanceJson data;
  final String currency, basis;
  final int netSalesMinor, recognizedCostsMinor, recordedResultMinor;
  final int? operatingResultMinor;
}

class ProductCostDto {
  ProductCostDto.fromJson(FinanceJson value)
    : data = Map.unmodifiable(value),
      productId = _integer(value, 'productId'),
      currency = _text(value, 'currency'),
      recipeVersion = _integer(value, 'recipeVersion'),
      priceMinor = _integer(value, 'priceMinor'),
      complete = _boolean(value, 'complete'),
      replacementCostMinor = _optionalInteger(value, 'replacementCostMinor'),
      contributionMinor = _optionalInteger(value, 'contributionMinor') {
    if (complete &&
        (replacementCostMinor == null || contributionMinor == null)) {
      throw const FormatException(
        'A complete cost response must contain its calculated amounts.',
      );
    }
  }
  final FinanceJson data;
  final int productId, recipeVersion, priceMinor;
  final String currency;
  final bool complete;
  final int? replacementCostMinor, contributionMinor;
}

class PricingPolicyDto {
  PricingPolicyDto.fromJson(FinanceJson value)
    : data = Map.unmodifiable(value),
      version = _integer(value, 'version'),
      confirmed = _boolean(value, 'confirmed'),
      targetBps = _optionalInteger(value, 'targetBps'),
      maxIncreaseBps = _integer(value, 'maxIncreaseBps'),
      incrementMinor = _integer(value, 'incrementMinor') {
    if (confirmed && targetBps == null) {
      throw const FormatException(
        'A confirmed policy needs an owner-defined target.',
      );
    }
  }
  final FinanceJson data;
  final int version, maxIncreaseBps, incrementMinor;
  final int? targetBps;
  final bool confirmed;
}

class PricingScenarioDto {
  PricingScenarioDto.fromJson(FinanceJson value)
    : data = Map.unmodifiable(value),
      id = _integer(value, 'id'),
      productId = _integer(value, 'productId'),
      feasible = _boolean(value, 'feasible'),
      expiresAt = DateTime.parse(_text(value, 'expiresAt')) {
    final current = value['current'];
    if (current is! FinanceJson) {
      throw const FormatException(
        'A scenario must include its current-price comparison.',
      );
    }
    _integer(current, 'priceMinor');
    final recommended = value['recommended'];
    if (feasible && recommended is! FinanceJson) {
      throw const FormatException(
        'A feasible scenario must include its calculated candidate.',
      );
    }
    if (recommended is FinanceJson) _integer(recommended, 'priceMinor');
  }
  final FinanceJson data;
  final int id, productId;
  final bool feasible;
  final DateTime expiresAt;
}
