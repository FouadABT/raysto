"use client";
import { useEffect, useRef, useState } from 'react';
import type { ConnectedApi } from '@/lib/connected/api';
import type { Json } from '@/lib/connected/contracts';

/** A guide into the real product. It never marks an unverified action paid. */
export function JudgeStory017({ api, tenant }: { api: ConnectedApi; tenant: number }) {
  const [story, setStory] = useState<Json>(), [error, setError] = useState(''), [busy, setBusy] = useState(false);
  const [step, setStep] = useState(0), [document, setDocument] = useState('');
  const sourceUrl = useRef(''), mounted = useRef(true), requestKey = useRef<string | undefined>(undefined);
  useEffect(() => {
    mounted.current = true; const controller = new AbortController();
    void api.query<Json>('judge.story', { restaurantId: tenant }, controller.signal).then(s => { if (!controller.signal.aborted) setStory(s); })
      .catch(e => { if (!controller.signal.aborted) setError(String(e)); });
    return () => { mounted.current = false; controller.abort(); if (sourceUrl.current) URL.revokeObjectURL(sourceUrl.current); };
  }, [api, tenant]);
  useEffect(() => {
    const run = story?.run as Json | null;
    if (!story?.active || !run?.runId) return;
    const timer = setInterval(() => {
      if (window.document.visibilityState !== 'visible') return;
      void api.command<Json>('judge.story.heartbeat', tenant, { runId: run.runId }).then(s => { if (mounted.current) setStory(s); })
        .catch(e => { if (mounted.current) setError(String(e)); });
    }, 240000);
    return () => clearInterval(timer);
  }, [api, tenant, story?.active, (story?.run as Json | null)?.runId]);
  const fixture = story?.fixture as Json | undefined;
  const steps = [
    ['Read the supplier document', 'Inspect the sample document. AI extraction is a draft; confirm its quantities, units and amount against the original.', 'supplies'],
    ['Confirm the purchasing cost', 'Review the delivery and invoice match in Bills and stock. A mismatch requires review before approval.', 'supplies'],
    ['Investigate affected dishes', 'Open Sales and margins. Use the Margin change widget to filter related records, then inspect the receipt evidence.', 'finance'],
    ['Compare a transparent scenario', 'Calculate the owner-target scenario. Compare unchanged volume, 10% fewer sales and 20% fewer sales. Ask the Studio assistant to create the scenario view.', 'finance'],
    ['Review the menu decision', 'Prepare and approve the price action only after reviewing its evidence. A saved scenario does not publish anything.', 'finance'],
    ['Complete a new customer checkout', 'Order the demonstrated dish through the café guest menu and approve PayPal Sandbox. Verify the recorded capture; a redirect alone is not payment evidence.', 'orders'],
    ['Approve supplier settlement separately', 'Open the linked bill. Review and approve its supported PayPal Payouts action, then inspect the recipient item outcome.', 'accountant'],
    ['Inspect the financial records', 'Compare recognized sales, costs, deposits and obligations on the same accounting basis. Recorded cash is not a verified bank balance.', 'finance'],
    ['Try an incomplete-cost example', 'Select the incomplete dish. Raysto must show the missing evidence and withhold a price recommendation.', 'finance'],
  ];
  const current = steps[step], run = story?.run as Json | undefined;
  const product = step === 8 ? fixture?.incompleteProductId : fixture?.productId;
  const destination = `/ops?section=${current[2]}${current[2] === 'finance' && product ? `&product=${product}` : ''}`;
  return <section className="ops-finance" aria-label="Guided café story">
    <header className="ops-finance-hero"><p className="ops-eyebrow">RAYSTO 0.17 · GUIDED REVIEW</p>
      <h2>A supplier cost changed. What should the café do?</h2>
      <p>Follow the evidence from purchasing to a reviewed price decision, a customer collection and a separately approved supplier payment.</p>
      <p>Illustrative café records · genuine provider results require actual PayPal Sandbox references.</p>
      <a className="ops-btn secondary" href="/ops?section=overview">Explore the workspace</a>
    </header>
    {error && <p role="alert" className="ops-error">{error}</p>}
    {!story?.active && <div className="ops-finance-panel">
      <p>{story?.busy ? 'Another reviewer is using the shared fixture. Independent exploration remains available.' : 'Start a protected review session. It preserves payment history and prevents a fixture reset during the active run.'}</p>
      <button className="ops-btn" disabled={busy || !!story?.busy || !story?.configured} onClick={() => {
        if (busy) return; setBusy(true); setError(''); requestKey.current ??= crypto.randomUUID();
        void api.command<Json>('judge.story.start', tenant, {}, { key: requestKey.current }).then(s => { if (mounted.current) setStory(s); })
          .catch(e => { if (mounted.current) setError(String(e)); }).finally(() => { if (mounted.current) setBusy(false); });
      }}>Follow the café story</button>
      {!story?.configured && <p>The owner’s fixture review is not complete. This deployment does not yet claim guided-story acceptance.</p>}
    </div>}
    {!!story?.active && <section className="ops-finance-panel">
      <p>Run {String(run?.runId)} · step {step + 1} of {steps.length}. Step navigation records your place, not proof of execution.</p>
      <h3>{current[0]}</h3><p>{current[1]}</p>
      {step === 0 && !!fixture?.mediaId && !document && <button className="ops-btn" onClick={() => {
        void api.file(Number(fixture.mediaId)).then(blob => { if (mounted.current) { sourceUrl.current = URL.createObjectURL(blob); setDocument(sourceUrl.current); } })
          .catch(e => { if (mounted.current) setError(String(e)); });
      }}>Load supplier document</button>}
      {document && step === 0 && <a className="ops-btn" href={document} target="_blank" rel="noopener noreferrer">Open supplier document</a>}
      <p><a className="ops-btn secondary" href={destination} target="_blank" rel="noopener noreferrer">Open this step in the workspace</a></p>
      <div className="ops-finance-select">
        <button className="ops-btn secondary" disabled={step === 0} onClick={() => setStep(n => n - 1)}>Previous step</button>
        <button className="ops-btn" disabled={step === steps.length - 1} onClick={() => setStep(n => n + 1)}>Next step</button>
      </div>
      <p>Review only the current run’s records. Existing checkouts retain their accepted amounts; repeat runs do not erase earlier provider evidence.</p>
    </section>}
  </section>;
}
