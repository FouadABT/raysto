"use client";

import { m, useInView } from "motion/react";
import { useEffect, useId, useMemo, useRef, useState, type KeyboardEvent, type PointerEvent, type ReactNode } from "react";
import { duration, easing, stagger, useReduce } from "@/lib/connected/motion";
import { areaPath, arcPath, donutSegments, labelEvery, linePath, niceMax, progress, project, ticks } from "./chart-math";

const safeId = (id: string) => id.replace(/[^a-zA-Z0-9_-]/g, "");

const draw = { duration: duration.long4, ease: easing.emphasized };

/* ---------- Sparkline ---------- */

export type SparklineProps = {
  values: readonly number[];
  /** What the line shows, read by assistive technology, e.g. "Paid sales, last 7 days". */
  label: string;
  width?: number;
  height?: number;
  color?: string;
  /** A soft lime fill under the line. */
  area?: boolean;
  className?: string;
};

/** A small trend line that draws itself once, when it first comes into view. */
export function Sparkline({ values, label, width = 96, height = 32, color = "var(--raysto-chart-1)", area = true, className }: SparklineProps) {
  const reduce = useReduce();
  const ref = useRef<SVGSVGElement>(null);
  const seen = useInView(ref, { once: true, amount: 0.5 });
  const id = safeId(useId());
  const pts = useMemo(() => project(values, width, height, undefined, 2), [values, width, height]);
  const line = linePath(pts);
  const fill = area ? areaPath(pts, height - 2) : "";
  const go = reduce || seen;
  return (
    <svg
      ref={ref}
      className={["m3-spark", className].filter(Boolean).join(" ")}
      viewBox={`0 0 ${width} ${height}`}
      width={width}
      height={height}
      role="img"
      aria-label={label}
    >
      {area && (
        <defs>
          <linearGradient id={`${id}g`} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="var(--raysto-chart-fill)" stopOpacity="0.85" />
            <stop offset="1" stopColor="var(--raysto-chart-fill)" stopOpacity="0" />
          </linearGradient>
          <clipPath id={`${id}c`}>
            {reduce ? (
              <rect x="0" y="0" width={width} height={height} />
            ) : (
              <m.rect x="0" y="0" height={height} initial={{ width: 0 }} animate={{ width: go ? width : 0 }} transition={draw} />
            )}
          </clipPath>
        </defs>
      )}
      {area && <path d={fill} fill={`url(#${id}g)`} clipPath={`url(#${id}c)`} />}
      {reduce ? (
        <path d={line} fill="none" stroke={color} strokeWidth={1.75} strokeLinecap="round" strokeLinejoin="round" />
      ) : (
        <m.path
          d={line}
          fill="none"
          stroke={color}
          strokeWidth={1.75}
          strokeLinecap="round"
          strokeLinejoin="round"
          initial={{ pathLength: 0 }}
          animate={{ pathLength: go ? 1 : 0 }}
          transition={draw}
        />
      )}
    </svg>
  );
}

/* ---------- Area chart ---------- */

export type ChartPoint = { label: string; value: number };

export type AreaChartProps = {
  /** The real series, oldest first. */
  points: readonly ChartPoint[];
  /** How a value reads in the tooltip and the data table. */
  format: (n: number) => string;
  /** How a value reads on the axis (shorter); defaults to `format`. */
  axisFormat?: (n: number) => string;
  /** A clearly labelled sample history, drawn as a dashed outline behind the real line. */
  sample?: { label: string; values: readonly number[] } | null;
  /** Names the chart for assistive technology and the data table. */
  title: string;
  /** Name of the real series, e.g. "Paid sales". */
  seriesLabel?: string;
  height?: number;
  className?: string;
};

const PAD = { top: 14, right: 12, bottom: 28, left: 52 };

/**
 * The main trend chart. The line draws left to right and the lime fill
 * follows it; hovering, or the arrow keys once focused, read each point. A
 * sample series, when given, is dashed, never filled, and labelled
 * "Sample · not real sales" in the legend, which is always visible.
 */
export function AreaChart({ points, format, axisFormat, sample, title, seriesLabel = "Paid sales", height = 240, className }: AreaChartProps) {
  const reduce = useReduce();
  const wrap = useRef<HTMLDivElement>(null);
  const seen = useInView(wrap, { once: true, amount: 0.3 });
  const [width, setWidth] = useState(640);
  const [active, setActive] = useState<number | null>(null);
  const id = safeId(useId());

  useEffect(() => {
    const el = wrap.current;
    if (!el || typeof ResizeObserver === "undefined") return;
    const ro = new ResizeObserver(([entry]) => {
      const w = Math.round(entry.contentRect.width);
      if (w > 0) setWidth(w);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  const values = points.map((p) => p.value);
  const sampleValues = sample?.values ?? [];
  const max = niceMax(Math.max(0, ...values, ...sampleValues));
  const innerW = Math.max(40, width - PAD.left - PAD.right);
  const innerH = Math.max(40, height - PAD.top - PAD.bottom);
  const place = (vs: readonly number[]) =>
    project(vs, innerW, innerH, max).map(([x, y]) => [x + PAD.left, y + PAD.top] as const);
  const pts = place(values);
  const samplePts = sample && sampleValues.length === values.length ? place(sampleValues) : [];
  const baseline = PAD.top + innerH;
  const line = linePath(pts);
  const fill = areaPath(pts, baseline);
  const showLabel = labelEvery(points.length, Math.max(2, Math.floor(innerW / 64)));
  const axis = axisFormat ?? format;
  const go = reduce || seen;

  const nearest = (clientX: number) => {
    const box = wrap.current?.getBoundingClientRect();
    if (!box || pts.length === 0) return null;
    const x = clientX - box.left;
    let best = 0;
    for (let i = 1; i < pts.length; i++) if (Math.abs(pts[i][0] - x) < Math.abs(pts[best][0] - x)) best = i;
    return best;
  };
  const onMove = (e: PointerEvent) => setActive(nearest(e.clientX));
  const onKey = (e: KeyboardEvent) => {
    if (pts.length === 0) return;
    const last = pts.length - 1;
    const at = active ?? last;
    const next =
      e.key === "ArrowRight" ? Math.min(last, at + 1) :
      e.key === "ArrowLeft" ? Math.max(0, at - 1) :
      e.key === "Home" ? 0 :
      e.key === "End" ? last :
      e.key === "Escape" ? null : undefined;
    if (next === undefined) return;
    e.preventDefault();
    setActive(next);
  };
  const tip = active === null || !points[active] ? null : {
    x: pts[active][0],
    y: pts[active][1],
    label: points[active].label,
    value: format(points[active].value),
    sample: samplePts.length ? format(sampleValues[active]) : null,
  };
  const tipText = tip ? `${tip.label}: ${seriesLabel} ${tip.value}${tip.sample ? `; sample, not real sales, ${tip.sample}` : ""}` : "";

  return (
    <figure className={["m3-area", className].filter(Boolean).join(" ")}>
      <div className="m3-legend" aria-hidden="true">
        <span className="m3-legend-item">
          <i className="m3-swatch solid" />
          {seriesLabel}
        </span>
        {sample && (
          <span className="m3-legend-item m3-sample-chip">
            <i className="m3-swatch dashed" />
            Sample · not real sales
          </span>
        )}
      </div>
      <div
        ref={wrap}
        className="m3-area-plot"
        role="group"
        tabIndex={0}
        aria-label={`${title}. Use the left and right arrow keys to read each point.`}
        onPointerMove={onMove}
        onPointerLeave={() => setActive(null)}
        onKeyDown={onKey}
        onFocus={() => setActive((a) => a ?? (pts.length ? pts.length - 1 : null))}
        onBlur={() => setActive(null)}
      >
        <svg viewBox={`0 0 ${width} ${height}`} width={width} height={height} aria-hidden="true">
          <defs>
            <linearGradient id={`${id}g`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0" stopColor="var(--raysto-chart-fill)" stopOpacity="0.9" />
              <stop offset="1" stopColor="var(--raysto-chart-fill)" stopOpacity="0.05" />
            </linearGradient>
            <clipPath id={`${id}c`}>
              {reduce ? (
                <rect x={PAD.left} y="0" width={innerW} height={height} />
              ) : (
                <m.rect x={PAD.left} y="0" height={height} initial={{ width: 0 }} animate={{ width: go ? innerW : 0 }} transition={draw} />
              )}
            </clipPath>
          </defs>
          {ticks(max).map((t) => {
            const y = PAD.top + innerH - (t / max) * innerH;
            return (
              <g key={t} className="m3-grid">
                <line x1={PAD.left} x2={PAD.left + innerW} y1={y} y2={y} />
                <text x={PAD.left - 8} y={y} dy="0.32em" textAnchor="end">
                  {axis(t)}
                </text>
              </g>
            );
          })}
          {points.map((p, i) =>
            showLabel(i) ? (
              <text key={i} className="m3-axis-x" x={pts[i][0]} y={height - 8} textAnchor="middle">
                {p.label}
              </text>
            ) : null,
          )}
          {samplePts.length > 0 && <path className="m3-sample-line" d={linePath(samplePts)} fill="none" />}
          <path d={fill} fill={`url(#${id}g)`} clipPath={`url(#${id}c)`} />
          {reduce ? (
            <path className="m3-area-line" d={line} fill="none" />
          ) : (
            <m.path
              key={points.length}
              className="m3-area-line"
              fill="none"
              initial={{ pathLength: 0, d: line }}
              animate={{ pathLength: go ? 1 : 0, d: line }}
              transition={draw}
            />
          )}
          {tip && (
            <g className="m3-tip-mark">
              <line x1={tip.x} x2={tip.x} y1={PAD.top} y2={baseline} />
              <circle cx={tip.x} cy={tip.y} r={5} />
            </g>
          )}
        </svg>
        {tip && (
          <div
            className="m3-tooltip"
            aria-hidden="true"
            style={{ left: Math.min(Math.max(tip.x, 70), width - 70), top: Math.max(tip.y - 12, 0) }}
          >
            <strong>{tip.label}</strong>
            <span>
              {seriesLabel}: {tip.value}
            </span>
            {tip.sample && <span className="m3-tooltip-sample">Sample · not real sales: {tip.sample}</span>}
          </div>
        )}
        <span className="m3-sr" aria-live="polite">
          {tipText}
        </span>
      </div>
      <table className="m3-sr">
        <caption>{title}</caption>
        <thead>
          <tr>
            <th scope="col">Period</th>
            <th scope="col">{seriesLabel}</th>
            {sample && <th scope="col">Sample, not real sales</th>}
          </tr>
        </thead>
        <tbody>
          {points.map((p, i) => (
            <tr key={i}>
              <th scope="row">{p.label}</th>
              <td>{format(p.value)}</td>
              {sample && <td>{sampleValues[i] === undefined ? "" : format(sampleValues[i])}</td>}
            </tr>
          ))}
        </tbody>
      </table>
    </figure>
  );
}

/* ---------- Donut ---------- */

export type DonutSegment = { label: string; value: number; display: string; color?: string };

export type DonutProps = {
  segments: readonly DonutSegment[];
  /** Names the chart, e.g. "Sales by channel". */
  title: string;
  size?: number;
  thickness?: number;
  /** What sits in the hole, e.g. the total. */
  center?: ReactNode;
  /** Show the labelled legend beside it (the accessible version of the chart). */
  legend?: boolean;
  className?: string;
};

const palette = ["var(--raysto-chart-1)", "var(--raysto-chart-2)", "var(--raysto-chart-3)", "var(--raysto-chart-4)", "var(--raysto-chart-5)"];

/** Shares of a whole; the segments sweep in one after another. The legend carries the numbers. */
export function Donut({ segments, title, size = 168, thickness = 18, center, legend = true, className }: DonutProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLDivElement>(null);
  const seen = useInView(ref, { once: true, amount: 0.4 });
  const r = (size - thickness) / 2;
  const c = size / 2;
  const segs = donutSegments(segments.map((s) => s.value));
  const total = segments.reduce((n, s) => n + Math.max(0, s.value), 0);
  const go = reduce || seen;
  return (
    <figure className={["m3-donut", className].filter(Boolean).join(" ")} role="group" aria-label={title}>
      <div ref={ref} className="m3-donut-ring" style={{ width: size, height: size }}>
        <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size} aria-hidden="true">
          <circle cx={c} cy={c} r={r} fill="none" className="m3-track" strokeWidth={thickness} />
          {segs.map((s, i) => {
            const color = segments[s.index].color ?? palette[s.index % palette.length];
            const d = s.end - s.start >= 0.9999 ? undefined : arcPath(c, c, r, s.start, s.end);
            if (!d) {
              return <circle key={s.index} cx={c} cy={c} r={r} fill="none" stroke={color} strokeWidth={thickness} />;
            }
            return reduce ? (
              <path key={s.index} d={d} fill="none" stroke={color} strokeWidth={thickness} />
            ) : (
              <m.path
                key={s.index}
                d={d}
                fill="none"
                stroke={color}
                strokeWidth={thickness}
                initial={{ pathLength: 0 }}
                animate={{ pathLength: go ? 1 : 0 }}
                transition={{ duration: duration.long2, ease: easing.emphasizedDecelerate, delay: stagger(i) }}
              />
            );
          })}
        </svg>
        {center && <div className="m3-donut-center">{center}</div>}
      </div>
      <ul className={legend ? "m3-legend-list" : "m3-sr"}>
        {segments.map((s, i) => (
          <li key={s.label}>
            <i className="m3-swatch" style={{ background: s.color ?? palette[i % palette.length] }} aria-hidden="true" />
            <span className="m3-legend-label">{s.label}</span>
            <span className="m3-legend-value">{s.display}</span>
            <span className="m3-legend-share">{total > 0 ? `${Math.round((Math.max(0, s.value) / total) * 100)}%` : "0%"}</span>
          </li>
        ))}
      </ul>
    </figure>
  );
}

/* ---------- Ring ---------- */

export type RingProps = {
  value: number;
  /** The target; 0 or less means there is none and the ring stays empty. */
  max: number;
  /** What is measured, e.g. "Today's sales against the daily target". */
  label: string;
  /** How the progress reads, e.g. "$21.50 of $300". Defaults to a percentage. */
  valueText?: string;
  size?: number;
  thickness?: number;
  children?: ReactNode;
  className?: string;
};

/** Progress toward a real target, filling once on reveal; past the target it stays full and says so. */
export function Ring({ value, max, label, valueText, size = 132, thickness = 12, children, className }: RingProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLDivElement>(null);
  const seen = useInView(ref, { once: true, amount: 0.5 });
  const { fraction, over } = progress(value, max);
  const r = (size - thickness) / 2;
  const c = size / 2;
  const text = `${label}: ${valueText ?? `${Math.round(fraction * 100)}%`}${over ? ", target passed" : ""}`;
  return (
    <div ref={ref} className={["m3-ring", over && "over", className].filter(Boolean).join(" ")} style={{ width: size, height: size }} role="img" aria-label={text}>
      <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size} aria-hidden="true" style={{ transform: "rotate(-90deg)" }}>
        <circle cx={c} cy={c} r={r} fill="none" className="m3-track" strokeWidth={thickness} />
        {fraction > 0 &&
          (reduce ? (
            <circle cx={c} cy={c} r={r} fill="none" className="m3-ring-value" strokeWidth={thickness} strokeLinecap="round" pathLength={1} strokeDasharray={`${fraction} 1`} />
          ) : (
            <m.circle
              cx={c}
              cy={c}
              r={r}
              fill="none"
              className="m3-ring-value"
              strokeWidth={thickness}
              strokeLinecap="round"
              initial={{ pathLength: 0 }}
              animate={{ pathLength: reduce || seen ? fraction : 0 }}
              transition={{ duration: duration.long4, ease: easing.emphasizedDecelerate }}
            />
          ))}
      </svg>
      {children && <div className="m3-ring-center" aria-hidden="true">{children}</div>}
    </div>
  );
}

/* ---------- Bar rows ---------- */

export type BarRowItem = { label: string; value: number; display: string; color?: string; note?: string };

export type BarRowProps = {
  rows: readonly BarRowItem[];
  /** Names the list, e.g. "Staff this week". */
  title: string;
  /** The value of a full bar; defaults to the largest row. */
  max?: number;
  className?: string;
};

/** Labelled horizontal bars; each grows from the start once in view. The numbers are text. */
export function BarRow({ rows, title, max, className }: BarRowProps) {
  const reduce = useReduce();
  const ref = useRef<HTMLUListElement>(null);
  const seen = useInView(ref, { once: true, amount: 0.3 });
  const top = max ?? Math.max(0, ...rows.map((r) => r.value));
  return (
    <ul ref={ref} className={["m3-bars", className].filter(Boolean).join(" ")} aria-label={title}>
      {rows.map((r, i) => {
        const f = top > 0 ? Math.min(1, Math.max(0, r.value) / top) : 0;
        const style = { width: `${f * 100}%`, background: r.color ?? "var(--raysto-chart-1)" };
        return (
          <li key={`${r.label}-${i}`}>
            <span className="m3-bars-label">
              {r.label}
              {r.note && <small>{r.note}</small>}
            </span>
            <span className="m3-bars-track" aria-hidden="true">
              {reduce ? (
                <span className="m3-bars-fill" style={style} />
              ) : (
                <m.span
                  className="m3-bars-fill"
                  style={{ ...style, transformOrigin: "left center" }}
                  initial={{ scaleX: 0 }}
                  animate={{ scaleX: seen ? 1 : 0 }}
                  transition={{ duration: duration.long2, ease: easing.emphasizedDecelerate, delay: stagger(i) }}
                />
              )}
            </span>
            <span className="m3-bars-value">{r.display}</span>
          </li>
        );
      })}
    </ul>
  );
}
