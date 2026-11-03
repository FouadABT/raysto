"use client";

import { animate, useInView } from "motion/react";
import { useEffect, useRef, useState } from "react";
import { duration as dur, easing, useReduce } from "@/lib/connected/motion";
import { countAt } from "./chart-math";

export type CountUpProps = {
  /** The real value; the count always lands exactly on it. */
  value: number;
  /** How a number reads, e.g. minor units → "$195.30". */
  format: (n: number) => string;
  /** Count from 0 on the first reveal (default), or show the value at once. */
  fromZero?: boolean;
  /** Seconds; default Material long2 (0.5 s). */
  duration?: number;
  className?: string;
};

/**
 * A number that counts to its real value: from 0 when it first scrolls into
 * view, from the previous value when the value changes. Tabular figures over
 * an invisible copy of the widest value, so nothing around it moves. The
 * moving digits are hidden from assistive technology, which reads the final
 * value only. Reduced motion, or a hidden tab, shows the value directly.
 */
export function CountUp({ value, format, fromZero = true, duration = dur.long2, className }: CountUpProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLSpanElement>(null);
  const seen = useInView(ref, { once: true, amount: 0.4 });
  const [shown, setShown] = useState(() => (reduce || !fromZero ? value : 0));
  const [from, setFrom] = useState(shown);
  const last = useRef(shown);

  useEffect(() => {
    if (reduce || (typeof document !== "undefined" && document.hidden)) {
      last.current = value;
      setShown(value);
      return;
    }
    if (!seen) return;
    const start = last.current;
    if (start === value) {
      setShown(value);
      return;
    }
    setFrom(start);
    const controls = animate(0, 1, {
      duration,
      ease: easing.emphasizedDecelerate,
      onUpdate: (t) => {
        const v = countAt(start, value, t);
        last.current = v;
        setShown(v);
      },
      onComplete: () => {
        last.current = value;
        setShown(value);
      },
    });
    return () => controls.stop();
  }, [value, seen, reduce, duration]);

  const final = format(value);
  return (
    <span ref={ref} className={["m3-count", className].filter(Boolean).join(" ")}>
      <span className="m3-count-sizer" aria-hidden="true">
        {final}
      </span>
      <span className="m3-count-sizer" aria-hidden="true">
        {format(from)}
      </span>
      <span className="m3-count-live" aria-hidden="true">
        {format(shown)}
      </span>
      <span className="m3-sr">{final}</span>
    </span>
  );
}
