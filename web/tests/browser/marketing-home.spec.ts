import { test, expect } from "@playwright/test";
test.use({ video: "on" });

test("200-percent desktop reflow equivalent preserves the primary action", async ({
  browser,
  baseURL,
}) => {
  // 1440×1000 physical pixels at 2× scale => 720×500 layout pixels.
  const context = await browser.newContext({
    baseURL,
    viewport: { width: 720, height: 500 },
    deviceScaleFactor: 2,
    reducedMotion: "reduce",
  });
  const page = await context.newPage();
  await page.goto("/");
  const action = page
    .locator(".lp-hero-copy")
    .getByRole("link", { name: "Book a demo" });
  await action.scrollIntoViewIfNeeded();
  await expect(action).toBeVisible();
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth,
    ),
  ).toBe(true);
  await page.screenshot({
    path: "test-results/marketing/zoom-200-equivalent.png",
  });
  await context.close();
});

for (const width of [320, 390, 768, 1024, 1440, 1920])
  test(`marketing homepage reflows at ${width}px`, async ({ page }) => {
    await page.setViewportSize({ width, height: width < 600 ? 844 : 1000 });
    await page.emulateMedia({ reducedMotion: "reduce" });
    const errors: string[] = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await page.goto("/");
    await expect(page.getByRole("heading", { level: 1 })).toHaveText(
      "Every order.Every table.One clear view.",
    );
    await page.evaluate(() => document.fonts.ready);
    await expect(page.locator(".lp-hero-photo img")).toBeVisible();
    expect(
      await page
        .locator(".lp-hero-photo img")
        .evaluate((element: HTMLImageElement) => element.naturalWidth),
    ).toBeGreaterThan(0);
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth,
      ),
    ).toBe(true);
    const cta = page
      .locator(".lp-hero-copy")
      .getByRole("link", { name: "Book a demo" });
    expect((await cta.boundingBox())!.height).toBeGreaterThanOrEqual(48);
    if (width < 600) {
      const action = (await cta.boundingBox())!;
      expect(action.y + action.height).toBeLessThanOrEqual(844);
    }
    const tableMetric = (await page
      .locator(".lp-dashboard-stats>div")
      .last()
      .boundingBox())!;
    const phone = (await page.locator(".lp-hero-phone").boundingBox())!;
    expect(phone.y).toBeGreaterThanOrEqual(tableMetric.y + tableMetric.height);
    for (const id of ["how-it-works", "platform", "ai", "faq"])
      await expect(page.locator(`#${id}`)).toBeAttached();
    const invalidAnchors = await page
      .locator('a[href^="#"]')
      .evaluateAll((links) =>
        links
          .filter(
            (link) =>
              !document.getElementById(link.getAttribute("href")!.slice(1)),
          )
          .map((link) => link.getAttribute("href")),
      );
    expect(invalidAnchors).toEqual([]);
    if ([390, 1440].includes(width)) {
      await page.screenshot({
        path: `test-results/marketing/home-${width}.png`,
        fullPage: true,
      });
      await page
        .locator(".lp-hero")
        .screenshot({ path: `test-results/marketing/hero-${width}.png` });
      await page
        .locator(".lp-ai")
        .screenshot({ path: `test-results/marketing/ai-${width}.png` });
    }
    expect(errors).toEqual([]);
  });

test("product interactions stay local and keyboard role tabs expose matching content", async ({
  page,
}) => {
  const mutations: string[] = [];
  page.on("request", (request) => {
    if (
      request.method() !== "GET" &&
      /\/api\/raysto|paypal/i.test(request.url())
    )
      mutations.push(request.url());
  });
  await page.goto("/");
  await page
    .getByRole("button", { name: "Select sample table 2", exact: true })
    .click();
  await expect(page.locator(".lp-table-detail")).toContainText("Table 02");
  await page.getByRole("tab", { name: "Ready 1", exact: true }).click();
  await expect(page.locator("#kitchen-panel")).toContainText("Order #23");
  await page.getByRole("tab", { name: "Supplies", exact: true }).click();
  await expect(page.locator("#menu-panel")).toContainText("Delivery to review");
  await page.getByRole("tab", { name: "Accounting", exact: true }).click();
  await expect(page.locator("#role-panel")).toContainText(
    "Needs review · Not posted",
  );
  await page.keyboard.press("ArrowRight");
  await expect(
    page.getByRole("tab", { name: "Stock", exact: true }),
  ).toBeFocused();
  await expect(page.locator("#role-panel")).toContainText(
    "Know what is available for service.",
  );
  await page
    .getByRole("button", { name: "Add Croque monsieur to sample basket" })
    .click();
  await expect(page.locator(".lp-hero-phone [role=status]")).toContainText(
    "no order placed",
  );
  expect(mutations).toEqual([]);
});

test("source and review dialogs retain a proposal state and restore focus", async ({
  page,
}) => {
  await page.goto("/");
  const source = page.getByRole("button", { name: "View source" });
  await source.click();
  const dialog = page.getByRole("dialog", { name: "Source evidence" });
  await expect(dialog).toContainText("not a real supplier invoice");
  await page.keyboard.press("Escape");
  await expect(dialog).not.toBeVisible();
  await expect(source).toBeFocused();
  await page
    .getByRole("button", { name: "Review proposal", exact: true })
    .click();
  const review = page.getByRole("dialog", {
    name: "Review the proposal",
    exact: true,
  });
  await expect(review).toContainText("Not posted");
  await expect(
    review.getByRole("button", { name: /Approve|Pay|Post/ }),
  ).toHaveCount(0);
  await review.getByRole("button", { name: "Close preview" }).click();
  await expect(review).not.toBeVisible();
});

test("initial HTML, native navigation and FAQ work without JavaScript", async ({
  browser,
  baseURL,
}) => {
  const context = await browser.newContext({
    javaScriptEnabled: false,
    baseURL,
  });
  const page = await context.newPage();
  await page.goto("/");
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "Every order.",
  );
  await expect(page.locator(".lp-faq-list details").first()).toHaveAttribute(
    "open",
    "",
  );
  await page
    .locator(".lp-faq-list summary")
    .filter({ hasText: "Can it support dine-in, pickup and delivery?" })
    .click();
  await expect(page.getByText(/Available service modes depend/)).toBeVisible();
  await page
    .locator(".lp-hero-copy")
    .getByRole("link", { name: "Book a demo" })
    .click();
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "your next service.",
  );
  await expect(
    page.getByRole("link", { name: "Prepare email draft" }),
  ).toHaveAttribute("href", /^mailto:/);
  await context.close();
});

test("device and app reduced motion stop enhancement and re-entry remains healthy", async ({
  page,
}) => {
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/");
  await page.getByRole("checkbox", { name: "Reduce motion" }).check();
  await expect(page.locator(".raysto-landing")).toHaveAttribute(
    "data-reduce-motion",
    "true",
  );
  expect(
    await page
      .locator("[data-hero-dashboard]")
      .evaluate((el) => el.getAttribute("style") ?? ""),
  ).not.toContain("transform");
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.getByRole("checkbox", { name: "Reduce motion" }).uncheck();
  await expect(page.locator(".raysto-landing")).toHaveAttribute(
    "data-reduce-motion",
    "true",
  );
  await page
    .locator(".lp-hero-copy")
    .getByRole("link", { name: "Book a demo" })
    .click();
  await page.goBack();
  await expect(page.getByRole("heading", { level: 1 })).toContainText(
    "One clear view.",
  );
  expect(errors).toEqual([]);
});

test("compact navigation closes on Escape and the page survives enlarged text", async ({
  page,
}) => {
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  const summary = page.getByLabel("Open navigation");
  await summary.click();
  await expect(
    page.getByRole("navigation", { name: "Mobile navigation" }),
  ).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(summary).toBeFocused();
  await expect(
    page.getByRole("navigation", { name: "Mobile navigation" }),
  ).not.toBeVisible();
  await summary.click();
  await page.setViewportSize({ width: 1024, height: 844 });
  await page.setViewportSize({ width: 390, height: 844 });
  await expect(
    page.getByRole("navigation", { name: "Mobile navigation" }),
  ).not.toBeVisible();
  await page.addStyleTag({ content: "html { font-size:200% !important; }" });
  await expect(
    page.locator(".lp-hero-copy").getByRole("link", { name: "Book a demo" }),
  ).toBeVisible();
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth,
    ),
  ).toBe(true);
});

test.describe("motion recordings", () => {
  for (const reducedMotion of ["no-preference", "reduce"] as const)
    test(`record marketing motion with ${reducedMotion}`, async ({ page }) => {
      await page.emulateMedia({ reducedMotion });
      await page.goto("/");
      await page.waitForTimeout(1600);
      for (const id of ["how-it-works", "platform", "ai"]) {
        await page.locator(`#${id}`).scrollIntoViewIfNeeded();
        await page.waitForTimeout(1500);
      }
      await page
        .getByRole("button", { name: "Review proposal", exact: true })
        .click();
      await page.waitForTimeout(350);
      await page.keyboard.press("Escape");
      await page.getByRole("tab", { name: "Kitchen", exact: true }).click();
      await page.locator(".lp-final").scrollIntoViewIfNeeded();
      await page.waitForTimeout(1200);
      await expect(
        page.getByRole("heading", { name: "Bring your restaurant together." }),
      ).toBeVisible();
    });

  test("email demo prepares a draft without sending or confirming a booking", async ({
    page,
  }) => {
    await page.goto("/contact");
    await page.getByLabel("Your name").fill("Sam Review");
    await page.getByLabel("Restaurant or café").fill("A sample café");
    await page
      .getByLabel("What would you like to explore?")
      .fill("I'd like to understand the kitchen workflow.");
    const href = await page
      .getByRole("link", { name: "Prepare email draft" })
      .getAttribute("href");
    expect(href).toMatch(/^mailto:\?/);
    expect(decodeURIComponent(href!)).toContain("Sam Review");
    expect(decodeURIComponent(href!)).toContain("kitchen workflow");
    await expect(
      page.getByText(/does not send a message or confirm a booking/),
    ).toBeVisible();
    await page.reload();
    await expect(page.getByLabel("Your name")).toHaveValue("Sam Review");
    await page.getByRole("button", { name: "Clear draft" }).click();
    await page.reload();
    await expect(page.getByLabel("Your name")).toHaveValue("");
  });
});
