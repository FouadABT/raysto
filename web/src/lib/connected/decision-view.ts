import type { DecisionView } from './finance';
/** Default reports roll forward on every read. Those observation timestamps
 * are not a new owner selection. An explicit period, when selected, is scope. */
export function financialPeriodScope(summary?: {basis:string;timezone?:string;from:string;to:string}, selected?:{from:string;to:string}) {
  return JSON.stringify([summary?.basis,summary?.timezone,selected??'default-rolling-period']);
}
const fields=['name','price','cost','contribution','complete'];
export function decisionView(value:unknown):DecisionView {
  if(!value||typeof value!=='object')throw Error('Invalid decision view');
  const v=value as DecisionView;
  if(Object.keys(v).some(k=>!['arrangement','columns','completeness','sort','widgets'].includes(k))||
    !['side-by-side','stacked'].includes(v.arrangement)||!['all','complete','incomplete'].includes(v.completeness)||
    !['name','contribution'].includes(v.sort)||!Array.isArray(v.columns)||v.columns.length<1||v.columns.length>5||
    new Set(v.columns).size!==v.columns.length||v.columns.some(c=>!fields.includes(c))||
    !Array.isArray(v.widgets)||v.widgets.length<1||v.widgets.length>2||new Set(v.widgets).size!==v.widgets.length||
    v.widgets.some(w=>!['comparison','evidence'].includes(w)))throw Error('Unknown analytical field or operation');
  return v;
}
export function decisionPage(input:unknown) {
  const v=decisionView(input), widgets:Record<string,unknown>={}, layout:Record<string,{xTrack:number;yTrack:number;xSpan:number;ySpan:number}>={};
  for(const [i,w] of v.widgets.entries()) {
    widgets[`decision-${w}`]={type:w==='comparison'?'raystoPriceScenario':'raystoIngredientEvidence',format:{decisionConfig:JSON.stringify(v)},
      dataMapping:{dish:[{id:'decisionProducts.name'}]}};
    layout[`decision-${w}`]={xTrack:v.arrangement==='stacked'?0:i*12,yTrack:v.arrangement==='stacked'?i*24:0,
      xSpan:v.arrangement==='stacked'?24:12,ySpan:24};
  }
  const y=v.arrangement==='stacked'?v.widgets.length*24:24;
  widgets['decision-products']={type:'grid',format:{crossFilter:'filter',title:{text:'Selected dish evidence',enabled:true}},
    dataMapping:{cols:v.columns.map(c=>({id:`decisionProducts.${c}`}))}};
  layout['decision-products']={xTrack:0,yTrack:y,xSpan:24,ySpan:24};
  widgets['decision-scenarios']={type:'grid',format:{title:{text:'Scenario assumptions and contribution',enabled:true}},
    dataMapping:{cols:['option','price','volumeResponse','units','contribution'].map(c=>({id:`decisionScenarios.${c}`}))}};
  layout['decision-scenarios']={xTrack:0,yTrack:y+24,xSpan:24,ySpan:24};
  return {id:'decision',widgets,widgetLayout:layout};
}

/** The typed custom-widget format travels with layout save/restore and undo. */
export function restoredDecisionView(state:unknown):DecisionView|undefined {
  try {
    const pages=(state as {pages?:{id:string;widgets?:Record<string,{format?:{decisionConfig?:string}}> }[]})?.pages;
    const config=Object.values(pages?.find(p=>p.id==='decision')?.widgets??{}).find(w=>w?.format?.decisionConfig)?.format?.decisionConfig;
    return config?decisionView(JSON.parse(config)):undefined;
  }catch{return undefined;}
}
