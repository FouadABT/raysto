"use client";

import { AnimatePresence, m } from "motion/react";
import { useEffect, useRef, useState, type CSSProperties, type ReactNode } from "react";
import { duration, easing, useReduce } from "@/lib/connected/motion";

const cards = { div: m.div, article: m.article, li: m.li, section: m.section } as const;
const grow = { duration: duration.medium4, ease: easing.emphasized };

export type ContainerCardProps = {
  /** Shared with the ContainerDialog it opens, e.g. `order-14`. */
  layoutId: string;
  children: ReactNode;
  as?: keyof typeof cards;
  className?: string;
  style?: CSSProperties;
};

/**
 * The card a ContainerDialog grows out of and shrinks back into (Material's
 * container transform). Opening it is the caller's job: put a real button
 * inside and set the dialog open from it.
 */
export function ContainerCard({ layoutId, children, as = "div", className, style }: ContainerCardProps) {
  const reduce = useReduce();
  if (reduce) {
    const Tag = as;
    return (
      <Tag className={className} style={style}>
        {children}
      </Tag>
    );
  }
  const Tag = cards[as];
  return (
    <Tag layoutId={layoutId} className={className} style={style} transition={{ layout: grow }}>
      {children}
    </Tag>
  );
}

export type ContainerDialogProps = {
  layoutId: string;
  open: boolean;
  onClose: () => void;
  /** The dialog's accessible name. */
  title: string;
  children: ReactNode;
  className?: string;
};

/**
 * A native modal `<dialog>` (focus trap, Esc, the top layer) whose surface
 * grows from its ContainerCard and shrinks back on close. The card's content
 * gives way first and the dialog's content fades in over the last 70%.
 * Focus returns to whatever opened it. Reduced motion opens and closes it
 * directly.
 */
export function ContainerDialog({ layoutId, open, onClose, title, children, className }: ContainerDialogProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLDialogElement>(null);
  const opener = useRef<HTMLElement | null>(null);
  const [mounted, setMounted] = useState(open);
  if (open && !mounted) setMounted(true);

  useEffect(() => {
    const dialog = ref.current;
    if (!dialog || !mounted || !open || dialog.open) return;
    opener.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    dialog.showModal();
  }, [mounted, open]);

  const finish = () => {
    ref.current?.close();
    setMounted(false);
    opener.current?.focus();
  };

  // Reduced motion has no exit animation to wait for: close at once.
  useEffect(() => {
    if (reduce && !open && mounted) finish();
  }, [reduce, open, mounted]);

  if (!mounted) return null;

  const close = (
    <button type="button" className="m3-dialog-close" aria-label="Close" onClick={onClose}>
      <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
        <path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" />
      </svg>
    </button>
  );

  return (
    <dialog
      ref={ref}
      className={["m3-dialog", className].filter(Boolean).join(" ")}
      aria-label={title}
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      onClick={(e) => {
        if (e.target === ref.current) onClose();
      }}
    >
      {reduce ? (
        <div className="m3-dialog-surface">
          {close}
          {children}
        </div>
      ) : (
        <AnimatePresence onExitComplete={finish}>
          {open && (
            <m.div key="surface" layoutId={layoutId} className="m3-dialog-surface" transition={{ layout: grow }}>
              <m.div
                className="m3-dialog-content"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1, transition: { duration: duration.medium2, ease: easing.standard, delay: duration.medium4 * 0.3 } }}
                exit={{ opacity: 0, transition: { duration: duration.short2, ease: easing.emphasizedAccelerate } }}
              >
                {close}
                {children}
              </m.div>
            </m.div>
          )}
        </AnimatePresence>
      )}
    </dialog>
  );
}
