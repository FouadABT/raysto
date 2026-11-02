# Raysto judging segment — production notes

Composition: `RaystoJudges38`. Exactly 1,140 frames at 30 fps, 1920 × 1080. Insert at 00:10 after the founder's own introduction; the segment finishes at 00:48 of the assembled submission. The ending deliberately opens into the next demonstration without fading to black.

## Render

```sh
npm ci
python replace_judges_audio.py --download --prepare-only
npx tsc
node render-judges-previews.mjs
npx remotion render src/index.ts RaystoJudges38 ../dist/raysto-judges-phase1-38s-pro-audio-1080p.mp4 --codec=h264 --crf=18 --concurrency=4 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=256k
```

Select installed Chrome with `--browser-executable` when needed. Frame-driven motion, paper shapes, paths, stamps, object movement and camera-like composition changes are authored in `src/JudgesFilm.tsx`. Reference-inspired techniques do not reuse the supplied Weepo footage or assets.

## Audio and narration

The current MP4 uses licensed stock music: **“Gimme that Groove!” by Michael Ramir C.**, with three quiet recorded paper effects from Mixkit. All synthesized music, percussion and clicks have been removed from this revision. See [audio sources, licensing and reproduction](AUDIO-LICENSES.md). The 38-second picture stream is identical to the original export; its SHA-256 comparison is recorded in the new export manifest.

`JUDGES-NARRATION.txt` provides a timed English narration for the founder. Record with the same microphone used in the 10-second introduction for continuity. Avoid speeding up speech to meet the limit. The current export has no voice-over. Its music bed is approximately -19 LUFS; adjust underneath the actual narration during final assembly.

The export is designed to remain intelligible without narration: project purpose, Gemini tool use, host approval, exact shares, PayPal approval, MCP reads and the connected console all appear on screen. Longer explanations and live evidence belong in the next phase.

## Asset provenance

The full final image prompt and generation method are preserved in [generation.txt](public/judges/generation.txt). The resulting project asset is [table-people.png](public/judges/table-people.png).

- `public/judges/table-people.png`: original AI-generated illustrative artwork, produced through the built-in image generation tool on 27 October 2026. It depicts two diners and a waiter; it is not a photograph of actual pilot participants. The original output is preserved outside the repository; this copy is the self-contained project asset. Generation brief: monochrome forest/ivory editorial photography, two diners at a small table and waiter behind, separated faces, vegetarian food, no text or logos, isolated silhouette, subtle film texture.
- `public/screens/`: actual Flutter-widget and connected-browser captures from the existing QA journey. Historical review capture details are in `CHALLENGE-DEMO.md`. This segment does not claim that every illustrated event is a new live session.
- `public/native-room-scroll.mp4`: actual connected Android emulator screen recording. Cropping and speed are editorial.
- `public/fonts/CormorantGaramond.ttf`: variable Cormorant Garamond from [Google Fonts](https://github.com/google/fonts/tree/main/ofl/cormorantgaramond), with its OFL alongside it. Used only for film headlines; the app's design tokens are unchanged.
- `public/fonts/Caveat.ttf`: variable Caveat from [Google Fonts](https://github.com/google/fonts/tree/main/ofl/caveat), with its OFL alongside it.
- Plus Jakarta Sans and its existing OFL remain bundled for labels and brand continuity.
- `public/judges/licensed-score.m4a`: current synchronized stock-audio intermediate, excluded from Git. Reproduce with `replace_judges_audio.py`; third-party licenses are in `AUDIO-LICENSES.md`.
- `public/judges/score.m4a`: superseded synthesized soundtrack, retained for the original export only. It is no longer used by `RaystoJudges38`.
- Paper silhouettes, grain, ink paths, labels, receipt layouts and all other motion elements are original code-native graphics. Financial values are the existing QA example, not new provider results.

## Claims and assembly

The segment states that the buyer approves through PayPal; it never shows a successful capture or zero remaining balance. PayPal is identified as Sandbox. MCP is explicitly read-only and its direct verification is separate from conversational acceptance. The $27 basket, submitted order and manager query have earlier evidence. Current gates remain in `../docs/project-status.md`.

The [research brief](JUDGES-RESEARCH.md) ties this opening to the competition criteria, primary winner stories and judge advice. It is an editorial explanation to precede the working demonstration, not a substitute for real acceptance footage. No app/backend changes, deployments or paid provider probes are needed for this video production.
