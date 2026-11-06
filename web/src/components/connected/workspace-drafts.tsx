"use client";
import { useEffect, useRef, type ReactNode } from "react";
import { confirmDiscard } from "@/lib/connected/confirm-discard";

type Draft = { baseline: string; dirty: boolean; edits: number };
const forms = new WeakMap<HTMLFormElement, Draft>();
let submitting: HTMLFormElement | null = null;
function fingerprint(form: HTMLFormElement) {
  return JSON.stringify(
    Array.from(form.elements)
      .filter(
        (e): e is HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement =>
          e instanceof HTMLInputElement ||
          e instanceof HTMLTextAreaElement ||
          e instanceof HTMLSelectElement,
      )
      .filter((e) => e.type !== "password" && e.type !== "hidden")
      .map((e) => [
        e.name,
        e.id,
        e.type,
        e instanceof HTMLInputElement && ["checkbox", "radio"].includes(e.type)
          ? e.checked
          : e.value,
      ]),
  );
}
/** Called synchronously by the shared mutation runner. A failed save never acknowledges a draft. */
export function submittedFormAcknowledgement() {
  const form = submitting,
    record = form && forms.get(form),
    edits = record?.edits;
  return () => {
    if (!form || !record) return;
    requestAnimationFrame(() => {
      if (record.edits !== edits) return;
      record.baseline = fingerprint(form);
      record.dirty = false;
      window.dispatchEvent(new Event("raysto:form-draft-change"));
    });
  };
}
export async function confirmFormDismiss(container: Element | null) {
  const dirty =
    container &&
    (container instanceof HTMLFormElement
      ? [container]
      : Array.from(container.querySelectorAll("form"))
    ).some((f) => forms.get(f)?.dirty);
  return !dirty || (await confirmDiscard("Discard the unsaved form changes?"));
}
export function WorkspaceDraftBoundary({
  children,
  onDirty,
}: {
  children: ReactNode;
  onDirty: (dirty: boolean) => void;
}) {
  const root = useRef<HTMLDivElement>(null),
    notify = useRef(onDirty);
  notify.current = onDirty;
  useEffect(() => {
    const sync = () => {
      const list = Array.from(
        root.current?.querySelectorAll("form") ?? [],
      ).filter((f) => !f.closest(".ops-finance") && !f.closest("[inert]"));
      for (const form of list)
        if (!forms.has(form))
          forms.set(form, {
            baseline: fingerprint(form),
            dirty: false,
            edits: 0,
          });
      notify.current(list.some((f) => forms.get(f)?.dirty));
    };
    const observer = new MutationObserver(sync);
    if (root.current)
      observer.observe(root.current, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["inert"],
      });
    sync();
    window.addEventListener("raysto:form-draft-change", sync);
    return () => {
      observer.disconnect();
      window.removeEventListener("raysto:form-draft-change", sync);
      notify.current(false);
    };
  }, []);
  return (
    <div
      ref={root}
      style={{ display: "contents" }}
      onKeyDownCapture={(e) => {
        const tab = (e.target as HTMLElement).closest<HTMLElement>(
            '[role="tab"]',
          ),
          list = tab?.closest('[role="tablist"]');
        if (
          !tab ||
          !list ||
          !["ArrowLeft", "ArrowRight", "Home", "End"].includes(e.key)
        )
          return;
        const items = Array.from(
          list.querySelectorAll<HTMLButtonElement>('[role="tab"]'),
        ).filter((b) => !b.disabled);
        const index = items.indexOf(tab as HTMLButtonElement);
        if (index < 0) return;
        e.preventDefault();
        const next =
          e.key === "Home"
            ? 0
            : e.key === "End"
              ? items.length - 1
              : (index + (e.key === "ArrowRight" ? 1 : -1) + items.length) %
                items.length;
        items[next]?.focus();
        items[next]?.click();
      }}
      onChangeCapture={(e) => {
        const target = e.target as HTMLElement,
          form = target.closest("form");
        if (!form || form.closest(".ops-finance")) return;
        const record = forms.get(form);
        if (!record) return;
        record.edits++;
        record.dirty = fingerprint(form) !== record.baseline;
        window.dispatchEvent(new Event("raysto:form-draft-change"));
      }}
      onSubmitCapture={(e) => {
        submitting = e.target as HTMLFormElement;
        queueMicrotask(() => {
          submitting = null;
        });
      }}
    >
      {children}
    </div>
  );
}
