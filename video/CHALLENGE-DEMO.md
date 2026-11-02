# Raysto — AI at the table, PayPal at checkout

The revised hackathon film tells one concrete story: two diners request vegetarian food under $30, review a $27 proposal, coordinate with staff and prepare individual $13.50 shares. It is 78 seconds, 1920 × 1080, 30 fps, with original music and frame-driven motion. There is no recorded voice-over; it works with captions and music, and the optional narration below can be recorded separately.

## Deliverables

- `../dist/raysto-hackathon-demo-v2-1080p.mp4`: H.264/AAC landscape master.
- `../dist/raysto-hackathon-demo-v2-thumbnail.png`: cover frame.
- `../dist/raysto-hackathon-demo-v2-contact-sheet.jpg`: visual review sheet.
- `../dist/raysto-hackathon-demo-v2-manifest.json`: encoding, provenance and verification details.
- `../dist/raysto-hackathon-demo-v2-SHA256SUMS.txt`: file integrity checksums.

These exports are local, ignored artifacts. Nothing is uploaded to YouTube or published automatically.

## Story and optional founder narration

| Time | On screen | Optional narration |
|---|---|---|
| 0–4s | Group decision, multiple interfaces | “Dinner is a group decision. Ordering and paying should work together.” |
| 4–10s | Two diners and their waiter share one visit | “Raysto brings diners, their waiter and AI into one room—with a clear audience.” |
| 10–17s | Actual Android recording of the request and response | “Two vegetarian diners. Thirty dollars. Something to share. The group asks Raysto.” |
| 17–25s | Actual recorded tool sequence and priced proposal | “Gemini retrieves the menu and calls Raysto’s pricing tools. The result: three dishes, twenty-seven dollars.” |
| 25–31s | Native review dialog, actual submitted order | “The host reviews the exact basket. The same items reach the kitchen.” |
| 31–37s | Persisted service and order events | “Requests and order progress stay in the conversation, with staff acknowledgement.” |
| 37–45s | Connected AG Grid / AG Studio manager view | “Managers can ask which tables requested the bill and still owe money—and see the actual records.” |
| 45–53s | Per-item allocation, two equal shares | “AI suggests a split. Backend rules calculate each item’s share: thirteen dollars fifty per diner.” |
| 53–60s | Native share review, genuine Sandbox login | “Each payer reviews their share and opens PayPal. The assistant cannot approve their purchase.” |
| 60–68s | Clearly labelled simulated settlement | “This payment outcome is simulated: one share, then the other, brings the illustrated balance to zero.” |
| 68–73s | Sanitized direct PayPal MCP read evidence | “PayPal MCP adds authorized payment-status investigation. This direct Sandbox read is verified.” |
| 73–78s | Closing product proposition | “Shared decisions. Individual control. Raysto: AI at the table, PayPal at checkout.” |

This narration is a guide, not a generated voice track. Allow pauses or shorten wording to suit the speaker.

## What is recorded, replayed and simulated

### Actual native recording

`public/native-room-scroll.mp4` is a screen recording from the project's Android app running in a local emulator, signed into the connected QA diner account. It shows the existing room, live connection indicator, stored request, formatted assistant response and scrolling. The edit crops device chrome and speeds up the clip; it is not a continuous recording of the full end-to-end journey or a physical-device pilot.

### Actual application screens and historical review

Native PNGs in `public/screens/` are rendered by the real Flutter widgets, bundled fonts and `tool/render_video_test.dart`, using a private snapshot of the dedicated QA restaurant, visit and order. Historical Gemini text, prices, tool names and submitted order #2 come from those records. No new Gemini run was performed for this film.

For the two approval-dialog captures only, the harness resets the recorded proposal to an in-memory review state with a future expiry. This lets the existing native dialogs open again. It does not update the backend, approve a proposal or capture money. The film labels these scenes as historical/demo replay. Other screenshots may show the capture harness's connection indicator; they are not live-stream acceptance evidence.

The connected dashboard and manager query are actual earlier browser captures from `docs/screenshots/story/`, associated with the QA visit. They are animated as stills in this edit. See `../docs/release-candidate-2026-10-27.md` for integration evidence and limitations.

### Real PayPal handoff; demo settlement

The English PayPal Sandbox login screen was captured from a newly prepared, unapproved USD 13.50 checkout for the existing QA visit. No buyer signed in or approved it. That checkout was cancelled after capture; no funds moved.

The following $27 → $13.50 → $0 settlement is an editorial illustration authorized by the user. It carries a persistent **DEMO · SIMULATED PAYMENT OUTCOME** label. It does not depict a verified capture, receipt, refund or backend balance update. The outstanding QA bill was not settled by this video task.

The MCP scene reflects an earlier successful **direct** official PayPal MCP `get_order` read for a USD 13.50 Sandbox order in `PAYER_ACTION_REQUIRED`. It is separate from the new browser screenshot and is not proof of a successful Gemini-to-MCP conversational run. See `../docs/paypal-mcp.md` and the release evidence. There is no claim of unrestricted AI payment execution.

This film is a clearly disclosed demonstration segment. It does not replace the still-pending real buyer approval/capture/refund acceptance or the restaurant pilot.

## Formatting fix used in these captures

Assistant messages now use `AssistantMessageBody` and `flutter_markdown_plus` so bold/list syntax renders as formatted prose instead of visible `**`. Human messages stay literal. Model-supplied images are replaced by their alternative text, and links do not automatically open external destinations.

The focused widget checks and analyzer passed; a native Android debug build was created and installed for the recording. This task did not publish a new production service or release APK.

## Edit and render

```sh
npm ci
npx tsc
node render-challenge-previews.mjs
npx remotion render src/index.ts RaystoChallenge ../dist/raysto-hackathon-demo-v2-1080p.mp4 --codec=h264 --crf=18 --concurrency=4 --pixel-format=yuv420p --audio-codec=aac --audio-bitrate=192k
```

Use `--browser-executable` to select an installed Chrome. `src/ChallengeFilm.tsx` contains the timeline, copy, screen crops and motion. The earlier `RaystoQuick` composition is retained. Captured public assets let the film render without backend access or credentials. Do not commit the private capture snapshot or QA account files.

`make_challenge_score.py` creates the original 78-second electronic score with NumPy. Encode it with:

```sh
ffmpeg -i out/challenge-score.wav -af loudnorm=I=-16:TP=-1.5:LRA=8 -ar 48000 -c:a aac -b:a 192k -f mp4 public/challenge-score.m4a
```

Application pixels, title graphics, motion and synthesized sound are project-created. Plus Jakarta Sans retains its bundled SIL Open Font License. The PayPal capture shows the genuine provider page for identification, without implying endorsement. See the video README and `../docs/assets.md` for asset and software licensing.
