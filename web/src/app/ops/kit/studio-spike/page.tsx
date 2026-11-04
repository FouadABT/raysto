import { notFound } from "next/navigation";
import { StudioSpike } from "./studio-spike";

/**
 * Development only: can AG Studio's grid widgets live outside the full Studio
 * canvas under the Studio licence? (docs/release-0.16-design.md, AG Studio.)
 */
export default function StudioSpikePage() {
  if (process.env.NODE_ENV === "production") notFound();
  return <StudioSpike />;
}
