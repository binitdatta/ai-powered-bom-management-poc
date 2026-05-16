#!/bin/bash
# ============================================================
# bomiq SDM — REST API Test Script (macOS compatible)
# Usage: ./test-api.sh [username] [password]
# ============================================================

BASE_URL="http://localhost:9086/bomiq/api/v1"
KC_URL="http://localhost:8080/realms/bomiq/protocol/openid-connect/token"
CLIENT_ID="bomiq-sdm"
USERNAME="${1:-engineer1}"
PASSWORD="${2:-engineer123}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

pass() { echo -e "${GREEN}  ✓ PASS${NC} $1"; }
fail() { echo -e "${RED}  ✗ FAIL${NC} $1"; }
info() { echo -e "${CYAN}  → ${NC}$1"; }
section() { echo -e "\n${YELLOW}━━━ $1 ━━━${NC}"; }

# ── 1. Get Access Token ────────────────────────────────────
section "Authenticate via Keycloak"
info "User: $USERNAME | Realm: bomiq | Client: $CLIENT_ID"

TOKEN_RESPONSE=$(curl -s -X POST "$KC_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=$CLIENT_ID" \
  -d "username=$USERNAME" \
  -d "password=$PASSWORD" \
  -d "scope=openid profile email roles")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

if [ -z "$ACCESS_TOKEN" ]; then
    fail "Authentication failed"
    echo "  Response: $(echo "$TOKEN_RESPONSE" | jq -r '.error_description // .error // .')"
    exit 1
fi

pass "Access token obtained (${#ACCESS_TOKEN} chars)"
info "Token: ${ACCESS_TOKEN:0:50}..."

# Helper: call API and return response — macOS compatible
call() {
    local METHOD="$1" ENDPOINT="$2" DESC="$3" JQ_FILTER="${4:-.}"
    local TMPFILE
    TMPFILE=$(mktemp)
    HTTP_CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" -X "$METHOD" \
      "${BASE_URL}${ENDPOINT}" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Accept: application/json")
    BODY=$(cat "$TMPFILE")
    rm -f "$TMPFILE"

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
        pass "[$HTTP_CODE] $DESC"
        echo "$BODY" | jq "$JQ_FILTER" 2>/dev/null || echo "$BODY"
    else
        fail "[$HTTP_CODE] $DESC"
        echo "  $(echo "$BODY" | jq -c '.' 2>/dev/null || echo "$BODY")"
    fi
    echo ""
}

# ── 2. Public Health ───────────────────────────────────────
section "Public Endpoint (no token)"
TMPFILE=$(mktemp)
HTTP_CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" "$BASE_URL/public/health")
BODY=$(cat "$TMPFILE"); rm -f "$TMPFILE"
if [ "$HTTP_CODE" == "200" ]; then
    pass "[200] Public health check"
    echo "$BODY" | jq '.data'
else
    fail "[$HTTP_CODE] Public health check"
    echo "$BODY"
fi
echo ""

# ── 3. BOMs ───────────────────────────────────────────────
section "BOMs"
call GET "/boms"              "List all active BOMs"        '{count: (.data|length), first: .data[0].bomNumber}'
call GET "/boms/stats/summary" "BOM statistics"             '.data'
call GET "/boms/hierarchy"    "BOM hierarchy tree"          '{rootCount: (.data|length)}'
call GET "/boms/1"            "BOM detail (id=1)"           '{bomNumber:.data.bomNumber, lineItems:(.data.lineItems|length)}'
call GET "/boms/1/lines"      "BOM line items (id=1)"       '{count:(.data|length)}'
call GET "/boms/1/cost-summary" "BOM cost summary (id=1)"   '.data'
call GET "/boms/1/children"   "Child BOMs (id=1)"           '{count:(.data|length)}'
call GET "/boms/1/validation-payload" "Validation payload (id=1)" \
    '{lineItemCount:.data.lineItemCount, complianceIssues:(.data.complianceIssues|length), supplierRisks:(.data.supplierRisks|length)}'

# ── 4. Components ─────────────────────────────────────────
section "Components"
call GET "/components"              "List all components"           '{count:(.data|length), first:.data[0].partNumber}'
call GET "/components/1"            "Component detail (id=1)"       '{partNumber:.data.partNumber, lifecycle:.data.lifecycleStatus}'
call GET "/components/lifecycle/ACTIVE" "Components lifecycle=ACTIVE"  '{count:(.data|length)}'
call GET "/components/by-supplier/1"   "Components by supplier (id=1)" '{count:(.data|length)}'

# ── 5. Suppliers ──────────────────────────────────────────
section "Suppliers"
call GET "/suppliers"           "List all suppliers"            '{count:(.data|length)}'
call GET "/suppliers/1"         "Supplier detail (id=1)"        '{code:.data.supplierCode, name:.data.legalName}'
call GET "/suppliers?tier=TIER1" "Suppliers tier=TIER1"         '{count:(.data|length)}'

# ── 6. Products ───────────────────────────────────────────
section "Products"
call GET "/products"            "List all active products"       '{count:(.data|length)}'
call GET "/products/1/boms"     "BOMs for product (id=1)"        '{count:(.data|length)}'

# ── 7. Security check ─────────────────────────────────────
section "Security Verification"
info "Calling /api/v1/boms without token — expect 401"
TMPFILE=$(mktemp)
HTTP_CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" "$BASE_URL/boms")
rm -f "$TMPFILE"
if [ "$HTTP_CODE" == "401" ]; then
    pass "[401] Unauthenticated request correctly rejected"
else
    fail "[${HTTP_CODE}] Expected 401, got ${HTTP_CODE}"
fi

echo -e "\n${GREEN}━━━ Test run complete ━━━${NC}\n"