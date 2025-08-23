from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter()


@router.get("/", response_class=HTMLResponse)
async def demo_root():
	return """
<!doctype html>
<html>
<head>
	<meta charset=\"utf-8\" />
	<title>AI Language Tutor - Demo</title>
	<style>
		body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 24px; }
		section { border: 1px solid #ddd; padding: 16px; border-radius: 8px; margin-bottom: 16px; }
		label { display: block; margin-top: 8px; font-weight: 600; }
		textarea, input, button { width: 100%; padding: 8px; margin-top: 4px; }
		button { cursor: pointer; }
		pre { background: #f7f7f7; padding: 12px; border-radius: 6px; overflow: auto; }
	</style>
</head>
<body>
	<h1>AI Language Tutor - Backend Demo</h1>
	<p>Provide a Firebase ID token for protected endpoints.</p>
	<label>Firebase ID Token (Bearer)</label>
	<input id=\"token\" placeholder=\"eyJhbGciOi...\" />

	<section>
		<h2>Correction</h2>
		<label>Text</label>
		<textarea id=\"corrText\" rows=\"3\">She go to school every day.</textarea>
		<label>Target language (optional)</label>
		<input id=\"corrLang\" placeholder=\"English\" />
		<button id=\"corrBtn\">Correct</button>
		<pre id=\"corrOut\"></pre>
	</section>

	<section>
		<h2>Conversation (Text to Speech)</h2>
		<label>User text</label>
		<textarea id=\"convText\" rows=\"2\">Can you greet me in Spanish?</textarea>
		<label>Voice ID (optional)</label>
		<input id=\"voiceId\" placeholder=\"ELEVENLABS_VOICE_ID\" />
		<button id=\"convBtn\">Send</button>
		<pre id=\"convOut\"></pre>
		<audio id=\"convAudio\" controls></audio>
	</section>

	<section>
		<h2>STT (Upload WAV)</h2>
		<label>Audio file</label>
		<input id=\"sttFile\" type=\"file\" accept=\"audio/*\" />
		<label>Language code</label>
		<input id=\"sttLang\" value=\"en-US\" />
		<button id=\"sttBtn\">Transcribe</button>
		<pre id=\"sttOut\"></pre>
	</section>

	<script>
		function authHeader() {
			const token = document.getElementById('token').value.trim();
			return token ? { 'Authorization': 'Bearer ' + token } : {};
		}

		document.getElementById('corrBtn').onclick = async () => {
			const body = {
				text: document.getElementById('corrText').value,
				target_language: document.getElementById('corrLang').value || null,
			};
			const r = await fetch('/api/correct', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json', ...authHeader() },
				body: JSON.stringify(body),
			});
			document.getElementById('corrOut').textContent = JSON.stringify(await r.json(), null, 2);
		};

		document.getElementById('convBtn').onclick = async () => {
			const body = {
				user_text: document.getElementById('convText').value,
				voice_id: document.getElementById('voiceId').value || null,
			};
			const r = await fetch('/api/conversation/reply', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json', ...authHeader() },
				body: JSON.stringify(body),
			});
			const data = await r.json();
			document.getElementById('convOut').textContent = JSON.stringify(data, null, 2);
			if (data.audio_b64) {
				document.getElementById('convAudio').src = 'data:audio/mpeg;base64,' + data.audio_b64;
				document.getElementById('convAudio').play();
			}
		};

		document.getElementById('sttBtn').onclick = async () => {
			const f = document.getElementById('sttFile').files[0];
			if (!f) { alert('Select a file'); return; }
			const form = new FormData();
			form.append('file', f);
			form.append('language_code', document.getElementById('sttLang').value || 'en-US');
			const r = await fetch('/api/stt/transcribe', {
				method: 'POST',
				headers: { ...authHeader() },
				body: form,
			});
			document.getElementById('sttOut').textContent = JSON.stringify(await r.json(), null, 2);
		};
	</script>
</body>
</html>
	"""