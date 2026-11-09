# Raysto landing scroll story — 9 November 2026

Local implementation following the request for more visible scroll interaction and a more distinctive design. Production promotion remains held.

## Reference direction

Reviewed the current [Awwwards scrolling collection](https://www.awwwards.com/websites/scrolling/) and [GSAP collection](https://www.awwwards.com/websites/gsap/). These are inspiration collections, not evidence of a universal design trend or a claimed award for Raysto. The adopted direction is editorial type, strong section contrast, chapter navigation and scroll-connected product storytelling. No third-party layout, code, image or brand assets were copied.

Implementation follows the installed GSAP React/performance skills and official [ScrollTrigger](https://gsap.com/docs/v3/Plugins/ScrollTrigger/) and [matchMedia](https://gsap.com/docs/v3/GSAP/gsap.matchMedia()) documentation. It uses the existing GSAP packages, native scrolling and CSS sticky positioning. No additional animation dependency.

## What changed

- A forest-and-lime four-chapter story connects supplier evidence, AI investigation, owner review in AG Studio and supported PayPal execution.
- On sufficiently wide and tall viewports, an evidence panel remains beside the narrative. GSAP scrubs its entrance, the background typography and an orbital brand accent with scrolling. Chapter links support direct navigation and reverse scrolling.
- A reading-progress line, desktop hero depth and service-photo parallax extend the motion beyond one-time entry effects.
- The hero links directly to the AI + PayPal story. Phones and short windows receive a compact chapter layout rather than a pinned scene.
- The active chapter remains usable under reduced motion, using immediate panel changes without spatial interpolation. All essential text remains in server-rendered chapter markup when JavaScript is unavailable. Decorative panel duplicates are hidden from accessibility navigation.

## Motion diagnosis

The actual in-app browser still reports `prefers-reduced-motion: reduce`; the page checkbox is not the cause. This suppresses spatial GSAP motion intentionally. Browser/device settings were not changed or bypassed. The new chapter interaction was visibly verified in that browser; normal-motion behavior was separately verified in an isolated Edge test context. The original user tab had become stuck on a localhost error document after a preview restart; a fresh review tab successfully loaded the same server and was retained as a deliverable.

## Boundaries

Scenes are illustrative and explicitly say so. No amounts are invented as live results; no provider outcome is inferred from animation. AI cannot approve, publish or pay. Customer checkout and supplier payout remain separate actions. Marketing interactions make no business API requests. No backend, database, native client, Awhar, shared infrastructure or production service changes.

## Validation

Production build and TypeScript passed for build `EPhu1TPCRcq8Tn-U9f7Ui` (`.tooling/landing-scroll-build.log`). The first sandbox attempt encountered a Windows generated-file write restriction; the scoped build completed with local permissions.

The full existing and new browser suite passed **19 checks** (`.tooling/landing-scroll-tests.log`): six responsive widths, 200% reflow equivalent, initial HTML without JavaScript, keyboard navigation, dialogs, sample controls, email draft, combined motion preferences, replays, forward/reverse chapter scrolling, breakpoint restoration and no business API calls. An initial sandbox runner attempt failed before test execution and was replaced by the installed Edge run with scoped local permissions.

Three additional focused runs passed, including live reduced-motion changes, forward/reverse navigation and a continuous-scroll recording (`.tooling/landing-scroll-focused.log`). The first two recheck existing cases with extra assertions; this is 20 distinct checks overall, not 22 independent cases. The initial performance numbers in the earlier landing report belong to its earlier artifact; no new field-performance or 10/10 score claim is made here.

Actual browser screenshot: `.tooling/landing-production/scroll-story-current-browser.jpg`.

Review URL: `http://127.0.0.1:3110/#connected-story`.

Remaining release boundaries: production hold, unconfirmed contact inbox/legal destinations and unavailable unfamiliar reviewers remain unchanged.
