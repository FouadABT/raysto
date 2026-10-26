import { WebApp } from "@/components/web-app";
import { DemoProvider } from "@/lib/store";
import { redirect } from "next/navigation";
export default async function Page({
  params,
}: {
  params: Promise<{ path?: string[] }>;
}) {
  const { path = [] } = await params;
  if (process.env.RAYSTO_OPS_ONLY === 'true') redirect('/ops');
  return <DemoProvider><WebApp path={path} /></DemoProvider>;
}
