"use client";

import { useRef, useState } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";
import { useLandingMotion } from "./motion-shell";
import { Symbol } from "./symbol";

gsap.registerPlugin(ScrollTrigger, useGSAP);

const chapters = [
  {
    label: "The evidence",
    icon: "receipt_long",
    title: "A supplier changes the price.",
    copy: "Start with the document. Confirm what changed, connect the ingredient and follow it into the dishes you serve.",
    status: "Source ready for review",
    rows: [
      ["Source", "Supplier document"],
      ["Ingredient", "Coffee beans"],
      ["Affected dish", "Cappuccino"],
    ],
  },
  {
    label: "The intelligence",
    icon: "auto_awesome",
    title: "AI connects the dots.",
    copy: "Ask why contribution changed. AI brings the evidence together and prepares a scenario using your targets and limits.",
    status: "AI proposal · not published",
    rows: [
      ["Evidence", "Confirmed ingredient cost"],
      ["Comparison", "Keep price / change price"],
      ["Volume response", "An explicit assumption"],
    ],
  },
  {
    label: "Your decision",
    icon: "tune",
    title: "Challenge it. Make it yours.",
    copy: "Try a tighter price limit. Compare a lower sales volume. Inspect the calculations in AG Studio, then keep, defer or review a price change.",
    status: "Owner review required",
    rows: [
      ["Control", "Your pricing policy"],
      ["Analysis", "AG Studio workspace"],
      ["Publication", "Separate approval"],
    ],
  },
  {
    label: "The money trail",
    icon: "account_balance_wallet",
    title: "PayPal moves the money.",
    copy: "A new order can use PayPal checkout. A supplier payout has its own approval. Return to inspect recorded outcomes, with pending states kept visible.",
    status: "Sandbox · no payment in this scene",
    rows: [
      ["Customer", "PayPal checkout"],
      ["Supplier", "Separately approved payout"],
      ["Evidence", "Recorded provider status"],
    ],
  },
] as const;

/** A native-scrolling story. Decorative panels duplicate the accessible chapters. */
export function ScrollStory() {
  const root = useRef<HTMLElement>(null);
  const [active, setActive] = useState(0);
  const { reduce, app } = useLandingMotion();
  useGSAP(
    () => {
      if (!root.current) return;
      const media = gsap.matchMedia(root);
      media.add(
        {
          wide: "(min-width: 1000px) and (min-height: 720px)",
          reduce: "(prefers-reduced-motion: reduce)",
          all: "(min-width: 0px)",
        },
        (context) => {
          const host = root.current!;
          const steps = Array.from(
            host.querySelectorAll<HTMLElement>(".lp-story-chapter"),
          );
          const cards = Array.from(
            host.querySelectorAll<HTMLElement>(".lp-story-card"),
          );
          let stored = false;
          try {
            stored = localStorage.getItem("raysto.reduceMotion") === "1";
          } catch {}
          const reduced = app || context.conditions?.reduce || stored;
          host.dataset.enhanced = "true";
          steps.forEach((step, index) => {
            ScrollTrigger.create({
              trigger: step,
              start: "top 55%",
              end: "bottom 55%",
              onToggle: (self) => {
                if (self.isActive) setActive(index);
              },
            });
            if (!reduced && context.conditions?.wide && index > 0) {
              gsap.fromTo(
                cards[index],
                { y: 110, rotation: 5, scale: 0.94 },
                {
                  y: 0,
                  rotation: 0,
                  scale: 1,
                  ease: "none",
                  scrollTrigger: {
                    trigger: step,
                    start: "top 90%",
                    end: "top 40%",
                    scrub: 0.35,
                  },
                },
              );
            }
          });
          if (!reduced) {
            gsap.fromTo(
              host.querySelector(".lp-story-orbit"),
              { rotation: -35 },
              {
                rotation: 140,
                ease: "none",
                scrollTrigger: {
                  trigger: host,
                  start: "top bottom",
                  end: "bottom top",
                  scrub: 0.5,
                },
              },
            );
            gsap.fromTo(
              host.querySelector(".lp-story-type"),
              { xPercent: 8 },
              {
                xPercent: -12,
                ease: "none",
                scrollTrigger: {
                  trigger: host,
                  start: "top bottom",
                  end: "bottom top",
                  scrub: 0.4,
                },
              },
            );
          }
          return () => {
            delete host.dataset.enhanced;
          };
        },
      );
      return () => media.revert();
    },
    { scope: root, dependencies: [app], revertOnUpdate: true },
  );

  return (
    <section
      id="connected-story"
      ref={root}
      className="lp-scroll-story"
      data-active={active}
      aria-labelledby="connected-story-title"
    >
      <div className="lp-story-type" aria-hidden="true">
        Evidence. Intelligence. Action.
      </div>
      <div className="lp-container">
        <div className="lp-story-heading">
          <span className="lp-eyebrow">
            ONE CONNECTED DECISION · FOUR CHAPTERS
          </span>
          <h2 id="connected-story-title">
            From a cost change
            <br />
            to <em>a clearer decision.</em>
          </h2>
          <p>AI prepares. You decide. PayPal executes supported payments.</p>
          <a href="#story-chapter-0" className="lp-story-scroll">
            Scroll to follow the evidence <Symbol name="south" />
          </a>
        </div>
        <div className="lp-story-layout">
          <div className="lp-story-sticky">
            <div className="lp-story-stage" aria-hidden="true">
              <div className="lp-story-orbit">
                <span>✳</span>
              </div>
              {chapters.map((chapter, index) => (
                <div
                  className="lp-story-card"
                  key={chapter.label}
                  data-current={active === index}
                >
                  <div className="lp-story-card-top">
                    <span>raysto ✳</span>
                    <span>0{index + 1} / 04</span>
                  </div>
                  <div className="lp-story-card-icon">
                    <Symbol name={chapter.icon} />
                  </div>
                  <span className="lp-eyebrow">{chapter.label}</span>
                  <h3>{index === 3 ? "PayPal payments" : chapter.title}</h3>
                  <dl>
                    {chapter.rows.map(([label, value]) => (
                      <div key={label}>
                        <dt>{label}</dt>
                        <dd>{value}</dd>
                      </div>
                    ))}
                  </dl>
                  <p className="lp-story-card-status">
                    <span />
                    {chapter.status}
                  </p>
                </div>
              ))}
            </div>
            <nav className="lp-story-nav" aria-label="Decision story chapters">
              {chapters.map((chapter, index) => (
                <a
                  key={chapter.label}
                  href={`#story-chapter-${index}`}
                  aria-label={`Chapter ${index + 1}: ${chapter.label}`}
                  aria-current={index === active ? "step" : undefined}
                >
                  <span>0{index + 1}</span>
                  <i />
                </a>
              ))}
            </nav>
            <p className="lp-story-note">
              Illustrative workflow.{" "}
              {reduce
                ? "Reduced motion: chapters change without animation."
                : "Scroll forward or back to explore."}
            </p>
          </div>
          <div className="lp-story-chapters">
            {chapters.map((chapter, index) => (
              <article
                id={`story-chapter-${index}`}
                className="lp-story-chapter"
                key={chapter.label}
                tabIndex={-1}
              >
                <span className="lp-story-number" aria-hidden="true">
                  0{index + 1}
                  <Symbol name={chapter.icon} />
                </span>
                <span className="lp-eyebrow">{chapter.label}</span>
                <h3>{chapter.title}</h3>
                <p>{chapter.copy}</p>
                <span className="lp-story-status">{chapter.status}</span>
                {index === 3 && (
                  <a className="lp-button" href="/ops">
                    Explore the workspace <Symbol name="north_east" />
                  </a>
                )}
              </article>
            ))}
          </div>
        </div>
        <p className="lp-story-disclaimer">
          Illustrative product story, not a payment receipt. Connected demos use
          PayPal Sandbox. AI does not approve, publish or pay.
        </p>
      </div>
    </section>
  );
}
