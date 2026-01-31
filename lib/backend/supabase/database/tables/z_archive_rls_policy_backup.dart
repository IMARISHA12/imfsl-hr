import '../database.dart';

class ZArchiveRlsPolicyBackupTable
    extends SupabaseTable<ZArchiveRlsPolicyBackupRow> {
  @override
  String get tableName => 'z_archive__rls_policy_backup';

  @override
  ZArchiveRlsPolicyBackupRow createRow(Map<String, dynamic> data) =>
      ZArchiveRlsPolicyBackupRow(data);
}

class ZArchiveRlsPolicyBackupRow extends SupabaseDataRow {
  ZArchiveRlsPolicyBackupRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveRlsPolicyBackupTable();

  DateTime? get backedUpAt => getField<DateTime>('backed_up_at');
  set backedUpAt(DateTime? value) => setField<DateTime>('backed_up_at', value);

  String? get polname => getField<String>('polname');
  set polname(String? value) => setField<String>('polname', value);

  String? get schemaName => getField<String>('schema_name');
  set schemaName(String? value) => setField<String>('schema_name', value);

  String? get tableNameField => getField<String>('table_name');
  set tableNameField(String? value) => setField<String>('table_name', value);

  bool? get isPermissive => getField<bool>('is_permissive');
  set isPermissive(bool? value) => setField<bool>('is_permissive', value);

  String? get polcmd => getField<String>('polcmd');
  set polcmd(String? value) => setField<String>('polcmd', value);

  List<String> get polroles => getListField<String>('polroles');
  set polroles(List<String>? value) => setListField<String>('polroles', value);

  String? get usingExpr => getField<String>('using_expr');
  set usingExpr(String? value) => setField<String>('using_expr', value);

  String? get withCheckExpr => getField<String>('with_check_expr');
  set withCheckExpr(String? value) =>
      setField<String>('with_check_expr', value);
}
