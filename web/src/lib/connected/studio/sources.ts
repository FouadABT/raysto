"use client";
/**
 * AG Studio data sources over Raysto queries. A source is a table of plain
 * rows, loaded through the console's own API (never from the browser to
 * PayPal), shaped once and handed to Studio, which does the grouping,
 * pivoting and charting. Field ids in widgets are `sourceId.field`.
 *
 * The contract (frozen 4 November, used by the Accountant, Supplies,
 * Dispatch and Group sections): `useStudioSource(id, load, deps)` returns
 * `{source, loading, error, reload}`; `source` is `{id, data}` once loaded.
 * Owner of further sources and paging: stream S4.
 */
import { useCallback, useEffect, useRef, useState } from "react";

export type StudioRow = Record<string, string | number | boolean | null>;

export interface StudioSource {
  id: string;
  data: StudioRow[];
}

/** Money for Studio: minor units become major units, so sums read as money. */
export const major = (minor: unknown) => Math.round(Number(minor ?? 0)) / 100;

/** A local day "2026-11-04" or month "2026-11" from an ISO instant, for grouping. */
export const dayOf = (iso: unknown) => (typeof iso === "string" ? iso.slice(0, 10) : "");
export const monthOf = (iso: unknown) => (typeof iso === "string" ? iso.slice(0, 7) : "");

/**
 * Loads one source and keeps the last good rows while it reloads, so a live
 * refresh never empties a dashboard. `deps` should hold the restaurant (or
 * group) id and the revision that triggers a reload.
 */
export function useStudioSource(
  id: string,
  load: () => Promise<StudioRow[]>,
  deps: readonly unknown[],
): { source?: StudioSource; loading: boolean; error?: string; reload: () => void } {
  const [source, setSource] = useState<StudioSource>();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>();
  const [tick, setTick] = useState(0);
  const loadRef = useRef(load);
  loadRef.current = load;
  useEffect(() => {
    let live = true;
    setLoading(true);
    loadRef
      .current()
      .then((data) => {
        if (!live) return;
        setSource({ id, data });
        setError(undefined);
      })
      .catch((e: unknown) => {
        if (live) setError(e instanceof Error ? e.message : String(e));
      })
      .finally(() => {
        if (live) setLoading(false);
      });
    return () => {
      live = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id, tick, ...deps]);
  const reload = useCallback(() => setTick((t) => t + 1), []);
  return { source, loading, error, reload };
}
