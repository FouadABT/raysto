import type { Metadata } from "next";
import localFont from "next/font/local";
import "material-symbols/rounded.css";
import "./globals.css";
import "lenis/dist/lenis.css";
import "@fontsource-variable/fraunces/full.css";
import "@fontsource-variable/fraunces/full-italic.css";
import "./supper-club.css";
import { DemoProvider } from "@/lib/store";

const jakarta = localFont({
  src: [
    { path: "../../public/fonts/PlusJakartaSans-Regular.ttf", weight: "400" },
    { path: "../../public/fonts/PlusJakartaSans-Medium.ttf", weight: "500" },
    { path: "../../public/fonts/PlusJakartaSans-SemiBold.ttf", weight: "600" },
    { path: "../../public/fonts/PlusJakartaSans-Bold.ttf", weight: "700" },
  ],
  variable: "--font-jakarta",
  display: "swap",
});
export const metadata: Metadata = {
  title: {
    default: "Raysto · A little more hospitality",
    template: "%s · Raysto",
  },
  description:
    "Discover, dine, and run a remarkable restaurant. Explore the Raysto phase 1 demo.",
  robots: { index: false, follow: false },
};
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={jakarta.variable} data-scroll-behavior="smooth">
      <body>
        <DemoProvider>{children}</DemoProvider>
      </body>
    </html>
  );
}
