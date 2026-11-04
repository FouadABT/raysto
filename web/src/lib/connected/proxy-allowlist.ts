// Names the operations console may send through the same-origin proxy. The
// backend still authorizes every call; this keeps the proxy from relaying
// anything the console does not use (for example platform admin commands).
export const consoleQueries = new Set([
  "me",
  "operations.snapshot",
  "operations.threads",
  "orders",
  "order",
  "checkouts",
  "report",
  "kitchen",
  "payment.exceptions",
  "agent.inbox",
  "agent.activity",
  "agent.task",
  "room",
  "assistant.run",
  // The "Try Raysto" demos.
  "counter.menu",
  "media",
  "menu.drafts",
  "checkout",
  // The back office (docs/back-office-design.md §3).
  "backoffice.close",
  "backoffice.closes",
  "shifts",
  "payouts",
  "payout",
  "catering",
  "catering.request",
  "complaints",
  "disputes",
  "expenses",
  "customers",
  "analytics",
  // The owner's dashboard (docs/dashboard-contract.md).
  "dashboard",
]);

/** Back-office names from the design; the drift test accepts these until the backend ships them. */
export const backofficeCommands = new Set([
  "close.run",
  "close.sign",
  "payroll.run",
  "payout.send",
  "shift.save",
  "shift.clock",
  "catering.request",
  "invoice.send",
  "invoice.remind",
  "complaint.open",
  "dispute.sweep",
  "expense.record",
  "loyalty.run",
]);
export const backofficeQueries = new Set([
  "backoffice.close",
  "backoffice.closes",
  "shifts",
  "payouts",
  "payout",
  "catering",
  "catering.request",
  "complaints",
  "disputes",
  "expenses",
  "customers",
  "analytics",
]);

/** 0.16 names (docs/release-0.16-design.md); the drift test accepts them until the backend ships them. */
export const phase16Commands = new Set([
  "group.create",
  "group.attach",
  "group.detach",
  "group.member.invite",
  "group.template.save",
  "group.template.push",
  "stock.transfer",
  "bill.snap",
  "bill.save",
  "bill.approve",
  "bill.pay",
  "bill.markPaid",
  "bill.void",
  "request.create",
  "request.send",
  "request.remind",
  "request.cancel",
  "ledger.adjust",
  "accountant.run",
  "driver.save",
  "driver.availability",
  "delivery.offer",
  "delivery.respond",
  "delivery.proof",
  "delivery.assign",
  "delivery.transition",
  "dispatch.suggest",
  "partner.app.save",
  "partner.app.rotate",
  "supplier.order.save",
  "supplier.order.send",
  "supplier.order.receive",
  "recipe.save",
  "stock.count",
  "stock.waste",
  "stock.save",
  "supplier.save",
  "supply.receive",
  "supplies.plan",
  "expense.snap",
  "studio.layout.save",
  "media.upload",
]);
/** 0.16 queries, as above. */
export const phase16Queries = new Set([
  "group.list",
  "group.overview",
  "group.compare",
  "group.ledger",
  "group.payables",
  "group.templates",
  "ledger.journal",
  "ledger.pnl",
  "ledger.cashflow",
  "ledger.vat",
  "bills",
  "bill",
  "requests",
  "request",
  "drivers",
  "delivery.board",
  "deliveries",
  "delivery.tracking",
  "partner.apps",
  "partner.events",
  "supplier.orders",
  "supplier.order",
  "stock",
  "stock.forecast",
  "suppliers",
  "recipes",
  "supply.deliveries",
  "supplier.scorecards",
  "studio.layout",
  "team",
]);

export const consoleCommands = new Set([
  "room.open",
  "room.read",
  "room.message",
  "service.transition",
  "operations.layout",
  "operations.archiveThread",
  "assistant.start",
  "assistant.cancel",
  "assistant.approve",
  "order.transition",
  "kitchen.progress",
  "payment.refund",
  "payment.release",
  "identity.stepUp",
  "agent.decide",
  // The "Try Raysto" demos: read a menu photo, draw a dish, ask the payments
  // agent, order by sentence and pay in PayPal Sandbox, start fresh.
  "menu.snap",
  "menu.photo",
  "payment.check",
  "quote.create",
  "order.submit",
  "payment.allocate",
  "payment.checkout",
  "judge.reset",
  // The back office: the close, pay and tips, catering invoices, complaints
  // and disputes, expenses, loyalty and shifts.
  "close.run",
  "close.sign",
  "payroll.run",
  "payout.send",
  "shift.save",
  "shift.clock",
  "catering.request",
  "invoice.send",
  "invoice.remind",
  "complaint.open",
  "dispute.sweep",
  "expense.record",
  "loyalty.run",
  // Owner limits, the close time and the daily sales target.
  "autonomy.set",
]);

for (const name of phase16Commands) consoleCommands.add(name);
for (const name of phase16Queries) consoleQueries.add(name);

export function allowedPath(path: string): boolean {
  if (path === "auth/firebase" || path === "events") return true;
  if (path === "voice/counter") return true;
  if (/^rooms\/[1-9][0-9]*\/events$/.test(path)) return true;
  if (/^media\/[1-9][0-9]*$/.test(path)) return true;
  const [kind, name, ...rest] = path.split("/");
  if (rest.length > 0 || !name) return false;
  if (kind === "queries") return consoleQueries.has(name);
  if (kind === "commands") return consoleCommands.has(name);
  return false;
}
