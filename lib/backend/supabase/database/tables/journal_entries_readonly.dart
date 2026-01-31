import '../database.dart';

class JournalEntriesReadonlyTable
    extends SupabaseTable<JournalEntriesReadonlyRow> {
  @override
  String get tableName => 'journal_entries_readonly';

  @override
  JournalEntriesReadonlyRow createRow(Map<String, dynamic> data) =>
      JournalEntriesReadonlyRow(data);
}

class JournalEntriesReadonlyRow extends SupabaseDataRow {
  JournalEntriesReadonlyRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalEntriesReadonlyTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get referenceNo => getField<String>('reference_no');
  set referenceNo(String? value) => setField<String>('reference_no', value);

  double? get totalAmount => getField<double>('total_amount');
  set totalAmount(double? value) => setField<double>('total_amount', value);

  String? get currency => getField<String>('currency');
  set currency(String? value) => setField<String>('currency', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
