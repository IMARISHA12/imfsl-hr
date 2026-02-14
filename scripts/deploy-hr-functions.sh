#!/usr/bin/env bash
# ============================================================================
# Deploy HR Edge Functions to Supabase
#
# Usage:
#   ./scripts/deploy-hr-functions.sh              # Deploy all HR functions
#   ./scripts/deploy-hr-functions.sh --payroll    # Deploy payroll only
#   ./scripts/deploy-hr-functions.sh --leave      # Deploy leave only
#   ./scripts/deploy-hr-functions.sh --attendance # Deploy attendance only
#   ./scripts/deploy-hr-functions.sh --performance # Deploy performance only
#   ./scripts/deploy-hr-functions.sh --verify     # Verify endpoints
#
# Required environment variables:
#   SUPABASE_ACCESS_TOKEN  - Supabase CLI access token (or run supabase login)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROJECT_REF="lzyixazjquouicfsfzzu"
FUNCTIONS_DIR="supabase/functions"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[HR-DEPLOY]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }

# All HR functions
HR_FUNCTIONS=(
  "hr-payroll-processor"
  "hr-leave-workflow"
  "hr-attendance"
  "hr-performance-review"
)

# ── Verify Prerequisites ───────────────────────────────────────────

verify_config() {
  log "Verifying configuration..."

  if ! command -v supabase &>/dev/null; then
    error "Supabase CLI not found. Install: npm i -g supabase"
    exit 1
  fi

  for func in "${HR_FUNCTIONS[@]}"; do
    if [[ ! -d "${PROJECT_DIR}/${FUNCTIONS_DIR}/${func}" ]]; then
      error "Function directory not found: ${FUNCTIONS_DIR}/${func}"
      exit 1
    fi
  done

  log "Configuration verified (Project: ${PROJECT_REF})"
}

# ── Deploy Function ────────────────────────────────────────────────

deploy_function() {
  local name=$1
  log "Deploying ${name}..."

  if supabase functions deploy "${name}" \
    --project-ref "${PROJECT_REF}" \
    --no-verify-jwt; then
    log "${name} deployed successfully"
  else
    error "${name} deployment FAILED"
    return 1
  fi
}

# ── Deploy All ─────────────────────────────────────────────────────

deploy_all() {
  verify_config

  log "Deploying all HR Edge Functions..."
  echo ""

  local pass=0
  local fail=0

  for func in "${HR_FUNCTIONS[@]}"; do
    if deploy_function "${func}"; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
    fi
    echo ""
  done

  echo "════════════════════════════════════════════"
  echo "  HR Deployment: ${pass} passed, ${fail} failed"
  echo "════════════════════════════════════════════"
  echo ""
  info "Endpoints:"
  for func in "${HR_FUNCTIONS[@]}"; do
    info "  https://${PROJECT_REF}.supabase.co/functions/v1/${func}"
  done
  echo ""
  info "Custom Domain:"
  for func in "${HR_FUNCTIONS[@]}"; do
    info "  https://api.admin-imarishamaisha.co.tz/functions/v1/${func}"
  done

  if [[ "${fail}" -gt 0 ]]; then
    exit 1
  fi
}

# ── Verify Endpoints ──────────────────────────────────────────────

verify_endpoints() {
  log "Verifying HR function endpoints..."
  echo ""

  for func in "${HR_FUNCTIONS[@]}"; do
    local url="https://${PROJECT_REF}.supabase.co/functions/v1/${func}"
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "${url}" 2>/dev/null || echo "000")

    if [[ "${status}" == "200" || "${status}" == "204" ]]; then
      log "  ${func}: OK (${status})"
    else
      warn "  ${func}: ${status} (may not be deployed yet)"
    fi
  done
}

# ── Main ───────────────────────────────────────────────────────────

case "${1:-all}" in
  --payroll)      verify_config; deploy_function "hr-payroll-processor" ;;
  --leave)        verify_config; deploy_function "hr-leave-workflow" ;;
  --attendance)   verify_config; deploy_function "hr-attendance" ;;
  --performance)  verify_config; deploy_function "hr-performance-review" ;;
  --verify)       verify_endpoints ;;
  all|--all)      deploy_all ;;
  *)
    echo "Usage: $0 [--payroll|--leave|--attendance|--performance|--verify|--all]"
    exit 1
    ;;
esac
