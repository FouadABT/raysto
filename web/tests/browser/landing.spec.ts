import { expect, test } from "@playwright/test";

// rays.to is served by the console's /judges route: Raysto's product page.
test.describe("the product page at rays.to", () => {
  test("offers the investigation and workspace with visible Sandbox limits", async ({
    page,
  }) => {
    await page.goto("/judges");
    await expect(page.getByRole("heading", { level: 1 })).toContainText(
      "The AI operating system",
    );
    await expect(page).toHaveTitle(/The AI operating system for restaurants/);
    const demo = page.getByRole("link", {
      name: "Follow a cost investigation",
    });
    await expect(demo).toHaveAttribute(
      "href",
      "https://ops.rays.to/ops?judge=1&section=finance&tab=investigate&guided=1",
    );
    for (const flow of [
      "Pays your bills",
      "Settles complaints",
      "Pays your team",
      "Gets you paid",
    ])
      await expect(page.getByText(flow, { exact: true })).toBeVisible();
    const text = await page.locator("body").innerText();
    expect(text.match(/Sandbox/g)?.length ?? 0).toBeGreaterThanOrEqual(1);
    expect(text).not.toMatch(
      /for hackathon judges|unit tests|integration tests/i,
    );
  });

  test("fits a 320 px phone without sideways scrolling", async ({ page }) => {
    await page.setViewportSize({ width: 320, height: 720 });
    await page.goto("/judges");
    await expect(
      page.getByRole("link", { name: "Follow a cost investigation" }),
    ).toBeVisible();
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - window.innerWidth,
    );
    expect(overflow).toBeLessThanOrEqual(0);
  });

  test("keeps the diagram still for anyone who asks for less motion", async ({
    page,
  }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto("/judges");
    const diagram = page.locator("figure.jg-decision-map");
    await expect(diagram.locator("ol>li")).toHaveCount(4);
    await expect(
      diagram.getByText("Read the evidence", { exact: true }),
    ).toBeVisible();
    await expect(
      diagram.getByText("Inspect the outcome", { exact: true }),
    ).toBeVisible();
    await expect(diagram.locator("video[autoplay]")).toHaveCount(0);
  });
});
