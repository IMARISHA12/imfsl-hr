import '../database.dart';

class RoleEnterprisePermissionsTable
    extends SupabaseTable<RoleEnterprisePermissionsRow> {
  @override
  String get tableName => 'role_enterprise_permissions';

  @override
  RoleEnterprisePermissionsRow createRow(Map<String, dynamic> data) =>
      RoleEnterprisePermissionsRow(data);
}

class RoleEnterprisePermissionsRow extends SupabaseDataRow {
  RoleEnterprisePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RoleEnterprisePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get roleKey => getField<String>('role_key')!;
  set roleKey(String value) => setField<String>('role_key', value);

  String get permissionKey => getField<String>('permission_key')!;
  set permissionKey(String value) => setField<String>('permission_key', value);

  DateTime? get grantedAt => getField<DateTime>('granted_at');
  set grantedAt(DateTime? value) => setField<DateTime>('granted_at', value);

  String? get grantedBy => getField<String>('granted_by');
  set grantedBy(String? value) => setField<String>('granted_by', value);
}
