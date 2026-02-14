-- ============================================================================
-- SEED 003: HR Master Data
-- Purpose: Populate reference/lookup tables for HR business logic
-- Includes: Tax brackets, statutory deductions, leave types, departments
-- Safe to re-run: Uses ON CONFLICT DO NOTHING
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- 1. TANZANIA PAYE TAX BRACKETS (2024/2025 Rates)
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO public.tax_brackets (bracket_name, min_amount, max_amount, rate_percent, fixed_amount, country_code)
VALUES
  ('Band 1: 0 - 270,000 TZS', 0, 270000, 0, 0, 'TZ'),
  ('Band 2: 270,001 - 520,000 TZS', 270000, 520000, 8, 0, 'TZ'),
  ('Band 3: 520,001 - 760,000 TZS', 520000, 760000, 20, 20000, 'TZ'),
  ('Band 4: 760,001 - 1,000,000 TZS', 760000, 1000000, 25, 68000, 'TZ'),
  ('Band 5: 1,000,001 - 1,500,000 TZS', 1000000, 1500000, 25, 128000, 'TZ'),
  ('Band 6: Above 1,500,000 TZS', 1500000, NULL, 30, 253000, 'TZ')
ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- 2. STATUTORY DEDUCTIONS (Tanzania)
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO public.statutory_deductions (deduction_code, deduction_name, employee_rate_percent, employer_rate_percent, is_mandatory)
VALUES
  ('NSSF', 'National Social Security Fund', 10.0, 10.0, true),
  ('WCF', 'Workers Compensation Fund', 0.0, 1.0, true),
  ('SDL', 'Skills Development Levy', 0.0, 4.5, true),
  ('HESLB', 'Higher Education Student Loans Board', 0.0, 0.0, false),
  ('PPF', 'Public Service Pensions Fund', 5.0, 15.0, false),
  ('NHIF', 'National Health Insurance Fund', 3.0, 3.0, false)
ON CONFLICT (deduction_code) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- 3. LEAVE TYPES (Tanzania Labor Law + IMFSL Policy)
-- ═══════════════════════════════════════════════════════════════════════

-- Ensure leave_types has data (may already exist from earlier migrations)
INSERT INTO public.leave_types (leave_type, annual_entitlement_days, max_consecutive_days, min_advance_notice_days, min_service_months, requires_document, applicable_gender, is_active)
VALUES
  ('Annual Leave', 28, 14, 14, 0, false, 'all', true),
  ('Sick Leave', 126, 63, 0, 0, true, 'all', true),
  ('Maternity Leave', 84, 84, 30, 6, true, 'Female', true),
  ('Paternity Leave', 3, 3, 7, 6, true, 'Male', true),
  ('Compassionate Leave', 4, 4, 0, 0, false, 'all', true),
  ('Study Leave', 10, 5, 14, 12, true, 'all', true),
  ('Unpaid Leave', 30, 30, 14, 6, false, 'all', true)
ON CONFLICT DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════════
-- 4. SAMPLE SALARY STRUCTURES (for existing employees)
-- ═══════════════════════════════════════════════════════════════════════

-- Only insert if salary_structures table is empty (first-time seed)
INSERT INTO public.salary_structures (employee_id, basic_salary, housing_allowance, transport_allowance, meal_allowance, medical_allowance, communication_allowance, is_current)
SELECT
  e.id,
  coalesce(e.salary, 500000), -- use existing salary or default
  round(coalesce(e.salary, 500000) * 0.15, 0), -- 15% housing
  100000, -- flat transport
  50000,  -- flat meals
  round(coalesce(e.salary, 500000) * 0.05, 0), -- 5% medical
  30000,  -- flat communication
  true
FROM public.employees e
WHERE (e.status = 'active' OR e.employment_status = 'active')
  AND NOT EXISTS (
    SELECT 1 FROM public.salary_structures ss WHERE ss.employee_id = e.id AND ss.is_current = true
  );

-- ═══════════════════════════════════════════════════════════════════════
-- 5. DEFAULT PERFORMANCE REVIEW CYCLE (Q1 2026)
-- ═══════════════════════════════════════════════════════════════════════

INSERT INTO public.performance_review_cycles (cycle_name, cycle_type, period_start, period_end, review_deadline, status, created_by)
SELECT 'Q1 2026 Performance Review', 'quarterly', '2026-01-01', '2026-03-31', '2026-04-15', 'draft', 'system'
WHERE NOT EXISTS (
  SELECT 1 FROM public.performance_review_cycles WHERE cycle_name = 'Q1 2026 Performance Review'
);

-- ═══════════════════════════════════════════════════════════════════════
-- VERIFICATION
-- ═══════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_tax int;
  v_ded int;
  v_leave int;
  v_salary int;
BEGIN
  SELECT count(*) INTO v_tax FROM public.tax_brackets WHERE country_code = 'TZ';
  SELECT count(*) INTO v_ded FROM public.statutory_deductions;
  SELECT count(*) INTO v_leave FROM public.leave_types WHERE is_active = true;
  SELECT count(*) INTO v_salary FROM public.salary_structures WHERE is_current = true;

  RAISE NOTICE '========================================';
  RAISE NOTICE 'HR MASTER DATA SEED COMPLETE';
  RAISE NOTICE 'Tax brackets: %', v_tax;
  RAISE NOTICE 'Statutory deductions: %', v_ded;
  RAISE NOTICE 'Leave types: %', v_leave;
  RAISE NOTICE 'Salary structures: %', v_salary;
  RAISE NOTICE '========================================';
END $$;
