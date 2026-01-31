import '../database.dart';

class BankStatementLinesTable extends SupabaseTable<BankStatementLinesRow> {
  @override
  String get tableName => 'bank_statement_lines';

  @override
  BankStatementLinesRow createRow(Map<String, dynamic> data) =>
      BankStatementLinesRow(data);
}

class BankStatementLinesRow extends SupabaseDataRow {
  BankStatementLinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => BankStatementLinesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get statementId => getField<String>('statement_id')!;
  set statementId(String value) => setField<String>('statement_id', value);

  int get lineNumber => getField<int>('line_number')!;
  set lineNumber(int value) => setField<int>('line_number', value);

  DateTime get txnDate => getField<DateTime>('txn_date')!;
  set txnDate(DateTime value) => setField<DateTime>('txn_date', value);

  DateTime? get valueDate => getField<DateTime>('value_date');
  set valueDate(DateTime? value) => setField<DateTime>('value_date', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get referenceField => getField<String>('reference');
  set referenceField(String? value) => setField<String>('reference', value);

  double? get debitAmount => getField<double>('debit_amount');
  set debitAmount(double? value) => setField<double>('debit_amount', value);

  double? get creditAmount => getField<double>('credit_amount');
  set creditAmount(double? value) => setField<double>('credit_amount', value);

  double? get runningBalance => getField<double>('running_balance');
  set runningBalance(double? value) =>
      setField<double>('running_balance', value);

  String get matchStatus => getField<String>('match_status')!;
  set matchStatus(String value) => setField<String>('match_status', value);

  String? get matchedToType => getField<String>('matched_to_type');
  set matchedToType(String? value) =>
      setField<String>('matched_to_type', value);

  String? get matchedToId => getField<String>('matched_to_id');
  set matchedToId(String? value) => setField<String>('matched_to_id', value);

  double? get matchedAmount => getField<double>('matched_amount');
  set matchedAmount(double? value) => setField<double>('matched_amount', value);

  double? get matchConfidence => getField<double>('match_confidence');
  set matchConfidence(double? value) =>
      setField<double>('match_confidence', value);

  String? get matchNotes => getField<String>('match_notes');
  set matchNotes(String? value) => setField<String>('match_notes', value);

  String? get matchedBy => getField<String>('matched_by');
  set matchedBy(String? value) => setField<String>('matched_by', value);

  DateTime? get matchedAt => getField<DateTime>('matched_at');
  set matchedAt(DateTime? value) => setField<DateTime>('matched_at', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
