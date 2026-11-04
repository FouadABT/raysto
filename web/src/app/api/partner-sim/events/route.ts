/** GET /api/partner-sim/events: the last 50 webhooks the simulator received and verified. */
import { authorize, hooks, json, refuse, simConfig } from "@/lib/server/partner-sim";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const config = simConfig();
  if (!config) return refuse(404, "not_configured", "The delivery simulator is not on this deployment yet.");
  const denied = await authorize(request, config);
  if (denied) return denied;
  return json(200, { data: { rows: hooks } });
}
