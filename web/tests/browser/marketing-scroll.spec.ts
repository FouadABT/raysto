import { test, expect } from "@playwright/test";

test.use({ video: { mode: "on", size: { width: 1440, height: 1000 } } });

for (const reduced of [false, true]) {
  test(`decision story follows scroll and reverses (${reduced ? "reduced" : "full motion"})`, async ({
    page,
  }) => {
    await page.emulateMedia({
      reducedMotion: reduced ? "reduce" : "no-preference",
    });
    const errors: string[] = [];
    const api: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    page.on("request", (r) => {
      if (r.url().includes("/api/")) api.push(r.url());
    });
    await page.goto("/");
    await expect(page.locator("#connected-story")).toHaveAttribute(
      "data-enhanced",
      "true",
    );
    await page.evaluate(() => document.fonts.ready);
    const gotoChapter = async (index: number) => {
      await page.locator(`#story-chapter-${index}`).evaluate((el) => {
        window.scrollTo({
          top: el.getBoundingClientRect().top + scrollY - innerHeight * 0.35,
          behavior: "instant",
        });
      });
      await expect(page.locator("#connected-story")).toHaveAttribute(
        "data-active",
        String(index),
      );
      await expect(page.locator(".lp-story-card").nth(index)).toBeVisible();
    };
    for (const index of [0, 1, 2, 3, 2, 0]) {
      await gotoChapter(index);
      await page.waitForTimeout(700);
    }
    await gotoChapter(1);
    const orbit = await page
      .locator(".lp-story-orbit")
      .evaluate((el) => getComputedStyle(el).transform);
    if (reduced) {
      expect(orbit).toBe("none");
      await expect(page.locator(".lp-story-note")).toContainText(
        "without animation",
      );
    } else {
      expect(orbit).not.toBe("none");
      await gotoChapter(2);
      await page.waitForTimeout(700);
      expect(
        await page
          .locator(".lp-story-orbit")
          .evaluate((el) => getComputedStyle(el).transform),
      ).not.toBe(orbit);
    }
    await page.screenshot({
      path: `test-results/marketing/scroll-story-${reduced ? "reduced" : "full"}.png`,
    });
    await page
      .getByRole("link", { name: "Chapter 4: The money trail" })
      .click();
    await expect(page.locator("#connected-story")).toHaveAttribute(
      "data-active",
      "3",
    );
    await expect(page.locator(".lp-story-card").nth(3)).toContainText(
      "no payment in this scene",
    );
    // Breakpoint changes must release sticky presentation; all chapter copy stays available.
    await page.setViewportSize({ width: 390, height: 844 });
    await expect(page.locator(".lp-story-sticky")).toBeHidden();
    await expect(page.locator(".lp-story-chapter")).toHaveCount(4);
    expect(
      await page.evaluate(
        () => document.documentElement.scrollWidth <= innerWidth,
      ),
    ).toBe(true);
    await page.setViewportSize({ width: 1440, height: 1000 });
    await gotoChapter(2);
    await expect(page.locator(".lp-story-sticky")).toBeVisible();
    if (!reduced) {
      await page.emulateMedia({ reducedMotion: "reduce" });
      await expect
        .poll(() =>
          page
            .locator(".lp-story-orbit")
            .evaluate((el) => getComputedStyle(el).transform),
        )
        .toBe("none");
      await gotoChapter(1);
      await expect(page.locator(".lp-story-card").nth(1)).toBeVisible();
    }
    expect(errors).toEqual([]);
    expect(api).toEqual([]);
  });
}

test("record the continuous scroll choreography", async ({ page }) => {
  await page.emulateMedia({ reducedMotion: "no-preference" });
  await page.goto("/#connected-story");
  await expect(page.locator("#connected-story")).toHaveAttribute(
    "data-enhanced",
    "true",
  );
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(900);
  const initial = await page
    .locator(".lp-story-orbit")
    .evaluate((el) => getComputedStyle(el).transform);
  for (let i = 0; i < 26; i++) {
    await page.mouse.wheel(0, 100);
    await page.waitForTimeout(180);
  }
  await expect(page.locator("#connected-story")).toHaveAttribute(
    "data-active",
    "3",
  );
  expect(
    await page
      .locator(".lp-story-orbit")
      .evaluate((el) => getComputedStyle(el).transform),
  ).not.toBe(initial);
  await page.waitForTimeout(700);
});
