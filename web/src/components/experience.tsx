"use client";
import dynamic from "next/dynamic";
import {
  useCallback,
  useEffect,
  useRef,
  useState,
  useSyncExternalStore,
} from "react";
import Link from "next/link";
import { motion, useInView, useScroll, useTransform } from "motion/react";
import Lenis from "lenis";
import { useDemo } from "@/lib/store";
import { ActionLink, Icon } from "./ui";

const TableSculpture = dynamic(() => import("./table-sculpture"), {
  ssr: false,
});

export function useCalmMotion() {
  const system = useMedia("(prefers-reduced-motion: reduce)", true);
  const { state } = useDemo();
  return Boolean(system || state.settings.reducedMotion);
}

function useMedia(query: string, serverValue: boolean) {
  const subscribe = useCallback(
    (notify: () => void) => {
      const media = matchMedia(query);
      media.addEventListener("change", notify);
      return () => media.removeEventListener("change", notify);
    },
    [query],
  );
  return useSyncExternalStore(
    subscribe,
    () => matchMedia(query).matches,
    () => serverValue,
  );
}

export function SmoothExperience() {
  const calm = useCalmMotion();
  const finePointer = useMedia("(pointer: fine)", false);
  useEffect(() => {
    if (calm || !finePointer) return;
    const lenis = new Lenis({
      duration: 0.85,
      smoothWheel: true,
      syncTouch: false,
      prevent: (node) =>
        node.tagName === "DIALOG" || node.closest("dialog") !== null,
    });
    // A keyboard command must take over immediately from wheel interpolation.
    const interruptForKeyboard = (event: KeyboardEvent) => {
      if (
        ![
          "Home",
          "End",
          "PageUp",
          "PageDown",
          "ArrowUp",
          "ArrowDown",
          " ",
        ].includes(event.key)
      )
        return;
      lenis.stop();
      lenis.start();
    };
    window.addEventListener("keydown", interruptForKeyboard);
    let frame = 0;
    const tick = (time: number) => {
      lenis.raf(time);
      frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => {
      cancelAnimationFrame(frame);
      window.removeEventListener("keydown", interruptForKeyboard);
      lenis.destroy();
    };
  }, [calm, finePointer]);
  return null;
}

export function OliveDrawing() {
  return (
    <svg
      viewBox="0 0 160 130"
      fill="none"
      aria-hidden="true"
      className="olive-drawing"
    >
      <path
        d="M32 114C55 90 83 53 130 20M67 76C50 75 24 47 31 38C52 38 69 56 67 76ZM84 58C89 39 111 32 121 40C115 57 100 64 84 58ZM105 38C99 21 100 8 109 5C121 15 121 27 105 38"
        stroke="currentColor"
        strokeWidth="2"
      />
      <ellipse
        cx="51"
        cy="91"
        rx="14"
        ry="20"
        transform="rotate(-35 51 91)"
        fill="currentColor"
      />
      <ellipse
        cx="91"
        cy="80"
        rx="14"
        ry="20"
        transform="rotate(25 91 80)"
        fill="currentColor"
      />
      <path
        d="M43 82L49 76M85 72L90 66"
        stroke="var(--paper)"
        strokeWidth="2"
      />
    </svg>
  );
}

export function SupperHero() {
  const { state } = useDemo();
  const calm = useCalmMotion();
  const wide = useMedia("(min-width: 760px)", false);
  const ref = useRef<HTMLElement>(null);
  const inView = useInView(ref, { margin: "100px" });
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });
  const photoY = useTransform(scrollYProgress, [0, 1], [0, 90]);
  const stampRotate = useTransform(scrollYProgress, [0, 1], [-12, 14]);
  const [webgl, setWebgl] = useState(false);
  useEffect(() => {
    if (calm || !wide) return;
    const canvas = document.createElement("canvas");
    const gl = canvas.getContext("webgl2");
    setWebgl(Boolean(gl));
    gl?.getExtension("WEBGL_lose_context")?.loseContext();
  }, [calm, wide]);
  return (
    <section className="supper-hero" ref={ref}>
      <div className="editorial-kicker">
        <span>CASABLANCA, MOROCCO</span>
        <span>THE GOOD COMPANY EDITION — 01</span>
      </div>
      <h1 className="supper-title">
        Come hungry<span className="tomato-period">.</span>
        <br />
        <span className="title-second">
          Leave <em>happy.</em>
        </span>
      </h1>
      <div className="supper-composition">
        <div className="supper-intro">
          <span className="eyebrow">A TABLE WORTH COMING BACK TO</span>
          <p>
            Long lunches. Last bites.
            <br />A little more <em>“stay a while.”</em>
          </p>
          <p className="supper-description">
            Mediterranean soul, Moroccan heart. Find your next favorite at{" "}
            {state.settings.restaurant}.
          </p>
          <ActionLink
            href="/r/olive-and-hearth"
            className="ticket-button"
            icon="north_east"
          >
            Find your favorite
          </ActionLink>
          <div className="hero-secondary">
            <Link href="/reservations">
              Save me a seat <Icon name="arrow_forward" />
            </Link>
          </div>
          <div className="table-object" aria-hidden="true">
            <div className="sculpture-fallback">
              <OliveDrawing />
            </div>
            {webgl && wide && !calm && inView && (
              <TableSculpture progress={scrollYProgress} />
            )}
            <span>A LITTLE OLIVE. A LOT OF SOUL.</span>
          </div>
        </div>
        <div className="supper-image-frame">
          <motion.img
            style={{ y: calm ? 0 : photoY }}
            src="/images/supper-table.webp"
            alt="Burrata, heirloom tomatoes and olives on a sunlit linen table — generated editorial illustration"
            fetchPriority="high"
            width="1536"
            height="1024"
          />
          <motion.div
            className="supper-stamp"
            style={{ rotate: calm ? -12 : stampRotate }}
          >
            <span>MADE FOR</span>
            <strong>
              one more
              <br />
              bite.
            </strong>
            <span>OLIVE & HEARTH</span>
          </motion.div>
          <div className="photo-footnote">
            <span>01 / AT OUR TABLE</span>
            <span>Fresh ingredients. No occasion needed.</span>
            <Icon name="south_east" />
          </div>
        </div>
      </div>
      <div className="hospitality-ribbon">
        <span>GOOD FOOD</span>
        <b>✳</b>
        <span>BETTER COMPANY</span>
        <b>✳</b>
        <span>EVERYONE’S WELCOME</span>
        <b>✳</b>
        <span>TAKE YOUR TIME</span>
      </div>
    </section>
  );
}

export function StoryPhoto() {
  const ref = useRef<HTMLDivElement>(null);
  const calm = useCalmMotion();
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });
  const y = useTransform(scrollYProgress, [0, 1], [-32, 32]);
  return (
    <div className="restaurant-feature-photo" ref={ref}>
      <motion.img
        style={{ y: calm ? 0 : y }}
        src="/images/olive-room.webp"
        alt="An imagined Olive & Hearth dining room, warm sun, olive banquettes and laid tables"
        loading="lazy"
        width="1536"
        height="1024"
      />
      <span className="image-badge">YOUR NEW USUAL.</span>
    </div>
  );
}
