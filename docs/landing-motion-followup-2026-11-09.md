# Landing motion and PayPal/AI follow-up — 9 November 2026

The user reported that animations were not visible and requested more prominent PayPal payments and AI messaging.

## Finding and behavior

The existing user browser at `http://127.0.0.1:3110/` reported `prefers-reduced-motion: reduce`. Its page Reduce motion checkbox was off, but the combined browser/device preference still correctly suppressed GSAP motion. This was observed through the existing in-app browser, not inferred from screenshots. No system or browser preference was changed.

The homepage now explains that preference near the introduction and scene controls. Replay controls are disabled while either the browser/device or page preference requests reduced motion. Normal mode provides finite, interruptible replay for the introduction, connected order journey and AI evidence workflow. Replay never overrides reduced motion.

## Changes

- More visible layered dashboard/phone entrances, with separate AI-proposal and PayPal-checkout accents.
- More distinct journey-card entrances and connector sequencing, a financial-panel entrance, and evidence-to-proposal choreography that ends at Needs review / Not posted.
- Replay controls make a short entrance discoverable after its first playback.
- PayPal and AI now appear in the hero, navigation, journey, financial explanation, AI review narrative, role summaries, guest section, FAQ and closing action.
- Connected PayPal Sandbox demonstrations remain distinct from the illustrative homepage scenes. Customer collections and supplier settlement remain separate reviewed actions. No partnership, automatic approval or genuine provider outcome is manufactured.

No backend, payment, authorization, native, AWS, PostgreSQL, Awhar or Nginx change is included. Production deployment remains held.

## Verification

The production build includes TypeScript validation. The marketing browser suite covers the original fifteen cases plus two focused checks: actual transform changes after GSAP replay, and a browser-requested reduced-motion state that cannot be overridden by the page switch. No API request or page error was observed in the replay test. The normal-mode recording is captured in an isolated test browser; it does not change the user's browser preference.

The prior unit and workflow regression results remain in `landing-validation-2026-11-09.json`. Its performance measurements apply to the earlier candidate and are not re-certified for these revised sequences. Exact follow-up source/build identity, test outcomes and recording paths are in `landing-motion-validation-2026-11-09.json`.

## Viewing

The updated local homepage remains on port 3110. The existing user tab was refreshed and its new PayPal/AI copy and reduced-motion explanation were observed. To see automatic motion in that browser, the user must allow motion in the browser/device accessibility preference. The full-motion recording provides an alternative without changing that preference.
