/**
 * The console proxy's one upload: `PUT media/{id}/content`, the bytes of a
 * file reserved with the `media.upload` command. Pure checks, so the route
 * stays small and the rules are unit-tested (tests/upload-proxy.test.ts).
 * The backend checks the size and SHA-256 against the reservation and scans
 * the file before anyone can use it; this only refuses what can never pass.
 */

/** The backend's own limit for one file (8 MiB). */
export const uploadMaximum = 8 * 1024 * 1024;

/** Photos and PDFs, as `media.upload` accepts them. */
export const uploadTypes = new Set(["image/jpeg", "image/png", "image/webp", "application/pdf"]);

const contentPath = /^media\/[1-9][0-9]{0,15}\/content$/;

export type UploadCheck = { ok: true; type: string } | { ok: false; status: number; code: string };

/** Whether a PUT may be relayed: the path, the console's own origin, a known type and size. */
export function checkUpload(input: {
  path: string;
  origin: string | null;
  expectedOrigin: string;
  contentType: string | null;
  contentLength: string | null;
}): UploadCheck {
  if (!contentPath.test(input.path)) return { ok: false, status: 404, code: "not_found" };
  if (input.origin !== input.expectedOrigin) return { ok: false, status: 403, code: "invalid_origin" };
  const type = (input.contentType ?? "").split(";")[0].trim().toLowerCase();
  if (!uploadTypes.has(type)) return { ok: false, status: 415, code: "unsupported_type" };
  if (input.contentLength != null && input.contentLength !== "") {
    const declared = Number(input.contentLength);
    if (!Number.isFinite(declared) || declared < 1) return { ok: false, status: 400, code: "empty_file" };
    if (declared > uploadMaximum) return { ok: false, status: 413, code: "payload_too_large" };
  }
  return { ok: true, type };
}

/**
 * Reads a request body up to [limit] bytes. Returns null when it is larger,
 * so the caller answers 413 without buffering the rest.
 */
export async function readLimited(body: ReadableStream<Uint8Array> | null, limit: number): Promise<Uint8Array | null> {
  if (!body) return new Uint8Array(0);
  const reader = body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const part = await reader.read();
      if (part.done) break;
      size += part.value.length;
      if (size > limit) {
        await reader.cancel();
        return null;
      }
      chunks.push(part.value);
    }
  } finally {
    reader.releaseLock();
  }
  const out = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    out.set(chunk, offset);
    offset += chunk.length;
  }
  return out;
}
