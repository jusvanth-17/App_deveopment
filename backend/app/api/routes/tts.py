from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.elevenlabs_service import ElevenLabsService


class TTSPayload(BaseModel):
	text: str
	voice_id: str | None = None
	model_id: str | None = None
	stability: float = 0.5
	similarity_boost: float = 0.5
	style: float = 0.0
	use_speaker_boost: bool = True


router = APIRouter(prefix="/tts", tags=["tts"])


@router.post("/synthesize")
async def synthesize_tts(payload: TTSPayload, user=Depends(get_current_user)):
	service = ElevenLabsService()
	try:
		audio_bytes = await service.synthesize(
			text=payload.text,
			voice_id=payload.voice_id,
			model_id=payload.model_id,
			stability=payload.stability,
			similarity_boost=payload.similarity_boost,
			style=payload.style,
			use_speaker_boost=payload.use_speaker_boost,
		)
		return StreamingResponse(iter([audio_bytes]), media_type="audio/mpeg")
	except ValueError as ve:
		raise HTTPException(status_code=400, detail=str(ve))
	except RuntimeError as re:
		raise HTTPException(status_code=500, detail=str(re))
	except Exception:
		raise HTTPException(status_code=502, detail="TTS provider error")