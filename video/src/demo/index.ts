import { registerRoot } from "remotion";
import { DemoRoot } from "./Demo";

// Separate entry for the judges' demo film:
//   npx remotion render src/demo/index.ts RaystoDemo ../dist/raysto-demo-1080p.mp4
registerRoot(DemoRoot);
