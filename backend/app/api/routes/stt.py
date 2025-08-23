from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, Form

from app.api.deps.auth import get_current_user
from app.services.speech_service import SpeechService

router = APIRouter(prefix="/stt", tags=["stt"])


@router.post("/transcribe")
async def transcribe_audio(
	user=Depends(get_current_user),
	file: UploadFile = File(None),
	language_code: str = Form(default="en-US"),
):
	if file is None:
		raise HTTPException(status_code=400, detail="file is required")
	content = await file.read()
	if not content:
		raise HTTPException(status_code=400, detail="empty file")
	try:
		service = SpeechService()
		transcript = service.transcribe_linear16(content, language_code=language_code)
		return {"transcript": transcript}
	except Exception:
		raise HTTPException(status_code=502, detail="STT provider error")