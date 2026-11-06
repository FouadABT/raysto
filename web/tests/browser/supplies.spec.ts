import { expect, test, type Page } from "@playwright/test";
import { chooseSection } from "./workspace-navigation";

/**
 * The Supplies section (stream S3) on the development preview's fixtures
 * (src/lib/connected/supplies-preview.ts): no backend, no sign-in, and the
 * preview refuses every command, which the section must say plainly.
 */
const preview = "/ops/preview";
const shots = "test-results/supplies";

async function openSupplies(page: Page) {
  await page.goto(preview);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({
    timeout: 60000,
  });
  await chooseSection(page, "Supplies");
  await expect(page.locator(".ops-appbar h1")).toHaveText(
    /^(Supplies|Bills and stock)$/,
  );
  await expect(page.getByRole("tab", { name: "Inventory" })).toHaveAttribute(
    "aria-selected",
    "true",
  );
}

const tab = (page: Page, name: string) =>
  page
    .getByRole("tablist", { name: "Supplies" })
    .getByRole("tab", { name: new RegExp(`^${name}`) });

test.describe("Supplies", () => {
  // The shared dev server compiles the console on first visit.
  test.setTimeout(150000);

  test("Inventory: cover, low stock and the stock grid with words beside the colours", async ({
    page,
  }) => {
    await openSupplies(page);
    await expect(
      page.locator(".ops-kpi").filter({ hasText: "To reorder now" }),
    ).toBeVisible();
    await expect(
      page.getByText("Usage from the last 28 days of sales and waste."),
    ).toBeVisible();
    await page
      .getByText("Explore stock cover and value", { exact: true })
      .click();
    // AG Studio renders when this deployment has its licence; otherwise a plain notice says the grid has the figures.
    await expect(
      page.locator(".ops-studio-canvas, .ops-studio-off").first(),
    ).toBeVisible();
    const grid = page.getByRole("region", { name: "Stock" });
    await expect(grid.getByText("Flour T55")).toBeVisible();
    await expect(grid.getByText("Reorder now").first()).toBeVisible();
    await expect(grid.getByText("5.0 days", { exact: true })).toBeVisible();
    await page.screenshot({
      path: `${shots}/inventory-1440.png`,
      fullPage: true,
    });
  });

  test("Purchasing: the orders, a draft from the forecast, and an order's receipt", async ({
    page,
  }) => {
    await openSupplies(page);
    await tab(page, "Purchasing").click();
    await expect(
      page.getByRole("button", { name: "Ask the planner what to order" }),
    ).toBeVisible();
    const grid = page.getByRole("region", { name: "Purchase orders" });
    await expect(grid.getByText("PO-14")).toBeVisible();
    await expect(
      page.locator(".ops-sup-groups").getByText("Marché Dupont"),
    ).toBeVisible();
    // The preview sends nothing, and says so instead of pretending.
    await page
      .locator(".ops-sup-groups")
      .getByRole("button", { name: "Draft this order" })
      .first()
      .click();
    await expect(
      page.getByText("The preview does not send commands.").first(),
    ).toBeVisible();
    await grid.getByText("PO-14").click();
    await expect(
      page.getByRole("heading", { name: "PO-14 · Marché Dupont" }),
    ).toBeVisible();
    await expect(
      page.getByLabel("Flour T55: quantity arriving now, in kg"),
    ).toHaveValue("25");
    await expect(
      page.getByRole("button", { name: "Record what arrived" }),
    ).toBeVisible();
    await page.getByRole("button", { name: "Cancel the order" }).click();
    await expect(
      page.getByRole("button", { name: "Yes, cancel PO-14" }),
    ).toBeVisible();
    await page.getByRole("button", { name: "Keep it" }).click();
    await page.screenshot({
      path: `${shots}/purchasing-1440.png`,
      fullPage: true,
    });
  });

  test("Receive: the 3-way match shows each variance in words and colour", async ({
    page,
  }) => {
    await openSupplies(page);
    await tab(page, "Receive").click();
    await expect(
      page.getByRole("heading", { name: "Check a delivery against its order" }),
    ).toBeVisible();
    await expect(page.locator(".ops-sup-inline select")).toContainText("PO-14");
    const match = page.locator(".ops-sup-match");
    await expect(match.getByRole("heading")).toContainText("PO-12");
    await expect(match.getByText("Dearer")).toBeVisible();
    await expect(
      match.getByText("$23.50 instead of $22.00 a unit (+6.8%)."),
    ).toBeVisible();
    await expect(match.getByText(/Supplies agent:/)).toBeVisible();
    await page.screenshot({
      path: `${shots}/receive-1440.png`,
      fullPage: true,
    });
  });

  test("Suppliers, Recipes and Waste", async ({ page }) => {
    await openSupplies(page);
    await tab(page, "Suppliers").click();
    const suppliers = page.getByRole("region", { name: "Suppliers" });
    await expect(suppliers.getByText("Café Nord Roasters")).toBeVisible();
    await expect(suppliers.getByText("+6.8%")).toBeVisible();

    await tab(page, "Recipes").click();
    const recipes = page.getByRole("region", { name: "Recipes" });
    await recipes.getByText("Butter croissant").click();
    await expect(
      page.getByRole("heading", { name: "Butter croissant" }),
    ).toBeVisible();
    await expect(
      page.locator(".ops-sup-total").getByText(/Portion cost/),
    ).toBeVisible();
    const flour = page.getByLabel("Flour T55: quantity per portion in kg");
    await flour.fill("0.06");
    // An unsaved edit can be undone; nothing is lost silently.
    await expect(
      page.getByRole("button", { name: "Undo changes" }),
    ).toBeVisible();
    await page.getByRole("button", { name: "Undo changes" }).click();
    await expect(flour).toHaveValue("0.05");
    await expect(
      page.getByRole("button", { name: "Save the recipe" }),
    ).toBeDisabled();

    await tab(page, "Waste").click();
    await expect(
      page.getByRole("region", { name: "Waste log" }).getByText("Whole milk"),
    ).toBeVisible();
    await page
      .getByLabel("Item")
      .selectOption({ label: "Oranges (18 kg on hand)" });
    await page.getByLabel(/Quantity/).fill("2");
    await expect(page.getByText(/Worth about \$4\.20/)).toBeVisible();
  });

  for (const [name, width, height] of [
    ["390", 390, 844],
    ["320", 320, 800],
  ] as const) {
    test(`at ${name} px with reduced motion nothing scrolls sideways`, async ({
      page,
    }) => {
      await page.setViewportSize({ width, height });
      await page.emulateMedia({ reducedMotion: "reduce" });
      await openSupplies(page);
      for (const t of ["Inventory", "Purchasing", "Receive", "Waste"]) {
        await tab(page, t).click();
        await page.waitForTimeout(300);
        const overflow = await page.evaluate(
          () => document.documentElement.scrollWidth - window.innerWidth,
        );
        expect(overflow, `${t} at ${name} px`).toBeLessThanOrEqual(1);
      }
      await tab(page, "Receive").click();
      await page.screenshot({
        path: `${shots}/receive-${name}.png`,
        fullPage: true,
      });
    });
  }
});
