"""
app/auth/routes.py  —  Keycloak PKCE OAuth2 — state via query parameter (no cookies)
"""
import urllib.parse
import hmac
import hashlib
import json
import base64
import time
import requests
from flask import (Blueprint, redirect, request,
                   session, url_for, render_template, make_response)
from config import settings
from app.auth.pkce        import generate_code_verifier, generate_code_challenge, generate_state
from app.auth.token_store import save_tokens, clear_session
import jwt as pyjwt

auth_bp = Blueprint("auth", __name__)

# ── Signed state token ────────────────────────────────────────────────────

def _sign(data: str) -> str:
    mac = hmac.new(settings.SECRET_KEY.encode(), data.encode(), hashlib.sha256)
    return mac.hexdigest()

def _make_token(verifier: str, state: str) -> str:
    """Pack verifier into a signed token embedded in the state parameter."""
    payload = json.dumps({"v": verifier, "t": int(time.time())})
    b64     = base64.urlsafe_b64encode(payload.encode()).decode()
    sig     = _sign(b64)
    return f"{b64}.{sig}"

def _read_token(token: str):
    """Verify and unpack. Returns verifier or None."""
    try:
        b64, sig = token.rsplit(".", 1)
        if not hmac.compare_digest(_sign(b64), sig):
            return None
        payload = json.loads(base64.urlsafe_b64decode(b64).decode())
        if time.time() - payload["t"] > 600:
            return None
        return payload["v"]
    except Exception:
        return None

# ── Routes ────────────────────────────────────────────────────────────────

@auth_bp.route("/login")
def login():
    verifier  = generate_code_verifier()
    challenge = generate_code_challenge(verifier)
    state     = generate_state()

    # Embed the verifier inside the state parameter as a signed token
    # Format: <random_state>.<signed_verifier_token>
    verifier_token = _make_token(verifier, state)
    composite_state = f"{state}.{verifier_token}"

    params = {
        "response_type":         "code",
        "client_id":             settings.KEYCLOAK_CLIENT_ID,
        "redirect_uri":          settings.KEYCLOAK_REDIRECT_URI,
        "scope":                 "openid profile email roles",
        "state":                 composite_state,
        "code_challenge":        challenge,
        "code_challenge_method": "S256",
    }
    return redirect(settings.KC_AUTH_URL + "?" + urllib.parse.urlencode(params))


@auth_bp.route("/callback")
def callback():
    error = request.args.get("error")
    if error:
        return render_template("auth/error.html",
                               error=error,
                               description=request.args.get("error_description", "")), 400

    code            = request.args.get("code")
    composite_state = request.args.get("state", "")

    # Split composite state: <random_state>.<verifier_token>
    # verifier_token itself contains a dot, so split on first dot only
    dot_idx = composite_state.find(".")
    if dot_idx == -1:
        return render_template("auth/error.html",
                               error="invalid_state",
                               description="State parameter malformed"), 400

    state_part     = composite_state[:dot_idx]
    verifier_token = composite_state[dot_idx+1:]
    verifier       = _read_token(verifier_token)

    if not verifier:
        return render_template("auth/error.html",
                               error="state_invalid",
                               description="State token invalid or expired"), 400

    # Exchange code for tokens
    resp = requests.post(settings.KC_TOKEN_URL, data={
        "grant_type":    "authorization_code",
        "client_id":     settings.KEYCLOAK_CLIENT_ID,
        "redirect_uri":  settings.KEYCLOAK_REDIRECT_URI,
        "code":          code,
        "code_verifier": verifier,
    }, timeout=10)

    if not resp.ok:
        return render_template("auth/error.html",
                               error="token_exchange_failed",
                               description=resp.text), 400

    tokens        = resp.json()
    access_token  = tokens["access_token"]
    id_token      = tokens.get("id_token", "")
    refresh_token = tokens.get("refresh_token", "")

    try:
        payload  = pyjwt.decode(access_token, options={"verify_signature": False})
        username = payload.get("preferred_username", "unknown")
        roles    = payload.get("realm_access", {}).get("roles", [])
    except Exception:
        username, roles = "unknown", []

    save_tokens(access_token, id_token, refresh_token, username, roles)
    return redirect(url_for("chat.index"))


@auth_bp.route("/logout")
def logout():
    id_token = session.get("id_token", "")
    clear_session()
    params = {
        "id_token_hint":            id_token,
        "post_logout_redirect_uri": url_for("chat.home", _external=True),
        "client_id":                settings.KEYCLOAK_CLIENT_ID,
    }
    return redirect(settings.KC_LOGOUT_URL + "?" + urllib.parse.urlencode(params))