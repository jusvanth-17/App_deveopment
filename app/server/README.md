# Server

- Copy env and set keys:

```
cp .env.example .env
# Fill ELEVENLABS_API_KEY and ELEVENLABS_AGENT_ID
```

- Start:

```
npm run dev
```

- Endpoints:
- `GET /health`
- `GET /elevenlabs/signed-url?agent_id=...` -> proxies to ElevenLabs signed URL

- WebSocket:
- `ws://localhost:3001/ws/chat` -> demo chat stream