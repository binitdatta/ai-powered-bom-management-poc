"""
app/chat/handlers.py  —  One handler per intent, SSE generators.
Token is passed explicitly to avoid Flask context issues inside generators.
All Anthropic calls are wrapped with full audit trail logging.
"""
import json
import logging
import os
import time
import uuid
from datetime import datetime, timezone
from typing import Any, Generator

import anthropic

from config import settings
from app.bom import client as api
from app.chat.intent import IntentState
from app.excel.builder import (
    build_validation_report,
    build_component_report,
    build_supplier_report,
)


# ── SSE helpers ───────────────────────────────────────────

def _sse(text: str) -> str:
    return f"data: {json.dumps({'text': text})}\n\n"


def _sse_download(path: str) -> str:
    filename = os.path.basename(path)
    return f"data: {json.dumps({'download': {'filename': filename, 'url': f'/chat/download/{filename}'}})}\n\n"


def _sse_done() -> str:
    return "data: [DONE]\n\n"


# ── Audit helpers ─────────────────────────────────────────
# NOTE: logging.getLogger() is called inside every function — never at module
# level — so it always resolves AFTER gunicorn post_fork attaches handlers.

def _make_request_id(label: str) -> str:
    ts  = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%f")
    uid = uuid.uuid4().hex[:6]
    return f"{label}:{ts}:{uid}"


def _serialize(obj: Any) -> Any:
    if hasattr(obj, "model_dump"):
        return obj.model_dump()
    if hasattr(obj, "__dict__"):
        return vars(obj)
    return str(obj)


def _log_request(request_id: str, payload: dict) -> None:
    logging.getLogger("anthropic.audit").info(
        "\n╔══ ANTHROPIC REQUEST  [%s] ══\n%s\n╚═══════════════════════════════════════",
        request_id,
        json.dumps(payload, indent=2, default=_serialize),
    )


# Pricing per million tokens — update if model changes
_COST_PER_M_INPUT  = 3.00   # USD
_COST_PER_M_OUTPUT = 15.00  # USD


def _calculate_cost(usage: dict) -> tuple[float, str]:
    input_tokens  = usage.get("input_tokens", 0)
    output_tokens = usage.get("output_tokens", 0)
    cache_read    = usage.get("cache_read_input_tokens", 0)
    cost = (
        ((input_tokens - cache_read) * _COST_PER_M_INPUT / 1_000_000) +
        (cache_read                  * (_COST_PER_M_INPUT * 0.1) / 1_000_000) +  # cache reads are 90% cheaper
        (output_tokens               * _COST_PER_M_OUTPUT / 1_000_000)
    )
    summary = (
        f"input={input_tokens} output={output_tokens} cache_read={cache_read} "
        f"→ ${cost:.6f} USD"
    )
    return cost, summary


def _log_response(request_id: str, response: Any, elapsed: float) -> None:
    serialized = _serialize(response)
    usage      = serialized.get("usage", {}) if isinstance(serialized, dict) else {}
    _, cost_summary = _calculate_cost(usage)

    logging.getLogger("anthropic.audit").info(
        "\n╔══ ANTHROPIC RESPONSE [%s]  (%.3fs) ══\n"
        "    COST: %s\n"
        "%s\n╚═══════════════════════════════════════",
        request_id,
        elapsed,
        cost_summary,
        json.dumps(serialized, indent=2, default=_serialize),
    )


def _log_error(request_id: str, exc: Exception, elapsed: float) -> None:
    logging.getLogger("anthropic.audit").error(
        "\n╔══ ANTHROPIC ERROR    [%s]  (%.3fs) ══\n%s\n╚═══════════════════════════════════════",
        request_id,
        elapsed,
        str(exc),
    )


# ── Core Claude streaming wrapper ─────────────────────────

def _stream_claude(
    system: str,
    user: str,
    *,
    label: str = "stream_claude",
) -> Generator[str, None, None]:
    client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)

    request_payload = {
        "model":      settings.CLAUDE_MODEL,
        "max_tokens": 2048,
        "system":     system,
        "messages":   [{"role": "user", "content": user}],
    }

    request_id = _make_request_id(label)
    _log_request(request_id, request_payload)

    start  = time.perf_counter()
    chunks = []

    try:
        with client.messages.stream(**request_payload) as stream:
            logging.getLogger("anthropic.audit").info(
                "╔══ ANTHROPIC STREAM START [%s]  (connected %.3fs) ══",
                request_id,
                time.perf_counter() - start,
            )
            for text in stream.text_stream:
                chunks.append(text)
                logging.getLogger("anthropic.audit").debug(
                    "[%s] CHUNK: %s", request_id, json.dumps(text),
                )
                yield _sse(text)

            final   = stream.get_final_message()
            elapsed = time.perf_counter() - start
            _log_response(request_id, final, elapsed)
            logging.getLogger("anthropic.audit").info(
                "╔══ ANTHROPIC STREAM END   [%s]  (%.3fs | %d chunks | ~%d chars) ══",
                request_id,
                elapsed,
                len(chunks),
                sum(len(c) for c in chunks),
            )

    except Exception as exc:
        _log_error(request_id, exc, time.perf_counter() - start)
        raise


# ── VALIDATE_BOM ──────────────────────────────────────────

def handle_validate_bom(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🔍 **BOM Validation** — starting...\n\n")

    bom_number = state.get("bom_number")
    if not bom_number:
        yield _sse("⚠️ Please specify a BOM number, e.g. *Validate BOM BOM-EC5000-001*\n")
        yield _sse_done()
        return

    yield _sse(f"📋 Fetching BOM `{bom_number}`...\n")
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n")
        yield _sse_done()
        return

    bom_id = bom["id"]
    yield _sse("📦 Fetching line items...\n")
    lines = api.get_bom_lines(token, bom_id)

    yield _sse("💰 Fetching cost summary...\n")
    cost = api.get_bom_cost(token, bom_id)

    yield _sse("👶 Fetching child BOMs...\n")
    children = api.get_bom_children(token, bom_id)

    yield _sse("🔬 Fetching validation payload...\n")
    payload = api.get_validation_payload(token, bom_id)

    yield _sse("🏭 Fetching all components...\n")
    components = api.list_components(token)

    yield _sse("🚚 Fetching suppliers...\n")
    suppliers = api.list_suppliers(token)

    yield _sse("\n---\n\n🤖 **AI Analysis** (Claude Sonnet):\n\n")

    issues    = payload.get("complianceIssues", [])
    sup_risks = payload.get("supplierRisks", [])

    summary = (
        f"BOM: {bom.get('bomNumber')} — {bom.get('bomTitle')}\n"
        f"Status: {bom.get('bomStatus')} | Revision: {bom.get('bomRevision')}\n"
        f"Total Material Cost: {cost.get('totalMaterialCost')} {cost.get('currencyCode', 'USD')}\n"
        f"Line Items: {cost.get('lineItemCount', 0)}  Child BOMs: {len(children)}\n\n"
        f"Compliance Issues ({len(issues)}):\n"
        f"{json.dumps(issues[:10], indent=2) if issues else 'None'}\n\n"
        f"Supplier Risks ({len(sup_risks)}):\n"
        f"{json.dumps(sup_risks[:10], indent=2) if sup_risks else 'None'}\n\n"
        f"BOM Lines sample (first 5):\n{json.dumps(lines[:5], indent=2)}"
    )

    yield from _stream_claude(
        "You are a senior BOM validation specialist. Analyze the BOM and give: "
        "1) Overall health (GREEN/YELLOW/RED) 2) Key findings 3) Recommendations 4) Risk summary. "
        "Be concise, technical, and actionable. Use bullet points.",
        f"Validate this BOM:\n{summary}\n\nOriginal request: {state['prompt']}",
        label="handle_validate_bom",
    )

    yield _sse("\n\n---\n\n📊 **Generating Excel Report**...\n")
    try:
        filepath = build_validation_report(
            bom_header=bom, bom_lines=lines, cost_summary=cost,
            children=children, components=components, suppliers=suppliers,
            validation_payload=payload, username="analyst", prompt=state["prompt"],
        )
        yield _sse(f"✅ Excel report ready: **{os.path.basename(filepath)}**\n\n")
        yield _sse_download(filepath)
    except Exception as e:
        yield _sse(f"⚠️ Excel generation failed: {e}\n")
    yield _sse_done()


# ── LIST_BOMS ─────────────────────────────────────────────

def handle_list_boms(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("📋 **BOM List**\n\n")
    boms = api.list_boms(token, status=state.get("status_filter"))
    if not boms:
        yield _sse("No BOMs found.\n")
        yield _sse_done()
        return
    lines_text = "\n".join(
        f"- `{b.get('bomNumber')}` — {b.get('bomTitle')} [{b.get('bomStatus')}]"
        for b in boms[:20]
    )
    yield from _stream_claude(
        "You are a helpful BOM data assistant. Present the BOM list clearly.",
        f"Here are the BOMs:\n{lines_text}\n\nUser asked: {state['prompt']}",
        label="handle_list_boms",
    )
    yield _sse_done()


# ── GET_BOM_DETAIL ────────────────────────────────────────

def handle_bom_detail(state: IntentState, token: str) -> Generator[str, None, None]:
    bom_number = state.get("bom_number")
    if not bom_number:
        yield _sse("Please specify a BOM number.\n")
        yield _sse_done()
        return
    yield _sse(f"📋 Fetching details for `{bom_number}`...\n\n")
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n")
        yield _sse_done()
        return
    lines = api.get_bom_lines(token, bom["id"])
    cost  = api.get_bom_cost(token, bom["id"])
    yield from _stream_claude(
        "You are a BOM data assistant. Summarize the BOM details clearly.",
        f"BOM:\n{json.dumps(bom, indent=2)}\nCost:\n{json.dumps(cost, indent=2)}\n"
        f"Line items: {len(lines)}\nUser asked: {state['prompt']}",
        label="handle_bom_detail",
    )
    yield _sse_done()


# ── BOM_HIERARCHY ─────────────────────────────────────────

def handle_bom_hierarchy(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🌳 **BOM Hierarchy**\n\n")
    hierarchy = api.get_bom_hierarchy(token)

    def fmt(nodes):
        out = []
        for node in nodes:
            b = node.get("bom", {})
            out.append(f"`{b.get('bomNumber')}` — {b.get('bomTitle')}")
            for c in node.get("children", []):
                out.append(f"  └─ `{c.get('bomNumber')}` — {c.get('bomTitle')}")
        return "\n".join(out)

    yield from _stream_claude(
        "You are a BOM data assistant. Describe the BOM hierarchy.",
        f"Hierarchy:\n{fmt(hierarchy)}\n\nUser asked: {state['prompt']}",
        label="handle_bom_hierarchy",
    )
    yield _sse_done()


# ── BOM_COST ──────────────────────────────────────────────

def handle_bom_cost(state: IntentState, token: str) -> Generator[str, None, None]:
    bom_number = state.get("bom_number")
    if not bom_number:
        stats = api.get_bom_stats(token)
        yield from _stream_claude(
            "You are a cost analyst. Summarize BOM cost data.",
            f"Stats: {json.dumps(stats)}\nUser asked: {state['prompt']}",
            label="handle_bom_cost.stats",
        )
        yield _sse_done()
        return
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n")
        yield _sse_done()
        return
    cost = api.get_bom_cost(token, bom["id"])
    yield from _stream_claude(
        "You are a cost analyst. Explain the BOM cost breakdown clearly.",
        f"Cost:\n{json.dumps(cost, indent=2)}\nUser asked: {state['prompt']}",
        label="handle_bom_cost.detail",
    )
    yield _sse_done()


# ── LIST_COMPONENTS ───────────────────────────────────────

def handle_list_components(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🔧 **Component Library**\n\n")
    comps = api.list_components(token, keyword=state.get("keyword"))
    yield from _stream_claude(
        "You are a parts librarian. Summarize the components list.",
        f"Components ({len(comps)} total, first 20):\n{json.dumps(comps[:20], indent=2)}\n"
        f"User asked: {state['prompt']}",
        label="handle_list_components",
    )
    yield _sse("\n\n📊 Generating component report...\n")
    try:
        filepath = build_component_report(comps)
        yield _sse(f"✅ Report ready: **{os.path.basename(filepath)}**\n\n")
        yield _sse_download(filepath)
    except Exception as e:
        yield _sse(f"⚠️ Report failed: {e}\n")
    yield _sse_done()


# ── OBSOLETE_PARTS ────────────────────────────────────────

def handle_obsolete_parts(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("⚠️ **Obsolete & NRND Components**\n\n")
    obsolete = api.components_by_lifecycle(token, "OBSOLETE")
    nrnd     = api.components_by_lifecycle(token, "NRND")
    all_risk = obsolete + nrnd
    yield from _stream_claude(
        "You are a compliance specialist. Flag risks from obsolete/NRND components.",
        f"Obsolete ({len(obsolete)}): {json.dumps(obsolete[:10], indent=2)}\n"
        f"NRND ({len(nrnd)}): {json.dumps(nrnd[:10], indent=2)}\n"
        f"User asked: {state['prompt']}",
        label="handle_obsolete_parts",
    )
    if all_risk:
        yield _sse("\n\n📊 Generating risk report...\n")
        try:
            filepath = build_component_report(all_risk, title="Obsolete & NRND Components")
            yield _sse(f"✅ Report ready: **{os.path.basename(filepath)}**\n\n")
            yield _sse_download(filepath)
        except Exception as e:
            yield _sse(f"⚠️ Report failed: {e}\n")
    yield _sse_done()


# ── LIST_SUPPLIERS ────────────────────────────────────────

def handle_list_suppliers(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🏭 **Supplier Registry**\n\n")
    suppliers = api.list_suppliers(token, tier=state.get("tier"))
    yield from _stream_claude(
        "You are a supplier relationship manager. Summarize the supplier list.",
        f"Suppliers ({len(suppliers)}):\n{json.dumps(suppliers[:15], indent=2)}\n"
        f"User asked: {state['prompt']}",
        label="handle_list_suppliers",
    )
    yield _sse("\n\n📊 Generating supplier report...\n")
    try:
        filepath = build_supplier_report(suppliers)
        yield _sse(f"✅ Report ready: **{os.path.basename(filepath)}**\n\n")
        yield _sse_download(filepath)
    except Exception as e:
        yield _sse(f"⚠️ Report failed: {e}\n")
    yield _sse_done()


# ── BOM_STATS ─────────────────────────────────────────────

def handle_bom_stats(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("📊 **Platform Statistics**\n\n")
    stats = api.get_bom_stats(token)
    yield from _stream_claude(
        "You are a data analyst. Present the platform statistics clearly.",
        f"Stats:\n{json.dumps(stats, indent=2)}\nUser asked: {state['prompt']}",
        label="handle_bom_stats",
    )
    yield _sse_done()


# ── HELP ──────────────────────────────────────────────────

def handle_help(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("""**bomiq SDM ChatBot — Available Commands**

**BOM Validation**
- *Validate BOM BOM-EC5000-001* — full AI validation + Excel report
- *Check BOM-EC5000-002 for compliance issues*

**BOM Queries**
- *List all BOMs* / *Show released BOMs* / *Show draft BOMs*
- *Show details for BOM BOM-EC5000-001*
- *Show the BOM hierarchy tree*
- *What is the cost of BOM BOM-EC5000-001?*

**Components**
- *List all components* / *Find components matching "capacitor"*
- *Show obsolete and NRND parts*

**Suppliers**
- *List all suppliers* / *Show Tier 1 suppliers*

**Platform**
- *Show platform statistics*
- *Help*
""")
    yield _sse_done()


# ── UNKNOWN ───────────────────────────────────────────────

def handle_unknown(state: IntentState, token: str) -> Generator[str, None, None]:
    yield from _stream_claude(
        "You are a helpful assistant for bomiq SDM. "
        "If unsure, suggest the user type 'help' to see available commands.",
        state["prompt"],
        label="handle_unknown",
    )
    yield _sse_done()


# ── Dispatcher ────────────────────────────────────────────

HANDLERS = {
    "VALIDATE_BOM":    handle_validate_bom,
    "LIST_BOMS":       handle_list_boms,
    "GET_BOM_DETAIL":  handle_bom_detail,
    "BOM_HIERARCHY":   handle_bom_hierarchy,
    "BOM_COST":        handle_bom_cost,
    "LIST_COMPONENTS": handle_list_components,
    "OBSOLETE_PARTS":  handle_obsolete_parts,
    "LIST_SUPPLIERS":  handle_list_suppliers,
    "BOM_STATS":       handle_bom_stats,
    "HELP":            handle_help,
    "UNKNOWN":         handle_unknown,
}


def dispatch(state: IntentState, token: str) -> Generator[str, None, None]:
    handler = HANDLERS.get(state["intent"], handle_unknown)
    yield from handler(state, token)