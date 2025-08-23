import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.api.deps import auth as auth_deps


def override_auth():
	return {"uid": "test-user"}


app.dependency_overrides = {}
app.dependency_overrides[auth_deps.get_current_user] = override_auth


def test_syllabus_missing_openai_key(monkeypatch):
	monkeypatch.delenv("OPENAI_API_KEY", raising=False)
	client = TestClient(app)
	r = client.post("/api/syllabus/generate", json={"target_language": "Spanish"})
	assert r.status_code == 500


def test_lessons_missing_topic(monkeypatch):
	monkeypatch.setenv("OPENAI_API_KEY", "dummy")
	client = TestClient(app)
	r = client.post("/api/lessons/generate", json={"topic_title": ""})
	assert r.status_code == 400