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
import { Symbol } from "./symbol";

gsap.registerPlugin(ScrollTrigger, useGSAP);
type Scene = "hero" | "journey" | "ai";
const MotionPreference = createContext({
  reduce: false,
  app: false,
  os: false,
  setApp: (_on: boolean) => {},
  replay: (_scene: Scene) => {},
});
const storageKey = "raysto.reduceMotion";
export const useLandingMotion = () => useContext(MotionPreference);

/** SSR content stays visible. This island owns only marketing choreography. */
export function MotionShell({ children }: { children: ReactNode }) {
  const scope = useRef<HTMLDivElement>(null);
  const scenes = useRef(new Map<Scene, gsap.core.Timeline>());
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
          gsap.fromTo(
            ".lp-reading-progress",
            { scaleX: 0 },
            {
              scaleX: 1,
              ease: "none",
              scrollTrigger: {
                trigger: root,
                start: "top top",
                end: "bottom bottom",
                scrub: 0.2,
              },
            },
          );
          if (desktop) {
            gsap.to(".lp-hero-scene", {
              y: 70,
              ease: "none",
              scrollTrigger: {
                trigger: ".lp-hero",
                start: "top top",
                end: "bottom top",
                scrub: 0.45,
              },
            });
            gsap.fromTo(
              ".lp-service-photo img",
              { yPercent: -5, scale: 1.12 },
              {
                yPercent: 5,
                scale: 1.12,
                ease: "none",
                scrollTrigger: {
                  trigger: ".lp-service-photo",
                  start: "top bottom",
                  end: "bottom top",
                  scrub: 0.6,
                },
              },
            );
          }
          const hero = gsap.timeline({ defaults: { ease: "power3.out" } });
          scenes.current.set("hero", hero);
          hero
            .from(
              "[data-hero-line]",
              {
                y: desktop ? 32 : 16,
                duration: 0.85,
                stagger: 0.1,
              },
              0.06,
            )
            .from(
              "[data-hero-dashboard]",
              {
                y: desktop ? 48 : 20,
                x: desktop ? 36 : 0,
                rotation: desktop ? -0.7 : 0,
                scale: desktop ? 0.97 : 1,
                duration: 1.1,
              },
              0.18,
            )
            .from(
              "[data-hero-phone]",
              {
                y: desktop ? 56 : 24,
                x: desktop ? 24 : 0,
                rotation: desktop ? 1.2 : 0,
                duration: 1.1,
              },
              0.45,
            )
            .from(
              "[data-hero-photo]",
              { scale: desktop ? 1.04 : 1.015, duration: 1.2 },
              0.35,
            )
            .from(
              "[data-hero-ai]",
              { x: desktop ? 16 : 0, opacity: 0.9, duration: 0.55 },
              1,
            )
            .from(
              "[data-hero-paypal]",
              { x: desktop ? 16 : 0, opacity: 0.9, duration: 0.55 },
              1.4,
            );
          gsap.utils
            .toArray<HTMLElement>("[data-reveal]", root)
            .forEach((element) => {
              gsap.from(element, {
                y: desktop ? 24 : 12,
                opacity: 0.9,
                duration: desktop ? 0.75 : 0.45,
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
              defaults: { duration: 0.55, ease: "power2.out" },
              scrollTrigger: { trigger: journey, start: "top 78%", once: true },
            });
            scenes.current.set("journey", timeline);
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
                    index * 0.4,
                  );
                if (marker)
                  timeline.from(
                    marker,
                    { backgroundColor: "#E6EDE2", scale: 0.88, duration: 0.5 },
                    index * 0.4,
                  );
                const card = stage.querySelector(".lp-stage-preview");
                if (card)
                  timeline.from(
                    card,
                    {
                      y: desktop ? 20 : 12,
                      scale: desktop ? 0.98 : 1,
                      opacity: 0.9,
                      duration: 0.65,
                    },
                    index * 0.4 + 0.08,
                  );
              });
          }
          const money = root.querySelector("[data-money]");
          if (money)
            gsap
              .timeline({
                scrollTrigger: { trigger: money, start: "top 82%", once: true },
              })
              .from(money, {
                y: desktop ? 32 : 12,
                scale: desktop ? 0.97 : 1,
                duration: 0.8,
                ease: "power2.out",
              })
              .from(
                money.querySelectorAll("[data-money-row]"),
                {
                  backgroundColor: "#D7F978",
                  x: desktop ? 12 : 0,
                  duration: 0.65,
                  stagger: 0.15,
                  ease: "power2.out",
                },
                0.35,
              );
          const ai = root.querySelector("[data-ai-scene]");
          if (ai) {
            const timeline = gsap.timeline({
              defaults: { duration: 0.55, ease: "power2.out" },
              scrollTrigger: { trigger: ai, start: "top 80%", once: true },
            });
            scenes.current.set("ai", timeline);
            timeline
              .from(ai.querySelector(".lp-source-sheet"), {
                y: 18,
                rotation: desktop ? -2 : 0,
                opacity: 0.9,
              })
              .from(
                ai.querySelector(".lp-evidence-connector"),
                { scaleX: 0, transformOrigin: "left" },
                0.4,
              )
              .from(
                ai.querySelector(".lp-proposal"),
                {
                  y: 24,
                  scale: desktop ? 0.97 : 1,
                  opacity: 0.9,
                  duration: 0.65,
                },
                0.85,
              )
              .from(
                ai.querySelector(".lp-status-pair"),
                { y: 8, opacity: 0.9, duration: 0.45 },
                1.25,
              );
          }
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
        scenes.current.clear();
      };
    },
    { scope, dependencies: [app], revertOnUpdate: true },
  );
  const replay = (scene: Scene) => {
    if (app || os) return;
    const timeline = scenes.current.get(scene);
    if (!timeline) return;
    timeline.scrollTrigger?.disable(false);
    timeline.restart();
  };
  return (
    <MotionPreference.Provider
      value={{ reduce: app || os, app, os, setApp, replay }}
    >
      <div
        ref={scope}
        className="raysto-landing"
        data-reduce-motion={app || os || undefined}
      >
        <div className="lp-reading-progress" aria-hidden="true" />
        {children}
      </div>
    </MotionPreference.Provider>
  );
}

export function MotionReplay({
  scene,
  label,
}: {
  scene: Scene;
  label: string;
}) {
  const { reduce, os, replay } = useLandingMotion();
  const hint = `lp-motion-hint-${scene}`;
  return (
    <div className="lp-motion-tools">
      <button
        type="button"
        className="lp-replay"
        aria-describedby={hint}
        onClick={() => replay(scene)}
        disabled={reduce}
      >
        <Symbol name={reduce ? "motion_photos_paused" : "replay"} />
        {label}
      </button>
      <p className="lp-motion-hint" id={hint}>
        {os
          ? "Your browser/device requests reduced motion. Animations stay off."
          : reduce
            ? "Reduced motion is on. Use the page’s Reduce motion setting to enable replay."
            : "Play the scene again, or scroll to follow the full story."}
      </p>
    </div>
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
