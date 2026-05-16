"""
app/chat/handlers.py  —  One handler per intent, SSE generators.
Token is passed explicitly to avoid Flask context issues inside generators.
"""
import json
import os
from typing import Generator
import anthropic
from config import settings
from app.bom       import client as api
from app.chat.intent import IntentState
from app.excel.builder import (build_validation_report,
                                build_component_report,
                                build_supplier_report)


def _sse(text: str) -> str:
    return f"data: {json.dumps({'text': text})}\n\n"


def _sse_download(path: str) -> str:
    filename = os.path.basename(path)
    return f"data: {json.dumps({'download': {'filename': filename, 'url': f'/chat/download/{filename}'}})}\n\n"


def _sse_done() -> str:
    return "data: [DONE]\n\n"


def _stream_claude(system: str, user: str) -> Generator[str, None, None]:
    client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)
    with client.messages.stream(
        model=settings.CLAUDE_MODEL,
        max_tokens=2048,
        system=system,
        messages=[{"role": "user", "content": user}],
    ) as stream:
        for text in stream.text_stream:
            yield _sse(text)


# ── VALIDATE_BOM ──────────────────────────────────────────
def handle_validate_bom(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🔍 **BOM Validation** — starting...\n\n")

    bom_number = state.get("bom_number")
    if not bom_number:
        yield _sse("⚠️ Please specify a BOM number, e.g. *Validate BOM BOM-EC5000-001*\n")
        yield _sse_done(); return

    yield _sse(f"📋 Fetching BOM `{bom_number}`...\n")
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n")
        yield _sse_done(); return

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

    summary = f"""
BOM: {bom.get('bomNumber')} — {bom.get('bomTitle')}
Status: {bom.get('bomStatus')} | Revision: {bom.get('bomRevision')}
Total Material Cost: {cost.get('totalMaterialCost')} {cost.get('currencyCode','USD')}
Line Items: {cost.get('lineItemCount', 0)}  Child BOMs: {len(children)}

Compliance Issues ({len(issues)}):
{json.dumps(issues[:10], indent=2) if issues else 'None'}

Supplier Risks ({len(sup_risks)}):
{json.dumps(sup_risks[:10], indent=2) if sup_risks else 'None'}

BOM Lines sample (first 5):
{json.dumps(lines[:5], indent=2)}
"""
    yield from _stream_claude(
        "You are a senior BOM validation specialist. Analyze the BOM and give: "
        "1) Overall health (GREEN/YELLOW/RED) 2) Key findings 3) Recommendations 4) Risk summary. "
        "Be concise, technical, and actionable. Use bullet points.",
        f"Validate this BOM:\n{summary}\n\nOriginal request: {state['prompt']}"
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
        yield _sse("No BOMs found.\n"); yield _sse_done(); return
    lines_text = "\n".join(
        f"- `{b.get('bomNumber')}` — {b.get('bomTitle')} [{b.get('bomStatus')}]"
        for b in boms[:20]
    )
    yield from _stream_claude(
        "You are a helpful BOM data assistant. Present the BOM list clearly.",
        f"Here are the BOMs:\n{lines_text}\n\nUser asked: {state['prompt']}"
    )
    yield _sse_done()


# ── GET_BOM_DETAIL ────────────────────────────────────────
def handle_bom_detail(state: IntentState, token: str) -> Generator[str, None, None]:
    bom_number = state.get("bom_number")
    if not bom_number:
        yield _sse("Please specify a BOM number.\n"); yield _sse_done(); return
    yield _sse(f"📋 Fetching details for `{bom_number}`...\n\n")
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n"); yield _sse_done(); return
    lines = api.get_bom_lines(token, bom["id"])
    cost  = api.get_bom_cost(token, bom["id"])
    yield from _stream_claude(
        "You are a BOM data assistant. Summarize the BOM details clearly.",
        f"BOM:\n{json.dumps(bom, indent=2)}\nCost:\n{json.dumps(cost, indent=2)}\n"
        f"Line items: {len(lines)}\nUser asked: {state['prompt']}"
    )
    yield _sse_done()


# ── BOM_HIERARCHY ─────────────────────────────────────────
def handle_bom_hierarchy(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🌳 **BOM Hierarchy**\n\n")
    hierarchy = api.get_bom_hierarchy(token)

    def fmt(nodes):
        lines = []
        for node in nodes:
            b = node.get("bom", {})
            lines.append(f"`{b.get('bomNumber')}` — {b.get('bomTitle')}")
            for c in node.get("children", []):
                lines.append(f"  └─ `{c.get('bomNumber')}` — {c.get('bomTitle')}")
        return "\n".join(lines)

    yield from _stream_claude(
        "You are a BOM data assistant. Describe the BOM hierarchy.",
        f"Hierarchy:\n{fmt(hierarchy)}\n\nUser asked: {state['prompt']}"
    )
    yield _sse_done()


# ── BOM_COST ──────────────────────────────────────────────
def handle_bom_cost(state: IntentState, token: str) -> Generator[str, None, None]:
    bom_number = state.get("bom_number")
    if not bom_number:
        stats = api.get_bom_stats(token)
        yield from _stream_claude(
            "You are a cost analyst. Summarize BOM cost data.",
            f"Stats: {json.dumps(stats)}\nUser asked: {state['prompt']}"
        )
        yield _sse_done(); return
    bom = api.find_bom_by_number(token, bom_number)
    if not bom:
        yield _sse(f"❌ BOM `{bom_number}` not found.\n"); yield _sse_done(); return
    cost = api.get_bom_cost(token, bom["id"])
    yield from _stream_claude(
        "You are a cost analyst. Explain the BOM cost breakdown clearly.",
        f"Cost:\n{json.dumps(cost, indent=2)}\nUser asked: {state['prompt']}"
    )
    yield _sse_done()


# ── LIST_COMPONENTS ───────────────────────────────────────
def handle_list_components(state: IntentState, token: str) -> Generator[str, None, None]:
    yield _sse("🔧 **Component Library**\n\n")
    comps = api.list_components(token, keyword=state.get("keyword"))
    yield from _stream_claude(
        "You are a parts librarian. Summarize the components list.",
        f"Components ({len(comps)} total, first 20):\n{json.dumps(comps[:20], indent=2)}\n"
        f"User asked: {state['prompt']}"
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
        f"User asked: {state['prompt']}"
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
        f"User asked: {state['prompt']}"
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
        f"Stats:\n{json.dumps(stats, indent=2)}\nUser asked: {state['prompt']}"
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
        state["prompt"]
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