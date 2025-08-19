from __future__ import annotations

import json
import os
from typing import Dict, Any, List

from openai import OpenAI


def _get_client() -> OpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set")
    return OpenAI(api_key=api_key)


def generate_course_outline(language: str, cefr_levels: List[str], lessons_per_level: int) -> Dict[str, Any]:
    client = _get_client()
    system = (
        "You are a curriculum designer for a language learning app. "
        "Return compact JSON only."
    )
    user = (
        "Create a course outline for learning {language}. Levels: {levels}. "
        "For each level, include {n} lessons with fields lesson_id (kebab-case), title, and objective. "
        "Use CEFR labels and keep objectives concise."
    ).format(language=language, levels=", ".join(cefr_levels), n=lessons_per_level)

    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        response_format={"type": "json_object"},
        temperature=0.3,
    )

    content = resp.choices[0].message.content or "{}"
    data = json.loads(content)
    # Normalize expected structure
    return {
        "language": language,
        "levels": data.get("levels", []),
    }


def generate_lesson_script(language: str, cefr: str, title: str) -> Dict[str, Any]:
    client = _get_client()
    system = (
        "You are a lesson author for a language learning app. "
        "Return JSON only with a short, engaging lesson split into parts."
    )
    user = (
        "Create a single lesson for {language} at CEFR {cefr} titled '{title}'. "
        "Split into 4-6 parts: intro, vocab, dialog, practice, optional culture or review. "
        "Each part must have part_id (kebab-case), kind, title, script (spoken text), and optional phrases. "
        "Keep scripts natural-sounding and concise, avoid long paragraphs."
    ).format(language=language, cefr=cefr, title=title)

    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        response_format={"type": "json_object"},
        temperature=0.6,
    )

    content = resp.choices[0].message.content or "{}"
    data = json.loads(content)
    # Normalize expected structure
    return {
        "lesson_id": data.get("lesson_id") or title.lower().replace(" ", "-")[:60],
        "language": language,
        "cefr": cefr,
        "title": title,
        "objective": data.get("objective", ""),
        "parts": data.get("parts", []),
    }

