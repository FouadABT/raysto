# RaystoPromo60: the one-minute tour

A 59.6-second, 1920×1080, 30 fps overview of Raysto across a phone, a tablet and the web. The export is `../dist/raysto-promo-60s-1080p.mp4`. The code lives in `src/promo/` with its own entry point, so the other films in this project are unchanged.

## Story

| Scene | Device | Footage |
|---|---|---|
| Intro | Phone, tablet and browser line up, then the camera dives into the tablet | stills from the recordings below |
| 01 Counter | Tablet | three items rung up, total $33.00, PayPal QR code |
| 02 Customer pays | Tablet and phone | a Sandbox buyer approves on PayPal's page |
| 03 Kitchen | Tablet | "Payment received", ticket #3 with its capture id, then the kitchen board taking #3 to Ready |
| 04 At the table | Three phones | the table room, Gemini's $27 basket, host approval, split into $13.50 shares, review before PayPal |
| 05 Owner | Browser | ops.rays.to: today's figures, the #3 panel with its PayPal capture id, payments and the $5 refund |
| 06 Ask Raysto | Tablet | the manager asks; Raysto answers from the ledger, then from PayPal through MCP |
| Outro | — | "AI helps. People approve. PayPal moves the money." and the stack |

## Footage provenance

- The tablet, buyer-phone, console and Ask clips were recorded on 1 November 2026 against `api.rays.to` in PayPal Sandbox; see `../docs/paypal-acceptance-2026-10-31.md`.
  - The tablet clips come from the Android release build running on the `Raysto_Tablet` emulator.
  - The $33.00 counter sale is checkout 9, capture `55W092765M630635H`.
  - The scripts that made them are `../tool/record_counter_footage.cjs`, `../tool/record_console_footage.cjs` and `../tool/record_ask_footage.cjs`.
- The Ask Raysto scene cuts from the one-tap question clip to a real screenshot of the typed question's answer. The emulator keyboard was too slow to film typing.
- The table-scene phones use `native-room-scroll.mp4` and the Flutter widget captures in `public/screens/`, described in `CHALLENGE-DEMO.md`. The two $13.50 shares were captured live on 31 October (`4MG67343RS1841023`, `47E23175WJ603464A`).

## Audio

- **Voice:** [Kokoro-82M](https://huggingface.co/hexgrad/Kokoro-82M) (Apache-2.0), voice `af_heart`, generated offline with [kokoro-onnx](https://github.com/thewh1teagle/kokoro-onnx) (MIT). The lines are in `src/promo/narration.json`.
- **Music:** "Gimme that Groove!" by Michael Ramir C., via Mixkit, under the Mixkit Stock Music Free License (see `AUDIO-LICENSES.md`). It is ducked under the voice. Credit it in the video description as for the judges film.

## Rebuild

```sh
# voice: needs ../.tooling/tts-venv with kokoro-onnx and soundfile,
# and the model in ../.tooling/kokoro/ (kokoro-v1.0.onnx, voices-v1.0.bin)
../.tooling/tts-venv/Scripts/python make_promo_voice.py af_heart

node render-promo-previews.mjs            # review stills in out/promo-review/
npx remotion render src/promo/index.ts RaystoPromo60 ../dist/raysto-promo-60s-1080p.mp4 \
  --codec=h264 --crf=18 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=192k \
  --browser-executable="C:/Program Files/Google/Chrome/Application/chrome.exe"
```

To try another voice, change the argument, for example `am_michael` or `bf_emma`. Scene timing follows the new lengths automatically.
