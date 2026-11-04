/**
 * Saved Studio layouts, as plain data: whether a saved state can be opened,
 * and how it sits over today's starting layout. Pure, so it is unit-tested.
 */
import type { AgDefaultRegistry, AgReportState } from "ag-studio";

type StudioState = AgReportState<AgDefaultRegistry>;

/** A saved state Studio can open: pages with ids and a selected page. */
export function isStudioState(v: unknown): v is StudioState {
  if (!v || typeof v !== "object") return false;
  const s = v as { pages?: unknown; selectedPageId?: unknown };
  return (
    Array.isArray(s.pages) &&
    s.pages.length > 0 &&
    s.pages.every((p) => p && typeof p === "object" && typeof (p as { id?: unknown }).id === "string") &&
    typeof s.selectedPageId === "string"
  );
}

/**
 * A saved layout over today's starting one: the saved pages first, then any
 * page added since it was saved, on the page asked for.
 */
export function mergeLayout(saved: StudioState | null, initial: StudioState, page?: string): StudioState {
  const base = saved ?? initial;
  const ids = new Set(base.pages.map((p) => p.id));
  const pages = [...base.pages, ...initial.pages.filter((p) => !ids.has(p.id))];
  const selected = page && pages.some((p) => p.id === page) ? page : base.selectedPageId;
  return { ...base, pages, selectedPageId: selected };
}
