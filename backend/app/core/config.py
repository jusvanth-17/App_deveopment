from functools import lru_cache
from pydantic import Field
from pydantic_settings import BaseSettings
from typing import List, Optional


class Settings(BaseSettings):
    environment: str = Field(default="development")

    # CORS
    allowed_origins: List[str] = Field(
        default_factory=lambda: [
            "http://localhost:3000",
            "http://localhost:5173",
            "http://127.0.0.1:3000",
            "http://127.0.0.1:5173",
            "*",
        ]
    )

    # Firebase / GCP
    firebase_project_id: Optional[str] = None
    google_application_credentials: Optional[str] = Field(
        default=None, description="Path to service account json"
    )
    gcp_credentials_base64: Optional[str] = Field(
        default=None, description="Base64 encoded service account JSON"
    )
    firebase_emulator_host: Optional[str] = None

    # Third-party services
    openai_api_key: Optional[str] = None
    stripe_api_key: Optional[str] = None
    elevenlabs_api_key: Optional[str] = None
    elevenlabs_default_voice_id: Optional[str] = Field(default=None)
    elevenlabs_model_id: str = Field(default="eleven_multilingual_v2")

    # Monitoring
    sentry_dsn: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()