import '../database.dart';

class ZArchiveSystemConfigurationsTable
    extends SupabaseTable<ZArchiveSystemConfigurationsRow> {
  @override
  String get tableName => 'z_archive_system_configurations';

  @override
  ZArchiveSystemConfigurationsRow createRow(Map<String, dynamic> data) =>
      ZArchiveSystemConfigurationsRow(data);
}

class ZArchiveSystemConfigurationsRow extends SupabaseDataRow {
  ZArchiveSystemConfigurationsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSystemConfigurationsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get key => getField<String>('key')!;
  set key(String value) => setField<String>('key', value);

  String get value => getField<String>('value')!;
  set value(String value) => setField<String>('value', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get isSensitive => getField<bool>('is_sensitive');
  set isSensitive(bool? value) => setField<bool>('is_sensitive', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
