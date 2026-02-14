#!/usr/bin/env bash
# ============================================================================
# Test Fineract Edge Functions
#
# Usage:
#   ./scripts/test-fineract.sh                  # Run all tests
#   ./scripts/test-fineract.sh --webhook        # Test webhook only
#   ./scripts/test-fineract.sh --lifecycle      # Test loan lifecycle only
#   ./scripts/test-fineract.sh --sync           # Test batch sync
#   ./scripts/test-fineract.sh --reconcile      # Test reconciliation
#
# Required environment variables:
#   SUPABASE_URL              - Supabase project URL
#   FINERACT_WEBHOOK_SECRET   - Webhook authentication secret
#   LOANDISK_WEBHOOK_SECRET   - Shared webhook secret (reused for auth)
# ============================================================================

set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-https://lzyixazjquouicfsfzzu.supabase.co}"
SECRET="${FINERACT_WEBHOOK_SECRET:-${LOANDISK_WEBHOOK_SECRET:-}}"
BASE="${SUPABASE_URL}/functions/v1"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { echo -e "  ${RED}FAIL${NC} $1"; }
skip() { echo -e "  ${YELLOW}SKIP${NC} $1"; }

PASSED=0
FAILED=0

assert_status() {
  local name=$1 expected=$2 actual=$3
  if [[ "$actual" == "$expected" ]]; then
    pass "$name (HTTP $actual)"
    ((PASSED++))
  else
    fail "$name (expected $expected, got $actual)"
    ((FAILED++))
  fi
}

# ── Test: Webhook Auth Rejection ───────────────────────────────────

test_webhook_auth() {
  echo ""
  echo "=== Webhook Authentication Tests ==="

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${BASE}/fineract-webhook" \
    -H "Content-Type: application/json" \
    -d '{"entity": "CLIENT", "action": "CREATE", "resourceId": 1}')
  assert_status "Reject unauthenticated request" "401" "$status"

  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${BASE}/fineract-webhook" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: wrong-secret" \
    -d '{"entity": "CLIENT", "action": "CREATE", "resourceId": 1}')
  assert_status "Reject invalid secret" "401" "$status"
}

# ── Test: Client Webhook ───────────────────────────────────────────

test_webhook_client() {
  echo ""
  echo "=== Client Webhook Tests ==="

  if [[ -z "$SECRET" ]]; then
    skip "No FINERACT_WEBHOOK_SECRET set"
    return
  fi

  local response
  response=$(curl -s -X POST \
    "${BASE}/fineract-webhook" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: ${SECRET}" \
    -d '{
      "entity": "CLIENT",
      "action": "CREATE",
      "resourceId": 99901,
      "tenantIdentifier": "default",
      "body": {
        "id": 99901,
        "firstname": "Test",
        "lastname": "Borrower",
        "displayName": "Test Borrower",
        "mobileNo": "+255700000001",
        "emailAddress": "test@example.com",
        "officeId": 1,
        "active": true
      }
    }')

  local success
  success=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success', False))" 2>/dev/null || echo "false")
  if [[ "$success" == "True" || "$success" == "true" ]]; then
    pass "Client CREATE webhook processed"
    ((PASSED++))
  else
    fail "Client CREATE webhook: $response"
    ((FAILED++))
  fi
}

# ── Test: Loan Webhook ─────────────────────────────────────────────

test_webhook_loan() {
  echo ""
  echo "=== Loan Webhook Tests ==="

  if [[ -z "$SECRET" ]]; then
    skip "No FINERACT_WEBHOOK_SECRET set"
    return
  fi

  local response
  response=$(curl -s -X POST \
    "${BASE}/fineract-webhook" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: ${SECRET}" \
    -d '{
      "entity": "LOAN",
      "action": "CREATE",
      "resourceId": 99901,
      "body": {
        "id": 99901,
        "clientId": 99901,
        "accountNo": "TEST-001",
        "loanProductName": "SME Loan",
        "principal": 5000000,
        "interestRatePerPeriod": 2.5,
        "numberOfRepayments": 12,
        "status": {"id": 200, "code": "loanStatusType.approved", "value": "Approved"}
      }
    }')

  local success
  success=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success', False))" 2>/dev/null || echo "false")
  if [[ "$success" == "True" || "$success" == "true" ]]; then
    pass "Loan CREATE webhook processed"
    ((PASSED++))
  else
    fail "Loan CREATE webhook: $response"
    ((FAILED++))
  fi
}

# ── Test: Loan Lifecycle ───────────────────────────────────────────

test_lifecycle() {
  echo ""
  echo "=== Loan Lifecycle Tests ==="

  if [[ -z "$SECRET" ]]; then
    skip "No FINERACT_WEBHOOK_SECRET set"
    return
  fi

  # Test invalid operation
  local response
  response=$(curl -s -X POST \
    "${BASE}/fineract-loan-lifecycle" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: ${SECRET}" \
    -d '{"operation": "invalid_op", "loan_id": "00000000-0000-0000-0000-000000000000"}')

  local success
  success=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success', False))" 2>/dev/null || echo "true")
  if [[ "$success" == "False" || "$success" == "false" ]]; then
    pass "Invalid operation rejected"
    ((PASSED++))
  else
    fail "Invalid operation not rejected: $response"
    ((FAILED++))
  fi

  # Test missing operation
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${BASE}/fineract-loan-lifecycle" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: ${SECRET}" \
    -d '{"loan_id": "test"}')
  assert_status "Reject missing operation" "400" "$status"
}

# ── Test: Batch Sync ───────────────────────────────────────────────

test_batch_sync() {
  echo ""
  echo "=== Batch Sync Tests ==="

  if [[ -z "$SECRET" ]]; then
    skip "No FINERACT_WEBHOOK_SECRET set"
    return
  fi

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${BASE}/fineract-batch-sync" \
    -H "Content-Type: application/json" \
    -d '{}')
  assert_status "Reject unauthenticated sync" "401" "$status"
}

# ── Test: Reconciliation ──────────────────────────────────────────

test_reconcile() {
  echo ""
  echo "=== Reconciliation Tests ==="

  if [[ -z "$SECRET" ]]; then
    skip "No FINERACT_WEBHOOK_SECRET set"
    return
  fi

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${BASE}/fineract-reconcile" \
    -H "Content-Type: application/json" \
    -d '{}')
  assert_status "Reject unauthenticated reconcile" "401" "$status"
}

# ── Main ───────────────────────────────────────────────────────────

echo "====================================="
echo " IMFSL Fineract Integration Tests"
echo "====================================="
echo "Base URL: ${BASE}"
echo ""

case "${1:-all}" in
  --webhook)    test_webhook_auth; test_webhook_client; test_webhook_loan ;;
  --lifecycle)  test_lifecycle ;;
  --sync)       test_batch_sync ;;
  --reconcile)  test_reconcile ;;
  all|--all)
    test_webhook_auth
    test_webhook_client
    test_webhook_loan
    test_lifecycle
    test_batch_sync
    test_reconcile
    ;;
  *)
    echo "Usage: $0 [--webhook|--lifecycle|--sync|--reconcile|--all]"
    exit 1
    ;;
esac

echo ""
echo "====================================="
echo " Results: ${PASSED} passed, ${FAILED} failed"
echo "====================================="

[[ $FAILED -eq 0 ]] && exit 0 || exit 1
