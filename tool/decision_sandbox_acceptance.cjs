/** Resumable, explicitly sample USD/Sandbox acceptance. Never sends supplier email.
 * Stages: prepare (document + reviewed receipt), price, collect, payout, evidence.
 * Persistent request keys and checked amounts prevent retries from duplicating money.
 */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const {session,request,root,base}=require('./decision_api.cjs');
const {chromium}=require(path.join(root,'web/node_modules/playwright'));
const runLabel=process.env.RAYSTO_ACCEPTANCE_RUN??'';assert(/^[a-z0-9-]*$/.test(runLabel));
const suffix=runLabel?'-'+runLabel:'';
const privatePath=path.join(root,'.tooling/decision-sandbox'+suffix+'-private.json');
const output=path.join(root,'docs/impact-innovation/integrated-sandbox'+suffix+'.json');
const state=fs.existsSync(privatePath)?JSON.parse(fs.readFileSync(privatePath,'utf8')):{runId:crypto.randomUUID(),steps:{}};
const report=fs.existsSync(output)?JSON.parse(fs.readFileSync(output,'utf8')):{provenance:'Authored USD sample records with actual PayPal Sandbox outcomes; not a restaurant pilot',events:[]};
const save=()=>{fs.writeFileSync(privatePath,JSON.stringify(state,null,2));fs.writeFileSync(output,JSON.stringify(report,null,2)+'\n');};
const record=(event,data)=>{report.events.push({at:new Date().toISOString(),event,...data});save();console.log(event);};
const pause=ms=>new Promise(r=>setTimeout(r,ms));
async function main(){
 const deployed=JSON.parse(fs.readFileSync(path.join(root,'docs/impact-innovation/backend-patch-deployment.json'),'utf8'));
 assert.equal(deployed.status,'deployed');report.sourceCommit=deployed.sourceCommit;report.backendVersion=deployed.version;report.runId=state.runId;
 const s=await session('owner');assert.equal(s.restaurantId,5);
 const venue=await s.query('restaurant.manage');assert.equal(venue.currency,'USD');assert.equal(venue.settings.taxBps,0);
 async function step(label,name,data={},options={},raw=false){
  const entry=state.steps[label]??={key:crypto.randomUUID(),name,data,options,raw};save();
  if(!entry.result){entry.result=raw?await request(base+'commands/'+entry.name,{requestKey:entry.key,restaurantId:s.restaurantId,...entry.data},s.headers):await s.command(entry.name,entry.data,{...entry.options,key:entry.key});save();}
  return entry.result;
 }
 async function task(id){for(let i=0;i<90;i++){const t=await s.query('agent.task',{id});if(['done','failed','cancelled'].includes(t.status))return t;await pause(1000);}throw Error('Task polling timed out; retry reads only.');}
 async function approve(label,a){assert.equal(a.status,'pending');const r=await step(label,'agent.decide',{decision:'approve'},{id:a.id,version:a.version});assert.equal(r.state,'executed',JSON.stringify(r));return r;}
 async function freshIdentity(){await s.command('identity.stepUp',{firebaseIdToken:s.headers['X-Raysto-Firebase-Token']});}
 const stage=process.argv[2];
 if(stage==='prepare'){
  const sup=(await s.query('suppliers',{limit:100})).rows.find(x=>x.id===4);assert(sup?.payoutEmail);assert(!sup.email);
  const menu=await s.query('menu.manage');
  const product=await step('dish','menu.save',{name:'Connected decision bowl - Sample',category:'Sample investigation',description:'Authored Sandbox acceptance dish, not observed business performance.',priceMinor:900,available:true,modifiers:[]},{version:menu.menuVersion});state.productId=product.id;
  const stock=await step('ingredient','stock.save',{name:'Connected bowl ingredients - Sample',unit:'kg',quantity:0,costMinor:0,lowAt:0,supplierId:sup.id});state.stockId=stock.stockId;
  const po=await step('baseline-order','supplier.order.save',{supplierId:sup.id,lines:[{stockItemId:stock.stockId,qty:1,unitCostMinor:1000}],note:'sample:connected-decision baseline; no supplier email.'});
  const sent=await step('baseline-send','supplier.order.send',{}, {id:po.orderId,version:po.version});assert.equal(sent.emailed,false);
  await step('baseline-receipt','supplier.order.receive',{lines:[{stockItemId:stock.stockId,qty:1,unitCostMinor:1000}]},{id:sent.orderId,version:sent.version});
  await step('recipe','costing.recipe.save',{productId:product.id,lines:[{stockItemId:stock.stockId,quantity:'350',unit:'g',packSize:'1',yieldBps:10000}],packagingMinor:0,packagingConfirmed:true},{version:0});
  const changed=await step('changed-order','supplier.order.save',{supplierId:sup.id,lines:[{stockItemId:stock.stockId,qty:1,unitCostMinor:1100}],note:'sample:connected-decision new supplier cost; no supplier email.'});state.supplierOrderId=changed.orderId;
  const changedSent=await step('changed-send','supplier.order.send',{}, {id:changed.orderId,version:changed.version});assert.equal(changedSent.emailed,false);
  const doc=path.join(root,'.tooling/decision'+suffix+'-supplier-note.png');
  if(!fs.existsSync(doc)){
   const browser=await chromium.launch({channel:'msedge',headless:true});
   try{const page=await browser.newPage({viewport:{width:1000,height:900},deviceScaleFactor:1});
    const escape=x=>String(x).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    await page.setContent(`<html><body style="padding:55px;font:22px Arial;color:#172b24;background:#fff"><p style="color:#705218">SAMPLE DOCUMENT - AUTHORED SANDBOX EXERCISE</p><h1>Supplier delivery and invoice</h1><p>${escape(sup.name)}</p><p>Reference: SAMPLE-DECISION-${changed.orderId}<br>Purchase order: PO-${changed.orderId}<br>Date: 6 November 2026</p><table style="width:100%;border-collapse:collapse" border="1" cellpadding="16"><tr><th>Item</th><th>Qty</th><th>Unit</th><th>Unit price</th><th>Total</th></tr><tr><td>Connected bowl ingredients - Sample</td><td>1</td><td>kg</td><td>USD 11.00</td><td>USD 11.00</td></tr></table><h2>Total due: USD 11.00</h2><p>Tax: USD 0.00<br>Due in 7 days</p><p>Illustrative purchasing evidence. This is not a real supplier invoice.</p></body></html>`);
    await page.screenshot({path:doc});
   }finally{await browser.close();}
  }
  const bytes=fs.readFileSync(doc);const media=await step('upload','media.upload',{purpose:'deliveryNote',mime:'image/png',byteLength:bytes.length,sha256:crypto.createHash('sha256').update(bytes).digest('hex')});state.mediaId=media.mediaId;
  if(!state.uploaded){const r=await fetch(base+'media/'+media.mediaId+'/content',{method:'PUT',headers:{...s.headers,'Content-Type':'application/octet-stream'},body:bytes});assert(r.ok,'Private document upload failed');state.uploaded=true;save();}
  let scanned;for(let i=0;i<45;i++){scanned=(await s.query('media',{cursor:media.mediaId-1,limit:5})).rows.find(x=>x.id===media.mediaId);if(['approved','rejected'].includes(scanned?.status))break;await pause(2000);}assert.equal(scanned?.status,'approved');
  const started=await step('read-document','supply.receive',{mediaId:media.mediaId,supplierOrderId:changed.orderId});const t=await task(started.taskId);assert.equal(t.status,'done',t.summary);
  const receipt=t.actions.find(a=>a.command==='stock.receive'),bill=t.actions.find(a=>a.command==='bill.match');assert(receipt&&bill);
  assert.equal(receipt.evidence.deliveredTotalMinor,1100);assert.equal(receipt.evidence.billTotalMinor,1100);assert.equal(receipt.evidence.currency,'USD');
  // Explicit inspection of the extraction precedes the two independent approvals.
  record('document-reviewed',{taskId:t.id,mediaId:media.mediaId,orderId:changed.orderId,totalMinor:1100,currency:'USD',summary:t.summary});
  if(!state.steps['receipt-approve']?.result)await approve('receipt-approve',receipt);
  if(!state.steps['bill-approve']?.result)await approve('bill-approve',bill);
  const order=await s.query('supplier.order',{id:changed.orderId});state.billId=order.billId??order.bill?.id;assert(state.billId);
  const cost=await s.query('costing.product',{id:product.id});assert.equal(cost.replacementCostMinor,385);assert.equal(cost.change.previousCostMinor,350);assert.equal(cost.change.costIncreaseMinor,35);
  record('confirmed-cost',{productId:product.id,stockId:stock.stockId,billId:state.billId,costMinor:385,previousCostMinor:350,receiptIds:cost.lines.map(x=>x.source.id),supplierEmailsSent:0});
 }
 else if(stage==='price'){
  assert(state.productId&&state.billId);
  // Freeze an old checkout before publication, then prove that its amount stays put.
  const q=await step('old-quote','quote.create',{fulfillment:'pickup',onBehalf:true,customerLabel:'Sample acceptance',linesJson:JSON.stringify([{productId:state.productId,quantity:1,options:[]}]),tipMinor:0},{},true);
  const o=await step('old-order','order.submit',{quoteId:q.id},{},true);
  const a=await step('old-allocation','payment.allocate',{orderId:o.orderId,method:'paypal'},{},true);
  const checkout=await step('old-checkout','payment.checkout',{}, {id:a.checkoutId});assert.equal(checkout.amountMinor,900);state.oldCheckoutId=checkout.checkoutId;
  const comparison=state.comparisonId?await s.query('pricing.comparison',{id:state.comparisonId}):await s.command('pricing.comparison.create',{productId:state.productId,baselineUnits:100,volumeChangeBps:-1000});assert.equal(comparison.recommended.priceMinor,970);state.comparisonId=comparison.id;
  const proposed=await step('price-proposal','pricing.propose',{comparisonId:comparison.id,option:'recommended'});assert.equal(proposed.preview.toMinor,970);assert.equal(proposed.preview.fromMinor,900);
  await freshIdentity();const approved=await step('price-approval','agent.decide',{decision:'approve'},{id:proposed.actionId,version:proposed.version});assert.equal(approved.state,'executed');
  let duplicate;try{duplicate=await s.command('agent.decide',{decision:'approve'},{id:proposed.actionId,version:proposed.version});}catch(e){assert(['version_conflict','invalid_transition'].includes(e.code));duplicate={state:'rejected',code:e.code};}
  const replay=await s.command('agent.decide',{decision:'approve'},{id:proposed.actionId,version:proposed.version,key:state.steps['price-approval'].key});assert.equal(replay.state,'executed');
  const frozen=await s.command('payment.checkout',{}, {id:checkout.checkoutId});assert.equal(frozen.amountMinor,900);
  state.decisionId=(await s.query('pricing.decisions')).rows.find(x=>x.actionId===proposed.actionId)?.id;assert(state.decisionId);
  record('price-published',{comparisonId:comparison.id,actionId:proposed.actionId,decisionId:state.decisionId,fromMinor:900,toMinor:970,oldCheckoutAmountMinor:frozen.amountMinor,duplicateState:duplicate.state,duplicateCode:duplicate.code,replayedRequestState:replay.state});
 }
 else if(stage==='collect'){
  assert(state.decisionId);
  const q=await step('new-quote','quote.create',{fulfillment:'pickup',onBehalf:true,customerLabel:'Sample acceptance',linesJson:JSON.stringify([{productId:state.productId,quantity:1,options:[]}]),tipMinor:0},{},true);
  const o=await step('new-order','order.submit',{quoteId:q.id},{},true);state.orderId=o.orderId;
  const a=await step('new-allocation','payment.allocate',{orderId:o.orderId,method:'paypal'},{},true);
  const checkout=await step('new-checkout','payment.checkout',{}, {id:a.checkoutId});assert.equal(checkout.amountMinor,970);assert.equal(checkout.currency,'USD');state.checkoutId=checkout.checkoutId;save();
  const status=await s.query('checkout',{id:checkout.checkoutId});
  if(status.state!=='completed'){
   const url=new URL(checkout.approvalUrl);assert.equal(url.hostname,'www.sandbox.paypal.com');
   const credentials=fs.readFileSync(path.join(root,'backend/.secrets/paypal-sandbox-buyers.txt'),'utf8');
   const email=credentials.match(/Email:\s*(\S+)/i)?.[1],password=credentials.match(/Password:\s*(\S+)/i)?.[1];assert(email&&password);
   const browser=await chromium.launch({channel:'msedge',headless:true});
   try{const page=await browser.newPage({viewport:{width:1100,height:900}});await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:60000});
    await page.locator('input#email, input[name="login_email"]').first().fill(email,{timeout:60000});
    if(await page.locator('#btnNext').isVisible())await page.locator('#btnNext').click();
    await page.locator('input#password, input[name="login_password"]').first().fill(password,{timeout:45000});
    await page.locator('#btnLogin, button[type="submit"]:has-text("Log In")').first().click();
    await page.locator('#payment-submit-btn, [data-testid="submit-button-initial"], button:has-text("Pay Now"), button:has-text("Complete Purchase"), button:has-text("Continue to Review Order")').first().click({timeout:90000});
    await page.waitForURL(/api\.rays\.to\/payments\/return/,{timeout:60000});
    await page.screenshot({path:path.join(root,'.tooling/decision'+suffix+'-paypal-return.png')});
   }finally{await browser.close();}
  }
  const captured=await s.command('payment.capture',{}, {id:checkout.checkoutId});assert.equal(captured.state,'completed');
  const duplicate=await s.command('payment.capture',{}, {id:checkout.checkoutId});assert.equal(duplicate.state,'completed');
  record('collection-completed',{orderId:o.orderId,checkoutId:checkout.checkoutId,amountMinor:970,currency:'USD',state:captured.state,duplicateCaptureState:duplicate.state});
 }
 else if(stage==='fulfill'){
  assert(state.orderId&&state.checkoutId);
  const captured=await s.query('checkout',{id:state.checkoutId});assert.equal(captured.state,'completed');
  for(const next of ['accepted','preparing','ready','collected','completed']){
   const order=await s.query('order',{id:state.orderId});
   const sequence=['submitted','accepted','preparing','ready','collected','completed'];
   if(sequence.indexOf(order.status)>=sequence.indexOf(next))continue;
   if(next==='ready'){
    const kitchen=(await s.query('kitchen',{limit:100})).rows.find(x=>x.id===state.orderId);assert(kitchen);
    for(const ticket of kitchen.tickets)if(ticket.completedQuantity<ticket.quantity)await step('kitchen-'+ticket.lineKey,'kitchen.progress',{lineKey:ticket.lineKey,completedQuantity:ticket.quantity},{id:state.orderId,version:ticket.version});
   }
   await step('fulfill-'+next,'order.transition',{status:next},{id:state.orderId,version:order.version});
  }
  const outcome=await s.query('pricing.decision.outcome',{id:state.decisionId});
  record('sample-order-fulfilled',{orderId:state.orderId,provenance:'Simulated restaurant fulfillment of the authored sample order; collection is actual PayPal Sandbox.',observationStatus:outcome.observationStatus,orders:outcome.orders});
 }
 else if(stage==='payout'){
  const bill=(await s.query('bills')).rows.find(x=>x.id===state.billId);assert(bill);assert.equal(bill.amountMinor,1100);assert.equal(bill.currency,'USD');assert.equal(bill.payVia,'paypal');
  await freshIdentity();const paid=await step('supplier-payment','bill.pay',{}, {id:bill.id,version:bill.version});
  const duplicate=await s.command('bill.pay',{}, {id:bill.id});assert.equal(duplicate.batchId,paid.batchId);
  let current;for(let i=0;i<45;i++){current=(await s.query('bills')).rows.find(x=>x.id===bill.id);if(['paid','failed'].includes(current.state))break;await pause(2000);}
  record('supplier-payment',{billId:bill.id,batchId:paid.batchId,amountMinor:1100,currency:'USD',state:current.state,providerBatchId:current.providerBatchId,payoutState:current.payoutState,duplicateBatchId:duplicate.batchId});
 }
 else if(stage==='stale'){
  assert(state.comparisonId&&state.productId);
  const before=await s.query('costing.product',{id:state.productId});
  let rejected;
  try{await s.command('pricing.propose',{comparisonId:state.comparisonId,option:'recommended'});}catch(e){rejected=e.code;}
  assert(rejected&&/expired|stale/.test(rejected),'A stale comparison must not prepare another publication.');
  const after=await s.query('costing.product',{id:state.productId});assert.equal(after.fingerprint,before.fingerprint);
  record('stale-comparison-refused',{comparisonId:state.comparisonId,code:rejected,priceUnchanged:after.priceMinor===before.priceMinor});
 }
 else if(stage==='cleanup'){
  assert(state.oldCheckoutId);
  const intent=await s.query('checkout',{id:state.oldCheckoutId});
  assert(['created','reserved','cancelled'].includes(intent.state),'A captured/uncertain checkout must remain for reconciliation.');
  const cancelled=await step('cancel-old-checkout','payment.cancel',{}, {id:state.oldCheckoutId});assert.equal(cancelled.state,'cancelled');
  const old=await s.query('order',{id:state.steps['old-order'].result.orderId});
  const order=await step('cancel-old-order','order.cancel',{reason:'Sample frozen-price acceptance complete; unapproved checkout cancelled.'},{id:old.id,version:old.version});assert.equal(order.status,'cancelled');
  record('unused-old-checkout-cancelled',{checkoutId:state.oldCheckoutId,orderId:old.id,historyPreserved:true});
 }
 else if(stage==='evidence'){
  report.outcome=await s.query('pricing.decision.outcome',{id:state.decisionId});
  report.finance=await s.query('finance.summary');
  report.acceptance={connectedEvidence:Boolean(report.outcome.supplierPayments?.length),fullAccrualAgreement:false,reason:'Existing sample venue remains on legacy recorded-transactions basis; no reviewed opening balances were invented.',physicalAndroidReview:'deferred',ownerPilotCount:0};save();console.log('Outcome and finance evidence saved.');
 }
 else throw Error('Choose prepare, price, collect, payout or evidence.');
 save();
}
main().catch(e=>{report.lastFailure={at:new Date().toISOString(),stage:process.argv[2],message:e.code??e.message.slice(0,180)};save();console.error(report.lastFailure.message);process.exitCode=1;});
