/**
 * Shared LoanDisk types used across all webhook and sync Edge Functions.
 *
 * These types are flexible to handle variations in LoanDisk's API response
 * formats across different versions and endpoints.
 */

// ─── Borrower ────────────────────────────────────────────────────────

export interface LoandiskBorrower {
  borrower_id?: number | string;
  id?: number | string;
  branch_id?: number | string;
  first_name?: string;
  last_name?: string;
  middle_name?: string;
  full_name?: string;
  phone_number?: string;
  mobile?: string;
  email?: string;
  nida_number?: string;
  national_id?: string;
  gender?: string;
  date_of_birth?: string;
  address?: string;
  city?: string;
  region?: string;
  district?: string;
  street?: string;
  business_type?: string;
  business_name?: string;
  business_location?: string;
  revenue_estimate?: number;
  next_of_kin_name?: string;
  next_of_kin_relationship?: string;
  next_of_kin_phone?: string;
  photo_url?: string;
  status?: string;
  [key: string]: unknown;
}

// ─── Loan ────────────────────────────────────────────────────────────

export interface LoandiskLoan {
  loan_id?: number | string;
  id?: number | string;
  borrower_id?: number | string;
  branch_id?: number | string;
  loan_number?: string;
  loan_product?: string;
  loan_product_id?: number | string;
  product_type?: string;
  principal_amount?: number;
  amount?: number;
  interest_rate?: number;
  rate?: number;
  interest_method?: string;
  duration?: number;
  duration_months?: number;
  duration_period?: string;
  repayment_frequency?: string;
  total_due?: number;
  total_amount?: number;
  outstanding_balance?: number;
  balance?: number;
  amount_paid?: number;
  total_paid?: number;
  status?: string;
  disbursed_date?: string;
  disbursed_at?: string;
  start_date?: string;
  end_date?: string;
  maturity_date?: string;
  approved_by?: string;
  approved_date?: string;
  officer_id?: string | number;
  loan_officer?: string;
  purpose?: string;
  loan_purpose?: string;
  collateral?: string;
  collateral_value?: number;
  penalty_amount?: number;
  days_overdue?: number;
  days_in_arrears?: number;
  last_payment_date?: string;
  next_payment_date?: string;
  created_at?: string;
  updated_at?: string;
  [key: string]: unknown;
}

// ─── Repayment ───────────────────────────────────────────────────────

export interface LoandiskRepayment {
  repayment_id?: number | string;
  id?: number | string;
  loan_id?: number | string;
  borrower_id?: number | string;
  branch_id?: number | string;
  amount?: number;
  amount_paid?: number;
  payment_amount?: number;
  principal_paid?: number;
  interest_paid?: number;
  penalty_paid?: number;
  payment_method?: string;
  payment_type?: string;
  receipt_number?: string;
  receipt_ref?: string;
  reference?: string;
  transaction_id?: string;
  payment_date?: string;
  paid_at?: string;
  collected_by?: string;
  collector_name?: string;
  notes?: string;
  status?: string;
  [key: string]: unknown;
}

// ─── Webhook Payloads ────────────────────────────────────────────────

export interface WebhookPayload {
  event?: string;
  event_type?: string;
  action?: string;
  data?: Record<string, unknown>;
  borrower?: LoandiskBorrower;
  loan?: LoandiskLoan;
  repayment?: LoandiskRepayment;
  [key: string]: unknown;
}

// ─── Sync Status ─────────────────────────────────────────────────────

export interface SyncResult {
  action: string;
  localId: string | null;
  externalRef: string;
  entityType: string;
  error?: string;
}
