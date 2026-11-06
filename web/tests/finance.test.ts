import { test } from 'node:test';
import assert from 'node:assert/strict';
import { knownMoney, scenarioAction, type PricingScenario } from '../src/lib/connected/finance';
import { allowedPath } from '../src/lib/connected/proxy-allowlist';

const scenario = { expiresAt: '2026-11-05T12:15:00Z', feasible: true,
  current: { priceMinor: 800 }, recommended: { priceMinor: 880 } } as PricingScenario;
test('unknown financial amounts are not formatted as zero', () => {
  assert.equal(knownMoney(null, String), 'Unknown');
  assert.equal(knownMoney(undefined, String), 'Unknown');
  assert.equal(knownMoney(Number.NaN, String), 'Unknown');
  assert.equal(knownMoney(0, String), '0');
});
test('review is offered only while a changed scenario is publishable', () => {
  const now = Date.parse('2026-11-05T12:00:00Z');
  assert.equal(scenarioAction(scenario, now), 'Prepare price review');
  assert.equal(scenarioAction(scenario, Date.parse('2026-11-05T12:15:00Z')), 'Recalculate expired scenario');
  assert.equal(scenarioAction({ ...scenario, publicationIssue: 'stale' }, now), 'Recalculate changed inputs');
  assert.equal(scenarioAction({ ...scenario, feasible: false, recommended: null }, now), 'Target exceeds the owner’s limits');
  assert.equal(scenarioAction({ ...scenario, recommended: scenario.current }, now), 'Current price meets the target');
});
test('finance routes pass the console proxy without adding arbitrary paths', () => {
  for (const route of ['queries/finance.summary', 'queries/costing.product', 'queries/pricing.scenario',
    'commands/pricing.policy.save', 'commands/pricing.propose', 'commands/menu.price.apply', 'commands/finance.investigate'])
    assert.equal(allowedPath(route), true, route);
  assert.equal(allowedPath('commands/finance.arbitrary'), false);
  assert.equal(allowedPath('queries/finance.summary/other'), false);
});
