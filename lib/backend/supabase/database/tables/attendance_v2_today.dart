import '../database.dart';

class AttendanceV2TodayTable extends SupabaseTable<AttendanceV2TodayRow> {
  @override
  String get tableName => 'attendance_v2_today';

  @override
  AttendanceV2TodayRow createRow(Map<String, dynamic> data) =>
      AttendanceV2TodayRow(data);
}

class AttendanceV2TodayRow extends SupabaseDataRow {
  AttendanceV2TodayRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceV2TodayTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get staffId => getField<String>('staff_id');
  set staffId(String? value) => setField<String>('staff_id', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  DateTime? get clockIn => getField<DateTime>('clock_in');
  set clockIn(DateTime? value) => setField<DateTime>('clock_in', value);

  DateTime? get clockOut => getField<DateTime>('clock_out');
  set clockOut(DateTime? value) => setField<DateTime>('clock_out', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
