/**
 * How the Money, Team and Customers sections read their records on the
 * Material 3 kit: people from shifts, PayPal ids from an approval's result,
 * the hours of the day worth charting. Pure, so it is unit tested.
 */
import type { Json } from "./contracts";
import { shiftHours, shiftPayMinor, shiftState, type CustomerProfile, type PayoutBatch, type Shift } from "./backoffice";

/** The PayPal id an executed action or command returned, with what it is. */
export function paypalIdOf(result: Json | undefined | null): string | undefined {
  if (!result) return undefined;
  const pick: [string, string][] = [
    ["providerBatchId", "PayPal batch"],
    ["invoiceNumber", "PayPal invoice"],
    ["providerInvoiceId", "PayPal invoice"],
    ["providerRefundId", "PayPal refund"],
    ["providerCaptureId", "PayPal capture"],
    ["providerDisputeId", "PayPal dispute"],
  ];
  for (const [key, label] of pick) {
    const v = result[key];
    if (typeof v === "string" && v) return `${label} ${v}`;
  }
  return undefined;
}

/** The snackbar line after an approval from a money tab: what happened, and PayPal's id. */
export function approvalNotice(state: string, result?: Json | null): string {
  if (state === "executed") {
    const id = paypalIdOf(result);
    return id ? `Approved. ${id}.` : "Approved.";
  }
  if (state === "rejected") return "Turned down. Nothing changed.";
  if (state === "stale") return "Things changed since the agent looked. It will check again.";
  if (result?.error === "provider_feature_disabled")
    return "PayPal refused it: this feature is not enabled on the Sandbox app yet. Nothing was sent or charged.";
  const said = typeof result?.message === "string" ? result.message : "";
  return said ? `It did not go through: ${said}` : "It did not go through.";
}

export type Person = {
  name: string;
  role: string;
  /** Worked or planned hours this week, quarter-hour rounded per shift. */
  hours: number;
  wageMinor: number;
  shifts: Shift[];
  /** onShift while any shift is clocked in, else planned when one is still ahead, else done. */
  state: "onShift" | "planned" | "done";
  payoutEmail?: string | null;
};

/** One card per person: their shifts this week, hours and wage, newest role. */
export function peopleOf(shifts: readonly Shift[], now = new Date()): Person[] {
  const byName = new Map<string, Shift[]>();
  for (const s of shifts) {
    const key = s.name.trim() || "Unnamed";
    byName.set(key, [...(byName.get(key) ?? []), s]);
  }
  const people: Person[] = [];
  for (const [name, list] of byName) {
    const sorted = [...list].sort((a, b) => a.startsAt.localeCompare(b.startsAt));
    const states = sorted.map((s) => shiftState(s, now));
    people.push({
      name,
      role: sorted[sorted.length - 1].role,
      hours: sorted.reduce((n, s) => n + shiftHours(s, now), 0),
      wageMinor: sorted.reduce((n, s) => n + shiftPayMinor(s, now), 0),
      shifts: sorted,
      state: states.includes("onShift") ? "onShift" : states.includes("planned") ? "planned" : "done",
      payoutEmail: sorted.find((s) => s.payoutEmail)?.payoutEmail ?? null,
    });
  }
  return people.sort((a, b) => b.hours - a.hours || a.name.localeCompare(b.name));
}

/** A person who worked but has no PayPal email yet: held out of the batch, by name. */
export interface HeldLine {
  recipientName: string;
  amountMinor: number;
  minutes?: number;
  reason?: string;
}

/** The held lines the payroll agent recorded on a batch (never sent to PayPal). */
export function heldOf(b: object): HeldLine[] {
  const held = ((b as { summary?: unknown }).summary as { held?: unknown } | null | undefined)?.held;
  if (!Array.isArray(held)) return [];
  return held
    .filter((h): h is Record<string, unknown> => !!h && typeof h === "object")
    .map((h) => ({
      recipientName: String(h.recipientName ?? ""),
      amountMinor: Number(h.amountMinor ?? 0),
      minutes: h.minutes == null ? undefined : Number(h.minutes),
      reason: h.reason == null ? undefined : String(h.reason),
    }))
    .filter((h) => h.recipientName);
}

/** The newest payout line for a person, if any batch named them. */
export function payoutFor(name: string, batches: readonly PayoutBatch[]): { state: string; amountMinor: number; currency: string; kind: string } | undefined {
  const newest = [...batches].sort((a, b) => b.createdAt.localeCompare(a.createdAt));
  for (const b of newest) {
    // A list row from an older backend may carry no lines; it names nobody.
    const item = (b.items ?? []).find((i) => i.recipientName.trim().toLowerCase() === name.trim().toLowerCase());
    if (item) return { state: item.state ?? b.state, amountMinor: item.amountMinor, currency: b.currency, kind: b.kind };
  }
  return undefined;
}

/** The newest batch that has left "proposed": the one whose PayPal outcome is worth showing. */
export function latestSent(batches: readonly PayoutBatch[]): PayoutBatch | undefined {
  return [...batches].filter((b) => b.state !== "proposed").sort((a, b) => b.createdAt.localeCompare(a.createdAt))[0];
}

/** Share of the biggest spender, 0..1, for a customer's spend bar. */
export function spendShare(c: Pick<CustomerProfile, "spentMinor">, all: readonly Pick<CustomerProfile, "spentMinor">[]): number {
  const top = Math.max(0, ...all.map((x) => x.spentMinor));
  return top > 0 ? Math.min(1, Math.max(0, c.spentMinor) / top) : 0;
}

/**
 * The hours worth charting: from one hour before the first sale to one hour
 * after the last, and never narrower than 07:00–21:00 so a quiet day still
 * reads as a day. Every hour inside is kept, zeros included.
 */
export function hourWindow(byHour: readonly { hour: number; salesMinor: number; orders: number }[]) {
  const sold = byHour.filter((h) => h.salesMinor > 0).map((h) => h.hour);
  const from = Math.max(0, Math.min(7, ...(sold.length ? [Math.min(...sold) - 1] : [7])));
  const to = Math.min(23, Math.max(21, ...(sold.length ? [Math.max(...sold) + 1] : [21])));
  const at = new Map(byHour.map((h) => [h.hour, h]));
  const out: { hour: number; salesMinor: number; orders: number; label: string }[] = [];
  for (let h = from; h <= to; h++) {
    const row = at.get(h);
    out.push({ hour: h, salesMinor: row?.salesMinor ?? 0, orders: row?.orders ?? 0, label: `${h}:00` });
  }
  return out;
}
