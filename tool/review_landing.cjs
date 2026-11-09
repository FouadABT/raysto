/** Local production marketing review. No account, payment or message submission. */
const { chromium } = require("../web/node_modules/playwright");
const fs = require("node:fs/promises");
const path = require("node:path");
const os = require("node:os");
const origin = process.env.RAYSTO_LANDING_ORIGIN || "http://127.0.0.1:3110";
if (!/^http:\/\/127\.0\.0\.1:\d+$/.test(origin))
  throw Error("Local candidate only");
const output = path.resolve(__dirname, "../.tooling/landing-production");

(async () => {
  await fs.mkdir(output, { recursive: true });
  const browser = await chromium.launch({ channel: "msedge", headless: true });
  const report = {
    checkedAtUtc: new Date().toISOString(),
    origin,
    browser: browser.version(),
    platform: os.platform(),
    cpu: os.cpus()[0].model,
    logicalCpus: os.cpus().length,
    memoryBytes: os.totalmem(),
    network:
      "Local production server; no artificial network throttle; browser CPU only throttled where stated.",
    dataset:
      "Deterministic illustrative scenes: six tables, three kitchen states, three menu views, seven roles and three FAQs. No business API.",
    runs: [],
  };
  try {
    for (const setting of [
      { width: 1440, height: 1000, cpu: 1 },
      { width: 390, height: 844, cpu: 1 },
      { width: 1440, height: 1000, cpu: 4 },
    ]) {
      const context = await browser.newContext({
        viewport: { width: setting.width, height: setting.height },
        reducedMotion: "no-preference",
      });
      const page = await context.newPage(),
        errors = [],
        blockedRequests = [];
      page.on("pageerror", (error) => errors.push(error.message));
      page.on("console", (message) => { if (message.type() === "error") errors.push(message.text()); });
      await page.route("**/api/**", (route) => {
        blockedRequests.push(new URL(route.request().url()).pathname);
        return route.abort();
      });
      const client = await context.newCDPSession(page);
      await client.send("Emulation.setCPUThrottlingRate", {
        rate: setting.cpu,
      });
      await page.addInitScript(() => {
        const data = (window.__landingReview = {
          lcpMs: null,
          cls: 0,
          longTasks: [],
          inputDurations: [],
          intervals: [],
        });
        new PerformanceObserver((list) => {
          for (const item of list.getEntries()) data.lcpMs = item.startTime;
        }).observe({ type: "largest-contentful-paint", buffered: true });
        new PerformanceObserver((list) => {
          for (const item of list.getEntries())
            if (!item.hadRecentInput) data.cls += item.value;
        }).observe({ type: "layout-shift", buffered: true });
        new PerformanceObserver((list) => {
          for (const item of list.getEntries())
            data.longTasks.push({
              startMs: item.startTime,
              durationMs: item.duration,
            });
        }).observe({ type: "longtask", buffered: true });
        new PerformanceObserver((list) => {
          for (const item of list.getEntries())
            if (item.interactionId) data.inputDurations.push(item.duration);
        }).observe({ type: "event", durationThreshold: 16, buffered: true });
        let first, previous;
        const frame = (t) => {
          first ??= t;
          if (previous != null) data.intervals.push(t - previous);
          previous = t;
          if (t - first < 2200) requestAnimationFrame(frame);
        };
        requestAnimationFrame(frame);
      });
      await page.goto(origin, { waitUntil: "load", timeout: 60000 });
      await page.getByRole("heading", { level: 1 }).waitFor();
      await page.evaluate(() => document.fonts.ready);
      await page.waitForTimeout(2500);
      const initial = await page.evaluate(() => {
        const data = window.__landingReview,
          frames = data.intervals.toSorted((a, b) => a - b);
        const resources = performance.getEntriesByType("resource");
        return {
          lcpMs: data.lcpMs,
          cls: data.cls,
          startupLongTasks: [...data.longTasks],
          startupFrames: frames.length,
          p95StartupFrameMs:
            frames[Math.ceil(frames.length * 0.95) - 1] ?? null,
          startupFramesWithin20ms: frames.length
            ? frames.filter((n) => n <= 20).length / frames.length
            : null,
          scriptEncodedBytes: resources
            .filter((r) => /\.js$/.test(new URL(r.name).pathname))
            .reduce((n, r) => n + r.encodedBodySize, 0),
          scriptDecodedBytes: resources
            .filter((r) => /\.js$/.test(new URL(r.name).pathname))
            .reduce((n, r) => n + r.decodedBodySize, 0),
          imageEncodedBytes: resources
            .filter((r) =>
              /\.(?:webp|avif|png|jpe?g|svg)$|\/_next\/image$/.test(
                new URL(r.name).pathname,
              ),
            )
            .reduce((n, r) => n + r.encodedBodySize, 0),
          resources: resources.map((r) => ({
            request: r.name.replace(location.origin, ""),
            initiator: r.initiatorType,
            encodedBytes: r.encodedBodySize,
            decodedBytes: r.decodedBodySize,
          })),
        };
      });
      for (const id of ["how-it-works", "platform", "ai"]) {
        await page.locator("#" + id).scrollIntoViewIfNeeded();
        await page.waitForTimeout(1300);
      }
      await page
        .getByRole("button", { name: "Select sample table 2", exact: true })
        .click();
      await page
        .getByRole("button", { name: "Review proposal", exact: true })
        .click();
      await page
        .getByRole("dialog", { name: "Review the proposal", exact: true })
        .waitFor();
      await page.keyboard.press("Escape");
      await page.getByRole("tab", { name: "Kitchen", exact: true }).click();
      await page.locator(".lp-final").scrollIntoViewIfNeeded();
      await page.waitForTimeout(1300);
      await page.evaluate(() => scrollTo({ top: 0, behavior: "instant" }));
      await page.waitForTimeout(500);
      const label = `${setting.width}-${setting.cpu}x`;
      if (setting.cpu === 1)
        await page.screenshot({
          path: path.join(output, `home-${label}.png`),
          fullPage: true,
        });
      const end = await page.evaluate(() => ({
        cls: window.__landingReview.cls,
        observedInteractionDurationsMs: window.__landingReview.inputDurations,
        longTasks: window.__landingReview.longTasks,
        noHorizontalOverflow:
          document.documentElement.scrollWidth <= innerWidth,
      }));
      report.runs.push({
        ...setting,
        ...initial,
        ...end,
        errors,
        blockedRequests,
        interpretation:
          "Synthetic localhost diagnostics. Startup frames are not field INP or a complete interaction benchmark; network resource bytes include matching preloads, exclude inline HTML/scripts, and are not added bundle size.",
      });
      await context.close();
      if (errors.length || blockedRequests.length)
        throw Error(
          "Browser error or unexpected API request during landing review.",
        );
    }
  } catch (error) {
    report.failure = error.message;
    process.exitCode = 1;
  } finally {
    await browser.close();
    await fs.writeFile(
      path.join(output, "results.json"),
      JSON.stringify(report, null, 2),
    );
  }
  console.log(JSON.stringify(report));
})().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
