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
import { loadFont } from "@remotion/fonts";

loadFont({
  family: "Editorial",
  url: staticFile("fonts/CormorantGaramond.ttf"),
  weight: "300 700",
});
loadFont({
  family: "Hand",
  url: staticFile("fonts/Caveat.ttf"),
  weight: "400 700",
});

const C = {
  ink: "#183E34",
  paper: "#F3EEDF",
  cream: "#FCF8EC",
  lime: "#D5F277",
  orange: "#BB6444",
  peach: "#E9C6A8",
  muted: "#727B68",
};
const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;
const move = (f: number, a: number, b: number, x = 0, y = 1) =>
  interpolate(f, [a, b], [x, y], {
    ...clamp,
    easing: Easing.bezier(0.16, 0.86, 0.24, 1),
  });
const linear = (f: number, a: number, b: number, x = 0, y = 1) =>
  interpolate(f, [a, b], [x, y], clamp);
const pop = (f: number, d = 0) =>
  spring({
    frame: f - d,
    fps: 30,
    config: { damping: 19, stiffness: 145, mass: 0.8 },
  });
const torn =
  "polygon(0.7% 1.1%, 12% 0%, 26% .6%, 43% 0%, 63% .7%, 81% 0%, 99.3% 1%, 100% 17%, 99.5% 39%, 100% 67%, 99.2% 99%, 83% 100%, 61% 99.3%, 39% 100%, 20% 99.4%, 0% 100%, .6% 72%, 0% 47%, .7% 21%)";

const Star: React.FC<{ size?: number; color?: string; angle?: number }> = ({
  size = 60,
  color = C.ink,
  angle = 0,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    style={{ transform: `rotate(${angle}deg)` }}
  >
    {[0, 45, 90, 135].map((a) => (
      <rect
        key={a}
        x="44"
        y="5"
        width="12"
        height="90"
        rx="3"
        fill={color}
        transform={`rotate(${a} 50 50)`}
      />
    ))}
  </svg>
);
const Brand: React.FC<{ dark?: boolean }> = ({ dark = false }) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 8,
      color: dark ? C.paper : C.ink,
      fontFamily: "Jakarta",
      fontSize: 37,
      fontWeight: 700,
      letterSpacing: -2,
    }}
  >
    raysto
    <Star size={32} color={dark ? C.lime : C.ink} />
  </div>
);
const Note: React.FC<{
  children: React.ReactNode;
  x: number;
  y: number;
  rotate?: number;
  color?: string;
  size?: number;
  opacity?: number;
}> = ({
  children,
  x,
  y,
  rotate = -4,
  color = C.orange,
  size = 40,
  opacity = 1,
}) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      transform: `rotate(${rotate}deg)`,
      fontFamily: "Hand",
      fontSize: size,
      fontWeight: 600,
      color,
      opacity,
      lineHeight: 1.06,
      whiteSpace: "pre-line",
    }}
  >
    {children}
  </div>
);
const Strip: React.FC<{
  children: React.ReactNode;
  color?: string;
  background?: string;
  style?: React.CSSProperties;
}> = ({ children, color = C.cream, background = C.ink, style }) => (
  <div
    style={{
      display: "inline-block",
      fontFamily: "Jakarta",
      fontWeight: 700,
      fontSize: 21,
      letterSpacing: 1.6,
      padding: "10px 18px",
      color,
      background,
      clipPath: torn,
      ...style,
    }}
  >
    {children}
  </div>
);
const Paper: React.FC<{
  children?: React.ReactNode;
  x: number;
  y: number;
  w: number;
  h: number;
  rotate?: number;
  scale?: number;
  opacity?: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({
  children,
  x,
  y,
  w,
  h,
  rotate = 0,
  scale = 1,
  opacity = 1,
  color = C.cream,
  style,
}) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      width: w,
      height: h,
      transform: `rotate(${rotate}deg) scale(${scale})`,
      transformOrigin: "50% 50%",
      opacity,
      filter: "drop-shadow(3px 10px 9px #172b231c)",
      ...style,
    }}
  >
    <div
      style={{
        position: "absolute",
        inset: 0,
        background: color,
        clipPath: torn,
      }}
    />
    <div style={{ position: "absolute", inset: 0 }}>{children}</div>
  </div>
);
const Ink: React.FC<{
  d: string;
  p: number;
  color?: string;
  width?: number;
  dashed?: boolean;
}> = ({ d, p, color = C.ink, width = 3, dashed = false }) => (
  <svg
    width="1920"
    height="1080"
    viewBox="0 0 1920 1080"
    style={{ position: "absolute", inset: 0, pointerEvents: "none" }}
  >
    <path
      d={d}
      pathLength={1}
      fill="none"
      stroke={color}
      strokeWidth={width}
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeDasharray={dashed ? ".012 .016" : 1}
      strokeDashoffset={dashed ? 0 : 1 - Math.max(0, Math.min(p, 1))}
      opacity={dashed ? p : 1}
    />
  </svg>
);
const Words: React.FC<{
  text: string;
  f: number;
  start?: number;
  step?: number;
  size?: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({ text, f, start = 0, step = 3, size = 100, color = C.ink, style }) => (
  <div
    style={{
      fontFamily: "Editorial",
      fontWeight: 700,
      fontSize: size,
      lineHeight: 0.97,
      letterSpacing: -2.8,
      color,
      ...style,
    }}
  >
    {text.split(" ").map((word, i) => (
      <React.Fragment key={`${word}-${i}`}>
        <span
          style={{
            display: "inline-block",
            opacity: move(f, start + i * step, start + i * step + 9),
            transform: `translateY(${move(f, start + i * step, start + i * step + 12, 24, 0)}px)`,
          }}
        >
          {word}
        </span>{" "}
      </React.Fragment>
    ))}
  </div>
);
const Tape: React.FC<{ x: number; y: number; rotate?: number }> = ({
  x,
  y,
  rotate = -5,
}) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      width: 125,
      height: 35,
      background: "#dad3b3b8",
      transform: `rotate(${rotate}deg)`,
      clipPath: "polygon(0 9%,98% 0,100% 91%,3% 100%,0 80%,2% 60%,0 40%)",
    }}
  />
);

const Atmosphere: React.FC<{ dark?: boolean; peach?: boolean }> = ({
  dark = false,
  peach = false,
}) => (
  <AbsoluteFill
    style={{ background: dark ? C.ink : peach ? C.peach : C.paper }}
  >
    <AbsoluteFill
      style={{
        background: dark
          ? "radial-gradient(ellipse at 42% 45%, #52755544, transparent 68%)"
          : "radial-gradient(ellipse at 48% 43%, #fffdf2cc, transparent 70%)",
      }}
    />
    <svg
      width="100%"
      height="100%"
      style={{
        position: "absolute",
        inset: 0,
        opacity: dark ? 0.065 : 0.1,
        mixBlendMode: dark ? "screen" : "multiply",
      }}
    >
      <filter id="paperGrain">
        <feTurbulence
          type="fractalNoise"
          baseFrequency=".72"
          numOctaves="3"
          stitchTiles="stitch"
          seed="19"
        />
        <feColorMatrix type="saturate" values="0" />
      </filter>
      <rect width="100%" height="100%" filter="url(#paperGrain)" />
    </svg>
    <AbsoluteFill
      style={{
        boxShadow: dark
          ? "inset 0 0 180px #001e1e55"
          : "inset 0 0 180px #72552d19",
      }}
    />
  </AbsoluteFill>
);

const Footer: React.FC<{ children: React.ReactNode; dark?: boolean }> = ({
  children,
  dark = false,
}) => (
  <div
    style={{
      position: "absolute",
      bottom: 33,
      left: 90,
      right: 90,
      textAlign: "center",
      fontFamily: "Jakarta",
      fontSize: 19,
      color: dark ? "#D1DDC4" : C.muted,
    }}
  >
    {children}
  </div>
);
const Crop: React.FC<{
  src: string;
  x: number;
  y: number;
  w: number;
  h: number;
  sourceW?: number;
  offset?: number;
  angle?: number;
  label?: string;
}> = ({ src, x, y, w, h, sourceW = w, offset = 0, angle = -2, label }) => (
  <Paper x={x} y={y} w={w} h={h} rotate={angle}>
    <div
      style={{
        position: "absolute",
        inset: 14,
        overflow: "hidden",
        clipPath: torn,
        background: "white",
      }}
    >
      <Img
        src={staticFile(src)}
        style={{
          position: "absolute",
          left: (w - 28 - sourceW) / 2,
          top: offset,
          width: sourceW,
        }}
      />
    </div>
    {label && (
      <Strip
        style={{
          position: "absolute",
          left: 20,
          top: -16,
          fontSize: 15,
          letterSpacing: 0.8,
        }}
      >
        {label}
      </Strip>
    )}
  </Paper>
);

const Bill: React.FC<{
  x: number;
  y: number;
  w?: number;
  rotate?: number;
  scale?: number;
  stamp?: number;
  opacity?: number;
}> = ({ x, y, w = 440, rotate = 0, scale = 1, stamp = 0, opacity = 1 }) => (
  <Paper
    x={x}
    y={y}
    w={w}
    h={570}
    rotate={rotate}
    scale={scale}
    opacity={opacity}
  >
    <div style={{ padding: "38px 35px", fontFamily: "Jakarta", color: C.ink }}>
      <div
        style={{
          textAlign: "center",
          fontSize: 18,
          fontWeight: 700,
          letterSpacing: 4,
        }}
      >
        RAYSTO / GARDEN 1
      </div>
      <div
        style={{
          textAlign: "center",
          fontFamily: "Hand",
          fontSize: 35,
          margin: "14px 0 25px",
        }}
      >
        A proposal for two
      </div>
      <div
        style={{
          borderTop: "2px dashed #91a18b",
          borderBottom: "2px dashed #91a18b",
          padding: "23px 0",
          fontSize: 23,
          lineHeight: 2.1,
        }}
      >
        {[
          ["Shared starter", "$6.00"],
          ["Garden pasta", "$12.00"],
          ["Roasted vegetables", "$9.00"],
        ].map(([a, b]) => (
          <div
            key={a}
            style={{ display: "flex", justifyContent: "space-between" }}
          >
            <span>{a}</span>
            <b>{b}</b>
          </div>
        ))}
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "baseline",
          justifyContent: "space-between",
          marginTop: 14,
        }}
      >
        <span style={{ fontSize: 21 }}>FOOD TOTAL</span>
        <span
          style={{ fontFamily: "Editorial", fontSize: 87, fontWeight: 700 }}
        >
          $27
        </span>
      </div>
      <div
        style={{
          fontFamily: "Hand",
          fontSize: 31,
          color: C.orange,
          textAlign: "center",
        }}
      >
        under the $30 budget
      </div>
    </div>
    {stamp > 0 && (
      <div
        style={{
          position: "absolute",
          left: 30,
          right: 30,
          top: 340,
          transform: `rotate(-13deg) scale(${1.8 - 0.8 * stamp})`,
          opacity: stamp,
          border: `5px double ${C.ink}`,
          color: C.ink,
          background: "#e9efc6e8",
          fontSize: 31,
          fontWeight: 700,
          textAlign: "center",
          padding: "16px 0",
          letterSpacing: 2,
        }}
      >
        HOST APPROVED
      </div>
    )}
  </Paper>
);

const Opening = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Atmosphere />
      <div style={{ position: "absolute", left: 110, top: 150, width: 1120 }}>
        <Words text="A restaurant visit." f={f} size={112} />
        <Words text="One coordinated system." f={f} start={13} size={112} />
      </div>
      <div
        style={{
          position: "absolute",
          right: 95,
          top: 375,
          width: 950,
          transform: `translateY(${move(f, 0, 24, 130, 0)}px) rotate(${move(f, 0, 30, 4, -2)}deg) scale(${move(f, 0, 150, 0.96, 1.015)})`,
        }}
      >
        <Img
          src={staticFile("judges/table-people.png")}
          style={{
            width: "100%",
            filter: "drop-shadow(8px 12px 8px #173f3522)",
          }}
        />
      </div>
      <Paper
        x={move(f, 12, 34, -430, 125)}
        y={425}
        w={425}
        h={365}
        rotate={-7}
        color={C.cream}
      >
        <Tape x={145} y={-12} />
        <div style={{ padding: 35, color: C.ink }}>
          <div style={{ fontFamily: "Hand", fontSize: 38 }}>
            At the table...
          </div>
          <div
            style={{
              fontFamily: "Editorial",
              fontSize: 48,
              fontWeight: 600,
              lineHeight: 1.2,
              marginTop: 18,
            }}
          >
            Two diners.
            <br />
            Vegetarian.
            <br />
            <span style={{ background: C.lime, padding: "0 8px" }}>
              Under $30.
            </span>
          </div>
        </div>
      </Paper>
      <div
        style={{
          position: "absolute",
          left: 160,
          top: 835,
          transform: `rotate(-3deg) scale(${pop(f, 44)})`,
        }}
      >
        <Strip>DINERS + STAFF + AI</Strip>
      </div>
      <Ink
        d="M 495 814 C 630 882 695 790 730 719 M 712 737 L 730 719 L 733 746"
        p={linear(f, 45, 73)}
        color={C.orange}
        width={4}
      />
      <Note x={580} y={850} rotate={-7} opacity={move(f, 55, 75)} size={38}>
        shared context
        <br />→ real actions
      </Note>
      <Footer>
        Restaurant commerce, coordinated through one authorized visit.
      </Footer>
    </AbsoluteFill>
  );
};

const Intelligence = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Atmosphere dark />
      <div style={{ position: "absolute", left: 105, top: 140, width: 1620 }}>
        <Words text="Gemini proposes." f={f} size={105} color={C.paper} />
        <Words
          text="Raysto calculates."
          f={f}
          start={10}
          size={105}
          color={C.paper}
        />
      </div>
      <Ink
        d="M 110 354 Q 480 373 850 350"
        p={linear(f, 25, 49)}
        color={C.lime}
        width={6}
      />
      <Paper
        x={move(f, 0, 25, -500, 105)}
        y={430}
        w={480}
        h={210}
        rotate={-4}
        color={C.lime}
      >
        <div style={{ padding: 28, color: C.ink }}>
          <div
            style={{
              fontFamily: "Jakarta",
              fontSize: 17,
              letterSpacing: 2,
              fontWeight: 700,
            }}
          >
            THE GROUP REQUEST
          </div>
          <div
            style={{
              fontFamily: "Editorial",
              fontSize: 46,
              fontWeight: 600,
              lineHeight: 1.1,
              marginTop: 12,
            }}
          >
            “Vegetarian for two.
            <br />
            Keep it under $30.”
          </div>
        </div>
      </Paper>
      {[
        ["read_menu", "Menu + availability"],
        ["quote_basket", "Server-calculated prices"],
      ].map(([tool, desc], i) => (
        <div
          key={tool}
          style={{
            position: "absolute",
            left: 115 + i * 380,
            top: 730,
            opacity: move(f, 26 + i * 25, 40 + i * 25),
            transform: `translateY(${move(f, 26 + i * 25, 46 + i * 25, 55, 0)}px)`,
          }}
        >
          <div
            style={{
              fontFamily: "Courier New",
              fontSize: 25,
              color: C.lime,
              fontWeight: 700,
            }}
          >
            {tool}()
          </div>
          <div
            style={{
              fontFamily: "Jakarta",
              fontSize: 23,
              color: C.paper,
              marginTop: 10,
            }}
          >
            {desc}
          </div>
          <Ink d="" p={0} />
        </div>
      ))}
      <Ink
        d="M 598 530 C 715 531 744 464 852 482 M 827 462 L 852 482 L 823 493"
        p={linear(f, 32, 57)}
        color={C.paper}
      />
      <Bill
        x={move(f, 49, 87, 980, 855)}
        y={move(f, 49, 87, 440, 398)}
        w={440}
        rotate={move(f, 49, 87, 13, 3)}
        scale={move(f, 49, 87, 0.6, 0.95)}
        opacity={move(f, 49, 62)}
      />
      <div
        style={{
          opacity: move(f, 82, 103),
          transform: `translateX(${move(f, 82, 108, 170, 0)}px)`,
        }}
      >
        <Crop
          src="screens/ai-basket.png"
          x={1380}
          y={265}
          w={420}
          h={650}
          sourceW={415}
          offset={-195}
          label="RECORDED NATIVE APP"
          angle={-4}
        />
      </div>
      <Note x={120} y={885} color={C.lime} size={43} opacity={move(f, 65, 80)}>
        tools, not guessed prices
      </Note>
      <Footer dark>
        Recorded QA result: three menu items, $27.00. Unknown allergens remain
        unknown.
      </Footer>
    </AbsoluteFill>
  );
};

const Approval = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Atmosphere />
      <div style={{ position: "absolute", left: 105, top: 140, width: 1700 }}>
        <Words text="Human approval becomes" f={f} size={100} />
        <Words text="an operational event." f={f} start={10} size={100} />
      </div>
      <Bill
        x={move(f, 0, 34, 855, 130)}
        y={move(f, 0, 34, 398, 398)}
        w={440}
        rotate={move(f, 0, 34, 3, -4)}
        scale={0.95}
        stamp={pop(f, 40)}
      />
      <Ink
        d="M 570 650 C 740 650 800 490 1030 510 M 1003 492 L 1030 510 L 1004 530"
        p={linear(f, 55, 88)}
        color={C.orange}
        width={4}
      />
      <Ink
        d="M 570 650 C 730 650 850 850 1090 852 M 1064 835 L 1090 852 L 1065 869"
        p={linear(f, 65, 96)}
        color={C.ink}
      />
      <div
        style={{
          opacity: move(f, 70, 89),
          transform: `translate(${move(f, 70, 100, -120, 0)}px,${move(f, 70, 100, 75, 0)}px)`,
        }}
      >
        <Crop
          src="screens/kitchen.png"
          x={1105}
          y={400}
          w={590}
          h={470}
          sourceW={580}
          offset={-130}
          label="ACTUAL SUBMITTED QA ORDER"
          angle={3}
        />
      </div>
      <Paper
        x={720}
        y={535}
        w={250}
        h={150}
        rotate={-9}
        opacity={move(f, 55, 64)}
        scale={pop(f, 55)}
        color={C.lime}
      >
        <div
          style={{
            padding: 20,
            textAlign: "center",
            fontFamily: "Courier New",
            fontWeight: 700,
            fontSize: 23,
            lineHeight: 1.45,
            color: C.ink,
          }}
        >
          ORDER #2
          <br />
          SUBMITTED
          <br />
          <span style={{ fontSize: 17 }}>visit → kitchen</span>
        </div>
      </Paper>
      <Note x={700} y={805} rotate={-6} opacity={move(f, 85, 103)}>
        Same items.
        <br />
        Same visit.
      </Note>
      <div
        style={{
          position: "absolute",
          left: 1170,
          top: 920,
          opacity: move(f, 105, 120),
        }}
      >
        <Strip>DINERS · WAITER · KITCHEN</Strip>
      </div>
      <Footer>
        Host-reviewed submission. Permissions and state transitions stay in the
        backend.
      </Footer>
    </AbsoluteFill>
  );
};

const Settlement = () => {
  const f = useCurrentFrame();
  const split = move(f, 20, 60);
  return (
    <AbsoluteFill>
      <Atmosphere peach />
      <div style={{ position: "absolute", left: 105, top: 140, width: 1700 }}>
        <Words text="AI prepares the shares." f={f} size={104} />
        <Words text="Each payer approves." f={f} start={12} size={104} />
      </div>
      <div
        style={{
          position: "absolute",
          left: 105,
          top: 400,
          fontFamily: "Courier New",
          fontSize: 23,
          fontWeight: 700,
          color: C.ink,
          opacity: move(f, 4, 15),
        }}
      >
        ONE $27 BILL / EXACT ALLOCATIONS
      </div>
      {[0, 1].map((i) => (
        <Paper
          key={i}
          x={610 + (i === 0 ? -1 : 1) * 250 * split}
          y={455 + (i === 0 ? -1 : 1) * 18 * split}
          w={390}
          h={390}
          rotate={(i === 0 ? -1 : 1) * 5 * split}
          scale={0.97}
        >
          <div style={{ padding: 30, color: C.ink, textAlign: "center" }}>
            <div
              style={{
                fontFamily: "Jakarta",
                fontSize: 18,
                letterSpacing: 3,
                fontWeight: 700,
              }}
            >
              DINER {i === 0 ? "A" : "B"}
            </div>
            <div
              style={{
                fontFamily: "Editorial",
                fontSize: 105,
                fontWeight: 700,
                margin: "12px 0",
              }}
            >
              $13.50
            </div>
            <div
              style={{
                borderTop: "2px dashed #9ca58d",
                paddingTop: 18,
                fontFamily: "Courier New",
                fontSize: 21,
                lineHeight: 1.5,
              }}
            >
              Starter 3.00
              <br />
              Pasta 6.00
              <br />
              Vegetables 4.50
            </div>
            <div
              style={{
                fontFamily: "Hand",
                fontSize: 34,
                color: C.orange,
                marginTop: 12,
              }}
            >
              review → approve
            </div>
          </div>
        </Paper>
      ))}
      <Ink d="M 801 464 L 800 835" p={1 - split} color={C.orange} width={3} />
      <Paper
        x={move(f, 65, 100, 1800, 1410)}
        y={440}
        w={370}
        h={250}
        rotate={-3}
        color={C.ink}
      >
        <div style={{ padding: 28, color: C.paper, textAlign: "center" }}>
          <div style={{ fontFamily: "Jakarta", fontSize: 43, fontWeight: 700 }}>
            PayPal
          </div>
          <div
            style={{
              fontFamily: "Jakarta",
              fontSize: 22,
              marginTop: 7,
              color: C.lime,
            }}
          >
            Sandbox checkout
          </div>
          <div style={{ fontFamily: "Hand", fontSize: 34, marginTop: 25 }}>
            your approval required
          </div>
        </div>
      </Paper>
      <Ink
        d="M 1270 545 C 1330 495 1354 510 1405 535 M 1384 515 L 1405 535 L 1375 540"
        p={linear(f, 89, 111)}
        color={C.ink}
        width={4}
      />
      <div
        style={{
          position: "absolute",
          left: 1420,
          top: 750,
          opacity: move(f, 120, 137),
        }}
      >
        <Strip background={C.cream} color={C.ink}>
          PAYPAL MCP
        </Strip>
        <div
          style={{
            fontFamily: "Courier New",
            fontSize: 24,
            color: C.ink,
            margin: "15px 0 3px",
          }}
        >
          get_order()
        </div>
        <div style={{ fontFamily: "Hand", fontSize: 33, color: C.orange }}>
          read-only status
        </div>
      </div>
      <Ink
        d="M 1590 696 C 1723 706 1770 742 1730 802 M 1719 778 L 1730 802 L 1754 788"
        p={linear(f, 135, 164)}
        color={C.orange}
      />
      <Note x={105} y={665} rotate={-5} size={36} opacity={move(f, 70, 90)}>
        AI never
        <br />
        approves
        <br />a purchase.
      </Note>
      <div
        style={{
          position: "absolute",
          left: 490,
          top: 900,
          opacity: move(f, 158, 176),
        }}
      >
        <Strip>GUARDED CHECKOUT + VERIFIED PROVIDER STATUS</Strip>
      </div>
      <Footer>
        Sandbox explanation · buyer capture not yet verified. MCP direct reads
        verified separately.
      </Footer>
    </AbsoluteFill>
  );
};

const Operations = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Atmosphere dark />
      <div style={{ position: "absolute", left: 105, top: 140, width: 1710 }}>
        <Words text="One shared state." f={f} size={112} color={C.paper} />
        <Words
          text="Across every role."
          f={f}
          start={11}
          size={112}
          color={C.paper}
        />
      </div>
      <div
        style={{
          position: "absolute",
          left: 95,
          top: 480,
          width: 530,
          transform: `rotate(-3deg) translateY(${move(f, 0, 25, 70, 0)}px)`,
        }}
      >
        <Img
          src={staticFile("judges/table-people.png")}
          style={{ width: "100%" }}
        />
        <div style={{ marginTop: 5, textAlign: "center" }}>
          <Strip color={C.ink} background={C.lime}>
            THE SHARED VISIT
          </Strip>
        </div>
      </div>
      <Ink
        d="M 620 660 C 730 610 712 524 836 539 M 816 517 L 836 539 L 809 554"
        p={linear(f, 20, 50)}
        color={C.lime}
        width={4}
      />
      <div
        style={{
          opacity: move(f, 27, 42),
          transform: `translateX(${move(f, 27, 58, 230, 0)}px) scale(${move(f, 27, 150, 0.93, 1)})`,
          transformOrigin: "1290px 650px",
        }}
      >
        <Crop
          src="screens/manager-assistant.png"
          x={845}
          y={420}
          w={920}
          h={500}
          sourceW={920}
          offset={-10}
          angle={2}
          label="CONNECTED AG GRID + AG STUDIO"
        />
      </div>
      <Paper
        x={650}
        y={815}
        w={550}
        h={125}
        rotate={-4}
        color={C.lime}
        opacity={move(f, 65, 81)}
        scale={pop(f, 65)}
      >
        <div
          style={{
            padding: "21px 29px",
            fontFamily: "Editorial",
            fontSize: 36,
            fontWeight: 700,
            color: C.ink,
          }}
        >
          “Who asked for the bill
          <br />
          and still needs to pay?”
        </div>
      </Paper>
      <Note
        x={1100}
        y={920}
        size={37}
        color={C.lime}
        rotate={-2}
        opacity={move(f, 92, 108)}
      >
        same records, useful answers
      </Note>
      <div
        style={{
          position: "absolute",
          left: 110,
          top: 910,
          fontFamily: "Courier New",
          fontSize: 19,
          color: "#d5ddc6",
          lineHeight: 1.6,
          opacity: move(f, 80, 96),
        }}
      >
        FLUTTER ↔ SERVERPOD
        <br />
        POSTGRESQL ↔ LIVE EVENTS
      </div>
      <Footer dark>
        Recorded manager query selected the bill-requested table with $27
        outstanding.
      </Footer>
    </AbsoluteFill>
  );
};

const DemoBridge = () => {
  const f = useCurrentFrame();
  return (
    <AbsoluteFill>
      <Atmosphere />
      <div
        style={{
          position: "absolute",
          left: 950,
          top: 110,
          width: 640,
          height: 880,
          overflow: "hidden",
          transform: `rotate(${move(f, 0, 28, 7, 1)}deg) translateX(${move(f, 0, 28, 600, 0)}px)`,
          filter: "drop-shadow(0 15px 20px #163d3530)",
          border: "14px solid #fffaf0",
          borderRadius: 6,
        }}
      >
        <Video
          src={staticFile("native-room-scroll.mp4")}
          muted
          playbackRate={1.2}
          style={{ width: "100%", marginTop: -155 }}
        />
      </div>
      <div style={{ position: "absolute", left: 110, top: 220, width: 780 }}>
        <Words text="Now, watch" f={f} start={8} size={114} />
        <Words text="the system" f={f} start={15} size={114} />
        <Words text="work." f={f} start={22} size={114} />
      </div>
      <Ink
        d="M 110 589 Q 290 617 475 589"
        p={linear(f, 30, 48)}
        color={C.orange}
        width={5}
      />
      <div
        style={{
          position: "absolute",
          left: 115,
          top: 715,
          opacity: move(f, 35, 50),
        }}
      >
        <Strip>ONE VISIT. TWO DINERS. ONE BILL.</Strip>
      </div>
      <Note x={140} y={825} size={48} opacity={move(f, 48, 63)}>
        From conversation to commerce.
      </Note>
      <Footer>
        Native Android recording · the working demonstration follows.
      </Footer>
    </AbsoluteFill>
  );
};

export const JudgesFilm = () => {
  const f = useCurrentFrame();
  const cuts = [0, 150, 360, 555, 810, 1020, 1140];
  const scenes = [
    Opening,
    Intelligence,
    Approval,
    Settlement,
    Operations,
    DemoBridge,
  ];
  const dark = (f >= 150 && f < 360) || (f >= 810 && f < 1020);
  return (
    <AbsoluteFill style={{ fontFamily: "Jakarta", background: C.paper }}>
      <Audio src={staticFile("judges/licensed-score.m4a")} volume={1} />
      {scenes.map((Scene, i) => (
        <Sequence
          key={i}
          from={cuts[i]}
          durationInFrames={cuts[i + 1] - cuts[i]}
        >
          <Scene />
        </Sequence>
      ))}
      <div style={{ position: "absolute", left: 100, top: 50 }}>
        <Brand dark={dark} />
      </div>
      <div
        style={{
          position: "absolute",
          right: 100,
          top: 63,
          fontFamily: "Courier New",
          fontSize: 17,
          fontWeight: 700,
          letterSpacing: 2,
          color: dark ? "#d8e4c8" : C.muted,
        }}
      >
        AI AT THE TABLE / PAYPAL AT CHECKOUT
      </div>
      {cuts.slice(1, -1).map((c, i) => {
        if (f < c - 7 || f > c + 10) return null;
        const p = linear(f, c - 7, c + 10);
        return (
          <div
            key={c}
            style={{
              position: "absolute",
              left: interpolate(p, [0, 1], [-2500, 2400]),
              top: -250,
              width: 2400,
              height: 1600,
              transform: `rotate(${i % 2 ? -8 : 8}deg)`,
              background: i % 2 ? C.paper : C.lime,
              clipPath: torn,
              boxShadow: "15px 0 30px #10261c22",
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};

export const JudgesComposition = () => (
  <Composition
    id="RaystoJudges38"
    component={JudgesFilm}
    durationInFrames={1140}
    fps={30}
    width={1920}
    height={1080}
  />
);
