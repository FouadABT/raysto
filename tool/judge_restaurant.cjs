// The judges' café on production (api.rays.to): its accounts, venue, sample
// menu photo and the console's judge login. Logins and ids live in the
// git-ignored backend/.secrets/judge-accounts.json; this script prints no
// password unless a mode says so.
//
//   node tool/judge_restaurant.cjs accounts  create the owner (private), manager and diner (published), verified
//   node tool/judge_restaurant.cjs venue     the owner creates and configures the café and makes the manager
//   node tool/judge_restaurant.cjs fresh     the owner starts the café fresh (server needs RAYSTO_JUDGE_RESTAURANT_ID)
//   node tool/judge_restaurant.cjs photo     upload the sample menu photo the menu agent reads
//   node tool/judge_restaurant.cjs delivery  upload the sample delivery note the supplies agent reads
//   node tool/judge_restaurant.cjs receipt   upload the sample receipt the expenses agent reads
//   node tool/judge_restaurant.cjs console   write the judge login into web/.env.local for the console build
//   node tool/judge_restaurant.cjs check     sign in as the manager and read what the demos need
//   node tool/judge_restaurant.cjs repair    put the published passwords back if someone changed them
//   node tool/judge_restaurant.cjs logins    print the published logins (manager and diner) for the README
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');

const root = path.resolve(__dirname, '..');
const api = 'https://api.rays.to/api/v2/';
const file = path.join(root, 'backend/.secrets/judge-accounts.json');
const state = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : { users: {}, keys: {} };
const save = () => fs.writeFileSync(file, JSON.stringify(state, null, 1), { mode: 0o600 });
const config = JSON.parse(fs.readFileSync(path.join(root, 'backend/.secrets/firebase-ops-config.json'), 'utf8').replace(/^\uFEFF/, ''));
const sdk = config.result.sdkConfig ?? JSON.parse(config.result.fileContents);
const assert = (value, message) => { if (!value) throw new Error(message); };
const report = (check, data = {}) => console.log(JSON.stringify({ at: new Date().toISOString(), check, ...data }));

async function http(url, body, headers = {}, method) {
  const r = await fetch(url, {
    method: method ?? (body ? 'POST' : 'GET'),
    headers: { 'Content-Type': 'application/json', ...headers },
    body: body ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(60000),
  });
  const raw = await r.text();
  let data = {};
  try { data = JSON.parse(raw); } catch {}
  if (!r.ok) throw Object.assign(new Error(`${url.replace(api, '').split('?')[0]}: HTTP ${r.status} ${data.error?.code ?? data.error?.message ?? ''}`), { code: data.error?.code ?? data.error?.message });
  return data.data ?? data;
}

async function adminHeaders() {
  const auth = require('C:/Users/fabat/AppData/Roaming/npm/node_modules/firebase-tools/lib/auth.js');
  const account = auth.getGlobalDefaultAccount();
  assert(account?.tokens?.refresh_token, 'Firebase CLI login required.');
  const token = await auth.getAccessToken(account.tokens.refresh_token, ['https://www.googleapis.com/auth/cloud-platform']);
  return { Authorization: 'Bearer ' + token.access_token };
}

// Readable passphrases for the published logins; they guard Sandbox only.
const words = ['basil', 'brioche', 'cocoa', 'crumble', 'fennel', 'ginger', 'hazelnut', 'honey', 'latte', 'lemon', 'mango', 'maple', 'mocha', 'nutmeg', 'olive', 'paprika', 'pepper', 'quince', 'saffron', 'sesame', 'tahini', 'thyme', 'vanilla', 'walnut'];
const passphrase = () => [0, 1, 2].map(() => words[crypto.randomInt(words.length)]).join('-') + '-' + crypto.randomInt(10, 100);
const accounts = {
  owner: { email: 'judges-owner@rays.to', name: 'Judges café owner', published: false },
  manager: { email: 'judge@rays.to', name: 'Hackathon judge', published: true },
  diner: { email: 'diner@rays.to', name: 'Hackathon diner', published: true },
};

async function signIn(role) {
  const u = state.users[role];
  assert(u, `Run "accounts" first (${role} missing).`);
  const proof = await http('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' + sdk.apiKey, { email: u.email, password: u.password, returnSecureToken: true });
  const session = await http(api + 'auth/firebase', { firebaseIdToken: proof.idToken });
  const headers = { Authorization: 'Bearer ' + session.token, 'X-Raysto-Firebase-Token': proof.idToken };
  const key = (step) => { state.keys[role + ':' + step] ??= crypto.randomBytes(18).toString('hex'); save(); return state.keys[role + ':' + step]; };
  const rid = () => state.restaurantId;
  return {
    headers,
    query: (name, params = {}) => http(api + 'queries/' + name + '?' + new URLSearchParams({ ...(rid() ? { restaurantId: rid() } : {}), ...params }), null, headers),
    command: (step, name, data = {}, opts = {}) => http(api + 'commands/' + name, { requestKey: key(step), restaurantId: opts.restaurantId === null ? undefined : rid(), resourceId: opts.id, expectedVersion: opts.version, dataJson: JSON.stringify(data) }, headers),
  };
}

async function createAccounts() {
  const headers = await adminHeaders();
  for (const [role, a] of Object.entries(accounts)) {
    if (state.users[role]) { report('Account already created', { role, email: a.email }); continue; }
    const u = { email: a.email, password: a.published ? passphrase() : crypto.randomBytes(24).toString('base64url') + '!A7', uid: 'judges-' + role + '-' + crypto.randomBytes(4).toString('hex') };
    await http('https://identitytoolkit.googleapis.com/v1/projects/raysto-38505/accounts', { localId: u.uid, email: u.email, password: u.password, emailVerified: true, displayName: a.name }, headers);
    state.users[role] = u;
    save();
    report('Verified Firebase account created', { role, email: u.email, published: a.published });
  }
}

async function venue() {
  const owner = await signIn('owner');
  if (!state.restaurantId) {
    state.restaurantId = (await owner.command('create', 'restaurant.create', { name: "Atelier Café · Judges", currency: 'USD' }, { restaurantId: null })).id;
    save();
    report('Café created', { restaurantId: state.restaurantId });
  }
  if (!state.configured) {
    const manage = await owner.query('restaurant.manage');
    await owner.command('configure', 'restaurant.configure', {
      name: manage.name,
      currency: 'USD',
      settings: {
        ...manage.settings,
        address: 'PayPal Sandbox demo for hackathon judges · not a real café',
        contactEmail: accounts.manager.email,
        country: 'US',
        timezone: 'America/New_York',
        languages: ['en', 'fr', 'ar'],
        modes: ['pickup'],
        hours: Array.from({ length: 7 }, (_, i) => ({ day: i + 1, start: 0, end: 1440 })),
        taxConfigured: true,
        taxBps: 0,
        paymentTiming: 'before',
        autoAcceptPaid: true,
        guestOrdering: false,
      },
    }, { version: manage.version });
    state.configured = true;
    save();
    report('Café configured: pickup, open all day, New York time, USD');
  }
  if (!state.managerJoined) {
    const invite = await owner.command('invite-manager', 'team.invite', { email: accounts.manager.email, role: 'manager' });
    const manager = await signIn('manager');
    await manager.command('accept', 'team.accept', { token: invite.invitationCode });
    state.managerJoined = true;
    save();
    report('The judge account is the café\u2019s manager');
  }
}

async function fresh() {
  const owner = await signIn('owner');
  const started = Date.now();
  const result = await owner.command('fresh-' + Date.now(), 'judge.reset', {});
  report('Café started fresh', { ...result, ms: Date.now() - started });
}

// A sample photo the agents read: uploaded once, scanned, its id kept in
// judge-accounts.json (`mediaId` for the menu, `keys.<name>` for the rest).
async function upload(name, file, remember) {
  const owner = await signIn('owner');
  const bytes = fs.readFileSync(path.join(root, file));
  let id = remember();
  if (!id) {
    const sent = await owner.command(`${name}-photo`, 'media.upload', { purpose: 'menuSource', mime: 'image/jpeg', byteLength: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex') });
    const put = await fetch(`${api}media/${sent.mediaId}/content`, { method: 'PUT', headers: { ...owner.headers, 'Content-Type': 'application/octet-stream' }, body: bytes });
    assert(put.ok, 'Upload failed: ' + put.status);
    id = remember(sent.mediaId);
    save();
  }
  let status;
  for (let i = 0; i < 60; i++) {
    const files = await owner.query('media', { cursor: id - 1, limit: 5 });
    status = files.rows.find((f) => f.id === id)?.status;
    if (status === 'approved' || status === 'rejected') break;
    await new Promise((r) => setTimeout(r, 3000));
  }
  assert(status === 'approved', `The scanner did not approve the ${name} photo: ` + status);
  report(`Sample ${name} photo uploaded and scanned`, { mediaId: id, bytes: bytes.length, status });
}

const photo = () => upload('menu', 'web/public/judges/menu.jpg', (id) => (id ? (state.mediaId = id) : state.mediaId));
const keyed = (name, file) => () =>
  upload(name, file, (id) => (id ? ((state.keys ??= {})[name + 'MediaId'] = id) : state.keys?.[name + 'MediaId']));
// The supplies and expenses agents read these two.
const delivery = keyed('delivery', 'docs/qa/2026-11-03/delivery-note.jpg');
const receipt = keyed('receipt', 'docs/qa/2026-11-03/receipt.jpg');

function consoleEnv() {
  const env = path.join(root, 'web/.env.local');
  const keep = fs.readFileSync(env, 'utf8').split(/\r?\n/).filter((l) => l && !l.startsWith('NEXT_PUBLIC_RAYSTO_JUDGE_'));
  fs.writeFileSync(env, [...keep,
    `NEXT_PUBLIC_RAYSTO_JUDGE_EMAIL=${state.users.manager.email}`,
    `NEXT_PUBLIC_RAYSTO_JUDGE_PASSWORD=${state.users.manager.password}`,
    `NEXT_PUBLIC_RAYSTO_JUDGE_RESTAURANT_ID=${state.restaurantId}`,
    `NEXT_PUBLIC_RAYSTO_JUDGE_DINER_EMAIL=${state.users.diner.email}`,
    `NEXT_PUBLIC_RAYSTO_JUDGE_DINER_PASSWORD=${state.users.diner.password}`,
    ...(state.mediaId ? [`NEXT_PUBLIC_RAYSTO_JUDGE_MENU_MEDIA_ID=${state.mediaId}`] : []),
    ...(state.keys?.deliveryMediaId ? [`NEXT_PUBLIC_RAYSTO_JUDGE_DELIVERY_MEDIA_ID=${state.keys.deliveryMediaId}`] : []),
    ...(state.keys?.receiptMediaId ? [`NEXT_PUBLIC_RAYSTO_JUDGE_RECEIPT_MEDIA_ID=${state.keys.receiptMediaId}`] : []),
    ''].join('\n'), { mode: 0o600 });
  report('Console judge login written to web/.env.local', { restaurantId: state.restaurantId });
}

async function check() {
  const manager = await signIn('manager');
  const me = await manager.query('me');
  const menu = await manager.query('counter.menu');
  const media = await manager.query('media', { limit: 100 });
  report('Judge manager sees the café', {
    memberships: me.memberships.map((m) => `${m.name} · ${m.role}`),
    dishes: menu.menu.length,
    voice: menu.voice,
    currency: menu.currency,
    menuPhoto: media.rows.find((m) => m.purpose === 'menuSource' && m.status === 'approved')?.id ?? null,
    menu: menu.menu.map((d) => `${d.name} ${d.priceMinor}`),
  });
}

async function repair() {
  const headers = await adminHeaders();
  for (const [role, u] of Object.entries(state.users)) {
    try {
      await http('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' + sdk.apiKey, { email: u.email, password: u.password, returnSecureToken: true });
      report('Login works', { role });
    } catch {
      await http('https://identitytoolkit.googleapis.com/v1/projects/raysto-38505/accounts:update', { localId: u.uid, email: u.email, password: u.password, emailVerified: true, disableUser: false }, headers);
      report('Login restored', { role });
    }
  }
}

const modes = {
  accounts: createAccounts,
  venue,
  fresh,
  photo,
  delivery,
  receipt,
  console: consoleEnv,
  check,
  repair,
  orders: async () => {
    const manager = await signIn('manager');
    const page = await manager.query('orders', { limit: 20 });
    for (const o of page.rows ?? []) report('Order', { id: o.id, status: o.status, payment: o.paymentStatus, total: o.totalMinor, created: o.createdAt });
  },
  inbox: async () => {
    const manager = await signIn('manager');
    const activity = await manager.query('agent.activity', { limit: 8 });
    const rows = activity.rows ?? activity.tasks ?? activity;
    for (const t of (Array.isArray(rows) ? rows : []).slice(0, 8)) {
      const task = await manager.query('agent.task', { id: t.id });
      report('Task', { id: task.id, agent: task.agent, status: task.status, actions: (task.actions ?? []).map((a) => ({ id: a.id, command: a.command, status: a.status, error: a.errorCode, result: a.result })) });
    }
  },
  task: async () => {
    const manager = await signIn('manager');
    const task = await manager.query('agent.task', { id: Number(process.argv[3]) });
    report('Task', { id: task.id, agent: task.agent, status: task.status, summary: task.summary, trace: task.trace, actions: (task.actions ?? []).map((a) => ({ command: a.command, status: a.status, rationale: a.rationale, error: a.errorCode })) });
  },
  query: async () => {
    const manager = await signIn('manager');
    const data = await manager.query(process.argv[3], JSON.parse(process.argv[4] ?? '{}'));
    console.log(JSON.stringify(data).slice(0, 4000));
  },
  logins: () => {
    for (const role of ['manager', 'diner']) console.log(`${role}: ${state.users[role].email} / ${state.users[role].password}`);
    console.log(`restaurantId: ${state.restaurantId}`);
  },
};
const mode = modes[process.argv[2]];
if (!mode) console.error('Usage: accounts | venue | fresh | photo | delivery | receipt | console | check | orders | inbox | repair | logins');
else Promise.resolve(mode()).catch((e) => { console.error(e.message); process.exitCode = 1; });
