"use client";

import { m } from "motion/react";
import { useState } from "react";
import { duration, easing, useReduce } from "@/lib/connected/motion";

export type StampProps = {
  /** Shows the stamp; only PayPal's confirmation should make this true. */
  paid: boolean;
  label?: string;
  /** Also land when it mounts already paid (default: a still stamp). */
  animateOnMount?: boolean;
  className?: string;
};

/**
 * The "PAID" mark: Fraunces italic in forest on a lime ring, tilted −8°. It
 * lands (scale 1.4 → 1 in 200 ms) only when `paid` turns true while the page
 * is open; something already paid when the page loads shows a still stamp.
 */
export function Stamp({ paid, label = "PAID", animateOnMount = false, className }: StampProps) {
  const reduce = useReduce();
  // React's "store what changed since the last render" pattern: it lands
  // only when paid turns true here, never for a page loaded already paid.
  const [prev, setPrev] = useState(paid);
  const [landed, setLanded] = useState(animateOnMount && paid);
  if (prev !== paid) {
    setPrev(paid);
    if (paid) setLanded(true);
  }
  if (!paid) return null;
  const cls = ["m3-stamp", className].filter(Boolean).join(" ");
  if (reduce || !landed) {
    return (
      <span className={cls} role="img" aria-label={label === "PAID" ? "Paid" : label}>
        {label}
      </span>
    );
  }
  return (
    <m.span
      className={cls}
      role="img"
      aria-label={label === "PAID" ? "Paid" : label}
      initial={{ opacity: 0, scale: 1.4, rotate: -8 }}
      animate={{ opacity: 1, scale: 1, rotate: -8 }}
      transition={{ duration: duration.short4, ease: easing.emphasizedAccelerate }}
    >
      {label}
    </m.span>
  );
}
