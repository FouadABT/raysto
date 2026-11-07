import type { AgStudioApi } from "ag-studio";

/**
 * Studio preserves the live page during undo. If undo removes that page,
 * select a page that survives before restoring the history entry.
 * Only the installed presentation API is called; no business state changes.
 */
export function stepLayoutHistory(api: AgStudioApi | null, direction: "undo" | "redo") {
  if (!api) return;
  const target = api.getHistory()[direction].at(-1)?.state;
  if (!target?.pages.length) return;
  const current = api.getState();
  if (!target.pages.some(p => p.id === current.selectedPageId)) {
    const selectedPageId = target.pages.some(p => p.id === target.selectedPageId) ? target.selectedPageId : target.pages[0].id;
    api.setState({ ...current, selectedPageId });
  }
  api[direction]();
}
