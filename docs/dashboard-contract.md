# The `dashboard` query (contract, frozen 3 November 2026)

`GET` query `dashboard` with `{restaurantId, range}`; `range` is `today`, `7d` or `30d`. Owners and managers only. Backend 0.15.0 serves it; the console Overview and the app's Today screen read it. Two fixtures hold the exact shape: [fixtures/dashboard-7d.json](fixtures/dashboard-7d.json) and [fixtures/dashboard-today.json](fixtures/dashboard-today.json). The backend test, the web unit tests and the Flutter widget tests all check against them.

| Field | Meaning |
|---|---|
| `range`, `timezone`, `currency`, `from`, `to` | The window, in the restaurant's own time zone; `from`/`to` are UTC instants |
| `granularity` | `hour` for `today`, `day` for `7d` and `30d` |
| `basis` | Always `paidOrdersByCreatedAt`: paid (or partly refunded) orders, not cancelled, rejected or expired, counted at the time they were placed. The UI labels it "Paid sales" |
| `points[]` | One bucket per hour or day, oldest first: `start` (UTC instant of the local bucket start), `label` (short local label), `salesMinor`, `orders`. Empty buckets are present with zeros |
| `kpis.{sales, orders, averageTicket, tips}` | `value` for the window, `previous` for the window of the same length just before (for `today`: yesterday up to the same local time), `series[]` aligned with `points` |
| `channels[]` | `channel` (`counter`, `table`, or the fulfilment), `salesMinor`, `orders`, largest first |
| `kitchen` | Orders now in `submitted`, `accepted`, `preparing`, `ready`, and `oldestMinutes` of the oldest of them (live, not windowed) |
| `latest[]` | Up to 8 newest orders: `id, number, status, paymentStatus, fulfillment, origin, totalMinor, currency, createdAt, customerLabel` |
| `staff[]` | Up to 5 people: `name`, `ordersMoved` (their `order.*` changes in the window), `hours` (worked in the window). Agents and system users are left out |
| `target` | `dailyTargetMinor` (setting; 0 = none) and `todayMinor` (paid sales today, whatever the range) |
| `sample` | `null`, or on the judges' café only when `RAYSTO_JUDGE_SAMPLE_HISTORY=true` and the range is `7d` or `30d`: `{label, points[]}` from a fixed weekly pattern computed in code, each day between 40% and 90% of `dailyTargetMinor` ($120–$270 when there is no target), orders at about $15 each. It is never added to any other field, never stored, and never read by analytics, the close or payroll. The UI draws it as a dashed outline with the label always visible |
