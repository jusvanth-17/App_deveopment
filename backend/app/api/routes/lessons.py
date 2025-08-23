from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.openai_service import OpenAIService
from app.repos.lessons_repo import create_lesson

router = APIRouter(prefix="/lessons", tags=["lessons"])


class LessonPayload(BaseModel):
	topic_title: str
	level: str | None = None


@router.post("/generate")
async def generate_lesson(payload: LessonPayload, user=Depends(get_current_user)):
	service = OpenAIService()
	try:
		data = await service.generate_lesson(payload.topic_title, payload.level)
		lesson_id = create_lesson(user_id=user["uid"], lesson=data)
		return {"id": lesson_id, "data": data}
	except ValueError as ve:
		raise HTTPException(status_code=400, detail=str(ve))
	except RuntimeError as re:
		raise HTTPException(status_code=500, detail=str(re))
	except Exception:
		raise HTTPException(status_code=502, detail="Lesson provider error")