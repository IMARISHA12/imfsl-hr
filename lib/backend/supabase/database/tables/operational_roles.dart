import '../database.dart';

class OperationalRolesTable extends SupabaseTable<OperationalRolesRow> {
  @override
  String get tableName => 'operational_roles';

  @override
  OperationalRolesRow createRow(Map<String, dynamic> data) =>
      OperationalRolesRow(data);
}

class OperationalRolesRow extends SupabaseDataRow {
  OperationalRolesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OperationalRolesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  int? get level => getField<int>('level');
  set level(int? value) => setField<int>('level', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
