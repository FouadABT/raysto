import {
  compareRows,
  pnlRows,
  venueRows,
  type CompareRow,
  type LedgerLine,
  type VenueFigures,
} from "../group";
import type { StudioSource } from "./sources";

const text = (...ids: string[]) =>
  ids.map((id) => ({ id, format: "textFormat" as const }));
const decimal = (...ids: string[]) =>
  ids.map((id) => ({ id, format: "decimalFormat" as const }));

/** Schemas remain valid for loading, empty and currency-filtered results. Never fabricate a data row. */
export function groupStudioSources(
  venues: readonly VenueFigures[],
  days: readonly CompareRow[],
  ledger: readonly LedgerLine[],
  currency: string,
): StudioSource[] {
  return [
    {
      id: "venues",
      data: venueRows(venues, currency),
      fields: [
        ...text("venue", "currency"),
        ...decimal(
          "sales",
          "orders",
          "averageTicket",
          "refunds",
          "payouts",
          "billsDue",
          "billsDueAmount",
          "lowStock",
          "liveDeliveries",
        ),
      ],
    },
    {
      id: "days",
      data: compareRows(days, currency),
      fields: [
        ...text("venue", "currency", "day"),
        ...decimal("sales", "orders"),
      ],
    },
    {
      id: "pnl",
      data: pnlRows(ledger, currency),
      fields: [
        ...text("venue", "month", "kind", "account"),
        ...decimal("amount"),
      ],
    },
  ];
}
