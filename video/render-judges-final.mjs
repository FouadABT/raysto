import { selectComposition, renderMedia } from '@remotion/renderer';
import path from 'node:path';

// Use the exact bundle inspected by render-judges-previews.mjs.
const serveUrl=path.resolve('out/judges-bundle');
const browserExecutable=process.env.RAYSTO_RENDER_BROWSER||'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const composition=await selectComposition({serveUrl,id:'RaystoJudges38',browserExecutable});
let last=-1;
await renderMedia({
 composition,serveUrl,browserExecutable,
 outputLocation:path.resolve('../dist/raysto-judges-phase1-38s-pro-audio-1080p.mp4'),
 codec:'h264',crf:18,concurrency:4,pixelFormat:'yuv420p',
 audioCodec:'aac',audioBitrate:'256k',
 onProgress:({progress})=>{const p=Math.floor(progress*10)*10;if(p!==last){console.log(`Export ${p}%`);last=p;}}
});
console.log('Export complete: 1140 frames / 38 seconds.');
