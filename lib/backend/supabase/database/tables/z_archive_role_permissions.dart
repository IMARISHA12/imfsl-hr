import '../database.dart';

class ZArchiveRolePermissionsTable
    extends SupabaseTable<ZArchiveRolePermissionsRow> {
  @override
  String get tableName => 'z_archive_role_permissions';

  @override
  ZArchiveRolePermissionsRow createRow(Map<String, dynamic> data) =>
      ZArchiveRolePermissionsRow(data);
}

class ZArchiveRolePermissionsRow extends SupabaseDataRow {
  ZArchiveRolePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveRolePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get roleId => getField<String>('role_id')!;
  set roleId(String value) => setField<String>('role_id', value);

  String get permissionId => getField<String>('permission_id')!;
  set permissionId(String value) => setField<String>('permission_id', value);

  DateTime get grantedAt => getField<DateTime>('granted_at')!;
  set grantedAt(DateTime value) => setField<DateTime>('granted_at', value);

  String? get grantedBy => getField<String>('granted_by');
  set grantedBy(String? value) => setField<String>('granted_by', value);
}
