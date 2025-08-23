from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.openai_service import OpenAIService

router = APIRouter(prefix="/correct", tags=["correction"])


class CorrectionPayload(BaseModel):
	text: str
	target_language: str | None = None


@router.post("")
async def correct_text(payload: CorrectionPayload, user=Depends(get_current_user)):
	service = OpenAIService()
	try:
		result = await service.correct_text(payload.text, target_language=payload.target_language)
		return result
	except ValueError as ve:
		raise HTTPException(status_code=400, detail=str(ve))
	except RuntimeError as re:
		raise HTTPException(status_code=500, detail=str(re))
	except Exception:
		raise HTTPException(status_code=502, detail="Correction provider error")