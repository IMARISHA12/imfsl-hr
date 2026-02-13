-- ============================================================================
-- MIGRATION: Consolidate Overlapping Tables — Phase 3 (Data Migration)
-- Date:       2026-02-13
-- Reference:  docs/DUPLICATE_TABLE_AUDIT.md
-- Criteria:   Tables with small row counts that can be merged into canonical
-- ============================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Add ip_address to audit_logs, migrate audit_logs_new, then drop
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE public.audit_logs
  ADD COLUMN IF NOT EXISTS ip_address inet;

-- Migrate the 2 rows from audit_logs_new → audit_logs
INSERT INTO public.audit_logs (table_name, record_id, operation, old_data, new_data, changed_by, changed_at, ip_address)
SELECT
  aln.table_name,
  aln.record_id,
  aln.action,
  aln.old_data,
  aln.new_data,
  aln.changed_by,
  aln.timestamp,
  aln.ip_address::inet
FROM public.audit_logs_new aln
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS public.audit_logs_new CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Migrate leave_policy → leave_policies, then drop
--    Map overlapping columns; leave_policies has richer schema
-- ─────────────────────────────────────────────────────────────────────────────
INSERT INTO public.leave_policies (
  leave_type,
  is_active,
  annual_entitlement_days,
  max_consecutive_days,
  min_advance_notice_days,
  min_service_months,
  requires_document,
  applicable_gender,
  created_at
)
SELECT
  lp.leave_type,
  lp.is_active,
  lp.max_days_per_year,
  lp.max_days_per_request,
  lp.requires_advance_notice_days,
  lp.min_service_months,
  lp.requires_attachment,
  lp.gender_restriction,
  lp.created_at
FROM public.leave_policy lp
WHERE NOT EXISTS (
  SELECT 1 FROM public.leave_policies lps
  WHERE lps.leave_type = lp.leave_type
)
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS public.leave_policy CASCADE;

COMMIT;

-- ============================================================================
-- POST-MIGRATION VERIFICATION
-- 1. SELECT count(*) FROM audit_logs WHERE ip_address IS NOT NULL;
--    Expected: >= 2 (migrated from audit_logs_new)
--
-- 2. SELECT count(*) FROM leave_policies;
--    Expected: >= 6 (original 6 + any unique types from leave_policy)
--
-- 3. Verify dropped:
--    SELECT table_name FROM information_schema.tables
--    WHERE table_schema = 'public'
--      AND table_name IN ('audit_logs_new', 'leave_policy');
--    Expected: 0 rows
-- ============================================================================
