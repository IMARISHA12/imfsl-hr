import '../database.dart';

class AttendanceLogsTable extends SupabaseTable<AttendanceLogsRow> {
  @override
  String get tableName => 'attendance_logs';

  @override
  AttendanceLogsRow createRow(Map<String, dynamic> data) =>
      AttendanceLogsRow(data);
}

class AttendanceLogsRow extends SupabaseDataRow {
  AttendanceLogsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AttendanceLogsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  String? get branch => getField<String>('branch');
  set branch(String? value) => setField<String>('branch', value);

  String get signType => getField<String>('sign_type')!;
  set signType(String value) => setField<String>('sign_type', value);

  DateTime? get ts => getField<DateTime>('ts');
  set ts(DateTime? value) => setField<DateTime>('ts', value);

  String? get geo => getField<String>('geo');
  set geo(String? value) => setField<String>('geo', value);

  String? get deviceId => getField<String>('device_id');
  set deviceId(String? value) => setField<String>('device_id', value);

  String? get attachmentUrl => getField<String>('attachment_url');
  set attachmentUrl(String? value) => setField<String>('attachment_url', value);

  bool? get isLate => getField<bool>('is_late');
  set isLate(bool? value) => setField<bool>('is_late', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  double? get latitude => getField<double>('latitude');
  set latitude(double? value) => setField<double>('latitude', value);

  double? get longitude => getField<double>('longitude');
  set longitude(double? value) => setField<double>('longitude', value);

  double? get locationAccuracy => getField<double>('location_accuracy');
  set locationAccuracy(double? value) =>
      setField<double>('location_accuracy', value);

  double? get distanceFromOffice => getField<double>('distance_from_office');
  set distanceFromOffice(double? value) =>
      setField<double>('distance_from_office', value);

  String? get officeLocationId => getField<String>('office_location_id');
  set officeLocationId(String? value) =>
      setField<String>('office_location_id', value);

  String? get validationStatus => getField<String>('validation_status');
  set validationStatus(String? value) =>
      setField<String>('validation_status', value);

  String? get failureReason => getField<String>('failure_reason');
  set failureReason(String? value) => setField<String>('failure_reason', value);
}
