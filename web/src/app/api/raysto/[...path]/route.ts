import { NextRequest } from "next/server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
const safePath =
  /^(auth\/firebase|queries\/[a-z.]+|commands\/[a-z.]+|rooms\/[1-9][0-9]*\/events|events)$/;
const maximum = 131072;

async function proxy(
  request: NextRequest,
  context: { params: Promise<{ path: string[] }> },
) {
  const path = (await context.params).path.join("/");
  if (!safePath.test(path))
    return Response.json({ error: { code: "not_found" } }, { status: 404 });
  const origin =
    process.env.RAYSTO_CONSOLE_ORIGIN ??
    (process.env.NODE_ENV === "production"
      ? "https://ops.rays.to"
      : request.nextUrl.origin);
  if (request.method === "POST" && request.headers.get("origin") !== origin)
    return Response.json(
      { error: { code: "invalid_origin" } },
      { status: 403 },
    );
  const headers = new Headers();
  for (const name of [
    "authorization",
    "x-raysto-firebase-token",
    "x-firebase-appcheck",
    "content-type",
    "accept",
  ]) {
    const value = request.headers.get(name);
    if (value && value.length <= 20000) headers.set(name, value);
  }
  let body: Uint8Array | undefined;
  if (request.method === "POST") {
    if (Number(request.headers.get("content-length") ?? 0) > maximum)
      return new Response(null, { status: 413 });
    const reader = request.body?.getReader();
    const chunks: Uint8Array[] = [];
    let size = 0;
    if (reader) {
      let timedOut = false;
      const bodyTimer = setTimeout(() => {
        timedOut = true;
        void reader.cancel();
      }, 15000);
      try {
        while (true) {
          const part = await reader.read();
          if (part.done) break;
          size += part.value.length;
          if (size > maximum) {
            await reader.cancel();
            return new Response(null, { status: 413 });
          }
          chunks.push(part.value);
        }
        if (timedOut) return new Response(null, { status: 408 });
      } finally {
        clearTimeout(bodyTimer);
        reader.releaseLock();
      }
    }
    body = new Uint8Array(size);
    let offset = 0;
    for (const chunk of chunks) {
      body.set(chunk, offset);
      offset += chunk.length;
    }
  }
  const controller = new AbortController();
  const stop = () => controller.abort();
  request.signal.addEventListener("abort", stop, { once: true });
  const timer = setTimeout(stop, 45000);
  try {
    // Fixed origin; client paths can never turn this into an open proxy.
    const result = await fetch(
      `https://api.rays.to/api/v2/${path}${request.nextUrl.search}`,
      {
        method: request.method,
        headers,
        body: body as BodyInit | undefined,
        cache: "no-store",
        redirect: "error",
        signal: controller.signal,
      },
    );
    const stream = result.body?.getReader();
    const cleanup = () => {
      clearTimeout(timer);
      request.signal.removeEventListener("abort", stop);
    };
    return new Response(
      stream
        ? new ReadableStream({
            async pull(out) {
              try {
                const next = await stream.read();
                if (next.done) {
                  cleanup();
                  out.close();
                } else out.enqueue(next.value);
              } catch (e) {
                cleanup();
                out.error(e);
              }
            },
            async cancel() {
              stop();
              cleanup();
              await stream.cancel();
            },
          })
        : null,
      {
        status: result.status,
        headers: {
          "Content-Type":
            result.headers.get("content-type") ?? "application/json",
          "Cache-Control": "no-store, no-transform",
          "X-Accel-Buffering": "no",
          "X-Content-Type-Options": "nosniff",
        },
      },
    );
  } catch {
    clearTimeout(timer);
    request.signal.removeEventListener("abort", stop);
    return Response.json(
      {
        error: {
          code: "backend_unavailable",
          message: "The restaurant service is temporarily unavailable.",
        },
      },
      { status: 502 },
    );
  }
}
export const GET = proxy;
export const POST = proxy;
