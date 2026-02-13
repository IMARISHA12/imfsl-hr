#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Deploy All LoanDisk Edge Functions to Supabase
# ──────────────────────────────────────────────────────────────────────
#
# Usage:
#   ./scripts/deploy-all-functions.sh              # Deploy all
#   ./scripts/deploy-all-functions.sh borrower     # Deploy only borrower webhook
#   ./scripts/deploy-all-functions.sh loan         # Deploy only loan webhook
#   ./scripts/deploy-all-functions.sh repayment    # Deploy only repayment webhook
#   ./scripts/deploy-all-functions.sh sync         # Deploy only batch sync
#   ./scripts/deploy-all-functions.sh reconcile    # Deploy only reconcile
#
# Prerequisites:
#   1. Install Supabase CLI:  brew install supabase/tap/supabase
#   2. Authenticate:          supabase login
#   3. Copy .env.example → .env and fill in all values
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_REF="lzyixazjquouicfsfzzu"

# Load .env
if [ -f "${PROJECT_DIR}/.env" ]; then
  set -a
  source "${PROJECT_DIR}/.env"
  set +a
else
  echo "ERROR: .env file not found. Copy .env.example to .env and fill in values."
  exit 1
fi

# Validate required env vars
required_vars=("LOANDISK_WEBHOOK_SECRET")
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: ${var} is not set in .env"
    exit 1
  fi
done

# ── Set secrets ──────────────────────────────────────────────────────
echo "Setting Edge Function secrets..."
secrets_cmd="LOANDISK_WEBHOOK_SECRET=${LOANDISK_WEBHOOK_SECRET}"

# Add batch sync secrets if available
if [ -n "${LOANDISK_API_KEY:-}" ]; then
  secrets_cmd="${secrets_cmd} LOANDISK_API_KEY=${LOANDISK_API_KEY}"
fi
if [ -n "${LOANDISK_API_BASE_URL:-}" ]; then
  secrets_cmd="${secrets_cmd} LOANDISK_API_BASE_URL=${LOANDISK_API_BASE_URL}"
fi

supabase secrets set ${secrets_cmd} --project-ref "${PROJECT_REF}"
echo "Secrets configured."

# ── Function list ────────────────────────────────────────────────────
ALL_FUNCTIONS=(
  "loandisk-webhook-borrower"
  "loandisk-webhook-loan"
  "loandisk-webhook-repayment"
  "loandisk-batch-sync"
  "loandisk-reconcile"
)

# Filter by argument
TARGET="${1:-all}"
DEPLOY_FUNCTIONS=()

case "${TARGET}" in
  all)
    DEPLOY_FUNCTIONS=("${ALL_FUNCTIONS[@]}")
    ;;
  borrower)
    DEPLOY_FUNCTIONS=("loandisk-webhook-borrower")
    ;;
  loan)
    DEPLOY_FUNCTIONS=("loandisk-webhook-loan")
    ;;
  repayment)
    DEPLOY_FUNCTIONS=("loandisk-webhook-repayment")
    ;;
  sync|batch)
    DEPLOY_FUNCTIONS=("loandisk-batch-sync")
    ;;
  reconcile)
    DEPLOY_FUNCTIONS=("loandisk-reconcile")
    ;;
  *)
    echo "Unknown target: ${TARGET}"
    echo "Usage: $0 [all|borrower|loan|repayment|sync|reconcile]"
    exit 1
    ;;
esac

# ── Deploy ───────────────────────────────────────────────────────────
echo ""
echo "Deploying ${#DEPLOY_FUNCTIONS[@]} function(s)..."
echo ""

PASS=0
FAIL=0

for func in "${DEPLOY_FUNCTIONS[@]}"; do
  echo "  Deploying ${func}..."
  if supabase functions deploy "${func}" \
    --project-ref "${PROJECT_REF}" \
    --no-verify-jwt; then
    echo "    ✓ ${func} deployed"
    PASS=$((PASS + 1))
  else
    echo "    ✗ ${func} FAILED"
    FAIL=$((FAIL + 1))
  fi
  echo ""
done

# ── Verify ───────────────────────────────────────────────────────────
echo "════════════════════════════════════════════"
echo "  Deployment: ${PASS} passed, ${FAIL} failed"
echo "════════════════════════════════════════════"
echo ""
echo "Webhook URLs:"
for func in "${DEPLOY_FUNCTIONS[@]}"; do
  echo "  https://${PROJECT_REF}.supabase.co/functions/v1/${func}"
done
echo ""
echo "Custom domain URLs:"
for func in "${DEPLOY_FUNCTIONS[@]}"; do
  echo "  https://api.admin-imarishamaisha.co.tz/functions/v1/${func}"
done

if [ "${FAIL}" -gt 0 ]; then
  exit 1
fi
