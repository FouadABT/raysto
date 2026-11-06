"use client";

import {
  createElement,
  useEffect,
  useState,
  useSyncExternalStore,
  type ReactNode,
} from "react";
import {
  LazyMotion,
  MotionConfig,
  domMax,
  useReducedMotion,
} from "motion/react";

/**
 * Material 3 motion for the console, from docs/design-tokens.json (md-sys.css
 * holds the same values for CSS). Easings are cubic-bezier control points;
 * durations are in seconds, as motion expects.
 */
export const easing = {
  emphasized: [0.2, 0, 0, 1],
  emphasizedDecelerate: [0.05, 0.7, 0.1, 1],
  emphasizedAccelerate: [0.3, 0, 0.8, 0.15],
  standard: [0.2, 0, 0, 1],
  standardDecelerate: [0, 0, 0, 1],
  standardAccelerate: [0.3, 0, 1, 1],
} as const satisfies Record<string, readonly [number, number, number, number]>;

export const duration = {
  short1: 0.05,
  short2: 0.1,
  short3: 0.15,
  short4: 0.2,
  medium1: 0.25,
  medium2: 0.3,
  medium3: 0.35,
  medium4: 0.4,
  long1: 0.45,
  long2: 0.5,
  long3: 0.55,
  long4: 0.6,
} as const;

/** How long a status move waits for Undo before it is sent. */
export const GRACE_MS = 5000;

/**
 * Entrance delay for the i-th item of a group: 0.09 s apart, never more than
 * 0.36 s (MOBILE_APP_DESIGN_SYSTEM_GUIDELINES, entrance stagger).
 */
export function stagger(i: number, step = 0.09, cap = 0.36): number {
  if (!Number.isFinite(i) || i <= 0) return 0;
  return Math.min(i * step, cap);
}

/* ---------- The console's own "Reduce motion" switch ---------- */

const KEY = "raysto.reduceMotion";
const listeners = new Set<() => void>();
let memoryPreference: boolean | undefined;

function readStored(): boolean {
  if (memoryPreference !== undefined) return memoryPreference;
  try {
    return globalThis.localStorage?.getItem(KEY) === "1";
  } catch {
    return false;
  }
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  const onStorage = (e: StorageEvent) => {
    if (e.key === KEY) {
      memoryPreference = undefined;
      listener();
    }
  };
  globalThis.addEventListener?.("storage", onStorage);
  return () => {
    listeners.delete(listener);
    globalThis.removeEventListener?.("storage", onStorage);
  };
}

/** Turns the console's reduce-motion switch on or off; it adds to the device setting, never overrides it. */
export function setReduceMotion(on: boolean) {
  memoryPreference = on;
  try {
    if (on) globalThis.localStorage?.setItem(KEY, "1");
    else globalThis.localStorage?.removeItem(KEY);
  } catch {
    /* Private mode: the switch lasts for this page only. */
  }
  if (typeof document !== "undefined") {
    for (const root of document.querySelectorAll<HTMLElement>(".ops-root")) {
      if (on) root.dataset.reduceMotion = "true";
      else delete root.dataset.reduceMotion;
    }
  }
  for (const l of listeners) l();
}

/** The console switch alone. */
export function useAppReduceMotion(): boolean {
  return useSyncExternalStore(subscribe, readStored, () => false);
}

/**
 * True when either the device or the console asks for reduced motion. Every
 * m3 component checks this itself and renders its final state directly:
 * motion's own reduced setting stops transforms but not opacity or pathLength.
 */
export function useReduce(): boolean {
  const device = useReducedMotion();
  const app = useAppReduceMotion();
  return Boolean(device) || app;
}

/* ---------- Entrances run once per section per session ---------- */

const visited = new Set<string>();

/**
 * True on the first visit to `key` in this session, false when the person
 * comes back to it, so a section never re-animates on return.
 */
export function useFirstVisit(key: string): boolean {
  const [first] = useState(() => !visited.has(key));
  useEffect(() => {
    visited.add(key);
  }, [key]);
  return first;
}

/** For tests. */
export function resetVisits() {
  visited.clear();
}

/**
 * The console's motion root: lazy-loads motion's DOM features (layout and
 * drag included) and applies the console switch on top of the device one.
 */
export function MotionRoot({ children }: { children: ReactNode }) {
  const app = useAppReduceMotion();
  useEffect(() => {
    if (app) setReduceMotion(true);
  }, [app]);
  return createElement(
    LazyMotion,
    { features: domMax },
    createElement(
      MotionConfig,
      { reducedMotion: app ? "always" : "user" },
      children,
    ),
  );
}
