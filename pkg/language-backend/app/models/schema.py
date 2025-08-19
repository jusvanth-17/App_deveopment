from __future__ import annotations

from typing import List, Optional, Literal, Dict, Any
from pydantic import BaseModel, Field


CEFR = Literal["A1", "A2", "B1", "B2", "C1", "C2"]


class OutlineLessonInfo(BaseModel):
    lesson_id: str
    title: str
    objective: str


class LevelOutline(BaseModel):
    cefr: CEFR
    label: str
    lessons: List[OutlineLessonInfo]


class CourseOutline(BaseModel):
    language: str
    levels: List[LevelOutline]


class LessonPart(BaseModel):
    part_id: str
    kind: Literal["intro", "vocab", "dialog", "practice", "culture", "review"]
    title: str
    script: str
    phrases: Optional[List[str]] = None
    estimated_duration_s: Optional[int] = None


class LessonScript(BaseModel):
    lesson_id: str
    language: str
    cefr: CEFR
    title: str
    objective: str
    parts: List[LessonPart]


class TTSAsset(BaseModel):
    part_id: str
    kind: str
    file_path: str
    bytes: Optional[int] = None


class GenerateCourseRequest(BaseModel):
    language: str = Field(..., description="Target language name, e.g. Spanish")
    cefr_levels: List[CEFR] = Field(default=["A1", "A2", "B1", "B2", "C1", "C2"])
    lessons_per_level: int = Field(default=10, ge=1, le=50)


class GenerateLessonRequest(BaseModel):
    language: str
    cefr: CEFR
    title: str
    voice_id: Optional[str] = None

