// RaystoDemo: the judges' demo film, under three minutes. Every product shot
// is a screen recording of the live judge path (rays.to, then the five Try
// Raysto cards against api.rays.to in PayPal Sandbox), cut by footage.ts;
// waiting is sped up and labelled as such. The tablet scene uses the app's
// own screens rendered with demo data, and says so. Voice: Kokoro, generated
// offline by make_demo_voice.py. Music: "Gimme that Groove!" by Michael
// Ramir C., Mixkit Stock Music Free License.
import React from "react";
import { AbsoluteFill, Composition, Img, Sequence, staticFile, useCurrentFrame } from "remotion";
import { Audio, Video } from "@remotion/media";
import { SECONDS } from "./voice-timing";
import narration from "./narration.json";
import { CLIPS, type Cut } from "./footage";
import { Backdrop, Browser, C, Camera, Chip, SANS, SERIF, Shot, Tablet, Words, tween, usePop } from "../promo/kit";

const FPS = 30;
const OVERLAP = 12;
const VOICE_DELAY = 10;
const TAIL = 18;

type SceneId =
  | "hook"
  | "rule"
  | "judges"
  | "voice"
  | "menu"
  | "order"
  | "paid"
  | "payments"
  | "photo"
  | "tablet"
  | "evidence"
  | "outro";

const LABELS: Partial<Record<SceneId, string>> = {
  judges: "rays.to · one click, nothing to install",
  voice: "1 · Voice order at the counter",
  menu: "2 · Menu agent reads a printed menu",
  order: "3 · One sentence becomes an order",
  paid: "3 · Approved on PayPal's own page",
  payments: "4 · Payments agent, PayPal MCP",
  photo: "5 · Image studio",
  tablet: "Staff tablet · app screens, demo data",
};

const footageFrames = (cuts: Cut[]) =>
  cuts.reduce((sum, c) => sum + Math.round(((c.to - c.from) / (c.speed ?? 1)) * FPS), 0);

// A scene lasts as long as its voice line or its footage, whichever is longer.
const ORDER: SceneId[] = ["hook", "rule", "judges", "voice", "menu", "order", "paid", "payments", "photo", "tablet", "evidence", "outro"];
const SCENES = ORDER.map((id) => {
  const voice = VOICE_DELAY + Math.ceil(SECONDS[id] * FPS) + TAIL;
  const clip = CLIPS[id];
  const frames = Math.max(voice, clip ? footageFrames(clip.cuts) + 14 : 0, id === "outro" ? voice + 60 : 0);
  return { id, frames };
});
const starts: Record<string, number> = {};
let cursor = 0;
for (const s of SCENES) {
  starts[s.id] = cursor;
  cursor += s.frames - OVERLAP;
}
export const TOTAL = cursor + OVERLAP;
const voiceWindows = SCENES.map((s) => [starts[s.id] + VOICE_DELAY, starts[s.id] + VOICE_DELAY + Math.ceil(SECONDS[s.id] * FPS)] as const);

const fill: React.CSSProperties = { width: "100%", height: "100%", objectFit: "cover" };

/** The recorded browser footage for one scene, cut and sped up as footage.ts says. */
const Footage: React.FC<{ id: SceneId }> = ({ id }) => {
  const clip = CLIPS[id]!;
  const f = useCurrentFrame();
  let at = 0;
  const pieces = clip.cuts.map((c, i) => {
    const speed = c.speed ?? 1;
    const length = Math.round(((c.to - c.from) / speed) * FPS);
    const from = at;
    at += length;
    return { c, i, speed, length, from };
  });
  const last = pieces[pieces.length - 1];
  const fast = pieces.find((p) => p.speed > 1.05 && f >= p.from && f < p.from + p.length);
  return (
    <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
      <Camera keys={clip.camera ?? [[0, 1, 0, 0]]}>
        <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
          <Browser width={1640} url={clip.url}>
            {pieces.map((p) => (
              <Sequence key={p.i} from={p.from} durationInFrames={p === last ? 100000 : p.length} layout="none">
                {/* The page fills the top-left two thirds of each recorded frame. */}
                <Video
                  src={staticFile(`demo/footage/${p.c.file}`)}
                  muted
                  trimBefore={Math.round(p.c.from * FPS)}
                  playbackRate={p.speed}
                  style={{ position: "absolute", left: 0, top: 0, width: "150%", height: "150%" }}
                />
              </Sequence>
            ))}
          </Browser>
        </AbsoluteFill>
      </Camera>
      {fast && (
        <Chip at={fast.from} tone="cream" size={24} style={{ right: 170, top: 168 }}>
          ⏩ {Math.round(fast.c.to - fast.c.from)} s of waiting, sped up ×{fast.speed.toFixed(0)}
        </Chip>
      )}
    </AbsoluteFill>
  );
};

const Hook: React.FC = () => {
  const f = useCurrentFrame();
  const items = ["The till", "Paper tickets", "The card reader"];
  return (
    <AbsoluteFill style={{ padding: "150px 170px" }}>
      <Words text="Lunch at a small café." at={4} size={120} font={SERIF} weight={500} color={C.forest} />
      <div style={{ display: "flex", gap: 36, marginTop: 90 }}>
        {items.map((label, i) => {
          const p = tween(f, 40 + i * 14, 70 + i * 14);
          const apart = tween(f, 150, 230);
          return (
            <div
              key={label}
              style={{
                padding: "34px 46px",
                borderRadius: 32,
                background: C.cream,
                boxShadow: "0 20px 40px rgba(16,38,31,0.14)",
                fontFamily: SANS,
                fontWeight: 700,
                fontSize: 46,
                color: C.forest,
                opacity: p,
                transform: `translateY(${(1 - p) * 60}px) translateX(${(i - 1) * apart * 70}px) rotate(${(i - 1) * apart * 4}deg)`,
              }}
            >
              {label}
            </div>
          );
        })}
      </div>
      <div style={{ marginTop: 80 }}>
        <Words text="…that don't talk to each other." at={110} size={56} weight={500} color={C.muted} />
      </div>
    </AbsoluteFill>
  );
};

const Rule: React.FC = () => (
  <AbsoluteFill style={{ padding: "170px 170px", gap: 34 }}>
    <Words text="AI coworkers prepare." at={70} size={110} font={SERIF} weight={600} />
    <Words text="You approve." at={128} size={110} font={SERIF} weight={600} />
    <Words text="PayPal moves the money." at={168} size={110} font={SERIF} weight={600} color={C.paypal} />
  </AbsoluteFill>
);

const TabletScene: React.FC = () => {
  const f = useCurrentFrame();
  const shots = ["tablet-counter-sale.png", "tablet-kitchen.png", "tablet-agents.png"];
  return (
    <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
      <Camera keys={[[0, 0.96, 0, 0], [240, 1.02, 0, 0]]}>
        <AbsoluteFill style={{ justifyContent: "center", alignItems: "center" }}>
          <Tablet width={1500}>
            {shots.map((s, i) => {
              const o = i === 0 ? 1 : tween(f, 20 + i * 75, 36 + i * 75);
              return <Img key={s} src={staticFile(`demo/${s}`)} style={{ ...fill, position: "absolute", inset: 0, opacity: o }} />;
            })}
          </Tablet>
        </AbsoluteFill>
      </Camera>
    </AbsoluteFill>
  );
};

const STATS = [
  ["9", "PayPal Sandbox captures and a refund, recorded live"],
  ["12 / 12", "live AI evaluation cases: menus, spoken orders, takeaway requests"],
  ["326", "automated tests: 151 backend, 154 app, 21 console"],
  ["MCP", "the payments agent reads PayPal through PayPal's own MCP server"],
] as const;

const Evidence: React.FC = () => (
  <AbsoluteFill style={{ padding: "130px 150px" }}>
    <Words text="Checked live, not on a slide." at={4} size={96} font={SERIF} weight={600} />
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 34, marginTop: 70 }}>
      {STATS.map(([big, small], i) => (
        <Stat key={big} big={big} small={small} at={40 + i * 26} />
      ))}
    </div>
  </AbsoluteFill>
);

const Stat: React.FC<{ big: string; small: string; at: number }> = ({ big, small, at }) => {
  const p = usePop(at);
  return (
    <div
      style={{
        padding: "36px 44px",
        borderRadius: 34,
        background: C.cream,
        boxShadow: "0 20px 40px rgba(16,38,31,0.12)",
        opacity: Math.min(1, p * 1.3),
        transform: `translateY(${(1 - p) * 40}px)`,
      }}
    >
      <div style={{ fontFamily: SERIF, fontWeight: 700, fontSize: 92, color: C.forest, lineHeight: 1 }}>{big}</div>
      <div style={{ fontFamily: SANS, fontWeight: 500, fontSize: 32, color: C.muted, marginTop: 12 }}>{small}</div>
    </div>
  );
};

const Outro: React.FC = () => {
  const star = usePop(10, 10);
  return (
    <AbsoluteFill style={{ justifyContent: "center", alignItems: "center", gap: 40 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 20 }}>
        <span style={{ fontFamily: SANS, fontWeight: 700, fontSize: 200, letterSpacing: -9, color: C.forest }}>raysto</span>
        <span style={{ fontSize: 150, color: C.forest, display: "inline-block", transform: `scale(${star}) rotate(${(1 - star) * -200}deg)` }}>✳</span>
      </div>
      <Words text="AI coworkers prepare. You approve. PayPal moves the money." at={30} size={54} weight={500} />
      <Chip at={90} tone="forest" size={46} style={{ position: "relative" }}>
        Try it at rays.to
      </Chip>
    </AbsoluteFill>
  );
};

const VIEWS: Record<SceneId, React.FC> = {
  hook: Hook,
  rule: Rule,
  judges: () => <Footage id="judges" />,
  voice: () => <Footage id="voice" />,
  menu: () => <Footage id="menu" />,
  order: () => <Footage id="order" />,
  paid: () => <Footage id="paid" />,
  payments: () => <Footage id="payments" />,
  photo: () => <Footage id="photo" />,
  tablet: TabletScene,
  evidence: Evidence,
  outro: Outro,
};

const LINES = Object.fromEntries((narration as { id: string; text: string }[]).map((l) => [l.id, l.text]));

/** Scene label, Sandbox note, caption of the spoken line and progress bar. */
const Overlay: React.FC = () => {
  const f = useCurrentFrame();
  const current = [...SCENES].reverse().find((s) => f >= starts[s.id])!;
  const local = f - starts[current.id];
  const label = LABELS[current.id];
  const shown = tween(local, 6, 20) * (1 - tween(local, current.frames - 16, current.frames - 4));
  const spoken = local >= VOICE_DELAY && local <= VOICE_DELAY + SECONDS[current.id] * FPS + 12;
  return (
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      {label && (
        <div
          style={{
            position: "absolute",
            left: 60,
            top: 34,
            padding: "12px 22px",
            borderRadius: 99,
            background: C.forest,
            color: C.cream,
            fontFamily: SANS,
            fontWeight: 700,
            fontSize: 24,
            opacity: shown,
          }}
        >
          {label}
        </div>
      )}
      {CLIPS[current.id] && (
        <div
          style={{
            position: "absolute",
            right: 60,
            top: 34,
            padding: "12px 22px",
            borderRadius: 99,
            background: C.cream,
            color: C.paypal,
            fontFamily: SANS,
            fontWeight: 700,
            fontSize: 22,
            opacity: shown,
          }}
        >
          PayPal Sandbox · recorded live, 2 November 2026
        </div>
      )}
      {spoken && (
        <div
          style={{
            position: "absolute",
            left: "50%",
            bottom: 22,
            transform: "translateX(-50%)",
            width: 1320,
            padding: "10px 24px",
            borderRadius: 16,
            background: "rgba(16,38,31,0.86)",
            color: "#fff",
            fontFamily: SANS,
            fontWeight: 500,
            fontSize: 26,
            lineHeight: 1.3,
            textAlign: "center",
            opacity: tween(local, VOICE_DELAY, VOICE_DELAY + 8),
          }}
        >
          {LINES[current.id]}
        </div>
      )}
      <div style={{ position: "absolute", left: 0, bottom: 0, height: 7, width: `${(f / TOTAL) * 100}%`, background: C.limeHot }} />
    </AbsoluteFill>
  );
};

export const Demo: React.FC = () => {
  const music = (frame: number) => {
    const speaking = voiceWindows.some(([a, b]) => frame >= a - 6 && frame <= b + 6);
    const fade = Math.min(tween(frame, 0, 20), 1 - tween(frame, TOTAL - 60, TOTAL));
    return fade * (speaking ? 0.09 : 0.22);
  };
  return (
    <AbsoluteFill style={{ background: C.paper }}>
      <Backdrop />
      {SCENES.map((s) => {
        const View = VIEWS[s.id];
        return (
          <Sequence key={s.id} from={starts[s.id]} durationInFrames={s.frames} premountFor={45}>
            <Shot duration={s.frames} enter={s.id === "hook" ? 0 : 14} exit={s.id === "outro" ? 30 : 12}>
              <View />
            </Shot>
          </Sequence>
        );
      })}
      <Overlay />
      {SCENES.map((s) => (
        <Sequence key={`voice-${s.id}`} from={starts[s.id] + VOICE_DELAY} layout="none">
          <Audio src={staticFile(`demo/voice/${s.id}.wav`)} volume={1} />
        </Sequence>
      ))}
      <Audio src={staticFile("promo/music.mp3")} volume={music} loop />
    </AbsoluteFill>
  );
};

export const DemoRoot: React.FC = () => (
  <Composition id="RaystoDemo" component={Demo} durationInFrames={TOTAL} fps={FPS} width={1920} height={1080} />
);
