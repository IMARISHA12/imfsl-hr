/**
 * Fineract → Supabase Business Logic
 *
 * Centralizes all transformation, validation, and enrichment rules
 * for mapping Apache Fineract entities to the local database schema.
 *
 * Business Rules:
 *   - Clients map to both `borrowers` and `clients` records
 *   - Loans link to borrowers via fineract_id lookup
 *   - Transactions (repayments) link to loans via fineract_id
 *   - Loan products are cached locally for reference
 *   - Savings accounts track alongside loan portfolios
 *   - Deletions are soft-deletes (status → 'inactive')
 *   - Credit scores re-assessed on loan status changes
 *   - PAR classification based on overdue days
 *   - NPA flagging when overdue > 90 days
 */

import type {
  FineractClient,
  FineractLoan,
  FineractLoanTransaction,
  FineractLoanProduct,
  FineractSavingsAccount,
  FineractOffice,
  FineractStaff,
} from "./fineract-types.ts";
import { fineractDateToISO, mapFineractLoanStatus, mapTransactionType } from "./fineract-types.ts";

// ─── Client Transformation ──────────────────────────────────────────

/**
 * Transform Fineract client → `borrowers` table row.
 */
export function transformFineractClient(c: FineractClient) {
  const fullName = c.displayName || c.fullname ||
    [c.firstname, c.middlename, c.lastname].filter(Boolean).join(" ") || "Unknown";
  const phone = c.mobileNo || "";
  const address = c.address?.[0];
  const nidaId = c.identifiers?.find(
    (id) => id.documentType?.name?.toLowerCase().includes("nida") ||
      id.documentType?.name?.toLowerCase().includes("national"),
  );

  return {
    fineract_id: c.id,
    full_name: fullName,
    phone_number: phone || "0000000000",
    nida_number: nidaId?.documentKey || null,
    email: c.emailAddress || null,
    gender: c.gender?.name || null,
    date_of_birth: fineractDateToISO(c.dateOfBirth) || null,
    status: c.active === false ? "inactive" : "active",
    external_reference_id: `FN-${c.id}`,
    borrower_code: c.accountNo || null,
    address: address ? [address.addressLine1, address.addressLine2, address.city].filter(Boolean).join(", ") : null,
    region: null,
    district: null,
    loan_officer_name: c.staffName || null,
    notes: null,
    updated_at: new Date().toISOString(),
  };
}

/**
 * Transform Fineract client → `clients` table row.
 * Provides the richest profile view for Retool dashboards.
 */
export function transformFineractToClient(c: FineractClient) {
  const names = splitFineractName(c);
  const phone = c.mobileNo || "";
  const address = c.address?.[0];
  const nidaId = c.identifiers?.find(
    (id) => id.documentType?.name?.toLowerCase().includes("nida") ||
      id.documentType?.name?.toLowerCase().includes("national"),
  );

  return {
    fineract_id: c.id,
    first_name: names.first,
    middle_name: names.middle || null,
    last_name: names.last,
    full_name: c.displayName || [names.first, names.middle, names.last].filter(Boolean).join(" "),
    phone_number: phone || "0000000000",
    nida_number: nidaId?.documentKey || null,
    email: c.emailAddress || null,
    gender: c.gender?.name || null,
    date_of_birth: fineractDateToISO(c.dateOfBirth) || null,
    status: c.active === false ? "inactive" : "active",
    external_reference_id: `FN-${c.id}`,
    borrower_code: c.accountNo || null,
    office_id: c.officeId || null,
    staff_id: c.staffId || null,
    activation_date: fineractDateToISO(c.activationDate) || null,
    loan_officer_name: c.staffName || null,
    address: address ? [address.addressLine1, address.addressLine2, address.city].filter(Boolean).join(", ") : null,
    credit_score: 50,
    risk_level: "Medium",
    updated_at: new Date().toISOString(),
  };
}

function splitFineractName(c: FineractClient): { first: string; middle: string; last: string } {
  if (c.firstname || c.lastname) {
    return {
      first: c.firstname || "Unknown",
      middle: c.middlename || "",
      last: c.lastname || "",
    };
  }
  const full = (c.displayName || c.fullname || "Unknown").trim();
  const parts = full.split(/\s+/);
  if (parts.length >= 3) {
    return { first: parts[0], middle: parts.slice(1, -1).join(" "), last: parts[parts.length - 1] };
  }
  if (parts.length === 2) {
    return { first: parts[0], middle: "", last: parts[1] };
  }
  return { first: parts[0] || "Unknown", middle: "", last: "" };
}

// ─── Loan Transformation ────────────────────────────────────────────

/**
 * Transform Fineract loan → `loans` table row.
 */
export function transformFineractLoan(l: FineractLoan, localBorrowerId: string) {
  const summary = l.summary || {};
  const timeline = l.timeline || {};
  const daysOverdue = calculateDaysOverdue(l);

  return {
    fineract_id: l.id,
    borrower_id: localBorrowerId,
    loan_number: l.accountNo || `FN-${l.id}`,
    fineract_product_id: l.loanProductId || null,
    product_type: l.loanProductName || "standard",
    amount_principal: l.principal || l.approvedPrincipal || 0,
    interest_rate: l.interestRatePerPeriod || 0,
    interest_rate_period: l.interestRateFrequencyType?.value?.toLowerCase() || "month",
    interest_method: l.interestType?.value || "declining_balance",
    duration_months: l.numberOfRepayments || l.termFrequency || 1,
    number_of_repayments: l.numberOfRepayments || null,
    amortization_type: l.amortizationType?.value || null,
    repayment_frequency: l.repaymentFrequencyType?.value || "monthly",
    // Grace periods
    grace_on_principal: l.graceOnPrincipalPayment || 0,
    grace_on_interest: l.graceOnInterestPayment || 0,
    // Status
    status: mapFineractLoanStatus(l.status),
    in_arrears: l.inArrears || false,
    is_npa: l.isNPA || false,
    days_overdue: daysOverdue,
    // Dates
    start_date: fineractDateToISO(timeline.actualDisbursementDate || timeline.expectedDisbursementDate) || null,
    disbursed_at: fineractDateToISO(timeline.actualDisbursementDate) || null,
    disbursed_by: timeline.disbursedByUsername || null,
    approved_by: timeline.approvedByUsername || null,
    approved_date: fineractDateToISO(timeline.approvedOnDate) || null,
    maturity_date: fineractDateToISO(timeline.expectedMaturityDate) || null,
    expected_maturity_date: fineractDateToISO(timeline.expectedMaturityDate) || null,
    // Summary amounts
    outstanding_balance: summary.totalOutstanding ?? null,
    total_paid: summary.totalRepayment ?? 0,
    total_expected: summary.totalExpectedRepayment ?? 0,
    total_interest_charged: summary.interestCharged ?? 0,
    interest_paid: summary.interestPaid ?? 0,
    total_fee_charges: summary.feeChargesCharged ?? 0,
    total_penalty_charges: summary.penaltyChargesCharged ?? 0,
    total_waived: summary.totalWaived ?? 0,
    total_written_off: summary.totalWrittenOff ?? 0,
    fees: summary.feeChargesCharged ?? 0,
    penalty_amount: summary.penaltyChargesCharged ?? 0,
    arrears_amount: (summary.principalOverdue || 0) + (summary.interestOverdue || 0) +
      (summary.feeChargesOverdue || 0) + (summary.penaltyChargesOverdue || 0),
    // Officer
    officer_id: l.loanOfficerId ? String(l.loanOfficerId) : null,
    loan_officer_name: l.loanOfficerName || null,
    loan_purpose: l.loanPurposeName || null,
    // Branch
    branch: l.clientOfficeId ? String(l.clientOfficeId) : null,
    notes: null,
    updated_at: new Date().toISOString(),
  };
}

function calculateDaysOverdue(l: FineractLoan): number {
  const overdueSince = l.summary?.overdueSinceDate;
  if (!overdueSince) return 0;
  const overdueDate = fineractDateToISO(overdueSince);
  if (!overdueDate) return 0;
  const diff = Date.now() - new Date(overdueDate).getTime();
  return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
}

// ─── Transaction/Repayment Transformation ───────────────────────────

/**
 * Payment method mapping for Fineract payment types
 */
const PAYMENT_TYPE_MAP: Record<string, string> = {
  cash: "cash",
  "mobile money": "mobile_money",
  "m-pesa": "mobile_money",
  mpesa: "mobile_money",
  "tigo pesa": "mobile_money",
  "airtel money": "mobile_money",
  "bank transfer": "bank_transfer",
  cheque: "cheque",
  check: "cheque",
};

/**
 * Transform Fineract loan transaction → `repayments` table row.
 */
export function transformFineractTransaction(t: FineractLoanTransaction, localLoanId: string) {
  const paymentType = t.paymentDetailData?.paymentType?.name?.toLowerCase() || "";
  const amount = t.amount || 0;

  return {
    fineract_id: t.id,
    loan_id: localLoanId,
    amount_paid: amount,
    payment_method: PAYMENT_TYPE_MAP[paymentType] || "cash",
    receipt_ref: t.paymentDetailData?.receiptNumber || t.externalId || null,
    collected_by: null,
    paid_at: fineractDateToISO(t.date) || new Date().toISOString(),
    transaction_type: mapTransactionType(t.type),
    principal_portion: t.principalPortion || 0,
    interest_portion: t.interestPortion || 0,
    fee_charges_portion: t.feeChargesPortion || 0,
    penalty_charges_portion: t.penaltyChargesPortion || 0,
    outstanding_loan_balance: t.outstandingLoanBalance ?? null,
    is_reversed: t.manuallyReversed || t.reversed || false,
  };
}

// ─── Loan Product Transformation ────────────────────────────────────

export function transformLoanProduct(p: FineractLoanProduct) {
  return {
    fineract_id: p.id,
    name: p.name || "Unknown",
    short_name: p.shortName || null,
    description: p.description || null,
    currency_code: p.currency?.code || "TZS",
    principal_min: p.minPrincipal ?? null,
    principal_default: p.principal ?? null,
    principal_max: p.maxPrincipal ?? null,
    interest_rate_min: p.minInterestRatePerPeriod ?? null,
    interest_rate_default: p.interestRatePerPeriod ?? null,
    interest_rate_max: p.maxInterestRatePerPeriod ?? null,
    interest_rate_frequency: p.interestRateFrequencyType?.value?.toLowerCase() || "per_month",
    interest_method: p.interestType?.value || "declining_balance",
    interest_calculation_period: p.interestCalculationPeriodType?.value || "same_as_repayment",
    repayment_frequency: p.repaymentFrequencyType?.value || "monthly",
    number_of_repayments_min: p.minNumberOfRepayments ?? null,
    number_of_repayments_default: p.numberOfRepayments ?? null,
    number_of_repayments_max: p.maxNumberOfRepayments ?? null,
    amortization_type: p.amortizationType?.value || "equal_installments",
    grace_on_principal: p.graceOnPrincipalPayment || 0,
    grace_on_interest: p.graceOnInterestPayment || 0,
    grace_on_interest_charged: p.graceOnInterestCharged || 0,
    include_in_borrower_cycle: p.includeInBorrowerCycle || false,
    accounting_rule: p.accountingRule?.value || "none",
    is_active: p.isActive !== false,
    updated_at: new Date().toISOString(),
  };
}

// ─── Savings Account Transformation ─────────────────────────────────

export function transformSavingsAccount(s: FineractSavingsAccount, localClientId: string | null, localBorrowerId: string | null) {
  const summary = s.summary || {};
  const statusCode = s.status?.code?.toLowerCase() || "";

  let status = "active";
  if (statusCode.includes("closed")) status = "closed";
  else if (statusCode.includes("withdrawn")) status = "closed";
  else if (statusCode.includes("rejected")) status = "closed";
  else if (statusCode.includes("submitted") || statusCode.includes("pending")) status = "pending";

  return {
    fineract_id: s.id,
    client_id: localClientId,
    borrower_id: localBorrowerId,
    account_number: s.accountNo || `FN-SAV-${s.id}`,
    product_name: s.savingsProductName || null,
    currency_code: s.currency?.code || "TZS",
    nominal_annual_interest_rate: s.nominalAnnualInterestRate || 0,
    balance: summary.accountBalance || 0,
    available_balance: summary.availableBalance ?? summary.accountBalance ?? 0,
    total_deposits: summary.totalDeposits || 0,
    total_withdrawals: summary.totalWithdrawals || 0,
    total_interest_earned: summary.totalInterestEarned || 0,
    status,
    activated_on: fineractDateToISO(s.timeline?.activatedOnDate) || null,
    external_reference_id: `FN-SAV-${s.id}`,
    updated_at: new Date().toISOString(),
  };
}

// ─── Office & Staff Transformation ──────────────────────────────────

export function transformOffice(o: FineractOffice) {
  return {
    fineract_id: o.id,
    name: o.name || "Unknown",
    name_decorated: o.nameDecorated || null,
    parent_id: o.parentId || null,
    hierarchy: o.hierarchy || null,
    opening_date: fineractDateToISO(o.openingDate) || null,
    external_id: o.externalId || null,
  };
}

export function transformStaff(s: FineractStaff) {
  return {
    fineract_id: s.id,
    office_id: s.officeId || null,
    firstname: s.firstname || "Unknown",
    lastname: s.lastname || "",
    display_name: s.displayName || [s.firstname, s.lastname].filter(Boolean).join(" "),
    mobile_no: s.mobileNo || null,
    email_address: s.emailAddress || null,
    is_loan_officer: s.isLoanOfficer || false,
    is_active: s.isActive !== false,
    joining_date: fineractDateToISO(s.joiningDate) || null,
    external_id: s.externalId || null,
    updated_at: new Date().toISOString(),
  };
}

// ─── Loan Schedule Transformation ───────────────────────────────────

export function transformSchedulePeriod(
  period: import("./fineract-types.ts").FineractSchedulePeriod,
  localLoanId: string,
) {
  if (!period.period || period.period === 0) return null; // Skip disbursement period

  return {
    loan_id: localLoanId,
    installment_number: period.period,
    from_date: fineractDateToISO(period.fromDate) || null,
    due_date: fineractDateToISO(period.dueDate) || new Date().toISOString(),
    principal_due: period.principalDue || 0,
    interest_due: period.interestDue || 0,
    fee_charges_due: period.feeChargesDue || 0,
    penalty_charges_due: period.penaltyChargesDue || 0,
    principal_paid: period.principalPaid || 0,
    interest_paid: period.interestPaid || 0,
    fee_charges_paid: period.feeChargesPaid || 0,
    penalty_charges_paid: period.penaltyChargesPaid || 0,
    is_completed: period.complete || false,
  };
}

// ─── Risk Assessment ────────────────────────────────────────────────

/**
 * Re-assess client risk level based on loan portfolio status.
 *
 * Rules:
 *   - days_overdue > 90 or NPA → High risk, score -= 20
 *   - days_overdue > 30       → Medium risk, score -= 10
 *   - all loans current       → Low risk, score += 5 (cap 100)
 *   - any loan defaulted      → High risk, score = max(10, current-30)
 *   - written off             → High risk, score = 10
 */
export function assessRisk(
  currentScore: number,
  currentRisk: string,
  daysOverdue: number,
  loanStatus: string,
  isNPA = false,
): { credit_score: number; risk_level: string } {
  let score = currentScore;
  let risk = currentRisk;

  if (isNPA || loanStatus === "defaulted") {
    score = Math.max(10, score - 30);
    risk = "High";
  } else if (daysOverdue > 90) {
    score = Math.max(10, score - 20);
    risk = "High";
  } else if (daysOverdue > 30) {
    score = Math.max(10, score - 10);
    risk = "Medium";
  } else if (loanStatus === "completed" && daysOverdue === 0) {
    score = Math.min(100, score + 5);
    risk = score >= 70 ? "Low" : "Medium";
  }

  return { credit_score: score, risk_level: risk };
}

// ─── Validation ─────────────────────────────────────────────────────

export function validateClient(c: FineractClient): string | null {
  if (!c.id || !Number.isFinite(c.id)) return "Missing or invalid Fineract client ID";
  if (!c.firstname && !c.lastname && !c.displayName && !c.fullname) {
    return "Client must have a name";
  }
  return null;
}

export function validateLoan(l: FineractLoan): string | null {
  if (!l.id || !Number.isFinite(l.id)) return "Missing or invalid Fineract loan ID";
  if (!l.clientId) return "Loan must have a clientId";
  const principal = l.principal || l.approvedPrincipal || 0;
  if (principal <= 0) return "Loan principal must be greater than 0";
  return null;
}

export function validateTransaction(t: FineractLoanTransaction): string | null {
  if (!t.id || !Number.isFinite(t.id)) return "Missing or invalid transaction ID";
  if (!t.amount || t.amount <= 0) return "Transaction amount must be greater than 0";
  return null;
}
