// Review stills for RaystoPromo60: node render-promo-previews.mjs [frames...]
import { bundle } from "@remotion/bundler";
import { openBrowser, selectComposition, renderStill } from "@remotion/renderer";
import { mkdir } from "node:fs/promises";
import path from "node:path";

const out = path.resolve("out/promo-review");
await mkdir(out, { recursive: true });
const serveUrl = await bundle({
  entryPoint: path.resolve("src/promo/index.ts"),
  outDir: path.resolve("out/promo-bundle"),
});
const browser = await openBrowser("chrome", {
  browserExecutable:
    process.env.RAYSTO_RENDER_BROWSER ||
    "C:/Program Files/Google/Chrome/Application/chrome.exe",
});
try {
  const composition = await selectComposition({ serveUrl, id: "RaystoPromo60", puppeteerInstance: browser });
  const args = process.argv.slice(2).map(Number);
  const frames = args.length ? args : [60, 140, 194, 294, 412, 510, 600, 668, 788, 898, 988, 1076, 1151, 1236, 1339, 1459, 1597, 1717];
  for (let i = 0; i < frames.length; i += 3) {
    await Promise.all(
      frames.slice(i, i + 3).map(async (frame) => {
        await renderStill({ composition, serveUrl, puppeteerInstance: browser, frame, scale: 0.5, output: path.join(out, `${frame}.png`) });
        console.log(`frame ${frame}`);
      }),
    );
  }
  console.log("duration", composition.durationInFrames);
} finally {
  await browser.close({ silent: true });
}
