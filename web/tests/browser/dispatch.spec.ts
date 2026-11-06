import { expect, test, type Locator, type Page } from "@playwright/test";
import { chooseSection } from "./workspace-navigation";

/**
 * The Dispatch section (stream S2) on the development preview's fixtures
 * (src/lib/connected/dispatch-preview.ts): no backend, no sign-in. The
 * preview refuses every command, so a sent offer shows up as one attempt and
 * the preview's refusal. Map tiles are a local blank image: no request leaves
 * the machine.
 */
const preview = "/ops/preview";
const shots = "test-results/dispatch";
const blank = Buffer.from(
  "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=",
  "base64",
);

async function openDispatch(page: Page) {
  await page.route(/tile\.openstreetmap\.org/, (route) =>
    route.fulfill({ status: 200, contentType: "image/png", body: blank }),
  );
  await page.goto(preview);
  await expect(page.locator(".ops-ov-greeting")).toBeVisible({
    timeout: 60000,
  });
  await chooseSection(page, "Dispatch");
  await expect(page.locator(".ops-appbar h1")).toHaveText("Dispatch");
}

const tab = (page: Page, name: string) =>
  page.getByRole("tablist", { name: "Dispatch" }).getByRole("tab", { name });
const amal = (page: Page) =>
  page.locator(".ops-dsp-driver").filter({ hasText: "Amal (demo login)" });
const job14 = (page: Page) =>
  page
    .locator(".ops-dsp-job")
    .filter({ hasText: "#14" })
    .locator(".ops-dsp-job-card");

/** HTML5 drag and drop with one shared DataTransfer, as a browser does it. */
async function drag(page: Page, source: Locator, target: Locator) {
  await source.scrollIntoViewIfNeeded();
  const data = await page.evaluateHandle(() => new DataTransfer());
  await source.dispatchEvent("dragstart", { dataTransfer: data });
  await target.scrollIntoViewIfNeeded();
  await target.dispatchEvent("dragenter", { dataTransfer: data });
  await target.dispatchEvent("dragover", { dataTransfer: data });
  await target.dispatchEvent("drop", { dataTransfer: data });
  await source.dispatchEvent("dragend", { dataTransfer: data });
}

test.describe("Dispatch", () => {
  test("the map credits OpenStreetMap and shows the café, the doors and a driver", async ({
    page,
  }) => {
    await openDispatch(page);
    const map = page.getByRole("figure", { name: "Deliveries on the map" });
    await expect(map.locator(".leaflet-container")).toBeVisible();
    await expect(map.locator(".leaflet-control-attribution")).toContainText(
      "OpenStreetMap contributors",
    );
    await expect(map.locator(".ops-map-pin.venue")).toHaveCount(1);
    await expect(map.locator(".ops-map-pin.job")).toHaveCount(4);
    await expect(map.locator(".ops-map-pin.driver")).toHaveCount(1);
    await expect(
      page.getByText("Proof at the door: the customer's code"),
    ).toBeVisible();
    await expect(
      page.locator(".ops-dsp-job").filter({ hasText: "#15" }),
    ).toContainText("by the AI dispatcher");
    await expect(
      page
        .getByRole("region", { name: "Delivery jobs" })
        .getByText("On the way"),
    ).toBeVisible();
    await page.screenshot({ path: `${shots}/board-1440.png`, fullPage: true });
  });

  test("dragging a job onto a driver sends exactly one offer after the Undo window", async ({
    page,
  }) => {
    await openDispatch(page);
    const layout = page.locator(".ops-dsp-layout");
    await expect(layout).toHaveAttribute("data-offers-sent", "0");
    await drag(page, job14(page), amal(page));
    await expect(
      page.getByText("Offering #14 to Amal (demo login)"),
    ).toBeVisible();
    await expect(amal(page)).toContainText("Offering #14");
    // The offer waits for Undo, then goes once; the preview refuses it, and says so.
    await expect(layout).toHaveAttribute("data-offers-sent", "1", {
      timeout: 9000,
    });
    await expect(
      page.getByText("The preview does not send commands.").first(),
    ).toBeVisible();
    await page.waitForTimeout(1500);
    await expect(layout).toHaveAttribute("data-offers-sent", "1");
  });

  test("Undo keeps the offer from being sent", async ({ page }) => {
    await openDispatch(page);
    await drag(page, job14(page), amal(page));
    await page.getByRole("button", { name: "Undo" }).click();
    await page.waitForTimeout(6500);
    await expect(page.locator(".ops-dsp-layout")).toHaveAttribute(
      "data-offers-sent",
      "0",
    );
    await expect(amal(page)).not.toContainText("Offering #14");
  });

  test("an offline driver is not a drop zone, and the keyboard can offer too", async ({
    page,
  }) => {
    await openDispatch(page);
    const noor = page
      .locator(".ops-dsp-driver")
      .filter({ hasText: "Noor · Sample" });
    await expect(noor).not.toHaveClass(/takes/);
    await drag(page, job14(page), noor);
    await page.waitForTimeout(500);
    await expect(page.getByText(/Offering #14/)).toHaveCount(0);
    await page
      .getByLabel("Offer #14 to")
      .selectOption({ label: "Sam · Sample" });
    await expect(page.getByText("Offering #14 to Sam · Sample")).toBeVisible();
  });

  test("partner apps show only the key's prefix, and the log of calls", async ({
    page,
  }) => {
    await openDispatch(page);
    await tab(page, "Partner apps").click();
    const app = page
      .locator(".ops-dsp-app")
      .filter({ hasText: "Demo Delivery Co. (simulator)" });
    await expect(app.getByText("rk_k7m2p9qa_…")).toBeVisible();
    await expect(app.getByText("Simulator", { exact: true })).toBeVisible();
    await expect(
      page
        .getByRole("region", { name: "Partner calls and webhooks" })
        .getByText("orders.create"),
    ).toBeVisible();
    await page.getByRole("button", { name: "Rotate the key" }).click();
    await expect(
      page
        .getByRole("alert")
        .filter({ hasText: "The preview does not send commands." }),
    ).toBeVisible();
  });

  test("the simulator keeps its banner and drives the partner API through the console server", async ({
    page,
  }) => {
    const posted: string[] = [];
    await page.route("**/api/partner-sim/events", (route) =>
      route.fulfill({
        json: {
          data: {
            rows: [
              {
                id: "evt_9",
                type: "order.accepted",
                ref: "sim-42",
                receivedAt: new Date().toISOString(),
                verified: true,
              },
            ],
          },
        },
      }),
    );
    await page.route("**/api/partner-sim/orders", async (route) => {
      posted.push(route.request().postData() ?? "");
      await route.fulfill({
        json: {
          data: {
            ref: "sim-42",
            status: "received",
            number: 16,
            dropoffCode: "4821",
          },
        },
      });
    });
    await openDispatch(page);
    await tab(page, "Simulator").click();
    await expect(page.getByRole("note")).toHaveText(
      "Simulator: a pretend outside delivery app. Not Uber Eats or Glovo.",
    );
    await page
      .getByRole("button", { name: "Send an order for the café's driver" })
      .click();
    await expect(
      page.getByText(/Order sim-42 sent, signed with the simulator's key/),
    ).toBeVisible();
    await expect(
      page.locator(".ops-dsp-sim-list").getByText("sim-42").first(),
    ).toBeVisible();
    await expect(page.getByText("Code for the door: 4821.")).toBeVisible();
    await expect(page.getByText("signature verified")).toBeVisible();
    expect(JSON.parse(posted[0])).toEqual({
      restaurantId: 1,
      fulfilledBy: "restaurant",
    });
  });

  test("without the simulator configured, the page says so", async ({
    page,
  }) => {
    await page.route("**/api/partner-sim/**", (route) =>
      route.fulfill({
        status: 404,
        json: {
          error: {
            code: "not_configured",
            message: "The delivery simulator is not on this deployment yet.",
          },
        },
      }),
    );
    await openDispatch(page);
    await tab(page, "Simulator").click();
    await page
      .getByRole("button", { name: "Send an order for the café's driver" })
      .click();
    await expect(page.locator(".ops-dsp-sim").getByRole("alert")).toHaveText(
      "The simulator is not configured on this deployment.",
    );
  });

  test("no page error at 390 px with reduced motion", async ({ page }) => {
    const errors: string[] = [];
    page.on("pageerror", (e) => errors.push(e.message));
    await page.setViewportSize({ width: 390, height: 844 });
    await page.emulateMedia({ reducedMotion: "reduce" });
    await openDispatch(page);
    await expect(page.locator(".leaflet-container")).toBeVisible();
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - window.innerWidth,
    );
    expect(overflow).toBeLessThanOrEqual(1);
    await tab(page, "Partner apps").click();
    await tab(page, "Simulator").click();
    await page.screenshot({ path: `${shots}/board-390.png`, fullPage: true });
    expect(errors).toEqual([]);
  });
});
