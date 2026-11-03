/**
 * Status moves from the board wait a few seconds for Undo before they are
 * sent, so nothing ever reaches a state that would need reversing: the
 * server's order transitions only go forward. The card shows its new column
 * at once; the command, with the version the board saw, goes when the grace
 * period ends, when the section closes, or when the page is hidden.
 */
import type { Json } from "./contracts";
import { GRACE_MS } from "./motion";

/** The part of ConnectedApi the board needs; tests pass a fake. */
export interface OrderApi {
  query<T>(name: string, params?: Json): Promise<T>;
  command<T>(name: string, restaurantId: number, data?: Json, options?: { id?: number; version?: number; key?: string }): Promise<T>;
}

export interface MoveOrder {
  id: number;
  version: number;
  status: string;
}

export interface PendingMove {
  orderId: number;
  /** The status and version the board saw when the first move was made. */
  from: string;
  expectedVersion: number;
  /** Each forward step, in order; a second move of the same card adds one. */
  steps: string[];
}

export interface PendingMovesOptions {
  send: (move: PendingMove) => Promise<void>;
  onSent?: (move: PendingMove) => void;
  onFailed?: (move: PendingMove, error: unknown) => void;
  onChange?: () => void;
  graceMs?: number;
  setTimer?: (fn: () => void, ms: number) => unknown;
  clearTimer?: (handle: unknown) => void;
}

export class PendingMoves {
  private moves = new Map<number, { move: PendingMove; timer: unknown }>();
  private sending = new Map<number, PendingMove>();
  private readonly grace: number;
  private readonly setTimer: (fn: () => void, ms: number) => unknown;
  private readonly clearTimer: (handle: unknown) => void;

  constructor(private readonly options: PendingMovesOptions) {
    this.grace = options.graceMs ?? GRACE_MS;
    this.setTimer = options.setTimer ?? ((fn, ms) => setTimeout(fn, ms));
    this.clearTimer = options.clearTimer ?? ((h) => clearTimeout(h as ReturnType<typeof setTimeout>));
  }

  /**
   * Moves `order` to `to` after the grace period. A second move of the same
   * card before then joins the first: one send, both steps, the first
   * version, and the grace period starts again.
   */
  schedule(order: MoveOrder, to: string): PendingMove {
    const held = this.moves.get(order.id);
    if (held) this.clearTimer(held.timer);
    const move: PendingMove = held
      ? { ...held.move, steps: held.move.steps.at(-1) === to ? held.move.steps : [...held.move.steps, to] }
      : { orderId: order.id, from: order.status, expectedVersion: order.version, steps: [to] };
    const timer = this.setTimer(() => void this.flushOne(order.id), this.grace);
    this.moves.set(order.id, { move, timer });
    this.options.onChange?.();
    return move;
  }

  /** Cancels a move that has not been sent; returns it, or null when it already went. */
  undo(orderId: number): PendingMove | null {
    const held = this.moves.get(orderId);
    if (!held) return null;
    this.clearTimer(held.timer);
    this.moves.delete(orderId);
    this.options.onChange?.();
    return held.move;
  }

  has(orderId: number) {
    return this.moves.has(orderId) || this.sending.has(orderId);
  }

  get size() {
    return this.moves.size + this.sending.size;
  }

  pending(): PendingMove[] {
    return [...this.moves.values()].map((h) => h.move);
  }

  /** Sends one move now (Undo is no longer offered). */
  async flushOne(orderId: number): Promise<void> {
    const held = this.moves.get(orderId);
    if (!held) return;
    this.clearTimer(held.timer);
    this.moves.delete(orderId);
    // While it is on its way the card keeps its new column.
    this.sending.set(orderId, held.move);
    this.options.onChange?.();
    try {
      await this.options.send(held.move);
      this.options.onSent?.(held.move);
    } catch (e) {
      this.options.onFailed?.(held.move, e);
    } finally {
      this.sending.delete(orderId);
      this.options.onChange?.();
    }
  }

  /** Sends every waiting move now: the section closes or the page is hidden. */
  async flush(): Promise<void> {
    await Promise.all([...this.moves.keys()].map((id) => this.flushOne(id)));
  }

  /**
   * Fresh rows with the waiting moves applied, so a live refresh never snaps
   * a card back. A row the server already changed (another version) is left
   * as the server says: the move will meet its version check and say so.
   */
  overlay<T extends MoveOrder>(rows: T[]): T[] {
    if (this.size === 0) return rows;
    return rows.map((r) => {
      const move = this.moves.get(r.id)?.move ?? this.sending.get(r.id);
      if (!move || r.version !== move.expectedVersion) return r;
      return { ...r, status: move.steps.at(-1)! };
    });
  }
}

/**
 * One forward step of an order, as the order panel has always taken it:
 * before "ready" it ticks the kitchen lines left open, then it sends the
 * transition with the version it holds. Returns the order's new version.
 */
export async function advanceOrder(
  api: OrderApi,
  tenant: number,
  order: { id: number; version: number },
  step: string,
  code?: string,
): Promise<number> {
  if (step === "ready") {
    for (const t of await openLines(api, tenant, order.id)) {
      await api.command("kitchen.progress", tenant, { lineKey: t.lineKey, completedQuantity: t.quantity }, { id: order.id, version: Number(t.version) });
    }
  }
  const result = await api.command<Json>(
    "order.transition",
    tenant,
    { status: step, ...(code ? { code } : {}) },
    { id: order.id, version: order.version },
  );
  return Number(result?.version ?? order.version + 1);
}

/** The kitchen lines of an order not yet done. */
export async function openLines(api: OrderApi, tenant: number, orderId: number): Promise<Json[]> {
  const kitchen = await api.query<{ rows: Json[] }>("kitchen", { restaurantId: tenant, limit: 100 });
  const tickets = ((kitchen.rows ?? []).find((r) => Number(r.id) === orderId)?.tickets ?? []) as Json[];
  return tickets.filter((t) => Number(t.completedQuantity) < Number(t.quantity));
}

/** Every step of a waiting move, each with the version the last one returned. */
export async function sendMove(api: OrderApi, tenant: number, move: PendingMove): Promise<void> {
  let version = move.expectedVersion;
  for (const step of move.steps) version = await advanceOrder(api, tenant, { id: move.orderId, version }, step);
}
