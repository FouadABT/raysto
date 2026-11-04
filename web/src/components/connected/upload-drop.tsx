"use client";
/**
 * Drop a photo or a PDF here, or pick one: the file is hashed in the
 * browser, reserved, sent and scanned, and [onReady] gets its media id.
 * Reusable by any section (bills, receipts, delivery notes, proofs).
 * Keyboard: the whole zone is one button; drag and drop is a shortcut, never
 * the only way. Progress is announced in a polite live region.
 * Owner: stream S1.
 */
import { useRef, useState, type DragEvent } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import { fileProblem, stageWords, uploadAccept, uploadFile, type UploadPurpose, type UploadStage } from "@/lib/connected/uploads";
import { Icon } from "./icons";
import "./upload-drop.css";

export function UploadDrop({
  api,
  tenant,
  purpose,
  label,
  hint = "A photo (JPEG, PNG, WebP) or a PDF, up to 8 MB.",
  disabled = false,
  onReady,
  compact = false,
}: {
  api: ConnectedApi;
  tenant: number;
  purpose: UploadPurpose;
  /** What the zone asks for ("Drop a bill here"). */
  label: string;
  hint?: string;
  disabled?: boolean;
  /** Called once the scanner approved the file. */
  onReady: (mediaId: number, file: File) => void | Promise<void>;
  compact?: boolean;
}) {
  const input = useRef<HTMLInputElement>(null);
  const [over, setOver] = useState(false);
  const [stage, setStage] = useState<UploadStage>();
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const busy = stage !== undefined && stage !== "ready";

  async function send(file: File | undefined) {
    if (!file || busy || disabled) return;
    setError("");
    setName(file.name);
    const problem = fileProblem(file);
    if (problem) {
      setError(problem);
      return;
    }
    try {
      const id = await uploadFile(api, tenant, purpose, file, setStage);
      await onReady(id, file);
    } catch (e) {
      setStage(undefined);
      setError(e instanceof Error ? e.message : String(e));
    }
  }

  function dropped(e: DragEvent<HTMLButtonElement>) {
    e.preventDefault();
    setOver(false);
    void send(e.dataTransfer.files?.[0]);
  }

  return (
    <div className={`ops-upload${compact ? " compact" : ""}`}>
      <button
        type="button"
        className={`ops-upload-zone${over ? " over" : ""}${busy ? " busy" : ""}`}
        disabled={disabled || busy}
        aria-describedby={`upload-hint-${purpose}`}
        onClick={() => input.current?.click()}
        onDragOver={(e) => {
          e.preventDefault();
          if (!over) setOver(true);
        }}
        onDragLeave={() => setOver(false)}
        onDrop={dropped}
      >
        <Icon name={busy ? "refresh" : "upload"} size={22} />
        <span className="ops-upload-label">{busy ? `${name}` : label}</span>
        <small id={`upload-hint-${purpose}`}>{busy ? stageWords[stage!] : hint}</small>
      </button>
      <input
        ref={input}
        type="file"
        accept={uploadAccept}
        hidden
        tabIndex={-1}
        onChange={(e) => {
          void send(e.target.files?.[0]);
          e.target.value = "";
        }}
      />
      <p className="ops-note" role="status" aria-live="polite">
        {stage === "ready" ? `${name}: checked and sent.` : ""}
      </p>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
    </div>
  );
}
