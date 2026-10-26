import { test, expect } from "@playwright/test";
import { mkdirSync } from "node:fs";

// Exercise the real WebGL renderer on machines without a physical test GPU.
test.use({
  launchOptions: {
    args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader"],
  },
});

test("editorial assets, real 3D, parallax and motion preferences", async ({
  page,
}) => {
  test.setTimeout(90000);
  const errors: string[] = [];
  page.on("pageerror", (e) => errors.push(e.message));
  await page.goto("/");
  await expect(
    page.getByRole("heading", { name: /Come hungry/ }),
  ).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await expect
    .poll(() =>
      page
        .locator(".supper-image-frame img")
        .evaluate((el: HTMLImageElement) => el.naturalWidth),
    )
    .toBeGreaterThan(0);
  await expect(page.locator(".table-canvas canvas")).toBeVisible();
  const canvas = page.locator(".table-canvas canvas");
  expect(
    await canvas.evaluate((el: HTMLCanvasElement) => ({
      width: el.width,
      height: el.height,
    })),
  ).toMatchObject({ width: expect.any(Number), height: expect.any(Number) });
  await expect(page.locator(".sculpture-fallback")).toBeHidden();
  mkdirSync("artifacts/screenshots", { recursive: true });
  await page.screenshot({
    path: "artifacts/screenshots/creative-desktop.png",
    animations: "disabled",
  });
  const photo = page.locator(".supper-image-frame img");
  const before = await photo.evaluate((el) => getComputedStyle(el).transform);
  await page.mouse.wheel(0, 400);
  await expect
    .poll(() => photo.evaluate((el) => getComputedStyle(el).transform))
    .not.toBe(before);
  await page.keyboard.press("Control+Home");
  await expect.poll(() => page.evaluate(() => scrollY)).toBeLessThan(2);
  await page.emulateMedia({ reducedMotion: "reduce" });
  await expect(page.locator(".table-canvas")).toHaveCount(0);
  await expect(page.locator("html")).not.toHaveClass(/lenis/);
  await expect(page.locator(".sculpture-fallback")).toBeVisible();
  const calmBefore = await photo.evaluate(
    (el) => getComputedStyle(el).transform,
  );
  await page.mouse.wheel(0, 300);
  await expect.poll(() => page.evaluate(() => scrollY)).toBeGreaterThan(100);
  expect(await photo.evaluate((el) => getComputedStyle(el).transform)).toBe(
    calmBefore,
  );
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto("/");
  await expect(
    page.getByRole("heading", { name: /Come hungry/ }),
  ).toBeVisible();
  await page.evaluate(() => document.fonts.ready);
  await expect
    .poll(() => photo.evaluate((el: HTMLImageElement) => el.naturalWidth))
    .toBeGreaterThan(0);
  await page.screenshot({
    path: "artifacts/screenshots/creative-mobile.png",
    animations: "disabled",
  });
  await page.addStyleTag({ content: "html { font-size: 200% !important; }" });
  const overflow = await page.evaluate(() => ({
    width: document.documentElement.scrollWidth,
    viewport: innerWidth,
    offenders: [...document.querySelectorAll("main *")]
      .filter(
        (el) =>
          el.getBoundingClientRect().right > innerWidth + 1 &&
          !el.closest(".category-row"),
      )
      .map((el) => ({
        class: el.className,
        right: el.getBoundingClientRect().right,
      }))
      .slice(0, 12),
  }));
  expect(overflow.width, JSON.stringify(overflow)).toBeLessThanOrEqual(
    overflow.viewport + 1,
  );
  expect(errors).toEqual([]);
});

test("missing WebGL retains the illustration and the ordering path", async ({
  page,
}) => {
  await page.addInitScript(() => {
    const original = HTMLCanvasElement.prototype.getContext;
    HTMLCanvasElement.prototype.getContext = function (
      this: HTMLCanvasElement,
      type: string,
      ...args: unknown[]
    ) {
      if (type === "webgl2" || type === "webgl") return null;
      return Reflect.apply(original, this, [type, ...args]);
    } as typeof original;
  });
  await page.goto("/");
  await expect(
    page.getByRole("heading", { name: /Come hungry/ }),
  ).toBeVisible();
  await expect(page.locator(".sculpture-fallback")).toBeVisible();
  await expect(page.locator(".table-canvas")).toHaveCount(0);
  await page
    .getByRole("link", { name: "Find your favorite", exact: true })
    .click();
  await expect(
    page.getByRole("button", {
      name: "Add Wood-fired margherita",
      exact: true,
    }),
  ).toBeVisible();
});
