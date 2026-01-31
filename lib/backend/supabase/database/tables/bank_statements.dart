import '../database.dart';

class BankStatementsTable extends SupabaseTable<BankStatementsRow> {
  @override
  String get tableName => 'bank_statements';

  @override
  BankStatementsRow createRow(Map<String, dynamic> data) =>
      BankStatementsRow(data);
}

class BankStatementsRow extends SupabaseDataRow {
  BankStatementsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BankStatementsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get bankAccountId => getField<String>('bank_account_id')!;
  set bankAccountId(String value) => setField<String>('bank_account_id', value);

  DateTime get statementDate => getField<DateTime>('statement_date')!;
  set statementDate(DateTime value) =>
      setField<DateTime>('statement_date', value);

  DateTime get periodStart => getField<DateTime>('period_start')!;
  set periodStart(DateTime value) => setField<DateTime>('period_start', value);

  DateTime get periodEnd => getField<DateTime>('period_end')!;
  set periodEnd(DateTime value) => setField<DateTime>('period_end', value);

  double get openingBalance => getField<double>('opening_balance')!;
  set openingBalance(double value) =>
      setField<double>('opening_balance', value);

  double get closingBalance => getField<double>('closing_balance')!;
  set closingBalance(double value) =>
      setField<double>('closing_balance', value);

  double? get totalDebits => getField<double>('total_debits');
  set totalDebits(double? value) => setField<double>('total_debits', value);

  double? get totalCredits => getField<double>('total_credits');
  set totalCredits(double? value) => setField<double>('total_credits', value);

  String? get sourceFileName => getField<String>('source_file_name');
  set sourceFileName(String? value) =>
      setField<String>('source_file_name', value);

  String? get sourceFileUrl => getField<String>('source_file_url');
  set sourceFileUrl(String? value) =>
      setField<String>('source_file_url', value);

  String? get importMethod => getField<String>('import_method');
  set importMethod(String? value) => setField<String>('import_method', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  int? get lineCount => getField<int>('line_count');
  set lineCount(int? value) => setField<int>('line_count', value);

  int? get matchedCount => getField<int>('matched_count');
  set matchedCount(int? value) => setField<int>('matched_count', value);

  int? get unmatchedCount => getField<int>('unmatched_count');
  set unmatchedCount(int? value) => setField<int>('unmatched_count', value);

  String? get importedBy => getField<String>('imported_by');
  set importedBy(String? value) => setField<String>('imported_by', value);

  DateTime? get importedAt => getField<DateTime>('imported_at');
  set importedAt(DateTime? value) => setField<DateTime>('imported_at', value);

  String? get matchedBy => getField<String>('matched_by');
  set matchedBy(String? value) => setField<String>('matched_by', value);

  DateTime? get matchedAt => getField<DateTime>('matched_at');
  set matchedAt(DateTime? value) => setField<DateTime>('matched_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
