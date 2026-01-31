import '../database.dart';

class BankReconciliationsTable extends SupabaseTable<BankReconciliationsRow> {
  @override
  String get tableName => 'bank_reconciliations';

  @override
  BankReconciliationsRow createRow(Map<String, dynamic> data) =>
      BankReconciliationsRow(data);
}

class BankReconciliationsRow extends SupabaseDataRow {
  BankReconciliationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BankReconciliationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get bankAccountId => getField<String>('bank_account_id')!;
  set bankAccountId(String value) => setField<String>('bank_account_id', value);

  DateTime get reconciliationDate => getField<DateTime>('reconciliation_date')!;
  set reconciliationDate(DateTime value) =>
      setField<DateTime>('reconciliation_date', value);

  String? get periodId => getField<String>('period_id');
  set periodId(String? value) => setField<String>('period_id', value);

  double get bankStatementBalance =>
      getField<double>('bank_statement_balance')!;
  set bankStatementBalance(double value) =>
      setField<double>('bank_statement_balance', value);

  double? get outstandingDeposits => getField<double>('outstanding_deposits');
  set outstandingDeposits(double? value) =>
      setField<double>('outstanding_deposits', value);

  double? get outstandingChecks => getField<double>('outstanding_checks');
  set outstandingChecks(double? value) =>
      setField<double>('outstanding_checks', value);

  double? get bankErrors => getField<double>('bank_errors');
  set bankErrors(double? value) => setField<double>('bank_errors', value);

  double? get adjustedBankBalance => getField<double>('adjusted_bank_balance');
  set adjustedBankBalance(double? value) =>
      setField<double>('adjusted_bank_balance', value);

  double get bookBalance => getField<double>('book_balance')!;
  set bookBalance(double value) => setField<double>('book_balance', value);

  double? get unrecordedDeposits => getField<double>('unrecorded_deposits');
  set unrecordedDeposits(double? value) =>
      setField<double>('unrecorded_deposits', value);

  double? get unrecordedChecks => getField<double>('unrecorded_checks');
  set unrecordedChecks(double? value) =>
      setField<double>('unrecorded_checks', value);

  double? get bookErrors => getField<double>('book_errors');
  set bookErrors(double? value) => setField<double>('book_errors', value);

  double? get adjustedBookBalance => getField<double>('adjusted_book_balance');
  set adjustedBookBalance(double? value) =>
      setField<double>('adjusted_book_balance', value);

  double? get variance => getField<double>('variance');
  set variance(double? value) => setField<double>('variance', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get varianceExplanation => getField<String>('variance_explanation');
  set varianceExplanation(String? value) =>
      setField<String>('variance_explanation', value);

  dynamic get outstandingItems => getField<dynamic>('outstanding_items');
  set outstandingItems(dynamic value) =>
      setField<dynamic>('outstanding_items', value);

  String? get preparedBy => getField<String>('prepared_by');
  set preparedBy(String? value) => setField<String>('prepared_by', value);

  DateTime? get preparedAt => getField<DateTime>('prepared_at');
  set preparedAt(DateTime? value) => setField<DateTime>('prepared_at', value);

  String? get reviewedBy => getField<String>('reviewed_by');
  set reviewedBy(String? value) => setField<String>('reviewed_by', value);

  DateTime? get reviewedAt => getField<DateTime>('reviewed_at');
  set reviewedAt(DateTime? value) => setField<DateTime>('reviewed_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  List<String> get evidenceUrls => getListField<String>('evidence_urls');
  set evidenceUrls(List<String>? value) =>
      setListField<String>('evidence_urls', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
