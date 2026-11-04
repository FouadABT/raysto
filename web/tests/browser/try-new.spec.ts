import { expect, test, type Page } from "@playwright/test";

/**
 * Try cards 10–14 on their development fixture (/ops/kit/try-new): the
 * shapes the 0.16 backend answers, with ids that say PREVIEW. Nothing here
 * reaches PayPal. `?state=missing` is a deployment without the commands.
 */
const fixture = "/ops/kit/try-new";
const shots = "test-results/try-new";

async function open(page: Page, query = "") {
  await page.goto(fixture + query);
  await expect(page.getByText("NEW IN 0.16 · FIVE MORE DEMOS, THE BACK OFFICE")).toBeVisible({ timeout: 60000 });
}
const card = (page: Page, title: string) =>
  page.locator("article.ops-try-card").filter({ has: page.getByRole("heading", { name: title, exact: true }) });

test.describe("Try cards 10–14", () => {
  test("10: the accountant reads the bill and PayPal Payouts pays it only after approval", async ({ page }) => {
    await open(page);
    const c = card(page, "Pay a bill with PayPal");
    await expect(c.getByRole("img", { name: /Sample electricity bill/ })).toBeVisible();
    await c.getByRole("button", { name: "Read this bill" }).click();
    await expect(c.getByText("Hudson Power & Light · Sample · Electricity · Review")).toBeVisible();
    await expect(c.getByText("Read with 94% confidence")).toBeVisible();
    await expect(c.getByText(/takes PayPal: bu…@personal\.example\.com \(Sandbox\)/)).toBeVisible();
    // Nothing is paid before the approval.
    await expect(c.locator(".ops-try-done")).toHaveCount(0);
    await c.getByRole("button", { name: "Approve (identity check)" }).click();
    await expect(c.getByText(/Sent with PayPal Payouts to the vendor's PayPal account/)).toBeVisible();
    await expect(c.getByText("PayPal payout batch PREVIEWBATCH01")).toBeVisible();
    await expect(c.getByText(/Paid with PayPal Payouts, batch PREVIEWBATCH01 \(Sandbox\)/)).toBeVisible();
  });

  test("11: the month's books, VAT and the flagged capture with its PayPal id", async ({ page }) => {
    await open(page);
    const c = card(page, "The accountant's month");
    await c.getByRole("button", { name: "Read this month" }).click();
    await expect(c.getByText(/Sales and other income \$1,284\.50, costs \$2,025\.50/)).toBeVisible();
    await expect(c.getByRole("cell", { name: "6110 Rent" })).toBeVisible();
    await expect(c.getByText(/VAT collected \$0\.00, paid on bills \$13\.10/)).toBeVisible();
    await expect(c.getByText("A capture with no order")).toBeVisible();
    await expect(c.getByText("PayPal capture PREVIEWCAPTURE1")).toBeVisible();
    await expect(c.getByText(/sales cover every bill/)).toBeVisible();
    await expect(c.getByText("PayPal fees estimated where PayPal did not report them")).toBeVisible();
  });

  test("12: a pay link with its QR code, marked paid only when PayPal's capture arrives", async ({ page }) => {
    await open(page);
    const c = card(page, "Ask a customer to pay");
    await c.getByRole("button", { name: "Make a $35.55 pay link" }).click();
    const link = c.getByRole("link", { name: "Open the pay link" });
    await expect(link).toHaveAttribute("href", "https://api.rays.to/pay/preview-token");
    await expect(link).toHaveAttribute("target", "_blank");
    await expect(c.locator("svg title", { hasText: "QR code for this pay link" })).toHaveCount(1);
    await expect(c.getByText("Studio Lumen · Sample · Open")).toBeVisible();
    await expect(c.getByText(/Paid in PayPal Sandbox, capture PREVIEWCAPTURE2/)).toBeVisible({ timeout: 15000 });
    await expect(link).toHaveCount(0);
  });

  test("13: a simulator order, the dispatcher's ranking, the offer and the signed webhooks", async ({ page }) => {
    await page.route("**/api/partner-sim/orders", (route) => route.fulfill({ json: { data: { ref: "sim-42" } } }));
    await open(page);
    const c = card(page, "Dispatch a delivery");
    await c.getByRole("button", { name: "Send a partner order" }).click();
    await expect(c.getByText("Order #A12 · Demo Delivery Co. (simulator) (simulator)")).toHaveCount(0);
    await expect(c.getByText(/Order #A12 · Demo Delivery Co\. \(simulator\)/)).toBeVisible();
    await expect(c.getByText("Sam · Sample · bike")).toBeVisible();
    await expect(c.getByText(/Distances are straight lines × 1\.3/)).toBeVisible();
    await c.getByRole("button", { name: "Approve", exact: true }).click();
    await expect(c.getByText(/Offered to the driver/)).toBeVisible();
    await expect(c.getByText("Signed webhook to the partner: order.accepted · delivered (HTTP 200)")).toBeVisible();
    await expect(c.getByText("Received from the partner: orders.create · accepted (HTTP 201)")).toBeVisible();
  });

  test("13: without the simulator the card says so and uses the waiting delivery", async ({ page }) => {
    await page.route("**/api/partner-sim/orders", (route) => route.fulfill({ status: 404, body: "" }));
    await open(page);
    const c = card(page, "Dispatch a delivery");
    await c.getByRole("button", { name: "Send a partner order" }).click();
    await expect(c.getByText(/The delivery simulator is not on this deployment yet\. This card uses the newest delivery/)).toBeVisible();
    await expect(c.getByText("Sam · Sample · bike")).toBeVisible();
  });

  test("14: the forecast, the proposed order and the 3-way match with the butter's price", async ({ page }) => {
    await open(page);
    const c = card(page, "Never run out");
    await c.getByRole("button", { name: "Plan this week's order" }).click();
    await expect(c.getByText("reorder 4.5 kg")).toBeVisible();
    await expect(c.getByText("Proposed order · Marché Dupont")).toBeVisible();
    await expect(c.getByText("usage from 28 days of orders × recipes")).toBeVisible();
    await expect(c.getByText("price +6.1%")).toBeVisible();
    await expect(c.getByText(/the supplier's bill says \$143\.00, \$6\.00 more than ordered/)).toBeVisible();
    await c.getByRole("button", { name: "Approve", exact: true }).click();
    await expect(c.getByText(/Saved as a purchase order/)).toBeVisible();
  });

  test("on a deployment without the 0.16 commands every card says so, and nothing reads as done", async ({ page }) => {
    await page.route("**/api/partner-sim/orders", (route) => route.fulfill({ status: 404, body: "" }));
    await open(page, "?state=missing");
    const expected: [string, string, RegExp][] = [
      ["Pay a bill with PayPal", "Read this bill", /Reading bills is not available on this deployment yet/],
      ["The accountant's month", "Read this month", /The profit and loss is not available on this deployment yet/],
      ["Ask a customer to pay", "Make a $35.55 pay link", /Making pay links is not available on this deployment yet/],
      ["Dispatch a delivery", "Send a partner order", /Dispatch is not available on this deployment yet/],
      ["Never run out", "Plan this week's order", /The stock forecast is not available on this deployment yet/],
    ];
    for (const [title, button, error] of expected) {
      const c = card(page, title);
      await c.getByRole("button", { name: button }).click();
      await expect(c.getByRole("alert")).toHaveText(error);
    }
    await expect(page.locator(".ops-try-done")).toHaveCount(0);
  });

  for (const [name, width, height] of [
    ["1440", 1440, 1000],
    ["390", 390, 844],
  ] as const) {
    test(`all five run without a page error at ${name} px, reduced motion`, async ({ page }) => {
      const errors: string[] = [];
      page.on("pageerror", (e) => errors.push(e.message));
      await page.route("**/api/partner-sim/orders", (route) => route.fulfill({ json: { data: { ref: "sim-42" } } }));
      await page.setViewportSize({ width, height });
      await page.emulateMedia({ reducedMotion: "reduce" });
      await open(page);
      for (const [title, button] of [
        ["Pay a bill with PayPal", "Read this bill"],
        ["The accountant's month", "Read this month"],
        ["Ask a customer to pay", "Make a $35.55 pay link"],
        ["Dispatch a delivery", "Send a partner order"],
        ["Never run out", "Plan this week's order"],
      ] as const) {
        const c = card(page, title);
        await c.getByRole("button", { name: button }).click();
        await expect(c.locator(".ops-try-result")).toBeVisible();
      }
      await expect(card(page, "Ask a customer to pay").getByText(/Paid in PayPal Sandbox/)).toBeVisible({ timeout: 15000 });
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      expect(overflow).toBeLessThanOrEqual(0);
      await page.screenshot({ path: `${shots}/cards-${name}.png`, fullPage: true });
      expect(errors).toEqual([]);
    });
  }
});
