"use client";
import { submittedFormAcknowledgement } from "./workspace-drafts";
import { useWorkspaceTab } from "@/lib/connected/workspace-location";
/**
 * Dispatch: the café's deliveries on an OpenStreetMap board, its drivers as
 * drop zones, the AI dispatcher's ranking, partner apps with their keys and
 * the log of every partner call, and a labelled simulator.
 *
 * - Dropping a job on a driver offers it for 90 seconds. Like the order
 *   board's moves, the offer waits a few seconds for Undo before it is sent,
 *   so Undo never has to take back something the driver already saw.
 * - "Suggest a driver" asks the server to rank the free drivers (distance and
 *   jobs on hand; straight lines × 1.3, so every time is an estimate) and, when
 *   the AI dispatcher is switched on, to propose one offer for approval.
 * - Partner keys are shown once and need an identity check, like refunds.
 *
 * Owner: stream S2 (docs/release-0.16-design.md).
 */
import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
  type DragEvent,
  type FormEvent,
  type ReactNode,
} from "react";
import type { ColDef } from "ag-grid-community";
import type { ConnectedApi } from "@/lib/connected/api";
import type { AgentActionRow } from "@/lib/connected/business";
import { currency, type Json } from "@/lib/connected/contracts";
import {
  canOffer,
  clock,
  dispatch,
  distanceText,
  etaText,
  eventText,
  failText,
  jobLabel,
  jobTone,
  keyNotice,
  mapCenter,
  mapPins,
  mapRoutes,
  secondsLeft,
  takesJobs,
  toneWords,
  vehicleWords,
  type BoardRow,
  type DispatchApi,
  type DriverRow,
  type PartnerAppRow,
  type PartnerEventRow,
  type Revealed,
  type Suggestion,
} from "@/lib/connected/dispatch";
import {
  countCol,
  dateCol,
  idCol,
  moneyCol,
  statusCol,
  words,
} from "@/lib/connected/grid-columns";
import { isJudgeVenue, judge } from "@/lib/connected/judge";
import { approvalNotice } from "@/lib/connected/money-view";
import { GRACE_MS, MotionRoot } from "@/lib/connected/motion";
import { stepUp, usesPassword } from "@/lib/connected/step-up";
import { AgentPanel, useLoad } from "./business-sections";
import type { SectionProps } from "./group-section";
import { Icon } from "./icons";
import { CountUp, Reveal, SnackbarProvider, useSnackbar } from "./m3";
import { OsmMap } from "./osm-map";
import { PartnerSim } from "./partner-sim";
import { RaystoGrid } from "./raysto-grid";
import "./dispatch-section.css";

type Tab = "board" | "partners" | "simulator";
const tabs: [Tab, string][] = [
  ["board", "Board"],
  ["partners", "Partner apps"],
  ["simulator", "Simulator"],
];

type Notice = ReturnType<typeof useSnackbar>;
function useNotice(): Notice | null {
  try {
    return useSnackbar();
  } catch {
    return null;
  }
}

function KitRoot({ children }: { children: ReactNode }) {
  const notice = useNotice();
  const inner = <MotionRoot>{children}</MotionRoot>;
  return notice ? inner : <SnackbarProvider>{inner}</SnackbarProvider>;
}

/** Reloads every `ms` while the page is visible, and when it becomes visible again. */
function usePoll(ms: number): number {
  const [tick, setTick] = useState(0);
  useEffect(() => {
    const bump = () =>
      document.visibilityState === "visible" && setTick((n) => n + 1);
    const timer = setInterval(bump, ms);
    document.addEventListener("visibilitychange", bump);
    return () => {
      clearInterval(timer);
      document.removeEventListener("visibilitychange", bump);
    };
  }, [ms]);
  return tick;
}

/** The clock for offer countdowns: ticks each second only while one is open. */
function useNow(active: boolean): number {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!active) return;
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, [active]);
  return now;
}

export function DispatchSection({
  api,
  tenant,
  revision,
  currencyCode,
}: SectionProps) {
  const [tab, setTab] = useWorkspaceTab<Tab>(
    "dispatch",
    ["board", "partners", "simulator"],
    "board",
  );
  const dx = useMemo(() => dispatch(api, tenant), [api, tenant]);
  return (
    <KitRoot>
      <div className="ops-business ops-dispatch">
        <div
          className="ops-chips ops-bo-tabs"
          role="tablist"
          aria-label="Dispatch"
        >
          {tabs.map(([t, label]) => (
            <button
              key={t}
              role="tab"
              tabIndex={tab === t ? 0 : -1}
              aria-selected={tab === t}
              aria-pressed={tab === t}
              onClick={() => setTab(t)}
            >
              {label}
            </button>
          ))}
        </div>
        {tab === "board" ? (
          <BoardTab
            api={api}
            dx={dx}
            tenant={tenant}
            revision={revision}
            currencyCode={currencyCode}
          />
        ) : tab === "partners" ? (
          <PartnersTab
            api={api}
            dx={dx}
            tenant={tenant}
            revision={revision}
            currencyCode={currencyCode}
          />
        ) : (
          <PartnerSim tenant={tenant} />
        )}
      </div>
    </KitRoot>
  );
}

/* ---------- The board ---------- */

type Pending = { driverId: number; driverName: string; key: string };

function BoardTab({
  api,
  dx,
  tenant,
  revision,
  currencyCode,
}: {
  api: ConnectedApi;
  dx: DispatchApi;
  tenant: number;
  revision: string;
  currencyCode: string;
}) {
  const notice = useNotice();
  const poll = usePoll(10000);
  const [tick, setTick] = useState(0);
  const refresh = useCallback(() => setTick((n) => n + 1), []);
  const deps = [dx, revision, tick, poll];
  const { data: board, error } = useLoad(() => dx.board(), deps);
  const { data: drivers } = useLoad(() => dx.drivers(), deps);
  const { data: inbox } = useLoad(() => dx.inbox(), deps);
  const [selected, setSelected] = useState<number>();
  const [pending, setPending] = useState<Record<number, Pending>>({});
  const pendingRef = useRef(pending);
  pendingRef.current = pending;
  const [sent, setSent] = useState(0);
  const [over, setOver] = useState<number>();
  const [suggestions, setSuggestions] = useState<Record<number, Suggestion>>(
    {},
  );
  const [busy, setBusy] = useState<string>();
  const [note, setNote] = useState("");
  const rows = board?.rows;
  const anyOffer = (rows ?? []).some((r) => r.offer);
  const now = useNow(anyOffer);
  const code = rows?.[0]?.currency ?? currencyCode;

  const say = useCallback(
    (message: string) => {
      if (notice) notice.show({ message });
      else setNote(message);
    },
    [notice],
  );

  /** Sends one pending offer, once: Undo removed it, a second call finds nothing. */
  const send = useCallback(
    async (jobId: number) => {
      const p = pendingRef.current[jobId];
      if (!p) return;
      const { [jobId]: _gone, ...rest } = pendingRef.current;
      pendingRef.current = rest;
      setPending(rest);
      setSent((n) => n + 1);
      try {
        await dx.offer(jobId, p.driverId, p.key);
        say(`Offered to ${p.driverName}: 90 seconds to accept.`);
      } catch (e) {
        say(failText(e));
      } finally {
        refresh();
      }
    },
    [dx, refresh, say],
  );

  // Leaving the board sends what is waiting, as the order board does.
  useEffect(
    () => () => {
      for (const id of Object.keys(pendingRef.current)) void send(Number(id));
    },
    [send],
  );

  const offer = useCallback(
    (job: BoardRow, driver: Pick<DriverRow, "id" | "name">) => {
      const next = {
        ...pendingRef.current,
        [job.id]: {
          driverId: driver.id,
          driverName: driver.name,
          key: crypto.randomUUID(),
        },
      };
      pendingRef.current = next;
      setPending(next);
      if (!notice) {
        void send(job.id);
        return;
      }
      notice.show({
        message: `Offering ${jobLabel(job)} to ${driver.name}`,
        durationMs: GRACE_MS,
        action: {
          label: "Undo",
          onPress: () => {
            const { [job.id]: _undone, ...rest } = pendingRef.current;
            pendingRef.current = rest;
            setPending(rest);
          },
        },
        onDismiss: (reason) => {
          if (reason !== "action") void send(job.id);
        },
      });
    },
    [notice, send],
  );

  async function act(label: string, run: () => Promise<string | void>) {
    const acknowledge = submittedFormAcknowledgement();
    setBusy(label);
    setNote("");
    try {
      const said = await run();
      acknowledge();
      if (said) say(said);
      refresh();
    } catch (e) {
      say(failText(e));
    } finally {
      setBusy(undefined);
    }
  }

  const waiting = (rows ?? []).filter(canOffer);
  const moving = (rows ?? []).filter((r) =>
    ["assigned", "collected", "outForDelivery"].includes(r.status),
  );
  const done = (rows ?? []).filter((r) => r.status === "delivered");
  const free = (drivers ?? []).filter(
    (d) => d.kind === "staff" && d.active && d.status === "available",
  );
  const proposals = ((inbox ?? []) as unknown as AgentActionRow[]).filter(
    (a) => a.command === "delivery.offer",
  );
  const pins = useMemo(
    () => mapPins(board, drivers, selected),
    [board, drivers, selected],
  );
  const routes = useMemo(() => mapRoutes(board, selected), [board, selected]);
  const byId = useMemo(
    () => new Map((drivers ?? []).map((d) => [d.id, d])),
    [drivers],
  );

  const drop = (e: DragEvent, driver: DriverRow) => {
    e.preventDefault();
    setOver(undefined);
    const id = Number(
      e.dataTransfer.getData("text/x-raysto-job") ||
        e.dataTransfer.getData("text/plain"),
    );
    const job = (rows ?? []).find((r) => r.id === id);
    if (job && canOffer(job) && takesJobs(driver)) offer(job, driver);
  };

  const columns = useMemo<ColDef<BoardRow>[]>(
    () => [
      {
        headerName: "Job",
        valueGetter: (p) => (p.data ? jobLabel(p.data) : ""),
        minWidth: 90,
        cellClass: "ops-cell-strong",
      },
      statusCol<BoardRow>("State", (r) => jobTone(r.status), {
        label: toneWords,
        minWidth: 150,
      }),
      {
        headerName: "Kitchen",
        valueGetter: (p) => words(p.data?.orderStatus),
        minWidth: 120,
      },
      {
        headerName: "Where",
        valueGetter: (p) =>
          p.data?.address?.line ?? p.data?.address?.city ?? "",
        minWidth: 170,
      },
      {
        headerName: "Driver",
        valueGetter: (p) =>
          p.data?.driver?.name ??
          (p.data?.fulfilledBy === "partner" ? "Partner's courier" : ""),
        minWidth: 140,
      },
      {
        headerName: "ETA",
        valueGetter: (p) => p.data?.eta?.minutes ?? null,
        valueFormatter: (p) => (p.data?.eta ? etaText(p.data.eta) : ""),
        minWidth: 170,
      },
      {
        headerName: "Distance",
        valueGetter: (p) => p.data?.eta?.distanceMeters ?? null,
        valueFormatter: (p) => distanceText(p.value),
        type: "rightAligned",
        cellClass: "ops-num",
        minWidth: 110,
      },
      moneyCol<BoardRow>("Fee", "feeMinor", (r) => r.currency),
      {
        headerName: "Partner",
        valueGetter: (p) =>
          p.data?.partner
            ? `${p.data.partner.name}${p.data.partner.simulator ? " (simulator)" : ""}`
            : "",
        minWidth: 160,
      },
      dateCol<BoardRow>("Placed", "createdAt"),
    ],
    [],
  );

  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <div className="ops-kpis compact">
        <div className={`ops-kpi ${waiting.length > 0 ? "alert" : ""}`}>
          <span>Need a driver</span>
          <strong>
            {board ? (
              <CountUp value={waiting.length} format={String} />
            ) : (
              <span aria-label="Loading delivery measure">—</span>
            )}
          </strong>
        </div>
        <div className="ops-kpi">
          <span>On the way</span>
          <strong>
            {board ? (
              <CountUp value={moving.length} format={String} />
            ) : (
              <span aria-label="Loading delivery measure">—</span>
            )}
          </strong>
        </div>
        <div className="ops-kpi">
          <span>Delivered, last 3 h</span>
          <strong>
            {board ? (
              <CountUp value={done.length} format={String} />
            ) : (
              <span aria-label="Loading delivery measure">—</span>
            )}
          </strong>
        </div>
        <div className="ops-kpi">
          <span>Drivers free</span>
          <strong>
            {board ? (
              <CountUp value={free.length} format={String} />
            ) : (
              <span aria-label="Loading delivery measure">—</span>
            )}
          </strong>
        </div>
      </div>
      {board && (
        <ul className="ops-dsp-facts" aria-label="How this café delivers">
          <li>
            Proof at the door:{" "}
            {board.proofMode === "code"
              ? "the customer's code"
              : board.proofMode === "photo"
                ? "a photo"
                : "none"}
          </li>
          <li>
            Fees: {board.feeMode === "distance" ? "base + per km" : "flat"}
          </li>
          <li>AI dispatcher: {board.aiDispatcher ? "on" : "off"}</li>
          <li>Automatic offers: {board.dispatchAuto ? "on" : "off"}</li>
        </ul>
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
      {proposals.length > 0 && (
        <div className="ops-bo-proposals">
          {proposals.map((a, i) => (
            <Reveal
              key={`${a.id}-${a.version}`}
              index={i}
              as="section"
              className="ops-panel ops-bo-card"
            >
              <AgentPanel
                api={api}
                tenant={tenant}
                action={a}
                inline
                knownPassword={isJudgeVenue(tenant) ? judge.password : ""}
                onDone={(state, result) => {
                  say(approvalNotice(state, result));
                  refresh();
                }}
              />
            </Reveal>
          ))}
        </div>
      )}
      <div className="ops-dsp-layout" data-offers-sent={sent}>
        <section
          className="ops-panel ops-dsp-map"
          aria-labelledby="dsp-map-title"
        >
          <h2 id="dsp-map-title">Deliveries on the map</h2>
          <OsmMap
            label="Deliveries on the map"
            pins={pins}
            routes={routes}
            center={mapCenter(board)}
            height={420}
            onPinClick={(p) =>
              p.kind === "job" && setSelected(Number(p.id.slice(4)))
            }
          />
          <p className="ops-note">
            Pins are the café, each customer&apos;s door and each driver&apos;s
            last shared position. Lines are straight; times are estimates.
          </p>
        </section>
        <section
          className="ops-panel ops-dsp-drivers"
          aria-labelledby="dsp-drivers-title"
        >
          <div className="ops-dsp-head">
            <h2 id="dsp-drivers-title">Drivers</h2>
            <DriverForm dx={dx} onSaved={refresh} />
          </div>
          <p className="ops-note">
            Drag a waiting job onto a driver to offer it for 90 seconds.
          </p>
          {drivers &&
            drivers.filter((d) => d.kind === "staff").length === 0 && (
              <p className="ops-note">
                No drivers yet. Couriers appear when they go available in the
                Raysto app; add drivers you call by phone here.
              </p>
            )}
          <ul className="ops-dsp-driver-list">
            {(drivers ?? [])
              .filter((d) => d.kind === "staff")
              .map((d) => {
                const open = (rows ?? []).find(
                  (r) => r.offer?.driverId === d.id,
                );
                const queued = Object.entries(pending).find(
                  ([, p]) => p.driverId === d.id,
                );
                return (
                  <li
                    key={d.id}
                    className={`ops-dsp-driver ${d.status}${over === d.id ? " over" : ""}${takesJobs(d) ? " takes" : ""}`}
                    aria-label={`${d.name}, ${words(d.status)}`}
                    onDragOver={(e) => {
                      if (!takesJobs(d)) return;
                      e.preventDefault();
                      e.dataTransfer.dropEffect = "move";
                      setOver(d.id);
                    }}
                    onDragLeave={() =>
                      setOver((x) => (x === d.id ? undefined : x))
                    }
                    onDrop={(e) => drop(e, d)}
                  >
                    <div className="ops-dsp-driver-top">
                      <span className="ops-dsp-avatar" aria-hidden="true">
                        {d.name.slice(0, 1).toUpperCase()}
                      </span>
                      <div>
                        <strong>{d.name}</strong>
                        <small>
                          {vehicleWords[d.vehicle] ?? d.vehicle} ·{" "}
                          {d.activeJobs} on hand · {d.deliveredToday} delivered
                          today
                          {d.hasLogin ? "" : " · by phone"}
                        </small>
                      </div>
                      <span
                        className={`ops-pill ${d.status === "available" ? "ok" : d.status === "busy" ? "ready" : "off"}`}
                      >
                        {words(d.status)}
                      </span>
                    </div>
                    {queued && (
                      <p className="ops-dsp-line">
                        Offering{" "}
                        {jobLabel(
                          (rows ?? []).find(
                            (r) => r.id === Number(queued[0]),
                          ) ?? { number: null, orderId: Number(queued[0]) },
                        )}
                        …
                      </p>
                    )}
                    {open?.offer && (
                      <div className="ops-dsp-line">
                        <span>
                          Offered {jobLabel(open)} ·{" "}
                          <span className="ops-num">
                            {clock(secondsLeft(open.offer.expiresAt, now))}
                          </span>{" "}
                          left
                        </span>
                        {!d.hasLogin && (
                          <span className="ops-dsp-answer">
                            <button
                              className="ops-secondary"
                              disabled={!!busy}
                              onClick={() =>
                                void act(
                                  "answer",
                                  async () => (
                                    await dx.answerFor(
                                      open.offer!.offerId,
                                      "accept",
                                    ),
                                    `${d.name} accepted ${jobLabel(open)}.`
                                  ),
                                )
                              }
                            >
                              They accepted
                            </button>
                            <button
                              className="ops-secondary"
                              disabled={!!busy}
                              onClick={() =>
                                void act(
                                  "answer",
                                  async () => (
                                    await dx.answerFor(
                                      open.offer!.offerId,
                                      "decline",
                                    ),
                                    `${d.name} declined.`
                                  ),
                                )
                              }
                            >
                              They declined
                            </button>
                          </span>
                        )}
                      </div>
                    )}
                    <button
                      className="ops-secondary ops-dsp-toggle"
                      disabled={!!busy || !d.active}
                      onClick={() =>
                        void act("availability", async () => {
                          await dx.availability(
                            d.id,
                            d.status === "offline" ? "available" : "offline",
                          );
                          return d.status === "offline"
                            ? `${d.name} is taking jobs.`
                            : `${d.name} is offline.`;
                        })
                      }
                    >
                      {d.status === "offline" ? "Set available" : "Set offline"}
                    </button>
                  </li>
                );
              })}
          </ul>
        </section>
      </div>
      <section className="ops-panel" aria-labelledby="dsp-queue-title">
        <h2 id="dsp-queue-title">Waiting for a driver</h2>
        {board && waiting.length === 0 && (
          <p className="ops-note">
            Every delivery has a driver. New ones appear here as the kitchen
            accepts them.
          </p>
        )}
        <ul className="ops-dsp-queue">
          {waiting.map((job, i) => {
            const queued = pending[job.id];
            const suggestion = suggestions[job.id];
            return (
              <Reveal
                key={job.id}
                index={i}
                as="li"
                className={`ops-dsp-job${selected === job.id ? " selected" : ""}`}
                visitKey="dispatch-queue"
              >
                <div
                  className="ops-dsp-job-card"
                  draggable={!queued}
                  aria-roledescription="draggable job"
                  onDragStart={(e) => {
                    e.dataTransfer.setData("text/x-raysto-job", String(job.id));
                    e.dataTransfer.setData("text/plain", String(job.id));
                    e.dataTransfer.effectAllowed = "move";
                    setSelected(job.id);
                  }}
                  onClick={() => setSelected(job.id)}
                >
                  <div className="ops-dsp-job-top">
                    <strong>{jobLabel(job)}</strong>
                    <span
                      className={`ops-pill ${job.ready ? "ready" : "cook"}`}
                    >
                      {job.ready ? "Ready" : words(job.orderStatus)}
                    </span>
                    {job.partner && (
                      <span className="ops-pill neutral">
                        {job.partner.name}
                        {job.partner.simulator &&
                        !/simulator/i.test(job.partner.name)
                          ? " (simulator)"
                          : ""}
                      </span>
                    )}
                  </div>
                  <p>
                    {job.address?.line ?? "No address"}
                    {job.address?.city ? `, ${job.address.city}` : ""}
                  </p>
                  <small>
                    {etaText(job.eta)}
                    {job.eta?.distanceMeters
                      ? ` · ${distanceText(job.eta.distanceMeters)}`
                      : ""}{" "}
                    · fee {currency(job.feeMinor, job.currency || code)}
                  </small>
                  {queued && (
                    <p className="ops-dsp-line">
                      Offering to {queued.driverName}… (Undo in the message
                      below)
                    </p>
                  )}
                  {job.offer && (
                    <p className="ops-dsp-line">
                      Offered to{" "}
                      {job.offer.driverName ??
                        byId.get(job.offer.driverId)?.name ??
                        "a driver"}
                      {job.offer.by === "agent" ? " by the AI dispatcher" : ""}{" "}
                      ·{" "}
                      <span className="ops-num">
                        {clock(secondsLeft(job.offer.expiresAt, now))}
                      </span>{" "}
                      left
                    </p>
                  )}
                </div>
                <div className="ops-dsp-job-actions">
                  <button
                    className="ops-secondary"
                    disabled={!!busy || !!queued}
                    onClick={() =>
                      void act(`suggest-${job.id}`, async () => {
                        const s = await dx.suggest(job.id);
                        setSuggestions((x) => ({ ...x, [job.id]: s }));
                        return s.ai === "queued"
                          ? "The AI dispatcher is choosing a driver; its proposal appears above for your approval."
                          : undefined;
                      })
                    }
                  >
                    <Icon name="agents" size={18} />
                    Suggest a driver
                  </button>
                  <label className="ops-dsp-pick">
                    <span className="sr-only">Offer {jobLabel(job)} to</span>
                    <select
                      value=""
                      disabled={!!queued}
                      onChange={(e) => {
                        const d = byId.get(Number(e.target.value));
                        if (d) offer(job, d);
                      }}
                    >
                      <option value="">Offer to…</option>
                      {(drivers ?? []).filter(takesJobs).map((d) => (
                        <option key={d.id} value={d.id}>
                          {d.name}
                        </option>
                      ))}
                    </select>
                  </label>
                  {job.offer && (
                    <button
                      className="ops-secondary"
                      disabled={!!busy}
                      onClick={() =>
                        void act(
                          "withdraw",
                          async () => (
                            await dx.withdraw(job.offer!.offerId),
                            "Offer withdrawn."
                          ),
                        )
                      }
                    >
                      Withdraw
                    </button>
                  )}
                </div>
                {suggestion && (
                  <div
                    className="ops-dsp-suggestion"
                    role="region"
                    aria-label={`Suggested drivers for ${jobLabel(job)}`}
                  >
                    <p className="ops-note">
                      {suggestion.ai === "queued"
                        ? "The AI dispatcher is reviewing this ranking. "
                        : "AI dispatcher off: this is Raysto's own ranking. "}
                      {suggestion.basis}
                    </p>
                    {suggestion.ranking.length === 0 ? (
                      <p className="ops-note">No driver is free right now.</p>
                    ) : (
                      <ol>
                        {suggestion.ranking.slice(0, 3).map((r) => (
                          <li key={r.driverId}>
                            <div>
                              <strong>{r.name}</strong> · score {r.score} ·
                              about {r.minutes} min
                              <small>{r.reasons.join(" · ")}</small>
                            </div>
                            <button
                              className="ops-secondary"
                              disabled={!!queued}
                              onClick={() =>
                                offer(job, { id: r.driverId, name: r.name })
                              }
                            >
                              Offer
                            </button>
                          </li>
                        ))}
                      </ol>
                    )}
                  </div>
                )}
              </Reveal>
            );
          })}
        </ul>
      </section>
      <RaystoGrid<BoardRow>
        label="Delivery jobs"
        rows={rows}
        columns={columns}
        loading={!board && !error}
        emptyText="No deliveries in the last three hours."
        getRowId={(p) => String(p.data.id)}
        onRowClicked={(e) => e.data && setSelected(e.data.id)}
        csvName="raysto-deliveries"
      />
    </>
  );
}

function DriverForm({ dx, onSaved }: { dx: DispatchApi; onSaved: () => void }) {
  const notice = useNotice();
  const [open, setOpen] = useState(false);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const data: Json = {
      name: String(f.get("name") ?? "").trim(),
      vehicle: String(f.get("vehicle") ?? "bike"),
    };
    const phone = String(f.get("phoneLast4") ?? "").trim();
    const email = String(f.get("payoutEmail") ?? "").trim();
    if (phone) data.phoneLast4 = phone;
    if (email) data.payoutEmail = email;
    setBusy(true);
    setError("");
    try {
      await dx.saveDriver(data);
      notice?.show({
        message: `${data.name} added. Set them available to offer jobs.`,
      });
      setOpen(false);
      onSaved();
    } catch (err) {
      setError(failText(err));
    } finally {
      setBusy(false);
    }
  }
  if (!open)
    return (
      <button className="ops-secondary" onClick={() => setOpen(true)}>
        <Icon name="plus" size={18} />
        Add a driver
      </button>
    );
  return (
    <form
      className="ops-bo-form ops-dsp-form"
      onSubmit={(e) => void submit(e)}
      aria-label="Add a driver"
    >
      <label>
        Name
        <input name="name" required maxLength={80} autoComplete="off" />
      </label>
      <label>
        Vehicle
        <select name="vehicle" defaultValue="bike">
          {Object.entries(vehicleWords).map(([v, label]) => (
            <option key={v} value={v}>
              {label}
            </option>
          ))}
        </select>
      </label>
      <label>
        Phone, last 4 digits
        <input
          name="phoneLast4"
          inputMode="numeric"
          pattern="\d{4}"
          maxLength={4}
          autoComplete="off"
        />
      </label>
      <label>
        PayPal email for pay
        <input
          name="payoutEmail"
          type="email"
          maxLength={254}
          autoComplete="off"
        />
      </label>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <button className="ops-primary" disabled={busy}>
        Save the driver
      </button>
      <button
        type="button"
        className="ops-secondary"
        onClick={() => setOpen(false)}
      >
        Cancel
      </button>
    </form>
  );
}

/* ---------- Partner apps ---------- */

function PartnersTab({
  api,
  dx,
  tenant,
  revision,
}: {
  api: ConnectedApi;
  dx: DispatchApi;
  tenant: number;
  revision: string;
  currencyCode: string;
}) {
  const notice = useNotice();
  const poll = usePoll(15000);
  const [tick, setTick] = useState(0);
  const deps = [dx, revision, tick, poll];
  const { data: apps, error } = useLoad(() => dx.apps(), deps);
  const { data: events } = useLoad(() => dx.events(), deps);
  const [revealed, setRevealed] = useState<Revealed>();
  const [retry, setRetry] = useState<{
    label: string;
    run: () => Promise<void>;
  }>();
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const refresh = () => setTick((n) => n + 1);

  async function run(label: string, fn: () => Promise<void>) {
    setBusy(true);
    setNote("");
    try {
      await fn();
      setRetry(undefined);
      refresh();
    } catch (e) {
      if ((e as { code?: string }).code === "reauthentication_required")
        setRetry({ label, run: fn });
      else setNote(failText(e));
    } finally {
      setBusy(false);
    }
  }

  const reveal = (app: Pick<PartnerAppRow, "id" | "name">, result: Json) =>
    setRevealed({
      id: app.id,
      name: app.name,
      key: result.key as string | undefined,
      webhookSecret: result.webhookSecret as string | undefined,
    });

  async function create(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    const f = new FormData(form);
    const name = String(f.get("name") ?? "").trim();
    const webhookUrl = String(f.get("webhookUrl") ?? "").trim();
    const data: Json = { name, simulator: f.get("simulator") === "on" };
    if (webhookUrl) data.webhookUrl = webhookUrl;
    await run("Create the app", async () => {
      const result = await dx.createApp(data);
      if (result.shown) reveal({ id: result.id as number, name }, result);
      form.reset();
    });
  }

  const columns = useMemo<ColDef<PartnerEventRow>[]>(
    () => [
      dateCol<PartnerEventRow>("When", "createdAt"),
      {
        headerName: "Way",
        valueGetter: (p) =>
          p.data?.direction === "in"
            ? "From the partner"
            : "Webhook to the partner",
        minWidth: 180,
      },
      {
        field: "type",
        headerName: "Event",
        minWidth: 150,
        cellClass: "ops-cell-strong",
      },
      idCol<PartnerEventRow>("Ref", "ref"),
      statusCol<PartnerEventRow>("Status", "status"),
      countCol<PartnerEventRow>("HTTP", "responseCode", {
        total: false,
        format: String,
      }),
      countCol<PartnerEventRow>("Tries", "attempts", { total: false }),
      {
        headerName: "App",
        valueGetter: (p) =>
          p.data
            ? `${p.data.appName ?? ""}${p.data.simulator ? " (simulator)" : ""}`
            : "",
        minWidth: 170,
      },
    ],
    [],
  );

  return (
    <>
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <section
        className="ops-panel ops-dsp-api"
        aria-labelledby="dsp-api-title"
      >
        <h2 id="dsp-api-title">The Delivery Partner API</h2>
        <p>
          An outside delivery app can read the menu, send orders, follow them
          and cancel them at <code>https://api.rays.to/api/partner/v1</code>.
          Its orders are settled outside PayPal: the café&apos;s accountant asks
          the partner to pay what it owes.
        </p>
        <ul>
          <li>
            <code>Authorization: Bearer rk_…</code> with the app&apos;s key.
          </li>
          <li>
            <code>X-Raysto-Signature: t=…,v1=…</code>: the hex HMAC-SHA256 of{" "}
            <code>t.body</code> with the webhook secret, within 5 minutes.
          </li>
          <li>
            <code>Idempotency-Key</code> on every POST; 64 KB and 60 requests a
            minute at most.
          </li>
          <li>
            Signed webhooks: order.accepted, order.ready, order.picked_up,
            order.delivered, driver.location, retried after 1 min, 5 min, 30
            min, 2 h and 6 h.
          </li>
        </ul>
        {apps && !apps.configured && (
          <p className="ops-note">
            Partner apps are not configured on this server yet.
          </p>
        )}
      </section>
      {note && (
        <p className="ops-error" role="alert">
          {note}
        </p>
      )}
      {retry && (
        <StepUpPrompt
          api={api}
          tenant={tenant}
          label={retry.label}
          onConfirmed={() => void run(retry.label, retry.run)}
          onCancel={() => setRetry(undefined)}
        />
      )}
      {revealed && (
        <section
          className="ops-panel ops-dsp-reveal"
          role="alert"
          aria-labelledby="dsp-reveal-title"
        >
          <h2 id="dsp-reveal-title">{revealed.name}: copy these now</h2>
          <p>{keyNotice}</p>
          {revealed.key && <Secret label="API key" value={revealed.key} />}
          {revealed.webhookSecret && (
            <Secret label="Webhook secret" value={revealed.webhookSecret} />
          )}
          <button
            className="ops-primary"
            onClick={() => setRevealed(undefined)}
          >
            I&apos;ve copied them
          </button>
        </section>
      )}
      <div className="ops-dsp-apps">
        {(apps?.rows ?? []).map((app, i) => (
          <Reveal
            key={app.id}
            index={i}
            as="section"
            className="ops-panel ops-bo-card ops-dsp-app"
            visitKey="dispatch-apps"
          >
            <div className="ops-dsp-head">
              <h3>{app.name}</h3>
              <span className={`ops-pill ${app.active ? "ok" : "off"}`}>
                {app.active ? "On" : "Off"}
              </span>
              {app.simulator && (
                <span className="ops-pill warn">Simulator</span>
              )}
            </div>
            <dl className="ops-dsp-dl">
              <dt>Key</dt>
              <dd>
                <code>{app.keyHint}</code>
              </dd>
              <dt>Webhook</dt>
              <dd>{app.webhookUrl ?? "None: events are logged, not sent"}</dd>
              <dt>Owed this month</dt>
              <dd>
                {app.owedThisMonth && app.owedThisMonth.orders > 0
                  ? `${currency(app.owedThisMonth.totalMinor, app.owedThisMonth.currency ?? "USD")} for ${app.owedThisMonth.orders} delivered order${app.owedThisMonth.orders === 1 ? "" : "s"}`
                  : "Nothing yet"}
              </dd>
              <dt>Last 24 h</dt>
              <dd>
                {app.events24h ?? 0} calls
                {app.failing
                  ? ` · ${app.failing} webhook${app.failing === 1 ? "" : "s"} failing`
                  : ""}
              </dd>
            </dl>
            <div className="ops-dsp-job-actions">
              <button
                className="ops-secondary"
                disabled={busy}
                onClick={() =>
                  void run("Rotate the key", async () =>
                    reveal(app, await dx.rotateApp(app.id, app.version, "key")),
                  )
                }
              >
                Rotate the key
              </button>
              <button
                className="ops-secondary"
                disabled={busy}
                onClick={() =>
                  void run("Rotate the secret", async () =>
                    reveal(
                      app,
                      await dx.rotateApp(app.id, app.version, "secret"),
                    ),
                  )
                }
              >
                Rotate the secret
              </button>
              <button
                className="ops-secondary"
                disabled={busy}
                onClick={() =>
                  void run(
                    app.active ? "Switch it off" : "Switch it on",
                    async () => {
                      await dx.updateApp(app.id, app.version, {
                        active: !app.active,
                      });
                      notice?.show({
                        message: app.active
                          ? `${app.name} is switched off.`
                          : `${app.name} is switched on.`,
                      });
                    },
                  )
                }
              >
                {app.active ? "Switch off" : "Switch on"}
              </button>
            </div>
          </Reveal>
        ))}
        <form
          className="ops-panel ops-bo-form ops-dsp-form"
          onSubmit={(e) => void create(e)}
          aria-label="Add a partner app"
        >
          <span className="ops-eyebrow">New partner app</span>
          <label className="wide">
            Name
            <input
              name="name"
              required
              maxLength={80}
              autoComplete="off"
              placeholder="Demo Delivery Co."
            />
          </label>
          <label className="wide">
            Webhook URL (https)
            <input
              name="webhookUrl"
              type="url"
              maxLength={500}
              placeholder="https://partner.example.com/raysto"
              autoComplete="off"
            />
          </label>
          <label className="ops-dsp-check">
            <input type="checkbox" name="simulator" />
            This is a simulator, not a real delivery company
          </label>
          <button className="ops-primary" disabled={busy}>
            <Icon name="plus" size={18} />
            Create the app and show its key
          </button>
        </form>
      </div>
      <RaystoGrid<PartnerEventRow>
        label="Partner calls and webhooks"
        rows={events}
        columns={columns}
        loading={!events && !error}
        emptyText="No partner calls yet."
        getRowId={(p) => String(p.data.id)}
        csvName="raysto-partner-events"
        totals={false}
      />
      {events && events.length > 0 && (
        <ol className="sr-only" aria-label="Partner calls in words">
          {events.slice(0, 10).map((e) => (
            <li key={e.id}>{eventText(e)}</li>
          ))}
        </ol>
      )}
    </>
  );
}

function Secret({ label, value }: { label: string; value: string }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="ops-dsp-secret">
      <span>{label}</span>
      <code>{value}</code>
      <button
        className="ops-secondary"
        onClick={() =>
          void navigator.clipboard?.writeText(value).then(
            () => setCopied(true),
            () => undefined,
          )
        }
      >
        <Icon name={copied ? "check" : "copy"} size={18} />
        {copied ? "Copied" : `Copy the ${label.toLowerCase()}`}
      </button>
    </div>
  );
}

function StepUpPrompt({
  api,
  tenant,
  label,
  onConfirmed,
  onCancel,
}: {
  api: ConnectedApi;
  tenant: number;
  label: string;
  onConfirmed: () => void;
  onCancel: () => void;
}) {
  const [password, setPassword] = useState(
    isJudgeVenue(tenant) ? judge.password : "",
  );
  const [byPassword, setByPassword] = useState(true);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  useEffect(() => {
    void usesPassword().then(setByPassword, () => setByPassword(true));
  }, []);
  async function confirm(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await stepUp(api, tenant, byPassword ? password : undefined);
      onConfirmed();
    } catch (err) {
      setError(failText(err));
    } finally {
      setBusy(false);
    }
  }
  return (
    <form
      className="ops-panel ops-bo-stepup"
      onSubmit={(e) => void confirm(e)}
      aria-label="Confirm it's you"
    >
      <p>
        Partner keys open your café to another app, so Raysto asks you to
        confirm it&apos;s you first ({label.toLowerCase()}).
      </p>
      {byPassword && (
        <label>
          Your password
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="current-password"
            required
          />
        </label>
      )}
      {error && (
        <p className="ops-error" role="alert">
          {error}
        </p>
      )}
      <button className="ops-primary" disabled={busy}>
        {byPassword
          ? "Confirm and continue"
          : "Confirm with Google and continue"}
      </button>
      <button type="button" className="ops-secondary" onClick={onCancel}>
        Cancel
      </button>
    </form>
  );
}
