import '../database.dart';

class JournalEntryLinesReadonlyTable
    extends SupabaseTable<JournalEntryLinesReadonlyRow> {
  @override
  String get tableName => 'journal_entry_lines_readonly';

  @override
  JournalEntryLinesReadonlyRow createRow(Map<String, dynamic> data) =>
      JournalEntryLinesReadonlyRow(data);
}

class JournalEntryLinesReadonlyRow extends SupabaseDataRow {
  JournalEntryLinesReadonlyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalEntryLinesReadonlyTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get journalEntryId => getField<String>('journal_entry_id');
  set journalEntryId(String? value) =>
      setField<String>('journal_entry_id', value);

  String? get accountId => getField<String>('account_id');
  set accountId(String? value) => setField<String>('account_id', value);

  String? get accountCode => getField<String>('account_code');
  set accountCode(String? value) => setField<String>('account_code', value);

  String? get accountName => getField<String>('account_name');
  set accountName(String? value) => setField<String>('account_name', value);

  double? get amount => getField<double>('amount');
  set amount(double? value) => setField<double>('amount', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);
}
