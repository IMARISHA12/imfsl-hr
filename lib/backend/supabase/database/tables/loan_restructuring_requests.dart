import '../database.dart';

class LoanRestructuringRequestsTable
    extends SupabaseTable<LoanRestructuringRequestsRow> {
  @override
  String get tableName => 'loan_restructuring_requests';

  @override
  LoanRestructuringRequestsRow createRow(Map<String, dynamic> data) =>
      LoanRestructuringRequestsRow(data);
}

class LoanRestructuringRequestsRow extends SupabaseDataRow {
  LoanRestructuringRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanRestructuringRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get requestType => getField<String>('request_type')!;
  set requestType(String value) => setField<String>('request_type', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  double get originalPrincipal => getField<double>('original_principal')!;
  set originalPrincipal(double value) =>
      setField<double>('original_principal', value);

  double? get originalRate => getField<double>('original_rate');
  set originalRate(double? value) => setField<double>('original_rate', value);

  int? get originalTenureMonths => getField<int>('original_tenure_months');
  set originalTenureMonths(int? value) =>
      setField<int>('original_tenure_months', value);

  double? get originalMonthlyPayment =>
      getField<double>('original_monthly_payment');
  set originalMonthlyPayment(double? value) =>
      setField<double>('original_monthly_payment', value);

  double? get proposedPrincipal => getField<double>('proposed_principal');
  set proposedPrincipal(double? value) =>
      setField<double>('proposed_principal', value);

  double? get proposedRate => getField<double>('proposed_rate');
  set proposedRate(double? value) => setField<double>('proposed_rate', value);

  int? get proposedTenureMonths => getField<int>('proposed_tenure_months');
  set proposedTenureMonths(int? value) =>
      setField<int>('proposed_tenure_months', value);

  double? get proposedMonthlyPayment =>
      getField<double>('proposed_monthly_payment');
  set proposedMonthlyPayment(double? value) =>
      setField<double>('proposed_monthly_payment', value);

  int? get proposedPaymentHolidayMonths =>
      getField<int>('proposed_payment_holiday_months');
  set proposedPaymentHolidayMonths(int? value) =>
      setField<int>('proposed_payment_holiday_months', value);

  String get reason => getField<String>('reason')!;
  set reason(String value) => setField<String>('reason', value);

  dynamic get supportingDocuments => getField<dynamic>('supporting_documents');
  set supportingDocuments(dynamic value) =>
      setField<dynamic>('supporting_documents', value);

  String get requestedBy => getField<String>('requested_by')!;
  set requestedBy(String value) => setField<String>('requested_by', value);

  String get requestedByName => getField<String>('requested_by_name')!;
  set requestedByName(String value) =>
      setField<String>('requested_by_name', value);

  DateTime get requestedAt => getField<DateTime>('requested_at')!;
  set requestedAt(DateTime value) => setField<DateTime>('requested_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  String? get reviewedByName => getField<String>('reviewed_by_name');
  set reviewedByName(String? value) =>
      setField<String>('reviewed_by_name', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get reviewNotes => getField<String>('review_notes');
  set reviewNotes(String? value) => setField<String>('review_notes', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  String? get approvedByName => getField<String>('approved_by_name');
  set approvedByName(String? value) =>
      setField<String>('approved_by_name', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get approvalNotes => getField<String>('approval_notes');
  set approvalNotes(String? value) => setField<String>('approval_notes', value);

  String? get rejectedBy => getField<String>('rejected_by');
  set rejectedBy(String? value) => setField<String>('rejected_by', value);

  String? get rejectedByName => getField<String>('rejected_by_name');
  set rejectedByName(String? value) =>
      setField<String>('rejected_by_name', value);

  DateTime? get rejectedAt => getField<DateTime>('rejected_at');
  set rejectedAt(DateTime? value) => setField<DateTime>('rejected_at', value);

  String? get rejectionReason => getField<String>('rejection_reason');
  set rejectionReason(String? value) =>
      setField<String>('rejection_reason', value);

  DateTime? get appliedAt => getField<DateTime>('applied_at');
  set appliedAt(DateTime? value) => setField<DateTime>('applied_at', value);

  String? get appliedBy => getField<String>('applied_by');
  set appliedBy(String? value) => setField<String>('applied_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
