import '../database.dart';

class JournalEntryLinesTable extends SupabaseTable<JournalEntryLinesRow> {
  @override
  String get tableName => 'journal_entry_lines';

  @override
  JournalEntryLinesRow createRow(Map<String, dynamic> data) =>
      JournalEntryLinesRow(data);
}

class JournalEntryLinesRow extends SupabaseDataRow {
  JournalEntryLinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalEntryLinesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get journalEntryId => getField<String>('journal_entry_id')!;
  set journalEntryId(String value) =>
      setField<String>('journal_entry_id', value);

  String? get accountId => getField<String>('account_id');
  set accountId(String? value) => setField<String>('account_id', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double? get debitAmount => getField<double>('debit_amount');
  set debitAmount(double? value) => setField<double>('debit_amount', value);

  double? get creditAmount => getField<double>('credit_amount');
  set creditAmount(double? value) => setField<double>('credit_amount', value);

  int get lineNumber => getField<int>('line_number')!;
  set lineNumber(int value) => setField<int>('line_number', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get orgId => getField<String>('org_id')!;
  set orgId(String value) => setField<String>('org_id', value);
}
