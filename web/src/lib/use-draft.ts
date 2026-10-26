"use client";
import { useEffect, useState } from "react";

/** Keeps unfinished form text across browser back/forward and reloads in this tab.
 * Committed data still lives exclusively in DemoProvider. */
export function useDraft<T extends object>(
  key: string,
  committed: T,
  label: string,
) {
  const storageKey = `raysto.web.draft.${key}`;
  const [draft, setDraft] = useState<T>(() => {
    if (typeof window === "undefined") return committed;
    try {
      const raw = sessionStorage.getItem(storageKey);
      if (!raw) return committed;
      const saved = JSON.parse(raw);
      if (
        saved &&
        Object.keys(committed).every(
          (k) => typeof saved[k] === typeof committed[k as keyof T],
        )
      )
        return saved;
    } catch {
      /* A blocked session store does not prevent ordinary editing. */
    }
    return committed;
  });
  const dirty = JSON.stringify(draft) !== JSON.stringify(committed);
  useEffect(() => {
    try {
      if (dirty) sessionStorage.setItem(storageKey, JSON.stringify(draft));
      else sessionStorage.removeItem(storageKey);
    } catch {
      /* Navigation guard still protects the in-memory draft. */
    }
  }, [draft, dirty, storageKey]);
  useEffect(() => {
    if (!dirty) return;
    const unload = (event: BeforeUnloadEvent) => event.preventDefault();
    const click = (event: MouseEvent) => {
      const link = (event.target as Element).closest("a[href]");
      if (!link || event.metaKey || event.ctrlKey || event.shiftKey) return;
      if (!confirm(`Discard your unsaved ${label} changes?`)) {
        event.preventDefault();
        event.stopPropagation();
      } else {
        try {
          sessionStorage.removeItem(storageKey);
        } catch {
          /* No stored draft. */
        }
      }
    };
    window.addEventListener("beforeunload", unload);
    document.addEventListener("click", click, true);
    return () => {
      window.removeEventListener("beforeunload", unload);
      document.removeEventListener("click", click, true);
    };
  }, [dirty, label, storageKey]);
  return { draft, setDraft, dirty };
}
