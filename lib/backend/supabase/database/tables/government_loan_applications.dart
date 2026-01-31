import '../database.dart';

class GovernmentLoanApplicationsTable
    extends SupabaseTable<GovernmentLoanApplicationsRow> {
  @override
  String get tableName => 'government_loan_applications';

  @override
  GovernmentLoanApplicationsRow createRow(Map<String, dynamic> data) =>
      GovernmentLoanApplicationsRow(data);
}

class GovernmentLoanApplicationsRow extends SupabaseDataRow {
  GovernmentLoanApplicationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GovernmentLoanApplicationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get applicationNumber => getField<String>('application_number')!;
  set applicationNumber(String value) =>
      setField<String>('application_number', value);

  String get employeeCacheId => getField<String>('employee_cache_id')!;
  set employeeCacheId(String value) =>
      setField<String>('employee_cache_id', value);

  String get checkNumber => getField<String>('check_number')!;
  set checkNumber(String value) => setField<String>('check_number', value);

  double get requestedAmount => getField<double>('requested_amount')!;
  set requestedAmount(double value) =>
      setField<double>('requested_amount', value);

  double? get approvedAmount => getField<double>('approved_amount');
  set approvedAmount(double? value) =>
      setField<double>('approved_amount', value);

  int get tenureMonths => getField<int>('tenure_months')!;
  set tenureMonths(int value) => setField<int>('tenure_months', value);

  double get interestRate => getField<double>('interest_rate')!;
  set interestRate(double value) => setField<double>('interest_rate', value);

  double get monthlyInstallment => getField<double>('monthly_installment')!;
  set monthlyInstallment(double value) =>
      setField<double>('monthly_installment', value);

  double? get totalInterest => getField<double>('total_interest');
  set totalInterest(double? value) => setField<double>('total_interest', value);

  double? get totalRepayment => getField<double>('total_repayment');
  set totalRepayment(double? value) =>
      setField<double>('total_repayment', value);

  double? get processingFee => getField<double>('processing_fee');
  set processingFee(double? value) => setField<double>('processing_fee', value);

  double get basicSalaryAtApplication =>
      getField<double>('basic_salary_at_application')!;
  set basicSalaryAtApplication(double value) =>
      setField<double>('basic_salary_at_application', value);

  double? get currentDeductionsAtApplication =>
      getField<double>('current_deductions_at_application');
  set currentDeductionsAtApplication(double? value) =>
      setField<double>('current_deductions_at_application', value);

  double get calculatedMaxInstallment =>
      getField<double>('calculated_max_installment')!;
  set calculatedMaxInstallment(double value) =>
      setField<double>('calculated_max_installment', value);

  bool get oneThirdRulePassed => getField<bool>('one_third_rule_passed')!;
  set oneThirdRulePassed(bool value) =>
      setField<bool>('one_third_rule_passed', value);

  double? get affordabilityRatio => getField<double>('affordability_ratio');
  set affordabilityRatio(double? value) =>
      setField<double>('affordability_ratio', value);

  String? get affordabilityRuleId => getField<String>('affordability_rule_id');
  set affordabilityRuleId(String? value) =>
      setField<String>('affordability_rule_id', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get submittedBy => getField<String>('submitted_by');
  set submittedBy(String? value) => setField<String>('submitted_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get disbursedAt => getField<DateTime>('disbursed_at');
  set disbursedAt(DateTime? value) => setField<DateTime>('disbursed_at', value);

  String? get disbursedBy => getField<String>('disbursed_by');
  set disbursedBy(String? value) => setField<String>('disbursed_by', value);

  String? get disbursementReference =>
      getField<String>('disbursement_reference');
  set disbursementReference(String? value) =>
      setField<String>('disbursement_reference', value);

  String? get journalEntryId => getField<String>('journal_entry_id');
  set journalEntryId(String? value) =>
      setField<String>('journal_entry_id', value);

  bool? get glPosted => getField<bool>('gl_posted');
  set glPosted(bool? value) => setField<bool>('gl_posted', value);

  String? get bankName => getField<String>('bank_name');
  set bankName(String? value) => setField<String>('bank_name', value);

  String? get bankAccountNumber => getField<String>('bank_account_number');
  set bankAccountNumber(String? value) =>
      setField<String>('bank_account_number', value);

  String? get bankAccountName => getField<String>('bank_account_name');
  set bankAccountName(String? value) =>
      setField<String>('bank_account_name', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  dynamic get riskAnalysisSummary =>
      getField<dynamic>('risk_analysis_summary');
  set riskAnalysisSummary(dynamic value) =>
      setField<dynamic>('risk_analysis_summary', value);

  int? get monthsToRetirement => getField<int>('months_to_retirement');
  set monthsToRetirement(int? value) =>
      setField<int>('months_to_retirement', value);

  bool? get loanEndsBeforeRetirement =>
      getField<bool>('loan_ends_before_retirement');
  set loanEndsBeforeRetirement(bool? value) =>
      setField<bool>('loan_ends_before_retirement', value);
}
