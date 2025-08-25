import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { ElevenLabsProvider } from './elevenlabs/ElevenLabsContext'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ElevenLabsProvider>
      <App />
    </ElevenLabsProvider>
  </StrictMode>,
)
