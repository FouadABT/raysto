"use client";
/**
 * The four hero flows the Overview's inbox can start: a bill arrives, a
 * guest complains, this week's payroll, a deposit. Each runs the same
 * backend calls as its Try card (10, 4, 2 and 12) with the same helpers, so
 * the AI coworker does real work that then waits in the inbox for a person.
 * Nothing here approves or pays: approval is the inbox's job, and a result
 * never claims more than the backend returned.
 */
import type { ConnectedApi } from "@/lib/connected/api";
import { agentCost } from "@/lib/connected/business";
import type { Json } from "@/lib/connected/contracts";
import type { InboxAction } from "@/lib/connected/inbox";
import {
  billNext,
  billView,
  depositRequest,
  pickBillFile,
  requestView,
  sampleBillMediaId,
  type BillView,
  type RequestView,
} from "@/lib/connected/try-new";
import { agentTask, pendingOf, poll, unavailable } from "./try-section";

export type FlowId = "bill" | "complaint" | "payroll" | "deposit";
export type Say = (step: string) => void;

export type FlowResult =
  /** The AI coworker's proposal is in the inbox. */
  | { kind: "proposal"; actionId: number; taskId: number; note?: string; aiCost?: string }
  /** The coworker finished without anything to approve; its own words. */
  | { kind: "note"; tone: "done" | "refused"; text: string; paypalId?: string }
  /** A bill read before that can be paid now, without a new proposal. */
  | { kind: "payBill"; bill: BillView }
  /** A pay link waiting for the payer. */
  | { kind: "payLink"; request: RequestView };

const costOf = (task: Json) => (Number(task.chargedMicros ?? 0) > 0 ? agentCost(Number(task.chargedMicros)) : undefined);

function proposalOf(task: Json): FlowResult | undefined {
  const pending = pendingOf(task);
  return pending ? { kind: "proposal", actionId: pending.id, taskId: Number(task.id), aiCost: costOf(task) } : undefined;
}

/** Card 10: the AI accountant reads the café's bill and drafts paying it with PayPal Payouts. */
export async function billArrived(
  api: ConnectedApi,
  tenant: number,
  signal: AbortSignal,
  say: Say,
  inbox: () => Promise<InboxAction[]>,
): Promise<FlowResult> {
  say("Finding the café's newest bill");
  const media = await api.query<{ rows?: Json[] }>("media", { restaurantId: tenant, limit: 100 });
  const file = pickBillFile(media.rows ?? [], sampleBillMediaId);
  if (!file) throw new Error("No bill file is uploaded on this café yet.");
  say("The AI accountant is reading the bill with Gemini");
  let asked: Json;
  try {
    asked = await api.command<Json>("bill.snap", tenant, { mediaId: Number(file.id) });
  } catch (e) {
    throw unavailable(e, "Reading bills");
  }
  let id = Number(asked.duplicateOfId ?? 0);
  if (!id) {
    if (!asked.taskId) throw new Error("The accountant did not start.");
    const done = await agentTask(api, tenant, Number(asked.taskId), signal, 120000);
    const proposal = proposalOf(done);
    if (proposal) return proposal;
    say("Reading what the accountant filed");
    const list = await api.query<{ rows?: Json[] }>("bills", { restaurantId: tenant });
    const filed = (list.rows ?? [])
      .filter((b) => Number(b.sourceMediaId) === Number(file.id) && (!b.taskId || Number(b.taskId) === Number(asked.taskId)))
      .sort((a, b) => Number(b.id) - Number(a.id))[0];
    id = Number(filed?.id ?? 0);
    if (!id) throw new Error(String(done.summary ?? "The accountant could not read a bill from this file."));
  }
  // The same file was read before (no AI spent twice), or filed without a proposal.
  const bill = billView(await api.query<Json>("bill", { restaurantId: tenant, id }));
  if (!bill) throw new Error("The bill could not be read back.");
  const waiting = (await inbox()).find((a) => a.command === "bill.pay" && Number(a.preview?.billId) === id);
  if (waiting)
    return {
      kind: "proposal",
      actionId: waiting.id,
      taskId: waiting.taskId,
      note: "Read before, so no AI was spent again: its payment is already waiting.",
    };
  const batch = bill.providerBatchId ? `PayPal batch ${bill.providerBatchId}` : undefined;
  switch (billNext(bill)) {
    case "pay":
      return { kind: "payBill", bill };
    case "paid":
      return { kind: "note", tone: "done", text: `${bill.vendor}'s bill was read before and is already paid with PayPal Payouts.`, paypalId: batch };
    case "paying":
      return { kind: "note", tone: "done", text: `${bill.vendor}'s bill was read before; PayPal Payouts is paying it now.`, paypalId: batch };
    case "paidElsewhere":
      return { kind: "note", tone: "done", text: `${bill.vendor}'s bill was read before and marked paid outside PayPal.` };
    case "duplicate":
      return { kind: "note", tone: "refused", text: `This looks like bill #${bill.duplicateOfId} again, so the accountant will not pay it twice.` };
    case "void":
      return { kind: "note", tone: "refused", text: "This bill was voided: nothing will be paid." };
    default:
      return { kind: "note", tone: "refused", text: "This vendor has no PayPal account on file, so the bill is paid outside PayPal." };
  }
}

/**
 * The newest order paid with PayPal, with at least $1 still refundable and
 * no complaint yet: never a cash sale, since PayPal can only refund what
 * PayPal captured. Reads the newest checkouts (five pages at most), then
 * each candidate order, as the order panel does.
 */
async function paypalPaidOrder(api: ConnectedApi, tenant: number, taken: Set<number>): Promise<Json | undefined> {
  const seen = new Set<number>();
  let cursor: number | undefined;
  for (let page = 0; page < 5; page++) {
    const r = await api.query<{ rows?: Json[]; nextCursor?: number | null }>("checkouts", {
      restaurantId: tenant,
      staff: true,
      order: "desc",
      limit: 100,
      ...(cursor ? { cursor } : {}),
    });
    for (const c of r.rows ?? []) {
      const orderId = Number(c.orderId ?? 0);
      if (c.method !== "paypal" || c.state !== "completed" || !orderId || taken.has(orderId) || seen.has(orderId)) continue;
      seen.add(orderId);
      const o = await api.query<Json>("order", { restaurantId: tenant, id: orderId, staff: true }).catch(() => undefined);
      if (!o || o.paymentStatus !== "paid" || ["cancelled", "rejected", "expired"].includes(String(o.status))) continue;
      const pay = ((o.payments as Json[] | undefined) ?? []).find((p) => p.method === "paypal" && p.providerCaptureId);
      const refunded = ((pay?.refunds as Json[] | undefined) ?? []).reduce((n, x) => n + Number(x.amountMinor ?? 0), 0);
      if (pay && Number(pay.amountMinor ?? 0) - refunded >= 100) return o;
    }
    if (!r.nextCursor) break;
    cursor = Number(r.nextCursor);
  }
  return undefined;
}

/** Card 4: the complaints agent checks the order and PayPal's capture, then drafts a refund. */
export async function guestComplained(api: ConnectedApi, tenant: number, signal: AbortSignal, say: Say): Promise<FlowResult> {
  say("Looking for a guest's complaint");
  const complaints = () => api.query<{ rows: Json[] }>("complaints", { restaurantId: tenant });
  let list: { rows: Json[] };
  try {
    list = await complaints();
  } catch (e) {
    throw unavailable(e, "Complaints");
  }
  // A complaint the agent is still on, or one it proposed and nobody decided, is reused.
  let row = list.rows.find((r) => ["open", "proposed"].includes(String(r.status)) && r.taskId);
  if (!row) {
    const taken = new Set(list.rows.map((r) => Number(r.orderId)));
    // Card 4 took the newest paid order; here it must be one PayPal captured,
    // since the demo café's stored history is cash at the till.
    const paid = await paypalPaidOrder(api, tenant, taken);
    if (!paid)
      throw new Error("Every order paid with PayPal already has a complaint, so there is nothing new to check. Try again after the next PayPal payment.");
    say(`A guest writes about ticket #${String(paid.number ?? paid.id)}`);
    // The guest names a dish that order really has, so the agent can check it.
    const first = ((paid.lines as Json[] | undefined) ?? [])[0];
    const dish = first ? String(first.name ?? "order").toLowerCase() : "order";
    try {
      await api.command("complaint.open", tenant, { text: `My ${dish} was missing from the bag.` }, { id: Number(paid.id) });
    } catch (e) {
      throw unavailable(e, "Complaints");
    }
    say("The complaints agent is checking the order and PayPal's capture");
    try {
      row = await poll(
        async () => (await complaints()).rows.find((r) => Number(r.orderId) === Number(paid.id) && r.taskId),
        (r) => r !== undefined,
        signal,
        2000,
        30000,
      );
    } catch (e) {
      if (signal.aborted) throw e;
      throw new Error("The complaints agent did not pick it up. Try again in a minute.");
    }
  } else {
    say("The complaints agent is checking the order and PayPal's capture");
  }
  const done = await agentTask(api, tenant, Number(row!.taskId), signal, 120000);
  const proposal = proposalOf(done);
  if (proposal) return proposal;
  // Refunded on its own within the owner's limit, or no refund proposed.
  const fresh = (await complaints().catch(() => list)).rows.find((r) => Number(r.id) === Number(row!.id));
  const refundId = typeof fresh?.providerRefundId === "string" && fresh.providerRefundId ? `PayPal refund ${fresh.providerRefundId}` : undefined;
  return {
    kind: "note",
    tone: fresh?.status === "refunded" ? "done" : "refused",
    text: String(done.summary ?? "The complaints agent proposed no refund."),
    paypalId: refundId,
  };
}

/** Card 2: this week's tips and wages, paid with PayPal Payouts after approval. */
export async function runPayroll(api: ConnectedApi, tenant: number, signal: AbortSignal, say: Say): Promise<FlowResult> {
  say("The payroll agent is adding up this week's shifts and tips");
  const to = new Date();
  const from = new Date(to.getTime() - 7 * 86400000);
  let asked: { taskId?: number };
  try {
    asked = await api.command<{ taskId?: number }>("payroll.run", tenant, { from: from.toISOString(), to: to.toISOString() });
  } catch (e) {
    throw unavailable(e, "The pay run");
  }
  if (!asked.taskId) throw new Error("The payroll agent did not start.");
  const done = await agentTask(api, tenant, asked.taskId, signal, 120000);
  return proposalOf(done) ?? { kind: "note", tone: "refused", text: String(done.summary ?? "No one is owed anything this week.") };
}

/** Card 12: a deposit pay link with a QR code, paid on PayPal's own page. */
export async function collectDeposit(api: ConnectedApi, tenant: number, _signal: AbortSignal, say: Say): Promise<FlowResult> {
  say("Making the pay link");
  let created: Json;
  try {
    // Card 12's request; the payer stays marked "· Sample" and the pay step carries the Sandbox chip.
    created = await api.command<Json>("request.create", tenant, { ...depositRequest, description: "Catering deposit · Friday lunch for 12" });
  } catch (e) {
    throw unavailable(e, "Making pay links");
  }
  const view = requestView(created);
  if (!view?.id) throw new Error("The pay link could not be read back.");
  if (!view.payUrl) throw new Error("The request was made, but this deployment has no pay-link secret yet, so its link cannot open.");
  return { kind: "payLink", request: view };
}

/** Reads a pay link until PayPal's capture marks it paid, or it is cancelled (15 minutes at most). */
export async function waitForPayment(api: ConnectedApi, tenant: number, id: number, signal: AbortSignal): Promise<RequestView> {
  const final = await poll(
    () => api.query<Json>("request", { restaurantId: tenant, id }),
    (r) => ["paid", "cancelled"].includes(String(r.state)),
    signal,
    3000,
    15 * 60000,
  );
  const view = requestView(final);
  if (!view) throw new Error("The pay link could not be read back.");
  return view;
}
