# Mobile App Design System — Complete AI Handoff Guidelines

Version: 1.0  
Prepared: 24 October 2026  
Purpose: transfer the approved visual language, interaction quality and motion system to a **different mobile application**.

---

## 1. Read this first

You are designing a new mobile application. Its subject, audience, workflows, business logic and features may be completely different from the application that inspired this document.

**Reuse the design principles and interaction system. Design the product around the new user's needs.**

This is a standalone specification. You do not need the original repository or conversation to understand it. If source code is available, treat it as a reference implementation, not the definition of the new product.

### The intended feeling

Calm, polished, warm, understandable and responsive. A useful next step should be obvious. Every meaningful interaction should have intentional feedback. Screens should flow together through coherent motion, spacing, typography and shared components.

The experience should feel prepared for the person using it. It should not feel like configuring software, operating an administration panel or completing a questionnaire before getting value.

### Priority order

1. Understand the person, their immediate task and the product's purpose.
2. Make the next useful action obvious and understandable.
3. Establish clear visual hierarchy and comfortable reading.
4. Make interactions feel connected through purposeful motion.
5. Maintain coherent state across screens.
6. Add deeper functionality without increasing everyday complexity.

Accessibility, honesty and reliable behavior apply to every priority. They are not optional final polish.

### Instruction language

- **Must:** part of the intended design/interaction contract unless the new user's explicit requirements override it.
- **Default:** the starting choice; adapt it when the new product provides a concrete reason.
- **Optional:** include only when the product needs it.
- **Reference detail:** an implementation detail from the approved original, not a universal constraint.

User instructions and the new project's applicable requirements take precedence over this guide. Resolve ordinary design choices with good judgment; do not turn this document into an unnecessary approval process.

## 2. What transfers, and what does not

| Transfer to the new application | Decide again for the new application |
| --- | --- |
| Warm paper backgrounds, forest emphasis, lime selection accents | Product name, logo, package/application ID and brand wording |
| Plus Jakarta Sans typography and rounded surfaces | Subject matter, audience, user roles and success criteria |
| Consistent Phosphor icon language | Navigation destination names and number of necessary destinations |
| One clear primary action per task context | Whether a daily plan, calendar, chat, timer or progress screen exists |
| Progressive disclosure and prepared choices | Domain-specific forms, data models, recommendations and terminology |
| Responsive app bars and a distinctive animated bottom dock where appropriate | Authentication, permissions, persistence, backend and payment requirements |
| Stable touch targets, press feedback and interruptible motion | Whether the product needs AI at all |
| Thoughtful empty/loading/error/offline states | Actual AI capabilities, sources, available actions and memory policy |
| A separate interactive component gallery for review | Imagery, illustrations, charts and domain-specific widgets |

Do not automatically copy football, fitness, nutrition, coaching language, the original three tab names, sample player imagery, original application ID, sample records or demo limitations.

The original application used an English/light design preview and authored examples. That is not a requirement to ship the new application in one language, omit real logic or simulate services. Establish the new scope explicitly.

## 3. Establish the new product before choosing screens

Complete a short brief using the user's request and any supplied project context:

```text
App name:
Package / application ID:
Audience:
Problem the person is trying to solve:
Main recurring task:
Useful first result:
Primary action on the main screen:
Supporting tasks:
Information needed before the first result:
Information that can wait:
Necessary top-level destinations:
Platforms and supported languages:
AI needed? If yes, its specific useful job:
Prototype or production behavior:
Persistence and offline expectations:
```

Do not invent personal information or claim requirements the user has not given. State reasonable assumptions when useful. Ask only for missing information that materially blocks the next step; continue independent design work where possible.

### Make a task map, not a module map

Describe the experience as user actions: discover → choose → act → understand the outcome → continue.

Avoid exposing technical architecture as navigation. A database table, integration or internal service is not automatically a destination.

For each proposed screen, answer:

1. Why does this screen exist?
2. What should someone understand immediately?
3. What is the primary action?
4. What happens after it?
5. What can be hidden until needed?

Remove or combine screens that do not have a clear job.

## 4. Simplicity and guidance rules

- Show a useful result as early as the domain allows.
- Require only information needed for that result. Explain why a sensitive or unusual input is needed.
- Prefer meaningful prepared choices over empty fields when the choices cover the task well.
- Offer useful defaults without pretending they were personally assessed.
- Use short, focused steps for a genuinely sequential decision.
- Keep optional details optional, with a clear way to skip.
- Put advanced adjustments behind the action they affect.
- Reveal ingredients, explanations, constraints, history or technical detail on demand.
- Avoid making a person understand the entire application before using one feature.
- Do not use onboarding as a tour of every capability.
- Use account creation, permissions and notifications at the point where their value is understandable. An essential security or identity requirement may justify earlier authentication.
- Do not force unnecessary chat or typing when a direct action is faster.
- Avoid decorative metrics, unexplained scores and artificial gamification.
- Keep the person's previous work when retrying, correcting or navigating back.

### First-use structure

A good default is: clear promise → smallest useful choice → prepared first result → one action.

This may take one screen or several. Do not force a fixed number of onboarding questions onto every product.

Returning users should resume their useful context rather than replay onboarding.

## 5. Visual identity and color tokens

The following is the **canonical light palette** from the approved redesigned experience. Use semantic aliases so colors can evolve consistently.

| Token | Hex | Default role |
| --- | --- | --- |
| `paper` | `#F6F7F2` | Main screen background |
| `white` | `#FFFFFF` | Default card and content surface |
| `ink` | `#173E34` | Main text and icons |
| `forest` | `#173F35` | Primary actions, dark hero surfaces, navigation dock |
| `muted` | `#68756C` | Supporting copy and secondary metadata |
| `lime` | `#D7F978` | Selected navigation indicator, selected chips, restrained emphasis |
| `mint` | `#E6EDE2` | Quiet supporting surfaces and secondary actions |
| `peach` | `#F3E8DB` | Warm supporting notices or alternate emphasis |
| `line` | `#DCE2D9` | Subtle borders, dividers and progress tracks |

### Color application

- Default screen: paper background, ink heading, muted supporting text, white cards.
- Primary button: forest background with white content.
- Secondary button: mint background with ink content.
- Selected choice: mint or lime surface, with a clear check/shape/border change.
- Dark hero: forest surface, white heading, mint supporting copy, a small lime accent.
- Dock: forest container, lime travelling indicator, ink selected content, white inactive content.
- Use lime to direct attention. Do not cover every surface with it.
- Use borders sparingly. Prefer spacing and surface hierarchy to outlining everything.
- Use semantic text/icons alongside color to express status.
- Do not use lime for small text on white or paper.
- Validate contrast for every actual foreground/background combination, including opacity, imagery and disabled/focus states.

### Error, warning and status colors

Peach is a warm surface, not a complete error system. For a product with destructive actions or validation errors, define explicit `error`, `onError`, `warning`, `onWarning`, `success` and `onSuccess` tokens and verify their contrast. Use a clear message and an appropriate icon; do not make color the only signal.

The original code also contains an older teal-based theme. Do not accidentally combine that older theme with these canonical tokens and create two competing visual systems.

### Dark mode

The approved visual reference is light. Dark mode requires a separately designed semantic palette, tested text contrast, imagery treatment, selection states and screenshots. Do not claim that changing the background to black creates a complete dark theme. Do not force a new dark palette into scope unless the new product needs it.

## 6. Typography

Primary family: **Plus Jakarta Sans**. Bundle the font and its license for reliable rendering. Use real supplied weights; avoid synthetic styles where possible.

| Role | Starting size | Weight | Line-height guidance |
| --- | --- | --- | --- |
| Editorial/entry heading | 32–36 | 700 | 1.10–1.20 |
| Large feature heading | 28–32 | 700 | 1.13–1.25 |
| Section heading | 19–22 | 600 | 1.20–1.35 |
| Card heading | 14–20, according to hierarchy | 600 | 1.20–1.40 |
| Primary action label | 15 | 600 | Around 1.20; allow wrapping |
| Main body | 14–16 | 400 | 1.50–1.70 |
| Supporting body | 12–13 | 400 | 1.50–1.80 |
| Metadata / compact label | 11–12 preferred | 500–700 | Readable when scaled |
| Large single metric | 34–48 | 600–700 | Compact, with a descriptive label |

Reference detail: the original helper uses a default line height of 1.2, tracking of `-1.1` logical pixels at sizes 28 and above and `-0.15` below 28. Longer body copy explicitly increases line height. Small uppercase eyebrows use wider tracking, approximately `1.8` logical pixels.

Some original metadata uses size 10. Treat that as a compact reference detail, not a reason to make important copy tiny. Prefer larger labels when starting the next product.

### Typography rules

- Establish hierarchy with size, weight, spacing and wording before adding color.
- Use a short editorial heading where it helps; avoid oversized marketing headings on every task screen.
- Keep long body copy left aligned in left-to-right languages.
- Never shrink important text simply to make a fixed-height card fit.
- Let text wrap and let its surface grow.
- Respect the user's text scale; do not globally cap it to hide layout problems.
- Avoid manual line breaks in dynamic or translated labels. Editorial breaks are acceptable in a short, reviewed heading.
- Support appropriate script-specific fonts and line height when localizing. The original Arabic fallback was Noto Sans Arabic; choose the actual fallback for the new languages.
- Use locale-aware formatting for dates, time, quantities and currency.

## 7. Spacing, shape and elevation

Use logical pixels in Flutter, equivalent layout units in other mobile frameworks. The following token scale consolidates the approved measurements; it is a practical specification rather than a requirement to reproduce every original hard-coded value.

| Token / measurement | Value | Use |
| --- | --- | --- |
| Micro gap | 4 | Tight related details |
| Small gap | 6–8 | Icon/label and chip relationships |
| Standard gap | 12 | Related controls and card spacing |
| Content gap | 16 | Card content relationships |
| Panel padding | 20 | Standard reusable panel |
| Screen gutter | 22 | Normal phone content inset |
| Sheet padding | 24 | Modal content inset |
| Section separation | 26–32 | Different content groups |
| Default card radius | 24 | White or supporting panels |
| Button radius | 22 | Main and secondary actions |
| Compact selection radius | 16–18 | Day/compact choice tiles |
| Large media radius | 24–28 | Hero imagery and illustrations |
| Sheet top radius | 28 | Rounded modal top edge |
| Pill radius | Fully rounded | Compact status and metadata |
| Default border | 1 | Quiet structural boundary |
| Focus / strong selection boundary | Approximately 2 | Visible interaction state |

### Layout discipline

- Use consistent gutters across headers, cards and bottom actions.
- Keep related information close and different groups separated.
- Avoid nested cards unless the inner surface has a distinct purpose.
- Default to zero elevation; use subtle separation only where layers need clarification.
- Avoid heavy shadows, decorative gradients and glass effects as a default language.
- Make tappable cards visibly and behaviorally consistent.
- Do not place every paragraph in its own card.

## 8. Phone layout and responsive behavior

This system is designed for mobile phones. A desktop browser preview should present a phone experience, not silently become a desktop dashboard.

Reference preview behavior: when both available dimensions are at least 600, center a 430-wide canvas with a height up to 932 and an outer radius of 28. Otherwise use the available viewport. These are preview-frame dimensions, not fixed production screen dimensions.

### Production layout requirements

- Support narrow phones, safe areas, display cutouts, system gesture areas and on-screen keyboards.
- Treat 320 logical pixels wide as an important stress case.
- Test text at 2× size and larger settings appropriate to the supported platforms.
- Prefer flexible width and content-driven height.
- Keep useful actions reachable when the keyboard is visible.
- A bottom action may stay anchored, but must respect keyboard and safe-area insets and leave the content scrollable.
- Provide enough bottom padding for content above a floating navigation dock.
- Preserve navigation and state identity through viewport changes; do not rebuild the entire application router when adding/removing a preview frame.
- Do not lock orientation merely to hide a broken layout. Establish the intended orientation policy and test it.

### Intrinsic measurement

Measure scaled, wrapped labels when their height controls a component. The dock reference uses:

```text
destinationWidth = availableDockWidth / destinationCount
labelHeight = maximum actual wrapped label height at the current text scale
dockContentHeight = max(68, 46 + labelHeight)
```

Do not assume every translated destination label fits on one line or that every large-text label fits on two lines.

## 9. Icons and imagery

### Icon system

- Use **Phosphor** consistently for app-authored icons.
- Default to regular icons. Filled variants may indicate selection or completion when appropriate.
- Typical sizes: 16 for compact context; 20–24 for controls and rows; approximately 23 in the dock; 40–48 for a meaningful completion state.
- Keep the stroke/weight language consistent. Avoid mixing unrelated icon libraries for style variety.
- Pair unfamiliar icons with labels. Icon-only actions need accessible names/tooltips.
- Mirror directional navigation arrows for RTL. Do not blindly mirror pictorial icons.
- Preserve official assets, notices and attribution requirements.
- Framework-owned intrinsic controls may use their platform icons.

Reference implementation detail: the original app bundled official regular/fill fonts behind constant `IconData` aliases because its pinned dependency combination needed that integration. The new project should select a compatible, maintained integration for its own SDK. Do not copy the workaround or original version numbers without checking compatibility.

### Imagery

- Use a small number of strong, domain-relevant images.
- Treat images as part of the content hierarchy, not filler.
- Use matching imagery when a choice changes the represented item.
- Preserve a stable image area during loading to avoid disruptive layout shifts.
- Use a suitable placeholder and a deliberate failure fallback.
- Fade decoded imagery in using the shared selection duration; show it immediately under reduced motion.
- Use meaningful alternative descriptions when an image conveys information. Exclude purely decorative images from duplicate announcements.
- Avoid essential text baked into an image.
- Record asset provenance and license. Label illustrative/generated media where its nature could affect trust.
- Do not carry the original product's people, food or domain illustrations into an unrelated application.

## 10. Screen anatomy and hierarchy

A default task screen contains:

1. A contextual app bar or clear entry heading.
2. A concise explanation of the current context.
3. One dominant next action or primary content item.
4. A small number of supporting actions.
5. Optional details disclosed in place or on a detail screen.

The primary action can be selecting an item, capturing something, reviewing a draft or beginning a task. It does not have to be a large button at the top of every screen.

### App bars

- Main destinations: a compact brand/context app bar, with an optional profile action.
- Detail screens: a contextual title and predictable back action.
- Default scroll behavior: floating/snap app bar that returns when scrolling upward.
- Keep the app bar pinned when persistent identity, safety or task controls make it necessary.
- Do not hide essential ongoing-task controls simply to make the screen look cleaner.
- Keep search and filters contextual rather than placing them everywhere.

### Information density

Use short sections and one main idea per card. Do not overload the first viewport with equal-weight cards, charts, statistics, badges and CTAs.

A collection/catalog product may need a list-first home. A creation product may need an editor-first home. Preserve clarity rather than forcing all domains into the same hero-card layout.

## 11. Navigation and the animated dock

### Information architecture

- Start by considering three major destinations. Add or remove destinations based on actual independent recurring tasks.
- Three is a design default, not a mandatory product structure.
- Do not make every feature a tab.
- Profile/preferences and secondary details usually sit outside the main destination set.
- A floating dock is appropriate for a small, stable destination set. Do not compress many labels into it.

### Dock appearance

Reference measurements: outer horizontal inset 20, bottom inset 14 plus system safe area, top inset 6, forest surface radius 27, inner padding 6, lime indicator radius 21. Default content height 68, growing for wrapped scaled labels.

Icon and label form one destination control. Inactive content is white; selected content is ink on lime. Selection is also exposed semantically.

### Dock behavior

- One indicator travels between destinations.
- Use spring motion with retained velocity when the selection is interrupted.
- Reference spring: approximately 460 ms settling duration and 0.12 bounce, with snap-to-end when settled.
- Indicator, icon state and page transition should feel coordinated.
- Rapid taps retarget the current motion rather than restarting from an unrelated position.
- Preserve each branch's useful scroll/form/navigation state where expected.
- Only the active destination receives input, keyboard focus and accessibility navigation.
- Fully inactive branches should not keep decorative tickers running.
- Reduced motion sets the indicator position immediately.

### Back and detail routes

Use platform-native detail transitions and preserve native back gestures. A shared-element transition is useful only when the same meaningful object appears in both places. Avoid duplicate hero tags and competing transitions.

Support valid deep links and a useful missing-route recovery. A direct detail link should not depend on having visited an unrelated screen first.

## 12. Motion system: required interaction contract

**Motion is part of the product, not an optional finishing effect.** Every meaningful tap, choice, navigation, disclosure, state change and completion needs understandable feedback. This does not require translating or bouncing every element.

### Shared tokens

| Token | Normal duration | Default purpose |
| --- | --- | --- |
| `feedback` | 140 ms | Press/release and small control feedback |
| `selection` | 240 ms | Choice changes, short crossfades, expansions |
| `branch` | 400 ms | Main destination transition |
| `sheet` | 360 ms opening | Modal sheet entrance |
| Sheet reverse | 240 ms | Modal dismissal |
| `milestone` | 440 ms | Progress and completion emphasis |
| Dock spring | About 460 ms | Travelling selection indicator |
| Initial reveal | Up to 650 ms | Restrained first entrance of a short content group |

Default curves:

```text
Spatial movement: easeOutCubic
Coordinated destination transition: easeInOutCubicEmphasized
Opacity / effects: easeInOut
Dock selection: interruptible spring
```

These are application tokens inspired by Material motion principles, not a claim that every value is a mandated Material specification.

### Interaction matrix

| Interaction | Normal feedback | Reduced motion |
| --- | --- | --- |
| Primary/secondary button | Native ink/state feedback; inner content compresses to 0.96 on press | Native state feedback; no compression |
| Tappable card | Ink plus inner compression to 0.98 | No spatial compression |
| Choice | Surface/border/check transition; clear selected state | Immediate selected state |
| Chip | Native selection feedback using shared duration | Immediate selection |
| Dock selection | Travelling spring indicator, icon change and coordinated page transition | Immediate active destination |
| Main branch | Directional shared axis with brief outgoing/incoming coordination | Immediate destination |
| Detail route | Native platform transition; meaningful shared element if applicable | Suppress passive movement while retaining back gesture behavior |
| Sheet | Native modal entrance/dismissal with shared durations | Immediate presentation/dismissal |
| Expansion | Animate content size; rotate/change the disclosure icon | Replace content directly |
| Content replacement | Short fade/size change; remove outgoing interactions | Direct replacement |
| Progress value | Animate toward actual new value | Set actual value immediately |
| Completion | Brief scale/check/content change | Show completion immediately |
| Image decode | Fade from stable placeholder | Display decoded image immediately |
| Error or validation | Clear inline state, focus/announcement where useful | Same information without decorative movement |

### Main branch reference

The original shared-axis transition uses up to 40 logical pixels of horizontal displacement, incoming scale around 0.975 and outgoing scale around 0.985. The incoming content moves to scale 1 and offset 0. Direction follows navigation order and reading direction.

Outgoing opacity clears early, approximately over the first 32% of the transition. Incoming opacity becomes prominent after approximately 15%. This avoids two full-strength headings competing during a long crossfade.

Treat these as a starting implementation, not a requirement to recreate animation math in a framework that already provides an equivalent accessible transition.

### Entrance choreography

The reference reveal has a small vertical offset around 6.5% of the child's height, a total duration of 650 ms and modest stagger intervals (`min(order × 0.09, 0.36)` of the animation timeline).

Use once on initial presentation, selectively. Do not animate a whole long list from scratch every time someone returns to a tab. Do not delay hit targets or keep useful content invisible for decoration.

### Motion quality requirements

- Keep the hit target in place while its interior compresses.
- Use animation state that can be interrupted and retargeted.
- Do not reset the user's scroll position to make an entrance animation easier.
- Do not animate numbers to imply measurements that do not exist.
- Do not insert fake loading delays to make a service seem intelligent.
- No perpetual breathing, floating, sparkling or wobbling for ordinary static UI.
- Ongoing animation must serve an active function and stop when that function stops.
- Avoid stacking unrelated page, card and child entrance effects at the same moment.
- Keep callbacks/state commits independent of animation-completion timing.
- Rapid presses must not duplicate routes, submissions or saves.

## 13. Reduced motion and accessibility

Effective reduced motion is enabled when **either the device preference or the app preference requests it**. An app-level switch must never override a device-level request for less movement.

For Flutter, account for relevant platform accessibility features as well as `MediaQuery.disableAnimations`; an operating system may expose reduced motion separately. Listen for runtime preference changes.

Reference implementation lesson: zero-duration `AnimatedSize` caused a synchronous layout mutation in the pinned original SDK. Its solution was to return the child directly in reduced-motion mode. Preserve that direct-replacement principle when a framework's zero-duration animation path is unreliable.

### Accessibility requirements

- Minimum default interactive target: 48 × 48 logical pixels. Small visible icons can sit inside larger targets.
- Give controls meaningful accessible names and correct selected/expanded/enabled states.
- Provide visible keyboard focus where keyboard interaction is supported.
- Preserve a logical reading and focus order.
- Mark redundant decorative elements appropriately to avoid repeated announcements.
- Keep inactive branches and outgoing replaced content out of input, focus and semantics.
- Remove collapsed controls from accessibility and focus navigation.
- Move focus sensibly into modal content and return it after dismissal.
- Announce meaningful asynchronous results once; do not continually re-announce a whole conversation.
- Do not use color, animation, sound or haptics as the only carrier of important information.
- Respect large text, sufficient contrast and readable touch spacing.
- Avoid flashing and unnecessary vibration. Optional haptics should follow platform/user preferences and never substitute for visible feedback.

Project contrast targets: at least 4.5:1 for ordinary text and 3:1 for large text or essential non-text boundaries where applicable. Measure actual colors and states; this guide is not an accessibility compliance certification. Complete the platform and accessibility review required by the new product.

## 14. Reusable component architecture

Build semantic tokens and reusable primitives first. Compose domain widgets from them rather than copying raw card/button styling into every screen.

### Foundation inventory

| Component | Purpose and contract |
| --- | --- |
| Primary action | One dominant task action; clear verb; enabled/disabled/busy/focus states; duplicate-submit protection |
| Secondary action | Alternative or supporting action with quieter visual emphasis |
| Icon action | Compact familiar operation; full hit target and accessible label |
| Interactive card | Meaningful content selection; stable hit area and press feedback |
| Surface/panel | Consistent padding, radius and Material-compatible ink layer |
| Body/heading/eyebrow | Consistent type hierarchy; no per-screen font improvisation |
| Metadata pill | Short noninteractive context; avoid styling it like a button unless it acts |
| Choice card | One meaningful option with title, optional supporting text and selected semantics |
| Choice chips | Small choice set that wraps; use radio or multi-select semantics appropriately |
| Detail/action row | Icon, title, supporting detail and appropriate trailing affordance |
| Section heading | Groups content; optional specific secondary action |
| Disclosure | Supporting detail revealed in place; explicit expanded state |
| Modal sheet | Focused contextual task or decision; scrollable, safe-area/keyboard-aware |
| Confirmation | Explains consequence; clear continue/cancel; appropriate to action risk |
| Inline notice | Context, feedback or recovery action; no modal interruption for routine information |
| Progress | Real completion value and readable label; not a decorative accuracy claim |
| Completion | Confirms what changed and offers a useful next step |
| Image/media surface | Stable layout, loading, fallback, accessibility and optional shared transition |
| Responsive app bar | Context and navigation with appropriate scroll behavior |
| Navigation dock | Small destination set, semantic selection, coordinated interruptible motion |
| Composer/input | Clear label, sensible keyboard behavior, draft preservation and validated submission |

### Domain compositions: choose only those needed

| Pattern | Adaptable purpose |
| --- | --- |
| Next-step hero | Present a prepared task, item or result |
| Explanation panel | Explain why a recommendation or state is shown |
| Adaptation sheet | Offer a small set of useful alternatives |
| Schedule/day strip | Select among dated contexts when time is a real organizing concept |
| Timeline/chapter/milestone | Show meaningful stages or outcomes |
| Task overview | Explain the task, requirements and next action before starting |
| Step viewer | One instruction and a clear position in a sequence |
| Timer/active-task control | Real start/pause/resume/finish behavior when elapsed time matters |
| Alternative picker | Choose a suitable replacement with coherent content updates |
| Capture/review | Acquire content, let the user correct it, then commit |
| Saved/repeat action | Reuse something familiar with a clear undo where feasible |
| Metric/assessment | Observed value with unit, period, origin and limits |
| Optional reflection | Lightweight feedback that begins unanswered |
| Preference row | A useful optional setting, with consequences explained |
| Connection row | Explain an integration before real permission or authentication |

These patterns can represent documents, purchases, learning tasks, travel plans, creative work or other domains. Do not retain the original domain names when they do not fit.

### Component API rules

- Use named inputs, explicit state and callbacks.
- Keep business decisions out of presentational components.
- Own only appropriate local resources, such as a composer controller or timer.
- Dispose controllers, listeners and timers.
- Preserve keys and state identity intentionally.
- Make loading/error/selected/disabled states explicit rather than inferring them from unrelated labels.
- Use consistent semantic token names; rename original project prefixes for the new project if necessary.
- Expose constraints and accessibility behavior in component documentation.
- Keep uncommon variations explicit. Avoid a giant universal card with many unrelated boolean flags.

## 15. Forms, selections and editing

- Use persistent labels rather than placeholder-only inputs.
- Explain required information at the point of entry.
- Use the appropriate keyboard, input action and autofill behavior.
- Validate at a helpful moment; do not interrupt every keystroke with errors.
- Keep errors close to the affected field and explain how to resolve them.
- Preserve valid entries after an error.
- Make optional input visibly optional.
- Disable an empty/invalid submission where that is understandable; explain what is missing when it is not obvious.
- Support cancellation without silently discarding significant work.
- Keep selection state visible through a check/border/label, not only color.
- After saving, distinguish a committed view from an editable draft.
- Undo must restore the actual previous data, including entered text, not only the button label.
- If an image, title, ingredients/attributes or downstream summary depend on a choice, update them together.

Use explicit confirmation for consequential or hard-to-reverse actions. Routine reversible interactions should usually use direct feedback and undo instead of repeated confirmation dialogs.

## 16. Sheets, dialogs and contextual detail

- Use a bottom sheet for a short contextual choice, explanation or focused edit.
- Use a full screen when the task needs substantial space, navigation or sustained attention.
- Use a dialog for a concise blocking decision where that pattern is appropriate.
- Do not stack several modals for ordinary navigation.
- Place a modal above the entire application shell when it must block the dock and underlying screens. In nested Flutter navigation, this generally means using the intended root navigator.
- Dismiss through the same navigator that presented it.
- Respect system safe areas and keyboard insets; allow scrolling when content is tall.
- A reference maximum sheet height is approximately 88% of the available viewport, with content scrolling inside.
- Keep cancellation accessible and avoid ambiguous button wording.
- Confirm result/state once when the sheet closes, not from multiple competing callbacks.
- Do not accidentally resume a paused active task when a help or leave sheet is dismissed.

## 17. AI experience — optional, useful and controlled

Include AI only if it helps a real task in the new application. Do not add a chatbot solely because the reference application had one.

### AI's job

Prefer explaining, narrowing options, drafting, transforming content and previewing concrete changes. Let direct actions handle simple operations that do not need a conversation.

Keep AI attached to the user's current task. Expose the relevant context and allow it to be corrected or removed where appropriate.

### AI widget inventory

| Widget | Required behavior |
| --- | --- |
| Introduction | Explain capabilities and actual limitations in task-specific language |
| Suggested prompts | A few useful contextual starting points, not a wall of generic commands |
| User message | Clearly distinguished from the assistant; preserve the person's wording |
| Assistant message | Readable answer, short paragraphs, clear next action where useful |
| Composer | Multiline input, disabled empty send, retained draft and keyboard-safe placement |
| Processing/streaming state | Reflect an actual request; accessible stop/cancel where supported |
| Embedded result | A real item/card/draft/action that can be inspected |
| Clarification | One useful question when essential context is missing |
| Change preview | Explain what will change and what data the proposal affects |
| Apply control | Commit only the reviewed proposal, once |
| Applied state | Show previous versus current values accurately |
| Undo | Restore the prior state where the operation supports reversal |
| Reason/source disclosure | Distinguish user context, inference and actual retrieved evidence |
| Uncertainty state | State the specific missing information or limitation plainly |
| Correction control | Let the person reject or revise an assumption |
| Memory control | Explicit opt-in where appropriate; show remembered information and allow forgetting |
| Request error/retry | Keep the draft/context, explain recovery, prevent duplicate actions |

### AI behavior rules

- Never imply an authored/demo response is live AI.
- Never fabricate retrieved sources, verification, personalization or completion of a real-world action.
- Do not add a simulated typing delay or artificial spinner for atmosphere.
- If streaming is supported, update smoothly without forcing scroll when the user is reading earlier content.
- Show a new result accessibly without re-announcing every token.
- A stopped request must not later apply an obsolete result.
- Tie responses and proposals to request IDs/versions so stale asynchronous replies do not overwrite newer choices.
- Separate suggested state from committed state.
- Apply a proposal once and show the actual resulting state across affected screens.
- Ask for the confirmation required by the real action's consequences and applicable product policy.
- Do not describe sample toggles as connected accounts, scheduled notifications or saved permanent memory.
- Explain sensitive data use at the relevant point, without turning every ordinary action into a warning flow.
- Make memory scope clear: current view, current conversation, device or account.
- Do not infer a sensitive personal fact from an ordinary selection and store it silently.

### Prototype state previews

A gallery may provide explicit controls such as “Preview processing”, “Stop response” and “Show sample result”. Label them as previews. Real production requests must drive the corresponding states rather than reuse a fake delay.

## 18. Loading, empty, offline, error and success states

Every asynchronous or data-driven feature needs more than a populated screenshot.

| State | Design requirement |
| --- | --- |
| Initial loading | Stable structure or quiet skeleton; actual request state; no arbitrary minimum wait |
| Refreshing | Keep existing useful content visible when possible; indicate refresh without clearing everything |
| Empty, first use | Explain what will appear and offer one useful first action |
| Empty, no matches | Explain the query/filter result and provide a way to adjust it |
| Partial result | Show what is available and identify what is missing |
| Recoverable error | Explain the problem in plain language; keep draft/context; offer relevant retry |
| Validation error | Explain the affected field and the correction |
| Offline | Identify what is actually saved/available; explain what requires connection |
| Permission denied | Explain the affected feature and an appropriate alternative or settings route |
| Session expired | Preserve recoverable work and guide reauthentication where possible |
| Success | State the actual outcome and provide continuation or undo |
| Destructive completion | Clearly identify what was removed and whether recovery is possible |

Do not show “saved” before a required save is confirmed. If optimistic updates are used, define pending/failure/rollback behavior.

Avoid full-screen blocking errors for a small failed supporting section. Do not claim offline availability for content that was never stored.

## 19. State, navigation and lifecycle correctness

- Use a single coherent source of truth for shared product state.
- Update related screens from the same committed result.
- Distinguish local selection, editable draft, pending request and committed data.
- Keep gallery/sample state separate from real user state.
- Guard duplicate submissions and duplicate navigation pushes.
- Prevent actions on disposed views and handle cancellation of asynchronous work.
- Preserve useful state on tab changes; intentionally reset it only when the product calls for a reset.
- Define back behavior for unfinished work.
- Define which state survives process restart and make that behavior honest.
- Use actual deadlines/elapsed time for timers; do not assume every periodic callback fires exactly on schedule.
- Foreground guided tasks should pause safely when backgrounded and require explicit resume when that matches the task.
- Background-capable operations need their own product/platform policy; do not copy a practice timer's pause rule to all domains.
- Closing help, a modal or a permission prompt should not accidentally commit or restart another action.
- Disconnecting an integration, forgetting a preference and resetting an example should affect exactly the advertised scope.

## 20. Localization, trust and platform conventions

### Localization

- Externalize user-facing strings from the start if localization is in scope.
- Test longer labels and plural forms, not just English.
- Support RTL layout and directional navigation motion when applicable.
- Avoid embedding meaningful text inside images.
- Format dates/numbers/currency for the user's locale.
- Do not claim localization based on framework controls alone; custom screens need translated and reviewed content.

### Trust

- Distinguish measured, self-reported, estimated, generated and sample information.
- Pair a metric with its unit, period and origin when that affects interpretation.
- Do not invent accuracy, readiness, eligibility or outcome scores for visual interest.
- Avoid outcome guarantees the product cannot substantiate.
- Present permissions at an understandable point and ask only for access the feature needs.
- Retain asset licenses and use appropriate rights for media and branding.

### Platform conventions

Preserve expected back navigation, text editing, scrolling, keyboard behavior, system sheets and accessibility integration. The visual language can be distinctive without making basic interactions unfamiliar.

## 21. Implementation guidance for a new project

This guide is framework-portable. The original implementation used Flutter, Riverpod and a declarative router with retained navigation branches. Those libraries are reference choices, not requirements for another stack.

### Suggested structure

```text
app/
  bootstrap
  router
  preferences
design_system/
  tokens/        colors, type, spacing, shape, motion
  theme/         semantic theme and platform integration
  icons/         app-owned icon aliases
  components/    reusable primitives and composed controls
features/
  <new_domain>/  domain screens, state and relevant compositions
demo/
  gallery/       isolated component/state demonstrations
assets/
  fonts/
  icons/
  images/
docs/
  product-direction.md
  design-system.md
  validation.md
```

Match the actual project's conventions rather than restructuring a working codebase for this tree alone.

### Token examples

```text
Colors.paper = #F6F7F2
Colors.ink = #173E34
Colors.primary = #173F35
Colors.onPrimary = #FFFFFF
Colors.selected = #D7F978
Colors.supportingSurface = #E6EDE2
Colors.warmSurface = #F3E8DB
Colors.outlineSubtle = #DCE2D9

Motion.feedback = 140ms
Motion.selection = 240ms
Motion.branch = 400ms
Motion.sheet = 360ms
Motion.milestone = 440ms

effectiveReducedMotion = deviceRequestsReducedMotion OR appRequestsReducedMotion
```

### Flutter implementation notes

- Translate semantic tokens into theme/extensions rather than scattering constants through screens.
- Use real Material/native control primitives and their state/focus semantics as the basis of custom styling.
- Put ink-producing controls on an appropriate Material surface; an opaque decorated box between the control and its Material ancestor can hide feedback.
- Place press transforms inside a stable interactive wrapper.
- For outgoing content, combine input, focus and semantics exclusion; opacity alone does not disable interaction.
- Manage controller/timer lifecycles and stable navigator slots.
- Measure wrapped labels with the current `TextScaler` and direction.
- Use the appropriate root navigator for app-wide blocking sheets.
- Preserve native route gestures while reducing passive transitions.
- Load the actual font families and image assets in screenshot tests.
- Verify icon tree shaking and font packaging in release builds if using custom icon assets.
- Use the new project's package ID and release metadata. Do not reuse `com.gmrt.uccen` unless the user specifically requests it.
- Select compatible dependencies for the new project. Do not treat the original pinned SDK, custom Material package or icon integration as permanently required versions.

## 22. Interactive component gallery

Build a separate in-app gallery when the user requests a reusable design foundation or broad visual review.

It should be reachable from a development/review entry such as profile or a dedicated preview route, without turning the normal home screen into a component catalog.

Organize the new gallery by relevant component families. The original had eight collections and 42 example families; the new product does not need those exact counts or categories.

For each component, provide:

1. Its name and purpose.
2. A realistic example from the **new** domain.
3. Working interaction, not a dead visual placeholder.
4. Relevant selected/disabled/loading/error/empty/success states.
5. A reversible or resettable demonstration where useful.
6. Normal and reduced-motion behavior.
7. Large-text and narrow-layout behavior.

Isolate sample state so trying a gallery example cannot unexpectedly modify a real record. Explicitly label any gallery control that changes a global preference.

## 23. Design and implementation workflow

### Step 1 — Define the useful journey

Write the brief, identify the first useful result and select the essential destinations. Remove speculative features from the initial experience.

### Step 2 — Establish the foundation

Create the tokens, typography, surfaces, actions, selection controls, app bar, navigation, sheet and motion policy. Use realistic content lengths.

### Step 3 — Prove one complete flow

Implement entry → primary task → outcome → next useful step. Use coherent local data if a design prototype was requested. Do not claim production services exist before they do.

### Step 4 — Cover supporting states

Add relevant errors, empty states, editing, cancel/undo, interrupted navigation and accessibility behavior. Connect supporting features to the same task context.

### Step 5 — Review actual pixels and interactions

Run the application, capture representative screens and use the flow. Inspect normal motion as well as static screenshots. Fix hierarchy and interaction problems before expanding coverage.

### Step 6 — Expand with the same components

Add the next feature using existing contracts. Introduce a new component when it has a distinct reusable purpose, not merely because one screen needs different padding.

### Step 7 — Verify and hand off

Run checks appropriate to the changes. Record what was tested, which artifacts were built and what remains unverified. Keep the user-facing report clear and brief.

Do not turn this sequence into a mandatory permission gate for every reversible step. If the user authorized implementation, continue until the requested result is concrete and reviewable.

## 24. Verification and acceptance checklist

### Product clarity

- [ ] The new application's purpose and audience are identifiable.
- [ ] A new person can find a useful next action without an explanation from the developer.
- [ ] The home screen prioritizes the recurring task rather than a feature inventory.
- [ ] Required input is minimal and justified.
- [ ] Optional detail is available without overwhelming the main flow.
- [ ] Terminology belongs to the new domain.

### Visual consistency

- [ ] Canonical palette and semantic roles are used consistently.
- [ ] Actual bundled fonts render correctly.
- [ ] Phosphor icon styles are coherent and legible.
- [ ] Gutters, panel padding, radii and action styles align across screens.
- [ ] Photos/illustrations match the selected content.
- [ ] Empty/error/loading states receive the same visual care as populated states.
- [ ] No layout depends on text truncation that hides essential meaning.

### Motion and navigation

- [ ] Buttons and cards have visible press feedback with stable hit targets.
- [ ] Choice changes are understandable and animated in normal mode.
- [ ] Dock selection and page changes are coordinated.
- [ ] Rapid tab changes retarget smoothly without duplicate navigators/routes.
- [ ] Inactive/outgoing content cannot receive taps, focus or accessibility navigation.
- [ ] Sheets, disclosures, content changes, progress and completion have appropriate transitions.
- [ ] Reduced motion works before and during interaction.
- [ ] Native back gestures and contextual back behavior remain usable.
- [ ] No artificial response delays or unnecessary continuous animation exist.

### Layout and accessibility

- [ ] Check a narrow 320-wide phone and a normal phone size.
- [ ] Check 2× text and supported larger settings.
- [ ] Check long translated strings/RTL when in scope.
- [ ] Check keyboard-visible inputs, sheets and pinned actions.
- [ ] Check supported orientation and safe-area configurations.
- [ ] Check contrast, labels, target sizes and focus states.
- [ ] Check screen-reader order and modal focus behavior on the actual platform where possible.

### Behavior

- [ ] A complete primary journey works with coherent data across screens.
- [ ] Save/cancel/retry/undo preserve the correct draft or committed state.
- [ ] Double taps cannot submit or navigate twice.
- [ ] Back navigation handles unfinished work intentionally.
- [ ] Active tasks behave correctly on background/resume.
- [ ] No stale asynchronous result can overwrite a newer user decision.
- [ ] Offline, permissions and connection claims match actual implementation.
- [ ] Sample gallery state cannot mutate real records unexpectedly.

### AI, if present

- [ ] Its useful job and actual capabilities are clear.
- [ ] The user can inspect a proposed change before committing it.
- [ ] Applied values and undo reflect actual data.
- [ ] Stop/cancel and request-error paths are handled.
- [ ] Sources and uncertainty are honest.
- [ ] Memory has explicit scope and correction/forget controls where appropriate.
- [ ] Demo behavior is clearly distinguished from a live service.

### Evidence and delivery

- [ ] Appropriate formatting, static analysis and behavioral checks pass.
- [ ] Screenshots use real fonts/assets, not test-font placeholders.
- [ ] Representative intermediate motion is observed or captured.
- [ ] At least one complete flow is exercised, not just individual screens.
- [ ] Requested release artifacts are built and identified correctly.
- [ ] Mobile build/package/signature metadata is verified when delivering an installable artifact.
- [ ] Device performance, native gestures and accessibility are not claimed based only on widget tests or a browser.
- [ ] Remaining limitations are stated accurately.

Write meaningful tests for risky transitions and shared state. Do not inflate the test count with assertions that only mirror implementation details. A high count does not establish usability or smooth device frame rate.

## 25. Anti-patterns to reject

- Copying the original application's domain because its design was approved.
- Reusing the old application name or package ID by accident.
- A configuration-heavy welcome experience before any value.
- Too many equally important home-screen actions.
- Turning every internal feature into a navigation tab.
- Adding an AI chat as the gateway to actions that should be direct.
- Large empty dashboards, decorative scores or invented progress.
- Inconsistent icon libraries, random corner radii and per-screen color choices.
- Tiny text or fixed-height cards used to hide layout constraints.
- Heavy shadows or gradients substituted for clear hierarchy.
- A static UI with animation mentioned only in documentation.
- Endless bounces, fake typing delays or animation on every paragraph.
- A crossfade that leaves two full-strength pages competing for attention.
- Shrinking the actual hit target during a press.
- Hidden clickable/focusable content behind a transition or modal.
- An undo button that does not restore the previous data.
- Claiming AI, persistence, connectivity or permissions that are only mocked.
- Claiming performance or accessibility validation that was not performed.

## 26. Ready-to-paste prompt for the next AI

```text
Read the attached MOBILE_APP_DESIGN_SYSTEM_GUIDELINES.md completely before
designing or implementing this mobile application.

This is a DIFFERENT product from the application that inspired the guide.
Preserve its approved visual and interaction system: warm paper surfaces,
forest emphasis, lime selection accents, Plus Jakarta Sans, consistent Phosphor
icons, rounded cards, simple guidance and purposeful Material-inspired motion.

Do not copy football/fitness/food features, original tab names, imagery, app name,
package ID or sample data unless my new requirements explicitly need them.

Design for my new audience and main task. Prioritize understandable UX, one clear
next action, minimal input, useful defaults and progressive disclosure. Choose
navigation around real recurring tasks rather than technical modules.

Implement actual feedback for presses, selection, navigation, sheets,
disclosures, content updates, progress and completion. Use shared motion tokens,
stable hit targets, interruptible transitions and device/app reduced-motion
support. Keep outgoing/inactive content out of input, focus and semantics.

Use reusable components and coherent state. If AI is useful, make it contextual,
honest and controllable, with proposal previews and explicit apply/undo where
appropriate. Label authored/demo services clearly.

Use realistic content from the NEW product. Validate narrow phones, large text,
keyboard layouts, interrupted navigation and important error/empty/offline
states. Review rendered screens and actual interactions, not only source code.

When implementation is requested, carry the authorized work through to a
working, reviewable result. Keep a component gallery separate from the normal
user journey when a gallery is in scope. Report what was verified accurately.

NEW PRODUCT BRIEF:
[Describe the new app, audience, main task, required features, platforms,
package ID if known, and whether you want a design demo or production logic.]
```

## 27. Portable project-memory block

If the new project uses an `AGENTS.md` or equivalent project guidance file, adapt this block to its actual product. Do not replace existing instructions blindly.

```text
Design priority: understandable mobile UX first, then consistent visual craft,
purposeful motion and coherent implementation. Follow the attached design guide.

Keep one clear primary action per task context. Prefer useful defaults, concise
choices and progressive disclosure. Avoid configuration-heavy onboarding and
navigation based on internal modules.

Use the shared paper/forest/lime system, typography, Phosphor icons, spacing,
rounded surfaces and component contracts consistently. Adapt content and
information architecture to THIS product; do not inherit the source app's domain.

Motion is required for meaningful interactions. Respect stable hit targets,
interruptibility, native gestures, focus/semantics and reduced-motion preferences.
Do not add fake delays or continuous decoration.

Use real shared state for real product outcomes and isolated state for gallery
examples. Describe prototype, AI, persistence and integration capabilities honestly.

Verify complete journeys and rendered UI as well as appropriate automated checks.
Never equate a test count with usability, device performance or accessibility.
```

---

This guide transfers a design system and a standard of interaction quality. The new application's purpose determines the product built with it.
