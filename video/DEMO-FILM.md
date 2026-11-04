# RaystoDemo v2: the judges' demo film

Under three minutes, 1920×1080, 30 fps, built around the money agents. The export is `../dist/raysto-demo-v2-1080p.mp4`; a copy is served at https://rays.to/demo.mp4 once published. The code lives in `src/demo/` with its own entry point (`src/demo/index.ts`). The first cut (2 November, five demos) is in git history.

## Story

| Scene | Seconds (planned) | What is on screen | Source |
|---|---|---|---|
| Hook | 6 | "A small café. Its AI coworkers run the money. You approve. PayPal moves it." | Title card |
| rays.to | 8 | The judges' page, one click into the console, nine demo cards | Recording |
| 1 · Close the day | 18 | The close agent reads PayPal's transactions through MCP (or the ledger, and says so), explains the gaps, the manager signs off | Recording |
| 2 · Pay the team | 22 | Clocked shifts → wages and tips as one batch → identity check → PayPal Payouts batch id | Recording |
| 3 · Bill the caterer | 18 | One-line request → priced quote with a deposit → "Send the invoice"; if Invoicing is still off on the Sandbox app, the honest message is shown and the `catering_pending` line is used | Recording |
| 4 · Settle a complaint | 20 | Complaint → kitchen ticket and PayPal capture via MCP → partial refund proposal → identity check → PayPal refund id | Recording |
| 5 · Chase a payment | 14 | `PAYER_ACTION_REQUIRED` via MCP → release after approval | Recording |
| 6 · Order in one sentence | 24 | Basket → one tap → PayPal's own page (trimmed past the login) → capture id and kitchen ticket | Recording |
| 7–9 · Montage | 16 | Menu reading, the voice order, the dish photo | Recording |
| Evidence | 10 | Fourteen coworkers; PayPal Orders, Payouts, Invoicing, Refunds, Transactions, Disputes; the MCP tool split; the run's real ids | Title card |
| Outro | 5 | "Try it at rays.to" | Title card |

## Honesty rules

- Every product shot is a screen recording of the live judge path on production, PayPal Sandbox. The "PayPal Sandbox · recorded live, {date}" chip appears only on recorded scenes.
- A cut faster than real time is waiting; the film badges it "sped up ×N" only when N ≥ 2 (a 1.4× trim is not sped up).
- No app stills or mock-ups. The tablet PNGs in `public/demo/` are no longer used.
- PayPal's login page is trimmed out; the buyer's email never appears.
- The catering scene uses the `catering` narration only when the invoice was really sent in the recording; otherwise `catering_pending` (set `CATERING_LINE` in `Demo.tsx`).
- The evidence card's ids (`STATS` in `Demo.tsx`) are replaced by the ids of the recording's own run.

## Footage provenance

- Recorded by `record_demo_v2.cjs` (kept outside the repository: it reads the private Sandbox buyer file) at a 1280×720 viewport, device scale 1.5, into 1920×1080 WebM. `public/demo/footage/` is not in git (large files); `events.json` there holds the step marks.
- `src/demo/footage.ts` is the edit list; `src/demo/narration.json` the spoken lines, which are also the captions.

## Audio

- **Voice:** [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) (Apache-2.0), voice `af_heart`, generated offline by `make_demo_voice.py`; a human recording of the same lines can replace the WAVs in `public/demo/voice/` (update `src/demo/voice-timing.ts`).
- **Music:** "Gimme that Groove!" by Michael Ramir C., via Mixkit, under the Mixkit Stock Music Free License (see `AUDIO-LICENSES.md`), ducked under the voice.

## Rebuild

```sh
../.tooling/tts-venv/Scripts/python make_demo_voice.py af_heart
npx remotion still src/demo/index.ts RaystoDemo out/demo-review/f.png --frame=900 --scale=0.5
npx remotion render src/demo/index.ts RaystoDemo ../dist/raysto-demo-v2-1080p.mp4 \
  --codec=h264 --crf=18 --concurrency=4 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=256k
```
