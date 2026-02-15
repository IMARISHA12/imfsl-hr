-- ============================================================================
-- MIGRATION 012: Create Missing HR Tables, Views & Aliases
-- Date:       2026-02-15
-- Purpose:    The Flutter app (hr_service.dart) and Edge Functions reference
--             several tables/views that were never created in prior migrations.
--             This migration creates them so the app can actually function.
--
--   NEW TABLES:
--     staff_attendance_v3     — clock-in/out records
--     leave_requests_v2       — leave requests (versioned)
--     leave_types             — leave type lookup
--     leave_balances          — per-user per-year entitlements
--     attendance_settings     — office attendance config
--     notifications           — user notification inbox (Dart uses this name)
--     staff_loans             — alias for staff_salary_loans
--
--   NEW VIEWS:
--     attendance_v2_today     — today's attendance for manager view
--     leave_requests_v2_enriched — leave requests joined with staff name
--
-- Strategy:   Idempotent — IF NOT EXISTS / OR REPLACE throughout
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- 1. staff_attendance_v3
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.staff_attendance_v3 (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id text NOT NULL,
  work_date date NOT NULL,
  clock_in_time timestamptz,
  clock_out_time timestamptz,
  -- Geolocation
  clock_in_latitude numeric,
  clock_in_longitude numeric,
  clock_out_latitude numeric,
  clock_out_longitude numeric,
  clock_in_geofence_id text,
  -- Device info
  clock_in_device_id text,
  clock_out_device_id text,
  clock_in_photo_path text,
  -- Computed / status
  status text NOT NULL DEFAULT 'present'
    CHECK (status IN ('present', 'absent', 'half_day', 'holiday', 'weekend', 'leave')),
  is_late boolean DEFAULT false,
  notes text,
  work_minutes numeric DEFAULT 0,
  overtime_minutes numeric DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (staff_id, work_date)
);

CREATE INDEX IF NOT EXISTS idx_attendance_v3_staff_date
  ON public.staff_attendance_v3 (staff_id, work_date DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_v3_date
  ON public.staff_attendance_v3 (work_date DESC);

-- ═══════════════════════════════════════════════════════════════════════
-- 2. leave_types
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  code text NOT NULL UNIQUE,
  days_allowed int NOT NULL DEFAULT 0,
  annual_entitlement_days int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  applicable_gender text,             -- NULL = all, 'male', 'female'
  min_advance_notice_days int,
  max_consecutive_days int,
  requires_document boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Seed standard leave types (idempotent: skip if code already exists)
INSERT INTO public.leave_types (name, code, days_allowed, annual_entitlement_days)
VALUES
  ('Annual Leave',     'annual',     28, 28),
  ('Sick Leave',       'sick',       21, 21),
  ('Maternity Leave',  'maternity',  84, 84),
  ('Paternity Leave',  'paternity',  3,  3),
  ('Compassionate',    'compassionate', 4, 4),
  ('Unpaid Leave',     'unpaid',     30, 30),
  ('Study Leave',      'study',      10, 10)
ON CONFLICT (code) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- 3. leave_requests_v2
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_requests_v2 (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id text NOT NULL,
  leave_type text NOT NULL,           -- references leave_types.code
  start_date date NOT NULL,
  end_date date NOT NULL,
  reason text,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
  approved_by text,
  approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leave_v2_staff
  ON public.leave_requests_v2 (staff_id, start_date DESC);
CREATE INDEX IF NOT EXISTS idx_leave_v2_status
  ON public.leave_requests_v2 (status, start_date DESC);

-- ═══════════════════════════════════════════════════════════════════════
-- 4. leave_balances
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_balances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  leave_type_id uuid NOT NULL REFERENCES public.leave_types(id) ON DELETE CASCADE,
  year int NOT NULL CHECK (year BETWEEN 2020 AND 2099),
  annual_entitlement int NOT NULL DEFAULT 0,
  used_days int NOT NULL DEFAULT 0,
  remaining_days int GENERATED ALWAYS AS (annual_entitlement - used_days) STORED,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, leave_type_id, year)
);

CREATE INDEX IF NOT EXISTS idx_leave_balances_user_year
  ON public.leave_balances (user_id, year);

-- ═══════════════════════════════════════════════════════════════════════
-- 5. attendance_settings
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.attendance_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  work_start_time time NOT NULL DEFAULT '08:00',
  work_end_time time NOT NULL DEFAULT '17:00',
  grace_period_minutes int NOT NULL DEFAULT 15,
  is_geofencing_enabled boolean NOT NULL DEFAULT false,
  office_latitude numeric,
  office_longitude numeric,
  geofence_radius_meters int DEFAULT 200,
  timezone text NOT NULL DEFAULT 'Africa/Dar_es_Salaam',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Seed default settings (one row)
INSERT INTO public.attendance_settings (work_start_time, work_end_time, grace_period_minutes)
SELECT '08:00', '17:00', 15
WHERE NOT EXISTS (SELECT 1 FROM public.attendance_settings LIMIT 1);

-- ═══════════════════════════════════════════════════════════════════════
-- 6. notifications  (Flutter uses "notifications", not "hr_notifications")
--    hr_notifications exists from migration 009 with different columns.
--    Create a separate "notifications" table matching the Dart code.
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,              -- auth.uid()::text
  title text NOT NULL,
  body text,
  event_type text,
  metadata jsonb DEFAULT '{}',
  is_read boolean NOT NULL DEFAULT false,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_read
  ON public.notifications (user_id, is_read, created_at DESC);

-- ═══════════════════════════════════════════════════════════════════════
-- 7. staff_loans  (Dart uses "staff_loans"; migration 007 created
--    "staff_salary_loans" with different column names)
--    Create a VIEW that maps the expected column names.
-- ═══════════════════════════════════════════════════════════════════════

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'staff_loans' AND table_schema = 'public'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.views
    WHERE table_name = 'staff_loans' AND table_schema = 'public'
  ) THEN
    -- Create a view that aliases staff_salary_loans columns to match Dart expectations
    CREATE VIEW public.staff_loans AS
    SELECT
      id,
      employee_id,
      loan_type,
      principal_amount,
      outstanding_balance AS remaining_balance,
      monthly_deduction AS monthly_installment,
      interest_rate,
      start_date,
      expected_end_date,
      status,
      approved_by,
      approved_at,
      notes,
      created_at,
      updated_at
    FROM public.staff_salary_loans;
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- 8. VIEW: attendance_v2_today — today's attendance for manager dashboard
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.attendance_v2_today AS
SELECT
  a.id,
  a.staff_id,
  COALESCE(e.full_name, s.full_name, a.staff_id) AS full_name,
  a.clock_in_time,
  a.clock_out_time,
  a.is_late,
  a.status,
  a.work_minutes,
  a.overtime_minutes,
  a.work_date
FROM public.staff_attendance_v3 a
LEFT JOIN public.employees e ON e.user_id::text = a.staff_id
LEFT JOIN public.staff s ON s.user_id::text = a.staff_id
WHERE a.work_date = current_date;

-- ═══════════════════════════════════════════════════════════════════════
-- 9. VIEW: leave_requests_v2_enriched — leave requests with staff name
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW public.leave_requests_v2_enriched AS
SELECT
  lr.*,
  COALESCE(e.full_name, s.full_name, lr.staff_id) AS full_name,
  CASE
    WHEN lr.status = 'approved'
      AND current_date BETWEEN lr.start_date AND lr.end_date
    THEN true
    ELSE false
  END AS is_active_now
FROM public.leave_requests_v2 lr
LEFT JOIN public.employees e ON e.user_id::text = lr.staff_id
LEFT JOIN public.staff s ON s.user_id::text = lr.staff_id;

-- ═══════════════════════════════════════════════════════════════════════
-- 10. RLS POLICIES — new tables
-- ═══════════════════════════════════════════════════════════════════════

-- 10a. staff_attendance_v3
ALTER TABLE public.staff_attendance_v3 ENABLE ROW LEVEL SECURITY;

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

DROP POLICY IF EXISTS attendance_v3_insert ON public.staff_attendance_v3;
CREATE POLICY attendance_v3_insert ON public.staff_attendance_v3
  FOR INSERT WITH CHECK (
    staff_id = auth.uid()::text
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS attendance_v3_update ON public.staff_attendance_v3;
CREATE POLICY attendance_v3_update ON public.staff_attendance_v3
  FOR UPDATE USING (
    staff_id = auth.uid()::text
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS attendance_v3_delete ON public.staff_attendance_v3;
CREATE POLICY attendance_v3_delete ON public.staff_attendance_v3
  FOR DELETE USING (auth.role() = 'service_role');

-- 10b. leave_types
ALTER TABLE public.leave_types ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS leave_types_read ON public.leave_types;
CREATE POLICY leave_types_read ON public.leave_types
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS leave_types_admin ON public.leave_types;
CREATE POLICY leave_types_admin ON public.leave_types
  FOR ALL USING (auth.role() = 'service_role');

-- 10c. leave_requests_v2
ALTER TABLE public.leave_requests_v2 ENABLE ROW LEVEL SECURITY;

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

DROP POLICY IF EXISTS leave_v2_insert ON public.leave_requests_v2;
CREATE POLICY leave_v2_insert ON public.leave_requests_v2
  FOR INSERT WITH CHECK (
    staff_id = auth.uid()::text
    OR auth.role() = 'service_role'
  );

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

DROP POLICY IF EXISTS leave_v2_delete ON public.leave_requests_v2;
CREATE POLICY leave_v2_delete ON public.leave_requests_v2
  FOR DELETE USING (auth.role() = 'service_role');

-- 10d. leave_balances
ALTER TABLE public.leave_balances ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS leave_balances_own ON public.leave_balances;
CREATE POLICY leave_balances_own ON public.leave_balances
  FOR SELECT USING (
    user_id = auth.uid()
    OR auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager')
    )
  );

DROP POLICY IF EXISTS leave_balances_admin ON public.leave_balances;
CREATE POLICY leave_balances_admin ON public.leave_balances
  FOR ALL USING (auth.role() = 'service_role');

-- 10e. attendance_settings
ALTER TABLE public.attendance_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS attendance_settings_read ON public.attendance_settings;
CREATE POLICY attendance_settings_read ON public.attendance_settings
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS attendance_settings_admin ON public.attendance_settings;
CREATE POLICY attendance_settings_admin ON public.attendance_settings
  FOR ALL USING (auth.role() = 'service_role');

-- 10f. notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notifications_own ON public.notifications;
CREATE POLICY notifications_own ON public.notifications
  FOR SELECT USING (
    user_id = auth.uid()::text
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS notifications_update ON public.notifications;
CREATE POLICY notifications_update ON public.notifications
  FOR UPDATE USING (
    user_id = auth.uid()::text
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS notifications_insert ON public.notifications;
CREATE POLICY notifications_insert ON public.notifications
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

DROP POLICY IF EXISTS notifications_delete ON public.notifications;
CREATE POLICY notifications_delete ON public.notifications
  FOR DELETE USING (auth.role() = 'service_role');

-- ═══════════════════════════════════════════════════════════════════════
-- 11. GRANTS
-- ═══════════════════════════════════════════════════════════════════════

GRANT SELECT, INSERT, UPDATE ON public.staff_attendance_v3 TO authenticated;
GRANT ALL ON public.staff_attendance_v3 TO service_role;

GRANT SELECT ON public.leave_types TO authenticated;
GRANT ALL ON public.leave_types TO service_role;

GRANT SELECT, INSERT, UPDATE ON public.leave_requests_v2 TO authenticated;
GRANT ALL ON public.leave_requests_v2 TO service_role;

GRANT SELECT ON public.leave_balances TO authenticated;
GRANT ALL ON public.leave_balances TO service_role;

GRANT SELECT ON public.attendance_settings TO authenticated;
GRANT ALL ON public.attendance_settings TO service_role;

GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

GRANT SELECT ON public.attendance_v2_today TO authenticated;
GRANT ALL ON public.attendance_v2_today TO service_role;

GRANT SELECT ON public.leave_requests_v2_enriched TO authenticated;
GRANT ALL ON public.leave_requests_v2_enriched TO service_role;

-- staff_loans is a view on staff_salary_loans — grant SELECT
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.views
             WHERE table_name = 'staff_loans' AND table_schema = 'public') THEN
    GRANT SELECT ON public.staff_loans TO authenticated;
    GRANT ALL ON public.staff_loans TO service_role;
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- 12. TRIGGER: Auto-notify on leave_requests_v2 status change
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.trg_leave_v2_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'pending' THEN
    INSERT INTO public.notifications (user_id, title, body, event_type, metadata)
    SELECT e.user_id::text,
           'New Leave Request',
           format('A leave request (%s to %s) needs your review', NEW.start_date, NEW.end_date),
           'leave_submitted',
           jsonb_build_object('request_id', NEW.id, 'staff_id', NEW.staff_id)
    FROM public.employees e
    WHERE e.role IN ('hr_manager', 'manager', 'admin')
      AND (e.status = 'active' OR e.employment_status = 'active');
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    INSERT INTO public.notifications (user_id, title, body, event_type, metadata)
    VALUES (
      NEW.staff_id,
      format('Leave %s', initcap(NEW.status)),
      format('Your leave from %s to %s has been %s', NEW.start_date, NEW.end_date, NEW.status),
      'leave_' || NEW.status,
      jsonb_build_object('request_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_leave_v2_notify ON public.leave_requests_v2;
CREATE TRIGGER trg_leave_v2_notify
  AFTER INSERT OR UPDATE ON public.leave_requests_v2
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_leave_v2_notify();

-- ═══════════════════════════════════════════════════════════════════════
-- VERIFICATION
-- ═══════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_tables text[];
  v_views text[];
  v_t text;
BEGIN
  v_tables := ARRAY[
    'staff_attendance_v3', 'leave_types', 'leave_requests_v2',
    'leave_balances', 'attendance_settings', 'notifications'
  ];
  v_views := ARRAY['attendance_v2_today', 'leave_requests_v2_enriched'];

  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRATION 012 VERIFICATION';

  FOREACH v_t IN ARRAY v_tables LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = v_t AND table_schema = 'public') THEN
      RAISE NOTICE '  TABLE %: OK', v_t;
    ELSE
      RAISE NOTICE '  TABLE %: MISSING!', v_t;
    END IF;
  END LOOP;

  FOREACH v_t IN ARRAY v_views LOOP
    IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = v_t AND table_schema = 'public') THEN
      RAISE NOTICE '  VIEW  %: OK', v_t;
    ELSE
      RAISE NOTICE '  VIEW  %: MISSING!', v_t;
    END IF;
  END LOOP;

  IF EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'staff_loans' AND table_schema = 'public')
     OR EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'staff_loans' AND table_schema = 'public') THEN
    RAISE NOTICE '  staff_loans alias: OK';
  ELSE
    RAISE NOTICE '  staff_loans alias: MISSING!';
  END IF;

  RAISE NOTICE '========================================';
END $$;
