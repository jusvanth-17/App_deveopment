import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';

export type ElevenEvent =
  | { type: 'agent_response_delta'; delta: string }
  | { type: 'agent_response_done' }
  | { type: 'transcript'; text: string; final?: boolean }
  | { type: 'error'; error: string }
  | { type: 'ready' };

type Listener = (evt: ElevenEvent) => void;

type ElevenLabsContextValue = {
  status: 'idle' | 'connecting' | 'connected' | 'error';
  error: string | null;
  connect: () => Promise<void>;
  disconnect: () => void;
  sendText: (text: string) => void;
  addListener: (fn: Listener) => void;
  removeListener: (fn: Listener) => void;
};

const ElevenLabsContext = createContext<ElevenLabsContextValue | null>(null);

export const useElevenLabs = (): ElevenLabsContextValue => {
  const ctx = useContext(ElevenLabsContext);
  if (!ctx) throw new Error('useElevenLabs must be used within ElevenLabsProvider');
  return ctx;
};

export const ElevenLabsProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [status, setStatus] = useState<'idle' | 'connecting' | 'connected' | 'error'>('idle');
  const [error, setError] = useState<string | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const listenersRef = useRef<Set<Listener>>(new Set());

  // Audio playback queue using WebAudio
  const audioCtxRef = useRef<AudioContext | null>(null);
  const nextStartTimeRef = useRef<number>(0);

  const emit = useCallback((evt: ElevenEvent) => {
    listenersRef.current.forEach((fn) => {
      try {
        fn(evt);
      } catch {
        // ignore listener errors
      }
    });
  }, []);

  const playAudioChunk = useCallback(async (arrBuf: ArrayBuffer) => {
    try {
      if (!audioCtxRef.current) {
        const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
        audioCtxRef.current = ctx;
        nextStartTimeRef.current = ctx.currentTime + 0.05;
      }
      const ctx = audioCtxRef.current!;
      const audioBuffer = await ctx.decodeAudioData(arrBuf.slice(0));
      const source = ctx.createBufferSource();
      source.buffer = audioBuffer;
      source.connect(ctx.destination);
      const startAt = Math.max(ctx.currentTime + 0.02, nextStartTimeRef.current || ctx.currentTime + 0.02);
      source.start(startAt);
      nextStartTimeRef.current = startAt + audioBuffer.duration;
    } catch (e) {
      // best-effort audio playback
    }
  }, []);

  const connect = useCallback(async () => {
    if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) return;
    setStatus('connecting');
    setError(null);
    try {
      const res = await fetch('http://localhost:3001/elevenlabs/signed-url');
      if (!res.ok) throw new Error('Failed to fetch signed url');
      const data = await res.json();
      const signedUrl: string | undefined = data?.signed_url || data?.url || data?.ws_url;
      if (!signedUrl) throw new Error('No signed url in response');

      const ws = new WebSocket(signedUrl);
      ws.binaryType = 'arraybuffer';
      wsRef.current = ws;

      ws.onopen = () => {
        setStatus('connected');
        setError(null);
        emit({ type: 'ready' });
      };
      ws.onerror = () => {
        setStatus('error');
        setError('WebSocket error');
      };
      ws.onclose = () => {
        setStatus('idle');
      };
      ws.onmessage = async (evt: MessageEvent) => {
        const data = evt.data;
        if (data instanceof ArrayBuffer) {
          // audio frames
          await playAudioChunk(data);
          return;
        }
        if (typeof data !== 'string') {
          // unknown binary type; ignore
          return;
        }
        try {
          const json = JSON.parse(data);
          if (json?.type === 'agent_response_delta' && typeof json.delta === 'string') {
            emit({ type: 'agent_response_delta', delta: json.delta });
          } else if (json?.type === 'agent_response_done') {
            emit({ type: 'agent_response_done' });
          } else if (json?.type === 'transcript' && typeof json.text === 'string') {
            emit({ type: 'transcript', text: json.text, final: !!json.final });
          } else if (json?.type === 'error' && typeof json.error === 'string') {
            emit({ type: 'error', error: json.error });
          }
        } catch {
          // Not JSON, try base64 audio string
          try {
            const base64 = data as string;
            const commaIdx = base64.indexOf(',');
            const b64 = commaIdx >= 0 ? base64.slice(commaIdx + 1) : base64;
            const binaryString = atob(b64);
            const len = binaryString.length;
            const bytes = new Uint8Array(len);
            for (let i = 0; i < len; i++) bytes[i] = binaryString.charCodeAt(i);
            await playAudioChunk(bytes.buffer);
          } catch {
            // ignore unknown message
          }
        }
      };
    } catch (e: any) {
      setStatus('error');
      setError(e?.message || 'Failed to connect');
    }
  }, [emit, playAudioChunk]);

  const disconnect = useCallback(() => {
    const ws = wsRef.current;
    if (ws) {
      try {
        ws.close();
      } catch {
        // ignore
      }
    }
    wsRef.current = null;
    setStatus('idle');
  }, []);

  const sendText = useCallback((text: string) => {
    const ws = wsRef.current;
    if (!ws || ws.readyState !== WebSocket.OPEN) return;
    ws.send(JSON.stringify({ type: 'user_message', text }));
  }, []);

  const addListener = useCallback((fn: Listener) => {
    listenersRef.current.add(fn);
  }, []);
  const removeListener = useCallback((fn: Listener) => {
    listenersRef.current.delete(fn);
  }, []);

  const value = useMemo<ElevenLabsContextValue>(
    () => ({ status, error, connect, disconnect, sendText, addListener, removeListener }),
    [status, error, connect, disconnect, sendText, addListener, removeListener],
  );

  useEffect(() => {
    return () => {
      try {
        wsRef.current?.close();
      } catch {
        // ignore
      }
      wsRef.current = null;
      if (audioCtxRef.current) {
        try { audioCtxRef.current.close(); } catch {}
        audioCtxRef.current = null;
      }
    };
  }, []);

  return <ElevenLabsContext.Provider value={value}>{children}</ElevenLabsContext.Provider>;
};