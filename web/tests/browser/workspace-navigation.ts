import { expect, type Page } from "@playwright/test";

/** Exercise the actual responsive primary/secondary navigation. */
export async function chooseSection(page: Page, name: string) {
  const phone = (page.viewportSize()?.width ?? 1440) < 600;
  if (phone)
    await page.getByRole("button", { name: "Open the console menu" }).click();
  const container = phone
    ? page.getByRole("dialog", { name: "Console menu" })
    : page.locator(".ops-shell-side");
  const button = container.getByRole("button", {
    name: name === "Supplies" ? /^(Supplies|Bills and stock)$/ : name,
    exact: name !== "Supplies",
  });
  if (!(await button.isVisible()))
    await container.getByText("Restaurant operations", { exact: true }).click();
  await button.click();
  await expect(page.locator(".ops-appbar h1")).toHaveText(
    name === "Supplies" ? /^(Supplies|Bills and stock)$/ : name,
  );
}
