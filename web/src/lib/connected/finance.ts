import type { ConnectedApi } from './api';
import type { Json } from './contracts';

export interface CostLine {
  stockItemId: number; name: string; unit: string; purchaseUnit: string;
  quantityMicros: number; yieldBps: number; packSizeMicros: number;
  unitCostMinor: number | null; costMinor: number | null;
  source: { type: string; id: number | null; at: string | null };
  option?: string;
}
export interface CostProduct {
  productId: number; name: string; priceMinor: number; currency: string;
  productVersion: number; recipeVersion: number; complete: boolean;
  replacementCostMinor: number | null; contributionMinor: number | null;
  netPriceMinor: number; packagingMinor: number | null; fingerprint: string;
  lines: CostLine[]; missing: string[]; excludedCosts: string[];
  recipe: { packagingConfirmed: boolean; lines: Json[] } | null;
  modifierOptions?: { id: string; name: string }[];
  change?: { complete: boolean; previousCostMinor: number | null; currentCostMinor: number | null;
    costIncreaseMinor: number | null; previousContributionMinor: number | null; assumption: string };
}
export interface PricingPolicy {
  version: number; confirmed: boolean; targetBps: number | null;
  maxIncreaseBps: number; incrementMinor: number; minimumMinor: number;
  maximumMinor: number; feeBps: number; feeFixedMinor: number; excludedProducts: number[];
}
export interface PricePoint {
  priceMinor: number; netPriceMinor: number; grossPriceMinor: number;
  costMinor: number; feeMinor: number; contributionMinor: number; contributionBps: number | null;
}
export interface PricingScenario {
  id: number; version: number; productId: number; productName: string;
  kind: 'scenario' | 'price-restoration'; targetMet?: boolean; currency?: string; current: PricePoint; recommended: PricePoint | null;
  feasible: boolean; baselineUnits: number; baselineContributionMinor: number;
  breakEvenUnits: number | null; expiresAt: string; assumptions: string[];
  sensitivity: { volumeChangeBps: number; units: number; contributionMinor: number | null }[];
  validForPublication?: boolean; publicationIssue?: string | null;
}
export interface FinancialSummary {
  currency: string; timezone?: string; basis: string; basisLabel: string; netSalesMinor: number;
  recognizedCostsMinor: number; operatingResultMinor: number | null;
  recordedResultMinor: number; balanced: boolean; complete: boolean;
  estimated: boolean; limitations: string[]; from: string; to: string;
  effectiveFrom?: string; partialPeriod?: boolean; recordedCashPositionMinor?: number | null;
  payablesMinor?: number | null; receivablesMinor?: number | null; customerDepositsMinor?: number | null; collectedMoneyMinor?: number | null;
  accounts: { account: string; name: string; balanceMinor: number }[];
}
export interface FinanceAnalysis {
  comparison?: PriceComparison | null; presentation?: DecisionView | null;
  status?: string; summary?: string; source?: string; view?: 'costing' | 'scenario' | 'money';
  taskId: number; evidence?: Record<string, Json>; businessChanges?: boolean;
  scenario?: PricingScenario | null;
}
export interface ComparisonOption extends PricePoint {
  key: 'keep' | 'recommended' | 'custom'; targetMet: boolean; violations: string[];
  publishable: boolean; breakEvenUnits: number | null; sensitivity: PricingScenario['sensitivity'];
}
export interface PriceComparison {
  id: number; version: number; revision: number; parentId: number | null;
  productId: number; productName: string; currency: string; sample: boolean;
  inputs: { baselineUnits: number; volumeChangeBps: number; maxIncreaseBps: number; candidatePriceMinor: number | null };
  options: ComparisonOption[]; policy: PricingPolicy; assumptions: string[]; changes: Json[];
  keepPriceCostReductionMinor: number; keepPriceTargetFeasibleWithNonnegativeCost: boolean;
  expiresAt: string; valid: boolean; invalidReason?: string; evidence: CostProduct;
  baselineDefinition: string; volumeBasis: string;
}
export interface PricingDecision {
  id: number; version: number; productId: number; productName: string; comparisonId: number;
  choice: 'keep' | 'propose' | 'defer' | 'reject'; reason: string; note: string; at: string;
  comparison?: PriceComparison; approval?: { id: number; status: string } | null;
}
export interface DecisionView {
  arrangement: 'side-by-side' | 'stacked'; columns: ('name' | 'price' | 'cost' | 'contribution' | 'complete')[];
  completeness: 'all' | 'complete' | 'incomplete'; sort: 'name' | 'contribution';
  widgets: ('comparison' | 'evidence')[];
}
export const financeApi = (api: ConnectedApi, restaurantId: number) => ({
  products: (signal?: AbortSignal) => api.query<{ rows: CostProduct[]; coverage: { complete: number; total: number } }>('costing.products', { restaurantId }, signal),
  policy: (signal?: AbortSignal) => api.query<PricingPolicy>('pricing.policy', { restaurantId }, signal),
  summary: (signal?: AbortSignal) => api.query<FinancialSummary>('finance.summary', { restaurantId }, signal),
  scenario: (productId: number, baselineUnits = 100, volumeChangeBps = 0) =>
    api.command<PricingScenario>('pricing.scenario.create', restaurantId, { productId, baselineUnits, volumeChangeBps }),
  propose: (scenarioId: number) => api.command<{ actionId: number; version: number; preview: Json }>('pricing.propose', restaurantId, { scenarioId }),
});

/** Safe display defaults never turn an unknown monetary input into zero. */
export const knownMoney = (value: number | null | undefined, format: (n: number) => string) =>
  typeof value === 'number' && Number.isFinite(value) ? format(value) : 'Unknown';

export function scenarioAction(s: PricingScenario, now = Date.now()): string {
  if (Date.parse(s.expiresAt) <= now) return 'Recalculate expired scenario';
  if (s.publicationIssue && s.publicationIssue !== 'no_change') return 'Recalculate changed inputs';
  if (!s.feasible || !s.recommended) return 'Target exceeds the owner’s limits';
  if (s.recommended.priceMinor === s.current.priceMinor) return s.kind === 'price-restoration' ? 'Price already restored' : 'Current price meets the target';
  return 'Prepare price review';
}

export const finance017Queries = ['costing.investigation', 'pricing.comparison', 'pricing.comparisons', 'pricing.decision', 'pricing.decisions', 'pricing.decision.outcome', 'finance.summary', 'finance.explain', 'finance.policy', 'finance.evidence', 'finance.payments', 'costing.products', 'costing.product',
  'pricing.policy', 'pricing.scenario', 'pricing.scenarios', 'pricing.history', 'finance.analysis', 'judge.story'] as const;
export const finance017Commands = ['costing.investigation.checkpoint', 'pricing.comparison.create', 'pricing.comparison.revise', 'pricing.decision.record', 'pricing.policy.save', 'pricing.scenario.create', 'pricing.undo.scenario', 'pricing.propose',
  'menu.price.apply', 'costing.recipe.save', 'finance.investigate', 'studio.turn', 'finance.policy.save', 'costing.receipt.confirm',
  'judge.story.configure', 'judge.story.start', 'judge.story.heartbeat'] as const;
