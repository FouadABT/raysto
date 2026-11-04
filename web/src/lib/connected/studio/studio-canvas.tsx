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
 * breaks. Saved layouts (`studio.layout.save`) and the AI tools are stream
 * S4's to add behind these same props.
 */
import { useMemo, type CSSProperties } from "react";
import { AgStudio, AgStudioProvider } from "ag-studio-react";
import { AgStudioLicenseManager, studioTheme, type AgDefaultRegistry, type AgReportState } from "ag-studio";
import type { StudioSource } from "./sources";

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

const noPanels = { view: { left: [], right: [] }, edit: { left: [], right: [] } };

function StudioOff({ label, height }: { label: string; height: CSSProperties["height"] }) {
  return (
    <div className="ops-studio-off" role="note" style={{ minHeight: height }}>
      <strong>{label}</strong>
      <span>AG Studio is switched off on this deployment; the table below has the same figures.</span>
    </div>
  );
}

export function StudioCanvas({
  label,
  sources,
  initialState,
  editable = false,
  height = 640,
  className,
}: {
  /** Accessible name of the dashboard ("Accountant: profit and loss"). */
  label: string;
  sources: StudioSource[];
  initialState: StudioState;
  /** Owners may open the edit panels; everyone else sees view mode. */
  editable?: boolean;
  height?: CSSProperties["height"];
  className?: string;
}) {
  if (!studioOn || !license) return <StudioOff label={label} height={height} />;
  return (
    <section className={`ops-studio-canvas${className ? ` ${className}` : ""}`} aria-label={label} style={{ height }}>
      <AgStudioProvider licenseKey={license}>
        <AgStudio
          mode={editable ? "edit" : "view"}
          theme={studioRaystoTheme}
          loadThemeGoogleFonts={false}
          panels={editable ? undefined : noPanels}
          initialState={initialState}
          data={{ sources }}
          style={{ height: "100%", width: "100%" }}
        />
      </AgStudioProvider>
    </section>
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
  const state = useMemo(
    () =>
      ({
        pages: [
          {
            id: "only",
            widgets: { main: widget },
            widgetLayout: { main: { xTrack: 0, yTrack: 0, xSpan: 16, ySpan: 12 } },
          },
        ],
        selectedPageId: "only",
      }) as unknown as StudioState,
    [widget],
  );
  return <StudioCanvas label={label} sources={[source]} initialState={state} height={height} className={className} />;
}
