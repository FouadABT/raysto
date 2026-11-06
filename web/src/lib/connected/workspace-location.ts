"use client";
import { useEffect, useState } from "react";

export const workspaceRouteEvent = "raysto:workspace-route";
export function workspaceUrl(
  current: string,
  values: Record<string, string | number | undefined>,
): string {
  const url = new URL(current, "https://ops.rays.to");
  if (
    values.section !== undefined &&
    values.section !== url.searchParams.get("section")
  ) {
    for (const key of [
      "tab",
      "view",
      "channel",
      "product",
      "comparison",
      "period",
    ])
      url.searchParams.delete(key);
  }
  for (const [key, value] of Object.entries(values)) {
    if (value === undefined) url.searchParams.delete(key);
    else url.searchParams.set(key, String(value));
  }
  return `${url.pathname}${url.search}${url.hash}`;
}
export function updateWorkspaceRoute(
  values: Record<string, string | number | undefined>,
  replace = false,
) {
  const next = workspaceUrl(window.location.href, values);
  if (next === `${location.pathname}${location.search}${location.hash}`) return;
  window.history[replace ? "replaceState" : "pushState"](null, "", next);
  window.dispatchEvent(new Event(workspaceRouteEvent));
}
export function useWorkspaceTab<T extends string>(
  section: string,
  allowed: readonly T[],
  fallback: T,
) {
  return useWorkspaceValue(section, "tab", allowed, fallback);
}
export function useWorkspaceValue<T extends string>(
  section: string,
  key: string,
  allowed: readonly T[],
  fallback: T,
) {
  const read = (): T => {
    if (typeof window === "undefined") return fallback;
    const p = new URLSearchParams(window.location.search),
      tab = p.get(key);
    return p.get("section") === section && allowed.includes(tab as T)
      ? (tab as T)
      : fallback;
  };
  const [value, setValue] = useState<T>(read);
  useEffect(() => {
    const sync = () => setValue(read());
    window.addEventListener("popstate", sync);
    window.addEventListener(workspaceRouteEvent, sync);
    return () => {
      window.removeEventListener("popstate", sync);
      window.removeEventListener(workspaceRouteEvent, sync);
    };
  }, [section, key, allowed.join("|"), fallback]);
  return [
    value,
    (next: T) => {
      updateWorkspaceRoute({ section, [key]: next });
    },
  ] as const;
}
