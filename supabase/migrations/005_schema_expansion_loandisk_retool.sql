-- ============================================================================
-- MIGRATION 005: Schema Expansion — Full LoanDisk Borrower & Loan Fields
-- Date:       2026-02-14
-- Purpose:    Capture ALL LoanDisk fields in Supabase canonical tables
--             so Retool can display the full borrower/loan profile
-- Strategy:   ADD COLUMN IF NOT EXISTS (safe re-run), then create Retool views
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: BORROWERS TABLE — Add missing profile fields
-- ═══════════════════════════════════════════════════════════════════════

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

-- Unique index on borrower_code (LoanDisk ID like #20230325YO9)
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_code_unique
  ON public.borrowers (borrower_code) WHERE borrower_code IS NOT NULL;

-- Unique index on external_reference_id (LD-{loandisk_id})
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_ext_ref_unique
  ON public.borrowers (external_reference_id) WHERE external_reference_id IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: CLIENTS TABLE — Add missing KYC/document fields
-- ═══════════════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: LOANS TABLE — Add missing disbursement & schedule fields
-- ═══════════════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: RETOOL VIEWS — Pre-joined for dashboard consumption
-- ═══════════════════════════════════════════════════════════════════════

-- D1. Borrower Profile View (single view with everything Retool needs)
CREATE OR REPLACE VIEW public.v_borrower_profiles AS
SELECT
  b.id,
  b.borrower_code,
  b.title,
  b.full_name,
  b.phone_number,
  b.email,
  b.nida_number,
  b.gender,
  b.date_of_birth,
  CASE WHEN b.date_of_birth IS NOT NULL
    THEN extract(year from age(current_date, b.date_of_birth))::int
    ELSE NULL
  END AS age_years,
  b.marital_status,
  b.credit_rating,
  b.photo_url,
  -- Business
  b.business_name,
  b.business_type,
  b.business_role,
  b.business_location,
  b.revenue_estimate,
  -- Location
  b.address,
  b.region,
  b.district,
  b.street,
  b.location_gps,
  b.gps_latitude,
  b.gps_longitude,
  -- Banking
  b.bank_name,
  b.bank_account_number,
  -- Documents
  b.drivers_license,
  b.vehicle_info,
  -- Contacts
  b.alternative_phone,
  b.next_of_kin_name,
  b.next_of_kin_relationship,
  b.next_of_kin_phone,
  b.guarantor_name,
  b.guarantor_phone,
  b.guarantor_relationship,
  -- Officer
  b.loan_officer_name,
  -- Status
  b.status,
  b.external_reference_id,
  b.notes,
  b.created_at,
  b.updated_at,
  -- Client enrichment (joined)
  c.id AS client_id,
  c.credit_score,
  c.risk_level,
  c.documents AS client_documents,
  -- Loan summary (aggregated)
  ls.total_loans,
  ls.active_loans,
  ls.total_principal,
  ls.total_outstanding,
  ls.total_paid,
  ls.max_days_overdue
FROM public.borrowers b
LEFT JOIN public.clients c ON c.external_reference_id = b.external_reference_id
LEFT JOIN LATERAL (
  SELECT
    count(*) AS total_loans,
    count(*) FILTER (WHERE l.status IN ('active', 'pending')) AS active_loans,
    coalesce(sum(l.amount_principal), 0) AS total_principal,
    coalesce(sum(l.outstanding_balance), 0) AS total_outstanding,
    coalesce(sum(l.total_paid), 0) AS total_paid,
    coalesce(max(l.days_overdue), 0) AS max_days_overdue
  FROM public.loans l
  WHERE l.borrower_id = b.id
) ls ON true;

-- D2. Loan Detail View (with borrower name and officer)
CREATE OR REPLACE VIEW public.v_loan_details AS
SELECT
  l.id,
  l.loan_number,
  l.borrower_id,
  b.full_name AS borrower_name,
  b.phone_number AS borrower_phone,
  b.borrower_code,
  l.loan_officer_name,
  l.officer_id,
  l.amount_principal,
  l.interest_rate,
  l.interest_rate_period,
  l.interest_method,
  l.duration_months,
  l.total_due,
  l.outstanding_balance,
  l.total_paid,
  l.interest_paid,
  l.fees,
  l.penalty_amount,
  l.days_overdue,
  l.status,
  l.product_type,
  l.start_date,
  l.disbursed_at,
  l.disbursed_by,
  l.maturity_date,
  l.last_payment_date,
  l.next_payment_date,
  l.repayment_frequency,
  l.approved_by,
  l.approved_date,
  l.loan_purpose,
  l.collateral,
  l.collateral_value,
  l.branch,
  l.notes,
  l.created_at,
  l.updated_at,
  -- Repayment summary
  rs.total_repayments,
  rs.last_repayment_amount,
  rs.last_repayment_date
FROM public.loans l
LEFT JOIN public.borrowers b ON b.id = l.borrower_id
LEFT JOIN LATERAL (
  SELECT
    count(*) AS total_repayments,
    (array_agg(r.amount_paid ORDER BY r.paid_at DESC))[1] AS last_repayment_amount,
    max(r.paid_at) AS last_repayment_date
  FROM public.repayments r
  WHERE r.loan_id = l.id
) rs ON true;

-- D3. Repayment History View (with loan and borrower context)
CREATE OR REPLACE VIEW public.v_repayment_history AS
SELECT
  r.id,
  r.loan_id,
  l.loan_number,
  l.borrower_id,
  b.full_name AS borrower_name,
  b.borrower_code,
  r.amount_paid,
  r.payment_method,
  r.receipt_ref,
  r.collected_by,
  r.paid_at,
  r.created_at
FROM public.repayments r
LEFT JOIN public.loans l ON l.id = r.loan_id
LEFT JOIN public.borrowers b ON b.id = l.borrower_id;

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: RLS Policies for the new views
-- ═══════════════════════════════════════════════════════════════════════

-- Views inherit RLS from underlying tables, but grant access for service role
GRANT SELECT ON public.v_borrower_profiles TO service_role, authenticated;
GRANT SELECT ON public.v_loan_details TO service_role, authenticated;
GRANT SELECT ON public.v_repayment_history TO service_role, authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
DO $$
DECLARE
  bcols int;
  ccols int;
  lcols int;
  vcnt int;
BEGIN
  SELECT count(*) INTO bcols FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'borrowers';
  SELECT count(*) INTO ccols FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'clients';
  SELECT count(*) INTO lcols FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'loans';
  SELECT count(*) INTO vcnt FROM information_schema.views
    WHERE table_schema = 'public' AND table_name LIKE 'v_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'SCHEMA EXPANSION COMPLETE';
  RAISE NOTICE 'borrowers columns: %', bcols;
  RAISE NOTICE 'clients columns: %', ccols;
  RAISE NOTICE 'loans columns: %', lcols;
  RAISE NOTICE 'Retool views: %', vcnt;
  RAISE NOTICE '========================================';
END $$;
