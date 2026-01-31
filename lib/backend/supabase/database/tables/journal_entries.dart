import '../database.dart';

class JournalEntriesTable extends SupabaseTable<JournalEntriesRow> {
  @override
  String get tableName => 'journal_entries';

  @override
  JournalEntriesRow createRow(Map<String, dynamic> data) =>
      JournalEntriesRow(data);
}

class JournalEntriesRow extends SupabaseDataRow {
  JournalEntriesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => JournalEntriesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get journalNumber => getField<String>('journal_number')!;
  set journalNumber(String value) => setField<String>('journal_number', value);

  DateTime get entryDate => getField<DateTime>('entry_date')!;
  set entryDate(DateTime value) => setField<DateTime>('entry_date', value);

  String? get referenceNo => getField<String>('reference_no');
  set referenceNo(String? value) => setField<String>('reference_no', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  double? get totalDebit => getField<double>('total_debit');
  set totalDebit(double? value) => setField<double>('total_debit', value);

  double? get totalCredit => getField<double>('total_credit');
  set totalCredit(double? value) => setField<double>('total_credit', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get postedBy => getField<String>('posted_by');
  set postedBy(String? value) => setField<String>('posted_by', value);

  DateTime? get postedAt => getField<DateTime>('posted_at');
  set postedAt(DateTime? value) => setField<DateTime>('posted_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get qboId => getField<String>('qbo_id');
  set qboId(String? value) => setField<String>('qbo_id', value);

  String? get qboDocNumber => getField<String>('qbo_doc_number');
  set qboDocNumber(String? value) => setField<String>('qbo_doc_number', value);

  String? get qboSyncToken => getField<String>('qbo_sync_token');
  set qboSyncToken(String? value) => setField<String>('qbo_sync_token', value);

  String? get submittedBy => getField<String>('submitted_by');
  set submittedBy(String? value) => setField<String>('submitted_by', value);

  DateTime? get submittedAt => getField<DateTime>('submitted_at');
  set submittedAt(DateTime? value) => setField<DateTime>('submitted_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String get orgId => getField<String>('org_id')!;
  set orgId(String value) => setField<String>('org_id', value);
}
