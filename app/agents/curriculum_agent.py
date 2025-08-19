from __future__ import annotations

from typing import List, Dict, Any

from app.services.openai_client import generate_course_outline


def build_course_outline(language: str, cefr_levels: List[str], lessons_per_level: int) -> Dict[str, Any]:
    outline = generate_course_outline(language, cefr_levels, lessons_per_level)
    # Light validation/normalization
    outline["language"] = language
    for lvl in outline.get("levels", []):
        lvl.setdefault("cefr", lvl.get("label"))
        lvl.setdefault("label", lvl.get("cefr"))
        for lesson in lvl.get("lessons", []):
            if not lesson.get("lesson_id"):
                title = lesson.get("title", "lesson")
                lesson["lesson_id"] = title.lower().replace(" ", "-")[:60]
    return outline

