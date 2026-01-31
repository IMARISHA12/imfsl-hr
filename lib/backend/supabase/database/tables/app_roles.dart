import '../database.dart';

class AppRolesTable extends SupabaseTable<AppRolesRow> {
  @override
  String get tableName => 'app_roles';

  @override
  AppRolesRow createRow(Map<String, dynamic> data) => AppRolesRow(data);
}

class AppRolesRow extends SupabaseDataRow {
  AppRolesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppRolesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
