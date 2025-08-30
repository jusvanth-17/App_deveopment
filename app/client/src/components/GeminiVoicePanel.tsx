import React, { useEffect, useMemo, useRef, useState } from 'react';
import { GeminiLiveClient } from '../gemini/GeminiLiveClient';

export const GeminiVoicePanel: React.FC = () => {
  const [connected, setConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const client = useMemo(() => new GeminiLiveClient(), []);

  useEffect(() => {
    if (!audioRef.current) return;
    const remote = client.getRemoteStream();
    if (remote) {
      (audioRef.current as any).srcObject = remote;
    }
  }, [client, connected]);

  const onClick = async () => {
    if (!connected) {
      try {
        setError(null);
        await client.connect();
        const stream = client.getRemoteStream();
        if (audioRef.current && stream) {
          (audioRef.current as any).srcObject = stream;
          try { await audioRef.current.play(); } catch {}
        }
        setConnected(true);
      } catch (e: any) {
        setError(e?.message || 'Failed to connect');
      }
    } else {
      await client.disconnect();
      setConnected(false);
    }
  };

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
      <button onClick={onClick} style={{ padding: '6px 10px', borderRadius: 10 }}>
        {connected ? 'Hang up (Gemini)' : 'Start Gemini Live'}
      </button>
      {error && <span style={{ color: '#f87171', fontSize: 12 }}>{error}</span>}
      <audio ref={audioRef} autoPlay playsInline />
    </div>
  );
};

