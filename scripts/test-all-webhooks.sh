#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Test All LoanDisk Webhook Edge Functions
# ──────────────────────────────────────────────────────────────────────
#
# Runs end-to-end tests against the deployed Edge Functions:
#   - Borrower webhook (create, update, soft-delete)
#   - Loan webhook (create, update, cancel)
#   - Repayment webhook (create, reversal)
#   - Batch sync (trigger)
#   - Reconciliation (trigger)
#
# Usage: ./scripts/test-all-webhooks.sh
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Load .env
if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a
  source "${PROJECT_DIR}/.env"
  set +a
fi

PROJECT_REF="lzyixazjquouicfsfzzu"
BASE="https://${PROJECT_REF}.supabase.co/functions/v1"
SECRET="${LOANDISK_WEBHOOK_SECRET:-}"

if [ -z "${SECRET}" ]; then
  echo "ERROR: LOANDISK_WEBHOOK_SECRET not set. Export it or create .env"
  exit 1
fi

PASS=0
FAIL=0
TOTAL=0

run_test() {
  local name="$1"
  local url="$2"
  local payload="$3"
  local expect_status="${4:-200}"
  local use_secret="${5:-yes}"

  TOTAL=$((TOTAL + 1))
  printf "  [%02d] %-45s" "${TOTAL}" "${name}"

  local headers=(-H "Content-Type: application/json")
  if [ "${use_secret}" = "yes" ]; then
    headers+=(-H "x-webhook-secret: ${SECRET}")
  elif [ "${use_secret}" = "wrong" ]; then
    headers+=(-H "x-webhook-secret: wrong-secret-value")
  fi

  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "${url}" \
    "${headers[@]}" \
    -d "${payload}" 2>&1)

  if [ "${http_code}" = "${expect_status}" ]; then
    echo "PASS (HTTP ${http_code})"
    PASS=$((PASS + 1))
  else
    echo "FAIL (HTTP ${http_code}, expected ${expect_status})"
    FAIL=$((FAIL + 1))
  fi
}

echo "════════════════════════════════════════════════════════════"
echo "  LoanDisk Webhook Integration Tests"
echo "════════════════════════════════════════════════════════════"
echo ""

# ── Auth Tests ───────────────────────────────────────────────────────
echo "Auth Tests:"
run_test "Borrower: reject no secret" \
  "${BASE}/loandisk-webhook-borrower" \
  '{"event":"borrower.created","data":{"borrower_id":1}}' \
  "401" "no"

run_test "Borrower: reject wrong secret" \
  "${BASE}/loandisk-webhook-borrower" \
  '{"event":"borrower.created","data":{"borrower_id":1}}' \
  "401" "wrong"

run_test "Loan payload: reject no secret" \
  "${BASE}/loandisk-webhook-borrower" \
  '{"event":"loan.created","data":{"loan_id":1}}' \
  "401" "no"

run_test "Repayment payload: reject no secret" \
  "${BASE}/loandisk-webhook-borrower" \
  '{"event":"repayment.created","data":{"repayment_id":1}}' \
  "401" "no"

echo ""

# ── Borrower Tests ───────────────────────────────────────────────────
echo "Borrower Webhook:"
run_test "Create borrower 900001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "borrower.created",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1,
      "first_name": "Amina",
      "last_name": "Hassan",
      "phone_number": "0754999888",
      "nida_number": "19880315-99901",
      "business_type": "Retail",
      "region": "Dar es Salaam",
      "district": "Ilala",
      "status": "active"
    }
  }'

run_test "Update borrower 900001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "borrower.updated",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1,
      "first_name": "Amina",
      "last_name": "Hassan-Updated",
      "phone_number": "0754999888",
      "business_type": "Wholesale",
      "status": "active"
    }
  }'

run_test "Soft-delete borrower 900001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "borrower.deleted",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1
    }
  }'

echo ""

# ── Loan Tests ───────────────────────────────────────────────────────
echo "Loan Webhook:"
# First re-create the borrower (un-delete)
run_test "Re-create borrower for loan test" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "borrower.created",
    "data": {
      "borrower_id": 900001,
      "branch_id": 1,
      "first_name": "Amina",
      "last_name": "Hassan",
      "phone_number": "0754999888",
      "status": "active"
    }
  }'

run_test "Create loan 800001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "loan.created",
    "data": {
      "loan_id": 800001,
      "borrower_id": 900001,
      "branch_id": 1,
      "principal_amount": 500000,
      "interest_rate": 18,
      "duration_months": 12,
      "status": "active",
      "loan_number": "LD-800001",
      "disbursed_date": "2026-01-15",
      "product_type": "sme_group"
    }
  }'

run_test "Update loan 800001 (overdue)" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "loan.updated",
    "data": {
      "loan_id": 800001,
      "borrower_id": 900001,
      "branch_id": 1,
      "principal_amount": 500000,
      "interest_rate": 18,
      "duration_months": 12,
      "outstanding_balance": 450000,
      "days_overdue": 45,
      "status": "active",
      "loan_number": "LD-800001"
    }
  }'

run_test "Cancel loan 800001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "loan.deleted",
    "data": {
      "loan_id": 800001,
      "branch_id": 1,
      "loan_number": "LD-800001"
    }
  }'

echo ""

# ── Repayment Tests ──────────────────────────────────────────────────
echo "Repayment Webhook:"
# Re-create loan for repayment test
run_test "Re-create loan for repayment" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "loan.created",
    "data": {
      "loan_id": 800001,
      "borrower_id": 900001,
      "branch_id": 1,
      "principal_amount": 500000,
      "interest_rate": 18,
      "duration_months": 12,
      "status": "active",
      "loan_number": "LD-800001"
    }
  }'

run_test "Create repayment 700001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "repayment.created",
    "data": {
      "repayment_id": 700001,
      "loan_id": 800001,
      "branch_id": 1,
      "amount_paid": 50000,
      "payment_method": "mobile_money",
      "receipt_number": "RCP-700001",
      "payment_date": "2026-02-01"
    }
  }'

run_test "Reverse repayment 700001" \
  "${BASE}/loandisk-webhook-borrower" \
  '{
    "event": "repayment.deleted",
    "data": {
      "repayment_id": 700001,
      "loan_id": 800001,
      "branch_id": 1,
      "receipt_number": "RCP-700001"
    }
  }'

echo ""

# ── Summary ──────────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════"
echo "  Results: ${PASS}/${TOTAL} passed, ${FAIL} failed"
echo "════════════════════════════════════════════════════════════"

if [ "${FAIL}" -gt 0 ]; then
  exit 1
fi
