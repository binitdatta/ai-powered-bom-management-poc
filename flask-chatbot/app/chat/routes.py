"""
app/chat/routes.py  —  Public home, protected chat, SSE stream, file download
"""
import os
from flask import (Blueprint, render_template, request, session,
                   Response, send_file, redirect, url_for)
from app.auth.decorators  import login_required
from app.auth.token_store import get_username, get_roles, get_access_token
from app.chat.intent      import detect_intent
from app.chat.handlers    import dispatch

chat_bp = Blueprint("chat", __name__)


@chat_bp.route("/")
def home():
    return render_template("home.html")


@chat_bp.route("/chat")
@login_required
def index():
    return render_template("chat/index.html",
                           username=get_username(),
                           roles=get_roles())


@chat_bp.route("/chat/stream", methods=["POST"])
@login_required
def stream():
    """SSE endpoint — capture token BEFORE entering the generator."""
    data         = request.get_json(silent=True) or {}
    prompt       = (data.get("prompt") or "").strip()
    access_token = get_access_token()   # ← read from session HERE, in request context

    if not prompt:
        def empty():
            yield "data: {\"text\": \"Please enter a prompt.\"}\n\n"
            yield "data: [DONE]\n\n"
        return Response(empty(), mimetype="text/event-stream",
                        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"})

    def generate(token: str, user_prompt: str):
        try:
            state = detect_intent(user_prompt)
            yield from dispatch(state, token)   # ← pass token as argument
        except Exception as e:
            import json, traceback
            traceback.print_exc()
            yield f"data: {json.dumps({'text': f'❌ Error: {str(e)}'})}\n\n"
            yield "data: [DONE]\n\n"

    return Response(generate(access_token, prompt),
                    mimetype="text/event-stream",
                    headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"})


@chat_bp.route("/chat/download/<filename>")
@login_required
def download(filename: str):
    from config import settings
    safe_name = os.path.basename(filename)
    filepath  = os.path.join(settings.DOWNLOADS_DIR, safe_name)
    if not os.path.isfile(filepath):
        return "File not found", 404
    return send_file(filepath, as_attachment=True,
                     download_name=safe_name,
                     mimetype="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")