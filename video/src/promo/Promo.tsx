// RaystoPromo60: a one-minute tour of Raysto on a phone, a tablet and the
// web, cut from footage recorded live against api.rays.to in PayPal Sandbox
// (see ../../docs/demo-video-plan.md). Voice: Kokoro, generated offline by
// make_promo_voice.py. Music: "Gimme that Groove!" by Michael Ramir C., Mixkit.
import React from "react";
import { AbsoluteFill, Composition, Img, Sequence, staticFile, useCurrentFrame } from "remotion";
import { Audio, Video } from "@remotion/media";
import { SECONDS } from "./voice-timing";
import {
  Backdrop,
  Browser,
  C,
  Camera,
  Chip,
  Highlight,
  Phone,
  SANS,
  SERIF,
  Shot,
  Tablet,
  Words,
  tween,
  usePop,
} from "./kit";

const FPS = 30;
const OVERLAP = 12;
const SCENES = [
  { id: "intro", frames: 156 },
  { id: "counter", frames: 210, label: "01  Counter · tablet" },
  { id: "pay", frames: 140, label: "02  Customer pays · phone" },
  { id: "kitchen", frames: 180, label: "03  Kitchen · tablet" },
  { id: "table", frames: 390, label: "04  At the table · phones" },
  { id: "web", frames: 255, label: "05  Owner · web console" },
  { id: "ai", frames: 270, label: "06  Ask Raysto · AI" },
  { id: "outro", frames: 270 },
] as const;
type SceneId = (typeof SCENES)[number]["id"];

const starts: Record<string, number> = {};
let cursor = 0;
for (const s of SCENES) {
  starts[s.id] = cursor;
  cursor += s.frames - OVERLAP;
}
export const TOTAL = cursor + OVERLAP;
const VOICE_DELAY = 10;
const voiceWindows = SCENES.map((s) => {
  const from = starts[s.id] + VOICE_DELAY;
  return [from, from + Math.ceil(SECONDS[s.id] * FPS)] as const;
});

const fill: React.CSSProperties = { width: "100%", height: "100%", objectFit: "cover" };
const box: React.CSSProperties = { width: "100%", height: "100%" };
const TABLET_W = 1500;
const tabletAt: React.CSSProperties = { position: "absolute", left: 210, top: 62 };

/** Counter footage on the tablet, cropped from the live recording. */
const TabletClip: React.FC<{ from: number; rate?: number }> = ({ from, rate = 1 }) => (
  <Video src={staticFile("promo/tablet-counter.mp4")} muted trimBefore={Math.round(from * FPS)} playbackRate={rate} objectFit="cover" style={box} />
);

const Intro: React.FC = () => {
  const f = useCurrentFrame();
  const letters = "raysto".split("");
  const star = usePop(26, 10);
  const devices = [usePop(38), usePop(46), usePop(54)];
  return (
    <AbsoluteFill>
      <Camera keys={[[0, 1, 0, 0], [118, 1, 0, 0], [156, 2.7, -235, 268]]}>
        <div style={{ position: "absolute", top: 60, width: "100%", display: "flex", justifyContent: "center", alignItems: "center" }}>
          {letters.map((l, i) => {
            const p = tween(f, 2 + i * 3, 22 + i * 3);
            return (
              <span
                key={i}
                style={{
                  fontFamily: SANS,
                  fontWeight: 700,
                  fontSize: 230,
                  letterSpacing: -10,
                  color: C.forest,
                  display: "inline-block",
                  transform: `translateY(${(1 - p) * 120}px) rotate(${(1 - p) * 12}deg)`,
                  opacity: p,
                }}
              >
                {l}
              </span>
            );
          })}
          <span
            style={{
              fontSize: 170,
              color: C.forest,
              marginLeft: 18,
              display: "inline-block",
              transform: `rotate(${(1 - star) * -220 + f * 0.6}deg) scale(${star})`,
            }}
          >
            ✳
          </span>
        </div>
        <div style={{ position: "absolute", top: 400, width: "100%", display: "flex", justifyContent: "center" }}>
          <Words text="One system for the counter, the kitchen and the table." at={30} size={44} weight={500} stagger={3} />
        </div>
        <div style={{ position: "absolute", left: 115, bottom: 70, display: "flex", alignItems: "flex-end", gap: 60 }}>
          {[
            <Phone key="p" width={230}>
              <Img src={staticFile("screens/discovery.png")} style={fill} />
            </Phone>,
            <Tablet key="t" width={640}>
              <Img src={staticFile("promo/tablet-paid.png")} style={fill} />
            </Tablet>,
            <Browser key="b" width={700} url="ops.rays.to">
              <Img src={staticFile("promo/console-overview.png")} style={fill} />
            </Browser>,
          ].map((d, i) => (
            <div key={i} style={{ transform: `translateY(${(1 - devices[i]) * 520}px)`, opacity: Math.min(1, devices[i] * 2) }}>
              {d}
            </div>
          ))}
        </div>
      </Camera>
    </AbsoluteFill>
  );
};

const Counter: React.FC = () => (
  <AbsoluteFill>
    <Camera keys={[[0, 0.94, 0, 0], [96, 1, 0, 0], [128, 1.75, 487, -150]]}>
      <Tablet width={TABLET_W} style={tabletAt}>
        <Sequence durationInFrames={104}>
          <TabletClip from={0} rate={2.3} />
        </Sequence>
        <Sequence from={104}>
          <TabletClip from={15.5} />
        </Sequence>
      </Tablet>
    </Camera>
    <Chip at={14} tone="cream" style={{ left: 90, top: 880 }} until={110}>
      Tap the order
    </Chip>
    <Chip at={58} tone="lime" style={{ left: 420, top: 880 }} until={110}>
      3 items · $33.00
    </Chip>
    <Chip at={130} tone="paypal" size={34} style={{ left: 90, top: 880 }}>
      Show the PayPal QR code
    </Chip>
  </AbsoluteFill>
);

const Pay: React.FC = () => {
  const f = useCurrentFrame();
  const phone = usePop(4, 16);
  const path = tween(f, 22, 52);
  return (
    <AbsoluteFill>
      <div style={{ ...tabletAt, transform: "translateX(-330px) scale(0.66)", filter: "blur(2px) saturate(0.9)" }}>
        <Tablet width={TABLET_W}>
          <TabletClip from={21} />
        </Tablet>
      </div>
      <svg width="1920" height="1080" style={{ position: "absolute" }}>
        <path
          d="M 820 380 C 980 300, 1080 330, 1200 420"
          fill="none"
          stroke={C.forest}
          strokeWidth={6}
          strokeLinecap="round"
          pathLength={1}
          style={{ strokeDasharray: `${path} 1`, strokeDashoffset: 0 }}
        />
      </svg>
      <div
        style={{
          position: "absolute",
          left: 1260,
          top: 110,
          transform: `translateX(${(1 - phone) * 760}px) rotate(${(1 - phone) * 12 - 3}deg)`,
        }}
      >
        <Phone width={420}>
          <Video src={staticFile("promo/buyer-phone.mp4")} muted playbackRate={1.5} objectFit="cover" style={box} />
        </Phone>
      </div>
      <Chip at={30} tone="cream" style={{ left: 1010, top: 930 }}>
        On the customer's own phone
      </Chip>
      <Chip at={52} tone="paypal" style={{ left: 1290, top: 30 }}>
        PayPal checkout
      </Chip>
    </AbsoluteFill>
  );
};

const Kitchen: React.FC = () => (
  <AbsoluteFill>
    <Camera keys={[[0, 1.05, 300, -100], [40, 1.9, 487, -150], [76, 1.9, 487, -150], [78, 1, 0, 0], [180, 1.35, 40, -120]]}>
      <Tablet width={TABLET_W} style={tabletAt}>
        <Sequence durationInFrames={78}>
          <TabletClip from={44.5} />
        </Sequence>
        <Sequence from={78}>
          <TabletClip from={57.5} rate={4} />
        </Sequence>
      </Tablet>
    </Camera>
    <Chip at={18} tone="lime" style={{ left: 90, top: 820 }} until={74}>
      Paid · PayPal capture 55W092765M630635H
    </Chip>
    <Chip at={84} tone="forest" style={{ left: 90, top: 900 }}>
      Kitchen board · updates live
    </Chip>
  </AbsoluteFill>
);

const TABLE_PHONES = [
  { x: 240, y: 160 },
  { x: 760, y: 110 },
  { x: 1280, y: 160 },
];

const Table: React.FC = () => {
  const f = useCurrentFrame();
  const swap1 = tween(f, 58, 72);
  const swap3 = tween(f, 244, 258);
  const split = usePop(318, 12);
  return (
    <AbsoluteFill>
      <Backdrop warm={1} />
      <Camera
        keys={[
          [0, 1.3, -520, 40],
          [58, 1.3, -520, 40],
          [128, 1.3, 0, 0],
          [186, 1.3, 0, 0],
          [216, 1.3, 520, 40],
          [282, 1.3, 520, 40],
          [320, 0.86, 0, 30],
        ]}
      >
        {TABLE_PHONES.map((p, i) => (
          <div key={i} style={{ position: "absolute", left: p.x, top: p.y }}>
            <Phone width={400}>
              {i === 0 && (
                <>
                  <Video src={staticFile("native-room-scroll.mp4")} muted playbackRate={1.3} objectFit="cover" style={box} />
                  <Img src={staticFile("screens/ai-basket.png")} style={{ ...fill, position: "absolute", inset: 0, opacity: swap1 }} />
                </>
              )}
              {i === 1 && <Img src={staticFile("screens/review-order.png")} style={fill} />}
              {i === 2 && (
                <>
                  <Img src={staticFile("screens/share.png")} style={fill} />
                  <Img src={staticFile("screens/review-share.png")} style={{ ...fill, position: "absolute", inset: 0, opacity: swap3 }} />
                </>
              )}
            </Phone>
          </div>
        ))}
      </Camera>
      <Chip at={12} tone="cream" style={{ left: 80, top: 90 }} until={120}>
        Guests share one room
      </Chip>
      <Chip at={66} tone="forest" style={{ left: 80, top: 170 }} until={120}>
        ✦ Gemini builds the order from the real menu
      </Chip>
      <Chip at={136} tone="lime" style={{ left: 80, top: 90 }} until={186}>
        The host approves · $27.00
      </Chip>
      <Chip at={222} tone="forest" style={{ left: 80, top: 90 }} until={300}>
        Split to the cent
      </Chip>
      <Chip at={252} tone="paypal" style={{ left: 80, top: 170 }} until={300}>
        Each guest approves their share in PayPal
      </Chip>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 905,
          display: "flex",
          justifyContent: "center",
          gap: 26,
          alignItems: "center",
          opacity: split,
          transform: `translateY(${(1 - split) * 40}px)`,
          fontFamily: SANS,
          fontWeight: 700,
          fontSize: 44,
          color: C.forest,
        }}
      >
        <span>$27.00</span>
        <span style={{ fontSize: 36 }}>→</span>
        {["$13.50", "$13.50"].map((v, i) => (
          <span key={i} style={{ background: C.lime, borderRadius: 99, padding: "8px 26px", transform: `scale(${0.8 + 0.2 * split})` }}>
            {v}
          </span>
        ))}
        <span style={{ fontSize: 28, color: C.muted, fontWeight: 500 }}>two buyers · two PayPal captures</span>
      </div>
    </AbsoluteFill>
  );
};

const BROWSER_W = 1680;
const Web: React.FC = () => (
  <AbsoluteFill>
    <Camera
      keys={[
        [0, 0.96, 0, 0],
        [24, 0.96, 0, 0],
        [66, 1.55, -403, -17],
        [78, 1.55, -403, -17],
        [80, 1.05, 200, 60],
        [130, 1.85, 615, 118],
        [152, 1.85, 615, 118],
        [154, 1.1, 0, 120],
        [255, 1.45, -228, 212],
      ]}
    >
      <Browser width={BROWSER_W} url="ops.rays.to/ops" style={{ position: "absolute", left: 120, top: 38 }}>
        <Sequence durationInFrames={80}>
          <Video src={staticFile("promo/console.mp4")} muted objectFit="cover" style={box} />
        </Sequence>
        <Sequence from={80} durationInFrames={74}>
          <Video src={staticFile("promo/console.mp4")} muted trimBefore={12 * FPS} objectFit="cover" style={box} />
        </Sequence>
        <Sequence from={154}>
          <Video src={staticFile("promo/console.mp4")} muted trimBefore={21 * FPS} objectFit="cover" style={box} />
        </Sequence>
      </Browser>
    </Camera>
    <Chip at={30} tone="forest" style={{ left: 80, top: 930 }} until={76}>
      Every channel, today
    </Chip>
    <Chip at={96} tone="lime" style={{ left: 80, top: 930 }} until={150}>
      Each order with its PayPal capture ID
    </Chip>
    <Chip at={166} tone="cream" style={{ left: 80, top: 930 }}>
      PayPal, cash and refunds kept apart
    </Chip>
    <Chip at={8} tone="paypal" size={26} style={{ right: 70, top: 40 }}>
      AG Grid console
    </Chip>
  </AbsoluteFill>
);

const FLOW = [
  { at: 66, title: "Gemini", sub: "understands the question" },
  { at: 96, title: "Raysto ledger", sub: "unresolved payments: none" },
  { at: 128, title: "PayPal MCP", sub: "checkout 9: COMPLETED" },
];

const Ai: React.FC = () => {
  const f = useCurrentFrame();
  const still = tween(f, 108, 120);
  return (
    <AbsoluteFill>
      <Camera keys={[[0, 1, 0, 0], [60, 1.25, -120, -120], [112, 1.25, -120, -120], [150, 1.75, -330, -48], [270, 1.82, -330, -48]]}>
        <Tablet width={TABLET_W} style={tabletAt}>
          <Video src={staticFile("promo/ask.mp4")} muted trimBefore={2 * FPS} playbackRate={2.2} objectFit="cover" style={box} />
          <Img src={staticFile("promo/ask-answer.png")} style={{ ...fill, position: "absolute", inset: 0, opacity: still }} />
          <Highlight at={156} x={34} y={402} w={560} h={76} />
        </Tablet>
      </Camera>
      <div style={{ position: "absolute", right: 70, top: 250, width: 480 }}>
        {FLOW.map((n, i) => {
          const p = tween(f, n.at, n.at + 16);
          const line = tween(f, n.at - 14, n.at);
          return (
            <div key={n.title} style={{ position: "relative", marginBottom: 46 }}>
              {i > 0 && (
                <div
                  style={{
                    position: "absolute",
                    left: 44,
                    top: -46,
                    width: 6,
                    height: 46 * line,
                    background: C.forest,
                    borderRadius: 3,
                  }}
                />
              )}
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 22,
                  padding: "18px 26px",
                  borderRadius: 26,
                  background: i === 2 ? C.paypal : C.cream,
                  color: i === 2 ? "#fff" : C.forest,
                  boxShadow: "0 18px 40px rgba(16,38,31,0.22)",
                  opacity: p,
                  transform: `translateX(${(1 - p) * 80}px)`,
                  fontFamily: SANS,
                }}
              >
                <div style={{ width: 40, height: 40, borderRadius: 99, background: i === 2 ? "#ffffff30" : C.lime, display: "grid", placeItems: "center", fontWeight: 700, fontSize: 24 }}>
                  {i + 1}
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 32 }}>{n.title}</div>
                  <div style={{ fontWeight: 500, fontSize: 22, opacity: 0.85 }}>{n.sub}</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
      <Chip at={176} tone="lime" style={{ left: 80, top: 930 }}>
        Reads payments. Never moves money.
      </Chip>
    </AbsoluteFill>
  );
};

const Outro: React.FC = () => {
  const f = useCurrentFrame();
  const up = tween(f, 118, 146);
  const logo = usePop(132, 12);
  const stack = ["PayPal Orders v2", "Webhooks", "PayPal MCP", "Gemini", "AG Grid", "Flutter · Serverpod"];
  return (
    <AbsoluteFill>
      <div style={{ position: "absolute", left: 0, right: 0, top: 250, transform: `translateY(${-up * 160}px)`, opacity: 1 - up }}>
        {[
          ["AI helps.", 8],
          ["People approve.", 34],
          ["PayPal moves the money.", 62],
        ].map(([t, at]) => (
          <Words key={t as string} text={t as string} at={at as number} size={120} font={SERIF} weight={500} italic style={{ justifyContent: "center" }} />
        ))}
      </div>
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          top: 300,
          textAlign: "center",
          opacity: logo,
          transform: `scale(${0.8 + 0.2 * logo})`,
        }}
      >
        <div style={{ fontFamily: SANS, fontWeight: 700, fontSize: 200, letterSpacing: -9, color: C.forest }}>
          raysto <span style={{ fontSize: 150, display: "inline-block", transform: `rotate(${f * 0.8}deg)` }}>✳</span>
        </div>
        <div style={{ fontFamily: SANS, fontWeight: 500, fontSize: 40, color: C.forest, marginTop: 4 }}>
          The counter, the kitchen and the table, on one system · rays.to
        </div>
      </div>
      <div style={{ position: "absolute", top: 720, left: 0, right: 0, display: "flex", justifyContent: "center", gap: 16 }}>
        {stack.map((s, i) => {
          const p = tween(f, 150 + i * 5, 170 + i * 5);
          return (
            <div
              key={s}
              style={{
                padding: "12px 24px",
                borderRadius: 99,
                background: s.startsWith("PayPal") || s === "Webhooks" ? C.paypal : C.cream,
                color: s.startsWith("PayPal") || s === "Webhooks" ? "#fff" : C.forest,
                fontFamily: SANS,
                fontWeight: 700,
                fontSize: 26,
                opacity: p,
                transform: `translateY(${(1 - p) * 30}px)`,
                boxShadow: "0 10px 24px rgba(16,38,31,0.16)",
              }}
            >
              {s}
            </div>
          );
        })}
      </div>
      <div style={{ position: "absolute", bottom: 90, width: "100%", textAlign: "center", fontFamily: SANS, fontSize: 24, color: C.muted, opacity: tween(f, 180, 200) }}>
        Shown in PayPal Sandbox with real test payments · github.com/FouadABT/raysto
      </div>
    </AbsoluteFill>
  );
};

const SCENE_VIEW: Record<SceneId, React.FC> = {
  intro: Intro,
  counter: Counter,
  pay: Pay,
  kitchen: Kitchen,
  table: Table,
  web: Web,
  ai: Ai,
  outro: Outro,
};

/** Scene name, the Sandbox notice and progress, above every middle scene. */
const Overlay: React.FC = () => {
  const f = useCurrentFrame();
  const shown = tween(f, starts.counter, starts.counter + 14) * (1 - tween(f, starts.outro, starts.outro + 12));
  const current = [...SCENES].reverse().find((s) => f >= starts[s.id] + 6);
  const label = current && "label" in current ? current.label : "";
  const swap = current ? tween(f, starts[current.id] + 6, starts[current.id] + 20) : 1;
  return (
    <AbsoluteFill style={{ opacity: shown }}>
      <div
        style={{
          position: "absolute",
          left: 40,
          top: 22,
          padding: "10px 24px",
          borderRadius: 99,
          background: `${C.cream}f2`,
          boxShadow: "0 10px 26px rgba(16,38,31,0.16)",
          fontFamily: SANS,
          fontWeight: 700,
          fontSize: 28,
          color: C.forest,
        }}
      >
        raysto ✳
        <span style={{ marginLeft: 22, fontWeight: 500, fontSize: 23, opacity: swap, display: "inline-block", transform: `translateY(${(1 - swap) * 14}px)` }}>
          {label}
        </span>
      </div>
      <div
        style={{
          position: "absolute",
          right: 50,
          bottom: 30,
          padding: "8px 18px",
          borderRadius: 99,
          background: `${C.cream}e8`,
          border: `2px solid ${C.paypalSky}`,
          color: C.paypal,
          fontFamily: SANS,
          fontWeight: 700,
          fontSize: 20,
        }}
      >
        PayPal Sandbox · real test payments
      </div>
      <div style={{ position: "absolute", left: 0, bottom: 0, height: 7, width: `${(f / TOTAL) * 100}%`, background: C.limeHot }} />
    </AbsoluteFill>
  );
};

export const Promo: React.FC = () => {
  const music = (frame: number) => {
    const speaking = voiceWindows.some(([a, b]) => frame >= a - 6 && frame <= b + 6);
    const fade = Math.min(tween(frame, 0, 20), 1 - tween(frame, TOTAL - 60, TOTAL));
    return fade * (speaking ? 0.11 : 0.26);
  };
  return (
    <AbsoluteFill style={{ background: C.paper }}>
      <Backdrop />
      {SCENES.map((s) => {
        const View = SCENE_VIEW[s.id];
        return (
          <Sequence key={s.id} from={starts[s.id]} durationInFrames={s.frames} premountFor={30}>
            <Shot duration={s.frames} enter={s.id === "intro" ? 0 : 14} exit={s.id === "outro" ? 30 : 12}>
              <View />
            </Shot>
          </Sequence>
        );
      })}
      <Overlay />
      {SCENES.map((s) => (
        <Sequence key={`voice-${s.id}`} from={starts[s.id] + VOICE_DELAY} layout="none">
          <Audio src={staticFile(`promo/voice/${s.id}.wav`)} volume={1} />
        </Sequence>
      ))}
      <Audio src={staticFile("promo/music.mp3")} volume={music} />
    </AbsoluteFill>
  );
};

export const PromoRoot: React.FC = () => (
  <Composition id="RaystoPromo60" component={Promo} durationInFrames={TOTAL} fps={FPS} width={1920} height={1080} />
);
