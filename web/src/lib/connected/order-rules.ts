/**
 * Which way an order may move on the console's board, mirroring the server's
 * table in ordering.dart (`OrderingModule.transition`, `kitchen`, the delivery
 * flow and `paymentCleared`). The server stays the judge: these rules only
 * keep the board from offering a move it would refuse.
 */

export type BoardRole = "owner" | "manager" | "waiter" | "kitchen";

/** The board's columns, left to right. */
export type Stage = "awaiting" | "new" | "accepted" | "preparing" | "ready" | "handedOver" | "done";

export const stages: { id: Stage; label: string; drops: boolean }[] = [
  { id: "awaiting", label: "Awaiting payment", drops: false },
  { id: "new", label: "New", drops: true },
  { id: "accepted", label: "Accepted", drops: true },
  { id: "preparing", label: "Preparing", drops: true },
  { id: "ready", label: "Ready", drops: true },
  { id: "handedOver", label: "Handed over", drops: true },
  { id: "done", label: "Done today", drops: true },
];

export const stageLabel = (s: Stage) => stages.find((x) => x.id === s)!.label;

export interface RuleOrder {
  status: string;
  fulfillment: string;
  origin: string;
  paymentStatus: string;
  pickupCode?: string | null;
}

/** The column an order sits in; cancelled, rejected and expired orders close in Done. */
export function stageOf(status: string): Stage {
  switch (status) {
    case "awaitingPayment":
      return "awaiting";
    case "submitted":
      return "new";
    case "accepted":
      return "accepted";
    case "preparing":
      return "preparing";
    case "ready":
      return "ready";
    case "served":
    case "collected":
    case "outForDelivery":
    case "delivered":
      return "handedOver";
    default:
      return "done";
  }
}

export interface Allowed {
  /** The status the server would accept next, or null. */
  to: string | null;
  /** The column that status sits in. */
  stage: Stage | null;
  /** An online pickup is handed over against the code on the customer's phone. */
  needsCode: boolean;
  /** Ready ticks the kitchen lines left open first, as the order panel does. */
  autoTicks: boolean;
  /** Why there is no move, in words a manager reads on the board. */
  reason: string | null;
  /** The button's words, e.g. "Mark ready". */
  verb: string | null;
}

const none = (reason: string): Allowed => ({ to: null, stage: null, needsCode: false, autoTicks: false, reason, verb: null });
const move = (to: string, verb: string, extra: Partial<Allowed> = {}): Allowed => ({
  to,
  stage: stageOf(to),
  needsCode: false,
  autoTicks: false,
  reason: null,
  verb,
  ...extra,
});

const managers = new Set<BoardRole>(["owner", "manager"]);
const operators = new Set<BoardRole>(["owner", "manager", "waiter"]);
const kitchenRoles = new Set<BoardRole>(["owner", "manager", "kitchen"]);

/**
 * The one next step for `order` by someone with `role`, as the server allows
 * it. Rejecting is never a board move: it needs a reason and stays a button
 * in the order panel.
 */
export function allowedNext(order: RuleOrder, role: BoardRole): Allowed {
  switch (order.status) {
    case "awaitingPayment":
      return none("Waits for PayPal: it joins New once paid");
    case "submitted":
      // A kitchen member may accept only when trusted to (a capability the
      // board does not see), so the board leaves accepting to operators.
      if (!operators.has(role)) return none("Accepted at the counter or by a manager");
      if (order.paymentStatus === "refunded") return none("Refunded: not taken into the kitchen");
      return move("accepted", "Accept");
    case "accepted":
      if (!kitchenRoles.has(role)) return none("The kitchen starts it");
      return move("preparing", "Start cooking");
    case "preparing":
      if (!kitchenRoles.has(role)) return none("The kitchen marks it ready");
      return move("ready", "Mark ready", { autoTicks: true });
    case "ready":
      if (order.fulfillment === "delivery") return none("Leaves through the delivery flow");
      if (!operators.has(role)) return none("Handed over at the counter");
      if (order.fulfillment === "dineIn") return move("served", "Served");
      if (order.fulfillment === "pickup")
        return move("collected", "Hand over", {
          needsCode: order.origin !== "counter" && !!order.pickupCode,
        });
      return none("No hand-over for this order");
    case "outForDelivery":
      return none("Out for delivery");
    case "served":
    case "collected":
    case "delivered":
      if (!operators.has(role)) return none("Completed at the counter");
      return move("completed", "Complete");
    default:
      return none("Closed");
  }
}

/** Managers may hand over a pickup without the code; anyone else needs it. */
export const codeOptional = (role: BoardRole) => managers.has(role);

/**
 * Why `order` cannot be dropped on `stage`, or null when it can. Only the
 * next column accepts a drop.
 */
export function dropReason(order: RuleOrder, role: BoardRole, stage: Stage): string | null {
  const next = allowedNext(order, role);
  if (next.stage === stage) return null;
  if (stageOf(order.status) === stage) return "Already here";
  if (!next.stage) return next.reason ?? "No move from here";
  return `Next step: ${stageLabel(next.stage)}`;
}
