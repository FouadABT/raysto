"use client";
import { useEffect, useRef, useState } from "react";
import { ConnectedApi } from "@/lib/connected/api";
import type { RoomSnapshot } from "@/lib/connected/contracts";
export function RoomPanel({
  api,
  tenant,
  roomId,
  table,
  onDirty,
}: {
  api: ConnectedApi;
  tenant: number;
  roomId: number;
  table: string;
  onDirty: (dirty: boolean) => void;
}) {
  const [room, setRoom] = useState<RoomSnapshot>();
  const [text, setText] = useState("");
  const [error, setError] = useState("");
  const [connectionError, setConnectionError] = useState("");
  const [busy, setBusy] = useState(false);
  const [status, setStatus] = useState("Connecting");
  const [reply, setReply] = useState<number>();
  const key = useRef({
    text: "",
    id: crypto.randomUUID(),
    reply: undefined as number | undefined,
  });
  const refresh = useRef<() => Promise<void>>(async () => {});
  const dirtyRef = useRef(onDirty);
  dirtyRef.current = onDirty;
  useEffect(() => {
    dirtyRef.current(!!text.trim());
    return () => dirtyRef.current(false);
  }, [text]);
  useEffect(() => {
    let active = true;
    let cursor = 0;
    const controller = new AbortController();
    async function load() {
      const data = await api.query<RoomSnapshot>(
        "room",
        { restaurantId: tenant, id: roomId },
        controller.signal,
      );
      if (active) {
        setRoom(data);
        cursor = data.sequence;
        if (document.visibilityState === "visible")
          await api.command(
            "room.read",
            tenant,
            { sequence: data.sequence },
            { id: roomId },
          );
      }
    }
    refresh.current = load;
    async function connect() {
      try {
        await load();
        while (active) {
          try {
            await api.stream(
              `rooms/${roomId}/events?restaurantId=${tenant}&after=${cursor}`,
              controller.signal,
              (event) => {
                if (!active) return;
                if (event.kind === "access.error") {
                  setRoom(undefined);
                  setError("Access to this room ended.");
                  active = false;
                  controller.abort();
                  return;
                }
                setStatus("Live");
                setConnectionError("");
                cursor = Number(event.cursor ?? cursor);
                if (
                  (event.events as unknown[] | undefined)?.length ||
                  event.reset
                )
                  void load().catch((e) => active && setError(String(e)));
              },
            );
          } catch (e) {
            if (!active) return;
            setStatus("Periodic refresh");
            setConnectionError(String(e));
            await new Promise((r) => setTimeout(r, 10000));
            await load();
          }
        }
      } catch (e) {
        if (active) {
          setRoom(undefined);
          setError(String(e));
        }
      }
    }
    void connect();
    return () => {
      active = false;
      controller.abort();
    };
  }, [api, tenant, roomId]);
  useEffect(() => {
    const warn = (event: BeforeUnloadEvent) => {
      if (text.trim()) {
        event.preventDefault();
        event.returnValue = "";
      }
    };
    window.addEventListener("beforeunload", warn);
    return () => window.removeEventListener("beforeunload", warn);
  }, [text]);
  async function send() {
    if (!text.trim() || busy) return;
    setBusy(true);
    setError("");
    if (key.current.text !== text || key.current.reply !== reply)
      key.current = { text, id: crypto.randomUUID(), reply };
    try {
      await api.command(
        "room.message",
        tenant,
        {
          text: text.trim(),
          clientMessageId: key.current.id,
          ...(reply ? { replyToId: reply } : {}),
        },
        { id: roomId, key: key.current.id },
      );
      setText("");
      setReply(undefined);
      await refresh.current();
    } catch (e) {
      setError(String(e));
    } finally {
      setBusy(false);
    }
  }
  return (
    <>
      <header>
        <span className="ops-eyebrow">{status}</span>
        <h2>{table} · Around the table</h2>
        <p>{room?.audience}</p>
      </header>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      {connectionError && !error && (
        <p className="ops-error" role="status">
          {connectionError}
        </p>
      )}
      <div className="ops-messages" aria-live="polite">
        {room?.messages.map((message) => {
          const member = room.members.find((m) => m.userId === message.userId);
          const body = message.body;
          return (
            <article
              key={message.id}
              className={
                message.kind === "activity" ? "ops-system-message" : ""
              }
            >
              <small>
                {message.kind === "assistant.answer"
                  ? "Raysto"
                  : (member?.name ?? "Table update")}
              </small>
              <p>
                {String(body.text ?? body.event ?? "Table activity").replace(
                  /\.(?=[a-z])/g,
                  " · ",
                )}
              </p>
              {message.kind === "message" && !room.closed && (
                <button onClick={() => setReply(message.id)}>Reply</button>
              )}
            </article>
          );
        })}
      </div>
      {room && !room.closed && (
        <form
          className="ops-composer"
          onSubmit={(e) => {
            e.preventDefault();
            void send();
          }}
        >
          {reply && (
            <button type="button" onClick={() => setReply(undefined)}>
              Cancel reply
            </button>
          )}
          <label>
            Message diners and assigned waiter
            <textarea
              maxLength={2000}
              rows={2}
              value={text}
              onChange={(e) => setText(e.target.value)}
            />
          </label>
          <button
            disabled={busy || !text.trim()}
            type="submit"
            className="ops-primary"
          >
            {busy ? "Sending…" : "Send to table"}
          </button>
        </form>
      )}
      {room?.closed && <p>This visit is closed. Its history is read-only.</p>}
    </>
  );
}
