from typing import Dict, List
import httpx
import os

from app.core.config import settings


class OpenAIService:
	def __init__(self) -> None:
		self.api_key = settings.openai_api_key or os.getenv("OPENAI_API_KEY")
		self.base_url = "https://api.openai.com/v1"

	async def generate_lesson(self, prompt: str, *, model: str = "gpt-4o-mini") -> Dict:
		if not self.api_key:
			raise RuntimeError("OPENAI_API_KEY not configured")
		headers = {"Authorization": f"Bearer {self.api_key}"}
		payload = {"model": model, "messages": [{"role": "user", "content": prompt}]}
		async with httpx.AsyncClient(timeout=60) as client:
			resp = await client.post(f"{self.base_url}/chat/completions", headers=headers, json=payload)
			resp.raise_for_status()
			return resp.json()