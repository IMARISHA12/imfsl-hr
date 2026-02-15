-- ============================================================================
-- MIGRATION 011: RLS Policies for Real V2/V3 HR Tables
-- Date:       2026-02-15
-- Purpose:    Add Row Level Security on the actual tables used by the
--             HR Flutter app and Edge Functions:
--               staff_attendance_v3, leave_requests_v2, staff_loans,
--               notifications, staff_performance, attendance_settings
--
--             Migration 009 created RLS for the OLD table names
--             (attendance_records, leave_requests, hr_notifications).
--             This migration covers the newer versioned tables.
--
-- Strategy:   Fully idempotent — uses IF EXISTS guard + DROP...IF EXISTS
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- A1. staff_attendance_v3 — main attendance table used by the app
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'staff_attendance_v3' AND table_schema = 'public') THEN

    ALTER TABLE public.staff_attendance_v3 ENABLE ROW LEVEL SECURITY;

    -- Staff can read their own attendance records; managers/admins can read all
    DROP POLICY IF EXISTS attendance_v3_select ON public.staff_attendance_v3;
    CREATE POLICY attendance_v3_select ON public.staff_attendance_v3
      FOR SELECT USING (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Staff can insert (clock in) their own records
    DROP POLICY IF EXISTS attendance_v3_insert ON public.staff_attendance_v3;
    CREATE POLICY attendance_v3_insert ON public.staff_attendance_v3
      FOR INSERT WITH CHECK (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
      );

    -- Staff can update (clock out) their own records; service_role can update any
    DROP POLICY IF EXISTS attendance_v3_update ON public.staff_attendance_v3;
    CREATE POLICY attendance_v3_update ON public.staff_attendance_v3
      FOR UPDATE USING (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
      );

    -- Only service_role can delete
    DROP POLICY IF EXISTS attendance_v3_delete ON public.staff_attendance_v3;
    CREATE POLICY attendance_v3_delete ON public.staff_attendance_v3
      FOR DELETE USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A2. leave_requests_v2 — main leave request table
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'leave_requests_v2' AND table_schema = 'public') THEN

    ALTER TABLE public.leave_requests_v2 ENABLE ROW LEVEL SECURITY;

    -- Staff see own; managers/admins see all
    DROP POLICY IF EXISTS leave_v2_select ON public.leave_requests_v2;
    CREATE POLICY leave_v2_select ON public.leave_requests_v2
      FOR SELECT USING (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Staff can submit own leave requests
    DROP POLICY IF EXISTS leave_v2_insert ON public.leave_requests_v2;
    CREATE POLICY leave_v2_insert ON public.leave_requests_v2
      FOR INSERT WITH CHECK (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
      );

    -- Staff can update own pending requests (cancel); service_role manages all
    DROP POLICY IF EXISTS leave_v2_update ON public.leave_requests_v2;
    CREATE POLICY leave_v2_update ON public.leave_requests_v2
      FOR UPDATE USING (
        (staff_id = auth.uid()::text AND status = 'pending')
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Only service_role can delete
    DROP POLICY IF EXISTS leave_v2_delete ON public.leave_requests_v2;
    CREATE POLICY leave_v2_delete ON public.leave_requests_v2
      FOR DELETE USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A3. staff_loans — employee loan tracking
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'staff_loans' AND table_schema = 'public') THEN

    ALTER TABLE public.staff_loans ENABLE ROW LEVEL SECURITY;

    -- Employees see own loans; HR/finance/admins see all
    DROP POLICY IF EXISTS staff_loans_select ON public.staff_loans;
    CREATE POLICY staff_loans_select ON public.staff_loans
      FOR SELECT USING (
        employee_id IN (
          SELECT id FROM public.employees WHERE user_id = auth.uid()
        )
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'finance')
        )
      );

    -- Only service_role can insert/update/delete
    DROP POLICY IF EXISTS staff_loans_admin ON public.staff_loans;
    CREATE POLICY staff_loans_admin ON public.staff_loans
      FOR ALL USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A4. notifications — user notification inbox
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'notifications' AND table_schema = 'public') THEN

    ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

    -- Users see their own notifications
    DROP POLICY IF EXISTS notifications_own ON public.notifications;
    CREATE POLICY notifications_own ON public.notifications
      FOR SELECT USING (
        user_id = auth.uid()::text
        OR auth.role() = 'service_role'
      );

    -- Users can update (mark as read) their own notifications
    DROP POLICY IF EXISTS notifications_update ON public.notifications;
    CREATE POLICY notifications_update ON public.notifications
      FOR UPDATE USING (
        user_id = auth.uid()::text
        OR auth.role() = 'service_role'
      );

    -- Only service_role can insert/delete notifications
    DROP POLICY IF EXISTS notifications_admin ON public.notifications;
    CREATE POLICY notifications_admin ON public.notifications
      FOR INSERT WITH CHECK (auth.role() = 'service_role');

    DROP POLICY IF EXISTS notifications_delete ON public.notifications;
    CREATE POLICY notifications_delete ON public.notifications
      FOR DELETE USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A5. staff_performance — KPI data
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'staff_performance' AND table_schema = 'public') THEN

    ALTER TABLE public.staff_performance ENABLE ROW LEVEL SECURITY;

    -- Staff see own performance data; managers/admins see all
    DROP POLICY IF EXISTS staff_perf_select ON public.staff_performance;
    CREATE POLICY staff_perf_select ON public.staff_performance
      FOR SELECT USING (
        staff_id = auth.uid()::text
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Only service_role can modify
    DROP POLICY IF EXISTS staff_perf_admin ON public.staff_performance;
    CREATE POLICY staff_perf_admin ON public.staff_performance
      FOR ALL USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A6. attendance_settings — office configuration (read-only for staff)
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'attendance_settings' AND table_schema = 'public') THEN

    ALTER TABLE public.attendance_settings ENABLE ROW LEVEL SECURITY;

    -- All authenticated users can read settings
    DROP POLICY IF EXISTS attendance_settings_read ON public.attendance_settings;
    CREATE POLICY attendance_settings_read ON public.attendance_settings
      FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

    -- Only service_role can modify
    DROP POLICY IF EXISTS attendance_settings_admin ON public.attendance_settings;
    CREATE POLICY attendance_settings_admin ON public.attendance_settings
      FOR ALL USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- A7. employees — core employee table (if not already RLS-enabled)
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'employees' AND table_schema = 'public') THEN

    ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

    -- Users can see their own employee record; managers/admins see all
    DROP POLICY IF EXISTS employees_own ON public.employees;
    CREATE POLICY employees_own ON public.employees
      FOR SELECT USING (
        user_id = auth.uid()
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Only service_role can modify employee records
    DROP POLICY IF EXISTS employees_admin ON public.employees;
    CREATE POLICY employees_admin ON public.employees
      FOR ALL USING (auth.role() = 'service_role');

  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- GRANTS — ensure authenticated role can access these tables
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  -- Grant SELECT/INSERT/UPDATE to authenticated for tables staff interacts with
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'staff_attendance_v3') THEN
    GRANT SELECT, INSERT, UPDATE ON public.staff_attendance_v3 TO authenticated;
    GRANT ALL ON public.staff_attendance_v3 TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leave_requests_v2') THEN
    GRANT SELECT, INSERT, UPDATE ON public.leave_requests_v2 TO authenticated;
    GRANT ALL ON public.leave_requests_v2 TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'staff_loans') THEN
    GRANT SELECT ON public.staff_loans TO authenticated;
    GRANT ALL ON public.staff_loans TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
    GRANT SELECT, UPDATE ON public.notifications TO authenticated;
    GRANT ALL ON public.notifications TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'staff_performance') THEN
    GRANT SELECT ON public.staff_performance TO authenticated;
    GRANT ALL ON public.staff_performance TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'attendance_settings') THEN
    GRANT SELECT ON public.attendance_settings TO authenticated;
    GRANT ALL ON public.attendance_settings TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'employees') THEN
    GRANT SELECT ON public.employees TO authenticated;
    GRANT ALL ON public.employees TO service_role;
  END IF;

  -- Views follow base table RLS, but need SELECT grants
  IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'attendance_v2_today') THEN
    GRANT SELECT ON public.attendance_v2_today TO authenticated;
    GRANT ALL ON public.attendance_v2_today TO service_role;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'leave_requests_v2_enriched') THEN
    GRANT SELECT ON public.leave_requests_v2_enriched TO authenticated;
    GRANT ALL ON public.leave_requests_v2_enriched TO service_role;
  END IF;
END $$;
