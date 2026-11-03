"use client";

import { AnimatePresence, m } from "motion/react";
import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { duration, easing, useReduce } from "@/lib/connected/motion";

export type SnackbarAction = { label: string; onPress: () => void };
export type DismissReason = "timeout" | "action" | "dismiss" | "replaced";
export type SnackbarOptions = {
  message: string;
  /** One action at most, e.g. Undo. */
  action?: SnackbarAction;
  /** How long it stays, in milliseconds (default 5000); it pauses while hovered or focused. */
  durationMs?: number;
  /** Told why it went away, so a caller can, say, send a pending move when Undo was not pressed. */
  onDismiss?: (reason: DismissReason) => void;
};

type Shown = SnackbarOptions & { id: number };
type Api = { show: (options: SnackbarOptions) => number; dismiss: (id?: number) => void };

const SnackbarContext = createContext<Api | null>(null);

export function useSnackbar(): Api {
  const api = useContext(SnackbarContext);
  if (!api) throw new Error("useSnackbar needs a SnackbarProvider above it.");
  return api;
}

/**
 * Material snackbars for the console: one at a time on the inverse surface,
 * a lime action, `role="status"`. A new one replaces the current one (which
 * is told "replaced"). The timer pauses while the pointer or focus is on it;
 * Esc closes it unless a dialog is open.
 */
export function SnackbarProvider({ children }: { children: ReactNode }) {
  const reduce = useReduce();
  const [current, setCurrent] = useState<Shown | null>(null);
  const seq = useRef(0);
  const currentRef = useRef<Shown | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const left = useRef(0);
  const startedAt = useRef(0);
  const paused = useRef(false);

  const clear = () => {
    if (timer.current) clearTimeout(timer.current);
    timer.current = null;
  };

  const close = useCallback((reason: DismissReason, id?: number) => {
    const now = currentRef.current;
    if (!now || (id !== undefined && now.id !== id)) return;
    clear();
    currentRef.current = null;
    setCurrent(null);
    now.onDismiss?.(reason);
  }, []);

  const arm = useCallback(
    (ms: number) => {
      clear();
      left.current = ms;
      startedAt.current = Date.now();
      if (!paused.current) timer.current = setTimeout(() => close("timeout"), ms);
    },
    [close],
  );

  const show = useCallback(
    (options: SnackbarOptions) => {
      const previous = currentRef.current;
      const next: Shown = { ...options, id: ++seq.current };
      currentRef.current = next;
      setCurrent(next);
      previous?.onDismiss?.("replaced");
      paused.current = false;
      arm(options.durationMs ?? 5000);
      return next.id;
    },
    [arm],
  );

  const dismiss = useCallback((id?: number) => close("dismiss", id), [close]);

  const pause = () => {
    if (paused.current || !currentRef.current) return;
    paused.current = true;
    left.current = Math.max(0, left.current - (Date.now() - startedAt.current));
    clear();
  };
  const resume = () => {
    if (!paused.current || !currentRef.current) return;
    paused.current = false;
    arm(Math.max(left.current, 1500));
  };

  useEffect(() => {
    if (!current) return;
    const onKey = (e: globalThis.KeyboardEvent) => {
      if (e.key !== "Escape" || document.querySelector("dialog[open]")) return;
      close("dismiss");
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [current, close]);

  useEffect(() => () => clear(), []);

  const api = useMemo(() => ({ show, dismiss }), [show, dismiss]);

  const body = current && (
    <div
      className="m3-snackbar"
      onPointerEnter={pause}
      onPointerLeave={resume}
      onFocus={pause}
      onBlur={resume}
    >
      <span className="m3-snackbar-text">{current.message}</span>
      {current.action && (
        <button
          type="button"
          className="m3-snackbar-action"
          onClick={() => {
            const act = current.action!;
            close("action");
            act.onPress();
          }}
        >
          {current.action.label}
        </button>
      )}
      <button type="button" className="m3-snackbar-close" aria-label="Close" onClick={() => close("dismiss")}>
        <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
          <path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
        </svg>
      </button>
    </div>
  );

  return (
    <SnackbarContext.Provider value={api}>
      {children}
      <div className="m3-snackbar-host" role="status" aria-live="polite">
        {reduce ? (
          body
        ) : (
          <AnimatePresence>
            {current && (
              <m.div
                key={current.id}
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0, transition: { duration: duration.medium1, ease: easing.emphasizedDecelerate } }}
                exit={{ opacity: 0, y: 6, transition: { duration: duration.short3, ease: easing.emphasizedAccelerate } }}
              >
                {body}
              </m.div>
            )}
          </AnimatePresence>
        )}
      </div>
    </SnackbarContext.Provider>
  );
}
