import '../database.dart';

class FinIotTrackingTable extends SupabaseTable<FinIotTrackingRow> {
  @override
  String get tableName => 'fin_iot_tracking';

  @override
  FinIotTrackingRow createRow(Map<String, dynamic> data) =>
      FinIotTrackingRow(data);
}

class FinIotTrackingRow extends SupabaseDataRow {
  FinIotTrackingRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FinIotTrackingTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get vehicleId => getField<String>('vehicle_id');
  set vehicleId(String? value) => setField<String>('vehicle_id', value);

  String get gpsDeviceImei => getField<String>('gps_device_imei')!;
  set gpsDeviceImei(String value) => setField<String>('gps_device_imei', value);

  String? get currentGpsState => getField<String>('current_gps_state');
  set currentGpsState(String? value) =>
      setField<String>('current_gps_state', value);

  double? get lastLocationLat => getField<double>('last_location_lat');
  set lastLocationLat(double? value) =>
      setField<double>('last_location_lat', value);

  double? get lastLocationLong => getField<double>('last_location_long');
  set lastLocationLong(double? value) =>
      setField<double>('last_location_long', value);

  bool? get isImmobilized => getField<bool>('is_immobilized');
  set isImmobilized(bool? value) => setField<bool>('is_immobilized', value);

  DateTime? get lastPingTime => getField<DateTime>('last_ping_time');
  set lastPingTime(DateTime? value) =>
      setField<DateTime>('last_ping_time', value);
}
