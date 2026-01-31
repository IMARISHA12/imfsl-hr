import '../database.dart';

class SecurityAuditFunctionGrantsTable
    extends SupabaseTable<SecurityAuditFunctionGrantsRow> {
  @override
  String get tableName => 'security_audit_function_grants';

  @override
  SecurityAuditFunctionGrantsRow createRow(Map<String, dynamic> data) =>
      SecurityAuditFunctionGrantsRow(data);
}

class SecurityAuditFunctionGrantsRow extends SupabaseDataRow {
  SecurityAuditFunctionGrantsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SecurityAuditFunctionGrantsTable();

  String? get issueType => getField<String>('issue_type');
  set issueType(String? value) => setField<String>('issue_type', value);

  String? get severity => getField<String>('severity');
  set severity(String? value) => setField<String>('severity', value);

  String? get objectName => getField<String>('object_name');
  set objectName(String? value) => setField<String>('object_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime? get checkedAt => getField<DateTime>('checked_at');
  set checkedAt(DateTime? value) => setField<DateTime>('checked_at', value);
}
