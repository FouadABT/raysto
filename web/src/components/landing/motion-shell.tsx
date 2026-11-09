"use client";

import {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
  type ReactNode,
} from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";

gsap.registerPlugin(ScrollTrigger, useGSAP);
const MotionPreference = createContext({
  reduce: false,
  app: false,
  setApp: (_on: boolean) => {},
});
const storageKey = "raysto.reduceMotion";
export const useLandingMotion = () => useContext(MotionPreference);

/** SSR content stays visible. This island owns only marketing choreography. */
export function MotionShell({ children }: { children: ReactNode }) {
  const scope = useRef<HTMLDivElement>(null);
  const [app, setAppState] = useState(false),
    [os, setOs] = useState(false);
  useEffect(() => {
    const media = matchMedia("(prefers-reduced-motion: reduce)");
    const syncOs = () => setOs(media.matches);
    const syncApp = () => {
      try {
        setAppState(localStorage.getItem(storageKey) === "1");
      } catch {}
    };
    syncOs();
    syncApp();
    media.addEventListener("change", syncOs);
    window.addEventListener("storage", syncApp);
    return () => {
      media.removeEventListener("change", syncOs);
      window.removeEventListener("storage", syncApp);
    };
  }, []);
  const setApp = (on: boolean) => {
    setAppState(on);
    try {
      if (on) localStorage.setItem(storageKey, "1");
      else localStorage.removeItem(storageKey);
    } catch {}
  };
  useGSAP(
    () => {
      const root = scope.current;
      if (!root) return;
      // Read storage here as well: no positional animation before the effect above.
      try {
        if (app || localStorage.getItem(storageKey) === "1") return;
      } catch {
        if (app) return;
      }
      const media = gsap.matchMedia(root);
      media.add(
        {
          base: "(min-width: 0px)",
          desktop: "(min-width: 1024px) and (pointer: fine)",
          reduce: "(prefers-reduced-motion: reduce)",
        },
        (context) => {
          if (context.conditions?.reduce) return;
          const desktop = !!context.conditions?.desktop;
          const hero = gsap.timeline({ defaults: { ease: "power3.out" } });
          hero
            .from(
              "[data-hero-line]",
              {
                y: desktop ? 24 : 12,
                duration: desktop ? 0.65 : 0.45,
                stagger: 0.08,
              },
              0.06,
            )
            .from(
              "[data-hero-dashboard]",
              {
                y: desktop ? 24 : 12,
                scale: desktop ? 0.985 : 1,
                duration: 0.8,
              },
              0.18,
            )
            .from(
              "[data-hero-phone]",
              { y: desktop ? 20 : 12, duration: 0.8 },
              0.32,
            )
            .from(
              "[data-hero-photo]",
              { scale: desktop ? 1.015 : 1, duration: 0.85 },
              0.42,
            );
          gsap.utils
            .toArray<HTMLElement>("[data-reveal]", root)
            .forEach((element) => {
              gsap.from(element, {
                y: desktop ? 24 : 12,
                opacity: 0.65,
                duration: desktop ? 0.6 : 0.4,
                ease: "power2.out",
                scrollTrigger: {
                  trigger: element,
                  start: "top 92%",
                  once: true,
                },
              });
            });
          const journey = root.querySelector("[data-journey]");
          if (journey) {
            const timeline = gsap.timeline({
              defaults: { duration: 0.4, ease: "power2.out" },
              scrollTrigger: { trigger: journey, start: "top 78%", once: true },
            });
            journey
              .querySelectorAll("[data-journey-stage]")
              .forEach((stage, index) => {
                const line = stage.querySelector(".lp-stage-connector"),
                  marker = stage.querySelector(".lp-stage-number");
                if (line)
                  timeline.from(
                    line,
                    {
                      scaleX: desktop ? 0 : 1,
                      scaleY: desktop ? 1 : 0,
                      transformOrigin: desktop ? "left center" : "center top",
                    },
                    index * 0.25,
                  );
                if (marker)
                  timeline.from(
                    marker,
                    { backgroundColor: "#E6EDE2", duration: 0.35 },
                    index * 0.25,
                  );
              });
          }
          const money = root.querySelector("[data-money]");
          if (money)
            gsap.from(money.querySelectorAll("[data-money-row]"), {
              backgroundColor: "#D7F978",
              duration: 0.7,
              stagger: 0.1,
              ease: "power2.out",
              scrollTrigger: { trigger: money, start: "top 82%", once: true },
            });
          const ai = root.querySelector("[data-ai-scene]");
          if (ai)
            gsap
              .timeline({
                defaults: { duration: 0.4, ease: "power2.out" },
                scrollTrigger: { trigger: ai, start: "top 80%", once: true },
              })
              .from(ai.querySelector(".lp-source-sheet"), {
                y: 12,
                opacity: 0.6,
              })
              .from(
                ai.querySelector(".lp-evidence-connector"),
                { scaleX: 0, transformOrigin: "left" },
                0.35,
              )
              .from(
                ai.querySelector(".lp-proposal"),
                { y: 12, opacity: 0.65 },
                0.7,
              );
          const illustration = root.querySelector("[data-cafe-drawing]");
          if (illustration)
            gsap.from(illustration.querySelectorAll("path"), {
              strokeDashoffset: 1,
              duration: 0.8,
              stagger: 0.025,
              ease: "power2.out",
              scrollTrigger: {
                trigger: illustration,
                start: "top 90%",
                once: true,
              },
            });
        },
      );
      let alive = true,
        frame = 0;
      const refresh = () => {
        cancelAnimationFrame(frame);
        frame = requestAnimationFrame(() => {
          if (alive) ScrollTrigger.refresh();
        });
      };
      root.addEventListener("load", refresh, true);
      void document.fonts.ready.then(() => {
        if (alive) refresh();
      });
      refresh();
      return () => {
        alive = false;
        cancelAnimationFrame(frame);
        root.removeEventListener("load", refresh, true);
        media.revert();
      };
    },
    { scope, dependencies: [app], revertOnUpdate: true },
  );
  return (
    <MotionPreference.Provider value={{ reduce: app || os, app, setApp }}>
      <div
        ref={scope}
        className="raysto-landing"
        data-reduce-motion={app || os || undefined}
      >
        {children}
      </div>
    </MotionPreference.Provider>
  );
}

export function MotionSwitch() {
  const { app, setApp } = useLandingMotion();
  return (
    <label className="lp-motion-switch">
      <input
        type="checkbox"
        checked={app}
        onChange={(event) => setApp(event.target.checked)}
      />
      <span>Reduce motion</span>
    </label>
  );
}
