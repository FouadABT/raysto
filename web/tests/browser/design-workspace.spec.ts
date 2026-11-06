import { expect, test } from "@playwright/test";
import { writeFile } from "node:fs/promises";

test.beforeEach(() =>
  test.skip(
    process.env.RAYSTO_FINANCE_017_E2E !== "on",
    "Opt-in design candidate on frozen UI fixtures; not provider acceptance.",
  ),
);
const sections = [
  ["overview", "Today"],
  ["finance", "Sales and margins"],
  ["supplies", "Bills and stock"],
  ["team", "Team"],
  ["money", "Money"],
  ["orders", "Orders"],
  ["payments", "Payments"],
  ["agents", "Agents"],
  ["accountant", "Accountant"],
  ["dispatch", "Dispatch"],
  ["group", "Group"],
  ["floor", "Floor"],
] as const;
for (const width of [1440, 320])
  test(`all owner destinations reflow at ${width}px`, async ({ page }) => {
    test.setTimeout(240000);
    await page.setViewportSize({ width, height: 900 });
    for (const [section, title] of sections) {
      await page.goto(
        `/ops/preview?section=${section}${section === "group" ? "&state=group" : ""}`,
      );
      await expect(
        page.getByRole("heading", { name: title, exact: true, level: 1 }),
      ).toBeVisible({ timeout: 60000 });
      await expect
        .poll(() =>
          page.evaluate(() => ({
            width: innerWidth,
            scroll: document.documentElement.scrollWidth,
          })),
        )
        .toMatchObject({ width });
      const overflow = await page.evaluate(
        () => document.documentElement.scrollWidth > innerWidth + 1,
      );
      expect(
        overflow,
        `${title} must contain its two-dimensional content`,
      ).toBe(false);
      await page.screenshot({
        path: `test-results/design/${width}-${section}.png`,
        fullPage: true,
      });
    }
  });

test("navigation, refresh, Back and draft recovery preserve the approved context", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=finance&tab=compare&product=171");
  await page.getByLabel("Assumed baseline units").fill("123");
  await page.getByRole("button", { name: "02 Cost evidence" }).click();
  await expect(
    page.getByRole("dialog", { name: "Discard these changes?" }),
  ).toBeVisible();
  await page.getByRole("button", { name: "Keep editing", exact: true }).click();
  await expect(page).toHaveURL(/tab=compare/);
  await expect(page.getByLabel("Assumed baseline units")).toHaveValue("123");
  await page.getByRole("button", { name: "02 Cost evidence" }).click();
  await page
    .getByRole("button", { name: "Discard changes", exact: true })
    .click();
  await expect(
    page.getByRole("table", { name: /Ingredient evidence/ }),
  ).toBeVisible();
  await page.getByRole("button", { name: "03 Compare options" }).click();
  await expect(page.getByLabel("Assumed baseline units")).toHaveValue("");
  await page.goBack();
  await expect(
    page.getByRole("table", { name: /Ingredient evidence/ }),
  ).toBeVisible();
  await page.reload();
  await expect(
    page.getByRole("table", { name: /Ingredient evidence/ }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Bills and stock", exact: true })
    .click();
  await page.getByRole("tab", { name: "Bills", exact: true }).click();
  await expect(page).toHaveURL(/section=supplies.*tab=bills/);
  await page.reload();
  await expect(
    page.getByRole("tab", { name: "Bills", exact: true }),
  ).toHaveAttribute("aria-selected", "true");
});

test("a report failure leaves costing usable and loading does not imply zero", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=finance&state=slow-costs");
  await expect(
    page.getByRole("status", { name: "Loading dish costs" }),
  ).toBeVisible();
  await expect(page.getByLabel("Inspect a dish")).toBeVisible();
  await page.goto("/ops/preview?section=finance&state=finance-unavailable");
  await expect(
    page.getByText("Financial summary could not refresh.", { exact: false }),
  ).toBeVisible();
  await expect(page.getByLabel("Inspect a dish")).toBeVisible();
  await expect(
    page.getByRole("button", { name: "Retry records" }),
  ).toBeEnabled();
});

test("inventory analysis agrees with its loaded rows and starts without editor panels", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=supplies");
  await page
    .getByText("Explore stock cover and value", { exact: true })
    .click();
  const studio = page.getByRole("region", {
    name: "Supplies: stock cover and value",
  });
  await expect(studio.getByText("258.90", { exact: true })).toBeVisible({
    timeout: 30000,
  });
  await expect(studio.getByText("Reorder now", { exact: true })).toBeVisible();
  await expect(
    page.getByRole("searchbox", { name: "Search stock" }),
  ).toBeVisible();
});

test("non-finance form drafts are guarded on navigation and modal dismissal", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=team");
  await page
    .getByRole("button", { name: /Add a shift|New shift/ })
    .first()
    .click();
  await page.getByLabel("Name", { exact: true }).fill("Draft person");
  await page.getByRole("button", { name: "Close", exact: true }).click();
  await page.getByRole("button", { name: "Keep editing", exact: true }).click();
  await expect(page.getByLabel("Name", { exact: true })).toHaveValue(
    "Draft person",
  );
  await page.getByRole("button", { name: "Cancel", exact: true }).click();
  await page
    .getByRole("button", { name: "Discard changes", exact: true })
    .click();
  await expect(page.getByLabel("Name", { exact: true })).toHaveCount(0);
});

test("guided entry places the useful control in view and keyboard focus returns from evidence", async ({
  page,
}) => {
  await page.goto("/ops/preview?section=finance");
  await page.getByRole("button", { name: "Investigate a cost change" }).click();
  const guide = page.getByRole("region", { name: "One dish setup" });
  await expect(guide).toBeFocused();
  expect(
    await guide.evaluate((e) => e.getBoundingClientRect().top),
  ).toBeLessThan(200);
  await page.getByRole("button", { name: "Review recipe inputs" }).click();
  await expect(page.getByLabel("Quantity per portion")).toBeVisible();
  await page.getByRole("button", { name: "Cancel", exact: true }).click();
  const receipt = page.getByRole("button", {
    name: "Inspect receipt",
    exact: true,
  });
  await receipt.click();
  await page
    .getByRole("dialog", { name: "Confirmed receipt evidence" })
    .press("Escape");
  await expect(receipt).toBeFocused();
});

test("synthetic workload keeps interaction feedback measurable and contains enlarged text", async ({
  page,
}) => {
  await page.addInitScript(() => {
    const data = { longTasks: [] as number[], inputFrames: [] as number[] };
    (window as unknown as { raystoMetrics: typeof data }).raystoMetrics = data;
    new PerformanceObserver((list) => {
      for (const entry of list.getEntries())
        data.longTasks.push(entry.duration);
    }).observe({ type: "longtask", buffered: true });
    document.addEventListener("input", () => {
      const start = performance.now();
      requestAnimationFrame(() =>
        data.inputFrames.push(performance.now() - start),
      );
    });
  });
  await page.goto("/ops/kit/decision");
  await expect(page.getByRole("grid")).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await page.evaluate(() => {
    const d = (
      window as unknown as {
        raystoMetrics: { longTasks: number[]; inputFrames: number[] };
      }
    ).raystoMetrics;
    d.longTasks = [];
    d.inputFrames = [];
  });
  await page.getByLabel("Find a sample dish").fill("Sample dish 49");
  await expect(
    page.getByText("11 of 500 synthetic records", { exact: false }),
  ).toBeVisible();
  await page.getByLabel("Synthetic dataset").selectOption("1000");
  await expect(
    page.getByText("11 of 1000 synthetic records", { exact: false }),
  ).toBeVisible();
  await page.getByLabel("Review state").selectOption("unresolved");
  await expect(
    page.getByRole("heading", { name: "Provider outcome unresolved" }),
  ).toBeVisible();
  const metrics = await page.evaluate(
    () => (window as unknown as { raystoMetrics: unknown }).raystoMetrics,
  );
  const report = JSON.stringify(
    {
      dataset: "500/1000 synthetic records",
      browser: "Edge",
      conditions: "local dev server; fonts warm; no network throttle",
      metrics,
    },
    null,
    2,
  );
  await writeFile(test.info().outputPath("performance.json"), report);
  await test.info().attach("warm-local-workload", {
    body: report,
    contentType: "application/json",
  });
  await page.setViewportSize({ width: 320, height: 800 });
  await page.addStyleTag({
    content:
      ".ops-root {font-size:200%} .ops-root input,.ops-root select,.ops-root button {font-size:inherit}",
  });
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth > innerWidth + 1,
    ),
  ).toBe(false);
});

const tabMatrix: Record<string, string[]> = {
  supplies: [
    "bills",
    "inventory",
    "purchasing",
    "receive",
    "suppliers",
    "recipes",
    "waste",
  ],
  accountant: ["overview", "pnl", "cash", "bills", "aging", "requests", "vat"],
  money: [
    "close",
    "pay",
    "catering",
    "refunds",
    "expenses",
    "customers",
    "analytics",
    "paypal",
  ],
  payments: ["captures", "cash", "refunds", "attempts", "byDay"],
  agents: ["inbox", "activity"],
  dispatch: ["board", "partners", "simulator"],
  group: ["portfolio", "compare", "money", "templates", "transfers"],
};
test("every supported owner tab restores a valid selected route", async ({
  page,
}) => {
  test.setTimeout(300000);
  const errors: string[] = [];
  page.on("pageerror", (e) => errors.push(e.message));
  for (const [section, tabs] of Object.entries(tabMatrix))
    for (const tab of tabs) {
      await page.goto(
        `/ops/preview?section=${section}&tab=${tab}${section === "group" ? "&state=group" : ""}`,
      );
      await expect(page.getByRole("heading", { level: 1 })).toBeVisible({
        timeout: 60000,
      });
      await expect(page.getByRole("tab", { selected: true })).toHaveCount(1);
      await expect(page.getByRole("tab", { selected: true })).toBeVisible();
      await expect(page).toHaveURL(new RegExp(`tab=${tab}(?:&|$)`));
    }
  expect(errors).toEqual([]);
});

for (const width of [1280, 1024, 768, 390])
  test(`focused investigation at ${width}px preserves controls and readable labels`, async ({
    page,
  }) => {
    await page.setViewportSize({ width, height: width === 768 ? 1024 : 844 });
    await page.goto(
      "/ops/preview?section=finance&tab=compare&product=171&comparison=901",
    );
    await expect(
      page.getByRole("heading", { name: /Lowest qualifying price/ }),
    ).toBeVisible({ timeout: 60000 });
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth > innerWidth + 1,
      ),
    ).toBe(false);
    const price = page.getByRole("button", {
      name: "Prepare review for this price",
    });
    expect(
      await price.evaluate((e) => e.getBoundingClientRect().height),
    ).toBeGreaterThanOrEqual(48);
    if (width >= 600 && width < 1200) {
      const label = page.getByRole("button", {
        name: "Sales and margins",
        exact: true,
      });
      expect(
        await label.evaluate((e) => e.scrollWidth <= e.clientWidth + 1),
      ).toBe(true);
    }
    await page.screenshot({
      path: `test-results/design/${width}-comparison.png`,
      fullPage: true,
    });
  });

test("rapid motion transitions exclude outgoing content and app reduced motion remains live", async ({
  page,
}) => {
  await page.addInitScript(() => {
    const observations: {
      inert: boolean;
      hidden: string | null;
      pointer: string;
    }[] = [];
    (
      window as unknown as { outgoingViews: typeof observations }
    ).outgoingViews = observations;
    new MutationObserver((records) => {
      for (const r of records) {
        const node = r.target;
        if (
          node instanceof HTMLElement &&
          node.matches(".ops-place") &&
          node.inert
        )
          observations.push({
            inert: node.inert,
            hidden: node.getAttribute("aria-hidden"),
            pointer: getComputedStyle(node).pointerEvents,
          });
      }
    }).observe(document, {
      subtree: true,
      attributes: true,
      attributeFilter: ["inert", "aria-hidden"],
    });
  });
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/ops/preview?section=overview");
  await expect(
    page.getByRole("heading", { level: 1, name: "Today", exact: true }),
  ).toBeVisible();
  await page
    .getByRole("button", { name: "Sales and margins", exact: true })
    .click();
  await expect.poll(()=>page.evaluate(()=>(window as unknown as {outgoingViews:{inert:boolean;hidden:string|null}[]}).outgoingViews.some(v=>v.inert&&v.hidden==='true'))).toBe(true);
  await page.getByRole("button", { name: "Team", exact: true }).click();
  await page.getByRole("button", { name: "Money", exact: true }).click();
  await expect(
    page.getByRole("heading", { level: 1, name: "Money", exact: true }),
  ).toBeFocused();
  await expect(page.locator(".ops-place[inert]")).toHaveCount(0);
  await page.getByRole("switch", { name: "Reduce motion" }).check();
  await page
    .getByRole("button", { name: "Sales and margins", exact: true })
    .click();
  await expect(page.locator(".ops-root")).toHaveAttribute(
    "data-reduce-motion",
    "true",
  );
  await expect(
    page.getByRole("heading", {
      name: "Know what changed. Choose what comes next.",
    }),
  ).toBeVisible();
});
