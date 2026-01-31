import '../database.dart';

class JournalLinesTable extends SupabaseTable<JournalLinesRow> {
  @override
  String get tableName => 'journal_lines';

  @override
  JournalLinesRow createRow(Map<String, dynamic> data) => JournalLinesRow(data);
}

class JournalLinesRow extends SupabaseDataRow {
  JournalLinesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalLinesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get journalId => getField<String>('journal_id')!;
  set journalId(String value) => setField<String>('journal_id', value);

  int get lineNo => getField<int>('line_no')!;
  set lineNo(int value) => setField<int>('line_no', value);

  String? get accountId => getField<String>('account_id');
  set accountId(String? value) => setField<String>('account_id', value);

  String get accountCode => getField<String>('account_code')!;
  set accountCode(String value) => setField<String>('account_code', value);

  String get accountName => getField<String>('account_name')!;
  set accountName(String value) => setField<String>('account_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  double get debit => getField<double>('debit')!;
  set debit(double value) => setField<double>('debit', value);

  double get credit => getField<double>('credit')!;
  set credit(double value) => setField<double>('credit', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
