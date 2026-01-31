import '../database.dart';

class ZArchiveLeaveTypesTable extends SupabaseTable<ZArchiveLeaveTypesRow> {
  @override
  String get tableName => 'z_archive_leave_types';

  @override
  ZArchiveLeaveTypesRow createRow(Map<String, dynamic> data) =>
      ZArchiveLeaveTypesRow(data);
}

class ZArchiveLeaveTypesRow extends SupabaseDataRow {
  ZArchiveLeaveTypesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveLeaveTypesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String? get code => getField<String>('code');
  set code(String? value) => setField<String>('code', value);

  int? get daysAllowed => getField<int>('days_allowed');
  set daysAllowed(int? value) => setField<int>('days_allowed', value);

  bool? get requiresAttachment => getField<bool>('requires_attachment');
  set requiresAttachment(bool? value) =>
      setField<bool>('requires_attachment', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
