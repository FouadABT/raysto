// The edit list for RaystoDemo: which seconds of each recording a scene shows
// and how fast. Recorded on 2 November 2026 against production (rays.to,
// ops.rays.to, api.rays.to, PayPal Sandbox) by a Playwright script at a
// 1280x720 viewport; the page fills the top-left 1280x720 of each frame.
// main.webm is the console session. paypal.webm is PayPal's approval page,
// trimmed to start at the review screen so the buyer login never appears.
// A cut with speed above 1 is waiting, and the film labels it "sped up".
import type { Key } from "../promo/kit";

export type Cut = { file: "main.webm" | "paypal.webm"; from: number; to: number; speed?: number };
export type Clip = { url: string; cuts: Cut[]; camera?: Key[] };

// Camera points, in px from the screen centre: the console's left and right
// card columns, and the middle (rays.to, PayPal). The points sit a little
// below the middle so results and buttons stay clear of the captions.
const LEFT: [number, number] = [-131, 130];
const RIGHT: [number, number] = [477, 130];
const zoomOn = (at: [number, number], scale = 1.5, from = 0, to = 24): Key[] => [
  [from, 1, 0, 0],
  [to, scale, at[0], at[1]],
];

export const CLIPS: Partial<Record<string, Clip>> = {
  judges: {
    url: "rays.to → ops.rays.to",
    cuts: [
      { file: "main.webm", from: 6.0, to: 11.0 },
      { file: "main.webm", from: 11.0, to: 26.2, speed: 8 },
      { file: "main.webm", from: 26.2, to: 29.4 },
    ],
  },
  voice: {
    url: "ops.rays.to · Try Raysto",
    cuts: [{ file: "main.webm", from: 30.6, to: 41.6 }],
    camera: zoomOn(RIGHT),
  },
  menu: {
    url: "ops.rays.to · Try Raysto",
    cuts: [
      { file: "main.webm", from: 43.7, to: 46.7 },
      { file: "main.webm", from: 46.7, to: 62.4, speed: 6 },
      { file: "main.webm", from: 62.4, to: 69.4 },
      { file: "main.webm", from: 69.4, to: 73.4 },
    ],
    camera: zoomOn(LEFT),
  },
  order: {
    url: "ops.rays.to · Try Raysto",
    cuts: [
      { file: "main.webm", from: 92.3, to: 95.3 },
      { file: "main.webm", from: 95.3, to: 104.2, speed: 4 },
      { file: "main.webm", from: 104.2, to: 116.0, speed: 1.4 },
    ],
    camera: zoomOn(LEFT),
  },
  paid: {
    url: "sandbox.paypal.com → ops.rays.to",
    cuts: [
      { file: "paypal.webm", from: 0.6, to: 9.0 },
      { file: "main.webm", from: 146.6, to: 152.0 },
    ],
    camera: [
      [0, 1.3, 0, 40],
      [250, 1.3, 0, 40],
      [262, 1.5, LEFT[0], LEFT[1]],
    ],
  },
  payments: {
    url: "ops.rays.to · Try Raysto",
    cuts: [
      { file: "main.webm", from: 153.4, to: 156.4 },
      { file: "main.webm", from: 156.4, to: 172.4, speed: 5 },
      { file: "main.webm", from: 172.4, to: 184.6 },
    ],
    camera: zoomOn(RIGHT),
  },
  photo: {
    url: "ops.rays.to · Try Raysto",
    cuts: [
      { file: "main.webm", from: 188.8, to: 191.8 },
      { file: "main.webm", from: 191.8, to: 237.1, speed: 15 },
      { file: "main.webm", from: 237.1, to: 245.1 },
    ],
    camera: zoomOn(LEFT),
  },
};
