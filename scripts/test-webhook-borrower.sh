#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Test script for loandisk-webhook-borrower Edge Function
#
# Usage:
#   ./scripts/test-webhook-borrower.sh
#
# Requires .env file with:
#   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, LOANDISK_WEBHOOK_SECRET
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
  echo "Copy .env.example to .env and fill in the values."
  exit 1
fi

BASE_URL="${SUPABASE_URL:-https://lzyixazjquouicfsfzzu.supabase.co}"
FUNCTION_URL="${BASE_URL}/functions/v1/loandisk-webhook-borrower"
WEBHOOK_SECRET="${LOANDISK_WEBHOOK_SECRET:?Missing LOANDISK_WEBHOOK_SECRET}"

echo "═══════════════════════════════════════════════════════════════"
echo "  Loandisk Webhook Borrower — Test Suite"
echo "  Endpoint: $FUNCTION_URL"
echo "═══════════════════════════════════════════════════════════════"
echo

# ── Test 1: Reject without secret ────────────────────────────────────
echo "▸ Test 1: Reject request without webhook secret"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -d '{"event": "borrower.created", "data": {"id": "test"}}')

if [ "$STATUS" = "401" ]; then
  echo "  ✓ PASS — Got 401 Unauthorized (expected)"
else
  echo "  ✗ FAIL — Got HTTP $STATUS (expected 401)"
fi
echo

# ── Test 2: Reject with wrong secret ────────────────────────────────
echo "▸ Test 2: Reject request with wrong webhook secret"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: wrong-secret-value" \
  -d '{"event": "borrower.created", "data": {"id": "test"}}')

if [ "$STATUS" = "401" ]; then
  echo "  ✓ PASS — Got 401 Unauthorized (expected)"
else
  echo "  ✗ FAIL — Got HTTP $STATUS (expected 401)"
fi
echo

# ── Test 3: Create borrower ─────────────────────────────────────────
echo "▸ Test 3: Create a new borrower via webhook"
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.created",
    "data": {
      "borrower_id": "LD-TEST-001",
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

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" = "200" ]; then
  echo "  ✓ PASS — Got 200 OK"
  echo "  Response: $BODY"
else
  echo "  ✗ FAIL — Got HTTP $STATUS"
  echo "  Response: $BODY"
fi
echo

# ── Test 4: Update borrower ─────────────────────────────────────────
echo "▸ Test 4: Update the same borrower"
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.updated",
    "data": {
      "borrower_id": "LD-TEST-001",
      "first_name": "Amina",
      "last_name": "Hassan-Mwangi",
      "phone_number": "0754999888",
      "nida_number": "19880315-99901",
      "business_type": "Wholesale",
      "business_location": "Dar es Salaam, Kariakoo",
      "revenue_estimate": 5000000,
      "status": "active"
    }
  }')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" = "200" ]; then
  echo "  ✓ PASS — Got 200 OK"
  echo "  Response: $BODY"
else
  echo "  ✗ FAIL — Got HTTP $STATUS"
  echo "  Response: $BODY"
fi
echo

# ── Test 5: Full-name-only payload (flat format) ────────────────────
echo "▸ Test 5: Flat payload with full_name (Loandisk alternate format)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.created",
    "borrower": {
      "id": "LD-TEST-002",
      "full_name": "Juma Bakari Mwinyi",
      "mobile": "0712345678",
      "national_id": "19750601-55501",
      "status": "active"
    }
  }')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" = "200" ]; then
  echo "  ✓ PASS — Got 200 OK"
  echo "  Response: $BODY"
else
  echo "  ✗ FAIL — Got HTTP $STATUS"
  echo "  Response: $BODY"
fi
echo

# ── Test 6: Delete borrower ─────────────────────────────────────────
echo "▸ Test 6: Delete (soft) a borrower"
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "$FUNCTION_URL" \
  -H "Content-Type: application/json" \
  -H "x-webhook-secret: $WEBHOOK_SECRET" \
  -d '{
    "event": "borrower.deleted",
    "data": {
      "borrower_id": "LD-TEST-002"
    }
  }')

BODY=$(echo "$RESPONSE" | head -n -1)
STATUS=$(echo "$RESPONSE" | tail -n 1)

if [ "$STATUS" = "200" ]; then
  echo "  ✓ PASS — Got 200 OK"
  echo "  Response: $BODY"
else
  echo "  ✗ FAIL — Got HTTP $STATUS"
  echo "  Response: $BODY"
fi
echo

echo "═══════════════════════════════════════════════════════════════"
echo "  Test suite complete."
echo "═══════════════════════════════════════════════════════════════"
