from typing import Dict, List
import httpx
import os
import json

from app.core.config import settings


class OpenAIService:
	def __init__(self) -> None:
		self.api_key = settings.openai_api_key or os.getenv("OPENAI_API_KEY")
		self.base_url = "https://api.openai.com/v1"

	async def generate_syllabus(self, target_language: str, goals: str | None = None) -> dict:
		if not target_language or not target_language.strip():
			raise ValueError("target_language is required")
		prompt = (
			"Create a compact learning syllabus as JSON with fields: topics (array of {id, title, objectives[], prerequisites[]}), "
			"levels (array of {level, description}), estimated_hours (number). Keep < 10 topics."
		)
		messages = [
			{"role": "system", "content": f"You are a language syllabus planner for {target_language}. Output JSON only."},
			{"role": "user", "content": f"Goals: {goals or 'general proficiency'}"},
		]
		content = await self.chat_reply(messages)
		try:
			return json.loads(content)
		except Exception:
			return {"raw": content}

	async def generate_lesson(self, topic_title: str, level: str | None = None) -> dict:
		if not topic_title or not topic_title.strip():
			raise ValueError("topic_title is required")
		prompt = (
			"Create a JSON lesson with fields: title, objectives[], vocabulary[{word,translation,example}], "
			"exercises[{type,prompt,answer,options?}], tips[]. Keep concise."
		)
		messages = [
			{"role": "system", "content": "You are a language tutor. Output JSON only."},
			{"role": "user", "content": f"Topic: {topic_title}. Level: {level or 'beginner'}."},
		]
		content = await self.chat_reply(messages)
		try:
			return json.loads(content)
		except Exception:
			return {"raw": content}

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