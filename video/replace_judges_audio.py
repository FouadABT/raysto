"""Synchronize licensed stock recordings to RaystoJudges38; preserve video packets.

Requires NumPy and the FFmpeg/FFprobe bundled with Remotion. Stock source files
and the synchronized audio intermediate are local, ignored build inputs, not
redistributable repository assets. Only the completed film is a delivery asset.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import subprocess
import urllib.request
import wave
from datetime import datetime, timezone
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / "out" / "licensed-audio"
BIN = ROOT / "node_modules" / "@remotion" / "compositor-win32-x64-msvc"
FFMPEG = BIN / "ffmpeg.exe"
FFPROBE = BIN / "ffprobe.exe"
DIST = ROOT.parent / "dist"
INPUT = DIST / "raysto-judges-phase1-38s-silent.mp4"
OUTPUT = DIST / "raysto-judges-phase1-38s-pro-audio-1080p.mp4"
SCORE = ROOT / "public" / "judges" / "licensed-score.m4a"
RATE = 48000
DURATION = 38
ASSETS = [
    {
        "title": "Gimme that Groove!",
        "artist": "Michael Ramir C.",
        "file": "gimme-that-groove-872.mp3",
        "url": "https://assets.mixkit.co/music/872/872.mp3",
        "page": "https://mixkit.co/free-stock-music/",
        "download_page": "https://mixkit.co/free-stock-music/download/872/",
        "license": "https://mixkit.co/license/modal/musicFree/",
    },
    {
        "title": "Paper slide",
        "artist": "Mixkit stock sound effects",
        "file": "paper-slide-1530.wav",
        "url": "https://assets.mixkit.co/active_storage/sfx/1530/1530.wav",
        "page": "https://mixkit.co/free-sound-effects/paper/",
        "download_page": "https://mixkit.co/free-sound-effects/download/1530/",
        "license": "https://mixkit.co/license/modal/sfxFree/",
    },
    {
        "title": "Page turn single",
        "artist": "Mixkit stock sound effects",
        "file": "page-turn-single-1104.wav",
        "url": "https://assets.mixkit.co/active_storage/sfx/1104/1104.wav",
        "page": "https://mixkit.co/free-sound-effects/paper/",
        "download_page": "https://mixkit.co/free-sound-effects/download/1104/",
        "license": "https://mixkit.co/license/modal/sfxFree/",
    },
]


def ffmpeg(*args: object) -> subprocess.CompletedProcess:
    result = subprocess.run(
        [str(FFMPEG), "-hide_banner", "-nostdin", "-y", *map(str, args)],
        capture_output=True,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.decode("utf-8", errors="replace"))
    return result


def decode(path: Path, duration: float | None = None, headroom: bool = False) -> np.ndarray:
    args: list[object] = ["-v", "error", "-i", path]
    if duration is not None:
        args += ["-t", duration]
    if headroom:
        # Avoid clipping a mastered MP3's intersample overshoot during PCM decode.
        args += ["-af", "volume=0.5"]
    raw = ffmpeg(*args, "-vn", "-ar", RATE, "-ac", 2,
                 "-c:a", "pcm_s16le", "-f", "wav", "pipe:1").stdout
    with wave.open(io.BytesIO(raw), "rb") as wav:
        pcm = wav.readframes(wav.getnframes())
    return np.frombuffer(pcm, dtype="<i2").reshape(-1, 2).astype(np.float32) / 32768


def write_wav(path: Path, samples: np.ndarray) -> None:
    assert np.max(np.abs(samples)) < 1, "Clipping in synchronized audio"
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        wav.writeframes((samples * 32767).astype("<i2").tobytes())


def measure(path: Path) -> dict:
    result = ffmpeg("-i", path, "-vn", "-af",
                    "loudnorm=I=-19:TP=-1.5:LRA=8:print_format=json",
                    "-f", "null", "-")
    log = result.stderr.decode("utf-8", errors="replace")
    return json.loads(log[log.rfind("{"):log.rfind("}") + 1])


def probe(path: Path) -> dict:
    result = subprocess.run(
        [str(FFPROBE), "-v", "error", "-show_entries",
         "format=duration,size:stream=codec_name,codec_type,width,height,r_frame_rate,nb_frames,duration,sample_rate,channels",
         "-of", "json", str(path)],
        check=True, capture_output=True,
    )
    return json.loads(result.stdout)


def video_hash(path: Path) -> str:
    # Decode-free comparison: same encoded picture stream before and after mux.
    raw = ffmpeg("-v", "error", "-i", path, "-map", "0:v:0", "-c:v", "copy",
                 "-an", "-f", "h264", "pipe:1").stdout
    return hashlib.sha256(raw).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--download", action="store_true",
                        help="Fetch the three licensed inputs if absent; no library scraping")
    parser.add_argument("--prepare-only", action="store_true",
                        help="Prepare the licensed input for a fresh Remotion render; skip mux")
    args = parser.parse_args()
    CACHE.mkdir(parents=True, exist_ok=True)
    for asset in ASSETS:
        target = CACHE / asset["file"]
        if not target.exists() and args.download:
            urllib.request.urlretrieve(asset["url"], target)
        if not target.exists():
            raise FileNotFoundError(f"Missing {target}; review AUDIO-LICENSES.md and use --download")

    music = decode(CACHE / ASSETS[0]["file"], DURATION, headroom=True)
    assert len(music) == RATE * DURATION
    # A contiguous excerpt preserves the musician's arrangement and tempo.
    music[:int(.12 * RATE)] *= np.linspace(0, 1, int(.12 * RATE))[:, None]
    music[-int(.85 * RATE):] *= np.linspace(1, 0, int(.85 * RATE))[:, None]
    music_wav = CACHE / "music-excerpt.wav"
    write_wav(music_wav, music)
    music_level = measure(music_wav)
    music *= 10 ** ((-19.0 - float(music_level["input_i"])) / 20)

    cues = [
        {"at": 4.84, "file": ASSETS[1]["file"], "peak_dbfs": -23.0},
        {"at": 18.31, "file": ASSETS[2]["file"], "peak_dbfs": -24.0},
        {"at": 33.82, "file": ASSETS[1]["file"], "peak_dbfs": -24.0},
    ]
    mix = music.copy()
    for cue in cues:
        sound = decode(CACHE / str(cue["file"]), headroom=True)
        # Remove leading/trailing near-silence, retaining the recorded movement.
        active = np.flatnonzero(np.max(np.abs(sound), axis=1) > .001)
        if not len(active):
            raise ValueError("Empty sound effect")
        sound = sound[max(0, active[0] - 480):min(len(sound), active[-1] + 1200)]
        sound *= 10 ** (float(cue["peak_dbfs"]) / 20) / np.max(np.abs(sound))
        fade = min(240, len(sound) // 4)
        sound[:fade] *= np.linspace(0, 1, fade)[:, None]
        sound[-fade:] *= np.linspace(1, 0, fade)[:, None]
        start = round(float(cue["at"]) * RATE)
        stop = min(len(mix), start + len(sound))
        mix[start:stop] += sound[:stop - start]

    mix_wav = CACHE / "synchronized-film-audio.wav"
    write_wav(mix_wav, mix)
    levels = measure(mix_wav)
    normalize = (
        "loudnorm=I=-19:TP=-1.5:LRA=8:linear=true:"
        f"measured_I={levels['input_i']}:measured_TP={levels['input_tp']}:"
        f"measured_LRA={levels['input_lra']}:measured_thresh={levels['input_thresh']}:"
        f"offset={levels['target_offset']}"
    )
    ffmpeg("-v", "error", "-i", mix_wav, "-af", normalize, "-ar", RATE,
           "-ac", 2, "-c:a", "aac", "-b:a", "256k", "-f", "mp4", SCORE)
    if args.prepare_only:
        print(json.dumps({"prepared": str(SCORE)}))
        return
    # Stream-copy both encoded tracks; never re-encode the original pictures.
    ffmpeg("-v", "error", "-i", INPUT, "-i", SCORE, "-map", "0:v:0",
           "-map", "1:a:0", "-c", "copy", "-t", DURATION,
           "-movflags", "+faststart", OUTPUT)
    info = probe(OUTPUT)
    picture = next(s for s in info["streams"] if s["codec_type"] == "video")
    assert (picture["width"], picture["height"]) == (1920, 1080)
    assert picture["nb_frames"] == "1140"
    assert picture["r_frame_rate"] == "30/1"
    assert float(picture["duration"]) == 38
    before_hash, after_hash = video_hash(INPUT), video_hash(OUTPUT)
    assert before_hash == after_hash, "Picture stream changed"
    final_pcm = decode(OUTPUT)
    peak = float(20 * np.log10(np.max(np.abs(final_pcm))))
    assert peak < -1, "Encoded audio has insufficient peak headroom"
    manifest = {
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "output": OUTPUT.name,
        "sha256": hashlib.sha256(OUTPUT.read_bytes()).hexdigest(),
        "media": info,
        "video_stream_unchanged": True,
        "video_stream_sha256": after_hash,
        "audio": {"music_excerpt_seconds": [0, 38], "sfx_cues": cues,
                  "sample_peak_dbfs": round(peak, 2), "loudness": measure(OUTPUT),
                  "voice_over": False, "synthesized_audio": False},
        "sources": [{**a, "sha256": hashlib.sha256((CACHE / a["file"]).read_bytes()).hexdigest()}
                    for a in ASSETS],
    }
    OUTPUT.with_suffix(".json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    OUTPUT.with_suffix(".sha256").write_text(f"{manifest['sha256']}  {OUTPUT.name}\n", encoding="utf-8")
    print(json.dumps({"output": str(OUTPUT), "visuals_unchanged": True,
                      "sample_peak_dbfs": round(peak, 2),
                      "loudness_lufs": manifest["audio"]["loudness"]["input_i"],
                      "frames": picture["nb_frames"], "duration": picture["duration"]}))


if __name__ == "__main__":
    main()
