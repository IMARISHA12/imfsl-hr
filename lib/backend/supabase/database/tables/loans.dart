import '../database.dart';

class LoansTable extends SupabaseTable<LoansRow> {
  @override
  String get tableName => 'loans';

  @override
  LoansRow createRow(Map<String, dynamic> data) => LoansRow(data);
}

class LoansRow extends SupabaseDataRow {
  LoansRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoansTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get branchId => getField<String>('branch_id');
  set branchId(String? value) => setField<String>('branch_id', value);

  String get applicantName => getField<String>('applicant_name')!;
  set applicantName(String value) => setField<String>('applicant_name', value);

  double get principalAmount => getField<double>('principal_amount')!;
  set principalAmount(double value) =>
      setField<double>('principal_amount', value);

  double get balance => getField<double>('balance')!;
  set balance(double value) => setField<double>('balance', value);

  double? get penaltyBalance => getField<double>('penalty_balance');
  set penaltyBalance(double? value) =>
      setField<double>('penalty_balance', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  bool? get legalFreeze => getField<bool>('legal_freeze');
  set legalFreeze(bool? value) => setField<bool>('legal_freeze', value);

  DateTime? get freezeDate => getField<DateTime>('freeze_date');
  set freezeDate(DateTime? value) => setField<DateTime>('freeze_date', value);

  DateTime? get lastPenaltyDate => getField<DateTime>('last_penalty_date');
  set lastPenaltyDate(DateTime? value) =>
      setField<DateTime>('last_penalty_date', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get ownerId => getField<String>('owner_id');
  set ownerId(String? value) => setField<String>('owner_id', value);

  String? get mteja => getField<String>('mteja');
  set mteja(String? value) => setField<String>('mteja', value);

  double? get principal => getField<double>('principal');
  set principal(double? value) => setField<double>('principal', value);

  double? get outstandingBalance => getField<double>('outstanding_balance');
  set outstandingBalance(double? value) =>
      setField<double>('outstanding_balance', value);

  bool? get isTopup => getField<bool>('is_topup');
  set isTopup(bool? value) => setField<bool>('is_topup', value);

  String? get parentLoanId => getField<String>('parent_loan_id');
  set parentLoanId(String? value) => setField<String>('parent_loan_id', value);

  String get productType => getField<String>('product_type')!;
  set productType(String value) => setField<String>('product_type', value);

  dynamic get productMetadata => getField<dynamic>('product_metadata');
  set productMetadata(dynamic value) =>
      setField<dynamic>('product_metadata', value);

  DateTime? get disbursedAt => getField<DateTime>('disbursed_at');
  set disbursedAt(DateTime? value) => setField<DateTime>('disbursed_at', value);

  String? get govtCheckNumber => getField<String>('govt_check_number');
  set govtCheckNumber(String? value) =>
      setField<String>('govt_check_number', value);

  DateTime? get govtRetirementDate =>
      getField<DateTime>('govt_retirement_date');
  set govtRetirementDate(DateTime? value) =>
      setField<DateTime>('govt_retirement_date', value);

  String get borrowerId => getField<String>('borrower_id')!;
  set borrowerId(String value) => setField<String>('borrower_id', value);

  String? get kycVerificationId => getField<String>('kyc_verification_id');
  set kycVerificationId(String? value) =>
      setField<String>('kyc_verification_id', value);

  int? get riskScore => getField<int>('risk_score');
  set riskScore(int? value) => setField<int>('risk_score', value);

  String? get repaymentPerformance => getField<String>('repayment_performance');
  set repaymentPerformance(String? value) =>
      setField<String>('repayment_performance', value);

  int? get daysPastDue => getField<int>('days_past_due');
  set daysPastDue(int? value) => setField<int>('days_past_due', value);

  DateTime? get nextPaymentDate => getField<DateTime>('next_payment_date');
  set nextPaymentDate(DateTime? value) =>
      setField<DateTime>('next_payment_date', value);

  double? get interestRate => getField<double>('interest_rate');
  set interestRate(double? value) => setField<double>('interest_rate', value);

  int? get tenureMonths => getField<int>('tenure_months');
  set tenureMonths(int? value) => setField<int>('tenure_months', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get disbursedBy => getField<String>('disbursed_by');
  set disbursedBy(String? value) => setField<String>('disbursed_by', value);

  DateTime? get closedAt => getField<DateTime>('closed_at');
  set closedAt(DateTime? value) => setField<DateTime>('closed_at', value);

  String? get closureReason => getField<String>('closure_reason');
  set closureReason(String? value) => setField<String>('closure_reason', value);

  String? get collateralDescription =>
      getField<String>('collateral_description');
  set collateralDescription(String? value) =>
      setField<String>('collateral_description', value);

  double? get collateralValue => getField<double>('collateral_value');
  set collateralValue(double? value) =>
      setField<double>('collateral_value', value);

  String? get collateralImageUrl => getField<String>('collateral_image_url');
  set collateralImageUrl(String? value) =>
      setField<String>('collateral_image_url', value);

  String? get loanPurpose => getField<String>('loan_purpose');
  set loanPurpose(String? value) => setField<String>('loan_purpose', value);

  String? get approvalNotes => getField<String>('approval_notes');
  set approvalNotes(String? value) => setField<String>('approval_notes', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  String? get recommendedBy => getField<String>('recommended_by');
  set recommendedBy(String? value) => setField<String>('recommended_by', value);

  DateTime? get recommendedAt => getField<DateTime>('recommended_at');
  set recommendedAt(DateTime? value) =>
      setField<DateTime>('recommended_at', value);

  dynamic get approvalConditions => getField<dynamic>('approval_conditions');
  set approvalConditions(dynamic value) =>
      setField<dynamic>('approval_conditions', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get organizationId => getField<String>('organization_id')!;
  set organizationId(String value) =>
      setField<String>('organization_id', value);
}
