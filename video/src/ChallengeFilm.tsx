import React from "react";
import {
  AbsoluteFill,
  Composition,
  Easing,
  Img,
  interpolate,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { Audio, Video } from "@remotion/media";

const ink = "#173F35",
  paper = "#F6F7F2",
  lime = "#D7F978",
  mint = "#E6EDE2",
  peach = "#F3E8DB";
const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const tween = (f: number, a: number, b: number, x = 0, y = 1) =>
  interpolate(f, [a, b], [x, y], {
    ...clamp,
    easing: Easing.bezier(0.16, 0.8, 0.22, 1),
  });
const enter = (f: number, d = 0) =>
  spring({ frame: f - d, fps: 30, config: { damping: 23, stiffness: 160 } });
const cuts = [
  0, 120, 300, 510, 750, 930, 1110, 1350, 1590, 1800, 2040, 2190, 2340,
];
const names = [
  "THE GROUP PROBLEM",
  "ONE SHARED VISIT",
  "THE REAL REQUEST",
  "GEMINI → TOOLS → QUOTE",
  "HUMAN APPROVAL",
  "CONNECTED SERVICE",
  "THE MANAGER’S COPILOT",
  "EXACT SHARES",
  "PAYPAL HANDOFF",
  "DEMO SETTLEMENT",
  "PAYPAL MCP",
  "RAYSTO",
];
const Pill: React.FC<{
  children: React.ReactNode;
  fill?: string;
  color?: string;
}> = ({ children, fill = lime, color = ink }) => (
  <div
    style={{
      padding: "12px 20px",
      borderRadius: 40,
      background: fill,
      color,
      fontSize: 22,
      fontWeight: 700,
      whiteSpace: "nowrap",
    }}
  >
    {children}
  </div>
);
const Star: React.FC<{ size?: number; color?: string }> = ({
  size = 42,
  color = lime,
}) => (
  <svg width={size} height={size} viewBox="0 0 100 100">
    {[0, 45, 90, 135].map((a) => (
      <rect
        key={a}
        x="43"
        y="3"
        width="14"
        height="94"
        rx="7"
        transform={`rotate(${a} 50 50)`}
        fill={color}
      />
    ))}
  </svg>
);
const Wordmark: React.FC<{ light?: boolean }> = ({ light = true }) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 8,
      color: light ? paper : ink,
      fontSize: 42,
      fontWeight: 700,
      letterSpacing: -2,
    }}
  >
    raysto
    <Star size={29} color={light ? lime : ink} />
  </div>
);

const Stage: React.FC<{
  dark?: boolean;
  children: React.ReactNode;
  warm?: boolean;
}> = ({ dark = false, children, warm = false }) => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        background: dark ? ink : warm ? peach : paper,
        color: dark ? paper : ink,
        overflow: "hidden",
      }}
    >
      <svg
        width="1920"
        height="1080"
        style={{ position: "absolute", opacity: dark ? 0.09 : 0.08 }}
      >
        <path
          d="M-80 770 C250 200 750 1120 1200 610 S1700 10 2070 380"
          fill="none"
          stroke={dark ? lime : ink}
          strokeWidth="2"
        />
        <circle
          cx={1520 + Math.sin(f / 90) * 30}
          cy="450"
          r="540"
          fill="none"
          stroke={dark ? lime : ink}
          strokeWidth="2"
        />
      </svg>
      {children}
    </AbsoluteFill>
  );
};
const Title: React.FC<{
  children: React.ReactNode;
  x?: number;
  y?: number;
  size?: number;
  width?: number;
  center?: boolean;
  delay?: number;
}> = ({
  children,
  x = 80,
  y = 160,
  size = 72,
  width = 1760,
  center = false,
  delay = 0,
}) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width,
        fontSize: size,
        fontWeight: 700,
        lineHeight: 1.1,
        letterSpacing: -size * 0.05,
        textAlign: center ? "center" : "left",
        transform: `translateY(${(1 - enter(f, delay)) * 45}px)`,
        opacity: tween(f, delay, delay + 10),
      }}
    >
      {children}
    </div>
  );
};
const Note: React.FC<{ children: React.ReactNode; dark?: boolean }> = ({
  children,
  dark = false,
}) => (
  <div
    style={{
      position: "absolute",
      bottom: 50,
      left: 100,
      right: 100,
      fontSize: 27,
      lineHeight: 1.35,
      textAlign: "center",
      color: dark ? "#CEDDD3" : "#526E62",
    }}
  >
    {children}
  </div>
);

// All UI windows below display actual app/browser pixels. Motion is editorial.
const Capture: React.FC<{
  file: string;
  x: number;
  y: number;
  w: number;
  h: number;
  sourceW?: number;
  offset?: number;
  pan?: number;
  rotate?: number;
  delay?: number;
  label?: string;
}> = ({
  file,
  x,
  y,
  w,
  h,
  sourceW = w,
  offset = 0,
  pan = 0,
  rotate = 0,
  delay = 0,
  label,
}) => {
  const f = useCurrentFrame(),
    p = enter(f, delay);
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width: w,
        height: h,
        overflow: "hidden",
        background: paper,
        borderRadius: 28,
        boxShadow: "0 26px 65px #071d2630",
        border: "1px solid #173f3524",
        transform: `translateY(${(1 - p) * 95}px) scale(${0.93 + 0.07 * p}) rotate(${rotate}deg)`,
        opacity: tween(f, delay, delay + 8),
      }}
    >
      {label && (
        <div
          style={{
            height: 46,
            padding: "0 20px",
            display: "flex",
            alignItems: "center",
            gap: 10,
            background: mint,
            color: ink,
            fontSize: 15,
            fontWeight: 700,
            letterSpacing: 1.3,
          }}
        >
          <span
            style={{
              width: 8,
              height: 8,
              background: "#7d9772",
              borderRadius: 10,
            }}
          />
          {label}
        </div>
      )}
      <div
        style={{
          position: "relative",
          height: h - (label ? 46 : 0),
          overflow: "hidden",
        }}
      >
        <Img
          src={staticFile(`screens/${file}.png`)}
          style={{
            position: "absolute",
            width: sourceW,
            maxWidth: "none",
            left: (w - sourceW) / 2,
            top: offset + tween(f, delay, delay + 160, 0, pan),
          }}
        />
      </div>
    </div>
  );
};
const PathArrow: React.FC<{
  x: number;
  y: number;
  length?: number;
  delay?: number;
  dark?: boolean;
}> = ({ x, y, length = 200, delay = 20, dark = false }) => {
  const f = useCurrentFrame();
  return (
    <svg
      width={length}
      height="80"
      style={{
        position: "absolute",
        left: x,
        top: y,
        opacity: tween(f, delay, delay + 10),
      }}
      viewBox={`0 0 ${length} 80`}
    >
      <path
        d={`M5 40 H${length - 18} M${length - 40} 18 L${length - 15} 40 L${length - 40} 62`}
        pathLength="1"
        strokeDasharray="1"
        strokeDashoffset={1 - tween(f, delay, delay + 25)}
        stroke={dark ? lime : ink}
        strokeWidth="4"
        fill="none"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
};
const Tap: React.FC<{ x: number; y: number; at: number }> = ({ x, y, at }) => {
  const f = useCurrentFrame(),
    p = tween(f, at, at + 20);
  return (
    <div
      style={{
        position: "absolute",
        left: x - 35,
        top: y - 35,
        width: 70,
        height: 70,
        border: "4px solid #98c650",
        borderRadius: 60,
        transform: `scale(${0.4 + p * 1.2})`,
        opacity: f < at ? 0 : 1 - p,
      }}
    />
  );
};

const Hook = () => {
  const f = useCurrentFrame();
  return (
    <Stage dark>
      <Capture
        file="conversation"
        x={-170}
        y={155}
        w={420}
        h={840}
        rotate={-12}
      />
      <Capture
        file="kitchen"
        x={1680}
        y={180}
        w={390}
        h={800}
        rotate={12}
        delay={4}
      />
      <div
        style={{
          position: "absolute",
          left: 360,
          top: 240,
          width: 1200,
          textAlign: "center",
          fontSize: 100,
          fontWeight: 700,
          letterSpacing: -5,
          lineHeight: 1.1,
        }}
      >
        <div
          style={{
            opacity: tween(f, 0, 12),
            transform: `translateY(${(1 - enter(f)) * 65}px)`,
          }}
        >
          Dinner is a
        </div>
        <div
          style={{
            color: lime,
            opacity: tween(f, 8, 22),
            transform: `translateY(${(1 - enter(f, 8)) * 65}px)`,
          }}
        >
          group decision.
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          left: 470,
          top: 570,
          width: 980,
          fontSize: 35,
          lineHeight: 1.45,
          textAlign: "center",
          opacity: tween(f, 27, 42),
        }}
      >
        Preferences. Budgets. Staff. Payments.
        <br />
        What if one conversation connected them?
      </div>
      <div
        style={{
          position: "absolute",
          left: 845,
          top: 805,
          transform: `rotate(${f * 0.5}deg) scale(${enter(f, 30)})`,
        }}
      >
        <Star size={180} />
      </div>
    </Stage>
  );
};

const SharedVisit = () => {
  const f = useCurrentFrame();
  return (
    <Stage warm>
      <Title y={145} size={70}>
        Meet the table. Keep everyone in context.
      </Title>
      <div
        style={{
          position: "absolute",
          left: 90,
          top: 325,
          width: 760,
          height: 480,
          borderRadius: 220,
          background: ink,
          transform: `scale(${0.9 + enter(f) * 0.1})`,
          boxShadow: "0 25px 50px #173f3520",
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 35,
            border: "1px dashed #b1c4ab70",
            borderRadius: 200,
          }}
        />
        <div
          style={{
            textAlign: "center",
            paddingTop: 145,
            color: paper,
            fontSize: 32,
          }}
        >
          GARDEN 1
          <div
            style={{
              fontSize: 86,
              color: lime,
              fontWeight: 700,
              letterSpacing: -6,
            }}
          >
            2 diners
          </div>
        </div>
        {["DINER A", "DINER B", "WAITER"].map((label, i) => (
          <div
            key={label}
            style={{
              position: "absolute",
              left: [40, 470, 255][i],
              top: [-34, -34, 416][i],
              background: i === 2 ? lime : paper,
              color: ink,
              borderRadius: 60,
              padding: "20px 32px",
              fontSize: 25,
              fontWeight: 700,
              transform: `translateY(${(1 - enter(f, 12 + i * 8)) * 40}px)`,
              opacity: tween(f, 12 + i * 8, 20 + i * 8),
            }}
          >
            {label}
          </div>
        ))}
      </div>
      <Capture
        file="conversation"
        x={1030}
        y={280}
        w={800}
        h={610}
        sourceW={800}
        offset={-70}
        pan={-50}
        label="ACTUAL ROOM / CLEAR AUDIENCE"
        delay={10}
      />
      <PathArrow x={840} y={530} length={170} />
      <Note>
        A room belongs to this visit. Diners and the assigned waiter share its
        context.
      </Note>
    </Stage>
  );
};

const Ask = () => {
  const f = useCurrentFrame();
  const prompt =
    "“Two of us. We prefer vegetarian food. Under $30. Something to share.”";
  return (
    <Stage dark>
      <div style={{position:'absolute',left:1150,top:135,width:450,height:850,overflow:'hidden',borderRadius:28,boxShadow:'0 26px 65px #071d2660',transform:`rotate(2deg) translateY(${(1-enter(f))*70}px)`}}>
        <Video src={staticFile('native-room-scroll.mp4')} playbackRate={1.7} muted style={{width:450,display:'block'}} />
      </div>
      <div
        style={{
          position: "absolute",
          left: 95,
          top: 200,
          display: "flex",
          gap: 12,
        }}
      >
        <Pill>ONE NATURAL REQUEST</Pill>
        <Pill fill="#35594C" color={paper}>
          2 diners · $30
        </Pill>
      </div>
      <Title x={95} y={330} width={950} size={77}>
        {prompt.slice(0, Math.floor(tween(f, 5, 105, 0, prompt.length)))}
      </Title>
      <div
        style={{
          position: "absolute",
          left: 100,
          top: 750,
          width: 920,
          fontSize: 31,
          color: "#c7d8ce",
          opacity: tween(f, 105, 125),
        }}
      >
        Menu, budget and shared preferences stay connected.
        <br />
        Raysto is asked to act on the restaurant’s menu.
      </div>
      <Note dark>Actual Android screen recording · connected QA room · historical Gemini response.</Note>
    </Stage>
  );
};

const ToolRun = () => {
  const f = useCurrentFrame();
  const steps = [
    ["read_room", "Who is here? What did they share?"],
    ["read_menu", "Read the restaurant’s actual catalogue."],
    ["read_menu", "Resolve the selected menu items."],
    ["quote_basket", "Ask the server to price the basket."],
  ];
  return (
    <Stage>
      <Title y={145} size={68}>
        Gemini calls tools. Raysto prices the basket.
      </Title>
      <div style={{ position: "absolute", left: 90, top: 290, width: 750 }}>
        {steps.map(([tool, desc], i) => (
          <div
            key={i}
            style={{
              marginBottom: 17,
              padding: "22px 26px",
              borderRadius: 23,
              background: i === 3 ? ink : mint,
              color: i === 3 ? paper : ink,
              opacity: tween(f, i * 24, i * 24 + 12),
              transform: `translateX(${(1 - enter(f, i * 24)) * -90}px)`,
            }}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                fontSize: 28,
                fontWeight: 700,
              }}
            >
              <span>{tool}</span>
              <span style={{ fontSize: 21, color: i === 3 ? lime : "#57794e" }}>
                ✓ completed
              </span>
            </div>
            <div style={{ fontSize: 23, marginTop: 8, opacity: 0.8 }}>
              {desc}
            </div>
          </div>
        ))}
      </div>
      <Capture
        file="ai-basket"
        x={955}
        y={280}
        w={865}
        h={650}
        sourceW={865}
        offset={-435}
        pan={-95}
        label="ACTUAL GEMINI ANSWER / SERVER-PRICED BASKET"
        delay={35}
      />
      <div
        style={{
          position: "absolute",
          left: 105,
          top: 850,
          display: "flex",
          gap: 14,
          opacity: tween(f, 115, 135),
        }}
      >
        <Pill>3 real menu items</Pill>
        <Pill fill={peach}>$27 / $30 budget</Pill>
      </div>
      <Note>
        Actual recorded tool sequence. Prices come from Raysto’s backend.
      </Note>
    </Stage>
  );
};

const Approve = () => {
  return (
    <Stage warm>
      <Title y={145} size={70}>
        A proposal becomes an order only after review.
      </Title>
      <Capture
        file="review-order"
        x={110}
        y={280}
        w={810}
        h={665}
        sourceW={760}
        offset={-480}
        label="NATIVE REVIEW DIALOG / HISTORICAL REPLAY"
      />
      <PathArrow x={945} y={520} length={160} delay={45} />
      <Capture
        file="kitchen"
        x={1130}
        y={280}
        w={660}
        h={665}
        sourceW={660}
        offset={-80}
        label="ACTUAL ORDER #2 / KITCHEN QUEUE"
        delay={65}
      />
      <Tap x={670} y={840} at={65} />
      <Note>
        The table host confirms the exact $27 basket. The kitchen receives the
        same items.
      </Note>
    </Stage>
  );
};

const Service = () => {
  const f = useCurrentFrame();
  return (
    <Stage dark>
      <Title y={140} size={70}>
        Service stays inside the shared visit.
      </Title>
      <Capture
        file="service-handoff"
        x={95}
        y={270}
        w={760}
        h={675}
        sourceW={760}
        offset={-180}
        pan={-80}
        label="PERSISTED ROOM EVENTS"
      />
      <div style={{ position: "absolute", left: 1000, top: 280, width: 760 }}>
        {[
          ["01", "Host approval recorded"],
          ["02", "Order sent to the kitchen"],
          ["03", "Bill request reaches staff"],
        ].map(([n, t], i) => (
          <div
            key={n}
            style={{
              marginBottom: 30,
              padding: "30px 34px",
              borderBottom: "1px solid #77938760",
              display: "flex",
              gap: 30,
              alignItems: "center",
              transform: `translateX(${(1 - enter(f, 15 + i * 20)) * 70}px)`,
              opacity: tween(f, 15 + i * 20, 28 + i * 20),
            }}
          >
            <span style={{ fontSize: 24, color: lime }}>{n}</span>
            <span style={{ fontSize: 35, fontWeight: 500 }}>{t}</span>
          </div>
        ))}
      </div>
      <div
        style={{
          position: "absolute",
          left: 1035,
          top: 790,
          display: "flex",
          gap: 12,
        }}
      >
        <Pill>DINERS</Pill>
        <Pill>WAITER</Pill>
        <Pill>KITCHEN</Pill>
      </div>
      <Note dark>
        One visit connects the conversation, service requests and operational
        records.
      </Note>
    </Stage>
  );
};

const Manager = () => {
  const f = useCurrentFrame();
  return (
    <Stage>
      <div
        style={{
          position: "absolute",
          left: 90,
          top: 145,
          fontSize: 26,
          fontWeight: 700,
          color: "#597347",
        }}
      >
        THE MANAGER ASKS
      </div>
      <Title y={195} size={58}>
        “Who requested the bill and still has money to pay?”
      </Title>
      <Capture
        file="manager-assistant"
        x={80}
        y={330}
        w={1760}
        h={620}
        sourceW={1760}
        offset={tween(f, 0, 130, -140, -240)}
        label="CONNECTED CONSOLE / AG GRID + AG STUDIO"
      />
      <div
        style={{
          position: "absolute",
          right: 130,
          top: 410,
          padding: "17px 28px",
          background: ink,
          color: paper,
          borderRadius: 18,
          fontSize: 27,
          fontWeight: 700,
          opacity: tween(f, 95, 115),
          boxShadow: "0 10px 30px #173f3530",
        }}
      >
        Garden 1 · $27 outstanding
      </div>
      <Note>
        Natural-language intent selects matching table records and explains the
        same balance.
      </Note>
    </Stage>
  );
};

const Shares = () => {
  const f = useCurrentFrame();
  return (
    <Stage warm>
      <Title y={145} size={70}>
        “Split our remaining bill equally.”
      </Title>
      <Capture
        file="share"
        x={90}
        y={280}
        w={780}
        h={675}
        sourceW={780}
        offset={-400}
        pan={-70}
        label="ACTUAL AI SHARE PROPOSAL"
      />
      <div style={{ position: "absolute", left: 1000, top: 285, width: 800 }}>
        <div style={{ fontSize: 27, color: "#5c7468", marginBottom: 18 }}>
          YOUR SHARE, CHARGE BY CHARGE
        </div>
        {[
          ["Shared starter", "$3.00"],
          ["Garden pasta", "$6.00"],
          ["Roasted vegetables", "$4.50"],
        ].map(([name, amount], i) => (
          <div
            key={name}
            style={{
              display: "flex",
              justifyContent: "space-between",
              padding: "26px 0",
              fontSize: 32,
              borderBottom: "1px solid #173f3530",
              opacity: tween(f, 20 + i * 18, 34 + i * 18),
              transform: `translateY(${(1 - enter(f, 20 + i * 18)) * 35}px)`,
            }}
          >
            <span>{name}</span>
            <strong>{amount}</strong>
          </div>
        ))}
        <div
          style={{
            marginTop: 38,
            padding: 28,
            borderRadius: 30,
            background: ink,
            color: paper,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            transform: `scale(${0.85 + enter(f, 85) * 0.15})`,
            opacity: tween(f, 85, 95),
          }}
        >
          <span style={{ fontSize: 27 }}>Reviewed total</span>
          <strong style={{ fontSize: 77, letterSpacing: -4, color: lime }}>
            $13.50
          </strong>
        </div>
      </div>
      <Note>
        Deterministic allocation. Each payer reviews their own amount.
      </Note>
    </Stage>
  );
};

const PayPal = () => {
  return (
    <Stage>
      <Title y={145} size={69}>
        The payer stays in control.
      </Title>
      <Sequence durationInFrames={95}>
        <Capture
          file="review-share"
          x={170}
          y={255}
          w={780}
          h={700}
          sourceW={650}
          offset={-360}
          label="NATIVE SHARE REVIEW / DEMO REPLAY"
        />
        <div
          style={{
            position: "absolute",
            left: 1100,
            top: 370,
            width: 650,
            fontSize: 54,
            fontWeight: 700,
            lineHeight: 1.2,
          }}
        >
          Approve this share.
          <br />
          <span style={{ color: "#63812e" }}>Then open PayPal.</span>
        </div>
        <div
          style={{
            position: "absolute",
            left: 1110,
            top: 640,
            width: 610,
            fontSize: 28,
            lineHeight: 1.5,
          }}
        >
          AI prepares the allocation.
          <br />
          It cannot approve a purchase for you.
        </div>
        <PathArrow x={960} y={555} length={120} />
      </Sequence>
      <Sequence from={95}>
        <Capture
          file="paypal-handoff"
          x={720}
          y={265}
          w={850}
          h={690}
          sourceW={1440}
          offset={-92}
          label="ACTUAL PAYPAL SANDBOX HANDOFF"
        />
        <div
          style={{
            position: "absolute",
            left: 100,
            top: 375,
            width: 510,
            fontSize: 53,
            fontWeight: 700,
            lineHeight: 1.2,
          }}
        >
          A real provider.
          <br />A separate approval.
        </div>
        <div
          style={{
            position: "absolute",
            left: 105,
            top: 610,
            width: 500,
            fontSize: 28,
            lineHeight: 1.5,
          }}
        >
          USD 13.50 checkout opened.
          <br />
          No buyer charge in this capture.
        </div>
      </Sequence>
      <Note>
        The PayPal Sandbox handoff is real. The following settlement is simulated.
      </Note>
    </Stage>
  );
};

const Settlement = () => {
  const f = useCurrentFrame();
  const first = f >= 75,
    second = f >= 155;
  return (
    <Stage dark>
      <div
        style={{
          position: "absolute",
          left: 80,
          top: 145,
          display: "flex",
          gap: 18,
        }}
      >
        <Pill fill={peach}>DEMO · SIMULATED PAYMENT OUTCOME</Pill>
      </div>
      <Title y={235} size={78}>
        Two approvals. One shared balance.
      </Title>
      {[
        ["DINER A", first, 150],
        ["DINER B", second, 1180],
      ].map(([name, paid, x]) => (
        <div
          key={String(name)}
          style={{
            position: "absolute",
            left: Number(x),
            top: 440,
            width: 580,
            height: 370,
            padding: 40,
            background: paid ? lime : "#31574a",
            color: paid ? ink : paper,
            borderRadius: 40,
            transform: `scale(${paid ? 1 + Math.sin(tween(f, name === "DINER A" ? 75 : 155, name === "DINER A" ? 100 : 180) * Math.PI) * 0.035 : 1})`,
          }}
        >
          <div style={{ fontSize: 25, fontWeight: 700, letterSpacing: 2 }}>
            {name}
          </div>
          <div
            style={{
              fontSize: 97,
              fontWeight: 700,
              letterSpacing: -6,
              marginTop: 25,
            }}
          >
            $13.50
          </div>
          <div style={{ fontSize: 29, marginTop: 26 }}>
            {paid ? "✓ Demo payment confirmed" : "Awaiting individual approval"}
          </div>
        </div>
      ))}
      <div
        style={{
          position: "absolute",
          left: 765,
          top: 515,
          width: 390,
          textAlign: "center",
        }}
      >
        <div style={{ fontSize: 22, color: "#c1d0c5" }}>REMAINING BALANCE</div>
        <div
          style={{
            fontSize: 92,
            fontWeight: 700,
            letterSpacing: -5,
            color: lime,
            marginTop: 22,
          }}
        >
          {second ? "$0.00" : first ? "$13.50" : "$27.00"}
        </div>
        <div style={{ fontSize: 22, marginTop: 20, color: "#c1d0c5" }}>
          {second
            ? "Settled in this illustration"
            : "One bill, exact allocations"}
        </div>
      </div>
      <Note dark>
        This outcome is simulated for the walkthrough. Real buyer capture
        remains a separate acceptance step.
      </Note>
    </Stage>
  );
};

const MCP = () => {
  const f = useCurrentFrame();
  return (
    <Stage>
      <Title y={145} size={68}>
        Payment uncertainty needs evidence.
      </Title>
      <div
        style={{
          position: "absolute",
          left: 100,
          top: 305,
          width: 700,
          fontSize: 46,
          lineHeight: 1.25,
          fontWeight: 700,
        }}
      >
        “Did my payment finish?”
      </div>
      <div
        style={{
          position: "absolute",
          left: 100,
          top: 485,
          width: 710,
          fontSize: 30,
          lineHeight: 1.5,
        }}
      >
        Raysto can inspect the authorized PayPal order through the official MCP
        server.
        <br />
        <br />
        <strong>Read-only tools.</strong> No autonomous capture.
      </div>
      <div
        style={{
          position: "absolute",
          left: 945,
          top: 290,
          width: 865,
          background: ink,
          color: paper,
          borderRadius: 32,
          padding: 40,
          boxShadow: "0 24px 60px #173f3525",
          transform: `translateY(${(1 - enter(f, 10)) * 60}px)`,
          opacity: tween(f, 10, 22),
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            fontSize: 22,
            color: lime,
            marginBottom: 30,
          }}
        >
          <span>VERIFIED DIRECT MCP READ</span>
          <Star size={29} />
        </div>
        {[
          ["provider", "PayPal Sandbox"],
          ["transport", "official MCP · stdio"],
          ["tool", "get_order"],
          ["amount", "USD 13.50"],
          ["result", "PAYER_ACTION_REQUIRED"],
          ["money moved", "none"],
        ].map(([a, b], i) => (
          <div
            key={a}
            style={{
              display: "flex",
              justifyContent: "space-between",
              borderBottom: "1px solid #ffffff20",
              padding: "17px 0",
              fontSize: 25,
              opacity: tween(f, 15 + i * 9, 25 + i * 9),
            }}
          >
            <span style={{ color: "#b6cbbf" }}>{a}</span>
            <strong style={{ color: i === 4 ? lime : paper }}>{b}</strong>
          </div>
        ))}
      </div>
      <Note>
        Recorded direct MCP verification. End-to-end Gemini → MCP chat
        acceptance is still pending.
      </Note>
    </Stage>
  );
};

const Ending = () => {
  const f = useCurrentFrame();
  return (
    <Stage dark>
      <Title y={235} size={105} center>
        Shared decisions.
        <br />
        Individual control.
      </Title>
      <div
        style={{
          position: "absolute",
          left: 210,
          top: 580,
          display: "flex",
          gap: 25,
          alignItems: "center",
        }}
      >
        {["CONVERSATION", "GEMINI TOOLS", "HUMAN REVIEW", "PAYPAL"].map(
          (s, i) => (
            <React.Fragment key={s}>
              <div
                style={{
                  padding: "22px 26px",
                  border: "1px solid #a8c49b65",
                  borderRadius: 18,
                  fontSize: 24,
                  fontWeight: 700,
                  color: i === 3 ? lime : paper,
                  opacity: tween(f, 12 + i * 7, 22 + i * 7),
                  transform: `translateY(${(1 - enter(f, 12 + i * 7)) * 35}px)`,
                }}
              >
                {s}
              </div>
              {i < 3 && <span style={{ color: lime, fontSize: 35 }}>→</span>}
            </React.Fragment>
          ),
        )}
      </div>
      <div
        style={{
          position: "absolute",
          left: 80,
          right: 80,
          top: 790,
          textAlign: "center",
          fontSize: 36,
          opacity: tween(f, 40, 55),
        }}
      >
        AI at the table. PayPal at checkout.
      </div>
      <div
        style={{
          position: "absolute",
          left: 80,
          right: 80,
          top: 875,
          textAlign: "center",
          fontSize: 27,
          color: "#adc5b7",
          opacity: tween(f, 48, 65),
        }}
      >
        rays.to · github.com/FouadABT/raysto
      </div>
    </Stage>
  );
};

const Challenge = () => {
  const f = useCurrentFrame();
  const index = Math.max(
    0,
    cuts.findIndex((c, i) => i < cuts.length - 1 && f >= c && f < cuts[i + 1]),
  );
  const scenes = [
    Hook,
    SharedVisit,
    Ask,
    ToolRun,
    Approve,
    Service,
    Manager,
    Shares,
    PayPal,
    Settlement,
    MCP,
    Ending,
  ];
  const dark = [0, 2, 5, 9, 11].includes(index);
  return (
    <AbsoluteFill
      style={{ fontFamily: "Jakarta, sans-serif", background: ink }}
    >
      <Audio src={staticFile("challenge-score.m4a")} volume={0.94} />
      {scenes.map((Scene, i) => (
        <Sequence
          key={i}
          from={cuts[i]}
          durationInFrames={cuts[i + 1] - cuts[i]}
        >
          <Scene />
        </Sequence>
      ))}
      <div
        style={{
          position: "absolute",
          left: 80,
          top: 42,
          right: 80,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
        }}
      >
        <Wordmark light={dark} />
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 20,
            color: dark ? "#d3e1d8" : ink,
            fontSize: 19,
            fontWeight: 700,
            letterSpacing: 1.5,
          }}
        >
          <span>
            {String(index + 1).padStart(2, "0")} / {names[index]}
          </span>
          <span
            style={{
              padding: "9px 15px",
              borderRadius: 8,
              background: dark ? "#365b4c" : mint,
              fontSize: 16,
            }}
          >
            DEMO WALKTHROUGH
          </span>
        </div>
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          height: 5,
          background: "#9bc652",
          width: `${(f / 2339) * 100}%`,
        }}
      />
      {cuts.slice(1, -1).map((c) => {
        if (f < c - 4 || f > c + 5) return null;
        const x = interpolate(f, [c - 4, c, c + 5], [-2500, -80, 2300], clamp);
        return (
          <div
            key={c}
            style={{
              position: "absolute",
              left: x,
              top: -120,
              width: 2250,
              height: 1400,
              transform: "rotate(-7deg)",
              background: lime,
            }}
          />
        );
      })}
      <AbsoluteFill
        style={{ background: ink, opacity: tween(f, 2320, 2339) }}
      />
    </AbsoluteFill>
  );
};

export const ChallengeComposition = () => (
  <Composition
    id="RaystoChallenge"
    component={Challenge}
    durationInFrames={2340}
    fps={30}
    width={1920}
    height={1080}
  />
);
