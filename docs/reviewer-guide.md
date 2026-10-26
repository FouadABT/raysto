# Reviewer guide

Raysto addresses a restaurant coordination problem: the people choosing food, preparing it and settling the bill need a consistent view of the same visit.

The conversation candidate connects Flutter visit rooms and the hosted [AG Grid/Studio operations console](https://ops.rays.to/ops) to Serverpod/PostgreSQL, Firebase, Gemini tools and PayPal Sandbox. Start with the [Road to 10/10 report](road-to-10-10.md). [Current status](project-status.md) separates observed behavior from remaining approval/refund, MCP, device and pilot gates. The older preview paths below remain available.

## Choose a path

| Path | Demonstrates | Does not demonstrate |
| --- | --- | --- |
| Offline mobile demo | Design and multi-role journeys using fictional local records; no credentials required. | Live AI/payment, cross-device synchronization or server authorization. |
| Connected mobile + configured backend | Real identities, server-owned records and configured providers. | Automatically available reviewer accounts or complete buyer-to-refund acceptance. |
| Connected `/ops` | Real authorized records, AG Grid, three AG Studio widgets, table room and server assistant. | Public staff credentials, completed buyer/refund acceptance or guaranteed trial access after December 10. |

[Setup](getting-started.md) covers all three. This snapshot has no public APK release attached; build from source. A hosted API URL alone is not a walkthrough or public admin credential.

## Interface walkthrough

1. Run mobile and choose its explicit offline demo.
2. Open a menu; inspect modifiers, basket totals and the assistant review step.
3. Choose **Demo controls → Scenario → B · Dine-in with PayPal** for the fictional cross-role flow. Its PayPal result is a simulation.
4. Switch to manager, kitchen and waiter to follow the same local order through service and bill closure.
5. Try dark mode, larger text and reduced motion.

The [offline guide](demo-guide.md) lists fictional accounts and scenarios. It is separate from provider acceptance.

## Technical review

- [Architecture and maps](backend-v2/README.md)
- [Capability-to-source index](backend-v2/capability-index.md)
- [Integration examples](backend-v2/integration.md) and [OpenAPI](backend-v2/openapi.json)
- [Permissions and transitions](backend-v2/security-and-states.md)
- [Payment workflow](backend-v2/maps/payment-workflow.png)
- [Acceptance scenarios](backend-v2/acceptance.md)
- [Artwork, fonts and photography](assets.md)

## Hackathon context

The [official rules](https://paypalaihackathon.devpost.com/rules) require a public open-source repository and a functional project accessible through a demo or complete run instructions. This initial commit imports an existing working tree; it does not fabricate historical development evidence. Dated project records describe the earlier work.

The final submission should link the verified build and video, explain actual PayPal/AI behavior and disclose limitations. Sponsor aspirations do not imply a completed integration or an award.
