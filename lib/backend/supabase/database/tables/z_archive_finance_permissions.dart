import '../database.dart';

class ZArchiveFinancePermissionsTable
    extends SupabaseTable<ZArchiveFinancePermissionsRow> {
  @override
  String get tableName => 'z_archive_finance_permissions';

  @override
  ZArchiveFinancePermissionsRow createRow(Map<String, dynamic> data) =>
      ZArchiveFinancePermissionsRow(data);
}

class ZArchiveFinancePermissionsRow extends SupabaseDataRow {
  ZArchiveFinancePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveFinancePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get permissionName => getField<String>('permission_name')!;
  set permissionName(String value) =>
      setField<String>('permission_name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get category => getField<String>('category');
  set category(String? value) => setField<String>('category', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
