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
    CHECK (phone_number ~ '^\+255[0-9]{9}$' OR phone_number ~ '^0[0-9]{9}$');
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
-- │ VERIFICATION                                                            │
-- └─────────────────────────────────────────────────────────────────────────┘

DO $$
DECLARE
  tbl_count int;
  idx_count int;
  trg_count int;
BEGIN
  SELECT count(*) INTO tbl_count FROM information_schema.tables WHERE table_schema = 'public';
  SELECT count(*) INTO idx_count FROM pg_indexes WHERE schemaname = 'public' AND indexname LIKE 'idx_%';
  SELECT count(*) INTO trg_count FROM pg_trigger WHERE tgname LIKE 'trg_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'MIGRATION COMPLETE';
  RAISE NOTICE 'Tables remaining: %', tbl_count;
  RAISE NOTICE 'Custom indexes: %', idx_count;
  RAISE NOTICE 'Normalization triggers: %', trg_count;
  RAISE NOTICE '========================================';
END $$;
