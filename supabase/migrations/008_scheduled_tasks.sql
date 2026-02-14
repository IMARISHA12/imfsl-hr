-- ============================================================================
-- MIGRATION 008: Scheduled Tasks & Automated Business Logic
-- Date:       2026-02-14
-- Purpose:    Cron-compatible functions for automated HR & loan operations:
--             - Daily loan arrears calculation
--             - Monthly leave accrual
--             - Monthly payroll reminder
--             - Daily attendance auto-close
--             - Quarterly performance review trigger
-- Strategy:   These functions are designed to be called by pg_cron or an
--             external scheduler. Each is idempotent and safe to re-run.
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: DAILY LOAN ARREARS UPDATE
-- ═══════════════════════════════════════════════════════════════════════

-- Recalculates days_overdue, in_arrears, is_npa for all active loans
CREATE OR REPLACE FUNCTION public.fn_daily_arrears_update()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_updated int := 0;
  v_npa_threshold int := 90; -- days before classified as NPA
BEGIN
  -- Update days overdue based on loan schedule
  WITH overdue_calc AS (
    SELECT
      l.id AS loan_id,
      CASE
        WHEN ls_overdue.earliest_overdue_date IS NOT NULL
          THEN (current_date - ls_overdue.earliest_overdue_date)::int
        WHEN l.expected_maturity_date IS NOT NULL AND current_date > l.expected_maturity_date
          THEN (current_date - l.expected_maturity_date)::int
        ELSE 0
      END AS calc_days_overdue,
      CASE
        WHEN ls_overdue.overdue_amount IS NOT NULL AND ls_overdue.overdue_amount > 0
          THEN ls_overdue.overdue_amount
        ELSE 0
      END AS calc_arrears
    FROM public.loans l
    LEFT JOIN LATERAL (
      SELECT
        min(ls.due_date) AS earliest_overdue_date,
        sum(ls.total_due - ls.total_paid) AS overdue_amount
      FROM public.loan_schedule ls
      WHERE ls.loan_id = l.id
        AND ls.due_date < current_date
        AND ls.is_completed = false
        AND ls.total_paid < ls.total_due
    ) ls_overdue ON true
    WHERE l.status IN ('active', 'defaulted')
  )
  UPDATE public.loans l SET
    days_overdue = oc.calc_days_overdue,
    arrears_amount = oc.calc_arrears,
    in_arrears = (oc.calc_days_overdue > 0),
    is_npa = (oc.calc_days_overdue >= v_npa_threshold),
    updated_at = now()
  FROM overdue_calc oc
  WHERE l.id = oc.loan_id
    AND (l.days_overdue IS DISTINCT FROM oc.calc_days_overdue
      OR l.arrears_amount IS DISTINCT FROM oc.calc_arrears);

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'task', 'daily_arrears_update',
    'loans_updated', v_updated,
    'run_at', now()
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: MONTHLY LEAVE ACCRUAL
-- ═══════════════════════════════════════════════════════════════════════

-- Pro-rata accrual: adds monthly fraction of annual entitlement
CREATE OR REPLACE FUNCTION public.fn_monthly_leave_accrual()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_year int := extract(year FROM current_date)::int;
  v_month int := extract(month FROM current_date)::int;
  v_updated int := 0;
  v_balance record;
BEGIN
  -- For each active leave balance, recalculate remaining based on entitlement and used
  FOR v_balance IN
    SELECT lb.id, lb.annual_entitlement, lb.used_days
    FROM public.leave_balances lb
    JOIN public.staff s ON s.user_id = lb.user_id AND s.active = true
    WHERE lb.year = v_year
  LOOP
    -- Pro-rata: entitlement up to current month
    DECLARE
      v_prorata_entitlement numeric;
    BEGIN
      v_prorata_entitlement := round((v_balance.annual_entitlement::numeric / 12.0) * v_month, 1);

      UPDATE public.leave_balances SET
        remaining_days = greatest(0, v_prorata_entitlement - coalesce(v_balance.used_days, 0))
      WHERE id = v_balance.id
        AND remaining_days IS DISTINCT FROM greatest(0, v_prorata_entitlement - coalesce(v_balance.used_days, 0));

      IF FOUND THEN v_updated := v_updated + 1; END IF;
    END;
  END LOOP;

  RETURN jsonb_build_object(
    'success', true,
    'task', 'monthly_leave_accrual',
    'balances_updated', v_updated,
    'year', v_year,
    'month', v_month,
    'run_at', now()
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: DAILY ATTENDANCE AUTO-CLOSE
-- ═══════════════════════════════════════════════════════════════════════

-- Auto-closes attendance records where staff forgot to clock out
CREATE OR REPLACE FUNCTION public.fn_daily_attendance_autoclose()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_closed int := 0;
  v_work_end time := '18:00:00'::time;
BEGIN
  -- Close records from yesterday (or older) that have clock_in but no clock_out
  UPDATE public.attendance_records SET
    clock_out = work_date::timestamptz + v_work_end,
    hours_worked = extract(epoch FROM (work_date::timestamptz + v_work_end - clock_in)) / 3600.0,
    updated_at = now()
  WHERE clock_in IS NOT NULL
    AND clock_out IS NULL
    AND work_date < current_date;

  GET DIAGNOSTICS v_closed = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'task', 'attendance_autoclose',
    'records_closed', v_closed,
    'run_at', now()
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: CONTRACT EXPIRY ALERTS
-- ═══════════════════════════════════════════════════════════════════════

-- Returns employees with contracts expiring within N days
CREATE OR REPLACE FUNCTION public.fn_contract_expiry_check(p_days_ahead int DEFAULT 30)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_agg(jsonb_build_object(
    'employee_id', e.id,
    'employee_name', e.full_name,
    'employee_code', e.employee_code,
    'department', e.dept,
    'contract_end_date', e.contract_end_date,
    'days_remaining', (e.contract_end_date - current_date),
    'manager_email', e.manager_email
  ) ORDER BY e.contract_end_date) INTO v_result
  FROM public.employees e
  WHERE e.contract_end_date IS NOT NULL
    AND e.contract_end_date BETWEEN current_date AND current_date + (p_days_ahead || ' days')::interval
    AND (e.status = 'active' OR e.employment_status = 'active');

  RETURN jsonb_build_object(
    'success', true,
    'task', 'contract_expiry_check',
    'days_ahead', p_days_ahead,
    'expiring_contracts', coalesce(v_result, '[]'::jsonb),
    'count', coalesce(jsonb_array_length(v_result), 0),
    'run_at', now()
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: DAILY LOAN MATURITY CHECK
-- ═══════════════════════════════════════════════════════════════════════

-- Identifies loans reaching maturity in the next N days
CREATE OR REPLACE FUNCTION public.fn_loan_maturity_check(p_days_ahead int DEFAULT 7)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_agg(jsonb_build_object(
    'loan_id', l.id,
    'loan_number', l.loan_number,
    'borrower_name', b.full_name,
    'borrower_phone', b.phone_number,
    'principal', l.amount_principal,
    'outstanding', l.outstanding_balance,
    'maturity_date', coalesce(l.expected_maturity_date, l.maturity_date),
    'days_until_maturity', (coalesce(l.expected_maturity_date, l.maturity_date) - current_date),
    'officer_name', l.loan_officer_name
  ) ORDER BY coalesce(l.expected_maturity_date, l.maturity_date)) INTO v_result
  FROM public.loans l
  JOIN public.borrowers b ON b.id = l.borrower_id
  WHERE l.status = 'active'
    AND coalesce(l.expected_maturity_date, l.maturity_date) IS NOT NULL
    AND coalesce(l.expected_maturity_date, l.maturity_date) BETWEEN current_date AND current_date + (p_days_ahead || ' days')::interval;

  RETURN jsonb_build_object(
    'success', true,
    'task', 'loan_maturity_check',
    'days_ahead', p_days_ahead,
    'maturing_loans', coalesce(v_result, '[]'::jsonb),
    'count', coalesce(jsonb_array_length(v_result), 0),
    'run_at', now()
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART F: SCHEDULED TASK AUDIT LOG
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.scheduled_task_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_name text NOT NULL,
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  status text NOT NULL DEFAULT 'running', -- running, completed, failed
  result jsonb,
  error_message text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_scheduled_tasks_name_date
  ON public.scheduled_task_runs (task_name, started_at DESC);

-- Wrapper that logs task execution
CREATE OR REPLACE FUNCTION public.fn_run_scheduled_task(p_task_name text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_run_id uuid;
  v_result jsonb;
BEGIN
  INSERT INTO public.scheduled_task_runs (task_name, status)
  VALUES (p_task_name, 'running')
  RETURNING id INTO v_run_id;

  BEGIN
    CASE p_task_name
      WHEN 'daily_arrears_update' THEN
        v_result := public.fn_daily_arrears_update();
      WHEN 'monthly_leave_accrual' THEN
        v_result := public.fn_monthly_leave_accrual();
      WHEN 'attendance_autoclose' THEN
        v_result := public.fn_daily_attendance_autoclose();
      WHEN 'contract_expiry_check' THEN
        v_result := public.fn_contract_expiry_check(30);
      WHEN 'loan_maturity_check' THEN
        v_result := public.fn_loan_maturity_check(7);
      ELSE
        RAISE EXCEPTION 'Unknown task: %', p_task_name;
    END CASE;

    UPDATE public.scheduled_task_runs SET
      status = 'completed',
      completed_at = now(),
      result = v_result
    WHERE id = v_run_id;

  EXCEPTION WHEN OTHERS THEN
    UPDATE public.scheduled_task_runs SET
      status = 'failed',
      completed_at = now(),
      error_message = SQLERRM
    WHERE id = v_run_id;

    v_result := jsonb_build_object('success', false, 'error', SQLERRM);
  END;

  RETURN v_result;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART G: pg_cron SCHEDULE SETUP (execute manually if pg_cron is enabled)
-- ═══════════════════════════════════════════════════════════════════════

-- NOTE: Uncomment these if pg_cron extension is available on your Supabase plan:
--
-- -- Daily arrears update at 6 AM EAT (3 AM UTC)
-- SELECT cron.schedule('daily-arrears', '0 3 * * *',
--   $$SELECT public.fn_run_scheduled_task('daily_arrears_update')$$);
--
-- -- Monthly leave accrual on 1st of each month at 1 AM UTC
-- SELECT cron.schedule('monthly-leave-accrual', '0 1 1 * *',
--   $$SELECT public.fn_run_scheduled_task('monthly_leave_accrual')$$);
--
-- -- Daily attendance auto-close at 11 PM EAT (8 PM UTC)
-- SELECT cron.schedule('attendance-autoclose', '0 20 * * *',
--   $$SELECT public.fn_run_scheduled_task('attendance_autoclose')$$);
--
-- -- Daily contract expiry check at 8 AM EAT (5 AM UTC)
-- SELECT cron.schedule('contract-expiry-check', '0 5 * * *',
--   $$SELECT public.fn_run_scheduled_task('contract_expiry_check')$$);
--
-- -- Daily loan maturity check at 7 AM EAT (4 AM UTC)
-- SELECT cron.schedule('loan-maturity-check', '0 4 * * *',
--   $$SELECT public.fn_run_scheduled_task('loan_maturity_check')$$);

-- ═══════════════════════════════════════════════════════════════════════
-- PART H: GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════════

GRANT SELECT, INSERT, UPDATE ON public.scheduled_task_runs TO service_role;

GRANT EXECUTE ON FUNCTION public.fn_daily_arrears_update TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_monthly_leave_accrual TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_daily_attendance_autoclose TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_contract_expiry_check TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_loan_maturity_check TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_run_scheduled_task TO service_role;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
  fn_count int;
BEGIN
  SELECT count(*) INTO fn_count FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name LIKE 'fn_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'SCHEDULED TASKS MIGRATION COMPLETE';
  RAISE NOTICE 'Scheduled functions: %', fn_count;
  RAISE NOTICE '========================================';
END $$;
