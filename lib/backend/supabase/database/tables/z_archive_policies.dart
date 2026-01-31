import '../database.dart';

class ZArchivePoliciesTable extends SupabaseTable<ZArchivePoliciesRow> {
  @override
  String get tableName => 'z_archive_policies';

  @override
  ZArchivePoliciesRow createRow(Map<String, dynamic> data) =>
      ZArchivePoliciesRow(data);
}

class ZArchivePoliciesRow extends SupabaseDataRow {
  ZArchivePoliciesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePoliciesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get content => getField<String>('content')!;
  set content(String value) => setField<String>('content', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String get version => getField<String>('version')!;
  set version(String value) => setField<String>('version', value);

  DateTime get effectiveDate => getField<DateTime>('effective_date')!;
  set effectiveDate(DateTime value) =>
      setField<DateTime>('effective_date', value);

  DateTime? get expiryDate => getField<DateTime>('expiry_date');
  set expiryDate(DateTime? value) => setField<DateTime>('expiry_date', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  String? get documentHash => getField<String>('document_hash');
  set documentHash(String? value) => setField<String>('document_hash', value);

  DateTime? get retentionUntil => getField<DateTime>('retention_until');
  set retentionUntil(DateTime? value) =>
      setField<DateTime>('retention_until', value);
}
