"use client";
/**
 * Money › PayPal account (0.16, stream S6): which PayPal account this café's
 * money goes through, and how the owner connects their own.
 *
 * - Use my own PayPal app: the owner pastes the Client ID and Secret of
 *   their app from developer.paypal.com. PayPal must accept them before
 *   anything is kept; the secret is sealed on the server and never comes
 *   back, so this page never shows it. Raysto adds its webhook to the app
 *   and reads which features the app has.
 * - Connect with PayPal: ready, but PayPal has to approve Raysto as a
 *   partner first; until then the page says so instead of pretending.
 */
import { useEffect, useRef, useState, type FormEvent } from "react";
import type { ConnectedApi } from "@/lib/connected/api";
import {
  developerUrl,
  featureWord,
  keyProblems,
  maskedClient,
  missingFeatures,
  modeLabel,
  modeLine,
  returnedFromPayPal,
  stepUpNote,
  webhookWord,
  type PayPalAccountStatus,
} from "@/lib/connected/paypal-account";
import { useLoad } from "./business-sections";
import { StepUpAction } from "./backoffice-sections";
import { Icon } from "./icons";
import { Reveal } from "./m3";
import "./paypal-account.css";

const fail = (e: unknown) => String(e instanceof Error ? e.message : e);

export function PayPalAccountTab({ api, tenant, version }: { api: ConnectedApi; tenant: number; version: string }) {
  const [tick, setTick] = useState(0);
  const { data, error } = useLoad(
    () => api.query<PayPalAccountStatus>("merchant.status", { restaurantId: tenant }),
    [api, tenant, version, tick],
  );
  const reload = () => setTick((n) => n + 1);
  if (error) return <p className="ops-note" role="alert">{error}</p>;
  if (!data) return <p className="ops-note" role="status">Reading the PayPal account…</p>;
  return (
    <div className="ops-bo-stack ops-paypal-account">
      <Reveal as="section" className="ops-panel ops-bo-card" index={0}>
        <h2>
          <Icon name="paypal" size={20} /> {modeLabel[data.mode]}
          {data.environment === "sandbox" && <span className="ops-pill ok">Sandbox</span>}
        </h2>
        <p>{modeLine(data)}</p>
      </Reveal>
      {data.ownApp && <OwnApp api={api} tenant={tenant} status={data} onDone={reload} />}
      {data.canEdit && <OwnAppForm api={api} tenant={tenant} status={data} onDone={reload} />}
      <Partner api={api} tenant={tenant} status={data} onDone={reload} />
      {!data.canEdit && <p className="ops-quiet-note">Only the owner connects or changes the café&apos;s PayPal account.</p>}
    </div>
  );
}

function OwnApp({ api, tenant, status, onDone }: { api: ConnectedApi; tenant: number; status: PayPalAccountStatus; onDone: () => void }) {
  const own = status.ownApp!;
  const [busy, setBusy] = useState(false);
  const [note, setNote] = useState("");
  const missing = missingFeatures(status);
  async function recheck() {
    setBusy(true);
    setNote("");
    try {
      await api.command("merchant.app.check", tenant, {});
      setNote("Checked with PayPal just now.");
      onDone();
    } catch (e) {
      setNote(fail(e));
    } finally {
      setBusy(false);
    }
  }
  return (
    <Reveal as="section" className="ops-panel ops-bo-card" index={1}>
      <h2>Your PayPal app</h2>
      <dl className="ops-bo-facts">
        <div>
          <dt>Client ID</dt>
          <dd>
            <code>{maskedClient(own.clientIdEnd)}</code> (the secret stays sealed on the server)
          </dd>
        </div>
        <div>
          <dt>PayPal merchant ID</dt>
          <dd>{own.merchantId ? <code>{own.merchantId}</code> : "Learned from your first payment"}</dd>
        </div>
        <div>
          <dt>Webhook</dt>
          <dd>{webhookWord(own.webhook)}</dd>
        </div>
        <div>
          <dt>Last checked</dt>
          <dd>{own.checkedAt ? new Date(own.checkedAt).toLocaleString() : "Not yet"}</dd>
        </div>
      </dl>
      <ul className="ops-paypal-features" aria-label="What your PayPal app can do">
        {own.features.map((f) => (
          <li key={f.name} data-state={f.state}>
            <Icon name={f.state === "enabled" ? "check" : f.state === "notEnabled" ? "cross" : "alert"} size={18} />
            <span>{f.label}</span>
            <strong>{featureWord[f.state]}</strong>
          </li>
        ))}
      </ul>
      {missing.length > 0 && (
        <p className="ops-note">
          Switch on {missing.map((f) => f.label.split(" (")[0]).join(", ")} in your app&apos;s features on{" "}
          <a href={developerUrl} target="_blank" rel="noreferrer">
            developer.paypal.com
          </a>
          , then check again.
        </p>
      )}
      <div className="ops-bo-actions">
        <button className="ops-secondary" disabled={busy} onClick={() => void recheck()}>
          <Icon name="refresh" size={18} /> {busy ? "Checking…" : "Check again"}
        </button>
        {status.canEdit && (
          <StepUpAction
            api={api}
            tenant={tenant}
            label="Disconnect"
            onRun={async () => {
              await api.command("merchant.app.remove", tenant, {});
              onDone();
              return "Disconnected. The café no longer uses that PayPal app.";
            }}
          />
        )}
      </div>
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </Reveal>
  );
}

function OwnAppForm({ api, tenant, status, onDone }: { api: ConnectedApi; tenant: number; status: PayPalAccountStatus; onDone: () => void }) {
  const [clientId, setClientId] = useState("");
  const [secret, setSecret] = useState("");
  const [merchantId, setMerchantId] = useState("");
  const [shown, setShown] = useState("");
  const problems = keyProblems(clientId, secret, merchantId);
  const ready = problems.length === 0;
  if (!status.keysStorable) {
    return (
      <section className="ops-panel ops-bo-card" aria-label="Use my own PayPal app">
        <h2>Use my own PayPal app</h2>
        <p className="ops-quiet-note">
          This server cannot keep PayPal app keys yet (its sealing key is not set), so nothing can be saved here.
        </p>
      </section>
    );
  }
  function submit(e: FormEvent) {
    e.preventDefault();
  }
  return (
    <Reveal as="section" className="ops-panel ops-bo-card" index={2}>
      <h2>{status.ownApp ? "Replace the PayPal app" : "Use my own PayPal app"}</h2>
      <ol className="ops-paypal-steps">
        <li>
          Open{" "}
          <a href={developerUrl} target="_blank" rel="noreferrer">
            Apps &amp; Credentials
          </a>{" "}
          on developer.paypal.com (Sandbox) and pick or create your app.
        </li>
        <li>Copy its Client ID and Secret here. PayPal checks them before Raysto keeps anything.</li>
        <li>Raysto adds its webhook to the app and lists what the app can do.</li>
      </ol>
      <form className="ops-bo-form" onSubmit={submit} autoComplete="off">
        <label>
          Client ID
          <input value={clientId} onChange={(e) => setClientId(e.target.value)} spellCheck={false} autoComplete="off" required />
        </label>
        <label>
          Secret
          <input
            type="password"
            value={secret}
            onChange={(e) => setSecret(e.target.value)}
            spellCheck={false}
            autoComplete="new-password"
            required
          />
        </label>
        <label>
          PayPal merchant ID (optional)
          <input value={merchantId} onChange={(e) => setMerchantId(e.target.value)} spellCheck={false} autoComplete="off" />
        </label>
      </form>
      {(clientId || secret) && !ready && (
        <ul className="ops-quiet-note">
          {problems.map((p) => (
            <li key={p}>{p}</li>
          ))}
        </ul>
      )}
      <StepUpAction
        api={api}
        tenant={tenant}
        label="Save and check with PayPal"
        disabled={!ready}
        onRun={async () => {
          const result = await api.command<PayPalAccountStatus>("merchant.app.save", tenant, {
            clientId: clientId.trim(),
            clientSecret: secret.trim(),
            ...(merchantId.trim() ? { merchantId: merchantId.trim().toUpperCase() } : {}),
          });
          // The secret leaves the page's memory as soon as PayPal has seen it.
          setSecret("");
          setClientId("");
          setMerchantId("");
          setShown(`PayPal accepted the app ending ${result.ownApp?.clientIdEnd ?? ""}.`);
          onDone();
          return "PayPal accepted the keys. Payments now go through your app.";
        }}
      />
      <small className="ops-note">{stepUpNote(status)}</small>
      {shown && (
        <p className="ops-note" role="status">
          {shown}
        </p>
      )}
    </Reveal>
  );
}

function Partner({ api, tenant, status, onDone }: { api: ConnectedApi; tenant: number; status: PayPalAccountStatus; onDone: () => void }) {
  const p = status.partner;
  const [consent, setConsent] = useState(false);
  const [note, setNote] = useState("");
  const tried = useRef(false);
  // Back from PayPal's onboarding: check the connection once, quietly. If the
  // identity check has lapsed, the button below does it.
  useEffect(() => {
    if (tried.current || typeof window === "undefined" || !returnedFromPayPal(window.location.search)) return;
    tried.current = true;
    api
      .command("merchant.refresh", tenant, {})
      .then(() => {
        setNote("Back from PayPal: the connection was checked.");
        onDone();
      })
      .catch(() => setNote("Back from PayPal: confirm your identity, then check the connection."));
  }, [api, tenant, onDone]);
  const blocked = !p.available || p.status === "approvalRequired";
  return (
    <section className="ops-panel ops-bo-card" aria-label="Connect with PayPal">
      <h2>Connect with PayPal</h2>
      <p>
        {p.status === "ready"
          ? `Connected: PayPal merchant ${p.merchantId}.`
          : p.status === "revoked"
            ? "You withdrew Raysto's permission at PayPal. Connect again to use it."
            : p.status === "restricted"
              ? "PayPal has not finished checking the account yet."
              : p.status === "pending"
                ? "Started; finish the steps on PayPal's page."
                : "Sign in to PayPal and let Raysto take payments for this café."}
      </p>
      {p.note && (
        <p className="ops-note" role="note">
          <Icon name="alert" size={18} /> {p.note}
        </p>
      )}
      {status.canEdit && !blocked && p.status !== "ready" && (
        <>
          <label className="ops-bo-check">
            <input type="checkbox" checked={consent} onChange={(e) => setConsent(e.target.checked)} /> I agree to share this café&apos;s
            details with PayPal for onboarding.
          </label>
          <StepUpAction
            api={api}
            tenant={tenant}
            label="Connect with PayPal"
            disabled={!consent}
            onRun={async () => {
              const r = await api.command<{ onboardingUrl?: string }>("merchant.connect", tenant, { shareDataConsent: true });
              if (r.onboardingUrl) window.open(r.onboardingUrl, "_blank", "noopener");
              return r.onboardingUrl ? "PayPal's page opened in a new tab." : "PayPal returned no onboarding page.";
            }}
          />
        </>
      )}
      {status.canEdit && p.status !== "notConnected" && p.available && (
        <StepUpAction
          api={api}
          tenant={tenant}
          label="Check the connection"
          onRun={async () => {
            const r = await api.command<{ status: string }>("merchant.refresh", tenant, {});
            onDone();
            return `PayPal says: ${r.status}.`;
          }}
        />
      )}
      {note && (
        <p className="ops-note" role="status">
          {note}
        </p>
      )}
    </section>
  );
}
