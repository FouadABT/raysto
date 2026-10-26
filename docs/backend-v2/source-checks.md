# Source check evidence — 26 October 2026

This table records the original source-only phase. Validation and deployment were subsequently authorized and executed. Current evidence is in [the mobile integration report](../mobile-backend-integration.md); current contract inventory is 68 commands and 41 queries.

| Check | Observed result |
|---|---|
| Pinned Serverpod source generation | Successful; generated server/client bindings and test endpoint helpers |
| Migration preparation | Two additive migration directories generated; application deferred |
| `dart analyze` in `backend/raysto/raysto_server` | Exit 0, **No issues found**; includes authored test definitions but does not execute them |
| `dart analyze` in `backend/raysto/raysto_client` | Exit 0, **No issues found** |
| Dart source formatting | Completed; final pass required no changes |
| `npx --yes --package typescript@latest tsc --noEmit --project backend/sdk/typescript/tsconfig.json` | Exit 0; no emitted files |
| Contract export | 68 commands, 33 queries, 49 source models; OpenAPI, TypeScript client, data dictionary and index written |
| Diagram export | Four Mermaid sources, four SVGs and four PNGs rendered; layouts visually reviewed |

Raw Dart analyzer output is retained in `backend/operations/static-analysis.txt` and `backend/operations/client-static-analysis.txt`. Source models and endpoints, rather than generated files, are the editable authority.

No unit tests, integration tests, load checks, application builds, APK builds, live provider probes, migration application, server start or deployment were performed. These source checks establish neither functional correctness nor production security. The acceptance matrix and operations runbook define the remaining release evidence.
