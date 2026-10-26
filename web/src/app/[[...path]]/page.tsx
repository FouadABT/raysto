import { WebApp } from "@/components/web-app";
export default async function Page({
  params,
}: {
  params: Promise<{ path?: string[] }>;
}) {
  const { path = [] } = await params;
  return <WebApp path={path} />;
}
