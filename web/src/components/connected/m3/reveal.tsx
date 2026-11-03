"use client";

import { m } from "motion/react";
import type { CSSProperties, ReactNode } from "react";
import { duration, easing, stagger, useFirstVisit, useReduce } from "@/lib/connected/motion";

const tags = { div: m.div, section: m.section, article: m.article, li: m.li, header: m.header, aside: m.aside } as const;

export type RevealProps = {
  children: ReactNode;
  /** Position in its group; sets the stagger (0.09 s apart, at most 0.36 s). */
  index?: number;
  as?: keyof typeof tags;
  className?: string;
  style?: CSSProperties;
  /** Wait until it scrolls into view (once), instead of playing on mount. */
  inView?: boolean;
  /** Plays only on the first visit to this key in the session. */
  visitKey?: string;
  id?: string;
};

/**
 * Material entrance: a fade with a 6 px rise on emphasized-decelerate. Under
 * reduced motion, or when coming back to a section, it renders the element
 * as it is, with nothing to wait for.
 */
export function Reveal({ children, index = 0, as = "div", className, style, inView = false, visitKey, id }: RevealProps) {
  const reduce = useReduce();
  const first = useFirstVisit(visitKey ?? "__always__");
  const still = reduce || (visitKey !== undefined && !first);
  if (still) {
    const Tag = as;
    return (
      <Tag className={className} style={style} id={id}>
        {children}
      </Tag>
    );
  }
  const Tag = tags[as];
  const shown = { opacity: 1, y: 0 };
  return (
    <Tag
      className={className}
      style={style}
      id={id}
      initial={{ opacity: 0, y: 6 }}
      {...(inView ? { whileInView: shown, viewport: { once: true, amount: 0.15 } } : { animate: shown })}
      transition={{ duration: duration.medium2, ease: easing.emphasizedDecelerate, delay: stagger(index) }}
    >
      {children}
    </Tag>
  );
}
