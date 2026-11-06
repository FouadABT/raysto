/** Read-only product review plus a saved sample calculation; no publication/payment. */
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {root}=require('./decision_api.cjs');const {expect}=require(path.join(root,'web/node_modules/@playwright/test'));const {chromium}=require(path.join(root,'web/node_modules/playwright'));
(async()=>{const browser=await chromium.launch({channel:'msedge',headless:true});try{
const page=await browser.newPage({viewport:{width:1440,height:1000}});const folder=path.join(root,'docs/design-experience/screenshots');fs.mkdirSync(folder,{recursive:true});
await page.goto('https://ops.rays.to/ops?judge=1&section=finance&tab=compare&product=72',{waitUntil:'domcontentloaded',timeout:60000});await page.getByLabel('Assumed baseline units').fill('100',{timeout:60000});await page.getByRole('button',{name:'Compare options',exact:true}).click();await page.getByRole('heading',{name:'Lowest qualifying price',exact:true}).waitFor({timeout:30000});await expect(page.getByRole('button',{name:'Recalculate as a new revision',exact:true})).toBeEnabled();await page.evaluate(()=>document.fonts.ready);await page.evaluate(()=>scrollTo(0,0));
await page.screenshot({path:path.join(folder,'deployed-comparison-desktop.png'),fullPage:true});
await page.setViewportSize({width:390,height:844});await page.evaluate(()=>scrollTo(0,0));assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false);await page.screenshot({path:path.join(folder,'deployed-comparison-phone.png'),fullPage:true});
console.log(JSON.stringify({status:'captured',url:page.url(),viewportOverflow:false,provenance:'Actual public UI; authored USD sample calculation; no publication or payment.'}));
}finally{await browser.close()}})().catch(e=>{console.error(e.message);process.exitCode=1});
