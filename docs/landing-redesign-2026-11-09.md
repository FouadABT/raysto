# Raysto landing redesign — 9 November 2026

Implemented from the user-supplied `Raysto_Landing_Design_and_Motion_Guide.pdf`, version 1.0. The PDF is a design reference, not permission to publish, send messages, invent integrations or replace existing business rules.

## Scope and composition

The operator-focused homepage is `/`. The existing guest experience remains `/discover`, its local account chooser remains `/login`, and connected sign-in remains `/ops`. Production deployment remains held. No backend, native app, database, Nginx, AWS or Awhar service change is part of this work.

| Guide section | Implementation |
| --- | --- |
| Hero and navigation | Three-line headline, photo/dashboard/phone layers, principal demo action, guest route and responsive navigation. |
| Connected order journey | Choose → Pay → Prepare → Serve, with linked entrance beats and labeled checkout illustration. |
| Operations | Interactive sample table selection, keyboard-accessible kitchen/menu tabs and selected-table details. |
| Money | Full-width forest section; bills, receivables and a paid order remain separate categories. Amounts render exactly rather than counting up. |
| AI | Source-to-proposal sequence, source and review dialogs, and a final Needs review / Not posted state. No approval or financial API. |
| Team and guest | Seven keyboard-accessible role tabs, a stable local capability panel, illustrative café photography and a guest-menu preview. |
| FAQ | Native disclosures, first answer open, complete copy in the initial HTML. |
| Final action | Lime closing section, original SVG café drawing and email-demo route. |

All marketing fixtures are deterministic and local. EUR amounts are illustrative, independent of the connected USD Sandbox venue. Sample selections grant no app permissions. The guest-discovery destination continues to identify itself as an interactive demo.

## Theme, assets and architecture

The marketing system is scoped under `.raysto-landing`: forest `#173F35`, sage `#E6EDE2`, off-white `#F6F7F2`, lime `#D7F978`, white, and readable secondary copy `#4D6358`. It does not replace the guest or Ops theme. Existing Plus Jakarta Sans and Fraunces supply real bundled weights and the italic editorial accent, using the guide's allowance for established equivalents. Material Symbols remains the icon family.

The original generated café image is 1536×1024, encoded as `web/public/images/landing/cafe-service.webp` (160,058 bytes). It depicts a server, cappuccino and croque monsieur and is labeled illustrative/AI-generated. It is not a customer endorsement. The selected output was generated for this task; no reference-page raster is shipped as the webpage. The source PNG remains in the Codex generated-images directory. The small salad derivative comes from the existing licensed Anna Pelzer photograph; attribution and license remain in `docs/assets.md`. `salad-preview.webp` is a 480px WebP derivative (36,790 bytes).

The homepage has a dedicated synchronous Server Component. The old optional catch-all becomes a required catch-all for existing guest/demo paths. Loading UI is preserved in those routes, Ops and Judges instead of wrapping the public homepage in a global streaming fallback. The homepage still evaluates `RAYSTO_OPS_ONLY=true` at request time and redirects to `/ops` for the console-only host mode.

Static icons remain server-rendered rather than creating one client boundary per icon. Only product interactions, preference controls and motion hydrate. Essential copy, links and FAQ answers are server-rendered and remain usable without JavaScript. GSAP 3.15.1 and `@gsap/react` 2.1.2 are pinned. Native scrolling is retained; this page does not initialize Lenis, Motion, a 3D runtime, pinning or a second scroll ticker.

Motion uses scoped `useGSAP`, matchMedia conditions and complete teardown. The hero has an overlapping entrance, journey connectors draw in sequence, money rows receive one emphasis, evidence settles into a reviewable proposal, role changes fade briefly, and the café line drawing completes once. Material/CSS owns control feedback. The OS preference and the app preference (`raysto.reduceMotion`) combine; either can remove nonessential motion. No number or decorative scene loops indefinitely.

Integration references: [GSAP React](https://gsap.com/resources/React/), [matchMedia](https://gsap.com/docs/v3/GSAP/gsap.matchMedia()/), [ScrollTrigger](https://gsap.com/docs/v3/Plugins/ScrollTrigger/), and the installed Next.js 16.4.3 server/client, loading and Image documentation.

## Email demo and launch limits

The user selected an email demo. `/contact` prepares a `mailto:` draft or copies inquiry text. It never sends a message or confirms a booking. The draft remains in the browser tab's session storage until cleared, with an explicit unavailable-storage fallback.

No real booking inbox was supplied. Without `RAYSTO_DEMO_CONTACT_EMAIL`, the email draft is deliberately unaddressed, and the interface explains that the recipient must be added in the email app. A configured address is validated server-side before becoming the public mail recipient. No mailbox was created or verified, and no email-client delivery was tested.

No published Privacy or Terms destinations were supplied. The footer identifies publication as pending rather than inventing policies or dead links. These remain requirements for a commercial launch, not claims satisfied by this preview.

## Validation and evidence

Baseline source: `c201bf9e00b98454e8417fc2645782a69acd6243`. Final code/artifact identity and measured results are recorded in `landing-validation-2026-11-09.json`.

- Unit suite: 181 passed, zero failed.
- Homepage browser suite: 14 passed in development, followed by 15 passed on the final production candidate, including a 200%-desktop-reflow equivalent (720×500 CSS pixels at 2× density for a 1440×1000 physical viewport), 320/390/768/1024/1440/1920px, native no-JavaScript reading/navigation/disclosure, local-only actions, keyboard tabs, modal focus return, OS/app reduced motion, enlarged text, re-entry and inquiry-draft recovery.
- Existing workflow regression: five passed — guest WebGL/fallback behavior, simulated checkout/service completion, menu draft/availability behavior and the Ops investigation entry.
- The initial local environment redirected `/` to Ops because console-only mode was enabled. The marketing preview explicitly sets it false. No deployed configuration was changed.
- The no-JavaScript check caught the old global loading boundary. After routing/loading scopes were corrected, the complete reading and FAQ journey passed.
- A production type check found obsolete generated declarations referencing the renamed optional catch-all. Only the resolved `.next/types` and `.next/dev/types` generated directories were cleared before rebuilding; no source declarations were forged.

Production compilation, TypeScript and standalone packaging passed. A local console-only runtime check returned HTTP 307 to /ops using the same build with RAYSTO_OPS_ONLY=true. Production-mode browser results and local performance measurements are recorded in the machine validation record. Local performance is synthetic, not field Core Web Vitals or a physical-device claim. No human usability or provider acceptance results are invented.

Rendered evidence: `web/test-results/marketing/home-390.png`, `home-1440.png`, `hero-390.png`, `hero-1440.png`, `ai-390.png` and `ai-1440.png`. Separate normal/reduced-motion recordings are retained under the browser output directory. Logs and production diagnostics are under `.tooling/landing-*.log` and `.tooling/landing-production/`.

## Final local production measurements

Implementation source: 7cde912aef636a995e7c91da51673225ecfcd29a. Build ID: fAA9PfqphyQYmd1HF-Kk_.

| Condition | LCP | CLS | Startup intervals within 20ms | Maximum recorded input-event duration |
| --- | ---: | ---: | ---: | ---: |
| 1440×1000, reference CPU | 564ms | 0.0040 | 95.2% of 105 | 72ms |
| 390×844, reference CPU | 312ms | 0.0094 | 96.7% of 123 | 96ms |
| 1440×1000, 4× browser CPU throttle | 1056ms | 0.0071 | 66.7% of 21 | 184ms |

Headless Edge 157.0.4341.42, Windows, Intel Core Ultra 7 155H, 22 logical CPUs, approximately 32GiB RAM; localhost without artificial network throttling. Initial matching network script resources totalled approximately 187.4KiB encoded. Matching initial image resources were approximately 242KiB desktop and 193KiB phone, including matching preloads. These are network-resource totals, not a measured incremental JavaScript cost over the old application; inline HTML/scripts are excluded.

The frame sample covers a fixed 2.2-second startup window and is not a complete interaction or field benchmark. The smaller 4× frame count reflects rendering stalls. The throttled startup still needs further optimization before claiming smoothness on slower devices. The maximum recorded Event Timing duration is not field INP, and this small authored task set does not establish field Core Web Vitals. CLS follows the browser definition, excluding recent-input shifts.

No console/page errors or API requests were observed in these three runs. The first diagnostic result is retained separately: static icons were subsequently kept on the server, and resource accounting was corrected to include matching preloads. It is not used as the final candidate result.

## Running and promotion

Use the existing Node 24 toolchain from `web/`, with `RAYSTO_OPS_ONLY=false`. For the isolated candidate, set `RAYSTO_ISOLATED_PREVIEW=guest-design` and build/start its standalone output. `playwright.marketing.config.ts` runs the homepage checks against an already-running local production server; it does not start a development server implicitly.

Keep console-only deployments on their existing setting. No Linux deployment archive, remote resource preflight, server promotion or public-site claim is established here. Production promotion remains separate, including the existing shared-host safety and resource gates.
