# Chat App (Web + Node server)

A Gemini-like chat UI (React + Vite) with optional ElevenLabs real-time voice over WebSocket. Includes a local text-streaming fallback WebSocket.

## Prerequisites
- Node.js 18+ and npm
- ElevenLabs account (for voice). You need:
  - ELEVENLABS_API_KEY
  - ELEVENLABS_AGENT_ID

## Project layout
- `app/server`: Node/Express server providing:
  - `GET /health`
  - `GET /elevenlabs/signed-url?agent_id=...` -> proxies to ElevenLabs to obtain a signed WS URL
  - `ws://localhost:3001/ws/chat` -> demo text streaming endpoint
- `app/client`: React + Vite front-end with a Gemini-like chat (`ChatScreen`) and a voice panel (`VoiceCallPanel`).

## 1) Configure server environment
Create `app/server/.env` and fill values:

```bash
ELEVENLABS_API_KEY=your_xi_api_key_here
ELEVENLABS_AGENT_ID=your_agent_id_here
PORT=3001
```

Tip: `ELEVENLABS_AGENT_ID` can be overridden per-request via query param `?agent_id=...`.

## 2) Install dependencies
```bash
cd app/server && npm install
cd ../client && npm install
```

## 3) Run the server
```bash
cd app/server
npm run dev
# In another terminal, verify:
curl http://localhost:3001/health
```

## 4) Run the client (web)
```bash
cd app/client
npm run dev
```
Open the printed Vite URL (usually `http://localhost:5173`).

## Usage
- Text chat works immediately via local fallback WS (`/ws/chat`).
- Click "Connect Voice" to open an ElevenLabs real-time WebSocket using the signed URL from the server. Requires valid `ELEVENLABS_API_KEY` and `ELEVENLABS_AGENT_ID`.

## Production build (optional)
```bash
cd app/client
npm run build
npm run preview
```

## Troubleshooting
- 401/403 when connecting voice: check `ELEVENLABS_API_KEY` and agent permissions.
- Cannot resolve signed URL: ensure the server is running and `.env` is set.
- CORS/WebSocket blocked in browser: run client and server on localhost as shown, or configure proper origins.

## Flutter alternative (optional)
You can keep this Node server and build a Flutter client:
- Text chat: connect to `ws://localhost:3001/ws/chat` and send `{type:"user_message", text}`.
- Voice: `GET http://localhost:3001/elevenlabs/signed-url`, then open the returned WS URL. Handle JSON text deltas and binary audio frames for playback.

If you want, we can scaffold the Flutter client next.