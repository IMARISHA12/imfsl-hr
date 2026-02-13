#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Deploy LoanDisk Universal Webhook Handler to Supabase
#
# This deploys the single Edge Function that handles ALL LoanDisk
# entity types: borrowers, loans, and repayments.
#
# Prerequisites:
#   1. Supabase CLI installed (brew install supabase/tap/supabase)
#   2. Authenticated: supabase login
#   3. .env file with LOANDISK_WEBHOOK_SECRET
#
# Usage:
#   ./scripts/deploy-loandisk.sh              # deploy universal handler
#   ./scripts/deploy-loandisk.sh --all        # deploy all functions
#   ./scripts/deploy-loandisk.sh --verify     # just verify deployment
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

PROJECT_REF="lzyixazjquouicfsfzzu"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FN_URL="https://${PROJECT_REF}.supabase.co/functions/v1/loandisk-webhook-borrower"

# Load .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

WEBHOOK_SECRET="${LOANDISK_WEBHOOK_SECRET:?Missing LOANDISK_WEBHOOK_SECRET in .env}"
DEPLOY_ALL=false
VERIFY_ONLY=false

for arg in "$@"; do
  case $arg in
    --all) DEPLOY_ALL=true ;;
    --verify) VERIFY_ONLY=true ;;
  esac
done

echo ""
echo "  LoanDisk Universal Webhook Deployment"
echo "  Project: ${PROJECT_REF}"
echo "  ─────────────────────────────────────────"
echo ""

# ── Verify-only mode ─────────────────────────────────────────────────

if $VERIFY_ONLY; then
  echo "[verify] Testing universal handler..."

  # Test 1: Unauthenticated (should 401)
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FN_URL" \
    -H "Content-Type: application/json" -d '{}')
  if [ "$CODE" = "401" ]; then
    echo "  Auth check:  PASS (401 for unauthenticated)"
  else
    echo "  Auth check:  FAIL (expected 401, got $CODE)"
    exit 1
  fi

  # Test 2: Authenticated borrower event
  RESP=$(curl -s -X POST "$FN_URL" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: $WEBHOOK_SECRET" \
    -d '{"event":"borrower.created","data":{"borrower_id":99999,"first_name":"Deploy","last_name":"Verify","phone_number":"0700999999","branch_id":1}}')
  if echo "$RESP" | grep -q '"success":true'; then
    echo "  Borrower:    PASS"
  else
    echo "  Borrower:    FAIL - $RESP"
  fi

  # Test 3: Authenticated loan event
  RESP=$(curl -s -X POST "$FN_URL" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: $WEBHOOK_SECRET" \
    -d '{"event":"loan.created","entity_type":"loan","data":{"loan_id":99999,"borrower_id":99999,"principal_amount":100000,"branch_id":1}}')
  if echo "$RESP" | grep -q '"entity_type":"loan"'; then
    echo "  Loan:        PASS"
  else
    echo "  Loan:        FAIL - $RESP"
  fi

  # Test 4: Authenticated repayment event
  RESP=$(curl -s -X POST "$FN_URL" \
    -H "Content-Type: application/json" \
    -H "x-webhook-secret: $WEBHOOK_SECRET" \
    -d '{"event":"repayment.created","entity_type":"repayment","data":{"repayment_id":99999,"loan_id":99999,"amount_paid":50000,"branch_id":1}}')
  if echo "$RESP" | grep -q '"entity_type":"repayment"'; then
    echo "  Repayment:   PASS"
  else
    echo "  Repayment:   FAIL - $RESP"
  fi

  echo ""
  echo "  Verification complete."
  exit 0
fi

# ── Set secrets ──────────────────────────────────────────────────────

echo "[1/3] Setting Edge Function secrets..."
supabase secrets set \
  "LOANDISK_WEBHOOK_SECRET=${WEBHOOK_SECRET}" \
  "SUPABASE_URL=${SUPABASE_URL:-https://${PROJECT_REF}.supabase.co}" \
  "SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY:-}" \
  --project-ref "${PROJECT_REF}"
echo "  Done."
echo ""

# ── Deploy functions ─────────────────────────────────────────────────

cd "$PROJECT_DIR"

echo "[2/3] Deploying Edge Functions..."

# Always deploy the universal handler
echo "  deploying loandisk-webhook-borrower (universal handler)..."
supabase functions deploy loandisk-webhook-borrower --project-ref "${PROJECT_REF}"

if $DEPLOY_ALL; then
  for fn in loandisk-webhook-loan loandisk-webhook-repayment loandisk-batch-sync loandisk-reconcile; do
    echo "  deploying ${fn}..."
    supabase functions deploy "${fn}" --project-ref "${PROJECT_REF}"
  done
fi

echo "  Done."
echo ""

# ── Verify ───────────────────────────────────────────────────────────

echo "[3/3] Verifying deployment..."

CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FN_URL" \
  -H "Content-Type: application/json" -d '{"event":"ping"}')

if [ "$CODE" = "401" ]; then
  echo "  Function is live (returned 401 for unauthenticated request)."
elif [ "$CODE" = "200" ]; then
  echo "  Function is live and responding."
else
  echo "  WARNING: Unexpected status $CODE"
fi

echo ""
echo "  Deployment complete!"
echo ""
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │ Universal Webhook URL (handles ALL entity types):          │"
echo "  │                                                             │"
echo "  │   ${FN_URL}"
echo "  │                                                             │"
echo "  │ Configure LoanDisk to send ALL webhooks to this URL with:  │"
echo "  │   Header: x-webhook-secret: <your secret>                  │"
echo "  │                                                             │"
echo "  │ Supported entity types:                                     │"
echo "  │   - borrower.created / borrower.updated / borrower.deleted │"
echo "  │   - loan.created / loan.updated / loan.deleted             │"
echo "  │   - repayment.created / repayment.updated / repayment.deleted│"
echo "  └─────────────────────────────────────────────────────────────┘"
echo ""
echo "  Verify with: ./scripts/deploy-loandisk.sh --verify"
echo ""
