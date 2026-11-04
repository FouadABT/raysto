"use client";
import type { SectionProps } from "./group-section";


/**
 * The supply manager: stock cover, supplier orders and the 3-way match on AG Studio.
 * Owner: stream S3 (docs/release-0.16-design.md). Placeholder until built.
 */
export function SuppliesSection(_props: SectionProps) {
  return (
    <section className="ops-panel" aria-labelledby="supplies-title">
      <h2 id="supplies-title">Supplies</h2>
      <p>Stock, supplier orders and deliveries, planned by the AI. Coming in 0.16.</p>
    </section>
  );
}
