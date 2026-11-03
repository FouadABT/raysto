import type { Metadata } from "next";
import { JudgesPage } from "@/components/judges/judges-page";
import "./judges.css";

export const metadata: Metadata = {
  title: { absolute: "Raysto · For hackathon judges" },
  description:
    "Raysto: AI coworkers run the café's money, people approve, PayPal moves it. Try nine live demos in three minutes, nothing to install.",
  robots: { index: true, follow: true },
};

export default function Page() {
  return <JudgesPage />;
}
