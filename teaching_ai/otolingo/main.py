import os
import re
import json
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel, Field
from dotenv import load_dotenv

# --- Load env ---
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "")
ELEVENLABS_DEFAULT_VOICE = os.getenv("ELEVENLABS_DEFAULT_VOICE", "")

# --- OpenAI client (SDK v1 style) ---
try:
    from openai import OpenAI  # pip install openai>=1.0.0
    _client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None
except Exception:
    _client = None

# --- HTTP fallback if SDK missing ---
import httpx

# --------- FastAPI app ---------
app = FastAPI(title="Language Lessons API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------- Models ---------
class SyllabusRequest(BaseModel):
    language: str

class LessonRequest(BaseModel):
    language: str
    topic: Optional[str] = Field(
        default=None,
        description="Optional topic focus, e.g. 'Greetings', 'Ordering food'"
    )
    difficulty: Optional[str] = Field(default="beginner", description="beginner | intermediate | advanced")
    minutes: int = Field(default=10, ge=5, le=20, description="Target lesson length in minutes")
    steps_min: int = Field(default=5, ge=3, le=10)
    steps_max: int = Field(default=7, ge=3, le=12)

class TTSRequest(BaseModel):
    text: str
    voice_id: Optional[str] = None
    stability: float = 0.7
    similarity_boost: float = 0.8

# --------- Helpers ---------
CODE_FENCE_RE = re.compile(r"^```[a-zA-Z0-9_-]*\n|```$", re.MULTILINE)

def _strip_code_fences(s: str) -> str:
    return CODE_FENCE_RE.sub("", s).strip()

def _openai_chat(messages: List[dict], model: str = "gpt-4o-mini", temperature: float = 0.7) -> str:
    """Call OpenAI chat completion and return content string. Uses SDK when available, else httpx."""
    if not OPENAI_API_KEY:
        raise HTTPException(status_code=500, detail="Missing OPENAI_API_KEY")

    if _client is not None:
        resp = _client.chat.completions.create(model=model, messages=messages, temperature=temperature)
        return resp.choices[0].message.content
    else:
        # HTTP fallback
        url = "https://api.openai.com/v1/chat/completions"
        headers = {"Authorization": f"Bearer {OPENAI_API_KEY}", "Content-Type": "application/json"}
        payload = {"model": model, "messages": messages, "temperature": temperature}
        with httpx.Client(timeout=60) as http:
            r = http.post(url, headers=headers, json=payload)
            if r.status_code != 200:
                raise HTTPException(status_code=502, detail=f"OpenAI error: {r.text}")
            data = r.json()
            return data["choices"][0]["message"]["content"]


def _parse_json_maybe(s: str) -> dict:
    """Try to coerce LLM output into JSON: strip fences, snip prose, and json.loads."""
    s2 = _strip_code_fences(s)
    # Attempt to grab first {...} block if extra text exists
    start = s2.find('{')
    end = s2.rfind('}')
    if start != -1 and end != -1 and end > start:
        s2 = s2[start:end+1]
    try:
        return json.loads(s2)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Invalid JSON from model: {e}\nRaw: {s[:500]}")

# --------- Routes ---------
@app.get("/")
async def root():
    return {
        "message": "Welcome to the Language Lessons API",
        "endpoints": {
            "POST /api/syllabus": "Generate a Markdown syllabus for a language",
            "POST /api/lesson": "Generate a ~10 minute JSON lesson for a language/topic",
            "POST /api/tts": "(optional) ElevenLabs TTS proxy"
        }
    }

@app.post("/api/syllabus")
async def generate_syllabus(req: SyllabusRequest):
    # Generate regular syllabus
    reg_messages = [
        {"role": "system", "content": "You are a professional curriculum designer."},
        {
            "role": "user",
            "content": (
                f"Generate a detailed language learning syllabus for {req.language}. "
                "Include 3 levels: Beginner, Intermediate, Advanced. "
                "For each level, provide 5–7 subtopics with: title, duration in hours, description. "
                "Format the response in Markdown only (no prose outside)."
            ),
        },
    ]
    regular_content = _openai_chat(reg_messages)
    
    # Generate elaborated syllabus
    elab_messages = [
        {"role": "system", "content": "You are a professional curriculum designer with expertise in creating comprehensive and detailed language learning materials."},
        {
            "role": "user",
            "content": (
                f"Generate a highly elaborated and comprehensive language learning syllabus for {req.language}. "
                "Include 3 levels: Beginner, Intermediate, Advanced. "
                "For each level, provide 5–7 subtopics with: title, duration in hours, description. "
                "For each subtopic, add extensive details including:"
                "1. Specific learning objectives"
                "2. Recommended learning resources"
                "3. Practice exercises and activities"
                "4. Assessment methods"
                "5. Cultural context and real-world applications"
                "Format the response in Markdown only (no prose outside). Use detailed formatting with headers, subheaders, bullet points, and numbered lists for maximum clarity."
            ),
        },
    ]
    elaborated_content = _openai_chat(elab_messages, temperature=0.8)
    
    return {
        "language": req.language, 
        "syllabus_markdown": regular_content, 
        "elaborated_syllabus_markdown": elaborated_content,
        "status": "success"
    }
    content = _openai_chat(messages)
    lesson = _parse_json_maybe(content)

    # Basic validation
    if "steps" not in lesson or not isinstance(lesson["steps"], list) or len(lesson["steps"]) == 0:
        raise HTTPException(status_code=502, detail="Model did not return steps[]")

    return {"lesson": lesson, "status": "success"}

@app.post("/api/tts")
async def elevenlabs_tts(req: TTSRequest):
    """Optional proxy to call ElevenLabs from Flutter without exposing the API key."""
    if not ELEVENLABS_API_KEY:
        raise HTTPException(status_code=400, detail="ELEVENLABS_API_KEY not configured on server")

    voice_id = req.voice_id or ELEVENLABS_DEFAULT_VOICE
    if not voice_id:
        raise HTTPException(status_code=400, detail="voice_id missing and ELEVENLABS_DEFAULT_VOICE not set")

    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": ELEVENLABS_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {
        "text": req.text,
        "voice_settings": {
            "stability": req.stability,
            "similarity_boost": req.similarity_boost,
        },
    }

    try:
        with httpx.Client(timeout=60) as http:
            r = http.post(url, headers=headers, json=payload)
            if r.status_code != 200:
                raise HTTPException(status_code=r.status_code, detail=r.text)
            # ElevenLabs returns audio/mpeg. We stream bytes back to client.
            return Response(content=r.content, media_type=r.headers.get("Content-Type", "audio/mpeg"))
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=f"TTS request failed: {e}")

# ------------- Optional: Firebase wrapper -------------
# If you deploy on Firebase Functions, you can wrap `app` using a framework adapter.
# Omitted here for clarity—this file is ready to run with Uvicorn locally or on any container.

# ------------- Main -------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)