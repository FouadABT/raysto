"use client";
/**
 * The shared AG Studio wrapper for the console's analytics pages.
 *
 * - `StudioCanvas`: a multi-page Studio over one or more sources. Managers
 *   see it in view mode; owners may switch to edit mode (`editable`).
 * - `StudioWidget`: one widget (a pivot grid with totals, a grid, a chart)
 *   filling a view-mode Studio. This is how the console gets enterprise
 *   grid features under the Studio licence: AG Studio's grid widgets do not
 *   render outside a Studio (spike, 4 November), but a one-widget Studio
 *   does, with no watermark and no licence error.
 *
 * Both render a plain notice when Studio is switched off at build time
 * (`NEXT_PUBLIC_RAYSTO_STUDIO=off`) or has no licence key, so a page never
 * breaks.
 *
 * Added by stream S4 behind optional props, the signatures above unchanged:
 * - `layoutKey`: load this person's saved layout for a scope and section
 *   (`studio.layout`) and, for owners in edit mode, save changes a moment
 *   after they stop (`studio.layout.save`). The judges' café never saves.
 * - `page`: the page to show, switched in place.
 * - `ai`: the AI assistant panel (edit mode), with how Raysto's tools read.
 * - New rows reach the open Studio through its `data` prop: no remount, so
 *   a live refresh keeps the reader's page, filters and selection.
 */
import { useEffect, useMemo, useRef, useState, type CSSProperties } from "react";
import { AgStudio, AgStudioProvider } from "ag-studio-react";
import {
  AgStudioAiModule,
  AgStudioLicenseManager,
  studioTheme,
  type AgAiHarnessSetup,
  type AgBaseAiToolDisplay,
  type AgDefaultRegistry,
  type AgReportState,
  type AgStudioApi,
} from "ag-studio";
import type { ConnectedApi } from "../api";
import type { StudioSource } from "./sources";
import { isStudioState, mergeLayout } from "./layout";

export { isStudioState, mergeLayout };

export const studioOn = process.env.NEXT_PUBLIC_RAYSTO_STUDIO !== "off";
const license = process.env.NEXT_PUBLIC_AG_STUDIO_LICENSE;
if (license) AgStudioLicenseManager.setLicenseKey(license);

/** Raysto's look inside Studio: the console's tokens, its font, 12 px corners. */
export const studioRaystoTheme = studioTheme.withParams({
  accentColor: "#173f35",
  backgroundColor: "#ffffff",
  foregroundColor: "#173e34",
  fontFamily: "var(--font-jakarta)",
  borderRadius: 12,
});

export type StudioState = AgReportState<AgDefaultRegistry>;

/** A widget as Studio's state holds it: `type`, `format`, `dataMapping`. */
export type StudioWidgetSpec = Record<string, unknown> & { type: string };

/** Where a person's layout lives: `venue:{id}` or `group:{id}`, and a console section. */
export interface StudioLayoutKey {
  api: ConnectedApi;
  scope: string;
  section: "overview" | "group" | "accountant" | "supplies" | "dispatch" | "money" | "floor";
  /** Owners save; everyone else, and every judge, only loads. */
  save: boolean;
}

/** Studio's 24-column canvas: rows are 16 px. */
export const STUDIO_COLUMNS = 24;
export const STUDIO_ROW = 16;

const noPanels = { view: { left: [], right: [] }, edit: { left: [], right: [] } };

function StudioOff({ label, height }: { label: string; height: CSSProperties["height"] }) {
  return (
    <div className="ops-studio-off" role="note" style={{ minHeight: height }}>
      <strong>{label}</strong>
      <span>AG Studio is switched off on this deployment; the table below has the same figures.</span>
    </div>
  );
}

export function StudioCanvas(props: {
  /** Accessible name of the dashboard ("Accountant: profit and loss"). */
  label: string;
  sources: StudioSource[];
  initialState: StudioState;
  /** Owners may open the edit panels; everyone else sees view mode. */
  editable?: boolean;
  height?: CSSProperties["height"];
  className?: string;
  layoutKey?: StudioLayoutKey;
  page?: string;
  /** Tools read by their label only (no detail component), so one map serves any framework. */
  ai?: { harness: AgAiHarnessSetup; display?: Record<string, Omit<AgBaseAiToolDisplay, "detail">> };
  onApi?: (api: AgStudioApi) => void;
}) {
  if (!studioOn || !license) return <StudioOff label={props.label} height={props.height ?? 640} />;
  return <StudioOn {...props} />;
}

function StudioOn({
  label,
  sources,
  initialState,
  editable = false,
  height = 640,
  className,
  layoutKey,
  page,
  ai,
  onApi,
}: Parameters<typeof StudioCanvas>[0]) {
  // undefined: still loading the saved layout; null: none saved.
  const [saved, setSaved] = useState<StudioState | null | undefined>(layoutKey ? undefined : null);
  const [note, setNote] = useState("");
  const studio = useRef<AgStudioApi | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const lastSaved = useRef("");
  const loadedAt = useRef(0);
  const key = layoutKey;
  const scope = key?.scope;
  const section = key?.section;
  const keyApi = key?.api;

  useEffect(() => {
    if (!keyApi || !scope || !section) return;
    let live = true;
    setSaved(undefined);
    keyApi
      .query<{ state: unknown; version: number | null }>("studio.layout", { scope, section })
      .then((r) => {
        if (!live) return;
        if (isStudioState(r.state)) {
          lastSaved.current = JSON.stringify(r.state);
          setSaved(r.state);
        } else setSaved(null);
      })
      // No saved layout to read (a new person, an older backend): start from the default.
      .catch(() => live && setSaved(null));
    return () => {
      live = false;
    };
  }, [keyApi, scope, section]);

  useEffect(() => () => clearTimeout(timer.current), []);

  // Switch page in place: the open Studio keeps its data, filters and history.
  useEffect(() => {
    const api = studio.current;
    if (!api || !page) return;
    const state = api.getState();
    if (state.selectedPageId !== page && state.pages.some((p) => p.id === page))
      api.setState({ ...state, selectedPageId: page });
  }, [page]);

  const data = useMemo(() => ({ sources }), [sources]);
  const start = useMemo(
    () => (saved === undefined ? undefined : mergeLayout(saved, initialState, page)),
    // The starting state is read once, when Studio mounts.
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [saved === undefined],
  );
  const canSave = Boolean(editable && key?.save);

  const persist = (state: StudioState) => {
    if (!canSave || !key) return;
    // Studio reports its own opening state; only the person's changes are saved.
    if (Date.now() - loadedAt.current < 800) return;
    const json = JSON.stringify(state);
    if (json === lastSaved.current) return;
    clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      if (json.length > 120000) {
        setNote("This layout is too large to save.");
        return;
      }
      key.api
        // A group or venue layout belongs to the person, not to one restaurant's command lock.
        .command("studio.layout.save", undefined as unknown as number, { scope: key.scope, section: key.section, state })
        .then(() => {
          lastSaved.current = json;
          setNote("Layout saved for you.");
        })
        .catch((e: unknown) => setNote(`The layout was not saved: ${e instanceof Error ? e.message : String(e)}`));
    }, 1500);
  };

  if (!start)
    return (
      <section className={`ops-studio ops-studio-canvas${className ? ` ${className}` : ""}`} aria-label={label} style={{ height }}>
        <p className="ops-note" role="status">
          Opening {label.toLowerCase()}…
        </p>
      </section>
    );
  return (
    <>
      <section className={`ops-studio ops-studio-canvas${className ? ` ${className}` : ""}`} aria-label={label} style={{ height }}>
        <AgStudioProvider licenseKey={license}>
          <AgStudio
            mode={editable ? "edit" : "view"}
            theme={studioRaystoTheme}
            loadThemeGoogleFonts={false}
            panels={editable ? undefined : noPanels}
            modules={ai ? [AgStudioAiModule] : undefined}
            ai={ai?.harness}
            aiToolDisplay={ai?.display}
            initialState={start}
            data={data}
            onApiReady={(e) => {
              studio.current = e.api as unknown as AgStudioApi;
              loadedAt.current = Date.now();
              onApi?.(e.api as unknown as AgStudioApi);
            }}
            onStateUpdated={(e) => persist(e.state as unknown as StudioState)}
            onStudioPreDestroyed={() => {
              studio.current = null;
            }}
            style={{ height: "100%", width: "100%" }}
          />
        </AgStudioProvider>
      </section>
      {canSave && note && (
        <small className="ops-studio-note" role="status">
          {note}
        </small>
      )}
    </>
  );
}

/** One widget filling a view-mode Studio: the console's enterprise grid. */
export function StudioWidget({
  label,
  source,
  widget,
  height = 420,
  className,
}: {
  label: string;
  source: StudioSource;
  widget: StudioWidgetSpec;
  height?: CSSProperties["height"];
  className?: string;
}) {
  const rows = typeof height === "number" ? Math.max(8, Math.floor((height - 32) / STUDIO_ROW)) : 24;
  const state = useMemo(
    () =>
      ({
        pages: [
          {
            id: "only",
            widgets: { main: widget },
            widgetLayout: { main: { xTrack: 0, yTrack: 0, xSpan: STUDIO_COLUMNS, ySpan: rows } },
          },
        ],
        selectedPageId: "only",
      }) as unknown as StudioState,
    [widget, rows],
  );
  const sources = useMemo(() => [source], [source]);
  return <StudioCanvas label={label} sources={sources} initialState={state} height={height} className={className} />;
}
