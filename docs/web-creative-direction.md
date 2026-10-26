# Raysto web — The good company edition

25 October 2026. A creative redesign of the existing Phase 1 demo. Guest and restaurant workflows retain the same domain/store, role guards and draft handling.

## Direction

A contemporary Casablanca supper club: warm paper, deep olive, citrus and a restrained tomato accent. The guest experience uses an asymmetric editorial masthead, custom perforated-ticket CTA, circular restaurant stamp, drawn olive branches, original table photography and a dining-room story. The workspace carries the identity through a dark olive navigation rail, compact ruled surfaces and a continuous metric strip. It retains efficient grids and explicit status controls.

Plus Jakarta Sans remains the functional text face. Self-hosted Fraunces supplies real variable display and italic faces, including optical size, softness and wonk axes. Material role tokens, Material Symbols, visible focus and 48px primary targets remain the foundation. The visual layer lives in `web/src/app/supper-club.css`; it changes expression without changing business rules.

## Research and interpretation

Research covered 2026 design/typography commentary, hospitality websites, award galleries and current animation documentation. These are references for the direction, not a claim that every example launched or won an award in 2026.

| Reference | What informed Raysto |
| --- | --- |
| [Creative Bloq: typography trends for 2026](https://www.creativebloq.com/design/fonts-typography/breaking-rules-and-bringing-joy-top-typography-trends-for-2026) | Characterful display type and expressive editorial contrast; interpretation of design commentary, not a universal trend rule. |
| [Adveris: 2026 innovative websites selection](https://www.adveris.fr/sites-internet-innovants-de-l-annee/) | Its designers emphasize identity and intentional interaction. Their subjective annual selection includes earlier work. |
| [Olive et Gourmando](https://oliveetgourmando.com/) | Live page visually inspected: expressive restaurant typography and direct hospitality language. No logo, font file, photograph or layout copied. |
| [Awwwards: Three.js gallery](https://www.awwwards.com/websites/three-js/) | Spatial web work as a reference category. Raysto uses a small food-related object while keeping ordering directly accessible. |
| [Motion: scroll-linked animation](https://motion.dev/docs/react-use-scroll) | Target-relative scroll progress and transforms for the photograph and circular stamp. |
| [Motion: accessibility](https://motion.dev/docs/react-accessibility) | Reduced-motion behavior. Implementation also subscribes directly to live media changes, covered by regression tests. |
| [React Three Fiber introduction](https://r3f.docs.pmnd.rs/getting-started/introduction) | Stable v9 compatibility with React 19. The v10 alpha was not selected. |
| [Lenis official repository](https://github.com/darkroomengineering/lenis) | Fine-pointer wheel smoothing with native touch behavior and dialog exclusions. |

Some requested award pages timed out and were not used as verified visual evidence. This was a focused research pass, not an exhaustive quantitative survey of all 2026 websites.

## Implementation

Verified against npm's stable tags on the work date: Next.js **16.4.3** (already installed), Motion **14.6.0**, Three.js **0.186.1**, React Three Fiber **9.8.2**, Lenis **1.3.27**, Fraunces package **5.3.0**. Exact versions and integrity are in `web/package-lock.json`.

- `experience.tsx`: scroll-linked imagery/stamp, generated-image story, olive drawing, smooth-wheel lifecycle, live system OR app motion preference.
- `table-sculpture.tsx`: original ceramic plate and olive meshes. Pointer and scroll affect orientation. Demand rendering, capped pixel ratio, no perpetual idle spin. Scene unmounts outside the hero, on small viewports and with reduced motion. WebGL absence or React rendering failure retains the drawn illustration.
- Navigation and ordering never require WebGL. The decorative scene is excluded from accessibility navigation. Touch scrolling remains native. Buttons retain ordinary keyboard and click behavior.
- No third-party textures, runtime CDN font requests, external model downloads or paid animation plugins.

## Original imagery

Two images were generated with the available built-in GPT image tool. No separate tool or model named “GPT Flare” was available or claimed.

| Runtime asset | Art direction |
| --- | --- |
| `web/public/images/supper-table.webp` | Overhead burrata, heirloom tomatoes, olives and citrus on linen; sunlight, tactile ceramics, forest napkin and red stripe. |
| `web/public/images/olive-room.webp` | Imagined Casablanca dining room, olive banquette, warm plaster, tiled floor, arched window and afternoon light. |

These are fictional illustrative scenes, not evidence of a real partner's restaurant or ingredients. PNG originals are in `web/artifacts/brand/`. Runtime WebP copies are approximately 485 KiB and 284 KiB. Existing stock dish images retain their provenance in `docs/assets.md`. The Fraunces OFL is copied to `web/public/licenses/Fraunces-OFL.txt`.

## Review

The existing seven browser journeys and two new creative-experience scenarios passed across the final full and focused runs. The added checks exercise real software-rendered WebGL, image loading, scroll transforms, live reduced-motion changes, keyboard interruption of wheel smoothing, mobile 2× text scaling and no-WebGL ordering access. TypeScript, all six domain tests and production compilation also passed. Review caught and corrected live motion-preference handling, keyboard/wheel competition, an enlarged-text footer overflow, and light-on-light navigation/stat text.

Actual rendered screenshots: `web/artifacts/screenshots/creative-desktop.png`, `creative-mobile.png`, `dashboard-desktop.png`, `dashboard-mobile.png` and `dashboard-dark.png`. The software WebGL test confirms rendering and interactions, not physical-device GPU performance. The in-app browser may use the illustration fallback when WebGL is unavailable. Native application source was not changed in this redesign; the earlier native validation is recorded separately in `docs/web-phase-1.md`.

Local demo only. This redesign does not publish a website or change production services.
