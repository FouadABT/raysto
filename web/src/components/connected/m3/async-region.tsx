"use client";
import { useEffect, useState, type ReactNode } from "react";

export type AsyncState = "initial" | "ready" | "refreshing" | "empty" | "unavailable" | "stale";
export function asyncState(loading: boolean, data: unknown, error?: unknown, empty = false): AsyncState {
  if (data == null) return error ? "unavailable" : "initial";
  if (loading) return "refreshing";
  if (error) return "stale";
  return empty ? "empty" : "ready";
}

/** Text acknowledges work immediately; decorative activity waits 150ms. */
export function Pending({ label, ariaLabel, kind = "panel", children }: {
  label: string; ariaLabel?: string; kind?: "inline" | "panel" | "studio" | "receipt"; children?: ReactNode;
}) {
  const [slow, setSlow] = useState(false);
  useEffect(() => { const timer = setTimeout(() => setSlow(true), 8000); return () => clearTimeout(timer); }, []);
  return <div className={`ops-pending ops-pending-${kind}`} role="status" aria-label={ariaLabel} aria-live="polite">
    <div className="ops-pending-label"><span className="ops-activity" aria-hidden="true" />{label}</div>
    {children ?? (kind !== "inline" && <div className="ops-placeholder-lines" aria-hidden="true"><i /><i /><i /></div>)}
    {slow && <p className="ops-slow-read">This is taking longer than usual. You can keep using the other sections while this finishes.</p>}
  </div>;
}

export function RefreshStatus({ loading, error, label = "Updating this view. Previous records remain visible.", retry }: {
  loading: boolean; error?: string; label?: string; retry?: () => void;
}) {
  if (error) return <div className="ops-refresh-status ops-refresh-failed" role="status">Could not refresh. Previously loaded records may be stale.
    {retry && <button className="jr-text-button" onClick={retry}>Retry</button>}</div>;
  return loading ? <Pending kind="inline" label={label} /> : null;
}
