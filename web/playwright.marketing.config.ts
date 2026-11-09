import { defineConfig } from "@playwright/test";

/** Runs against an explicitly started local site, including the production build. */
export default defineConfig({
  testDir: "./tests/browser",
  testMatch: "marketing-home.spec.ts",
  outputDir: process.env.RAYSTO_E2E_OUTPUT ?? "test-results/marketing-production",
  fullyParallel: false,
  workers: 1,
  timeout: 45000,
  expect: { timeout: 10000 },
  reporter: [["list"]],
  use: {
    baseURL: `http://127.0.0.1:${process.env.RAYSTO_E2E_PORT ?? "3110"}`,
    channel: "msedge",
    viewport: { width: 1440, height: 1000 },
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
  },
});
