## Language Learning Backend (OpenAI + ElevenLabs)

This FastAPI backend generates course outlines and lesson scripts with OpenAI, and optionally produces TTS audio for each lesson part via ElevenLabs.

### Setup
- Python 3.10+
- Set environment variables in a `.env` file at the repo root:
```
OPENAI_API_KEY=sk-...
ELEVENLABS_API_KEY=xi-...
DEFAULT_VOICE_ID=<your-elevenlabs-voice-id>
``` 

### Install
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

### Run
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

OpenAPI docs: `http://localhost:8000/docs`

### Notes
- If `ELEVENLABS_API_KEY` or `voice_id` is missing, TTS will be skipped and a `.txt` placeholder will be written instead of audio.
- Generated assets are saved under `data/courses/<language>/<cefr>/<lesson_id>/parts/`.
