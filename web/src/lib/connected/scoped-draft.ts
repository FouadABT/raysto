"use client";
import { useState, type Dispatch, type SetStateAction } from "react";
/** In-memory drafts belong to the API identity; no credentials or drafts enter browser storage. */
const scopes = new WeakMap<object, Map<string, unknown>>();
export function clearScopedDrafts(scope: object, prefix: string) {
  const entries = scopes.get(scope);
  if (entries)
    for (const key of entries.keys())
      if (
        key.startsWith(prefix) &&
        !key.endsWith(":request-keys") &&
        !key.endsWith(":review")
      )
        entries.delete(key);
}
export function useScopedDraft<T>(
  scope: object,
  key: string,
  initial: T,
): [T, Dispatch<SetStateAction<T>>] {
  let records = scopes.get(scope);
  if (!records) {
    records = new Map();
    scopes.set(scope, records);
  }
  const entries = records;
  const read = () => {
    if (!entries.has(key)) entries.set(key, initial);
    return entries.get(key) as T;
  };
  const [entry, setEntry] = useState(() => ({ scope, key, value: read() }));
  let current = entry;
  if (entry.scope !== scope || entry.key !== key) {
    current = { scope, key, value: read() };
    setEntry(current);
  }
  return [
    current.value,
    (next) =>
      setEntry((old) => {
        // A late callback from an outgoing identity or record cannot restore it.
        if (old.scope !== scope || old.key !== key) return old;
        const resolved =
          typeof next === "function" ? (next as (v: T) => T)(old.value) : next;
        entries.set(key, resolved);
        return { ...old, value: resolved };
      }),
  ];
}
