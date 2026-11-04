import { expect, test, type Page } from "@playwright/test";

/**
 * The Accountant section (stream S1) on the development preview's labelled
 * sample books (src/lib/connected/accountant-preview.ts): no backend, no
 * sign-in, and the preview refuses every command, which must be said.
 */
const preview = "/ops/preview";
const shots = "test-results/accountant";

async function openAccountant(page: Page) {
  await page.goto(preview);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({ timeout: 60000 });
  const width = page.viewportSize()?.width ?? 1440;
  if (width < 840) {
    await page.getByRole("button", { name: "Open the console menu" }).click();
    await page.getByRole("dialog").getByRole("button", { name: "Accountant" }).click();
  } else {
    await page.locator(".ops-shell-side .ops-sections").getByRole("button", { name: "Accountant" }).click();
  }
  await expect(page.locator(".ops-appbar h1")).toHaveText("Accountant");
}

const tab = (page: Page, name: string) => page.getByRole("tablist", { name: "Accountant" }).getByRole("tab", { name: new RegExp(`^${name}`) });

test.describe("Accountant", () => {
  test("Overview: the figures, the rules' findings and a way to each", async ({ page }) => {
    await openAccountant(page);
    await expect(tab(page, "Overview")).toHaveAttribute("aria-selected", "true");
    await expect(page.locator(".ops-kpi").filter({ hasText: "Owed to you" })).toContainText("$120.00");
    const findings = page.getByRole("region", { name: "What needs attention" });
    await expect(findings.getByText("City Water 42.00 USD was due 3 day(s) ago.")).toBeVisible();
    await expect(findings.getByText("Needs you today")).toBeVisible();
    await page.getByRole("button", { name: "Ask the accountant to review the month" }).click();
    await expect(page.getByText("The preview does not send commands.").first()).toBeVisible();
    await findings.getByRole("button", { name: /Open Bills/ }).first().click();
    await expect(tab(page, "Bills")).toHaveAttribute("aria-selected", "true");
    await page.screenshot({ path: `${shots}/overview-1440.png`, fullPage: true });
  });

  test("Bills: the drop zone, PayPal ids and proofs, and a bill's detail with its next step", async ({ page }) => {
    await openAccountant(page);
    await tab(page, "Bills").click();
    await expect(page.getByRole("button", { name: /Drop a bill here/ })).toBeVisible();
    const grid = page.getByRole("region", { name: "Bills" });
    await expect(grid.getByText("PayPal Payouts SAMPLE-BATCH-1 · item SAMPLE-ITEM-1 · completed")).toBeVisible();
    await expect(grid.getByText("Paid elsewhere · proof #77")).toBeVisible();
    await expect(grid.getByText("Overdue").first()).toBeVisible();
    await grid.getByText("Power Co").click();
    const detail = page.locator("#acc-bill-detail");
    await expect(detail.getByRole("heading", { name: "Power Co: $196.10" })).toBeVisible();
    await expect(detail.getByText(/8% above September/)).toBeVisible();
    await expect(detail.getByRole("button", { name: /Pay \$196.10 via PayPal \(identity check\)/ })).toBeVisible();
    await detail.getByRole("button", { name: "Paid elsewhere…" }).click();
    await expect(detail.getByRole("button", { name: /Drop the proof of payment/ })).toBeVisible();
    await page.getByRole("button", { name: "Enter a bill by hand" }).click();
    await expect(page.getByLabel(/Vendor's PayPal email/)).toBeVisible();
    await page.screenshot({ path: `${shots}/bills-1440.png`, fullPage: true });
  });

  test("Requests: a pay link's QR code and the PayPal capture of a paid one", async ({ page }) => {
    await openAccountant(page);
    await tab(page, "Requests").click();
    const grid = page.getByRole("region", { name: "Payment requests" });
    await expect(grid.getByText("SAMPLE-CAPTURE-6")).toBeVisible();
    await grid.getByText("Acme Offices").click();
    await expect(page.getByRole("img", { name: "Pay $120.00 with PayPal" })).toBeVisible();
    await expect(page.getByText("https://api.rays.to/pay/0123456789abcdef0123456789abcdef")).toBeVisible();
    await expect(page.getByRole("button", { name: "Remind" })).toBeVisible();
    // A new request is checked before anything is sent.
    await page.getByLabel("Who pays").fill("Lina");
    await page.getByLabel("For").fill("Cake order");
    await page.getByLabel(/^Amount/).fill("12.345");
    await page.getByRole("button", { name: "Create the pay link" }).click();
    await expect(page.getByText("Use at most two decimals.")).toBeVisible();
    await page.screenshot({ path: `${shots}/requests-1440.png`, fullPage: true });
  });

  test("P&L, cash flow, aging and VAT render with their plain grids", async ({ page }) => {
    await openAccountant(page);
    await tab(page, "P&L").click();
    await expect(page.locator(".ops-kpi").filter({ hasText: "Profit" })).toContainText("$3,498.10");
    await expect(page.getByText(/PayPal fees are estimates/)).toBeVisible();
    await expect(page.locator(".ops-studio-canvas, .ops-studio-off").first()).toBeVisible();
    await expect(page.getByRole("region", { name: "Profit and loss lines" }).getByText("6110 Rent")).toBeVisible();
    await tab(page, "Cash flow").click();
    await expect(page.getByText(/An estimate, not a promise/)).toBeVisible();
    await expect(page.getByRole("region", { name: "Bills due in the next 30 days" }).getByText("Monthly, expected")).toBeVisible();
    await page.screenshot({ path: `${shots}/cash-1440.png`, fullPage: true });
    await tab(page, "Payables aging").click();
    await expect(page.locator(".ops-kpi").filter({ hasText: "31–60 days" })).toContainText("$42.00");
    await tab(page, "VAT").click();
    await expect(page.getByText("Tax rate 10.00%.", { exact: false })).toBeVisible();
    await expect(page.locator(".ops-kpi").filter({ hasText: "Due" })).toContainText("$751.90");
  });

  test("a 320 px phone at twice the text size keeps every figure and action", async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 800 });
    await openAccountant(page);
    await page.evaluate(() => (document.documentElement.style.fontSize = "200%"));
    await tab(page, "Bills").click();
    await page.getByRole("region", { name: "Bills" }).getByText("Power Co").click();
    await expect(page.locator("#acc-bill-detail").getByRole("button", { name: /via PayPal/ })).toBeVisible();
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    expect(overflow).toBeLessThanOrEqual(1);
    await page.screenshot({ path: `${shots}/bills-320-2x.png`, fullPage: true });
  });
});
