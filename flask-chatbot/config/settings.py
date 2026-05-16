"""
config/settings.py  —  Central configuration loaded from .env
"""
import os
from dotenv import load_dotenv

load_dotenv()

# Flask
SECRET_KEY            = os.environ.get("FLASK_SECRET_KEY", "dev-secret-change-me")
DEBUG                 = os.getenv("FLASK_DEBUG", "false").lower() == "true"

# Keycloak PKCE
KEYCLOAK_URL          = os.getenv("KEYCLOAK_URL",          "http://localhost:8080")
KEYCLOAK_REALM        = os.getenv("KEYCLOAK_REALM",        "bomiq")
KEYCLOAK_CLIENT_ID    = os.getenv("KEYCLOAK_CLIENT_ID",    "bomiq-sdm")
KEYCLOAK_REDIRECT_URI = os.getenv("KEYCLOAK_REDIRECT_URI", "http://localhost:5001/auth/callback")

# Derived Keycloak URLs
KC_BASE           = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect"
KC_AUTH_URL       = f"{KC_BASE}/auth"
KC_TOKEN_URL      = f"{KC_BASE}/token"
KC_LOGOUT_URL     = f"{KC_BASE}/logout"
KC_USERINFO_URL   = f"{KC_BASE}/userinfo"
KC_JWKS_URL       = f"{KC_BASE}/certs"

# Spring Boot REST API
SPRING_API_BASE_URL = os.getenv("SPRING_API_BASE_URL",
                                 "http://localhost:9086/bomiq/api/v1")

# Claude
ANTHROPIC_API_KEY   = os.environ.get("ANTHROPIC_API_KEY", "")
CLAUDE_MODEL        = "claude-sonnet-4-20250514"

# Downloads directory
DOWNLOADS_DIR = os.path.join(os.path.dirname(__file__), "..", "downloads")
os.makedirs(DOWNLOADS_DIR, exist_ok=True)