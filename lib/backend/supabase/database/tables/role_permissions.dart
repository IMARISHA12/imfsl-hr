import '../database.dart';

class RolePermissionsTable extends SupabaseTable<RolePermissionsRow> {
  @override
  String get tableName => 'role_permissions';

  @override
  RolePermissionsRow createRow(Map<String, dynamic> data) =>
      RolePermissionsRow(data);
}

class RolePermissionsRow extends SupabaseDataRow {
  RolePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RolePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get roleId => getField<String>('role_id')!;
  set roleId(String value) => setField<String>('role_id', value);

  String get permissionId => getField<String>('permission_id')!;
  set permissionId(String value) => setField<String>('permission_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
