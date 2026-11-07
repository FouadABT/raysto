"use client";
import { useMemo, useState } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import { clearOverviewSnapshots } from "@/lib/connected/read-snapshots";
import { useOverviewRead } from "@/lib/connected/use-overview-read";

/** Authored race cases only; no network or connected identity. */
export function ReadScopePreview() {
  const [identity, setIdentity] = useState(1), [tenant, setTenant] = useState(1);
  const [revision, setRevision] = useState(0), [denied, setDenied] = useState(false);
  const api = useMemo(() => ({}) as ConnectedApi, [identity]);
  const read = useOverviewRead(api, tenant, "scope-fixture", String(revision), () =>
    new Promise<string>((resolve, reject) => {
      // Deliberately ignore abort: obsolete providers must still be discarded.
      setTimeout(() => denied ? reject(Object.assign(new Error("Permission revoked"), { code: "forbidden" }))
        : resolve(identity + ":" + tenant), revision > 0 && tenant === 1 ? 1500 : 300);
    }));
  return <main>
    <h1>Authored read-scope recovery</h1>
    <output aria-label="Retained result">{read.data ?? "Pending"}</output>
    {read.error && <p role="alert">{read.error}</p>}
    <button onClick={() => setRevision(n => n + 1)}>Queue obsolete read</button>
    <button onClick={() => setTenant(2)}>Switch venue</button>
    <button onClick={() => setIdentity(2)}>Switch identity</button>
    <button onClick={() => { setDenied(true); setRevision(n => n + 1); }}>Revoke access</button>
    <button onClick={() => clearOverviewSnapshots(api, true)}>End scope</button>
  </main>;
}
