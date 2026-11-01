// Films a real counter sale for the demo video: the tablet emulator rings up
// three items and shows the PayPal QR, a Sandbox buyer approves on a phone-sized
// browser, and the paid ticket moves through the kitchen board.
//
//   node tool/record_counter_footage.cjs
//
// Needs the Raysto app signed in as the QA owner on the running emulator and
// the private QA files used by tool/live_session_qa.cjs. PayPal Sandbox only.
// Output (ignored by git): dist/video-footage/counter-tablet-<date>.mp4 and
// counter-buyer-phone-<date>.mp4, trimmed so no sign-in appears.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto');
const { execFileSync, spawn } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'dist/video-footage');
fs.mkdirSync(out, { recursive: true });
const day = new Date().toISOString().slice(0, 10);
const adb = path.join(process.env.LOCALAPPDATA, 'Android/Sdk/platform-tools/adb.exe');
const ffmpeg = path.join(root, 'video/node_modules/@remotion/compositor-win32-x64-msvc/ffmpeg.exe');
const qa = JSON.parse(fs.readFileSync(path.join(root, '.tooling/road-0110-private.json')));
const cfg = JSON.parse(fs.readFileSync(path.join(root, 'backend/.secrets/firebase-ops-config.json'), 'utf8').replace(/^﻿/, ''));
const sdk = cfg.result.sdkConfig ?? JSON.parse(cfg.result.fileContents);
const buyer = (() => {
  const text = fs.readFileSync(path.join(root, 'backend/.secrets/paypal-sandbox-buyers.txt'), 'utf8');
  return { email: [...text.matchAll(/Email:\s*(\S+)/g)][1][1], password: [...text.matchAll(/Password:\s*(\S+)/g)][1][1] };
})();
const api = 'https://api.rays.to/api/v2/';
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const sh = (...args) => execFileSync(adb, ['shell', ...args]).toString();

/// Where the first on-screen node whose text or description starts with
/// label is. Reading the screen toggles accessibility, so fixed controls are
/// located once before filming.
function locate(label) {
  sh('uiautomator', 'dump', '/sdcard/ui.xml');
  const xml = execFileSync(adb, ['exec-out', 'cat', '/sdcard/ui.xml']).toString();
  for (const m of xml.matchAll(/<node [^>]*>/g)) {
    const get = (k) => (m[0].match(new RegExp(' ' + k + '="([^"]*)"')) || [])[1] ?? '';
    const name = (get('text') || get('content-desc')).replace(/&#10;/g, '\n');
    if (!name.startsWith(label)) continue;
    const [x1, y1, x2, y2] = get('bounds').match(/\d+/g).map(Number);
    return [(x1 + x2) >> 1, (y1 + y2) >> 1];
  }
  throw new Error(`Nothing on screen starts with "${label}"`);
}

const press = ([x, y], after = 1200) => {
  sh('input', 'tap', String(x), String(y));
  return wait(after);
};
const tap = (label, { after = 1200 } = {}) => press(locate(label), after);

async function http(url, body, headers = {}) {
  const r = await fetch(url, { method: body ? 'POST' : 'GET', headers: { 'Content-Type': 'application/json', ...headers }, body: body ? JSON.stringify(body) : undefined });
  const d = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(`${url.replace(api, '')}: HTTP ${r.status} ${d.error?.code ?? ''}`);
  return d.data ?? d;
}

async function owner() {
  const u = qa.users.find((x) => x.role === 'owner');
  const p = await http('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=' + sdk.apiKey, { email: u.email, password: u.password, returnSecureToken: true });
  const s = await http(api + 'auth/firebase', { firebaseIdToken: p.idToken });
  const h = { Authorization: 'Bearer ' + s.token, 'X-Raysto-Firebase-Token': p.idToken };
  return (name, q = {}) => http(api + 'queries/' + name + '?' + new URLSearchParams({ restaurantId: qa.rid, ...q }), null, h);
}

/// The buyer's phone: approve on PayPal's Sandbox page, filmed after sign-in.
async function approve(url) {
  const { chromium, devices } = require(path.join(root, 'web/node_modules/playwright'));
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  const context = await browser.newContext({ ...devices['Pixel 7'], recordVideo: { dir: out, size: { width: 412, height: 839 } } });
  const opened = Date.now();
  const page = await context.newPage();
  let cut = 0;
  try {
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
    const email = page.locator('input#email, input[name="login_email"]').first();
    await email.waitFor({ timeout: 60000 });
    await email.fill(buyer.email);
    const next = page.locator('#btnNext');
    if (await next.isVisible().catch(() => false)) await next.click();
    const password = page.locator('input#password, input[name="login_password"]').first();
    await password.waitFor({ timeout: 45000 });
    await password.fill(buyer.password);
    await page.locator('#btnLogin, button[type="submit"]:has-text("Log In")').first().click();
    const pay = page.locator('#payment-submit-btn, [data-testid="submit-button-initial"], button:has-text("Pay Now"), button:has-text("Complete Purchase"), button:has-text("Continue to Review Order")').first();
    await pay.waitFor({ timeout: 90000 });
    cut = (Date.now() - opened) / 1000 + 0.5;
    await wait(2500);
    await pay.click();
    await page.waitForURL(/api\.rays\.to\/payments\/return/, { timeout: 120000 });
    await wait(2500);
  } finally {
    const video = page.video();
    await context.close();
    await browser.close();
    const raw = await video.path();
    if (cut) encode(raw, cut, path.join(out, `counter-buyer-phone-${day}.mp4`));
    fs.unlinkSync(raw);
  }
}

function encode(input, from, file) {
  execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-ss', from.toFixed(2), '-i', input, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', '-an', file]);
  console.log(file);
}

(async () => {
  const query = await owner();
  const newest = async () => { const r = (await query('checkouts', { staff: 'true', order: 'desc', limit: 1 })).rows?.[0]; return r ? r.checkoutId ?? r.id : 0; };
  const before = await newest();
  await tap('Counter\n', { after: 3000 });
  const at = Object.fromEntries(
    ['Add Garden pasta', 'Add Shared tomato starter', 'Add Lemon chicken', 'Kitchen\n', 'Orders\n'].map((l) => [l, locate(l)]),
  );
  // screenrecord stops by itself after 180 s; it is ended earlier below.
  const recorder = spawn(adb, ['shell', 'screenrecord', '--size', '1920x1200', '--bit-rate', '16000000', '/sdcard/counter.mp4']);
  await wait(2000);
  await press(at['Add Garden pasta']);
  await press(at['Add Shared tomato starter']);
  await press(at['Add Lemon chicken'], 1500);
  await tap('PayPal QR', { after: 6000 }); // it moves down as the sale grows
  let checkout;
  for (let i = 0; i < 20 && !checkout; i++) {
    const id = await newest();
    if (id > before) checkout = await query('checkout', { id });
    else await wait(1000);
  }
  if (!checkout?.approvalUrl) throw new Error('The counter did not create a PayPal checkout');
  console.log('checkout', checkout.checkoutId ?? checkout.id, 'amount', checkout.amountMinor);
  await approve(checkout.approvalUrl);
  await wait(9000); // the counter polls and shows the paid ticket
  await press(at['Kitchen\n'], 3500);
  await tap('Start cooking', { after: 3000 });
  await tap('Mark ready', { after: 4000 });
  await press(at['Orders\n'], 4000);
  sh('pkill', '-INT', 'screenrecord');
  await new Promise((r) => recorder.on('exit', r));
  await wait(1500);
  const raw = path.join(out, `counter-tablet-raw-${crypto.randomBytes(3).toString('hex')}.mp4`);
  execFileSync(adb, ['pull', '/sdcard/counter.mp4', raw]);
  encode(raw, 0, path.join(out, `counter-tablet-${day}.mp4`));
  fs.unlinkSync(raw);
})().catch((e) => { console.error(e.message); process.exitCode = 1; });
