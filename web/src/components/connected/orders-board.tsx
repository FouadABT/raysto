"use client";
import { m, type PanInfo } from "motion/react";
import { useCallback, useEffect, useReducer, useRef, useState } from "react";
import { currency, type Json } from "@/lib/connected/contracts";
import { channelOf, customerOf, isPaid, type OrderRow } from "@/lib/connected/business";
import { GRACE_MS } from "@/lib/connected/motion";
import {
  allowedNext,
  codeOptional,
  dropReason,
  stageLabel,
  stageOf,
  stages,
  type BoardRole,
  type Stage,
} from "@/lib/connected/order-rules";
import { PendingMoves, advanceOrder, openLines, sendMove, type OrderApi, type PendingMove } from "@/lib/connected/pending-moves";
import { ContainerCard, ContainerDialog, useSnackbar, type SnackbarOptions } from "./m3";
import { OrderPanel, words } from "./business-sections";
import { Icon } from "./icons";

/** An order as the `orders` query lists it, with the code and lines the board shows. */
export type BoardOrder = OrderRow & { pickupCode?: string | null; lines?: Json[] };

type Snackbars = { show: (o: SnackbarOptions) => number; dismiss: (id?: number) => void };

/** The console normally has a SnackbarProvider; without one, messages fall back to the board's own status line. */
function useOptionalSnackbar(): Snackbars | null {
  try {
    return useSnackbar();
  } catch {
    return null;
  }
}

/** Dragging is for a mouse or pen; on touch the board scrolls and each card's button moves it. */
function useFinePointer() {
  const [fine, setFine] = useState(false);
  useEffect(() => {
    const q = window.matchMedia("(pointer: fine)");
    const set = () => setFine(q.matches);
    set();
    q.addEventListener("change", set);
    return () => q.removeEventListener("change", set);
  }, []);
  return fine;
}

const ticket = (o: Pick<BoardOrder, "number" | "id">) => (o.number ? `#${o.number}` : `Order ${o.id}`);

const minutesAgo = (iso: string, now: number) => {
  const min = Math.max(0, Math.round((now - new Date(iso).getTime()) / 60000));
  return min < 1 ? "just now" : min < 60 ? `${min} min ago` : `${Math.floor(min / 60)} h ${min % 60} min ago`;
};

const isToday = (iso: string) => new Date(iso).toDateString() === new Date().toDateString();

/**
 * The orders as a board: one column per stage, oldest first. A card moves one
 * column at a time, by drag or by its "Move to" button; the move waits five
 * seconds for Undo before it is sent. An online pickup is handed over against
 * the code on the customer's phone, asked for in a dialog and sent at once.
 */
export function OrdersBoard({
  api,
  tenant,
  rows,
  revision,
  role = "manager",
  reload,
}: {
  api: OrderApi;
  tenant: number;
  rows: BoardOrder[];
  revision: string;
  role?: BoardRole;
  reload: () => void;
}) {
  const snackbar = useOptionalSnackbar();
  const [note, setNote] = useState("");
  const [, rerender] = useReducer((n: number) => n + 1, 0);
  const fine = useFinePointer();
  const latest = useRef({ api, tenant, reload, snackbar });
  latest.current = { api, tenant, reload, snackbar };
  const toasts = useRef(new Map<number, number>());
  const ticketOf = useRef(new Map<number, string>());

  const say = useCallback((options: SnackbarOptions) => {
    const s = latest.current.snackbar;
    if (s) return s.show(options);
    setNote(options.message);
    return -1;
  }, []);

  const [moves] = useState(
    () =>
      new PendingMoves({
        send: (move) => sendMove(latest.current.api, latest.current.tenant, move),
        onSent: (move) => {
          const id = toasts.current.get(move.orderId);
          toasts.current.delete(move.orderId);
          if (id !== undefined && id >= 0) latest.current.snackbar?.dismiss(id);
          latest.current.reload();
        },
        onFailed: (move, error) => {
          toasts.current.delete(move.orderId);
          say({ message: `${ticketOf.current.get(move.orderId) ?? `Order ${move.orderId}`} did not move: ${error instanceof Error ? error.message : String(error)}` });
          latest.current.reload();
        },
        onChange: () => rerender(),
      }),
  );

  // A pending move goes out when the section closes or the page is hidden;
  // leaving the page while one waits asks first.
  useEffect(() => {
    const hidden = () => {
      if (document.visibilityState === "hidden") void moves.flush();
    };
    const leaving = (e: BeforeUnloadEvent) => {
      if (!moves.size) return;
      void moves.flush();
      e.preventDefault();
      e.returnValue = "";
    };
    document.addEventListener("visibilitychange", hidden);
    window.addEventListener("beforeunload", leaving);
    return () => {
      document.removeEventListener("visibilitychange", hidden);
      window.removeEventListener("beforeunload", leaving);
      void moves.flush();
    };
  }, [moves]);

  const now = Date.now();
  const shown = moves.overlay(rows);
  for (const o of shown) ticketOf.current.set(o.id, ticket(o));
  const byStage = new Map<Stage, BoardOrder[]>(stages.map((s) => [s.id, []]));
  for (const o of shown) {
    const s = stageOf(o.status);
    if (s === "done" && !isToday(o.createdAt)) continue;
    byStage.get(s)!.push(o);
  }
  for (const list of byStage.values()) list.sort((a, b) => a.createdAt.localeCompare(b.createdAt));

  const [showDone, setShowDone] = useState(false);
  const [dragging, setDragging] = useState<BoardOrder>();
  const [over, setOver] = useState<Stage>();
  const columns = useRef(new Map<Stage, HTMLElement>());
  const [openId, setOpenId] = useState<number>();
  const [shownId, setShownId] = useState<number>();
  const [codeFor, setCodeFor] = useState<BoardOrder>();

  const stageAt = (x: number, y: number): Stage | undefined => {
    for (const [stage, el] of columns.current) {
      const r = el.getBoundingClientRect();
      if (x >= r.left && x <= r.right && y >= r.top && y <= r.bottom) return stage;
    }
    return undefined;
  };
  const point = (event: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) =>
    "clientX" in event ? { x: event.clientX, y: event.clientY } : { x: info.point.x - window.scrollX, y: info.point.y - window.scrollY };

  async function move(order: BoardOrder) {
    const next = allowedNext(order, role);
    if (!next.to || !next.stage) return;
    if (next.needsCode) {
      setCodeFor(order);
      return;
    }
    let ticks = 0;
    if (next.autoTicks) ticks = await openLines(api, tenant, order.id).then((l) => l.length, () => 0);
    if (moves.has(order.id)) {
      const old = toasts.current.get(order.id);
      if (old !== undefined && old >= 0) snackbar?.dismiss(old);
    }
    moves.schedule(order, next.to);
    const label = stageLabel(next.stage);
    const id = say({
      message: `${ticket(order)} moved to ${label}${ticks ? ` · ${ticks} open ${ticks === 1 ? "line" : "lines"} will be ticked` : ""}`,
      action: {
        label: "Undo",
        onPress: () => {
          if (moves.undo(order.id)) say({ message: `${ticket(order)} stays in ${stageLabel(stageOf(order.status))}`, durationMs: 3000 });
        },
      },
      durationMs: GRACE_MS,
      // Closing the message by hand, or another one taking its place, ends
      // the chance to undo: the move goes now.
      onDismiss: (reason) => {
        if (reason === "dismiss" || reason === "replaced") void moves.flushOne(order.id);
      },
    });
    toasts.current.set(order.id, id);
  }

  async function handOver(order: BoardOrder, code: string | undefined) {
    setCodeFor(undefined);
    try {
      await advanceOrder(api, tenant, order, "collected", code);
      say({ message: `${ticket(order)} handed over` });
      reload();
    } catch (e) {
      say({ message: `${ticket(order)} was not handed over: ${e instanceof Error ? e.message : String(e)}` });
    }
  }

  const open = (id: number) => {
    setShownId(id);
    setOpenId(id);
  };
  const detail = shown.find((o) => o.id === shownId) ?? rows.find((o) => o.id === shownId);

  return (
    <div className={`m3-board-wrap${dragging ? " is-dragging" : ""}`}>
      <div className="m3-board" aria-label="Orders by stage">
        {stages.map((s) => {
          const list = byStage.get(s.id) ?? [];
          const why = dragging ? dropReason(dragging, role, s.id) : null;
          const state = !dragging
            ? undefined
            : why === null
              ? over === s.id
                ? "over"
                : "allowed"
              : stageOf(dragging.status) === s.id
                ? "source"
                : "blocked";
          const collapsed = s.id === "done" && !showDone;
          return (
            <section
              key={s.id}
              className="m3-board-col"
              data-stage={s.id}
              data-drop={state}
              aria-labelledby={`board-${s.id}`}
              ref={(el) => {
                if (el) columns.current.set(s.id, el);
                else columns.current.delete(s.id);
              }}
            >
              <header className="m3-board-head">
                <span className="m3-board-dot" aria-hidden="true" />
                <h3 id={`board-${s.id}`}>{s.label}</h3>
                <span className="m3-board-count" aria-label={`${list.length} ${list.length === 1 ? "order" : "orders"}`}>
                  {list.length}
                </span>
              </header>
              {/* One label while dragging: "Drop here" on the column that takes the card, or, when
                  no column can, the reason in the card's own column. Other columns only dim. */}
              {(state === "allowed" || state === "over") && <p className="m3-board-why">Drop here</p>}
              {state === "source" && dragging && !allowedNext(dragging, role).stage && (
                <p className="m3-board-why">{allowedNext(dragging, role).reason ?? "No move from here"}</p>
              )}
              {collapsed ? (
                <button type="button" className="m3-board-more" onClick={() => setShowDone(true)} disabled={!list.length}>
                  {list.length ? `Show ${list.length} done today` : "Nothing done yet today"}
                </button>
              ) : list.length === 0 ? (
                <p className="m3-board-empty">{s.id === "awaiting" ? "No order is waiting for PayPal." : "No orders here."}</p>
              ) : (
                <ul className="m3-board-list">
                  {list.map((o) => {
                    const next = allowedNext(o, role);
                    const pending = moves.has(o.id);
                    return (
                      <li key={o.id} className="m3-board-item">
                        <m.div
                          className={`m3-board-drag${dragging?.id === o.id ? " dragging" : ""}`}
                          drag={fine && !!next.to && !pending}
                          dragSnapToOrigin
                          dragMomentum={false}
                          dragElastic={1}
                          whileDrag={{ scale: 1.02, zIndex: 5 }}
                          onDragStart={() => setDragging(o)}
                          onDrag={(e, info) => {
                            const p = point(e, info);
                            const at = stageAt(p.x, p.y);
                            if (at !== over) setOver(at);
                          }}
                          onDragEnd={(e, info) => {
                            const p = point(e, info);
                            const at = stageAt(p.x, p.y);
                            setDragging(undefined);
                            setOver(undefined);
                            if (at && dropReason(o, role, at) === null) void move(o);
                          }}
                        >
                          <ContainerCard layoutId={`order-${o.id}`} as="article" className="m3-board-card">
                            <div className="m3-board-card-top">
                              <strong className="m3-board-ticket">{ticket(o)}</strong>
                              <span className="m3-board-stage">{words(o.status)}</span>
                            </div>
                            <p className="m3-board-meta">
                              {channelOf(o)} · {customerOf(o)}
                            </p>
                            {Array.isArray(o.lines) && o.lines.length > 0 && (
                              <p className="m3-board-lines">
                                {(o.lines as Json[]).map((l) => `${String(l.quantity)}× ${String(l.name)}`).join(", ")}
                              </p>
                            )}
                            <p className="m3-board-foot">
                              <span>{currency(o.totalMinor, o.currency)}</span>
                              {!isPaid(o.paymentStatus) && <span className="m3-board-unpaid">{words(o.paymentStatus)}</span>}
                              <span className="m3-board-age">{minutesAgo(o.createdAt, now)}</span>
                            </p>
                            {pending && (
                              <p className="m3-board-pending" role="status">
                                Moving to {stageLabel(stageOf(o.status))}; Undo is in the message below
                              </p>
                            )}
                            <div className="m3-board-actions">
                              <button type="button" className="m3-board-open" onClick={() => open(o.id)} aria-label={`Open order ${ticket(o)}`}>
                                Open
                              </button>
                              {next.to && next.stage ? (
                                <button
                                  type="button"
                                  className="m3-board-move"
                                  disabled={pending}
                                  onClick={() => void move(o)}
                                  aria-label={`Move ${ticket(o)} to ${stageLabel(next.stage)}`}
                                >
                                  {next.verb}
                                  <Icon name="arrow" size={16} />
                                </button>
                              ) : (
                                s.id !== "done" && <small className="m3-board-reason">{next.reason}</small>
                              )}
                            </div>
                          </ContainerCard>
                        </m.div>
                      </li>
                    );
                  })}
                </ul>
              )}
            </section>
          );
        })}
      </div>
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
      <ContainerDialog
        layoutId={`order-${shownId ?? 0}`}
        open={openId !== undefined}
        onClose={() => setOpenId(undefined)}
        title={detail ? `Order ${ticket(detail)}` : "Order"}
        className="m3-board-dialog"
      >
        {shownId !== undefined && (
          <OrderPanel
            api={api}
            tenant={tenant}
            id={shownId}
            revision={revision}
            onChanged={() => {
              setOpenId(undefined);
              reload();
            }}
          />
        )}
      </ContainerDialog>
      <PickupCodeDialog
        open={codeFor !== undefined}
        ticket={codeFor ? ticket(codeFor) : ""}
        optional={codeOptional(role)}
        onCancel={() => setCodeFor(undefined)}
        onConfirm={(code) => codeFor && void handOver(codeFor, code)}
      />
    </div>
  );
}

/**
 * The code on the customer's phone, asked for in a Material dialog instead of
 * the browser's prompt. Managers may hand over without it.
 */
export function PickupCodeDialog({
  open,
  ticket,
  optional,
  onCancel,
  onConfirm,
}: {
  open: boolean;
  ticket: string;
  optional: boolean;
  onCancel: () => void;
  onConfirm: (code: string | undefined) => void;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const opener = useRef<HTMLElement | null>(null);
  const [code, setCode] = useState("");
  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (open && !d.open) {
      opener.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
      setCode("");
      d.showModal();
    } else if (!open && d.open) {
      d.close();
      opener.current?.focus();
    }
  }, [open]);
  const valid = /^\d{4}$/.test(code) || (optional && code === "");
  return (
    <dialog
      ref={ref}
      className="m3-dialog m3-code-dialog"
      aria-labelledby="m3-code-title"
      onCancel={(e) => {
        e.preventDefault();
        onCancel();
      }}
    >
      <form
        className="m3-dialog-surface"
        method="dialog"
        onSubmit={(e) => {
          e.preventDefault();
          if (valid) onConfirm(code || undefined);
        }}
      >
        <h2 id="m3-code-title">Hand over {ticket}</h2>
        <label className="m3-code-field">
          Pickup code on the customer&rsquo;s phone
          <input
            inputMode="numeric"
            autoComplete="off"
            pattern="\d{4}"
            maxLength={4}
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, "").slice(0, 4))}
            aria-describedby="m3-code-help"
            required={!optional}
          />
        </label>
        <p id="m3-code-help" className="m3-code-help">
          {optional ? "Four digits. As a manager you may leave it empty and hand over without it." : "Four digits, shown on the customer's order."}
        </p>
        <div className="m3-code-actions">
          <button type="button" onClick={onCancel}>
            Cancel
          </button>
          <button type="submit" className="ops-primary" disabled={!valid}>
            Hand over
          </button>
        </div>
      </form>
    </dialog>
  );
}

export type { PendingMove };
