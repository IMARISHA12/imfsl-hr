import '../database.dart';

class ZArchivePermissionsTable extends SupabaseTable<ZArchivePermissionsRow> {
  @override
  String get tableName => 'z_archive_permissions';

  @override
  ZArchivePermissionsRow createRow(Map<String, dynamic> data) =>
      ZArchivePermissionsRow(data);
}

class ZArchivePermissionsRow extends SupabaseDataRow {
  ZArchivePermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchivePermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get role => getField<String>('role')!;
  set role(String value) => setField<String>('role', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get module => getField<String>('module')!;
  set module(String value) => setField<String>('module', value);

  String get action => getField<String>('action')!;
  set action(String value) => setField<String>('action', value);

  String? get resource => getField<String>('resource');
  set resource(String? value) => setField<String>('resource', value);

  bool? get isSystem => getField<bool>('is_system');
  set isSystem(bool? value) => setField<bool>('is_system', value);
}
