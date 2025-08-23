from typing import List
from google.cloud import speech


class SpeechService:
	def __init__(self) -> None:
		self.client = speech.SpeechClient()

	def transcribe_linear16(self, audio_content: bytes, language_code: str = "en-US") -> str:
		config = speech.RecognitionConfig(
			encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
			language_code=language_code,
		)
		audio = speech.RecognitionAudio(content=audio_content)
		response = self.client.recognize(config=config, audio=audio)
		for result in response.results:
			return result.alternatives[0].transcript
		return ""