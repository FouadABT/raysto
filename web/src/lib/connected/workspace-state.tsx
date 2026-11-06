"use client";
import { createContext, useContext, useRef } from "react";
import type { ConnectedApi } from "./api";
import { useScopedDraft } from "./scoped-draft";

export const WorkspaceStateContext = createContext<
  { api: ConnectedApi; tenant: number; role?: string } | undefined
>(undefined);
/** Search and grid configuration survive navigation, scoped to identity and venue. */
export function useWorkspaceState<T>(key: string, initial: T) {
  const scope = useContext(WorkspaceStateContext),
    local = useRef({});
  return useScopedDraft(
    scope?.api ?? local.current,
    `${scope?.tenant ?? "local"}:view:${key}`,
    initial,
  );
}
