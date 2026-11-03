import { expect, test, type Page } from "@playwright/test";

// The Orders board on the development-only preview (an in-memory API that
// records every command on window.__boardCommands).
const commands = (page: Page) => page.evaluate(() => (window as unknown as { __boardCommands?: unknown[] }).__boardCommands ?? []);
const column = (page: Page, stage: string) => page.locator(`section.m3-board-col[data-stage="${stage}"]`);
const card = (page: Page, ticket: string) => page.locator(".m3-board-item").filter({ has: page.locator(".m3-board-ticket", { hasText: new RegExp(`^${ticket}$`) }) });

async function drag(page: Page, ticket: string, stage: string) {
  const from = await card(page, ticket).locator(".m3-board-card").boundingBox();
  const to = await column(page, stage).boundingBox();
  if (!from || !to) throw new Error("not on screen");
  await page.mouse.move(from.x + from.width / 2, from.y + 30);
  await page.mouse.down();
  const steps = 16;
  for (let i = 1; i <= steps; i++) {
    await page.mouse.move(
      from.x + from.width / 2 + ((to.x + to.width / 2 - (from.x + from.width / 2)) * i) / steps,
      from.y + 30 + ((to.y + 80 - (from.y + 30)) * i) / steps,
    );
  }
  await page.mouse.up();
}

test.describe("orders", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/ops/board-preview");
    await page.locator(".m3-board-card").first().waitFor();
  });

  test("a drag to the next column sends one transition, with the version the board saw, after 5 s", async ({ page }) => {
    await drag(page, "#14", "ready");
    await expect(column(page, "ready").locator(".m3-board-ticket", { hasText: "#14" })).toBeVisible();
    await expect(page.locator(".m3-snackbar")).toContainText("#14 moved to Ready · 1 open line will be ticked");
    await page.waitForTimeout(3500);
    expect(await commands(page)).toEqual([]);
    await expect.poll(() => commands(page), { timeout: 6000 }).toEqual([
      { name: "kitchen.progress", data: { lineKey: "l1", completedQuantity: 2 }, id: 14, version: 4 },
      { name: "order.transition", data: { status: "ready" }, id: 14, version: 3 },
    ]);
  });

  test("Undo sends nothing and puts the card back", async ({ page }) => {
    await drag(page, "#12", "accepted");
    await expect(column(page, "accepted").locator(".m3-board-ticket", { hasText: "#12" })).toBeVisible();
    await page.locator(".m3-snackbar").getByRole("button", { name: "Undo" }).click();
    await expect(column(page, "new").locator(".m3-board-ticket", { hasText: "#12" })).toBeVisible();
    await page.waitForTimeout(6000);
    expect(await commands(page)).toEqual([]);
  });

  test("a drop on a column that is not next snaps back and sends nothing", async ({ page }) => {
    await drag(page, "#12", "ready");
    await page.waitForTimeout(800);
    await expect(column(page, "new").locator(".m3-board-ticket", { hasText: "#12" })).toBeVisible();
    await expect(page.locator(".m3-snackbar")).toHaveCount(0);
    await page.waitForTimeout(5500);
    expect(await commands(page)).toEqual([]);
  });

  test("the Move button works from the keyboard", async ({ page }) => {
    const move = page.getByRole("button", { name: "Move #13 to Preparing" });
    await move.focus();
    await page.keyboard.press("Enter");
    await expect(column(page, "preparing").locator(".m3-board-ticket", { hasText: "#13" })).toBeVisible();
    await expect.poll(() => commands(page), { timeout: 8000 }).toEqual([
      { name: "order.transition", data: { status: "preparing" }, id: 13, version: 3 },
    ]);
  });

  test("an online pickup is handed over against its code, at once", async ({ page }) => {
    await page.getByRole("button", { name: "Move #15 to Handed over" }).click();
    const dialog = page.getByRole("dialog", { name: "Hand over #15" });
    await expect(dialog).toBeVisible();
    await dialog.getByLabel("Pickup code on the customer’s phone").fill("0271");
    await dialog.getByRole("button", { name: "Hand over" }).click();
    await expect.poll(() => commands(page), { timeout: 3000 }).toEqual([
      { name: "order.transition", data: { status: "collected", code: "0271" }, id: 15, version: 3 },
    ]);
    await expect(page.locator(".m3-snackbar")).toContainText("#15 handed over");
  });

  test("delivery at ready has no drop target and says why", async ({ page }) => {
    await expect(card(page, "#16")).toContainText("Leaves through the delivery flow");
    await expect(card(page, "#16").getByRole("button", { name: /^Move/ })).toHaveCount(0);
  });

  test("an approved money proposal confirms with the PayPal id and no Undo", async ({ page }) => {
    await page.getByRole("button", { name: "Agents" }).click();
    await page.getByRole("button", { name: /^Review:/ }).click();
    await page.getByRole("dialog").getByRole("button", { name: "Approve (identity check)" }).click();
    const bar = page.locator(".m3-snackbar");
    await expect(bar).toContainText("PayPal 4RJ81234AB567890C");
    await expect(bar.getByRole("button", { name: "Undo" })).toHaveCount(0);
  });
});
