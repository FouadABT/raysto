"use client";
import { useEffect, useRef, useState } from 'react';
import type { ConnectedApi } from '@/lib/connected/api';
import { currency, type Json } from '@/lib/connected/contracts';
import { financeApi, knownMoney, scenarioAction, type CostProduct, type FinancialSummary, type PricingPolicy, type PricingScenario } from '@/lib/connected/finance';
import { RaystoGrid } from './raysto-grid';
import { moneyCol, countCol } from '@/lib/connected/grid-columns';
import { FinanceStudio } from './finance-studio';
import { PriceComparisonPanel } from './price-comparison';
import type { PriceComparison } from '@/lib/connected/finance';
import './finance-section.css';

type Review = { actionId: number; version: number; preview: Json };
export function FinanceSection({ api, tenant, revision, onDirty }: {
  api: ConnectedApi; tenant: number; revision: string; onDirty?: (dirty: boolean) => void;
}) {
  const [products, setProducts] = useState<CostProduct[]>([]);
  const [policy, setPolicy] = useState<PricingPolicy>();
  const [summary, setSummary] = useState<FinancialSummary>();
  const [accounting, setAccounting] = useState<Json>();
  const [showAccounting, setShowAccounting] = useState(false);
  const [selected, setSelected] = useState<number>();
  const [scenario, setScenario] = useState<PricingScenario>();
  const [comparison, setComparison] = useState<PriceComparison>();
  const [guided, setGuided] = useState(false);
  const [newDishVersion, setNewDishVersion] = useState<number>();
  const [setup,setSetup]=useState<Json>();
  const [comparisonDirty,setComparisonDirty]=useState(false);
  const [review, setReview] = useState<Review>();
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const [tick, setTick] = useState(0);
  const [showPolicy, setShowPolicy] = useState(false);
  const [editRecipe, setEditRecipe] = useState(false);
  const [receipt, setReceipt] = useState<number>();
  const [units, setUnits] = useState('100');
  const [volume, setVolume] = useState('-10');
  const generation = useRef(0);
  const dirtySources = useRef(new Set<string>());
  const formRequests = useRef(new Map<string, string>());
  function formCommand(name: string, data: Json, version: number) {
    const fingerprint = JSON.stringify([name, version, data]);
    let key = formRequests.current.get(fingerprint);
    if (!key) { key = crypto.randomUUID(); formRequests.current.set(fingerprint, key); }
    return api.command(name, tenant, data, { version, key });
  }
  function markDirty(source: string, dirty: boolean) {
    if(source==='comparison')setComparisonDirty(dirty);
    if (dirty) dirtySources.current.add(source); else dirtySources.current.delete(source);
    onDirty?.(dirtySources.current.size > 0);
  }
  function chooseProduct(id: number) {
    if (busy || editRecipe) return;
    if(id !== selected && dirtySources.current.has('comparison') && !window.confirm('Discard unsaved comparison inputs?')) return;
    if (id !== selected && dirtySources.current.has('receipt') && !window.confirm('Discard the unsaved receipt review?')) return;
    setSelected(id);
    setComparison(undefined); markDirty('comparison',false);
  }
  useEffect(() => {
    const controller = new AbortController(), current = ++generation.current;
    setError('');
    void Promise.all([financeApi(api, tenant).products(controller.signal), financeApi(api, tenant).policy(controller.signal),
      financeApi(api, tenant).summary(controller.signal), api.query<Json>('finance.policy', { restaurantId: tenant }, controller.signal)]).then(([p, policy, summary, accounting]) => {
      if (current !== generation.current || controller.signal.aborted) return;
      setProducts(p.rows); setPolicy(policy); setSummary(summary); setAccounting(accounting);
      const requested = Number(new URLSearchParams(window.location.search).get('product'));
      setSelected(old => p.rows.some(p => p.productId === old) ? old : p.rows.find(p => p.productId === requested)?.productId ?? p.rows[0]?.productId);
    }).catch(e => { if (!controller.signal.aborted) setError(String(e)); });
    return () => { controller.abort(); generation.current++; };
  }, [api, tenant, revision, tick]);
  useEffect(() => { setScenario(undefined); setReview(undefined); setReceipt(undefined); setComparison(undefined); }, [selected, tenant]);
  const product = products.find(p => p.productId === selected);
  useEffect(()=>{const controller=new AbortController();setSetup(undefined);
    if(selected)void api.query<Json>('costing.investigation',{restaurantId:tenant,productId:selected},controller.signal)
      .then(v=>{if(!controller.signal.aborted)setSetup(v);}).catch(()=>{});
    return ()=>controller.abort();
  },[api,tenant,selected,tick]);
  const code = product?.currency ?? summary?.currency ?? 'USD';
  const fmt = (v: number | null | undefined) => knownMoney(v, n => currency(n, code));
  async function run(action: () => Promise<void>) {
    if (busy) return;
    const current = generation.current;
    setBusy(true); setError(''); setNotice('');
    try { await action(); } catch (e) { if (current === generation.current) setError(String(e)); }
    finally { setBusy(false); }
  }
  const canPropose = scenario && scenarioAction(scenario) === 'Prepare price review';
  return <div className="ops-finance">
    <header className="ops-finance-hero">
      <p className="ops-eyebrow">RESTAURANT FINANCES</p>
      <h2>Understand the cost. Review the decision.</h2>
      <button className="ops-btn" type="button" onClick={()=>setGuided(v=>!v)}>Investigate a cost change</button>
      <p>Receipt-backed recipe costs and owner-defined price scenarios. No menu changes or payments happen from a chart.</p>
      <button type="button" className="ops-btn secondary" onClick={() => setTick(t => t + 1)} disabled={busy}>Refresh records</button>
    </header>
    {error && <p role="alert" className="ops-error">{error}</p>}
    {notice && <p role="status" className="ops-note">{notice}</p>}
    {summary && <section aria-label="Financial basis" className="ops-finance-panel">
      <h3>{summary.basisLabel}</h3>
      <p>Period: {new Date(summary.effectiveFrom ?? summary.from).toLocaleString(undefined, { timeZone: summary.timezone ?? 'UTC' })} – {new Date(summary.to).toLocaleString(undefined, { timeZone: summary.timezone ?? 'UTC' })} ({summary.timezone ?? 'UTC'}).</p>
      <dl className="ops-finance-figures">
        <div><dt>Recorded net sales</dt><dd>{fmt(summary.netSalesMinor)}</dd></div>
        <div><dt>Recognized costs</dt><dd>{fmt(summary.recognizedCostsMinor)}</dd></div>
        <div><dt>{summary.operatingResultMinor == null ? 'Recorded result · not accrual profit' : 'Operating result'}</dt>
          <dd>{fmt(summary.operatingResultMinor ?? summary.recordedResultMinor)}</dd></div>
      </dl>
      {summary.basis === 'management-accrual-v1' && <dl className="ops-finance-figures">
        <div><dt>Collected money</dt><dd>{fmt(summary.collectedMoneyMinor)}</dd></div>
        <div><dt>Recorded cash position</dt><dd>{fmt(summary.recordedCashPositionMinor)}</dd></div>
        <div><dt>Payables</dt><dd>{fmt(summary.payablesMinor)}</dd></div>
        <div><dt>Receivables</dt><dd>{fmt(summary.receivablesMinor)}</dd></div>
        <div><dt>Customer deposits</dt><dd>{fmt(summary.customerDepositsMinor)}</dd></div>
      </dl>}
      <p>{summary.balanced ? 'Journal balances.' : 'Journal discrepancy: investigate before relying on this report.'}
        {summary.estimated ? ' Some costs or fees are estimates.' : ''}</p>
      {summary.limitations.map(l => <p className="ops-note" key={l}>{l}</p>)}
      {accounting?.configured === false && <button className="ops-btn secondary" disabled={busy || showAccounting || editRecipe || showPolicy} onClick={() => setShowAccounting(true)}>Review accounting cutover</button>}
      {showAccounting && <AccountingEditor currencyCode={code} onDirty={v => markDirty('accounting', v)} cancel={() => setShowAccounting(false)} save={async data => {
        await formCommand('finance.policy.save', data, 0); setShowAccounting(false); setTick(t => t + 1);
      }} />}
    </section>}
    <section className="ops-finance-panel" aria-label="Cost coverage">
      <h3>Sales and margins</h3>
      <p>{products.filter(p => p.complete).length} of {products.length} dishes have complete recipe, packaging, receipt and tax inputs.</p>
      <button className="ops-btn secondary" disabled={busy || newDishVersion!==undefined} onClick={()=>void run(async()=>{
        const menu=await api.query<{menuVersion:number}>('menu.manage',{restaurantId:tenant});
        setNewDishVersion(menu.menuVersion);
      })}>Add a dish for investigation</button>
      {newDishVersion!==undefined&&<DraftForm onDirty={v=>markDirty('newDish',v)} cancel={()=>setNewDishVersion(undefined)} save={async f=>{
        const price=Number(f.get('price'))*100;
        if(!Number.isFinite(price)||price<1||Math.abs(price-Math.round(price))>0.00001)throw Error('Enter a price with at most two decimal places.');
        await formCommand('menu.save',{name:String(f.get('name')).trim(),category:String(f.get('category')).trim(),priceMinor:Math.round(price),available:false,modifiers:[]},newDishVersion);
        setNewDishVersion(undefined);setTick(t=>t+1);
      }}>
        <legend>Add one dish</legend>
        <p>This creates an unavailable menu item for costing. Review availability separately in menu management before selling it.</p>
        <label>Dish name<input name="name" required maxLength={150}/></label>
        <label>Menu category<input name="category" required maxLength={80}/></label>
        <label>Current selling price ({code})<input name="price" type="number" required min="0.01" step="0.01"/></label>
      </DraftForm>}
      <div className="ops-finance-select">
        <label>Inspect a dish<select value={selected ?? ''} onChange={e => chooseProduct(Number(e.target.value))} disabled={busy || editRecipe}>
          {products.map(p => <option key={p.productId} value={p.productId}>{p.name}{p.complete ? '' : ' · incomplete cost'}</option>)}
        </select></label>
        <button className="ops-btn secondary" type="button" onClick={() => setShowPolicy(true)} disabled={busy || showPolicy || editRecipe}>Owner pricing policy</button>
      </div>
      {showPolicy && policy && <PolicyEditor key={tenant} policy={policy} products={products} currencyCode={code} onDirty={v => markDirty('policy', v)} cancel={() => setShowPolicy(false)}
        save={async (data, version) => { await formCommand('pricing.policy.save', data, version);
          setShowPolicy(false); setTick(t => t + 1); setScenario(undefined); }} />}
    </section>
    {product && <>
      {guided&&<section className="ops-finance-panel" aria-label="One dish setup">
        <h3>Start with {product.name}</h3>
        <p>Set up one dish. Payroll and accounting opening balances are not required for this cost comparison.</p>
        <button className="ops-btn" disabled={busy} onClick={()=>void run(async()=>{
          const state=await api.command<Json>('costing.investigation.checkpoint',tenant,{productId:product.productId});setSetup(state);
        })}>Save setup checkpoint</button>
        {setup?.startedAt!=null&&<p>Setup started {String(setup.startedAt)} · elapsed setup {setup.elapsedSetupSeconds==null?'pending':`${String(setup.elapsedSetupSeconds)} seconds`}. {setup.alreadyCompleteAtStart===true?'This dish already had complete inputs at the start.':''}</p>}
        <p>Setup timing includes pauses. Research sessions measure active effort separately.</p>
        <ol>
          <li><a href="?section=supplies">Review supplier document and delivery</a>. Confirm extracted values before recording a receipt; uploading does not approve a bill or payment.</li>
          <li>Inspect ingredient receipts below and confirm their purchase units.</li>
          <li>Edit this recipe’s quantities, conversions, yield and packaging.</li>
          <li>Confirm the owner pricing policy, then compare the options.</li>
        </ol>
        <p>{product.complete?'This dish has the required cost inputs.':`${product.missing.length} missing inputs for this dish.`} Saved recipe and receipt steps remain available when you return.</p>
        {product.missing.map(m=><p key={m}>{m}</p>)}
        <button className="ops-btn secondary" disabled={busy||editRecipe||showPolicy} onClick={()=>setEditRecipe(true)}>Review recipe inputs</button>
      </section>}
      <section className="ops-finance-panel" aria-label={`${product.name} cost evidence`}>
        <h3>{product.name}</h3>
        <dl className="ops-finance-figures">
          <div><dt>Menu price</dt><dd>{fmt(product.priceMinor)}</dd></div>
          <div><dt>Replacement cost</dt><dd>{fmt(product.replacementCostMinor)}</dd></div>
          <div><dt>Contribution before fees and overhead</dt><dd>{fmt(product.contributionMinor)}</dd></div>
        </dl>
        {product.missing.length > 0 && <div role="note"><strong>Complete these inputs before recommending a price</strong>
          <ul>{product.missing.map(m => <li key={m}>{m}</li>)}</ul></div>}
        <p className="ops-note">Recipe revision {product.recipeVersion}. Latest confirmed receipt cost; not FIFO or weighted-average valuation.</p>
        {product.change?.complete && <p>Recorded recipe-cost change: {fmt(product.change.costIncreaseMinor)}. {product.change.assumption}</p>}
        <div className="ops-finance-table" tabIndex={0} role="region" aria-label="Ingredient evidence; scroll horizontally for receipt controls"><table><caption>Ingredient evidence · scroll across for receipts on a small screen</caption>
          <thead><tr><th>Ingredient</th><th>Recipe quantity</th><th>Cost</th><th>Receipt</th></tr></thead>
          <tbody>{product.lines.map((l, i) => <tr key={`${l.stockItemId}:${i}`}><th scope="row">{l.name}</th>
            <td>{l.quantityMicros / 1000000} {l.unit ?? l.purchaseUnit}</td><td>{fmt(l.costMinor)}</td>
            <td>{l.source.id ? <button className="ops-btn secondary" type="button" onClick={() => setReceipt(l.source.id!)}>Inspect receipt</button> : 'Not confirmed'}</td></tr>)}</tbody>
        </table></div>
        {receipt && <ReceiptEvidence key={`${tenant}:${receipt}`} api={api} tenant={tenant} id={receipt} onDirty={v => markDirty('receipt', v)} close={() => setReceipt(undefined)} changed={() => setTick(t => t + 1)} />}
        <button className="ops-btn secondary" type="button" onClick={() => setEditRecipe(true)} disabled={busy || editRecipe || showPolicy}>Edit recipe and packaging</button>
        {editRecipe && <RecipeEditor api={api} tenant={tenant} product={product} onDirty={v => markDirty('recipe', v)} cancel={() => setEditRecipe(false)} save={async (data, version) => {
          await formCommand('costing.recipe.save', { productId: product.productId, ...data }, version);
          setEditRecipe(false); setTick(t => t + 1); setScenario(undefined);
        }} />}
      </section>
      <section className="ops-finance-panel" aria-label="Price scenario">
        <h3>Compare an owner-target scenario</h3>
        <p>Demand response is an assumption. The owner’s target and cap determine the price candidates.</p>
        <form className="ops-finance-select" onSubmit={e => { e.preventDefault(); void run(async () => {
          const value = await financeApi(api, tenant).scenario(product.productId, Number(units), Math.round(Number(volume) * 100));
          setScenario(value); setReview(undefined);
        }); }}>
          <label>Baseline units<input type="number" min="1" max="1000000" required value={units} onChange={e => setUnits(e.target.value)} /></label>
          <label>Assumed volume change (%)<input type="number" min="-100" max="100" step="0.01" required value={volume} onChange={e => setVolume(e.target.value)} /></label>
          <button className="ops-btn" type="submit" disabled={busy || !product.complete || !policy?.confirmed}>Calculate scenario</button>
        </form>
        {!policy?.confirmed && <p role="note">The owner must confirm a pricing target first.</p>}
        {scenario && <>
          <p><strong>Scenario:</strong> {scenario.kind === 'price-restoration' ? `Restore the previous reviewed price: ${fmt(scenario.recommended?.priceMinor)}. ${scenario.targetMet ? 'The current contribution target is met.' : 'This price is below the current contribution target.'}` : scenario.feasible ? `Lowest candidate within the target and cap: ${fmt(scenario.recommended?.priceMinor)}.` : 'No price meets the target within the owner’s limits.'}</p>
          <p>Break-even against the baseline contribution: {scenario.breakEvenUnits ?? 'not applicable'} units.</p>
          <div className="ops-finance-table"><table><caption>Assumed demand response</caption>
            <thead><tr><th>Volume change</th><th>Units</th><th>Projected contribution</th></tr></thead>
            <tbody>{scenario.sensitivity.map(r => <tr key={r.volumeChangeBps}><td>{r.volumeChangeBps / 100}%</td><td>{r.units}</td><td>{fmt(r.contributionMinor)}</td></tr>)}</tbody>
          </table></div>
          {scenario.assumptions.map(a => <p className="ops-note" key={a}>{a}</p>)}
          <button className="ops-btn" type="button" disabled={busy || !canPropose || !!review} onClick={() => void run(async () => {
            const checked = await api.query<PricingScenario>('pricing.scenario', { restaurantId: tenant, id: scenario.id });
            setScenario(checked);
            if (!checked.validForPublication) throw new Error(scenarioAction(checked));
            setReview(await financeApi(api, tenant).propose(scenario.id));
          })}>{review ? 'Price review prepared' : scenarioAction(scenario)}</button>
          {review && <div className="ops-finance-review" role="region" aria-label="Review menu price change">
            <h4>Review before publishing</h4>
            <p>{product.name}: {fmt(Number(review.preview.fromMinor))} → {fmt(Number(review.preview.toMinor))}.</p>
            <p>Applies immediately to new quotes. Existing orders and PayPal checkout amounts stay frozen. This does not send money.</p>
            <button className="ops-btn" disabled={busy} onClick={() => void run(async () => {
              const result = await api.command<{ state: string; result?: Json }>('agent.decide', tenant, { decision: 'approve' }, { id: review.actionId, version: review.version });
              if (result.state !== 'executed') throw new Error(`Price was not published: ${result.state}. Recalculate before retrying.`);
              setNotice('Menu price published. Existing orders keep their original amounts.');
              setReview(undefined); setScenario(undefined); setTick(t => t + 1);
            })}>Approve and publish price</button>
            <button className="ops-btn secondary" disabled={busy} onClick={() => void run(async () => {
              await api.command('agent.decide', tenant, { decision: 'reject' }, { id: review.actionId, version: review.version }); setReview(undefined);
            })}>Reject proposal</button>
          </div>}
        </>}
      </section>
      <PriceComparisonPanel key={`${tenant}:${product.productId}`} api={api} tenant={tenant} product={product} policy={policy}
        value={comparison} onChange={setComparison} onPublished={()=>setTick(t=>t+1)} onDirty={v=>markDirty('comparison',v)}/>
      <FinanceStudio api={api} tenant={tenant} products={products} scenario={scenario} productId={product.productId} summary={summary} openProduct={chooseProduct} openReceipt={id=>{if(!dirtySources.current.has('receipt')||window.confirm('Discard the unsaved receipt review?'))setReceipt(id);}}
        comparison={comparison} onComparison={setComparison} comparisonDirty={comparisonDirty}
        onScenario={s => { setScenario(s); setReview(undefined); }} />
      <PriceHistory key={`${tenant}:${tick}`} api={api} tenant={tenant} currencyCode={code} products={products}
        disabled={busy || editRecipe || showPolicy || !!receipt} restore={id => run(async () => {
          const value = await api.command<PricingScenario>('pricing.undo.scenario', tenant, {}, { id });
          setSelected(value.productId); setScenario(value); setReview(undefined);
          setNotice('Restoration scenario prepared using current costs. Review its assumptions before preparing a price proposal.');
        })} />
    </>}
    {products.length > 0 && <section className="ops-finance-panel"><h3>Every dish</h3>
      <RaystoGrid<CostProduct> label="Product contribution" rows={products} columns={[
        { field: 'name', headerName: 'Dish', minWidth: 180 },
        moneyCol<CostProduct>('Menu price', 'priceMinor', code),
        { ...moneyCol<CostProduct>('Replacement cost', 'replacementCostMinor', code), valueFormatter: p => fmt(p.value) },
        { ...moneyCol<CostProduct>('Contribution', 'contributionMinor', code), valueFormatter: p => fmt(p.value) },
        countCol<CostProduct>('Recipe revision', 'recipeVersion'),
      ]} totals={false} height={360} />
      <p>Unknown costs are not zero. The detailed evidence above identifies missing inputs.</p>
    </section>}
  </div>;
}

function PriceHistory({ api, tenant, currencyCode, products, disabled, restore }: { api: ConnectedApi; tenant: number; currencyCode: string; products: CostProduct[]; disabled: boolean; restore: (id: number) => Promise<void> }) {
  const [rows, setRows] = useState<Json[]>([]), [cursor, setCursor] = useState<number | null>(null);
  const [error, setError] = useState(''), [loading, setLoading] = useState(false);
  const active = useRef(true);
  async function load(after?: number) {
    setLoading(true); setError('');
    try {
      const page = await api.query<{ rows: Json[]; nextCursor: number | null }>('pricing.history', { restaurantId: tenant, ...(after ? { cursor: after } : {}) });
      if (active.current) { setRows(previous => after ? [...previous, ...page.rows] : page.rows); setCursor(page.nextCursor); }
    } catch (e) { if (active.current) setError(String(e)); }
    finally { if (active.current) setLoading(false); }
  }
  useEffect(() => { active.current = true; void load(); return () => { active.current = false; }; }, [api, tenant]);
  return <section className="ops-finance-panel" aria-label="Price decision history"><h3>Price decision history</h3>
    <p className="ops-note">Published decisions preserve their review and original amounts. Prior orders and checkouts keep their frozen prices.</p>
    {error && <p role="alert">{error}</p>}
    <ol>{rows.map(row => <li key={Number(row.id)}>{products.find(p => p.productId === row.productId)?.name ?? 'Archived product'}: {currency(Number(row.fromMinor), currencyCode)} → {currency(Number(row.toMinor), currencyCode)} · {new Date(String(row.effectiveAt)).toLocaleString()}
      <details><summary>Review evidence</summary><p>Approved action {String(row.actionId)} · scenario {String(row.scenarioId)} · menu revision {String(row.menuVersion)}</p></details>
      <button type="button" className="ops-btn secondary" disabled={disabled || products.find(p => p.productId === row.productId)?.priceMinor !== row.toMinor}
        onClick={() => void restore(Number(row.id))}>Compare restoring this price</button>
    </li>)}</ol>
    {loading && <p role="status">Loading decisions…</p>}
    {!loading && !error && rows.length === 0 && <p>No published price decisions yet.</p>}
    {cursor && <button className="ops-btn secondary" disabled={loading} onClick={() => void load(cursor)}>Load earlier decisions</button>}
    {error && <button className="ops-btn secondary" onClick={() => void load()}>Retry history</button>}
  </section>;
}

function ReceiptEvidence({ api, tenant, id, close, changed, onDirty }: { api: ConnectedApi; tenant: number; id: number; close: () => void; changed: () => void; onDirty: (v: boolean) => void }) {
  const [record, setRecord] = useState<Json>(), [error, setError] = useState(''), [url, setUrl] = useState('');
  const objectUrl = useRef('');
  const active = useRef(true);
  const dirty = useRef(false);
  useEffect(() => {
    active.current = true; const controller = new AbortController();
    void api.query<Json>('finance.evidence', { restaurantId: tenant, id }, controller.signal).then(r => { if (!controller.signal.aborted) setRecord(r); })
      .catch(e => { if (!controller.signal.aborted) setError(String(e)); });
    return () => { active.current = false; controller.abort(); if (objectUrl.current) URL.revokeObjectURL(objectUrl.current); };
  }, [api, tenant, id]);
  return <aside className="ops-finance-review" aria-label="Confirmed receipt evidence">
    <h4>Confirmed receipt evidence</h4>
    {error && <p role="alert">{error}</p>}
    {record ? <><p>{String(record.ingredient)} · {String(record.quantity)} {String(record.purchaseUnit)}</p>
      <p>Receipt unit cost: {knownMoney(record.unitCostMinor as number | null, n => currency(n, String(record.currency)))} · {String(record.at)}</p>
      {(record.limitations as string[]).map(l => <p key={l}>{l}</p>)}
      {record.purchaseUnit == null && <DraftForm onDirty={v => { dirty.current = v; onDirty(v); }} cancel={close} save={async f => {
        const unit = String(f.get('unit'));
        await api.command('costing.receipt.confirm', tenant, { purchaseUnit: unit, reviewed: true, reason: String(f.get('reason')) }, { id });
        setRecord(r => r ? { ...r, purchaseUnit: unit } : r); changed();
      }}>
        <legend>Review the original purchase unit</legend>
        <label>Unit stated on the original receipt<select name="unit" required defaultValue=""><option value="">Choose the recorded unit</option>
          {['g', 'kg', 'ml', 'l', 'piece', 'unit', 'box'].map(u => <option key={u}>{u}</option>)}</select></label>
        <label>Evidence and review notes<input name="reason" required maxLength={1000} /></label>
        <label><input type="checkbox" required /> I checked the original receipt. I am not inferring its unit.</label>
      </DraftForm>}
      {record.mediaId && !url && <button className="ops-btn secondary" onClick={() => {
        void api.file(Number(record.mediaId)).then(blob => { if (!active.current) return; objectUrl.current = URL.createObjectURL(blob); setUrl(objectUrl.current); }).catch(e => { if (active.current) setError(String(e)); });
      }}>Load source document</button>}
      {url && <a className="ops-btn secondary" href={url} target="_blank" rel="noopener noreferrer">Open source document</a>}
    </> : <p role="status">Loading receipt…</p>}
    <button className="ops-btn secondary" onClick={() => { if (!dirty.current || window.confirm('Discard the unsaved receipt review?')) close(); }}>Close evidence</button>
  </aside>;
}

function DraftForm({ children, save, onDirty, cancel, changeToken }: { children: React.ReactNode; save: (form: FormData) => Promise<void>; onDirty?: (v: boolean) => void; cancel: () => void; changeToken?: string }) {
  const [busy, setBusy] = useState(false), [error, setError] = useState('');
  const dirty = useRef(false);
  const dirtyListener = useRef(onDirty);
  dirtyListener.current = onDirty;
  const previousToken = useRef(changeToken);
  useEffect(() => { if (previousToken.current !== changeToken) { dirty.current = true; dirtyListener.current?.(true); previousToken.current = changeToken; } }, [changeToken]);
  useEffect(() => {
    function beforeUnload(e: BeforeUnloadEvent) { if (dirty.current) { e.preventDefault(); e.returnValue = ''; } }
    window.addEventListener('beforeunload', beforeUnload);
    return () => { window.removeEventListener('beforeunload', beforeUnload); dirtyListener.current?.(false); };
  }, []);
  return <form className="ops-finance-form" onChange={() => { dirty.current = true; onDirty?.(true); }} onSubmit={e => {
    e.preventDefault(); if (busy) return; const form = new FormData(e.currentTarget);
    setBusy(true); setError(''); void save(form).then(() => { dirty.current = false; onDirty?.(false); })
      .catch(e => setError(String(e))).finally(() => setBusy(false));
  }}><fieldset disabled={busy}>{children}</fieldset>
    {error && <p role="alert" className="ops-error">{error}</p>}
    <div className="ops-finance-select"><button className="ops-btn" type="submit" disabled={busy}>Save</button>
      <button className="ops-btn secondary" type="button" disabled={busy} onClick={() => {
        if (!dirty.current || window.confirm('Discard the unsaved changes?')) { dirty.current = false; onDirty?.(false); cancel(); }
      }}>Cancel</button></div>
  </form>;
}

function AccountingEditor({ currencyCode, save, cancel, onDirty }: { currencyCode: string; save: (data: Json) => Promise<void>; cancel: () => void; onDirty: (dirty: boolean) => void }) {
  const accounts = { '1000': 'Recorded PayPal funds', '1010': 'Recorded cash and bank', '1100': 'Receivables', '1200': 'Inventory',
    '2000': 'Payables', '2050': 'Goods received, not invoiced', '2100': 'Tax collected', '2110': 'Recoverable tax',
    '2200': 'Tips owed', '2250': 'Wages payable', '2300': 'Customer deposits', '3000': 'Owner equity' };
  const [rows, setRows] = useState<{ id: string; account: string; debit: string; credit: string }[]>([]);
  function update(id: string, field: string, value: string) { setRows(rows => rows.map(r => r.id === id ? { ...r, [field]: value } : r)); }
  return <DraftForm cancel={cancel} onDirty={onDirty} changeToken={JSON.stringify(rows)} save={async f => save({
    reviewed: true, reason: String(f.get('reason')), opening: rows.map(r => ({ account: r.account,
      debitMinor: Math.round(Number(r.debit) * 100), creditMinor: Math.round(Number(r.credit) * 100) })),
  })}>
    <legend>Owner review · management accounting cutover</legend>
    <p>Starts when the server accepts this review. Earlier reports stay on the legacy basis. Review outstanding deposits, inventory, bills, wages and tips; do not import an unverified bank balance.</p>
    {rows.map((r, i) => <fieldset className="ops-finance-ingredient" key={r.id}><legend>Opening balance {i + 1}</legend>
      <label>Account<select required value={r.account} onChange={e => update(r.id, 'account', e.target.value)}><option value="">Choose account</option>
        {Object.entries(accounts).map(([id, label]) => <option key={id} value={id}>{label}</option>)}</select></label>
      <label>Debit ({currencyCode})<input type="number" min="0" max="1000000" step="0.01" value={r.debit} onChange={e => update(r.id, 'debit', e.target.value)} /></label>
      <label>Credit ({currencyCode})<input type="number" min="0" max="1000000" step="0.01" value={r.credit} onChange={e => update(r.id, 'credit', e.target.value)} /></label>
      <button type="button" className="ops-btn secondary" onClick={() => setRows(rows => rows.filter(row => row.id !== r.id))}>Remove opening line</button>
    </fieldset>)}
    <button type="button" className="ops-btn secondary" onClick={() => setRows(rows => [...rows, { id: crypto.randomUUID(), account: '', debit: '0', credit: '0' }])}>Add opening balance</button>
    <p>Debits and credits must balance. This cutover cannot be changed in place; corrections use reviewed journal adjustments.</p>
    <label>Review notes<textarea required name="reason" maxLength={1000} rows={3} /></label>
    <label><input type="checkbox" required /> I reviewed these balances. An empty list means zero opening balances.</label>
  </DraftForm>;
}

function PolicyEditor({ policy: currentPolicy, products, currencyCode, save, onDirty, cancel }: { policy: PricingPolicy; products: CostProduct[]; currencyCode: string; save: (d: Json, version: number) => Promise<void>; onDirty?: (v: boolean) => void; cancel: () => void }) {
  const policy = useRef(currentPolicy).current;
  return <DraftForm onDirty={onDirty} cancel={cancel} save={async f => save({
    targetBps: Math.round(Number(f.get('target')) * 100), maxIncreaseBps: Math.round(Number(f.get('cap')) * 100),
    incrementMinor: Math.round(Number(f.get('increment')) * 100), minimumMinor: Math.round(Number(f.get('minimum')) * 100), maximumMinor: Math.round(Number(f.get('maximum')) * 100),
    feeBps: Math.round(Number(f.get('fee')) * 100), feeFixedMinor: Math.round(Number(f.get('fixed')) * 100), excludedProducts: f.getAll('excluded').map(Number),
  }, policy.version)}>
    <legend>Owner-defined targets · these are not industry benchmarks</legend>
    <label>Target contribution (%)<input name="target" type="number" min="0" max="95" step="0.01" required defaultValue={policy.targetBps == null ? '' : policy.targetBps / 100} /></label>
    <label>Maximum price increase (%)<input name="cap" type="number" min="0" max="100" step="0.01" required defaultValue={policy.maxIncreaseBps / 100} /></label>
    <label>Price increment ({currencyCode})<input name="increment" type="number" min="0.01" max="1000" step="0.01" required defaultValue={policy.incrementMinor / 100} /></label>
    <label>Minimum product price ({currencyCode})<input name="minimum" type="number" min="0.01" max="1000000" step="0.01" required defaultValue={policy.minimumMinor / 100} /></label>
    <label>Maximum product price ({currencyCode})<input name="maximum" type="number" min="0.01" max="1000000" step="0.01" required defaultValue={policy.maximumMinor / 100} /></label>
    <label>Estimated payment fee (%)<input name="fee" type="number" min="0" max="50" step="0.01" required defaultValue={policy.feeBps / 100} /></label>
    <label>Estimated fixed fee allocated per item ({currencyCode})<input name="fixed" type="number" min="0" max="10000" step="0.01" required defaultValue={policy.feeFixedMinor / 100} /></label>
    <fieldset><legend>Protect products from recommendations</legend>{products.map(p => <label key={p.productId}>
      <input type="checkbox" name="excluded" value={p.productId} defaultChecked={policy.excludedProducts.includes(p.productId)} /> {p.name}</label>)}</fieldset>
    <p>Only the owner can save this policy. Zero fees exclude payment fees; shared overhead remains excluded.</p>
  </DraftForm>;
}

function RecipeEditor({ api, tenant, product, save, cancel, onDirty }: { api: ConnectedApi; tenant: number; product: CostProduct; save: (d: Json, version: number) => Promise<void>; cancel: () => void; onDirty?: (v: boolean) => void }) {
  const version = useRef(product.recipeVersion).current;
  const [stock, setStock] = useState<{ id: number; name: string; unit: string }[]>([]);
  const [error, setError] = useState('');
  const initial = product.recipe?.lines ?? product.lines;
  const [lines, setLines] = useState(initial.map(l => ({ key: crypto.randomUUID(), stockItemId: Number(l.stockItemId), quantity: String(Number(l.quantityMicros) / 1000000),
    unit: String(l.unit ?? l.purchaseUnit), yield: String(Number(l.yieldBps) / 100), packSize: String(Number(l.packSizeMicros) / 1000000), option: String(l.option ?? ''), mode: String('mode' in l ? l.mode ?? 'add' : 'add') })));
  useEffect(() => {
    const controller = new AbortController();
    void (async () => {
      const rows: typeof stock = []; let cursor: number | null = null;
      do {
        const page: { rows: typeof stock; nextCursor?: number | null } = await api.query('stock', { restaurantId: tenant, limit: 100, ...(cursor ? { cursor } : {}) }, controller.signal);
        rows.push(...page.rows); cursor = page.nextCursor ?? null;
      } while (cursor && rows.length < 1000);
      if (cursor) throw new Error('This recipe editor supports up to 1,000 stock items. No partial ingredient list is used.');
      if (!controller.signal.aborted) setStock(rows);
    })().catch(e => { if (!controller.signal.aborted) setError(String(e)); });
    return () => controller.abort();
  }, [api, tenant]);
  function update(key: string, field: string, value: string | number) { setLines(rows => rows.map(l => l.key === key ? { ...l, [field]: value } : l)); }
  return <DraftForm changeToken={JSON.stringify(lines)} save={async f => save({ lines: lines.map(l => ({ stockItemId: l.stockItemId, quantity: l.quantity, unit: l.unit,
    yieldBps: Math.round(Number(l.yield) * 100), packSize: l.packSize, mode: l.option ? l.mode : 'add', ...(l.option ? { option: l.option } : {}) })),
    packagingMinor: Math.round(Number(f.get('packaging')) * 100), packagingConfirmed: f.get('confirmed') === 'on' }, version)} cancel={cancel} onDirty={onDirty}>
    <legend>Recipe quantities and recorded conversions</legend>
    {error && <p role="alert">{error}</p>}
    {lines.map((l, index) => <fieldset className="ops-finance-ingredient" key={l.key}>
      <legend>Ingredient {index + 1}</legend>
      <label>Ingredient<select required value={l.stockItemId || ''} onChange={e => update(l.key, 'stockItemId', Number(e.target.value))}>
        <option value="">Choose an ingredient</option>{stock.map(s => <option key={s.id} value={s.id}>{s.name} · purchased in {s.unit}</option>)}</select></label>
      <label>Quantity per portion<input required type="number" min="0.000001" max="1000000" step="0.000001" value={l.quantity} onChange={e => update(l.key, 'quantity', e.target.value)} /></label>
      <label>Recipe unit<select value={l.unit} onChange={e => update(l.key, 'unit', e.target.value)}>{['g', 'kg', 'ml', 'l', 'piece', 'unit'].map(u => <option key={u}>{u}</option>)}</select></label>
      <label>Usable yield (%)<input required type="number" min="0.01" max="100" step="0.01" value={l.yield} onChange={e => update(l.key, 'yield', e.target.value)} /></label>
      <label>Units in one purchase pack<input required type="number" min="0.000001" max="1000000" step="0.000001" value={l.packSize} onChange={e => update(l.key, 'packSize', e.target.value)} /></label>
      <label>Included with<select value={l.option} onChange={e => update(l.key, 'option', e.target.value)}><option value="">Every portion</option>
        {product.modifierOptions?.map(o => <option key={o.id} value={o.id}>{o.name}</option>)}</select></label>
      {l.option && <label>Modifier adjustment<select value={l.mode} onChange={e => update(l.key, 'mode', e.target.value)}><option value="add">Add this quantity</option><option value="remove">Remove from base recipe</option></select></label>}
      <button type="button" className="ops-btn secondary" onClick={() => { setLines(rows => rows.filter(row => row.key !== l.key)); onDirty?.(true); }}>Remove ingredient</button>
    </fieldset>)}
    <button type="button" className="ops-btn secondary" onClick={() => { setLines(rows => [...rows, { key: crypto.randomUUID(), stockItemId: 0, quantity: '1', unit: 'piece', yield: '100', packSize: '1', option: '', mode: 'add' }]); onDirty?.(true); }}>Add ingredient</button>
    <p>Use one for a normal purchase unit. For a box of 12 pieces, record 12. Mass-to-volume conversions require a measured recipe; Raysto does not infer them.</p>
    <label>Packaging per portion ({product.currency})<input name="packaging" type="number" step="0.01" required min="0" defaultValue={(product.packagingMinor ?? 0) / 100} /></label>
    <label><input name="confirmed" type="checkbox" defaultChecked={product.recipe?.packagingConfirmed ?? false} /> I confirmed the packaging cost, including a genuine zero.</label>
  </DraftForm>;
}
