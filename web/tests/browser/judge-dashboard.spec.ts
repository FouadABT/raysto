import { expect, test } from "@playwright/test";
test.beforeEach(() =>
  test.skip(
    process.env.RAYSTO_FINANCE_017_E2E !== "on",
    "Frozen UI fixtures; not provider acceptance.",
  ),
);
test("a clear summary leads to the complete dish and keeps advanced reports available", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=overview&demo=1");
  const start = page.getByRole("region", {
    name: "Start a cost investigation",
  });
  await expect(
    start.getByRole("heading", {
      name: "A supplier cost rose. What should change?",
    }),
  ).toBeVisible();
  await expect(
    start.getByRole("button", { name: "Start the investigation" }),
  ).toBeEnabled();
  await expect(
    page.getByRole("heading", { name: "AI Action Inbox" }),
  ).toHaveCount(0);
  await expect(page.locator(".ops-ov-studio")).toHaveCount(0);
  const summary = page.getByRole("region", { name: "Café summary" });
  await expect(summary).toContainText("$195.30");
  await page.getByRole("button", { name: "Today", exact: true }).last().click();
  await expect(summary).toContainText("$21.50");
  await start.getByRole("button", { name: "Start the investigation" }).click();
  expect(Object.fromEntries(new URL(page.url()).searchParams)).toMatchObject({
    section: "finance",
    tab: "evidence",
    product: "171",
    guided: "1",
  });
  await expect(
    page.getByRole("heading", { name: "The cost behind this dish" }),
  ).toBeVisible();
  await expect(
    page.getByRole("table", { name: /Ingredient evidence/ }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Compare price options", exact: true })
    .click();
  await expect(page.getByLabel("Assumed baseline units")).toBeVisible();
});
test("detailed tools and financial definitions remain explicit, recoverable views", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=overview");
  await page.getByRole("button", { name: "About these figures" }).click();
  await expect(
    page.getByRole("region", { name: "Financial definitions" }),
  ).toContainText("not recognized net sales or profit");
  await page
    .getByRole("button", { name: "Open detailed reports & AI tools" })
    .click();
  await expect(
    page.getByRole("heading", { name: "AI Action Inbox" }),
  ).toBeVisible();
  await expect(page).toHaveURL(/view=details/);
  await page.reload();
  await expect(
    page.getByRole("heading", { name: "AI Action Inbox" }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Back to café overview" }).click();
  await expect(page.locator(".jr-welcome")).toBeVisible();
  await expect(
    page.getByRole("heading", { name: "AI Action Inbox" }),
  ).toHaveCount(0);
});
test("saved assumptions are disclosed before editing and unsaved changes retain their guard", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=finance&tab=compare&product=171");
  await page.getByText("Resume a saved comparison", { exact: true }).click();
  await page.getByRole("button", { name: /Revision 1 · expires/ }).click();
  await expect(
    page.getByRole("heading", { name: /Lowest qualifying price/ }),
  ).toBeVisible();
  await expect(page.getByLabel("Assumed baseline units")).toBeHidden();
  await page
    .getByText("Adjust the comparison assumptions", { exact: true })
    .click();
  await expect(page.getByLabel("Assumed baseline units")).toHaveValue("100");
  await page
    .getByText("Price limits & a price of your own", { exact: true })
    .click();
  await page.getByLabel("Increase limit (%)", { exact: true }).fill("5");
  await page.getByRole("button", { name: "02 Cost evidence" }).click();
  await expect(
    page.getByRole("dialog", { name: "Discard these changes?" }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Keep editing", exact: true }).click();
  await expect(
    page.getByLabel("Increase limit (%)", { exact: true }),
  ).toHaveValue("5");
  await page
    .getByRole("button", { name: "Cancel input changes", exact: true })
    .click();
  await page
    .getByRole("button", { name: "Discard changes", exact: true })
    .click();
  await expect(
    page.getByRole("heading", { name: /Lowest qualifying price/ }),
  ).toBeVisible();
});
for (const width of [1440, 1024, 768, 390, 320])
  test(
    "summary contains charts and primary controls at " + width + "px",
    async ({ page }) => {
      await page.setViewportSize({ width, height: 1000 });
      await page.emulateMedia({ reducedMotion: "reduce" });
      await page.goto("/ops/preview?section=overview&demo=1");
      await expect(
        page.getByRole("region", { name: "Café summary" }),
      ).toContainText("$195.30");
      await page.evaluate(() => document.fonts.ready);
      expect(
        await page.evaluate(
          () => document.documentElement.scrollWidth <= innerWidth + 1,
        ),
      ).toBe(true);
      const primary = page.getByRole("button", {
        name: "Start the investigation",
      });
      expect((await primary.boundingBox())!.height).toBeGreaterThanOrEqual(48);
      for (const button of await page
        .getByRole("group", { name: "Period" })
        .getByRole("button")
        .all())
        expect((await button.boundingBox())!.height).toBeGreaterThanOrEqual(48);
      await page.locator(".jr-sales [tabindex]").first().focus();
      await page.keyboard.press("ArrowRight");
      await page.screenshot({
        path: "test-results/judge-dashboard/" + width + ".png",
        fullPage: true,
      });
    },
  );
test("unavailable figures remain unknown while dish evidence is still usable", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=overview&state=failed");
  await expect(
    page
      .getByRole("alert")
      .filter({ hasText: "The café figures are unavailable" }),
  ).toContainText("The café figures are unavailable");
  await expect(page.getByRole("region", { name: "Café summary" })).toHaveCount(
    0,
  );
  await expect(
    page.getByRole("button", { name: "Start the investigation" }),
  ).toBeEnabled();
});
