import { expect, test, type Page } from "@playwright/test";

/**
 * The signed-in console on its development preview (/ops/preview): the real
 * shell and workspace on the frozen dashboard fixtures, with no backend and
 * no sign-in. One section per area of the console; each stream adds its own.
 */
const preview = "/ops/preview";
const shots = "test-results/console";

async function openOverview(page: Page, query = "") {
  await page.goto(preview + query);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({
    timeout: 60000,
  });
}

/* ---------- Shell and Overview (stream C) ---------- */
test.describe("Shell and Overview", () => {
  for (const [name, width, height] of [
    ["1440", 1440, 1000],
    ["390", 390, 844],
  ] as const) {
    for (const motion of ["no-preference", "reduce"] as const) {
      test(`Overview at ${name} px, motion ${motion}`, async ({ page }) => {
        await page.setViewportSize({ width, height });
        await page.emulateMedia({ reducedMotion: motion });
        await openOverview(page);
        await expect(page.locator(".ops-ov-kpi").first()).toBeVisible();
        await page.waitForTimeout(motion === "reduce" ? 300 : 2000);
        await page.screenshot({
          path: `${shots}/overview-${name}-${motion}.png`,
          fullPage: true,
        });
      });
    }
  }

  test("with reduced motion the real figures are there in the first frame, fully opaque", async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await openOverview(page);
    const hero = page.locator(".ops-ov-kpi.hero .ops-ov-kpi-value");
    await expect(hero).toBeVisible();
    // No wait: the value is final as soon as the card exists.
    expect(await hero.locator(".m3-count-live").innerText()).toBe("$195.30");
    await expect(page.locator(".ops-ov-live-number .m3-count-live")).toHaveText(
      "4",
    );
    // The sample's dashed outline is drawn faint on purpose; nothing else may be.
    const faded = await page.evaluate(() =>
      [...document.querySelectorAll(".ops-ov *, .ops-appbar *")]
        .filter(
          (el) =>
            !el.matches(".m3-sample-line") &&
            Number(getComputedStyle(el).opacity) < 1,
        )
        .map(
          (el) =>
            `${el.tagName}.${el.getAttribute("class") ?? ""} ${(el as HTMLElement).style?.opacity ?? ""}`,
        ),
    );
    expect(faded).toEqual([]);
  });

  test("the Overview does not shift its layout while it animates", async ({
    page,
  }) => {
    await page.addInitScript(() => {
      (window as unknown as { __cls: number }).__cls = 0;
      new PerformanceObserver((list) => {
        for (const entry of list.getEntries() as unknown as {
          value: number;
          hadRecentInput: boolean;
        }[])
          if (!entry.hadRecentInput)
            (window as unknown as { __cls: number }).__cls += entry.value;
      }).observe({ type: "layout-shift", buffered: true });
    });
    await page.goto(preview);
    // Measured from the first Overview content, once the figures have arrived.
    await expect(page.locator(".ops-ov-kpi").first()).toBeVisible({
      timeout: 60000,
    });
    await page.evaluate(
      () => ((window as unknown as { __cls: number }).__cls = 0),
    );
    await page.waitForTimeout(2500);
    const cls = await page.evaluate(
      () => (window as unknown as { __cls: number }).__cls,
    );
    expect(cls).toBeLessThan(0.02);
  });

  test("screen readers hear the comparison as words", async ({ page }) => {
    await openOverview(page);
    await expect(
      page.locator(".ops-ov-kpi.hero .ops-ov-delta .m3-sr"),
    ).toHaveText("up 215% on the previous 7 days");
    await expect(
      page.locator(".ops-ov-kpi.hero .m3-count .m3-sr").first(),
    ).toHaveText("$195.30");
  });

  test("the sample history is labelled and drawn apart from the real line", async ({
    page,
  }) => {
    await openOverview(page);
    await expect(
      page.locator(".ops-ov-trendcard").getByText("Sample · not real sales"),
    ).toBeVisible();
  });

  test("the period buttons switch the figures", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await openOverview(page);
    await page
      .getByRole("group", { name: "Period" })
      .getByRole("button", { name: "Today" })
      .click();
    await expect(
      page
        .getByRole("group", { name: "Period" })
        .getByRole("button", { name: "Today" }),
    ).toHaveAttribute("aria-pressed", "true");
    await expect(
      page.locator(".ops-ov-kpi.hero .ops-ov-kpi-value .m3-count-live"),
    ).toHaveText("$21.50");
    await page.getByRole("button", { name: "7 days" }).click();
  });

  test("a dashboard the backend cannot serve reads as an honest error", async ({
    page,
  }) => {
    await openOverview(page, "?state=failed");
    await expect(
      page
        .getByRole("alert")
        .filter({ hasText: "The figures could not load." }),
    ).toBeVisible();
    await expect(page.locator(".ops-ov-kpi")).toHaveCount(0);
  });

  test("a café with no paid order draws no chart", async ({ page }) => {
    await openOverview(page, "?state=empty");
    await expect(
      page.getByText(/No paid orders in the last 7 days/),
    ).toBeVisible();
    await expect(page.locator(".ops-ov-trendcard svg")).toHaveCount(0);
    await expect(
      page.getByRole("button", { name: /Set a daily target/ }),
    ).toBeVisible();
  });

  test("keyboard: the navigation drawer at 1440 px", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await openOverview(page);
    const nav = page.locator(".ops-shell-side .ops-sections");
    await expect(
      nav.getByRole("button", { name: /^(Overview|Today)$/ }),
    ).toHaveAttribute("aria-current", "page");
    await nav.getByRole("button", { name: /^(Overview|Today)$/ }).focus();
    await page.keyboard.press("Tab");
    const next = (await nav
      .getByRole("button", { name: "Sales and margins", exact: true })
      .count())
      ? "Sales and margins"
      : "Orders";
    await expect(
      nav.getByRole("button", { name: next, exact: true }),
    ).toBeFocused();
    await page.keyboard.press("Enter");
    await expect(
      nav.getByRole("button", { name: next, exact: true }),
    ).toHaveAttribute("aria-current", "page");
    await expect(page.locator(".ops-appbar h1")).toHaveText(next);
  });

  test("keyboard: the navigation rail at 1024 px", async ({ page }) => {
    await page.setViewportSize({ width: 1024, height: 800 });
    await openOverview(page);
    const rail = page.locator(".ops-shell-side .ops-sections");
    const box = await page.locator(".ops-shell-side").boundingBox();
    expect(box?.width).toBeGreaterThanOrEqual(96);
    expect(box?.width).toBeLessThanOrEqual(120);
    for (const item of await rail.getByRole("button").all()) {
      const b = await item.boundingBox();
      expect(b!.height).toBeGreaterThanOrEqual(48);
    }
    await rail.getByRole("button", { name: "Money" }).focus();
    await page.keyboard.press("Enter");
    await expect(page.locator(".ops-appbar h1")).toHaveText("Money");
  });

  test("keyboard: the phone's modal drawer opens, traps focus and closes with Esc", async ({
    page,
  }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await openOverview(page);
    await expect(page.locator(".ops-shell-side")).toBeHidden();
    const menu = page.getByRole("button", { name: "Open the console menu" });
    await menu.focus();
    await page.keyboard.press("Enter");
    const drawer = page.getByRole("dialog", { name: "Console menu" });
    await expect(drawer).toBeVisible();
    await expect(drawer.getByRole("button", { name: "Team" })).toBeVisible();
    await page.keyboard.press("Escape");
    await expect(drawer).toBeHidden();
    await expect(menu).toBeFocused();
    // Choosing a section closes the drawer and shows it.
    await menu.click();
    if (
      !(await drawer
        .getByRole("button", { name: "Agents", exact: true })
        .isVisible())
    )
      await drawer.getByText("Restaurant operations", { exact: true }).click();
    await drawer.getByRole("button", { name: "Agents" }).click();
    await expect(drawer).toBeHidden();
    await expect(page.locator(".ops-appbar h1")).toHaveText("Agents");
  });

  test("the console's own reduce-motion switch", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 1000 });
    await openOverview(page);
    const sw = page
      .locator(".ops-shell-side")
      .getByRole("switch", { name: "Reduce motion" });
    await expect(sw).not.toBeChecked();
    await sw.check();
    await expect(page.locator(".ops-root.with-shell")).toHaveAttribute(
      "data-reduce-motion",
      "true",
    );
    await sw.uncheck();
    expect(
      await page.evaluate(() => localStorage.getItem("raysto.reduceMotion")),
    ).toBeNull();
  });
});

/* ---------- Orders board (stream D) ---------- */

/* ---------- Money, Team and Try (stream E) ---------- */
test.describe("money", () => {
  async function openSection(page: Page, name: string) {
    await openOverview(page);
    const side = page.locator(".ops-shell-side .ops-sections");
    if (await side.isVisible()) {
      await side.getByRole("button", { name }).click();
    } else {
      await page.getByRole("button", { name: "Open the console menu" }).click();
      await page
        .getByRole("dialog", { name: "Console menu" })
        .getByRole("button", { name })
        .click();
    }
    await expect(page.locator(".ops-appbar h1")).toHaveText(name);
  }

  const tabs = [
    "Close the day",
    "Pay & tips",
    "Catering",
    "Refunds & disputes",
    "Expenses",
    "Customers",
    "Analytics",
  ];
  for (const [name, width, height] of [
    ["1440", 1440, 1000],
    ["390", 390, 844],
  ] as const) {
    for (const motion of ["no-preference", "reduce"] as const) {
      test(`every Money tab and Team render at ${name} px, motion ${motion}`, async ({
        page,
      }) => {
        const errors: string[] = [];
        page.on("pageerror", (e) => errors.push(e.message));
        await page.setViewportSize({ width, height });
        await page.emulateMedia({ reducedMotion: motion });
        await openSection(page, "Money");
        for (const tab of tabs) {
          await page.getByRole("tab", { name: tab }).click();
          await expect(page.getByRole("tab", { name: tab })).toHaveAttribute(
            "aria-selected",
            "true",
          );
          await page.waitForTimeout(motion === "reduce" ? 200 : 900);
          await page.screenshot({
            path: `${shots}/money-${tab.toLowerCase().replace(/[^a-z]+/g, "-")}-${name}-${motion}.png`,
            fullPage: true,
          });
        }
        await openSection(page, "Team");
        await expect(
          page.getByRole("group", { name: "Team view" }),
        ).toBeVisible();
        await page.screenshot({
          path: `${shots}/team-${name}-${motion}.png`,
          fullPage: true,
        });
        expect(errors).toEqual([]);
      });
    }
  }

  test("Analytics draws paid sales per day with the sample labelled apart", async ({
    page,
  }) => {
    await openSection(page, "Money");
    await page.getByRole("tab", { name: "Analytics" }).click();
    const chart = page
      .locator(".ops-bo-chartcard")
      .filter({ hasText: "Paid sales per day" });
    await expect(chart).toBeVisible();
    await expect(chart.getByText("Sample · not real sales")).toBeVisible();
  });

  test("with reduced motion a count-up shows its final value at once", async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await openSection(page, "Money");
    await page.getByRole("tab", { name: "Expenses" }).click();
    const tile = page.locator(".ops-kpi").filter({ hasText: "Last 30 days" });
    await expect(tile.locator(".m3-count-live")).toHaveText("$0.00");
    await expect(tile.locator(".m3-sr")).toHaveText("$0.00");
  });

  test("a refused command reads as a note on the card, never as a result", async ({
    page,
  }) => {
    await openSection(page, "Money");
    await page.getByRole("button", { name: "Run the close" }).click();
    await expect(
      page
        .getByRole("status")
        .filter({ hasText: "The preview does not send commands." }),
    ).toBeVisible();
    await expect(page.locator(".ops-bo-stamp")).toHaveCount(0);
  });

  test("a payout list row without lines never crashes Team or the pay run, and held staff are named", async ({
    page,
  }) => {
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    await page.goto(preview + "?state=payouts");
    await expect(page.locator(".ops-ov-greeting")).toBeVisible({
      timeout: 60000,
    });
    const side = page.locator(".ops-shell-side .ops-sections");
    await side.getByRole("button", { name: "Team" }).click();
    await expect(page.locator(".ops-appbar h1")).toHaveText("Team");
    await expect(page.getByText("Nadia").first()).toBeVisible();
    await side.getByRole("button", { name: "Money" }).click();
    await page.getByRole("tab", { name: "Pay & tips" }).click();
    await expect(page.getByText("Held · Lina")).toBeVisible();
    await expect(
      page.getByText("No PayPal email: add one to pay.").first(),
    ).toBeVisible();
    expect(errors).toEqual([]);
  });

  test("Team switches between cards and the grid", async ({ page }) => {
    await openSection(page, "Team");
    const view = page.getByRole("group", { name: "Team view" });
    await expect(view.getByRole("button", { name: "Cards" })).toHaveAttribute(
      "aria-pressed",
      "true",
    );
    await view.getByRole("button", { name: "Grid" }).click();
    await expect(page.locator(".ops-grid.tall")).toBeVisible();
  });
});
