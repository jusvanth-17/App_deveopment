from typing import Any, Dict, List, Optional
from google.cloud.firestore_v1 import Client

from app.core.firebase import get_firestore_client


LESSONS_SUBCOLLECTION = "lessons"


def _collection(client: Client, user_id: str):
	return client.collection("users").document(user_id).collection(LESSONS_SUBCOLLECTION)


def create_lesson(user_id: str, lesson: Dict[str, Any]) -> str:
	client = get_firestore_client()
	doc_ref = _collection(client, user_id).document()
	doc_ref.set({"data": lesson})
	return doc_ref.id


def get_lesson(user_id: str, lesson_id: str) -> Optional[Dict[str, Any]]:
	client = get_firestore_client()
	doc = _collection(client, user_id).document(lesson_id).get()
	if not doc.exists:
		return None
	return {"id": doc.id, **doc.to_dict()}


def list_lessons(user_id: str) -> List[Dict[str, Any]]:
	client = get_firestore_client()
	docs = _collection(client, user_id).stream()
	return [{"id": d.id, **d.to_dict()} for d in docs]