/** Uses an existing Firebase CLI login. Never prints credentials or changes other projects. */
const fs = require('node:fs');
const path = require('node:path');
async function main() {
  const cliLib = process.argv[2];
  if (!cliLib) throw new Error('Provide the installed firebase-tools/lib directory.');
  const auth = require(path.join(cliLib, 'auth.js'));
  const account = auth.getGlobalDefaultAccount();
  if (!account?.tokens?.refresh_token) throw new Error('Firebase login required.');
  const token = await auth.getAccessToken(account.tokens.refresh_token, ['https://www.googleapis.com/auth/cloud-platform']);
  const endpoint = 'https://identitytoolkit.googleapis.com/admin/v2/projects/raysto-38505/config';
  const headers = {Authorization: `Bearer ${token.access_token}`, 'Content-Type': 'application/json'};
  const current = await fetch(endpoint, {headers, signal:AbortSignal.timeout(20000)});
  if (!current.ok) throw new Error(`Read Firebase auth config: HTTP ${current.status}`);
  const config = await current.json();
  const domains = [...new Set([...(config.authorizedDomains ?? []), 'ops.rays.to'])];
  if (!config.authorizedDomains?.includes('ops.rays.to')) {
    const update = await fetch(`${endpoint}?updateMask=authorizedDomains`, {
      method:'PATCH', headers, body:JSON.stringify({authorizedDomains:domains}), signal:AbortSignal.timeout(20000),
    });
    if (!update.ok) throw new Error(`Authorize console: HTTP ${update.status}`);
  }
  const root = path.resolve(__dirname, '../..');
  const downloaded = JSON.parse(fs.readFileSync(path.join(root,'backend/.secrets/firebase-ops-config.json'),'utf8').replace(/^\uFEFF/,''));
  const sdk = downloaded.result.sdkConfig ?? JSON.parse(downloaded.result.fileContents);
  if (sdk.projectId !== 'raysto-38505') throw new Error('Unexpected Firebase project.');
  const license = fs.readFileSync(path.join(root,'backend/.secrets/ag-studio-trial.txt'),'utf8').trim();
  fs.writeFileSync(path.join(root,'web/.env.local'),[
    `NEXT_PUBLIC_FIREBASE_API_KEY=${sdk.apiKey}`,`NEXT_PUBLIC_FIREBASE_APP_ID=${sdk.appId}`,
    `NEXT_PUBLIC_AG_STUDIO_LICENSE=${license}`, 'RAYSTO_OPS_ONLY=true',
    'RAYSTO_CONSOLE_ORIGIN=https://ops.rays.to','',
  ].join('\n'),{mode:0o600});
  console.log(JSON.stringify({project:sdk.projectId,webAppId:sdk.appId,authorizedDomain:'ops.rays.to',localBuildConfigurationWritten:true}));
}
main().catch(error=>{console.error(error.message);process.exitCode=1;});
