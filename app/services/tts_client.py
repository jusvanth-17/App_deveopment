from __future__ import annotations

import os
from pathlib import Path
from typing import Optional

from elevenlabs.client import ElevenLabs


def _get_client() -> Optional[ElevenLabs]:
    api_key = os.getenv("ELEVENLABS_API_KEY")
    if not api_key:
        return None
    return ElevenLabs(api_key=api_key)


def synthesize_to_file(text: str, out_path: Path, voice_id: Optional[str]) -> Path:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    client = _get_client()
    if not client or not voice_id:
        # Fallback: write text placeholder if TTS not configured
        out_path.with_suffix(".txt").write_text(text)
        return out_path.with_suffix(".txt")

    audio = client.text_to_speech.convert(
        voice_id=voice_id,
        model_id="eleven_turbo_v2",
        text=text,
        output_format="mp3_44100_128",
    )

    with open(out_path, "wb") as f:
        for chunk in audio:
            if chunk:
                f.write(chunk)
    return out_path

