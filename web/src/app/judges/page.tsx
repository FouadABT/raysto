import type { Metadata } from "next";
import { JudgesPage } from "@/components/judges/judges-page";
import "./judges.css";

export const metadata: Metadata = {
  title: { absolute: "Raysto · For hackathon judges" },
  description:
    "Raysto: AI coworkers prepare, people approve, PayPal moves the money. Try five live demos in two minutes, nothing to install.",
  robots: { index: true, follow: true },
};

export default function Page() {
  return <JudgesPage />;
}
