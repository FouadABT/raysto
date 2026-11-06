import { readFile } from "node:fs/promises";
import path from "node:path";
import { notFound } from "next/navigation";
import type { Dashboard } from "@/lib/connected/dashboard";
import { PreviewConsole } from "./preview-console";
import "../../md-sys.css";
import "../operations.css";
import "@/components/connected/m3/m3.css";
import "../m3-shell.css";
import "../m3-board.css";
import "../m3-money.css";
import "../design-workspace.css";

/** Development only: the signed-in console on the frozen dashboard fixtures. */
export default async function PreviewPage() {
  if (process.env.NODE_ENV === "production") notFound();
  const read = async (name: string) =>
    JSON.parse(
      await readFile(
        path.join(process.cwd(), "..", "docs", "fixtures", name),
        "utf8",
      ),
    ) as Dashboard;
  const [week, today] = await Promise.all([
    read("dashboard-7d.json"),
    read("dashboard-today.json"),
  ]);
  return <PreviewConsole week={week} today={today} />;
}
