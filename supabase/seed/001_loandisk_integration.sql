-- Seed: Default Loandisk integration configuration
-- Run once to bootstrap the integration record that the webhook Edge Function references.
-- Already seeded via REST API on 2026-02-13 (id: c4023907-dfa5-4926-b06e-cb4667e49c00)
-- This SQL is kept as a repeatable reference.

INSERT INTO loandisk_integrations (
  integration_name,
  environment,
  base_url,
  allowed_ip_ranges,
  is_active,
  sync_enabled,
  sync_interval_minutes,
  sync_loans,
  sync_repayments,
  sync_customers,
  sync_branches,
  created_at,
  updated_at
)
SELECT
  'Loandisk Production',
  'production',
  'https://api.loandisk.com',
  ARRAY[]::text[],
  true,
  true,
  60,
  true,
  true,
  true,
  false,
  now(),
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM loandisk_integrations
  WHERE integration_name = 'Loandisk Production'
    AND environment = 'production'
);
