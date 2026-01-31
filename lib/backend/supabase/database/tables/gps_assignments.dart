import '../database.dart';

class GpsAssignmentsTable extends SupabaseTable<GpsAssignmentsRow> {
  @override
  String get tableName => 'gps_assignments';

  @override
  GpsAssignmentsRow createRow(Map<String, dynamic> data) =>
      GpsAssignmentsRow(data);
}

class GpsAssignmentsRow extends SupabaseDataRow {
  GpsAssignmentsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GpsAssignmentsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get loanId => getField<String>('loan_id')!;
  set loanId(String value) => setField<String>('loan_id', value);

  String get technicianId => getField<String>('technician_id')!;
  set technicianId(String value) => setField<String>('technician_id', value);

  String? get deviceImei => getField<String>('device_imei');
  set deviceImei(String? value) => setField<String>('device_imei', value);

  String? get installationPhotoUrl =>
      getField<String>('installation_photo_url');
  set installationPhotoUrl(String? value) =>
      setField<String>('installation_photo_url', value);

  String? get chassisPhotoUrl => getField<String>('chassis_photo_url');
  set chassisPhotoUrl(String? value) =>
      setField<String>('chassis_photo_url', value);

  String? get installationLocationGps =>
      getField<String>('installation_location_gps');
  set installationLocationGps(String? value) =>
      setField<String>('installation_location_gps', value);

  bool? get signalVerified => getField<bool>('signal_verified');
  set signalVerified(bool? value) => setField<bool>('signal_verified', value);

  String? get jobStatus => getField<String>('job_status');
  set jobStatus(String? value) => setField<String>('job_status', value);

  DateTime? get completedAt => getField<DateTime>('completed_at');
  set completedAt(DateTime? value) => setField<DateTime>('completed_at', value);
}
