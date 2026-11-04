# Raysto video projects

**Motion design for the AI-with-PayPal story** follows the [motion guide](MOTION-GUIDE.md): tools, colours, movement, the scene list and honesty rules. The first scene is **MoneyBrainTest**, a 15-second animated diagram in `src/motion/MoneyBrain.tsx`.

The newest judge-facing opening is **RaystoJudges38**: an original 38-second editorial collage segment to follow the founder's 10-second introduction. See the [research brief](JUDGES-RESEARCH.md), [production notes](JUDGES-PRODUCTION.md) and [timed narration](JUDGES-NARRATION.txt). Its current local master is `../dist/raysto-judges-phase1-38s-pro-audio-1080p.mp4`, with licensed professional stock music and recorded paper effects. [Audio credits and reproduction](AUDIO-LICENSES.md). The previous synthesized-audio export is preserved.

The earlier longer film is **RaystoChallenge**, a 78-second landscape hackathon walkthrough: [story, capture provenance and narration guide](CHALLENGE-DEMO.md). Render it to `../dist/raysto-hackathon-demo-v2-1080p.mp4`. It combines an actual Android recording with native interface captures, connected operations, a genuine PayPal Sandbox handoff and explicitly simulated settlement.

The earlier **RaystoQuick** composition below remains available as the original 45-second product overview.

## Original film — Your table. In sync.

A 45-second, 1920 × 1080, 30 fps landscape product film. The edit uses actual native interface captures, a connected browser capture, kinetic type, screen-recorder-style crops, cursor accents, original Raysto artwork and an original electronic score. There is no voice-over; the message is readable with sound muted.

## Render and edit

```sh
npm ci
npm run dev
npx tsc
node render-previews.mjs
npx remotion render src/index.ts RaystoQuick ../dist/raysto-motion-tour-1080p.mp4 --codec=h264 --crf=18 --concurrency=4 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=192k
```

The preview script uses installed Windows Chrome by default. Override `RAYSTO_RENDER_BROWSER` for another local browser. The render CLI can use `--browser-executable` or Remotion's downloaded headless browser. All motion is deterministic and frame-driven in `src/Composition.tsx`.

Deliverables are saved in the repository's ignored `dist/` folder. Local preview frames and render bundles are in ignored `video/out/`. The committed `public/` files are sufficient to render the video without Firebase, PayPal, Google credentials or a working backend.

## Edit map

| Time | Scene | Source |
|---|---|---|
| 00:00–00:03.5 | Your table. In sync. | Native discovery capture + original table illustration |
| 00:03.5–00:09 | Discovery, table QR and menu | Native discovery and menu widgets |
| 00:09–00:15 | Diners + waiter in one room | Native room widget with recorded QA messages |
| 00:15–00:22 | Two vegetarian diners, $30 budget, $27 proposal | Historical successful Gemini response, shown by the actual app |
| 00:22–00:28.5 | Reviewed order reaches the kitchen | Existing submitted QA order #2; three items |
| 00:28.5–00:34 | Connected restaurant workspace | Actual AG Grid / AG Studio browser screenshot |
| 00:34–00:40 | $13.50 suggested individual share | Historical AI allocation proposal; no fabricated payment success |
| 00:40–00:45 | AI at the table. PayPal at checkout. | Raysto end card + original artwork |

## Capture provenance and limits

Native PNGs were rendered at 860 × 1800 from the project's real Flutter widgets using `tool/render_video_test.dart`, the bundled fonts and a read-only snapshot of the dedicated Sandbox QA restaurant, visit and order. This is an animated screenshot walkthrough, **not a recording of an uninterrupted physical-device session**. Pointer taps, motion and titles are editorial overlays. The screenshot harness stubs network operations and does not establish live streaming, device performance or interaction success.

The harness selects historical room messages for clarity. Discovery is a QA-only presentation projection. Prices, proposal wording and order state come from the existing QA records; this render did not send a new AI request or create, approve or capture a payment. The private input `.tooling/video-data.json` is intentionally excluded from source and distribution. New native captures require an authorized replacement snapshot; the supplied public PNGs need no private data.

The dashboard screenshot came from the connected browser session documented in `docs/release-candidate-2026-10-27.md`. UI and financial states are left as captured. The final payment scene explicitly says buyer approval and capture are pending. The film is a product overview, not completion evidence for the deferred Sandbox acceptance journey.

## Artwork, typography and sound

- `public/table-art.png`: the existing Raysto illustration, copied unchanged from `assets/images/raysto-table-story.png`.
- `public/screens/`: native application pixels and QA browser captures owned by this project. No invented UI or purchased stock footage.
- `public/fonts/`: unmodified Plus Jakarta Sans Regular, Medium and Bold, designed by Gumpita Rahayu / Tokotype. SIL Open Font License 1.1 is included beside the fonts. See `docs/assets.md` for upstream attribution.
- Shapes, cursor, title animation and brand motif: original composition code.
- `public/soundtrack.m4a`: original synthesized music, percussion, clicks and transition sounds. No third-party samples. Reproduce the WAV with `python make_soundtrack.py` (NumPy required), then encode with the command below from this directory.

```sh
ffmpeg -i out/original-score.wav -af loudnorm=I=-16:TP=-1.5:LRA=8 -ar 48000 -c:a aac -b:a 192k -f mp4 public/soundtrack.m4a
```

Project code and original assets follow the repository license; bundled fonts retain their OFL. Remotion has its own [license terms](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md), separate from the Raysto source license.
