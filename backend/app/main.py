from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sentry_sdk

from app.core.config import settings
from app.core.firebase import ensure_firebase_initialized
from app.api.routes.health import router as health_router
from app.api.routes.users import router as users_router
from app.api.routes.tts import router as tts_router
from app.api.routes.stt import router as stt_router
from app.api.routes.correct import router as correct_router
from app.api.routes.conversation import router as conversation_router
from app.api.routes.web_demo import router as web_demo_router


def create_app() -> FastAPI:
    app = FastAPI(title="AI Language Tutor API", version="0.1.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    if settings.sentry_dsn:
        sentry_sdk.init(dsn=settings.sentry_dsn, traces_sample_rate=0.05)

    app.include_router(health_router, prefix="/api")
    app.include_router(users_router, prefix="/api")
    app.include_router(tts_router, prefix="/api")
    app.include_router(stt_router, prefix="/api")
    app.include_router(correct_router, prefix="/api")
    app.include_router(conversation_router, prefix="/api")
    app.include_router(web_demo_router)

    @app.on_event("startup")
    def on_startup() -> None:
        ensure_firebase_initialized()

    return app


app = create_app()