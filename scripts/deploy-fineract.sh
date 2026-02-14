#!/usr/bin/env bash
# ============================================================================
# Deploy Fineract Edge Functions to Supabase
#
# Usage:
#   ./scripts/deploy-fineract.sh              # Deploy all Fineract functions
#   ./scripts/deploy-fineract.sh --webhook    # Deploy webhook only
#   ./scripts/deploy-fineract.sh --sync       # Deploy batch-sync only
#   ./scripts/deploy-fineract.sh --reconcile  # Deploy reconcile only
#   ./scripts/deploy-fineract.sh --lifecycle  # Deploy loan-lifecycle only
#   ./scripts/deploy-fineract.sh --verify     # Just verify configuration
#   ./scripts/deploy-fineract.sh --setup-hooks # Register Fineract webhooks
#
# Required environment variables:
#   SUPABASE_ACCESS_TOKEN     - Supabase CLI access token
#   FINERACT_BASE_URL         - Apache Fineract instance URL
#   FINERACT_USERNAME         - Fineract API username
#   FINERACT_PASSWORD         - Fineract API password
#   FINERACT_TENANT_ID        - Fineract tenant identifier
#   FINERACT_WEBHOOK_SECRET   - Secret for webhook authentication
# ============================================================================

set -euo pipefail

PROJECT_REF="lzyixazjquouicfsfzzu"
FUNCTIONS_DIR="supabase/functions"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[DEPLOY]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }

# ── Verify Prerequisites ───────────────────────────────────────────

verify_config() {
  log "Verifying configuration..."

  if ! command -v supabase &>/dev/null; then
    error "Supabase CLI not found. Install: npm i -g supabase"
    exit 1
  fi

  local missing=()
  [[ -z "${FINERACT_BASE_URL:-}" ]] && missing+=("FINERACT_BASE_URL")
  [[ -z "${FINERACT_USERNAME:-}" ]] && missing+=("FINERACT_USERNAME")
  [[ -z "${FINERACT_PASSWORD:-}" ]] && missing+=("FINERACT_PASSWORD")
  [[ -z "${FINERACT_WEBHOOK_SECRET:-}" ]] && missing+=("FINERACT_WEBHOOK_SECRET")

  if [[ ${#missing[@]} -gt 0 ]]; then
    error "Missing environment variables: ${missing[*]}"
    echo ""
    echo "Set them in your .env file or export them:"
    echo "  export FINERACT_BASE_URL=https://your-fineract-instance.com"
    echo "  export FINERACT_USERNAME=mifos"
    echo "  export FINERACT_PASSWORD=password"
    echo "  export FINERACT_TENANT_ID=default"
    echo "  export FINERACT_WEBHOOK_SECRET=your-secret-here"
    exit 1
  fi

  log "Configuration verified:"
  info "  Fineract URL:    ${FINERACT_BASE_URL}"
  info "  Tenant ID:       ${FINERACT_TENANT_ID:-default}"
  info "  Username:        ${FINERACT_USERNAME}"
  info "  Project:         ${PROJECT_REF}"
}

# ── Deploy Function ────────────────────────────────────────────────

deploy_function() {
  local name=$1
  log "Deploying ${name}..."

  if [[ ! -d "${FUNCTIONS_DIR}/${name}" ]]; then
    error "Function directory not found: ${FUNCTIONS_DIR}/${name}"
    return 1
  fi

  supabase functions deploy "${name}" \
    --project-ref "${PROJECT_REF}" \
    --no-verify-jwt

  if [[ $? -eq 0 ]]; then
    log "${name} deployed successfully"
  else
    error "${name} deployment failed"
    return 1
  fi
}

# ── Set Secrets ────────────────────────────────────────────────────

set_secrets() {
  log "Setting Fineract secrets..."

  supabase secrets set \
    FINERACT_BASE_URL="${FINERACT_BASE_URL}" \
    FINERACT_USERNAME="${FINERACT_USERNAME}" \
    FINERACT_PASSWORD="${FINERACT_PASSWORD}" \
    FINERACT_TENANT_ID="${FINERACT_TENANT_ID:-default}" \
    FINERACT_WEBHOOK_SECRET="${FINERACT_WEBHOOK_SECRET}" \
    --project-ref "${PROJECT_REF}"

  log "Secrets configured"
}

# ── Deploy All ─────────────────────────────────────────────────────

deploy_all() {
  verify_config
  set_secrets

  log "Deploying all Fineract Edge Functions..."
  deploy_function "fineract-webhook"
  deploy_function "fineract-batch-sync"
  deploy_function "fineract-reconcile"
  deploy_function "fineract-loan-lifecycle"

  echo ""
  log "All Fineract functions deployed!"
  echo ""
  info "Endpoints:"
  info "  Webhook:    https://${PROJECT_REF}.supabase.co/functions/v1/fineract-webhook"
  info "  Batch Sync: https://${PROJECT_REF}.supabase.co/functions/v1/fineract-batch-sync"
  info "  Reconcile:  https://${PROJECT_REF}.supabase.co/functions/v1/fineract-reconcile"
  info "  Lifecycle:  https://${PROJECT_REF}.supabase.co/functions/v1/fineract-loan-lifecycle"
}

# ── Main ───────────────────────────────────────────────────────────

case "${1:-all}" in
  --webhook)    verify_config; deploy_function "fineract-webhook" ;;
  --sync)       verify_config; deploy_function "fineract-batch-sync" ;;
  --reconcile)  verify_config; deploy_function "fineract-reconcile" ;;
  --lifecycle)  verify_config; deploy_function "fineract-loan-lifecycle" ;;
  --verify)     verify_config; log "All checks passed" ;;
  --secrets)    verify_config; set_secrets ;;
  all|--all)    deploy_all ;;
  *)
    echo "Usage: $0 [--webhook|--sync|--reconcile|--lifecycle|--verify|--secrets|--all]"
    exit 1
    ;;
esac
