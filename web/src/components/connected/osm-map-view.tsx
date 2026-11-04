"use client";
/**
 * The Leaflet half of `osm-map.tsx`, imported only in the browser. Pins are
 * plain HTML (no image files), each with its words in a tooltip and an
 * accessible name; a list under the map carries the same places for screen
 * readers and keyboards. Reduced motion turns off every map animation.
 * Owner: stream S2.
 */
import { useEffect, useMemo, useRef } from "react";
import L from "leaflet";
import { MapContainer, Marker, Polyline, TileLayer, Tooltip, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import { useReduce } from "@/lib/connected/motion";
import type { MapPin } from "@/lib/connected/dispatch";
import { attribution, tileUrl, type OsmMapProps } from "./osm-map";

const glyph: Record<MapPin["kind"], string> = {
  venue: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3.5v6a2.5 2.5 0 0 0 5 0v-6M8.5 3.5v17M17.5 20.5V3.5c-2.2 1.5-3 4-3 7h3"/></svg>',
  job: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 10.5 12 4l8 6.5V20H4z"/><path d="M10 20v-5h4v5"/></svg>',
  driver: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="6.5" cy="17" r="2.5"/><circle cx="17.5" cy="17" r="2.5"/><path d="M9 17h6M13 6.5h3l2.5 8M11 10h4l-2 7"/></svg>',
};

function icon(pin: MapPin) {
  return L.divIcon({
    className: "",
    html: `<span class="ops-map-pin ${pin.kind} ${pin.tone}${pin.selected ? " selected" : ""}">${glyph[pin.kind]}</span>`,
    iconSize: [34, 34],
    iconAnchor: [17, 30],
    tooltipAnchor: [0, -26],
  });
}

/** Fits the places once, and again only when the set of places changes. */
function Fit({ points, fitKey, animate }: { points: [number, number][]; fitKey: string; animate: boolean }) {
  const map = useMap();
  const last = useRef("");
  useEffect(() => {
    if (last.current === fitKey || points.length === 0) return;
    last.current = fitKey;
    if (points.length === 1) map.setView(points[0], Math.max(map.getZoom(), 15), { animate });
    else map.fitBounds(L.latLngBounds(points), { padding: [36, 36], maxZoom: 16, animate });
  }, [map, points, fitKey, animate]);
  return null;
}

export function OsmMapView({ label, pins, routes = [], center, zoom = 14, height = 380, onPinClick, fitKey }: OsmMapProps) {
  const reduce = useReduce();
  const points = useMemo(() => pins.map((p) => [p.latitude, p.longitude] as [number, number]), [pins]);
  const key = fitKey ?? pins.map((p) => p.id).sort().join(",");
  return (
    <figure className="ops-map" aria-label={label} style={{ height }}>
      <MapContainer
        center={center}
        zoom={zoom}
        className="ops-map-canvas"
        scrollWheelZoom={false}
        zoomAnimation={!reduce}
        fadeAnimation={!reduce}
        markerZoomAnimation={!reduce}
        inertia={!reduce}
        attributionControl
      >
        {/* No prefetching beyond the view: Leaflet keeps no extra rows of tiles. */}
        <TileLayer url={tileUrl} attribution={attribution} keepBuffer={0} updateWhenIdle maxZoom={19} crossOrigin="" referrerPolicy="strict-origin-when-cross-origin" />
        {routes.map((r) => (
          <Polyline key={r.id} positions={r.points} pathOptions={{ className: `ops-map-route ${r.tone}`, weight: 4, dashArray: r.tone === "plan" ? "8 8" : undefined }} />
        ))}
        {pins.map((p) => (
          <Marker
            key={p.id}
            position={[p.latitude, p.longitude]}
            icon={icon(p)}
            title={p.label}
            alt={p.label}
            keyboard
            zIndexOffset={p.kind === "venue" ? 1000 : p.selected ? 800 : p.kind === "driver" ? 600 : 0}
            eventHandlers={onPinClick ? { click: () => onPinClick(p) } : undefined}
          >
            <Tooltip direction="top">{p.label}</Tooltip>
          </Marker>
        ))}
        <Fit points={points} fitKey={key} animate={!reduce} />
      </MapContainer>
      <figcaption className="ops-sr-only">
        {label}: {pins.length === 0 ? "no places to show." : pins.map((p) => p.label).join("; ")}
      </figcaption>
    </figure>
  );
}
