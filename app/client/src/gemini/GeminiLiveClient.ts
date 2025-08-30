export type GeminiLiveOptions = {
  model?: string;
  baseUrl?: string; // your server base, default http://localhost:3001
};

export class GeminiLiveClient {
  private pc: RTCPeerConnection | null = null;
  private micStream: MediaStream | null = null;
  private remoteStream: MediaStream | null = null;
  private readonly model: string;
  private readonly baseUrl: string;

  constructor(options?: GeminiLiveOptions) {
    this.model = options?.model || 'gemini-2.0-flash-live-001';
    this.baseUrl = options?.baseUrl || 'http://localhost:3001';
  }

  getRemoteStream(): MediaStream | null {
    return this.remoteStream;
  }

  async connect(): Promise<void> {
    if (this.pc) return;

    this.pc = new RTCPeerConnection({
      iceServers: [{ urls: ['stun:stun.l.google.com:19302'] }],
    });

    this.remoteStream = new MediaStream();
    this.pc.ontrack = (evt) => {
      if (!this.remoteStream) this.remoteStream = new MediaStream();
      this.remoteStream.addTrack(evt.track);
    };

    // mic
    this.micStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
    for (const track of this.micStream.getAudioTracks()) {
      this.pc.addTrack(track, this.micStream);
    }

    // receive audio
    this.pc.addTransceiver('audio', { direction: 'recvonly' });

    const offer = await this.pc.createOffer();
    await this.pc.setLocalDescription(offer);

    const resp = await fetch(`${this.baseUrl}/gemini/connect?model=${encodeURIComponent(this.model)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/sdp' },
      body: offer.sdp || '',
    });
    if (!resp.ok) {
      const txt = await resp.text();
      throw new Error(`Gemini connect failed: ${resp.status} ${txt}`);
    }
    const answerSdp = await resp.text();
    await this.pc.setRemoteDescription({ type: 'answer', sdp: answerSdp });
  }

  async disconnect(): Promise<void> {
    try {
      this.pc?.close();
    } catch {}
    this.pc = null;
    try {
      if (this.micStream) {
        for (const t of this.micStream.getTracks()) t.stop();
        this.micStream = null;
      }
    } catch {}
    this.remoteStream = null;
  }
}

