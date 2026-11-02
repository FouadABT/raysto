# Judge-facing film: licensed audio revision

Applies only to `RaystoJudges38`, exported as
`../dist/raysto-judges-phase1-38s-pro-audio-1080p.mp4` on 27 October 2026.
The earlier synthesized soundtrack remains in the original export for reference.

## Sources

| Recording | Creator / provider | Official download page | License |
| --- | --- | --- | --- |
| Gimme that Groove! — music, item 872 | Michael Ramir C. / Mixkit | [Track download](https://mixkit.co/free-stock-music/download/872/) · [Catalogue](https://mixkit.co/free-stock-music/) | [Mixkit Stock Music Free License](https://mixkit.co/license/modal/musicFree/) |
| Paper slide — effect, item 1530 | Mixkit | [Effect download](https://mixkit.co/free-sound-effects/download/1530/) · [Paper effects](https://mixkit.co/free-sound-effects/paper/) | [Mixkit Sound Effects Free License](https://mixkit.co/license/modal/sfxFree/) |
| Page turn single — effect, item 1104 | Mixkit | [Effect download](https://mixkit.co/free-sound-effects/download/1104/) | [Mixkit Sound Effects Free License](https://mixkit.co/license/modal/sfxFree/) |

These licenses allow synchronization in this completed YouTube video. The recordings
remain third-party copyrighted material, separate from the repository's source
license. Do not redistribute the raw recordings or audio intermediate with source
files, as stock, or as a standalone music release. Do not register them with Content
ID. Review the [Mixkit User Terms](https://mixkit.co/terms/) for other uses.

Local license-page and terms snapshots are in `out/licensed-audio/`. The export's
adjacent JSON manifest records source URLs and SHA-256 hashes. Raw downloads and
the synchronized audio intermediate are ignored by Git; only the completed video
is intended for delivery. No reference-video music was reused.

Suggested YouTube credit:

> Music: “Gimme that Groove!” by Michael Ramir C., via Mixkit.
> Paper sound effects: Mixkit. Used under the Mixkit free licenses.
> https://mixkit.co/

## Editorial treatment

- One continuous 38-second excerpt, no tempo changes or synthetic percussion.
- A 120 ms opening fade and 850 ms ending fade for assembly with the next phase.
- Three recorded paper cues at 4.84, 18.31 and 33.82 seconds, kept below the music's peaks.
- No repeated UI clicks, payment-success chimes or artificial impact sounds.
- No voice-over; use `JUDGES-NARRATION.txt` when recording the founder's narration.
- Measured finished mix: -19.05 LUFS integrated, -3.28 dBTP true peak;
  AAC stereo, 48 kHz. Lower the bed as necessary when adding recorded speech.

## Reproduce

With Remotion dependencies and Python/NumPy available, run from `video/`:

```sh
python replace_judges_audio.py --download
```

This fetches only the three selected recordings if absent, creates the local
`public/judges/licensed-score.m4a` input, and muxes it into the existing silent
38-second master. It checks duration, frame count, audio peaks and matching H.264
stream hashes. It keeps the original MP4 and writes a new MP4, JSON manifest and
checksum. The source composition also uses this licensed input for future renders.
The original silent master must exist before running the mux step. For a clean
checkout without that master, add `--prepare-only` and then render the composition.

Verification covers encoding, timing, level measurements and unchanged pictures;
it does not replace listening on the final playback system after narration is added.
