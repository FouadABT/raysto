# Demo video plan (under 3 minutes)

A shot list for the Devpost video, built from footage recorded live against `api.rays.to` and PayPal Sandbox. Footage files are in `dist/video-footage/`, which git ignores; regenerate them with the scripts named below. Everything on screen is PayPal Sandbox, and every payment shown really completed in Sandbox (ids in [paypal-acceptance-2026-10-31.md](paypal-acceptance-2026-10-31.md)).

## Footage on disk

| File | Length | What it shows | Made with |
|---|---|---|---|
| `counter-tablet-2026-11-01.mp4` | 74 s, 1920×1200 | Tablet counter: three items, $33.00, PayPal QR, "Payment received", ticket #3 with pickup code, the kitchen board taking #3 to Ready | `node tool/record_counter_footage.cjs` |
| `counter-buyer-phone-2026-11-01.mp4` | 7 s, phone size | The buyer approving that $33.00 on PayPal's Sandbox page, then "Thanks for using PayPal" | same script |
| `console-2026-11-01.mp4` | ~33 s, 1920×1080 | ops.rays.to: today's $33.00 by channel, orders grid, the #3 panel with its PayPal capture id, payments with the two $13.50 table shares and the $5 refund | `node tool/record_console_footage.cjs` |
| `ask-raysto-2026-11-01.mp4` | 35 s, 1920×1200 | The manager taps "Which PayPal payments are unresolved?" on the tablet; Raysto answers from the ledger: nothing needs attention | manual adb recording (see note) |
| `ask-raysto-answer-2026-11-01.png` | still, 2560×1600 | The same screen after asking "Are any PayPal payments unresolved? Did checkout 9 really go through at PayPal?": "PayPal reports COMPLETED for checkout 9: USD 33.00. Source: PayPal MCP." | screenshot on the tablet |
| `../raysto-judges-phase1-38s-pro-audio-1080p.mp4` | 38 s | The existing judges segment from `video/` | `video/` Remotion project |

Note: the emulator's on-screen keyboard is too slow to film typing. That is why the clip uses the one-tap suggestion and the PayPal MCP answer is a still. `tool/record_ask_footage.cjs` types and films a full question on a faster emulator or a real tablet.

## Timeline

| Time | Shot | Narration (suggested) |
|---|---|---|
| 0:00–0:10 | Fouad on camera | Who you are and the problem: a snack bar runs on a till, paper tickets and a card terminal that don't talk to each other. |
| 0:10–0:48 | Judges segment (existing render) | As written in `video/JUDGES-NARRATION.txt`. The captures have now been demonstrated, so the "do not describe a successful capture" note no longer applies. |
| 0:48–1:05 | Tablet counter, 0–25 s of the clip (speed up the menu taps 1.5×) | "Lunch at a snack bar. The cashier taps three items and shows a PayPal QR code." |
| 1:05–1:12 | Buyer phone clip, full screen or as an inset over the QR | "The customer pays on their own phone, in PayPal." |
| 1:12–1:25 | Tablet counter, "Payment received" to the end | "Raysto captures the payment and prints ticket number three with a pickup code. The kitchen already has it." |
| 1:25–1:55 | Console clip | "The owner sees every channel in one place: counter, pickup and table orders, each with its PayPal capture id. A table's bill split into two $13.50 shares, each paid by a different person. A $5 refund, and cash kept apart from PayPal." |
| 1:55–2:25 | Ask Raysto clip (15 s), then the answer still with a slow push-in (15 s) | "The manager asks Raysto: is anything unresolved, and did that sale really go through? Raysto checks the ledger, then asks PayPal through the PayPal MCP server, and says where each answer came from. It reads payments; it never moves money." |
| 2:25–2:45 | Closing card: rays.to, "PayPal Orders v2 · Webhooks · MCP", "Gemini with human approval", "AG Grid console", repo link | "Raysto: the counter, the kitchen and the table on one system, with PayPal for every payment and AI that helps but never pays for anyone." |

The total is 2:45, which leaves 15 s of margin under the 3-minute limit.

## What only Fouad can do

- Record the 10-second introduction and the voice-over.
- Optional but stronger: film a real phone scanning the tablet's QR code with the Android build (`dist/raysto-0.12.1-2015-android-arm64.apk`). Use it in place of the browser buyer clip.
- Do the final edit and audio mix (the `video/` project already has a licensed music bed), then upload to YouTube or Vimeo and paste the link into Devpost.

## Rules for the edit

- Keep "PayPal Sandbox" visible or spoken whenever a payment is on screen.
- Don't reuse the "simulated settlement" part of the older 78-second film. Real captures now exist, so show those instead.
- Don't show the offline demo mode.
