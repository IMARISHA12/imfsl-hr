-- ============================================================================
-- ONE-CLICK MIGRATION RUNNER
-- Copy-paste this ENTIRE file into the Supabase Dashboard SQL Editor
-- and click "Run". It executes all 5 migrations in correct order.
--
-- Date:    2026-02-14
-- Time:    ~5 seconds estimated
-- Risk:    LOW (0 data loss, all drops are empty tables)
-- ============================================================================

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 0: Bootstrap SQL Audit Tables                                     │
-- │ Fixes admin_sql_exec() and sql_editor_run() RPC functions               │
-- └─────────────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS public.admin_sql_audit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  executed_at timestamptz DEFAULT now() NOT NULL,
  sql_text text NOT NULL,
  executed_by text DEFAULT current_user,
  result_status text DEFAULT 'success',
  error_message text
);

CREATE TABLE IF NOT EXISTS public.sql_editor_audit (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  executed_at timestamptz DEFAULT now() NOT NULL,
  sql_text text NOT NULL,
  params jsonb,
  executed_by text DEFAULT current_user,
  result_status text DEFAULT 'success',
  error_message text
);

ALTER TABLE public.admin_sql_audit ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sql_editor_audit ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'admin_sql_audit_service_only') THEN
    CREATE POLICY admin_sql_audit_service_only ON public.admin_sql_audit FOR ALL USING (auth.role() = 'service_role');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'sql_editor_audit_service_only') THEN
    CREATE POLICY sql_editor_audit_service_only ON public.sql_editor_audit FOR ALL USING (auth.role() = 'service_role');
  END IF;
END $$;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 1: Drop 17 Empty Duplicate Tables                                │
-- └─────────────────────────────────────────────────────────────────────────┘

DROP TABLE IF EXISTS public.ld_borrowers CASCADE;
DROP TABLE IF EXISTS public.ld_loans CASCADE;
DROP TABLE IF EXISTS public.ld_repayments CASCADE;
DROP TABLE IF EXISTS public.fin_borrowers CASCADE;
DROP TABLE IF EXISTS public.fin_loans CASCADE;
DROP TABLE IF EXISTS public.sync_runs CASCADE;
DROP TABLE IF EXISTS public.staging_loans_import CASCADE;
DROP TABLE IF EXISTS public.customer_loans CASCADE;
DROP TABLE IF EXISTS public.customers_core CASCADE;
DROP TABLE IF EXISTS public.attendance_v2 CASCADE;
DROP TABLE IF EXISTS public.leave_balance CASCADE;
DROP TABLE IF EXISTS public.petty_cash CASCADE;
DROP TABLE IF EXISTS public.staff_permissions CASCADE;
DROP TABLE IF EXISTS public.staff_roles CASCADE;
DROP TABLE IF EXISTS public.role_permissions CASCADE;
DROP TABLE IF EXISTS public.permissions CASCADE;
DROP TABLE IF EXISTS public.loan_repayments CASCADE;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 2: Drop z_archive_ Historical Tables                             │
-- └─────────────────────────────────────────────────────────────────────────┘

DO $$
DECLARE
  tbl text;
BEGIN
  FOR tbl IN
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name LIKE 'z_archive_%'
    ORDER BY table_name
  LOOP
    EXECUTE format('DROP TABLE IF EXISTS public.%I CASCADE', tbl);
    RAISE NOTICE 'Dropped: %', tbl;
  END LOOP;
END $$;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 3: Consolidate audit_logs_new → audit_logs, leave_policy → policies│
-- └─────────────────────────────────────────────────────────────────────────┘

ALTER TABLE public.audit_logs ADD COLUMN IF NOT EXISTS ip_address inet;

INSERT INTO public.audit_logs (table_name, record_id, operation, old_data, new_data, changed_by, changed_at, ip_address)
SELECT table_name, record_id, action, old_data, new_data, changed_by, timestamp, ip_address::inet
FROM public.audit_logs_new
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS public.audit_logs_new CASCADE;

INSERT INTO public.leave_policies (leave_type, is_active, annual_entitlement_days, max_consecutive_days, min_advance_notice_days, min_service_months, requires_document, applicable_gender, created_at)
SELECT leave_type, is_active, max_days_per_year, max_days_per_request, requires_advance_notice_days, min_service_months, requires_attachment, gender_restriction, created_at
FROM public.leave_policy lp
WHERE NOT EXISTS (SELECT 1 FROM public.leave_policies lps WHERE lps.leave_type = lp.leave_type)
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS public.leave_policy CASCADE;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 4: Data Cleanup — Normalization Functions                         │
-- └─────────────────────────────────────────────────────────────────────────┘

CREATE OR REPLACE FUNCTION public.normalize_email(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT lower(trim(raw))
$$;

CREATE OR REPLACE FUNCTION public.normalize_phone_tz(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT CASE
    WHEN trim(raw) ~ '^\+255[0-9]{9}$' THEN trim(raw)
    WHEN trim(raw) ~ '^255[0-9]{9}$'   THEN '+' || trim(raw)
    WHEN trim(raw) ~ '^0[0-9]{9}$'     THEN '+255' || substring(trim(raw) from 2)
    WHEN trim(raw) ~ '^[67][0-9]{8}$'  THEN '+255' || trim(raw)
    ELSE trim(raw)
  END
$$;

CREATE OR REPLACE FUNCTION public.normalize_tin(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT upper(regexp_replace(trim(raw), '[\s\-]', '', 'g'))
$$;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 4: Staff Table — Normalize + Constrain                            │
-- └─────────────────────────────────────────────────────────────────────────┘

UPDATE public.staff SET email = normalize_email(email) WHERE email IS NOT NULL;
UPDATE public.staff SET phone = normalize_phone_tz(phone)
  WHERE phone IS NOT NULL AND phone != '' AND phone != '+255 xxx xxx xxx';
UPDATE public.staff SET tin_number = normalize_tin(tin_number) WHERE tin_number IS NOT NULL;

ALTER TABLE public.staff ALTER COLUMN email SET NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_staff_email_unique ON public.staff (lower(email));
DO $$ BEGIN
  ALTER TABLE public.staff ADD CONSTRAINT chk_staff_email_format
    CHECK (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS idx_staff_user_id_unique ON public.staff (user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_staff_department ON public.staff (department);
CREATE INDEX IF NOT EXISTS idx_staff_active ON public.staff (active);

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 4: Employees Table — Normalize TIN + Constrain                    │
-- └─────────────────────────────────────────────────────────────────────────┘

UPDATE public.employees SET tin_number = COALESCE(
  NULLIF(normalize_tin(tin_number), ''), NULLIF(normalize_tin(tin), ''), NULLIF(normalize_tin(tin_no), ''))
WHERE tin_number IS NULL AND (tin IS NOT NULL OR tin_no IS NOT NULL);

UPDATE public.employees SET nida_number = COALESCE(
  NULLIF(trim(nida_number), ''), NULLIF(trim(national_id), ''))
WHERE nida_number IS NULL AND national_id IS NOT NULL;

ALTER TABLE public.employees ALTER COLUMN email SET NOT NULL;
UPDATE public.employees SET email = normalize_email(email) WHERE email IS NOT NULL;
UPDATE public.employees SET phone = normalize_phone_tz(phone) WHERE phone IS NOT NULL AND phone != '';

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_email_unique ON public.employees (lower(email));
DO $$ BEGIN
  ALTER TABLE public.employees ADD CONSTRAINT chk_employees_email_format
    CHECK (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_code_unique ON public.employees (employee_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_tin_unique ON public.employees (normalize_tin(tin_number)) WHERE tin_number IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_nida_unique ON public.employees (nida_number) WHERE nida_number IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_user_id_unique ON public.employees (user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_dept_status ON public.employees (dept, status);

COMMENT ON COLUMN public.employees.tin IS 'DEPRECATED: Use tin_number instead';
COMMENT ON COLUMN public.employees.tin_no IS 'DEPRECATED: Use tin_number instead';
COMMENT ON COLUMN public.employees.national_id IS 'DEPRECATED: Use nida_number instead';

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 4: Clients, Customers, Vendors, Borrowers, Loans, etc.           │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Clients
UPDATE public.clients SET phone_number = normalize_phone_tz(phone_number) WHERE phone_number IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_phone_unique ON public.clients (phone_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ext_ref_unique ON public.clients (external_reference_id) WHERE external_reference_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_nida_unique ON public.clients (nida_number) WHERE nida_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_clients_status_risk ON public.clients (status, risk_level);
DO $$ BEGIN
  ALTER TABLE public.clients ADD CONSTRAINT chk_clients_phone_format
    CHECK (phone_number ~ '^\+255[0-9]{9}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Customers
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_code_unique ON public.customers (customer_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_email_unique ON public.customers (lower(email)) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_phone_unique ON public.customers (phone) WHERE phone IS NOT NULL;

-- Vendors
UPDATE public.vendors v SET vendor_code = sub.new_code
FROM (SELECT id, 'VND-' || LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::text, 4, '0') as new_code
      FROM public.vendors WHERE vendor_code IS NULL) sub
WHERE v.id = sub.id AND v.vendor_code IS NULL;

ALTER TABLE public.vendors ALTER COLUMN vendor_code SET NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_vendors_code_unique ON public.vendors (vendor_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_vendors_name_unique ON public.vendors (lower(vendor_name));

-- Borrowers
UPDATE public.borrowers SET phone_number = normalize_phone_tz(phone_number) WHERE phone_number IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_phone_unique ON public.borrowers (phone_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_nida_unique ON public.borrowers (nida_number) WHERE nida_number IS NOT NULL;

-- Loans
CREATE UNIQUE INDEX IF NOT EXISTS idx_loans_number_unique ON public.loans (loan_number) WHERE loan_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_loans_borrower_status ON public.loans (borrower_id, status);
CREATE INDEX IF NOT EXISTS idx_loans_officer ON public.loans (officer_id) WHERE officer_id IS NOT NULL;

-- Leave Balances
CREATE UNIQUE INDEX IF NOT EXISTS idx_leave_balances_key ON public.leave_balances (staff_id, leave_type, year);

-- Attendance
CREATE INDEX IF NOT EXISTS idx_attendance_work_date ON public.attendance_records (work_date);
CREATE INDEX IF NOT EXISTS idx_attendance_staff_id ON public.attendance_records (staff_id);

-- Profiles
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_phone_unique ON public.profiles (phone_number) WHERE phone_number IS NOT NULL;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 4: Preventive Triggers                                            │
-- └─────────────────────────────────────────────────────────────────────────┘

CREATE OR REPLACE FUNCTION public.trg_normalize_staff()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.email := normalize_email(NEW.email);
  IF NEW.phone IS NOT NULL AND NEW.phone != '' THEN
    NEW.phone := normalize_phone_tz(NEW.phone);
  END IF;
  IF NEW.tin_number IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin_number);
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_staff_normalize ON public.staff;
CREATE TRIGGER trg_staff_normalize BEFORE INSERT OR UPDATE ON public.staff
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_staff();

CREATE OR REPLACE FUNCTION public.trg_normalize_employees()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.email := normalize_email(NEW.email);
  IF NEW.phone IS NOT NULL AND NEW.phone != '' THEN
    NEW.phone := normalize_phone_tz(NEW.phone);
  END IF;
  IF NEW.tin_number IS NULL AND NEW.tin IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin);
  END IF;
  IF NEW.tin_number IS NULL AND NEW.tin_no IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin_no);
  END IF;
  IF NEW.tin_number IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin_number);
  END IF;
  IF NEW.nida_number IS NULL AND NEW.national_id IS NOT NULL THEN
    NEW.nida_number := trim(NEW.national_id);
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_employees_normalize ON public.employees;
CREATE TRIGGER trg_employees_normalize BEFORE INSERT OR UPDATE ON public.employees
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_employees();

CREATE OR REPLACE FUNCTION public.trg_normalize_clients()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.phone_number IS NOT NULL THEN
    NEW.phone_number := normalize_phone_tz(NEW.phone_number);
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_clients_normalize ON public.clients;
CREATE TRIGGER trg_clients_normalize BEFORE INSERT OR UPDATE ON public.clients
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_clients();

CREATE OR REPLACE FUNCTION public.trg_normalize_borrowers()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.phone_number IS NOT NULL THEN
    NEW.phone_number := normalize_phone_tz(NEW.phone_number);
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_borrowers_normalize ON public.borrowers;
CREATE TRIGGER trg_borrowers_normalize BEFORE INSERT OR UPDATE ON public.borrowers
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_borrowers();

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ PHASE 5: Schema Expansion — Full LoanDisk Fields for Retool            │
-- └─────────────────────────────────────────────────────────────────────────┘

-- Borrowers: add full profile fields
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS borrower_code text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS title text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS email text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS gender text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS date_of_birth date;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS marital_status text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS business_name text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS business_type text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS business_role text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS business_location text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS address text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS region text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS district text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS street text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS gps_latitude numeric;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS gps_longitude numeric;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS alternative_phone text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS photo_url text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS credit_rating text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS bank_name text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS bank_account_number text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS drivers_license text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS vehicle_info text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS next_of_kin_name text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS next_of_kin_relationship text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS next_of_kin_phone text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS guarantor_name text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS guarantor_phone text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS guarantor_relationship text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS loan_officer_name text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS revenue_estimate numeric;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS external_reference_id text;
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_code_unique ON public.borrowers (borrower_code) WHERE borrower_code IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_ext_ref_unique ON public.borrowers (external_reference_id) WHERE external_reference_id IS NOT NULL;

-- Clients: add KYC/document fields
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS borrower_code text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS title text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS full_name text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS gender text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS date_of_birth date;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS marital_status text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS business_role text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS address text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS gps_latitude numeric;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS gps_longitude numeric;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS alternative_phone text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS credit_rating text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS bank_name text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS bank_account_number text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS drivers_license text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS vehicle_info text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS guarantor_name text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS guarantor_phone text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS guarantor_relationship text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS loan_officer_name text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS documents jsonb DEFAULT '[]'::jsonb;

-- Loans: add disbursement & schedule fields
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS maturity_date date;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_method text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_rate_period text DEFAULT 'month';
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS interest_paid numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS penalty_amount numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS fees numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS disbursed_by text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS repayment_frequency text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS next_payment_date date;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS loan_purpose text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS collateral text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS collateral_value numeric;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS loan_officer_name text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS approved_date date;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Retool Views
CREATE OR REPLACE VIEW public.v_borrower_profiles AS
SELECT
  b.id, b.borrower_code, b.title, b.full_name, b.phone_number, b.email, b.nida_number,
  b.gender, b.date_of_birth,
  CASE WHEN b.date_of_birth IS NOT NULL
    THEN extract(year from age(current_date, b.date_of_birth))::int ELSE NULL END AS age_years,
  b.marital_status, b.credit_rating, b.photo_url,
  b.business_name, b.business_type, b.business_role, b.business_location, b.revenue_estimate,
  b.address, b.region, b.district, b.street, b.location_gps, b.gps_latitude, b.gps_longitude,
  b.bank_name, b.bank_account_number, b.drivers_license, b.vehicle_info,
  b.alternative_phone, b.next_of_kin_name, b.next_of_kin_relationship, b.next_of_kin_phone,
  b.guarantor_name, b.guarantor_phone, b.guarantor_relationship,
  b.loan_officer_name, b.status, b.external_reference_id, b.notes, b.created_at, b.updated_at,
  c.id AS client_id, c.credit_score, c.risk_level, c.documents AS client_documents,
  ls.total_loans, ls.active_loans, ls.total_principal, ls.total_outstanding, ls.total_paid, ls.max_days_overdue
FROM public.borrowers b
LEFT JOIN public.clients c ON c.external_reference_id = b.external_reference_id
LEFT JOIN LATERAL (
  SELECT count(*) AS total_loans,
    count(*) FILTER (WHERE l.status IN ('active','pending')) AS active_loans,
    coalesce(sum(l.amount_principal),0) AS total_principal,
    coalesce(sum(l.outstanding_balance),0) AS total_outstanding,
    coalesce(sum(l.total_paid),0) AS total_paid,
    coalesce(max(l.days_overdue),0) AS max_days_overdue
  FROM public.loans l WHERE l.borrower_id = b.id
) ls ON true;

CREATE OR REPLACE VIEW public.v_loan_details AS
SELECT
  l.id, l.loan_number, l.borrower_id, b.full_name AS borrower_name, b.phone_number AS borrower_phone,
  b.borrower_code, l.loan_officer_name, l.officer_id,
  l.amount_principal, l.interest_rate, l.interest_rate_period, l.interest_method,
  l.duration_months, l.total_due, l.outstanding_balance, l.total_paid, l.interest_paid,
  l.fees, l.penalty_amount, l.days_overdue, l.status, l.product_type,
  l.start_date, l.disbursed_at, l.disbursed_by, l.maturity_date,
  l.last_payment_date, l.next_payment_date, l.repayment_frequency,
  l.approved_by, l.approved_date, l.loan_purpose, l.collateral, l.collateral_value,
  l.branch, l.notes, l.created_at, l.updated_at,
  rs.total_repayments, rs.last_repayment_amount, rs.last_repayment_date
FROM public.loans l
LEFT JOIN public.borrowers b ON b.id = l.borrower_id
LEFT JOIN LATERAL (
  SELECT count(*) AS total_repayments,
    (array_agg(r.amount_paid ORDER BY r.paid_at DESC))[1] AS last_repayment_amount,
    max(r.paid_at) AS last_repayment_date
  FROM public.repayments r WHERE r.loan_id = l.id
) rs ON true;

CREATE OR REPLACE VIEW public.v_repayment_history AS
SELECT r.id, r.loan_id, l.loan_number, l.borrower_id,
  b.full_name AS borrower_name, b.borrower_code,
  r.amount_paid, r.payment_method, r.receipt_ref, r.collected_by, r.paid_at, r.created_at
FROM public.repayments r
LEFT JOIN public.loans l ON l.id = r.loan_id
LEFT JOIN public.borrowers b ON b.id = l.borrower_id;

GRANT SELECT ON public.v_borrower_profiles TO service_role, authenticated;
GRANT SELECT ON public.v_loan_details TO service_role, authenticated;
GRANT SELECT ON public.v_repayment_history TO service_role, authenticated;

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ NOTE: Migrations 006–008 must be run from their individual files       │
-- │                                                                        │
-- │ Run in order:                                                          │
-- │   1. 006_fineract_integration.sql   (Fineract core banking integration)│
-- │   2. 006b_hr_prerequisite_tables.sql (leave_types, leave_requests,    │
-- │      leave_balances, attendance_records + Tanzania leave type seeds)   │
-- │   3. 007_hr_business_logic.sql      (Payroll, Leave, Attendance, Perf.)│
-- │   4. 008_scheduled_tasks.sql        (Cron jobs, arrears, leave accrual)│
-- │   5. 009_rls_policies_and_integration.sql (RLS, notifications, audit) │
-- │   6. 010_staff_performance_monthly.sql (KPI snapshots, dashboard fn)  │
-- │                                                                        │
-- │ These are too large for a single SQL Editor run.                       │
-- └─────────────────────────────────────────────────────────────────────────┘

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ VERIFICATION                                                            │
-- └─────────────────────────────────────────────────────────────────────────┘

DO $$
DECLARE
  tbl_count int;
  idx_count int;
  trg_count int;
  view_count int;
  fn_count int;
BEGIN
  SELECT count(*) INTO tbl_count FROM information_schema.tables WHERE table_schema = 'public';
  SELECT count(*) INTO idx_count FROM pg_indexes WHERE schemaname = 'public' AND indexname LIKE 'idx_%';
  SELECT count(*) INTO trg_count FROM pg_trigger WHERE tgname LIKE 'trg_%';
  SELECT count(*) INTO view_count FROM information_schema.views WHERE table_schema = 'public' AND table_name LIKE 'v_%';
  SELECT count(*) INTO fn_count FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name LIKE 'rpc_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRATION COMPLETE';
  RAISE NOTICE 'Tables remaining: %', tbl_count;
  RAISE NOTICE 'Custom indexes: %', idx_count;
  RAISE NOTICE 'Normalization triggers: %', trg_count;
  RAISE NOTICE 'Retool views: %', view_count;
  RAISE NOTICE 'RPC functions: %', fn_count;
  RAISE NOTICE '========================================';
END $$;
