// Motion kit for RaystoPromo60: timing helpers, camera moves, device frames,
// labels and the zoom-through scene wrapper. Every animation is driven by the
// frame number (no CSS transitions), so renders are deterministic.
import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFont } from "@remotion/fonts";

for (const [file, weight] of [
  ["PlusJakartaSans-Regular.ttf", "400"],
  ["PlusJakartaSans-Medium.ttf", "500"],
  ["PlusJakartaSans-Bold.ttf", "700"],
] as const) {
  loadFont({ family: "Jakarta", url: staticFile(`fonts/${file}`), weight });
}
loadFont({
  family: "Editorial",
  url: staticFile("fonts/CormorantGaramond.ttf"),
  weight: "300 700",
});

export const C = {
  paper: "#F5F2E8",
  cream: "#FFFDF7",
  forest: "#23493C",
  ink: "#10261F",
  lime: "#D9EE96",
  limeHot: "#C8EE5A",
  muted: "#6D7A6F",
  paypal: "#003087",
  paypalSky: "#0070E0",
};
export const SANS = "Jakarta, sans-serif";
export const SERIF = "Editorial, serif";

const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
export const OUT = Easing.bezier(0.16, 1, 0.3, 1);
export const IN_OUT = Easing.bezier(0.65, 0, 0.35, 1);

/** Eased value from x to y between frames a and b. */
export const tween = (
  f: number,
  a: number,
  b: number,
  x = 0,
  y = 1,
  easing = OUT,
) => interpolate(f, [a, b], [x, y], { ...clamp, easing });

/** A springy 0→1 starting at frame `at`. */
export const usePop = (at: number, damping = 14) => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();
  return spring({ frame: f - at, fps, config: { damping, stiffness: 170, mass: 0.7 } });
};

export type Key = [frame: number, scale: number, x: number, y: number];

/**
 * A camera over its children: keyframes of scale and the point (in px from
 * the frame centre) brought to the middle of the screen, eased in and out.
 */
export const Camera: React.FC<{ keys: Key[]; children: React.ReactNode }> = ({
  keys,
  children,
}) => {
  const f = useCurrentFrame();
  let [s, x, y] = [keys[0][1], keys[0][2], keys[0][3]];
  for (let i = 0; i < keys.length - 1; i++) {
    const [a, s0, x0, y0] = keys[i];
    const [b, s1, x1, y1] = keys[i + 1];
    if (f >= a) {
      const p = tween(f, a, b, 0, 1, IN_OUT);
      [s, x, y] = [s0 + (s1 - s0) * p, x0 + (x1 - x0) * p, y0 + (y1 - y0) * p];
    }
  }
  return (
    <AbsoluteFill
      style={{ transform: `scale(${s}) translate(${-x}px, ${-y}px)`, transformOrigin: "50% 50%" }}
    >
      {children}
    </AbsoluteFill>
  );
};

/** Zoom-through entrance and exit, so scenes overlap into each other. */
export const Shot: React.FC<{
  duration: number;
  children: React.ReactNode;
  enter?: number;
  exit?: number;
}> = ({ duration, children, enter = 14, exit = 12 }) => {
  const f = useCurrentFrame();
  const i = enter ? tween(f, 0, enter) : 1;
  const o = exit ? tween(f, duration - exit, duration, 0, 1, Easing.in(Easing.cubic)) : 0;
  return (
    <AbsoluteFill
      style={{
        opacity: i * (1 - o),
        transform: `scale(${(1.1 - 0.1 * i) * (1 + 0.12 * o)})`,
        filter: `blur(${(1 - i) * 14 + o * 16}px)`,
      }}
    >
      {children}
    </AbsoluteFill>
  );
};

/** Soft paper backdrop with slowly drifting colour fields. */
export const Backdrop: React.FC<{ warm?: number }> = ({ warm = 0 }) => {
  const f = useCurrentFrame();
  const a = Math.sin(f / 70) * 120;
  const b = Math.cos(f / 90) * 140;
  return (
    <AbsoluteFill style={{ background: C.paper, overflow: "hidden" }}>
      <div
        style={{
          position: "absolute",
          width: 1300,
          height: 1300,
          left: -380 + a,
          top: -520 + b * 0.4,
          borderRadius: "50%",
          background: `radial-gradient(circle, ${C.lime}${warm ? "d0" : "90"} 0%, transparent 62%)`,
        }}
      />
      <div
        style={{
          position: "absolute",
          width: 1400,
          height: 1400,
          right: -520 - b,
          bottom: -760 + a * 0.5,
          borderRadius: "50%",
          background: `radial-gradient(circle, ${C.forest}26 0%, transparent 60%)`,
        }}
      />
      <svg width="1920" height="1080" style={{ position: "absolute", opacity: 0.18 }}>
        <defs>
          <pattern id="dots" width="36" height="36" patternUnits="userSpaceOnUse">
            <circle cx="2" cy="2" r="1.6" fill={C.forest} />
          </pattern>
        </defs>
        <rect width="1920" height="1080" fill="url(#dots)" />
      </svg>
    </AbsoluteFill>
  );
};

const shadow = "0 50px 90px rgba(16,38,31,0.28), 0 12px 24px rgba(16,38,31,0.18)";

/** A tablet in landscape with a 16:10 screen. */
export const Tablet: React.FC<{ width: number; children: React.ReactNode; style?: React.CSSProperties }> = ({
  width,
  children,
  style,
}) => {
  const bezel = width * 0.016;
  return (
    <div
      style={{
        width,
        height: (width - 2 * bezel) * 0.625 + 2 * bezel,
        padding: bezel,
        borderRadius: width * 0.035,
        background: "linear-gradient(145deg, #2a3933, #0c1512)",
        boxShadow: shadow,
        ...style,
      }}
    >
      <div style={{ width: "100%", height: "100%", borderRadius: width * 0.02, overflow: "hidden", position: "relative", background: C.paper }}>
        {children}
      </div>
    </div>
  );
};

/** A phone in portrait with a 9:19.5 screen and a camera island. */
export const Phone: React.FC<{ width: number; children: React.ReactNode; style?: React.CSSProperties }> = ({
  width,
  children,
  style,
}) => {
  const bezel = width * 0.035;
  return (
    <div
      style={{
        width,
        height: (width - 2 * bezel) * 2.1 + 2 * bezel,
        padding: bezel,
        borderRadius: width * 0.16,
        background: "linear-gradient(160deg, #2d3b35, #0b1411)",
        boxShadow: shadow,
        position: "relative",
        ...style,
      }}
    >
      <div style={{ width: "100%", height: "100%", borderRadius: width * 0.13, overflow: "hidden", position: "relative", background: C.paper }}>
        {children}
      </div>
      <div
        style={{
          position: "absolute",
          top: bezel + width * 0.03,
          left: "50%",
          width: width * 0.26,
          height: width * 0.07,
          marginLeft: -width * 0.13,
          borderRadius: 99,
          background: "#0b1411",
        }}
      />
    </div>
  );
};

/** A browser window with the console address. */
export const Browser: React.FC<{ width: number; url: string; children: React.ReactNode; style?: React.CSSProperties }> = ({
  width,
  url,
  children,
  style,
}) => (
  <div style={{ width, borderRadius: 22, overflow: "hidden", background: C.cream, boxShadow: shadow, ...style }}>
    <div style={{ height: 58, display: "flex", alignItems: "center", gap: 10, padding: "0 22px", background: "#E9E5D8" }}>
      {["#E36B5D", "#E9B949", "#78B567"].map((c) => (
        <div key={c} style={{ width: 15, height: 15, borderRadius: 99, background: c }} />
      ))}
      <div
        style={{
          marginLeft: 26,
          padding: "8px 22px",
          borderRadius: 99,
          background: C.cream,
          fontFamily: SANS,
          fontSize: 20,
          color: C.forest,
        }}
      >
        🔒 {url}
      </div>
    </div>
    <div style={{ width: "100%", height: width * 0.5625, position: "relative", overflow: "hidden" }}>{children}</div>
  </div>
);

/** A label that pops in at frame `at`; `tone` picks the colour set. */
export const Chip: React.FC<{
  at: number;
  children: React.ReactNode;
  tone?: "forest" | "lime" | "paypal" | "cream";
  size?: number;
  style?: React.CSSProperties;
  until?: number;
}> = ({ at, children, tone = "forest", size = 30, style, until }) => {
  const f = useCurrentFrame();
  const p = usePop(at);
  const gone = until === undefined ? 0 : tween(f, until, until + 10, 0, 1, Easing.in(Easing.cubic));
  const colours = {
    forest: [C.forest, C.cream],
    lime: [C.lime, C.ink],
    paypal: [C.paypal, "#FFFFFF"],
    cream: [C.cream, C.forest],
  }[tone];
  return (
    <div
      style={{
        position: "absolute",
        padding: `${size * 0.45}px ${size * 0.85}px`,
        borderRadius: 999,
        background: colours[0],
        color: colours[1],
        fontFamily: SANS,
        fontWeight: 700,
        fontSize: size,
        letterSpacing: -0.3,
        whiteSpace: "nowrap",
        boxShadow: "0 14px 30px rgba(16,38,31,0.22)",
        opacity: Math.min(1, p * 1.4) * (1 - gone),
        transform: `translateY(${(1 - p) * 26 - gone * 16}px) scale(${0.7 + 0.3 * p})`,
        ...style,
      }}
    >
      {children}
    </div>
  );
};

/** Words that rise into place one after another. */
export const Words: React.FC<{
  text: string;
  at: number;
  size: number;
  color?: string;
  font?: string;
  weight?: number;
  italic?: boolean;
  stagger?: number;
  style?: React.CSSProperties;
}> = ({ text, at, size, color = C.forest, font = SANS, weight = 700, italic, stagger = 4, style }) => {
  const f = useCurrentFrame();
  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: `0 ${size * 0.26}px`, ...style }}>
      {text.split(" ").map((w, i) => {
        const p = tween(f, at + i * stagger, at + i * stagger + 18);
        return (
          <span key={i} style={{ display: "inline-block", overflow: "hidden", paddingBottom: size * 0.12 }}>
            <span
              style={{
                display: "inline-block",
                fontFamily: font,
                fontWeight: weight,
                fontStyle: italic ? "italic" : "normal",
                fontSize: size,
                lineHeight: 1.02,
                letterSpacing: font === SANS ? -size * 0.035 : 0,
                color,
                transform: `translateY(${(1 - p) * 110}%)`,
                opacity: p,
              }}
            >
              {w}
            </span>
          </span>
        );
      })}
    </div>
  );
};

/** A rounded highlight box whose outline draws itself. */
export const Highlight: React.FC<{ at: number; x: number; y: number; w: number; h: number }> = ({ at, x, y, w, h }) => {
  const f = useCurrentFrame();
  const p = tween(f, at, at + 22);
  const len = 2 * (w + h);
  return (
    <svg style={{ position: "absolute", left: x - 8, top: y - 8, overflow: "visible" }} width={w + 16} height={h + 16}>
      <rect
        x={4}
        y={4}
        width={w + 8}
        height={h + 8}
        rx={18}
        fill={`${C.limeHot}${Math.round(p * 55).toString(16).padStart(2, "0")}`}
        stroke={C.limeHot}
        strokeWidth={7}
        strokeDasharray={len}
        strokeDashoffset={len * (1 - p)}
      />
    </svg>
  );
};
