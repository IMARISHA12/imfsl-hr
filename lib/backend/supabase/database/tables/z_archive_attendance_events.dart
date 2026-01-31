import '../database.dart';

class ZArchiveAttendanceEventsTable
    extends SupabaseTable<ZArchiveAttendanceEventsRow> {
  @override
  String get tableName => 'z_archive_attendance_events';

  @override
  ZArchiveAttendanceEventsRow createRow(Map<String, dynamic> data) =>
      ZArchiveAttendanceEventsRow(data);
}

class ZArchiveAttendanceEventsRow extends SupabaseDataRow {
  ZArchiveAttendanceEventsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ZArchiveAttendanceEventsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get employeeId => getField<String>('employee_id')!;
  set employeeId(String value) => setField<String>('employee_id', value);

  String get eventType => getField<String>('event_type')!;
  set eventType(String value) => setField<String>('event_type', value);

  DateTime get at => getField<DateTime>('at')!;
  set at(DateTime value) => setField<DateTime>('at', value);

  double? get lat => getField<double>('lat');
  set lat(double? value) => setField<double>('lat', value);

  double? get lon => getField<double>('lon');
  set lon(double? value) => setField<double>('lon', value);

  String? get method => getField<String>('method');
  set method(String? value) => setField<String>('method', value);

  String? get idempotencyKey => getField<String>('idempotency_key');
  set idempotencyKey(String? value) =>
      setField<String>('idempotency_key', value);

  dynamic get meta => getField<dynamic>('meta');
  set meta(dynamic value) => setField<dynamic>('meta', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}
