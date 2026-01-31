import '../database.dart';

class AttendanceSettingsTable extends SupabaseTable<AttendanceSettingsRow> {
  @override
  String get tableName => 'attendance_settings';

  @override
  AttendanceSettingsRow createRow(Map<String, dynamic> data) =>
      AttendanceSettingsRow(data);
}

class AttendanceSettingsRow extends SupabaseDataRow {
  AttendanceSettingsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceSettingsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get officeName => getField<String>('office_name')!;
  set officeName(String value) => setField<String>('office_name', value);

  double? get officeLatitude => getField<double>('office_latitude');
  set officeLatitude(double? value) =>
      setField<double>('office_latitude', value);

  double? get officeLongitude => getField<double>('office_longitude');
  set officeLongitude(double? value) =>
      setField<double>('office_longitude', value);

  int get allowedRadiusMeters => getField<int>('allowed_radius_meters')!;
  set allowedRadiusMeters(int value) =>
      setField<int>('allowed_radius_meters', value);

  PostgresTime get workStartTime => getField<PostgresTime>('work_start_time')!;
  set workStartTime(PostgresTime value) =>
      setField<PostgresTime>('work_start_time', value);

  PostgresTime get workEndTime => getField<PostgresTime>('work_end_time')!;
  set workEndTime(PostgresTime value) =>
      setField<PostgresTime>('work_end_time', value);

  int get gracePeriodMinutes => getField<int>('grace_period_minutes')!;
  set gracePeriodMinutes(int value) =>
      setField<int>('grace_period_minutes', value);

  bool get isGeofencingEnabled => getField<bool>('is_geofencing_enabled')!;
  set isGeofencingEnabled(bool value) =>
      setField<bool>('is_geofencing_enabled', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);
}
