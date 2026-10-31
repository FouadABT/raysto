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
  "room",
  "assistant.run",
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
]);

export function allowedPath(path: string): boolean {
  if (path === "auth/firebase" || path === "events") return true;
  if (/^rooms\/[1-9][0-9]*\/events$/.test(path)) return true;
  const [kind, name, ...rest] = path.split("/");
  if (rest.length > 0 || !name) return false;
  if (kind === "queries") return consoleQueries.has(name);
  if (kind === "commands") return consoleCommands.has(name);
  return false;
}
