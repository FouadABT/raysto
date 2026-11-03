"use client";

import { m } from "motion/react";
import { duration, easing, useReduce } from "@/lib/connected/motion";

export type NavIndicatorProps = {
  /** Render it inside the item that is selected; it slides from the last one. */
  active: boolean;
  /** One id per navigation, e.g. `ops-nav` for the drawer and `ops-rail` for the rail. */
  layoutId?: string;
  className?: string;
};

/**
 * Material's navigation active indicator: a lime pill behind the selected
 * item that slides to the next selection. Place it as the first child of a
 * `position: relative` item; the item's label sits above it (see m3.css).
 */
export function NavIndicator({ active, layoutId = "m3-nav-indicator", className }: NavIndicatorProps) {
  const reduce = useReduce();
  if (!active) return null;
  const cls = ["m3-nav-indicator", className].filter(Boolean).join(" ");
  if (reduce) return <span className={cls} aria-hidden="true" />;
  return (
    <m.span
      layoutId={layoutId}
      className={cls}
      aria-hidden="true"
      transition={{ layout: { duration: duration.medium2, ease: easing.emphasized } }}
    />
  );
}
