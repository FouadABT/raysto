"use client";
import type { ConnectedApi } from "@/lib/connected/api";

/** Props every 0.16 section receives from the workspace. */
export interface SectionProps {
  api: ConnectedApi;
  tenant: number;
  revision: string;
  currencyCode: string;
}

/**
 * Franchise view: every venue of the group on AG Studio pages (portfolio, compare venues, money).
 * Owner: stream S4 (docs/release-0.16-design.md). Placeholder until built.
 */
export function GroupSection(_props: SectionProps) {
  return (
    <section className="ops-panel" aria-labelledby="group-title">
      <h2 id="group-title">Group</h2>
      <p>All your venues side by side. Coming in 0.16.</p>
    </section>
  );
}
