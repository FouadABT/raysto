"use client";
import { useEffect, useRef, useState } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import type {
  FinanceAnalysis,
  PriceComparison,
  DecisionView,
} from "@/lib/connected/finance";
import { useScopedDraft } from "@/lib/connected/scoped-draft";

/** A narrow-screen path through the same bounded, authenticated Studio-turn API. */
export function FinanceAnalyst({
  api,
  tenant,
  productId,
  comparison,
  dirty,
  onComparison,
  onPresentation,
}: {
  api: ConnectedApi;
  tenant: number;
  productId?: number;
  comparison?: PriceComparison;
  dirty: boolean;
  onComparison?: (value: PriceComparison) => void;
  onPresentation: (value: DecisionView) => void;
}) {
  const [text, setText] = useScopedDraft(
    api,
    `analyst:${tenant}:${productId}`,
    "",
  );
  const [summary, setSummary] = useState(""),
    [notice, setNotice] = useState(""),
    [busy, setBusy] = useState(false);
  const [source, setSource] = useState("");
  const [summaryScope, setSummaryScope] = useState("");
  const turn = useRef<AbortController | undefined>(undefined);
  const token = JSON.stringify([
    api.scopeKey,
    tenant,
    productId,
    comparison?.id,
    dirty,
  ]);
  const current = useRef(token);
  current.current = token;
  useEffect(() => {
    setBusy(false);
    return () => {
      turn.current?.abort();
    };
  }, [token]);
  async function ask() {
    if (busy || dirty || !text.trim()) return;
    const controller = new AbortController();
    turn.current = controller;
    const scope = token;
    setBusy(true);
    setNotice("Preparing an evidence-based analysis…");
    setSummary("");
    setSource("");
    try {
      const task = await api.command<{ taskId: number }>(
        "studio.turn",
        tenant,
        {
          text: text.trim(),
          productId,
          ...(comparison ? { comparisonId: comparison.id } : {}),
        },
        { key: crypto.randomUUID() },
      );
      controller.signal.throwIfAborted();
      if (current.current !== scope) return;
      setNotice(
        `Analysis task ${task.taskId}. Cancelling this view does not cancel its background task.`,
      );
      for (let i = 0; i < 75; i++) {
        const result = await api.query<FinanceAnalysis>(
          "finance.analysis",
          { restaurantId: tenant, id: task.taskId },
          controller.signal,
        );
        controller.signal.throwIfAborted();
        if (current.current !== scope) return;
        if (
          result.source === "gemini" ||
          result.source === "deterministic-fallback"
        ) {
          setSummary(result.summary ?? "Read the linked evidence.");
          setSource(result.source);
          setSummaryScope(
            `${productId}:${result.comparison?.id ?? comparison?.id}`,
          );
          setNotice("Analysis ready. No price or payment has been approved.");
          if (result.presentation) onPresentation(result.presentation);
          if (result.comparison) onComparison?.(result.comparison);
          return;
        }
        if (result.status === "failed" || result.status === "cancelled")
          throw Error(result.summary ?? "The analysis could not finish.");
        await new Promise<void>((resolve, reject) => {
          const stop = () => {
            clearTimeout(timer);
            reject(controller.signal.reason);
          };
          const timer = setTimeout(() => {
            controller.signal.removeEventListener("abort", stop);
            resolve();
          }, 1200);
          controller.signal.addEventListener("abort", stop, { once: true });
        });
      }
      setNotice(
        "The task is still pending. Inspect it in Agents; your manual comparison remains available.",
      );
    } catch (error) {
      if (!controller.signal.aborted && current.current === scope)
        setNotice(
          error instanceof Error
            ? error.message
            : "The analysis is unavailable. Use the structured comparison or inspect its task in Agents.",
        );
    } finally {
      if (current.current === scope) setBusy(false);
    }
  }
  return (
    <section
      className="ops-finance-panel ops-analyst"
      aria-label="Financial analyst conversation"
    >
      <h3>Ask about these costs</h3>
      <p>
        Challenge an assumption or ask which evidence supports the comparison.
      </p>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          void ask();
        }}
      >
        <label>
          Your question
          <textarea
            maxLength={3000}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="What if volume falls by ten percent?"
            disabled={busy}
          />
        </label>
        {dirty && (
          <p role="note">
            Save or cancel your comparison inputs before requesting another
            analysis.
          </p>
        )}
        <div className="ops-finance-select">
          <button className="ops-btn" disabled={busy || dirty || !text.trim()}>
            Ask the financial analyst
          </button>
          {busy && (
            <button
              className="ops-btn secondary"
              type="button"
              onClick={() => {
                turn.current?.abort();
                setBusy(false);
                setNotice(
                  "Stopped updating this view. The background task may still be running; inspect its actual state in Agents.",
                );
              }}
            >
              Stop updating this view
            </button>
          )}
        </div>
      </form>
      {notice && <p role="status">{notice}</p>}
      {summary && summaryScope === `${productId}:${comparison?.id}` && (
        <article aria-label="Financial explanation">
          <strong>
            {source === "deterministic-fallback"
              ? "Deterministic fallback explanation"
              : "AI explanation using recorded evidence"}
          </strong>
          <p>Based on the saved comparison and confirmed inputs.</p>
          <p style={{ whiteSpace: "pre-wrap" }}>{summary}</p>
        </article>
      )}
      <a href="?section=agents">Inspect analysis tasks</a>
    </section>
  );
}
