/**
 * POST /api/partner-sim/webhook: where Raysto sends the simulator's signed
 * webhooks. The signature is checked with the simulator's secret before
 * anything is kept; an unsigned or stale call is refused with 401, which
 * Raysto records and retries.
 */
import { json, refuse, remember, simConfig, verify } from "@/lib/server/partner-sim";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const config = simConfig();
  if (!config) return refuse(404, "not_configured", "The delivery simulator is not on this deployment yet.");
  const body = await request.text();
  if (body.length > 65536) return refuse(413, "payload_too_large", "Too large.");
  if (!verify(config.secret, request.headers.get("x-raysto-signature"), body))
    return refuse(401, "bad_signature", "The signature does not match.");
  const hook = remember(body);
  if (!hook) return refuse(400, "invalid_event", "Not a Raysto event.");
  return json(200, { received: true, id: hook.id });
}
