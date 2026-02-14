-- ============================================================================
-- MIGRATION 010: Staff Performance Monthly + HR Dashboard KPIs
-- Date:       2026-02-14
-- Purpose:    1. Create staff_performance_monthly table (referenced by 009 trigger)
--             2. Add HR dashboard KPI function (rpc_hr_dashboard_kpis)
--             3. Add loan-officer-to-employee field mappings
-- Strategy:   Idempotent — IF NOT EXISTS
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: Staff Performance Monthly — Loan Officer KPI Snapshots
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.staff_performance_monthly (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  month int NOT NULL CHECK (month BETWEEN 1 AND 12),
  year int NOT NULL CHECK (year BETWEEN 2020 AND 2099),

  -- Loan portfolio metrics (auto-calculated by trigger)
  total_loans_managed int DEFAULT 0,
  total_disbursed numeric DEFAULT 0,
  total_collected numeric DEFAULT 0,
  active_loans int DEFAULT 0,
  overdue_loans int DEFAULT 0,

  -- Attendance metrics (populated by scheduled task)
  attendance_score int CHECK (attendance_score BETWEEN 0 AND 100),
  days_worked int DEFAULT 0,
  days_late int DEFAULT 0,
  days_absent int DEFAULT 0,

  -- Collection performance
  collection_score int CHECK (collection_score BETWEEN 0 AND 100),
  total_collections numeric DEFAULT 0,
  collection_target numeric DEFAULT 0,
  collection_rate_percent numeric GENERATED ALWAYS AS (
    CASE WHEN collection_target > 0
      THEN round((total_collections / collection_target) * 100, 2)
      ELSE 0
    END
  ) STORED,

  -- Customer & compliance
  customer_satisfaction_score int CHECK (customer_satisfaction_score BETWEEN 0 AND 100),
  compliance_score int CHECK (compliance_score BETWEEN 0 AND 100),

  -- Overall
  overall_score int CHECK (overall_score BETWEEN 0 AND 100),
  grade text CHECK (grade IN ('A', 'B', 'C', 'D', 'F')),

  -- Manager actions
  recommendation text,
  recommendation_reason text,
  recommendation_acted boolean DEFAULT false,
  acted_by text,
  action_taken text,
  action_date timestamptz,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  UNIQUE (staff_id, month, year)
);

CREATE INDEX IF NOT EXISTS idx_staff_perf_monthly_date
  ON public.staff_performance_monthly (year DESC, month DESC);
CREATE INDEX IF NOT EXISTS idx_staff_perf_monthly_staff
  ON public.staff_performance_monthly (staff_id, year DESC, month DESC);
CREATE INDEX IF NOT EXISTS idx_staff_perf_monthly_grade
  ON public.staff_performance_monthly (grade, year, month);

-- RLS
ALTER TABLE public.staff_performance_monthly ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS perf_monthly_own ON public.staff_performance_monthly;
CREATE POLICY perf_monthly_own ON public.staff_performance_monthly
  FOR SELECT USING (
    staff_id IN (
      SELECT id FROM public.employees WHERE user_id = auth.uid()
    )
    OR auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'manager')
    )
  );

DROP POLICY IF EXISTS perf_monthly_admin ON public.staff_performance_monthly;
CREATE POLICY perf_monthly_admin ON public.staff_performance_monthly
  FOR ALL USING (auth.role() = 'service_role');

GRANT SELECT ON public.staff_performance_monthly TO authenticated;
GRANT ALL ON public.staff_performance_monthly TO service_role;

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: HR Dashboard KPI Function
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.rpc_hr_dashboard_kpis()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
  v_headcount int;
  v_active int;
  v_new_hires int;
  v_departures int;
  v_avg_tenure numeric;
  v_dept_count int;
  v_monthly_payroll numeric;
  v_avg_salary numeric;
  v_pending_leaves int;
  v_on_leave_today int;
  v_attendance_rate numeric;
  v_avg_performance numeric;
  v_pending_reviews int;
  v_expiring_contracts int;
  v_loan_balance numeric;
BEGIN
  -- Headcount
  SELECT count(*) INTO v_headcount
  FROM public.employees;

  SELECT count(*) INTO v_active
  FROM public.employees
  WHERE status = 'active' OR employment_status = 'active';

  -- New hires this month
  SELECT count(*) INTO v_new_hires
  FROM public.employees
  WHERE hire_date >= date_trunc('month', current_date);

  -- Departures this month
  SELECT count(*) INTO v_departures
  FROM public.employees
  WHERE (status = 'terminated' OR employment_status = 'terminated')
    AND updated_at >= date_trunc('month', current_date);

  -- Avg tenure (in months)
  SELECT coalesce(round(avg(
    extract(epoch FROM (current_date - hire_date)) / 86400 / 30.44
  ), 1), 0) INTO v_avg_tenure
  FROM public.employees
  WHERE hire_date IS NOT NULL
    AND (status = 'active' OR employment_status = 'active');

  -- Department count
  SELECT count(DISTINCT dept) INTO v_dept_count
  FROM public.employees WHERE dept IS NOT NULL;

  -- Latest payroll cost
  SELECT coalesce(total_net_salary, 0) INTO v_monthly_payroll
  FROM public.payroll_runs
  WHERE status IN ('approved', 'paid')
  ORDER BY run_period_year DESC, run_period_month DESC
  LIMIT 1;

  -- Average salary
  SELECT coalesce(round(avg(gross_salary), 0), 0) INTO v_avg_salary
  FROM public.salary_structures
  WHERE is_current = true;

  -- Pending leave requests
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leave_requests') THEN
    EXECUTE 'SELECT count(*) FROM public.leave_requests WHERE status = $1' INTO v_pending_leaves USING 'pending';

    EXECUTE 'SELECT count(*) FROM public.leave_requests WHERE status = $1 AND start_date <= $2 AND end_date >= $2'
      INTO v_on_leave_today USING 'approved', current_date;
  ELSE
    v_pending_leaves := 0;
    v_on_leave_today := 0;
  END IF;

  -- Attendance rate (this month)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'attendance_records') THEN
    EXECUTE '
      SELECT coalesce(round(
        (count(*) FILTER (WHERE clock_in IS NOT NULL))::numeric /
        NULLIF(count(*), 0) * 100
      , 1), 0)
      FROM public.attendance_records
      WHERE work_date >= date_trunc($1, current_date)'
    INTO v_attendance_rate USING 'month';
  ELSE
    v_attendance_rate := 0;
  END IF;

  -- Performance
  SELECT coalesce(round(avg(overall_score), 1), 0) INTO v_avg_performance
  FROM public.performance_reviews
  WHERE status = 'completed' AND overall_score IS NOT NULL;

  SELECT count(*) INTO v_pending_reviews
  FROM public.performance_reviews
  WHERE status IN ('pending', 'self_review', 'manager_review');

  -- Contract expiry
  SELECT count(*) INTO v_expiring_contracts
  FROM public.employees
  WHERE contract_end_date BETWEEN current_date AND (current_date + interval '30 days')
    AND (status = 'active' OR employment_status = 'active');

  -- Staff loan balance
  SELECT coalesce(sum(outstanding_balance), 0) INTO v_loan_balance
  FROM public.staff_salary_loans
  WHERE status = 'active';

  v_result := jsonb_build_object(
    'headcount', jsonb_build_object(
      'total', v_headcount,
      'active', v_active,
      'new_hires_this_month', v_new_hires,
      'departures_this_month', v_departures,
      'avg_tenure_months', v_avg_tenure,
      'departments', v_dept_count
    ),
    'payroll', jsonb_build_object(
      'monthly_cost', v_monthly_payroll,
      'avg_salary', v_avg_salary,
      'staff_loan_balance', v_loan_balance
    ),
    'leave', jsonb_build_object(
      'pending_requests', v_pending_leaves,
      'on_leave_today', v_on_leave_today
    ),
    'attendance', jsonb_build_object(
      'rate_this_month', v_attendance_rate
    ),
    'performance', jsonb_build_object(
      'avg_score', v_avg_performance,
      'pending_reviews', v_pending_reviews
    ),
    'alerts', jsonb_build_object(
      'expiring_contracts', v_expiring_contracts
    ),
    'generated_at', now()
  );

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.rpc_hr_dashboard_kpis TO authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_hr_dashboard_kpis TO service_role;

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: Monthly Performance Snapshot Scheduler
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.fn_generate_monthly_performance_snapshots(
  p_month int DEFAULT NULL,
  p_year int DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_month int := coalesce(p_month, extract(month FROM current_date)::int);
  v_year int := coalesce(p_year, extract(year FROM current_date)::int);
  v_start_date date;
  v_end_date date;
  v_emp record;
  v_count int := 0;
  v_days_worked int;
  v_days_late int;
  v_days_absent int;
  v_att_score int;
BEGIN
  v_start_date := make_date(v_year, v_month, 1);
  v_end_date := (v_start_date + interval '1 month' - interval '1 day')::date;

  FOR v_emp IN
    SELECT e.id, e.full_name
    FROM public.employees e
    WHERE e.status = 'active' OR e.employment_status = 'active'
  LOOP
    -- Attendance metrics
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'attendance_records') THEN
      SELECT
        count(*) FILTER (WHERE clock_in IS NOT NULL),
        count(*) FILTER (WHERE is_late = true),
        count(*) FILTER (WHERE clock_in IS NULL)
      INTO v_days_worked, v_days_late, v_days_absent
      FROM public.attendance_records
      WHERE staff_id = v_emp.id
        AND work_date BETWEEN v_start_date AND v_end_date;
    ELSE
      v_days_worked := 0; v_days_late := 0; v_days_absent := 0;
    END IF;

    -- Simple attendance score: (worked - late) / max(worked + absent, 1) * 100
    v_att_score := CASE
      WHEN (v_days_worked + v_days_absent) > 0
      THEN round(((v_days_worked - v_days_late)::numeric / (v_days_worked + v_days_absent)) * 100)
      ELSE 0
    END;

    INSERT INTO public.staff_performance_monthly (
      staff_id, month, year,
      days_worked, days_late, days_absent, attendance_score
    ) VALUES (
      v_emp.id, v_month, v_year,
      v_days_worked, v_days_late, v_days_absent, v_att_score
    )
    ON CONFLICT (staff_id, month, year) DO UPDATE SET
      days_worked = EXCLUDED.days_worked,
      days_late = EXCLUDED.days_late,
      days_absent = EXCLUDED.days_absent,
      attendance_score = EXCLUDED.attendance_score,
      updated_at = now();

    v_count := v_count + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'snapshots_generated', v_count,
    'period', format('%s-%s', v_year, lpad(v_month::text, 2, '0'))
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.fn_generate_monthly_performance_snapshots TO service_role;

-- ═══════════════════════════════════════════════════════════════════════
-- VERIFICATION
-- ═══════════════════════════════════════════════════════════════════════
DO $$
DECLARE
  v_perf_tbl boolean;
  v_kpi_fn boolean;
  v_snapshot_fn boolean;
BEGIN
  v_perf_tbl := EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'staff_performance_monthly');
  v_kpi_fn := EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'rpc_hr_dashboard_kpis');
  v_snapshot_fn := EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'fn_generate_monthly_performance_snapshots');

  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRATION 010 COMPLETE';
  RAISE NOTICE 'staff_performance_monthly: %', v_perf_tbl;
  RAISE NOTICE 'rpc_hr_dashboard_kpis: %', v_kpi_fn;
  RAISE NOTICE 'fn_generate_monthly_performance_snapshots: %', v_snapshot_fn;
  RAISE NOTICE '========================================';
END $$;
