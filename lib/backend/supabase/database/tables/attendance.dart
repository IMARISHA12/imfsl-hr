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

  PostgresTime? get clockIn => getField<PostgresTime>('clock_in');
  set clockIn(PostgresTime? value) => setField<PostgresTime>('clock_in', value);

  PostgresTime? get clockOut => getField<PostgresTime>('clock_out');
  set clockOut(PostgresTime? value) =>
      setField<PostgresTime>('clock_out', value);

  double? get clockInGpsLat => getField<double>('clock_in_gps_lat');
  set clockInGpsLat(double? value) =>
      setField<double>('clock_in_gps_lat', value);

  double? get clockInGpsLng => getField<double>('clock_in_gps_lng');
  set clockInGpsLng(double? value) =>
      setField<double>('clock_in_gps_lng', value);

  int? get lateMinutes => getField<int>('late_minutes');
  set lateMinutes(int? value) => setField<int>('late_minutes', value);

  int? get overtimeMinutes => getField<int>('overtime_minutes');
  set overtimeMinutes(int? value) => setField<int>('overtime_minutes', value);
}
