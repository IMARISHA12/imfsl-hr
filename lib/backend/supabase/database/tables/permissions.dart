import '../database.dart';

class PermissionsTable extends SupabaseTable<PermissionsRow> {
  @override
  String get tableName => 'permissions';

  @override
  PermissionsRow createRow(Map<String, dynamic> data) => PermissionsRow(data);
}

class PermissionsRow extends SupabaseDataRow {
  PermissionsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PermissionsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get slug => getField<String>('slug')!;
  set slug(String value) => setField<String>('slug', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get key => getField<String>('key');
  set key(String? value) => setField<String>('key', value);
}
