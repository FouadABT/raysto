"use client";
import { useMemo, useState } from "react";
import { MotionRoot } from "@/lib/connected/motion";
import { RaystoGrid } from "@/components/connected/raysto-grid";
import { moneyCol } from "@/lib/connected/grid-columns";
import { ContainerDialog } from "@/components/connected/m3";

type Product = {
  id: number;
  name: string;
  priceMinor: number;
  costMinor: number | null;
  complete: boolean;
};
const states = [
  "ready",
  "loading",
  "empty",
  "incomplete",
  "stale",
  "failed",
  "unresolved",
] as const;
export function DecisionKit() {
  const [state, setState] = useState<(typeof states)[number]>("ready");
  const [size, setSize] = useState(500),
    [search, setSearch] = useState(""),
    [open, setOpen] = useState(false);
  const products = useMemo(
    () =>
      Array.from({ length: size }, (_, i): Product => ({
        id: i + 1,
        name: `Sample dish ${i + 1}${i % 20 === 0 ? " · a long descriptive café menu name for wrapping review" : ""}`,
        priceMinor: 970,
        costMinor: i % 10 ? 385 : null,
        complete: i % 10 !== 0,
      })),
    [size],
  );
  const rows = products.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase()),
  );
  return (
    <MotionRoot>
      <main className="ops-root" style={{ padding: 24 }}>
        <div className="ops-workspace">
          <div className="ops-finance">
            <header>
              <p className="ops-eyebrow">
                DEVELOPMENT ONLY · ILLUSTRATIVE DATA
              </p>
              <h1>Decision component review</h1>
              <p>
                No backend command, model request or payment can be executed
                here.
              </p>
            </header>
            <div className="ops-finance-select">
              <label>
                Review state
                <select
                  value={state}
                  onChange={(e) => setState(e.target.value as typeof state)}
                >
                  {states.map((s) => (
                    <option key={s}>{s}</option>
                  ))}
                </select>
              </label>
              <label>
                Synthetic dataset
                <select
                  value={size}
                  onChange={(e) => setSize(Number(e.target.value))}
                >
                  <option value={500}>500 products</option>
                  <option value={1000}>1,000 historical-shaped records</option>
                </select>
              </label>
            </div>
            <section className="ops-finance-panel" aria-label="State example">
              {state === "loading" ? (
                <p role="status">
                  Reading confirmed costs… Amounts are pending.
                </p>
              ) : state === "empty" ? (
                <>
                  <h2>No costed dishes yet</h2>
                  <p>Start with one dish and its supplier evidence.</p>
                </>
              ) : state === "failed" ? (
                <>
                  <h2>Costs could not refresh</h2>
                  <p role="alert">
                    The previous view may be stale. No new financial result is
                    available.
                  </p>
                  <button className="ops-btn" onClick={() => setState("ready")}>
                    Retry example
                  </button>
                </>
              ) : state === "unresolved" ? (
                <>
                  <h2>Provider outcome unresolved</h2>
                  <p>
                    A submitted payout batch is not confirmation that its
                    recipient was paid.
                  </p>
                </>
              ) : (
                <>
                  <h2>House lunch bowl · sample</h2>
                  <p>
                    {state === "incomplete"
                      ? "Incomplete cost data. Confirm the missing receipt before recommending a price."
                      : state === "stale"
                        ? "Comparison expired. Its evidence stays readable; recalculate before publication."
                        : "Replacement cost $3.85 · included-cost contribution $5.85 at a $9.70 menu price, before fees and shared overhead."}
                  </p>
                  <button
                    className="ops-btn secondary"
                    onClick={() => setOpen(true)}
                  >
                    Inspect sample evidence
                  </button>
                </>
              )}
            </section>
            <section className="ops-finance-panel">
              <h2>Synthetic grid workload</h2>
              <label>
                Find a sample dish
                <input
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                />
              </label>
              <p role="status">
                {rows.length} of {products.length} synthetic records · not
                business totals
              </p>
              <RaystoGrid<Product>
                label="Synthetic decision workload"
                rows={rows}
                height={420}
                totals={false}
                columns={[
                  { field: "name", headerName: "Dish", minWidth: 220 },
                  moneyCol<Product>("Menu price", "priceMinor", "USD"),
                  {
                    ...moneyCol<Product>(
                      "Replacement cost",
                      "costMinor",
                      "USD",
                    ),
                    valueFormatter: (p) =>
                      p.value == null
                        ? "Unknown"
                        : `$${(p.value / 100).toFixed(2)}`,
                  },
                ]}
              />
            </section>
            <ContainerDialog
              layoutId="kit-evidence"
              open={open}
              onClose={() => setOpen(false)}
              title="Illustrative supplier evidence"
            >
              <div style={{ padding: 24 }}>
                <h2>Sample cost evidence</h2>
                <p>
                  350 g at $11/kg = $3.85. These independently checkable values
                  are a fixture, not an uploaded document or provider result.
                </p>
                <button
                  className="ops-btn secondary"
                  onClick={() => setOpen(false)}
                >
                  Close evidence
                </button>
              </div>
            </ContainerDialog>
          </div>
        </div>
      </main>
    </MotionRoot>
  );
}
