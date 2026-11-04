import { test } from "node:test";
import assert from "node:assert/strict";
import { allowedPath } from "../src/lib/connected/proxy-allowlist";
import { checkUpload, readLimited, uploadMaximum } from "../src/lib/connected/upload-proxy";

const ok = { path: "media/12/content", origin: "https://ops.rays.to", expectedOrigin: "https://ops.rays.to", contentType: "application/pdf", contentLength: "2048" };

test("the upload route relays only a file's content, from the console, as a photo or PDF up to 8 MiB", () => {
  assert.deepEqual(checkUpload(ok), { ok: true, type: "application/pdf" });
  assert.deepEqual(checkUpload({ ...ok, contentType: "image/JPEG; charset=binary" }), { ok: true, type: "image/jpeg" });
  for (const path of ["media/12", "media/0/content", "media/12/content/x", "commands/media.upload", "../media/12/content", "media/abc/content"])
    assert.equal(checkUpload({ ...ok, path }).ok, false, path);
  assert.deepEqual(checkUpload({ ...ok, origin: "https://evil.example" }), { ok: false, status: 403, code: "invalid_origin" });
  assert.deepEqual(checkUpload({ ...ok, origin: null }), { ok: false, status: 403, code: "invalid_origin" });
  assert.deepEqual(checkUpload({ ...ok, contentType: "text/html" }), { ok: false, status: 415, code: "unsupported_type" });
  assert.deepEqual(checkUpload({ ...ok, contentType: null }), { ok: false, status: 415, code: "unsupported_type" });
  assert.deepEqual(checkUpload({ ...ok, contentLength: String(uploadMaximum + 1) }), { ok: false, status: 413, code: "payload_too_large" });
  assert.deepEqual(checkUpload({ ...ok, contentLength: "0" }), { ok: false, status: 400, code: "empty_file" });
  // The general allowlist never opens the content path to GET or POST.
  assert.equal(allowedPath("media/12/content"), false);
});

const stream = (sizes: number[]) =>
  new ReadableStream<Uint8Array>({
    start(c) {
      for (const n of sizes) c.enqueue(new Uint8Array(n).fill(7));
      c.close();
    },
  });

test("the body is read up to the limit and refused beyond it, without lying about its length", async () => {
  const body = await readLimited(stream([3, 4]), 10);
  assert.equal(body?.length, 7);
  assert.equal(body?.[6], 7);
  assert.equal(await readLimited(stream([6, 6]), 10), null);
  assert.equal((await readLimited(null, 10))?.length, 0);
});
