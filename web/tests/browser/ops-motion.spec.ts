import { test, expect } from "@playwright/test";
test.use({ video: "on" });
test.beforeEach(() => test.skip(process.env.RAYSTO_FINANCE_017_E2E !== "on", "Authored UI fixtures only."));

for (const width of [320, 390]) test(`the complete starting action fits the first viewport at ${width}px`, async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.setViewportSize({ width, height: width === 320 ? 740 : 844 });
  await page.goto("/ops/preview?section=overview&demo=1");
  const action = page.getByRole("button", { name: "Start the investigation", exact: true });
  await expect(action).toBeEnabled();
  await page.evaluate(() => document.fonts.ready);
  await page.locator(".jr-sales").scrollIntoViewIfNeeded();
  await page.locator(".jr-channels").scrollIntoViewIfNeeded();
  await page.evaluate(() => scrollTo(0, 0));
  const box = (await action.boundingBox())!;
  expect(box.y + box.height).toBeLessThanOrEqual(width === 320 ? 740 : 844);
  expect(box.height).toBeGreaterThanOrEqual(48);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  await page.screenshot({ path: `test-results/ops-motion/overview-${width}.png`, fullPage: true });
});

test("returning to Today retains its figures while fresh data loads", async ({ page }) => {
  await page.goto("/ops/preview?section=overview&state=motion-slow");
  const summary = page.getByRole("region", { name: "Café summary" });
  await expect(summary).toContainText("$195.30");
  await page.getByRole("button", { name: "Team", exact: true }).click();
  await expect(page.getByRole("heading", { name: "Team", exact: true, level: 1 })).toBeVisible();
  await page.getByRole("button", { name: "Today", exact: true }).first().click();
  await expect(summary).toContainText("$195.30");
  await expect(page.getByText("Loading…", { exact: true })).toHaveCount(0);
  await expect(page.getByText(/Updating the last 7 days/)).toBeVisible();
});

test("a requested period does not relabel the previous result", async ({ page }) => {
  await page.goto("/ops/preview?section=overview&state=motion-slow");
  await expect(page.getByRole("region", { name: "Café summary" })).toContainText("$195.30");
  await page.getByRole("button", { name: "30 days", exact: true }).click();
  await expect(page.getByText(/displayed figures still cover the last 7 days/)).toBeVisible();
  await expect(page.getByRole("region", { name: "Café summary" })).toContainText("$195.30");
  await expect(page.getByText(/displayed figures still cover/)).toHaveCount(0, { timeout: 10000 });
});

test("daily close distinguishes loading from confirmed absence and failure", async ({ page }) => {
  await page.goto("/ops/preview?section=money&state=motion-close-failed");
  await expect(page.getByRole("heading", { name: "Checking today’s close…" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Run the close", exact: true })).toBeDisabled();
  await expect(page.getByRole("heading", { name: "Today's close is unavailable" })).toBeVisible();
  await expect(page.getByRole("heading", { name: "Not closed yet" })).toHaveCount(0);
});

test("receipt close completes its normal-motion exit and returns focus", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=finance&tab=evidence&product=171");
  const opener = page.getByRole("button", { name: "Inspect receipt", exact: true }).first();
  await opener.click();
  const dialog = page.getByRole("dialog", { name: "Confirmed receipt evidence" });
  await expect(dialog).toBeVisible();
  await dialog.getByRole("button", { name: "Close", exact: true }).click();
  await expect(dialog).toHaveCount(0);
  await expect(opener).toBeFocused();
});

for (const width of [320, 1440]) test(`receipt loading keeps its footer stable at ${width}px`, async ({ page }) => {
  await page.setViewportSize({ width, height: 1000 });
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=finance&tab=evidence&product=171&state=motion-slow");
  await page.getByRole("button", { name: "Inspect receipt", exact: true }).first().click();
  const dialog = page.getByRole("dialog", { name: "Confirmed receipt evidence" });
  const footer = dialog.getByRole("button", { name: "Close evidence", exact: true });
  await expect(dialog.getByText("Loading receipt…", { exact: true })).toBeVisible();
  await page.waitForTimeout(550);
  const before = (await footer.boundingBox())!;
  await expect(dialog.getByText("Receipt unit cost:", { exact: false })).toBeVisible();
  const after = (await footer.boundingBox())!;
  expect(Math.abs(after.y - before.y)).toBeLessThanOrEqual(1);
});

test("the phone drawer closes, restores focus and recovers across a breakpoint", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=overview");
  const opener = page.getByRole("button", { name: "Open the console menu" });
  await opener.click();
  const drawer = page.getByRole("dialog", { name: "Console menu" });
  await expect(drawer).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(drawer).not.toBeVisible();
  await expect(opener).toBeFocused();
  await opener.click();
  await page.setViewportSize({ width: 1024, height: 844 });
  await expect(drawer).not.toBeVisible();
});

test("dismissal reverses a drawer that is still entering without jumping to its end", async ({ page }) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=overview");
  await page.getByRole("button", { name: "Open the console menu" }).click();
  const offsets = await page.locator(".ops-drawer").evaluate(el => {
    // Freeze an intermediate entrance frame; dispatch the native cancel event
    // in the same task so browser-driver latency cannot finish the short exit.
    const entrance = el.getAnimations().find(a => a instanceof CSSAnimation);
    if (!entrance) throw new Error("Expected the normal-motion drawer entrance");
    entrance.pause();
    entrance.currentTime = 60;
    const before = new DOMMatrix(getComputedStyle(el).transform).m41;
    el.dispatchEvent(new Event("cancel", { cancelable: true }));
    const frames = el.getAnimations().filter(a => !(a instanceof CSSAnimation))
      .map(a => a.effect instanceof KeyframeEffect ? a.effect.getKeyframes() : [])
      .find(f => f.at(-1)?.transform === "translateX(-100%)");
    const start = frames?.[0]?.transform ? new DOMMatrix(String(frames[0].transform)).m41 : null;
    return { before, start };
  });
  expect(offsets.before).toBeLessThan(0);
  expect(offsets.start).not.toBeNull();
  expect(Math.abs(offsets.start! - offsets.before)).toBeLessThanOrEqual(1);
  await expect(page.getByRole("dialog", { name: "Console menu" })).not.toBeVisible();
});

test("app reduced motion stops CSS activity and device preference cannot be overridden", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=overview");
  await page.getByRole("switch", { name: "Reduce motion" }).check();
  await expect(page.locator("html")).toHaveAttribute("data-raysto-reduce-motion", "");
  await page.getByRole("button", { name: "Sales and margins", exact: true }).click();
  const summaries = page.locator("details>summary");
  if (await summaries.count()) expect(await summaries.first().evaluate(el => getComputedStyle(el, "::after").transitionDuration)).toBe("0s");
  await page.getByRole("switch", { name: "Reduce motion" }).uncheck();
  await page.emulateMedia({ reducedMotion: "reduce" });
  expect(await page.locator(".ops-btn").first().evaluate(el => getComputedStyle(el).transitionDuration)).toBe("0s");
});

for (const reducedMotion of ["no-preference", "reduce"] as const) test(`record the investigation entry and evidence with ${reducedMotion}`, async ({ page }) => {
  await page.emulateMedia({ reducedMotion });
  await page.goto("/ops/preview?section=overview&demo=1");
  const start = page.getByRole("button", { name: "Start the investigation", exact: true });
  await expect(start).toBeEnabled();
  await page.evaluate(() => document.fonts.ready);
  await page.locator(".jr-sales").scrollIntoViewIfNeeded();
  await page.waitForTimeout(450);
  await page.locator(".jr-channels").scrollIntoViewIfNeeded();
  await page.waitForTimeout(450);
  await page.evaluate(() => scrollTo(0, 0));
  await page.screenshot({ path: `test-results/ops-motion/desktop-${reducedMotion}.png`, fullPage: true });
  await start.click();
  await expect(page.getByRole("heading", { name: "The cost behind this dish" })).toBeVisible();
  const inspect = page.getByRole("button", { name: "Inspect receipt", exact: true }).first();
  await inspect.click();
  const dialog = page.getByRole("dialog", { name: "Confirmed receipt evidence" });
  await expect(dialog).toContainText("Receipt unit cost");
  await page.screenshot({ path: `test-results/ops-motion/receipt-${reducedMotion}.png` });
  await dialog.getByRole("button", { name: "Close", exact: true }).click();
  await expect(dialog).toHaveCount(0);
  await page.getByRole("button", { name: "Compare price options", exact: true }).click();
  await expect(page.getByRole("heading", { name: "Compare a pricing decision" })).toBeFocused();
});


test("scope changes, late responses and permission loss cannot restore retained figures", async ({ page }) => {
  await page.goto("/ops/preview?state=motion-scope");
  const result = page.getByLabel("Retained result");
  await expect(result).toHaveText("1:1");
  await page.getByRole("button", { name: "Queue obsolete read" }).click();
  await page.waitForTimeout(50);
  await page.getByRole("button", { name: "Switch venue" }).click();
  await expect(result).not.toHaveText("1:1");
  await expect(result).toHaveText("1:2");
  await page.waitForTimeout(1600);
  await expect(result).toHaveText("1:2");
  await page.getByRole("button", { name: "Switch identity" }).click();
  await expect(result).not.toHaveText("1:2");
  await expect(result).toHaveText("2:2");
  await page.getByRole("button", { name: "Revoke access" }).click();
  await expect(page.getByRole("main").getByRole("alert")).toContainText("Permission revoked");
  await expect(result).toHaveText("Pending");
  await page.getByRole("button", { name: "Queue obsolete read" }).click();
  await page.getByRole("button", { name: "End scope" }).click();
  await page.waitForTimeout(500);
  await expect(result).toHaveText("Pending");
});


test("the investigation opens while dish costing is still loading", async ({ page }) => {
  await page.goto("/ops/preview?section=overview&state=motion-slow");
  await expect(page.getByText("Finding confirmed dish costs…", { exact: true })).toBeVisible();
  const start = page.getByRole("button", { name: "Start the investigation", exact: true });
  expect(await start.isEnabled()).toBe(true);
  await start.click();
  await expect(page.getByRole("heading", { name: "The cost behind this dish" })).toBeVisible();
});
