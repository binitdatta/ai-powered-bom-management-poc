"""
app/auth/token_store.py  —  Session-backed token storage
"""
from flask import session
from typing import Optional


def save_tokens(access_token: str, id_token: str, refresh_token: str,
                username: str, roles: list[str]) -> None:
    session["access_token"]   = access_token
    session["id_token"]       = id_token
    session["refresh_token"]  = refresh_token
    session["username"]       = username
    session["roles"]          = roles
    session["authenticated"]  = True


def get_access_token() -> Optional[str]:
    return session.get("access_token")


def get_username() -> Optional[str]:
    return session.get("username")


def get_roles() -> list[str]:
    return session.get("roles", [])


def is_authenticated() -> bool:
    return session.get("authenticated", False)


def clear_session() -> None:
    session.clear()
