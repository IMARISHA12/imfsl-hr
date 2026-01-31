import '../database.dart';

class LeaveTypesTable extends SupabaseTable<LeaveTypesRow> {
  @override
  String get tableName => 'leave_types';

  @override
  LeaveTypesRow createRow(Map<String, dynamic> data) => LeaveTypesRow(data);
}

class LeaveTypesRow extends SupabaseDataRow {
  LeaveTypesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => LeaveTypesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get code => getField<String>('code')!;
  set code(String value) => setField<String>('code', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  int get daysAllowed => getField<int>('days_allowed')!;
  set daysAllowed(int value) => setField<int>('days_allowed', value);

  bool? get requiresAttachment => getField<bool>('requires_attachment');
  set requiresAttachment(bool? value) =>
      setField<bool>('requires_attachment', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
