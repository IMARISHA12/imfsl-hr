import '../database.dart';

class AttendanceTable extends SupabaseTable<AttendanceRow> {
  @override
  String get tableName => 'attendance';

  @override
  AttendanceRow createRow(Map<String, dynamic> data) => AttendanceRow(data);
}

class AttendanceRow extends SupabaseDataRow {
  AttendanceRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get workDate => getField<DateTime>('work_date')!;
  set workDate(DateTime value) => setField<DateTime>('work_date', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  String? get note => getField<String>('note');
  set note(String? value) => setField<String>('note', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
