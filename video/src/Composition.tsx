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
import { Audio } from "@remotion/media";
import { loadFont } from "@remotion/fonts";

const C = {
  paper: "#F6F7F2",
  forest: "#173F35",
  lime: "#D7F978",
  peach: "#F3E8DB",
  mint: "#E6EDE2",
};
for (const [weight, name] of [
  [400, "Regular"],
  [500, "Medium"],
  [700, "Bold"],
] as const) {
  loadFont({
    family: "Jakarta",
    url: staticFile(`fonts/PlusJakartaSans-${name}.ttf`),
    weight: String(weight),
  });
}
const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const ease = (f: number, start: number, end: number, a = 0, b = 1) =>
  interpolate(f, [start, end], [a, b], {
    ...clamp,
    easing: Easing.bezier(0.18, 0.85, 0.24, 1),
  });
const pop = (f: number, delay = 0) =>
  spring({
    frame: f - delay,
    fps: 30,
    config: { damping: 19, stiffness: 150, mass: 0.8 },
  });

const Asterisk: React.FC<{
  size?: number;
  color?: string;
  rotation?: number;
}> = ({ size = 40, color = C.forest, rotation = 0 }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    style={{ transform: `rotate(${rotation}deg)`, flexShrink: 0 }}
  >
    {Array.from({ length: 8 }, (_, i) => (
      <rect
        key={i}
        x="42"
        y="5"
        width="16"
        height="90"
        rx="8"
        fill={color}
        transform={`rotate(${i * 22.5} 50 50)`}
      />
    ))}
  </svg>
);
const Brand: React.FC<{ dark?: boolean; large?: boolean }> = ({
  dark = false,
  large = false,
}) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: large ? 14 : 6,
      fontSize: large ? 100 : 42,
      fontWeight: 700,
      letterSpacing: large ? -7 : -2.5,
      color: dark ? C.paper : C.forest,
    }}
  >
    raysto
    <Asterisk size={large ? 66 : 28} color={dark ? C.lime : C.forest} />
  </div>
);

const Backdrop: React.FC<{
  dark?: boolean;
  peach?: boolean;
  children?: React.ReactNode;
}> = ({ dark = false, peach = false, children }) => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        background: dark ? C.forest : peach ? C.peach : C.paper,
        color: dark ? C.paper : C.forest,
        overflow: "hidden",
      }}
    >
      <svg
        width="1920"
        height="1080"
        style={{ position: "absolute", opacity: dark ? 0.1 : 0.12 }}
      >
        <circle
          cx={1560 + Math.sin(f / 90) * 20}
          cy="410"
          r="590"
          fill="none"
          stroke={dark ? C.lime : C.forest}
          strokeWidth="2"
        />
        <circle
          cx="1560"
          cy="410"
          r="640"
          fill="none"
          stroke={dark ? C.lime : C.forest}
          strokeWidth="1"
          strokeDasharray="3 15"
        />
        <path
          d="M-90 890 Q300 600 650 930 T1300 970"
          fill="none"
          stroke={dark ? C.lime : C.forest}
          strokeWidth="2"
        />
      </svg>
      {children}
    </AbsoluteFill>
  );
};
const Label: React.FC<{ index: string; text: string; dark?: boolean }> = ({
  index,
  text,
  dark = false,
}) => (
  <div
    style={{
      position: "absolute",
      left: 84,
      top: 54,
      right: 84,
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      color: dark ? C.paper : C.forest,
    }}
  >
    <Brand dark={dark} />
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 15,
        fontSize: 19,
        fontWeight: 700,
        letterSpacing: 3,
      }}
    >
      <span style={{ opacity: 0.6 }}>{index}</span>
      <span>{text}</span>
      <span
        style={{
          width: 8,
          height: 8,
          background: dark ? C.lime : C.forest,
          borderRadius: "50%",
        }}
      />
    </div>
  </div>
);
const Footer: React.FC<{ text?: string; dark?: boolean }> = ({
  text = "NATIVE APP CAPTURES  /  SANDBOX WALKTHROUGH",
  dark = false,
}) => (
  <div
    style={{
      position: "absolute",
      left: 86,
      bottom: 37,
      fontSize: 17,
      letterSpacing: 2.1,
      fontWeight: 500,
      color: dark ? "#B6C9BF" : "#5C756B",
    }}
  >
    {text}
  </div>
);
const Headline: React.FC<{
  lines: string[];
  top?: number;
  left?: number;
  size?: number;
  width?: number;
  delay?: number;
  accent?: number;
  dark?: boolean;
}> = ({
  lines,
  top = 250,
  left = 90,
  size = 104,
  width = 900,
  delay = 0,
  accent = -1,
  dark = false,
}) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        position: "absolute",
        top,
        left,
        width,
        fontSize: size,
        fontWeight: 700,
        lineHeight: 1.08,
        letterSpacing: -size * 0.055,
      }}
    >
      {lines.map((line, i) => (
        <div key={line} style={{ overflow: "hidden", paddingBottom: 9 }}>
          <div
            style={{
              transform: `translateY(${(1 - ease(f, delay + i * 4, delay + 19 + i * 4)) * 135}%)`,
              color: accent === i ? (dark ? C.lime : "#557929") : undefined,
            }}
          >
            {line}
          </div>
        </div>
      ))}
    </div>
  );
};
const Copy: React.FC<{
  children: React.ReactNode;
  top: number;
  left?: number;
  width?: number;
  dark?: boolean;
  delay?: number;
}> = ({ children, top, left = 96, width = 720, dark = false, delay = 15 }) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        position: "absolute",
        left,
        top,
        width,
        fontSize: 30,
        lineHeight: 1.55,
        fontWeight: 400,
        color: dark ? "#C5D4CB" : "#506D61",
        opacity: ease(f, delay, delay + 16),
        transform: `translateY(${ease(f, delay, delay + 20, 20, 0)}px)`,
      }}
    >
      {children}
    </div>
  );
};
const Tag: React.FC<{
  text: string;
  x: number;
  y: number;
  dark?: boolean;
  delay?: number;
}> = ({ text, x, y, dark = false, delay = 15 }) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        padding: "15px 25px",
        borderRadius: 50,
        background: dark ? C.lime : C.forest,
        color: dark ? C.forest : C.paper,
        fontSize: 22,
        fontWeight: 700,
        transform: `translateY(${(1 - pop(f, delay)) * 30}px) scale(${0.9 + pop(f, delay) * 0.1})`,
        opacity: ease(f, delay, delay + 8),
      }}
    >
      {text}
    </div>
  );
};

// Immutable captures of the actual Flutter widgets, not recreated interface components.
const Phone: React.FC<{
  file: string;
  x?: number;
  y?: number;
  width?: number;
  rotation?: number;
  delay?: number;
}> = ({ file, x = 1250, y = 125, width = 390, rotation = 0, delay = 0 }) => {
  const f = useCurrentFrame();
  const entry = pop(f, delay);
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width,
        height: (width * 1800) / 860,
        borderRadius: 35,
        overflow: "hidden",
        border: "7px solid #fff",
        background: C.paper,
        boxShadow: "0 35px 80px #09281f35, 0 0 0 1px #173f3518",
        transform: `translateY(${(1 - entry) * 100 + Math.sin(f / 45) * 6}px) rotate(${rotation}deg) scale(${0.94 + entry * 0.06})`,
        opacity: ease(f, delay, delay + 8),
      }}
    >
      <Img
        src={staticFile(`screens/${file}.png`)}
        style={{ width: "100%", display: "block" }}
      />
    </div>
  );
};
const Cursor: React.FC<{ x: number; y: number; at?: number }> = ({
  x,
  y,
  at = 30,
}) => {
  const f = useCurrentFrame();
  const entry = ease(f, at - 18, at);
  const ring = interpolate(f, [at, at + 20], [0, 1], clamp);
  return (
    <div
      style={{
        position: "absolute",
        left: x + (1 - entry) * 70,
        top: y + (1 - entry) * 100,
        opacity: ease(f, at - 18, at - 10) * (1 - ease(f, at + 28, at + 45)),
        transform: `scale(${1 - Math.sin((Math.min(Math.max(f - at, 0), 10) / 10) * Math.PI) * 0.16})`,
      }}
    >
      <div
        style={{
          position: "absolute",
          width: 90,
          height: 90,
          left: -45,
          top: -45,
          borderRadius: "50%",
          border: "4px solid #8bb64a",
          opacity: 1 - ring,
          transform: `scale(${0.3 + ring * 1.4})`,
        }}
      />
      <svg width="44" height="57" viewBox="0 0 44 57">
        <path
          d="M4 3 L37 32 L23 34 L32 51 L23 55 L15 37 L4 47 Z"
          fill={C.forest}
          stroke="white"
          strokeWidth="3"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  );
};
// Screen-recorder close-ups use the same original pixels, with editorial framing.
const ScreenCrop: React.FC<{
  file: string;
  x?: number;
  y?: number;
  w?: number;
  h?: number;
  imageWidth?: number;
  offsetY?: number;
  label?: string;
  drift?: number;
}> = ({
  file,
  x = 965,
  y = 170,
  w = 860,
  h = 750,
  imageWidth = 860,
  offsetY = -300,
  label = "RAYSTO / APP DETAIL",
  drift = -12,
}) => {
  const f = useCurrentFrame();
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: y,
        width: w,
        height: h,
        borderRadius: 30,
        background: C.paper,
        boxShadow: "0 32px 80px #09281f25",
        border: "1px solid #173f3522",
        overflow: "hidden",
        transform: `translateY(${(1 - pop(f)) * 75}px) scale(${0.96 + pop(f) * 0.04})`,
        opacity: ease(f, 0, 8),
      }}
    >
      <div
        style={{
          height: 54,
          background: "#EDF0E8",
          display: "flex",
          alignItems: "center",
          padding: "0 24px",
          gap: 8,
          borderBottom: "1px solid #173f3517",
        }}
      >
        {[0, 1, 2].map((i) => (
          <span
            key={i}
            style={{
              width: 9,
              height: 9,
              borderRadius: 10,
              background: i === 0 ? "#7d9970" : "#c6cfc2",
            }}
          />
        ))}
        <span
          style={{
            fontSize: 15,
            color: C.forest,
            letterSpacing: 2,
            marginLeft: 13,
          }}
        >
          {label}
        </span>
      </div>
      <div style={{ position: "relative", height: h - 54, overflow: "hidden" }}>
        <Img
          src={staticFile(`screens/${file}.png`)}
          style={{
            position: "absolute",
            width: imageWidth,
            maxWidth: "none",
            left: (w - imageWidth) / 2,
            top: offsetY + ease(f, 0, 150, 0, drift),
          }}
        />
      </div>
    </div>
  );
};

const Hero: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop dark>
      <Label index="" text="PULL UP A CHAIR" dark />
      <div
        style={{
          position: "absolute",
          width: 840,
          height: 840,
          borderRadius: "50%",
          background: C.lime,
          right: -165,
          top: 120,
          transform: `scale(${ease(f, 0, 34, 0.1, 1)})`,
        }}
      />
      <Img
        src={staticFile("table-art.png")}
        style={{
          position: "absolute",
          width: 970,
          right: -165,
          top: 360,
          transform: `rotate(${ease(f, 0, 70, -22, 2)}deg) translateY(${ease(f, 0, 30, 100, 0)}px)`,
          opacity: ease(f, 7, 25),
        }}
      />
      <Phone
        file="discovery"
        x={1110}
        y={150}
        width={340}
        rotation={-8}
        delay={8}
      />
      <Headline
        lines={["Your table.", "In sync."]}
        top={260}
        size={142}
        width={1000}
        dark
        accent={1}
      />
      <Copy top={625} dark delay={25}>
        Good food. Shared decisions.
        <br />A little help from Raysto.
      </Copy>
      <Tag text="AI AT THE TABLE" x={96} y={790} dark delay={35} />
      <Footer text="A QUICK LOOK AT RAYSTO" dark />
    </Backdrop>
  );
};
const Discover: React.FC = () => (
  <Backdrop peach>
    <Label index="01" text="FIND YOUR TABLE" />
    <Sequence durationInFrames={90}>
      <Headline
        lines={["Good food.", "Good company."]}
        size={100}
        top={270}
        width={1020}
      />
      <Copy top={550}>
        Find a restaurant.
        <br />
        At the table? Start with its QR.
      </Copy>
      <Phone file="discovery" x={1215} y={126} width={390} rotation={3} />
      <Cursor x={1440} y={660} at={62} />
      <div style={{ position: "absolute", left: 100, top: 760 }}>
        <Asterisk size={105} color="#789049" />
      </div>
    </Sequence>
    <Sequence from={90}>
      <Headline lines={["Something", "to share."]} top={280} size={111} />
      <Copy top={580}>
        Browse the actual menu.
        <br />
        Choose together.
      </Copy>
      <ScreenCrop
        file="menu"
        y={160}
        h={790}
        imageWidth={860}
        offsetY={-510}
        label="THE MENU / USD"
        drift={-80}
      />
      <Cursor x={1390} y={500} at={38} />
      <Tag text="MENU → TABLE CONVERSATION" x={96} y={760} />
    </Sequence>
    <Footer />
  </Backdrop>
);
const Conversation: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop>
      <Label index="02" text="GET EVERYONE TOGETHER" />
      <Headline
        lines={["One table.", "One conversation."]}
        top={265}
        size={91}
        width={970}
      />
      <Copy top={525}>
        Diners + your waiter.
        <br />
        The audience stays clear.
      </Copy>
      <div
        style={{
          position: "absolute",
          left: 100,
          top: 700,
          display: "flex",
          gap: 10,
          transform: `translateX(${ease(f, 14, 34, -40, 0)}px)`,
          opacity: ease(f, 14, 30),
        }}
      >
        {["YOU", "DINER", "WAITER"].map((name, i) => (
          <div
            key={name}
            style={{
              background: i === 2 ? C.forest : C.mint,
              color: i === 2 ? C.paper : C.forest,
              borderRadius: 60,
              padding: "22px 29px",
              fontSize: 21,
              fontWeight: 700,
            }}
          >
            {name}
          </div>
        ))}
      </div>
      <Sequence durationInFrames={80}>
        <Phone file="conversation" x={1230} y={130} width={390} rotation={-2} />
      </Sequence>
      <Sequence from={80}>
        <ScreenCrop
          file="conversation"
          y={175}
          h={730}
          imageWidth={860}
          offsetY={-300}
          label="AROUND THE TABLE / SHARED ROOM"
          drift={-80}
        />
      </Sequence>
      <Footer />
    </Backdrop>
  );
};
const Ai: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop dark>
      <Label index="03" text="ASK RAYSTO" dark />
      <div
        style={{
          position: "absolute",
          right: 10,
          top: 105,
          opacity: 0.18,
          transform: `rotate(${f / 8}deg)`,
        }}
      >
        <Asterisk size={320} color={C.lime} />
      </div>
      <Sequence durationInFrames={90}>
        <Headline
          lines={["2 diners.", "$30 budget."]}
          top={260}
          size={116}
          dark
          accent={1}
        />
        <Copy top={565} dark>
          “We both prefer vegetarian food.
          <br />
          Suggest something to share.”
        </Copy>
        <Phone file="ai-basket" x={1230} y={130} width={390} rotation={3} />
        <Tag text="GROUNDED IN THE MENU" x={96} y={765} dark />
      </Sequence>
      <Sequence from={90}>
        <Headline
          lines={["A $27", "group proposal."]}
          top={245}
          size={105}
          width={970}
          dark
          accent={0}
        />
        <Copy top={540} dark>
          Real menu items. Clear prices.
          <br />A human reviews the order.
        </Copy>
        <ScreenCrop
          file="ai-basket"
          y={170}
          h={770}
          imageWidth={860}
          offsetY={-440}
          label="RECORDED GEMINI RESPONSE / $27.00"
          drift={-60}
        />
        <Tag
          text="ALLERGEN UNKNOWN? ASK STAFF."
          x={96}
          y={745}
          dark
          delay={22}
        />
      </Sequence>
      <Footer text="NATIVE APP / RECORDED SANDBOX AI RESPONSE" dark />
    </Backdrop>
  );
};
const Kitchen: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop>
      <Label index="04" text="KEEP SERVICE CONNECTED" />
      <Headline
        lines={["From the table", "to the kitchen."]}
        top={230}
        size={99}
        width={1040}
      />
      <Copy top={515}>
        The reviewed order joins
        <br />
        the kitchen’s queue.
      </Copy>
      <Tag text="ORDER #2 · SUBMITTED" x={96} y={700} />
      <Sequence durationInFrames={100}>
        <Phone file="kitchen" x={1250} y={135} width={390} rotation={2} />
        <div
          style={{
            position: "absolute",
            left: 840,
            top: 710,
            transform: `translateX(${ease(f, 10, 70, -30, 40)}px)`,
            opacity: ease(f, 10, 25),
          }}
        >
          <svg width="310" height="130" viewBox="0 0 310 130">
            <path
              d="M10 95 Q120 0 280 55 M248 28 L284 57 L247 77"
              fill="none"
              stroke={C.forest}
              strokeWidth="5"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeDasharray="7 11"
            />
          </svg>
        </div>
      </Sequence>
      <Sequence from={100}>
        <ScreenCrop
          file="kitchen"
          y={175}
          h={765}
          imageWidth={860}
          offsetY={-100}
          label="KITCHEN QUEUE / THREE ITEMS"
          drift={-70}
        />
      </Sequence>
      <Footer />
    </Backdrop>
  );
};
const Operations: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop peach>
      <Label index="05" text="SEE THE WHOLE FLOOR" />
      <Headline lines={["One clear view."]} top={145} size={98} width={1700} />
      <Copy top={275} width={1500} delay={10}>
        Tables, service and outstanding bills — connected in AG Grid + AG
        Studio.
      </Copy>
      <div
        style={{
          position: "absolute",
          left: 100,
          top: 395,
          width: 1718,
          height: 550,
          overflow: "hidden",
          borderRadius: 28,
          border: "2px solid #173f3526",
          boxShadow: "0 25px 60px #173f3520",
          background: C.paper,
          transform: `translateY(${(1 - pop(f, 5)) * 80}px) scale(${0.98 + pop(f, 5) * 0.02})`,
          opacity: ease(f, 5, 15),
        }}
      >
        <Img
          src={staticFile("screens/dashboard.png")}
          style={{
            position: "absolute",
            width: 1720,
            left: 0,
            top: ease(f, 15, 150, -250, -275),
          }}
        />
      </div>
      <Footer text="ACTUAL BROWSER CAPTURE / CONNECTED SANDBOX RECORDS" />
    </Backdrop>
  );
};
const Share: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop>
      <Label index="06" text="REVIEW YOUR SHARE" />
      <Headline
        lines={["Your share.", "Your approval."]}
        top={210}
        size={102}
        width={980}
      />
      <div
        style={{
          position: "absolute",
          left: 98,
          top: 495,
          display: "flex",
          alignItems: "baseline",
          gap: 20,
          transform: `scale(${0.8 + pop(f, 16) * 0.2})`,
          transformOrigin: "left center",
          opacity: ease(f, 16, 24),
        }}
      >
        <span style={{ fontSize: 145, fontWeight: 700, letterSpacing: -9 }}>
          $13.50
        </span>
        <span style={{ fontSize: 25, color: "#506D61" }}>proposed share</span>
      </div>
      <Copy top={705} width={780} delay={25}>
        AI helps explain the split.
        <br />
        Each diner approves in PayPal Sandbox.
      </Copy>
      <Sequence durationInFrames={75}>
        <Phone file="share" x={1250} y={132} width={390} rotation={-3} />
      </Sequence>
      <Sequence from={75}>
        <ScreenCrop
          file="share"
          y={165}
          h={785}
          imageWidth={860}
          offsetY={-465}
          label="RECORDED AI RESPONSE / PAYMENT PROPOSAL"
          drift={-120}
        />
      </Sequence>
      <Footer text="SANDBOX PROPOSAL / BUYER APPROVAL AND CAPTURE PENDING" />
    </Backdrop>
  );
};
const End: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <Backdrop dark>
      <div style={{ position: "absolute", left: 96, top: 65 }}>
        <Brand dark large />
      </div>
      <div
        style={{
          position: "absolute",
          right: -185,
          top: 225,
          width: 760,
          height: 760,
          background: C.lime,
          borderRadius: "50%",
          transform: `scale(${pop(f, 3)})`,
        }}
      />
      <Img
        src={staticFile("table-art.png")}
        style={{
          position: "absolute",
          right: -150,
          top: 285,
          width: 1050,
          transform: `rotate(${ease(f, 0, 130, -12, 5)}deg) translateX(${ease(f, 0, 35, 150, 0)}px)`,
          opacity: ease(f, 0, 15),
        }}
      />
      <Headline
        lines={["AI at the table.", "PayPal at checkout."]}
        top={350}
        size={105}
        width={1460}
        dark
        accent={0}
      />
      <div
        style={{
          position: "absolute",
          left: 103,
          top: 750,
          opacity: ease(f, 25, 45),
          display: "flex",
          alignItems: "center",
          gap: 22,
        }}
      >
        <span style={{ fontSize: 46, fontWeight: 700, letterSpacing: -1 }}>
          rays.to
        </span>
        <span style={{ width: 64, height: 2, background: C.lime }} />
        <span style={{ fontSize: 25, color: "#C5D4CB" }}>
          Good company. Better coordination.
        </span>
      </div>
      <Footer text="RAYSTO / SANDBOX PRODUCT WALKTHROUGH" dark />
    </Backdrop>
  );
};
const Wipes: React.FC = () => {
  const f = useCurrentFrame();
  const cuts = [105, 270, 450, 660, 855, 1020, 1200];
  const cut = cuts.find((c) => f >= c - 5 && f <= c + 7);
  if (cut === undefined) return null;
  const x = interpolate(f, [cut - 5, cut, cut + 7], [-2600, -140, 2400], {
    easing: Easing.bezier(0.5, 0, 0.5, 1),
    ...clamp,
  });
  return (
    <div
      style={{
        position: "absolute",
        left: x,
        top: -350,
        width: 2200,
        height: 1800,
        background: C.lime,
        transform: "rotate(-12deg)",
      }}
    />
  );
};
const RaystoFilm: React.FC = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill
      style={{
        fontFamily: "Jakarta, sans-serif",
        fontWeight: 400,
        background: C.forest,
      }}
    >
      <Audio src={staticFile("soundtrack.m4a")} volume={0.94} />
      <Sequence durationInFrames={105}>
        <Hero />
      </Sequence>
      <Sequence from={105} durationInFrames={165}>
        <Discover />
      </Sequence>
      <Sequence from={270} durationInFrames={180}>
        <Conversation />
      </Sequence>
      <Sequence from={450} durationInFrames={210}>
        <Ai />
      </Sequence>
      <Sequence from={660} durationInFrames={195}>
        <Kitchen />
      </Sequence>
      <Sequence from={855} durationInFrames={165}>
        <Operations />
      </Sequence>
      <Sequence from={1020} durationInFrames={180}>
        <Share />
      </Sequence>
      <Sequence from={1200} durationInFrames={150}>
        <End />
      </Sequence>
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          height: 5,
          width: `${(f / 1349) * 100}%`,
          background: "#A2CF53",
        }}
      />
      <Wipes />
      <AbsoluteFill
        style={{
          background: "#102D25",
          opacity: ease(f, 1332, 1349, 0, 1),
          pointerEvents: "none",
        }}
      />
    </AbsoluteFill>
  );
};
export const MyComposition: React.FC = () => (
  <Composition
    id="RaystoQuick"
    component={RaystoFilm}
    durationInFrames={1350}
    fps={30}
    width={1920}
    height={1080}
  />
);
