import { registerRoot } from "remotion";
import { PromoRoot } from "./Promo";

// Separate entry for the one-minute promo:
//   npx remotion render src/promo/index.ts RaystoPromo60 ../dist/raysto-promo-60s-1080p.mp4
registerRoot(PromoRoot);
