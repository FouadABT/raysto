# m3: the console's Material 3 motion kit

Tokens: `web/src/app/md-sys.css` (from `docs/design-tokens.json`). Motion values and switches: `web/src/lib/connected/motion.ts`. Styles: `m3.css`, imported after `operations.css` in `app/ops/page.tsx`. See every component on the fixture at `/ops/kit` (development only).

**Wrap the console once** in `MotionRoot` (from `motion.ts`; it loads motion's DOM features with `LazyMotion` and applies the console's own reduce-motion switch) and `SnackbarProvider`. Components use motion's `m.*` elements, which need `LazyMotion` above them.

| Component | Use |
|---|---|
| `Reveal index as inView visitKey` | Fade + 6 px rise, staggered by `index`. `visitKey` (e.g. the section id) plays it only on the first visit of the session; `inView` waits until it scrolls into view. |
| `CountUp value format fromZero` | Counts to the real value (from 0 on first reveal, from the previous value on change), tabular, no layout shift; screen readers get the final value only. |
| `Sparkline values label` | A small self-drawing trend line with a lime fill. |
| `AreaChart points format axisFormat sample title seriesLabel` | The main trend. `sample: {label, values}` draws a dashed outline and shows "Sample · not real sales" in the legend and tooltip; it is never filled and never mixed into the real line. Arrow keys read the points once focused; a hidden table carries the data. |
| `Donut segments title center legend` | Shares of a whole; the legend is the accessible version. |
| `Ring value max label valueText` | Progress toward a real target; full and marked when passed. |
| `BarRow rows title max` | Labelled horizontal bars with the numbers as text. |
| `useSnackbar().show({message, action, durationMs, onDismiss})` | One at a time; a new one replaces the old (`onDismiss("replaced")`). Pauses on hover/focus; Esc closes it unless a dialog is open. For status moves, send the command in `onDismiss` when the reason is not `"action"`. |
| `Stamp paid` | "PAID"; it lands only when `paid` turns true on this page. Only PayPal's confirmation should set it. |
| `ContainerCard layoutId` + `ContainerDialog layoutId open onClose title` | Container transform into a native modal `<dialog>`; focus returns to the opener. Put a real button inside the card to open it. |
| `FadeThrough k scale` | Section change. Pass `scale={false}` around AG Grid, AG Studio and the Floor: a transform on their ancestors breaks their measurements. |
| `NavIndicator active layoutId` | The lime pill behind the selected nav item; first child of a `position: relative` item whose label has `position: relative; z-index: 1`. |

Rules: no animation decides state (commands never wait for one); reduced motion renders the final state directly; nothing re-animates when a person comes back to a section; numbers land on real values.
