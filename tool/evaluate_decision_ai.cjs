/** Actual-model evaluator against an explicitly configured matching Raysto candidate.
 * node tool/evaluate_decision_ai.cjs .tooling/decision-eval-private.json
 * Private config: baseUrl, restaurantId, productId, headers, candidateSource,
 * comparisonId, sampleConfirmed:true. Headers are never written to the result.
 * No approval, publication, order, bill or payment command is sent.
 * Existing studio.turn budget limits remain authoritative; failures are retained.
 */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..');
async function main(){
  if(process.argv.length!==3)throw Error('Provide the private configuration path for a verified sample candidate.');
  const config=JSON.parse(fs.readFileSync(process.argv[2],'utf8'));
  const url=new URL(config.baseUrl);
  if(!['api.rays.to','127.0.0.1','localhost'].includes(url.hostname)||!url.pathname.endsWith('/api/v2/'))throw Error('Unsupported Raysto API URL.');
  if(url.hostname==='api.rays.to'&&url.protocol!=='https:')throw Error('HTTPS required.');
  if(config.sampleConfirmed!==true||!config.candidateSource||!config.headers?.Authorization)throw Error('Confirm sample data, exact candidate source and authorized session first.');
  const cases=JSON.parse(fs.readFileSync(path.join(root,'docs/impact-innovation/evaluation-cases.json'),'utf8')).cases.filter(c=>c.phrases);
  const results=[];
  const output=path.join(root,'docs/impact-innovation/actual-model-results.json');
  if(fs.existsSync(output))throw Error('An evaluation record already exists; preserve it and choose a new dated run before retrying.');
  async function request(route,body){
    const r=await fetch(new URL(route,url),{method:body?'POST':'GET',headers:{'Content-Type':'application/json',...config.headers},body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(65000)});
    const value=await r.json();if(!r.ok||value.error)throw Error(`HTTP ${r.status}: ${value.error?.code??'request_failed'}`);return value.data??value;
  }
  const params=new URLSearchParams({restaurantId:String(config.restaurantId),id:String(config.comparisonId)});
  const selected=await request('queries/pricing.comparison?'+params);
  if(!selected.valid||selected.productId!==config.productId)throw Error('Select a current supported comparison first.');
  const save=()=>fs.writeFileSync(output,JSON.stringify({candidateSource:config.candidateSource,model:config.model??'record from candidate manifest',provenance:'Live candidate requests on explicit sample records; only source=gemini counts as a provider result',results,successRate:null,reviewStatus:'Human source/amount/task review pending; source=gemini alone is not success'},null,2)+'\n');
  evaluation: for(const c of cases)for(const text of c.phrases){
    const start=Date.now(),r={id:c.id,text,startedAt:new Date().toISOString(),expected:c.expected,pass:null};
    try{
      const scope=c.id==='I06'?{productId:config.incompleteProductId}:{productId:config.productId,comparisonId:c.id==='I04'?config.cappedComparisonId:config.comparisonId};
      if(!scope.productId||(c.id==='I04'&&!scope.comparisonId))throw Error('Required case-specific sample evidence is missing.');
      r.scope=scope;
      const task=await request('commands/studio.turn',{requestKey:crypto.randomUUID(),restaurantId:config.restaurantId,dataJson:JSON.stringify({text,...scope})});
      r.taskId=task.taskId;
      for(let n=0;n<75;n++){
        const value=await request('queries/finance.analysis?'+new URLSearchParams({restaurantId:String(config.restaurantId),id:String(task.taskId)}));
        if(value.source||['failed','cancelled'].includes(value.status)){
          r.status=value.status;r.source=value.source;r.summary=value.summary;r.view=value.presentation??value.view;
          r.comparison=value.comparison;r.evidence=value.evidence;break;
        }
        await new Promise(resolve=>setTimeout(resolve,1000));
      }
      if(!r.source&&!r.status)r.error='poll_timeout';
    }catch(e){r.error=e.message;}
    r.latencyMs=Date.now()-start;results.push(r);save();
    console.log(`${r.id} ${r.source??r.error??r.status} ${r.latencyMs}ms; human scoring pending`);
    if(r.error?.includes('budget'))break evaluation;
  }
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
