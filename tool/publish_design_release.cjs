/** Publish scanned candidate artifacts to the existing public Raysto repository. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process');
const root=path.resolve(__dirname,'..'),repo='FouadABT/raysto',tag='raysto-0.17-design-dev6';
const git=spawnSync('git',['credential','fill'],{cwd:root,input:'protocol=https\nhost=github.com\n\n',encoding:'utf8',windowsHide:true});assert.equal(git.status,0,'Existing Git credential unavailable.');
const credential=Object.fromEntries(git.stdout.split(/\r?\n/).filter(l=>l.includes('=')).map(l=>[l.slice(0,l.indexOf('=')),l.slice(l.indexOf('=')+1)]));assert(credential.password);
const headers={Authorization:'Bearer '+credential.password,Accept:'application/vnd.github+json','X-GitHub-Api-Version':'2022-11-28','User-Agent':'Raysto-candidate-release'};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function api(route,body){const r=await fetch('https://api.github.com/repos/'+repo+route,{headers:{...headers,'Content-Type':'application/json'},method:body?'POST':'GET',body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(60000)});if(r.status===404)return null;assert(r.ok,'GitHub API HTTP '+r.status);return r.json();}
(async()=>{const repository=await api('');assert(repository&&!repository.private&&repository.full_name===repo);
const manifest=JSON.parse(fs.readFileSync(path.join(root,'docs/release-0.17-manifest.json'),'utf8'));assert.equal(manifest.console.sourceCommit,'e59d7ed1f93cfee7cfc105ae57fb9e58669319a0');
for(const c of ['backend','console','android']){assert.equal(sha(path.join(root,manifest[c].artifact)),manifest[c].sha256);if(c!=='android')assert.equal(manifest[c].configIncluded,false);}
let release=await api('/releases/tags/'+tag);
if(!release)release=await api('/releases',{tag_name:tag,name:'Raysto 0.17 — Design development candidate',prerelease:true,draft:false,body:
'Deployed backend/console 0.17.0-dev.6. Development candidate with open independent-review, assistive-technology, physical-device and licence gates; no score is guaranteed.\n\n'+
'Exact application commits, checksums, actual-model and PayPal Sandbox results: docs/release-0.17-manifest.json and docs/design-experience/acceptance.md at this tag.\n\n'+
'The backend archive is a binary delta for the documented dev.5 runtime libraries/migrations, not a standalone installation. The console includes its tested Linux Node runtime. Runtime secrets are excluded. The ARM64 APK uses the existing development key; physical review is deferred. Source build instructions remain in the repository.\n\n'+
'Presentation production and restaurant-owner impact claims are separate workstreams.'});
assert(release&&release.tag_name===tag&&release.prerelease&&!release.draft);
const files=['backend','console','android'].map(c=>path.join(root,manifest[c].artifact)).concat([path.join(root,'docs/release-0.17-manifest.json'),path.join(root,'docs/design-experience/candidate-evidence.json')]);
const checksums=path.join(root,'dist/SHA256SUMS-design-dev6.txt');fs.writeFileSync(checksums,files.map(p=>sha(p)+'  '+path.basename(p)).join('\n')+'\n');files.push(checksums);
const assets=new Map(release.assets.map(a=>[a.name,a])),published=[];
for(const p of files){const digest=sha(p),name=path.basename(p);let item=assets.get(name);
if(item)assert(item.size===fs.statSync(p).size&&item.digest==='sha256:'+digest,'Existing release asset differs; never overwrite.');
else{const url=release.upload_url.split('{')[0]+'?name='+encodeURIComponent(name);assert(url.startsWith('https://uploads.github.com/repos/'+repo+'/releases/'));const r=await fetch(url,{method:'POST',headers:{...headers,'Content-Type':'application/octet-stream'},body:fs.readFileSync(p),signal:AbortSignal.timeout(300000)});assert(r.ok,'GitHub asset upload HTTP '+r.status);item=await r.json();assert(item.size===fs.statSync(p).size&&item.digest==='sha256:'+digest);}
published.push({name,sha256:digest,bytes:fs.statSync(p).size,url:item.browser_download_url});}
const report={checkedAtUtc:new Date().toISOString(),status:'published-prerelease',url:release.html_url,tag,assets:published};
fs.writeFileSync(path.join(root,'docs/design-experience/artifact-publication.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({status:report.status,url:report.url,assetCount:published.length}));
})().catch(e=>{console.error(e.cause?.code??e.message);process.exitCode=1});
