"""Independent Decimal reference for the authored USD owner exercises."""
from decimal import Decimal, ROUND_HALF_UP, ROUND_CEILING
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
fixture = json.loads((root / 'docs/impact-innovation/exercises.json').read_text(encoding='utf-8'))
def money(n):
    return int(n.quantize(Decimal(1), rounding=ROUND_HALF_UP))
for e in fixture['exercises']:
    portion = Decimal(e['quantity']) / 1000
    cost = money(portion * e['currentUnitCostMinor'])
    previous = money(portion * e['previousUnitCostMinor'])
    current = e['priceMinor']; target = Decimal(fixture['targetBps']) / 10000
    # Algebraic solution, independent from the Dart candidate search.
    minimum = Decimal(cost) / (1 - target)
    increment = fixture['incrementMinor']
    candidate = int((minimum / increment).to_integral_value(rounding=ROUND_CEILING)) * increment
    contribution = candidate - cost
    expected = {
        'previousCostMinor': previous, 'costMinor': cost, 'costIncreaseMinor': cost - previous,
        'keepContributionMinor': current - cost, 'recommendedPriceMinor': candidate,
        'recommendedContributionMinor': contribution,
        'breakEvenUnits': int((Decimal((current - cost) * fixture['baselineUnits']) / contribution).to_integral_value(rounding=ROUND_CEILING)),
        'requiredCostReductionMinor': cost - money(Decimal(current) * (1 - target)),
        'fivePercentCapFeasible': candidate <= current * Decimal('1.05'),
        'contributionAt100UnitsMinor': contribution * 100,
        'contributionAt90UnitsMinor': contribution * 90,
        'contributionAt80UnitsMinor': contribution * 80,
        'customContributionMinor': e['customPriceMinor'] - cost,
    }
    assert expected == e['expected'], (e['id'], expected, e['expected'])
    assert candidate <= current * Decimal('1.10')
    print(f"PASS exercise {e['id']}: {len(expected)} exact reference values; provenance=synthetic")
