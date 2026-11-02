"""Inspect the rendered film and create local review artifacts (Pillow/NumPy)."""
from pathlib import Path
import hashlib
import json
import math
import subprocess
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
DIST = ROOT.parent / 'dist'
OUT = ROOT / 'out' / 'challenge-final-review'
OUT.mkdir(parents=True, exist_ok=True)
BIN = ROOT / 'node_modules' / '@remotion' / 'compositor-win32-x64-msvc'
FILM = DIST / 'raysto-hackathon-demo-v2-1080p.mp4'
PREFIX = 'raysto-hackathon-demo-v2'

def run(args):
    return subprocess.run([str(x) for x in args], capture_output=True, check=True).stdout

probe = json.loads(run([BIN / 'ffprobe.exe', '-v', 'error', '-show_streams',
                        '-show_format', '-of', 'json', FILM]))
video = next(x for x in probe['streams'] if x['codec_type'] == 'video')
audio = next(x for x in probe['streams'] if x['codec_type'] == 'audio')
assert (video['width'], video['height']) == (1920, 1080)
assert video['r_frame_rate'] == '30/1'
assert video['codec_name'] == 'h264' and audio['codec_name'] == 'aac'
assert abs(float(probe['format']['duration']) - 78) < 0.1
assert int(video['nb_frames']) == 2340

frames = [70, 220, 440, 670, 850, 1040, 1250, 1500, 1650, 1740, 1920, 2000, 2130, 2270]
labels = ['Group decision', 'Shared visit', 'Native Android recording', 'Gemini tool sequence',
          'Host review / kitchen', 'Staff coordination', 'Manager assistant', 'Exact shares',
          'Native payment review', 'Real Sandbox handoff', 'Simulated payer A',
          'Simulated settlement', 'Direct MCP evidence', 'Closing proposition']
for frame in frames:
    run([BIN / 'ffmpeg.exe', '-y', '-v', 'error', '-ss', str(frame / 30), '-i', FILM,
         '-frames:v', '1', '-vf', 'scale=640:360', '-f', 'image2', OUT / f'{frame}.png'])

thumbnail = DIST / f'{PREFIX}-thumbnail.png'
run([BIN / 'ffmpeg.exe', '-y', '-v', 'error', '-ss', str(440 / 30), '-i', FILM,
     '-frames:v', '1', '-f', 'image2', thumbnail])
font = ImageFont.truetype(str(ROOT / 'public' / 'fonts' / 'PlusJakartaSans-Bold.ttf'), 22)
small = ImageFont.truetype(str(ROOT / 'public' / 'fonts' / 'PlusJakartaSans-Medium.ttf'), 17)
sheet = Image.new('RGB', (1920, 2080), '#F6F7F2')
draw = ImageDraw.Draw(sheet)
draw.text((22, 18), 'RAYSTO / HACKATHON DEMO V2 / 78 SECONDS / FINAL EXPORT REVIEW', font=font, fill='#173F35')
for index, frame in enumerate(frames):
    x, y = (index % 3) * 640, 65 + (index // 3) * 400
    sheet.paste(Image.open(OUT / f'{frame}.png').convert('RGB'), (x, y))
    draw.text((x + 12, y + 369), f'{frame / 30:05.1f}s  {labels[index]}', font=small, fill='#173F35')
contact = DIST / f'{PREFIX}-contact-sheet.jpg'
sheet.save(contact, quality=92)

wav = OUT / 'audio-check.wav'
run([BIN / 'ffmpeg.exe', '-y', '-v', 'error', '-i', FILM, '-vn', '-c:a', 'pcm_s16le', wav])
with wave.open(str(wav), 'rb') as source:
    samples = np.frombuffer(source.readframes(source.getnframes()), dtype=np.int16).astype(np.float64) / 32768
peak = float(np.max(np.abs(samples)))
assert peak > 0 and peak < 0.999

atoms = []
with FILM.open('rb') as f:
    while True:
        head = f.read(8)
        if len(head) < 8:
            break
        size, kind = int.from_bytes(head[:4], 'big'), head[4:].decode('ascii', errors='replace')
        extra = 0
        if size == 1:
            size, extra = int.from_bytes(f.read(8), 'big'), 8
        atoms.append(kind)
        if size == 0:
            break
        f.seek(size - 8 - extra, 1)
faststart = atoms.index('moov') < atoms.index('mdat')

manifest = {
    'title': 'Raysto — AI at the table, PayPal at checkout',
    'created': '2026-10-27',
    'composition': 'RaystoChallenge',
    'duration_seconds': float(probe['format']['duration']),
    'width': video['width'], 'height': video['height'], 'fps': 30,
    'frames': int(video['nb_frames']), 'video_codec': video['codec_name'],
    'pixel_format': video['pix_fmt'], 'audio_codec': audio['codec_name'],
    'audio_channels': audio['channels'], 'audio_sample_rate': audio['sample_rate'],
    'audio_peak_dbfs': round(20 * math.log10(peak), 2),
    'faststart': faststart,
    'size_bytes': FILM.stat().st_size,
    'reviewed_frames': frames,
    'source_notes': {
        'native_clip': 'Actual connected Android emulator recording; edited and accelerated.',
        'native_stills': 'Actual Flutter widgets with recorded QA data; review dialogs are explicitly labelled historical replay.',
        'dashboard': 'Earlier connected AG Grid / AG Studio browser captures.',
        'paypal_handoff': 'Genuine unapproved Sandbox checkout login screen; checkout cancelled after capture.',
        'settlement': 'User-authorized simulated payment outcome, clearly labelled; no funds captured.',
        'mcp': 'Earlier verified direct official MCP get_order read; complete Gemini-to-MCP chat acceptance remains pending.',
        'audio': 'Original synthesized score; no voice-over.'
    },
    'verification': 'Encoding and representative decoded frames inspected; audio non-silent and below clipping. No claim of completed real-payment acceptance.',
}
manifest_path = DIST / f'{PREFIX}-manifest.json'
manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
files = [FILM, thumbnail, contact, manifest_path]
checksums = ''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n' for p in files)
(DIST / f'{PREFIX}-SHA256SUMS.txt').write_text(checksums, encoding='utf-8')
print(json.dumps(manifest, indent=2, ensure_ascii=True))
