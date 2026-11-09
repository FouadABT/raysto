import { test, expect } from "@playwright/test";

test.use({ video: { mode: "on", size: { width: 1440, height: 1000 } } });

test("visible GSAP replay connects the AI and PayPal story", async ({
  page,
}) => {
  await page.emulateMedia({ reducedMotion: "no-preference" });
  const errors: string[] = [],
    requests: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  page.on("request", (request) => {
    if (/\/api\//.test(request.url())) requests.push(request.url());
  });
  await page.goto("/");
  await expect(page.locator(".lp-integration-tags")).toContainText(
    "PayPal payments",
  );
  await expect(
    page.getByRole("link", { name: "PayPal", exact: true }),
  ).toBeVisible();
  await page.waitForTimeout(2300);
  const replay = page.getByRole("button", {
    name: "Replay introduction",
    exact: true,
  });
  await expect(replay).toBeEnabled();
  await replay.click();
  await page.waitForTimeout(70);
  const first = await page
    .locator("[data-hero-dashboard]")
    .evaluate((el) => getComputedStyle(el).transform);
  expect(first).not.toBe("none");
  await page.waitForTimeout(300);
  expect(
    await page
      .locator("[data-hero-dashboard]")
      .evaluate((el) => getComputedStyle(el).transform),
  ).not.toBe(first);
  await page.waitForTimeout(1800);
  await page
    .getByRole("button", { name: "Replay order journey", exact: true })
    .click();
  await page.waitForTimeout(2100);
  await page.locator("#payments").scrollIntoViewIfNeeded();
  await expect(page.locator(".lp-payment-qualification")).toContainText(
    "PayPal Sandbox",
  );
  await page.waitForTimeout(1200);
  await page
    .getByRole("button", { name: "Replay AI workflow", exact: true })
    .click();
  await page.waitForTimeout(1800);
  await expect(page.locator(".lp-proposal")).toContainText("Needs review");
  await expect(page.locator(".lp-proposal")).toContainText("Not posted");
  await page.screenshot({
    path: "test-results/marketing/ai-paypal-motion.png",
  });
  expect(errors).toEqual([]);
  expect(requests).toEqual([]);
});

test("reduced-motion mode explains the browser preference without overriding it", async ({
  page,
}) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.goto("/");
  await expect(
    page.getByRole("button", { name: "Replay introduction", exact: true }),
  ).toBeDisabled();
  await expect(page.locator("#lp-motion-hint-hero")).toContainText(
    "Your browser/device requests reduced motion",
  );
  await page.screenshot({ path: "test-results/marketing/reduced-motion-status.png" });
  await page.getByRole("checkbox", { name: "Reduce motion" }).check();
  await page.getByRole("checkbox", { name: "Reduce motion" }).uncheck();
  await expect(
    page.getByRole("button", { name: "Replay introduction", exact: true }),
  ).toBeDisabled();
  expect(
    await page
      .locator("[data-hero-dashboard]")
      .evaluate((el) => el.getAttribute("style") ?? ""),
  ).not.toContain("transform");
});
