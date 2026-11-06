/** Private judge sessions for bounded acceptance scripts. Never print credentials. */
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),base='https://api.rays.to/api/v2/';
async function request(url,body,headers={}){
 const r=await fetch(url,{method:body?'POST':'GET',headers:{'Content-Type':'application/json',...headers},body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(65000)});
 const raw=await r.json();if(!r.ok||raw.error)throw Object.assign(Error(`HTTP ${r.status} ${raw.error?.code??'request_failed'}`),{code:raw.error?.code,status:r.status});return raw.data??raw;
}
async function session(role='owner'){
 const state=JSON.parse(fs.readFileSync(path.join(root,'backend/.secrets/judge-accounts.json'),'utf8'));
 const config=JSON.parse(fs.readFileSync(path.join(root,'backend/.secrets/firebase-ops-config.json'),'utf8').replace(/^\uFEFF/,''));
 const sdk=config.result.sdkConfig??JSON.parse(config.result.fileContents),user=state.users[role];
 if(!user)throw Error('Requested private judge account is unavailable.');
 const proof=await request('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key='+sdk.apiKey,{email:user.email,password:user.password,returnSecureToken:true});
 const auth=await request(base+'auth/firebase',{firebaseIdToken:proof.idToken});
 const headers={Authorization:'Bearer '+auth.token,'X-Raysto-Firebase-Token':proof.idToken};
 const restaurantId=state.restaurantId;
 return {headers,restaurantId,query:(name,p={})=>request(base+'queries/'+name+'?'+new URLSearchParams({restaurantId,...p}),null,headers),
  command:(name,data={},options={})=>request(base+'commands/'+name,{requestKey:options.key??crypto.randomUUID(),restaurantId:options.restaurantId??restaurantId,resourceId:options.id,expectedVersion:options.version,dataJson:JSON.stringify(data)},headers)};
}
module.exports={session,request,base,root};
