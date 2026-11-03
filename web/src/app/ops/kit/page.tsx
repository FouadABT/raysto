import { readFile } from "node:fs/promises";
import path from "node:path";
import { notFound } from "next/navigation";
import { KitGallery, type DashboardFixture } from "./kit-gallery";
import "../../md-sys.css";
import "../operations.css";
import "@/components/connected/m3/m3.css";
import "./kit.css";

/** Development only: every m3 component on the frozen dashboard fixture. */
export default async function KitPage() {
  if (process.env.NODE_ENV === "production") notFound();
  const file = path.join(process.cwd(), "..", "docs", "fixtures", "dashboard-7d.json");
  const data = JSON.parse(await readFile(file, "utf8")) as DashboardFixture;
  return <KitGallery data={data} />;
}
