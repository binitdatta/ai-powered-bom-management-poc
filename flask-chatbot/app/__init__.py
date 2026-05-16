"""
app/__init__.py  —  Flask application factory
"""
from flask import Flask
from config import settings


def create_app() -> Flask:
    app = Flask(__name__, template_folder="templates", static_folder="static")
    app.secret_key = settings.SECRET_KEY
    app.config["DEBUG"] = settings.DEBUG

    # SameSite=Lax allows cookie to survive Keycloak redirect back to Flask
    app.config["SESSION_COOKIE_SAMESITE"]  = "Lax"
    app.config["SESSION_COOKIE_SECURE"]    = False
    app.config["SESSION_COOKIE_HTTPONLY"]  = True

    from app.auth.routes import auth_bp
    from app.chat.routes import chat_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(chat_bp, url_prefix="/")

    return app