export default function Loading() {
  return (
    <main className="loading-page" aria-busy="true">
      <div className="brand">
        raysto<span>✳</span>
      </div>
      <p>Opening your space…</p>
      <div className="skeleton" />
    </main>
  );
}
