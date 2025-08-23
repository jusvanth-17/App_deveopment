import base64
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.openai_service import OpenAIService
from app.services.elevenlabs_service import ElevenLabsService

router = APIRouter(prefix="/conversation", tags=["conversation"])


class ConversationPayload(BaseModel):
	user_text: str
	voice_id: str | None = None


@router.post("/reply")
async def conversation_reply(payload: ConversationPayload, user=Depends(get_current_user)):
	if not payload.user_text or not payload.user_text.strip():
		raise HTTPException(status_code=400, detail="user_text is required")
	openai = OpenAIService()
	tts = ElevenLabsService()
	try:
		messages = [
			{"role": "system", "content": "You are a helpful language tutor. Keep replies short."},
			{"role": "user", "content": payload.user_text},
		]
		reply_text = await openai.chat_reply(messages)
		audio_bytes = await tts.synthesize(text=reply_text, voice_id=payload.voice_id)
		audio_b64 = base64.b64encode(audio_bytes).decode("ascii")
		return {"reply_text": reply_text, "audio_b64": audio_b64}
	except ValueError as ve:
		raise HTTPException(status_code=400, detail=str(ve))
	except RuntimeError as re:
		raise HTTPException(status_code=500, detail=str(re))
	except Exception:
		raise HTTPException(status_code=502, detail="Conversation provider error")