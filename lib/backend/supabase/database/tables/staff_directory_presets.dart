import '../database.dart';

class StaffDirectoryPresetsTable
    extends SupabaseTable<StaffDirectoryPresetsRow> {
  @override
  String get tableName => 'staff_directory_presets';

  @override
  StaffDirectoryPresetsRow createRow(Map<String, dynamic> data) =>
      StaffDirectoryPresetsRow(data);
}

class StaffDirectoryPresetsRow extends SupabaseDataRow {
  StaffDirectoryPresetsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffDirectoryPresetsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get createdByUserId => getField<String>('created_by_user_id');
  set createdByUserId(String? value) =>
      setField<String>('created_by_user_id', value);

  String get createdByLabel => getField<String>('created_by_label')!;
  set createdByLabel(String value) =>
      setField<String>('created_by_label', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  dynamic get config => getField<dynamic>('config')!;
  set config(dynamic value) => setField<dynamic>('config', value);
}
