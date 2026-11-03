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
]);

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
