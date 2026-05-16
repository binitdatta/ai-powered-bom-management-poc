"""
app/auth/pkce.py  —  PKCE helpers (RFC 7636)
"""
import base64
import hashlib
import os
import secrets


def generate_code_verifier() -> str:
    """Generate a cryptographically-random 64-char code verifier."""
    return base64.urlsafe_b64encode(os.urandom(48)).rstrip(b"=").decode("ascii")


def generate_code_challenge(verifier: str) -> str:
    """Derive S256 code challenge from verifier."""
    digest = hashlib.sha256(verifier.encode("ascii")).digest()
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode("ascii")


def generate_state() -> str:
    return secrets.token_urlsafe(32)
