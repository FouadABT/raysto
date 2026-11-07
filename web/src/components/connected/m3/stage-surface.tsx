"use client";
import { useEffect, useRef, type ReactNode } from "react";
import { useIsPresent } from "motion/react";
import { easing, motionPresets, useReduce } from "@/lib/connected/motion";

/** Content updates in place: never remount drafts, grids or financial controls. */
export function StageSurface({ stage, children, className, focus = true }: {
  stage: string; children: ReactNode; className?: string; focus?: boolean;
}) {
  const reduce = useReduce(), present = useIsPresent();
  const root = useRef<HTMLDivElement>(null), previous = useRef(stage);
  useEffect(() => {
    if (reduce || !present || !root.current) return;
    const animation = root.current.animate([{ opacity: 0.65 }, { opacity: 1 }], {
      duration: motionPresets.effectsDefault.duration * 1000,
      easing: `cubic-bezier(${easing.standard.join(",")})`,
    });
    return () => animation.cancel();
  }, [stage, reduce, present]);
  useEffect(() => {
    if (previous.current === stage) return;
    previous.current = stage;
    if (!focus) return;
    const frame = requestAnimationFrame(() => {
      const heading = root.current?.querySelector<HTMLElement>("h2,h3,h4");
      if (heading) { heading.tabIndex = -1; heading.focus({ preventScroll: true }); }
    });
    return () => cancelAnimationFrame(frame);
  }, [stage, focus]);
  return <div ref={root} className={className} inert={!present} aria-hidden={!present || undefined}>{children}</div>;
}
