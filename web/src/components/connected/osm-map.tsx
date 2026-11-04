"use client";
/**
 * The console's map: OpenStreetMap tiles through Leaflet, loaded only in the
 * browser (Leaflet touches `window` when it is imported). The tile URL is a
 * build setting, `NEXT_PUBLIC_TILE_URL`, so a deployment can move to its own
 * tile server; the default is OpenStreetMap's, whose usage policy asks for
 * the attribution, a real referrer and no bulk or prefetched downloads.
 * Owner: stream S2.
 */
import dynamic from "next/dynamic";
import type { MapPin, MapRoute } from "@/lib/connected/dispatch";

export const tileUrl = process.env.NEXT_PUBLIC_TILE_URL || "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
export const attribution = '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noreferrer">OpenStreetMap</a> contributors';

export interface OsmMapProps {
  /** The map's accessible name ("Deliveries on the map"). */
  label: string;
  pins: MapPin[];
  routes?: MapRoute[];
  center: [number, number];
  zoom?: number;
  height?: number;
  onPinClick?: (pin: MapPin) => void;
  /** Changes when the set of places changes; the view fits them again then. */
  fitKey?: string;
}

function Placeholder({ height = 380 }: { height?: number }) {
  return (
    <div className="ops-map ops-map-loading" style={{ height }} role="status">
      Loading the map…
    </div>
  );
}

export const OsmMap = dynamic<OsmMapProps>(() => import("./osm-map-view").then((m) => m.OsmMapView), {
  ssr: false,
  loading: () => <Placeholder />,
});
