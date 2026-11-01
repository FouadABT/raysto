// Films the manager asking Raysto about PayPal on the tablet emulator, for
// the demo video. The app must be open on "Ask Raysto about today" as the QA
// owner. The question is typed and checked before filming starts (emulator
// typing is slow); the film shows the question being sent and answered.
// Output (ignored by git): dist/video-footage/ask-raysto-<date>.mp4.
//
//   node tool/record_ask_footage.cjs ["question"]
const fs = require('node:fs'), path = require('node:path');
const { execFileSync, spawn } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'dist/video-footage');
const adb = path.join(process.env.LOCALAPPDATA, 'Android/Sdk/platform-tools/adb.exe');
const ffmpeg = path.join(root, 'video/node_modules/@remotion/compositor-win32-x64-msvc/ffmpeg.exe');
const sh = (...args) => execFileSync(adb, ['shell', ...args]).toString();
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
const question = process.argv[2] ?? 'Are any PayPal payments unresolved? Did checkout 9 really go through at PayPal?';

/// The question field's text and the Ask button's centre, read from the screen.
function screen() {
  sh('uiautomator', 'dump', '/sdcard/ui.xml');
  const xml = execFileSync(adb, ['exec-out', 'cat', '/sdcard/ui.xml']).toString();
  const nodes = [...xml.matchAll(/<node [^>]*>/g)].map((m) => m[0]);
  const attr = (n, k) => (n.match(new RegExp(' ' + k + '="([^"]*)"')) || [])[1] ?? '';
  const centre = (n) => { const [a, b, c, d] = attr(n, 'bounds').match(/\d+/g).map(Number); return [(a + c) >> 1, (b + d) >> 1]; };
  const field = nodes.find((n) => attr(n, 'class') === 'android.widget.EditText');
  const ask = nodes.find((n) => attr(n, 'class') !== 'android.widget.EditText' && (attr(n, 'text') || attr(n, 'content-desc')) === 'Ask');
  if (!field || !ask) throw new Error('Open "Ask Raysto about today" first');
  return { text: attr(field, 'text').replace(/&apos;/g, "'").replace(/&quot;/g, '"').replace(/&amp;/g, '&'), field: centre(field), ask: centre(ask) };
}
const tap = ([x, y]) => sh('input', 'tap', String(x), String(y));

(async () => {
  let s = screen();
  tap(s.field);
  await wait(800);
  // Clear whatever is there, then type a word at a time so nothing is dropped.
  sh('input', 'keyevent', 'KEYCODE_MOVE_END');
  sh('input', 'keyevent', ...Array(s.text.length + 5).fill('67'));
  for (const [i, word] of question.split(' ').entries()) {
    sh('input', 'text', (i ? ' ' : '') + word.replace(/([?'"()&;<>|*$])/g, '\$1'));
    await wait(700);
  }
  for (let i = 0; i < 30 && (s = screen()).text !== question; i++) await wait(1000);
  if (s.text !== question) throw new Error('The question did not type correctly; run again');
  sh('input', 'keyevent', '4'); // hide the on-screen keyboard
  await wait(1500);
  s = screen();
  const recorder = spawn(adb, ['shell', 'screenrecord', '--size', '1920x1200', '--bit-rate', '16000000', '/sdcard/ask.mp4']);
  await wait(2500);
  tap(s.ask);
  await wait(30000); // Gemini, the ledger and PayPal MCP answer within this
  sh('pkill', '-INT', 'screenrecord');
  await new Promise((r) => recorder.on('exit', r));
  await wait(1500);
  const raw = path.join(out, 'ask-raw.mp4');
  execFileSync(adb, ['pull', '/sdcard/ask.mp4', raw]);
  const file = path.join(out, `ask-raysto-${new Date().toISOString().slice(0, 10)}.mp4`);
  execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-i', raw, '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', '-an', file]);
  fs.unlinkSync(raw);
  console.log(file);
})().catch((e) => { console.error(e.message); process.exitCode = 1; });
