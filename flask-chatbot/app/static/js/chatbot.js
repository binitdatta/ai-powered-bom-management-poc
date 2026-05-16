/* bomiq SDM ChatBot — Frontend JS */

const messagesEl = document.getElementById("chatMessages");
const inputEl    = document.getElementById("promptInput");
const sendBtn    = document.getElementById("sendBtn");

// Ctrl+Enter to send
inputEl.addEventListener("keydown", e => {
  if (e.ctrlKey && e.key === "Enter") sendPrompt();
});

function useChip(el) {
  inputEl.value = el.textContent.trim();
  inputEl.focus();
}

function clearChat() {
  messagesEl.innerHTML = "";
}

function scrollBottom() {
  messagesEl.scrollTop = messagesEl.scrollHeight;
}

// Simple markdown → HTML (bold, italic, code, headers, bullets)
function markdownToHtml(text) {
  return text
    .replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
    .replace(/\*\*([^*]+)\*\*/g,"<strong>$1</strong>")
    .replace(/\*([^*]+)\*/g,"<em>$1</em>")
    .replace(/`([^`]+)`/g,"<code>$1</code>")
    .replace(/^#{1,3} (.+)$/gm,"<strong>$1</strong>")
    .replace(/^- (.+)$/gm,"• $1")
    .replace(/\n/g,"<br/>");
}

function addUserMsg(text) {
  const div = document.createElement("div");
  div.className = "d-flex mb-3 justify-content-end";
  div.innerHTML = `<div class="msg-user msg-bubble">${markdownToHtml(text)}</div>`;
  messagesEl.appendChild(div);
  scrollBottom();
}

function addBotMsg() {
  const wrap = document.createElement("div");
  wrap.className = "d-flex mb-3";
  const bubble = document.createElement("div");
  bubble.className = "msg-bot msg-bubble";
  // typing indicator
  bubble.innerHTML = `<span class="typing-dot"></span><span class="typing-dot"></span><span class="typing-dot"></span>`;
  wrap.appendChild(bubble);
  messagesEl.appendChild(wrap);
  scrollBottom();
  return bubble;
}

function addDownloadPill(bubble, filename, url) {
  const pill = document.createElement("a");
  pill.className = "download-pill mt-2 d-inline-flex";
  pill.href      = url;
  pill.download  = filename;
  pill.innerHTML = `<i class="bi bi-file-earmark-excel-fill"></i> Download ${filename}`;
  bubble.appendChild(document.createElement("br"));
  bubble.appendChild(pill);
  scrollBottom();
}

async function sendPrompt() {
  const prompt = inputEl.value.trim();
  if (!prompt) return;

  inputEl.value = "";
  sendBtn.disabled = true;
  addUserMsg(prompt);

  const bubble = addBotMsg();
  let   accText = "";
  let   firstChunk = true;

  try {
    const resp = await fetch("/chat/stream", {
      method:  "POST",
      headers: {"Content-Type": "application/json"},
      body:    JSON.stringify({prompt}),
    });

    const reader = resp.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const {done, value} = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, {stream: true});
      const lines = chunk.split("\n");

      for (const line of lines) {
        if (!line.startsWith("data:")) continue;
        const raw = line.slice(5).trim();
        if (raw === "[DONE]") break;

        try {
          const msg = JSON.parse(raw);

          if (msg.text !== undefined) {
            if (firstChunk) {
              bubble.innerHTML = "";
              firstChunk = false;
            }
            accText += msg.text;
            bubble.innerHTML = markdownToHtml(accText);
            scrollBottom();
          }

          if (msg.download) {
            addDownloadPill(bubble, msg.download.filename, msg.download.url);
          }
        } catch (_) {}
      }
    }
  } catch (err) {
    bubble.innerHTML = `<span class="text-danger">❌ Connection error: ${err.message}</span>`;
  }

  sendBtn.disabled = false;
  inputEl.focus();
}
