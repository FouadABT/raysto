export default function RouteLoading() {
  return (
    <main className="loading-page" aria-busy="true">
      <div className="loading-mark" aria-hidden="true">
        rays<span>to</span>
        <i>✳</i>
      </div>
      <p className="loading-line">
        AI prepares · you approve · PayPal moves the money
      </p>
      <div className="skeleton" />
      <span className="sr-only" role="status">
        Opening Raysto…
      </span>
    </main>
  );
}
