#!/usr/bin/env bash
# ============================================================================
# Test HR Edge Functions
#
# Usage:
#   ./scripts/test-hr-workflows.sh                  # Run all tests
#   ./scripts/test-hr-workflows.sh --payroll        # Test payroll only
#   ./scripts/test-hr-workflows.sh --leave          # Test leave only
#   ./scripts/test-hr-workflows.sh --attendance     # Test attendance only
#   ./scripts/test-hr-workflows.sh --performance    # Test performance only
#
# Required environment variables:
#   SUPABASE_URL              - Supabase project URL
#   SUPABASE_SERVICE_ROLE_KEY - Service role key for authentication
# ============================================================================

set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-https://lzyixazjquouicfsfzzu.supabase.co}"
SERVICE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-}"
BASE="${SUPABASE_URL}/functions/v1"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { echo -e "  ${RED}FAIL${NC} $1"; }
skip() { echo -e "  ${YELLOW}SKIP${NC} $1"; }
info() { echo -e "  ${BLUE}INFO${NC} $1"; }

PASSED=0
FAILED=0

if [[ -z "${SERVICE_KEY}" ]]; then
  echo "ERROR: SUPABASE_SERVICE_ROLE_KEY is required"
  echo "  export SUPABASE_SERVICE_ROLE_KEY=your-service-key"
  exit 1
fi

AUTH_HEADER="Authorization: Bearer ${SERVICE_KEY}"

# ── Helpers ────────────────────────────────────────────────────────

call_fn() {
  local fn=$1 payload=$2
  curl -s -w "\n%{http_code}" -X POST \
    "${BASE}/${fn}" \
    -H "Content-Type: application/json" \
    -H "${AUTH_HEADER}" \
    -d "${payload}"
}

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

assert_json_field() {
  local name=$1 body=$2 field=$3 expected=$4
  local actual
  actual=$(echo "$body" | jq -r ".${field}" 2>/dev/null)
  if [[ "$actual" == "$expected" ]]; then
    pass "$name (.${field} = ${expected})"
    ((PASSED++))
  else
    fail "$name (.${field} expected '${expected}', got '${actual}')"
    ((FAILED++))
  fi
}

# ── Test: Payroll Processor ────────────────────────────────────────

test_payroll() {
  echo ""
  echo "=== HR Payroll Processor Tests ==="

  # Test missing operation
  local response status body
  response=$(call_fn "hr-payroll-processor" '{}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  assert_status "Reject missing operation" "400" "$status"

  # Test unknown operation
  response=$(call_fn "hr-payroll-processor" '{"operation":"invalid"}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  assert_status "Reject unknown operation" "400" "$status"

  # Test create_run
  response=$(call_fn "hr-payroll-processor" '{"operation":"create_run","month":1,"year":2026}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$status" == "200" ]]; then
    assert_status "Create payroll run" "200" "$status"
    assert_json_field "Create payroll run" "$body" "success" "true"

    # Extract run_id for further tests
    local run_id
    run_id=$(echo "$body" | jq -r ".payroll_run_id" 2>/dev/null)
    info "Created payroll run: ${run_id}"

    if [[ -n "${run_id}" && "${run_id}" != "null" ]]; then
      # Test generate payslips
      response=$(call_fn "hr-payroll-processor" "{\"operation\":\"generate\",\"payroll_run_id\":\"${run_id}\"}")
      status=$(echo "$response" | tail -1)
      body=$(echo "$response" | sed '$d')
      info "Generate payslips: HTTP ${status} - $(echo "$body" | jq -c '.' 2>/dev/null | head -c 100)"

      # Test approve
      response=$(call_fn "hr-payroll-processor" "{\"operation\":\"approve\",\"payroll_run_id\":\"${run_id}\",\"approved_by\":\"test\"}")
      status=$(echo "$response" | tail -1)
      info "Approve payroll: HTTP ${status}"
    fi
  else
    assert_status "Create payroll run" "200" "$status"
    info "Body: $(echo "$body" | jq -c '.' 2>/dev/null | head -c 200)"
  fi

  # Test generate without run_id
  response=$(call_fn "hr-payroll-processor" '{"operation":"generate"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject generate without run_id" "400" "$status"
}

# ── Test: Leave Workflow ───────────────────────────────────────────

test_leave() {
  echo ""
  echo "=== HR Leave Workflow Tests ==="

  # Test missing operation
  local response status body
  response=$(call_fn "hr-leave-workflow" '{}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject missing operation" "400" "$status"

  # Test submit missing fields
  response=$(call_fn "hr-leave-workflow" '{"operation":"submit"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject submit without required fields" "400" "$status"

  # Test balance
  response=$(call_fn "hr-leave-workflow" '{"operation":"balance","user_id":"00000000-0000-0000-0000-000000000000"}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$status" == "200" ]]; then
    assert_status "Get leave balance (empty user)" "200" "$status"
    assert_json_field "Balance response" "$body" "success" "true"
  else
    assert_status "Get leave balance" "200" "$status"
    info "Body: $(echo "$body" | jq -c '.' 2>/dev/null | head -c 200)"
  fi

  # Test team calendar
  response=$(call_fn "hr-leave-workflow" '{"operation":"team_calendar","start_date":"2026-01-01","end_date":"2026-01-31"}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$status" == "200" ]]; then
    assert_status "Get team calendar" "200" "$status"
  else
    assert_status "Get team calendar" "200" "$status"
  fi

  # Test reject without manager comment
  response=$(call_fn "hr-leave-workflow" '{"operation":"reject","request_id":"00000000-0000-0000-0000-000000000000"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject rejection without comment" "400" "$status"

  # Test init_year
  response=$(call_fn "hr-leave-workflow" '{"operation":"init_year","year":2026}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
  info "Init year: HTTP ${status} - $(echo "$body" | jq -c '.' 2>/dev/null | head -c 100)"
}

# ── Test: Attendance ───────────────────────────────────────────────

test_attendance() {
  echo ""
  echo "=== HR Attendance Tests ==="

  # Test missing operation
  local response status body
  response=$(call_fn "hr-attendance" '{}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject missing operation" "400" "$status"

  # Test clock_in without staff_id
  response=$(call_fn "hr-attendance" '{"operation":"clock_in"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject clock_in without staff_id" "400" "$status"

  # Test today's attendance
  response=$(call_fn "hr-attendance" '{"operation":"today"}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$status" == "200" ]]; then
    assert_status "Get today's attendance" "200" "$status"
    assert_json_field "Today response" "$body" "success" "true"
    local present absent
    present=$(echo "$body" | jq -r ".stats.present_count" 2>/dev/null)
    absent=$(echo "$body" | jq -r ".stats.absent_count" 2>/dev/null)
    info "Today: ${present} present, ${absent} absent"
  else
    assert_status "Get today's attendance" "200" "$status"
    info "Body: $(echo "$body" | jq -c '.' 2>/dev/null | head -c 200)"
  fi

  # Test rate without record_id
  response=$(call_fn "hr-attendance" '{"operation":"rate"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject rate without record_id" "400" "$status"
}

# ── Test: Performance Review ──────────────────────────────────────

test_performance() {
  echo ""
  echo "=== HR Performance Review Tests ==="

  # Test missing operation
  local response status body
  response=$(call_fn "hr-performance-review" '{}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject missing operation" "400" "$status"

  # Test create_cycle missing fields
  response=$(call_fn "hr-performance-review" '{"operation":"create_cycle"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject create_cycle without fields" "400" "$status"

  # Test create_cycle
  response=$(call_fn "hr-performance-review" '{"operation":"create_cycle","cycle_name":"Test Q1 2026","period_start":"2026-01-01","period_end":"2026-03-31","cycle_type":"quarterly"}')
  status=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$status" == "200" ]]; then
    assert_status "Create review cycle" "200" "$status"
    assert_json_field "Cycle created" "$body" "success" "true"

    local cycle_id
    cycle_id=$(echo "$body" | jq -r ".cycle_id" 2>/dev/null)
    info "Created cycle: ${cycle_id}"

    if [[ -n "${cycle_id}" && "${cycle_id}" != "null" ]]; then
      # Test cycle summary
      response=$(call_fn "hr-performance-review" "{\"operation\":\"cycle_summary\",\"cycle_id\":\"${cycle_id}\"}")
      status=$(echo "$response" | tail -1)
      info "Cycle summary: HTTP ${status}"
    fi
  else
    assert_status "Create review cycle" "200" "$status"
    info "Body: $(echo "$body" | jq -c '.' 2>/dev/null | head -c 200)"
  fi

  # Test self_review missing scores
  response=$(call_fn "hr-performance-review" '{"operation":"self_review","review_id":"00000000-0000-0000-0000-000000000000"}')
  status=$(echo "$response" | tail -1)
  assert_status "Reject self_review without scores" "400" "$status"
}

# ── Main ───────────────────────────────────────────────────────────

case "${1:-all}" in
  --payroll)      test_payroll ;;
  --leave)        test_leave ;;
  --attendance)   test_attendance ;;
  --performance)  test_performance ;;
  all|--all)
    test_payroll
    test_leave
    test_attendance
    test_performance
    ;;
  *)
    echo "Usage: $0 [--payroll|--leave|--attendance|--performance|--all]"
    exit 1
    ;;
esac

# ── Summary ────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════"
echo "  HR Tests: ${PASSED} passed, ${FAILED} failed"
echo "════════════════════════════════════════════"
echo ""

if [[ "${FAILED}" -gt 0 ]]; then
  exit 1
fi
