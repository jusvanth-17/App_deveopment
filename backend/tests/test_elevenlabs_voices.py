import pytest
from fastapi.testclient import TestClient

from app.main import app


def override_auth():
	return {"uid": "test-user"}


app.dependency_overrides = {}
from app.api.deps import auth as auth_deps
app.dependency_overrides[auth_deps.get_current_user] = override_auth


def test_voices_missing_api_key(monkeypatch):
	monkeypatch.delenv("ELEVENLABS_API_KEY", raising=False)
	client = TestClient(app)
	r = client.get("/api/tts/voices")
	assert r.status_code == 500
	assert "API_KEY" in r.json()["detail"] or r.json()["detail"]