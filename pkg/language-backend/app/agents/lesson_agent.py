from __future__ import annotations

import os
from pathlib import Path
from typing import Dict, Any, Optional, List

from app.services.openai_client import generate_lesson_script
from app.services.tts_client import synthesize_to_file


def _lesson_dir(language: str, cefr: str, lesson_id: str) -> Path:
    return Path("data") / "courses" / language.lower() / cefr.upper() / lesson_id


def generate_full_lesson(language: str, cefr: str, title: str, voice_id: Optional[str]) -> Dict[str, Any]:
    script = generate_lesson_script(language, cefr, title)
    lesson_id = script["lesson_id"]
    base_dir = _lesson_dir(language, cefr, lesson_id)
    parts_dir = base_dir / "parts"
    parts_dir.mkdir(parents=True, exist_ok=True)

    assets: List[Dict[str, Any]] = []
    for part in script.get("parts", []):
        part_id = part.get("part_id") or part.get("title", "part").lower().replace(" ", "-")
        out_audio = parts_dir / f"{part_id}.mp3"
        path = synthesize_to_file(part.get("script", ""), out_audio, voice_id)
        size = path.stat().st_size if path.exists() else 0
        assets.append({
            "part_id": part_id,
            "kind": part.get("kind", "unknown"),
            "file_path": str(path),
            "bytes": size,
        })

    # Persist metadata
    (base_dir / "lesson.json").write_text(__import__("json").dumps(script, ensure_ascii=False, indent=2))
    (base_dir / "assets.json").write_text(__import__("json").dumps(assets, ensure_ascii=False, indent=2))

    return {
        "lesson": script,
        "assets": assets,
    }

