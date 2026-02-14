-- ============================================================================
-- MIGRATION 009: Row Level Security Policies & Cross-System Integration
-- Date:       2026-02-14
-- Purpose:    1. Enable RLS on all HR tables with role-based access
--             2. Add cross-system triggers (HR ↔ Loans integration)
--             3. Add notification queue for workflow events
--             4. Add audit trail for sensitive HR operations
-- Strategy:   Idempotent — uses IF NOT EXISTS and DROP...IF EXISTS
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: ROW LEVEL SECURITY — HR Tables
-- ═══════════════════════════════════════════════════════════════════════

-- ── A1. Reference/lookup tables (read by authenticated, write by service) ──

ALTER TABLE public.tax_brackets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.statutory_deductions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tax_brackets_read ON public.tax_brackets;
CREATE POLICY tax_brackets_read ON public.tax_brackets
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS tax_brackets_admin ON public.tax_brackets;
CREATE POLICY tax_brackets_admin ON public.tax_brackets
  FOR ALL USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS statutory_deductions_read ON public.statutory_deductions;
CREATE POLICY statutory_deductions_read ON public.statutory_deductions
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS statutory_deductions_admin ON public.statutory_deductions;
CREATE POLICY statutory_deductions_admin ON public.statutory_deductions
  FOR ALL USING (auth.role() = 'service_role');

-- ── A2. Salary structures (own + manager read, service write) ──────────

ALTER TABLE public.salary_structures ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS salary_structures_own ON public.salary_structures;
CREATE POLICY salary_structures_own ON public.salary_structures
  FOR SELECT USING (
    employee_id IN (
      SELECT id FROM public.employees WHERE user_id = auth.uid()
    )
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS salary_structures_admin ON public.salary_structures;
CREATE POLICY salary_structures_admin ON public.salary_structures
  FOR ALL USING (auth.role() = 'service_role');

-- ── A3. Payroll runs (managers read, service write) ────────────────────

ALTER TABLE public.payroll_runs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payroll_runs_read ON public.payroll_runs;
CREATE POLICY payroll_runs_read ON public.payroll_runs
  FOR SELECT USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance', 'manager')
    )
  );

DROP POLICY IF EXISTS payroll_runs_admin ON public.payroll_runs;
CREATE POLICY payroll_runs_admin ON public.payroll_runs
  FOR ALL USING (auth.role() = 'service_role');

-- ── A4. Payslips (own payslips + HR/finance read, service write) ───────

ALTER TABLE public.payslips ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payslips_own ON public.payslips;
CREATE POLICY payslips_own ON public.payslips
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

DROP POLICY IF EXISTS payslips_admin ON public.payslips;
CREATE POLICY payslips_admin ON public.payslips
  FOR ALL USING (auth.role() = 'service_role');

-- ── A5. Payslip deductions (same as payslips) ─────────────────────────

ALTER TABLE public.payslip_deductions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payslip_deductions_own ON public.payslip_deductions;
CREATE POLICY payslip_deductions_own ON public.payslip_deductions
  FOR SELECT USING (
    payslip_id IN (
      SELECT ps.id FROM public.payslips ps
      JOIN public.employees e ON e.id = ps.employee_id
      WHERE e.user_id = auth.uid()
    )
    OR auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager', 'finance')
    )
  );

DROP POLICY IF EXISTS payslip_deductions_admin ON public.payslip_deductions;
CREATE POLICY payslip_deductions_admin ON public.payslip_deductions
  FOR ALL USING (auth.role() = 'service_role');

-- ── A6. Staff salary loans (own + HR read, service write) ─────────────

ALTER TABLE public.staff_salary_loans ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS salary_loans_own ON public.staff_salary_loans;
CREATE POLICY salary_loans_own ON public.staff_salary_loans
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

DROP POLICY IF EXISTS salary_loans_admin ON public.staff_salary_loans;
CREATE POLICY salary_loans_admin ON public.staff_salary_loans
  FOR ALL USING (auth.role() = 'service_role');

-- ── A7. Leave types (public read) ─────────────────────────────────────

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leave_types' AND table_schema = 'public') THEN
    ALTER TABLE public.leave_types ENABLE ROW LEVEL SECURITY;

    DROP POLICY IF EXISTS leave_types_read ON public.leave_types;
    CREATE POLICY leave_types_read ON public.leave_types
      FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

    DROP POLICY IF EXISTS leave_types_admin ON public.leave_types;
    CREATE POLICY leave_types_admin ON public.leave_types
      FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;

-- ── A8. Leave requests (own + manager + HR, service write) ────────────

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leave_requests' AND table_schema = 'public') THEN
    ALTER TABLE public.leave_requests ENABLE ROW LEVEL SECURITY;

    DROP POLICY IF EXISTS leave_requests_own ON public.leave_requests;
    CREATE POLICY leave_requests_own ON public.leave_requests
      FOR SELECT USING (
        user_id = auth.uid()
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Staff can insert their own leave requests
    DROP POLICY IF EXISTS leave_requests_insert ON public.leave_requests;
    CREATE POLICY leave_requests_insert ON public.leave_requests
      FOR INSERT WITH CHECK (
        user_id = auth.uid()
        OR auth.role() = 'service_role'
      );

    DROP POLICY IF EXISTS leave_requests_admin ON public.leave_requests;
    CREATE POLICY leave_requests_admin ON public.leave_requests
      FOR UPDATE USING (auth.role() = 'service_role');

    DROP POLICY IF EXISTS leave_requests_delete ON public.leave_requests;
    CREATE POLICY leave_requests_delete ON public.leave_requests
      FOR DELETE USING (auth.role() = 'service_role');
  END IF;
END $$;

-- ── A9. Leave balances (own read, service write) ──────────────────────

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leave_balances' AND table_schema = 'public') THEN
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
  END IF;
END $$;

-- ── A10. Attendance records (own + manager, service write) ────────────

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'attendance_records' AND table_schema = 'public') THEN
    ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

    DROP POLICY IF EXISTS attendance_own ON public.attendance_records;
    CREATE POLICY attendance_own ON public.attendance_records
      FOR SELECT USING (
        staff_id IN (
          SELECT s.id FROM public.staff s WHERE s.user_id = auth.uid()
        )
        OR auth.role() = 'service_role'
        OR EXISTS (
          SELECT 1 FROM public.employees e
          WHERE e.user_id = auth.uid()
            AND e.role IN ('admin', 'hr_manager', 'manager')
        )
      );

    -- Staff can insert their own clock-in records
    DROP POLICY IF EXISTS attendance_insert ON public.attendance_records;
    CREATE POLICY attendance_insert ON public.attendance_records
      FOR INSERT WITH CHECK (
        staff_id IN (
          SELECT s.id FROM public.staff s WHERE s.user_id = auth.uid()
        )
        OR auth.role() = 'service_role'
      );

    DROP POLICY IF EXISTS attendance_admin ON public.attendance_records;
    CREATE POLICY attendance_admin ON public.attendance_records
      FOR UPDATE USING (auth.role() = 'service_role');
  END IF;
END $$;

-- ── A11. Performance review cycles (all authenticated read, service write) ─

ALTER TABLE public.performance_review_cycles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS perf_cycles_read ON public.performance_review_cycles;
CREATE POLICY perf_cycles_read ON public.performance_review_cycles
  FOR SELECT USING (auth.role() IN ('authenticated', 'service_role'));

DROP POLICY IF EXISTS perf_cycles_admin ON public.performance_review_cycles;
CREATE POLICY perf_cycles_admin ON public.performance_review_cycles
  FOR ALL USING (auth.role() = 'service_role');

-- ── A12. Performance reviews (own + reviewer + HR, service write) ──────

ALTER TABLE public.performance_reviews ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS perf_reviews_own ON public.performance_reviews;
CREATE POLICY perf_reviews_own ON public.performance_reviews
  FOR SELECT USING (
    employee_id IN (
      SELECT id FROM public.employees WHERE user_id = auth.uid()
    )
    OR reviewer_id IN (
      SELECT id FROM public.employees WHERE user_id = auth.uid()
    )
    OR auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager')
    )
  );

DROP POLICY IF EXISTS perf_reviews_admin ON public.performance_reviews;
CREATE POLICY perf_reviews_admin ON public.performance_reviews
  FOR ALL USING (auth.role() = 'service_role');

-- ── A13. Performance goals (own + reviewer read) ──────────────────────

ALTER TABLE public.performance_goals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS perf_goals_own ON public.performance_goals;
CREATE POLICY perf_goals_own ON public.performance_goals
  FOR SELECT USING (
    review_id IN (
      SELECT pr.id FROM public.performance_reviews pr
      JOIN public.employees e ON e.id = pr.employee_id
      WHERE e.user_id = auth.uid()
    )
    OR review_id IN (
      SELECT pr.id FROM public.performance_reviews pr
      WHERE pr.reviewer_id IN (
        SELECT id FROM public.employees WHERE user_id = auth.uid()
      )
    )
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS perf_goals_admin ON public.performance_goals;
CREATE POLICY perf_goals_admin ON public.performance_goals
  FOR ALL USING (auth.role() = 'service_role');

-- ── A14. Scheduled task runs (service only) ───────────────────────────

ALTER TABLE public.scheduled_task_runs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS scheduled_tasks_admin ON public.scheduled_task_runs;
CREATE POLICY scheduled_tasks_admin ON public.scheduled_task_runs
  FOR ALL USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS scheduled_tasks_read ON public.scheduled_task_runs;
CREATE POLICY scheduled_tasks_read ON public.scheduled_task_runs
  FOR SELECT USING (
    auth.role() = 'service_role'
    OR EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager')
    )
  );

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: CROSS-SYSTEM INTEGRATION — HR ↔ Loan Performance
-- ═══════════════════════════════════════════════════════════════════════

-- B1. Auto-update loan officer KPIs when loan status changes
CREATE OR REPLACE FUNCTION public.trg_loan_status_update_officer_kpi()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_officer_employee_id uuid;
BEGIN
  -- Find the employee record for this loan officer
  SELECT e.id INTO v_officer_employee_id
  FROM public.employees e
  WHERE (e.full_name = NEW.loan_officer_name OR e.employee_code = NEW.loan_officer_name)
    AND (e.status = 'active' OR e.employment_status = 'active')
  LIMIT 1;

  IF v_officer_employee_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Only trigger on meaningful status changes
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Update officer's performance snapshot (if table exists)
    IF EXISTS (SELECT 1 FROM information_schema.tables
               WHERE table_name = 'staff_performance_monthly' AND table_schema = 'public') THEN
      INSERT INTO public.staff_performance_monthly (
        staff_id, month, year,
        total_loans_managed, total_disbursed, total_collected,
        active_loans, overdue_loans
      )
      SELECT
        v_officer_employee_id,
        extract(month FROM current_date)::int,
        extract(year FROM current_date)::int,
        count(*),
        coalesce(sum(l.amount_principal), 0),
        coalesce(sum(l.total_repaid), 0),
        count(*) FILTER (WHERE l.status = 'active'),
        count(*) FILTER (WHERE l.in_arrears = true)
      FROM public.loans l
      WHERE (l.loan_officer_name IN (
        SELECT e2.full_name FROM public.employees e2 WHERE e2.id = v_officer_employee_id
      ))
      ON CONFLICT (staff_id, month, year) DO UPDATE SET
        total_loans_managed = EXCLUDED.total_loans_managed,
        total_disbursed = EXCLUDED.total_disbursed,
        total_collected = EXCLUDED.total_collected,
        active_loans = EXCLUDED.active_loans,
        overdue_loans = EXCLUDED.overdue_loans,
        updated_at = now();
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Attach trigger (only if loans table exists)
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'loans' AND table_schema = 'public') THEN
    DROP TRIGGER IF EXISTS trg_loan_officer_kpi ON public.loans;
    CREATE TRIGGER trg_loan_officer_kpi
      AFTER UPDATE ON public.loans
      FOR EACH ROW
      WHEN (OLD.status IS DISTINCT FROM NEW.status)
      EXECUTE FUNCTION public.trg_loan_status_update_officer_kpi();
  END IF;
END $$;

-- B2. Staff loan deduction sync — when salary loan approved, ensure
--     it appears in next payroll automatically
CREATE OR REPLACE FUNCTION public.trg_salary_loan_approved()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'active' AND (OLD.status IS NULL OR OLD.status = 'pending') THEN
    -- Notify via event (can be consumed by external systems)
    PERFORM pg_notify('hr_events', jsonb_build_object(
      'event', 'salary_loan_approved',
      'employee_id', NEW.employee_id,
      'loan_amount', NEW.loan_amount,
      'monthly_deduction', NEW.monthly_deduction,
      'loan_id', NEW.id
    )::text);
  END IF;

  IF NEW.status = 'completed' AND OLD.status = 'active' THEN
    PERFORM pg_notify('hr_events', jsonb_build_object(
      'event', 'salary_loan_completed',
      'employee_id', NEW.employee_id,
      'loan_id', NEW.id
    )::text);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_salary_loan_status ON public.staff_salary_loans;
CREATE TRIGGER trg_salary_loan_status
  AFTER UPDATE ON public.staff_salary_loans
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_salary_loan_approved();

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: NOTIFICATION QUEUE — Workflow Event Log
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.hr_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_user_id uuid, -- target user
  recipient_role text,     -- or target role (hr_manager, admin)
  event_type text NOT NULL, -- leave_submitted, payroll_ready, review_due, etc.
  title text NOT NULL,
  body text,
  metadata jsonb DEFAULT '{}',
  is_read boolean NOT NULL DEFAULT false,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_hr_notifications_user
  ON public.hr_notifications (recipient_user_id, is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_hr_notifications_role
  ON public.hr_notifications (recipient_role, is_read, created_at DESC);

ALTER TABLE public.hr_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notifications_own ON public.hr_notifications;
CREATE POLICY notifications_own ON public.hr_notifications
  FOR SELECT USING (
    recipient_user_id = auth.uid()
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS notifications_mark_read ON public.hr_notifications;
CREATE POLICY notifications_mark_read ON public.hr_notifications
  FOR UPDATE USING (
    recipient_user_id = auth.uid()
    OR auth.role() = 'service_role'
  )
  WITH CHECK (
    recipient_user_id = auth.uid()
    OR auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS notifications_admin ON public.hr_notifications;
CREATE POLICY notifications_admin ON public.hr_notifications
  FOR ALL USING (auth.role() = 'service_role');

GRANT SELECT, UPDATE ON public.hr_notifications TO authenticated;
GRANT ALL ON public.hr_notifications TO service_role;

-- C2. Helper: Send notification
CREATE OR REPLACE FUNCTION public.fn_send_notification(
  p_user_id uuid,
  p_role text,
  p_event_type text,
  p_title text,
  p_body text DEFAULT NULL,
  p_metadata jsonb DEFAULT '{}'
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.hr_notifications (recipient_user_id, recipient_role, event_type, title, body, metadata)
  VALUES (p_user_id, p_role, p_event_type, p_title, p_body, p_metadata)
  RETURNING id INTO v_id;

  -- Also push via pg_notify for real-time
  PERFORM pg_notify('hr_notifications', jsonb_build_object(
    'id', v_id,
    'user_id', p_user_id,
    'role', p_role,
    'event_type', p_event_type,
    'title', p_title
  )::text);

  RETURN v_id;
END;
$$;

-- C3. Auto-notify on leave request status change
CREATE OR REPLACE FUNCTION public.trg_leave_request_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'pending' THEN
    -- Notify managers about new leave request
    PERFORM public.fn_send_notification(
      NULL, 'hr_manager', 'leave_submitted',
      'New Leave Request',
      format('%s submitted a leave request (%s - %s)',
        coalesce(NEW.reason, 'Leave'), NEW.start_date::text, NEW.end_date::text),
      jsonb_build_object('request_id', NEW.id, 'user_id', NEW.user_id)
    );
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status = 'approved' THEN
    PERFORM public.fn_send_notification(
      NEW.user_id, NULL, 'leave_approved',
      'Leave Request Approved',
      format('Your leave from %s to %s has been approved', NEW.start_date::text, NEW.end_date::text),
      jsonb_build_object('request_id', NEW.id)
    );
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.status = 'pending' AND NEW.status = 'rejected' THEN
    PERFORM public.fn_send_notification(
      NEW.user_id, NULL, 'leave_rejected',
      'Leave Request Rejected',
      format('Your leave from %s to %s was not approved', NEW.start_date::text, NEW.end_date::text),
      jsonb_build_object('request_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$;

DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_name = 'leave_requests' AND table_schema = 'public') THEN
    DROP TRIGGER IF EXISTS trg_leave_notify ON public.leave_requests;
    CREATE TRIGGER trg_leave_notify
      AFTER INSERT OR UPDATE ON public.leave_requests
      FOR EACH ROW
      EXECUTE FUNCTION public.trg_leave_request_notify();
  END IF;
END $$;

-- C4. Auto-notify on payroll status change
CREATE OR REPLACE FUNCTION public.trg_payroll_run_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'approved' AND (OLD.status IS NULL OR OLD.status != 'approved') THEN
    PERFORM public.fn_send_notification(
      NULL, 'finance', 'payroll_approved',
      format('Payroll Approved: %s', NEW.month),
      format('Payroll for %s has been approved and is ready for payment', NEW.month),
      jsonb_build_object('payroll_run_id', NEW.id)
    );
  END IF;

  IF NEW.status = 'paid' AND OLD.status != 'paid' THEN
    PERFORM public.fn_send_notification(
      NULL, 'admin', 'payroll_paid',
      format('Payroll Paid: %s', NEW.month),
      format('All salaries for %s have been disbursed', NEW.month),
      jsonb_build_object('payroll_run_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_payroll_notify ON public.payroll_runs;
CREATE TRIGGER trg_payroll_notify
  AFTER UPDATE ON public.payroll_runs
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_payroll_run_notify();

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: AUDIT TRAIL — Sensitive HR Operations
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.hr_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text NOT NULL,
  record_id uuid,
  action text NOT NULL, -- INSERT, UPDATE, DELETE
  old_values jsonb,
  new_values jsonb,
  changed_fields text[],
  performed_by uuid, -- user who made the change
  performed_at timestamptz NOT NULL DEFAULT now(),
  ip_address text,
  user_agent text
);

CREATE INDEX IF NOT EXISTS idx_hr_audit_table_date
  ON public.hr_audit_log (table_name, performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_hr_audit_record
  ON public.hr_audit_log (record_id, performed_at DESC);

ALTER TABLE public.hr_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS audit_log_admin ON public.hr_audit_log;
CREATE POLICY audit_log_admin ON public.hr_audit_log
  FOR ALL USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS audit_log_read ON public.hr_audit_log;
CREATE POLICY audit_log_read ON public.hr_audit_log
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.employees e
      WHERE e.user_id = auth.uid()
        AND e.role IN ('admin', 'hr_manager')
    )
  );

GRANT SELECT ON public.hr_audit_log TO authenticated;
GRANT ALL ON public.hr_audit_log TO service_role;

-- D2. Generic audit trigger function
CREATE OR REPLACE FUNCTION public.fn_hr_audit_trigger()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_old jsonb;
  v_new jsonb;
  v_changed text[];
  v_key text;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_old := to_jsonb(OLD);
    INSERT INTO public.hr_audit_log (table_name, record_id, action, old_values, performed_by)
    VALUES (TG_TABLE_NAME, (v_old->>'id')::uuid, 'DELETE', v_old, auth.uid());
    RETURN OLD;
  END IF;

  IF TG_OP = 'INSERT' THEN
    v_new := to_jsonb(NEW);
    INSERT INTO public.hr_audit_log (table_name, record_id, action, new_values, performed_by)
    VALUES (TG_TABLE_NAME, (v_new->>'id')::uuid, 'INSERT', v_new, auth.uid());
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);

    -- Find changed fields
    FOR v_key IN SELECT jsonb_object_keys(v_new)
    LOOP
      IF v_old->v_key IS DISTINCT FROM v_new->v_key THEN
        v_changed := array_append(v_changed, v_key);
      END IF;
    END LOOP;

    -- Only log if something actually changed
    IF v_changed IS NOT NULL AND array_length(v_changed, 1) > 0 THEN
      INSERT INTO public.hr_audit_log (
        table_name, record_id, action, old_values, new_values, changed_fields, performed_by
      )
      VALUES (TG_TABLE_NAME, (v_new->>'id')::uuid, 'UPDATE', v_old, v_new, v_changed, auth.uid());
    END IF;

    RETURN NEW;
  END IF;

  RETURN NULL;
END;
$$;

-- Attach audit triggers to sensitive tables
DO $$ BEGIN
  -- Salary changes
  DROP TRIGGER IF EXISTS trg_audit_salary_structures ON public.salary_structures;
  CREATE TRIGGER trg_audit_salary_structures
    AFTER INSERT OR UPDATE OR DELETE ON public.salary_structures
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();

  -- Payslip changes
  DROP TRIGGER IF EXISTS trg_audit_payslips ON public.payslips;
  CREATE TRIGGER trg_audit_payslips
    AFTER INSERT OR UPDATE OR DELETE ON public.payslips
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();

  -- Salary loan changes
  DROP TRIGGER IF EXISTS trg_audit_salary_loans ON public.staff_salary_loans;
  CREATE TRIGGER trg_audit_salary_loans
    AFTER INSERT OR UPDATE OR DELETE ON public.staff_salary_loans
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();

  -- Performance review changes
  DROP TRIGGER IF EXISTS trg_audit_performance_reviews ON public.performance_reviews;
  CREATE TRIGGER trg_audit_performance_reviews
    AFTER INSERT OR UPDATE OR DELETE ON public.performance_reviews
    FOR EACH ROW EXECUTE FUNCTION public.fn_hr_audit_trigger();
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: RPC — Notification Queries
-- ═══════════════════════════════════════════════════════════════════════

-- Get unread notification count
CREATE OR REPLACE FUNCTION public.rpc_unread_notification_count()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_count int;
  v_user_id uuid := auth.uid();
  v_role text;
BEGIN
  -- Get user's role
  SELECT e.role INTO v_role
  FROM public.employees e
  WHERE e.user_id = v_user_id
  LIMIT 1;

  SELECT count(*) INTO v_count
  FROM public.hr_notifications
  WHERE is_read = false
    AND (recipient_user_id = v_user_id OR recipient_role = v_role);

  RETURN jsonb_build_object('count', v_count);
END;
$$;

-- Mark notifications as read
CREATE OR REPLACE FUNCTION public.rpc_mark_notifications_read(p_notification_ids uuid[])
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_updated int;
BEGIN
  UPDATE public.hr_notifications SET
    is_read = true,
    read_at = now()
  WHERE id = ANY(p_notification_ids)
    AND (recipient_user_id = auth.uid() OR auth.role() = 'service_role');

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  RETURN jsonb_build_object('success', true, 'marked_read', v_updated);
END;
$$;

-- Get notifications with pagination
CREATE OR REPLACE FUNCTION public.rpc_get_notifications(
  p_limit int DEFAULT 20,
  p_offset int DEFAULT 0,
  p_unread_only boolean DEFAULT false
) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_role text;
  v_result jsonb;
BEGIN
  SELECT e.role INTO v_role
  FROM public.employees e WHERE e.user_id = v_user_id LIMIT 1;

  SELECT jsonb_agg(n ORDER BY n.created_at DESC) INTO v_result
  FROM (
    SELECT id, event_type, title, body, metadata, is_read, created_at
    FROM public.hr_notifications
    WHERE (recipient_user_id = v_user_id OR recipient_role = v_role)
      AND (NOT p_unread_only OR is_read = false)
    ORDER BY created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) n;

  RETURN jsonb_build_object(
    'success', true,
    'notifications', coalesce(v_result, '[]'::jsonb)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.rpc_unread_notification_count TO authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_mark_notifications_read TO authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_get_notifications TO authenticated;

-- ═══════════════════════════════════════════════════════════════════════
-- PART F: GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════════

GRANT EXECUTE ON FUNCTION public.fn_send_notification TO service_role;
GRANT EXECUTE ON FUNCTION public.fn_hr_audit_trigger TO service_role;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
  v_rls_count int;
  v_policy_count int;
  v_trigger_count int;
  v_notification_tbl boolean;
  v_audit_tbl boolean;
BEGIN
  SELECT count(*) INTO v_rls_count
  FROM pg_tables WHERE schemaname = 'public' AND tablename IN (
    SELECT c.relname FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relrowsecurity = true
  );

  SELECT count(*) INTO v_policy_count
  FROM pg_policies WHERE schemaname = 'public';

  SELECT count(*) INTO v_trigger_count
  FROM pg_trigger WHERE tgname LIKE 'trg_%';

  v_notification_tbl := EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'hr_notifications');
  v_audit_tbl := EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'hr_audit_log');

  RAISE NOTICE '========================================';
  RAISE NOTICE 'RLS & INTEGRATION MIGRATION COMPLETE';
  RAISE NOTICE 'Tables with RLS: %', v_rls_count;
  RAISE NOTICE 'Total policies: %', v_policy_count;
  RAISE NOTICE 'Total triggers: %', v_trigger_count;
  RAISE NOTICE 'Notification table: %', v_notification_tbl;
  RAISE NOTICE 'Audit log table: %', v_audit_tbl;
  RAISE NOTICE '========================================';
END $$;
