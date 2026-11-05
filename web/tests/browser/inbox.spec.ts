import { expect, test, type Page } from "@playwright/test";

/**
 * The Overview's AI Action Inbox on the development preview (/ops/preview):
 * the real console shell and workspace on fixtures, no backend, no sign-in.
 * `?demo=1` opens it as the shared demo café; `?state=inbox` holds five
 * proposals and `?state=caught-up` an empty inbox whose starters work. Every
 * PayPal id in the fixtures says PREVIEW (src/lib/connected/inbox-preview.ts).
 */
const shots = "test-results/inbox";

async function open(page: Page, query: string) {
  await page.goto(`/ops/preview${query}`);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({ timeout: 60000 });
  await expect(page.getByRole("heading", { name: "AI Action Inbox" })).toBeVisible();
}
const card = (page: Page, title: string) => page.locator("article.ops-inbox-item").filter({ has: page.getByRole("heading", { name: title, exact: true }) });

test.describe("AI Action Inbox", () => {
  test("the demo café lands on the Overview, inbox first, with one Demo café badge and no Try in the navigation", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await open(page, "?state=inbox&demo=1");
    await expect(page.locator(".ops-appbar h1")).toHaveText("Overview");
    const nav = page.locator(".ops-shell-side .ops-sections");
    await expect(nav.getByRole("button", { name: "Overview" })).toHaveAttribute("aria-current", "page");
    await expect(nav.getByRole("button", { name: /Try/ })).toHaveCount(0);
    await expect(page.locator(".ops-demo-badge")).toHaveCount(1);
    await expect(page.locator(".ops-demo-badge")).toContainText("Demo café");
    // The badge replaces the bar's own Sandbox chip; the inbox comes before the figures.
    await expect(page.locator(".ops-appbar-sandbox")).toHaveCount(0);
    const inbox = await page.locator(".ops-inbox").boundingBox();
    const figures = await page.locator(".ops-ov-figures-head").boundingBox();
    expect(inbox!.y).toBeLessThan(figures!.y);
    await expect(page.locator(".ops-inbox-count")).toHaveText("5 waiting for you · 4 move money");
    await expect(card(page, "Partly refund order #14: $8.50 USD").getByText("PayPal capture PREVIEWCAPTURE7")).toBeVisible();
    await page.waitForTimeout(1200);
    await page.screenshot({ path: `${shots}/overview-1440.png` });
  });

  test("approving a payout shows PayPal's batch id; a refund's id arrives when PayPal confirms", async ({ page }) => {
    await open(page, "?state=inbox&demo=1");
    const payroll = card(page, "Pay this week's tips: $184.00 to 3 people");
    await expect(payroll.getByText("Nadia $72.00, Omar $64.00")).toBeVisible();
    await expect(payroll.locator(".ops-inbox-outcome")).toHaveCount(0);
    await payroll.getByRole("button", { name: /^Approve:/ }).click();
    const done = payroll.locator(".ops-inbox-outcome.done");
    await expect(done).toContainText("Sent with PayPal Payouts. Each person receives it in their PayPal account.");
    await expect(done.locator(".ops-inbox-id")).toHaveText("PayPal batch PREVIEWBATCH03");

    const refund = card(page, "Partly refund order #14: $8.50 USD");
    await refund.getByRole("button", { name: /^Approve:/ }).click();
    // Approved first, with no id invented while PayPal has not answered.
    await expect(refund.locator(".ops-inbox-outcome.done")).toContainText("The refund is on its way to PayPal");
    await expect(refund.getByText("Waiting for PayPal’s id…")).toBeVisible();
    await expect(refund.locator(".ops-inbox-id")).toHaveText("PayPal refund PREVIEWREFUND7Q", { timeout: 20000 });
    await expect(refund.locator(".ops-inbox-outcome.done")).toContainText("Refunded through PayPal.");
    await page.screenshot({ path: `${shots}/approved-1440.png`, fullPage: true });
  });

  test("Not now turns a proposal down; one someone else decided first reads as already handled", async ({ page }) => {
    await open(page, "?state=inbox&demo=1");
    // Four show at first; the fifth is one tap away.
    await expect(page.locator("article.ops-inbox-item")).toHaveCount(4);
    await page.getByRole("button", { name: "Show 1 more" }).click();
    await expect(page.locator("article.ops-inbox-item")).toHaveCount(5);
    const order = card(page, "Order from Marché Dupont: espresso beans and butter");
    await expect(order.getByText("No money moves")).toBeVisible();
    await order.getByRole("button", { name: /^Not now:/ }).click();
    await expect(order.locator(".ops-inbox-outcome.dismissed")).toHaveText(/Turned down\. Nothing changed\./);
    await order.getByRole("button", { name: "Dismiss this result" }).click();
    await expect(order).toHaveCount(0);

    const release = card(page, "Release an unfinished PayPal checkout of $4.50");
    await release.getByRole("button", { name: /^Approve:/ }).click();
    await expect(release.locator(".ops-inbox-outcome.handled")).toContainText("Already handled: someone else decided this one first.");
    await expect(release.locator(".ops-inbox-id")).toHaveCount(0);
  });

  test("an empty inbox says so, and its starters put real work in it", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await open(page, "?state=caught-up&demo=1");
    await expect(page.getByRole("heading", { name: "You’re all caught up." })).toBeVisible();
    const start = page.locator(".ops-inbox-start");
    await expect(start.getByRole("heading", { name: "Start new work" })).toBeVisible();
    for (const name of ["A bill arrived", "A guest complained", "Run this week's payroll", "Collect a deposit"])
      await expect(start.getByRole("button", { name: new RegExp(name) })).toBeVisible();
    await page.screenshot({ path: `${shots}/caught-up-1440.png` });

    await start.getByRole("button", { name: /Run this week's payroll/ }).click();
    await expect(start.getByText(/Ready for your approval in the inbox/)).toBeVisible({ timeout: 20000 });
    const payroll = card(page, "Pay this week's tips: $184.00 to 3 people");
    await expect(payroll).toBeVisible();
    await expect(page.getByRole("heading", { name: "You’re all caught up." })).toHaveCount(0);

    await start.getByRole("button", { name: /Collect a deposit/ }).click();
    const link = page.locator("article.ops-inbox-item").filter({ hasText: "Catering deposit" });
    await expect(link.locator(".ops-paypal-chip")).toHaveText("PayPal Sandbox");
    await expect(link.getByRole("link", { name: "Open the pay link" })).toHaveAttribute("href", "https://api.rays.to/pay/preview-token");
    await expect(link.locator("svg title", { hasText: "QR code for this pay link" })).toHaveCount(1);
    // Nothing reads paid until PayPal's capture arrives.
    await expect(link.locator(".m3-stamp")).toHaveCount(0);
    await expect(link.getByText("PayPal capture PREVIEWCAPTURE2")).toBeVisible({ timeout: 20000 });
    await expect(link.getByRole("link", { name: "Open the pay link" })).toHaveCount(0);

    // The complaint goes on an order PayPal captured, and its refund waits for approval.
    await start.getByRole("button", { name: /A guest complained/ }).click();
    const refund = card(page, "Partly refund order #14: $8.50 USD");
    await expect(refund).toBeVisible({ timeout: 20000 });
    await expect(refund.getByText("PayPal capture PREVIEWCAPTURE7")).toBeVisible();
    await expect(refund.locator(".ops-inbox-outcome")).toHaveCount(0);
    await page.screenshot({ path: `${shots}/started-1440.png`, fullPage: true });
  });

  test("Try is out of the navigation but opens by URL on the demo café, and only there", async ({ page }) => {
    await page.goto("/ops/preview?demo=1&section=try");
    await expect(page.locator(".ops-appbar h1")).toHaveText("Try Raysto", { timeout: 60000 });
    await expect(page.getByRole("heading", { name: /AI coworkers run the caf/ })).toBeVisible();
    await expect(page.locator(".ops-shell-side .ops-sections").getByRole("button", { name: /Try/ })).toHaveCount(0);
    await page.goto("/ops/preview?section=try");
    await expect(page.locator(".ops-appbar h1")).toHaveText("Overview", { timeout: 60000 });
    await page.goto("/ops/preview?demo=1&section=money");
    await expect(page.locator(".ops-appbar h1")).toHaveText("Money", { timeout: 60000 });
  });

  for (const width of [360, 320]) {
    test(`at ${width} px the inbox fits without sideways scrolling, at 2x text too`, async ({ page }) => {
      const errors: string[] = [];
      page.on("pageerror", (e) => errors.push(e.message));
      await page.setViewportSize({ width, height: 780 });
      await open(page, "?state=inbox&demo=1");
      const fits = () => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1);
      expect(await fits()).toBe(true);
      for (const b of await page.locator(".ops-inbox button:visible").all()) {
        const box = await b.boundingBox();
        expect(box!.height).toBeGreaterThanOrEqual(48);
      }
      await page.waitForTimeout(1200);
      await page.screenshot({ path: `${shots}/overview-${width}.png`, fullPage: true });
      // Doubled text inside the inbox: every label wraps instead of pushing the page sideways.
      await page.addStyleTag({ content: ".ops-inbox *:not(svg, svg *) { font-size: 28px !important; line-height: 1.3 !important; }" });
      await page.waitForTimeout(300);
      expect(await fits()).toBe(true);
      await page.screenshot({ path: `${shots}/overview-${width}-2x.png`, fullPage: true });
      expect(errors).toEqual([]);
    });
  }

  test("with reduced motion the inbox is there in the first frame, fully opaque", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await open(page, "?state=inbox&demo=1");
    await expect(page.locator(".ops-inbox-item").first()).toBeVisible();
    const faded = await page.evaluate(() =>
      [...document.querySelectorAll(".ops-inbox *")].filter((el) => Number(getComputedStyle(el).opacity) < 1).map((el) => el.className),
    );
    expect(faded).toEqual([]);
  });

  test("the 30-day analytics open on AG Studio once scrolled to", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await open(page, "?state=inbox&demo=1");
    const analytics = page.locator(".ops-ov-studio");
    await analytics.scrollIntoViewIfNeeded();
    await expect(analytics.getByRole("heading", { name: "Sales and money · last 30 days" })).toBeVisible();
    await expect(analytics.locator(".ops-studio-canvas, .ops-studio-off")).toBeVisible({ timeout: 30000 });
    await analytics.getByRole("button", { name: "In & out" }).click();
    await expect(analytics.getByRole("button", { name: "In & out" })).toHaveAttribute("aria-pressed", "true");
    await page.waitForTimeout(2500);
    await analytics.screenshot({ path: `${shots}/analytics-1440.png` });
  });
});
