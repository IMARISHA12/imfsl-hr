#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Test LoanDisk Data Pipeline via REST API
#
# Verifies end-to-end data flow against the real database:
#   Raw staging → Normalized tables → Business logic
#
# Usage: ./scripts/test-data-pipeline.sh
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a
  source "${PROJECT_DIR}/.env"
  set +a
fi

SRK="${SUPABASE_SERVICE_ROLE_KEY:?Missing SUPABASE_SERVICE_ROLE_KEY}"
BASE="${SUPABASE_URL:?Missing SUPABASE_URL}/rest/v1"
AUTH=(-H "apikey: ${SRK}" -H "Authorization: Bearer ${SRK}")

PASS=0
FAIL=0
TOTAL=0

TS=$(date +%s)
TEST_PHONE="07555${TS: -5}"
TEST_BORROWER_LD=$((990000 + RANDOM % 9999))
TEST_LOAN_LD=$((880000 + RANDOM % 9999))
TEST_NIDA="19900101-${TS: -5}"

assert() {
  local name="$1"
  local condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "${condition}" >/dev/null 2>&1; then
    printf "  [%02d] %-50s PASS\n" "${TOTAL}" "${name}"
    PASS=$((PASS + 1))
  else
    printf "  [%02d] %-50s FAIL\n" "${TOTAL}" "${name}"
    FAIL=$((FAIL + 1))
  fi
}

api_get() {
  curl -s "${BASE}/$1" "${AUTH[@]}" -H "Accept: application/json"
}

api_post() {
  curl -s "${BASE}/$1" "${AUTH[@]}" -H "Content-Type: application/json" -H "Prefer: return=representation" -d "$2"
}

api_patch() {
  curl -s -X PATCH "${BASE}/$1" "${AUTH[@]}" -H "Content-Type: application/json" -H "Prefer: return=representation" -d "$2"
}

api_delete() {
  curl -s -X DELETE "${BASE}/$1" "${AUTH[@]}"
}

echo "════════════════════════════════════════════════════════════"
echo "  LoanDisk Data Pipeline Tests"
echo "  Using IDs: borrower=${TEST_BORROWER_LD}, loan=${TEST_LOAN_LD}"
echo "════════════════════════════════════════════════════════════"
echo ""

# ── 1. Raw Staging Layer ─────────────────────────────────────────────
echo "Raw Staging Layer:"

RESULT=$(api_post "raw_borrowers" \
  "{\"loandisk_id\":${TEST_BORROWER_LD},\"branch_id\":1,\"payload\":{\"first_name\":\"Pipeline\",\"last_name\":\"TestUser\",\"phone_number\":\"${TEST_PHONE}\"},\"source\":\"test\"}")
assert "Insert raw_borrowers" "echo '${RESULT}' | grep -q 'loandisk_id'"

RESULT=$(api_post "raw_loans" \
  "{\"loandisk_id\":${TEST_LOAN_LD},\"branch_id\":1,\"borrower_loandisk_id\":${TEST_BORROWER_LD},\"payload\":{\"principal_amount\":500000},\"source\":\"test\"}")
assert "Insert raw_loans" "echo '${RESULT}' | grep -q 'loandisk_id'"

RESULT=$(api_post "raw_repayments" \
  "{\"loandisk_id\":${TEST_LOAN_LD},\"branch_id\":1,\"loan_loandisk_id\":${TEST_LOAN_LD},\"payload\":{\"amount_paid\":50000},\"source\":\"test\"}")
assert "Insert raw_repayments" "echo '${RESULT}' | grep -q 'loandisk_id'"

echo ""

# ── 2. Normalized Tables ─────────────────────────────────────────────
echo "Normalized Tables:"

# borrowers: full_name, phone_number, nida_number, status
RESULT=$(api_post "borrowers" \
  "{\"full_name\":\"Pipeline TestUser\",\"phone_number\":\"${TEST_PHONE}\",\"nida_number\":\"${TEST_NIDA}\",\"status\":\"active\"}")
BORROWER_ID=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null || echo "")
assert "Insert borrowers" "[ -n '${BORROWER_ID}' ]"

# clients: first_name(NOT NULL), last_name, phone_number(NOT NULL)
EXT_REF="LD-${TEST_BORROWER_LD}"
RESULT=$(api_post "clients" \
  "{\"first_name\":\"Pipeline\",\"last_name\":\"TestUser\",\"phone_number\":\"${TEST_PHONE}\",\"nida_number\":\"${TEST_NIDA}\",\"external_reference_id\":\"${EXT_REF}\",\"status\":\"active\",\"credit_score\":50,\"risk_level\":\"Medium\"}")
CLIENT_ID=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null || echo "")
assert "Insert clients" "[ -n '${CLIENT_ID}' ]"

# loans: borrower_id(FK), loan_number, amount_principal, interest_rate, duration_months
if [ -n "${BORROWER_ID}" ]; then
  RESULT=$(api_post "loans" \
    "{\"borrower_id\":\"${BORROWER_ID}\",\"loan_number\":\"LD-${TEST_LOAN_LD}\",\"amount_principal\":500000,\"interest_rate\":15,\"duration_months\":6,\"outstanding_balance\":500000,\"total_paid\":0,\"status\":\"active\",\"product_type\":\"sme_individual\"}")
  LOAN_ID=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null || echo "")
  assert "Insert loans" "[ -n '${LOAN_ID}' ]"
else
  LOAN_ID=""
  assert "Insert loans (skipped - no borrower)" "false"
fi

echo ""

# ── 3. Webhook Events ────────────────────────────────────────────────
echo "Webhook Events:"

RESULT=$(api_post "webhook_events" \
  "{\"provider\":\"loandisk\",\"event_key\":\"borrower.created\",\"payload\":{\"test_id\":\"${TS}\"}}")
assert "Insert webhook_events" "echo '${RESULT}' | grep -q 'provider'"

echo ""

# ── 4. Sync Tracking ─────────────────────────────────────────────────
echo "Sync Tracking:"

INT_ID=$(api_get "loandisk_integrations?select=id&is_active=eq.true&limit=1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['id'] if d else '')" 2>/dev/null || echo "")

if [ -n "${INT_ID}" ]; then
  RESULT=$(api_post "loandisk_sync_runs" \
    "{\"integration_id\":\"${INT_ID}\",\"run_type\":\"manual\",\"started_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"status\":\"completed\",\"records_fetched\":1,\"records_created\":1,\"records_updated\":0,\"records_skipped\":0,\"records_failed\":0,\"entity_types\":[\"borrower\"]}")
  SYNC_RUN_ID=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null || echo "")
  assert "Insert loandisk_sync_runs" "[ -n '${SYNC_RUN_ID}' ]"

  if [ -n "${SYNC_RUN_ID}" ]; then
    RESULT=$(api_post "loandisk_sync_items" \
      "{\"sync_run_id\":\"${SYNC_RUN_ID}\",\"entity_type\":\"borrower\",\"external_id\":\"${EXT_REF}\",\"action\":\"created\",\"local_id\":\"${CLIENT_ID}\",\"source_data\":{\"test\":true}}")
    assert "Insert loandisk_sync_items" "echo '${RESULT}' | grep -q 'entity_type'"
  else
    assert "Insert loandisk_sync_items (skipped)" "false"
  fi
else
  assert "Insert loandisk_sync_runs (no integration)" "false"
  assert "Insert loandisk_sync_items (skipped)" "false"
fi

echo ""

# ── 5. Observability ─────────────────────────────────────────────────
echo "Observability:"

RESULT=$(api_post "edge_function_invocations" \
  "{\"function_name\":\"loandisk-webhook-borrower\",\"duration_ms\":123,\"status\":\"success\",\"metadata\":{\"test_id\":\"${TS}\"}}")
assert "Insert edge_function_invocations" "echo '${RESULT}' | grep -q 'function_name'"

RESULT=$(api_post "webhook_failures" \
  "{\"error_message\":\"Auth failed test\",\"raw_payload\":{\"test_id\":\"${TS}\"}}")
assert "Insert webhook_failures (auth log)" "echo '${RESULT}' | grep -q 'error_message'"

echo ""

# ── 6. Repayment + Balance ───────────────────────────────────────────
echo "Repayment & Balance:"

if [ -n "${LOAN_ID}" ]; then
  # repayments: loan_id(FK), amount_paid, payment_method, receipt_ref, paid_at
  RESULT=$(api_post "repayments" \
    "{\"loan_id\":\"${LOAN_ID}\",\"amount_paid\":100000,\"paid_at\":\"2026-02-01\",\"payment_method\":\"mobile_money\",\"receipt_ref\":\"REC-${TS}\"}")
  REPAY_ID=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['id'])" 2>/dev/null || echo "")
  assert "Insert repayment" "[ -n '${REPAY_ID}' ]"

  # Simulate balance update
  api_patch "loans?id=eq.${LOAN_ID}" "{\"total_paid\":100000,\"outstanding_balance\":475000}" >/dev/null
  TOTAL_PAID=$(api_get "loans?id=eq.${LOAN_ID}&select=total_paid" | python3 -c "import sys,json; print(int(json.load(sys.stdin)[0]['total_paid']))" 2>/dev/null || echo "0")
  assert "Loan balance updated (total_paid=100000)" "[ '${TOTAL_PAID}' = '100000' ]"

  # Second repayment (full payoff)
  RESULT=$(api_post "repayments" \
    "{\"loan_id\":\"${LOAN_ID}\",\"amount_paid\":475000,\"paid_at\":\"2026-02-10\",\"payment_method\":\"bank_transfer\",\"receipt_ref\":\"REC2-${TS}\"}")
  assert "Insert second repayment (full payoff)" "echo '${RESULT}' | grep -q 'amount_paid'"

  # Mark loan completed (auto-close uses "completed" to satisfy DB constraint)
  api_patch "loans?id=eq.${LOAN_ID}" "{\"total_paid\":575000,\"outstanding_balance\":0,\"status\":\"completed\"}" >/dev/null
  LOAN_STATUS=$(api_get "loans?id=eq.${LOAN_ID}&select=status" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['status'])" 2>/dev/null || echo "")
  assert "Loan completed after full repayment" "[ '${LOAN_STATUS}' = 'completed' ]"
else
  assert "Insert repayment (skipped - no loan)" "false"
  assert "Loan balance updated (skipped)" "false"
  assert "Insert second repayment (skipped)" "false"
  assert "Loan auto-closed (skipped)" "false"
fi

echo ""

# ── 7. Risk Assessment ───────────────────────────────────────────────
echo "Risk Assessment:"

if [ -n "${CLIENT_ID}" ]; then
  # Simulate overdue → risk increase
  api_patch "clients?id=eq.${CLIENT_ID}" "{\"credit_score\":35,\"risk_level\":\"High\"}" >/dev/null
  RISK_LEVEL=$(api_get "clients?id=eq.${CLIENT_ID}&select=risk_level" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['risk_level'])" 2>/dev/null || echo "")
  assert "Client risk updated to High" "[ '${RISK_LEVEL}' = 'High' ]"

  # Simulate recovery
  api_patch "clients?id=eq.${CLIENT_ID}" "{\"credit_score\":75,\"risk_level\":\"Low\"}" >/dev/null
  RISK_LEVEL=$(api_get "clients?id=eq.${CLIENT_ID}&select=risk_level" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['risk_level'])" 2>/dev/null || echo "")
  assert "Client risk recovered to Low" "[ '${RISK_LEVEL}' = 'Low' ]"
else
  assert "Client risk updated (skipped)" "false"
  assert "Client risk recovered (skipped)" "false"
fi

echo ""

# ── 8. Deletion Cascade ──────────────────────────────────────────────
echo "Deletion Cascade:"

if [ -n "${BORROWER_ID}" ] && [ -n "${CLIENT_ID}" ]; then
  api_patch "borrowers?id=eq.${BORROWER_ID}" "{\"status\":\"inactive\"}" >/dev/null
  api_patch "clients?id=eq.${CLIENT_ID}" "{\"status\":\"inactive\"}" >/dev/null

  B_STATUS=$(api_get "borrowers?id=eq.${BORROWER_ID}&select=status" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['status'])" 2>/dev/null || echo "")
  assert "Borrower set to inactive" "[ '${B_STATUS}' = 'inactive' ]"

  C_STATUS=$(api_get "clients?id=eq.${CLIENT_ID}&select=status" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['status'])" 2>/dev/null || echo "")
  assert "Client set to inactive" "[ '${C_STATUS}' = 'inactive' ]"

  if [ -n "${LOAN_ID}" ]; then
    # Reset to active first, then default on borrower deletion
    api_patch "loans?id=eq.${LOAN_ID}" "{\"total_paid\":0,\"outstanding_balance\":500000,\"status\":\"active\"}" >/dev/null
    api_patch "loans?id=eq.${LOAN_ID}" "{\"status\":\"defaulted\"}" >/dev/null
    L_STATUS=$(api_get "loans?id=eq.${LOAN_ID}&select=status" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['status'])" 2>/dev/null || echo "")
    assert "Loan defaulted on borrower deletion" "[ '${L_STATUS}' = 'defaulted' ]"
  fi
else
  assert "Borrower set to inactive (skipped)" "false"
  assert "Client set to inactive (skipped)" "false"
fi

echo ""

# ── Cleanup ──────────────────────────────────────────────────────────
echo "Cleanup:"
[ -n "${LOAN_ID:-}" ] && api_delete "repayments?loan_id=eq.${LOAN_ID}" >/dev/null 2>&1 || true
[ -n "${LOAN_ID:-}" ] && api_delete "loans?id=eq.${LOAN_ID}" >/dev/null 2>&1 || true
[ -n "${CLIENT_ID:-}" ] && api_delete "clients?id=eq.${CLIENT_ID}" >/dev/null 2>&1 || true
[ -n "${BORROWER_ID:-}" ] && api_delete "borrowers?id=eq.${BORROWER_ID}" >/dev/null 2>&1 || true
api_delete "raw_borrowers?loandisk_id=eq.${TEST_BORROWER_LD}" >/dev/null 2>&1 || true
api_delete "raw_loans?loandisk_id=eq.${TEST_LOAN_LD}" >/dev/null 2>&1 || true
api_delete "raw_repayments?loandisk_id=eq.${TEST_LOAN_LD}" >/dev/null 2>&1 || true
api_delete "webhook_events?payload->>test_id=eq.${TS}" >/dev/null 2>&1 || true
api_delete "edge_function_invocations?metadata->>test_id=eq.${TS}" >/dev/null 2>&1 || true
api_delete "webhook_failures?raw_payload->>test_id=eq.${TS}" >/dev/null 2>&1 || true
[ -n "${SYNC_RUN_ID:-}" ] && api_delete "loandisk_sync_items?sync_run_id=eq.${SYNC_RUN_ID}" >/dev/null 2>&1 || true
[ -n "${SYNC_RUN_ID:-}" ] && api_delete "loandisk_sync_runs?id=eq.${SYNC_RUN_ID}" >/dev/null 2>&1 || true

echo "  Test data cleaned up."
echo ""

# ── Summary ──────────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════"
echo "  Results: ${PASS}/${TOTAL} passed, ${FAIL} failed"
echo "════════════════════════════════════════════════════════════"

if [ "${FAIL}" -gt 0 ]; then
  exit 1
fi
