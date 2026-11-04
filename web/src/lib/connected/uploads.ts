/**
 * Sending a file to Raysto from the console, in the three steps the backend
 * asks for: reserve it (`media.upload` with its type, size and SHA-256),
 * send the bytes (`PUT media/{id}/content`, through the console proxy), then
 * wait for the scanner to approve it. Shared by the accountant's bills and
 * receipts (stream S1) and any section that takes a photo or a PDF.
 */
import { ApiFailure, type ConnectedApi } from "./api";
import type { Json } from "./contracts";
import { uploadMaximum, uploadTypes } from "./upload-proxy";

export type UploadPurpose = "bill" | "receipt" | "deliveryNote" | "deliveryProof" | "support";
export type UploadStage = "checking" | "reserving" | "sending" | "scanning" | "ready";

export const uploadAccept = [...uploadTypes].join(",");

/** Why a file cannot be sent, in plain words, or null when it can. */
export function fileProblem(file: { type: string; size: number }): string | null {
  if (!uploadTypes.has(file.type)) return "Use a JPEG, PNG or WebP photo, or a PDF.";
  if (file.size < 1) return "This file is empty.";
  if (file.size > uploadMaximum) return "Keep the file under 8 MB.";
  return null;
}

/** SHA-256 of the bytes, as lowercase hex. */
export async function sha256Hex(data: ArrayBuffer): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

const pause = (ms: number, signal?: AbortSignal) =>
  new Promise<void>((resolve, reject) => {
    const t = setTimeout(resolve, ms);
    signal?.addEventListener(
      "abort",
      () => {
        clearTimeout(t);
        reject(new ApiFailure("cancelled", "Stopped."));
      },
      { once: true },
    );
  });

/**
 * Waits until the scanner has looked at the file: resolves when it is
 * approved, fails when it is rejected or takes longer than [timeoutMs].
 * Reads the person's own files (`media` without a restaurant).
 */
export async function waitForScan(
  api: Pick<ConnectedApi, "query">,
  mediaId: number,
  { signal, intervalMs = 1500, timeoutMs = 90000 }: { signal?: AbortSignal; intervalMs?: number; timeoutMs?: number } = {},
): Promise<void> {
  const until = Date.now() + timeoutMs;
  while (Date.now() < until) {
    const page = await api.query<{ rows?: Json[] }>("media", { cursor: mediaId - 1, limit: 1 }, signal);
    const row = (page.rows ?? []).find((r) => r.id === mediaId);
    if (row?.status === "approved") return;
    if (row?.status === "rejected") throw new ApiFailure("file_rejected", "The file scanner refused this file. Try another photo or PDF.");
    await pause(intervalMs, signal);
  }
  throw new ApiFailure("scan_timeout", "The file is still being checked. Try again in a minute.");
}

/** Reserves, sends and waits for one file; returns its media id once approved. */
export async function uploadFile(
  api: ConnectedApi,
  tenant: number,
  purpose: UploadPurpose,
  file: File,
  onStage: (stage: UploadStage) => void = () => {},
  signal?: AbortSignal,
): Promise<number> {
  onStage("checking");
  const problem = fileProblem(file);
  if (problem) throw new ApiFailure("invalid_input", problem);
  const sha256 = await sha256Hex(await file.arrayBuffer());
  onStage("reserving");
  const reserved = await api.command<{ mediaId: number }>("media.upload", tenant, {
    purpose,
    mime: file.type,
    byteLength: file.size,
    sha256,
  });
  const put = (api as Partial<Pick<ConnectedApi, "upload">>).upload;
  if (typeof put !== "function") throw new ApiFailure("upload_unavailable", "This console cannot send files here.");
  onStage("sending");
  await put.call(api, reserved.mediaId, file);
  onStage("scanning");
  await waitForScan(api, reserved.mediaId, { signal });
  onStage("ready");
  return reserved.mediaId;
}

export const stageWords: Record<UploadStage, string> = {
  checking: "Checking the file…",
  reserving: "Preparing the upload…",
  sending: "Sending…",
  scanning: "Scanning for safety…",
  ready: "Ready.",
};
