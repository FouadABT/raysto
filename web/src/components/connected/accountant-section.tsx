"use client";
import type { SectionProps } from "./group-section";


/**
 * The AI accountant: P&amp;L, cash flow, payables and receivables on AG Studio, bills and pay links.
 * Owner: stream S1 (docs/release-0.16-design.md). Placeholder until built.
 */
export function AccountantSection(_props: SectionProps) {
  return (
    <section className="ops-panel" aria-labelledby="accountant-title">
      <h2 id="accountant-title">Accountant</h2>
      <p>Bills, pay links and the books, prepared by the AI accountant. Coming in 0.16.</p>
    </section>
  );
}
