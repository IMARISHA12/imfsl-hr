import '../database.dart';

class AttendanceRecordsTable extends SupabaseTable<AttendanceRecordsRow> {
  @override
  String get tableName => 'attendance_records';

  @override
  AttendanceRecordsRow createRow(Map<String, dynamic> data) =>
      AttendanceRecordsRow(data);
}

class AttendanceRecordsRow extends SupabaseDataRow {
  AttendanceRecordsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceRecordsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get clockIn => getField<DateTime>('clock_in')!;
  set clockIn(DateTime value) => setField<DateTime>('clock_in', value);

  DateTime? get clockOut => getField<DateTime>('clock_out');
  set clockOut(DateTime? value) => setField<DateTime>('clock_out', value);

  String? get dailyReport => getField<String>('daily_report');
  set dailyReport(String? value) => setField<String>('daily_report', value);

  int? get managerRating => getField<int>('manager_rating');
  set managerRating(int? value) => setField<int>('manager_rating', value);

  String? get managerNotes => getField<String>('manager_notes');
  set managerNotes(String? value) => setField<String>('manager_notes', value);

  String? get ratedBy => getField<String>('rated_by');
  set ratedBy(String? value) => setField<String>('rated_by', value);

  DateTime? get ratedAt => getField<DateTime>('rated_at');
  set ratedAt(DateTime? value) => setField<DateTime>('rated_at', value);

  DateTime get workDate => getField<DateTime>('work_date')!;
  set workDate(DateTime value) => setField<DateTime>('work_date', value);

  double? get hoursWorked => getField<double>('hours_worked');
  set hoursWorked(double? value) => setField<double>('hours_worked', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  bool? get isLate => getField<bool>('is_late');
  set isLate(bool? value) => setField<bool>('is_late', value);

  int? get lateMinutes => getField<int>('late_minutes');
  set lateMinutes(int? value) => setField<int>('late_minutes', value);
}
