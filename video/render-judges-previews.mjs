import { bundle } from "@remotion/bundler";
import {
  openBrowser,
  selectComposition,
  renderStill,
} from "@remotion/renderer";
import { mkdir } from "node:fs/promises";
import path from "node:path";

const out = path.resolve("out/judges-review");
await mkdir(out, { recursive: true });
const serveUrl = await bundle({
  entryPoint: path.resolve("src/index.ts"),
  outDir: path.resolve("out/judges-bundle"),
});
const browser = await openBrowser("chrome", {
  browserExecutable:
    process.env.RAYSTO_RENDER_BROWSER ||
    "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
});
try {
  const composition = await selectComposition({
    serveUrl,
    id: "RaystoJudges38",
    puppeteerInstance: browser,
  });
  const args = process.argv.slice(2).map(Number);
  const frames = args.length
    ? args
    : [60, 130, 215, 310, 420, 500, 625, 730, 875, 970, 1080, 1138];
  for (let i = 0; i < frames.length; i += 3) {
    await Promise.all(
      frames.slice(i, i + 3).map(async (frame) => {
        await renderStill({
          composition,
          serveUrl,
          puppeteerInstance: browser,
          frame,
          scale: 0.65,
          output: path.join(out, `${frame}.png`),
        });
        console.log(`Reviewed frame ${frame}`);
      }),
    );
  }
} finally {
  await browser.close({ silent: true });
}
