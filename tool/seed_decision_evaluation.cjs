/** Authored USD exercise only. No email, price approval, bill or payment is sent. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {session,root,base}=require('./decision_api.cjs');
const candidateSource=require('node:child_process').execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim();
async function main(){
 const s=await session('owner'),file=path.join(root,'.tooling/decision-fixture-private.json');
 const state=fs.existsSync(file)?JSON.parse(fs.readFileSync(file,'utf8')):{steps:{}};
 const save=()=>fs.writeFileSync(file,JSON.stringify(state,null,2));
 async function step(id,name,data,options={}){
  const v=state.steps[id]??={key:crypto.randomUUID(),name,data,options};save();
  if(!v.result){v.result=await s.command(v.name,v.data,{...v.options,key:v.key});save();}
  return v.result;
 }
 const venue=await s.query('restaurant.manage');
 if(venue.currency!=='USD'||venue.settings.taxBps!==0||venue.settings.taxConfigured!==true)throw Error('The authored fixture requires the existing zero-tax USD sample venue.');
 const suppliers=await s.query('suppliers',{limit:100});
 const prior=suppliers.rows.find(x=>x.payoutEmail);
 if(!prior)throw Error('A configured sample supplier is required; no recipient will be invented.');
 const supplier=await step('supplier','supplier.save',{name:'Decision exercise · Sample supplier',payoutEmail:prior.payoutEmail,email:null,leadDays:0});
 const menu=await s.query('menu.manage');
 const product=await step('dish','menu.save',{name:'House lunch bowl · Decision sample',category:'Sample investigation',description:'Authored USD exercise; not a real café result.',priceMinor:900,available:false,modifiers:[]},{version:menu.menuVersion});
 await step('start','costing.investigation.checkpoint',{productId:product.id});
 const stock=await step('ingredient','stock.save',{name:'Bowl ingredients · Decision sample',unit:'kg',quantity:0,costMinor:0,lowAt:0,supplierId:supplier.supplierId});
 for(const [phase,cost] of [['baseline',1000],['increase',1100]]){
  const order=await step(phase+'-order','supplier.order.save',{supplierId:supplier.supplierId,lines:[{stockItemId:stock.stockId,qty:1,unitCostMinor:cost}],note:'sample:decision-exercise-A '+phase+'; authored evidence, no supplier message.'});
  const sent=await step(phase+'-review','supplier.order.send',{}, {id:order.orderId,version:order.version});
  if(sent.emailed!==false)throw Error('Unexpected supplier messaging state.');
  await step(phase+'-receipt','supplier.order.receive',{lines:[{stockItemId:stock.stockId,qty:1,unitCostMinor:cost}]},{id:sent.orderId,version:sent.version});
 }
 await step('recipe','costing.recipe.save',{productId:product.id,lines:[{stockItemId:stock.stockId,quantity:'350',unit:'g',packSize:'1',yieldBps:10000}],packagingMinor:0,packagingConfirmed:true},{version:0});
 const policy=await s.query('pricing.policy');
 if(policy.confirmed){if(policy.targetBps!==6000||policy.maxIncreaseBps!==1000||policy.incrementMinor!==10||policy.feeBps!==0||policy.feeFixedMinor!==0)throw Error('Existing owner policy differs; preserve it and review the fixture.');}
 else await step('policy','pricing.policy.save',{targetBps:6000,maxIncreaseBps:1000,incrementMinor:10,feeBps:0,feeFixedMinor:0,excludedProducts:[]},{version:policy.version??0});
 await step('finish','costing.investigation.checkpoint',{productId:product.id});
 const cost=await s.query('costing.product',{id:product.id});
 if(!cost.complete||cost.replacementCostMinor!==385||cost.contributionMinor!==515)throw Error('Authored exercise and server cost do not agree.');
 const comparison=await s.command('pricing.comparison.create',{productId:product.id,baselineUnits:100,volumeChangeBps:-1000});
 if(comparison.options.find(x=>x.key==='recommended')?.priceMinor!==970)throw Error('Reference price mismatch.');
 const capped=await s.command('pricing.comparison.revise',{parentId:comparison.id,maxIncreaseBps:500});
 const latestMenu=await s.query('menu.manage');
 const incomplete=await step('incomplete-dish','menu.save',{name:'Seasonal bowl · Incomplete decision sample',category:'Sample investigation',description:'Authored missing-evidence exercise; recipe deliberately unconfirmed.',priceMinor:900,available:false,modifiers:[]},{version:latestMenu.menuVersion});
 fs.writeFileSync(path.join(root,'.tooling/decision-eval-private.json'),JSON.stringify({baseUrl:base,restaurantId:s.restaurantId,productId:product.id,comparisonId:comparison.id,cappedComparisonId:capped.id,incompleteProductId:incomplete.id,headers:s.headers,candidateSource,model:'gemini-3.6-flash',sampleConfirmed:true},null,2));
 const report={at:new Date().toISOString(),sourceCommit:'f5fb637c4b2202ac52b9f70ef711015f8a5a00a1',provenance:'Authored USD exercise A; not observed business results',restaurantId:s.restaurantId,productId:product.id,comparisonId:comparison.id,supplierId:supplier.supplierId,stockItemId:stock.stockId,confirmedReceiptIds:cost.lines.map(l=>l.source.id),replacementCostMinor:385,currentContributionMinor:515,recommendedPriceMinor:970,baselineUnits:100,volumeBasis:'explicit sample assumption',supplierEmailsSent:0,pricePublished:false,moneyActions:0};
 report.incompleteProductId=incomplete.id;report.cappedComparisonId=capped.id;
 report.sourceCommit=candidateSource;
 fs.writeFileSync(path.join(root,'docs/impact-innovation/deployed-sample-fixture.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
