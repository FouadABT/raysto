import { test, expect, type Page } from "@playwright/test";
import { mkdirSync } from "node:fs";
const artifactDir = "artifacts/screenshots";
async function addPizza(page: Page) {
  await page.goto("/r/olive-and-hearth");
  await page
    .getByRole("button", { name: "Add Wood-fired margherita", exact: true })
    .click();
  await page.getByRole("dialog").getByRole("button", { name: /Add ·/ }).click();
}
async function owner(page: Page) {
  await page.goto("/login");
  await page
    .getByRole("button", { name: /Yasmine · Restaurant owner/ })
    .click();
  await expect(
    page.getByRole("heading", { name: /A good day starts here/ }),
  ).toBeVisible();
}
test("guest checkout retains failed attempt, then completes through restaurant service", async ({
  page,
}) => {
  await addPizza(page);
  await page.goto("/checkout");
  await page.getByText("Demo payment outcome", { exact: true }).click();
  await page.getByRole("button", { name: "Failed", exact: true }).click();
  await page.getByRole("checkbox").check();
  await page.getByRole("button", { name: /Place demo order/ }).click();
  await expect(page.locator(".error-text[role=alert]")).toContainText(
    "simulated payment failed",
  );
  await expect(page).toHaveURL(/checkout/);
  await page.getByRole("button", { name: "Success", exact: true }).click();
  await expect(page).toHaveURL(/checkout/);
  await page.getByRole("button", { name: /Place demo order/ }).click();
  await expect(page).toHaveURL(/orders\/RS-/);
  const url = page.url();
  const id = url.split("/").pop()!;
  await expect(page.getByText("Paid", { exact: true })).toBeVisible();
  await owner(page);
  await page.goto("/dashboard/orders");
  await page
    .getByRole("textbox", { name: "Search order, guest or table" })
    .fill(id);
  await page.getByRole("button", { name: id, exact: true }).click();
  for (const name of [
    "Accept order",
    "Start preparing",
    "Mark ready",
    "Mark served",
  ])
    await page
      .getByRole("dialog")
      .getByRole("button", { name, exact: true })
      .click();
  await expect(
    page.getByRole("dialog").getByText("Completed", { exact: true }).first(),
  ).toBeVisible();
  await page.getByRole("button", { name: "Close dialog" }).click();
  await page.goto(url);
  await expect(
    page.getByRole("heading", { name: "Hope that hit the spot." }),
  ).toBeVisible();
  await page.reload();
  await expect(
    page.getByRole("heading", { name: "Hope that hit the spot." }),
  ).toBeVisible();
});
test("table join, duplicate service request, shared bill and protected close", async ({
  page,
}) => {
  await page.goto("/table/1");
  await page
    .getByRole("button", { name: "Join table & explore the menu" })
    .click();
  await expect(page).toHaveURL(/r\/olive-and-hearth/);
  await addPizza(page);
  await page.goto("/checkout");
  await page.getByLabel("Pay at restaurant · demo").check();
  await page.getByRole("checkbox").check();
  await page.getByRole("button", { name: /Place demo order/ }).click();
  await expect(page).toHaveURL(/orders\/RS-/);
  await page.goto("/visit");
  await page.getByRole("button", { name: "Water refill", exact: true }).click();
  await page.getByRole("button", { name: "Water refill", exact: true }).click();
  await expect(page.getByRole("status")).toContainText("already with the team");
  await expect(page.getByRole("button", { name: /Pay MAD/ })).toBeVisible();
  await owner(page);
  await page.goto("/dashboard/tables");
  await page.locator(".floor-table").filter({ hasText: "01" }).click();
  await page.getByRole("button", { name: "Close settled visit" }).click();
  await expect(page.getByRole("status")).toContainText(
    "Complete the orders and settle",
  );
});
test("menu draft cancel and shared availability affect guest ordering", async ({
  page,
}) => {
  await owner(page);
  await page.goto("/dashboard/menu");
  await page
    .getByRole("button", { name: "Edit Burrata garden bowl", exact: true })
    .click();
  await page.getByLabel("Dish name", { exact: true }).fill("Unsaved rename");
  page.once("dialog", (dialog) => dialog.dismiss());
  await page.getByRole("button", { name: "Close dialog" }).click();
  await expect(page.getByRole("dialog")).toBeVisible();
  page.once("dialog", (dialog) => dialog.accept());
  await page.getByRole("button", { name: "Close dialog" }).click();
  await expect(
    page.getByRole("heading", { name: "Burrata garden bowl", exact: true }),
  ).toBeVisible();
  const card = page
    .locator(".menu-admin-card")
    .filter({ hasText: "Burrata garden bowl" });
  await card.getByRole("switch").uncheck();
  await page.goto("/r/olive-and-hearth");
  await expect(
    page.getByRole("button", { name: "Add Burrata garden bowl", exact: true }),
  ).toBeDisabled();
});
test("role guard and browser tabs share demo state", async ({
  page,
  context,
}) => {
  await page.goto("/login");
  await page.getByRole("button", { name: /Omar · Kitchen/ }).click();
  await expect(
    page.getByRole("heading", { name: "A little heat. A lot of heart." }),
  ).toBeVisible();
  await page.goto("/dashboard/payments");
  await expect(
    page.getByRole("heading", { name: "A different workspace" }),
  ).toBeVisible();
  const guest = await context.newPage();
  await guest.goto("/r/olive-and-hearth");
  await page.goto("/dashboard/menu");
  await page
    .locator(".menu-admin-card")
    .filter({ hasText: "Burrata garden bowl" })
    .getByRole("switch")
    .uncheck();
  await expect(
    guest.getByRole("button", { name: "Add Burrata garden bowl", exact: true }),
  ).toBeDisabled();
  await guest.close();
});
test("desktop and 320px screen inventory, fonts, assets and screenshots", async ({
  page,
}) => {
  test.setTimeout(180000);
  mkdirSync(artifactDir, { recursive: true });
  const errors: string[] = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.goto("/");
  await expect(
    page.getByRole("heading", { name: /Come hungry/ }),
  ).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({
    path: `${artifactDir}/guest-desktop.png`,
    fullPage: true,
    animations: "disabled",
  });
  await owner(page);
  await page.screenshot({
    path: `${artifactDir}/dashboard-desktop.png`,
    fullPage: true,
    animations: "disabled",
  });
  for (const route of [
    "orders",
    "kitchen",
    "tables",
    "menu",
    "reservations",
    "requests",
    "deliveries",
    "payments",
    "team",
    "reports",
    "settings",
    "storefront",
    "activity",
    "billing",
  ]) {
    await page.goto(`/dashboard/${route}`);
    await expect(page.locator("#main")).toBeVisible();
    await expect(page.locator(".loading-page")).toHaveCount(0);
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth + 1,
      ),
      `Desktop overflow on ${route}`,
    ).toBe(true);
  }
  await page.setViewportSize({ width: 320, height: 740 });
  for (const route of [
    "/discover",
    "/r/olive-and-hearth",
    "/scan",
    "/table/1",
    "/cart",
    "/checkout",
    "/orders",
    "/visit",
    "/reservations",
    "/favorites",
    "/account",
    "/help",
    "/about",
    "/dashboard/overview",
    "/dashboard/orders",
    "/dashboard/kitchen",
    "/dashboard/tables",
    "/dashboard/menu",
    "/dashboard/reservations",
    "/dashboard/settings",
  ]) {
    await page.goto(route);
    await expect(page.locator("#main")).toBeVisible();
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth + 1,
      ),
      `320px overflow on ${route}`,
    ).toBe(true);
  }
  await page.goto("/discover");
  await expect(
    page.getByRole("heading", { name: /Come hungry/ }),
  ).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({
    path: `${artifactDir}/guest-mobile.png`,
    fullPage: true,
    animations: "disabled",
  });
  await page.goto("/dashboard/overview");
  await expect(
    page.getByRole("heading", { name: /A good day starts here/ }),
  ).toBeVisible();
  await page.screenshot({
    path: `${artifactDir}/dashboard-mobile.png`,
    fullPage: true,
    animations: "disabled",
  });
  expect(errors).toEqual([]);
});
test("keyboard modal focus, reduced motion and doubled text", async ({
  page,
}) => {
  await page.emulateMedia({ reducedMotion: "reduce" });
  await page.setViewportSize({ width: 640, height: 900 });
  await page.goto("/r/olive-and-hearth");
  await page
    .getByRole("button", { name: "Add Wood-fired margherita", exact: true })
    .click();
  await expect(page.getByRole("dialog")).toBeVisible();
  await page.keyboard.press("Escape");
  await expect(page.getByRole("dialog")).toHaveCount(0);
  await expect(
    page.getByRole("button", {
      name: "Add Wood-fired margherita",
      exact: true,
    }),
  ).toBeFocused();
  await page.goto("/account");
  await expect(page.getByLabel("Name", { exact: true })).toBeVisible();
  await page.addStyleTag({ content: "html { font-size: 200% !important; }" });
  expect(
    await page.evaluate(
      () => document.documentElement.scrollWidth <= innerWidth + 1,
    ),
  ).toBe(true);
  const duration = await page
    .locator("#main")
    .evaluate((el) => getComputedStyle(el).animationDuration);
  expect(duration).toBe("0s");
});

test("unsaved profile survives back navigation and dark grid uses semantic surfaces", async ({
  page,
}) => {
  mkdirSync(artifactDir, { recursive: true });
  await page.goto("/discover");
  await page
    .getByRole("link", { name: "Your demo account", exact: true })
    .click();
  await page.getByLabel("Name", { exact: true }).fill("Unfinished draft");
  await page.goBack();
  await page.goForward();
  await expect(page.getByLabel("Name", { exact: true })).toHaveValue(
    "Unfinished draft",
  );
  await page.getByRole("button", { name: "Cancel", exact: true }).click();
  await expect(page.getByLabel("Name", { exact: true })).toHaveValue(
    "Alex Morgan",
  );
  await page.getByRole("switch", { name: /Dark appearance/ }).check();
  await owner(page);
  await page.goto("/dashboard/orders");
  await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
  await expect(page.locator(".ag-root-wrapper")).toHaveCSS(
    "background-color",
    "rgb(25, 42, 34)",
  );
  await page.screenshot({
    path: `${artifactDir}/dashboard-dark.png`,
    fullPage: true,
  });
});
