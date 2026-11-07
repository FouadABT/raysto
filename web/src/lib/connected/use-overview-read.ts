"use client";
import { useEffect, useRef, useState } from "react";
import type { ConnectedApi } from "./api";
import { overviewSnapshots } from "./read-snapshots";

/** Revalidates on every mount/revision; only Today opts into retention. */
export function useOverviewRead<T>(api: ConnectedApi, tenant: number, key: string, revision: string,
  read: (signal: AbortSignal) => Promise<T>, enabled = true) {
  const store = overviewSnapshots(api), cacheKey = `${tenant}:${key}`;
  const reader = useRef(read); reader.current = read;
  const [retry, setRetry] = useState(0);
  const [state, setState] = useState<{ api: ConnectedApi; tenant: number; data?: T; error?: string; loading: boolean }>(() => ({
    api, tenant, data: enabled ? store.get<T>(cacheKey) : undefined, loading: enabled,
  }));
  useEffect(() => {
    if (!enabled) return;
    const controller = new AbortController(), epoch = store.epoch;
    const unsubscribe = store.subscribe(ended => {
      controller.abort();
      if (ended) setState({ api, tenant, loading: false, error: "Access changed. Reopen the workspace to load authorized records." });
      else setRetry(n => n + 1);
    });
    const retained = store.get<T>(cacheKey);
    setState(s => ({ api, tenant, data: retained ?? (s.api === api && s.tenant === tenant ? s.data : undefined), loading: true }));
    const signal = AbortSignal.any([controller.signal, AbortSignal.timeout(45000)]);
    void reader.current(signal).then(data => {
      if (controller.signal.aborted || store.epoch !== epoch) return;
      store.put(cacheKey, data);
      setState({ api, tenant, data, loading: false });
    }).catch(e => {
      if (controller.signal.aborted || store.epoch !== epoch) return;
      const denied = ["forbidden", "unauthorized", "permission_denied", "session_changed"].includes(e?.code);
      if (denied) store.clear(true);
      setState(s => ({ api, tenant, data: denied || s.api !== api || s.tenant !== tenant ? undefined : s.data, error: e instanceof Error ? e.message : String(e), loading: false }));
    });
    return () => { unsubscribe(); controller.abort(); };
  }, [api, tenant, cacheKey, revision, retry, enabled, store]);
  // Scope-check during render, before effects run, so a venue/identity change
  // cannot briefly expose the previous scope or seed its next request.
  const visible = enabled && state.api === api && state.tenant === tenant
    ? state : { data: undefined, error: undefined, loading: enabled };
  return { ...visible, reload: () => setRetry(n => n + 1) };
}
