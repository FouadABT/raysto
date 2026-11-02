import { bundle } from "@remotion/bundler";
import {
  openBrowser,
  selectComposition,
  renderStill,
} from "@remotion/renderer";
import { mkdir } from "node:fs/promises";
import path from "node:path";

const out = path.resolve("out/challenge-review");
await mkdir(out, { recursive: true });
const serveUrl = await bundle({
  entryPoint: path.resolve("src/index.ts"),
  outDir: path.resolve("out/challenge-bundle"),
});
const browserExecutable =
  process.env.RAYSTO_RENDER_BROWSER ||
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const browser = await openBrowser("chrome", { browserExecutable });
try {
  const composition = await selectComposition({
    serveUrl,
    id: "RaystoChallenge",
    puppeteerInstance: browser,
  });
  const frames = process.argv.slice(2).map(Number);
  const chosen = frames.length
    ? frames
    : [70,220,440,670,850,1040,1250,1500,1650,1740,1920,2000,2130,2270];
  for (let i = 0; i < chosen.length; i += 3) {
    await Promise.all(
      chosen.slice(i, i + 3).map(async (frame) => {
        await renderStill({
          composition,
          serveUrl,
          puppeteerInstance: browser,
          frame,
          scale: 0.65,
          output: path.join(out, `${frame}.png`),
        });
        console.log(`Preview ${frame}`);
      }),
    );
  }
} finally {
  await browser.close({ silent: true });
}
