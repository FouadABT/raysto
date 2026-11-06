/** Read-only recovery and trace attachment. Never starts another model turn. */
const fs=require('node:fs'),path=require('node:path');const {session,root}=require('./decision_api.cjs');
async function main(){
 const s=await session('owner'),file=path.join(root,'docs/impact-innovation/actual-model-results.json'),run=JSON.parse(fs.readFileSync(file,'utf8'));
 const records=[];
 for(const r of run.results){if(!r.taskId)continue;const task=await s.query('agent.task',{id:r.taskId});const item={taskId:r.taskId,status:task.status,summary:task.summary,chargedMicros:task.chargedMicros,trace:task.trace,actions:task.actions.map(a=>({id:a.id,command:a.command,status:a.status}))};
  if(r.error){const a=await s.query('finance.analysis',{id:r.taskId});item.recovered={source:a.source,summary:a.summary,presentation:a.presentation,evidence:a.evidence};}records.push(item);
 }
 const policy=await s.query('pricing.policy'),cost=await s.query('costing.product',{id:72});
 const report={checkedAt:new Date().toISOString(),sourceCommit:run.candidateSource,scope:'Read-only verification; original failed attempts remain in the evaluation denominator',priceUnchanged:cost.priceMinor===900,policyCapUnchanged:policy.maxIncreaseBps===1000,records};
 fs.writeFileSync(path.join(root,'docs/impact-innovation/actual-model-task-review.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({records:records.length,priceUnchanged:report.priceUnchanged,policyCapUnchanged:report.policyCapUnchanged}));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
