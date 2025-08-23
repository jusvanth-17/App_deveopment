import base64
import json
import os
from functools import lru_cache
from typing import Any, Dict

import firebase_admin
from firebase_admin import auth as firebase_auth
from firebase_admin import credentials, firestore

from app.core.config import settings


@lru_cache
def ensure_firebase_initialized() -> firebase_admin.App:
    if firebase_admin._apps:
        return firebase_admin.get_app()

    cred_obj = None

    if settings.gcp_credentials_base64:
        decoded = base64.b64decode(settings.gcp_credentials_base64)
        service_account_info = json.loads(decoded)
        cred_obj = credentials.Certificate(service_account_info)
    elif settings.google_application_credentials and os.path.exists(
        settings.google_application_credentials
    ):
        cred_obj = credentials.Certificate(settings.google_application_credentials)
    else:
        # Fallback to application default credentials if available
        try:
            cred_obj = credentials.ApplicationDefault()
        except Exception:
            pass

    app = firebase_admin.initialize_app(cred_obj) if cred_obj else firebase_admin.initialize_app()

    # Firestore emulator support
    if settings.firebase_emulator_host:
        os.environ.setdefault("FIRESTORE_EMULATOR_HOST", settings.firebase_emulator_host)

    return app


def get_firestore_client() -> firestore.Client:
    ensure_firebase_initialized()
    return firestore.client()


def verify_id_token(id_token: str) -> Dict[str, Any]:
    ensure_firebase_initialized()
    return firebase_auth.verify_id_token(id_token)