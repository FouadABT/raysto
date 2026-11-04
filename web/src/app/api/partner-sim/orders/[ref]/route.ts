/** GET /api/partner-sim/orders/{ref}: the simulator reads one of its orders. */
import { authorize, json, partnerCall, refuse, simConfig } from "@/lib/server/partner-sim";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(request: Request, context: { params: Promise<{ ref: string }> }) {
  const config = simConfig();
  if (!config) return refuse(404, "not_configured", "The delivery simulator is not on this deployment yet.");
  const denied = await authorize(request, config);
  if (denied) return denied;
  const { ref } = await context.params;
  if (!/^[A-Za-z0-9_-]{1,64}$/.test(ref)) return refuse(400, "invalid_input", "Unknown ref.");
  try {
    const read = await partnerCall(config, "GET", `orders/${ref}`);
    return json(read.status, read.status < 300 ? { data: read.data } : read.data);
  } catch {
    return refuse(502, "partner_api_unavailable", "The Delivery Partner API did not answer.");
  }
}
