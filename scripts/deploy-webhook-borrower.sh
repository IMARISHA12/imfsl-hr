#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# Deploy loandisk-webhook-borrower Edge Function to Supabase
#
# Prerequisites:
#   1. Supabase CLI installed (brew install supabase/tap/supabase)
#   2. Authenticated: supabase login
#   3. .env file with LOANDISK_WEBHOOK_SECRET (generate with: openssl rand -hex 32)
#
# Usage:
#   ./scripts/deploy-webhook-borrower.sh
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

PROJECT_REF="lzyixazjquouicfsfzzu"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env
if [ -f "$PROJECT_DIR/.env" ]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

WEBHOOK_SECRET="${LOANDISK_WEBHOOK_SECRET:?Missing LOANDISK_WEBHOOK_SECRET in .env}"

echo ""
echo "  Deploying loandisk-webhook-borrower"
echo "  Project: ${PROJECT_REF}"
echo "  ─────────────────────────────────────────"
echo ""

# Step 1: Set Edge Function secrets
echo "[1/3] Setting Edge Function secrets..."
supabase secrets set \
  "LOANDISK_WEBHOOK_SECRET=${WEBHOOK_SECRET}" \
  --project-ref "${PROJECT_REF}"
echo "  Done."
echo ""

# Step 2: Deploy the function
echo "[2/3] Deploying Edge Function..."
cd "$PROJECT_DIR"
supabase functions deploy loandisk-webhook-borrower \
  --project-ref "${PROJECT_REF}"
echo "  Done."
echo ""

# Step 3: Verify deployment
echo "[3/3] Verifying deployment..."
RESP=$(curl -s -w "\n%{http_code}" \
  "https://${PROJECT_REF}.supabase.co/functions/v1/loandisk-webhook-borrower" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"event":"ping"}')
STATUS=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | head -n -1)

if [ "$STATUS" = "401" ]; then
  echo "  Function is live (returned 401 for unauthenticated request)."
elif [ "$STATUS" = "200" ]; then
  echo "  Function is live and responding."
else
  echo "  WARNING: Unexpected status $STATUS"
  echo "  Response: $BODY"
fi

echo ""
echo "  Deployment complete!"
echo ""
echo "  Webhook URL:"
echo "    https://${PROJECT_REF}.supabase.co/functions/v1/loandisk-webhook-borrower"
echo "    https://api.admin-imarishamaisha.co.tz/functions/v1/loandisk-webhook-borrower"
echo ""
echo "  Configure Loandisk to send webhooks to the URL above with header:"
echo "    x-webhook-secret: <your LOANDISK_WEBHOOK_SECRET value>"
echo ""
echo "  Run the test suite:"
echo "    ./scripts/test-webhook-borrower.sh"
echo ""
