"use client";

import { AnimatePresence, m, useIsPresent } from "motion/react";
import {
  useEffect,
  useRef,
  useState,
  type CSSProperties,
  type ReactNode,
} from "react";
import { duration, easing, motionPresets, useReduce } from "@/lib/connected/motion";
import { confirmFormDismiss } from "../workspace-drafts";

const cards = {
  div: m.div,
  article: m.article,
  li: m.li,
  section: m.section,
} as const;
const grow = motionPresets.spatialDefault;

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
export function ContainerCard({
  layoutId,
  children,
  as = "div",
  className,
  style,
}: ContainerCardProps) {
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
    <Tag
      layoutId={layoutId}
      className={className}
      style={style}
      transition={{ layout: grow }}
    >
      {children}
    </Tag>
  );
}

export type ContainerDialogProps = {
  layoutId: string;
  open: boolean;
  onClose: () => void;
  /** Release the originating record only after the native modal closes. */
  onExited?: () => void;
  /** Fixed native layers use a compositor entrance instead of a table-row morph. */
  shared?: boolean;
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
export function ContainerDialog({
  layoutId,
  open,
  onClose,
  title,
  children,
  className,
  onExited,
  shared = true,
}: ContainerDialogProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLDialogElement>(null);
  const opener = useRef<HTMLElement | null>(null);
  const [mounted, setMounted] = useState(open);
  const requestClose = async () => {
    if (await confirmFormDismiss(ref.current)) onClose();
  };
  if (open && !mounted) setMounted(true);

  useEffect(() => {
    const dialog = ref.current;
    if (!dialog || !mounted || !open || dialog.open) return;
    opener.current =
      document.activeElement instanceof HTMLElement
        ? document.activeElement
        : null;
    dialog.showModal();
  }, [mounted, open]);

  useEffect(
    () => () => {
      // Some evidence routes unmount the dialog directly instead of animating
      // open=false. Restore focus in both paths, including a removed opener.
      const target = opener.current?.isConnected
        ? opener.current
        : document.getElementById("workspace-content");
      target?.focus({ preventScroll: true });
    },
    [],
  );

  const finish = () => {
    ref.current?.close();
    setMounted(false);
    opener.current?.focus();
    onExited?.();
  };

  // Reduced motion has no exit animation to wait for: close at once.
  useEffect(() => {
    if (reduce && !open && mounted) finish();
  }, [reduce, open, mounted]);
  useEffect(() => {
    if (!open && ref.current?.open) ref.current.focus();
  }, [open]);

  if (!mounted) return null;

  const close = (
    <button
      type="button"
      className="m3-dialog-close"
      aria-label="Close"
      onClick={() => void requestClose()}
    >
      <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
        <path
          d="M6 6l12 12M18 6L6 18"
          stroke="currentColor"
          strokeWidth="1.75"
          strokeLinecap="round"
        />
      </svg>
    </button>
  );

  return (
    <dialog
      ref={ref}
      className={["m3-dialog", className].filter(Boolean).join(" ")}
      aria-label={title}
      data-closing={!open || undefined}
      tabIndex={-1}
      onCancel={(e) => {
        e.preventDefault();
        void requestClose();
      }}
      onClick={(e) => {
        if (e.target === ref.current) void requestClose();
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
            <m.div
              key="surface"
              inert={!open}
              aria-hidden={!open || undefined}
              layoutId={shared ? layoutId : undefined}
              className="m3-dialog-surface"
              transition={shared ? { layout: grow } : motionPresets.spatialDefault}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 6, transition: motionPresets.effectsDefault }}
            >
              <PresentDialogContent>
              <m.div
                className="m3-dialog-content"
                initial={{ opacity: 0 }}
                animate={{
                  opacity: 1,
                  transition: {
                    duration: duration.medium2,
                    ease: easing.standard,
                    delay: 0.06,
                  },
                }}
                exit={{
                  opacity: 0,
                  transition: {
                    duration: duration.short2,
                    ease: easing.emphasizedAccelerate,
                  },
                }}
              >
                {close}
                {children}
              </m.div>
              </PresentDialogContent>
            </m.div>
          )}
        </AnimatePresence>
      )}
    </dialog>
  );
}

function PresentDialogContent({ children }: { children: ReactNode }) {
  const present = useIsPresent();
  return <div inert={!present} aria-hidden={!present || undefined}>{children}</div>;
}
