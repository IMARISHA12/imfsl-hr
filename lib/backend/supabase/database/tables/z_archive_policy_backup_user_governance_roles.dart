import '../database.dart';

class ZArchivePolicyBackupUserGovernanceRolesTable
    extends SupabaseTable<ZArchivePolicyBackupUserGovernanceRolesRow> {
  @override
  String get tableName => 'z_archive__policy_backup_user_governance_roles';

  @override
  ZArchivePolicyBackupUserGovernanceRolesRow createRow(
          Map<String, dynamic> data) =>
      ZArchivePolicyBackupUserGovernanceRolesRow(data);
}

class ZArchivePolicyBackupUserGovernanceRolesRow extends SupabaseDataRow {
  ZArchivePolicyBackupUserGovernanceRolesRow(Map<String, dynamic> data)
      : super(data);

  @override
  SupabaseTable get table => ZArchivePolicyBackupUserGovernanceRolesTable();

  DateTime? get backedUpAt => getField<DateTime>('backed_up_at');
  set backedUpAt(DateTime? value) => setField<DateTime>('backed_up_at', value);

  String? get schemaname => getField<String>('schemaname');
  set schemaname(String? value) => setField<String>('schemaname', value);

  String? get tablename => getField<String>('tablename');
  set tablename(String? value) => setField<String>('tablename', value);

  String? get policyname => getField<String>('policyname');
  set policyname(String? value) => setField<String>('policyname', value);

  String? get permissive => getField<String>('permissive');
  set permissive(String? value) => setField<String>('permissive', value);

  List<String> get roles => getListField<String>('roles');
  set roles(List<String>? value) => setListField<String>('roles', value);

  String? get cmd => getField<String>('cmd');
  set cmd(String? value) => setField<String>('cmd', value);

  String? get qual => getField<String>('qual');
  set qual(String? value) => setField<String>('qual', value);

  String? get withCheck => getField<String>('with_check');
  set withCheck(String? value) => setField<String>('with_check', value);
}
