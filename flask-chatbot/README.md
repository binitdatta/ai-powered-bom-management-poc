# bomiq SDM — Python Flask AI ChatBot

A Python 3.12 Flask ChatBot that uses **Keycloak 26 PKCE** authentication,
calls the **Spring Boot REST API** backend, performs **AI-powered BOM validation**
via Claude Sonnet + LangGraph, and produces **downloadable Excel reports**.

---

## Architecture

```
Browser ──PKCE──▶ Keycloak 26 (port 8080, realm: bomiq)
Browser ◀──────── Flask ChatBot (port 5000)
Flask   ──JWT───▶ Spring Boot REST API (port 9086/bomiq/api/v1)
Flask   ──────── Claude Sonnet (Anthropic API)
Flask   ──────── openpyxl → .xlsx downloads
```

---

## Prerequisites

| Requirement | Version |
|---|---|
| Python | 3.12+ |
| Keycloak | 26 (running on port 8080, realm `bomiq`) |
| Spring Boot app | Running on port 9086 |
| Anthropic API key | From https://console.anthropic.com |

---

## 1 — Get Your Claude API Key

1. Go to **https://console.anthropic.com**
2. Sign in or create an account
3. Navigate to **API Keys** → **Create Key**
4. Copy the key (starts with `sk-ant-...`)
5. You will paste it into `.env` in step 4 below

---

## 2 — Create and Activate a Virtual Environment

```bash
# From the flask-chatbot/ directory
cd /path/to/bomiq-sdm/flask-chatbot

# Create the venv (Python 3.12 required)
python3.12 -m venv .venv

# Activate (macOS / Linux)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Verify you're inside the venv
which python        # should show .../.venv/bin/python
python --version    # should show Python 3.12.x
```

---

## 3 — Install Dependencies

```bash
# Ensure venv is active, then:
pip install --upgrade pip
pip install -r requirements.txt
```

---

## 4 — Configure Environment

```bash
# Copy the example env file
cp .env.example .env

# Open .env in your editor and fill in:
nano .env    # or: open .env, code .env, vim .env
```

Edit `.env` with your actual values:

```dotenv
# ── Claude API Key (required) ──────────────────────────────
ANTHROPIC_API_KEY=sk-ant-YOUR_KEY_HERE

# ── Flask ──────────────────────────────────────────────────
FLASK_SECRET_KEY=any-random-32-char-string-here
FLASK_ENV=development
FLASK_DEBUG=false

# ── Keycloak (must match your running Keycloak instance) ───
KEYCLOAK_URL=http://localhost:8080
KEYCLOAK_REALM=bomiq
KEYCLOAK_CLIENT_ID=bomiq-sdm
KEYCLOAK_REDIRECT_URI=http://localhost:5000/auth/callback

# ── Spring Boot API ────────────────────────────────────────
SPRING_API_BASE_URL=http://localhost:9086/bomiq/api/v1
```

> ⚠️ **Never commit `.env` to Git.** It is listed in `.gitignore`.

---

## 5 — Keycloak Prerequisites

Ensure the `bomiq` realm client `bomiq-sdm` has:

- **Valid Redirect URIs** includes: `http://localhost:5000/*` and `http://localhost:5000/auth/callback`
- **Valid Post Logout Redirect URIs** includes: `http://localhost:5000/*`
- **Web Origins** includes: `http://localhost:5000`
- **Authentication flow**: Standard flow ✅ (Direct access grants optional)
- **Advanced → Proof Key for Code Exchange**: S256 enforced

These are already configured if you used the provided `keycloak/bomiq-realm.json`.

---

## 6 — Run with Gunicorn (recommended)

```bash
# Ensure .venv is activated
source .venv/bin/activate

# Run with gunicorn (gthread worker — required for SSE streaming)
gunicorn -c gunicorn.conf.py wsgi:app
```

You should see:
```
[INFO] Starting gunicorn 23.0.0
[INFO] Listening at: http://0.0.0.0:5000
[INFO] Worker class: gthread
[INFO] Booting worker with pid: XXXXX
```

Open: **http://localhost:5000**

---

## 7 — Run with Flask Dev Server (development only)

```bash
source .venv/bin/activate
python wsgi.py
```

> ⚠️ Flask dev server does not support concurrent SSE streams reliably. Use gunicorn for testing the full chat experience.

---

## 8 — Stopping the Server

```bash
# Gunicorn: Ctrl+C or
pkill -f "gunicorn"

# Deactivate venv when done
deactivate
```

---

## Available Chat Prompts

### BOM Validation (multi-API + Excel report)
```
Validate BOM BOM-EC5000-001
Check BOM-EC5000-002 for compliance issues
Audit the main gateway BOM
Run full validation on BOM BOM-EC5000-003
```

### BOM Queries
```
List all BOMs
Show released BOMs
Show draft BOMs
Show details for BOM BOM-EC5000-001
What is the cost of BOM BOM-EC5000-001?
Show the BOM hierarchy tree
```

### Components
```
List all components
Show all obsolete and NRND parts
Find components matching "capacitor"
Show active components
```

### Suppliers
```
List all suppliers
Show Tier 1 suppliers
List Tier 2 vendors
```

### Platform
```
Show platform statistics
Help
```

---

## Project Structure

```
flask-chatbot/
├── app/
│   ├── __init__.py          # Flask application factory
│   ├── auth/
│   │   ├── pkce.py          # PKCE code verifier/challenge (RFC 7636)
│   │   ├── token_store.py   # Session-backed token storage
│   │   ├── decorators.py    # @login_required
│   │   └── routes.py        # /auth/login, /auth/callback, /auth/logout
│   ├── bom/
│   │   └── client.py        # Spring Boot REST API client (all endpoints)
│   ├── chat/
│   │   ├── intent.py        # LangGraph + Claude intent detection
│   │   ├── handlers.py      # One handler per intent, SSE generators
│   │   └── routes.py        # /, /chat, /chat/stream, /chat/download
│   ├── excel/
│   │   └── builder.py       # openpyxl multi-tab workbook generation
│   ├── static/
│   │   ├── css/chatbot.css
│   │   └── js/chatbot.js    # SSE consumer + markdown renderer
│   └── templates/
│       ├── base.html
│       ├── home.html
│       ├── auth/error.html
│       └── chat/index.html
├── config/
│   └── settings.py          # All config from .env
├── downloads/               # Generated .xlsx files (gitignored)
├── wsgi.py                  # WSGI entry point
├── gunicorn.conf.py         # Gunicorn config (gthread, port 5000)
├── requirements.txt
├── .env.example             # Template — copy to .env and fill in
├── .gitignore               # Excludes .env, .venv, downloads/
└── README.md                # This file
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `FLASK_SECRET_KEY` not set error | Missing `.env` | Copy `.env.example` → `.env` |
| 401 after Keycloak login | Redirect URI mismatch | Add `http://localhost:5000/auth/callback` to Keycloak |
| SSE stream cuts off | Using Flask dev server | Use `gunicorn -c gunicorn.conf.py wsgi:app` |
| Excel download 404 | `downloads/` missing | It is auto-created; check disk permissions |
| `anthropic.AuthenticationError` | Bad API key | Verify `ANTHROPIC_API_KEY` in `.env` |
| Spring Boot API returns 401 | Expired session token | Log out and log back in |
| `ModuleNotFoundError` | venv not active | Run `source .venv/bin/activate` |


cd /path/to/flask-chatbot
deactivate                        # exit whatever venv is active
rm -rf .venv                      # blow away the broken one
python3 -m venv .venv             # fresh venv using system python3
source .venv/bin/activate         # activate it

which python3
# Must show: /path/to/flask-chatbot/.venv/bin/python3

which pip
# Must show: /path/to/flask-chatbot/.venv/bin/pip


python3 -m pip install --upgrade pip       # use python3 -m pip, NOT bare pip
pip install -r requirements.txt

python3 -c "import secrets; print(secrets.token_hex(32))"
