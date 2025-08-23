## AI Language Tutor - Backend (FastAPI)

### Quickstart

1. Create and activate venv
```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Install dependencies
```bash
pip install -r requirements.txt
```

3. Configure environment
```bash
cp .env.example .env
# Fill in env vars
```

4. Run locally
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

5. Health check
```bash
curl http://localhost:8000/api/health
```

### Firebase Emulator (optional)
- Ensure `FIREBASE_EMULATOR_HOST` is set in `.env`.
- Provide service account via `GOOGLE_APPLICATION_CREDENTIALS` or `GCP_CREDENTIALS_BASE64`.

### Lint & Test
```bash
ruff check .
black --check .
pytest
```