import type { Metadata } from "next";
import { JudgesPage } from "@/components/judges/judges-page";
import "./judges.css";

export const metadata: Metadata = {
  title: { absolute: "Raysto · The AI operating system for restaurants" },
  description:
    "AI coworkers prepare the work, you approve it, and PayPal moves the money. Bills paid, refunds settled and the team paid, in one system for restaurants and cafés.",
  robots: { index: true, follow: true },
};

export default function Page() {
  return <JudgesPage />;
}
