import '../database.dart';

class AttendanceV2Table extends SupabaseTable<AttendanceV2Row> {
  @override
  String get tableName => 'attendance_v2';

  @override
  AttendanceV2Row createRow(Map<String, dynamic> data) => AttendanceV2Row(data);
}

class AttendanceV2Row extends SupabaseDataRow {
  AttendanceV2Row(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceV2Table();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  DateTime? get clockIn => getField<DateTime>('clock_in');
  set clockIn(DateTime? value) => setField<DateTime>('clock_in', value);

  DateTime? get clockOut => getField<DateTime>('clock_out');
  set clockOut(DateTime? value) => setField<DateTime>('clock_out', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
