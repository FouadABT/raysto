/**
 * Raysto's AG Studio AI tools (defineAiTool), for the Group section's Studio:
 *
 * - raysto_pnl: revenue, costs and profit per currency from the venues'
 *   journals (group.ledger). Owners and accountants only.
 * - raysto_bills_due: unpaid bills due soon or overdue (group.payables).
 * - raysto_stockouts: items at or under their low mark, or that run out
 *   before a delivery could arrive, per venue (stock.forecast).
 * - raysto_propose: asks a venue's agent for a proposal (a restock plan or
 *   a bills review). It only creates an agent task; nothing is paid, sent
 *   or ordered until a person approves it in Agents.
 *
 * `RaystoToolHarness` is the assistant panel behind them. It picks the tool
 * from the question's words and runs it in the browser, through the same
 * console API (never from the browser to PayPal); no language model runs
 * here, and the panel says so. Each call shows as a tool step, so the
 * reader sees which figures the answer came from.
 */
import type {
  AgAiChatMessage,
  AgAiChatSession,
  AgAiChatSessionEventListener,
  AgAiHarness,
  AgAiHarnessEventListener,
  AgAiNewThreadOptions,
  AgAiRunStatus,
  AgAiThreadSummary,
  AgAiTool,
  AgAiToolContext,
  AgAiToolResult,
  AgBaseAiToolDisplay,
  AgStudioApi,
} from "ag-studio";
import type { ConnectedApi } from "../api";
import { currency } from "../contracts";
import type { GroupRange, GroupVenueRef, LedgerLine, PayableRow } from "../group";

export interface ToolScope {
  api: ConnectedApi;
  groupId: number;
  groupName: string;
  venues: GroupVenueRef[];
  range: GroupRange;
  /** Owners and accountants read the books. */
  money: boolean;
}

export const toolNames = ["raysto_pnl", "raysto_bills_due", "raysto_stockouts", "raysto_propose"] as const;
export type ToolName = (typeof toolNames)[number];

const rangeWords: Record<GroupRange, string> = { today: "today", "7d": "the last 7 days", "30d": "the last 30 days" };

/** Revenue, costs and profit per currency from journal lines. Never adds two currencies. */
export function profitByCurrency(lines: readonly LedgerLine[]): { currency: string; revenueMinor: number; costMinor: number; netMinor: number }[] {
  const by = new Map<string, { currency: string; revenueMinor: number; costMinor: number; netMinor: number }>();
  for (const l of lines) {
    const head = String(l.account).charAt(0);
    if (head !== "4" && head !== "5" && head !== "6") continue;
    const code = l.currency.toUpperCase();
    const t = by.get(code) ?? { currency: code, revenueMinor: 0, costMinor: 0, netMinor: 0 };
    if (head === "4") t.revenueMinor += l.creditMinor - l.debitMinor;
    else t.costMinor += l.debitMinor - l.creditMinor;
    t.netMinor = t.revenueMinor - t.costMinor;
    by.set(code, t);
  }
  return [...by.values()].sort((a, b) => a.currency.localeCompare(b.currency));
}

/** Bills due within `days` or overdue, soonest first. */
export function billsDueWithin(rows: readonly PayableRow[], days: number, now = new Date()): PayableRow[] {
  const limit = now.getTime() + days * 86_400_000;
  return rows
    .filter((b) => b.daysOverdue > 0 || !b.dueAt || Date.parse(b.dueAt) <= limit)
    .sort((a, b) => (a.dueAt ? Date.parse(a.dueAt) : 0) - (b.dueAt ? Date.parse(b.dueAt) : 0));
}

/** Which tool a question asks for, by its words; undefined when none fits. */
export function toolFor(text: string): { tool: ToolName; args: Record<string, unknown> } | undefined {
  const t = text.toLowerCase();
  const range: GroupRange | undefined = /\btoday\b/.test(t) ? "today" : /\b(30|thirty)\b|\bmonth\b/.test(t) ? "30d" : /\b(7|seven)\b|\bweek\b/.test(t) ? "7d" : undefined;
  if (/\b(propose|proposal|plan|reorder|restock|draft an order|review the bills|ask the)\b/.test(t))
    return { tool: "raysto_propose", args: { kind: /\bbill|pay|accountant\b/.test(t) ? "bills" : "restock" } };
  if (/\b(stock|stock-?outs?|run(ning)? out|low|inventory|ingredients?)\b/.test(t)) return { tool: "raysto_stockouts", args: {} };
  if (/\b(bills?|payables?|due|overdue|owe|invoices? to pay|utilities)\b/.test(t))
    return { tool: "raysto_bills_due", args: { withinDays: /\b(30|month)\b/.test(t) ? 30 : 7 } };
  if (/\b(p&l|pnl|profit|loss|revenue|costs?|margin|earn|made|net)\b/.test(t))
    return { tool: "raysto_pnl", args: range ? { range } : {} };
  return undefined;
}

const fail = (ctx: AgAiToolContext, e: unknown) => ctx.error(e instanceof Error ? e.message : String(e));

/** The four tools, bound to the open Studio and to the group being read. */
export function defineRaystoTools(studio: AgStudioApi, scope: () => ToolScope): AgAiTool[] {
  const pnl = studio.defineAiTool({
    name: "raysto_pnl",
    description: "Revenue, costs and profit per currency for the group's venues, from their double-entry journals.",
    params: (s) =>
      s.object({
        range: s.enum(["today", "7d", "30d"] as const).optional(),
        venue: s.string().optional(),
      }),
    execute: async (args: { range?: GroupRange; venue?: string }, ctx) => {
      const g = scope();
      if (!g.money) return ctx.error("Only the group's owner and its accountants read the books.");
      const range = args.range ?? g.range;
      try {
        const r = await g.api.query<{ rows: LedgerLine[]; truncated: boolean }>("group.ledger", { groupId: g.groupId, range }, ctx.signal);
        const lines = args.venue ? r.rows.filter((l) => l.venue.toLowerCase().includes(String(args.venue).toLowerCase())) : r.rows;
        const totals = profitByCurrency(lines);
        if (totals.length === 0) return ctx.success(`No revenue or costs are booked for ${rangeWords[range]}.`, { totals });
        const text = totals
          .map(
            (t) =>
              `${t.currency}: revenue ${currency(t.revenueMinor, t.currency)}, costs ${currency(t.costMinor, t.currency)}, profit ${currency(t.netMinor, t.currency)}`,
          )
          .join("; ");
        const estimated = lines.some((l) => l.source?.estimated);
        return ctx.success(
          `${args.venue ? `${args.venue}` : g.groupName}, ${rangeWords[range]}. ${text}.${estimated ? " Some PayPal fees are estimates until PayPal reports them." : ""}${r.truncated ? " Only the newest 2,000 lines were read." : ""}`,
          { totals, range },
        );
      } catch (e) {
        return fail(ctx, e);
      }
    },
  });
  const bills = studio.defineAiTool({
    name: "raysto_bills_due",
    description: "Unpaid bills across the group's venues that are overdue or due within the given number of days.",
    params: (s) => s.object({ withinDays: s.number().optional() }),
    execute: async (args: { withinDays?: number }, ctx) => {
      const g = scope();
      if (!g.money) return ctx.error("Only the group's owner and its accountants read the bills.");
      const days = Math.min(90, Math.max(1, Math.round(Number(args.withinDays ?? 7))));
      try {
        const r = await g.api.query<{ rows: PayableRow[] }>("group.payables", { groupId: g.groupId }, ctx.signal);
        const due = billsDueWithin(r.rows, days);
        if (due.length === 0) return ctx.success(`No unpaid bills are overdue or due within ${days} days.`, { bills: [] });
        const sums = new Map<string, number>();
        for (const b of due) sums.set(b.currency, (sums.get(b.currency) ?? 0) + b.amountMinor);
        const lines = due
          .slice(0, 8)
          .map(
            (b) =>
              `${b.vendor} (${b.venue}) ${currency(b.amountMinor, b.currency)}, ${b.daysOverdue > 0 ? `${b.daysOverdue} days overdue` : b.dueAt ? `due ${new Date(b.dueAt).toLocaleDateString()}` : "no due date"}`,
          );
        return ctx.success(
          `${due.length} bill${due.length === 1 ? "" : "s"} to pay: ${[...sums].map(([c, m]) => currency(m, c)).join(" and ")}. ${lines.join("; ")}${due.length > 8 ? "; and more in Money" : ""}. Paying one needs the owner's approval in the Accountant.`,
          { bills: due.slice(0, 20) },
        );
      } catch (e) {
        return fail(ctx, e);
      }
    },
  });
  const stockouts = studio.defineAiTool({
    name: "raysto_stockouts",
    description: "Stock items at or under their low mark, or that run out before a delivery could arrive, per venue.",
    params: (s) => s.object({ venue: s.string().optional() }),
    execute: async (args: { venue?: string }, ctx) => {
      const g = scope();
      const venues = args.venue ? g.venues.filter((v) => v.name.toLowerCase().includes(String(args.venue).toLowerCase())) : g.venues;
      const found: { venue: string; name: string; quantity: number; unit: string; daysCover: number | null }[] = [];
      const unread: string[] = [];
      for (const v of venues) {
        try {
          const r = await g.api.query<{
            rows: { name: string; quantity: number; unit: string; low: boolean; daysCover?: number | null; leadDays?: number; reorder?: boolean }[];
          }>("stock.forecast", { restaurantId: v.restaurantId }, ctx.signal);
          for (const x of r.rows)
            if (x.low || x.reorder || (x.daysCover != null && x.leadDays != null && x.daysCover <= x.leadDays))
              found.push({ venue: v.name, name: x.name, quantity: x.quantity, unit: x.unit, daysCover: x.daysCover ?? null });
        } catch {
          unread.push(v.name);
        }
      }
      const tail = unread.length ? ` ${unread.join(" and ")} could not be read with your role.` : "";
      if (found.length === 0) return ctx.success(`Nothing is running low.${tail}`, { items: [] });
      return ctx.success(
        `${found.length} item${found.length === 1 ? "" : "s"} to restock: ${found
          .slice(0, 10)
          .map((x) => `${x.name} at ${x.venue} (${x.quantity} ${x.unit}${x.daysCover != null ? `, about ${x.daysCover} days left` : ""})`)
          .join("; ")}.${tail}`,
        { items: found },
      );
    },
  });
  const propose = studio.defineAiTool({
    name: "raysto_propose",
    description:
      "Ask one venue's agent for a proposal: a restock plan from the supplies planner, or a bills review from the accountant. Creates an agent task only; nothing is paid or ordered until a person approves it.",
    params: (s) => s.object({ kind: s.enum(["restock", "bills"] as const), venue: s.string().optional() }),
    execute: async (args: { kind: "restock" | "bills"; venue?: string }, ctx) => {
      const g = scope();
      const venue =
        (args.venue && g.venues.find((v) => v.name.toLowerCase().includes(String(args.venue).toLowerCase()))) ||
        g.venues.find((v) => v.role === "owner" || v.role === "manager");
      if (!venue) return ctx.error("You manage none of this group's venues, so no agent can be asked for you.");
      const command = args.kind === "restock" ? "supplies.plan" : "accountant.run";
      try {
        await g.api.command(command, venue.restaurantId, {});
        return ctx.success(
          `Asked ${args.kind === "restock" ? "the supplies planner" : "the accountant"} at ${venue.name} for a proposal. It waits in Agents for a person to approve; nothing is paid or ordered before then.`,
          { venue: venue.name, kind: args.kind },
        );
      } catch (e) {
        return fail(ctx, e);
      }
    },
  });
  return [pnl, bills, stockouts, propose];
}

/** How each tool's step reads in the assistant panel. */
export const raystoToolDisplay: Record<ToolName, Omit<AgBaseAiToolDisplay, "detail">> = {
  raysto_pnl: {
    label: ({ status, result }) => ({
      text: status === "done" ? "Read the venues' journals" : "Reading the venues' journals",
      ...(result?.success ? { pill: "Profit and loss" } : {}),
    }),
  },
  raysto_bills_due: {
    label: ({ status, args }) => ({
      text: status === "done" ? "Checked the unpaid bills" : "Checking the unpaid bills",
      pill: `${Number(args.withinDays ?? 7)} days`,
    }),
  },
  raysto_stockouts: {
    label: ({ status }) => ({ text: status === "done" ? "Read the stock forecasts" : "Reading the stock forecasts" }),
  },
  raysto_propose: {
    label: ({ status, args }) => ({
      text: status === "done" ? "Asked an agent for a proposal" : "Asking an agent for a proposal",
      pill: args.kind === "bills" ? "Bills review" : "Restock plan",
    }),
  },
};

const help =
  "I answer from your group's figures with four tools: profit and loss, bills due, stock running low, and asking a venue's agent for a proposal. Try “Profit this month”, “Which bills are due?”, “What is running low?” or “Propose a restock”. I match your words to a tool; no language model runs in your browser.";

class ToolSession implements AgAiChatSession {
  messages: readonly AgAiChatMessage[] = [];
  status: AgAiRunStatus = "idle";
  artifacts = [];
  private listeners = new Set<AgAiChatSessionEventListener>();
  private abort?: AbortController;
  constructor(
    readonly threadId: string,
    private harness: RaystoToolHarness,
  ) {}
  addEventListener(_type: "changed", l: AgAiChatSessionEventListener) {
    this.listeners.add(l);
  }
  removeEventListener(_type: "changed", l: AgAiChatSessionEventListener) {
    this.listeners.delete(l);
  }
  private changed() {
    for (const l of this.listeners) l({ type: "changed" });
    this.harness.changed();
  }
  private add(m: AgAiChatMessage) {
    this.messages = [...this.messages, m];
    this.changed();
  }
  sendMessage(text: string) {
    if (this.status === "running" || !text.trim()) return;
    this.add({ id: crypto.randomUUID(), role: "user", parts: [{ type: "text", text }], createdAt: Date.now() });
    this.harness.touch(this.threadId, text);
    const pick = toolFor(text);
    const tool = pick && this.harness.tools().find((t) => t.name === pick.tool);
    if (!pick || !tool?.execute) {
      this.add({ id: crypto.randomUUID(), role: "assistant", parts: [{ type: "text", text: help }], createdAt: Date.now() });
      return;
    }
    const callId = crypto.randomUUID();
    const step = (status: "executing" | "complete" | "error", result?: AgAiToolResult): AgAiChatMessage => ({
      id: `tool:${callId}`,
      role: "assistant",
      createdAt: Date.now(),
      parts: [{ type: "tool_call", toolCall: { toolCallId: callId, name: tool.name, status, args: pick.args, result } }],
    });
    this.status = "running";
    this.add(step("executing"));
    this.abort = new AbortController();
    const ctx: AgAiToolContext = {
      signal: this.abort.signal,
      run: { threadId: this.threadId, runId: callId },
      success: (response, data) => ({ success: true, response, data }),
      error: (messages) => ({ success: false, issues: (Array.isArray(messages) ? messages : [messages]).map((message) => ({ message })) }),
    };
    void tool
      .execute({ toolCallId: callId, name: tool.name, args: pick.args }, ctx)
      .then((result) => {
        if (this.abort?.signal.aborted) return;
        this.messages = [
          ...this.messages.filter((m) => m.id !== `tool:${callId}`),
          step(result.success ? "complete" : "error", result),
          {
            id: crypto.randomUUID(),
            role: "assistant",
            createdAt: Date.now(),
            parts: result.success
              ? [{ type: "text", text: result.response }]
              : [{ type: "error", message: result.issues.map((i) => i.message).join(" ") }],
          },
        ];
        this.status = "idle";
        this.changed();
      })
      .catch((e: unknown) => {
        this.status = "error";
        this.add({ id: crypto.randomUUID(), role: "assistant", parts: [{ type: "error", message: String(e) }], createdAt: Date.now() });
      });
  }
  cancel() {
    this.abort?.abort();
    if (this.status === "running") {
      this.status = "idle";
      this.add({ id: crypto.randomUUID(), role: "assistant", parts: [{ type: "text", text: "Stopped." }], createdAt: Date.now() });
    }
  }
  close() {
    this.abort?.abort();
    this.listeners.clear();
  }
}

/** The Group Studio's assistant: Raysto's four tools, picked by the question's words. */
export class RaystoToolHarness implements AgAiHarness {
  readonly agents = [
    {
      id: "raysto-figures",
      name: "Raysto figures",
      description: "Answers from your group's books and stock with Raysto's tools. It never pays or orders.",
      available: true,
      userFacing: true,
    },
  ];
  readonly promptStarters = [
    { label: "Profit this month", prompt: "What profit did the group make in the last 30 days?" },
    { label: "Bills due", prompt: "Which bills are due this week?" },
    { label: "Running low", prompt: "What stock is running low?" },
    { label: "Propose a restock", prompt: "Propose a restock plan." },
  ];
  threads: readonly AgAiThreadSummary[] = [];
  private sessions = new Map<string, ToolSession>();
  private listeners = new Set<AgAiHarnessEventListener>();
  constructor(readonly tools: () => readonly AgAiTool[]) {}
  changed() {
    for (const l of this.listeners) l({ type: "changed" });
  }
  touch(threadId: string, text: string) {
    this.threads = this.threads.map((t) =>
      t.threadId === threadId ? { ...t, title: t.title || text.slice(0, 55), updatedAt: Date.now() } : t,
    );
  }
  addEventListener(_type: "changed", l: AgAiHarnessEventListener) {
    this.listeners.add(l);
  }
  removeEventListener(_type: "changed", l: AgAiHarnessEventListener) {
    this.listeners.delete(l);
  }
  getAgent(id: string) {
    return this.agents.find((a) => a.id === id);
  }
  getThread(id: string) {
    return this.threads.find((t) => t.threadId === id);
  }
  async openThread(id: string) {
    const s = this.sessions.get(id);
    if (!s) throw new Error("Conversation unavailable.");
    return s;
  }
  async createThread(options: AgAiNewThreadOptions) {
    if (!this.getAgent(options.agentId)) throw new Error("Assistant unavailable.");
    const id = crypto.randomUUID();
    const session = new ToolSession(id, this);
    this.sessions.set(id, session);
    this.threads = [...this.threads, { threadId: id, agentId: options.agentId, title: options.title ?? "", updatedAt: Date.now() }];
    this.changed();
    return session;
  }
  async deleteThread(id: string) {
    this.sessions.get(id)?.close();
    this.sessions.delete(id);
    this.threads = this.threads.filter((t) => t.threadId !== id);
    this.changed();
  }
  dispose() {
    for (const s of this.sessions.values()) s.close();
    this.listeners.clear();
  }
}

/** For the Group Studio: the harness, built from the Studio API once it exists. */
export function groupAssistant(scope: () => ToolScope) {
  let tools: AgAiTool[] = [];
  return {
    harness: (params: { api: AgStudioApi }) => {
      tools = defineRaystoTools(params.api, scope);
      return new RaystoToolHarness(() => tools);
    },
    display: raystoToolDisplay,
  };
}

/** Kept for the contract's name: the tool names this module defines. */
export const studioAiTools = toolNames;
