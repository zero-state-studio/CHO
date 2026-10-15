"""Post-produzione dell'audio generato (versi, effetti, musica) per Godot.

Uso: tools/.venv/bin/python tools/elevenlabs/convert_audio.py

Legge i file grezzi in source_assets/ai_raw/elevenlabs/ e scrive in assets/audio/:
- versi ed effetti: WAV mono 16 bit, silenzio iniziale e finale tolto, picco a -1 dBFS,
  breve dissolvenza in uscita;
- musica: OGG Vorbis stereo, picco a -1 dBFS, fine e inizio sovrapposti con una
  dissolvenza incrociata, così il brano si ripete senza stacco.
Stampa durata e picco di ogni file.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
import soundfile as sf

ROOT: Path = Path(__file__).resolve().parents[2]
RAW: Path = ROOT / "source_assets" / "ai_raw" / "elevenlabs"
OUT: Path = ROOT / "assets" / "audio"

PEAK_DBFS: float = -1.0
SILENCE_DBFS: float = -45.0
FADE_OUT_SECONDS: float = 0.015
LOOP_CROSSFADE_SECONDS: float = 2.0

# file grezzo (prefisso, prima di "_asset_") -> file pulito
VOICES: dict[str, str] = {
    "junior_greeting": "voices/vox_junior_greeting.wav",
    "junior_annoyed": "voices/vox_junior_annoyed.wav",
    "junior_cheer": "voices/vox_junior_cheer.wav",
    "manager_greeting": "voices/vox_manager_greeting.wav",
    "manager_annoyed": "voices/vox_manager_annoyed.wav",
    "manager_cheer": "voices/vox_manager_cheer.wav",
}
EFFECTS: dict[str, str] = {
    "footsteps_rubber": "sfx/sfx_footsteps_rubber.wav",
    "click": "sfx/sfx_click.wav",
    "printer": "sfx/sfx_printer.wav",
    "coffee": "sfx/sfx_coffee.wav",
    "rubber_bump": "sfx/sfx_rubber_bump.wav",
    "paper_ball": "sfx/sfx_paper_ball.wav",
    "microwave_ding": "sfx/sfx_microwave_ding.wav",
    "email_notification": "sfx/sfx_email_notification.wav",
    "bell_1800": "sfx/sfx_bell_1800.wav",
    "collapse": "sfx/sfx_collapse.wav",
}
MUSIC: dict[str, str] = {
    "hold_loop": "music/mus_hold_loop.ogg",
}


def find_raw(folder: str, prefix: str) -> Path:
    matches = sorted((RAW / folder).glob(f"{prefix}_asset_*"))
    if len(matches) != 1:
        raise SystemExit(f"Atteso un solo file grezzo per {prefix} in {folder}, trovati {len(matches)}")
    return matches[0]


def to_mono(data: np.ndarray) -> np.ndarray:
    return data.mean(axis=1) if data.ndim == 2 else data


def normalize(data: np.ndarray) -> np.ndarray:
    peak = float(np.max(np.abs(data))) if data.size else 0.0
    if peak <= 0.0:
        return data
    return data * (10 ** (PEAK_DBFS / 20) / peak)


def trim_silence(data: np.ndarray, rate: int) -> np.ndarray:
    level = np.abs(data if data.ndim == 1 else data.max(axis=1))
    threshold = 10 ** (SILENCE_DBFS / 20) * max(float(level.max()), 1e-9)
    loud = np.nonzero(level > threshold)[0]
    if loud.size == 0:
        return data
    margin = int(0.01 * rate)
    return data[max(loud[0] - margin, 0): min(loud[-1] + margin, len(data))]


def fade_out(data: np.ndarray, rate: int) -> np.ndarray:
    count = min(int(FADE_OUT_SECONDS * rate), len(data))
    ramp = np.linspace(1.0, 0.0, count)
    data = data.copy()
    data[-count:] *= ramp if data.ndim == 1 else ramp[:, None]
    return data


def make_loop(data: np.ndarray, rate: int) -> np.ndarray:
    """La coda sfuma dentro l'inizio: il file finisce dove ricomincia."""
    count = int(LOOP_CROSSFADE_SECONDS * rate)
    if len(data) <= count * 2:
        return data
    ramp = np.linspace(0.0, 1.0, count)[:, None] if data.ndim == 2 else np.linspace(0.0, 1.0, count)
    head = data[:count] * ramp + data[-count:] * (1.0 - ramp)
    return np.concatenate([head, data[count:-count]])


def report(path: Path, data: np.ndarray, rate: int) -> None:
    peak = 20 * np.log10(max(float(np.max(np.abs(data))), 1e-9))
    print(f"{path.relative_to(ROOT)}: {len(data) / rate:5.2f} s, picco {peak:5.1f} dBFS")


def convert_short(folder: str, mapping: dict[str, str]) -> None:
    for prefix, target in mapping.items():
        data, rate = sf.read(find_raw(folder, prefix), dtype="float64")
        data = fade_out(normalize(trim_silence(to_mono(data), rate)), rate)
        out = OUT / target
        out.parent.mkdir(parents=True, exist_ok=True)
        sf.write(out, data, rate, subtype="PCM_16")
        report(out, data, rate)


def convert_music() -> None:
    for prefix, target in MUSIC.items():
        data, rate = sf.read(find_raw("sprint1-musica", prefix), dtype="float64")
        data = normalize(make_loop(data, rate))
        out = OUT / target
        out.parent.mkdir(parents=True, exist_ok=True)
        sf.write(out, data, rate, format="OGG", subtype="VORBIS")
        report(out, data, rate)


if __name__ == "__main__":
    convert_short("sprint1-versi", VOICES)
    convert_short("sprint1-effetti", EFFECTS)
    convert_music()
