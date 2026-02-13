-- ============================================================================
-- MIGRATION: Drop Duplicate/Superseded Tables — Phase 1 (Safe Drops)
-- Date:       2026-02-13
-- Reference:  docs/DUPLICATE_TABLE_AUDIT.md
-- Criteria:   0 rows, 0 active code references, confirmed superseded
-- Rollback:   Recreate from schema definitions (no data loss — all empty)
-- ============================================================================

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. LoanDisk Legacy Tables (superseded by raw_* + canonical pipeline)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.ld_borrowers CASCADE;
DROP TABLE IF EXISTS public.ld_loans CASCADE;
DROP TABLE IF EXISTS public.ld_repayments CASCADE;
DROP TABLE IF EXISTS public.fin_borrowers CASCADE;
DROP TABLE IF EXISTS public.fin_loans CASCADE;
DROP TABLE IF EXISTS public.sync_runs CASCADE;
DROP TABLE IF EXISTS public.staging_loans_import CASCADE;
DROP TABLE IF EXISTS public.customer_loans CASCADE;
DROP TABLE IF EXISTS public.customers_core CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Attendance Superseded Versions (empty, never deployed)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.attendance_v2 CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Leave Management Duplicates (empty, rigid schema superseded)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.leave_balance CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. Petty Cash Legacy (empty, superseded by boxes/registers system)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.petty_cash CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. Roles & Permissions (empty, superseded by enterprise_permissions)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.staff_permissions CASCADE;
DROP TABLE IF EXISTS public.staff_roles CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. Repayment Duplicate (empty, superseded by repayments table)
-- ─────────────────────────────────────────────────────────────────────────────
DROP TABLE IF EXISTS public.loan_repayments CASCADE;

COMMIT;

-- ============================================================================
-- POST-MIGRATION VERIFICATION
-- Run this query to confirm all tables were dropped:
--
-- SELECT table_name FROM information_schema.tables
-- WHERE table_schema = 'public'
--   AND table_name IN (
--     'ld_borrowers','ld_loans','ld_repayments',
--     'fin_borrowers','fin_loans','sync_runs',
--     'staging_loans_import','customer_loans','customers_core',
--     'attendance_v2','leave_balance','petty_cash',
--     'staff_permissions','staff_roles','role_permissions',
--     'permissions','loan_repayments'
--   );
-- Expected result: 0 rows
-- ============================================================================
