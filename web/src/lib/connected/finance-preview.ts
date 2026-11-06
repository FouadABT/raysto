import type { CostProduct, PricingPolicy, PriceComparison } from './finance';
import type { Json } from './contracts';

/** Frozen UI-review data only; the development preview cannot send commands. */
export function financePreview(asOf: string): Record<string, (p: Json) => unknown> {
  const bowl: CostProduct = {
    productId: 171, name: 'House lunch bowl · UI sample', currency: 'USD', priceMinor: 900, productVersion: 1,
    recipeVersion: 1, complete: true, replacementCostMinor: 385, netPriceMinor: 900,
    contributionMinor: 515, packagingMinor: 0, fingerprint: 'ui-review-fixture', missing: [],
    excludedCosts: ['Shared overhead', 'Payment fees'], modifierOptions: [],
    recipe: { packagingConfirmed: true, lines: [{ stockItemId: 71, quantityMicros: 350000000, unit: 'g', yieldBps: 10000, packSizeMicros: 1000000 }] },
    lines: [{ stockItemId: 71, name: 'Prepared bowl ingredients', quantityMicros: 350000000, unit: 'g', purchaseUnit: 'kg',
      unitCostMinor: 1100, yieldBps: 10000, packSizeMicros: 1000000, costMinor: 385,
      source: { type: 'stockMovement', id: 17, at: asOf } }],
    change: { complete: true, previousCostMinor: 350, currentCostMinor: 385, costIncreaseMinor: 35, previousContributionMinor: 550,
      assumption: 'Current recipe, previous confirmed receipt comparison. Not observed historical contribution.' },
  };
  const incomplete: CostProduct = { ...bowl, productId: 172, name: 'Seasonal bowl · incomplete UI sample',
    complete: false, replacementCostMinor: null, contributionMinor: null, recipe: null,
    missing: ['The ingredient receipt and packaging cost need confirmation.'], change: undefined };
  const policy: PricingPolicy = { version: 1, confirmed: true, targetBps: 6000, maxIncreaseBps: 1000, incrementMinor: 10,
    minimumMinor: 1, maximumMinor: 100000000, feeBps: 0, feeFixedMinor: 0, excludedProducts: [] };
  const comparison:PriceComparison={id:901,version:1,revision:1,parentId:null,productId:171,productName:bowl.name,currency:'USD',sample:true,
    inputs:{baselineUnits:100,volumeChangeBps:-1000,maxIncreaseBps:1000,candidatePriceMinor:null},policy,
    options:[{key:'keep',priceMinor:900,netPriceMinor:900,grossPriceMinor:900,costMinor:385,feeMinor:0,contributionMinor:515,contributionBps:5722,
      targetMet:false,publishable:false,violations:['contribution_target'],breakEvenUnits:100,sensitivity:[{volumeChangeBps:0,units:100,contributionMinor:51500},{volumeChangeBps:-1000,units:90,contributionMinor:46350},{volumeChangeBps:-2000,units:80,contributionMinor:41200}]},
      {key:'recommended',priceMinor:970,netPriceMinor:970,grossPriceMinor:970,costMinor:385,feeMinor:0,contributionMinor:585,contributionBps:6030,
      targetMet:true,publishable:true,violations:[],breakEvenUnits:89,sensitivity:[{volumeChangeBps:0,units:100,contributionMinor:58500},{volumeChangeBps:-1000,units:90,contributionMinor:52650},{volumeChangeBps:-2000,units:80,contributionMinor:46800}]}],
    assumptions:['Frozen UI sample: volume is assumed. No business result is established.'],changes:[],keepPriceCostReductionMinor:25,
    keepPriceTargetFeasibleWithNonnegativeCost:true,expiresAt:'2099-01-01T00:00:00Z',valid:true,evidence:bowl,
    baselineDefinition:'Keep current price with the newly confirmed cost',volumeBasis:'sample-assumption'};
  return {
    'costing.investigation':()=>({ready:true,stepsSaved:false,sample:true}),
    'pricing.comparisons':()=>({rows:[comparison],nextCursor:null}),
    'pricing.comparison':()=>comparison,
    'pricing.decisions':()=>({rows:[],nextCursor:null}),
    'costing.products': () => ({ rows: [bowl, incomplete], coverage: { complete: 1, total: 2 }, sample: true }),
    'pricing.policy': () => policy,
    'finance.policy': () => ({ configured: false, version: 0 }),
    'finance.summary': () => ({ currency: 'USD', timezone: 'UTC', basis: 'legacy-recorded-transactions',
      basisLabel: 'UI preview · illustrative records', netSalesMinor: 900, recognizedCostsMinor: 385, recordedResultMinor: 515,
      operatingResultMinor: null, complete: false, balanced: true, estimated: true,
      from: '2026-11-05T00:00:00Z', to: asOf, accounts: [],
      limitations: ['Frozen UI fixture. No backend, model or PayPal acceptance is established by this preview.'] }),
    'finance.evidence': () => ({ id: 17, currency: 'USD', ingredient: 'Prepared bowl ingredients', purchaseUnit: 'kg',
      stockUnit: 'kg', quantity: 1, unitCostMinor: 1100, at: asOf, mediaId: null, limitations: ['The UI preview has no private documents.'] }),
    'pricing.history': () => ({ rows: [] }),
    'finance.payments': () => ({ rows: [] }),
    'judge.story': () => ({ configured: false, active: false, busy: false, fixture: null, run: null }),
  };
}
