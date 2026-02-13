#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Test script for loandisk-webhook-borrower Edge Function
#
# Usage:
#   ./scripts/test-webhook-borrower.sh
#
# Requires .env file with:
#   SUPABASE_URL, LOANDISK_WEBHOOK_SECRET
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
else
  echo "ERROR: .env file not found at $PROJECT_DIR/.env"
  exit 1
fi

BASE_URL="${SUPABASE_URL:-https://lzyixazjquouicfsfzzu.supabase.co}"
FUNCTION_URL="${BASE_URL}/functions/v1/loandisk-webhook-borrower"
WEBHOOK_SECRET="${LOANDISK_WEBHOOK_SECRET:?Missing LOANDISK_WEBHOOK_SECRET}"

PASS=0
FAIL=0

run_test() {
  local name="$1"
  local expected_status="$2"
  local actual_status="$3"
  local body="$4"

  if [ "$actual_status" = "$expected_status" ]; then
    echo "  PASS  HTTP $actual_status"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  HTTP $actual_status (expected $expected_status)"
    echo "        $body"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "  Loandisk Webhook Borrower — Test Suite"
echo "  Endpoint: $FUNCTION_URL"
echo "  -----------------------------------------------"
echo ""

# ── Test 1: Reject without secret ────────────────────────────────────
echo "[1/6] Reject request without webhook secret"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{"event":"borrower.created","data":{"borrower_id":1}}')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "no-secret" "401" "$STATUS" "$BODY"
echo ""

# ── Test 2: Reject with wrong secret ────────────────────────────────
echo "[2/6] Reject request with wrong webhook secret"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: wrong-secret-value" \
  -d '{"event":"borrower.created","data":{"borrower_id":1}}')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "wrong-secret" "401" "$STATUS" "$BODY"
echo ""

# ── Test 3: Create borrower (Loandisk numeric ID) ───────────────────
echo "[3/6] Create a new borrower via webhook"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.created",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1,
      "first_name": "Amina",
      "last_name": "Hassan",
      "phone_number": "0754999888",
      "nida_number": "19880315-99901",
      "business_type": "Retail",
      "business_location": "Dar es Salaam, Kariakoo",
      "region": "Dar es Salaam",
      "district": "Ilala",
      "street": "Kariakoo Market",
      "status": "active"
    }
  }')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "create-borrower" "200" "$STATUS" "$BODY"
echo "        $BODY"
echo ""

# ── Test 4: Update borrower ─────────────────────────────────────────
echo "[4/6] Update the same borrower"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.updated",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1,
      "first_name": "Amina",
      "last_name": "Hassan-Mwangi",
      "phone_number": "0754999888",
      "nida_number": "19880315-99901",
      "business_type": "Wholesale",
      "revenue_estimate": 5000000,
      "status": "active"
    }
  }')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "update-borrower" "200" "$STATUS" "$BODY"
echo "        $BODY"
echo ""

# ── Test 5: Full-name payload (alternate Loandisk format) ───────────
echo "[5/6] Alternate format: full_name under 'borrower' key"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.created",
    "borrower": {
      "id": 900002,
      "branch_id": 1,
      "full_name": "Juma Bakari Mwinyi",
      "mobile": "0712345678",
      "national_id": "19750601-55501",
      "status": "active"
    }
  }')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "alt-format" "200" "$STATUS" "$BODY"
echo "        $BODY"
echo ""

# ── Test 6: Delete (soft) a borrower ────────────────────────────────
echo "[6/6] Soft-delete a borrower"
RESP=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.deleted",
    "data": {
      "borrower_id": 900002,
      "branch_id": 1
    }
  }')
BODY=$(echo "$RESP" | head -n -1)
STATUS=$(echo "$RESP" | tail -n 1)
run_test "delete-borrower" "200" "$STATUS" "$BODY"
echo "        $BODY"
echo ""

echo "  -----------------------------------------------"
echo "  Results: $PASS passed, $FAIL failed (of 6)"
echo "  -----------------------------------------------"
echo ""

exit $FAIL
