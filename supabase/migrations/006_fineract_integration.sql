-- ============================================================================
-- MIGRATION 006: Apache Fineract Integration
-- Date:       2026-02-14
-- Purpose:    Replace LoanDisk integration with Apache Fineract core banking
--             platform. Adds Fineract-specific tables, updates raw staging
--             tables, creates comprehensive Retool views and RPC functions
--             for full business logic.
-- Strategy:   ADD IF NOT EXISTS (safe re-run), preserve existing data
-- ============================================================================

-- ═══════════════════════════════════════════════════════════════════════
-- PART A: FINERACT INTEGRATION CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.fineract_integrations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  instance_name text NOT NULL DEFAULT 'IMFSL Fineract',
  base_url text NOT NULL,
  tenant_id text NOT NULL DEFAULT 'default',
  username text NOT NULL,
  -- password stored as encrypted env var, not in DB
  is_active boolean NOT NULL DEFAULT true,
  sync_clients boolean NOT NULL DEFAULT true,
  sync_loans boolean NOT NULL DEFAULT true,
  sync_repayments boolean NOT NULL DEFAULT true,
  sync_savings boolean NOT NULL DEFAULT false,
  sync_staff boolean NOT NULL DEFAULT true,
  last_sync_at timestamptz,
  last_sync_status text,
  webhook_secret text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART B: FINERACT RAW STAGING TABLES
-- ═══════════════════════════════════════════════════════════════════════

-- B1. Raw Clients (from Fineract /clients endpoint)
CREATE TABLE IF NOT EXISTS public.raw_fineract_clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint NOT NULL,
  office_id bigint,
  payload jsonb NOT NULL,
  source text NOT NULL DEFAULT 'batch_sync',
  fetched_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (fineract_id)
);

-- B2. Raw Loans (from Fineract /loans endpoint)
CREATE TABLE IF NOT EXISTS public.raw_fineract_loans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint NOT NULL,
  client_fineract_id bigint,
  payload jsonb NOT NULL,
  source text NOT NULL DEFAULT 'batch_sync',
  fetched_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (fineract_id)
);

-- B3. Raw Loan Transactions (from Fineract /loans/{id}/transactions)
CREATE TABLE IF NOT EXISTS public.raw_fineract_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint NOT NULL,
  loan_fineract_id bigint NOT NULL,
  transaction_type text,
  payload jsonb NOT NULL,
  source text NOT NULL DEFAULT 'batch_sync',
  fetched_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (fineract_id)
);

-- B4. Raw Savings Accounts (from Fineract /savingsaccounts)
CREATE TABLE IF NOT EXISTS public.raw_fineract_savings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint NOT NULL,
  client_fineract_id bigint,
  payload jsonb NOT NULL,
  source text NOT NULL DEFAULT 'batch_sync',
  fetched_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (fineract_id)
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART C: FINERACT SYNC TRACKING
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.fineract_sync_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  integration_id uuid NOT NULL REFERENCES public.fineract_integrations(id),
  run_type text NOT NULL DEFAULT 'scheduled',
  started_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  status text NOT NULL DEFAULT 'running',
  records_fetched int NOT NULL DEFAULT 0,
  records_created int NOT NULL DEFAULT 0,
  records_updated int NOT NULL DEFAULT 0,
  records_skipped int NOT NULL DEFAULT 0,
  records_failed int NOT NULL DEFAULT 0,
  entity_types text[] DEFAULT '{}',
  error_message text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.fineract_sync_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_run_id uuid NOT NULL REFERENCES public.fineract_sync_runs(id),
  entity_type text NOT NULL,
  external_id text NOT NULL,
  action text NOT NULL,
  local_id uuid,
  source_data jsonb,
  transformed_data jsonb,
  error_message text,
  synced_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART D: FINERACT RECONCILIATION
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.fineract_reconciliation_snapshots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reconciliation_date timestamptz NOT NULL DEFAULT now(),
  period_start timestamptz,
  period_end timestamptz,
  -- Fineract-side totals
  fn_total_clients int DEFAULT 0,
  fn_total_loans int DEFAULT 0,
  fn_total_disbursed numeric DEFAULT 0,
  fn_total_outstanding numeric DEFAULT 0,
  fn_total_repayments numeric DEFAULT 0,
  fn_total_savings_accounts int DEFAULT 0,
  fn_total_savings_balance numeric DEFAULT 0,
  -- System-side totals
  sys_total_clients int DEFAULT 0,
  sys_total_loans int DEFAULT 0,
  sys_total_disbursed numeric DEFAULT 0,
  sys_total_outstanding numeric DEFAULT 0,
  sys_total_repayments numeric DEFAULT 0,
  -- Variances
  variance_clients int DEFAULT 0,
  variance_loans int DEFAULT 0,
  variance_disbursed numeric DEFAULT 0,
  variance_outstanding numeric DEFAULT 0,
  variance_repayments numeric DEFAULT 0,
  status text NOT NULL DEFAULT 'pending',
  variance_notes text,
  fn_snapshot_data jsonb,
  sys_snapshot_data jsonb,
  variance_details jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART E: LOAN PRODUCTS (Fineract loan product catalog)
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.loan_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint UNIQUE,
  name text NOT NULL,
  short_name text,
  description text,
  currency_code text NOT NULL DEFAULT 'TZS',
  principal_min numeric,
  principal_default numeric,
  principal_max numeric,
  interest_rate_min numeric,
  interest_rate_default numeric,
  interest_rate_max numeric,
  interest_rate_frequency text DEFAULT 'per_month',
  interest_method text DEFAULT 'declining_balance',
  interest_calculation_period text DEFAULT 'same_as_repayment',
  repayment_frequency text DEFAULT 'monthly',
  number_of_repayments_min int,
  number_of_repayments_default int,
  number_of_repayments_max int,
  amortization_type text DEFAULT 'equal_installments',
  grace_on_principal int DEFAULT 0,
  grace_on_interest int DEFAULT 0,
  grace_on_interest_charged int DEFAULT 0,
  include_in_borrower_cycle boolean DEFAULT false,
  accounting_rule text DEFAULT 'none',
  is_active boolean DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART F: LOAN SCHEDULE (amortization schedule from Fineract)
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.loan_schedule (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_id uuid NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
  installment_number int NOT NULL,
  due_date date NOT NULL,
  principal_due numeric NOT NULL DEFAULT 0,
  interest_due numeric NOT NULL DEFAULT 0,
  fee_charges_due numeric NOT NULL DEFAULT 0,
  penalty_charges_due numeric NOT NULL DEFAULT 0,
  total_due numeric GENERATED ALWAYS AS (principal_due + interest_due + fee_charges_due + penalty_charges_due) STORED,
  principal_paid numeric NOT NULL DEFAULT 0,
  interest_paid numeric NOT NULL DEFAULT 0,
  fee_charges_paid numeric NOT NULL DEFAULT 0,
  penalty_charges_paid numeric NOT NULL DEFAULT 0,
  total_paid numeric GENERATED ALWAYS AS (principal_paid + interest_paid + fee_charges_paid + penalty_charges_paid) STORED,
  is_completed boolean DEFAULT false,
  from_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (loan_id, installment_number)
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART G: SAVINGS ACCOUNTS
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.savings_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint UNIQUE,
  client_id uuid REFERENCES public.clients(id),
  borrower_id uuid REFERENCES public.borrowers(id),
  account_number text UNIQUE,
  product_name text,
  currency_code text DEFAULT 'TZS',
  nominal_annual_interest_rate numeric DEFAULT 0,
  balance numeric NOT NULL DEFAULT 0,
  available_balance numeric DEFAULT 0,
  total_deposits numeric DEFAULT 0,
  total_withdrawals numeric DEFAULT 0,
  total_interest_earned numeric DEFAULT 0,
  status text NOT NULL DEFAULT 'active',
  activated_on date,
  last_transaction_date date,
  external_reference_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART H: OFFICES & STAFF (Fineract organizational structure)
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.fineract_offices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint UNIQUE NOT NULL,
  name text NOT NULL,
  name_decorated text,
  parent_id bigint,
  hierarchy text,
  opening_date date,
  external_id text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.fineract_staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fineract_id bigint UNIQUE NOT NULL,
  office_id bigint,
  firstname text NOT NULL,
  lastname text NOT NULL,
  display_name text,
  mobile_no text,
  email_address text,
  is_loan_officer boolean DEFAULT false,
  is_active boolean DEFAULT true,
  joining_date date,
  external_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════
-- PART I: LOAN LIFECYCLE AUDIT (tracks state transitions)
-- ═══════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.loan_lifecycle_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_id uuid NOT NULL REFERENCES public.loans(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  from_status text,
  to_status text,
  amount numeric,
  performed_by text,
  fineract_transaction_id bigint,
  notes text,
  event_data jsonb,
  event_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_loan_lifecycle_loan_id ON public.loan_lifecycle_events(loan_id);
CREATE INDEX IF NOT EXISTS idx_loan_lifecycle_event_type ON public.loan_lifecycle_events(event_type);

-- ═══════════════════════════════════════════════════════════════════════
-- PART J: ADD FINERACT COLUMNS TO EXISTING TABLES
-- ═══════════════════════════════════════════════════════════════════════

-- Borrowers: add fineract_id
ALTER TABLE public.borrowers ADD COLUMN IF NOT EXISTS fineract_id bigint;
CREATE UNIQUE INDEX IF NOT EXISTS idx_borrowers_fineract_id
  ON public.borrowers (fineract_id) WHERE fineract_id IS NOT NULL;

-- Clients: add fineract_id and savings info
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS fineract_id bigint;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS office_id bigint;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS staff_id bigint;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS activation_date date;
ALTER TABLE public.clients ADD COLUMN IF NOT EXISTS savings_account_id uuid;
CREATE UNIQUE INDEX IF NOT EXISTS idx_clients_fineract_id
  ON public.clients (fineract_id) WHERE fineract_id IS NOT NULL;

-- Loans: add fineract fields
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS fineract_id bigint;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS loan_product_id uuid REFERENCES public.loan_products(id);
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS fineract_product_id bigint;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS amortization_type text;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS number_of_repayments int;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS grace_on_principal int DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS grace_on_interest int DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_interest_charged numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_fee_charges numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_penalty_charges numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_waived numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_written_off numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS total_expected numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS arrears_amount numeric DEFAULT 0;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS expected_maturity_date date;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS in_arrears boolean DEFAULT false;
ALTER TABLE public.loans ADD COLUMN IF NOT EXISTS is_npa boolean DEFAULT false;
CREATE UNIQUE INDEX IF NOT EXISTS idx_loans_fineract_id
  ON public.loans (fineract_id) WHERE fineract_id IS NOT NULL;

-- Repayments: add fineract fields
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS fineract_id bigint;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS transaction_type text;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS principal_portion numeric DEFAULT 0;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS interest_portion numeric DEFAULT 0;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS fee_charges_portion numeric DEFAULT 0;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS penalty_charges_portion numeric DEFAULT 0;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS outstanding_loan_balance numeric;
ALTER TABLE public.repayments ADD COLUMN IF NOT EXISTS is_reversed boolean DEFAULT false;
CREATE UNIQUE INDEX IF NOT EXISTS idx_repayments_fineract_id
  ON public.repayments (fineract_id) WHERE fineract_id IS NOT NULL;

-- ═══════════════════════════════════════════════════════════════════════
-- PART K: RETOOL VIEWS — Full Business Logic Dashboards
-- ═══════════════════════════════════════════════════════════════════════

-- K1. Portfolio Overview (executive dashboard)
CREATE OR REPLACE VIEW public.v_portfolio_overview AS
SELECT
  count(*) AS total_loans,
  count(*) FILTER (WHERE status = 'active') AS active_loans,
  count(*) FILTER (WHERE status = 'pending') AS pending_loans,
  count(*) FILTER (WHERE status = 'completed') AS completed_loans,
  count(*) FILTER (WHERE status = 'defaulted') AS defaulted_loans,
  count(*) FILTER (WHERE in_arrears = true) AS loans_in_arrears,
  count(*) FILTER (WHERE is_npa = true) AS npa_loans,
  coalesce(sum(amount_principal), 0) AS total_principal_disbursed,
  coalesce(sum(outstanding_balance), 0) AS total_outstanding,
  coalesce(sum(total_paid), 0) AS total_collected,
  coalesce(sum(arrears_amount) FILTER (WHERE in_arrears = true), 0) AS total_arrears,
  coalesce(sum(total_written_off), 0) AS total_written_off,
  coalesce(avg(interest_rate), 0) AS avg_interest_rate,
  coalesce(avg(duration_months), 0) AS avg_loan_duration_months,
  CASE WHEN sum(amount_principal) > 0
    THEN round(sum(total_paid)::numeric / sum(amount_principal) * 100, 2)
    ELSE 0
  END AS collection_rate_pct,
  CASE WHEN count(*) > 0
    THEN round(count(*) FILTER (WHERE in_arrears = true)::numeric / count(*) * 100, 2)
    ELSE 0
  END AS portfolio_at_risk_pct
FROM public.loans;

-- K2. Loan Officer Performance
CREATE OR REPLACE VIEW public.v_loan_officer_performance AS
SELECT
  coalesce(l.loan_officer_name, 'Unassigned') AS loan_officer,
  count(*) AS total_loans,
  count(*) FILTER (WHERE l.status = 'active') AS active_loans,
  count(*) FILTER (WHERE l.status = 'completed') AS completed_loans,
  count(*) FILTER (WHERE l.status = 'defaulted') AS defaulted_loans,
  count(*) FILTER (WHERE l.in_arrears = true) AS loans_in_arrears,
  coalesce(sum(l.amount_principal), 0) AS total_disbursed,
  coalesce(sum(l.outstanding_balance), 0) AS total_outstanding,
  coalesce(sum(l.total_paid), 0) AS total_collected,
  CASE WHEN sum(l.amount_principal) > 0
    THEN round(sum(l.total_paid)::numeric / sum(l.amount_principal) * 100, 2)
    ELSE 0
  END AS collection_rate_pct,
  count(DISTINCT l.borrower_id) AS unique_borrowers
FROM public.loans l
GROUP BY l.loan_officer_name;

-- K3. Product Performance
CREATE OR REPLACE VIEW public.v_product_performance AS
SELECT
  coalesce(lp.name, l.product_type, 'Unknown') AS product_name,
  lp.short_name AS product_code,
  count(*) AS total_loans,
  count(*) FILTER (WHERE l.status = 'active') AS active_loans,
  coalesce(sum(l.amount_principal), 0) AS total_disbursed,
  coalesce(sum(l.outstanding_balance), 0) AS total_outstanding,
  coalesce(sum(l.total_paid), 0) AS total_collected,
  coalesce(avg(l.interest_rate), 0) AS avg_interest_rate,
  coalesce(avg(l.duration_months), 0) AS avg_duration_months,
  count(*) FILTER (WHERE l.in_arrears = true) AS loans_in_arrears,
  count(*) FILTER (WHERE l.status = 'defaulted') AS defaulted_loans,
  CASE WHEN count(*) > 0
    THEN round(count(*) FILTER (WHERE l.in_arrears = true)::numeric / count(*) * 100, 2)
    ELSE 0
  END AS par_pct
FROM public.loans l
LEFT JOIN public.loan_products lp ON lp.id = l.loan_product_id
GROUP BY lp.name, lp.short_name, l.product_type;

-- K4. Aging Analysis (PAR bands)
CREATE OR REPLACE VIEW public.v_aging_analysis AS
SELECT
  CASE
    WHEN days_overdue IS NULL OR days_overdue = 0 THEN 'Current'
    WHEN days_overdue BETWEEN 1 AND 30 THEN 'PAR 1-30'
    WHEN days_overdue BETWEEN 31 AND 60 THEN 'PAR 31-60'
    WHEN days_overdue BETWEEN 61 AND 90 THEN 'PAR 61-90'
    WHEN days_overdue BETWEEN 91 AND 180 THEN 'PAR 91-180'
    WHEN days_overdue > 180 THEN 'PAR 180+'
  END AS aging_band,
  count(*) AS loan_count,
  coalesce(sum(outstanding_balance), 0) AS total_outstanding,
  coalesce(sum(arrears_amount), 0) AS total_arrears,
  coalesce(sum(amount_principal), 0) AS total_principal
FROM public.loans
WHERE status IN ('active', 'defaulted')
GROUP BY
  CASE
    WHEN days_overdue IS NULL OR days_overdue = 0 THEN 'Current'
    WHEN days_overdue BETWEEN 1 AND 30 THEN 'PAR 1-30'
    WHEN days_overdue BETWEEN 31 AND 60 THEN 'PAR 31-60'
    WHEN days_overdue BETWEEN 61 AND 90 THEN 'PAR 61-90'
    WHEN days_overdue BETWEEN 91 AND 180 THEN 'PAR 91-180'
    WHEN days_overdue > 180 THEN 'PAR 180+'
  END
ORDER BY
  CASE
    WHEN days_overdue IS NULL OR days_overdue = 0 THEN 0
    WHEN days_overdue BETWEEN 1 AND 30 THEN 1
    WHEN days_overdue BETWEEN 31 AND 60 THEN 2
    WHEN days_overdue BETWEEN 61 AND 90 THEN 3
    WHEN days_overdue BETWEEN 91 AND 180 THEN 4
    WHEN days_overdue > 180 THEN 5
  END;

-- K5. Daily Collections Summary
CREATE OR REPLACE VIEW public.v_daily_collections AS
SELECT
  date_trunc('day', r.paid_at)::date AS collection_date,
  count(*) AS transaction_count,
  coalesce(sum(r.amount_paid), 0) AS total_collected,
  coalesce(sum(r.principal_portion), 0) AS principal_collected,
  coalesce(sum(r.interest_portion), 0) AS interest_collected,
  coalesce(sum(r.fee_charges_portion), 0) AS fees_collected,
  count(DISTINCT r.loan_id) AS unique_loans,
  count(*) FILTER (WHERE r.payment_method = 'cash') AS cash_payments,
  count(*) FILTER (WHERE r.payment_method = 'mobile_money') AS mobile_payments,
  count(*) FILTER (WHERE r.payment_method = 'bank_transfer') AS bank_payments
FROM public.repayments r
WHERE r.is_reversed = false
GROUP BY date_trunc('day', r.paid_at)::date
ORDER BY collection_date DESC;

-- K6. Client 360 View (comprehensive client profile for Retool)
CREATE OR REPLACE VIEW public.v_client_360 AS
SELECT
  c.id AS client_id,
  c.fineract_id AS fineract_client_id,
  c.external_reference_id,
  c.borrower_code,
  c.title,
  c.first_name,
  c.middle_name,
  c.last_name,
  c.full_name,
  c.phone_number,
  c.nida_number,
  c.email,
  c.gender,
  c.date_of_birth,
  c.marital_status,
  c.activation_date,
  c.credit_score,
  c.risk_level,
  c.credit_rating,
  c.status,
  -- Business info
  c.business_type,
  c.business_name,
  c.business_role,
  c.business_location,
  c.revenue_estimate,
  -- Location
  c.address,
  c.region,
  c.district,
  c.street,
  c.gps_latitude,
  c.gps_longitude,
  -- Banking
  c.bank_name,
  c.bank_account_number,
  -- Contacts
  c.alternative_phone,
  c.next_of_kin_name,
  c.next_of_kin_phone,
  c.guarantor_name,
  c.guarantor_phone,
  -- Officer
  c.loan_officer_name,
  fs.display_name AS assigned_officer_name,
  fo.name AS office_name,
  -- Loan summary
  loan_stats.total_loans,
  loan_stats.active_loans,
  loan_stats.total_principal,
  loan_stats.total_outstanding,
  loan_stats.total_paid_all,
  loan_stats.max_days_overdue,
  loan_stats.has_arrears,
  -- Savings summary
  sav_stats.savings_balance,
  sav_stats.total_deposits,
  -- Timestamps
  c.created_at,
  c.updated_at
FROM public.clients c
LEFT JOIN public.fineract_staff fs ON fs.fineract_id = c.staff_id
LEFT JOIN public.fineract_offices fo ON fo.fineract_id = c.office_id
LEFT JOIN LATERAL (
  SELECT
    count(*) AS total_loans,
    count(*) FILTER (WHERE l.status IN ('active', 'pending')) AS active_loans,
    coalesce(sum(l.amount_principal), 0) AS total_principal,
    coalesce(sum(l.outstanding_balance), 0) AS total_outstanding,
    coalesce(sum(l.total_paid), 0) AS total_paid_all,
    coalesce(max(l.days_overdue), 0) AS max_days_overdue,
    bool_or(l.in_arrears) AS has_arrears
  FROM public.loans l
  WHERE l.borrower_id IN (
    SELECT b.id FROM public.borrowers b WHERE b.fineract_id = c.fineract_id
    UNION
    SELECT b2.id FROM public.borrowers b2 WHERE b2.phone_number = c.phone_number
  )
) loan_stats ON true
LEFT JOIN LATERAL (
  SELECT
    coalesce(sum(sa.balance), 0) AS savings_balance,
    coalesce(sum(sa.total_deposits), 0) AS total_deposits
  FROM public.savings_accounts sa
  WHERE sa.client_id = c.id
) sav_stats ON true;

-- K7. Loan Schedule View (for Retool amortization display)
CREATE OR REPLACE VIEW public.v_loan_schedule AS
SELECT
  ls.id,
  ls.loan_id,
  l.loan_number,
  b.full_name AS borrower_name,
  ls.installment_number,
  ls.from_date,
  ls.due_date,
  ls.principal_due,
  ls.interest_due,
  ls.fee_charges_due,
  ls.penalty_charges_due,
  ls.total_due,
  ls.principal_paid,
  ls.interest_paid,
  ls.fee_charges_paid,
  ls.penalty_charges_paid,
  ls.total_paid,
  (ls.total_due - ls.total_paid) AS balance_remaining,
  ls.is_completed,
  CASE
    WHEN ls.is_completed THEN 'Paid'
    WHEN ls.due_date < current_date AND ls.total_paid < ls.total_due THEN 'Overdue'
    WHEN ls.due_date = current_date THEN 'Due Today'
    ELSE 'Upcoming'
  END AS installment_status
FROM public.loan_schedule ls
JOIN public.loans l ON l.id = ls.loan_id
LEFT JOIN public.borrowers b ON b.id = l.borrower_id;

-- K8. Loan Lifecycle Audit Trail (for Retool audit tab)
CREATE OR REPLACE VIEW public.v_loan_audit_trail AS
SELECT
  lle.id,
  lle.loan_id,
  l.loan_number,
  b.full_name AS borrower_name,
  lle.event_type,
  lle.from_status,
  lle.to_status,
  lle.amount,
  lle.performed_by,
  lle.notes,
  lle.event_date,
  lle.created_at
FROM public.loan_lifecycle_events lle
JOIN public.loans l ON l.id = lle.loan_id
LEFT JOIN public.borrowers b ON b.id = l.borrower_id
ORDER BY lle.event_date DESC;

-- ═══════════════════════════════════════════════════════════════════════
-- PART L: RPC FUNCTIONS FOR RETOOL BUSINESS LOGIC
-- ═══════════════════════════════════════════════════════════════════════

-- L1. Approve a loan (records lifecycle event, updates status)
CREATE OR REPLACE FUNCTION public.rpc_approve_loan(
  p_loan_id uuid,
  p_approved_by text DEFAULT 'system',
  p_notes text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_loan record;
  v_result jsonb;
BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan not found');
  END IF;
  IF v_loan.status != 'pending' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan must be in pending status to approve. Current: ' || v_loan.status);
  END IF;

  UPDATE public.loans SET
    status = 'active',
    approved_by = p_approved_by,
    approved_date = current_date,
    updated_at = now()
  WHERE id = p_loan_id;

  INSERT INTO public.loan_lifecycle_events (loan_id, event_type, from_status, to_status, performed_by, notes)
  VALUES (p_loan_id, 'approval', 'pending', 'active', p_approved_by, p_notes);

  RETURN jsonb_build_object('success', true, 'loan_id', p_loan_id, 'new_status', 'active');
END;
$$;

-- L2. Disburse a loan
CREATE OR REPLACE FUNCTION public.rpc_disburse_loan(
  p_loan_id uuid,
  p_disbursed_by text DEFAULT 'system',
  p_disbursement_date date DEFAULT current_date,
  p_notes text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_loan record;
BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan not found');
  END IF;
  IF v_loan.status != 'active' THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan must be approved (active) to disburse. Current: ' || v_loan.status);
  END IF;

  UPDATE public.loans SET
    disbursed_at = p_disbursement_date::timestamptz,
    disbursed_by = p_disbursed_by,
    start_date = p_disbursement_date,
    outstanding_balance = amount_principal,
    updated_at = now()
  WHERE id = p_loan_id;

  INSERT INTO public.loan_lifecycle_events (loan_id, event_type, from_status, to_status, amount, performed_by, notes, event_date)
  VALUES (p_loan_id, 'disbursement', 'active', 'active', v_loan.amount_principal, p_disbursed_by, p_notes, p_disbursement_date::timestamptz);

  RETURN jsonb_build_object('success', true, 'loan_id', p_loan_id, 'amount_disbursed', v_loan.amount_principal);
END;
$$;

-- L3. Record a repayment
CREATE OR REPLACE FUNCTION public.rpc_record_repayment(
  p_loan_id uuid,
  p_amount numeric,
  p_payment_method text DEFAULT 'cash',
  p_receipt_ref text DEFAULT NULL,
  p_collected_by text DEFAULT 'system',
  p_payment_date timestamptz DEFAULT now(),
  p_notes text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_loan record;
  v_repayment_id uuid;
  v_new_total_paid numeric;
  v_new_outstanding numeric;
  v_new_status text;
BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan not found');
  END IF;
  IF v_loan.status NOT IN ('active', 'defaulted') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan must be active or defaulted to accept repayment. Current: ' || v_loan.status);
  END IF;
  IF p_amount <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Amount must be greater than 0');
  END IF;

  INSERT INTO public.repayments (loan_id, amount_paid, payment_method, receipt_ref, collected_by, paid_at)
  VALUES (p_loan_id, p_amount, p_payment_method, p_receipt_ref, p_collected_by, p_payment_date)
  RETURNING id INTO v_repayment_id;

  -- Recalculate totals
  SELECT coalesce(sum(amount_paid), 0) INTO v_new_total_paid
  FROM public.repayments WHERE loan_id = p_loan_id AND (is_reversed = false OR is_reversed IS NULL);

  v_new_outstanding := greatest(0, coalesce(v_loan.total_due, v_loan.amount_principal, 0) - v_new_total_paid);
  v_new_status := v_loan.status;

  IF v_new_outstanding <= 0 THEN
    v_new_status := 'completed';
  END IF;

  UPDATE public.loans SET
    total_paid = v_new_total_paid,
    outstanding_balance = v_new_outstanding,
    last_payment_date = p_payment_date::date,
    status = v_new_status,
    days_overdue = CASE WHEN v_new_outstanding <= 0 THEN 0 ELSE days_overdue END,
    in_arrears = CASE WHEN v_new_outstanding <= 0 THEN false ELSE in_arrears END,
    updated_at = now()
  WHERE id = p_loan_id;

  INSERT INTO public.loan_lifecycle_events (loan_id, event_type, from_status, to_status, amount, performed_by, notes, event_date)
  VALUES (p_loan_id, 'repayment', v_loan.status, v_new_status, p_amount, p_collected_by, p_notes, p_payment_date);

  RETURN jsonb_build_object(
    'success', true,
    'repayment_id', v_repayment_id,
    'loan_id', p_loan_id,
    'amount', p_amount,
    'new_total_paid', v_new_total_paid,
    'new_outstanding', v_new_outstanding,
    'new_status', v_new_status
  );
END;
$$;

-- L4. Write off a loan
CREATE OR REPLACE FUNCTION public.rpc_write_off_loan(
  p_loan_id uuid,
  p_written_off_by text DEFAULT 'system',
  p_reason text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_loan record;
BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan not found');
  END IF;
  IF v_loan.status NOT IN ('active', 'defaulted') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Can only write off active or defaulted loans. Current: ' || v_loan.status);
  END IF;

  UPDATE public.loans SET
    status = 'defaulted',
    total_written_off = coalesce(outstanding_balance, 0),
    outstanding_balance = 0,
    updated_at = now()
  WHERE id = p_loan_id;

  INSERT INTO public.loan_lifecycle_events (loan_id, event_type, from_status, to_status, amount, performed_by, notes)
  VALUES (p_loan_id, 'write_off', v_loan.status, 'defaulted', v_loan.outstanding_balance, p_written_off_by, p_reason);

  RETURN jsonb_build_object('success', true, 'loan_id', p_loan_id, 'written_off_amount', v_loan.outstanding_balance);
END;
$$;

-- L5. Reschedule a loan
CREATE OR REPLACE FUNCTION public.rpc_reschedule_loan(
  p_loan_id uuid,
  p_new_duration_months int,
  p_new_interest_rate numeric DEFAULT NULL,
  p_grace_period int DEFAULT 0,
  p_rescheduled_by text DEFAULT 'system',
  p_reason text DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_loan record;
BEGIN
  SELECT * INTO v_loan FROM public.loans WHERE id = p_loan_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Loan not found');
  END IF;
  IF v_loan.status NOT IN ('active', 'defaulted') THEN
    RETURN jsonb_build_object('success', false, 'error', 'Can only reschedule active or defaulted loans');
  END IF;

  UPDATE public.loans SET
    duration_months = p_new_duration_months,
    interest_rate = coalesce(p_new_interest_rate, interest_rate),
    grace_on_principal = p_grace_period,
    maturity_date = start_date + (p_new_duration_months || ' months')::interval,
    expected_maturity_date = start_date + (p_new_duration_months || ' months')::interval,
    status = 'active',
    in_arrears = false,
    days_overdue = 0,
    updated_at = now()
  WHERE id = p_loan_id;

  INSERT INTO public.loan_lifecycle_events (loan_id, event_type, from_status, to_status, performed_by, notes, event_data)
  VALUES (p_loan_id, 'reschedule', v_loan.status, 'active', p_rescheduled_by, p_reason,
    jsonb_build_object(
      'old_duration', v_loan.duration_months,
      'new_duration', p_new_duration_months,
      'old_interest_rate', v_loan.interest_rate,
      'new_interest_rate', coalesce(p_new_interest_rate, v_loan.interest_rate),
      'grace_period', p_grace_period
    )
  );

  RETURN jsonb_build_object('success', true, 'loan_id', p_loan_id, 'new_duration_months', p_new_duration_months);
END;
$$;

-- L6. Get client portfolio summary (for Retool client detail page)
CREATE OR REPLACE FUNCTION public.rpc_client_portfolio(p_client_id uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_client record;
  v_loans jsonb;
  v_savings jsonb;
  v_recent_repayments jsonb;
BEGIN
  SELECT * INTO v_client FROM public.clients WHERE id = p_client_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Client not found');
  END IF;

  SELECT jsonb_agg(jsonb_build_object(
    'loan_id', l.id, 'loan_number', l.loan_number, 'product', l.product_type,
    'principal', l.amount_principal, 'outstanding', l.outstanding_balance,
    'total_paid', l.total_paid, 'status', l.status, 'days_overdue', l.days_overdue,
    'start_date', l.start_date, 'maturity_date', l.maturity_date
  ) ORDER BY l.created_at DESC) INTO v_loans
  FROM public.loans l
  JOIN public.borrowers b ON b.id = l.borrower_id
  WHERE b.fineract_id = v_client.fineract_id OR b.phone_number = v_client.phone_number;

  SELECT jsonb_agg(jsonb_build_object(
    'account_id', sa.id, 'account_number', sa.account_number,
    'product', sa.product_name, 'balance', sa.balance, 'status', sa.status
  )) INTO v_savings
  FROM public.savings_accounts sa WHERE sa.client_id = p_client_id;

  SELECT jsonb_agg(jsonb_build_object(
    'repayment_id', r.id, 'amount', r.amount_paid, 'method', r.payment_method,
    'receipt', r.receipt_ref, 'paid_at', r.paid_at, 'loan_number', l.loan_number
  ) ORDER BY r.paid_at DESC) INTO v_recent_repayments
  FROM public.repayments r
  JOIN public.loans l ON l.id = r.loan_id
  JOIN public.borrowers b ON b.id = l.borrower_id
  WHERE (b.fineract_id = v_client.fineract_id OR b.phone_number = v_client.phone_number)
    AND (r.is_reversed = false OR r.is_reversed IS NULL)
  LIMIT 20;

  RETURN jsonb_build_object(
    'success', true,
    'client', row_to_json(v_client),
    'loans', coalesce(v_loans, '[]'::jsonb),
    'savings', coalesce(v_savings, '[]'::jsonb),
    'recent_repayments', coalesce(v_recent_repayments, '[]'::jsonb)
  );
END;
$$;

-- L7. Dashboard KPIs (single call for Retool dashboard header)
CREATE OR REPLACE FUNCTION public.rpc_dashboard_kpis()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  v_result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'total_clients', (SELECT count(*) FROM public.clients WHERE status = 'active'),
    'total_borrowers', (SELECT count(*) FROM public.borrowers WHERE status = 'active'),
    'active_loans', (SELECT count(*) FROM public.loans WHERE status = 'active'),
    'pending_loans', (SELECT count(*) FROM public.loans WHERE status = 'pending'),
    'total_disbursed', (SELECT coalesce(sum(amount_principal), 0) FROM public.loans),
    'total_outstanding', (SELECT coalesce(sum(outstanding_balance), 0) FROM public.loans WHERE status IN ('active', 'defaulted')),
    'total_collected', (SELECT coalesce(sum(total_paid), 0) FROM public.loans),
    'loans_in_arrears', (SELECT count(*) FROM public.loans WHERE in_arrears = true),
    'total_arrears_amount', (SELECT coalesce(sum(arrears_amount), 0) FROM public.loans WHERE in_arrears = true),
    'npa_count', (SELECT count(*) FROM public.loans WHERE is_npa = true),
    'collection_today', (SELECT coalesce(sum(amount_paid), 0) FROM public.repayments WHERE paid_at::date = current_date AND (is_reversed = false OR is_reversed IS NULL)),
    'collection_this_month', (SELECT coalesce(sum(amount_paid), 0) FROM public.repayments WHERE date_trunc('month', paid_at) = date_trunc('month', current_date) AND (is_reversed = false OR is_reversed IS NULL)),
    'savings_total_balance', (SELECT coalesce(sum(balance), 0) FROM public.savings_accounts WHERE status = 'active'),
    'staff_count', (SELECT count(*) FROM public.staff),
    'last_sync', (SELECT max(completed_at) FROM public.fineract_sync_runs WHERE status = 'completed')
  ) INTO v_result;

  RETURN v_result;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════════
-- PART M: GRANT PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════════

GRANT SELECT ON public.v_portfolio_overview TO service_role, authenticated;
GRANT SELECT ON public.v_loan_officer_performance TO service_role, authenticated;
GRANT SELECT ON public.v_product_performance TO service_role, authenticated;
GRANT SELECT ON public.v_aging_analysis TO service_role, authenticated;
GRANT SELECT ON public.v_daily_collections TO service_role, authenticated;
GRANT SELECT ON public.v_client_360 TO service_role, authenticated;
GRANT SELECT ON public.v_loan_schedule TO service_role, authenticated;
GRANT SELECT ON public.v_loan_audit_trail TO service_role, authenticated;

GRANT SELECT, INSERT, UPDATE ON public.fineract_integrations TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.raw_fineract_clients TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.raw_fineract_loans TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.raw_fineract_transactions TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.raw_fineract_savings TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.fineract_sync_runs TO service_role;
GRANT SELECT, INSERT ON public.fineract_sync_items TO service_role;
GRANT SELECT, INSERT ON public.fineract_reconciliation_snapshots TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.loan_products TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.loan_schedule TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.savings_accounts TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.fineract_offices TO service_role;
GRANT SELECT, INSERT, UPDATE ON public.fineract_staff TO service_role;
GRANT SELECT, INSERT ON public.loan_lifecycle_events TO service_role;

GRANT EXECUTE ON FUNCTION public.rpc_approve_loan TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_disburse_loan TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_record_repayment TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_write_off_loan TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_reschedule_loan TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_client_portfolio TO service_role, authenticated;
GRANT EXECUTE ON FUNCTION public.rpc_dashboard_kpis TO service_role, authenticated;

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
    WHERE table_schema = 'public' AND table_name LIKE 'fineract_%' OR table_name IN ('loan_products', 'loan_schedule', 'savings_accounts', 'loan_lifecycle_events');
  SELECT count(*) INTO view_count FROM information_schema.views
    WHERE table_schema = 'public' AND table_name LIKE 'v_%';
  SELECT count(*) INTO fn_count FROM information_schema.routines
    WHERE routine_schema = 'public' AND routine_name LIKE 'rpc_%';

  RAISE NOTICE '========================================';
  RAISE NOTICE 'FINERACT INTEGRATION MIGRATION COMPLETE';
  RAISE NOTICE 'New tables: %', tbl_count;
  RAISE NOTICE 'Views: %', view_count;
  RAISE NOTICE 'RPC functions: %', fn_count;
  RAISE NOTICE '========================================';
END $$;
