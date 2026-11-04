// The edit list for RaystoDemo (v2, the money agents): which seconds of each
// recording a scene shows and how fast. Recorded against production
// (rays.to, ops.rays.to, api.rays.to, PayPal Sandbox) by a Playwright script
// at a 1280x720 viewport; the page fills the top-left 1280x720 of each
// 1920x1080 frame. main.webm is the console session. paypal.webm is PayPal's
// approval page, trimmed to start at the review screen so the buyer login
// never appears. A cut with speed of 2 or more is waiting, and the film
// labels it "sped up".
//
// PHASE 2: the cut times below are placeholders until the 3 November
// recording lands (events.json in public/demo/footage/ gives the marks).
import type { Key } from "../promo/kit";

export type Cut = { file: "main.webm" | "paypal.webm"; from: number; to: number; speed?: number };
export type Clip = { url: string; cuts: Cut[]; camera?: Key[] };

// Camera points, in px from the screen centre, for the console's left and
// right card columns at 1.7x. They sit below the middle so results and
// buttons stay clear of the captions.
export const LEFT: [number, number] = [-131, 120];
export const RIGHT: [number, number] = [477, 120];
export const ZOOM = 1.7;
export const zoomOn = (at: [number, number], scale = ZOOM, from = 0, to = 24): Key[] => [
  [from, 1, 0, 0],
  [to, scale, at[0], at[1]],
];

const TRY = "ops.rays.to · Try Raysto";

export const CLIPS: Partial<Record<string, Clip>> = {
  judges: {
    url: "rays.to → ops.rays.to",
    cuts: [{ file: "main.webm", from: 0, to: 6 }],
  },
  close: { url: TRY, cuts: [{ file: "main.webm", from: 6, to: 20 }], camera: zoomOn(LEFT) },
  payroll: { url: TRY, cuts: [{ file: "main.webm", from: 20, to: 36 }], camera: zoomOn(RIGHT) },
  catering: { url: TRY, cuts: [{ file: "main.webm", from: 36, to: 50 }], camera: zoomOn(LEFT) },
  complaint: { url: TRY, cuts: [{ file: "main.webm", from: 50, to: 66 }], camera: zoomOn(RIGHT) },
  payments: { url: TRY, cuts: [{ file: "main.webm", from: 66, to: 78 }], camera: zoomOn(LEFT) },
  order: { url: TRY, cuts: [{ file: "main.webm", from: 78, to: 90 }], camera: zoomOn(RIGHT) },
  paid: {
    url: "sandbox.paypal.com → ops.rays.to",
    cuts: [
      { file: "paypal.webm", from: 0, to: 6 },
      { file: "main.webm", from: 90, to: 96 },
    ],
    camera: [
      [0, 1.3, 0, 40],
      [170, 1.3, 0, 40],
      [182, ZOOM, RIGHT[0], RIGHT[1]],
    ],
  },
  montage: {
    url: TRY,
    cuts: [
      { file: "main.webm", from: 96, to: 100 },
      { file: "main.webm", from: 100, to: 104 },
      { file: "main.webm", from: 104, to: 108 },
    ],
    camera: zoomOn(LEFT),
  },
};
