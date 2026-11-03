/**
 * Pure helpers for the console's Overview: the greeting, the comparison
 * wording, the kitchen total and the range words. Kept free of React so the
 * unit tests run them directly.
 */
import type { Dashboard, DashboardRange } from "./dashboard";

/** "Good morning" / "Good afternoon" / "Good evening" at the café's own hour. */
export function greetingFor(now: Date, timeZone?: string): string {
  const hour = localHour(now, timeZone);
  if (hour >= 5 && hour < 12) return "Good morning";
  if (hour >= 12 && hour < 17) return "Good afternoon";
  return "Good evening";
}

export function localHour(now: Date, timeZone?: string): number {
  try {
    const part = new Intl.DateTimeFormat("en-US", { hour: "numeric", hourCycle: "h23", timeZone })
      .formatToParts(now)
      .find((p) => p.type === "hour");
    const h = Number(part?.value);
    return Number.isFinite(h) ? h % 24 : now.getHours();
  } catch {
    return now.getHours();
  }
}

/** "Tuesday 3 November" in the café's zone. */
export function localDate(now: Date, timeZone?: string): string {
  try {
    return new Intl.DateTimeFormat("en-GB", { weekday: "long", day: "numeric", month: "long", timeZone }).format(now);
  } catch {
    return now.toDateString();
  }
}

/** "America/New_York" → "New York". */
export function zoneCity(timeZone?: string): string {
  if (!timeZone) return "";
  return (timeZone.split("/").pop() ?? "").replaceAll("_", " ");
}

/**
 * The first name to greet: the account's display name, else the part of the
 * email before "@". The judges' café greets its published login as "judge".
 */
export function firstName(displayName?: string | null, email?: string | null, judges = false): string {
  if (judges) return "judge";
  const fromName = (displayName ?? "").trim().split(/\s+/)[0];
  if (fromName) return fromName;
  const local = (email ?? "").split("@")[0]?.split(/[._+-]/)[0] ?? "";
  return local ? local.charAt(0).toUpperCase() + local.slice(1) : "";
}

/** The comparison period, as words. */
export function previousWords(range: DashboardRange): string {
  return range === "today" ? "yesterday at this time" : range === "7d" ? "the previous 7 days" : "the previous 30 days";
}

/** The comparison period on a chip-sized line: "vs previous 7 days". */
export function previousShort(range: DashboardRange): string {
  return range === "today" ? "vs yesterday so far" : range === "7d" ? "vs previous 7 days" : "vs previous 30 days";
}

/** The window itself, as words. */
export function rangeWords(range: DashboardRange): string {
  return range === "today" ? "today" : range === "7d" ? "the last 7 days" : "the last 30 days";
}

export type Trend = "up" | "down" | "flat" | "new" | "none";

/** Direction and rounded percentage of a change; `new` when there was nothing before. */
export function trend(value: number, previous: number): { kind: Trend; percent: number } {
  if (previous === 0) return value === 0 ? { kind: "none", percent: 0 } : { kind: "new", percent: 0 };
  const percent = Math.round(((value - previous) / Math.abs(previous)) * 100);
  if (percent === 0) return { kind: "flat", percent: 0 };
  return { kind: percent > 0 ? "up" : "down", percent: Math.abs(percent) };
}

/** The short chip: "+215%", "−30%", "Same", "New", "—". */
export function deltaChip(value: number, previous: number): string {
  const t = trend(value, previous);
  switch (t.kind) {
    case "up":
      return `+${t.percent}%`;
    case "down":
      return `−${t.percent}%`;
    case "flat":
      return "Same";
    case "new":
      return "New";
    default:
      return "—";
  }
}

/** What a screen reader hears: "up 215% on the previous 7 days". */
export function deltaSentence(value: number, previous: number, range: DashboardRange): string {
  const t = trend(value, previous);
  const period = previousWords(range);
  switch (t.kind) {
    case "up":
      return `up ${t.percent}% on ${period}`;
    case "down":
      return `down ${t.percent}% on ${period}`;
    case "flat":
      return `the same as ${period}`;
    case "new":
      return `new: nothing in ${period}`;
    default:
      return `nothing yet, and nothing in ${period}`;
  }
}

/** Orders open in the kitchen now: new, accepted, preparing and ready. */
export function kitchenTotal(k: Dashboard["kitchen"]): number {
  return k.submitted + k.accepted + k.preparing + k.ready;
}

/** True when the window holds no real paid order at all. */
export function noSales(d: Pick<Dashboard, "kpis" | "points">): boolean {
  return d.kpis.orders.value === 0 && d.points.every((p) => p.salesMinor === 0 && p.orders === 0);
}

const channels: Record<string, string> = {
  pickup: "Pickup",
  counter: "Counter",
  table: "Table",
  delivery: "Delivery",
  dineIn: "Dine-in",
  online: "Online",
};

export function channelName(c: string): string {
  return channels[c] ?? c.charAt(0).toUpperCase() + c.slice(1);
}

export const ranges: readonly { id: DashboardRange; label: string }[] = [
  { id: "today", label: "Today" },
  { id: "7d", label: "7 days" },
  { id: "30d", label: "30 days" },
];

export function isRange(v: unknown): v is DashboardRange {
  return v === "today" || v === "7d" || v === "30d";
}
