import '../database.dart';

class ZArchiveRolesTable extends SupabaseTable<ZArchiveRolesRow> {
  @override
  String get tableName => 'z_archive_roles';

  @override
  ZArchiveRolesRow createRow(Map<String, dynamic> data) =>
      ZArchiveRolesRow(data);
}

class ZArchiveRolesRow extends SupabaseDataRow {
  ZArchiveRolesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveRolesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  String? get parentRoleId => getField<String>('parent_role_id');
  set parentRoleId(String? value) => setField<String>('parent_role_id', value);

  String? get color => getField<String>('color');
  set color(String? value) => setField<String>('color', value);
}
