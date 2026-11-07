/** Read-only review of an already-running LOCAL production console. No commands or AI turns. */
const { chromium } = require('../web/node_modules/playwright');
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const output = path.resolve(__dirname, '../.tooling/ops-motion-production');
const origin = process.env.RAYSTO_MOTION_REVIEW_ORIGIN || 'http://127.0.0.1:3101';
if (!/^http:\/\/127\.0\.0\.1:\d+$/.test(origin)) throw Error('Local candidate only.');

(async () => {
  await fs.mkdir(output, { recursive: true });
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  const report = { checkedAtUtc: new Date().toISOString(), origin, platform: os.platform(),
    method: 'v2-native-input-transition-windows', viewport: { width: 1440, height: 1000 },
    diagnosticProfiling: process.env.RAYSTO_MOTION_PROFILE === '1', sharedAuthenticatedContext: true,
    cpu: os.cpus()[0]?.model, logicalCpus: os.cpus().length, memoryBytes: os.totalmem(),
    browser: browser.version(), provenance: 'Local production web candidate; shared USD judge sample, existing Sandbox records; read-only.', runs: [] };
  let sharedContext, sharedPage, sharedClient;
  try {
    for (const rate of process.env.RAYSTO_MOTION_REVIEW_RATE === '1' ? [1] : [1, 4]) {
      const context = sharedContext ??= await browser.newContext({ viewport: { width: 1440, height: 1000 }, reducedMotion: 'no-preference',
        ...(process.env.RAYSTO_MOTION_REVIEW_CAPTURE === '1' ? { recordVideo: { dir: output, size: { width: 1440, height: 1000 } } } : {}) });
      const existingPage = !!sharedPage;
      const page = sharedPage ??= await context.newPage();
      // Refuse business mutations even if a future UI accidentally attempts one.
      if (!existingPage) await page.route('**/api/raysto/**', route => {
        const url = new URL(route.request().url());
        if (/\/commands\/|\/studio\/turn|\/assistant/.test(url.pathname) && route.request().method() !== 'GET') return route.abort();
        return route.continue();
      });
      const client = sharedClient ??= await context.newCDPSession(page);
      await client.send('Emulation.setCPUThrottlingRate', { rate });
      if (existingPage) await page.getByRole('button', { name: 'Today', exact: true }).first().click();
      else await page.goto(origin + '/ops?judge=1', { waitUntil: 'domcontentloaded', timeout: 60000 });
      const start = page.getByRole('button', { name: 'Start the investigation', exact: true });
      await start.waitFor({ state: 'visible', timeout: 60000 });
      await page.waitForFunction(() => ![...document.querySelectorAll('button')].find(b => b.textContent.includes('Start the investigation'))?.disabled);
      await page.evaluate(() => document.fonts.ready);
      await page.locator('.jr-sales').scrollIntoViewIfNeeded();
      await page.waitForTimeout(500);
      await page.locator('.jr-channels').scrollIntoViewIfNeeded();
      await page.waitForTimeout(500);
      await page.evaluate(() => scrollTo(0, 0));
      await page.screenshot({ path: path.join(output, `overview-${rate}x.png`), fullPage: true });
      await start.click();
      const inspect = page.getByRole('button', { name: 'Inspect receipt', exact: true }).first();
      await inspect.waitFor({ state: 'visible', timeout: 45000 });
      await page.waitForTimeout(500);
      await page.evaluate(() => scrollTo(0, 0));
      const dialog = page.getByRole('dialog', { name: 'Confirmed receipt evidence' });
      const center = async locator => { const box = await locator.boundingBox(); if (!box || box.y < 0 || box.y + box.height > 1000) throw Error('Review control is unavailable in the measured viewport.'); return { x: box.x + box.width/2, y: box.y + box.height/2 }; };
      const inspectPoint = await center(inspect);
      const comparePoint = await center(page.locator('.ops-decision-nav button').nth(2));
      const evidencePoint = await center(page.locator('.ops-decision-nav button').nth(1));
      await inspect.click();
      await dialog.getByText('Receipt unit cost:', { exact: false }).waitFor({ state: 'visible' });
      await page.waitForTimeout(550);
      const closePoint = await center(dialog.locator('.m3-dialog-close'));
      await dialog.locator('.m3-dialog-close').click();
      await dialog.waitFor({ state: 'detached' });
      const idleCadence = await page.evaluate(() => new Promise(resolve => {
        const frames = []; let previous, done = false;
        const finish = () => { if (done) return; done = true; const sorted = frames.toSorted((a,b) => a-b); resolve({ count: sorted.length, p95Ms: sorted[Math.max(0, Math.ceil(sorted.length*.95)-1)] ?? null, within20msFraction: sorted.length ? sorted.filter(n=>n<=20).length/sorted.length : null }); };
        setTimeout(finish, 2200);
        const tick = t => { if(done)return; if(previous!=null)frames.push(t-previous); previous=t; if(frames.length>=60)finish(); else requestAnimationFrame(tick); }; requestAnimationFrame(tick);
      }));
      if (process.env.RAYSTO_MOTION_TRACE_ROI === '1') await client.send('Tracing.start', { categories: 'devtools.timeline,v8,disabled-by-default-v8.gc,blink.user_timing', transferMode: 'ReturnAsStream' });
      await page.evaluate(() => {
        const data = window.__opsMotion = { intervals: [], tasks: [], shifts: [], tracking: true, until: 0 };
        new PerformanceObserver(list => { for (const item of list.getEntries()) data.tasks.push({ start: item.startTime, duration: item.duration }); }).observe({ type: 'longtask', buffered: false });
        new PerformanceObserver(list => { for (const item of list.getEntries()) if (!item.hadRecentInput) data.shifts.push({ value: item.value, sources: item.sources.map(source => ({ element: source.node?.className ?? source.node?.parentElement?.className ?? 'text', before: source.previousRect, after: source.currentRect })) }); }).observe({ type: 'layout-shift', buffered: false });
        let previous;
        function frame(t) {
          if (!data.tracking) return;
          // No per-frame DOM/animation enumeration: that forces style work.
          const active = t <= data.until;
          if (active && previous != null) data.intervals.push(t - previous);
          previous = active ? t : undefined;
          requestAnimationFrame(frame);
        }
        requestAnimationFrame(frame);
      });
      if (process.env.RAYSTO_MOTION_PROFILE === '1') { await client.send('Profiler.enable'); await client.send('Profiler.start'); }
      const clickWindow = async (point, duration) => {
        await page.evaluate(ms => { window.__opsMotion.until = performance.now() + ms; }, duration);
        await page.mouse.click(point.x, point.y);
      };
      for (let iteration = 0; iteration < 3; iteration++) {
        // Coordinates are resolved before measurement. Role/actionability queries
        // otherwise dominate the sampled CPU at 4x and are not application work.
        await clickWindow(inspectPoint, 550);
        await page.waitForTimeout(650);
        if (!(await page.evaluate(() => !!document.querySelector('dialog[open]')))) throw Error('Receipt did not open during the measured cycle.');
        await clickWindow(closePoint, 220);
        await page.waitForTimeout(250);
        if (await page.evaluate(() => !!document.querySelector('dialog[open]'))) throw Error('Receipt did not close during the measured cycle.');
        await clickWindow(comparePoint, 240);
        await page.waitForTimeout(450);
        if (await page.evaluate(() => new URLSearchParams(location.search).get('tab')) !== 'compare') throw Error('Comparison stage did not open during the measured cycle.');
        await clickWindow(evidencePoint, 240);
        await page.waitForTimeout(450);
        if (await page.evaluate(() => new URLSearchParams(location.search).get('tab')) !== 'evidence') throw Error('Evidence stage did not open during the measured cycle.');
      }
      const measurements = await page.evaluate(() => {
        const data = window.__opsMotion; data.tracking = false;
        const frames = [...data.intervals].sort((a, b) => a - b);
        return { transitionWindowFrames: frames.length,
          within20msFraction: frames.length ? frames.filter(n => n <= 20).length / frames.length : null,
          p95FrameMs: frames.length ? frames[Math.min(frames.length - 1, Math.ceil(frames.length * .95) - 1)] : null,
          longTasks: data.tasks, layoutShift: data.shifts.reduce((a, b) => a + b.value, 0), layoutShiftEntries: data.shifts };
      });
      await inspect.waitFor({ state: 'visible' });
      if (process.env.RAYSTO_MOTION_PROFILE === '1') {
        const { profile } = await client.send('Profiler.stop');
        await fs.writeFile(path.join(output, `cpu-${rate}x.cpuprofile`), JSON.stringify(profile));
      }
      if (process.env.RAYSTO_MOTION_TRACE_ROI === '1') {
        const done = new Promise(resolve => client.once('Tracing.tracingComplete', resolve));
        await client.send('Tracing.end'); const { stream } = await done;
        const parts = [];
        for (;;) { const part = await client.send('IO.read', { handle: stream }); parts.push(part.base64Encoded ? Buffer.from(part.data, 'base64') : Buffer.from(part.data)); if (part.eof) break; }
        await client.send('IO.close', { handle: stream });
        await fs.writeFile(path.join(output, `trace-roi-${rate}x.json`), Buffer.concat(parts));
      }
      report.runs.push({ cpuThrottle: rate, iterations: 3, idleCadence, captureDuringMeasurement: process.env.RAYSTO_MOTION_REVIEW_CAPTURE === '1', ...measurements, interpretation: 'Long tasks are total observed work; attribution requires trace inspection.' });
      await page.getByRole('button', { name: '02 Cost evidence' }).click();
      await inspect.waitFor({ state: 'visible' });
      await inspect.click();
      await dialog.getByText('Receipt unit cost:', { exact: false }).waitFor({ state: 'visible' });
      await page.waitForTimeout(550);
      await page.screenshot({ path: path.join(output, `receipt-${rate}x.png`) });
      await dialog.getByRole('button', { name: 'Close', exact: true }).click();
      await dialog.waitFor({ state: 'detached' });
      await client.send('Tracing.start', { categories: 'devtools.timeline,blink.user_timing', transferMode: 'ReturnAsStream' });
      await page.getByRole('button', { name: '03 Compare options' }).click();
      await page.getByRole('heading', { name: 'Compare a pricing decision' }).waitFor({ state: 'visible' });
      await page.waitForTimeout(500);
      await page.getByRole('button', { name: '02 Cost evidence' }).click();
      await inspect.waitFor({ state: 'visible' });
      await page.waitForTimeout(500);
      const traceDone = new Promise(resolve => client.once('Tracing.tracingComplete', resolve));
      await client.send('Tracing.end');
      const { stream } = await traceDone;
      const chunks = [];
      for (;;) { const part = await client.send('IO.read', { handle: stream }); chunks.push(part.base64Encoded ? Buffer.from(part.data, 'base64') : Buffer.from(part.data)); if (part.eof) break; }
      await client.send('IO.close', { handle: stream });
      await fs.writeFile(path.join(output, `trace-${rate}x.json`), Buffer.concat(chunks));
    }
  } catch (error) { report.failure = String(error.message).slice(0, 500); }
  finally {
    await browser.close();
    await fs.writeFile(path.join(output, 'results.json'), JSON.stringify(report, null, 2));
  }
  console.log(JSON.stringify(report));
  if (report.failure) process.exitCode = 1;
})().catch(e => { console.error(e.message); process.exitCode = 1; });
