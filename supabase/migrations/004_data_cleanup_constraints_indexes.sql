-- ============================================================================
-- MIGRATION 004: Professional Data Cleanup — Constraints, Indexes, Normalization
-- Date:       2026-02-13
-- Reference:  docs/DUPLICATE_TABLE_AUDIT.md
-- Scope:      staff, employees, clients, customers, vendors, attendance,
--             borrowers, loans, leave_balances, profiles
-- Strategy:   Zero data loss. Normalize → Deduplicate → Constrain → Index
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: NORMALIZATION FUNCTIONS (reusable)
-- ═══════════════════════════════════════════════════════════════════════

-- Email normalization: lower + trim
CREATE OR REPLACE FUNCTION public.normalize_email(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT lower(trim(raw))
$$;

-- Phone normalization: Tanzania E.164 (+255xxxxxxxxx)
-- Handles: 0712xxx, +255712xxx, 255712xxx, 712xxx
CREATE OR REPLACE FUNCTION public.normalize_phone_tz(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT CASE
    WHEN trim(raw) ~ '^\+255[0-9]{9}$' THEN trim(raw)
    WHEN trim(raw) ~ '^255[0-9]{9}$'   THEN '+' || trim(raw)
    WHEN trim(raw) ~ '^0[0-9]{9}$'     THEN '+255' || substring(trim(raw) from 2)
    WHEN trim(raw) ~ '^[67][0-9]{8}$'  THEN '+255' || trim(raw)
    ELSE trim(raw)  -- leave non-TZ numbers as-is
  END
$$;

-- TIN normalization: remove dashes/spaces, uppercase
CREATE OR REPLACE FUNCTION public.normalize_tin(raw text)
RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT upper(regexp_replace(trim(raw), '[\s\-]', '', 'g'))
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: STAFF TABLE — Normalize + Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- B1. Normalize existing emails
UPDATE public.staff SET email = normalize_email(email) WHERE email IS NOT NULL;

-- B2. Normalize existing phones
UPDATE public.staff SET phone = normalize_phone_tz(phone)
WHERE phone IS NOT NULL AND phone != '' AND phone != '+255 xxx xxx xxx';

-- B3. Normalize TIN numbers
UPDATE public.staff SET tin_number = normalize_tin(tin_number)
WHERE tin_number IS NOT NULL;

-- B4. Make email NOT NULL (all 7 rows have emails)
ALTER TABLE public.staff ALTER COLUMN email SET NOT NULL;

-- B5. Add UNIQUE constraint on lower(email) — functional unique index
CREATE UNIQUE INDEX IF NOT EXISTS idx_staff_email_unique
  ON public.staff (lower(email));

-- B6. Add CHECK constraint for email format
DO $$ BEGIN
  ALTER TABLE public.staff ADD CONSTRAINT chk_staff_email_format
    CHECK (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- B7. Add UNIQUE constraint on user_id (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_staff_user_id_unique
  ON public.staff (user_id) WHERE user_id IS NOT NULL;

-- B8. Add index on department (used in RLS/joins)
CREATE INDEX IF NOT EXISTS idx_staff_department ON public.staff (department);

-- B9. Add index on active status
CREATE INDEX IF NOT EXISTS idx_staff_active ON public.staff (active);

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: EMPLOYEES TABLE — Normalize TIN + Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- C1. Consolidate TIN fields: Coalesce tin_number ← tin ← tin_no
UPDATE public.employees
SET tin_number = COALESCE(
  NULLIF(normalize_tin(tin_number), ''),
  NULLIF(normalize_tin(tin), ''),
  NULLIF(normalize_tin(tin_no), '')
)
WHERE tin_number IS NULL AND (tin IS NOT NULL OR tin_no IS NOT NULL);

-- C2. Consolidate national ID: nida_number ← national_id
UPDATE public.employees
SET nida_number = COALESCE(
  NULLIF(trim(nida_number), ''),
  NULLIF(trim(national_id), '')
)
WHERE nida_number IS NULL AND national_id IS NOT NULL;

-- C2b. Make email NOT NULL (all 6 employees have emails)
ALTER TABLE public.employees ALTER COLUMN email SET NOT NULL;

-- C3. Normalize existing emails
UPDATE public.employees SET email = normalize_email(email) WHERE email IS NOT NULL;

-- C4. Normalize phone numbers
UPDATE public.employees SET phone = normalize_phone_tz(phone)
WHERE phone IS NOT NULL AND phone != '';

-- C5. UNIQUE constraint on lower(email)
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_email_unique
  ON public.employees (lower(email));

-- C6. Add CHECK constraint for email format
DO $$ BEGIN
  ALTER TABLE public.employees ADD CONSTRAINT chk_employees_email_format
    CHECK (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- C7. UNIQUE constraint on employee_code (likely exists, but ensure)
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_code_unique
  ON public.employees (employee_code);

-- C8. UNIQUE on tin_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_tin_unique
  ON public.employees (normalize_tin(tin_number)) WHERE tin_number IS NOT NULL;

-- C9. UNIQUE on nida_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_nida_unique
  ON public.employees (nida_number) WHERE nida_number IS NOT NULL;

-- C10. UNIQUE on user_id (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_user_id_unique
  ON public.employees (user_id) WHERE user_id IS NOT NULL;

-- C11. Add index on dept + status (common query pattern)
CREATE INDEX IF NOT EXISTS idx_employees_dept_status
  ON public.employees (dept, status);

-- C12. Mark deprecated TIN columns with comment (do not drop yet — app may reference)
COMMENT ON COLUMN public.employees.tin IS 'DEPRECATED: Use tin_number instead';
COMMENT ON COLUMN public.employees.tin_no IS 'DEPRECATED: Use tin_number instead';
COMMENT ON COLUMN public.employees.national_id IS 'DEPRECATED: Use nida_number instead';

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: CLIENTS TABLE — Normalize phone + Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- D1. Normalize phone numbers to E.164
UPDATE public.clients SET phone_number = normalize_phone_tz(phone_number)
WHERE phone_number IS NOT NULL;

-- D2. UNIQUE on phone_number (likely exists)
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_phone_unique
  ON public.clients (phone_number);

-- D3. UNIQUE on external_reference_id (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_ext_ref_unique
  ON public.clients (external_reference_id) WHERE external_reference_id IS NOT NULL;

-- D4. UNIQUE on nida_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_nida_unique
  ON public.clients (nida_number) WHERE nida_number IS NOT NULL;

-- D5. Add index on status + risk_level (used in risk queries)
CREATE INDEX IF NOT EXISTS idx_clients_status_risk
  ON public.clients (status, risk_level);

-- D6. Add CHECK for phone format (Tanzania E.164 — only normalized format allowed)
DO $$ BEGIN
  ALTER TABLE public.clients ADD CONSTRAINT chk_clients_phone_format
    CHECK (phone_number ~ '^\+255[0-9]{9}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: CUSTOMERS TABLE — Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- E1. UNIQUE on customer_code
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_code_unique
  ON public.customers (customer_code);

-- E2. UNIQUE on email (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_email_unique
  ON public.customers (lower(email)) WHERE email IS NOT NULL;

-- E3. UNIQUE on phone (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_customers_phone_unique
  ON public.customers (phone) WHERE phone IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART F: VENDORS TABLE — Generate codes + Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- F1. Generate vendor codes for records missing them
UPDATE public.vendors v
SET vendor_code = sub.new_code
FROM (
  SELECT id, 'VND-' || LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::text, 4, '0') as new_code
  FROM public.vendors WHERE vendor_code IS NULL
) sub
WHERE v.id = sub.id AND v.vendor_code IS NULL;

-- F2. Make vendor_code NOT NULL
ALTER TABLE public.vendors ALTER COLUMN vendor_code SET NOT NULL;

-- F3. UNIQUE on vendor_code
CREATE UNIQUE INDEX IF NOT EXISTS idx_vendors_code_unique
  ON public.vendors (vendor_code);

-- F4. UNIQUE on vendor_name
CREATE UNIQUE INDEX IF NOT EXISTS idx_vendors_name_unique
  ON public.vendors (lower(vendor_name));

-- ═══════════════════════════════════════════════════════════════════════
-- PART G: BORROWERS TABLE — Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- G1. Normalize phone numbers
UPDATE public.borrowers SET phone_number = normalize_phone_tz(phone_number)
WHERE phone_number IS NOT NULL;

-- G2. UNIQUE on phone_number
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_phone_unique
  ON public.borrowers (phone_number);

-- G3. UNIQUE on nida_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_nida_unique
  ON public.borrowers (nida_number) WHERE nida_number IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART H: LOANS TABLE — Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- H1. UNIQUE on loan_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_loans_number_unique
  ON public.loans (loan_number) WHERE loan_number IS NOT NULL;

-- H2. Add index on borrower_id + status (common join pattern)
CREATE INDEX IF NOT EXISTS idx_loans_borrower_status
  ON public.loans (borrower_id, status);

-- H3. Add index on officer_id
CREATE INDEX IF NOT EXISTS idx_loans_officer ON public.loans (officer_id)
  WHERE officer_id IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART I: LEAVE BALANCES — Constrain
-- ═══════════════════════════════════════════════════════════════════════

-- I1. UNIQUE on (staff_id, leave_type, year) — one balance per type per year
CREATE UNIQUE INDEX IF NOT EXISTS idx_leave_balances_key
  ON public.leave_balances (staff_id, leave_type, year);

-- ═══════════════════════════════════════════════════════════════════════
-- PART J: ATTENDANCE RECORDS — Add index (unique constraint already exists)
-- ═══════════════════════════════════════════════════════════════════════

-- J1. Add index on work_date for reporting queries
CREATE INDEX IF NOT EXISTS idx_attendance_work_date
  ON public.attendance_records (work_date);

-- J2. Add index on staff_id for per-staff queries
CREATE INDEX IF NOT EXISTS idx_attendance_staff_id
  ON public.attendance_records (staff_id);

-- ═══════════════════════════════════════════════════════════════════════
-- PART K: PROFILES TABLE — Constrain (0 rows, preventive only)
-- ═══════════════════════════════════════════════════════════════════════

-- K1. UNIQUE on phone_number (where not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_phone_unique
  ON public.profiles (phone_number) WHERE phone_number IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART L: PREVENTIVE TRIGGERS — Auto-normalize on INSERT/UPDATE
-- ═══════════════════════════════════════════════════════════════════════

-- L1. Staff email/phone/TIN normalization trigger
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
CREATE TRIGGER trg_staff_normalize
  BEFORE INSERT OR UPDATE ON public.staff
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_staff();

-- L2. Employees email/phone/TIN normalization trigger
CREATE OR REPLACE FUNCTION public.trg_normalize_employees()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.email := normalize_email(NEW.email);
  IF NEW.phone IS NOT NULL AND NEW.phone != '' THEN
    NEW.phone := normalize_phone_tz(NEW.phone);
  END IF;
  -- Consolidate deprecated TIN fields into tin_number
  IF NEW.tin_number IS NULL AND NEW.tin IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin);
  END IF;
  IF NEW.tin_number IS NULL AND NEW.tin_no IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin_no);
  END IF;
  IF NEW.tin_number IS NOT NULL THEN
    NEW.tin_number := normalize_tin(NEW.tin_number);
  END IF;
  -- Consolidate deprecated national_id into nida_number
  IF NEW.nida_number IS NULL AND NEW.national_id IS NOT NULL THEN
    NEW.nida_number := trim(NEW.national_id);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_employees_normalize ON public.employees;
CREATE TRIGGER trg_employees_normalize
  BEFORE INSERT OR UPDATE ON public.employees
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_employees();

-- L3. Clients phone normalization trigger
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
CREATE TRIGGER trg_clients_normalize
  BEFORE INSERT OR UPDATE ON public.clients
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_clients();

-- L4. Borrowers phone normalization trigger
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
CREATE TRIGGER trg_borrowers_normalize
  BEFORE INSERT OR UPDATE ON public.borrowers
  FOR EACH ROW EXECUTE FUNCTION public.trg_normalize_borrowers();

-- ═══════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES
-- ═══════════════════════════════════════════════════════════════════════
-- Run after migration to confirm all constraints are active:
--
-- SELECT indexname, tablename FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND indexname LIKE 'idx_%_unique'
-- ORDER BY tablename, indexname;
--
-- SELECT conname, conrelid::regclass, contype
-- FROM pg_constraint
-- WHERE conname LIKE 'chk_%'
-- ORDER BY conrelid::regclass;
--
-- SELECT tgname, tgrelid::regclass
-- FROM pg_trigger
-- WHERE tgname LIKE 'trg_%'
-- ORDER BY tgrelid::regclass;
-- ============================================================================
