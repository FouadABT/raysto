"use client";

import { AnimatePresence, m, useIsPresent } from "motion/react";
import type { ReactNode } from "react";
import { duration, easing, useReduce } from "@/lib/connected/motion";

export type FadeThroughProps = {
  /** Changes when the content is a different place, e.g. the section id. */
  k: string;
  children: ReactNode;
  /**
   * The 0.92 → 1 scale of Material's fade through. Turn it off for AG Grid
   * and the Floor: a transform on their ancestors breaks their measurements.
   */
  scale?: boolean;
  className?: string;
};

/**
 * Material fade through between sections: the old content fades out in the
 * first 30% (90 ms), the new one fades in with a slight scale over the
 * rest (210 ms). Nothing animates on first load or under reduced motion.
 */
export function FadeThrough({
  k,
  children,
  scale = true,
  className,
}: FadeThroughProps) {
  const reduce = useReduce();
  if (reduce) {
    return (
      <div key={k} className={className}>
        {children}
      </div>
    );
  }
  return (
    <AnimatePresence mode="wait" initial={false}>
      <PresentBranch key={k} className={className} scale={scale}>
        {children}
      </PresentBranch>
    </AnimatePresence>
  );
}

function PresentBranch({
  children,
  className,
  scale,
}: {
  children: ReactNode;
  className?: string;
  scale: boolean;
}) {
  const present = useIsPresent();
  return (
    <m.div
      className={className}
      inert={!present}
      aria-hidden={!present || undefined}
      style={{ pointerEvents: present ? undefined : "none" }}
      initial={{ opacity: 0, scale: scale ? 0.98 : 1 }}
      animate={{
        opacity: 1,
        scale: 1,
        transition: {
          duration: duration.medium2 * 0.7,
          ease: easing.emphasizedDecelerate,
        },
      }}
      exit={{
        opacity: 0,
        transition: {
          duration: duration.medium2 * 0.3,
          ease: easing.emphasizedAccelerate,
        },
      }}
    >
      {children}
    </m.div>
  );
}
