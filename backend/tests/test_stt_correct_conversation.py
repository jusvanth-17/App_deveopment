import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.api.deps import auth as auth_deps


def override_auth():
	return {"uid": "test-user"}


app.dependency_overrides = {}
app.dependency_overrides[auth_deps.get_current_user] = override_auth


def test_stt_missing_file():
	client = TestClient(app)
	r = client.post("/api/stt/transcribe")
	assert r.status_code == 400
	assert "file" in r.json()["detail"]


def test_correct_empty_text(monkeypatch):
	monkeypatch.delenv("OPENAI_API_KEY", raising=False)
	client = TestClient(app)
	r = client.post("/api/correct", json={"text": ""})
	assert r.status_code == 400


def test_conversation_missing_openai_key(monkeypatch):
	monkeypatch.delenv("OPENAI_API_KEY", raising=False)
	client = TestClient(app)
	r = client.post("/api/conversation/reply", json={"user_text": "Hi"})
	assert r.status_code == 500
	assert "OPENAI" in r.json()["detail"] or r.json()["detail"]