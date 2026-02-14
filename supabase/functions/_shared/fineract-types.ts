/**
 * Apache Fineract types used across all Edge Functions.
 *
 * Based on Apache Fineract REST API v1 data structures.
 * Fineract uses numeric IDs and nested objects for related entities.
 */

// ─── Client ─────────────────────────────────────────────────────────

export interface FineractClient {
  id: number;
  accountNo?: string;
  externalId?: string;
  status?: { id: number; code: string; value: string };
  active?: boolean;
  activationDate?: number[];
  firstname?: string;
  middlename?: string;
  lastname?: string;
  displayName?: string;
  fullname?: string;
  mobileNo?: string;
  emailAddress?: string;
  dateOfBirth?: number[];
  gender?: { id: number; name: string; isActive: boolean };
  officeId?: number;
  officeName?: string;
  staffId?: number;
  staffName?: string;
  savingsAccountId?: number;
  savingsProductId?: number;
  // Timeline
  timeline?: {
    submittedOnDate?: number[];
    submittedByUsername?: string;
    activatedOnDate?: number[];
    activatedByUsername?: string;
  };
  // Groups
  groups?: { id: number; name: string }[];
  // Address (custom)
  address?: FineractAddress[];
  // Identifiers
  identifiers?: FineractIdentifier[];
  [key: string]: unknown;
}

export interface FineractAddress {
  addressTypeId?: number;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  stateProvinceId?: number;
  countryId?: number;
  postalCode?: string;
}

export interface FineractIdentifier {
  id?: number;
  clientId?: number;
  documentTypeId?: number;
  documentType?: { id: number; name: string };
  documentKey?: string;
  description?: string;
  status?: string;
}

// ─── Loan ───────────────────────────────────────────────────────────

export interface FineractLoan {
  id: number;
  accountNo?: string;
  externalId?: string;
  clientId?: number;
  clientName?: string;
  clientAccountNo?: string;
  clientOfficeId?: number;
  loanProductId?: number;
  loanProductName?: string;
  loanProductDescription?: string;
  loanOfficerId?: number;
  loanOfficerName?: string;
  loanPurposeId?: number;
  loanPurposeName?: string;
  loanType?: { id: number; code: string; value: string };
  // Amounts
  principal?: number;
  approvedPrincipal?: number;
  proposedPrincipal?: number;
  netDisbursalAmount?: number;
  // Interest
  interestRatePerPeriod?: number;
  interestRateFrequencyType?: { id: number; code: string; value: string };
  annualInterestRate?: number;
  interestType?: { id: number; code: string; value: string };
  interestCalculationPeriodType?: { id: number; code: string; value: string };
  // Terms
  termFrequency?: number;
  termPeriodFrequencyType?: { id: number; code: string; value: string };
  numberOfRepayments?: number;
  repaymentEvery?: number;
  repaymentFrequencyType?: { id: number; code: string; value: string };
  // Amortization
  amortizationType?: { id: number; code: string; value: string };
  // Grace periods
  graceOnPrincipalPayment?: number;
  graceOnInterestPayment?: number;
  graceOnInterestCharged?: number;
  graceOnArrearsAgeing?: number;
  // Status
  status?: { id: number; code: string; value: string };
  inArrears?: boolean;
  isNPA?: boolean;
  // Dates
  timeline?: {
    submittedOnDate?: number[];
    submittedByUsername?: string;
    approvedOnDate?: number[];
    approvedByUsername?: string;
    expectedDisbursementDate?: number[];
    actualDisbursementDate?: number[];
    disbursedByUsername?: string;
    expectedMaturityDate?: number[];
    closedOnDate?: number[];
    writtenOffOnDate?: number[];
  };
  // Summary
  summary?: {
    principalDisbursed?: number;
    principalPaid?: number;
    principalWrittenOff?: number;
    principalOutstanding?: number;
    principalOverdue?: number;
    interestCharged?: number;
    interestPaid?: number;
    interestWaived?: number;
    interestWrittenOff?: number;
    interestOutstanding?: number;
    interestOverdue?: number;
    feeChargesCharged?: number;
    feeChargesDueAtDisbursementCharged?: number;
    feeChargesPaid?: number;
    feeChargesWaived?: number;
    feeChargesWrittenOff?: number;
    feeChargesOutstanding?: number;
    feeChargesOverdue?: number;
    penaltyChargesCharged?: number;
    penaltyChargesPaid?: number;
    penaltyChargesWaived?: number;
    penaltyChargesWrittenOff?: number;
    penaltyChargesOutstanding?: number;
    penaltyChargesOverdue?: number;
    totalExpectedRepayment?: number;
    totalRepayment?: number;
    totalExpectedCostOfLoan?: number;
    totalCostOfLoan?: number;
    totalWaived?: number;
    totalWrittenOff?: number;
    totalOutstanding?: number;
    totalOverdue?: number;
    totalRecovered?: number;
    overdueSinceDate?: number[];
  };
  // Repayment schedule
  repaymentSchedule?: {
    currency?: { code: string; name: string; decimalPlaces: number };
    loanTermInDays?: number;
    totalPrincipalDisbursed?: number;
    totalPrincipalExpected?: number;
    totalPrincipalPaid?: number;
    totalInterestCharged?: number;
    totalFeeChargesCharged?: number;
    totalPenaltyChargesCharged?: number;
    totalWaived?: number;
    totalWrittenOff?: number;
    totalRepaymentExpected?: number;
    totalRepayment?: number;
    totalPaidInAdvance?: number;
    totalPaidLate?: number;
    totalOutstanding?: number;
    periods?: FineractSchedulePeriod[];
  };
  // Collateral
  collateral?: unknown[];
  // Currency
  currency?: { code: string; name: string; decimalPlaces: number; displaySymbol: string };
  [key: string]: unknown;
}

export interface FineractSchedulePeriod {
  period?: number;
  fromDate?: number[];
  dueDate?: number[];
  complete?: boolean;
  daysInPeriod?: number;
  principalDisbursed?: number;
  principalLoanBalanceOutstanding?: number;
  principalDue?: number;
  principalPaid?: number;
  principalWrittenOff?: number;
  principalOutstanding?: number;
  principalOriginalDue?: number;
  interestDue?: number;
  interestPaid?: number;
  interestWaived?: number;
  interestWrittenOff?: number;
  interestOutstanding?: number;
  feeChargesDue?: number;
  feeChargesPaid?: number;
  feeChargesWaived?: number;
  feeChargesWrittenOff?: number;
  feeChargesOutstanding?: number;
  penaltyChargesDue?: number;
  penaltyChargesPaid?: number;
  penaltyChargesWaived?: number;
  penaltyChargesWrittenOff?: number;
  penaltyChargesOutstanding?: number;
  totalDueForPeriod?: number;
  totalPaidForPeriod?: number;
  totalPaidInAdvanceForPeriod?: number;
  totalPaidLateForPeriod?: number;
  totalWaivedForPeriod?: number;
  totalWrittenOffForPeriod?: number;
  totalOutstandingForPeriod?: number;
  totalActualCostOfLoanForPeriod?: number;
}

// ─── Loan Transaction ───────────────────────────────────────────────

export interface FineractLoanTransaction {
  id: number;
  type?: { id: number; code: string; value: string };
  date?: number[];
  currency?: { code: string; name: string; decimalPlaces: number };
  amount?: number;
  principalPortion?: number;
  interestPortion?: number;
  feeChargesPortion?: number;
  penaltyChargesPortion?: number;
  overpaymentPortion?: number;
  unrecognizedIncomePortion?: number;
  outstandingLoanBalance?: number;
  submittedOnDate?: number[];
  manuallyReversed?: boolean;
  reversed?: boolean;
  paymentDetailData?: {
    paymentType?: { id: number; name: string };
    accountNumber?: string;
    checkNumber?: string;
    routingCode?: string;
    receiptNumber?: string;
    bankNumber?: string;
  };
  externalId?: string;
  [key: string]: unknown;
}

// ─── Loan Product ───────────────────────────────────────────────────

export interface FineractLoanProduct {
  id: number;
  name?: string;
  shortName?: string;
  description?: string;
  currency?: { code: string; name: string; decimalPlaces: number };
  principal?: number;
  minPrincipal?: number;
  maxPrincipal?: number;
  numberOfRepayments?: number;
  minNumberOfRepayments?: number;
  maxNumberOfRepayments?: number;
  repaymentEvery?: number;
  repaymentFrequencyType?: { id: number; code: string; value: string };
  interestRatePerPeriod?: number;
  minInterestRatePerPeriod?: number;
  maxInterestRatePerPeriod?: number;
  interestRateFrequencyType?: { id: number; code: string; value: string };
  annualInterestRate?: number;
  amortizationType?: { id: number; code: string; value: string };
  interestType?: { id: number; code: string; value: string };
  interestCalculationPeriodType?: { id: number; code: string; value: string };
  transactionProcessingStrategyId?: number;
  graceOnPrincipalPayment?: number;
  graceOnInterestPayment?: number;
  graceOnInterestCharged?: number;
  includeInBorrowerCycle?: boolean;
  accountingRule?: { id: number; code: string; value: string };
  isActive?: boolean;
  [key: string]: unknown;
}

// ─── Savings Account ────────────────────────────────────────────────

export interface FineractSavingsAccount {
  id: number;
  accountNo?: string;
  externalId?: string;
  clientId?: number;
  clientName?: string;
  savingsProductId?: number;
  savingsProductName?: string;
  status?: { id: number; code: string; value: string };
  currency?: { code: string; name: string; decimalPlaces: number };
  nominalAnnualInterestRate?: number;
  summary?: {
    totalDeposits?: number;
    totalWithdrawals?: number;
    totalInterestEarned?: number;
    totalInterestPosted?: number;
    accountBalance?: number;
    totalOverdraftInterestDerived?: number;
    availableBalance?: number;
  };
  timeline?: {
    submittedOnDate?: number[];
    activatedOnDate?: number[];
    closedOnDate?: number[];
  };
  [key: string]: unknown;
}

// ─── Office & Staff ─────────────────────────────────────────────────

export interface FineractOffice {
  id: number;
  name?: string;
  nameDecorated?: string;
  externalId?: string;
  openingDate?: number[];
  hierarchy?: string;
  parentId?: number;
  parentName?: string;
}

export interface FineractStaff {
  id: number;
  officeId?: number;
  officeName?: string;
  firstname?: string;
  lastname?: string;
  displayName?: string;
  mobileNo?: string;
  emailAddress?: string;
  isLoanOfficer?: boolean;
  isActive?: boolean;
  joiningDate?: number[];
  externalId?: string;
}

// ─── Webhook / Hook Payload ─────────────────────────────────────────

export interface FineractHookPayload {
  action?: string;
  entity?: string;
  body?: Record<string, unknown>;
  resourceId?: number;
  subresourceId?: number;
  timestamp?: string;
  tenantIdentifier?: string;
  [key: string]: unknown;
}

// ─── Sync Status ────────────────────────────────────────────────────

export interface SyncResult {
  action: string;
  localId: string | null;
  externalRef: string;
  entityType: string;
  error?: string;
}

// ─── Helpers ────────────────────────────────────────────────────────

/**
 * Convert Fineract date array [year, month, day] to ISO date string.
 * Fineract returns dates as [2026, 2, 14] format.
 */
export function fineractDateToISO(dateArr: number[] | undefined | null): string | null {
  if (!dateArr || !Array.isArray(dateArr) || dateArr.length < 3) return null;
  const [year, month, day] = dateArr;
  return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
}

/**
 * Convert ISO date string to Fineract date format "dd MMMM yyyy".
 */
export function isoToFineractDate(iso: string | null | undefined): string | null {
  if (!iso) return null;
  const d = new Date(iso);
  if (isNaN(d.getTime())) return null;
  const months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];
  return `${d.getDate()} ${months[d.getMonth()]} ${d.getFullYear()}`;
}

/**
 * Map Fineract loan status code to local status.
 */
export function mapFineractLoanStatus(status: { id: number; code: string; value: string } | undefined): string {
  if (!status) return "pending";
  const code = status.code?.toLowerCase() || "";
  if (code.includes("submitted") || code.includes("pendingapproval")) return "pending";
  if (code.includes("approved")) return "pending";
  if (code.includes("active") || code.includes("disbursed")) return "active";
  if (code.includes("closed") || code.includes("overpaid")) return "completed";
  if (code.includes("written") || code.includes("rescheduled")) return "defaulted";
  if (code.includes("rejected") || code.includes("withdrawn")) return "defaulted";
  return "pending";
}

/**
 * Map Fineract transaction type to local type.
 */
export function mapTransactionType(type: { id: number; code: string; value: string } | undefined): string {
  if (!type) return "repayment";
  const code = type.code?.toLowerCase() || "";
  if (code.includes("disbursement")) return "disbursement";
  if (code.includes("repayment")) return "repayment";
  if (code.includes("waive")) return "waiver";
  if (code.includes("writeoff")) return "write_off";
  if (code.includes("recovery")) return "recovery";
  if (code.includes("charge")) return "fee";
  return "repayment";
}
