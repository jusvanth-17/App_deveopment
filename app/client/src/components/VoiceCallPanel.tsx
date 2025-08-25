import React, { useState } from 'react';
import { useElevenLabs } from '../elevenlabs/ElevenLabsContext';

export const VoiceCallPanel: React.FC = () => {
  const { status, connect, sendText } = useElevenLabs();
  const [message, setMessage] = useState<string>('');

  const onConnect = async () => {
    await connect();
  };

  const onSend = () => {
    const text = message.trim();
    if (!text) return;
    sendText(text);
    setMessage('');
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <button
        onClick={onConnect}
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
      <button onClick={onSend} style={{ padding: '4px 8px', borderRadius: 8 }}>
        Send
      </button>
    </div>
  );
};

export default VoiceCallPanel;

