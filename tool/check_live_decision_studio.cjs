/** Actual deployed Studio/browser interaction; sample dish, no approvals. */
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..');const {chromium}=require(path.join(root,'web/node_modules/playwright'));
async function main(){
 const browser=await chromium.launch({channel:'msedge',headless:true});
 const result={startedAt:new Date().toISOString(),source:'Actual deployed console and backend, sample dish 72',errors:[]};
 let currentPage;
 try{
  const page=await browser.newPage({viewport:{width:1600,height:1100}});page.on('pageerror',e=>result.errors.push(e.message));
  currentPage=page;
  page.on('response',async response=>{if(response.url().includes('finance.analysis')&&response.ok())try{const raw=await response.json(),data=raw.data??raw;if(data.source)result.analysis={taskId:data.taskId,source:data.source,summary:data.summary,presentation:data.presentation};}catch{}});
  await page.goto('https://ops.rays.to/ops?judge=1&section=finance',{waitUntil:'domcontentloaded',timeout:60000});
  await page.getByRole('heading',{name:'Understand the cost. Review the decision.'}).waitFor({timeout:60000});
  await page.getByLabel('Inspect a dish').selectOption('72');
  const comparison=page.getByRole('region',{name:'Compare a pricing decision'});
  await comparison.getByLabel('Assumed baseline units').fill('100');
  await comparison.getByRole('button',{name:'Compare options',exact:true}).click();
  await comparison.getByRole('heading',{name:/Lowest qualifying price/}).waitFor({timeout:30000});
  const studio=page.getByRole('region',{name:'AG Studio restaurant finance'});await studio.scrollIntoViewIfNeeded();
  await studio.getByRole('button',{name:'Financial analyst',exact:true}).click();
  result.inputs=await studio.locator('textarea,input,[contenteditable="true"]').evaluateAll(es=>es.map(e=>({tag:e.tagName,placeholder:e.getAttribute('placeholder'),label:e.getAttribute('aria-label'),role:e.getAttribute('role')})));
  fs.writeFileSync(path.join(root,'docs/impact-innovation/live-studio-inspection.json'),JSON.stringify(result,null,2)+'\n');
  await studio.screenshot({path:path.join(root,'.tooling/live-studio-before.png')});
  await studio.getByRole('textbox',{name:'Message input'}).fill('Show this comparison beside its ingredient evidence, with cost before contribution.');
  await studio.getByRole('button',{name:/Send/}).click();
  await studio.getByRole('heading',{name:'Ingredient evidence',exact:true}).waitFor({timeout:100000});
  await studio.locator('.ag-row').filter({hasText:'recommended'}).first().waitFor({timeout:15000});
  assert.equal(result.analysis?.source,'gemini','Actual model result required');
  const opening=result.analysis.summary.split('\n')[0].replace(/\*\*/g,'');
  await studio.getByText(opening,{exact:false}).first().waitFor({timeout:15000});
  await studio.getByText('The evidence view is ready. Dashboard changes do not approve any business action.',{exact:true}).waitFor({timeout:15000});
  result.visibleExplanation=true;
  assert.deepEqual(result.errors,[],'No browser errors are allowed');
  await studio.screenshot({path:path.join(root,'.tooling/live-studio-after.png')});
  await studio.getByRole('button',{name:'Open receipt #10',exact:true}).click();
  await page.getByRole('heading',{name:'Confirmed receipt evidence',exact:true}).waitFor();
  await page.getByRole('button',{name:'Close evidence',exact:true}).click();
  await studio.getByRole('button',{name:'Undo layout change',exact:true}).click();
  await comparison.getByRole('heading',{name:/Lowest qualifying price/}).waitFor();
  result.status='passed';result.receiptDrill=true;result.layoutUndoPreservedComparison=true;result.sessionLocalJudgeLayout=true;
  result.backendSource=JSON.parse(fs.readFileSync(path.join(root,'docs/impact-innovation/backend-patch-deployment.json'),'utf8')).sourceCommit;
  result.consoleSource=JSON.parse(fs.readFileSync(path.join(root,'docs/impact-innovation/console-deployment.json'),'utf8')).sourceCommit;
  fs.writeFileSync(path.join(root,'docs/impact-innovation/live-studio-acceptance.json'),JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result));
 }catch(e){
  result.status='failed';result.failure=e.message.slice(0,300);
  if(currentPage){result.visibleWorkspace=await currentPage.getByRole('region',{name:'AG Studio restaurant finance'}).innerText().catch(()=>null);await currentPage.screenshot({path:path.join(root,'.tooling/live-studio-failure.png')}).catch(()=>{});}
  fs.writeFileSync(path.join(root,'docs/impact-innovation/live-studio-failure.json'),JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result));throw e;
 }finally{await browser.close();}
}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
