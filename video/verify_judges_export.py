"""Verify the local master and produce review frames, a thumbnail and hashes."""
from pathlib import Path
import subprocess
import json
import hashlib
import math
import wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parent
DIST=ROOT.parent/'dist'
OUT=ROOT/'out/judges-final-review'
OUT.mkdir(parents=True,exist_ok=True)
BIN=ROOT/'node_modules/@remotion/compositor-win32-x64-msvc'
PREFIX='raysto-judges-phase1-38s'
FILM=DIST/f'{PREFIX}-1080p.mp4'
def run(args):
    return subprocess.run([str(x) for x in args],capture_output=True,check=True).stdout
probe=json.loads(run([BIN/'ffprobe.exe','-v','error','-show_streams','-show_format','-of','json',FILM]))
v=next(s for s in probe['streams'] if s['codec_type']=='video')
a=next(s for s in probe['streams'] if s['codec_type']=='audio')
assert (v['width'],v['height'],v['r_frame_rate'],int(v['nb_frames']))==(1920,1080,'30/1',1140)
assert v['codec_name']=='h264' and a['codec_name']=='aac'
assert abs(float(probe['format']['duration'])-38)<.1
frames=[30,90,130,215,310,420,500,625,730,875,970,1080,1138]
labels=['Opening','Shared visit','Group request','Gemini tools','Server-priced result','Host approval','Kitchen event','Exact shares','PayPal + MCP','Shared operations','AG Studio evidence','Native demonstration','Bridge to next phase']
for f in frames:
    run([BIN/'ffmpeg.exe','-y','-v','error','-ss',f/30,'-i',FILM,'-frames:v','1','-vf','scale=640:360','-f','image2',OUT/f'{f}.png'])
thumbnail=DIST/f'{PREFIX}-thumbnail.png'
run([BIN/'ffmpeg.exe','-y','-v','error','-ss',3,'-i',FILM,'-frames:v','1','-f','image2',thumbnail])
font=ImageFont.truetype(str(ROOT/'public/fonts/PlusJakartaSans-Bold.ttf'),22)
small=ImageFont.truetype(str(ROOT/'public/fonts/PlusJakartaSans-Medium.ttf'),17)
sheet=Image.new('RGB',(1920,2080),'#F3EEDF');draw=ImageDraw.Draw(sheet)
draw.text((22,18),'RAYSTO / JUDGES PHASE 1 / 38 SECONDS / FINAL EXPORT REVIEW',font=font,fill='#173F35')
for i,f in enumerate(frames):
    x,y=(i%3)*640,65+(i//3)*400
    sheet.paste(Image.open(OUT/f'{f}.png').convert('RGB'),(x,y))
    draw.text((x+12,y+369),f'{f/30:05.1f}s  {labels[i]}',font=small,fill='#173F35')
contact=DIST/f'{PREFIX}-contact-sheet.jpg';sheet.save(contact,quality=93)
wav=OUT/'audio-check.wav'
run([BIN/'ffmpeg.exe','-y','-v','error','-i',FILM,'-vn','-c:a','pcm_s16le',wav])
with wave.open(str(wav),'rb') as audio:
    data=np.frombuffer(audio.readframes(audio.getnframes()),dtype=np.int16).astype(np.float64)/32768
peak=float(np.max(np.abs(data)))
assert 0<peak<.999
# A silent stream-copy is convenient when assembling the founder's own narration.
silent=DIST/f'{PREFIX}-silent.mp4'
run([BIN/'ffmpeg.exe','-y','-v','error','-i',FILM,'-map','0:v:0','-c:v','copy','-an','-movflags','+faststart',silent])
atoms=[]
with FILM.open('rb') as f:
    while True:
        head=f.read(8)
        if len(head)<8:break
        size=int.from_bytes(head[:4],'big');kind=head[4:].decode('ascii',errors='replace');extra=0
        if size==1:size=int.from_bytes(f.read(8),'big');extra=8
        atoms.append(kind)
        if size==0:break
        f.seek(size-8-extra,1)
manifest={
 'title':'Raysto — judge-facing project explanation',
 'date':'2026-10-27','composition':'RaystoJudges38',
 'video_seconds':float(v['duration']),'container_seconds':float(probe['format']['duration']),
 'frames':1140,'fps':30,'width':1920,'height':1080,
 'video_codec':v['codec_name'],'pixel_format':v['pix_fmt'],
 'audio_codec':a['codec_name'],'audio_sample_rate':a['sample_rate'],'audio_channels':a['channels'],
 'audio_peak_dbfs':round(20*math.log10(peak),2),
 'faststart':atoms.index('moov')<atoms.index('mdat'),
 'bytes':FILM.stat().st_size,'sampled_review_frames':frames,
 'assembly_offset_seconds':10,'assembled_segment_end_seconds':48,
 'audio':'Original music and synthesized effects; no voice-over. Timed narration supplied separately.',
 'provenance':'Original illustrative AI photo and motion artwork; historical QA widget/browser captures; actual Android emulator recording.',
 'payment_claim':'Exact-allocation and Sandbox approval explanation. No successful buyer capture depicted. Direct MCP verification is separate from conversational acceptance.',
 'reference':'Technique inspired by user-supplied Weepo video; no reference footage, script or music reused.',
 'verification':'TypeScript passed. Selected layouts and decoded master frames inspected; media properties and non-clipping audio checked.'
}
manifest_path=DIST/f'{PREFIX}-manifest.json'
manifest_path.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
files=[FILM,silent,thumbnail,contact,manifest_path]
(DIST/f'{PREFIX}-SHA256SUMS.txt').write_text(''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n' for p in files),encoding='utf-8')
print(json.dumps(manifest,indent=2,ensure_ascii=True))
