// Records 1920x1080 footage of the live owner console for the demo video.
// Signs in with the QA owner (reads only; no command is sent) and walks
// Overview -> Orders -> an order's PayPal panel -> Payments. Output is a
// trimmed H.264 .mp4 in dist/video-footage/ (ignored by git).
const fs = require('node:fs'), path = require('node:path');
const root = path.resolve(__dirname, '..');
const qa = JSON.parse(fs.readFileSync(path.join(root, '.tooling/road-0110-private.json')));
const owner = qa.users.find((u) => u.role === 'owner');
const out = path.join(root, 'dist/video-footage');
const pause = (page, ms) => page.waitForTimeout(ms);
(async () => {
  const { chromium } = require(path.join(root, 'web/node_modules/playwright'));
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  // The console keeps its sign-in per tab, so the sign-in is recorded too and
  // cut from the start of the footage afterwards.
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
    deviceScaleFactor: 1,
    recordVideo: { dir: out, size: { width: 1920, height: 1080 } },
  });
  const opened = Date.now();
  const page = await context.newPage();
  await page.goto('https://ops.rays.to/ops');
  await page.getByLabel('Email').fill(owner.email);
  await page.getByLabel('Password').fill(owner.password);
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  await page.locator('.ops-sections').waitFor({ timeout: 90000 });
  await page.locator('.ops-kpi').first().waitFor();
  await pause(page, 1500);
  const cut = (Date.now() - opened) / 1000;
  await pause(page, 4000);
  await page.locator('.ops-kpi', { hasText: 'PayPal collected' }).hover();
  await pause(page, 1500);
  await page.locator('.ops-sections button', { hasText: 'Orders' }).click();
  await page.locator('.ag-row[row-index]').first().waitFor();
  await pause(page, 2500);
  await page.locator('.ops-chips button', { hasText: 'Counter' }).click();
  await pause(page, 1800);
  await page.locator('.ops-chips button', { hasText: 'All' }).first().click();
  await pause(page, 1200);
  for (const i of [0, 2]) {
    await page.locator('.ag-row[row-index]').nth(i).click();
    await pause(page, 3500);
  }
  await page.locator('.ops-sections button', { hasText: 'Payments' }).click();
  await page.locator('.ag-row[row-index]').first().waitFor();
  await pause(page, 3500);
  await page.locator('.ops-chips button', { hasText: 'Refunds' }).click();
  await pause(page, 3000);
  await page.locator('.ops-chips button', { hasText: 'PayPal captures' }).click();
  await pause(page, 3000);
  const video = page.video();
  await context.close();
  const file = await video.path();
  const named = path.join(out, `console-${new Date().toISOString().slice(0, 10)}.mp4`);
  // Remotion ships an ffmpeg build; it trims the sign-in and encodes H.264.
  const ffmpeg = path.join(root, 'video/node_modules/@remotion/compositor-win32-x64-msvc/ffmpeg.exe');
  require('node:child_process').execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-ss', cut.toFixed(2), '-i', file,
    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', '-an', named]);
  fs.unlinkSync(file);
  console.log(named, 'trimmed', cut.toFixed(1) + 's of sign-in');
  await browser.close();
})().catch((e) => { console.error(e.message); process.exit(1); });
