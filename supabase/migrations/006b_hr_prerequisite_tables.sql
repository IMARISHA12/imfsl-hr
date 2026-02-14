-- ============================================================================
-- MIGRATION 006b: HR Prerequisite Tables
-- Date:       2026-02-14
-- Purpose:    Create core HR tables that migration 007 depends on:
--             - leave_types (leave categories with annual entitlements)
--             - leave_requests (employee leave applications)
--             - leave_balances (per-employee per-year leave tracking)
--             - attendance_records (daily clock-in/out)
-- Strategy:   CREATE IF NOT EXISTS (safe re-run), seed leave_types
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- 1. LEAVE TYPES — master list of leave categories
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  leave_type text NOT NULL,              -- display name (used by Flutter joins)
  name text NOT NULL,                    -- canonical name
  days_allowed int NOT NULL DEFAULT 0,
  requires_attachment boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Seed standard Tanzania leave types (idempotent via ON CONFLICT)
INSERT INTO public.leave_types (code, leave_type, name, days_allowed, requires_attachment) VALUES
  ('ANNUAL',     'Likizo ya Mwaka',           'Annual Leave',       28, false),
  ('SICK',       'Likizo ya Ugonjwa',         'Sick Leave',         63, true),
  ('MATERNITY',  'Likizo ya Uzazi (Mama)',     'Maternity Leave',    84, true),
  ('PATERNITY',  'Likizo ya Uzazi (Baba)',     'Paternity Leave',     3, true),
  ('COMPASSION', 'Likizo ya Msiba',           'Compassionate Leave',  4, false),
  ('STUDY',      'Likizo ya Masomo',           'Study Leave',        14, true),
  ('UNPAID',     'Likizo Bila Malipo',         'Unpaid Leave',        0, false)
ON CONFLICT (code) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- 2. LEAVE REQUESTS — employee leave applications
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,                 -- auth.uid() of the employee
  leave_type_id uuid NOT NULL REFERENCES public.leave_types(id),
  start_date date NOT NULL,
  end_date date NOT NULL,
  days_count int NOT NULL DEFAULT 1,
  reason text,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','approved','rejected','cancelled')),
  manager_comment text,
  processed_by text,                     -- email of approver/rejector
  processed_at timestamptz,
  attachment_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leave_requests_user
  ON public.leave_requests (user_id, status);

CREATE INDEX IF NOT EXISTS idx_leave_requests_dates
  ON public.leave_requests (start_date, end_date);

-- ═══════════════════════════════════════════════════════════════════════
-- 3. LEAVE BALANCES — per-employee per-year tracking
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.leave_balances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL,                 -- auth.uid() of the employee
  leave_type_id uuid NOT NULL REFERENCES public.leave_types(id),
  year int NOT NULL DEFAULT EXTRACT(YEAR FROM current_date)::int,
  annual_entitlement int NOT NULL DEFAULT 0,
  used_days int NOT NULL DEFAULT 0,
  remaining_days int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, leave_type_id, year)
);

-- ═══════════════════════════════════════════════════════════════════════
-- 4. ATTENDANCE RECORDS — daily clock-in/out
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.attendance_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id text NOT NULL,                -- references staff(id) or employee user_id
  work_date date NOT NULL DEFAULT current_date,
  clock_in timestamptz NOT NULL DEFAULT now(),
  clock_out timestamptz,
  hours_worked numeric,                  -- auto-calculated on clock-out
  is_late boolean DEFAULT false,
  late_minutes int DEFAULT 0,
  daily_report text,
  manager_rating int CHECK (manager_rating BETWEEN 1 AND 5),
  manager_notes text,
  rated_by text,
  rated_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (staff_id, work_date)
);

CREATE INDEX IF NOT EXISTS idx_attendance_records_date
  ON public.attendance_records (work_date, staff_id);

-- ═══════════════════════════════════════════════════════════════════════
-- 5. Enable RLS on new tables
-- ═══════════════════════════════════════════════════════════════════════

ALTER TABLE public.leave_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

-- Service role bypass (edge functions use service role)
CREATE POLICY "service_role_full_access" ON public.leave_types
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "service_role_full_access" ON public.leave_requests
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "service_role_full_access" ON public.leave_balances
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "service_role_full_access" ON public.attendance_records
  FOR ALL USING (auth.role() = 'service_role');

-- Authenticated users can read leave types
CREATE POLICY "authenticated_read_leave_types" ON public.leave_types
  FOR SELECT USING (auth.role() = 'authenticated');

-- Users can read their own records
CREATE POLICY "users_read_own_leave_requests" ON public.leave_requests
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "users_read_own_leave_balances" ON public.leave_balances
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "users_read_own_attendance" ON public.attendance_records
  FOR SELECT USING (staff_id = auth.uid()::text);
