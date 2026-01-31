import '../database.dart';

class SystemConfigurationsTable extends SupabaseTable<SystemConfigurationsRow> {
  @override
  String get tableName => 'system_configurations';

  @override
  SystemConfigurationsRow createRow(Map<String, dynamic> data) =>
      SystemConfigurationsRow(data);
}

class SystemConfigurationsRow extends SupabaseDataRow {
  SystemConfigurationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SystemConfigurationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  dynamic get value => getField<dynamic>('value');
  set value(dynamic value) => setField<dynamic>('value', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get updatedBy => getField<String>('updated_by');
  set updatedBy(String? value) => setField<String>('updated_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
