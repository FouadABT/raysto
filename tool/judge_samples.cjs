// Renders the judges' sample documents with a local Chrome: the electricity
// bill the accountant reads (web/public/judges/bill.pdf, uploaded by
// `node tool/judge_restaurant.cjs bill`) and its picture on Try card 10
// (web/public/judges/bill.png). Both say "Sample" on their face.
//
//   PLAYWRIGHT_EXECUTABLE="C:/Program Files/Google/Chrome/Application/chrome.exe" node tool/judge_samples.cjs
const path = require('node:path');
const fs = require('node:fs');
const { chromium } = require(path.join(__dirname, '..', 'web', 'node_modules', 'playwright'));

const root = path.resolve(__dirname, '..');
const executablePath = process.env.PLAYWRIGHT_EXECUTABLE || 'C:/Program Files/Google/Chrome/Application/chrome.exe';

(async () => {
  const browser = await chromium.launch({ executablePath });
  try {
    const page = await browser.newPage({ viewport: { width: 816, height: 1056 }, deviceScaleFactor: 2 });
    const source = path.join(root, 'tool', 'judges', 'bill-sample.html');
    await page.goto('file:///' + source.replace(/\\/g, '/'));
    const pdf = path.join(root, 'web', 'public', 'judges', 'bill.pdf');
    await page.pdf({ path: pdf, format: 'Letter', printBackground: true, pageRanges: '1' });
    const png = path.join(root, 'web', 'public', 'judges', 'bill.png');
    await page.screenshot({ path: png, clip: { x: 0, y: 0, width: 816, height: 1056 } });
    for (const f of [pdf, png]) console.log(JSON.stringify({ file: path.relative(root, f), bytes: fs.statSync(f).size }));
  } finally {
    await browser.close();
  }
})().catch((e) => {
  console.error(e.message);
  process.exitCode = 1;
});
