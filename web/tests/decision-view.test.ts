import { strict as assert } from 'node:assert';
import { test } from 'node:test';
import { decisionPage, decisionView, restoredDecisionView } from '../src/lib/connected/decision-view';
const view={arrangement:'side-by-side',columns:['name','cost','contribution'],completeness:'incomplete',sort:'contribution',widgets:['comparison','evidence']};
test('decision configuration survives serialization, restore and layout undo',()=>{
  const page=decisionPage(view),state=JSON.parse(JSON.stringify({pages:[page]}));
  assert.deepEqual(restoredDecisionView(state),view);
  assert.equal(page.widgetLayout['decision-evidence'].xTrack,12);
  assert.equal(restoredDecisionView({pages:[]}),undefined);
  assert.equal(decisionPage({...view,arrangement:'stacked'}).widgetLayout['decision-evidence'].yTrack,24);
});
test('presentation accepts only declared fields and operations',()=>{
  for(const change of [{columns:['bankBalance']},{columns:['cost','cost']},{columns:[5]},{widgets:['payment.execute']},{expression:'eval()'},{sort:'rawSql'}]) {
    assert.throws(()=>decisionView({...view,...change}));
  }
  assert.equal(restoredDecisionView({pages:[{id:'decision',widgets:{x:{format:{decisionConfig:'{"columns":["private"]}'}}}}]}),undefined);
});
