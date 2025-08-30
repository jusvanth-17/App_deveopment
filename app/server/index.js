/* eslint-disable no-console */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const http = require('http');
const { WebSocketServer } = require('ws');

const PORT = process.env.PORT ? Number(process.env.PORT) : 3001;

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

// Proxy Gemini Live WebRTC SDP exchange to avoid exposing API key to the client
// The client sends SDP offer (Content-Type: application/sdp) and receives SDP answer
app.post('/gemini/connect', express.text({ type: 'application/sdp', limit: '2mb' }), async (req, res) => {
  try {
    const model = (req.query.model || process.env.GEMINI_LIVE_MODEL || 'gemini-2.0-flash-live-001').toString();
    const apiKey = process.env.GOOGLE_API_KEY || process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'Server missing GOOGLE_API_KEY (or GEMINI_API_KEY)' });
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:connect?key=${encodeURIComponent(apiKey)}`;

    const { data, headers, status } = await axios.post(endpoint, req.body, {
      headers: { 'Content-Type': 'application/sdp' },
      responseType: 'text',
      timeout: 15_000,
      validateStatus: () => true,
    });

    // Forward SDP answer as plain text
    res.status(status);
    res.setHeader('Content-Type', headers['content-type'] || 'application/sdp');
    res.send(typeof data === 'string' ? data : String(data || ''));
  } catch (error) {
    console.error('gemini/connect error', error?.response?.data || error?.message || error);
    res.status(500).json({ error: 'Failed to connect to Gemini Live' });
  }
});

// Proxy to fetch ElevenLabs signed WebSocket URL without exposing API key to the client
app.get('/elevenlabs/signed-url', async (req, res) => {
  try {
    const agentId = req.query.agent_id || process.env.ELEVENLABS_AGENT_ID;
    if (!agentId) {
      return res.status(400).json({ error: 'Missing agent_id' });
    }
    const apiKey = process.env.ELEVENLABS_API_KEY;
    if (!apiKey) {
      return res.status(400).json({ error: 'Server missing ELEVENLABS_API_KEY' });
    }

    const url = `https://api.elevenlabs.io/v1/convai/conversation/get-signed-url?agent_id=${encodeURIComponent(
      agentId,
    )}`;
    const { data } = await axios.get(url, {
      headers: {
        'xi-api-key': apiKey,
      },
      timeout: 15_000,
    });
    res.json(data);
  } catch (error) {
    console.error('signed-url error', error?.response?.data || error?.message || error);
    res.status(500).json({ error: 'Failed to fetch signed url' });
  }
});

const server = http.createServer(app);

// Simple WebSocket for text chat streaming (placeholder while ElevenLabs is configured)
const wss = new WebSocketServer({ server, path: '/ws/chat' });

wss.on('connection', (ws) => {
  ws.on('message', (raw) => {
    try {
      const msg = JSON.parse(raw.toString());
      if (msg?.type === 'user_message' && typeof msg.text === 'string') {
        const full = `You said: ${msg.text}`;
        // Stream token-by-token response
        const tokens = full.split(/(\s+)/); // keep spaces
        let idx = 0;
        const interval = setInterval(() => {
          if (idx >= tokens.length) {
            ws.send(JSON.stringify({ type: 'agent_response_done' }));
            clearInterval(interval);
            return;
          }
          ws.send(JSON.stringify({ type: 'agent_response_delta', delta: tokens[idx] }));
          idx += 1;
        }, 50);
      }
    } catch (e) {
      ws.send(JSON.stringify({ type: 'error', error: 'Malformed message' }));
    }
  });

  ws.send(JSON.stringify({ type: 'ready' }));
});

server.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});

