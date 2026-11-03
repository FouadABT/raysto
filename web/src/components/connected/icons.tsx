// One small outline icon set for the console, drawn on a 24px grid with a
// 1.75 stroke so every icon carries the same weight.
import type { SVGProps } from "react";

const paths = {
  overview: <><rect x="3.5" y="3.5" width="7" height="7" rx="2" /><rect x="13.5" y="3.5" width="7" height="7" rx="2" /><rect x="3.5" y="13.5" width="7" height="7" rx="2" /><rect x="13.5" y="13.5" width="7" height="7" rx="2" /></>,
  orders: <><path d="M6 3.5h12v17l-3-2-3 2-3-2-3 2z" /><path d="M9 8.5h6M9 12h6M9 15.5h3.5" /></>,
  payments: <><rect x="2.75" y="5.5" width="18.5" height="13" rx="2.5" /><path d="M2.75 9.75h18.5M6.5 15h3" /></>,
  agents: <><path d="M12 3.5 13.6 8a2 2 0 0 0 1.2 1.2l4.5 1.6-4.5 1.6A2 2 0 0 0 13.6 13.6L12 18.1l-1.6-4.5a2 2 0 0 0-1.2-1.2L4.7 10.8l4.5-1.6A2 2 0 0 0 10.4 8z" /><path d="M18.5 15.5v4M16.5 17.5h4" /></>,
  floor: <><ellipse cx="12" cy="12" rx="5.5" ry="4" /><path d="M5 5.5h3M16 5.5h3M5 18.5h3M16 18.5h3" /></>,
  refresh: <><path d="M20 11.5a8 8 0 0 0-14.3-4.6L4 9" /><path d="M4 4.5V9h4.5" /><path d="M4 12.5a8 8 0 0 0 14.3 4.6L20 15" /><path d="M20 19.5V15h-4.5" /></>,
  save: <><path d="M5 3.5h11l3.5 3.5v13H5z" /><path d="M8.5 3.5v5h6v-5M8 20.5v-6h8v6" /></>,
  signOut: <><path d="M14 4.5H6.5a2 2 0 0 0-2 2v11a2 2 0 0 0 2 2H14" /><path d="M17 8l4 4-4 4M21 12H10" /></>,
  arrow: <path d="M5 12h14M13 6l6 6-6 6" />,
  check: <path d="M5 12.5l4.5 4.5L19 7.5" />,
  alert: <><path d="M12 3.5 21.5 20h-19z" /><path d="M12 10v4.5M12 17.25v.25" /></>,
  clock: <><circle cx="12" cy="12" r="8.5" /><path d="M12 7.5V12l3 2" /></>,
  kitchen: <><path d="M6 3.5v6a2.5 2.5 0 0 0 5 0v-6M8.5 3.5v17" /><path d="M17.5 20.5V3.5c-2.2 1.5-3 4-3 7h3" /></>,
  bell: <><path d="M6 16.5V11a6 6 0 0 1 12 0v5.5l1.5 2h-15z" /><path d="M10 20.5h4" /></>,
  receipt: <><path d="M6 3.5h12v17l-3-2-3 2-3-2-3 2z" /><path d="M9 9h6M9 13h6" /></>,
  paypal: <><path d="M8 20.5 10.5 4H16a4 4 0 0 1 0 8h-3.5l-1.2 8.5z" /><path d="M6 17.5h3" /></>,
  play: <><circle cx="12" cy="12" r="8.5" /><path d="M10.25 8.75v6.5L15.5 12z" /></>,
  mic: <><rect x="9" y="3.5" width="6" height="11" rx="3" /><path d="M5.5 11.5a6.5 6.5 0 0 0 13 0M12 18v2.5" /></>,
  image: <><rect x="3.5" y="4.5" width="17" height="15" rx="2.5" /><circle cx="9" cy="9.5" r="1.75" /><path d="m20.5 16-4.5-4.5L7 20" /></>,
  chat: <><path d="M4.5 5.5h15v10h-8l-4.5 3.5v-3.5H4.5z" /><path d="M8.5 9.5h7M8.5 12.5h4" /></>,
  menu: <><path d="M6 3.5h12v17H6z" /><path d="M9 8h6M9 11.5h6M9 15h4" /></>,
  money: <><circle cx="12" cy="12" r="8.5" /><path d="M12 7v10M14.75 9.25c0-1-1.2-1.75-2.75-1.75S9.25 8.25 9.25 9.5c0 2.5 5.5 1.5 5.5 4.25 0 1.25-1.2 2-2.75 2s-2.75-.75-2.75-1.75" /></>,
  team: <><circle cx="9" cy="8.5" r="3" /><path d="M3.5 19a5.5 5.5 0 0 1 11 0" /><circle cx="16.5" cy="9.5" r="2.25" /><path d="M15.5 14.25a4.5 4.5 0 0 1 5 4.25" /></>,
  plus: <path d="M12 5v14M5 12h14" />,
  invoice: <><path d="M6 3.5h9l3 3v14H6z" /><path d="M15 3.5v3h3M9 11h6M9 14.5h6M9 18h3" /></>,
  chart: <><path d="M4 20h16" /><rect x="6" y="11" width="3" height="6" rx="0.75" /><rect x="11" y="7" width="3" height="10" rx="0.75" /><rect x="16" y="4" width="3" height="13" rx="0.75" /></>,
} as const;

export type IconName = keyof typeof paths;

export function Icon({ name, size = 20, ...rest }: { name: IconName; size?: number } & SVGProps<SVGSVGElement>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.75}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
      {...rest}
    >
      {paths[name]}
    </svg>
  );
}
