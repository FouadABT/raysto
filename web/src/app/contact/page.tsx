import type { Metadata } from "next";
import { EmailInquiry } from "@/components/landing/email-inquiry";
import "@/components/landing/landing.css";

export const metadata: Metadata = {
  title: "Book a demo",
  description: "Prepare an email inquiry for a closer look at Raysto.",
};
export default function ContactPage() {
  const configured = process.env.RAYSTO_DEMO_CONTACT_EMAIL ?? "";
  const recipient =
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$/.test(
      configured,
    )
      ? configured
      : "";
  return (
    <div className="raysto-landing lp-contact-page">
      <header className="lp-header">
        <div className="lp-container lp-header-inner">
          <a className="lp-wordmark" href="/" aria-label="Raysto home">
            raysto<span aria-hidden="true">✳</span>
          </a>
          <a className="lp-signin" href="/">
            Back to the product
          </a>
          <div className="lp-header-actions">
            <a href="/ops" className="lp-button lp-button-outline">
              Explore workspace
            </a>
          </div>
        </div>
      </header>
      <main className="lp-container lp-contact-layout">
        <div>
          <span className="lp-eyebrow">TAKE A CLOSER LOOK</span>
          <h1>
            Let&apos;s talk about
            <br />
            <em>your next service.</em>
          </h1>
          <p className="lp-intro">
            Prepare a demo inquiry in your own words. You review the email
            before sending it.
          </p>
          <a href="/" className="lp-link">
            Explore the product first{" "}
            <span className="material-symbols-rounded" aria-hidden="true">
              arrow_back
            </span>
          </a>
        </div>
        <EmailInquiry recipient={recipient} />
      </main>
    </div>
  );
}
