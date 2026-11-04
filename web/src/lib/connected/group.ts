/**
 * Franchise groups in the console: the shapes of the group.* queries and the
 * arithmetic the Group section and its Studio pages share. Pure, so it is
 * unit-tested (tests/group.test.ts). Money is in minor units and is summed
 * per currency only: a group with a dollar café and a euro bistro has two
 * totals, never one.
 */
import type { Membership } from "./contracts";
import { major, type StudioRow } from "./studio/sources";

export type GroupRole = "owner" | "areaManager" | "accountant";

/** A group as `me` lists it. */
export interface GroupRef {
  id: number;
  name: string;
  role: GroupRole;
}

export interface GroupVenueRef {
  restaurantId: number;
  name: string;
  currency: string;
  /** The person's own role in this venue, if any. */
  role?: string | null;
}

/** A group as `group.list` returns it. */
export interface GroupRow extends GroupRef {
  currency?: string | null;
  version: number;
  venues: GroupVenueRef[];
}

export type GroupRange = "today" | "7d" | "30d";

export interface VenueFigures {
  restaurantId: number;
  name: string;
  currency: string;
  paidSalesMinor: number;
  orders: number;
  averageTicketMinor: number;
  refundsMinor: number;
  payoutsMinor: number;
  billsDue: number;
  billsDueMinor: number;
  lowStock: number;
  liveDeliveries: number;
}

export interface CurrencyTotals {
  currency: string;
  [key: string]: number | string;
}

export interface GroupOverview {
  groupId: number;
  range: GroupRange;
  venues: VenueFigures[];
  totals: CurrencyTotals[];
}

export interface CompareRow {
  restaurantId: number;
  venue: string;
  currency: string;
  date: string;
  salesMinor: number;
  orders: number;
}

export interface LedgerLine {
  restaurantId: number;
  venue: string;
  date: string;
  at: string;
  account: string;
  accountName: string;
  debitMinor: number;
  creditMinor: number;
  currency: string;
  memo?: string | null;
  source?: { kind?: string; id?: number | string; estimated?: boolean } | null;
}

export interface PayableRow {
  restaurantId: number;
  venue: string;
  currency: string;
  id: number;
  vendor: string;
  category?: string | null;
  amountMinor: number;
  dueAt?: string | null;
  state: string;
  daysOverdue: number;
}

export interface TemplateRow {
  id: number;
  name: string;
  items: { name: string; priceMinor?: number; description?: string; category?: string }[];
  version: number;
  updatedAt: string;
}

export const rangeLabel: Record<GroupRange, string> = { today: "Today", "7d": "7 days", "30d": "30 days" };

/** "Owner", "Area manager", "Accountant". */
export const roleLabel = (role: string) =>
  role === "areaManager" ? "Area manager" : role.charAt(0).toUpperCase() + role.slice(1);

/** Owners and accountants read the group's books; an area manager reads sales and stock. */
export const readsMoney = (role?: string) => role === "owner" || role === "accountant";

/** The group a venue belongs to, among the person's groups. */
export function groupOfVenue(groups: readonly GroupRow[], restaurantId: number): GroupRow | undefined {
  return groups.find((g) => g.venues.some((v) => v.restaurantId === restaurantId));
}

/** The currencies in play, in a stable order. */
export function currenciesOf(rows: readonly { currency: string }[]): string[] {
  return [...new Set(rows.map((r) => r.currency.toUpperCase()))].sort();
}

/**
 * Venue figures summed per currency. Never adds a dollar to a euro: each
 * currency keeps its own total, and the venues in it are counted.
 */
export function totalsByCurrency(
  venues: readonly VenueFigures[],
): { currency: string; venues: number; paidSalesMinor: number; orders: number; billsDueMinor: number; lowStock: number }[] {
  const by = new Map<string, { currency: string; venues: number; paidSalesMinor: number; orders: number; billsDueMinor: number; lowStock: number }>();
  for (const v of venues) {
    const code = v.currency.toUpperCase();
    const t = by.get(code) ?? { currency: code, venues: 0, paidSalesMinor: 0, orders: 0, billsDueMinor: 0, lowStock: 0 };
    t.venues += 1;
    t.paidSalesMinor += v.paidSalesMinor;
    t.orders += v.orders;
    t.billsDueMinor += v.billsDueMinor;
    t.lowStock += v.lowStock;
    by.set(code, t);
  }
  return [...by.values()].sort((a, b) => a.currency.localeCompare(b.currency));
}

/** Studio rows for the Portfolio page: one per venue, money in major units. */
export function venueRows(venues: readonly VenueFigures[], currency?: string): StudioRow[] {
  return venues
    .filter((v) => !currency || v.currency.toUpperCase() === currency)
    .map((v) => ({
      venue: v.name,
      currency: v.currency.toUpperCase(),
      sales: major(v.paidSalesMinor),
      orders: v.orders,
      averageTicket: major(v.averageTicketMinor),
      refunds: major(v.refundsMinor),
      payouts: major(v.payoutsMinor),
      billsDue: v.billsDue,
      billsDueAmount: major(v.billsDueMinor),
      lowStock: v.lowStock,
      liveDeliveries: v.liveDeliveries,
    }));
}

/** Studio rows for Compare venues: venue × day. */
export function compareRows(rows: readonly CompareRow[], currency?: string): StudioRow[] {
  return rows
    .filter((r) => !currency || r.currency.toUpperCase() === currency)
    .map((r) => ({
      venue: r.venue,
      currency: r.currency.toUpperCase(),
      day: r.date,
      sales: major(r.salesMinor),
      orders: r.orders,
    }));
}

/** Studio rows for Money: one per journal line, signed so revenue and cost read as positive. */
export function ledgerRows(lines: readonly LedgerLine[], currency?: string): StudioRow[] {
  return lines
    .filter((l) => !currency || l.currency.toUpperCase() === currency)
    .map((l) => {
      const debit = Number(l.debitMinor ?? 0);
      const credit = Number(l.creditMinor ?? 0);
      const head = String(l.account ?? "").charAt(0);
      // Revenue (4xxx) and liabilities and equity (2xxx, 3xxx) grow with credits; the rest with debits.
      const signed = ["2", "3", "4"].includes(head) ? credit - debit : debit - credit;
      return {
        venue: l.venue,
        currency: l.currency.toUpperCase(),
        month: String(l.date ?? "").slice(0, 7),
        day: String(l.date ?? "").slice(0, 10),
        account: `${l.account} ${l.accountName}`,
        kind: head === "4" ? "Revenue" : head === "5" || head === "6" ? "Costs" : head === "1" ? "Assets" : "Liabilities",
        amount: major(signed),
        debit: major(debit),
        credit: major(credit),
        memo: l.memo ?? "",
        source: l.source?.kind ?? "",
        estimated: l.source?.estimated === true,
      };
    });
}

/**
 * Studio rows for the profit and loss: revenue and cost lines only, revenue
 * positive and costs negative, so a pivot's total row is the profit.
 */
export function pnlRows(lines: readonly LedgerLine[], currency?: string): StudioRow[] {
  return lines
    .filter((l) => !currency || l.currency.toUpperCase() === currency)
    .filter((l) => ["4", "5", "6"].includes(String(l.account ?? "").charAt(0)))
    .map((l) => {
      const revenue = String(l.account).charAt(0) === "4";
      const debit = Number(l.debitMinor ?? 0);
      const credit = Number(l.creditMinor ?? 0);
      return {
        venue: l.venue,
        month: String(l.date ?? "").slice(0, 7),
        kind: revenue ? "Revenue" : "Costs",
        account: `${l.account} ${l.accountName}`,
        amount: major(revenue ? credit - debit : -(debit - credit)),
      };
    });
}

/** Payables in aging buckets, as accountants read them. */
export function agingBucket(daysOverdue: number): "Not due" | "0–30 days" | "31–60 days" | "61–90 days" | "90+ days" {
  if (daysOverdue <= 0) return "Not due";
  if (daysOverdue <= 30) return "0–30 days";
  if (daysOverdue <= 60) return "31–60 days";
  if (daysOverdue <= 90) return "61–90 days";
  return "90+ days";
}

/**
 * Menu template lines from plain text: one dish per line, "Name, 12.50" or
 * "Name — 12.50 — description". Prices become minor units; a line without a
 * price, or with a bad one, is reported, not guessed.
 */
export function parseTemplateLines(text: string): { items: { name: string; priceMinor: number; description?: string }[]; errors: string[] } {
  const items: { name: string; priceMinor: number; description?: string }[] = [];
  const errors: string[] = [];
  text
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean)
    .forEach((line, i) => {
      const parts = line.split(/\s*[,;|—–]\s*|\s+-\s+/).filter(Boolean);
      const name = parts[0]?.trim() ?? "";
      const price = parts[1]?.replace(/[^\d.]/g, "") ?? "";
      if (!name || !/^\d+(\.\d{1,2})?$/.test(price)) {
        errors.push(`Line ${i + 1}: write it as "Dish name, 12.50".`);
        return;
      }
      if (name.length > 80) {
        errors.push(`Line ${i + 1}: the name is longer than 80 characters.`);
        return;
      }
      items.push({
        name,
        priceMinor: Math.round(Number(price) * 100),
        ...(parts[2] ? { description: parts.slice(2).join(", ").slice(0, 280) } : {}),
      });
    });
  if (items.length > 80) errors.push("A template holds at most 80 dishes.");
  return { items, errors };
}

/** The venues the picker offers: all of them, or the chosen group's that the person works in. */
export function venuesInChoice(memberships: readonly Membership[], choice: { groups: readonly GroupRow[]; groupId: number | null } | null): Membership[] {
  const group = choice?.groupId ? choice.groups.find((g) => g.id === choice.groupId) : undefined;
  if (!group) return [...memberships];
  const ids = new Set(group.venues.map((v) => v.restaurantId));
  const inside = memberships.filter((m) => ids.has(m.restaurantId));
  // A group role without a venue role still needs a venue to open the console in.
  return inside.length ? inside : [...memberships];
}
