import '../database.dart';

class LoanWriteoffRequestsTable extends SupabaseTable<LoanWriteoffRequestsRow> {
  @override
  String get tableName => 'loan_writeoff_requests';

  @override
  LoanWriteoffRequestsRow createRow(Map<String, dynamic> data) =>
      LoanWriteoffRequestsRow(data);
}

class LoanWriteoffRequestsRow extends SupabaseDataRow {
  LoanWriteoffRequestsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LoanWriteoffRequestsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  double get outstandingPrincipal => getField<double>('outstanding_principal')!;
  set outstandingPrincipal(double value) =>
      setField<double>('outstanding_principal', value);

  double get outstandingInterest => getField<double>('outstanding_interest')!;
  set outstandingInterest(double value) =>
      setField<double>('outstanding_interest', value);

  double get outstandingPenalties => getField<double>('outstanding_penalties')!;
  set outstandingPenalties(double value) =>
      setField<double>('outstanding_penalties', value);

  double get totalWriteoffAmount => getField<double>('total_writeoff_amount')!;
  set totalWriteoffAmount(double value) =>
      setField<double>('total_writeoff_amount', value);

  double? get recoveryAmount => getField<double>('recovery_amount');
  set recoveryAmount(double? value) =>
      setField<double>('recovery_amount', value);

  double get netWriteoffAmount => getField<double>('net_writeoff_amount')!;
  set netWriteoffAmount(double value) =>
      setField<double>('net_writeoff_amount', value);

  String get writeoffReason => getField<String>('writeoff_reason')!;
  set writeoffReason(String value) =>
      setField<String>('writeoff_reason', value);

  String get justification => getField<String>('justification')!;
  set justification(String value) => setField<String>('justification', value);

  dynamic get supportingDocuments => getField<dynamic>('supporting_documents');
  set supportingDocuments(dynamic value) =>
      setField<dynamic>('supporting_documents', value);

  String? get collectionEfforts => getField<String>('collection_efforts');
  set collectionEfforts(String? value) =>
      setField<String>('collection_efforts', value);

  DateTime? get lastPaymentDate => getField<DateTime>('last_payment_date');
  set lastPaymentDate(DateTime? value) =>
      setField<DateTime>('last_payment_date', value);

  int? get daysDelinquent => getField<int>('days_delinquent');
  set daysDelinquent(int? value) => setField<int>('days_delinquent', value);

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

  String? get journalEntryId => getField<String>('journal_entry_id');
  set journalEntryId(String? value) =>
      setField<String>('journal_entry_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
