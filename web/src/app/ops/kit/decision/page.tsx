import { notFound } from "next/navigation";
import { DecisionKit } from "./decision-kit";
import "../../../md-sys.css";
import "../../operations.css";
import "@/components/connected/m3/m3.css";
import "../../design-workspace.css";

export default function DecisionKitPage() {
  if (process.env.NODE_ENV === "production") notFound();
  return <DecisionKit />;
}
