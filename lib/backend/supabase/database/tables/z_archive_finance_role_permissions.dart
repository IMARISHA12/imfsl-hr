import '../database.dart';

class ZArchiveFinanceRolePermissionsTable
    extends SupabaseTable<ZArchiveFinanceRolePermissionsRow> {
  @override
  String get tableName => 'z_archive_finance_role_permissions';

  @override
  ZArchiveFinanceRolePermissionsRow createRow(Map<String, dynamic> data) =>
      ZArchiveFinanceRolePermissionsRow(data);
}

class ZArchiveFinanceRolePermissionsRow extends SupabaseDataRow {
  ZArchiveFinanceRolePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveFinanceRolePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  String get permissionName => getField<String>('permission_name')!;
  set permissionName(String value) =>
      setField<String>('permission_name', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
