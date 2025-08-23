import base64
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel

from app.api.deps.auth import get_current_user
from app.services.openai_service import OpenAIService
from app.services.elevenlabs_service import ElevenLabsService
from app.services.speech_service import SpeechService


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


@router.post("/voice-reply")
async def conversation_voice_reply(
	user=Depends(get_current_user),
	file: UploadFile = File(None),
	language_code: str = Form(default="en-US"),
	voice_id: str | None = Form(default=None),
):
	if file is None:
		raise HTTPException(status_code=400, detail="file is required")
	content = await file.read()
	if not content:
		raise HTTPException(status_code=400, detail="empty file")
	stt = SpeechService()
	openai = OpenAIService()
	tts = ElevenLabsService()
	try:
		user_text = stt.transcribe_linear16(content, language_code=language_code)
		messages = [
			{"role": "system", "content": "You are a helpful language tutor. Keep replies short."},
			{"role": "user", "content": user_text},
		]
		reply_text = await openai.chat_reply(messages)
		audio_bytes = await tts.synthesize(text=reply_text, voice_id=voice_id)
		audio_b64 = base64.b64encode(audio_bytes).decode("ascii")
		return {"user_text": user_text, "reply_text": reply_text, "audio_b64": audio_b64}
	except Exception:
		raise HTTPException(status_code=502, detail="Voice conversation provider error")