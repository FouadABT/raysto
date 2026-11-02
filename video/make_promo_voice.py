"""Voice-over for RaystoPromo60 with Kokoro (Apache-2.0), fully offline.

    ../.tooling/tts-venv/Scripts/python make_promo_voice.py [voice]

Reads src/promo/narration.json, writes one WAV per line to public/promo/voice/
and their lengths to src/promo/voice-timing.ts, which the composition uses
to place each scene. Model files live in ../.tooling/kokoro/ (not in git).
"""
import json, pathlib, sys
import soundfile as sf
from kokoro_onnx import Kokoro

here = pathlib.Path(__file__).parent
model = here.parent / '.tooling' / 'kokoro'
voice = sys.argv[1] if len(sys.argv) > 1 else 'af_heart'
lines = json.loads((here / 'src/promo/narration.json').read_text(encoding='utf-8'))
out = here / 'public/promo/voice'
out.mkdir(parents=True, exist_ok=True)
kokoro = Kokoro(str(model / 'kokoro-v1.0.onnx'), str(model / 'voices-v1.0.bin'))
timing = {}
for line in lines:
    samples, rate = kokoro.create(line['text'], voice=voice, speed=1.0, lang='en-us')
    sf.write(out / f"{line['id']}.wav", samples, rate)
    timing[line['id']] = round(len(samples) / rate, 3)
    print(line['id'], timing[line['id']], 's')
ts = [
    '// Written by make_promo_voice.py: seconds of speech per scene.',
    f'export const VOICE = {json.dumps(voice)};',
    f'export const SECONDS: Record<string, number> = {json.dumps(timing, indent=2)};',
]
(here / 'src/promo/voice-timing.ts').write_text('\n'.join(ts) + '\n')
print('total', round(sum(timing.values()), 2), 's')
