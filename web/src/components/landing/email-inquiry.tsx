"use client";

import { useEffect, useRef, useState } from "react";

const draftKey = "raysto.marketing.inquiry";

/** Email demo only: prepares local text, never calls a submission endpoint. */
export function EmailInquiry({ recipient = "" }: { recipient?: string }) {
  const form = useRef<HTMLFormElement>(null);
  const [name, setName] = useState(""),
    [restaurant, setRestaurant] = useState(""),
    [message, setMessage] = useState("");
  const [status, setStatus] = useState("");
  const [restored, setRestored] = useState(false),
    [retained, setRetained] = useState(true);
  useEffect(() => {
    try {
      const draft = JSON.parse(sessionStorage.getItem(draftKey) ?? "null");
      if (
        draft &&
        typeof draft.name === "string" &&
        typeof draft.restaurant === "string" &&
        typeof draft.message === "string"
      ) {
        setName(draft.name.slice(0, 100));
        setRestaurant(draft.restaurant.slice(0, 160));
        setMessage(draft.message.slice(0, 1500));
      }
    } catch {
      setRetained(false);
    }
    setRestored(true);
  }, []);
  useEffect(() => {
    if (!restored) return;
    try {
      if (name || restaurant || message)
        sessionStorage.setItem(
          draftKey,
          JSON.stringify({ name, restaurant, message }),
        );
      else sessionStorage.removeItem(draftKey);
    } catch {
      setRetained(false);
    }
  }, [name, restaurant, message, restored]);
  const body = `Hello Raysto,\n\nI'd like a closer look at the restaurant workspace.\n\nName: ${name || "[Your name]"}\nRestaurant: ${restaurant || "[Your restaurant]"}\n\n${message || "I'd like to discuss orders, service, payments and AI assistance."}\n\nThank you.`;
  const href = `mailto:${recipient}?subject=${encodeURIComponent("Raysto demo inquiry")}&body=${encodeURIComponent(body)}`;
  return (
    <div className="lp-inquiry">
      <p className="lp-inquiry-notice">
        Email demo · This page prepares a draft. It does not send a message or
        confirm a booking.
        {!recipient &&
          " Add the recipient in your email app before sending; a Raysto booking inbox is not configured in this preview."}
      </p>
      <form ref={form} onSubmit={(event) => event.preventDefault()}>
        <label>
          Your name <small>Optional</small>
          <input
            autoComplete="name"
            value={name}
            onChange={(event) => setName(event.target.value)}
            maxLength={100}
          />
        </label>
        <label>
          Restaurant or café <small>Optional</small>
          <input
            autoComplete="organization"
            value={restaurant}
            onChange={(event) => setRestaurant(event.target.value)}
            maxLength={160}
          />
        </label>
        <label>
          What would you like to explore?
          <textarea
            value={message}
            onChange={(event) => setMessage(event.target.value)}
            maxLength={1500}
            placeholder="Tell us a little about your service."
          />
        </label>
        <div className="lp-actions">
          <a
            className="lp-button"
            href={href}
            onClick={() =>
              setStatus(
                "Email draft requested. Review the recipient and message in your email app; nothing was sent by this website.",
              )
            }
          >
            Prepare email draft{" "}
            <span className="material-symbols-rounded" aria-hidden="true">
              north_east
            </span>
          </a>
          <button
            type="button"
            className="lp-button lp-button-outline"
            onClick={async () => {
              try {
                await navigator.clipboard.writeText(
                  `Subject: Raysto demo inquiry\n\n${body}`,
                );
                setStatus(
                  "Inquiry copied. Paste it into an email when you are ready. Nothing has been sent.",
                );
              } catch {
                setStatus(
                  "Copy is unavailable in this browser. Use Prepare email draft instead.",
                );
              }
            }}
          >
            Copy inquiry
          </button>
          <button
            type="button"
            className="lp-text-button"
            onClick={() => {
              setName("");
              setRestaurant("");
              setMessage("");
              setStatus("Draft cleared.");
            }}
          >
            Clear draft
          </button>
        </div>
        <p className="lp-inquiry-status" role="status">
          {status}
        </p>
        <small className="lp-preview-label">
          {retained
            ? "Your draft is retained in this browser tab until you clear it."
            : "Browser storage is unavailable. Keep this page open to retain your draft."}{" "}
          Preparing an email uses your own email app.
        </small>
      </form>
    </div>
  );
}
