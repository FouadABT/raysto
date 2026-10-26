"use client";
import Link from "next/link";
import {
  useEffect,
  useId,
  useRef,
  type ReactNode,
  type ButtonHTMLAttributes,
} from "react";
import { money, type Order } from "@/lib/domain";
export function Icon({
  name,
  className = "",
}: {
  name: string;
  className?: string;
}) {
  return (
    <span
      className={`material-symbols-rounded ${className}`}
      aria-hidden="true"
    >
      {name}
    </span>
  );
}
export function Brand({ compact = false }: { compact?: boolean }) {
  return (
    <Link className="brand" href="/" aria-label="Raysto home">
      {compact ? "r" : "raysto"}
      <span className="brand-mark">✳</span>
    </Link>
  );
}
export function Button({
  children,
  icon,
  variant = "primary",
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  icon?: string;
  variant?: string;
}) {
  return (
    <button
      type="button"
      className={`button ${variant} ${className}`}
      {...props}
    >
      <span className="button-inner">
        {icon && <Icon name={icon} />} {children}
      </span>
    </button>
  );
}
export function ActionLink({
  children,
  href,
  icon,
  variant = "primary",
  className = "",
}: {
  children: ReactNode;
  href: string;
  icon?: string;
  variant?: string;
  className?: string;
}) {
  return (
    <Link href={href} className={`button ${variant} ${className}`}>
      <span className="button-inner">
        {icon && <Icon name={icon} />} {children}
      </span>
    </Link>
  );
}
export function IconButton({
  name,
  label,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { name: string; label: string }) {
  return (
    <button
      type="button"
      className="icon-button"
      aria-label={label}
      title={label}
      {...props}
    >
      <Icon name={name} />
    </button>
  );
}
export function Badge({
  children,
  tone = "",
}: {
  children: ReactNode;
  tone?: string;
}) {
  return (
    <span
      className={`badge ${tone || String(children).toLowerCase().replaceAll(" ", "-")}`}
    >
      <span className="status-dot" />
      {children}
    </span>
  );
}
export function PageTitle({
  eyebrow,
  title,
  description,
  action,
}: {
  eyebrow?: string;
  title: string;
  description?: string;
  action?: ReactNode;
}) {
  return (
    <div className="page-title">
      <div>
        {eyebrow && <div className="eyebrow">{eyebrow}</div>}
        <h1>{title}</h1>
        {description && <p>{description}</p>}
      </div>
      {action && <div className="title-action">{action}</div>}
    </div>
  );
}
export function SectionTitle({
  title,
  children,
}: {
  title: string;
  children?: ReactNode;
}) {
  return (
    <div className="section-title">
      <h2>{title}</h2>
      {children}
    </div>
  );
}
export function Empty({
  icon = "search",
  title = "Nothing here yet",
  text,
  action,
}: {
  icon?: string;
  title?: string;
  text: string;
  action?: ReactNode;
}) {
  return (
    <div className="empty">
      <span className="empty-icon">
        <Icon name={icon} />
      </span>
      <h3>{title}</h3>
      <p>{text}</p>
      {action}
    </div>
  );
}
export function Search({
  value,
  onChange,
  placeholder = "Search…",
}: {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}) {
  return (
    <label className="search">
      <Icon name="search" />
      <input
        aria-label={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
      />
      {value && (
        <button aria-label="Clear search" onClick={() => onChange("")}>
          <Icon name="close" />
        </button>
      )}
    </label>
  );
}
export function Chips({
  items,
  value,
  onChange,
}: {
  items: string[];
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <div className="chips" role="group" aria-label="Filter">
      {items.map((item) => (
        <button
          type="button"
          key={item}
          className={`chip ${item === value ? "selected" : ""}`}
          aria-pressed={item === value}
          onClick={() => onChange(item)}
        >
          {item === value && <Icon name="check" />}
          {item}
        </button>
      ))}
    </div>
  );
}
export function Field({
  label,
  children,
  hint,
}: {
  label: string;
  children: ReactNode;
  hint?: string;
}) {
  return (
    <label className="field">
      <span>{label}</span>
      {children}
      {hint && <small>{hint}</small>}
    </label>
  );
}
export function Modal({
  title,
  children,
  onClose,
  dirty = false,
  wide = false,
}: {
  title: string;
  children: ReactNode;
  onClose: () => void;
  dirty?: boolean;
  wide?: boolean;
}) {
  const ref = useRef<HTMLDialogElement>(null);
  const titleId = useId();
  const close = () => {
    if (!dirty || window.confirm("Discard your unsaved changes?")) onClose();
  };
  useEffect(() => {
    const dialog = ref.current;
    const focused = document.activeElement as HTMLElement;
    dialog?.showModal();
    return () => {
      dialog?.close();
      focused?.focus();
    };
  }, []);
  return (
    <dialog
      ref={ref}
      className={`modal ${wide ? "wide" : ""}`}
      aria-labelledby={titleId}
      onCancel={(e) => {
        e.preventDefault();
        close();
      }}
    >
      <header>
        <h2 id={titleId}>{title}</h2>
        <IconButton name="close" label="Close dialog" onClick={close} />
      </header>
      <div className="modal-body">{children}</div>
    </dialog>
  );
}
export function FoodImage({
  image,
  name,
  className = "",
}: {
  image: string;
  name: string;
  className?: string;
}) {
  return image ? (
    <img
      className={`food-image ${className}`}
      src={`/images/${image}`}
      alt={name}
      loading="lazy"
    />
  ) : (
    <div className={`food-placeholder ${className}`}>
      <Icon
        name={
          name.toLowerCase().includes("dessert") ? "icecream" : "local_cafe"
        }
      />
    </div>
  );
}
export function OrderLines({ order }: { order: Order }) {
  return (
    <div className="order-lines">
      {order.lines.map((line) => (
        <div className="line-item" key={line.id}>
          <FoodImage image={line.image} name={line.name} />
          <div>
            <strong>
              {line.quantity} × {line.name}
            </strong>
            <p>
              {line.option}
              {line.note && ` · ${line.note}`}
            </p>
          </div>
          <b>{money(line.price * line.quantity)}</b>
        </div>
      ))}
    </div>
  );
}
export function Totals({
  subtotal,
  discount,
  fee,
  tip,
  total,
}: {
  subtotal: number;
  discount: number;
  fee: number;
  tip: number;
  total: number;
}) {
  return (
    <div className="totals">
      <div>
        <span>Subtotal</span>
        <span>{money(subtotal)}</span>
      </div>
      {discount > 0 && (
        <div>
          <span>WELCOME10</span>
          <span>−{money(discount)}</span>
        </div>
      )}
      <div>
        <span>Delivery</span>
        <span>{fee ? money(fee) : "No charge"}</span>
      </div>
      {tip > 0 && (
        <div>
          <span>Tip for the team</span>
          <span>{money(tip)}</span>
        </div>
      )}
      <div className="grand-total">
        <strong>Total</strong>
        <strong>{money(total)}</strong>
      </div>
      <small>
        Demo prices include applicable taxes. No actual payment is processed.
      </small>
    </div>
  );
}
export function DownloadCSV({
  rows,
  name = "raysto-demo",
}: {
  rows: (string | number)[][];
  name?: string;
}) {
  return (
    <Button
      variant="secondary"
      icon="download"
      onClick={() => {
        const content = rows
          .map((row) =>
            row
              .map(
                (cell) =>
                  `"${String(cell)
                    .replace(/^[=+@-]/, "'$&")
                    .replaceAll('"', '""')}"`,
              )
              .join(","),
          )
          .join("\r\n");
        const url = URL.createObjectURL(
          new Blob(["\uFEFF" + content], { type: "text/csv;charset=utf-8;" }),
        );
        const a = document.createElement("a");
        a.href = url;
        a.download = `${name}.csv`;
        a.click();
        URL.revokeObjectURL(url);
      }}
    >
      Export CSV
    </Button>
  );
}
export function timeLabel(iso: string) {
  return new Intl.DateTimeFormat("en", {
    hour: "numeric",
    minute: "2-digit",
  }).format(new Date(iso));
}
