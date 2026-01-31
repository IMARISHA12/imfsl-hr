import '../database.dart';

class ZArchiveSystemConfigurationTable
    extends SupabaseTable<ZArchiveSystemConfigurationRow> {
  @override
  String get tableName => 'z_archive_system_configuration';

  @override
  ZArchiveSystemConfigurationRow createRow(Map<String, dynamic> data) =>
      ZArchiveSystemConfigurationRow(data);
}

class ZArchiveSystemConfigurationRow extends SupabaseDataRow {
  ZArchiveSystemConfigurationRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveSystemConfigurationTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get configKey => getField<String>('config_key')!;
  set configKey(String value) => setField<String>('config_key', value);

  dynamic get configValue => getField<dynamic>('config_value')!;
  set configValue(dynamic value) => setField<dynamic>('config_value', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  bool? get isActive => getField<bool>('is_active');
  set isActive(bool? value) => setField<bool>('is_active', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
