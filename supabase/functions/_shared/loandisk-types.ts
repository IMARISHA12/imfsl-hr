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
  // Identity
  borrower_code?: string;
  title?: string;
  first_name?: string;
  last_name?: string;
  middle_name?: string;
  full_name?: string;
  phone_number?: string;
  mobile?: string;
  email?: string;
  alternative_phone?: string;
  nida_number?: string;
  national_id?: string;
  gender?: string;
  date_of_birth?: string;
  marital_status?: string;
  age?: number;
  // Credit
  credit_rating?: string;
  credit?: string;
  // Location
  address?: string;
  city?: string;
  region?: string;
  district?: string;
  street?: string;
  gps_latitude?: number | string;
  gps_longitude?: number | string;
  location?: string;
  // Business
  business_type?: string;
  business_name?: string;
  business_location?: string;
  business_role?: string;
  occupation?: string;
  revenue_estimate?: number;
  // Banking
  bank_name?: string;
  bank_account?: string;
  bank_account_number?: string;
  // Documents
  drivers_license?: string;
  driving_license?: string;
  vehicle_info?: string;
  vehicle?: string;
  nida_scan_url?: string;
  drivers_license_scan_url?: string;
  photo_url?: string;
  // Guarantor / Next of kin
  next_of_kin_name?: string;
  next_of_kin_relationship?: string;
  next_of_kin_phone?: string;
  guarantor_name?: string;
  guarantor_phone?: string;
  guarantor_relationship?: string;
  // Officer
  loan_officer?: string;
  loan_officer_name?: string;
  // Notes / custom fields
  notes?: string;
  other_info?: string;
  heading_address?: string;
  chairman_name?: string;
  visited_by?: string;
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
  // Amounts
  principal_amount?: number;
  amount?: number;
  interest_rate?: number;
  rate?: number;
  interest_method?: string;
  interest_rate_period?: string;
  interest_paid?: number;
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
  penalty_amount?: number;
  fees?: number;
  fee_amount?: number;
  // Status
  status?: string;
  // Dates
  disbursed_date?: string;
  disbursed_at?: string;
  disbursed_by?: string;
  start_date?: string;
  end_date?: string;
  maturity_date?: string;
  released_date?: string;
  // Approval
  approved_by?: string;
  approved_date?: string;
  // Officer
  officer_id?: string | number;
  loan_officer?: string;
  loan_officer_name?: string;
  // Purpose / Collateral
  purpose?: string;
  loan_purpose?: string;
  collateral?: string;
  collateral_value?: number;
  // Overdue
  days_overdue?: number;
  days_in_arrears?: number;
  days_past?: number;
  last_payment_date?: string;
  next_payment_date?: string;
  // Notes
  notes?: string;
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
