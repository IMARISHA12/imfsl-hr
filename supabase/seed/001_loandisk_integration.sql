-- Seed: Default Loandisk integration configuration
-- Run once to bootstrap the integration record that the webhook Edge Function references.

INSERT INTO loandisk_integrations (
  id,
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
  updated_at,
  created_by
)
VALUES (
  gen_random_uuid(),
  'Loandisk Production',
  'production',
  'https://api.loandisk.com',
  ARRAY[]::text[],          -- No IP restriction initially; tighten once Loandisk IPs are known
  true,
  true,
  60,                       -- Sync every 60 minutes (for scheduled pulls)
  true,
  true,
  true,
  false,                    -- Branch sync disabled by default
  now(),
  now(),
  'system'
)
ON CONFLICT DO NOTHING;
