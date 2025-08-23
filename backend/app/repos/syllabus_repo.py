from typing import Any, Dict, List, Optional
from google.cloud.firestore_v1 import Client

from app.core.firebase import get_firestore_client


SYLLABI_SUBCOLLECTION = "syllabi"


def _collection(client: Client, user_id: str):
	return client.collection("users").document(user_id).collection(SYLLABI_SUBCOLLECTION)


def create_syllabus(user_id: str, syllabus: Dict[str, Any]) -> str:
	client = get_firestore_client()
	doc_ref = _collection(client, user_id).document()
	doc_ref.set({"data": syllabus})
	return doc_ref.id


def get_syllabus(user_id: str, syllabus_id: str) -> Optional[Dict[str, Any]]:
	client = get_firestore_client()
	doc = _collection(client, user_id).document(syllabus_id).get()
	if not doc.exists:
		return None
	return {"id": doc.id, **doc.to_dict()}


def list_syllabi(user_id: str) -> List[Dict[str, Any]]:
	client = get_firestore_client()
	docs = _collection(client, user_id).stream()
	return [{"id": d.id, **d.to_dict()} for d in docs]