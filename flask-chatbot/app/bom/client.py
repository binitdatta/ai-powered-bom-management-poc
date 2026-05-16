"""
app/bom/client.py  —  Spring Boot REST API client
Token is passed explicitly — never read from Flask session inside generators.
"""
import requests
from typing import Any, Optional
from config import settings


def _headers(token: str) -> dict:
    return {
        "Authorization": f"Bearer {token}",
        "Accept":        "application/json",
    }


def _get(path: str, token: str, params: Optional[dict] = None) -> Any:
    url  = f"{settings.SPRING_API_BASE_URL}{path}"
    resp = requests.get(url, headers=_headers(token), params=params, timeout=15)
    resp.raise_for_status()
    return resp.json().get("data", resp.json())


# ── BOMs ──────────────────────────────────────────────────
def list_boms(token: str, status: str = None, product_id: int = None) -> list:
    params = {}
    if status:     params["status"]    = status
    if product_id: params["productId"] = product_id
    return _get("/boms", token, params)


def get_bom(token: str, bom_id: int) -> dict:
    return _get(f"/boms/{bom_id}", token)


def get_bom_lines(token: str, bom_id: int) -> list:
    return _get(f"/boms/{bom_id}/lines", token)


def get_bom_cost(token: str, bom_id: int) -> dict:
    return _get(f"/boms/{bom_id}/cost-summary", token)


def get_bom_children(token: str, bom_id: int) -> list:
    return _get(f"/boms/{bom_id}/children", token)


def get_bom_hierarchy(token: str) -> list:
    return _get("/boms/hierarchy", token)


def get_bom_stats(token: str) -> dict:
    return _get("/boms/stats/summary", token)


def get_validation_payload(token: str, bom_id: int) -> dict:
    return _get(f"/boms/{bom_id}/validation-payload", token)


def find_bom_by_number(token: str, bom_number: str) -> Optional[dict]:
    boms = list_boms(token)
    num  = bom_number.upper().strip()
    for b in boms:
        if b.get("bomNumber", "").upper() == num:
            return b
    return None


# ── Components ────────────────────────────────────────────
def list_components(token: str, keyword: str = None) -> list:
    params = {"keyword": keyword} if keyword else {}
    return _get("/components", token, params)


def get_component(token: str, comp_id: int) -> dict:
    return _get(f"/components/{comp_id}", token)


def components_by_lifecycle(token: str, status: str) -> list:
    return _get(f"/components/lifecycle/{status}", token)


def components_by_supplier(token: str, supplier_id: int) -> list:
    return _get(f"/components/by-supplier/{supplier_id}", token)


# ── Suppliers ─────────────────────────────────────────────
def list_suppliers(token: str, tier: str = None) -> list:
    params = {"tier": tier} if tier else {}
    return _get("/suppliers", token, params)


def get_supplier(token: str, sup_id: int) -> dict:
    return _get(f"/suppliers/{sup_id}", token)


# ── Products ──────────────────────────────────────────────
def list_products(token: str) -> list:
    return _get("/products", token)


def product_boms(token: str, product_id: int) -> list:
    return _get(f"/products/{product_id}/boms", token)