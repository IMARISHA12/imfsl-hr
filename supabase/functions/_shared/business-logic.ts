/**
 * LoanDisk → Supabase Business Logic
 *
 * Centralizes all transformation, validation, and enrichment rules
 * for mapping LoanDisk entities to the local database schema.
 *
 * Business Rules:
 *   - Borrowers become both `borrowers` and `clients` records
 *   - Loans link to borrowers via external_reference_id lookup
 *   - Repayments link to loans via loan external_reference_id lookup
 *   - Deletions are soft-deletes (status → 'inactive' / 'cancelled')
 *   - Credit scores default to 50, risk_level to 'Medium'
 *   - Loan status mapping: LoanDisk statuses → local statuses
 *   - Overdue calculations trigger risk level re-assessment
 */

import type {
  LoandiskBorrower,
  LoandiskLoan,
  LoandiskRepayment,
} from "./loandisk-types.ts";

// ─── Borrower Transformation ─────────────────────────────────────────

export function splitName(b: LoandiskBorrower): { first: string; middle: string; last: string } {
  if (b.first_name || b.last_name) {
    return {
      first: b.first_name || "Unknown",
      middle: b.middle_name || "",
      last: b.last_name || "",
    };
  }
  const full = (b.full_name || "Unknown").trim();
  const parts = full.split(/\s+/);
  if (parts.length >= 3) {
    return { first: parts[0], middle: parts.slice(1, -1).join(" "), last: parts[parts.length - 1] };
  }
  if (parts.length === 2) {
    return { first: parts[0], middle: "", last: parts[1] };
  }
  return { first: parts[0] || "Unknown", middle: "", last: "" };
}

export function buildFullName(b: LoandiskBorrower): string {
  if (b.full_name) return b.full_name.trim();
  const parts = [b.first_name, b.middle_name, b.last_name].filter(Boolean);
  return parts.join(" ").trim() || "Unknown";
}

export function resolvePhone(b: LoandiskBorrower): string {
  return (b.phone_number || b.mobile || "").trim() || "0000000000";
}

export function resolveNida(b: LoandiskBorrower): string | null {
  return b.nida_number || b.national_id || null;
}

function resolveGps(b: LoandiskBorrower): { lat: number | null; lng: number | null } {
  const lat = b.gps_latitude != null ? Number(b.gps_latitude) : null;
  const lng = b.gps_longitude != null ? Number(b.gps_longitude) : null;
  return {
    lat: lat != null && Number.isFinite(lat) ? lat : null,
    lng: lng != null && Number.isFinite(lng) ? lng : null,
  };
}

/**
 * Transform LoanDisk borrower → `borrowers` table row.
 * Captures the full borrower profile from LoanDisk.
 */
export function transformBorrower(b: LoandiskBorrower) {
  const gps = resolveGps(b);
  return {
    full_name: buildFullName(b),
    phone_number: resolvePhone(b),
    nida_number: resolveNida(b),
    location_gps: b.region ? `${b.region}${b.district ? ', ' + b.district : ''}` : null,
    status: b.status || "active",
    // Extended fields
    borrower_code: b.borrower_code || null,
    email: b.email || null,
    gender: b.gender || null,
    date_of_birth: b.date_of_birth || null,
    marital_status: b.marital_status || null,
    credit_rating: b.credit_rating || b.credit || null,
    // Business
    business_name: b.business_name || null,
    business_type: b.business_type || null,
    business_role: b.business_role || b.occupation || null,
    business_location: b.business_location || null,
    revenue_estimate: b.revenue_estimate ?? null,
    // Location
    address: b.address || b.location || null,
    region: b.region || null,
    district: b.district || null,
    street: b.street || null,
    gps_latitude: gps.lat,
    gps_longitude: gps.lng,
    // Contact
    alternative_phone: b.alternative_phone || null,
    // Banking
    bank_name: b.bank_name || null,
    bank_account_number: b.bank_account_number || b.bank_account || null,
    // Documents
    drivers_license: b.drivers_license || b.driving_license || null,
    vehicle_info: b.vehicle_info || b.vehicle || null,
    photo_url: b.photo_url || null,
    // Guarantor / Next of kin
    next_of_kin_name: b.next_of_kin_name || null,
    next_of_kin_relationship: b.next_of_kin_relationship || null,
    next_of_kin_phone: b.next_of_kin_phone || null,
    guarantor_name: b.guarantor_name || null,
    guarantor_phone: b.guarantor_phone || null,
    guarantor_relationship: b.guarantor_relationship || null,
    // Officer
    loan_officer_name: b.loan_officer_name || b.loan_officer || null,
    // Notes
    notes: b.notes || b.other_info || null,
    updated_at: new Date().toISOString(),
  };
}

/**
 * Transform LoanDisk borrower → `clients` table row.
 * Provides the richest profile view for Retool dashboards.
 */
export function transformClient(b: LoandiskBorrower, externalRef: string) {
  const names = splitName(b);
  const gps = resolveGps(b);
  return {
    first_name: names.first,
    middle_name: names.middle || null,
    last_name: names.last,
    full_name: buildFullName(b),
    phone_number: resolvePhone(b),
    nida_number: resolveNida(b),
    status: b.status || "active",
    external_reference_id: externalRef,
    // Extended profile
    borrower_code: b.borrower_code || null,
    gender: b.gender || null,
    date_of_birth: b.date_of_birth || null,
    marital_status: b.marital_status || null,
    credit_rating: b.credit_rating || b.credit || null,
    // Business
    business_type: b.business_type || null,
    business_name: b.business_name || null,
    business_role: b.business_role || b.occupation || null,
    business_location: b.business_location || null,
    revenue_estimate: b.revenue_estimate ?? null,
    // Location
    address: b.address || b.location || null,
    region: b.region || null,
    district: b.district || null,
    street: b.street || null,
    gps_latitude: gps.lat,
    gps_longitude: gps.lng,
    // Contact
    alternative_phone: b.alternative_phone || null,
    next_of_kin_name: b.next_of_kin_name || null,
    next_of_kin_relationship: b.next_of_kin_relationship || null,
    next_of_kin_phone: b.next_of_kin_phone || null,
    guarantor_name: b.guarantor_name || null,
    guarantor_phone: b.guarantor_phone || null,
    guarantor_relationship: b.guarantor_relationship || null,
    // Banking
    bank_name: b.bank_name || null,
    bank_account_number: b.bank_account_number || b.bank_account || null,
    // Documents
    drivers_license: b.drivers_license || b.driving_license || null,
    vehicle_info: b.vehicle_info || b.vehicle || null,
    photo_url: b.photo_url || null,
    // Officer / Notes
    loan_officer_name: b.loan_officer_name || b.loan_officer || null,
    notes: b.notes || b.other_info || null,
    updated_at: new Date().toISOString(),
  };
}

// ─── Loan Transformation ─────────────────────────────────────────────

// Valid DB statuses: active, pending, defaulted, completed
// (closed requires total_paid >= total_due; cancelled/rejected/restructured not allowed)
const LOAN_STATUS_MAP: Record<string, string> = {
  active: "active",
  open: "active",
  current: "active",
  disbursed: "active",
  pending: "pending",
  approved: "pending",
  processing: "pending",
  closed: "completed",
  paid: "completed",
  fully_paid: "completed",
  settled: "completed",
  completed: "completed",
  written_off: "defaulted",
  default: "defaulted",
  defaulted: "defaulted",
  rejected: "defaulted",
  cancelled: "defaulted",
  restructured: "active",
};

export function mapLoanStatus(raw: string | undefined): string {
  if (!raw) return "pending";
  return LOAN_STATUS_MAP[raw.toLowerCase().trim()] || "pending";
}

/**
 * Resolve the principal amount from various LoanDisk field names.
 */
function resolvePrincipal(l: LoandiskLoan): number {
  const raw = l.principal_amount ?? l.amount ?? 0;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 0;
}

function resolveInterestRate(l: LoandiskLoan): number {
  const raw = l.interest_rate ?? l.rate ?? 0;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 0;
}

function resolveDuration(l: LoandiskLoan): number {
  const raw = l.duration_months ?? l.duration ?? 1;
  const num = Number(raw);
  return Number.isFinite(num) && num > 0 ? num : 1;
}

function resolveOutstanding(l: LoandiskLoan): number | null {
  const raw = l.outstanding_balance ?? l.balance;
  if (raw == null) return null;
  const num = Number(raw);
  return Number.isFinite(num) ? num : null;
}

function resolveTotalPaid(l: LoandiskLoan): number {
  const raw = l.amount_paid ?? l.total_paid ?? 0;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 0;
}

function resolveDaysOverdue(l: LoandiskLoan): number {
  const raw = l.days_overdue ?? l.days_in_arrears ?? 0;
  const num = Number(raw);
  return Number.isFinite(num) ? num : 0;
}

/**
 * Transform LoanDisk loan → `loans` table row.
 *
 * Note: total_due is a GENERATED column (computed from principal * rate),
 *       so we never include it in inserts/updates.
 */
export function transformLoan(l: LoandiskLoan, localBorrowerId: string) {
  const interestPaid = l.interest_paid != null ? Number(l.interest_paid) : null;
  const penaltyAmount = l.penalty_amount != null ? Number(l.penalty_amount) : null;
  const collateralValue = l.collateral_value != null ? Number(l.collateral_value) : null;

  return {
    borrower_id: localBorrowerId,
    amount_principal: resolvePrincipal(l),
    interest_rate: resolveInterestRate(l),
    duration_months: resolveDuration(l),
    start_date: l.start_date || l.disbursed_date || l.disbursed_at || l.released_date || null,
    status: mapLoanStatus(l.status),
    approved_by: l.approved_by || null,
    loan_number: l.loan_number || null,
    officer_id: l.officer_id ? String(l.officer_id) : null,
    outstanding_balance: resolveOutstanding(l),
    total_paid: resolveTotalPaid(l),
    days_overdue: resolveDaysOverdue(l),
    last_payment_date: l.last_payment_date || null,
    product_type: l.product_type || l.loan_product || "sme_group",
    disbursed_at: l.disbursed_at || l.disbursed_date || l.released_date || null,
    branch: l.branch_id ? String(l.branch_id) : null,
    // Extended fields
    maturity_date: l.maturity_date || l.end_date || null,
    interest_method: l.interest_method || null,
    interest_rate_period: l.interest_rate_period || l.duration_period || "month",
    interest_paid: interestPaid != null && Number.isFinite(interestPaid) ? interestPaid : null,
    penalty_amount: penaltyAmount != null && Number.isFinite(penaltyAmount) ? penaltyAmount : null,
    disbursed_by: l.disbursed_by || null,
    repayment_frequency: l.repayment_frequency || null,
    next_payment_date: l.next_payment_date || null,
    loan_purpose: l.loan_purpose || l.purpose || null,
    collateral: l.collateral || null,
    collateral_value: collateralValue != null && Number.isFinite(collateralValue) ? collateralValue : null,
    loan_officer_name: l.loan_officer_name || l.loan_officer || null,
    approved_date: l.approved_date || null,
    notes: l.notes || null,
    updated_at: new Date().toISOString(),
  };
}

// ─── Repayment Transformation ────────────────────────────────────────

const PAYMENT_METHOD_MAP: Record<string, string> = {
  cash: "cash",
  mobile_money: "mobile_money",
  mpesa: "mobile_money",
  "m-pesa": "mobile_money",
  tigo_pesa: "mobile_money",
  airtel_money: "mobile_money",
  bank_transfer: "bank_transfer",
  bank: "bank_transfer",
  cheque: "cheque",
  check: "cheque",
};

function mapPaymentMethod(raw: string | undefined): string {
  if (!raw) return "cash";
  return PAYMENT_METHOD_MAP[raw.toLowerCase().trim()] || "cash";
}

/**
 * Transform LoanDisk repayment → `repayments` table row.
 *
 * repayments schema:
 *   id, loan_id(FK→loans, NOT NULL), amount_paid(NOT NULL),
 *   payment_method(default:'cash'), receipt_ref, collected_by, paid_at
 */
export function transformRepayment(r: LoandiskRepayment, localLoanId: string) {
  const amount = Number(r.amount_paid ?? r.amount ?? r.payment_amount ?? 0);
  return {
    loan_id: localLoanId,
    amount_paid: Number.isFinite(amount) ? amount : 0,
    payment_method: mapPaymentMethod(r.payment_method || r.payment_type),
    receipt_ref: r.receipt_number || r.receipt_ref || r.reference || r.transaction_id || null,
    collected_by: r.collected_by || r.collector_name || null,
    paid_at: r.payment_date || r.paid_at || new Date().toISOString(),
  };
}

// ─── Risk Assessment ─────────────────────────────────────────────────

/**
 * Re-assess client risk level based on loan portfolio status.
 *
 * Rules:
 *   - days_overdue > 90  → High risk, score -= 20
 *   - days_overdue > 30  → Medium risk, score -= 10
 *   - all loans current   → Low risk, score += 5 (cap 100)
 *   - any loan defaulted  → High risk, score = max(10, current-30)
 */
export function assessRisk(
  currentScore: number,
  currentRisk: string,
  daysOverdue: number,
  loanStatus: string,
): { credit_score: number; risk_level: string } {
  let score = currentScore;
  let risk = currentRisk;

  if (loanStatus === "defaulted") {
    score = Math.max(10, score - 30);
    risk = "High";
  } else if (daysOverdue > 90) {
    score = Math.max(10, score - 20);
    risk = "High";
  } else if (daysOverdue > 30) {
    score = Math.max(10, score - 10);
    risk = "Medium";
  } else if (loanStatus === "closed" && daysOverdue === 0) {
    score = Math.min(100, score + 5);
    risk = score >= 70 ? "Low" : "Medium";
  }

  return { credit_score: score, risk_level: risk };
}

// ─── Deletion / Deactivation Cascade ─────────────────────────────────

/**
 * Describes what should happen when a LoanDisk entity is deleted.
 * We never hard-delete; all deletions are status changes.
 */
export const CASCADE_RULES = {
  borrower: {
    /**
     * When a borrower is deleted:
     * 1. borrowers.status → 'inactive'
     * 2. clients.status → 'inactive'
     * 3. All active loans for that borrower → 'defaulted'
     * 4. Log the cascade in access_log
     */
    affectedTables: ["borrowers", "clients", "loans"],
  },
  loan: {
    /**
     * When a loan is deleted:
     * 1. loans.status → 'defaulted'
     * 2. Update client risk (if applicable)
     */
    affectedTables: ["loans"],
  },
  repayment: {
    /**
     * When a repayment is deleted:
     * 1. Delete the repayment record (hard delete ok for repayments reversal)
     * 2. Recalculate loan.total_paid and loan.outstanding_balance
     */
    affectedTables: ["repayments", "loans"],
  },
};

// ─── Validation ──────────────────────────────────────────────────────

export function validateBorrower(b: LoandiskBorrower): string | null {
  const id = b.borrower_id ?? b.id;
  if (id == null || !Number.isFinite(Number(id))) {
    return "Missing or invalid borrower_id";
  }
  if (!b.first_name && !b.last_name && !b.full_name) {
    return "Borrower must have at least a name (first_name, last_name, or full_name)";
  }
  return null;
}

export function validateLoan(l: LoandiskLoan): string | null {
  const id = l.loan_id ?? l.id;
  if (id == null || !Number.isFinite(Number(id))) {
    return "Missing or invalid loan_id";
  }
  if (l.borrower_id == null) {
    return "Loan must have a borrower_id";
  }
  const principal = resolvePrincipal(l);
  if (principal <= 0) {
    return "Loan principal must be greater than 0";
  }
  return null;
}

export function validateRepayment(r: LoandiskRepayment): string | null {
  const id = r.repayment_id ?? r.id;
  if (id == null || !Number.isFinite(Number(id))) {
    return "Missing or invalid repayment_id";
  }
  if (r.loan_id == null) {
    return "Repayment must have a loan_id";
  }
  const amount = Number(r.amount_paid ?? r.amount ?? r.payment_amount ?? 0);
  if (!Number.isFinite(amount) || amount <= 0) {
    return "Repayment amount must be greater than 0";
  }
  return null;
}
