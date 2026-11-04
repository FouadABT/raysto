"use client";
import type { SectionProps } from "./group-section";


/**
 * Delivery dispatch: the OpenStreetMap board, drivers, offers and the partner event log.
 * Owner: stream S2 (docs/release-0.16-design.md). Placeholder until built.
 */
export function DispatchSection(_props: SectionProps) {
  return (
    <section className="ops-panel" aria-labelledby="dispatch-title">
      <h2 id="dispatch-title">Dispatch</h2>
      <p>Drivers, deliveries on a live map, and partner apps. Coming in 0.16.</p>
    </section>
  );
}
