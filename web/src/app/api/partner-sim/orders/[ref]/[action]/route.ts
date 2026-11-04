/**
 * POST /api/partner-sim/orders/{ref}/cancel and /status: the simulator
 * cancels one of its orders, or reports its own courier's pickup and
 * handover (`{status: "picked_up" | "delivered"}`).
 */
import { authorize, json, partnerCall, refuse, simConfig } from "@/lib/server/partner-sim";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(request: Request, context: { params: Promise<{ ref: string; action: string }> }) {
  const config = simConfig();
  if (!config) return refuse(404, "not_configured", "The delivery simulator is not on this deployment yet.");
  const denied = await authorize(request, config);
  if (denied) return denied;
  const { ref, action } = await context.params;
  if (!/^[A-Za-z0-9_-]{1,64}$/.test(ref) || !["cancel", "status"].includes(action)) return refuse(404, "not_found", "Unknown endpoint.");
  let input: Record<string, unknown> = {};
  try {
    const text = await request.text();
    if (text.length > 2048) return refuse(413, "payload_too_large", "Too large.");
    input = text ? (JSON.parse(text) as Record<string, unknown>) : {};
  } catch {
    return refuse(400, "invalid_json", "Send JSON.");
  }
  const body =
    action === "cancel"
      ? { reason: "Cancelled from the partner simulator." }
      : {
          status: input.status === "delivered" ? "delivered" : "picked_up",
          ...(input.status === "delivered" ? {} : { courier: { name: "Sim courier", vehicle: "scooter" } }),
        };
  try {
    const sent = await partnerCall(config, "POST", `orders/${ref}/${action}`, body);
    return json(sent.status, sent.status < 300 ? { data: sent.data } : sent.data);
  } catch {
    return refuse(502, "partner_api_unavailable", "The Delivery Partner API did not answer.");
  }
}
