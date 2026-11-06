import type { Metadata } from "next";
import { JudgesPage } from "@/components/judges/judges-page";
import "./judges.css";

export const metadata: Metadata = {
  title: { absolute: "Raysto · The AI operating system for restaurants" },
  description:
    "Connect café costs, recipes and payments. Investigate the evidence, challenge pricing assumptions and inspect recorded outcomes.",
  robots: { index: true, follow: true },
};

export default function Page() {
  return <JudgesPage />;
}
