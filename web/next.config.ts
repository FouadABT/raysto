import type { NextConfig } from "next";
const config: NextConfig = {
  distDir:
    process.env.RAYSTO_ISOLATED_PREVIEW === "017"
      ? ".next-finance-017"
      : process.env.RAYSTO_ISOLATED_PREVIEW === "guest-design"
        ? ".next-guest-design"
        : ".next",
  output: "standalone",
  poweredByHeader: false,
  reactStrictMode: true,
  turbopack: { root: process.cwd() },
  devIndicators: false,
};
export default config;
