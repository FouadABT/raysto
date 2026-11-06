"use client";
import { createContext, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { AgStudio, AgStudioProvider, createWidgets, type AgWidgetDefinition } from 'ag-studio-react';
import { AgStudioAiModule, clientToolRunner, createAiHarness, type AgDefaultRegistry,
  type AgReportState, type AgStudioApi, type AgAiEvent, type AgWidgetApi, type AgWidgetField, type AgWidgetFieldReference, type AgWidgetDataFormat } from 'ag-studio';
import type { ConnectedApi } from '@/lib/connected/api';
import { currency, type Json } from '@/lib/connected/contracts';
import type { CostProduct, FinanceAnalysis, FinancialSummary, PricingScenario } from '@/lib/connected/finance';
import { knownMoney } from '@/lib/connected/finance';
import { studioRaystoTheme } from '@/lib/connected/studio/studio-canvas';
import { isJudgeVenue } from '@/lib/connected/judge';
import type { PriceComparison, DecisionView } from '@/lib/connected/finance';
import { decisionPage, decisionView, restoredDecisionView, financialPeriodScope } from '@/lib/connected/decision-view';

type WidgetId = 'raystoMarginChange' | 'raystoPriceScenario' | 'raystoPaymentEvidence' | 'raystoIngredientEvidence';
type Definition<T extends WidgetId> = AgWidgetDefinition<T, { type: T; dataMapping: { dish?: AgWidgetFieldReference[] }; format?: AgWidgetDataFormat<unknown> & {decisionConfig?:string} }>;
interface Registry extends Omit<AgDefaultRegistry, 'widgets'> {
  widgets: readonly [...AgDefaultRegistry['widgets'], Definition<'raystoMarginChange'>,
    Definition<'raystoPriceScenario'>, Definition<'raystoPaymentEvidence'>, Definition<'raystoIngredientEvidence'>];
}
interface ContextValue {
  comparison?: PriceComparison;
  products: CostProduct[]; scenario?: PricingScenario; summary?: FinancialSummary;
  payouts: Json[]; openProduct: (id: number) => void;
  openReceipt: (id:number)=>void;
}
const Context = createContext<ContextValue | null>(null);
function FinanceWidget({ widgetType, widgetApi, dataMapping }: { widgetType: string; widgetApi: AgWidgetApi; dataMapping: { dish?: AgWidgetField[] } }) {
  const value = useContext(Context);
  if (!value) return null;
  const code = value.products[0]?.currency ?? value.summary?.currency ?? 'USD';
  const fmt = (n: number | null | undefined) => knownMoney(n, v => currency(v, code));
  if(widgetType==='raystoIngredientEvidence') {
    const p=value.comparison?.evidence;
    const lines=p?.lines??[];
    return <div className="ops-finance-panel">
      <h3>Ingredient evidence</h3>
      {p?<><p>{value.comparison?.productName} · reviewed recipe revision {String(p.recipeVersion)}. {value.comparison?.sample?'Sample evidence.':''}</p>
        <p>Showing {Math.min(8,lines.length)} of {lines.length} ingredient lines.</p>
        {lines.slice(0,8).map((line,i)=>{const source=line.source;return <div key={i}>
          <p>{String(line.name??line.stockItemId)} · {typeof line.quantityMicros==='number'?line.quantityMicros/1000000:'Unknown'} {String(line.unit??'')} per portion<br/>
            Confirmed cost {fmt(line.unitCostMinor as number|null)} per {String(line.purchaseUnit??'unconfirmed unit')} · included cost {fmt(line.costMinor as number|null)}<br/>
            Receipt date {String(source?.at??'unknown')} · usable yield {typeof line.yieldBps==='number'?`${line.yieldBps/100}%`:'unknown'}.</p>
          {typeof source?.id==='number'&&<button className="ops-btn secondary" onClick={()=>value.openReceipt(source.id as number)}>Open receipt #{source.id}</button>}
        </div>;})}
        <p>Packaging {fmt(p.packagingMinor as number|null)}. Review inputs above to inspect every conversion and excluded cost.</p>
      </>:<p>Select a saved comparison to inspect its original ingredient evidence.</p>}
    </div>;
  }
  if (widgetType === 'raystoMarginChange') return <div className="ops-finance-panel">
    <h3>Margin change</h3><p>Current recipe compared with previous confirmed costs for the latest receipt. Contribution before fees and shared overhead.</p>
    <p>Showing {Math.min(8,value.products.length)} of {value.products.length} dishes in this view.</p>
    {value.products.slice(0, 8).map(p => <p key={p.productId}><button type="button" className="ops-btn secondary" onClick={() => {
      const field = dataMapping.dish?.[0];
      if (field) widgetApi.toggleCrossFilter({ type: 'value', group: 0, field, value: p.name, reset: true });
      value.openProduct(p.productId);
    }}>
      {p.name} · {fmt(p.contributionMinor)}{p.complete ? '' : ' · incomplete'}<br />
      {p.change?.complete ? `Recorded cost change: ${fmt(p.change.costIncreaseMinor)}` : 'Previous cost comparison is incomplete.'}</button></p>)}
    <button type="button" className="ops-btn secondary" onClick={() => widgetApi.resetCrossFilter()}>Clear dish filter</button>
  </div>;
  if (widgetType === 'raystoPriceScenario') return <div className="ops-finance-panel">
    <h3>Owner-target scenario</h3>{value.comparison ? <>
      <p>{value.comparison.productName} · comparison revision {value.comparison.revision}</p>
      {value.comparison.options.map(o=><p key={o.key}>{o.key}: {fmt(o.priceMinor)} · contribution {fmt(o.contributionMinor)} · break-even {o.breakEvenUnits??'unavailable'} units.</p>)}
      <p>Volume response is assumed. Use the reviewed decision controls to prepare a price action.</p>
    </> : value.scenario ? <>
      <p>{value.scenario.productName}: {fmt(value.scenario.current.priceMinor)} → {fmt(value.scenario.recommended?.priceMinor)}.</p>
      <p>{value.scenario.feasible ? `Break-even volume: ${value.scenario.breakEvenUnits ?? 'not applicable'} units.` : 'Target cannot be met inside the price cap.'}</p>
      <p>Volume response is assumed, not predicted. This widget cannot publish a price.</p>
    </> : <p>Calculate a scenario in Sales and margins to compare it here.</p>}
  </div>;
  return <div className="ops-finance-panel"><h3>PayPal payout evidence</h3>
    {value.payouts.length ? value.payouts.slice(0, 6).map((p, i) => <div key={String(p.id ?? i)}>
      <p>{String(p.kind ?? 'Payout')} · {String(p.state ?? 'Unknown state')} · {currency(Number(p.totalMinor), String(p.currency))}<br />
      {p.providerBatchId ? `PayPal batch ${String(p.providerBatchId)}` : 'No provider batch recorded. This is not proof of payment.'}
      </p>
      {Array.isArray(p.reviews) && (p.reviews as Json[]).map(r => <p key={Number(r.actionId)}>{String(r.title)} · {String(r.status)} · {r.approverUserId ? `reviewed ${String(r.decidedAt)}` : 'No manual approver recorded; inspect the existing automation policy.'}</p>)}
      {Array.isArray(p.items) && (p.items as Json[]).slice(0, 8).map(item => <p key={Number(item.id)}>Recipient item: {String(item.state)} · {currency(Number(item.amountMinor), String(p.currency))}<br />{item.providerItemId ? String(item.providerItemId) : 'No provider item reference yet.'}</p>)}
      {((p.items as Json[] | undefined)?.length ?? 0) > 8 || p.itemsTruncated === true ? <p>Item preview is partial. Open Money to inspect all recipient outcomes.</p> : null}
      <a href="?section=money">Open payment review and evidence</a>
    </div>) : <p>No payout evidence loaded. A submitted batch is not a completed recipient payment.</p>}
    <p>Read the bill and item-level outcome before treating a supplier as paid.</p>
  </div>;
}
function widget<T extends WidgetId>(id: T, label: string): Definition<T> {
  return {
    id, label, comp: FinanceWidget, defaultSize: { width: 420, height: 280 }, minSize: { width: 240, height: 200 },
    icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-width="2" d="M4 20V9h4v11m4 0V4h4v16m4 0V12"/></svg>',
    formatShape: ({ api }) => api.defineAiCommand(s => ({ input: s.object({decisionConfig:s.string().optional()}), execute: (value) => ({ success: true as const, value }) })).shape,
    dataMapping: { dish: { type: 'field', supportedRoles: ['category'], required: false } },
    form: p => p.createDefaults({ dataMappingItems: [{ key: 'dish', label: 'Dish for cross-filtering' }] }),
    ai: { description: 'Evidence-backed restaurant finance widget. Presentation only; never changes prices or sends money.' },
  };
}
const widgets = [widget('raystoMarginChange', 'Cost evidence'), widget('raystoPriceScenario', 'Price scenario'), widget('raystoPaymentEvidence', 'PayPal evidence'),widget('raystoIngredientEvidence','Ingredient evidence')] as const;
const widgetConfig = createWidgets<Registry>({ additionalTypes: [...widgets], menu: [{ label: 'Restaurant finances',
  widgetIds: ['raystoMarginChange', 'raystoPriceScenario', 'raystoPaymentEvidence','raystoIngredientEvidence'] }] });
const page = (id: string, type: WidgetId) => ({ id, widgets: {
  [`${id}-evidence`]: { type, dataMapping: { dish: [{ id: 'products.name' }] } },
  [`${id}-grid`]: { type: 'grid', format: { crossFilter: 'filter', title: { text: 'Recipe contribution records', enabled: true } },
    dataMapping: { cols: [{ id: 'products.name' }, { id: 'products.price' }, { id: 'products.cost' }, { id: 'products.contribution' }, { id: 'products.complete' }] } },
}, widgetLayout: {
  [`${id}-evidence`]: { xTrack: 0, yTrack: 0, xSpan: 9, ySpan: 28 },
  [`${id}-grid`]: { xTrack: 9, yTrack: 0, xSpan: 15, ySpan: 28 },
} });
const templates = [page('costing', 'raystoMarginChange'), page('scenario', 'raystoPriceScenario'), page('money', 'raystoPaymentEvidence')];
const initial = { pages: [templates[0]], selectedPageId: 'costing' } as unknown as AgReportState<Registry>;
const license = process.env.NEXT_PUBLIC_AG_STUDIO_LICENSE;

export function FinanceStudio({ api, tenant, products, scenario, productId, summary, onScenario, comparison, onComparison, comparisonDirty=false, openProduct = () => undefined, openReceipt=()=>undefined }: {
  openReceipt?:(id:number)=>void;
  comparisonDirty?:boolean;
  comparison?: PriceComparison; onComparison?: (v:PriceComparison)=>void;
  api: ConnectedApi; tenant: number; products: CostProduct[]; scenario?: PricingScenario;
  productId?: number; summary?: FinancialSummary; openProduct?: (id: number) => void; onScenario?: (s: PricingScenario) => void;
}) {
  const [payouts, setPayouts] = useState<Json[]>([]), [notice, setNotice] = useState('');
  const [panel, setPanel] = useState<'ai' | 'edit' | 'data' | 'filters' | undefined>();
  const [view,setView]=useState<DecisionView>();
  const [start, setStart] = useState<AgReportState<Registry>>();
  const studio = useRef<AgStudioApi | null>(null);
  // Streaming refreshes advance the default report's from/to bounds. Keep the
  // owner's logical scope stable so an analysis cannot invalidate itself.
  const token=JSON.stringify([tenant,productId,scenario?.id,comparison?.id,summary?.currency,financialPeriodScope(summary),null,comparison?.sample,comparisonDirty]);
  const scope = useRef({ api, tenant, productId, scenario, onScenario, comparison, onComparison,token });
  scope.current = { api, tenant, productId, scenario, onScenario, comparison, onComparison,token };
  const layoutVersion = useRef<number | undefined>(undefined);
  const saveTimer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const pendingView=useRef<{api:ConnectedApi;tokens:string[];signal?:AbortSignal}|undefined>(undefined);
  useEffect(() => {
    const controller = new AbortController();
    setStart(undefined); setPayouts([]); setNotice(''); setView(undefined); layoutVersion.current = undefined;
    void api.query<{ rows: Json[] }>('finance.payments', { restaurantId: tenant, limit: 10 }, controller.signal)
      .then(r => { if (!controller.signal.aborted) setPayouts(r.rows); }).catch(() => { if (!controller.signal.aborted) setPayouts([]); });
    const fallback = () => { if (!controller.signal.aborted) setStart(initial); };
    if (isJudgeVenue(tenant)) { fallback(); }
    else void api.query<{ state: AgReportState<Registry> | null; version?: number }>('studio.layout', {
      restaurantId: tenant, scope: `venue:${tenant}`, section: 'finance',
    }, controller.signal).then(r => { if (!controller.signal.aborted) { layoutVersion.current = r.version; setView(restoredDecisionView(r.state)); setStart(r.state ?? initial); } }).catch(fallback);
    return () => { controller.abort(); clearTimeout(saveTimer.current); studio.current = null; };
  }, [api, tenant]);
  const ai = useMemo(() => ({ harness: ({ api: studioApi }: { api: AgStudioApi }) => {
    function assertScope(){const p=pendingView.current;if(!p||p.signal?.aborted||p.api!==scope.current.api||!p.tokens.includes(scope.current.token))throw Error('The analytical selection changed. Run the request again.');}
    const configure=studioApi.defineAiTool({name:'raysto_configure_decision_view',
      description:'Configure validated comparison and evidence widgets, columns, filters and arrangement. Presentation only.',
      params:s=>s.object({arrangement:s.enum(['side-by-side','stacked'] as const),
        columns:s.array(s.enum(['name','price','cost','contribution','complete'] as const)),
        completeness:s.enum(['all','complete','incomplete'] as const),sort:s.enum(['name','contribution'] as const),
        widgets:s.array(s.enum(['comparison','evidence'] as const))}),
      execute:async(args:DecisionView,ctx)=>{
        assertScope();
        const selected=decisionView(args),state=studioApi.getState();setView(selected);
        studioApi.setState({...state,pages:[...state.pages.filter(p=>p.id!=='decision'),decisionPage(selected)],selectedPageId:'decision'} as never);
        return ctx.success('Configured the evidence and scenario view. No business action was approved.');
      }});
    const open = studioApi.defineAiTool({ name: 'raysto_open_finance_view',
      description: 'Create an evidence widget on the restaurant finance dashboard. Presentation only.',
      params: s => s.object({ view: s.enum(['costing', 'scenario', 'money'] as const) }),
      execute: async (args: { view: 'costing' | 'scenario' | 'money' }, ctx) => {
        assertScope();
        const state = studioApi.getState();
        const target = templates.find(p => p.id === args.view)!;
        const existing = state.pages.find(p => p.id === args.view);
        const next = existing ?? target;
        studioApi.setState({ ...state, pages: [...state.pages.filter(p => p.id !== args.view), next], selectedPageId: args.view } as never);
        return ctx.success('Opened the evidence view. No price or payment was changed.');
      },
    });
    return createAiHarness(studioApi, () => ({ primary: 'raysto-finance', agents: [clientToolRunner({
      id: 'raysto-finance', name: 'Raysto financial analyst', tools: () => [open,configure], maxTurns: 2,
      run: async function* (input, ctx): AsyncIterable<AgAiEvent> {
        if (input.messages.at(-1)?.role === 'tool') {
          yield { type: 'TEXT_MESSAGE_CHUNK', delta: 'The evidence view is ready. Dashboard changes do not approve any business action.' }; return;
        }
        const question = input.messages.findLast(m => m.role === 'user');
        if (!question || question.role !== 'user') return;
        const current = scope.current;
        if(JSON.parse(current.token)[8])throw Error('Save or cancel the comparison inputs before asking for a new analysis.');
        pendingView.current=undefined;
        const task = await current.api.command<{ taskId: number }>('studio.turn', current.tenant, {
          text: question.content, ...(current.productId ? { productId: current.productId } : {}),
          ...(current.scenario ? { scenarioId: current.scenario.id } : {}),
          ...(current.comparison ? {comparisonId:current.comparison.id}:{}),
        }, { key: `studio_${input.runId.replace(/[^A-Za-z0-9_-]/g, '').slice(0, 80)}` });
        if(current.api===scope.current.api&&current.token===scope.current.token)setNotice(`Analysis task ${task.taskId} submitted. Cancelling stops this view; inspect the task in Agents for its backend state.`);
        let result: FinanceAnalysis | undefined;
        for (let n = 0; n < 75; n++) {
          ctx.signal?.throwIfAborted();
          result = await current.api.query<FinanceAnalysis>('finance.analysis', { restaurantId: current.tenant, id: task.taskId }, ctx.signal);
          if (result.source === 'gemini' || result.source === 'deterministic-fallback') break;
          if (['failed', 'cancelled'].includes(result.status ?? '')) throw new Error(result.summary ?? 'Financial analysis could not complete.');
          await new Promise<void>((resolve, reject) => {
            const stop = () => { clearTimeout(timer); reject(ctx.signal?.reason); };
            const timer = setTimeout(() => { ctx.signal?.removeEventListener('abort', stop); resolve(); }, 1200);
            ctx.signal?.addEventListener('abort', stop, { once: true });
          });
        }
        ctx.signal?.throwIfAborted();
        if (current.api !== scope.current.api || current.token !== scope.current.token || !result?.view || !['gemini', 'deterministic-fallback'].includes(result.source ?? '')) throw new Error('Analysis is not complete or the selection changed. Reopen its task to recover the result.');
        const newToken=JSON.parse(current.token) as unknown[];newToken[2]=result.scenario?.id??current.scenario?.id;newToken[3]=result.comparison?.id??current.comparison?.id;newToken[7]=result.comparison?.sample??current.comparison?.sample;
        pendingView.current={api:current.api,tokens:[current.token,JSON.stringify(newToken)],signal:ctx.signal};
        if (result.scenario) scope.current.onScenario?.(result.scenario);
        if(result.comparison) scope.current.onComparison?.(result.comparison);
        yield { type: 'TEXT_MESSAGE_CHUNK', delta: result.summary ?? 'Read the linked evidence.' };
        const call = `view-${task.taskId}`;
        yield { type: 'TOOL_CALL_START', toolCallId: call, toolCallName: result.presentation?'raysto_configure_decision_view':'raysto_open_finance_view' };
        yield { type: 'TOOL_CALL_ARGS', toolCallId: call, delta: JSON.stringify(result.presentation?decisionView(result.presentation):{ view: result.view }) };
        yield { type: 'TOOL_CALL_END', toolCallId: call };
      },
    })] }));
  } }), []);
  if (!license || process.env.NEXT_PUBLIC_RAYSTO_STUDIO === 'off') return <section className="ops-finance-panel" role="note">
    <h3>Analytical workspace</h3><p>AG Studio is unavailable on this deployment. The same server-calculated evidence is available above.</p>
  </section>;
  if (!start) return <p role="status">Opening the financial workspace…</p>;
  return <section className="ops-finance-panel" aria-label="AG Studio restaurant finance">
    <h3>Your financial workspace · AG Studio</h3>
    <p>Explore the data, arrange evidence widgets, or ask the financial analyst. Layout undo does not reverse a payment or menu change.</p>
    <div className="ops-finance-select">
      {([['ai', 'Financial analyst'], ['edit', 'Edit layout'], ['data', 'Data fields'], ['filters', 'Studio filters']] as const).map(([id, label]) =>
        <button key={id} className="ops-btn secondary" aria-pressed={panel === id} onClick={() => setPanel(p => p === id ? undefined : id)}>{label}</button>)}
      <button className="ops-btn secondary" onClick={() => studio.current?.undo()}>Undo layout change</button>
      <button className="ops-btn secondary" onClick={() => studio.current?.redo()}>Redo layout change</button></div>
    <button className="ops-btn secondary" disabled={!comparison} onClick={()=>{
      const api=studio.current;if(!api)return;
      const selection:DecisionView={arrangement:'side-by-side',columns:['name','cost','contribution','complete'],completeness:'all',sort:'contribution',widgets:['comparison','evidence']};
      const state=api.getState();api.setState({...state,pages:[...state.pages.filter(p=>p.id!=='decision'),decisionPage(selection)],selectedPageId:'decision'} as never);
    }}>Compare beside ingredient evidence</button>
    <p className="ops-note">On a narrow screen, pan the analytical canvas horizontally. Cost evidence and reviewed decisions are also available above.</p>
    <Context.Provider value={{ products:products.filter(p=>!view||view.completeness==='all'||p.complete===(view.completeness==='complete')), scenario, comparison, summary, payouts, openProduct,openReceipt }}>
      <div className="ops-finance-canvas">
      <AgStudioProvider licenseKey={license}><AgStudio<Registry> key={tenant}
        widgets={widgetConfig} modules={[AgStudioAiModule]} theme={studioRaystoTheme} loadThemeGoogleFonts={false}
        mode="edit" panels={{ edit: { left: [], right: panel ? [panel] : [] }, view: { left: [], right: [] } }}
        initialState={start} ai={ai.harness} style={{ height: 720, width: '100%', minWidth: panel ? 1100 : 800 }}
        data={{ sources: [{ id: 'products', data: products.filter(p=>!view||view.completeness==='all'||p.complete===(view.completeness==='complete'))
          .toSorted((a,b)=>view?.sort==='contribution'?(b.contributionMinor??-Infinity)-(a.contributionMinor??-Infinity):a.name.localeCompare(b.name))
          .map(p => ({ name: p.name, price: p.priceMinor / 100,
          cost: p.replacementCostMinor == null ? null : p.replacementCostMinor / 100,
          contribution: p.contributionMinor == null ? null : p.contributionMinor / 100, complete: p.complete })) },
          {id:'decisionProducts',fields:[{id:'name',format:'textFormat'},{id:'price',format:'decimalFormat'},{id:'cost',format:'decimalFormat'},{id:'contribution',format:'decimalFormat'},{id:'complete',format:'booleanFormat'}],
            data:comparison&&(!view||view.completeness==='all'||comparison.evidence.complete===(view.completeness==='complete'))?[{name:comparison.productName,price:Number(comparison.evidence.priceMinor)/100,cost:typeof comparison.evidence.replacementCostMinor==='number'?comparison.evidence.replacementCostMinor/100:null,contribution:typeof comparison.evidence.contributionMinor==='number'?comparison.evidence.contributionMinor/100:null,complete:comparison.evidence.complete===true}]:[]},
          {id:'decisionScenarios',fields:[{id:'option',format:'textFormat'},{id:'price',format:'decimalFormat'},{id:'volumeResponse',format:'decimalFormat'},{id:'units',format:'integerFormat'},{id:'contribution',format:'decimalFormat'}],data:comparison?.options.flatMap(o=>o.sensitivity.map(s=>({option:o.key,price:o.priceMinor/100,
            volumeResponse:s.volumeChangeBps/100,units:s.units,contribution:s.contributionMinor==null?null:s.contributionMinor/100})))??[]}] }}
        onApiReady={e => { studio.current = e.api; }}
        onStateUpdated={e => {
          setView(restoredDecisionView(e.state));
          clearTimeout(saveTimer.current);
          if (isJudgeVenue(tenant)) { setNotice('Layout changes last for this review session.'); return; }
          saveTimer.current = setTimeout(() => {
            void api.command<{ version: number }>('studio.layout.save', tenant, {
              scope: `venue:${tenant}`, section: 'finance', state: e.state,
            }, { version: layoutVersion.current }).then(r => { layoutVersion.current = r.version; setNotice('Layout saved.'); })
              .catch(() => setNotice('Layout was not saved. Only the owner can save; your current layout remains open.'));
          }, 1500);
        }} />
      </AgStudioProvider>
      </div>
    </Context.Provider>
    {notice && <p role="status">{notice}</p>}
  </section>;
}
