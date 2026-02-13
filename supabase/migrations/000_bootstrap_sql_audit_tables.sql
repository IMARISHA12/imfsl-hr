-- ============================================================================
-- MIGRATION: Bootstrap Missing Audit Tables for SQL Exec Functions
-- Date:       2026-02-13
-- Priority:   RUN THIS FIRST (before other migrations)
-- Purpose:    Restores admin_sql_audit and sql_editor_audit tables
--             which are required by admin_sql_exec() and sql_editor_run()
-- ============================================================================

BEGIN;

-- admin_sql_exec depends on this table for audit logging
CREATE TABLE IF NOT EXISTS public.admin_sql_audit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  executed_at timestamptz DEFAULT now() NOT NULL,
  sql_text text NOT NULL,
  executed_by text DEFAULT current_user,
  result_status text DEFAULT 'success',
  error_message text
);

-- sql_editor_run depends on this table for audit logging
CREATE TABLE IF NOT EXISTS public.sql_editor_audit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  executed_at timestamptz DEFAULT now() NOT NULL,
  sql_text text NOT NULL,
  params jsonb,
  executed_by text DEFAULT current_user,
  result_status text DEFAULT 'success',
  error_message text
);

-- Enable RLS but allow service_role to bypass
ALTER TABLE public.admin_sql_audit ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sql_editor_audit ENABLE ROW LEVEL SECURITY;

-- Only service_role should access these
CREATE POLICY admin_sql_audit_service_only ON public.admin_sql_audit
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY sql_editor_audit_service_only ON public.sql_editor_audit
  FOR ALL USING (auth.role() = 'service_role');

COMMIT;

-- ============================================================================
-- VERIFICATION:
-- SELECT * FROM admin_sql_audit LIMIT 1;
-- SELECT * FROM sql_editor_audit LIMIT 1;
-- Both should return empty results (no error)
--
-- Then test:
-- SELECT admin_sql_exec('SELECT current_database()');
-- Should now work without the "relation does not exist" error
-- ============================================================================
