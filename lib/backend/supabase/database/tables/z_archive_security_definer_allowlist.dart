import '../database.dart';

class ZArchiveSecurityDefinerAllowlistTable
    extends SupabaseTable<ZArchiveSecurityDefinerAllowlistRow> {
  @override
  String get tableName => 'z_archive_security_definer_allowlist';

  @override
  ZArchiveSecurityDefinerAllowlistRow createRow(Map<String, dynamic> data) =>
      ZArchiveSecurityDefinerAllowlistRow(data);
}

class ZArchiveSecurityDefinerAllowlistRow extends SupabaseDataRow {
  ZArchiveSecurityDefinerAllowlistRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSecurityDefinerAllowlistTable();

  String get functionName => getField<String>('function_name')!;
  set functionName(String value) => setField<String>('function_name', value);

  String get category => getField<String>('category')!;
  set category(String value) => setField<String>('category', value);

  String get justification => getField<String>('justification')!;
  set justification(String value) => setField<String>('justification', value);

  String get approvedBy => getField<String>('approved_by')!;
  set approvedBy(String value) => setField<String>('approved_by', value);

  DateTime get approvedAt => getField<DateTime>('approved_at')!;
  set approvedAt(DateTime value) => setField<DateTime>('approved_at', value);

  DateTime get reviewDueDate => getField<DateTime>('review_due_date')!;
  set reviewDueDate(DateTime value) =>
      setField<DateTime>('review_due_date', value);
}
