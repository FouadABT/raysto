import { expect, test, type Page } from "@playwright/test";
import { chooseSection } from "./workspace-navigation";

/**
 * The franchise view (stream S4) on the development preview's sample group
 * (`/ops/preview?state=group`, src/lib/connected/group-preview.ts): the group
 * switcher, the Group section's AG Studio pages with no watermark and no
 * licence error, and the shared grid's totals row following its search.
 */
const preview = "/ops/preview?state=group";
const shots = "test-results/group";

/** AG Studio and AG Grid print licence problems to the console. */
const licenceTrouble =
  /License Key Not Found|Invalid License|License Expired|has expired|watermark/i;

async function openGroup(page: Page, problems: string[]) {
  page.on("console", (m) => {
    if (licenceTrouble.test(m.text())) problems.push(m.text());
  });
  page.on("pageerror", (e) => problems.push(String(e)));
  await page.goto(preview);
  await expect(page.locator(".jr-welcome")).toBeVisible({
    timeout: 60000,
  });
  await chooseSection(page, "Group");
  await expect(
    page.getByRole("heading", { name: "Atelier Group · Sample" }),
  ).toBeVisible();
}

test.describe("Group", () => {
  test("the switcher below the primary navigation narrows it to the group's venues", async ({
    page,
  }) => {
    await page.goto(preview);
    await expect(page.locator(".jr-welcome")).toBeVisible({
      timeout: 60000,
    });
    const side = page.locator(".ops-shell-side");
    const groupSelect = side.getByLabel("Group", { exact: true });
    const venueSelect = side.getByLabel("Restaurant", { exact: true });
    await side.getByText("Group workspace", { exact: true }).click();
    await expect(groupSelect).toBeVisible();
    // The switcher sits below the primary navigation.
    const g = await groupSelect.boundingBox();
    const v = await venueSelect.boundingBox();
    expect(g && v && g.y > v.y).toBeTruthy();
    await expect(venueSelect.locator("option")).toHaveCount(3);
    await groupSelect.selectOption({ label: "Atelier Group · Sample" });
    await expect(venueSelect.locator("option")).toHaveCount(2);
    await expect(
      venueSelect.locator("option", { hasText: "Corner Deli" }),
    ).toHaveCount(0);
    await expect(side.getByText("2 venues · you are its owner")).toBeVisible();
    await groupSelect.selectOption({ label: "All my restaurants" });
    await expect(venueSelect.locator("option")).toHaveCount(3);
  });

  test("Studio pages, with no watermark and no licence error; money stays per currency", async ({
    page,
  }) => {
    const problems: string[] = [];
    await openGroup(page, problems);
    await expect(
      page.getByRole("note").filter({
        hasText:
          "share one Sandbox merchant; in production each connects its own PayPal.",
      }),
    ).toBeVisible();
    // Two currencies, two totals: a dollar is never added to a euro.
    await expect(
      page.locator(".ops-kpi").filter({ hasText: "Paid sales · EUR" }),
    ).toContainText("€964.00");
    await expect(
      page.locator(".ops-kpi").filter({ hasText: "Paid sales · USD" }),
    ).toContainText("$1,842.50");
    const studio = page.locator(".ops-studio-canvas, .ops-studio-off").first();
    await expect(studio).toBeVisible();
    const live = await page.locator(".ops-studio-canvas").count();
    if (live) {
      // Studio always mounts its watermark element and hides it when the licence is good.
      const marks = page.locator(".ops-studio-canvas .ag-studio-watermark");
      for (let i = 0; i < (await marks.count()); i++)
        await expect(marks.nth(i)).toBeHidden();
      await expect(
        page
          .locator(".ops-studio-canvas .ag-studio-watermark-text")
          .filter({ hasText: /\S/ }),
      ).toHaveCount(0);
      await expect(
        page
          .getByRole("group", { name: "Currency" })
          .getByRole("button", { name: "EUR" }),
      ).toBeVisible();
    }
    const pages = page.getByRole("tablist", { name: "Group pages" });
    await pages.getByRole("tab", { name: "Compare venues" }).click();
    await expect(
      page.getByRole("region", { name: "Sales by venue and day" }),
    ).toBeVisible();
    await pages.getByRole("tab", { name: "Money" }).click();
    const bills = page.getByRole("region", { name: "Bills to pay" });
    await expect(bills.getByText("Brussels Power")).toBeVisible();
    await expect(bills.getByText("0–30 days").first()).toBeVisible();
    await expect(
      page
        .getByRole("region", { name: "Journal lines" })
        .getByText("Electricity")
        .first(),
    ).toBeVisible();
    await pages.getByRole("tab", { name: "Portfolio" }).click();
    await page.waitForTimeout(1500);
    await page.screenshot({
      path: `${shots}/portfolio-1440.png`,
      fullPage: true,
    });
    expect(problems, problems.join("\n")).toEqual([]);
  });

  test("the totals row follows the quick search", async ({ page }) => {
    const problems: string[] = [];
    await openGroup(page, problems);
    const grid = page.getByRole("region", { name: "Venues" });
    const totals = grid.locator(".ag-row-pinned");
    await expect(totals).toContainText("Total of 2 rows");
    await expect(totals).toContainText("€964.00 · $1,842.50");
    await page
      .getByRole("searchbox", { name: "Search venues" })
      .fill("Harbour");
    await expect(totals).toContainText("Total of 1 row");
    await expect(totals).toContainText("€964.00");
    await expect(totals).not.toContainText("$");
    await expect(page.locator(".ops-grid-count").first()).toHaveText("1 of 2");
    await page
      .getByRole("searchbox", { name: "Search venues" })
      .fill("nothing like this");
    await expect(
      page
        .getByRole("status")
        .filter({ hasText: "Nothing matches “nothing like this”." }),
    ).toBeVisible();
    // The money reads right-aligned, in tabular figures.
    await page.getByRole("searchbox", { name: "Search venues" }).fill("");
    const cell = grid
      .locator('[role="gridcell"][col-id="paidSalesMinor"]')
      .first();
    await expect(cell).toHaveClass(/ag-right-aligned-cell/);
    await expect(cell).toHaveCSS("font-variant-numeric", "tabular-nums");
    // The export button is there for every grid that names a file.
    await expect(
      page.getByRole("button", { name: "CSV" }).first(),
    ).toBeEnabled();
  });

  test("templates and transfers say plainly that the preview sends nothing", async ({
    page,
  }) => {
    const problems: string[] = [];
    await openGroup(page, problems);
    const pages = page.getByRole("tablist", { name: "Group pages" });
    await pages.getByRole("tab", { name: "Menu templates" }).click();
    await expect(page.getByText("Winter specials")).toBeVisible();
    await page.getByRole("button", { name: "Push to every venue" }).click();
    await expect(
      page.getByText("The preview does not send commands.").first(),
    ).toBeVisible();
    await pages.getByRole("tab", { name: "Stock transfers" }).click();
    await expect(
      page.getByRole("heading", { name: /Move stock from Atelier Café/ }),
    ).toBeVisible();
  });
});

test("empty ledger data leaves Group Studio usable without a schema error", async ({
  page,
}) => {
  const problems: string[] = [];
  page.on("console", (m) => {
    if (
      m.type() === "error" &&
      /Fatal error|no fields|does not exist in the schema/.test(m.text())
    )
      problems.push(m.text());
  });
  await page.goto("/ops/preview?section=group&state=group&emptyLedger=1");
  await expect(
    page.getByRole("heading", { name: "Atelier Group · Sample", exact: true }),
  ).toBeVisible();
  await expect(
    page.getByRole("region", { name: "Atelier Group · Sample: Portfolio" }),
  ).toBeVisible({ timeout: 30000 });
  await page.getByRole("tab", { name: "Money", exact: true }).click();
  await expect(
    page.getByText(
      "No revenue or cost entries are available for this currency and period. No operating result is shown.",
      { exact: true },
    ),
  ).toBeVisible();
  await expect(
    page.getByRole("region", { name: "Atelier Group · Sample: Money" }),
  ).toHaveCount(0);
  expect(problems).toEqual([]);
});

test("an empty accountant view explains missing rows without a Studio schema error", async ({
  page,
}) => {
  const errors: string[] = [];
  page.on("console", (m) => {
    if (
      m.type() === "error" &&
      /Fatal error|no fields|does not exist in the schema/.test(m.text())
    )
      errors.push(m.text());
  });
  await page.goto("/ops/preview?section=accountant&tab=pnl&emptyBooks=1");
  await expect(
    page.getByText(
      "No analytical rows are available for this view yet. Check the selected period and source records.",
      { exact: true },
    ),
  ).toBeVisible({ timeout: 30000 });
  expect(errors).toEqual([]);
});
