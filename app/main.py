from __future__ import annotations

import os
from typing import Dict, Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
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

# Enable CORS for Flutter/dev
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve generated assets (audio/text) under /assets
app.mount("/assets", StaticFiles(directory="data"), name="assets")


@app.get("/health")
def health() -> Dict[str, Any]:
    return {"status": "ok"}


@app.post("/generate-course")
def generate_course(req: GenerateCourseRequest):
    try:
        if not os.getenv("OPENAI_API_KEY"):
            raise HTTPException(status_code=400, detail="OPENAI_API_KEY missing")
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
        if not os.getenv("OPENAI_API_KEY"):
            raise HTTPException(status_code=400, detail="OPENAI_API_KEY missing")
        result = generate_full_lesson(
            language=req.language,
            cefr=req.cefr,
            title=req.title,
            voice_id=req.voice_id or os.getenv("DEFAULT_VOICE_ID"),
        )
        return JSONResponse(content=result)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/download/backend")
def download_backend() -> FileResponse:
    file_path = "/workspace/language-backend.tgz"
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="archive not found")
    return FileResponse(
        path=file_path,
        media_type="application/gzip",
        filename="language-backend.tgz",
    )


@app.get("/config")
def config():
    return {
        "openai_ready": bool(os.getenv("OPENAI_API_KEY")),
        "elevenlabs_ready": bool(os.getenv("ELEVENLABS_API_KEY")),
        "assets_base": "/assets",
        "languages": [
            "Spanish", "French", "German", "Italian", "Portuguese", "Japanese", "Korean", "Chinese"
        ],
        "cefr_levels": ["A1", "A2", "B1", "B2", "C1", "C2"],
    }

