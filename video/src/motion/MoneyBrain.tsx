/**
 * "The money brain": a 15-second motion test for the AI-with-PayPal story.
 *
 * Café -> three AI coworkers prepare work -> the owner approves with an
 * identity check -> PayPal pays the people who take PayPal. It ends on the
 * real PayPal Sandbox records from docs/facts.json.
 *
 * Honesty: this is a diagram. It shows no amounts, and every id on screen
 * is a real Sandbox id. Every animation is a pure function of the frame
 * (no timers, no randomness), so parallel rendering cannot flicker.
 */
import React from "react";
import {
  AbsoluteFill,
  Composition,
  Easing,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFont } from "@remotion/fonts";

loadFont({ family: "Jakarta", url: staticFile("fonts/PlusJakartaSans-Regular.ttf"), weight: "400" });
loadFont({ family: "Jakarta", url: staticFile("fonts/PlusJakartaSans-Medium.ttf"), weight: "500" });
loadFont({ family: "Jakarta", url: staticFile("fonts/PlusJakartaSans-Bold.ttf"), weight: "700" });

// Raysto's tokens (docs/design-tokens.json), darkened for a cinematic canvas.
const C = {
  bg: "#06120e",
  bg2: "#0d2a21",
  card: "#0f241e",
  line: "rgba(215, 249, 120, 0.22)",
  lime: "#d7f978",
  mint: "#8fd9b6",
  text: "#f6f7f2",
  muted: "#9fb3a8",
  paypal: "#2f8cff",
  paypalDeep: "#0b4fb3",
};

const ease = Easing.bezier(0.16, 1, 0.3, 1);
const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

// Real ids from docs/facts.json (PayPal Sandbox).
const IDS = [
  "633829727B675370M",
  "EUG58M87BKY5E",
  "4C048952Y13801205",
  "2J851836BE9699524",
  "4KZDS8M7DDWTL",
  "4MG67343RS1841023",
  "8MM65248WS403211T",
  "N48TL9D5X6PLG",
  "47E23175WJ603464A",
  "ZFW54957PSL9C",
  "1FC985713C934991E",
  "TMS8FKRT6ALYU",
  "20K31884958788526",
];

type Pt = { x: number; y: number };
const P = {
  cafe: { x: 245, y: 560 },
  accountant: { x: 625, y: 330 },
  dispatcher: { x: 625, y: 560 },
  planner: { x: 625, y: 790 },
  owner: { x: 1000, y: 560 },
  paypal: { x: 1335, y: 560 },
  provider: { x: 1695, y: 330 },
  driver: { x: 1695, y: 560 },
  supplier: { x: 1695, y: 790 },
} satisfies Record<string, Pt>;

// A horizontal S-curve between two points, and the point at t along it.
const controls = (a: Pt, b: Pt) => {
  const dx = (b.x - a.x) * 0.5;
  return [a, { x: a.x + dx, y: a.y }, { x: b.x - dx, y: b.y }, b] as const;
};
const pathOf = (a: Pt, b: Pt) => {
  const [p0, p1, p2, p3] = controls(a, b);
  return `M ${p0.x} ${p0.y} C ${p1.x} ${p1.y}, ${p2.x} ${p2.y}, ${p3.x} ${p3.y}`;
};
const pointAt = (a: Pt, b: Pt, t: number): Pt => {
  const [p0, p1, p2, p3] = controls(a, b);
  const u = 1 - t;
  const w = [u * u * u, 3 * u * u * t, 3 * u * t * t, t * t * t];
  return {
    x: w[0] * p0.x + w[1] * p1.x + w[2] * p2.x + w[3] * p3.x,
    y: w[0] * p0.y + w[1] * p1.y + w[2] * p2.y + w[3] * p3.y,
  };
};

// ---- Icons (24-unit Material-style glyphs) ----------------------------------
const icons: Record<string, string> = {
  store: "M4 4h16l1 5a3 3 0 0 1-5 2 3 3 0 0 1-4 0 3 3 0 0 1-4 0 3 3 0 0 1-5-2l1-5Zm1 9h14v7H5v-7Zm5 2v5h4v-5h-4Z",
  receipt: "M6 2h12v20l-3-2-3 2-3-2-3 2V2Zm3 5v2h6V7H9Zm0 4v2h6v-2H9Zm0 4v2h4v-2H9Z",
  route: "M6 3a3 3 0 1 1 0 6 3 3 0 0 1 0-6Zm12 12a3 3 0 1 1 0 6 3 3 0 0 1 0-6ZM6 11c4 0 6 1 6 4s2 4 6 4v-2c-3 0-4-1-4-2 0-4-3-6-8-6v2Z",
  box: "M12 2 21 7v10l-9 5-9-5V7l9-5Zm0 2.3L5.5 8 12 11.6 18.5 8 12 4.3ZM5 9.7v6.1l6 3.4v-6.1L5 9.7Zm14 0-6 3.4v6.1l6-3.4V9.7Z",
  shield: "M12 2 20 5v6c0 5-3.4 9.4-8 11-4.6-1.6-8-6-8-11V5l8-3Zm-1 13.6 6-6-1.4-1.4-4.6 4.6-2.1-2.1L7.5 12l3.5 3.6Z",
  wallet: "M3 6a3 3 0 0 1 3-3h12v3h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H6a3 3 0 0 1-3-3V6Zm3-1a1 1 0 0 0 0 2h10V5H6Zm11 8a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3Z",
  wifi: "M12 18a2 2 0 1 1 0 4 2 2 0 0 1 0-4ZM4.9 13.5a10 10 0 0 1 14.2 0l-1.5 1.5a8 8 0 0 0-11.2 0l-1.5-1.5ZM1.4 10a15 15 0 0 1 21.2 0L21.1 11.5a13 13 0 0 0-18.2 0L1.4 10Z",
  bike: "M5 13a4 4 0 1 1 0 8 4 4 0 0 1 0-8Zm14 0a4 4 0 1 1 0 8 4 4 0 0 1 0-8ZM14 4h3l3 9h-2l-1-3h-4l-3 5H8l4-7-1-2H9V4h5Z",
  crate: "M3 7h18v14H3V7Zm2 2v10h14V9H5Zm-1-5h16v2H4V4Zm4 7h8v2H8v-2Z",
};

const Icon: React.FC<{ name: string; color: string; size?: number }> = ({ name, color, size = 26 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" aria-hidden>
    <path d={icons[name]} fill={color} />
  </svg>
);

// ---- A node card --------------------------------------------------------------
const Node: React.FC<{
  at: Pt;
  start: number;
  label: string;
  sub: string;
  subAfter?: { text: string; from: number };
  icon: string;
  color: string;
  width?: number;
  big?: boolean;
  /** Frames during which the card shows a "thinking" shimmer along its foot. */
  working?: [number, number];
}> = ({ at, start, label, sub, subAfter, icon, color, width = 290, big, working }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const pop = spring({ frame: frame - start, fps, config: { damping: 16, stiffness: 140, mass: 0.7 } });
  const glow = 0.35 + 0.25 * Math.sin((frame - start) / 9);
  const swapped = subAfter ? interpolate(frame, [subAfter.from, subAfter.from + 8], [0, 1], clamp) : 0;
  const think = working
    ? interpolate(frame, [working[0], working[0] + 6, working[1] - 6, working[1]], [0, 1, 1, 0], clamp)
    : 0;
  const sweep = working ? ((frame - working[0]) / 22) % 1 : 0;
  return (
    <div
      style={{
        position: "absolute",
        overflow: "hidden",
        left: at.x,
        top: at.y,
        width,
        translate: "-50% -50%",
        scale: String(interpolate(pop, [0, 1], [0.6, 1])),
        opacity: interpolate(pop, [0, 0.4], [0, 1], clamp),
        display: "flex",
        alignItems: "center",
        gap: 16,
        padding: big ? "22px 24px" : "16px 18px",
        borderRadius: 20,
        background: C.card,
        border: `1.5px solid ${color}`,
        boxShadow: `0 0 ${big ? 60 : 40}px ${color}${Math.round(glow * 120)
          .toString(16)
          .padStart(2, "0")}`,
      }}
    >
      <div
        style={{
          width: big ? 60 : 50,
          height: big ? 60 : 50,
          borderRadius: 14,
          background: `${color}26`,
          display: "grid",
          placeItems: "center",
          flexShrink: 0,
        }}
      >
        <Icon name={icon} color={color} size={big ? 32 : 26} />
      </div>
      {think > 0 && (
        <div
          style={{
            position: "absolute",
            left: 0,
            right: 0,
            bottom: 0,
            height: 3,
            opacity: think,
            background: `linear-gradient(90deg, transparent ${sweep * 100 - 30}%, ${color} ${sweep * 100}%, transparent ${sweep * 100 + 30}%)`,
          }}
        />
      )}
      <div style={{ display: "flex", flexDirection: "column", gap: 4, minWidth: 0 }}>
        <div style={{ color: C.text, fontSize: big ? 28 : 23, fontWeight: 700, lineHeight: 1.1, whiteSpace: "nowrap" }}>
          {label}
        </div>
        <div style={{ position: "relative", height: 22, fontSize: 17, fontWeight: 500 }}>
          <span style={{ position: "absolute", left: 0, color: C.muted, opacity: 1 - swapped, whiteSpace: "nowrap" }}>
            {sub}
          </span>
          {subAfter && (
            <span
              style={{
                position: "absolute",
                left: 0,
                color: C.lime,
                opacity: swapped,
                translate: `0 ${(1 - swapped) * 8}px`,
                whiteSpace: "nowrap",
              }}
            >
              {subAfter.text}
            </span>
          )}
        </div>
      </div>
    </div>
  );
};

// ---- Edges -------------------------------------------------------------------
const Edge: React.FC<{ a: Pt; b: Pt; start: number; color?: string; flow?: boolean }> = ({
  a,
  b,
  start,
  color = C.lime,
  flow = true,
}) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [start, start + 22], [0, 1], { ...clamp, easing: ease });
  const d = pathOf(a, b);
  return (
    <g>
      <path d={d} stroke={C.line} strokeWidth={2} fill="none" pathLength={1} strokeDasharray="1 1" strokeDashoffset={1 - p} />
      {flow && p >= 1 && (
        <path
          d={d}
          stroke={color}
          strokeOpacity={0.55}
          strokeWidth={2.5}
          fill="none"
          strokeDasharray="10 22"
          strokeDashoffset={-(frame - start) * 1.6}
          strokeLinecap="round"
        />
      )}
    </g>
  );
};

// Money moving along an edge: glowing dots, in a loop while `until`.
const Money: React.FC<{ a: Pt; b: Pt; start: number; until: number; color: string }> = ({ a, b, start, until, color }) => {
  const frame = useCurrentFrame();
  if (frame < start) return null;
  const fade = interpolate(frame, [until, until + 12], [1, 0], clamp);
  const dots = 5;
  return (
    <g opacity={fade}>
      {Array.from({ length: dots }, (_, i) => {
        const tt = (frame - start) / 34 - i / dots;
        if (tt < 0) return null;
        const t = tt % 1;
        const pt = pointAt(a, b, t);
        const o = interpolate(t, [0, 0.12, 0.88, 1], [0, 1, 1, 0]);
        return (
          <g key={i} opacity={o}>
            <circle cx={pt.x} cy={pt.y} r={16} fill={color} opacity={0.18} />
            <circle cx={pt.x} cy={pt.y} r={7} fill={color} />
          </g>
        );
      })}
    </g>
  );
};

// ---- Text --------------------------------------------------------------------
const Headline: React.FC<{ text: string; from: number; to: number }> = ({ text, from, to }) => {
  const frame = useCurrentFrame();
  const inn = interpolate(frame, [from, from + 16], [0, 1], { ...clamp, easing: ease });
  const out = interpolate(frame, [to - 10, to], [0, 1], clamp);
  if (frame < from || frame > to) return null;
  return (
    <div
      style={{
        position: "absolute",
        left: 120,
        top: 118,
        fontSize: 58,
        fontWeight: 700,
        letterSpacing: -1.2,
        color: C.text,
        opacity: inn * (1 - out),
        translate: `0 ${(1 - inn) * 26 - out * 12}px`,
      }}
    >
      {text}
    </div>
  );
};

const Chip: React.FC<{ at: Pt; start: number; text: string }> = ({ at, start, text }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [start, start + 14], [0, 1], { ...clamp, easing: ease });
  const done = interpolate(frame, [232, 240], [0, 1], clamp);
  return (
    <div
      style={{
        position: "absolute",
        left: at.x,
        top: at.y - 92,
        translate: `-50% ${(1 - p) * 14}px`,
        opacity: p,
        padding: "9px 16px",
        borderRadius: 999,
        background: "#13332a",
        border: `1px solid ${C.mint}55`,
        color: C.mint,
        fontSize: 17,
        fontWeight: 500,
        whiteSpace: "nowrap",
        display: "flex",
        gap: 8,
        alignItems: "center",
      }}
    >
      {/* The dot turns lime once the owner has approved the proposals. */}
      <span style={{ width: 8, height: 8, borderRadius: 4, background: done > 0.5 ? C.lime : C.mint, scale: String(1 + done * 0.4) }} />
      {text}
    </div>
  );
};

// The owner's identity check: a ring that sweeps once, then a tick.
const Approval: React.FC<{ at: Pt; start: number }> = ({ at, start }) => {
  const frame = useCurrentFrame();
  const sweep = interpolate(frame, [start, start + 40], [0, 1], { ...clamp, easing: Easing.inOut(Easing.cubic) });
  const tick = interpolate(frame, [start + 40, start + 50], [0, 1], clamp);
  const ring = interpolate(frame, [start + 40, start + 70], [0, 1], clamp);
  if (frame < start) return null;
  return (
    <svg style={{ position: "absolute", left: 0, top: 0 }} width={1920} height={1080}>
      <circle
        cx={at.x}
        cy={at.y}
        r={190}
        fill="none"
        stroke={C.lime}
        strokeWidth={3}
        pathLength={1}
        strokeDasharray="1 1"
        strokeDashoffset={1 - sweep}
        transform={`rotate(-90 ${at.x} ${at.y})`}
        opacity={1 - ring * 0.6}
      />
      <circle cx={at.x} cy={at.y} r={190 + ring * 60} fill="none" stroke={C.lime} strokeWidth={2} opacity={(1 - ring) * tick * 0.8} />
      <g opacity={tick} transform={`translate(${at.x + 134} ${at.y - 134}) scale(${0.6 + tick * 0.4})`}>
        <circle r={22} fill={C.lime} />
        <path d="M-9 0 l6 6 l12 -12" stroke={C.bg} strokeWidth={4} fill="none" strokeLinecap="round" strokeLinejoin="round" />
      </g>
    </svg>
  );
};

const Proof: React.FC<{ start: number }> = ({ start }) => {
  const frame = useCurrentFrame();
  const p = interpolate(frame, [start, start + 18], [0, 1], { ...clamp, easing: ease });
  if (frame < start) return null;
  const shift = (frame - start) * 2.2;
  return (
    <div
      style={{
        position: "absolute",
        left: 120,
        right: 120,
        top: 900,
        height: 100,
        borderRadius: 22,
        background: "#0b1d17",
        border: `1px solid ${C.paypal}66`,
        opacity: p,
        translate: `0 ${(1 - p) * 40}px`,
        display: "flex",
        alignItems: "center",
        overflow: "hidden",
      }}
    >
      <div style={{ padding: "0 28px", flexShrink: 0, borderRight: `1px solid ${C.paypal}44` }}>
        <div style={{ color: C.text, fontSize: 22, fontWeight: 700 }}>Real PayPal Sandbox records</div>
        <div style={{ color: C.muted, fontSize: 17, fontWeight: 500 }}>11 captures · 4 refunds · 5 payout batches</div>
      </div>
      <div style={{ position: "relative", flex: 1, height: "100%", overflow: "hidden" }}>
        <div
          style={{
            position: "absolute",
            top: 30,
            left: 24,
            display: "flex",
            gap: 14,
            translate: `${-shift}px 0`,
            whiteSpace: "nowrap",
          }}
        >
          {IDS.map((id) => (
            <span
              key={id}
              style={{
                fontFamily: "Consolas, monospace",
                fontSize: 20,
                color: "#cfe3ff",
                padding: "6px 12px",
                borderRadius: 10,
                background: `${C.paypal}22`,
              }}
            >
              {id}
            </span>
          ))}
        </div>
      </div>
    </div>
  );
};

// ---- The scene ---------------------------------------------------------------
export const MoneyBrain: React.FC = () => {
  const frame = useCurrentFrame();
  const bgIn = interpolate(frame, [0, 20], [0, 1], clamp);
  const drift = frame * 0.25;
  return (
    <AbsoluteFill style={{ background: C.bg, fontFamily: "Jakarta, sans-serif", overflow: "hidden" }}>
      <AbsoluteFill
        style={{
          opacity: bgIn,
          background: `radial-gradient(1100px 700px at 30% 55%, ${C.bg2}, transparent 70%), radial-gradient(900px 600px at 80% 50%, #0a2a4a66, transparent 70%)`,
        }}
      />
      <AbsoluteFill
        style={{
          opacity: bgIn * 0.5,
          backgroundImage: "radial-gradient(rgba(215,249,120,0.10) 1.2px, transparent 1.2px)",
          backgroundSize: "34px 34px",
          backgroundPosition: `${-drift}px 0px`,
        }}
      />

      <div
        style={{
          position: "absolute",
          left: 122,
          top: 78,
          color: C.lime,
          fontSize: 20,
          fontWeight: 700,
          letterSpacing: 4,
          opacity: interpolate(frame, [6, 20], [0, 1], clamp),
        }}
      >
        RAYSTO · AI WITH PAYPAL
      </div>
      <Headline text="Three AI coworkers run the back office." from={10} to={150} />
      <Headline text="They prepare the work. You approve it." from={152} to={268} />
      <Headline text="PayPal moves the money." from={270} to={372} />
      <Headline text="AI prepares. You approve. PayPal pays." from={374} to={460} />

      <svg style={{ position: "absolute", left: 0, top: 0 }} width={1920} height={1080}>
        <Edge a={P.cafe} b={P.accountant} start={46} />
        <Edge a={P.cafe} b={P.dispatcher} start={52} />
        <Edge a={P.cafe} b={P.planner} start={58} />
        <Edge a={P.accountant} b={P.owner} start={150} />
        <Edge a={P.dispatcher} b={P.owner} start={156} />
        <Edge a={P.planner} b={P.owner} start={162} />
        <Edge a={P.owner} b={P.paypal} start={246} color={C.paypal} />
        <Edge a={P.paypal} b={P.provider} start={276} color={C.paypal} />
        <Edge a={P.paypal} b={P.driver} start={282} color={C.paypal} />
        <Edge a={P.paypal} b={P.supplier} start={288} color={C.paypal} />
        <Money a={P.owner} b={P.paypal} start={262} until={384} color={C.lime} />
        <Money a={P.paypal} b={P.provider} start={296} until={392} color={C.paypal} />
        <Money a={P.paypal} b={P.driver} start={300} until={392} color={C.paypal} />
        <Money a={P.paypal} b={P.supplier} start={304} until={392} color={C.paypal} />
      </svg>

      <Approval at={P.owner} start={190} />

      <Node at={P.cafe} start={20} big width={300} label="Atelier café" sub="Orders · bills · stock" icon="store" color={C.lime} />
      <Node at={P.accountant} start={60} working={[74, 112]} label="AI accountant" sub="Bills and books" icon="receipt" color={C.mint} />
      <Node at={P.dispatcher} start={68} working={[82, 122]} label="AI dispatcher" sub="Deliveries" icon="route" color={C.mint} />
      <Node at={P.planner} start={76} working={[90, 132]} label="AI supply planner" sub="Stock and orders" icon="box" color={C.mint} width={320} />
      <Chip at={P.accountant} start={108} text="Internet bill read from a photo" />
      <Chip at={P.dispatcher} start={118} text="6 deliveries done · driver owed" />
      <Chip at={P.planner} start={128} text="Stock-out in 2 days · order drafted" />
      <Node
        at={P.owner}
        start={166}
        big
        width={346}
        label="Owner approves"
        sub="Identity check…"
        subAfter={{ text: "Approved", from: 232 }}
        icon="shield"
        color={C.lime}
      />
      <Node at={P.paypal} start={250} big width={260} label="PayPal" sub="Payouts · Sandbox" icon="wallet" color={C.paypal} />
      <Node
        at={P.provider}
        start={284}
        label="Internet provider"
        sub="Waiting"
        subAfter={{ text: "Paid through PayPal", from: 326 }}
        icon="wifi"
        color={C.paypal}
        width={286}
      />
      <Node
        at={P.driver}
        start={290}
        label="Driver"
        sub="Waiting"
        subAfter={{ text: "Paid through PayPal", from: 332 }}
        icon="bike"
        color={C.paypal}
        width={286}
      />
      <Node
        at={P.supplier}
        start={296}
        label="Supplier"
        sub="Waiting"
        subAfter={{ text: "Paid through PayPal", from: 338 }}
        icon="crate"
        color={C.paypal}
        width={286}
      />

      <Proof start={372} />

      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 26,
          textAlign: "center",
          color: "#6f8579",
          fontSize: 16,
          fontWeight: 500,
          opacity: bgIn,
        }}
      >
        Diagram of how Raysto works · ids shown are real PayPal Sandbox records
      </div>
    </AbsoluteFill>
  );
};

export const MoneyBrainComposition: React.FC = () => (
  <Composition id="MoneyBrainTest" component={MoneyBrain} durationInFrames={450} fps={30} width={1920} height={1080} />
);
