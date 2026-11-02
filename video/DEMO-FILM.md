# RaystoDemo: the judges' demo film

A 2 min 25 s, 1920×1080, 30 fps film of the judges' path, for the Devpost video field. The export is `../dist/raysto-demo-1080p.mp4`; a copy is served at https://rays.to/demo.mp4. The code lives in `src/demo/` with its own entry point.

## Story

| Scene | What is on screen | Source |
|---|---|---|
| Hook, rule | "Lunch at a small café", then "AI coworkers prepare. You approve. PayPal moves the money." | Title cards |
| rays.to | The judges' page, "Try it now", the console signing in | Recording |
| 1 · Voice | A spoken counter order becomes ticket lines; lemonade flagged as not on the menu | Recording |
| 2 · Menu | The menu agent reads a printed menu: 14 dishes, 3 new, 1 price change, soup held back; approved | Recording |
| 3 · Order | "Two vegetarian lunches under $25…" → basket, one tap, PayPal's own approval page, capture `8DJ62510842222013`, ticket #9 | Recording |
| 4 · Payments | The payments agent reads PayPal through MCP (`PAYER_ACTION_REQUIRED`), proposes the release, approved after the identity check | Recording |
| 5 · Photo | Gemini draws the croque monsieur; scanned, approved | Recording |
| Staff tablet | Counter, kitchen and agents screens | The app's screens rendered with demo data (`tool/render_staff_test.dart`), labelled as such |
| Evidence, outro | 9 captures and a refund, 12/12 live AI evaluation, 326 automated tests, PayPal MCP; "Try it at rays.to" | Title cards |

## Footage provenance

- Recorded on 2 November 2026 against production (rays.to, ops.rays.to with console 0.15.1, api.rays.to with backend 0.13.9, PayPal Sandbox) by a Playwright script at a 1280×720 viewport. The session's PayPal capture is `8DJ62510842222013`; see session 5 in `../docs/paypal-acceptance-2026-10-31.md`.
- `public/demo/footage/` is not in git (large files). `main.webm` is the console session; `paypal.webm` is PayPal's approval page, trimmed to start at the review screen so the Sandbox buyer's login never appears.
- `src/demo/footage.ts` is the edit list. Any cut faster than real time is waiting (Gemini or a page load), and the film labels it "sped up" with the real number of seconds.

## Audio

- **Voice:** [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) (Apache-2.0), voice `af_heart`, generated offline; the lines are in `src/demo/narration.json` and appear as captions. To use a human recording of the same lines instead, put one WAV per line in `public/demo/voice/` with the same names and update the seconds in `src/demo/voice-timing.ts`; each scene stretches to fit its line.
- **Music:** "Gimme that Groove!" by Michael Ramir C., via Mixkit, under the Mixkit Stock Music Free License (see `AUDIO-LICENSES.md`), ducked under the voice.

## Rebuild

```sh
../.tooling/tts-venv/Scripts/python make_demo_voice.py af_heart
npx remotion still src/demo/index.ts RaystoDemo out/demo-review/f.png --frame=900 --scale=0.5
npx remotion render src/demo/index.ts RaystoDemo ../dist/raysto-demo-1080p.mp4 \
  --codec=h264 --crf=18 --concurrency=4 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=256k
```
