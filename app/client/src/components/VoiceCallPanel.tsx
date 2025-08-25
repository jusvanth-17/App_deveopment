import React, { useRef, useState } from 'react';

export const VoiceCallPanel: React.FC = () => {
  const [status, setStatus] = useState<'idle' | 'connecting' | 'connected' | 'error'>('idle');
  const [message, setMessage] = useState<string>('');
  const wsRef = useRef<WebSocket | null>(null);

  const connect = async () => {
    try {
      setStatus('connecting');
      const res = await fetch('http://localhost:3001/elevenlabs/signed-url');
      if (!res.ok) throw new Error('Failed to fetch signed url');
      const data = await res.json();
      const signedUrl: string | undefined = data?.signed_url || data?.url || data?.ws_url;
      if (!signedUrl) throw new Error('No signed url in response');
      const ws = new WebSocket(signedUrl);
      wsRef.current = ws;
      ws.onopen = () => setStatus('connected');
      ws.onerror = () => setStatus('error');
      ws.onclose = () => setStatus('idle');
      ws.onmessage = (evt) => {
        // For now, just log incoming events. You can route to UI as needed.
        try {
          const payload = JSON.parse(evt.data);
          // eslint-disable-next-line no-console
          console.log('ElevenLabs event', payload);
        } catch {
          // eslint-disable-next-line no-console
          console.log('ElevenLabs binary/unknown message');
        }
      };
    } catch (e) {
      setStatus('error');
    }
  };

  const sendText = () => {
    const text = message.trim();
    if (!text || !wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) return;
    wsRef.current.send(JSON.stringify({ type: 'user_message', text }));
    setMessage('');
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <button
        onClick={connect}
        disabled={status === 'connecting' || status === 'connected'}
        style={{ padding: '4px 8px', borderRadius: 8 }}
      >
        {status === 'connected' ? 'Connected' : status === 'connecting' ? 'Connecting…' : 'Connect Voice'}
      </button>
      <input
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        placeholder="Send text to agent"
        style={{
          width: 220,
          border: '1px solid #e5e7eb',
          borderRadius: 8,
          padding: '6px 8px',
        }}
      />
      <button onClick={sendText} style={{ padding: '4px 8px', borderRadius: 8 }}>
        Send
      </button>
    </div>
  );
};

export default VoiceCallPanel;

