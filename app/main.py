from __future__ import annotations

import os
from typing import Dict, Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from dotenv import load_dotenv

from app.models.schema import (
    GenerateCourseRequest,
    GenerateLessonRequest,
)
from app.agents.curriculum_agent import build_course_outline
from app.agents.lesson_agent import generate_full_lesson


load_dotenv()

app = FastAPI(title="Language Learning Backend", version="0.1.0")


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"status": "ok"}


@app.post("/generate-course")
def generate_course(req: GenerateCourseRequest):
    try:
        outline = build_course_outline(
            language=req.language,
            cefr_levels=req.cefr_levels,
            lessons_per_level=req.lessons_per_level,
        )
        return JSONResponse(content=outline)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/generate-lesson")
def generate_lesson(req: GenerateLessonRequest):
    try:
        result = generate_full_lesson(
            language=req.language,
            cefr=req.cefr,
            title=req.title,
            voice_id=req.voice_id or os.getenv("DEFAULT_VOICE_ID"),
        )
        return JSONResponse(content=result)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

