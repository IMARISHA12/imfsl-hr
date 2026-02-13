-- ============================================================================
-- MIGRATION: Drop z_archive_ Tables — Phase 2 (Archive Cleanup)
-- Date:       2026-02-13
-- Reference:  docs/DUPLICATE_TABLE_AUDIT.md
-- Criteria:   z_archive_ prefix, 0 active code references
-- Note:       These are historical schema backups from past migrations
-- ============================================================================

BEGIN;

DROP TABLE IF EXISTS public.z_archive__policy_backup_user_governance_roles CASCADE;
DROP TABLE IF EXISTS public.z_archive__rls_policy_backup CASCADE;
DROP TABLE IF EXISTS public.z_archive__rls_policy_backup_cleanup CASCADE;
DROP TABLE IF EXISTS public.z_archive_alert_suppression_metrics CASCADE;
DROP TABLE IF EXISTS public.z_archive_alerts_metrics CASCADE;
DROP TABLE IF EXISTS public.z_archive_analytics_events CASCADE;
DROP TABLE IF EXISTS public.z_archive_approval_flows CASCADE;
DROP TABLE IF EXISTS public.z_archive_approval_levels CASCADE;
DROP TABLE IF EXISTS public.z_archive_approval_steps CASCADE;
DROP TABLE IF EXISTS public.z_archive_asset_categories CASCADE;
DROP TABLE IF EXISTS public.z_archive_attendance_events CASCADE;
DROP TABLE IF EXISTS public.z_archive_award_types CASCADE;
DROP TABLE IF EXISTS public.z_archive_benchmark_standards CASCADE;
DROP TABLE IF EXISTS public.z_archive_billing_categories CASCADE;
DROP TABLE IF EXISTS public.z_archive_database_backups CASCADE;
DROP TABLE IF EXISTS public.z_archive_document_access_logs CASCADE;
DROP TABLE IF EXISTS public.z_archive_edge_function_metrics CASCADE;
DROP TABLE IF EXISTS public.z_archive_edge_metrics_refresh_audit CASCADE;
DROP TABLE IF EXISTS public.z_archive_email_templates CASCADE;
DROP TABLE IF EXISTS public.z_archive_employee_learning_modules CASCADE;
DROP TABLE IF EXISTS public.z_archive_employee_onboarding_status CASCADE;
DROP TABLE IF EXISTS public.z_archive_finance_audit_logs_old_20251015_1033 CASCADE;
DROP TABLE IF EXISTS public.z_archive_finance_permissions CASCADE;
DROP TABLE IF EXISTS public.z_archive_finance_role_permissions CASCADE;
DROP TABLE IF EXISTS public.z_archive_gl_periods CASCADE;
DROP TABLE IF EXISTS public.z_archive_governance_role_audit CASCADE;
DROP TABLE IF EXISTS public.z_archive_health_check_reports CASCADE;
DROP TABLE IF EXISTS public.z_archive_hr_review_question_bank CASCADE;
DROP TABLE IF EXISTS public.z_archive_imfsl_branches CASCADE;
DROP TABLE IF EXISTS public.z_archive_integration_logs CASCADE;
DROP TABLE IF EXISTS public.z_archive_knowledge_base_articles CASCADE;
DROP TABLE IF EXISTS public.z_archive_leave_approval_matrix CASCADE;
DROP TABLE IF EXISTS public.z_archive_leave_types CASCADE;
DROP TABLE IF EXISTS public.z_archive_monitoring_thresholds CASCADE;
DROP TABLE IF EXISTS public.z_archive_mv_refresh_status CASCADE;
DROP TABLE IF EXISTS public.z_archive_n8n_workflows CASCADE;
DROP TABLE IF EXISTS public.z_archive_perf_alerts CASCADE;
DROP TABLE IF EXISTS public.z_archive_perf_metrics CASCADE;
DROP TABLE IF EXISTS public.z_archive_perf_thresholds CASCADE;
DROP TABLE IF EXISTS public.z_archive_permissions CASCADE;
DROP TABLE IF EXISTS public.z_archive_pii_field_mappings CASCADE;
DROP TABLE IF EXISTS public.z_archive_policies CASCADE;
DROP TABLE IF EXISTS public.z_archive_positions CASCADE;
DROP TABLE IF EXISTS public.z_archive_purge_audit CASCADE;
DROP TABLE IF EXISTS public.z_archive_role_permissions CASCADE;
DROP TABLE IF EXISTS public.z_archive_roles CASCADE;
DROP TABLE IF EXISTS public.z_archive_security_alerts CASCADE;
DROP TABLE IF EXISTS public.z_archive_security_audit_logs CASCADE;
DROP TABLE IF EXISTS public.z_archive_security_definer_allowlist CASCADE;
DROP TABLE IF EXISTS public.z_archive_security_incident_workflows CASCADE;
DROP TABLE IF EXISTS public.z_archive_security_playbooks CASCADE;
DROP TABLE IF EXISTS public.z_archive_skills_matrix CASCADE;
DROP TABLE IF EXISTS public.z_archive_system_configuration CASCADE;
DROP TABLE IF EXISTS public.z_archive_system_configurations CASCADE;
DROP TABLE IF EXISTS public.z_archive_system_events CASCADE;
DROP TABLE IF EXISTS public.z_archive_tamper_evident_audit CASCADE;
DROP TABLE IF EXISTS public.z_archive_task_templates CASCADE;
DROP TABLE IF EXISTS public.z_archive_tax_rules CASCADE;
DROP TABLE IF EXISTS public.z_archive_token_audit_logs CASCADE;
DROP TABLE IF EXISTS public.z_archive_tz_tax_config CASCADE;
DROP TABLE IF EXISTS public.z_archive_vendor_cache_metrics CASCADE;

COMMIT;

-- ============================================================================
-- POST-MIGRATION VERIFICATION
-- Run: SELECT count(*) FROM information_schema.tables
--      WHERE table_schema = 'public' AND table_name LIKE 'z_archive_%';
-- Expected result: 0
-- ============================================================================
