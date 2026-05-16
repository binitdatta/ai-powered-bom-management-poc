"""
app/chat/intent.py  —  LangGraph-based intent detection + orchestration

Intents handled:
  VALIDATE_BOM      — full BOM validation with Excel report
  LIST_BOMS         — list all BOMs or by status
  GET_BOM_DETAIL    — detail for a specific BOM
  BOM_HIERARCHY     — show BOM tree
  BOM_COST          — cost breakdown for a BOM
  LIST_COMPONENTS   — list components, optionally filtered
  OBSOLETE_PARTS    — find obsolete/NRND components
  LIST_SUPPLIERS    — list suppliers, optionally by tier
  BOM_STATS         — platform statistics
  HELP              — show available commands
  UNKNOWN           — fallback
"""
import re
import json
from typing import TypedDict, Annotated, Optional
from langgraph.graph import StateGraph, END
import anthropic
from config import settings


class IntentState(TypedDict):
    prompt:       str
    intent:       str
    bom_number:   Optional[str]
    bom_id:       Optional[int]
    lifecycle:    Optional[str]
    tier:         Optional[str]
    keyword:      Optional[str]
    status_filter: Optional[str]
    error:        Optional[str]


_SYSTEM_PROMPT = """You are an intent classifier for bomiq SDM, a Bill of Materials management system.

Given a user's natural language prompt, respond with a JSON object (no markdown, no prose) with:
{
  "intent": "<one of the intents below>",
  "bom_number": "<BOM number like BOM-EC5000-001 if mentioned, else null>",
  "lifecycle": "<ACTIVE|OBSOLETE|NRND|NEW|PROTOTYPE if mentioned, else null>",
  "tier": "<TIER1|TIER2|TIER3 if mentioned, else null>",
  "keyword": "<search keyword if mentioned, else null>",
  "status_filter": "<DRAFT|IN_REVIEW|APPROVED|RELEASED|OBSOLETE if mentioned, else null>"
}

Intents:
- VALIDATE_BOM       : user wants to validate, check, audit, review, assess a BOM
- LIST_BOMS          : user wants to see/list/show all or filtered BOMs
- GET_BOM_DETAIL     : user wants details of a specific BOM
- BOM_HIERARCHY      : user asks about BOM tree, parent-child relationships, hierarchy
- BOM_COST           : user asks about cost, price, total, budget of a BOM
- LIST_COMPONENTS    : user wants to see components, parts, list parts
- OBSOLETE_PARTS     : user asks about obsolete, NRND, end-of-life, discontinued components
- LIST_SUPPLIERS     : user wants to see suppliers, vendors
- BOM_STATS          : user asks for statistics, summary, counts, dashboard overview
- HELP               : user asks for help, what can you do, commands
- UNKNOWN            : none of the above
"""


def detect_intent(prompt: str) -> IntentState:
    """Use Claude to detect intent from natural language prompt."""
    client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)
    msg = client.messages.create(
        model=settings.CLAUDE_MODEL,
        max_tokens=300,
        system=_SYSTEM_PROMPT,
        messages=[{"role": "user", "content": prompt}],
    )
    raw = msg.content[0].text.strip()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        # Fallback: try to extract JSON from the response
        match = re.search(r'\{.*\}', raw, re.DOTALL)
        if match:
            data = json.loads(match.group())
        else:
            data = {"intent": "UNKNOWN"}

    return IntentState(
        prompt        = prompt,
        intent        = data.get("intent", "UNKNOWN"),
        bom_number    = data.get("bom_number"),
        bom_id        = None,
        lifecycle     = data.get("lifecycle"),
        tier          = data.get("tier"),
        keyword       = data.get("keyword"),
        status_filter = data.get("status_filter"),
        error         = None,
    )
