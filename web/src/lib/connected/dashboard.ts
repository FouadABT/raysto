/**
 * The owner's dashboard, as the `dashboard` query returns it (backend
 * 0.15.0). The contract is docs/dashboard-contract.md; the fixtures in
 * docs/fixtures/ hold the exact shape. Money is integer minor units, instants
 * are UTC ISO strings, buckets are the café's own local hours or days.
 */

export type DashboardRange = "today" | "7d" | "30d";

/** One hour (today) or day (7d, 30d), oldest first; empty buckets are zeros. */
export interface DashboardPoint {
  start: string;
  label: string;
  salesMinor: number;
  orders: number;
}

/** A figure for the window, the same-length window before it, and its series aligned with `points`. */
export interface DashboardKpi {
  value: number;
  previous: number;
  series: number[];
}

export interface DashboardChannel {
  channel: string;
  salesMinor: number;
  orders: number;
}

export interface DashboardOrder {
  id: number;
  number: number | null;
  status: string;
  paymentStatus: string;
  fulfillment: string;
  origin: string;
  totalMinor: number;
  currency: string;
  createdAt: string;
  customerLabel: string | null;
}

export interface DashboardPerson {
  name: string;
  ordersMoved: number;
  hours: number;
}

export interface Dashboard {
  range: DashboardRange;
  timezone: string;
  currency: string;
  from: string;
  to: string;
  granularity: "hour" | "day";
  /** Always paid (or partly refunded) orders, counted when placed. */
  basis: "paidOrdersByCreatedAt";
  points: DashboardPoint[];
  kpis: {
    sales: DashboardKpi;
    orders: DashboardKpi;
    averageTicket: DashboardKpi;
    tips: DashboardKpi;
  };
  channels: DashboardChannel[];
  /** Live: orders open in the kitchen now, whatever the range. */
  kitchen: {
    submitted: number;
    accepted: number;
    preparing: number;
    ready: number;
    oldestMinutes: number;
  };
  latest: DashboardOrder[];
  staff: DashboardPerson[];
  target: { dailyTargetMinor: number; todayMinor: number };
  /**
   * The judges' café only, when its sample switch is on: a labelled weekly
   * pattern, never a sale. Draw it apart from the real figures, with `label`
   * always visible; never add it to anything.
   */
  sample: { label: string; points: DashboardPoint[] } | null;
}
