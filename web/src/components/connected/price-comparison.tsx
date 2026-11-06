"use client";
import { WorkspaceStateContext } from "@/lib/connected/workspace-state";
import { useContext, useEffect, useRef, useState } from "react";
import { useScopedDraft } from "@/lib/connected/scoped-draft";
import { confirmDiscard } from "@/lib/connected/confirm-discard";
import { updateWorkspaceRoute } from "@/lib/connected/workspace-location";
import type { ConnectedApi } from "@/lib/connected/api";
import { currency, type Json } from "@/lib/connected/contracts";
import type {
  CostProduct,
  PriceComparison,
  PricingDecision,
  PricingPolicy,
} from "@/lib/connected/finance";

export function PriceComparisonPanel({
  api,
  tenant,
  product,
  policy,
  value,
  onChange,
  onPublished,
  onDirty,
  mode = "compare",
}: {
  api: ConnectedApi;
  tenant: number;
  product: CostProduct;
  policy?: PricingPolicy;
  value?: PriceComparison;
  onChange: (v: PriceComparison | undefined) => void;
  onPublished: () => void;
  onDirty: (v: boolean) => void;
  mode?: "compare" | "history";
}) {
  const role = useContext(WorkspaceStateContext)?.role;
  const canDecide = role === "owner" || role === "manager";
  const useDraft = <T,>(key: string, initial: T) =>
    useScopedDraft(
      api,
      `comparison:${tenant}:${product.productId}:${key}`,
      initial,
    );
  const [units, setUnits] = useDraft("units", ""),
    [volume, setVolume] = useDraft("volume", "-10"),
    [cap, setCap] = useDraft("cap", ""),
    [price, setPrice] = useDraft("price", "");
  const [draftRevision, setDraftRevision] = useDraft<number | undefined>(
    "revision",
    undefined,
  );
  const [dirty, setDirty] = useDraft("dirty", false);
  const [inputsDirty, setInputsDirty] = useDraft("inputs-dirty", false);
  const [reason, setReason] = useDraft("reason", "customer_sensitivity"),
    [note, setNote] = useDraft("note", "");
  const [busy, setBusy] = useState(false),
    [error, setError] = useState(""),
    [message, setMessage] = useState("");
  const [review, setReview] = useDraft<
    { actionId: number; version: number; preview: Json } | undefined
  >("review", undefined);
  const [decisions, setDecisions] = useState<PricingDecision[]>([]),
    [cursor, setCursor] = useState<number | null>(null);
  const [detail, setDetail] = useState<Json>();
  const [saved, setSaved] = useState<PriceComparison[]>([]),
    [savedCursor, setSavedCursor] = useState<number | null>(null);
  const resultsRef = useRef<HTMLDivElement>(null),
    reviewRef = useRef<HTMLElement>(null);
  useEffect(() => {
    const frame = requestAnimationFrame(() => {
      resultsRef.current?.focus({ preventScroll: true });
    });
    return () => cancelAnimationFrame(frame);
  }, [value?.id]);
  useEffect(() => {
    if (review) {
      reviewRef.current?.scrollIntoView({
        block: "nearest",
        behavior: "instant",
      });
      reviewRef.current?.focus({ preventScroll: true });
    }
  }, [review?.actionId]);
  const alive = useRef(true);
  const [requests] = useDraft("request-keys", new Map<string, string>());
  const [clock, setClock] = useState(Date.now());
  useEffect(() => {
    const timer = setInterval(() => setClock(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);
  useEffect(() => {
    alive.current = true;
    return () => {
      alive.current = false;
    };
  }, []);
  useEffect(() => {
    if (!value || draftRevision === value.id) return;
    setUnits(String(value.inputs.baselineUnits));
    setVolume(String(value.inputs.volumeChangeBps / 100));
    setCap(String(value.inputs.maxIncreaseBps / 100));
    setPrice(
      value.inputs.candidatePriceMinor == null
        ? ""
        : String(value.inputs.candidatePriceMinor / 100),
    );
    setReview(undefined);
    setDraftRevision(value.id);
    setDirty(false);
    setInputsDirty(false);
    onDirty(false);
  }, [value?.id]); // New server revision becomes the saved form basis.
  useEffect(() => {
    const discard = () => {
      setUnits(value ? String(value.inputs.baselineUnits) : "");
      setVolume(value ? String(value.inputs.volumeChangeBps / 100) : "-10");
      setCap(value ? String(value.inputs.maxIncreaseBps / 100) : "");
      setPrice(
        value?.inputs.candidatePriceMinor
          ? String(value.inputs.candidatePriceMinor / 100)
          : "",
      );
      setDraftRevision(value?.id);
      setReason("customer_sensitivity");
      setNote("");
      setDirty(false);
      setInputsDirty(false);
      onDirty(false);
    };
    window.addEventListener("raysto:discard-drafts", discard);
    return () => window.removeEventListener("raysto:discard-drafts", discard);
  }, [value?.id]);
  useEffect(() => {
    onDirty(dirty);
  }, [dirty]);
  useEffect(() => {
    if (value) updateWorkspaceRoute({ comparison: value.id }, true);
  }, [value?.id]);
  const fmt = (n: number) => currency(n, product.currency);
  async function command<T>(
    name: string,
    data: Json,
    options: { id?: number; version?: number } = {},
  ) {
    const signature = JSON.stringify([name, data, options]);
    if (!requests.has(signature)) requests.set(signature, crypto.randomUUID());
    const result = await api.command<T>(name, tenant, data, {
      ...options,
      key: requests.get(signature),
    });
    requests.delete(signature);
    return result;
  }
  async function load(after?: number) {
    const page = await api.query<{
      rows: PricingDecision[];
      nextCursor: number | null;
    }>("pricing.decisions", {
      restaurantId: tenant,
      ...(after ? { cursor: after } : {}),
    });
    if (alive.current) {
      setDecisions((old) => (after ? [...old, ...page.rows] : page.rows));
      setCursor(page.nextCursor);
    }
  }
  useEffect(() => {
    void load().catch((e) => {
      if (alive.current) setError(String(e));
    });
  }, []);
  async function loadSaved(after?: number) {
    const page = await api.query<{
      rows: PriceComparison[];
      nextCursor: number | null;
    }>("pricing.comparisons", {
      restaurantId: tenant,
      ...(after ? { cursor: after } : {}),
    });
    if (alive.current) {
      setSaved((old) => (after ? [...old, ...page.rows] : page.rows));
      setSavedCursor(page.nextCursor);
    }
  }
  useEffect(() => {
    void loadSaved().catch((e) => {
      if (alive.current) setError(String(e));
    });
  }, []);
  async function run(fn: () => Promise<void>) {
    if (busy) return;
    setBusy(true);
    setError("");
    setMessage("");
    try {
      await fn();
    } catch (e) {
      if (alive.current) setError(String(e));
    } finally {
      if (alive.current) setBusy(false);
    }
  }
  const field =
    (setter: (v: string) => void, assumption = true) =>
    (
      e: React.ChangeEvent<
        HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement
      >,
    ) => {
      setter(e.target.value);
      setDirty(true);
      if (assumption) setInputsDirty(true);
      onDirty(true);
    };
  const valid =
    !!value &&
    value.valid &&
    Date.parse(value.expiresAt) > clock &&
    !inputsDirty;
  return (
    <section
      className="ops-finance-panel"
      aria-label="Compare a pricing decision"
    >
      <h3>
        {mode === "history"
          ? "Your decision record"
          : "Compare a pricing decision"}
      </h3>
      <p>
        Keep the current price, inspect a change, or defer. Every option uses
        the same confirmed ingredient costs.
      </p>
      {!canDecide && (
        <p role="note">
          Analytical access: an owner or authorized manager must record pricing
          decisions and approve menu publication.
        </p>
      )}
      {!product.complete && (
        <p role="note" className="ops-note">
          Incomplete cost data. Confirm the missing inputs in Cost evidence
          before recommending a price.
        </p>
      )}
      {!policy?.confirmed && (
        <p role="note" className="ops-note">
          An owner must confirm the contribution target before a price can be
          recommended. Review Owner pricing policy in Choose a dish.
        </p>
      )}
      {mode === "compare" && (
        <>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              void run(async () => {
                const baseline = Number(units),
                  response = Number(volume),
                  limit =
                    cap === "" ? policy?.maxIncreaseBps : Number(cap) * 100;
                if (
                  !Number.isInteger(baseline) ||
                  baseline < 1 ||
                  !Number.isFinite(response) ||
                  !Number.isInteger(limit)
                )
                  throw Error("Enter baseline units and valid percentages.");
                const candidate = price === "" ? null : Number(price) * 100;
                if (
                  candidate != null &&
                  (!Number.isFinite(candidate) ||
                    Math.abs(candidate - Math.round(candidate)) > 0.00001)
                )
                  throw Error("Use a price with at most two decimal places.");
                const data = {
                  ...(value
                    ? { parentId: value.id }
                    : { productId: product.productId }),
                  baselineUnits: baseline,
                  volumeChangeBps: Math.round(response * 100),
                  maxIncreaseBps: limit,
                  candidatePriceMinor:
                    candidate == null ? null : Math.round(candidate),
                };
                const next = await command<PriceComparison>(
                  value
                    ? "pricing.comparison.revise"
                    : "pricing.comparison.create",
                  data,
                );
                if (alive.current) {
                  onChange(next);
                  setDirty(false);
                  setInputsDirty(false);
                  onDirty(false);
                  setMessage("Comparison saved. No menu change was made.");
                  await loadSaved();
                }
              });
            }}
          >
            <div className="ops-finance-select">
              <label>
                Assumed baseline units
                <input
                  type="number"
                  min="1"
                  step="1"
                  required
                  value={units}
                  onChange={field(setUnits)}
                />
              </label>
              <label>
                Assumed volume change (%)
                <input
                  type="number"
                  min="-100"
                  max="100"
                  step="0.01"
                  required
                  value={volume}
                  onChange={field(setVolume)}
                />
              </label>
              <label>
                Increase limit (%)
                <input
                  type="number"
                  min="0"
                  max={(policy?.maxIncreaseBps ?? 0) / 100}
                  step="0.01"
                  placeholder={String((policy?.maxIncreaseBps ?? 0) / 100)}
                  value={cap}
                  onChange={field(setCap)}
                />
              </label>
              <label>
                Price to inspect ({product.currency})
                <input
                  type="number"
                  min="0.01"
                  step="0.01"
                  value={price}
                  onChange={field(setPrice)}
                />
              </label>
            </div>
            <p>
              Volume is an owner assumption. No sales history or demand
              prediction is inferred from these inputs.
            </p>
            <button
              className="ops-btn"
              disabled={busy || !product.complete || !policy?.confirmed}
            >
              {value ? "Recalculate as a new revision" : "Compare options"}
            </button>
            <button
              type="button"
              className="ops-btn secondary"
              disabled={busy}
              onClick={async () => {
                if (
                  !(await confirmDiscard(
                    "Your unsaved comparison inputs will be discarded.",
                  ))
                )
                  return;
                setUnits(value ? String(value.inputs.baselineUnits) : "");
                setVolume(
                  value ? String(value.inputs.volumeChangeBps / 100) : "-10",
                );
                setCap(value ? String(value.inputs.maxIncreaseBps / 100) : "");
                setPrice(
                  value?.inputs.candidatePriceMinor
                    ? String(value.inputs.candidatePriceMinor / 100)
                    : "",
                );
                setDirty(false);
                setInputsDirty(false);
                onDirty(false);
              }}
            >
              Cancel input changes
            </button>
          </form>
        </>
      )}
      {error && <p role="alert">{error}</p>}
      {message && <p role="status">{message}</p>}
      <details>
        <summary>Resume a saved comparison</summary>
        {saved
          .filter((s) => s.productId === product.productId)
          .map((s) => (
            <p key={s.id}>
              <button
                className="ops-btn secondary"
                disabled={busy}
                onClick={async () => {
                  if (
                    dirty &&
                    !(await confirmDiscard(
                      "Open the saved revision and discard your unsaved inputs?",
                    ))
                  )
                    return;
                  void run(async () => {
                    const result = await api.query<PriceComparison>(
                      "pricing.comparison",
                      { restaurantId: tenant, id: s.id },
                    );
                    if (alive.current) onChange(result);
                  });
                }}
              >
                Revision {s.revision} · expires{" "}
                {new Date(s.expiresAt).toLocaleString()}
              </button>
            </p>
          ))}
        {savedCursor && (
          <button
            className="ops-btn secondary"
            disabled={busy}
            onClick={() => void run(() => loadSaved(savedCursor))}
          >
            Load earlier comparisons
          </button>
        )}
      </details>
      {mode === "compare" && value && (
        <>
          <p>
            {value.sample ? "Sample café · " : ""}Revision {value.revision} ·{" "}
            {value.baselineDefinition}
          </p>
          {!valid && (
            <p role="status">
              {inputsDirty
                ? "Inputs have changed. Recalculate to review these assumptions before recording a decision."
                : "Comparison is stale or expired. Recalculate before recording a decision or preparing publication."}
            </p>
          )}
          <div
            className="ops-price-options"
            ref={resultsRef}
            tabIndex={-1}
            role="region"
            aria-label={`Saved comparison revision ${value.revision} results`}
          >
            {value.options.map((o) => (
              <article
                className="ops-price-option"
                data-option={o.key}
                key={`${value.id}:${o.key}`}
              >
                <h4>
                  {o.key === "keep"
                    ? "Keep current price"
                    : o.key === "custom"
                      ? "Owner-entered price"
                      : "Lowest qualifying price"}
                </h4>
                <p className="ops-option-price">{fmt(o.priceMinor)}</p>
                <span className="ops-option-tag">
                  {o.targetMet ? "Target met" : "Below target"}
                </span>
                <dl>
                  <div>
                    <dt>Contribution per item*</dt>
                    <dd>{fmt(o.contributionMinor)}</dd>
                  </div>
                  <div>
                    <dt>Contribution rate</dt>
                    <dd>
                      {o.contributionBps == null
                        ? "Unknown"
                        : `${o.contributionBps / 100}%`}
                    </dd>
                  </div>
                  <div>
                    <dt>Break-even volume</dt>
                    <dd>
                      {o.breakEvenUnits ?? "Unavailable"}
                      {o.breakEvenUnits == null ? "" : " units"}
                    </dd>
                  </div>
                </dl>
                <small>
                  *Before shared overhead. Break-even is against keeping the
                  current price at the same confirmed cost.
                </small>
                <details>
                  <summary>Costs & volume assumptions</summary>
                  <p>
                    Net revenue {fmt(o.netPriceMinor)} · variable cost{" "}
                    {fmt(o.costMinor)} · estimated fee {fmt(o.feeMinor)}.
                  </p>
                  <ul>
                    {o.sensitivity.map((s) => (
                      <li key={s.volumeChangeBps}>
                        Scenario · {s.volumeChangeBps / 100}% assumed volume
                        response: {s.units} units,{" "}
                        {s.contributionMinor == null
                          ? "unknown"
                          : fmt(s.contributionMinor)}{" "}
                        contribution.
                      </li>
                    ))}
                  </ul>
                </details>
                {o.violations.length > 0 && (
                  <p>
                    Analysis limits:{" "}
                    {o.violations.map((v) => v.replaceAll("_", " ")).join(", ")}
                    .
                  </p>
                )}
                {o.publishable && (
                  <button
                    className="ops-btn"
                    disabled={busy || !valid || !!review || !canDecide}
                    onClick={() =>
                      void run(async () => {
                        const r = await command<{
                          actionId: number;
                          version: number;
                          preview: Json;
                        }>("pricing.propose", {
                          comparisonId: value.id,
                          option: o.key,
                        });
                        if (alive.current) {
                          setReview(r);
                          await load();
                        }
                      })
                    }
                  >
                    Prepare review for this price
                  </button>
                )}
              </article>
            ))}
          </div>
          <p>
            Keeping the price would require{" "}
            {fmt(value.keepPriceCostReductionMinor)} less variable cost per item
            to meet the target. This is a mathematical requirement; no supplier
            saving or recipe alternative has been verified.
          </p>
          {!value.keepPriceTargetFeasibleWithNonnegativeCost && (
            <p>
              The target cannot be reached even with zero included ingredient
              cost under these fee assumptions.
            </p>
          )}
          {value.assumptions.map((s) => (
            <p className="ops-note" key={s}>
              {s}
            </p>
          ))}
          {value.changes.length > 0 && (
            <details>
              <summary>What changed in this revision</summary>
              <ul>
                {value.changes.map((c, i) => (
                  <li key={i}>
                    {String(c.field)}: {String(c.from ?? "none")} →{" "}
                    {String(c.to ?? "none")}
                  </li>
                ))}
              </ul>
            </details>
          )}
          <label>
            Decision reason
            <select value={reason} onChange={field(setReason, false)}>
              {[
                "customer_sensitivity",
                "missing_evidence",
                "timing",
                "assumptions",
                "target_met",
                "other",
              ].map((r) => (
                <option key={r} value={r}>
                  {
                    {
                      customer_sensitivity: "Customer sensitivity",
                      missing_evidence: "More evidence needed",
                      timing: "The timing is not right",
                      assumptions: "I would use different assumptions",
                      target_met: "The current price meets my goal",
                      other: "Another reason",
                    }[r]
                  }
                </option>
              ))}
            </select>
          </label>
          <label>
            Optional decision note
            <textarea
              maxLength={1000}
              value={note}
              onChange={field(setNote, false)}
            />
          </label>
          <div className="ops-finance-select">
            {(["keep", "defer", "reject"] as const).map((choice) => (
              <button
                className="ops-btn secondary"
                key={choice}
                disabled={busy || !valid || !canDecide}
                onClick={() =>
                  void run(async () => {
                    await command("pricing.decision.record", {
                      comparisonId: value.id,
                      choice,
                      reason,
                      note,
                    });
                    if (alive.current) {
                      setNote("");
                      setDirty(false);
                      setInputsDirty(false);
                      onDirty(false);
                      setMessage("Decision recorded. The menu is unchanged.");
                      await load();
                    }
                  })
                }
              >
                {choice === "keep"
                  ? "Keep current price"
                  : choice === "defer"
                    ? "Defer decision"
                    : "Reject recommendation"}
              </button>
            ))}
          </div>
        </>
      )}
      {review && (
        <section
          ref={reviewRef}
          tabIndex={-1}
          aria-label="Review comparison price"
          className="ops-finance-review"
        >
          <h4>Review before publishing</h4>
          <p className="ops-eyebrow">PREPARED PROPOSAL · MENU UNCHANGED</p>
          {value && (
            <dl className="ops-review-inputs">
              <div>
                <dt>Comparison</dt>
                <dd>
                  Revision {value.revision} · {value.currency}
                </dd>
              </div>
              <div>
                <dt>Owner target</dt>
                <dd>
                  {value.policy.targetBps == null
                    ? "Not confirmed"
                    : `${value.policy.targetBps / 100}% contribution`}
                </dd>
              </div>
              <div>
                <dt>Increase limit</dt>
                <dd>{value.inputs.maxIncreaseBps / 100}%</dd>
              </div>
              <div>
                <dt>Expires</dt>
                <dd>{new Date(value.expiresAt).toLocaleString()}</dd>
              </div>
            </dl>
          )}
          <p>
            {String(review.preview.item)}:{" "}
            {fmt(Number(review.preview.fromMinor))} →{" "}
            {fmt(Number(review.preview.toMinor))}.
          </p>
          <p>
            Only new quotes use this price. Existing orders and checkouts keep
            their frozen amounts. Supplier payments need a separate approval.
          </p>
          <button
            className="ops-btn"
            disabled={busy || !valid || !canDecide}
            onClick={() =>
              void run(async () => {
                const r = await command<{ state: string }>(
                  "agent.decide",
                  { decision: "approve" },
                  { id: review.actionId, version: review.version },
                );
                if (r.state !== "executed")
                  throw Error(
                    `Publication state: ${r.state}. Inspect the action before retrying.`,
                  );
                if (alive.current) {
                  setReview(undefined);
                  onChange(undefined);
                  onDirty(false);
                  onPublished();
                  await load();
                  setMessage("Price published after approval.");
                }
              })
            }
          >
            Approve and publish price
          </button>
          <button
            className="ops-btn secondary"
            disabled={busy}
            onClick={() =>
              void run(async () => {
                await command(
                  "agent.decide",
                  { decision: "reject" },
                  { id: review.actionId, version: review.version },
                );
                if (alive.current) {
                  setReview(undefined);
                  await load();
                }
              })
            }
          >
            Reject proposal
          </button>
        </section>
      )}
      <details className="ops-decisions-history" open={mode === "history"}>
        <summary>Decisions to revisit</summary>
        {decisions.length === 0 && <p>No decisions recorded yet.</p>}
        {decisions.map((d) => (
          <p key={d.id}>
            <button
              className="ops-btn secondary"
              disabled={busy}
              onClick={() =>
                void run(async () => {
                  const result = await api.query<Json>(
                    "pricing.decision.outcome",
                    { restaurantId: tenant, id: d.id },
                  );
                  if (alive.current) setDetail(result);
                })
              }
            >
              {d.productName} · {d.choice} · {new Date(d.at).toLocaleString()}
            </button>
          </p>
        ))}
        {cursor && (
          <button
            className="ops-btn secondary"
            disabled={busy}
            onClick={() => void run(() => load(cursor))}
          >
            Load earlier decisions
          </button>
        )}
        {detail && (
          <DecisionOutcome value={detail} close={() => setDetail(undefined)} />
        )}
      </details>
    </section>
  );
}

export function DecisionOutcome({
  value,
  close,
}: {
  value: Json;
  close: () => void;
}) {
  const approval = value.approval as Json | undefined;
  const comparison = value.comparison as PriceComparison | undefined;
  const rows = (v: unknown) => (Array.isArray(v) ? (v as Json[]) : []);
  const money = (n: unknown) =>
    typeof n === "number" ? currency(n, String(value.currency)) : "Unknown";
  return (
    <section
      className="ops-finance-review"
      aria-label="Recorded decision outcome"
    >
      <h4>{String(value.productName)} · recorded decision</h4>
      <p>
        {String(value.choice)} · {String(value.reason).replaceAll("_", " ")} ·{" "}
        {String(value.note ?? "")}
      </p>
      <p>
        Approval: {String(approval?.status ?? "No price action requested")}.
        Observation: {String(value.observationStatus ?? "pending")}.
      </p>
      <ol
        className="ops-decision-timeline"
        aria-label="Decision evidence and execution"
      >
        <li>
          <span>01</span>
          <div>
            <strong>Comparison preserved</strong>
            <p>
              {comparison
                ? `Revision ${comparison.revision} · original costs and assumptions`
                : "Original comparison unavailable"}
            </p>
          </div>
        </li>
        <li>
          <span>02</span>
          <div>
            <strong>Owner decision recorded</strong>
            <p>
              {String(value.choice).replaceAll("_", " ")} ·{" "}
              {String(value.reason).replaceAll("_", " ")}
            </p>
          </div>
        </li>
        <li>
          <span>03</span>
          <div>
            <strong>Price action</strong>
            <p>{String(approval?.status ?? "No publication requested")}</p>
          </div>
        </li>
        <li>
          <span>04</span>
          <div>
            <strong>Recorded observations</strong>
            <p>
              {String(value.observationStatus ?? "Pending")} · inspect orders
              and provider outcomes below
            </p>
          </div>
        </li>
      </ol>
      {comparison && (
        <details>
          <summary>
            Original comparison and evidence · revision {comparison.revision}
          </summary>
          <p>
            {comparison.baselineDefinition} ·{" "}
            {comparison.sample ? "Sample records" : "Recorded venue data"} ·{" "}
            {comparison.inputs.baselineUnits} assumed baseline units.
          </p>
          {comparison.options.map((o) => (
            <p key={o.key}>
              Scenario · {o.key}: price {money(o.priceMinor)}, contribution{" "}
              {money(o.contributionMinor)}, break-even{" "}
              {o.breakEvenUnits ?? "unavailable"} units.
            </p>
          ))}
          {rows(comparison.evidence.lines).map((l, i) => (
            <p key={i}>
              {String(l.name ?? l.stockItemId)} ·{" "}
              {typeof l.quantityMicros === "number"
                ? l.quantityMicros / 1000000
                : "Unknown"}{" "}
              {String(l.unit ?? "unconfirmed unit")} · cost {money(l.costMinor)}{" "}
              · receipt{" "}
              {String((l.source as Json | undefined)?.id ?? "unknown")}
            </p>
          ))}
        </details>
      )}
      {(["before", "after"] as const).map((key) => {
        const p = value[key] as Json | undefined;
        return (
          p && (
            <article key={key}>
              <h5>
                {key === "before" ? "Before publication" : "After publication"}
              </h5>
              <p>
                {String(p.from ?? "Not scheduled")} →{" "}
                {String(p.to ?? "Not scheduled")} · {String(value.timezone)}
              </p>
              {key === "after" && (
                <p>
                  {String(p.elapsedCompleteDays ?? 0)} of 7 complete local days
                  available.
                </p>
              )}
              <p>
                {String(p.units)} units · {String(p.costedOrders)}/
                {String(p.orders)} orders costed. Recorded contribution:{" "}
                {money(p.contributionMinor)}.
              </p>
              <p>
                {String(p.newPriceUnits)} units at the reviewed version;{" "}
                {String(p.frozenEarlierPriceUnits)} at earlier versions;{" "}
                {String(p.laterRevisionUnits ?? 0)} at later versions;{" "}
                {String(p.unknownVersionUnits)} unknown.
              </p>
              {p.complete !== true && (
                <p>
                  Incomplete evidence. Known subtotals are not a complete
                  financial result.
                </p>
              )}
            </article>
          )
        );
      })}
      <h5>Order and collection records</h5>
      {rows(value.orders).map((o) => (
        <details key={String(o.orderId)}>
          <summary>
            Order #{String(o.orderId)} · {String(o.state)}
          </summary>
          <p>
            Accepted {String(o.acceptedAt)} · earned{" "}
            {String(o.earnedAt ?? "not recorded")} · recipe revisions{" "}
            {String(o.recipeVersions ?? "unknown")}.
          </p>
          <p>
            Historical contribution {money(o.contributionMinor)}.{" "}
            {o.refundAllocationUncertain
              ? "Refund allocation remains uncertain."
              : ""}
          </p>
          {rows(o.captures).map((c) => (
            <p key={String(c.id)}>
              PayPal capture {String(c.providerCaptureId ?? "pending")} ·{" "}
              {String(c.state)} · checkout collection {money(c.amountMinor)} ·
              refunded {money(c.refundedMinor)}.
            </p>
          ))}
        </details>
      ))}
      {value.ordersTruncated === true && (
        <p>
          Showing 100 of {String(value.matchedOrderCount)} matched orders.
          Period totals use the complete query.
        </p>
      )}
      <h5>Separately reviewed supplier settlements</h5>
      {rows(value.supplierPayments).map((b) => (
        <article key={String(b.billId)}>
          <p>
            Bill #{String(b.billId)} · {String(b.state)} ·{" "}
            {typeof b.amountMinor === "number"
              ? currency(b.amountMinor, String(b.currency ?? value.currency))
              : "Unknown"}{" "}
            · payout batch {String(b.batchState ?? "not submitted")}.
          </p>
          {rows(b.items).map((i) => (
            <p key={String(i.id)}>
              Recipient outcome {String(i.state)} ·{" "}
              {String(i.providerItemId ?? "no provider item reference")}.
            </p>
          ))}
        </article>
      ))}
      {Array.isArray(value.limitations) &&
        value.limitations.map((s, i) => <p key={i}>{String(s)}</p>)}
      <button className="ops-btn secondary" onClick={close}>
        Close decision
      </button>
    </section>
  );
}
