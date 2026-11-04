/**
 * The Group section on the development preview (`/ops/preview?state=group`):
 * a sample group of two venues in two currencies, so the browser tests see
 * the switcher, the Studio pages and the grids without a backend. Sample
 * figures only; the preview sends no command.
 */
import type { Json } from "./contracts";
import type { CompareRow, GroupRef, GroupRow, LedgerLine, PayableRow, TemplateRow, VenueFigures } from "./group";

const cafe = { restaurantId: 1, name: "Atelier Café · Preview", currency: "USD" };
const harbour = { restaurantId: 2, name: "Atelier Harbour · Preview", currency: "EUR" };

export const groupPreviewRefs: GroupRef[] = [{ id: 7, name: "Atelier Group · Sample", role: "owner" }];

/** The shell's props for `?state=group`: two venues and one group. */
export function groupPreviewShell(state: string) {
  if (state !== "group") return {};
  return {
    memberships: [
      { restaurantId: cafe.restaurantId, name: cafe.name, role: "owner" },
      { restaurantId: harbour.restaurantId, name: harbour.name, role: "owner" },
      // Outside the group: the switcher hides it when the group is chosen.
      { restaurantId: 3, name: "Corner Deli · Preview", role: "owner" },
    ] as never[],
    groups: groupPreviewRefs,
  };
}

const day = (asOf: string, back: number) => new Date(Date.parse(asOf) - back * 86_400_000).toISOString().slice(0, 10);

/** The group.* answers for `?state=group`; other states get none. */
export function groupPreview(state: string, asOf: string): Record<string, (p: Json) => unknown> {
  if (state !== "group") return {};
  const group: GroupRow = {
    id: 7,
    name: "Atelier Group · Sample",
    role: "owner",
    currency: "USD",
    version: 3,
    venues: [
      { ...cafe, role: "owner" },
      { ...harbour, role: "owner" },
    ],
  };
  const venues: VenueFigures[] = [
    { ...cafe, paidSalesMinor: 184250, orders: 61, averageTicketMinor: 3020, refundsMinor: 1250, payoutsMinor: 28800, billsDue: 2, billsDueMinor: 31640, lowStock: 3, liveDeliveries: 1 },
    { ...harbour, paidSalesMinor: 96400, orders: 28, averageTicketMinor: 3443, refundsMinor: 0, payoutsMinor: 0, billsDue: 1, billsDueMinor: 12900, lowStock: 1, liveDeliveries: 0 },
  ];
  const compare: CompareRow[] = [];
  for (let i = 6; i >= 0; i--)
    for (const [v, base] of [
      [cafe, 24000],
      [harbour, 13000],
    ] as const)
      compare.push({ restaurantId: v.restaurantId, venue: v.name, currency: v.currency, date: day(asOf, i), salesMinor: base + ((i * 3170) % 9000), orders: 6 + ((i * 5) % 7) });
  const lines: LedgerLine[] = [];
  const add = (v: typeof cafe, back: number, account: string, accountName: string, debit: number, credit: number, memo: string) =>
    lines.push({ restaurantId: v.restaurantId, venue: v.name, date: day(asOf, back), at: `${day(asOf, back)}T12:00:00Z`, account, accountName, debitMinor: debit, creditMinor: credit, currency: v.currency, memo, source: { kind: "sample" } });
  for (const [v, sales, fee] of [
    [cafe, 184250, 6450],
    [harbour, 96400, 3380],
  ] as const) {
    add(v, 2, "1000", "PayPal balance", sales, 0, "PayPal captures");
    add(v, 2, "4000", "Sales", 0, sales, "PayPal captures");
    add(v, 2, "6000", "PayPal fees", fee, 0, "PayPal fees (estimated)");
    add(v, 2, "1000", "PayPal balance", 0, fee, "PayPal fees (estimated)");
    add(v, 4, "6100", "Utilities", v === cafe ? 18240 : 12900, 0, "Electricity");
    add(v, 4, "2000", "Payables", 0, v === cafe ? 18240 : 12900, "Electricity");
  }
  const payables: PayableRow[] = [
    { ...cafe, venue: cafe.name, id: 31, vendor: "Brussels Power", category: "utilities", amountMinor: 18240, dueAt: `${day(asOf, -3)}T00:00:00Z`, state: "approved", daysOverdue: 0 },
    { ...cafe, venue: cafe.name, id: 32, vendor: "Aqua City Water", category: "utilities", amountMinor: 13400, dueAt: `${day(asOf, 12)}T00:00:00Z`, state: "review", daysOverdue: 12 },
    { ...harbour, venue: harbour.name, id: 41, vendor: "Harbour Electric", category: "utilities", amountMinor: 12900, dueAt: `${day(asOf, -5)}T00:00:00Z`, state: "approved", daysOverdue: 0 },
  ];
  const templates: TemplateRow[] = [
    {
      id: 5,
      name: "Winter specials",
      items: [
        { name: "Mushroom soup", priceMinor: 750, category: "Group specials" },
        { name: "Lemon tart", priceMinor: 600, category: "Group specials" },
      ],
      version: 1,
      updatedAt: asOf,
    },
  ];
  const sum = (key: keyof VenueFigures) =>
    ["EUR", "USD"].map((c) => ({ currency: c, [key]: venues.filter((v) => v.currency === c).reduce((n, v) => n + Number(v[key]), 0) }));
  return {
    "group.list": () => ({ rows: [group], nextCursor: null }),
    "group.overview": (p) => ({ groupId: 7, range: p.range ?? "7d", venues, totals: sum("paidSalesMinor") }),
    "group.compare": (p) => ({ groupId: 7, range: p.range ?? "7d", rows: compare }),
    "group.ledger": () => ({ groupId: 7, basis: "journal", rows: lines, truncated: false, totals: [] }),
    "group.payables": () => ({ groupId: 7, rows: payables, totals: [] }),
    "group.templates": () => ({ rows: templates, nextCursor: null }),
    "studio.layout": (p) => ({ scope: p.scope, section: p.section, state: null, version: null }),
  };
}
