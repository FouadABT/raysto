"use client";
import { Component, useEffect, useState, type ReactNode } from "react";
import { AgStudio, AgStudioProvider, GridWidget, PivotGridWidget } from "ag-studio-react";
import type { AgDefaultRegistry, AgReportState } from "ag-studio";

const license = process.env.NEXT_PUBLIC_AG_STUDIO_LICENSE;

/** A small, made-up month of bills: rows by category, columns by month. */
const bills = [
  { category: "Electricity", month: "2026-09", amount: 182.4 },
  { category: "Electricity", month: "2026-10", amount: 196.1 },
  { category: "Water", month: "2026-09", amount: 41.2 },
  { category: "Water", month: "2026-10", amount: 39.8 },
  { category: "Rent", month: "2026-09", amount: 1800 },
  { category: "Rent", month: "2026-10", amount: 1800 },
  { category: "Internet", month: "2026-09", amount: 49.9 },
  { category: "Internet", month: "2026-10", amount: 49.9 },
  { category: "Supplier", month: "2026-09", amount: 912.35 },
  { category: "Supplier", month: "2026-10", amount: 1044.7 },
];

/** One page, one pivot widget filling it, view mode, no panels. */
const pivotOnly: AgReportState<AgDefaultRegistry> = {
  pages: [
    {
      id: "bills",
      widgets: {
        pivot: {
          type: "pivot-grid",
          format: {
            title: { text: "Bills by category and month", enabled: true },
            style: { grandTotalRow: { enabled: true }, totalColumns: true },
          },
          dataMapping: {
            rows: [{ id: "bills.category" }],
            columns: [{ id: "bills.month" }],
            values: [{ id: "bills.amount", aggregation: "sum" }],
          },
        },
      },
      widgetLayout: { pivot: { xTrack: 0, yTrack: 0, xSpan: 16, ySpan: 12 } },
    },
  ],
  selectedPageId: "bills",
} as unknown as AgReportState<AgDefaultRegistry>;

class Boundary extends Component<{ label: string; children: ReactNode }, { error?: string }> {
  state: { error?: string } = {};
  static getDerivedStateFromError(error: unknown) {
    return { error: String(error instanceof Error ? error.message : error) };
  }
  render() {
    return this.state.error ? (
      <p data-spike-error={this.props.label} style={{ color: "#a32d32" }}>
        {this.props.label} failed: {this.state.error}
      </p>
    ) : (
      this.props.children
    );
  }
}

export function StudioSpike() {
  const [ready, setReady] = useState(false);
  useEffect(() => setReady(true), []);
  if (!ready) return null;
  return (
    <main style={{ padding: 24, display: "grid", gap: 24, background: "#f6f7f2", minHeight: "100vh" }}>
      <h1>AG Studio spike</h1>
      <p>Licence key present: {license ? "yes" : "no"}</p>
      <AgStudioProvider licenseKey={license}>
        <section aria-label="A: Studio in view mode, one pivot widget">
          <h2>A. Studio, view mode, one pivot widget</h2>
          <div data-spike="studio-view" style={{ height: 420, width: "100%" }}>
            <Boundary label="studio-view">
              <AgStudio
                mode="view"
                loadThemeGoogleFonts={false}
                panels={{ view: { left: [], right: [] }, edit: { left: [], right: [] } }}
                initialState={pivotOnly}
                data={{ sources: [{ id: "bills", data: bills }] }}
                style={{ height: "100%", width: "100%" }}
              />
            </Boundary>
          </div>
        </section>
        <section aria-label="B: grid widgets without Studio">
          <h2>B. GridWidget and PivotGridWidget on their own</h2>
          <div data-spike="standalone" style={{ height: 300, width: "100%" }}>
            <Boundary label="grid-widget">
              {/* These expect the parameters Studio passes a widget; rendered bare to see what happens. */}
              <GridWidget {...({} as Parameters<typeof GridWidget>[0])} />
            </Boundary>
            <Boundary label="pivot-widget">
              <PivotGridWidget {...({} as Parameters<typeof PivotGridWidget>[0])} />
            </Boundary>
          </div>
        </section>
      </AgStudioProvider>
    </main>
  );
}
