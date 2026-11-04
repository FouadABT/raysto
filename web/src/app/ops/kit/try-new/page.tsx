import { notFound } from "next/navigation";
import { TryNewPreview } from "./try-new-preview";
import "../../../md-sys.css";
import "../../operations.css";
import "@/components/connected/m3/m3.css";
import "../../m3-shell.css";
import "../../m3-board.css";
import "../../m3-money.css";

/**
 * Development only: Try cards 10–14 on a fixture API, for the browser tests
 * (tests/browser/try-new.spec.ts). `?state=missing` answers every new
 * command as a deployment that does not offer it yet.
 */
export default function TryNewPage() {
  if (process.env.NODE_ENV === "production") notFound();
  return <TryNewPreview />;
}
