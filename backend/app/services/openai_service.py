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

	async def chat_reply(self, messages: list[dict], *, model: str = "gpt-4o-mini") -> str:
		if not self.api_key:
			raise RuntimeError("OPENAI_API_KEY not configured")
		headers = {"Authorization": f"Bearer {self.api_key}"}
		payload = {"model": model, "messages": messages}
		async with httpx.AsyncClient(timeout=60) as client:
			resp = await client.post(f"{self.base_url}/chat/completions", headers=headers, json=payload)
			resp.raise_for_status()
			data = resp.json()
			return data["choices"][0]["message"]["content"]

	async def correct_text(self, text: str, target_language: str | None = None) -> dict:
		if not text or not text.strip():
			raise ValueError("text is required")
		instruction = "You are a language tutor. Correct grammar and provide a short explanation."
		if target_language:
			instruction += f" Respond in {target_language}."
		messages = [
			{"role": "system", "content": instruction},
			{"role": "user", "content": text},
		]
		content = await self.chat_reply(messages)
		return {"corrected_text": content}