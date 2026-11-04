/**
 * POST /api/partner-sim/orders: the simulator ("Demo Delivery Co.", a
 * pretend outside delivery app, not Uber Eats or Glovo) sends one signed
 * sample order to the judges' café through the real Delivery Partner API.
 * Body: `{restaurantId, fulfilledBy?: "restaurant" | "partner"}`.
 */
import { authorize, json, partnerCall, refuse, sampleDropoffs, sampleLines, sampleRef, simConfig } from "@/lib/server/partner-sim";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const config = simConfig();
  if (!config) return refuse(404, "not_configured", "The delivery simulator is not on this deployment yet.");
  const denied = await authorize(request, config);
  if (denied) return denied;
  const text = await request.text();
  if (text.length > 4096) return refuse(413, "payload_too_large", "Too large.");
  let input: { restaurantId?: unknown; fulfilledBy?: unknown };
  try {
    input = text ? (JSON.parse(text) as typeof input) : {};
  } catch {
    return refuse(400, "invalid_json", "Send JSON.");
  }
  if (input.restaurantId != null && Number(input.restaurantId) !== config.restaurantId)
    return refuse(403, "forbidden", "The simulator only sends orders to the judges' café.");
  const fulfilledBy = input.fulfilledBy === "partner" ? "partner" : "restaurant";
  try {
    const menu = await partnerCall(config, "GET", "menu");
    if (menu.status !== 200) return json(menu.status, menu.data);
    const lines = sampleLines(menu.data.items);
    if (lines.length === 0) return refuse(409, "no_items", "The café has nothing on its menu to order.");
    const ref = sampleRef();
    const dropoff = sampleDropoffs[Math.floor(Math.random() * sampleDropoffs.length)];
    const sent = await partnerCall(config, "POST", "orders", {
      ref,
      fulfilledBy,
      lines,
      address: dropoff,
      customer: { name: "Sample customer" },
      note: "Sent by the Raysto partner simulator.",
    });
    return json(sent.status, sent.status < 300 ? { data: { ...sent.data, ref, simulator: true } } : sent.data);
  } catch {
    return refuse(502, "partner_api_unavailable", "The Delivery Partner API did not answer.");
  }
}
