const fs=require('node:fs'),path=require('node:path');
const {session,request,base,root}=require('./decision_api.cjs');
async function main(){
 const s=await session('manager'),me=await s.query('me'),menu=await s.query('counter.menu');
 const report={at:new Date().toISOString(),sourceCommit:'f5fb637c4b2202ac52b9f70ef711015f8a5a00a1',
  managerAuthenticated:me.memberships.some(m=>m.restaurantId===s.restaurantId||m.id===s.restaurantId),
  existingMenuReadable:Array.isArray(menu.menu),currency:menu.currency,dishCount:menu.menu.length};
 try{await request(base+'queries/orders?restaurantId='+s.restaurantId,null,{Authorization:'Bearer invalid-probe'});report.invalidSessionRejected=false;}catch(e){report.invalidSessionRejected=[401,403].includes(e.status);}
 try{await s.query('finance.policy');report.financeInitiallyDisabled=false;}catch(e){report.financeInitiallyDisabled=e.code==='not_enabled';}
 if(!report.existingMenuReadable||!report.invalidSessionRejected||!report.financeInitiallyDisabled)throw Error('Compatibility check failed: '+JSON.stringify(report));
 fs.writeFileSync(path.join(root,'docs/impact-innovation/deployed-compatibility.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
