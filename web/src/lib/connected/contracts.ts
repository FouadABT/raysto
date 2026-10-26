/** Additive /api/v2 contracts. Money is always integer minor units. */
export type Json = Record<string, unknown>;
export type AttentionFilter = "all" | "billRequested" | "paymentExceptions";
export interface Membership {
  restaurantId: number;
  name: string;
  role: string;
}
export interface ServiceRow {
  id: number;
  kind: string;
  status: string;
  version: number;
}
export interface PaymentRow {
  checkoutId: number;
  state: string;
  amountMinor: number;
}
export interface TableRow {
  id: number;
  label: string;
  zone: string;
  geometry: Json;
  capacity: number;
  visitId: number | null;
  roomId: number | null;
  guests: number;
  status: string;
  outstandingMinor: number;
  currency: string;
  serviceCount: number;
  billRequested: boolean;
  paymentException: boolean;
  services: ServiceRow[];
  payments: PaymentRow[];
}
export interface OperationsSnapshot {
  restaurantId: number;
  name: string;
  currency: string;
  filter: AttentionFilter;
  rows: TableRow[];
  asOf: string;
  layout: Json | null;
  layoutVersion: number;
  outstandingMinor: number;
  eventCursor: number;
  floor: {
    width: number;
    height: number;
    objects: { id: string; kind: string; label: string; geometry: Json }[];
  } | null;
}
export interface RoomMessage {
  id: number;
  sequence: number;
  kind: string;
  userId: string | null;
  clientMessageId: string | null;
  replyToId: number | null;
  body: Json;
  createdAt: string;
}
export interface RoomSnapshot {
  id: number;
  restaurantId: number;
  visitId: number | null;
  orderId: number | null;
  hostUserId: string | null;
  currentUserId: string;
  audience: string;
  aiDisclosure: string;
  version: number;
  sequence: number;
  closed: boolean;
  messages: RoomMessage[];
  members: {
    userId: string;
    name: string;
    role: string;
    lastReadSequence: number;
  }[];
  beforeCursor: number | null;
}
export interface AssistantResult {
  id: number;
  status: string;
  answer: {
    text?: string;
    presentation?: {
      filter: AttentionFilter;
      asOf: string;
      view?: "overview" | "payments" | "service";
    };
  };
  steps: { tool: string; status: string; source?: string }[];
}
export interface AssistantHistory extends AssistantResult {
  threadKey: string;
  text: string;
  createdAt: string;
}
export const currency = (minor: number, code: string) =>
  new Intl.NumberFormat("en", { style: "currency", currency: code }).format(
    minor / 100,
  );
