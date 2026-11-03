/**
 * Pure maths for the m3 charts and number displays: no React, so it is unit
 * tested directly (web/tests/motion.test.ts).
 */

export type Pt = readonly [number, number];

/** A tidy top for a value axis: 1, 2, 2.5 or 5 times a power of ten, at least `v`. */
export function niceMax(v: number): number {
  if (!Number.isFinite(v) || v <= 0) return 1;
  const power = 10 ** Math.floor(Math.log10(v));
  for (const step of [1, 2, 2.5, 5, 10]) {
    if (step * power >= v) return step * power;
  }
  return 10 * power;
}

/** Evenly spaced tick values from 0 to `max` (inclusive). */
export function ticks(max: number, count = 4): number[] {
  const top = niceMax(max);
  return Array.from({ length: count + 1 }, (_, i) => (top / count) * i);
}

/**
 * Points for `values` inside a `width` × `height` box with `pad` around it.
 * The top of the scale is `max` (default: the nice top of the data), so the
 * same scale can be shared by a real series and a sample series.
 */
export function project(values: readonly number[], width: number, height: number, max?: number, pad = 0): Pt[] {
  const top = max ?? niceMax(Math.max(0, ...values));
  const n = values.length;
  const innerW = Math.max(0, width - pad * 2);
  const innerH = Math.max(0, height - pad * 2);
  return values.map((v, i) => {
    const x = pad + (n <= 1 ? innerW / 2 : (innerW * i) / (n - 1));
    const y = pad + innerH - (Math.max(0, v) / top) * innerH;
    return [round(x), round(y)] as const;
  });
}

const round = (n: number) => Math.round(n * 100) / 100;

/**
 * A smooth line through the points that never overshoots: monotone cubic
 * interpolation (Fritsch–Carlson), so a curve never dips below zero or
 * invents a peak the data does not have.
 */
export function linePath(points: readonly Pt[]): string {
  const n = points.length;
  if (n === 0) return "";
  if (n === 1) return `M${points[0][0]},${points[0][1]}`;
  if (n === 2) return `M${points[0][0]},${points[0][1]}L${points[1][0]},${points[1][1]}`;
  const dx: number[] = [];
  const slope: number[] = [];
  for (let i = 0; i < n - 1; i++) {
    dx[i] = points[i + 1][0] - points[i][0];
    slope[i] = dx[i] === 0 ? 0 : (points[i + 1][1] - points[i][1]) / dx[i];
  }
  const m: number[] = [slope[0]];
  for (let i = 1; i < n - 1; i++) {
    m[i] = slope[i - 1] * slope[i] <= 0 ? 0 : (slope[i - 1] + slope[i]) / 2;
  }
  m[n - 1] = slope[n - 2];
  for (let i = 0; i < n - 1; i++) {
    if (slope[i] === 0) {
      m[i] = 0;
      m[i + 1] = 0;
      continue;
    }
    const a = m[i] / slope[i];
    const b = m[i + 1] / slope[i];
    const s = a * a + b * b;
    if (s > 9) {
      const t = 3 / Math.sqrt(s);
      m[i] = t * a * slope[i];
      m[i + 1] = t * b * slope[i];
    }
  }
  let d = `M${points[0][0]},${points[0][1]}`;
  for (let i = 0; i < n - 1; i++) {
    const [x0, y0] = points[i];
    const [x1, y1] = points[i + 1];
    const h = dx[i] / 3;
    d += `C${round(x0 + h)},${round(y0 + m[i] * h)} ${round(x1 - h)},${round(y1 - m[i + 1] * h)} ${x1},${y1}`;
  }
  return d;
}

/** The line closed down to the baseline, for the area fill. */
export function areaPath(points: readonly Pt[], baseline: number): string {
  if (points.length === 0) return "";
  const line = linePath(points);
  const first = points[0];
  const last = points[points.length - 1];
  return `${line}L${last[0]},${baseline}L${first[0]},${baseline}Z`;
}

/** A circular arc from `start` to `end` (fractions of a turn, 0 at 12 o'clock, clockwise). */
export function arcPath(cx: number, cy: number, r: number, start: number, end: number): string {
  const span = Math.min(Math.max(end - start, 0), 0.9999);
  const a0 = start * 2 * Math.PI - Math.PI / 2;
  const a1 = (start + span) * 2 * Math.PI - Math.PI / 2;
  const x0 = round(cx + r * Math.cos(a0));
  const y0 = round(cy + r * Math.sin(a0));
  const x1 = round(cx + r * Math.cos(a1));
  const y1 = round(cy + r * Math.sin(a1));
  const large = span > 0.5 ? 1 : 0;
  return `M${x0},${y0}A${r},${r} 0 ${large} 1 ${x1},${y1}`;
}

/**
 * Donut segments as fractions of a turn, with a small gap between them.
 * Zero and negative values are left out; one segment fills the whole ring.
 */
export function donutSegments(values: readonly number[], gap = 0.012): { start: number; end: number; share: number; index: number }[] {
  const kept = values.map((v, index) => ({ v: Math.max(0, v), index })).filter((s) => s.v > 0);
  const total = kept.reduce((n, s) => n + s.v, 0);
  if (total <= 0) return [];
  if (kept.length === 1) return [{ start: 0, end: 1, share: 1, index: kept[0].index }];
  let at = 0;
  return kept.map((s) => {
    const share = s.v / total;
    const seg = { start: at + gap / 2, end: at + share - gap / 2, share, index: s.index };
    at += share;
    return seg;
  });
}

/** Progress toward a target, 0 to 1; `over` when the target is passed. */
export function progress(value: number, target: number): { fraction: number; over: boolean } {
  if (!Number.isFinite(target) || target <= 0) return { fraction: 0, over: false };
  const f = Math.max(0, value) / target;
  return { fraction: Math.min(f, 1), over: f > 1 };
}

/** Change against the previous period as a fraction, or null when there was nothing before. */
export function delta(value: number, previous: number): number | null {
  if (!Number.isFinite(previous) || previous === 0) return null;
  return (value - previous) / Math.abs(previous);
}

/** "+12%", "−8%", "0%", or "new" when nothing came before but something now. */
export function deltaLabel(value: number, previous: number): string {
  const d = delta(value, previous);
  if (d === null) return value > 0 ? "new" : "0%";
  const pct = Math.round(d * 100);
  if (pct === 0) return "0%";
  return `${pct > 0 ? "+" : "−"}${Math.abs(pct)}%`;
}

/** Money from minor units, e.g. 19530 → "$195.30". */
export function formatMoney(minor: number, currency = "USD", locale = "en-US"): string {
  return new Intl.NumberFormat(locale, { style: "currency", currency }).format(minor / 100);
}

/** Short money for axes and tight cards, e.g. 1953000 → "$19.5K". */
export function formatMoneyShort(minor: number, currency = "USD", locale = "en-US"): string {
  const major = minor / 100;
  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency,
    notation: Math.abs(major) >= 10000 ? "compact" : "standard",
    maximumFractionDigits: Math.abs(major) >= 10000 ? 1 : 0,
  }).format(major);
}

export function formatCount(n: number, locale = "en-US"): string {
  return new Intl.NumberFormat(locale).format(Math.round(n));
}

/**
 * The value a count-up shows at time `t` (0 to 1, already eased) on its way
 * from `from` to `to`, rounded to whole units so money never shows fractions
 * of a cent. It reaches `to` exactly at t = 1 and never passes it.
 */
export function countAt(from: number, to: number, t: number): number {
  if (t >= 1) return to;
  if (t <= 0) return from;
  const v = from + (to - from) * t;
  return to >= from ? Math.min(Math.round(v), to) : Math.max(Math.round(v), to);
}

/** Which labels to print on an x axis of `n` points so at most `max` show, always keeping the last. */
export function labelEvery(n: number, max: number): (i: number) => boolean {
  if (n <= max) return () => true;
  const step = Math.ceil(n / max);
  return (i) => i === n - 1 || (i % step === 0 && n - 1 - i >= step / 2);
}
