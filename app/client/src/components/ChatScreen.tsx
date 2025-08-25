import React, { useEffect, useMemo, useRef, useState } from 'react';
import { VoiceCallPanel } from './VoiceCallPanel';

type Message = {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
};

function useChatSocket() {
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);

  const connect = useMemo(
    () => () => {
      if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) return;
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
  const { connect, connected, error, sendUserMessage } = useChatSocket();
  const [streamingId, setStreamingId] = useState<string | null>(null);
  const listRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const ws = connect();
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
            return prev.map((m) =>
              m.id === streamingId ? { ...m, content: m.content + data.delta } : m,
            );
          });
        } else if (data.type === 'agent_response_done') {
          setStreamingId(null);
        } else if (data.type === 'error') {
          console.error(data.error);
        }
      } catch (e) {
        // ignore
      }
    };
  }, [connect, streamingId]);

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
    sendUserMessage(text);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100vh' }}>
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '12px 16px',
          borderBottom: '1px solid #e5e7eb',
          background: 'white',
          position: 'sticky',
          top: 0,
          zIndex: 10,
        }}
      >
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: 16,
              background: '#111827',
            }}
          />
          <strong>Assistant</strong>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ fontSize: 12, color: connected ? '#059669' : '#6b7280' }}>
            {connected ? 'Connected' : 'Disconnected'} {error ? `· ${error}` : ''}
          </div>
          <VoiceCallPanel />
        </div>
      </header>

      <div
        ref={listRef}
        style={{ flex: 1, overflowY: 'auto', padding: '16px', background: '#fafafa' }}
      >
        {messages.map((m) => (
          <div key={m.id} style={{ display: 'flex', marginBottom: 12 }}>
            <div style={{ width: 36 }}>{m.role === 'assistant' ? '🤖' : '🧑'}</div>
            <div
              style={{
                background: m.role === 'assistant' ? 'white' : '#111827',
                color: m.role === 'assistant' ? '#111827' : 'white',
                padding: '10px 12px',
                borderRadius: 12,
                border: m.role === 'assistant' ? '1px solid #e5e7eb' : 'none',
                maxWidth: 720,
                whiteSpace: 'pre-wrap',
              }}
            >
              {m.content}
            </div>
          </div>
        ))}
      </div>

      <div style={{ padding: 12, borderTop: '1px solid #e5e7eb', background: 'white' }}>
        <div style={{ display: 'flex', gap: 8 }}>
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) onSend();
            }}
            placeholder="Ask anything..."
            style={{
              flex: 1,
              border: '1px solid #e5e7eb',
              borderRadius: 12,
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

