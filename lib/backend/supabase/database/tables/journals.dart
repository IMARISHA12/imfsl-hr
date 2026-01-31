import '../database.dart';

class JournalsTable extends SupabaseTable<JournalsRow> {
  @override
  String get tableName => 'journals';

  @override
  JournalsRow createRow(Map<String, dynamic> data) => JournalsRow(data);
}

class JournalsRow extends SupabaseDataRow {
  JournalsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get journalDate => getField<DateTime>('journal_date')!;
  set journalDate(DateTime value) => setField<DateTime>('journal_date', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get currency => getField<String>('currency')!;
  set currency(String value) => setField<String>('currency', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get referenceType => getField<String>('reference_type');
  set referenceType(String? value) => setField<String>('reference_type', value);

  String? get referenceId => getField<String>('reference_id');
  set referenceId(String? value) => setField<String>('reference_id', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get postedBy => getField<String>('posted_by');
  set postedBy(String? value) => setField<String>('posted_by', value);

  DateTime? get postedAt => getField<DateTime>('posted_at');
  set postedAt(DateTime? value) => setField<DateTime>('posted_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
