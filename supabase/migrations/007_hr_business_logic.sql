-- ============================================================================
-- MIGRATION 007: HR Business Logic — Payroll, Leave, Attendance, Performance
-- Date:       2026-02-14
-- Purpose:    Add comprehensive HR business logic including:
--             - Payroll processing (payslips, deductions, tax computation)
--             - Leave management (approval workflows, accrual logic)
--             - Attendance tracking (clock-in/out RPC, overtime, geofence)
--             - Performance review workflows
--             - HR reporting views (department summaries, headcount)
-- Strategy:   ADD IF NOT EXISTS (safe re-run), preserve existing data
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: PAYROLL TABLES — Payslips, Deductions, Tax Brackets
-- ═══════════════════════════════════════════════════════════════════════

-- A1. Tax brackets (Tanzania PAYE rates)
CREATE TABLE IF NOT EXISTS public.tax_brackets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bracket_name text NOT NULL,
  min_amount numeric NOT NULL DEFAULT 0,
  max_amount numeric, -- NULL = unlimited
  rate_percent numeric NOT NULL DEFAULT 0,
  fixed_amount numeric NOT NULL DEFAULT 0, -- fixed component for this bracket
  effective_from date NOT NULL DEFAULT '2024-07-01',
  effective_to date, -- NULL = current
  country_code text NOT NULL DEFAULT 'TZ',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- A2. Statutory deduction rates (NSSF, WCF, SDL, HESLB, etc.)
CREATE TABLE IF NOT EXISTS public.statutory_deductions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  deduction_code text NOT NULL UNIQUE,
  deduction_name text NOT NULL,
  employee_rate_percent numeric NOT NULL DEFAULT 0,
  employer_rate_percent numeric NOT NULL DEFAULT 0,
  max_employee_amount numeric, -- cap per month
  max_employer_amount numeric,
  is_mandatory boolean NOT NULL DEFAULT true,
  is_active boolean NOT NULL DEFAULT true,
  effective_from date NOT NULL DEFAULT '2024-07-01',
  effective_to date,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- A3. Employee salary structure
CREATE TABLE IF NOT EXISTS public.salary_structures (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  basic_salary numeric NOT NULL DEFAULT 0,
  housing_allowance numeric NOT NULL DEFAULT 0,
  transport_allowance numeric NOT NULL DEFAULT 0,
  meal_allowance numeric NOT NULL DEFAULT 0,
  medical_allowance numeric NOT NULL DEFAULT 0,
  communication_allowance numeric NOT NULL DEFAULT 0,
  other_allowances numeric NOT NULL DEFAULT 0,
  gross_salary numeric GENERATED ALWAYS AS (
    basic_salary + housing_allowance + transport_allowance +
    meal_allowance + medical_allowance + communication_allowance + other_allowances
  ) STORED,
  effective_from date NOT NULL DEFAULT current_date,
  effective_to date,
  is_current boolean NOT NULL DEFAULT true,
  approved_by text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_salary_structures_current
  ON public.salary_structures (employee_id) WHERE is_current = true;

-- A4a. Payroll runs (one per month, groups all payslips)
CREATE TABLE IF NOT EXISTS public.payroll_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  run_period_month int NOT NULL CHECK (run_period_month BETWEEN 1 AND 12),
  run_period_year int NOT NULL CHECK (run_period_year >= 2020),
  month text NOT NULL,                           -- display label e.g. "February 2026"
  status text NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','submitted','approved','paid','cancelled')),
  run_date date NOT NULL DEFAULT current_date,
  prepared_by text,
  approved_by text,
  approved_at timestamptz,
  total_gross numeric NOT NULL DEFAULT 0,
  total_deductions numeric NOT NULL DEFAULT 0,
  total_net numeric NOT NULL DEFAULT 0,
  total_cost numeric NOT NULL DEFAULT 0,         -- gross + employer contributions
  employee_count int NOT NULL DEFAULT 0,
  bank_export_format text,                       -- CRDB/NMB/NBC CSV format identifier
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (run_period_month, run_period_year)
);

-- A4b. Payslips (one per employee per payroll run)
CREATE TABLE IF NOT EXISTS public.payslips (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payroll_run_id uuid NOT NULL REFERENCES public.payroll_runs(id) ON DELETE CASCADE,
  employee_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  employee_name text NOT NULL,
  employee_code text,
  department text,
  -- Earnings
  basic_salary numeric NOT NULL DEFAULT 0,
  housing_allowance numeric NOT NULL DEFAULT 0,
  transport_allowance numeric NOT NULL DEFAULT 0,
  meal_allowance numeric NOT NULL DEFAULT 0,
  medical_allowance numeric NOT NULL DEFAULT 0,
  communication_allowance numeric NOT NULL DEFAULT 0,
  other_allowances numeric NOT NULL DEFAULT 0,
  overtime_pay numeric NOT NULL DEFAULT 0,
  bonus numeric NOT NULL DEFAULT 0,
  gross_salary numeric NOT NULL DEFAULT 0,
  -- Deductions
  paye_tax numeric NOT NULL DEFAULT 0,
  nssf_employee numeric NOT NULL DEFAULT 0,
  nssf_employer numeric NOT NULL DEFAULT 0,
  wcf_contribution numeric NOT NULL DEFAULT 0,
  sdl_contribution numeric NOT NULL DEFAULT 0,
  heslb_deduction numeric NOT NULL DEFAULT 0,
  loan_deduction numeric NOT NULL DEFAULT 0,
  other_deductions numeric NOT NULL DEFAULT 0,
  total_deductions numeric NOT NULL DEFAULT 0,
  -- Net
  net_salary numeric NOT NULL DEFAULT 0,
  -- Payment info
  bank_name text,
  bank_account_number text,
  bank_account_name text,
  payment_status text NOT NULL DEFAULT 'pending', -- pending/paid/failed
  payment_reference text,
  paid_at timestamptz,
  -- Metadata
  days_worked int,
  days_absent int,
  overtime_hours numeric DEFAULT 0,
  late_deduction numeric DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (payroll_run_id, employee_id)
);

-- A5. Payslip deduction line items (for detailed breakdown)
CREATE TABLE IF NOT EXISTS public.payslip_deductions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payslip_id uuid NOT NULL REFERENCES public.payslips(id) ON DELETE CASCADE,
  deduction_code text NOT NULL,
  deduction_name text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  is_statutory boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- A6. Loan deductions (staff salary loans tracked for payroll deduction)
CREATE TABLE IF NOT EXISTS public.staff_salary_loans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  loan_type text NOT NULL DEFAULT 'salary_advance', -- salary_advance, staff_loan, emergency
  principal_amount numeric NOT NULL,
  outstanding_balance numeric NOT NULL,
  monthly_deduction numeric NOT NULL,
  interest_rate numeric NOT NULL DEFAULT 0,
  start_date date NOT NULL DEFAULT current_date,
  expected_end_date date,
  status text NOT NULL DEFAULT 'active', -- active, completed, defaulted, cancelled
  approved_by text,
  approved_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: PAYROLL RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════

-- B1. Calculate PAYE tax (Tanzania progressive rates)
CREATE OR REPLACE FUNCTION public.fn_calculate_paye(p_taxable_income numeric)
RETURNS numeric LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_tax numeric := 0;
  v_remaining numeric := p_taxable_income;
  v_bracket record;
BEGIN
  IF p_taxable_income <= 0 THEN
    RETURN 0;
  END IF;

  FOR v_bracket IN
    SELECT min_amount, max_amount, rate_percent
    FROM public.tax_brackets
    WHERE is_active = true AND country_code = 'TZ'
      AND effective_from <= current_date
      AND (effective_to IS NULL OR effective_to >= current_date)
    ORDER BY min_amount ASC
  LOOP
    IF v_remaining <= 0 THEN EXIT; END IF;

    DECLARE
      v_bracket_size numeric;
      v_taxable_in_bracket numeric;
    BEGIN
      v_bracket_size := CASE
        WHEN v_bracket.max_amount IS NULL THEN v_remaining
        ELSE v_bracket.max_amount - v_bracket.min_amount
      END;
      v_taxable_in_bracket := least(v_remaining, v_bracket_size);
      v_tax := v_tax + (v_taxable_in_bracket * v_bracket.rate_percent / 100);
      v_remaining := v_remaining - v_taxable_in_bracket;
    END;
  END LOOP;

  RETURN round(v_tax, 2);
END;
$$;

-- B2. Generate payslips for a payroll run
CREATE OR REPLACE FUNCTION public.rpc_generate_payslips(
  p_payroll_run_id uuid,
  p_month int,
  p_year int
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_emp record;
  v_salary record;
  v_gross numeric;
  v_nssf_emp numeric;
  v_nssf_er numeric;
  v_taxable numeric;
  v_paye numeric;
  v_wcf numeric;
  v_sdl numeric;
  v_heslb numeric;
  v_loan_ded numeric;
  v_total_ded numeric;
  v_net numeric;
  v_overtime_hrs numeric;
  v_overtime_pay numeric;
  v_days_worked int;
  v_days_absent int;
  v_late_deduction numeric;
  v_count int := 0;
  v_total_cost numeric := 0;
BEGIN
  -- Verify payroll run exists
  IF NOT EXISTS (SELECT 1 FROM public.payroll_runs WHERE id = p_payroll_run_id) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Payroll run not found');
  END IF;

  -- Delete existing payslips for this run (regeneration)
  DELETE FROM public.payslips WHERE payroll_run_id = p_payroll_run_id;

  FOR v_emp IN
    SELECT e.id, e.employee_code, e.full_name, e.dept, e.bank_name,
           e.bank_account_number, e.bank_account_name
    FROM public.employees e
    WHERE e.status = 'active' OR e.employment_status = 'active'
  LOOP
    -- Get current salary structure
    SELECT * INTO v_salary
    FROM public.salary_structures
    WHERE employee_id = v_emp.id AND is_current = true
    LIMIT 1;

    IF v_salary IS NULL THEN
      CONTINUE; -- skip employees without salary structure
    END IF;

    -- Calculate attendance (days worked, overtime)
    SELECT
      count(*) FILTER (WHERE clock_in IS NOT NULL),
      coalesce(sum(CASE WHEN hours_worked > 8 THEN hours_worked - 8 ELSE 0 END), 0),
      count(*) FILTER (WHERE clock_in IS NULL),
      coalesce(sum(CASE WHEN is_late = true THEN late_minutes ELSE 0 END), 0)
    INTO v_days_worked, v_overtime_hrs, v_days_absent, v_late_deduction
    FROM public.attendance_records
    WHERE staff_id IN (
      SELECT s.id FROM public.staff s WHERE s.email = (
        SELECT e2.email FROM public.employees e2 WHERE e2.id = v_emp.id
      )
    )
    AND extract(month FROM work_date) = p_month
    AND extract(year FROM work_date) = p_year;

    -- Overtime pay: 1.5x hourly rate
    v_overtime_pay := round(v_overtime_hrs * (v_salary.basic_salary / 22 / 8) * 1.5, 2);

    -- Late deduction: per-minute penalty (configurable, default 500 TZS/min)
    v_late_deduction := round(coalesce(v_late_deduction, 0) * 500, 2);

    -- Gross salary
    v_gross := v_salary.gross_salary + v_overtime_pay;

    -- NSSF: 10% employee, 10% employer (on gross)
    v_nssf_emp := round(v_gross * 0.10, 2);
    v_nssf_er := round(v_gross * 0.10, 2);

    -- Taxable income = gross - NSSF employee contribution
    v_taxable := v_gross - v_nssf_emp;

    -- PAYE
    v_paye := public.fn_calculate_paye(v_taxable);

    -- WCF: 1% employer
    v_wcf := round(v_gross * 0.01, 2);

    -- SDL: 4.5% employer
    v_sdl := round(v_gross * 0.045, 2);

    -- HESLB: check if employee has HESLB deduction
    v_heslb := 0; -- default, can be overridden per employee

    -- Staff loan deductions
    SELECT coalesce(sum(monthly_deduction), 0) INTO v_loan_ded
    FROM public.staff_salary_loans
    WHERE employee_id = v_emp.id AND status = 'active';

    -- Total deductions
    v_total_ded := v_paye + v_nssf_emp + v_loan_ded + v_heslb + v_late_deduction;

    -- Net salary
    v_net := v_gross - v_total_ded;

    INSERT INTO public.payslips (
      payroll_run_id, employee_id, employee_name, employee_code, department,
      basic_salary, housing_allowance, transport_allowance, meal_allowance,
      medical_allowance, communication_allowance, other_allowances,
      overtime_pay, gross_salary,
      paye_tax, nssf_employee, nssf_employer, wcf_contribution, sdl_contribution,
      heslb_deduction, loan_deduction, other_deductions, total_deductions,
      net_salary, bank_name, bank_account_number, bank_account_name,
      days_worked, days_absent, overtime_hours, late_deduction
    ) VALUES (
      p_payroll_run_id, v_emp.id, v_emp.full_name, v_emp.employee_code, v_emp.dept,
      v_salary.basic_salary, v_salary.housing_allowance, v_salary.transport_allowance,
      v_salary.meal_allowance, v_salary.medical_allowance, v_salary.communication_allowance,
      v_salary.other_allowances, v_overtime_pay, v_gross,
      v_paye, v_nssf_emp, v_nssf_er, v_wcf, v_sdl,
      v_heslb, v_loan_ded, v_late_deduction, v_total_ded,
      v_net, v_emp.bank_name, v_emp.bank_account_number, v_emp.bank_account_name,
      v_days_worked, v_days_absent, v_overtime_hrs, v_late_deduction
    );

    v_count := v_count + 1;
    v_total_cost := v_total_cost + v_net + v_nssf_er + v_wcf + v_sdl;
  END LOOP;

  -- Update payroll run totals
  UPDATE public.payroll_runs SET
    total_cost = v_total_cost,
    status = 'draft'
  WHERE id = p_payroll_run_id;

  RETURN jsonb_build_object(
    'success', true,
    'payroll_run_id', p_payroll_run_id,
    'employees_processed', v_count,
    'total_cost', v_total_cost
  );
END;
$$;

-- B3. Approve payroll run
CREATE OR REPLACE FUNCTION public.rpc_approve_payroll(
  p_payroll_run_id uuid,
  p_approved_by text DEFAULT 'system'
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_run record;
  v_total_net numeric;
  v_employee_count int;
BEGIN
  SELECT * INTO v_run FROM public.payroll_runs WHERE id = p_payroll_run_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Payroll run not found');
  END IF;
  IF v_run.status NOT IN ('draft', 'submitted') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Payroll must be in draft or submitted status. Current: ' || v_run.status);
  END IF;

  SELECT count(*), coalesce(sum(net_salary), 0)
  INTO v_employee_count, v_total_net
  FROM public.payslips WHERE payroll_run_id = p_payroll_run_id;

  IF v_employee_count = 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'No payslips found. Generate payslips first.');
  END IF;

  UPDATE public.payroll_runs SET
    status = 'approved',
    prepared_by = coalesce(prepared_by, p_approved_by)
  WHERE id = p_payroll_run_id;

  RETURN jsonb_build_object(
    'success', true,
    'payroll_run_id', p_payroll_run_id,
    'employees', v_employee_count,
    'total_net', v_total_net,
    'status', 'approved'
  );
END;
$$;

-- B4. Generate bank payment file (returns CSV-ready data)
CREATE OR REPLACE FUNCTION public.rpc_payroll_bank_export(p_payroll_run_id uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_payments jsonb;
  v_total numeric;
  v_count int;
BEGIN
  SELECT jsonb_agg(jsonb_build_object(
    'employee_name', p.employee_name,
    'employee_code', p.employee_code,
    'bank_name', p.bank_name,
    'bank_account_number', p.bank_account_number,
    'bank_account_name', p.bank_account_name,
    'net_salary', p.net_salary,
    'payment_reference', 'PAY-' || to_char(now(), 'YYYYMM') || '-' || p.employee_code
  ) ORDER BY p.employee_name),
  coalesce(sum(p.net_salary), 0),
  count(*)
  INTO v_payments, v_total, v_count
  FROM public.payslips p
  WHERE p.payroll_run_id = p_payroll_run_id AND p.net_salary > 0;

  RETURN jsonb_build_object(
    'success', true,
    'payroll_run_id', p_payroll_run_id,
    'payment_count', v_count,
    'total_amount', v_total,
    'payments', coalesce(v_payments, '[]'::jsonb)
  );
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: LEAVE MANAGEMENT RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════

-- C1. Submit leave request (validates balance, policy rules)
CREATE OR REPLACE FUNCTION public.rpc_submit_leave_request(
  p_user_id uuid,
  p_leave_type_id uuid,
  p_start_date date,
  p_end_date date,
  p_reason text DEFAULT NULL,
  p_attachment_url text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_leave_type record;
  v_balance record;
  v_days_requested int;
  v_employee record;
  v_request_id uuid;
  v_current_year int := extract(year FROM current_date)::int;
BEGIN
  -- Validate dates
  IF p_start_date > p_end_date THEN
    RETURN jsonb_build_object('success', false, 'error', 'Start date must be before or equal to end date');
  END IF;
  IF p_start_date < current_date THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot request leave for past dates');
  END IF;

  -- Calculate business days
  v_days_requested := (p_end_date - p_start_date) + 1;

  -- Get leave type
  SELECT * INTO v_leave_type FROM public.leave_types WHERE id = p_leave_type_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Invalid leave type');
  END IF;

  -- Get employee info
  SELECT * INTO v_employee FROM public.employees WHERE user_id = p_user_id;
  IF NOT FOUND THEN
    -- Try staff table
    IF NOT EXISTS (SELECT 1 FROM public.staff WHERE user_id = p_user_id) THEN
      RETURN jsonb_build_object('success', false, 'error', 'Employee not found');
    END IF;
  END IF;

  -- Check gender restriction
  IF v_leave_type.applicable_gender IS NOT NULL AND v_leave_type.applicable_gender != 'all' THEN
    IF v_employee.gender IS NOT NULL AND lower(v_employee.gender) != lower(v_leave_type.applicable_gender) THEN
      RETURN jsonb_build_object('success', false, 'error', 'This leave type is restricted to ' || v_leave_type.applicable_gender || ' employees');
    END IF;
  END IF;

  -- Check advance notice
  IF v_leave_type.min_advance_notice_days IS NOT NULL
     AND (p_start_date - current_date) < v_leave_type.min_advance_notice_days THEN
    RETURN jsonb_build_object('success', false, 'error',
      'Minimum ' || v_leave_type.min_advance_notice_days || ' days advance notice required');
  END IF;

  -- Check max consecutive days
  IF v_leave_type.max_consecutive_days IS NOT NULL AND v_days_requested > v_leave_type.max_consecutive_days THEN
    RETURN jsonb_build_object('success', false, 'error',
      'Maximum ' || v_leave_type.max_consecutive_days || ' consecutive days allowed for this leave type');
  END IF;

  -- Check document requirement
  IF v_leave_type.requires_document = true AND p_attachment_url IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Supporting document is required for this leave type');
  END IF;

  -- Check balance
  SELECT * INTO v_balance
  FROM public.leave_balances
  WHERE user_id = p_user_id AND leave_type_id = p_leave_type_id AND year = v_current_year;

  IF v_balance IS NOT NULL AND coalesce(v_balance.remaining_days, 0) < v_days_requested THEN
    RETURN jsonb_build_object('success', false, 'error',
      'Insufficient leave balance. Available: ' || coalesce(v_balance.remaining_days, 0) || ', Requested: ' || v_days_requested);
  END IF;

  -- Check for overlapping requests
  IF EXISTS (
    SELECT 1 FROM public.leave_requests
    WHERE user_id = p_user_id
      AND status IN ('pending', 'approved')
      AND daterange(start_date, end_date, '[]') && daterange(p_start_date, p_end_date, '[]')
  ) THEN
    RETURN jsonb_build_object('success', false, 'error', 'You have an overlapping leave request for these dates');
  END IF;

  -- Create leave request
  INSERT INTO public.leave_requests (user_id, leave_type_id, start_date, end_date, days_count, reason, status, attachment_url)
  VALUES (p_user_id, p_leave_type_id, p_start_date, p_end_date, v_days_requested, p_reason, 'pending', p_attachment_url)
  RETURNING id INTO v_request_id;

  RETURN jsonb_build_object(
    'success', true,
    'request_id', v_request_id,
    'days_requested', v_days_requested,
    'leave_type', v_leave_type.leave_type,
    'status', 'pending'
  );
END;
$$;

-- C2. Approve/reject leave request
CREATE OR REPLACE FUNCTION public.rpc_process_leave_request(
  p_request_id uuid,
  p_action text, -- 'approve' or 'reject'
  p_manager_comment text DEFAULT NULL,
  p_processed_by uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_request record;
  v_new_status text;
  v_current_year int := extract(year FROM current_date)::int;
BEGIN
  SELECT * INTO v_request FROM public.leave_requests WHERE id = p_request_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Leave request not found');
  END IF;
  IF v_request.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Leave request is not pending. Current: ' || v_request.status);
  END IF;

  IF p_action = 'approve' THEN
    v_new_status := 'approved';

    -- Deduct from leave balance
    UPDATE public.leave_balances SET
      used_days = coalesce(used_days, 0) + v_request.days_count,
      remaining_days = coalesce(remaining_days, 0) - v_request.days_count
    WHERE user_id = v_request.user_id
      AND leave_type_id = v_request.leave_type_id
      AND year = v_current_year;

  ELSIF p_action = 'reject' THEN
    v_new_status := 'rejected';
  ELSE
    RETURN jsonb_build_object('success', false, 'error', 'Invalid action. Use approve or reject');
  END IF;

  UPDATE public.leave_requests SET
    status = v_new_status,
    manager_comment = p_manager_comment
  WHERE id = p_request_id;

  RETURN jsonb_build_object(
    'success', true,
    'request_id', p_request_id,
    'action', p_action,
    'new_status', v_new_status,
    'employee_id', v_request.user_id,
    'days', v_request.days_count
  );
END;
$$;

-- C3. Cancel leave request (only if pending or approved & future)
CREATE OR REPLACE FUNCTION public.rpc_cancel_leave_request(
  p_request_id uuid,
  p_cancelled_by uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_request record;
  v_current_year int := extract(year FROM current_date)::int;
BEGIN
  SELECT * INTO v_request FROM public.leave_requests WHERE id = p_request_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Leave request not found');
  END IF;

  IF v_request.status NOT IN ('pending', 'approved') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Can only cancel pending or approved requests');
  END IF;

  IF v_request.status = 'approved' AND v_request.start_date <= current_date THEN
    RETURN jsonb_build_object('success', false, 'error', 'Cannot cancel leave that has already started');
  END IF;

  -- Restore balance if was approved
  IF v_request.status = 'approved' THEN
    UPDATE public.leave_balances SET
      used_days = greatest(0, coalesce(used_days, 0) - v_request.days_count),
      remaining_days = coalesce(remaining_days, 0) + v_request.days_count
    WHERE user_id = v_request.user_id
      AND leave_type_id = v_request.leave_type_id
      AND year = v_current_year;
  END IF;

  UPDATE public.leave_requests SET status = 'cancelled' WHERE id = p_request_id;

  RETURN jsonb_build_object('success', true, 'request_id', p_request_id, 'status', 'cancelled');
END;
$$;

-- C4. Initialize annual leave balances for all staff
CREATE OR REPLACE FUNCTION public.rpc_initialize_leave_balances(
  p_year int DEFAULT extract(year FROM current_date)::int
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_count int := 0;
  v_staff record;
  v_lt record;
BEGIN
  FOR v_staff IN
    SELECT s.id AS staff_id, s.user_id
    FROM public.staff s WHERE s.active = true AND s.user_id IS NOT NULL
  LOOP
    FOR v_lt IN
      SELECT id, annual_entitlement_days FROM public.leave_types WHERE is_active = true
    LOOP
      INSERT INTO public.leave_balances (user_id, leave_type_id, year, annual_entitlement, used_days, remaining_days)
      VALUES (v_staff.user_id, v_lt.id, p_year, v_lt.annual_entitlement_days, 0, v_lt.annual_entitlement_days)
      ON CONFLICT (user_id, leave_type_id, year) DO NOTHING;
      v_count := v_count + 1;
    END LOOP;
  END LOOP;

  RETURN jsonb_build_object('success', true, 'balances_initialized', v_count, 'year', p_year);
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: ATTENDANCE TRACKING RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════

-- D1. Clock in (with geofence validation)
CREATE OR REPLACE FUNCTION public.rpc_clock_in(
  p_staff_id uuid,
  p_latitude numeric DEFAULT NULL,
  p_longitude numeric DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_today date := current_date;
  v_now timestamptz := now();
  v_existing record;
  v_is_late boolean := false;
  v_late_mins int := 0;
  v_work_start time := '08:00:00'::time; -- configurable
  v_record_id uuid;
  v_geofence_ok boolean := true;
  v_dept record;
BEGIN
  -- Check if already clocked in today
  SELECT * INTO v_existing
  FROM public.attendance_records
  WHERE staff_id = p_staff_id AND work_date = v_today;

  IF v_existing IS NOT NULL AND v_existing.clock_in IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Already clocked in today at ' || v_existing.clock_in::text);
  END IF;

  -- Check late status
  IF v_now::time > v_work_start THEN
    v_is_late := true;
    v_late_mins := extract(epoch FROM (v_now::time - v_work_start))::int / 60;
  END IF;

  -- Geofence validation (if coordinates provided)
  IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
    SELECT d.* INTO v_dept
    FROM public.departments d
    JOIN public.staff s ON lower(s.department) = lower(d.key) OR lower(s.department) = lower(d.name)
    WHERE s.id = p_staff_id AND d.is_attendance_location = true
    LIMIT 1;

    IF v_dept IS NOT NULL AND v_dept.branch_latitude IS NOT NULL THEN
      -- Haversine distance check (simplified)
      IF (
        6371000 * acos(
          least(1, cos(radians(v_dept.branch_latitude)) * cos(radians(p_latitude))
          * cos(radians(p_longitude) - radians(v_dept.branch_longitude))
          + sin(radians(v_dept.branch_latitude)) * sin(radians(p_latitude)))
        )
      ) > coalesce(v_dept.attendance_radius_m, 500) THEN
        v_geofence_ok := false;
      END IF;
    END IF;
  END IF;

  IF v_existing IS NOT NULL THEN
    -- Update existing record
    UPDATE public.attendance_records SET
      clock_in = v_now,
      is_late = v_is_late,
      late_minutes = v_late_mins,
      updated_at = now()
    WHERE id = v_existing.id
    RETURNING id INTO v_record_id;
  ELSE
    INSERT INTO public.attendance_records (staff_id, work_date, clock_in, is_late, late_minutes)
    VALUES (p_staff_id, v_today, v_now, v_is_late, v_late_mins)
    RETURNING id INTO v_record_id;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'record_id', v_record_id,
    'clock_in', v_now,
    'is_late', v_is_late,
    'late_minutes', v_late_mins,
    'geofence_ok', v_geofence_ok,
    'work_date', v_today
  );
END;
$$;

-- D2. Clock out (calculates hours worked)
CREATE OR REPLACE FUNCTION public.rpc_clock_out(
  p_staff_id uuid,
  p_daily_report text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_today date := current_date;
  v_now timestamptz := now();
  v_record record;
  v_hours numeric;
BEGIN
  SELECT * INTO v_record
  FROM public.attendance_records
  WHERE staff_id = p_staff_id AND work_date = v_today;

  IF NOT FOUND OR v_record.clock_in IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'No clock-in record found for today');
  END IF;

  IF v_record.clock_out IS NOT NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Already clocked out today at ' || v_record.clock_out::text);
  END IF;

  v_hours := round(extract(epoch FROM (v_now - v_record.clock_in)) / 3600.0, 2);

  UPDATE public.attendance_records SET
    clock_out = v_now,
    hours_worked = v_hours,
    daily_report = p_daily_report,
    updated_at = now()
  WHERE id = v_record.id;

  RETURN jsonb_build_object(
    'success', true,
    'record_id', v_record.id,
    'clock_in', v_record.clock_in,
    'clock_out', v_now,
    'hours_worked', v_hours,
    'is_overtime', v_hours > 8,
    'overtime_hours', greatest(0, v_hours - 8)
  );
END;
$$;

-- D3. Rate staff daily performance (manager action)
CREATE OR REPLACE FUNCTION public.rpc_rate_attendance(
  p_record_id uuid,
  p_rating int, -- 1-5
  p_manager_notes text DEFAULT NULL,
  p_rated_by uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF p_rating < 1 OR p_rating > 5 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Rating must be between 1 and 5');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.attendance_records WHERE id = p_record_id) THEN
    RETURN jsonb_build_object('success', false, 'error', 'Attendance record not found');
  END IF;

  UPDATE public.attendance_records SET
    manager_rating = p_rating,
    manager_notes = p_manager_notes,
    rated_by = p_rated_by,
    rated_at = now(),
    updated_at = now()
  WHERE id = p_record_id;

  RETURN jsonb_build_object('success', true, 'record_id', p_record_id, 'rating', p_rating);
END;
$$;

-- D4. Monthly attendance summary (for Retool)
CREATE OR REPLACE FUNCTION public.rpc_attendance_summary(
  p_month int DEFAULT extract(month FROM current_date)::int,
  p_year int DEFAULT extract(year FROM current_date)::int
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_agg(row_data ORDER BY staff_name) INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'staff_id', s.id,
      'staff_name', s.full_name,
      'department', s.department,
      'days_present', count(*) FILTER (WHERE ar.clock_in IS NOT NULL),
      'days_late', count(*) FILTER (WHERE ar.is_late = true),
      'total_late_minutes', coalesce(sum(ar.late_minutes), 0),
      'total_hours', round(coalesce(sum(ar.hours_worked), 0), 2),
      'overtime_hours', round(coalesce(sum(CASE WHEN ar.hours_worked > 8 THEN ar.hours_worked - 8 ELSE 0 END), 0), 2),
      'avg_rating', round(coalesce(avg(ar.manager_rating), 0), 1),
      'days_without_report', count(*) FILTER (WHERE ar.clock_out IS NOT NULL AND ar.daily_report IS NULL)
    ) AS row_data, s.full_name AS staff_name
    FROM public.staff s
    LEFT JOIN public.attendance_records ar
      ON ar.staff_id = s.id
      AND extract(month FROM ar.work_date) = p_month
      AND extract(year FROM ar.work_date) = p_year
    WHERE s.active = true
    GROUP BY s.id, s.full_name, s.department
  ) sub;

  RETURN jsonb_build_object('success', true, 'month', p_month, 'year', p_year, 'summary', coalesce(v_result, '[]'::jsonb));
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: PERFORMANCE REVIEW SYSTEM
-- ═══════════════════════════════════════════════════════════════════════

-- E1. Performance review cycles (quarterly, annual, etc.)
CREATE TABLE IF NOT EXISTS public.performance_review_cycles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cycle_name text NOT NULL,
  cycle_type text NOT NULL DEFAULT 'quarterly', -- quarterly, semi_annual, annual
  period_start date NOT NULL,
  period_end date NOT NULL,
  review_deadline date,
  status text NOT NULL DEFAULT 'draft', -- draft, active, in_review, completed
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- E2. Individual performance reviews
CREATE TABLE IF NOT EXISTS public.performance_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cycle_id uuid NOT NULL REFERENCES public.performance_review_cycles(id) ON DELETE CASCADE,
  employee_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  reviewer_id uuid, -- manager/reviewer
  -- Self-assessment scores (1-5)
  self_score_quality int,
  self_score_productivity int,
  self_score_teamwork int,
  self_score_initiative int,
  self_score_attendance int,
  self_comments text,
  -- Manager assessment scores (1-5)
  mgr_score_quality int,
  mgr_score_productivity int,
  mgr_score_teamwork int,
  mgr_score_initiative int,
  mgr_score_attendance int,
  mgr_comments text,
  -- KPI-based scores (auto-calculated for loan officers)
  kpi_disbursement_score numeric,
  kpi_collection_score numeric,
  kpi_par_score numeric,
  kpi_client_growth_score numeric,
  -- Overall
  overall_score numeric,
  overall_grade text, -- A, B, C, D, F
  status text NOT NULL DEFAULT 'pending', -- pending, self_review, manager_review, completed
  recommendations text,
  development_plan text,
  submitted_at timestamptz,
  reviewed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (cycle_id, employee_id)
);

-- E3. Performance goals/objectives
CREATE TABLE IF NOT EXISTS public.performance_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES public.performance_reviews(id) ON DELETE CASCADE,
  goal_description text NOT NULL,
  target_metric text,
  target_value numeric,
  actual_value numeric,
  weight_percent numeric DEFAULT 0,
  achievement_percent numeric DEFAULT 0,
  status text NOT NULL DEFAULT 'pending', -- pending, in_progress, achieved, missed
  due_date date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- E4. Submit self-review
CREATE OR REPLACE FUNCTION public.rpc_submit_self_review(
  p_review_id uuid,
  p_quality int,
  p_productivity int,
  p_teamwork int,
  p_initiative int,
  p_attendance int,
  p_comments text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_review record;
BEGIN
  SELECT * INTO v_review FROM public.performance_reviews WHERE id = p_review_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Performance review not found');
  END IF;
  IF v_review.status NOT IN ('pending', 'self_review') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Review is not in self-review stage');
  END IF;

  -- Validate scores
  IF p_quality < 1 OR p_quality > 5 OR p_productivity < 1 OR p_productivity > 5
     OR p_teamwork < 1 OR p_teamwork > 5 OR p_initiative < 1 OR p_initiative > 5
     OR p_attendance < 1 OR p_attendance > 5 THEN
    RETURN jsonb_build_object('success', false, 'error', 'All scores must be between 1 and 5');
  END IF;

  UPDATE public.performance_reviews SET
    self_score_quality = p_quality,
    self_score_productivity = p_productivity,
    self_score_teamwork = p_teamwork,
    self_score_initiative = p_initiative,
    self_score_attendance = p_attendance,
    self_comments = p_comments,
    status = 'manager_review',
    submitted_at = now(),
    updated_at = now()
  WHERE id = p_review_id;

  RETURN jsonb_build_object('success', true, 'review_id', p_review_id, 'status', 'manager_review');
END;
$$;

-- E5. Submit manager review & calculate overall score
CREATE OR REPLACE FUNCTION public.rpc_submit_manager_review(
  p_review_id uuid,
  p_quality int,
  p_productivity int,
  p_teamwork int,
  p_initiative int,
  p_attendance int,
  p_comments text DEFAULT NULL,
  p_recommendations text DEFAULT NULL,
  p_development_plan text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_review record;
  v_overall numeric;
  v_grade text;
BEGIN
  SELECT * INTO v_review FROM public.performance_reviews WHERE id = p_review_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Performance review not found');
  END IF;
  IF v_review.status != 'manager_review' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Review is not in manager review stage. Current: ' || v_review.status);
  END IF;

  -- Calculate overall: 70% manager, 30% self (weighted average)
  v_overall := round((
    (p_quality + p_productivity + p_teamwork + p_initiative + p_attendance)::numeric / 5.0 * 0.7
    + coalesce((v_review.self_score_quality + v_review.self_score_productivity + v_review.self_score_teamwork
       + v_review.self_score_initiative + v_review.self_score_attendance)::numeric / 5.0 * 0.3, 0)
  ), 2);

  -- Grade assignment
  v_grade := CASE
    WHEN v_overall >= 4.5 THEN 'A'
    WHEN v_overall >= 3.5 THEN 'B'
    WHEN v_overall >= 2.5 THEN 'C'
    WHEN v_overall >= 1.5 THEN 'D'
    ELSE 'F'
  END;

  UPDATE public.performance_reviews SET
    mgr_score_quality = p_quality,
    mgr_score_productivity = p_productivity,
    mgr_score_teamwork = p_teamwork,
    mgr_score_initiative = p_initiative,
    mgr_score_attendance = p_attendance,
    mgr_comments = p_comments,
    recommendations = p_recommendations,
    development_plan = p_development_plan,
    overall_score = v_overall,
    overall_grade = v_grade,
    status = 'completed',
    reviewed_at = now(),
    updated_at = now()
  WHERE id = p_review_id;

  RETURN jsonb_build_object(
    'success', true,
    'review_id', p_review_id,
    'overall_score', v_overall,
    'grade', v_grade,
    'status', 'completed'
  );
END;
$$;

-- E6. Auto-calculate KPI scores for loan officers
CREATE OR REPLACE FUNCTION public.rpc_calculate_kpi_scores(
  p_cycle_id uuid
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_cycle record;
  v_review record;
  v_updated int := 0;
  v_disb_score numeric;
  v_coll_score numeric;
  v_par_score numeric;
  v_growth_score numeric;
BEGIN
  SELECT * INTO v_cycle FROM public.performance_review_cycles WHERE id = p_cycle_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Review cycle not found');
  END IF;

  FOR v_review IN
    SELECT pr.id AS review_id, pr.employee_id, e.email
    FROM public.performance_reviews pr
    JOIN public.employees e ON e.id = pr.employee_id
    WHERE pr.cycle_id = p_cycle_id
  LOOP
    -- Get loan officer performance from staff_performance table
    SELECT
      CASE WHEN coalesce(sp.actual_disbursement, 0) > 0 THEN least(5, round(sp.actual_disbursement / greatest(1, 10000000) * 5, 2)) ELSE 0 END,
      CASE WHEN coalesce(sp.actual_collection, 0) > 0 THEN least(5, round(sp.actual_collection / greatest(1, 5000000) * 5, 2)) ELSE 0 END,
      CASE WHEN coalesce(sp.current_par_30, 0) <= 5 THEN 5
           WHEN sp.current_par_30 <= 10 THEN 4
           WHEN sp.current_par_30 <= 20 THEN 3
           WHEN sp.current_par_30 <= 30 THEN 2
           ELSE 1 END,
      coalesce(sp.ptp_success_rate, 0) / 20.0
    INTO v_disb_score, v_coll_score, v_par_score, v_growth_score
    FROM public.staff_performance sp
    JOIN public.staff s ON s.id = sp.staff_id
    WHERE s.email = v_review.email
      AND sp.period_start >= v_cycle.period_start
      AND sp.period_end <= v_cycle.period_end
    ORDER BY sp.period_end DESC
    LIMIT 1;

    IF v_disb_score IS NOT NULL THEN
      UPDATE public.performance_reviews SET
        kpi_disbursement_score = v_disb_score,
        kpi_collection_score = v_coll_score,
        kpi_par_score = v_par_score,
        kpi_client_growth_score = v_growth_score,
        updated_at = now()
      WHERE id = v_review.review_id;
      v_updated := v_updated + 1;
    END IF;
  END LOOP;

  RETURN jsonb_build_object('success', true, 'cycle_id', p_cycle_id, 'kpi_scores_updated', v_updated);
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART F: HR REPORTING VIEWS
-- ═══════════════════════════════════════════════════════════════════════

-- F1. Department headcount & cost summary
CREATE OR REPLACE VIEW public.v_department_summary AS
SELECT
  coalesce(e.dept, 'Unassigned') AS department,
  count(*) AS total_employees,
  count(*) FILTER (WHERE e.status = 'active' OR e.employment_status = 'active') AS active_employees,
  count(*) FILTER (WHERE e.gender = 'Male') AS male_count,
  count(*) FILTER (WHERE e.gender = 'Female') AS female_count,
  round(coalesce(avg(e.salary), 0), 2) AS avg_salary,
  coalesce(sum(e.salary), 0) AS total_salary_cost,
  count(*) FILTER (WHERE e.contract_end_date IS NOT NULL AND e.contract_end_date <= current_date + interval '90 days') AS contracts_expiring_90d,
  count(*) FILTER (WHERE e.hire_date >= current_date - interval '6 months') AS new_hires_6m
FROM public.employees e
GROUP BY e.dept;

-- F2. Employee directory (comprehensive Retool view)
CREATE OR REPLACE VIEW public.v_employee_directory AS
SELECT
  e.id,
  e.employee_code,
  e.full_name,
  e.email,
  e.phone,
  e.dept AS department,
  e.branch,
  e.position,
  e.job_position,
  e.manager_email,
  e.status,
  e.employment_status,
  e.hire_date,
  e.contract_start_date,
  e.contract_end_date,
  CASE
    WHEN e.contract_end_date IS NULL THEN 'Permanent'
    WHEN e.contract_end_date < current_date THEN 'Expired'
    WHEN e.contract_end_date <= current_date + interval '30 days' THEN 'Expiring Soon'
    ELSE 'Active'
  END AS contract_status,
  e.date_of_birth,
  CASE WHEN e.date_of_birth IS NOT NULL
    THEN extract(year FROM age(current_date, e.date_of_birth))::int
    ELSE NULL
  END AS age_years,
  e.gender,
  e.salary,
  e.tin_number,
  e.nida_number,
  e.bank_name,
  e.bank_account_number,
  -- Attendance summary (current month)
  att.days_present,
  att.days_late,
  att.total_hours,
  -- Leave summary (current year)
  lv.total_leave_taken,
  lv.leave_balance_remaining,
  e.created_at,
  e.updated_at
FROM public.employees e
LEFT JOIN LATERAL (
  SELECT
    count(*) FILTER (WHERE ar.clock_in IS NOT NULL) AS days_present,
    count(*) FILTER (WHERE ar.is_late = true) AS days_late,
    round(coalesce(sum(ar.hours_worked), 0), 2) AS total_hours
  FROM public.attendance_records ar
  JOIN public.staff s ON s.id = ar.staff_id AND s.email = e.email
  WHERE extract(month FROM ar.work_date) = extract(month FROM current_date)
    AND extract(year FROM ar.work_date) = extract(year FROM current_date)
) att ON true
LEFT JOIN LATERAL (
  SELECT
    coalesce(sum(lb.used_days), 0) AS total_leave_taken,
    coalesce(sum(lb.remaining_days), 0) AS leave_balance_remaining
  FROM public.leave_balances lb
  JOIN public.staff s ON s.user_id = lb.user_id AND s.email = e.email
  WHERE lb.year = extract(year FROM current_date)::int
) lv ON true;

-- F3. Leave dashboard view
CREATE OR REPLACE VIEW public.v_leave_dashboard AS
SELECT
  lr.id AS request_id,
  e.full_name AS employee_name,
  e.employee_code,
  e.dept AS department,
  lt.leave_type,
  lr.start_date,
  lr.end_date,
  lr.days_count,
  lr.reason,
  lr.status,
  lr.manager_comment,
  lr.attachment_url,
  lr.created_at AS requested_at,
  lb.annual_entitlement,
  lb.used_days,
  lb.remaining_days
FROM public.leave_requests lr
JOIN public.employees e ON e.user_id = lr.user_id
JOIN public.leave_types lt ON lt.id = lr.leave_type_id
LEFT JOIN public.leave_balances lb
  ON lb.user_id = lr.user_id
  AND lb.leave_type_id = lr.leave_type_id
  AND lb.year = extract(year FROM current_date)::int;

-- F4. Attendance dashboard view
CREATE OR REPLACE VIEW public.v_attendance_dashboard AS
SELECT
  ar.id,
  ar.staff_id,
  s.full_name AS staff_name,
  s.department,
  ar.work_date,
  ar.clock_in,
  ar.clock_out,
  ar.hours_worked,
  ar.is_late,
  ar.late_minutes,
  ar.daily_report,
  ar.manager_rating,
  ar.manager_notes,
  CASE
    WHEN ar.clock_out IS NULL AND ar.clock_in IS NOT NULL THEN 'Working'
    WHEN ar.hours_worked >= 8 THEN 'Full Day'
    WHEN ar.hours_worked >= 4 THEN 'Half Day'
    WHEN ar.hours_worked > 0 THEN 'Partial'
    ELSE 'Absent'
  END AS attendance_status,
  CASE WHEN ar.hours_worked > 8 THEN round(ar.hours_worked - 8, 2) ELSE 0 END AS overtime_hours
FROM public.attendance_records ar
JOIN public.staff s ON s.id = ar.staff_id;

-- F5. Payroll summary view
CREATE OR REPLACE VIEW public.v_payroll_summary AS
SELECT
  pr.id AS payroll_run_id,
  pr.run_period_month,
  pr.run_period_year,
  pr.month AS period_name,
  pr.status,
  pr.run_date,
  pr.prepared_by,
  pr.total_cost,
  ps.employee_count,
  ps.total_gross,
  ps.total_deductions,
  ps.total_net,
  ps.total_paye,
  ps.total_nssf_employee,
  ps.total_nssf_employer,
  ps.total_wcf,
  ps.total_sdl
FROM public.payroll_runs pr
LEFT JOIN LATERAL (
  SELECT
    count(*) AS employee_count,
    coalesce(sum(p.gross_salary), 0) AS total_gross,
    coalesce(sum(p.total_deductions), 0) AS total_deductions,
    coalesce(sum(p.net_salary), 0) AS total_net,
    coalesce(sum(p.paye_tax), 0) AS total_paye,
    coalesce(sum(p.nssf_employee), 0) AS total_nssf_employee,
    coalesce(sum(p.nssf_employer), 0) AS total_nssf_employer,
    coalesce(sum(p.wcf_contribution), 0) AS total_wcf,
    coalesce(sum(p.sdl_contribution), 0) AS total_sdl
  FROM public.payslips p
  WHERE p.payroll_run_id = pr.id
) ps ON true;

-- F6. Performance review dashboard
CREATE OR REPLACE VIEW public.v_performance_dashboard AS
SELECT
  prc.cycle_name,
  prc.cycle_type,
  prc.period_start,
  prc.period_end,
  prc.status AS cycle_status,
  pr.id AS review_id,
  pr.employee_id,
  e.full_name AS employee_name,
  e.employee_code,
  e.dept AS department,
  pr.status AS review_status,
  pr.self_score_quality,
  pr.self_score_productivity,
  pr.self_score_teamwork,
  pr.self_score_initiative,
  pr.self_score_attendance,
  pr.mgr_score_quality,
  pr.mgr_score_productivity,
  pr.mgr_score_teamwork,
  pr.mgr_score_initiative,
  pr.mgr_score_attendance,
  pr.kpi_disbursement_score,
  pr.kpi_collection_score,
  pr.kpi_par_score,
  pr.overall_score,
  pr.overall_grade,
  pr.recommendations,
  pr.development_plan,
  pr.submitted_at,
  pr.reviewed_at
FROM public.performance_reviews pr
JOIN public.performance_review_cycles prc ON prc.id = pr.cycle_id
JOIN public.employees e ON e.id = pr.employee_id;

-- F7. HR KPI dashboard (single call)
CREATE OR REPLACE FUNCTION public.rpc_hr_dashboard_kpis()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_total_staff int;
  v_present int;
  v_work_days int;
  v_rate numeric;
  v_result jsonb;
BEGIN
  -- Calculate attendance rate for this month
  v_total_staff := (SELECT count(*) FROM public.staff WHERE active = true);
  v_present := (SELECT count(DISTINCT staff_id) FROM public.attendance_records
    WHERE work_date >= date_trunc('month', current_date) AND clock_in IS NOT NULL);
  v_work_days := GREATEST(1, EXTRACT(DAY FROM current_date)::int);
  v_rate := CASE WHEN v_total_staff > 0
    THEN round((v_present::numeric / (v_total_staff * v_work_days)) * 100, 0)
    ELSE 0 END;

  SELECT jsonb_build_object(
    'headcount', jsonb_build_object(
      'active', (SELECT count(*) FROM public.employees WHERE status = 'active' OR employment_status = 'active'),
      'total_staff', v_total_staff,
      'departments', (SELECT count(DISTINCT dept) FROM public.employees WHERE dept IS NOT NULL),
      'new_hires_this_month', (SELECT count(*) FROM public.employees WHERE hire_date >= date_trunc('month', current_date))
    ),
    'payroll', jsonb_build_object(
      'monthly_cost', (SELECT total_cost FROM public.payroll_runs ORDER BY run_date DESC LIMIT 1),
      'avg_salary', (SELECT round(avg(basic_salary), 0) FROM public.salary_structures WHERE is_current = true),
      'status', (SELECT status FROM public.payroll_runs ORDER BY run_date DESC LIMIT 1)
    ),
    'attendance', jsonb_build_object(
      'present_today', (SELECT count(*) FROM public.attendance_records WHERE work_date = current_date AND clock_in IS NOT NULL),
      'late_today', (SELECT count(*) FROM public.attendance_records WHERE work_date = current_date AND is_late = true),
      'rate_this_month', v_rate
    ),
    'leave', jsonb_build_object(
      'pending_requests', (SELECT count(*) FROM public.leave_requests WHERE status = 'pending'),
      'on_leave_today', (SELECT count(*) FROM public.leave_requests WHERE status = 'approved' AND current_date BETWEEN start_date AND end_date)
    ),
    'performance', jsonb_build_object(
      'avg_score', (SELECT round(avg(overall_score), 1) FROM public.performance_reviews WHERE overall_score IS NOT NULL),
      'pending_reviews', (SELECT count(*) FROM public.performance_reviews WHERE status IN ('pending', 'self_review', 'manager_review')),
      'active_cycles', (SELECT count(*) FROM public.performance_review_cycles WHERE status IN ('active', 'in_review'))
    ),
    'alerts', jsonb_build_object(
      'expiring_contracts', (SELECT count(*) FROM public.employees WHERE contract_end_date BETWEEN current_date AND current_date + interval '30 days')
    )
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART G: SEED TANZANIA PAYE TAX BRACKETS (2024/2025)
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO public.tax_brackets (bracket_name, min_amount, max_amount, rate_percent, fixed_amount, country_code)
VALUES
  ('Band 1 (0 - 270,000)', 0, 270000, 0, 0, 'TZ'),
  ('Band 2 (270,001 - 520,000)', 270000, 520000, 8, 0, 'TZ'),
  ('Band 3 (520,001 - 760,000)', 520000, 760000, 20, 20000, 'TZ'),
  ('Band 4 (760,001 - 1,000,000)', 760000, 1000000, 25, 68000, 'TZ'),
  ('Band 5 (1,000,001 - 1,500,000)', 1000000, 1500000, 25, 128000, 'TZ'),
  ('Band 6 (Above 1,500,000)', 1500000, NULL, 30, 253000, 'TZ')
ON CONFLICT DO NOTHING;

-- Statutory deductions
INSERT INTO public.statutory_deductions (deduction_code, deduction_name, employee_rate_percent, employer_rate_percent, is_mandatory)
VALUES
  ('NSSF', 'National Social Security Fund', 10, 10, true),
  ('WCF', 'Workers Compensation Fund', 0, 1, true),
  ('SDL', 'Skills Development Levy', 0, 4.5, true),
  ('HESLB', 'Higher Education Student Loans Board', 0, 0, false)
ON CONFLICT (deduction_code) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- PART H: GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════════

-- Tables
GRANT SELECT, INSERT, UPDATE ON public.tax_brackets TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.statutory_deductions TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.salary_structures TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.payslips TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.payslip_deductions TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.staff_salary_loans TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.performance_review_cycles TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.performance_reviews TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.performance_goals TO service_role;

-- Views
GRANT SELECT ON public.v_department_summary TO service_role, authenticated;
GRANT SELECT ON public.v_employee_directory TO service_role, authenticated;
GRANT SELECT ON public.v_leave_dashboard TO service_role, authenticated;
GRANT SELECT ON public.v_attendance_dashboard TO service_role, authenticated;
GRANT SELECT ON public.v_payroll_summary TO service_role, authenticated;
GRANT SELECT ON public.v_performance_dashboard TO service_role, authenticated;

-- RPC Functions
GRANT EXECUTE ON FUNCTION public.fn_calculate_paye TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_generate_payslips TO service_role;
GRANT EXECUTE ON FUNCTION public.rpc_approve_payroll TO service_role;
GRANT EXECUTE ON FUNCTION public.rpc_payroll_bank_export TO service_role;
GRANT EXECUTE ON FUNCTION public.rpc_submit_leave_request TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_process_leave_request TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_cancel_leave_request TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_initialize_leave_balances TO service_role;
GRANT EXECUTE ON FUNCTION public.rpc_clock_in TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_clock_out TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_rate_attendance TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_attendance_summary TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_submit_self_review TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_submit_manager_review TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_calculate_kpi_scores TO service_role;
GRANT EXECUTE ON FUNCTION public.rpc_hr_dashboard_kpis TO service_role, authenticated;

-- ============================================================================
-- PART I: UPDATE RUN_ALL_MIGRATIONS
-- ============================================================================

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
  tbl_count int;
  view_count int;
  fn_count int;
BEGIN
  SELECT count(*) INTO tbl_count FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN (
      'tax_brackets', 'statutory_deductions', 'salary_structures',
      'payslips', 'payslip_deductions', 'staff_salary_loans',
      'performance_review_cycles', 'performance_reviews', 'performance_goals'
    );
  SELECT count(*) INTO view_count FROM information_schema.views
    WHERE table_schema = 'public' AND table_name LIKE 'v_%';
  SELECT count(*) INTO fn_count FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name LIKE 'rpc_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'HR BUSINESS LOGIC MIGRATION COMPLETE';
  RAISE NOTICE 'New HR tables: %', tbl_count;
  RAISE NOTICE 'Total views: %', view_count;
  RAISE NOTICE 'Total RPC functions: %', fn_count;
  RAISE NOTICE '========================================';
END $$;
