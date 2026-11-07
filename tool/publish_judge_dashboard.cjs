/** Publish only scanned web-candidate artifacts to Raysto's existing public repository. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict'),{spawnSync}=require('node:child_process');
const root=path.resolve(__dirname,'..'),folder=path.join(root,'docs/judge-dashboard'),repo='FouadABT/raysto',tag='raysto-0.17-judge-dev8';
const git=spawnSync('git',['credential','fill'],{cwd:root,input:'protocol=https\nhost=github.com\n\n',encoding:'utf8',windowsHide:true});assert.equal(git.status,0,'Existing Git credential unavailable.');
const credential=Object.fromEntries(git.stdout.split(/\r?\n/).filter(l=>l.includes('=')).map(l=>[l.slice(0,l.indexOf('=')),l.slice(l.indexOf('=')+1)]));assert(credential.password);
const headers={Authorization:'Bearer '+credential.password,Accept:'application/vnd.github+json','X-GitHub-Api-Version':'2022-11-28','User-Agent':'Raysto-candidate-release'};
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
async function api(route,body){const r=await fetch('https://api.github.com/repos/'+repo+route,{headers:{...headers,'Content-Type':'application/json'},method:body?'POST':'GET',body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(60000)});if(r.status===404)return null;assert(r.ok,'GitHub API HTTP '+r.status);return r.json();}
(async()=>{const repository=await api('');assert(repository&&!repository.private&&repository.full_name===repo);
const manifest=JSON.parse(fs.readFileSync(path.join(folder,'release-manifest.json'),'utf8'));
assert.equal(manifest.console.version,'0.17.0-dev.8');assert.equal(manifest.console.sourceCommit,JSON.parse(fs.readFileSync(path.join(folder,'console-deployment.json'),'utf8')).sourceCommit);
const publication=JSON.parse(fs.readFileSync(path.join(folder,'source-publication.json'),'utf8'));
const ref=await api('/git/ref/tags/'+tag);assert(ref&&ref.object.type==='tag','The verified source tag must already be public.');
assert.equal((await api('/git/tags/'+ref.object.sha)).object.sha,publication.tagSourceCommit);
for(const c of ['backend','console','android'])assert.equal(sha(path.join(root,manifest[c].artifact)),manifest[c].sha256);
assert.equal(manifest.console.privateCredentialScan,'passed');
let release=await api('/releases/tags/'+tag);
if(!release)release=await api('/releases',{tag_name:tag,name:'Raysto 0.17 — Judge-first web candidate',prerelease:true,draft:false,body:
'The owner console now starts with one cost investigation, three headline figures and readable charts. Detailed evidence, pricing reviews and AG Studio remain available on request.\n\n'+
'Console 0.17.0-dev.8; unchanged backend 0.17.0-dev.6 and development-signed Android 0.17.0-dev.3+2203. Exact source, checksums, deployed checks and remaining gates: docs/judge-dashboard/release-manifest.json and docs/judge-dashboard/acceptance.md at this tag.\n\n'+
'This release contains the scanned Linux console and its evidence. Unchanged backend/APK artifacts remain available in the prior design-dev6 release, with hashes in the manifest. No credentials or runtime configuration are included. Restaurant-owner research and physical Android review remain open; no judging score is guaranteed.'});
assert(release&&release.tag_name===tag&&release.prerelease&&!release.draft);
const files=[path.join(root,manifest.console.artifact),...['release-manifest.json','validation.json','audit-after.json','deployed-journey.json','evidence-index.json','acceptance.md'].map(f=>path.join(folder,f))];
const owner=JSON.parse(fs.readFileSync(path.join(root,'backend/.secrets/judge-accounts.json'),'utf8')).users.owner;
const buyer=fs.readFileSync(path.join(root,'backend/.secrets/paypal-sandbox-buyers.txt'),'utf8');
const secrets=[owner.email,owner.password,...[...buyer.matchAll(/(?:Email|Password):\s*(\S+)/gi)].map(m=>m[1])].filter(Boolean).map(s=>Buffer.from(s));
for(const p of files.filter(p=>!p.endsWith('.tar.gz')))assert(!secrets.some(s=>fs.readFileSync(p).includes(s)),'Private credential in evidence; publication refused.');
const checksums=path.join(root,'dist/SHA256SUMS-judge-dev8.txt');fs.writeFileSync(checksums,files.map(p=>sha(p)+'  '+path.basename(p)).join('\n')+'\n');files.push(checksums);
const assets=new Map(release.assets.map(a=>[a.name,a])),published=[];
for(const p of files){const digest=sha(p),name=path.basename(p);let item=assets.get(name);
 if(item)assert(item.size===fs.statSync(p).size&&item.digest==='sha256:'+digest,'Existing release asset differs; never overwrite.');
 else{const url=release.upload_url.split('{')[0]+'?name='+encodeURIComponent(name);assert(url.startsWith('https://uploads.github.com/repos/'+repo+'/releases/'));const r=await fetch(url,{method:'POST',headers:{...headers,'Content-Type':'application/octet-stream'},body:fs.readFileSync(p),signal:AbortSignal.timeout(300000)});assert(r.ok,'GitHub asset upload HTTP '+r.status);item=await r.json();assert(item.size===fs.statSync(p).size&&item.digest==='sha256:'+digest);}
 published.push({name,sha256:digest,bytes:fs.statSync(p).size,url:item.browser_download_url});
}
const report={checkedAtUtc:new Date().toISOString(),status:'published-prerelease',url:release.html_url,tag,assets:published};
fs.writeFileSync(path.join(folder,'artifact-publication.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({status:report.status,url:report.url,assetCount:published.length}));
})().catch(e=>{console.error(e.cause?.code??e.message);process.exitCode=1});
