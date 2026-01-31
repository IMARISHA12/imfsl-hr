import '../database.dart';

class ZArchiveRlsPolicyBackupCleanupTable
    extends SupabaseTable<ZArchiveRlsPolicyBackupCleanupRow> {
  @override
  String get tableName => 'z_archive__rls_policy_backup_cleanup';

  @override
  ZArchiveRlsPolicyBackupCleanupRow createRow(Map<String, dynamic> data) =>
      ZArchiveRlsPolicyBackupCleanupRow(data);
}

class ZArchiveRlsPolicyBackupCleanupRow extends SupabaseDataRow {
  ZArchiveRlsPolicyBackupCleanupRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveRlsPolicyBackupCleanupTable();

  DateTime? get backedUpAt => getField<DateTime>('backed_up_at');
  set backedUpAt(DateTime? value) => setField<DateTime>('backed_up_at', value);

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get tableNameField => getField<String>('table_name');
  set tableNameField(String? value) => setField<String>('table_name', value);

  String? get policyName => getField<String>('policy_name');
  set policyName(String? value) => setField<String>('policy_name', value);

  String? get policyCmd => getField<String>('policy_cmd');
  set policyCmd(String? value) => setField<String>('policy_cmd', value);

  bool? get isPermissive => getField<bool>('is_permissive');
  set isPermissive(bool? value) => setField<bool>('is_permissive', value);

  List<String> get policyRoles => getListField<String>('policy_roles');
  set policyRoles(List<String>? value) =>
      setListField<String>('policy_roles', value);

  String? get usingExpr => getField<String>('using_expr');
  set usingExpr(String? value) => setField<String>('using_expr', value);

  String? get withCheckExpr => getField<String>('with_check_expr');
  set withCheckExpr(String? value) =>
      setField<String>('with_check_expr', value);
}
