"use client";
import { useSyncExternalStore } from "react";

// Only opaque in-memory tokens; no identity or business records are retained.
const pending = new Set<object>(),
  listeners = new Set<() => void>();
export function setReadPending(token: object, active: boolean) {
  const before = pending.size > 0;
  if (active) pending.add(token);
  else pending.delete(token);
  if (before !== pending.size > 0) for (const listener of listeners) listener();
}
const subscribe = (listener: () => void) => {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
};
export function ReadProgress() {
  const active = useSyncExternalStore(
    subscribe,
    () => pending.size > 0,
    () => false,
  );
  return (
    <div className="ops-read-progress" role="status" aria-live="polite">
      {active ? "Updating records. Previously loaded rows may be stale." : ""}
    </div>
  );
}
