import '../database.dart';

class StaffAttendanceV3Table extends SupabaseTable<StaffAttendanceV3Row> {
  @override
  String get tableName => 'staff_attendance_v3';

  @override
  StaffAttendanceV3Row createRow(Map<String, dynamic> data) =>
      StaffAttendanceV3Row(data);
}

class StaffAttendanceV3Row extends SupabaseDataRow {
  StaffAttendanceV3Row(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => StaffAttendanceV3Table();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get staffId => getField<String>('staff_id')!;
  set staffId(String value) => setField<String>('staff_id', value);

  DateTime get workDate => getField<DateTime>('work_date')!;
  set workDate(DateTime value) => setField<DateTime>('work_date', value);

  DateTime? get clockInTime => getField<DateTime>('clock_in_time');
  set clockInTime(DateTime? value) =>
      setField<DateTime>('clock_in_time', value);

  double? get clockInLatitude => getField<double>('clock_in_latitude');
  set clockInLatitude(double? value) =>
      setField<double>('clock_in_latitude', value);

  double? get clockInLongitude => getField<double>('clock_in_longitude');
  set clockInLongitude(double? value) =>
      setField<double>('clock_in_longitude', value);

  String? get clockInGeofenceId => getField<String>('clock_in_geofence_id');
  set clockInGeofenceId(String? value) =>
      setField<String>('clock_in_geofence_id', value);

  bool? get clockInWithinGeofence => getField<bool>('clock_in_within_geofence');
  set clockInWithinGeofence(bool? value) =>
      setField<bool>('clock_in_within_geofence', value);

  String? get clockInDeviceId => getField<String>('clock_in_device_id');
  set clockInDeviceId(String? value) =>
      setField<String>('clock_in_device_id', value);

  String? get clockInBiometricHash =>
      getField<String>('clock_in_biometric_hash');
  set clockInBiometricHash(String? value) =>
      setField<String>('clock_in_biometric_hash', value);

  String? get clockInPhotoPath => getField<String>('clock_in_photo_path');
  set clockInPhotoPath(String? value) =>
      setField<String>('clock_in_photo_path', value);

  DateTime? get clockOutTime => getField<DateTime>('clock_out_time');
  set clockOutTime(DateTime? value) =>
      setField<DateTime>('clock_out_time', value);

  double? get clockOutLatitude => getField<double>('clock_out_latitude');
  set clockOutLatitude(double? value) =>
      setField<double>('clock_out_latitude', value);

  double? get clockOutLongitude => getField<double>('clock_out_longitude');
  set clockOutLongitude(double? value) =>
      setField<double>('clock_out_longitude', value);

  String? get clockOutGeofenceId => getField<String>('clock_out_geofence_id');
  set clockOutGeofenceId(String? value) =>
      setField<String>('clock_out_geofence_id', value);

  bool? get clockOutWithinGeofence =>
      getField<bool>('clock_out_within_geofence');
  set clockOutWithinGeofence(bool? value) =>
      setField<bool>('clock_out_within_geofence', value);

  String? get clockOutDeviceId => getField<String>('clock_out_device_id');
  set clockOutDeviceId(String? value) =>
      setField<String>('clock_out_device_id', value);

  int? get workMinutes => getField<int>('work_minutes');
  set workMinutes(int? value) => setField<int>('work_minutes', value);

  int? get overtimeMinutes => getField<int>('overtime_minutes');
  set overtimeMinutes(int? value) => setField<int>('overtime_minutes', value);

  bool? get isLate => getField<bool>('is_late');
  set isLate(bool? value) => setField<bool>('is_late', value);

  int? get lateMinutes => getField<int>('late_minutes');
  set lateMinutes(int? value) => setField<int>('late_minutes', value);

  bool? get isEarlyDeparture => getField<bool>('is_early_departure');
  set isEarlyDeparture(bool? value) =>
      setField<bool>('is_early_departure', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  String? get notes => getField<String>('notes');
  set notes(String? value) => setField<String>('notes', value);

  bool? get requiresApproval => getField<bool>('requires_approval');
  set requiresApproval(bool? value) =>
      setField<bool>('requires_approval', value);

  String? get approvedBy => getField<String>('approved_by');
  set approvedBy(String? value) => setField<String>('approved_by', value);

  DateTime? get approvedAt => getField<DateTime>('approved_at');
  set approvedAt(DateTime? value) => setField<DateTime>('approved_at', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
