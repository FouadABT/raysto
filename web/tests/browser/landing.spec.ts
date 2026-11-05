import { expect, test } from "@playwright/test";

// rays.to is served by the console's /judges route: Raysto's product page.
test.describe("the product page at rays.to", () => {
  test("says what Raysto is, opens the demo café, and names Sandbox once", async ({ page }) => {
    await page.goto("/judges");
    await expect(page.getByRole("heading", { level: 1 })).toContainText("The AI operating system");
    await expect(page).toHaveTitle(/The AI operating system for restaurants/);
    const demo = page.getByRole("link", { name: "Enter the live demo" });
    await expect(demo).toHaveAttribute("href", "https://ops.rays.to/ops?judge=1");
    for (const flow of ["Pays your bills", "Settles complaints", "Pays your team", "Gets you paid"])
      await expect(page.getByText(flow, { exact: true })).toBeVisible();
    const text = await page.locator("body").innerText();
    expect(text.match(/Sandbox/g)?.length ?? 0).toBe(1);
    expect(text).not.toMatch(/for hackathon judges|unit tests|integration tests/i);
  });

  test("fits a 320 px phone without sideways scrolling", async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 720 });
    await page.goto("/judges");
    await expect(page.getByRole("link", { name: "Enter the live demo" })).toBeVisible();
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    expect(overflow).toBeLessThanOrEqual(0);
  });

  test("keeps the diagram still for anyone who asks for less motion", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto("/judges");
    const video = page.locator("figure.jg-diagram video");
    await expect(video).toHaveAttribute("poster", "/judges/brain.jpg");
    await page.waitForTimeout(800);
    expect(await video.evaluate((v: HTMLVideoElement) => v.paused)).toBe(true);
  });
});
