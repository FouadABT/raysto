"use client";
export default function ErrorPage({ reset }: { reset: () => void }) {
  return (
    <main className="loading-page">
      <h1>Let’s try that again.</h1>
      <p>
        This page couldn’t open. Your saved demo data is still in this browser.
      </p>
      <button onClick={reset}>Try again</button>
      <a href="/">Back to Raysto</a>
    </main>
  );
}
