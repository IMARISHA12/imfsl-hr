#!/usr/bin/env bash
# ============================================================================
# Apache Fineract — Initial Setup & Configuration
#
# This script:
#   1. Waits for Fineract to be ready
#   2. Creates the IMFSL office structure
#   3. Creates loan products matching IMFSL's portfolio
#   4. Creates staff/loan officers
#   5. Registers webhook hooks for Supabase Edge Functions
#
# Usage:
#   ./fineract/setup-fineract.sh
#
# Prerequisites:
#   - Fineract running (docker-compose up -d)
#   - Wait ~2 minutes for initialization
# ============================================================================

set -euo pipefail

FINERACT_URL="${FINERACT_BASE_URL:-https://localhost:8443}"
USERNAME="${FINERACT_USERNAME:-mifos}"
PASSWORD="${FINERACT_PASSWORD:-password}"
TENANT="${FINERACT_TENANT_ID:-default}"

# Supabase Edge Function URL for webhook
SUPABASE_PROJECT_REF="lzyixazjquouicfsfzzu"
WEBHOOK_URL="https://${SUPABASE_PROJECT_REF}.supabase.co/functions/v1/fineract-webhook"
WEBHOOK_SECRET="${FINERACT_WEBHOOK_SECRET:-}"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[SETUP]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1" >&2; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# ── API Helper ─────────────────────────────────────────────────────

api() {
  local method=$1 path=$2
  shift 2
  curl -sk -X "${method}" \
    "${FINERACT_URL}/fineract-provider/api/v1${path}" \
    -H "Content-Type: application/json" \
    -H "Fineract-Platform-TenantId: ${TENANT}" \
    -u "${USERNAME}:${PASSWORD}" \
    "$@"
}

api_post() {
  local path=$1 data=$2
  api POST "${path}" -d "${data}"
}

api_get() {
  api GET "$1"
}

# ── Wait for Fineract ──────────────────────────────────────────────

wait_for_fineract() {
  log "Waiting for Fineract to be ready..."
  local max_attempts=30
  local attempt=0

  while [[ $attempt -lt $max_attempts ]]; do
    if curl -sk -o /dev/null -w "%{http_code}" \
      "${FINERACT_URL}/fineract-provider/actuator/health" 2>/dev/null | grep -q "200"; then
      log "Fineract is ready!"
      return 0
    fi
    ((attempt++))
    echo -n "."
    sleep 5
  done

  error "Fineract did not become ready within ${max_attempts} attempts"
  exit 1
}

# ── 1. Create Offices ──────────────────────────────────────────────

setup_offices() {
  log "Creating IMFSL office structure..."

  # Head Office (usually exists as ID 1)
  local head_office
  head_office=$(api_get "/offices" | python3 -c "
import sys, json
offices = json.load(sys.stdin)
for o in offices:
    if o.get('id') == 1:
        print(o['id'])
        break
" 2>/dev/null || echo "1")

  info "Head Office ID: ${head_office}"

  # Create branch offices
  for branch in "Dar es Salaam Branch" "Dodoma Branch" "Arusha Branch" "Mwanza Branch"; do
    local result
    result=$(api_post "/offices" "{
      \"name\": \"${branch}\",
      \"dateFormat\": \"dd MMMM yyyy\",
      \"locale\": \"en\",
      \"openingDate\": \"01 January 2024\",
      \"parentId\": ${head_office}
    }" 2>/dev/null)

    local office_id
    office_id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('resourceId','?'))" 2>/dev/null || echo "exists")
    info "  ${branch}: ${office_id}"
  done

  log "Offices created"
}

# ── 2. Create Loan Products ───────────────────────────────────────

setup_loan_products() {
  log "Creating IMFSL loan products..."

  # SME Group Loan
  api_post "/loanproducts" '{
    "name": "SME Group Loan",
    "shortName": "SMEG",
    "description": "Small and medium enterprise group lending product",
    "currencyCode": "TZS",
    "digitsAfterDecimal": 0,
    "inMultiplesOf": 1000,
    "principal": 5000000,
    "minPrincipal": 500000,
    "maxPrincipal": 50000000,
    "numberOfRepayments": 12,
    "minNumberOfRepayments": 3,
    "maxNumberOfRepayments": 36,
    "repaymentEvery": 1,
    "repaymentFrequencyType": 2,
    "interestRatePerPeriod": 2.5,
    "minInterestRatePerPeriod": 1.0,
    "maxInterestRatePerPeriod": 5.0,
    "interestRateFrequencyType": 2,
    "amortizationType": 1,
    "interestType": 1,
    "interestCalculationPeriodType": 1,
    "transactionProcessingStrategyCode": "mifos-standard-strategy",
    "graceOnPrincipalPayment": 0,
    "graceOnInterestPayment": 0,
    "includeInBorrowerCycle": true,
    "accountingRule": 1,
    "dateFormat": "dd MMMM yyyy",
    "locale": "en"
  }' >/dev/null 2>&1
  info "  SME Group Loan (SMEG)"

  # Individual Business Loan
  api_post "/loanproducts" '{
    "name": "Individual Business Loan",
    "shortName": "IBL",
    "description": "Individual business lending product for established businesses",
    "currencyCode": "TZS",
    "digitsAfterDecimal": 0,
    "inMultiplesOf": 1000,
    "principal": 10000000,
    "minPrincipal": 1000000,
    "maxPrincipal": 100000000,
    "numberOfRepayments": 12,
    "minNumberOfRepayments": 6,
    "maxNumberOfRepayments": 48,
    "repaymentEvery": 1,
    "repaymentFrequencyType": 2,
    "interestRatePerPeriod": 2.0,
    "minInterestRatePerPeriod": 1.0,
    "maxInterestRatePerPeriod": 4.0,
    "interestRateFrequencyType": 2,
    "amortizationType": 1,
    "interestType": 1,
    "interestCalculationPeriodType": 1,
    "transactionProcessingStrategyCode": "mifos-standard-strategy",
    "graceOnPrincipalPayment": 1,
    "graceOnInterestPayment": 0,
    "includeInBorrowerCycle": true,
    "accountingRule": 1,
    "dateFormat": "dd MMMM yyyy",
    "locale": "en"
  }' >/dev/null 2>&1
  info "  Individual Business Loan (IBL)"

  # Agricultural Loan
  api_post "/loanproducts" '{
    "name": "Agricultural Loan",
    "shortName": "AGRI",
    "description": "Seasonal agricultural lending for farming activities",
    "currencyCode": "TZS",
    "digitsAfterDecimal": 0,
    "inMultiplesOf": 1000,
    "principal": 3000000,
    "minPrincipal": 200000,
    "maxPrincipal": 20000000,
    "numberOfRepayments": 6,
    "minNumberOfRepayments": 3,
    "maxNumberOfRepayments": 12,
    "repaymentEvery": 1,
    "repaymentFrequencyType": 2,
    "interestRatePerPeriod": 1.5,
    "minInterestRatePerPeriod": 1.0,
    "maxInterestRatePerPeriod": 3.0,
    "interestRateFrequencyType": 2,
    "amortizationType": 1,
    "interestType": 0,
    "interestCalculationPeriodType": 1,
    "transactionProcessingStrategyCode": "mifos-standard-strategy",
    "graceOnPrincipalPayment": 3,
    "graceOnInterestPayment": 1,
    "includeInBorrowerCycle": false,
    "accountingRule": 1,
    "dateFormat": "dd MMMM yyyy",
    "locale": "en"
  }' >/dev/null 2>&1
  info "  Agricultural Loan (AGRI)"

  # Emergency/Short-term Loan
  api_post "/loanproducts" '{
    "name": "Emergency Short-term Loan",
    "shortName": "EMRG",
    "description": "Short-term emergency lending for urgent needs",
    "currencyCode": "TZS",
    "digitsAfterDecimal": 0,
    "inMultiplesOf": 1000,
    "principal": 1000000,
    "minPrincipal": 100000,
    "maxPrincipal": 5000000,
    "numberOfRepayments": 3,
    "minNumberOfRepayments": 1,
    "maxNumberOfRepayments": 6,
    "repaymentEvery": 1,
    "repaymentFrequencyType": 2,
    "interestRatePerPeriod": 3.0,
    "minInterestRatePerPeriod": 2.0,
    "maxInterestRatePerPeriod": 5.0,
    "interestRateFrequencyType": 2,
    "amortizationType": 1,
    "interestType": 0,
    "interestCalculationPeriodType": 1,
    "transactionProcessingStrategyCode": "mifos-standard-strategy",
    "graceOnPrincipalPayment": 0,
    "graceOnInterestPayment": 0,
    "includeInBorrowerCycle": false,
    "accountingRule": 1,
    "dateFormat": "dd MMMM yyyy",
    "locale": "en"
  }' >/dev/null 2>&1
  info "  Emergency Short-term Loan (EMRG)"

  log "Loan products created"
}

# ── 3. Create Staff ────────────────────────────────────────────────

setup_staff() {
  log "Creating IMFSL loan officers..."

  # Get first branch office ID
  local offices
  offices=$(api_get "/offices" 2>/dev/null)
  local office_id
  office_id=$(echo "$offices" | python3 -c "
import sys, json
offices = json.load(sys.stdin)
for o in offices:
    if o.get('id', 0) > 1:
        print(o['id'])
        break
else:
    print(1)
" 2>/dev/null || echo "1")

  for staff_data in \
    '{"officeId":'${office_id}',"firstname":"John","lastname":"Mushi","isLoanOfficer":true,"isActive":true,"joiningDate":"01 January 2024","dateFormat":"dd MMMM yyyy","locale":"en"}' \
    '{"officeId":'${office_id}',"firstname":"Mary","lastname":"Makundi","isLoanOfficer":true,"isActive":true,"joiningDate":"01 January 2024","dateFormat":"dd MMMM yyyy","locale":"en"}' \
    '{"officeId":1,"firstname":"Admin","lastname":"Officer","isLoanOfficer":false,"isActive":true,"joiningDate":"01 January 2024","dateFormat":"dd MMMM yyyy","locale":"en"}'; do
    local result
    result=$(api_post "/staff" "${staff_data}" 2>/dev/null)
    local name
    name=$(echo "${staff_data}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"{d['firstname']} {d['lastname']}\")" 2>/dev/null || echo "?")
    info "  ${name}"
  done

  log "Staff created"
}

# ── 4. Register Webhooks ──────────────────────────────────────────

setup_webhooks() {
  log "Registering Fineract webhooks..."

  if [[ -z "${WEBHOOK_SECRET}" ]]; then
    warn "FINERACT_WEBHOOK_SECRET not set. Skipping webhook registration."
    warn "Set it and re-run, or manually register hooks in Fineract."
    return
  fi

  # Register hooks for key events
  for entity_action in \
    "CREATE:CLIENT" "UPDATE:CLIENT" "DELETE:CLIENT" \
    "CREATE:LOAN" "APPROVE:LOAN" "DISBURSE:LOAN" "CLOSE:LOAN" "WRITEOFF:LOAN" \
    "CREATE:LOAN_TRANSACTION"; do

    IFS=':' read -r action entity <<< "${entity_action}"

    api_post "/hooks" "{
      \"name\": \"Web\",
      \"displayName\": \"IMFSL Supabase Sync - ${entity} ${action}\",
      \"isActive\": true,
      \"events\": [{
        \"actionName\": \"${action}\",
        \"entityName\": \"${entity}\"
      }],
      \"config\": [
        {\"fieldName\": \"Payload URL\", \"fieldValue\": \"${WEBHOOK_URL}\"},
        {\"fieldName\": \"Content Type\", \"fieldValue\": \"json\"}
      ]
    }" >/dev/null 2>&1

    info "  ${entity}.${action} → ${WEBHOOK_URL}"
  done

  log "Webhooks registered"
  info "All Fineract events will be sent to: ${WEBHOOK_URL}"
}

# ── 5. Verify Setup ───────────────────────────────────────────────

verify_setup() {
  log "Verifying Fineract setup..."

  local offices loans_products staff hooks

  offices=$(api_get "/offices" 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  info "  Offices: ${offices}"

  loans_products=$(api_get "/loanproducts" 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  info "  Loan Products: ${loans_products}"

  staff=$(api_get "/staff" 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  info "  Staff: ${staff}"

  hooks=$(api_get "/hooks" 2>/dev/null | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "?")
  info "  Webhooks: ${hooks}"

  echo ""
  log "Setup complete!"
  echo ""
  info "Fineract API:  ${FINERACT_URL}/fineract-provider/api/v1"
  info "Admin Login:   ${USERNAME} / (your password)"
  info "Tenant ID:     ${TENANT}"
  echo ""
  info "Next steps:"
  info "  1. Run migration 006 in Supabase SQL Editor"
  info "  2. Set env vars: FINERACT_BASE_URL, FINERACT_USERNAME, FINERACT_PASSWORD"
  info "  3. Deploy Edge Functions: ./scripts/deploy-fineract.sh"
  info "  4. Run initial sync: curl -X POST .../fineract-batch-sync"
  info "  5. Build Retool dashboards using the v_* views and rpc_* functions"
}

# ── Main ───────────────────────────────────────────────────────────

echo ""
echo "============================================="
echo " Apache Fineract — IMFSL Setup"
echo "============================================="
echo ""

wait_for_fineract
setup_offices
setup_loan_products
setup_staff
setup_webhooks
verify_setup
