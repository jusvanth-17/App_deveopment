from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.openai_service import OpenAIService
from app.repos.syllabus_repo import create_syllabus

router = APIRouter(prefix="/syllabus", tags=["syllabus"])


class SyllabusPayload(BaseModel):
	target_language: str
	goals: str | None = None


@router.post("/generate")
async def generate_syllabus(payload: SyllabusPayload, user=Depends(get_current_user)):
	service = OpenAIService()
	try:
		data = await service.generate_syllabus(payload.target_language, payload.goals)
		syllabus_id = create_syllabus(user_id=user["uid"], syllabus=data)
		return {"id": syllabus_id, "data": data}
	except ValueError as ve:
		raise HTTPException(status_code=400, detail=str(ve))
	except RuntimeError as re:
		raise HTTPException(status_code=500, detail=str(re))
	except Exception:
		raise HTTPException(status_code=502, detail="Syllabus provider error")