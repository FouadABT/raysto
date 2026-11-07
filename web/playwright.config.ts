import { defineConfig } from "@playwright/test";
const port = process.env.RAYSTO_E2E_PORT ?? "3100";
export default defineConfig({
  testDir: "./tests/browser",
  outputDir: process.env.RAYSTO_E2E_OUTPUT ?? "test-results",
  fullyParallel: false,
  workers: 1,
  timeout: 45000,
  expect: { timeout: 10000 },
  reporter: [["list"]],
  use: {
    baseURL: `http://127.0.0.1:${port}`,
    channel: process.env.PLAYWRIGHT_EXECUTABLE ? undefined : "msedge",
    launchOptions: process.env.PLAYWRIGHT_EXECUTABLE
      ? { executablePath: process.env.PLAYWRIGHT_EXECUTABLE }
      : {},
    viewport: { width: 1440, height: 1000 },
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
  },
  webServer: {
    env: process.env.RAYSTO_FINANCE_017_E2E === "on" ? { NEXT_PUBLIC_RAYSTO_FINANCE_017: "on" } : {},
    command: `node node_modules/next/dist/bin/next dev --hostname 127.0.0.1 --port ${port}`,
    url: `http://127.0.0.1:${port}/ops/preview`,
    reuseExistingServer: true,
    timeout: 120000,
  },
});
