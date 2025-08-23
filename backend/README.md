## AI Language Tutor - Backend (FastAPI)

A production-ready FastAPI backend for an AI-powered language tutor. It supports syllabus and lesson generation (OpenAI), text correction, text-to-speech (ElevenLabs), speech-to-text (Google STT), and 1:1 conversation (voice or text). Works with web, Flutter, and native clients via standard HTTP/JSON.

### Key Features
- Firebase Auth verification (Bearer ID tokens)
- AI syllabus and lesson generation (OpenAI)
- Text correction with brief explanations (OpenAI)
- Text-to-Speech synthesis and voices (ElevenLabs)
- Speech-to-Text transcription (Google Speech-to-Text)
- Conversation: text reply + audio, and voice 1:1 (upload) flows
- Firestore storage for user syllabi and lessons
- Web demo at `/`, OpenAPI docs at `/docs`

---

## 1) Prerequisites
- Python 3.13+ and pip
- A Firebase project with billing enabled
- Google Cloud Speech-to-Text API enabled in the same GCP project
- OpenAI API key
- ElevenLabs API key and at least one Voice ID
- (Optional) Docker, GitHub Actions for CI

---

## 2) Firebase & Google Cloud Setup

### 2.1 Create Firebase Project
1. Go to `https://console.firebase.google.com` and create a project (enable billing).
2. Enable the following:
   - Firestore (Native mode)
   - Authentication (Email/Password or other providers you need)
   - Storage (optional, for storing audio later)

### 2.2 Service Account Credentials
You need a Google service account with access to Firestore and (optionally) Storage.
1. Go to `https://console.cloud.google.com/iam-admin/serviceaccounts` (select the same project).
2. Create a service account (e.g., `backend-sa`).
3. Grant roles:
   - Firestore User (or Firestore Owner for dev)
   - Viewer (minimum)
   - (Optional) Storage Admin, if you plan to write audio to Storage
4. Create a JSON key for this service account and download it.
5. Choose ONE of the following ways to provide credentials to the backend:
   - Set `GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/service-account.json`
   - OR set `GCP_CREDENTIALS_BASE64` to the base64-encoded contents of that JSON file

### 2.3 Enable Speech-to-Text API
1. Go to `https://console.cloud.google.com/apis/library`.
2. Search for “Speech-to-Text API” and enable it for your project.

### 2.4 Firebase Auth in Clients
Your web/Flutter/native apps should sign users in using Firebase Auth and attach the Firebase ID token to requests:
- HTTP header: `Authorization: Bearer <FIREBASE_ID_TOKEN>`

---

## 3) Third-Party Providers

### 3.1 OpenAI
- Create an API key at `https://platform.openai.com/`
- Set `OPENAI_API_KEY` in `.env`

### 3.2 ElevenLabs
- Create an account and API key at `https://elevenlabs.io/`
- Set `ELEVENLABS_API_KEY` in `.env`
- Get a Voice ID:
  - You can list voices using the ElevenLabs dashboard, or via our endpoint once configured: `GET /api/tts/voices`
- Set a default voice with `ELEVENLABS_DEFAULT_VOICE_ID` in `.env`

---

## 4) Configure the Backend

### 4.1 Clone and Install
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 4.2 Environment Variables
Copy and fill the sample env file:
```bash
cp .env.example .env
```

Required variables (most common):

| Variable | Required | Description |
|---|---|---|
| `OPENAI_API_KEY` | Yes | OpenAI key for syllabus, lessons, correction, and conversation replies |
| `ELEVENLABS_API_KEY` | Yes | ElevenLabs key for TTS |
| `ELEVENLABS_DEFAULT_VOICE_ID` | Yes | Default voice for TTS if caller doesn’t provide one |
| `GOOGLE_APPLICATION_CREDENTIALS` | One of these | Absolute path to service account JSON |
| `GCP_CREDENTIALS_BASE64` | One of these | Base64 of the same JSON; alternative to file path |
| `FIREBASE_PROJECT_ID` | Recommended | Firebase project ID for clarity |
| `FIREBASE_EMULATOR_HOST` | Optional | Host for Firestore emulator (e.g., `localhost:8080`) |
| `ALLOWED_ORIGINS` | Optional | Comma-separated list for CORS (e.g., `http://localhost:3000`) |
| `SENTRY_DSN` | Optional | Enable Sentry error tracking |

### 4.3 Run the Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- Visit `http://localhost:8000/` for the web demo
- Visit `http://localhost:8000/docs` for interactive docs

### 4.4 Docker
```bash
# Build
docker build -t language-tutor-backend:latest .

# Run (mount env file)
docker run --rm -p 8000:8000 --env-file .env language-tutor-backend:latest
```

---

## 5) Authentication
All sensitive endpoints require a Firebase ID token in the header:
```
Authorization: Bearer <FIREBASE_ID_TOKEN>
```
- In Flutter/web/native, use Firebase Auth SDK to sign-in and get the token.

---

## 6) API Overview

Public/demo:
- `GET /` — Minimal web demo to exercise correction, STT (upload), and conversation (text → speech)
- `GET /docs` — OpenAPI docs
- `GET /api/health` — Health check

Auth required:
- `GET /api/users/me` — Returns decoded Firebase token claims

Text-to-Speech (ElevenLabs):
- `GET /api/tts/voices` — List voices
- `POST /api/tts/synthesize` — Body: `{ text, voice_id? }` → returns `audio/mpeg`

Speech-to-Text (Google STT):
- `POST /api/stt/transcribe` — multipart: `file`, optional `language_code` → `{ transcript }`

Correction (OpenAI):
- `POST /api/correct` — Body: `{ text, target_language? }` → `{ corrected_text }`

Conversation (OpenAI + ElevenLabs):
- `POST /api/conversation/reply` — Body: `{ user_text, voice_id? }` → `{ reply_text, audio_b64 }`
- `POST /api/conversation/voice-reply` — multipart: `file`, optional `language_code`, `voice_id` → `{ user_text, reply_text, audio_b64 }`

Syllabus & Lessons (OpenAI + Firestore):
- `POST /api/syllabus/generate` — Body: `{ target_language, goals? }` → Saves under `users/{uid}/syllabi`
- `POST /api/lessons/generate` — Body: `{ topic_title, level? }` → Saves under `users/{uid}/lessons`

---

## 7) Firebase Emulator (Optional)
If you prefer local Firestore/Auth emulation:
1. Install Firebase CLI: `npm i -g firebase-tools`
2. Login: `firebase login`
3. Start emulators in `backend` (uses `firebase.json`):
   ```bash
   firebase emulators:start
   ```
4. Set `.env` with `FIREBASE_EMULATOR_HOST=localhost:8080` to point Firestore client to emulator.

Note: Production rules in `firestore.rules` are minimal placeholders. Update them for your security model.

---

## 8) CI, Testing, and Linting
- CI: `.github/workflows/ci.yml` runs lint (`ruff`, `black --check`) and tests (`pytest`).
- Local checks:
```bash
ruff check .
black --check .
pytest
```

---

## 9) Integrating from Clients

### 9.1 Flutter (dio)
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:8000',
  headers: {'Authorization': 'Bearer $firebaseIdToken'},
));

final correction = await dio.post('/api/correct', data: {
  'text': 'She go to school every day.',
  'target_language': 'English',
});
```

### 9.2 Web (fetch)
```js
const res = await fetch('/api/conversation/reply', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${idToken}`,
  },
  body: JSON.stringify({ user_text: 'Teach me greetings in Spanish' })
});
const data = await res.json();
```

---

## 10) Deployment Notes
- Containerize with the provided `Dockerfile`. Suitable for Cloud Run, ECS, or Kubernetes.
- Configure all environment variables in your platform’s secret manager.
- Consider API versioning (e.g., `/api/v1`), rate limiting, logging/metrics (Sentry already supported).
- Optionally store generated audio/text in Firebase Storage and return signed URLs for reuse.

---

## 11) Troubleshooting
- `401 Not authenticated` → Missing/invalid Firebase ID token in `Authorization` header.
- `Invalid token` → Token expired or issued for a different Firebase project.
- `OPENAI_API_KEY not configured` → Set key in `.env`.
- `ELEVENLABS_API_KEY not configured` or `voice_id is required` → Set `ELEVENLABS_API_KEY` and `ELEVENLABS_DEFAULT_VOICE_ID`, or provide `voice_id`.
- `STT provider error` or `PermissionDenied` → Ensure Speech-to-Text API is enabled and service account has permissions.
- `Form data requires "python-multipart"` → Already included; reinstall deps: `pip install -r requirements.txt`.
- CORS issues → Adjust `ALLOWED_ORIGINS` in `.env` to include your app origin(s).

---

## 12) Quickstart
```bash
# 1) Create venv and install
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2) Configure env
cp .env.example .env
# Fill OPENAI_API_KEY, ELEVENLABS_* and GCP credentials vars

# 3) Run
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 4) Test health
curl http://localhost:8000/api/health
```