"""
app/__init__.py  —  Flask application factory
"""
import logging

from flask import Flask


def create_app() -> Flask:
    from config import settings

    app = Flask(__name__, template_folder="templates", static_folder="static")
    app.secret_key = settings.SECRET_KEY
    app.config["DEBUG"] = settings.DEBUG

    app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
    app.config["SESSION_COOKIE_SECURE"]   = False
    app.config["SESSION_COOKIE_HTTPONLY"] = True

    from app.auth.routes import auth_bp
    from app.chat.routes import chat_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(chat_bp, url_prefix="/")

    return app