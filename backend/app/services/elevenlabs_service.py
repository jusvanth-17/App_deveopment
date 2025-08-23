import os
from typing import Optional
import httpx

from app.core.config import settings


class ElevenLabsService:
	BASE_URL = "https://api.elevenlabs.io/v1"

	def __init__(self) -> None:
		self.api_key = settings.elevenlabs_api_key or os.getenv("ELEVENLABS_API_KEY")

	def _get_headers(self, accept: str = "audio/mpeg") -> dict:
		if not self.api_key:
			raise RuntimeError("ELEVENLABS_API_KEY not configured")
		return {
			"xi-api-key": self.api_key,
			"accept": accept,
			"content-type": "application/json",
		}

	async def synthesize(
		self,
		text: str,
		*,
		voice_id: Optional[str] = None,
		model_id: Optional[str] = None,
		stability: float = 0.5,
		similarity_boost: float = 0.5,
		style: float = 0.0,
		use_speaker_boost: bool = True,
	) -> bytes:
		if not text or not text.strip():
			raise ValueError("text is required")
		voice = voice_id or settings.elevenlabs_default_voice_id
		if not voice:
			raise ValueError("voice_id is required")
		payload = {
			"text": text,
			"model_id": model_id or settings.elevenlabs_model_id,
			"voice_settings": {
				"stability": stability,
				"similarity_boost": similarity_boost,
				"style": style,
				"use_speaker_boost": use_speaker_boost,
			},
		}
		url = f"{self.BASE_URL}/text-to-speech/{voice}"
		headers = self._get_headers(accept="audio/mpeg")
		async with httpx.AsyncClient(timeout=60) as client:
			resp = await client.post(url, headers=headers, json=payload)
			resp.raise_for_status()
			return resp.content

	async def list_voices(self) -> dict:
		headers = self._get_headers(accept="application/json")
		url = f"{self.BASE_URL}/voices"
		async with httpx.AsyncClient(timeout=30) as client:
			resp = await client.get(url, headers=headers)
			resp.raise_for_status()
			return resp.json()