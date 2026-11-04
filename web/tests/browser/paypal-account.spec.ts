import { expect, test, type Page } from "@playwright/test";

/**
 * Money › PayPal account (stream S6) on the development preview: a café on
 * its own PayPal app with Invoicing switched off (`?state=paypal`), and the
 * partner path waiting for PayPal's approval. No backend; the preview
 * refuses every command, which must be said.
 */
const shots = "test-results/paypal-account";

async function open(page: Page, state = "paypal") {
  await page.goto(`/ops/preview?state=${state}`);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({ timeout: 60000 });
  const width = page.viewportSize()?.width ?? 1440;
  if (width < 840) {
    await page.getByRole("button", { name: "Open the console menu" }).click();
    await page.getByRole("dialog").getByRole("button", { name: "Money" }).click();
  } else {
    await page.locator(".ops-shell-side .ops-sections").getByRole("button", { name: "Money" }).click();
  }
  await page.getByRole("tablist", { name: "Back office" }).getByRole("tab", { name: "PayPal account" }).click();
}

test.describe("PayPal account", () => {
  test("own app: masked client, checklist, what to switch on, and the partner note", async ({ page }) => {
    await open(page);
    await expect(page.getByRole("heading", { name: /Your own PayPal app/ }).first()).toBeVisible();
    await expect(page.getByText("••••Q7xZ")).toBeVisible();
    const list = page.getByRole("list", { name: "What your PayPal app can do" });
    await expect(list.locator("li")).toHaveCount(6);
    await expect(list.locator('li[data-state="notEnabled"]')).toContainText("Invoicing");
    await expect(page.getByText(/Switch on Invoicing in your app/)).toBeVisible();
    await expect(page.getByText(/Needs PayPal's partner approval for Raysto/)).toBeVisible();
    // The secret field is a password field and starts empty; saving waits for valid keys.
    const secret = page.getByLabel("Secret");
    await expect(secret).toHaveAttribute("type", "password");
    await expect(secret).toHaveValue("");
    await expect(page.getByRole("button", { name: /Save and check with PayPal/ })).toBeDisabled();
    await page.getByRole("button", { name: /Check again/ }).click();
    await expect(page.getByText("The preview does not send commands.").first()).toBeVisible();
    await page.screenshot({ path: `${shots}/own-app-1440.png`, fullPage: true });
  });

  test("a 320 px phone shows the shared Sandbox account without sideways scrolling", async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 800 });
    await open(page, "empty");
    await expect(page.getByRole("heading", { name: /Raysto's shared Sandbox account/ })).toBeVisible();
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    expect(overflow).toBeLessThanOrEqual(1);
    await page.screenshot({ path: `${shots}/shared-320.png`, fullPage: true });
  });
});
