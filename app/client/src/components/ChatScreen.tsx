import React, { useEffect, useMemo, useRef, useState } from 'react';
import { VoiceCallPanel } from './VoiceCallPanel';
import { useElevenLabs, type ElevenEvent } from '../elevenlabs/ElevenLabsContext';

type Message = {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
};

function useFallbackChatSocket() {
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);

  const connect = useMemo(
    () => () => {
      if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) return wsRef.current;
      const ws = new WebSocket('ws://localhost:3001/ws/chat');
      wsRef.current = ws;
      ws.onopen = () => {
        setConnected(true);
        setError(null);
      };
      ws.onclose = () => {
        setConnected(false);
      };
      ws.onerror = () => {
        setError('WebSocket error');
      };
      return ws;
    },
    [],
  );

  const sendUserMessage = (text: string) => {
    if (!wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) return;
    wsRef.current.send(JSON.stringify({ type: 'user_message', text }));
  };

  return { wsRef, connect, connected, error, sendUserMessage };
}

export const ChatScreen: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const { status: elevenStatus, connect: connectEleven, addListener, removeListener, sendText } = useElevenLabs();
  const fallback = useFallbackChatSocket();
  const [streamingId, setStreamingId] = useState<string | null>(null);
  const listRef = useRef<HTMLDivElement | null>(null);

  // Connect ElevenLabs on mount for voice-like experience
  useEffect(() => {
    if (elevenStatus === 'idle') {
      connectEleven();
    }
  }, [elevenStatus, connectEleven]);

  // Subscribe to ElevenLabs events for streaming response
  useEffect(() => {
    const handler = (evt: ElevenEvent) => {
      if (evt.type === 'agent_response_delta') {
        setMessages((prev) => {
          if (!streamingId) {
            const id = crypto.randomUUID();
            setStreamingId(id);
            return [...prev, { id, role: 'assistant', content: evt.delta }];
          }
          return prev.map((m) => (m.id === streamingId ? { ...m, content: m.content + evt.delta } : m));
        });
      } else if (evt.type === 'agent_response_done') {
        setStreamingId(null);
      }
    };
    addListener(handler);
    return () => removeListener(handler);
  }, [addListener, removeListener, streamingId]);

  // Fallback local websocket for text-only if ElevenLabs not connected
  useEffect(() => {
    if (elevenStatus === 'connected') return;
    const ws = fallback.connect();
    if (!ws) return;
    ws.onmessage = (evt) => {
      try {
        const data = JSON.parse(evt.data);
        if (data.type === 'ready') return;
        if (data.type === 'agent_response_delta') {
          setMessages((prev) => {
            if (!streamingId) {
              const id = crypto.randomUUID();
              setStreamingId(id);
              return [...prev, { id, role: 'assistant', content: data.delta }];
            }
            return prev.map((m) => (m.id === streamingId ? { ...m, content: m.content + data.delta } : m));
          });
        } else if (data.type === 'agent_response_done') {
          setStreamingId(null);
        }
      } catch {
        // ignore
      }
    };
  }, [elevenStatus, fallback, streamingId]);

  useEffect(() => {
    if (!listRef.current) return;
    listRef.current.scrollTop = listRef.current.scrollHeight;
  }, [messages]);

  const onSend = () => {
    const text = input.trim();
    if (!text) return;
    const id = crypto.randomUUID();
    setMessages((m) => [...m, { id, role: 'user', content: text }]);
    setInput('');
    if (elevenStatus === 'connected') {
      sendText(text);
    } else {
      fallback.sendUserMessage(text);
    }
  };

  // Gemini-like layout: centered, wide bubbles, subtle background and typing area
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', background: '#0b1021' }}>
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '12px 16px',
          borderBottom: '1px solid rgba(255,255,255,0.08)',
          background: 'rgba(7, 10, 24, 0.7)',
          position: 'sticky',
          top: 0,
          zIndex: 10,
          backdropFilter: 'blur(8px)',
        }}
      >
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', color: 'white' }}>
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: 16,
              background: 'linear-gradient(135deg, #6ee7f9 0%, #8b5cf6 100%)',
            }}
          />
          <strong>Gemini-like Assistant</strong>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.7)' }}>
            {elevenStatus === 'connected' ? 'Voice · Connected' : fallback.connected ? 'Text · Connected' : 'Disconnected'}
          </div>
          <VoiceCallPanel />
        </div>
      </header>

      <div
        ref={listRef}
        style={{ flex: 1, overflowY: 'auto', padding: '24px 16px', display: 'flex', justifyContent: 'center' }}
      >
        <div style={{ width: '100%', maxWidth: 860 }}>
          {messages.map((m) => (
            <div key={m.id} style={{ display: 'flex', marginBottom: 16 }}>
              <div style={{ width: 36 }}>{m.role === 'assistant' ? '🤖' : '🧑'}</div>
              <div
                style={{
                  background:
                    m.role === 'assistant'
                      ? 'linear-gradient(180deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.04) 100%)'
                      : 'linear-gradient(180deg, rgba(59,130,246,0.25) 0%, rgba(59,130,246,0.18) 100%)',
                  color: 'white',
                  padding: '12px 14px',
                  borderRadius: 16,
                  border: '1px solid rgba(255,255,255,0.12)',
                  maxWidth: 760,
                  whiteSpace: 'pre-wrap',
                }}
              >
                {m.content}
              </div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ padding: 16, borderTop: '1px solid rgba(255,255,255,0.08)', background: 'rgba(7, 10, 24, 0.7)', backdropFilter: 'blur(8px)' }}>
        <div style={{ display: 'flex', gap: 8, maxWidth: 860, margin: '0 auto' }}>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) onSend();
            }}
            placeholder="Ask anything..."
            style={{
              flex: 1,
              border: '1px solid rgba(255,255,255,0.12)',
              background: 'rgba(255,255,255,0.06)',
              color: 'white',
              borderRadius: 16,
              padding: '12px 14px',
              outline: 'none',
            }}
          />
          <button onClick={onSend} style={{ padding: '0 16px', borderRadius: 12 }}>
            Send
          </button>
        </div>
      </div>
    </div>
  );
};

export default ChatScreen;

