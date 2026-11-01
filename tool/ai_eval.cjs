// Live evaluation of Raysto's AI agents against api.rays.to, with fixed
// cases and known answers. Writes docs/ai-evaluation-results.md.
//
//   node tool/ai_eval.cjs [menu|voice|cart|all]
//
// Menu and voice cases run on the QA owner's unpublished "Atelier Café · QA"
// restaurant; menu proposals are turned down after scoring, so no menu
// changes. Cart cases ask the takeaway assistant on the Sandbox restaurant
// and only read its proposal: nothing is ordered or paid. Inputs are rendered
// menu images and synthetic (Kokoro) voices, not camera photos or people.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto');
const root = path.resolve(__dirname, '..');
const qa = JSON.parse(fs.readFileSync(path.join(root, '.tooling/road-0110-private.json')));
const agentsState = JSON.parse(fs.readFileSync(path.join(root, '.tooling/agents-0130-qa-private.json')));
const cfg = JSON.parse(fs.readFileSync(path.join(root, 'backend/.secrets/firebase-ops-config.json'), 'utf8').replace(/^﻿/, ''));
const sdk = cfg.result.sdkConfig ?? JSON.parse(cfg.result.fileContents);
const fixtures = path.join(root, 'docs/qa/2026-11-01');
const output = path.join(root, 'docs/ai-evaluation-results.md');
const api = 'https://api.rays.to/api/v2/';
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const normal = (s) => String(s ?? '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]+/g, ' ').trim();

async function http(url, body, headers = {}, raw) {
  const r = await fetch(url, { method: body ? 'POST' : 'GET', headers: { 'Content-Type': raw ?? 'application/json', ...headers }, body: body == null ? undefined : raw ? body : JSON.stringify(body), signal: AbortSignal.timeout(90000) });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(`${url.replace(api, '')}: HTTP ${r.status} ${data.error?.code ?? ''} ${data.error?.message ?? ''}`);
  return data.data ?? data;
}
async function signIn(role, rid) {
  const u = qa.users.find((x) => x.role === role);
  const proof = await http('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' + sdk.apiKey, { email: u.email, password: u.password, returnSecureToken: true });
  const session = await http(api + 'auth/firebase', { firebaseIdToken: proof.idToken });
  const headers = { Authorization: 'Bearer ' + session.token, 'X-Raysto-Firebase-Token': proof.idToken };
  const key = () => crypto.randomBytes(18).toString('hex');
  return {
    headers,
    query: (name, params = {}) => http(api + 'queries/' + name + '?' + new URLSearchParams({ restaurantId: rid, ...params }), null, headers),
    command: (name, data, id, version) => http(api + 'commands/' + name, { requestKey: key(), restaurantId: rid, resourceId: id, expectedVersion: version, dataJson: JSON.stringify(data) }, headers),
  };
}

// ---- Menu agent: a photo of a paper menu becomes a priced, sectioned draft.
const menus = [
  { id: 'menu-1', file: 'menu-board.jpg', what: 'Printed café menu, 14 dishes, 1 without price, 2 priced options', unpriced: ['soup of the day'], options: [['croque monsieur', 100], ['cappuccino', 40]],
    dishes: [['butter croissant', 220], ['pain au chocolat', 240], ['granola bowl', 650], ['croque monsieur', 750], ['falafel wrap', 800], ['chicken club', 950], ['quiche lorraine', 1100], ['mushroom risotto', 1350], ['espresso', 180], ['cappuccino', 320], ['fresh orange juice', 400], ['lemon tart', 450], ['chocolate mousse', 400]] },
  { id: 'menu-2', file: 'menu-chalkboard.jpg', what: 'French bistro chalkboard, handwriting font, comma decimals, 9 dishes', unpriced: [], options: [['steak frites', 150]],
    dishes: [['soupe a l oignon', 650], ['salade de chevre chaud', 890], ['steak frites', 1600], ['moules marinieres', 1450], ['ratatouille', 1200], ['creme brulee', 550], ['tarte tatin', 600], ['cafe', 200], ['verre de vin rouge', 450]] },
  { id: 'menu-3', file: 'menu-street.jpg', what: 'Food-truck board, two columns, S/L sizes as price columns, 9 dishes', unpriced: [], options: [['carnitas', 500]],
    dishes: [['carnitas', [600, 1100]], ['chicken tinga', [600, 1100]], ['grilled veggie', [500, 900]], ['chips', 450], ['elote', 375], ['bean', 850], ['steak burrito', 1225], ['horchata', 300], ['mexican cola', 350]] },
];
async function menuCase(owner, c) {
  const bytes = fs.readFileSync(path.join(fixtures, c.file));
  const up = await owner.command('media.upload', { purpose: 'menuSource', mime: 'image/jpeg', byteLength: bytes.length, sha256: crypto.createHash('sha256').update(bytes).digest('hex') });
  const put = await fetch(`${api}media/${up.mediaId}/content`, { method: 'PUT', headers: { ...owner.headers, 'Content-Type': 'application/octet-stream' }, body: bytes });
  if (!put.ok) throw new Error('upload ' + put.status);
  for (let i = 0; i < 60; i++) {
    const files = await owner.query('media', { cursor: up.mediaId - 1, limit: 5 });
    const st = files.rows.find((f) => f.id === up.mediaId)?.status;
    if (st === 'approved') break;
    if (st === 'rejected' || i === 59) throw new Error('scan ' + st);
    await wait(2000);
  }
  const started = Date.now();
  const snap = await owner.command('menu.snap', { mediaIds: [up.mediaId] });
  let task;
  for (let i = 0; i < 90; i++) {
    task = await owner.query('agent.task', { id: snap.taskId });
    if (['done', 'failed'].includes(task.status)) break;
    await wait(2000);
  }
  const seconds = (Date.now() - started) / 1000;
  const action = (task.actions ?? []).find((a) => a.status === 'pending');
  if (!action) return { seconds, cost: task.chargedMicros, pass: false, detail: `no proposal (${task.status}: ${task.summary})` };
  const drafts = await owner.query('menu.drafts', { cursor: action.preview.draftId - 1, limit: 1 });
  const items = drafts.rows.find((d) => d.id === action.preview.draftId).items.filter((i) => i.status !== 'archived');
  await owner.command('agent.decide', { decision: 'reject' }, action.id, action.version);
  const find = (key) => items.find((i) => normal(i.name).includes(key));
  const found = c.dishes.filter(([k]) => find(k));
  const priced = c.dishes.filter(([k, p]) => { const i = find(k); return i && (Array.isArray(p) ? p.includes(i.priceMinor) : i.priceMinor === p); });
  const held = c.unpriced.filter((k) => find(k)?.available === false);
  const opts = c.options.filter(([k, p]) => (find(k)?.modifiers ?? []).some((g) => (g.options ?? []).some((o) => o.priceMinor === p)));
  const pass = found.length === c.dishes.length && priced.length >= Math.ceil(0.9 * c.dishes.length) && held.length === c.unpriced.length;
  return { seconds, cost: task.chargedMicros, pass, detail: `dishes ${found.length}/${c.dishes.length}, prices ${priced.length}/${c.dishes.length}, unpriced held ${held.length}/${c.unpriced.length}, options ${opts.length}/${c.options.length}, sections ${new Set(items.map((i) => i.category)).size}` };
}

// ---- Counter voice: a spoken order becomes ticket lines.
const voices = [
  { id: 'voice-1', file: 'counter-order.wav', what: '"Two croque monsieur, one with a fried egg. A cappuccino with oat milk. And a lemonade. The name is Sam."',
    check: (h, n) => n('croque') === 2 && n('croque', true) === 1 && n('cappuccino', true) === 1 && h.unmatched.some((u) => normal(u).includes('lemonade')) && h.customerLabel === 'Sam' },
  { id: 'voice-2', file: 'voice-2.wav', what: '"Three espressos and one lemon tart, please."', check: (h, n) => n('espresso') === 3 && n('lemon tart') === 1 && h.lines.length === 2 },
  { id: 'voice-3', file: 'voice-3.wav', what: '"A granola bowl and a fresh orange juice. The name is Lina." (British voice)', check: (h, n) => n('granola') === 1 && n('orange') === 1 && h.customerLabel === 'Lina' },
  { id: 'voice-4', file: 'voice-4.wav', what: '"Two cappuccinos, one of them with oat milk, and a chocolate mousse."', check: (h, n) => n('cappuccino') === 2 && n('cappuccino', true) === 1 && n('chocolate mousse') === 1 },
  { id: 'voice-5', file: 'voice-5.wav', what: '"One pizza margherita and a large coke, please." (nothing on the menu)', check: (h) => h.lines.length === 0 && h.unmatched.length >= 2 },
];
async function voiceCase(owner, menu, c) {
  const audio = fs.readFileSync(path.join(fixtures, c.file));
  const started = Date.now();
  const heard = await http(`${api}voice/counter?restaurantId=${agentsState.rid}`, audio, owner.headers, 'audio/wav');
  const seconds = (Date.now() - started) / 1000;
  const byId = Object.fromEntries(menu.menu.map((m) => [m.productId, m]));
  const n = (key, withOption) => heard.lines.filter((l) => normal(byId[l.productId]?.name).includes(key) && (!withOption || l.options.length > 0)).reduce((s, l) => s + l.quantity, 0);
  const lines = heard.lines.map((l) => `${l.quantity}× ${byId[l.productId]?.name}${l.options.length ? ' +option' : ''}`).join(', ') || 'no lines';
  return { seconds, pass: c.check(heard, n), detail: `${lines}${heard.customerLabel ? `; name ${heard.customerLabel}` : ''}${heard.unmatched.length ? `; not on menu: ${heard.unmatched.join(', ')}` : ''}` };
}

// ---- Takeaway assistant: one sentence becomes a priced pickup basket.
const carts = [
  { id: 'cart-1', text: 'Something vegetarian for one under $10, as soon as possible.', check: (q, v) => q && q.totalMinor <= 1000 && q.lines.every((l) => v(l.name)) },
  { id: 'cart-2', text: 'Lunch for two under $30: one with chicken, one vegetarian.', check: (q, v) => q && q.totalMinor <= 3000 && q.lines.some((l) => /chicken/i.test(l.name)) && q.lines.some((l) => v(l.name)) },
  { id: 'cart-3', text: 'I have a severe nut allergy. What can I order safely?', check: (q, v, a) => !q && /allerg|staff|confirm|ask/i.test(a) },
  { id: 'cart-4', text: 'One garden pasta for pickup at 13:15, please.', check: (q, v, a, local) => q && q.lines.some((l) => /garden pasta/i.test(l.name)) && local === '13:15' },
];
async function cartCase(diner, store, c) {
  const vegetarian = new Set(store.menu.filter((m) => (m.dietary ?? []).includes('vegetarian')).map((m) => m.name));
  const started = Date.now();
  const run0 = await diner.command('assistant.start', { text: c.text, locale: 'en', context: 'cart' });
  let run;
  for (let i = 0; i < 40; i++) {
    run = await diner.query('assistant.run', { id: run0.runId });
    if (!['queued', 'running'].includes(run.status)) break;
    await wait(1500);
  }
  const seconds = (Date.now() - started) / 1000;
  const q = run.proposal?.kind === 'basket' ? run.proposal.payload?.quote : null;
  const local = q?.slot ? new Date(q.slot).toLocaleTimeString('en-GB', { timeZone: store.settings?.timezone ?? 'UTC', hour: '2-digit', minute: '2-digit' }) : null;
  const pass = run.status !== 'failed' && Boolean(c.check(q, (name) => vegetarian.has(name), run.answer?.text ?? '', local));
  const basket = q ? `${q.lines.map((l) => `${l.quantity}× ${l.name}`).join(', ')}, $${(q.totalMinor / 100).toFixed(2)}${local ? `, pickup ${local}` : ''}` : `no basket: "${String(run.answer?.text ?? run.status).slice(0, 110).replace(/\s+/g, ' ')}"`;
  return { seconds, pass, detail: basket };
}

// The Gemini key's per-minute quota is small; cases run one at a time, spaced.
const pause = 20000;
const median = (xs) => { const s = [...xs].sort((a, b) => a - b); return s.length ? s[Math.floor((s.length - 1) / 2)] : 0; };
(async () => {
  const mode = process.argv[2] ?? 'all';
  const results = [];
  if (mode === 'menu' || mode === 'all') {
    const owner = await signIn('owner', agentsState.rid);
    for (const c of menus) { results.push({ agent: 'Menu agent', ...c, ...(await menuCase(owner, c).catch((e) => ({ pass: false, detail: e.message }))) }); await wait(pause); }
  }
  if (mode === 'voice' || mode === 'all') {
    const owner = await signIn('owner', agentsState.rid);
    const menu = await owner.query('counter.menu');
    for (const c of voices) { results.push({ agent: 'Counter voice', ...c, ...(await voiceCase(owner, menu, c).catch((e) => ({ pass: false, detail: e.message }))) }); await wait(pause); }
  }
  if (mode === 'cart' || mode === 'all') {
    const diner = await signIn('diner1', qa.rid);
    const store = await diner.query('storefront');
    for (const c of carts) { results.push({ agent: 'Takeaway assistant', ...c, what: `"${c.text}"`, ...(await cartCase(diner, store, c).catch((e) => ({ pass: false, detail: e.message }))) }); await wait(pause); }
  }
  for (const r of results) console.log(JSON.stringify({ id: r.id, pass: r.pass, seconds: r.seconds, detail: r.detail }));
  const agents = [...new Set(results.map((r) => r.agent))];
  const md = [
    '# AI evaluation results',
    '',
    `Run on ${new Date().toISOString().slice(0, 16).replace('T', ' ')} UTC against production (\`api.rays.to\`) with \`tool/ai_eval.cjs ${mode}\`. Model: Gemini 3.6 Flash (Developer API). Inputs are rendered menu images and synthetic voices (Kokoro TTS), not camera photos or people. Menu proposals were turned down after scoring and no order was placed.`,
    '',
    '| Agent | Cases | Passed | Median time |',
    '|---|---|---|---|',
    ...agents.map((a) => { const rs = results.filter((r) => r.agent === a); return `| ${a} | ${rs.length} | ${rs.filter((r) => r.pass).length} | ${median(rs.filter((r) => r.seconds).map((r) => r.seconds)).toFixed(1)} s |`; }),
    '',
    ...agents.flatMap((a) => [
      `## ${a}`,
      '',
      '| Case | Input | Result | Pass | Time |',
      '|---|---|---|---|---|',
      ...results.filter((r) => r.agent === a).map((r) => `| ${r.id} | ${r.what.replace(/\|/g, '/')} | ${String(r.detail).replace(/\|/g, '/')} | ${r.pass ? 'yes' : '**no**'} | ${r.seconds ? r.seconds.toFixed(1) + ' s' : '–'}${r.cost ? ` · $${(r.cost / 1e6).toFixed(3)}` : ''} |`),
      '',
    ]),
    'Pass rules. Menu: every dish found, at least 90% of prices exact (a sized dish may take either size), every dish printed without a price held back unavailable. Voice: the exact dishes, quantities, options and name; nothing invented. Cart: the basket respects the stated budget, diet and pickup time; with a stated allergy and no recorded allergens, no basket is offered.',
    '',
  ].join('\n');
  if (mode === 'all') fs.writeFileSync(output, md);
  else console.log(md);
})().catch((e) => { console.error(e.message); process.exitCode = 1; });
