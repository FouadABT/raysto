import type { Json } from "./contracts";

/**
 * The judges' café and its published manager login, set when the console is
 * built. Everything there is PayPal Sandbox; the login is public on purpose.
 */
export const judge = {
  email: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_EMAIL ?? "",
  password: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_PASSWORD ?? "",
  restaurantId: Number(process.env.NEXT_PUBLIC_RAYSTO_JUDGE_RESTAURANT_ID ?? 0),
  buyerEmail: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_BUYER_EMAIL ?? "",
  buyerPassword: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_BUYER_PASSWORD ?? "",
  /** The diner login for the Android app. */
  dinerEmail: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_DINER_EMAIL ?? "",
  dinerPassword: process.env.NEXT_PUBLIC_RAYSTO_JUDGE_DINER_PASSWORD ?? "",
  apkUrl: process.env.NEXT_PUBLIC_RAYSTO_APK_URL ?? "",
  apkVersion: process.env.NEXT_PUBLIC_RAYSTO_APK_VERSION ?? "",
  apkSha256: process.env.NEXT_PUBLIC_RAYSTO_APK_SHA256 ?? "",
  videoUrl: process.env.NEXT_PUBLIC_RAYSTO_VIDEO_URL ?? "",
  videoLength: process.env.NEXT_PUBLIC_RAYSTO_VIDEO_LENGTH ?? "",
  /** The sample photos uploaded to the café: the printed menu, a supplier's
   * delivery note and a receipt, for the menu, supplies and expenses agents. */
  menuMediaId: Number(process.env.NEXT_PUBLIC_RAYSTO_JUDGE_MENU_MEDIA_ID ?? 0),
  deliveryMediaId: Number(process.env.NEXT_PUBLIC_RAYSTO_JUDGE_DELIVERY_MEDIA_ID ?? 0),
  receiptMediaId: Number(process.env.NEXT_PUBLIC_RAYSTO_JUDGE_RECEIPT_MEDIA_ID ?? 0),
};

/**
 * How many AI coworkers the product ships, in words, for the judges' page and
 * the Try page. One edit here when an agent is added or cut.
 */
export const coworkers = { count: "fourteen", demos: 9 };

/**
 * The evidence numbers on the judges' page. docs/facts.json holds the same
 * facts (the console is built without the docs folder), and
 * tests/facts.test.ts fails when the two disagree.
 */
export const evidence = {
  captures: 11,
  refunds: 4,
  payoutBatches: 5,
  backendUnit: 68,
  backendIntegration: 122,
  startedOn: "24 October 2026",
  firstCommit: "26 October 2026",
};

export const judgeLogin = () => !!(judge.email && judge.password);
export const isJudgeVenue = (restaurantId: number) =>
  judge.restaurantId > 0 && restaurantId === judge.restaurantId;

/** "12 s" or "1 min 05 s": how long a demo has been running. */
export function elapsed(ms: number): string {
  const s = Math.max(0, Math.round(ms / 1000));
  return s < 60 ? `${s} s` : `${Math.floor(s / 60)} min ${String(s % 60).padStart(2, "0")} s`;
}

export interface Dish {
  productId: number;
  name: string;
  priceMinor: number;
  category?: string;
  modifiers?: { id: string; name: string; options?: { id: string; name: string; priceMinor: number }[] }[];
}

export type DraftRow = {
  name: string;
  category: string;
  priceMinor: number;
  available: boolean;
  change: "new" | "price" | "same";
  was?: number;
};

/** What reading the menu photo would change on the current menu. */
export function menuChanges(draft: Json[], menu: Dish[]): DraftRow[] {
  const current = new Map(menu.map((d) => [d.name.trim().toLowerCase(), d]));
  return draft.map((raw) => {
    const name = String(raw.name ?? "");
    const priceMinor = Number(raw.priceMinor ?? 0);
    const old = current.get(name.trim().toLowerCase());
    return {
      name,
      category: String(raw.category ?? ""),
      priceMinor,
      available: raw.available !== false,
      change: !old ? "new" : old.priceMinor !== priceMinor ? "price" : "same",
      ...(old && old.priceMinor !== priceMinor ? { was: old.priceMinor } : {}),
    };
  });
}

/** The ticket lines the counter voice heard, in the menu's own words. */
export function heardLines(lines: Json[], menu: Dish[]): string[] {
  const byId = new Map(menu.map((d) => [d.productId, d]));
  return lines.map((line) => {
    const dish = byId.get(Number(line.productId));
    const chosen = ((line.options as string[] | undefined) ?? []).map((ref) => {
      const [group, option] = ref.split(":");
      return (
        dish?.modifiers
          ?.find((g) => g.id === group)
          ?.options?.find((o) => o.id === option)?.name ?? option
      );
    });
    const note = typeof line.note === "string" && line.note ? ` (${line.note})` : "";
    return `${Number(line.quantity ?? 1)}× ${dish?.name ?? `dish ${line.productId}`}${
      chosen.length ? ` + ${chosen.join(", ")}` : ""
    }${note}`;
  });
}

/** The basket the takeaway assistant proposed, if it proposed one. */
export function basketOf(run: Json | undefined) {
  const proposal = run?.proposal as Json | undefined;
  if (!proposal || proposal.kind !== "basket") return undefined;
  const quote = ((proposal.payload as Json | undefined)?.quote ?? {}) as Json;
  return {
    id: Number(proposal.id),
    version: Number(proposal.version),
    lines: ((quote.lines as Json[] | undefined) ?? []).map(
      (l) => `${Number(l.quantity ?? 1)}× ${String(l.name ?? "")}`,
    ),
    totalMinor: Number(quote.totalMinor ?? 0),
    currency: String(quote.currency ?? "USD"),
    slot: typeof quote.slot === "string" ? quote.slot : undefined,
  };
}

/** Tool steps an agent or the assistant took, for the "how it got there" line. */
export function toolsUsed(trace: unknown): string[] {
  if (!Array.isArray(trace)) return [];
  const names = trace
    .map((t) => (t && typeof t === "object" ? ((t as Json).tool ?? (t as Json).name) : undefined))
    .filter((n): n is string => typeof n === "string");
  return [...new Set(names)];
}
