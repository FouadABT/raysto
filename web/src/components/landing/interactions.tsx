"use client";

import {
  useEffect,
  useRef,
  useState,
  type KeyboardEvent,
  type ReactNode,
} from "react";
import { useLandingMotion } from "./motion-shell";
import { roles } from "./fixtures";
import { Symbol } from "./symbol";

export function MobileNavigation() {
  const ref = useRef<HTMLDetailsElement>(null);
  useEffect(() => {
    const outside = (event: PointerEvent) => {
      if (ref.current?.open && !ref.current.contains(event.target as Node))
        ref.current.open = false;
    };
    const wide = matchMedia("(min-width:840px)");
    const closeWide = () => {
      if (wide.matches && ref.current) ref.current.open = false;
    };
    wide.addEventListener("change", closeWide);
    document.addEventListener("pointerdown", outside);
    return () => {
      document.removeEventListener("pointerdown", outside);
      wide.removeEventListener("change", closeWide);
    };
  }, []);
  return (
    <details
      ref={ref}
      className="lp-mobile-menu"
      onKeyDown={(event) => {
        if (event.key === "Escape" && ref.current?.open) {
          ref.current.open = false;
          ref.current.querySelector("summary")?.focus();
        }
      }}
    >
      <summary aria-label="Open navigation">
        <Symbol name="menu" />
      </summary>
      <nav
        aria-label="Mobile navigation"
        onClick={(event) => {
          if ((event.target as Element).closest("a") && ref.current)
            ref.current.open = false;
        }}
      >
        <a href="#platform">Platform</a>
        <a href="#how-it-works">How it works</a>
        <a href="#payments">PayPal payments</a>
        <a href="#ai">AI</a>
        <a href="#faq">FAQ</a>
        <a href="/ops">Sign in</a>
        <a className="lp-button" href="/contact">
          Book a demo <Symbol name="north_east" />
        </a>
      </nav>
    </details>
  );
}

export function FloorPreview({ hero = false }: { hero?: boolean }) {
  const [table, setTable] = useState(4);
  return (
    <div className={`lp-floor ${hero ? "lp-floor-hero" : ""}`}>
      <div
        className="lp-tables"
        role="group"
        aria-label={hero ? "Hero sample tables" : "Sample terrace tables"}
      >
        {[1, 2, 3, 4, 5, 6].map((number) => (
          <button
            key={number}
            aria-pressed={table === number}
            aria-label={`Select sample table ${number}`}
            onClick={() => setTable(number)}
          >
            {String(number).padStart(2, "0")}
            <i />
          </button>
        ))}
        <span className="lp-floor-plant" aria-hidden="true">
          ✳
        </span>
      </div>
      {!hero && (
        <div className="lp-table-detail" aria-live="polite">
          <strong>Table {String(table).padStart(2, "0")}</strong>
          <span>
            <Symbol name="group" /> {table === 4 ? 4 : 2} guests
          </span>
          <span className="lp-pill">
            {table === 4 ? "Bill requested" : "Open visit"}
          </span>
        </div>
      )}
    </div>
  );
}

export function GuestPhone({ salad = false }: { salad?: boolean }) {
  const [added, setAdded] = useState(false);
  const dish = salad ? "Salade verte" : "Croque monsieur";
  return (
    <div className="lp-phone" aria-label={`Illustrative guest menu: ${dish}`}>
      <div className="lp-phone-top">
        <strong>Atelier Café</strong>
        <Symbol name="menu" />
      </div>
      <div className={`lp-phone-food ${salad ? "salad" : ""}`}>
        <img
          src={
            salad
              ? "/images/landing/salad-preview.webp"
              : "/images/landing/cafe-service.webp"
          }
          alt=""
          width="220"
          height="190"
          loading="lazy"
        />
      </div>
      <strong>{dish}</strong>
      <span>{salad ? "€6.50" : "€7.50"}</span>
      <button
        className="lp-button lp-button-small"
        aria-label={`Add ${dish} to sample basket`}
        onClick={() => setAdded(true)}
      >
        <Symbol name={added ? "check" : "shopping_bag"} />
        {added ? "Added to preview" : "Add to basket"}
      </button>
      <span className="lp-phone-note" role="status">
        {added ? "Local sample · no order placed" : "Illustrative menu"}
      </span>
    </div>
  );
}

function usePanelEntrance(key: string, ref: { current: HTMLElement | null }) {
  const { reduce } = useLandingMotion();
  useEffect(() => {
    if (reduce || !ref.current) return;
    const animation = ref.current.animate([{ opacity: 0.65 }, { opacity: 1 }], {
      duration: 240,
      easing: "cubic-bezier(.2,0,0,1)",
    });
    return () => animation.cancel();
  }, [key, reduce, ref]);
}

/** Roving focus; selection changes only this marketing preview. */
function moveTab(
  event: KeyboardEvent<HTMLElement>,
  index: number,
  count: number,
  select: (index: number) => void,
) {
  const next =
    event.key === "ArrowRight"
      ? (index + 1) % count
      : event.key === "ArrowLeft"
        ? (index - 1 + count) % count
        : event.key === "Home"
          ? 0
          : event.key === "End"
            ? count - 1
            : null;
  if (next === null) return;
  event.preventDefault();
  const buttons =
    event.currentTarget.querySelectorAll<HTMLButtonElement>("[role=tab]");
  select(next);
  buttons[next]?.focus();
}

export function KitchenPreview() {
  const labels = ["New", "Preparing", "Ready"],
    [selected, setSelected] = useState(1);
  const ref = useRef<HTMLDivElement>(null);
  usePanelEntrance(String(selected), ref);
  const dishes =
    selected === 0
      ? [
          ["#26", "Tarte du jour"],
          ["#27", "Café crème"],
        ]
      : selected === 1
        ? [
            ["#24", "Croque monsieur"],
            ["#25", "Salade verte"],
            ["#28", "Soup of the day"],
          ]
        : [["#23", "Croque monsieur"]];
  return (
    <>
      <div
        className="lp-mini-tabs"
        role="tablist"
        aria-label="Sample kitchen status"
        onKeyDown={(event) => moveTab(event, selected, 3, setSelected)}
      >
        {labels.map((label, index) => (
          <button
            key={label}
            role="tab"
            id={`kitchen-${index}`}
            aria-selected={selected === index}
            aria-controls="kitchen-panel"
            tabIndex={selected === index ? 0 : -1}
            onClick={() => setSelected(index)}
          >
            {label} <small>{[2, 3, 1][index]}</small>
          </button>
        ))}
      </div>
      <div
        className="lp-ticket-list"
        ref={ref}
        role="tabpanel"
        id="kitchen-panel"
        aria-labelledby={`kitchen-${selected}`}
        tabIndex={0}
      >
        {dishes.map(([number, dish]) => (
          <div className="lp-ticket" key={number}>
            <span>
              <strong>Order {number}</strong>
              <small>{dish}</small>
            </span>
            <span className={`lp-pill ${selected === 1 ? "lime" : ""}`}>
              {labels[selected]}
            </span>
          </div>
        ))}
      </div>
    </>
  );
}

export function MenuPreview() {
  const labels = ["Dishes", "Availability", "Supplies"],
    [selected, setSelected] = useState(0);
  const ref = useRef<HTMLDivElement>(null);
  usePanelEntrance(String(selected), ref);
  return (
    <>
      <div
        className="lp-mini-tabs"
        role="tablist"
        aria-label="Sample menu views"
        onKeyDown={(event) => moveTab(event, selected, 3, setSelected)}
      >
        {labels.map((label, index) => (
          <button
            key={label}
            id={`menu-${index}`}
            role="tab"
            aria-selected={selected === index}
            aria-controls="menu-panel"
            tabIndex={selected === index ? 0 : -1}
            onClick={() => setSelected(index)}
          >
            {label}
          </button>
        ))}
      </div>
      <div
        ref={ref}
        className="lp-menu-list"
        id="menu-panel"
        role="tabpanel"
        aria-labelledby={`menu-${selected}`}
        tabIndex={0}
      >
        {selected === 2 ? (
          <>
            <div className="lp-ticket">
              <span>
                <strong>Milk</strong>
                <small>Delivery to review</small>
              </span>
              <Symbol name="inventory_2" />
            </div>
            <div className="lp-ticket">
              <span>
                <strong>Bread</strong>
                <small>Confirmed purchasing unit</small>
              </span>
              <Symbol name="bakery_dining" />
            </div>
          </>
        ) : (
          <>
            <div className="lp-menu-item">
              <span className="lp-food-thumb">
                <img
                  src="/images/landing/cafe-service.webp"
                  alt=""
                  width="64"
                  height="64"
                  loading="lazy"
                />
              </span>
              <span>
                <strong>Croque monsieur</strong>
                <small>
                  ● {selected === 1 ? "Available for service" : "In stock"}
                </small>
              </span>
              <Symbol name="chevron_right" />
            </div>
            <div className="lp-menu-item">
              <img
                src="/images/landing/salad-preview.webp"
                alt=""
                width="52"
                height="52"
                loading="lazy"
              />
              <span>
                <strong>Salade verte</strong>
                <small>
                  ● {selected === 1 ? "Available for service" : "In stock"}
                </small>
              </span>
              <Symbol name="chevron_right" />
            </div>
          </>
        )}
      </div>
    </>
  );
}

export function RolePreview() {
  const [selected, setSelected] = useState(0),
    current = roles[selected];
  const ref = useRef<HTMLDivElement>(null);
  usePanelEntrance(current.name, ref);
  return (
    <>
      <div
        className="lp-role-tabs"
        role="tablist"
        aria-label="Explore team roles"
        onKeyDown={(event) =>
          moveTab(event, selected, roles.length, setSelected)
        }
      >
        {roles.map((role, index) => (
          <button
            key={role.name}
            role="tab"
            id={`role-${index}`}
            aria-controls="role-panel"
            aria-selected={index === selected}
            tabIndex={index === selected ? 0 : -1}
            onClick={() => setSelected(index)}
          >
            {role.name}
          </button>
        ))}
      </div>
      <div
        ref={ref}
        className="lp-role-panel"
        role="tabpanel"
        id="role-panel"
        aria-labelledby={`role-${selected}`}
        tabIndex={0}
      >
        <div>
          <span className="lp-eyebrow">FOR {current.name.toUpperCase()}</span>
          <h3>{current.title}</h3>
          <p>{current.description}</p>
        </div>
        <div className="lp-role-state">
          <Symbol name={current.icon} />
          <div>
            <small>{current.metric}</small>
            <strong>{current.value}</strong>
            <span>{current.detail}</span>
          </div>
        </div>
      </div>
    </>
  );
}

function PreviewDialog({
  title,
  children,
  label,
}: {
  title: string;
  children: ReactNode;
  label: string;
}) {
  const dialog = useRef<HTMLDialogElement>(null),
    opener = useRef<HTMLButtonElement>(null),
    animation = useRef<Animation | null>(null);
  const { reduce } = useLandingMotion();
  useEffect(() => () => animation.current?.cancel(), []);
  const close = () => {
    const element = dialog.current;
    if (!element?.open || element.dataset.closing) return;
    const finish = () => {
      element.close();
      element.removeAttribute("data-closing");
      element.querySelector<HTMLElement>(".lp-dialog-content")!.inert = false;
      animation.current?.cancel();
      animation.current = null;
      opener.current?.focus();
    };
    if (reduce) {
      finish();
      return;
    }
    element.dataset.closing = "true";
    element.querySelector<HTMLElement>(".lp-dialog-content")!.inert = true;
    element.focus();
    const style = getComputedStyle(element),
      start = { opacity: style.opacity, transform: style.transform };
    animation.current?.cancel();
    animation.current = element.animate(
      [start, { opacity: 0, transform: "translateY(8px)" }],
      { duration: 180, easing: "cubic-bezier(.2,0,0,1)" },
    );
    void animation.current.finished.then(finish).catch(() => {});
  };
  return (
    <>
      <button
        ref={opener}
        className={
          label === "Review proposal"
            ? "lp-button lp-button-small"
            : "lp-text-button"
        }
        onClick={() => {
          const element = dialog.current;
          if (!element || element.open) return;
          element.showModal();
          if (!reduce)
            animation.current = element.animate(
              [
                { opacity: 0.7, transform: "translateY(12px)" },
                { opacity: 1, transform: "translateY(0)" },
              ],
              { duration: 280, easing: "cubic-bezier(.2,0,0,1)" },
            );
        }}
      >
        {label}
        {label === "View source" && <Symbol name="north_east" />}
      </button>
      <dialog
        ref={dialog}
        className="lp-dialog"
        aria-label={title}
        tabIndex={-1}
        onCancel={(event) => {
          event.preventDefault();
          close();
        }}
        onClick={(event) => {
          if (event.target === dialog.current) close();
        }}
      >
        <div className="lp-dialog-content">
          <span className="lp-eyebrow">ILLUSTRATIVE PRODUCT PREVIEW</span>
          <h2>{title}</h2>
          {children}
          <button className="lp-button" onClick={close}>
            Close preview <Symbol name="close" />
          </button>
        </div>
      </dialog>
    </>
  );
}

export function AIReviewPreview() {
  return (
    <div className="lp-ai-scene" data-ai-scene>
      <div className="lp-source-sheet">
        <Symbol name="description" />
        <strong>Supplier bill</strong>
        <i />
        <i />
        <i />
        <i />
        <strong>€196.10</strong>
      </div>
      <span className="lp-evidence-connector" aria-hidden="true">
        <Symbol name="arrow_forward" />
      </span>
      <div className="lp-proposal">
        <span className="lp-preview-title">
          <Symbol name="description" /> Supplier bill
        </span>
        <strong className="lp-proposal-amount">€196.10</strong>
        <div className="lp-status-pair">
          <span className="lp-pill lime">Needs review</span>
          <span className="lp-pill">Not posted</span>
        </div>
        <div className="lp-proposal-actions">
          <PreviewDialog title="Source evidence" label="View source">
            <p>
              This authored supplier document illustrates a total of{" "}
              <strong>€196.10</strong>. It is not a real supplier invoice or a
              recorded payment.
            </p>
            <div className="lp-evidence-total">
              <span>Illustrative document total</span>
              <strong>€196.10</strong>
            </div>
          </PreviewDialog>
          <PreviewDialog title="Review the proposal" label="Review proposal">
            <p>
              AI keeps the evidence and the proposed amount together. An
              authorized team member would review the source, category and
              amount before applying a financial change.
            </p>
            <div className="lp-status-pair">
              <span className="lp-pill lime">Needs review</span>
              <span className="lp-pill">Not posted</span>
            </div>
            <p>
              A supported PayPal supplier payout requires a separate review.
              This preview does not approve, post or pay a bill.
            </p>
          </PreviewDialog>
        </div>
      </div>
    </div>
  );
}
