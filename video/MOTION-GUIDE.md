# Raysto motion guide

How we make Raysto's motion design: animated diagrams that explain "AI with PayPal", placed between real product footage. Written 4 November 2026 for the hackathon film.

The full film waits for Fouad's go-ahead. Short test scenes are fine when he asks for them.

## Tools

Everything is code rendered to video. Nothing is generated footage.

| Need | Use | Where |
| --- | --- | --- |
| Film scenes, diagrams, titles, assembly with voice and music | Remotion 4.0.539 (React) | this folder, `src/` |
| Quick motion experiments in HTML and GSAP | HyperFrames 0.9.6 | `Desktop\video-studio\hyperframes` |
| 3D objects (only when a scene truly needs depth) | three.js inside Remotion | `Desktop\video-studio\remotion` has a working example |
| Captions and word timings from a voiceover | WhisperX (CPU, int8) | command line |
| Cutting silence and loading time out of screen recordings | auto-editor, FFmpeg | command line |

Claude Code skills to load before working: `video-studio` (picks the tool and holds the machine facts), then `remotion-best-practices`. For eases and timelines also use `gsap-skills:*`; for 3D use `threejs-*`; for captions use `remotion-captions`.

## The motion language

**Canvas.** Dark green-black with Raysto's colours, so the money flow glows. A light Material version is a palette swap in the scene's colour block.

| Token | Value | Used for |
| --- | --- | --- |
| Background | `#06120e`, glow `#0d2a21` | canvas, with a slow dot grid |
| Lime | `#d7f978` | Raysto, the café, the owner's approval |
| Mint | `#8fd9b6` | AI coworkers and what they propose |
| PayPal blue | `#2f8cff` | PayPal and money that has moved |
| Text | `#f6f7f2`, muted `#9fb3a8` | titles and labels |

**Type.** Plus Jakarta Sans from `public/fonts`. Headline 58 px bold, card titles 23–28 px bold, labels 17 px medium. Card titles never wrap.

**Movement.**
- One idea per 3 to 5 seconds. The headline changes when the idea changes.
- Things enter with `Easing.bezier(0.16, 1, 0.3, 1)` and cards pop with a spring (damping 16, stiffness 140).
- Lines draw in about 22 frames, then carry a slow dashed flow so the system feels alive.
- AI work shows as a shimmer along the card's foot, then a proposal chip.
- Approval is a ring that sweeps once around the owner, then a tick.
- Money is glowing dots travelling along a line, PayPal blue after PayPal.

## Scenes

**Built: the money brain** (`src/motion/MoneyBrain.tsx`, composition `MoneyBrainTest`, 15 s). The café, three AI coworkers proposing work, the owner approving with an identity check, PayPal paying the internet provider, a driver and a supplier, and a closing strip of real Sandbox ids.

**Next, when the film is approved:**
1. **Bill to payout.** A bill prints like a receipt, an AI scan line lights up vendor, amount and due date, the fields fly into a payable card, and the card flips to "Paid by PayPal Payout" with its batch id.
2. **The iceberg.** Above water: one QR code. Below: the AI coworkers, the ledger, Orders, Payouts, Disputes and the PayPal MCP server.
3. **Pay link.** A card flips to show its QR code; a phone scans it; the request turns paid with the capture id.
4. **Captures on a lock screen.** Real Sandbox captures stack up as notifications while the day's count rises.
5. **Dispatch.** Arcs from the café to drivers on a street map, one offer accepted, the driver paid.

## Film shape (under 3 minutes, 16:9)

1. The problem and who it is for, about 15 s.
2. The money brain, about 20 s.
3. Four loops of about 25 s: a motion intro, then real footage with captions, ending on the real PayPal id.
4. Proof, about 15 s: the graph lights up with the real ids and the public repo.

Cut loading screens. An AI voiceover is allowed. Never show the offline demo's simulated payment.

## Honesty rules

- Animated scenes are diagrams and say so on screen.
- Every PayPal id shown is real and comes from `docs/facts.json` or a Sandbox run log.
- No invented amounts presented as real. Payees shown being paid by PayPal must be ones that take PayPal; utilities that don't are "paid elsewhere".
- Everything PayPal is labelled Sandbox.
- No sandbox passwords or secrets in any frame.

## Technical rules

- Every animation is a pure function of the frame: `useCurrentFrame()` with `interpolate` or `spring`. No CSS transitions, timers, `requestAnimationFrame` or unseeded randomness. Remotion renders frames out of order in parallel tabs.
- Fonts load with `loadFont` from `public/fonts`.
- Keep scenes in `src/motion/` and register them in `src/Root.tsx`.

## Commands

```bash
cd video
npx remotion studio                                   # live preview
npx remotion render MoneyBrainTest out/money-brain-test.mp4
npx remotion still MoneyBrainTest out/f.png --frame=240
```

Check every render:

```bash
ffprobe -v error -show_entries format=duration:stream=width,height,r_frame_rate -of compact out/money-brain-test.mp4
ffmpeg -v error -y -i out/money-brain-test.mp4 -vf "select='eq(n\,95)+eq(n\,236)+eq(n\,330)+eq(n\,420)',scale=960:-1,tile=2x2" -frames:v 1 out/sheet.png
```

Look at the sheet, then watch the clip itself: stills show layout, not whether the timing feels right.
