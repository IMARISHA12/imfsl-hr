import '../database.dart';

class GpsDevicesTable extends SupabaseTable<GpsDevicesRow> {
  @override
  String get tableName => 'gps_devices';

  @override
  GpsDevicesRow createRow(Map<String, dynamic> data) => GpsDevicesRow(data);
}

class GpsDevicesRow extends SupabaseDataRow {
  GpsDevicesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => GpsDevicesTable();

  String get imei => getField<String>('imei')!;
  set imei(String value) => setField<String>('imei', value);

  String? get provider => getField<String>('provider');
  set provider(String? value) => setField<String>('provider', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get simNumber => getField<String>('sim_number');
  set simNumber(String? value) => setField<String>('sim_number', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
