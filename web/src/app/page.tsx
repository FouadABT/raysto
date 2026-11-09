import type { Metadata } from "next";
import { redirect } from "next/navigation";
import { LandingPage } from "@/components/landing/landing-page";

// Keep the existing console-only host configuration a request-time decision.
export const dynamic = "force-dynamic";
export const metadata: Metadata = {
  title: "Raysto · Every order. Every table. One clear view.",
  description:
    "Bring restaurant operations, AI assistance and PayPal payments together in one clear workspace.",
};
export default function HomePage() {
  if (process.env.RAYSTO_OPS_ONLY === "true") redirect("/ops");
  return <LandingPage />;
}
