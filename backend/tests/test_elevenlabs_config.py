import os
import pytest

from app.services.elevenlabs_service import ElevenLabsService
from tests.utils import run


def test_elevenlabs_missing_api_key(monkeypatch):
	monkeypatch.delenv("ELEVENLABS_API_KEY", raising=False)
	service = ElevenLabsService()
	with pytest.raises(RuntimeError):
		# This will raise because API key missing
		service._get_headers()


def test_elevenlabs_missing_voice_id(monkeypatch):
	monkeypatch.setenv("ELEVENLABS_API_KEY", "dummy")
	service = ElevenLabsService()
	with pytest.raises(ValueError):
		run(service.synthesize(text="hello", voice_id=None))